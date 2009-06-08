<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    $user_id = $_COOKIE['visitor'] ? $_COOKIE['visitor'] : null;

    /**** ... ****/
    
    $sm = get_smarty_instance();
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("errata.html.tpl");

?>
