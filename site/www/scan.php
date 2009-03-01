<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    $scan_id = $_GET['id'] ? $_GET['id'] : null;
    
    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    $scan = get_scan($dbh, $scan_id);
    
    if($_SERVER['REQUEST_METHOD'] == 'POST')
    {
        if($scan)
        {
            $scan = array('id' => $scan_id,
                          'print_id' => $_POST['print_id'],
                          'last_step' => $_POST['last_step'],
                          'user_name' => $_POST['user_name'],
                          'min_row' => $_POST['min_row'],
                          'min_column' => $_POST['min_column'],
                          'min_zoom' => $_POST['min_zoom'],
                          'max_row' => $_POST['max_row'],
                          'max_column' => $_POST['max_column'],
                          'max_zoom' => $_POST['max_zoom']);
            
            $dbh->query('START TRANSACTION');
            $scan = set_scan($dbh, $scan);
            $dbh->query('COMMIT');
        }
    }
    
    header('Content-Type: text/plain');
    print_r($scan);

    if($scan)
    {
        $step = get_step($dbh, $scan['id']);
        print_r($step);
    }

?>
