<?php

    require_once 'Smarty/Smarty.class.php';

   /**
    * @return   Smarty  Locally-usable Smarty instance.
    */
    function get_smarty_instance()
    {
        $s = new Smarty();

        $s->compile_dir = join(DIRECTORY_SEPARATOR, array(dirname(__FILE__), '..', 'templates', 'cache'));
        $s->cache_dir = join(DIRECTORY_SEPARATOR, array(dirname(__FILE__), '..', 'templates', 'cache'));

        $s->template_dir = join(DIRECTORY_SEPARATOR, array(dirname(__FILE__), '..', 'templates'));
        $s->config_dir = join(DIRECTORY_SEPARATOR, array(dirname(__FILE__), '..', 'templates'));
        
        $s->assign('domain', get_domain_name());
        $s->assign('base_dir', get_base_dir());
        $s->assign('base_href', get_base_href());
        $s->assign('constants', get_defined_constants());
        $s->assign('request', array('get' => $_GET, 'uri' => $_SERVER['REQUEST_URI']));
        $s->assign('providers', get_map_providers());
        
        $s->register_modifier('nice_relativetime', 'nice_relativetime');
        $s->register_modifier('nice_datetime', 'nice_datetime');
        $s->register_modifier('nice_degree', 'nice_degree');
        $s->register_modifier('step_description', 'step_description');
        
        return $s;
    }
    
    function get_domain_name()
    {
        if(php_sapi_name() == 'cli')
            return CLI_DOMAIN_NAME;
        
        $server_name = defined('SERVER_NAME') ? SERVER_NAME : $_SERVER['SERVER_NAME'];
        
        if($_SERVER['SERVER_PORT'] != 80)
            return "{$server_name}:{$_SERVER['SERVER_PORT']}";
        
        return $server_name;
    }
    
    function get_base_dir()
    {
        if(php_sapi_name() == 'cli')
            return CLI_BASE_DIRECTORY;
        
        return rtrim(str_replace(' ', '%20', dirname($_SERVER['SCRIPT_NAME'])), DIRECTORY_SEPARATOR);
    }
    
    function get_base_href()
    {
        if(php_sapi_name() == 'cli')
            return '';
        
        $query_pos = strpos($_SERVER['REQUEST_URI'], '?');
        
        return ($query_pos === false) ? $_SERVER['REQUEST_URI']
                                      : substr($_SERVER['REQUEST_URI'], 0, $query_pos);
    }
    
    function get_map_providers()
    {
        if(preg_match_all('#^(http://\S+)\b\s+\b(.+)$#mi', TILE_PROVIDERS, $m))
            return array_map(null, $m[1], $m[2]);
    
        return array(array('http://tile.openstreetmap.org/{Z}/{X}/{Y}.png', 'OpenStreetMap'));
    }
    
    function nice_datetime($ts)
    {
        return date('l, M j Y, g:ia T', $ts);
    }
    
    function nice_relativetime($seconds)
    {
        switch(true)
        {
            case abs($seconds) <= 90:
                return 'moments ago';

            case abs($seconds) <= 90 * 60:
                return round(abs($seconds) / 60).' minutes ago';

            case abs($seconds) <= 36 * 60 * 60:
                return round(abs($seconds) / (60 * 60)).' hours ago';

            default:
                return round(abs($seconds) / (24 * 60 * 60)).' days ago';
        }
    }
    
    function nice_degree($str, $axis)
    {
        if(is_numeric($str))
        {
            $val = floatval($str);
            
            $dir = $val;
            $val = abs($val);

            $deg = floor($val);
            $val = ($val - $deg) * 60;
            
            $min = floor($val);
            $val = ($val - $min) * 60;
            
            $sec = floor($val);
            
            if($axis == 'lat') {
                $dir = ($dir >= 0) ? 'N' : 'S';
            } else {
                $dir = ($dir >= 0) ? 'E' : 'W';
            }
            
            return sprintf('%d°%02d\'%02d"%s', $deg, $min, $sec, $dir);
        }

        return $str;
    }
    
    function step_description($number)
    {
        return get_step_description($number);
    }
    
    function print_headers($print)
    {
        header(sprintf('X-Print-ID: %s', $print['id']));
        header(sprintf('X-Print-User-ID: %s', $print['user_id']));
        header(sprintf('X-Print-Paper: %s %s', $print['paper_size'], $print['orientation']));
        header(sprintf('X-Print-Provider: %s', $print['provider']));
        header(sprintf('X-Print-PDF-URL: %s', $print['pdf_url']));
        header(sprintf('X-Print-Preview-URL: %s', $print['preview_url']));
        header(sprintf('X-Print-Bounds: %.6f %.6f %.6f %.6f', $print['south'], $print['west'], $print['north'], $print['east']));
        header(sprintf('X-Print-Center: %.6f %.6f %d', $print['latitude'], $print['longitude'], $print['zoom']));
        header(sprintf('X-Print-Country: %s (woeid %d)', $print['country_name'], $print['country_woeid']));
        header(sprintf('X-Print-Region: %s (woeid %d)', $print['region_name'], $print['region_woeid']));
        header(sprintf('X-Print-Place: %s (woeid %d)', $print['place_name'], $print['place_woeid']));
    }
    
    function scan_headers($scan)
    {
        header(sprintf('X-Scan-ID: %s', $scan['id']));
        header(sprintf('X-Scan-User-ID: %s', $scan['user_id']));
        header(sprintf('X-Scan-Finished: %s', ($scan['last_step'] == STEP_FINISHED) ? 'yes' : 'no'));
        //header(sprintf('X-Scan-Private: %s', $scan['is_private']));
        header(sprintf('X-Scan-Will-Edit: %s', $scan['will_edit']));
        header(sprintf('X-Scan-Minimum-Coord: %.3f %.3f %d', $scan['min_row'], $scan['min_column'], $scan['min_zoom']));
        header(sprintf('X-Scan-Maximum-Coord: %.3f %.3f %d', $scan['max_row'], $scan['max_column'], $scan['max_zoom']));
        header(sprintf('X-Scan-Provider-URL: %s/{Z}/{X}/{Y}.jpg', $scan['base_url']));
        header(sprintf('X-Scan-QRCode-URL: %s/qrcode.jpg', $scan['base_url']));
        header(sprintf('X-Scan-Preview-URL: %s/preview.jpg', $scan['base_url']));
        header(sprintf('X-Scan-Large-URL: %s/large.jpg', $scan['base_url']));
    }
    
    function modify_scan_for_json($scan)
    {
        unset($scan['last_step']);
        unset($scan['age']);

        $scan['min_row'] = floatval($scan['min_row']);
        $scan['min_column'] = floatval($scan['min_column']);
        $scan['min_zoom'] = intval($scan['min_zoom']);
        $scan['max_row'] = floatval($scan['max_row']);
        $scan['max_column'] = floatval($scan['max_column']);
        $scan['max_zoom'] = intval($scan['max_zoom']);
        $scan['created'] = intval($scan['created']);
        $scan['large_url'] = $scan['base_url'].'/large.jpg';
        $scan['qrcode_url'] = $scan['base_url'].'/qrcode.jpg';
        $scan['preview_url'] = $scan['base_url'].'/preview.jpg';
        
        return $scan;
    }
    
    function modify_scan_for_geojson($scan, $print)
    {
        $type = 'Feature';
        $properties = $scan;
        $id = $properties['id'];
        
        $n = floatval($print['north']);
        $s = floatval($print['south']);
        $w = floatval($print['west']);
        $e = floatval($print['east']);

        $perimeter = array(array($w, $n), array($e, $n), array($e, $s), array($w, $s), array($w, $n));
        $geometry = array('type' => 'Polygon', 'coordinates' => array($perimeter));

        return compact('type', 'id', 'geometry', 'properties');
    }
    
    function enforce_master_on_off_switch($language)
    {
        if(defined('MASTER_ON_OFF_SWITCH') and MASTER_ON_OFF_SWITCH)
            return;

        $sm = get_smarty_instance();
        $sm->assign('language', $language);
        header('Retry-After: 300'); // let's just say five minutes
        die_with_code(503, $sm->fetch("unavailable.html.tpl"));
    }
    
    function die_with_code($code, $message)
    {
        if($code != 503)
            error_log("die_with_code: $code, $message");

        header("HTTP/1.1 {$code}");
        die($message);
    }

?>
