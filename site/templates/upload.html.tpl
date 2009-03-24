<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Upload Walking Papers</title>
	<link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
</head>
<body>

    <h1><a href="{$base_dir}/"><img src="{$base_dir}/icon.png" border="0" align="bottom" alt="" /> Walking Papers</a></h1>
    
    <p>
        (explanation)
    </p>
    
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
    
    <p id="footer">
        &copy;2009 <a href="http://mike.teczno.com">Michal Migurski</a>, <a href="http://stamen.com">Stamen Design</a>
    </p>
    
</body>
</html>
