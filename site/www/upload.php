<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    $dbh->query('START TRANSACTION');
    $scan = add_scan($dbh);
    $dbh->query('COMMIT');

    $post = s3_get_post_details($scan['id'], time() + 300);

    $sm = get_smarty_instance();
    $sm->assign('post', $post);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("upload.html.tpl");

?>
