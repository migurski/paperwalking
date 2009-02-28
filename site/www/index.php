<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    /**** ... ****/
    
    $dbh =& get_db_connection();

    $post = s3_get_post_details(time() + 300);

?>
<form action="http://<?= htmlspecialchars($post['bucket']) ?>.s3.amazonaws.com/" method="post" enctype="multipart/form-data">
    <input name="AWSAccessKeyId" type="hidden" value="<?= htmlspecialchars($post['access']) ?>">
    <input name="acl" type="hidden" value="<?= htmlspecialchars($post['acl']) ?>">
    <input name="key" type="hidden" value="<?= htmlspecialchars($post['key']) ?>">
    <input name="redirect" type="hidden" value="<?= htmlspecialchars($post['redirect']) ?>">

    <input name="policy" type="hidden" value="<?= htmlspecialchars($post['policy']) ?>">
    <input name="signature" type="hidden" value="<?= htmlspecialchars($post['signature']) ?>">
    
    <input name="file" type="file">
    <input type="submit" value="Upload It!">
</form>
