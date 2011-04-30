<?php
   /**
    * Display page for a single print with a given ID.
    *
    * When this page receives a POST request, it's probably from compose.py
    * (check the API_PASSWORD) with new information on print components for
    * building into a new PDF.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';

    $print_id = $_GET['id'] ? $_GET['id'] : null;
    
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);
    
    enforce_master_on_off_switch($language);

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($user_id)
        $user = get_user($dbh, $user_id);

    if($user)
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);
    
    $print = get_print($dbh, $print_id);
    
    if($print && $_SERVER['REQUEST_METHOD'] == 'POST')
    {
        if($_POST['password'] != API_PASSWORD)
            die_with_code(401, 'Sorry, bad password');
        
        // we accept a subset of print properties here
        foreach(array('north', 'south', 'east', 'west', 'zoom', 'paper', 'last_step') as $field)
            if(isset($_POST[$field]))
                $print[$field] = $_POST[$field];
        
        add_log($dbh, "Posting additional details to print {$print['id']}");

        if($_POST['last_step'] == STEP_FINISHED)
        {
            $print_data = json_decode($_POST['print_data'], true);
            $atlas_pages = array();
            
            foreach($print_data['pages'] as $page)
                if($page['part'])
                    $atlas_pages[] = $page;
            
            $print['pdf_url'] = $_POST['pdf_url'];
            $print['preview_url'] = $_POST['preview_url'];
            $print['last_step'] = $_POST['last_step'];
            $print['atlas_pages'] = json_encode($atlas_pages);
        }
        
        $north = $print['north'];
        $south = $print['south'];
        $east = $print['east'];
        $west = $print['west'];
        $zoom = $print['zoom'];
        
        if(isset($north) && isset($south) && isset($east) && isset($west) && $zoom)
        {
            list($print['country_name'], $print['country_woeid'],
                 $print['region_name'], $print['region_woeid'],
                 $print['place_name'], $print['place_woeid'])
             = latlon_placeinfo(($north + $south) / 2, ($west + $east) / 2, $zoom - 1);
        }
        
        $dbh->query('START TRANSACTION');
        $print = set_print($dbh, $print);
        $dbh->query('COMMIT');
    }
    
    $sm = get_smarty_instance();
    $sm->assign('print', $print);
    $sm->assign('language', $language);
    
    print_headers($print);

    $type = $_GET['type'] ? $_GET['type'] : $_SERVER['HTTP_ACCEPT'];
    $type = get_preferred_type($type, array('text/html', 'application/paperwalking+xml'));
    
    if($type == 'text/html') {
        header("Content-Type: text/html; charset=UTF-8");
        print $sm->fetch("print.html.tpl");
    
    } elseif($type == 'application/paperwalking+xml') { 
        header("Content-Type: application/paperwalking+xml; charset=UTF-8");
        print '<'.'?xml version="1.0" encoding="utf-8"?'.">\n";
        print $sm->fetch("print.xml.tpl");
    
    } else {
        header('HTTP/1.1 406');
        die("Unknown content-type.\n");
    }

?>
