<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Print #{$print.id|escape} (Walking Papers)</title>
	<link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
</head>
<body>

    <span id="print-info" style="display: none;">
        <span class="print">{$print.id|escape}</span>
        <span class="north">{$print.north|escape}</span>
        <span class="south">{$print.south|escape}</span>
        <span class="east">{$print.east|escape}</span>
        <span class="west">{$print.west|escape}</span>
    </span>

    {include file="navigation.htmlf.tpl"}
    
    <h2>Print Map</h2>
    
    <p>
        Print map of the area surrounding
        {if $print.place_woeid}
            <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.latitude|escape}&amp;lon={$print.longitude|escape}&amp;zoom=15&amp;layers=B000FTF">
                {$print.latitude|nice_degree:"lat"|escape}, {$print.longitude|nice_degree:"lon"|escape}</a>
            <br />
            {$print.place_name|escape}

        {else}
            <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.latitude|escape}&amp;lon={$print.longitude|escape}&amp;zoom=15&amp;layers=B000FTF">
                {$print.latitude|nice_degree:"lat"|escape}, {$print.longitude|nice_degree:"lon"|escape}</a>
        {/if}
        <br />
        Created {$print.age|nice_relativetime|escape}.
        <span class="date-created" style="display: none;">{$print.created|escape}</span>
    </p>
    
    <p>
        <a href="{$print.pdf_url|escape}">
            <img src="{$base_dir}/tiny-doc.png" border="0" align="bottom"/>
            Download map PDF for print</a>
    </p>

    <p>
        <a href="{$print.pdf_url|escape}">Download a map</a> to get started mapping this area
        from street level. Add details like businesses, parks, schools, buildings, paths,
        post boxes, cash machines and other useful landmarks. When you’re finished,
        <a href="{$base_dir}/upload.php">post a scan</a> of your annotated map
        to trace your handwritten changes and notes directly into OpenStreetMap.
    </p>

    {if $print.zoom}
        <form action="{$base_dir}/compose.php" method="post" name="bounds">
            <p>
                <input name="north" type="hidden" value="{$print.north|escape}" />
                <input name="south" type="hidden" value="{$print.south|escape}" />
                <input name="east" type="hidden" value="{$print.east|escape}" />
                <input name="west" type="hidden" value="{$print.west|escape}" />
                <input name="zoom" type="hidden" value="{$print.zoom|escape}" />
        
                Is this map wrong, or out of date?
                <input class="mac-button" type="submit" name="action" value="Redo" />
            </p>
        </form>
    {/if}
    
    <div class="sheet {$print.orientation|escape}">
        <img src="{$print.preview_url|escape}"/>
        <div class="dummy-qrcode"><img src="http://chart.apis.google.com/chart?chs=44x44&amp;cht=qr&amp;chld=L%7C0&amp;chl=example" alt="" border="0" /></div>
        <div class="dog-ear"> </div>
    </div>
    
    <p id="mini-map">
        <img class="doc" src="{$base_dir}/c-thru-doc.png" />
    </p>
    
    <script type="text/javascript" language="javascript1.2">
    // <![CDATA[
    
        var onPlaces = new Function('res', "appendPlacename(res, document.getElementById('print-location'))");
        var flickrKey = '{$constants.FLICKR_KEY|escape}';
        var cloudmadeKey = '{$constants.CLOUDMADE_KEY|escape}';
        var lat = {$print.latitude|escape};
        var lon = {$print.longitude|escape};
        
        {if !$print.place_woeid}getPlacename(lat, lon, flickrKey, 'onPlaces');{/if}
        makeStaticMap('mini-map', lat, lon, cloudmadeKey);

    // ]]>
    </script>

    <p>
        If you don’t have a printer, send us a
        <b><a href="http://en.wikipedia.org/wiki/Self-addressed_stamped_envelope">self-addressed, stamped envelope</a>
        with the print ID, “{$print.id}”,</b> and we’ll mail you a printed copy of this map. If you don’t have a scanner,
        mail us your printed map and an <b>e-mail address</b> and we’ll scan it for
        you.
    </p>

    <blockquote>
        Walking Papers<br />
        c/o Stamen Design<br />
        3012 16th St. #200<br />
        San Francisco, CA 94103
    </blockquote>

    <p>
        Please allow a few weeks for scanning and printing.
    </p>

    {include file="footer.htmlf.tpl"}
    
</body>
</html>
