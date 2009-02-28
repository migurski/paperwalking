<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    $scan_id = $_GET['id'] ? $_GET['id'] : null;
    
    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    $scan = get_scan($dbh, $scan_id);
    
    if($scan)
    {
        $step = get_step($dbh, $scan['id']);

        header('Content-Type: text/plain');
        print_r($scan);
        print_r($step);
    }

?>
