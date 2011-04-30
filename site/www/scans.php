<?php
   /**
    * Display page for list of all recent scans in reverse-chronological order.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    enforce_master_on_off_switch($language);

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($user_id)
        $user = get_user($dbh, $user_id);

    if($user)
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);
    
    $pagination = array('page' => $_GET['page'], 'perpage' => $_GET['perpage']);
    
    $scans = get_scans($dbh, $pagination, false);
    $prints = array();
    
    foreach($scans as $i => $scan)
    {
        if(is_null($scan['print_latitude'])) {
            $prints[$i] = false;
        
        } else {
            $prints[$i] = get_print($dbh, $scan['print_id']);
        }
    }

    $type = $_GET['type'] ? $_GET['type'] : $_SERVER['HTTP_ACCEPT'];
    $type = get_preferred_type($type, array('text/html', 'application/json'));
    
    if($type == 'text/html') {
        list($count, $offset, $perpage, $page) = get_pagination($pagination);
    
        $sm = get_smarty_instance();
        $sm->assign('scans', $scans);
        $sm->assign('language', $language);
    
        $sm->assign('count', $count);
        $sm->assign('offset', $offset);
        $sm->assign('perpage', $perpage);
        $sm->assign('page', $page);
        
        header("Content-Type: text/html; charset=UTF-8");
        print $sm->fetch("scans.html.tpl");
    
    } elseif($type == 'application/json') { 
       /*
        * Convert to GeoJSON using prints information.
        */
        $scans_prints = array_map(null, $scans, $prints);

        $features = array();
        $leftover = array();
        
        foreach($scans_prints as $i => $scan_print)
        {
            list($scan, $print) = $scan_print;
            
            if($print) {
                $features[] = modify_scan_for_geojson($scan, $print);

            } else {
                $leftover[] = modify_scan_for_json($scan);
            }
        }
        
        $type = 'FeatureCollection';
        $response = compact('type', 'features', 'leftover');

        header("Content-Type: application/json; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        echo json_encode($response)."\n";
    
    } else {
        header('HTTP/1.1 406');
        die("Unknown content-type.\n");
    }

?>
