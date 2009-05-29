<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Walking Papers</title>
	<link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    <h2>Recent Scans</h2>
    
    <ol>
        {foreach from=$scans item="scan"}
            <li>
                <a href="{$base_dir}/scan.php?id={$scan.id|escape}">
                    <b id="scan-{$scan.id|escape}">{$scan.age|nice_relativetime|escape}</b></a>
                <script type="text/javascript" language="javascript1.2" defer="defer">
                // <![CDATA[
                
                    var onPlaces_{$scan.id|escape} = new Function('res', "appendPlacename(res, document.getElementById('scan-{$scan.id|escape}'))");
                    getPlacename({$scan.print_latitude|escape}, {$scan.print_longitude|escape}, '{$constants.FLICKR_KEY|escape}', 'onPlaces_{$scan.id|escape}');
            
                // ]]>
                </script>
            </li>
        {/foreach}
    </ol>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
