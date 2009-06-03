<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Uploaded Walking Papers</title>
	<link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    <h2>Uploaded A Scanned Map</h2>
    
    <p>
        (explanation)
    </p>
    
    <form action="{$base_dir}/uploaded.php" method="post" enctype="multipart/form-data">
        <p>
            private?
            <input type="checkbox" value="yes" name="private" {if $scan.is_private == 'yes'}checked="checked"{/if} />
        </p>
    
        <p>
            will edit?
            <input type="checkbox" value="yes" name="edit" {if $scan.will_edit == 'yes'}checked="checked"{/if} />
        </p>
    
        <input type="hidden" name="scan" value="{$scan.id|escape}">
        <input type="submit" value="Yes Please">
    </form>
    
    <pre>{$scan|@print_r:1|escape}</pre>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
