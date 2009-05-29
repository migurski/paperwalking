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
    
    <h2>Recent Prints</h2>
    
    <ol>
        {foreach from=$prints item="print"}
            <li>
                <a href="{$base_dir}/print.php?id={$print.id|escape}">
                    <b id="print-{$print.id|escape}">{$print.age|nice_relativetime|escape}</b></a>
                <script type="text/javascript" language="javascript1.2" defer="defer">
                // <![CDATA[
                
                    var onPlaces_{$print.id|escape} = new Function('res', "appendPlacename(res, document.getElementById('print-{$print.id|escape}'))");
                    getPlacename({$print.latitude|escape}, {$print.longitude|escape}, '{$constants.FLICKR_KEY|escape}', 'onPlaces_{$print.id|escape}');
            
                // ]]>
                </script>
            </li>
        {/foreach}
    </ol>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
