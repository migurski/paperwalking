<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    $scan_id = $_GET['scan'] ? $_GET['scan'] : null;
    $object_id = $_GET['key'] ? $_GET['key'] : null;
    $expected_etag = $_GET['etag'] ? $_GET['etag'] : null;
    list($user_id, $language) = read_userdata($_COOKIE['visitor'], $_SERVER['HTTP_ACCEPT_LANGUAGE']);

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($user_id)
        $user = get_user($dbh, $user_id);

    if($user)
        setcookie('visitor', write_userdata($user['id'], $language), time() + 86400 * 31);
    
    if($scan_id)
        $scan = get_scan($dbh, $scan_id);

    if($scan && $object_id && $expected_etag)
    {
        $url = s3_signed_object_url($object_id, time() + 300, 'HEAD');
        $etag_match = verify_s3_etag($object_id, $expected_etag);
        
        if($etag_match && $scan && $scan['last_step'] <= 1)
        {
            $dbh->query('START TRANSACTION');

            $added = add_step($dbh, $scan['id'], 1);
            
            if($added)
                add_message($dbh, s3_unsigned_object_url($object_id));
            
            $scan = get_scan($dbh, $scan['id']);
            
            $dbh->query('COMMIT');
            
            //header('Location: http://'.get_domain_name().get_base_dir().'/scan.php?id='.urlencode($scan['id']));
            //exit();
        }

        header('Location: http://'.get_domain_name().get_base_dir().'/uploaded.php?scan='.urlencode($scan['id']));
    }
    
    $sm = get_smarty_instance();
    $sm->assign('scan', $scan);
    $sm->assign('language', $language);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("uploaded.html.tpl");

?>
