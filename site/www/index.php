<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    /*
    $scan_id = $_GET['scan'] ? $_GET['scan'] : null;
    */
    
    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    $sm = get_smarty_instance();
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("index.html.tpl");

?>
