<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    $user_id = $_COOKIE['visitor'] ? $_COOKIE['visitor'] : null;

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    $user = $user_id ? get_user($dbh, $user_id) : add_user($dbh);

    if($user)
        setcookie('visitor', $user['id'], time() + 86400 * 31);
    
    $dbh->query('START TRANSACTION');
    $scan = add_scan($dbh, $user['id']);
    $dbh->query('COMMIT');

    $post = s3_get_post_details($scan['id'], time() + 600);

    $sm = get_smarty_instance();
    $sm->assign('post', $post);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("upload.html.tpl");

?>
