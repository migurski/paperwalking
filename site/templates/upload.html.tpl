<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Untitled</title>
</head>
<body>

    <form action="http://{$post.bucket|escape}.s3.amazonaws.com/" method="post" enctype="multipart/form-data">
        <input name="AWSAccessKeyId" type="hidden" value="{$post.access|escape}">
        <input name="acl" type="hidden" value="{$post.acl|escape}">
        <input name="key" type="hidden" value="{$post.key|escape}">
        <input name="redirect" type="hidden" value="{$post.redirect|escape}">
    
        <input name="policy" type="hidden" value="{$post.policy|escape}">
        <input name="signature" type="hidden" value="{$post.signature|escape}">
        
        <input name="file" type="file">
        <input type="submit" value="Upload It!">
    </form>
    
</body>
</html>
