<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    $print_id = $_GET['id'] ? $_GET['id'] : null;
    
    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    $print = get_print($dbh, $print_id);
    
    $sm = get_smarty_instance();
    $sm->assign('print', $print);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("print.html.tpl");

?>
