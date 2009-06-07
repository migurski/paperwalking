<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Scanned Map #{$scan.id|escape} (Walking Papers)</title>
	<link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
	<link rel="stylesheet" href="{$base_dir}/scan.css" type="text/css" />
	{if $scan && $scan.last_step != 6 && $scan.last_step != $constants.STEP_FATAL_ERROR && $scan.last_step != $constants.STEP_FATAL_QRCODE_ERROR}
        <meta http-equiv="refresh" content="5" />
    {else}
        <script type="text/javascript" src="http://www.openstreetmap.org/javascripts/swfobject.js"></script>
        <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
        <script type="text/javascript" src="{$base_dir}/script.js"></script>
        <script type="text/javascript" src="{$base_dir}/scan.js"></script>
    {/if}
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    {if $scan}
        {if $scan.last_step == $constants.STEP_FINISHED}
            <h2>Scanned Map</h2>
            
            {if $scan.description}
                <p style="font-style: italic;">
                    {$scan.description|escape}
                </p>
            {/if}
            
            <p>
                Covers the area near
                {if $print.place_woeid}
                    <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.latitude|escape}&amp;lon={$print.longitude|escape}&amp;zoom=15&amp;layers=B000FTF">
                        {$print.latitude|nice_degree:"lat"|escape}, {$print.longitude|nice_degree:"lon"|escape}</a>
                    <br />
                    {$print.place_name|escape}
        
                {else}
                    <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.latitude|escape}&amp;lon={$print.longitude|escape}&amp;zoom=15&amp;layers=B000FTF">
                        {$print.latitude|nice_degree:"lat"|escape}, {$print.longitude|nice_degree:"lon"|escape}</a>
                {/if}
                <br/>
                Uploaded {$scan.age|nice_relativetime|escape}.
            </p>
            
            {if !$print.place_woeid}
                <script type="text/javascript" language="javascript1.2">
                // <![CDATA[
                
                    var onPlaces = new Function('res', "appendPlacename(res, document.getElementById('print-location'))");
                    var flickrKey = '{$constants.FLICKR_KEY|escape}';
                    var lat = {$print.latitude|escape};
                    var lon = {$print.longitude|escape};
                    
                    getPlacename(lat, lon, flickrKey, 'onPlaces');
            
                // ]]>
                </script>
            {/if}
        
            <p>
                <a href="http://{$constants.S3_BUCKET_ID|escape}.s3.amazonaws.com/scans/{$scan.id|escape}/large.jpg">
                    <img border="1" src="http://{$constants.S3_BUCKET_ID|escape}.s3.amazonaws.com/scans/{$scan.id|escape}/preview.jpg" /></a>
            </p>
        
            <p>
                Download a
                <a href="{$base_dir}/print.php?id={$scan.print_id|escape}">fresh map of this area from print #{$scan.print_id|escape}</a>.
            </p>
    
            <h2>Edit The Map</h2>
    
            <div id="editor">
                <p>
                    You can edit OpenStreetMap using this scanned map as a guide
                    right here in this page, with the web-based OSM editor
                    <a href="http://wiki.openstreetmap.org/index.php/Potlatch">Potlatch</a>.
                </p>
                
                <form onsubmit="return editInPotlatch(this.elements);">
                    <p>
                        First, you’ll need to log in with your OpenStreetMap account
                        to do any editing; do that below or
                        <a href="http://www.openstreetmap.org/user/new">create a new account</a>.
                        <strong><i>Walking Papers</i> will not see or keep your password</strong>,
                        it is passed directly to OpenStreetMap.
                    </p>
                    <p>
                        <label for="username">Email Address or Username</label>
                        <br />
                        <input id="username-textfield" name="username" type="text" size="30" />
                    </p>
                    <script type="text/javascript">
                    // <![CDATA[{literal}
                    
                        if(readCookie('openstreetmap-username') && document.getElementById('username-textfield'))
                            document.getElementById('username-textfield').value = readCookie('openstreetmap-username');
                    
                    // {/literal}]]>
                    </script>
                    <p>
                        <label for="password">Password</label>
                        <br />
                        <input name="password" type="password" size="30" />
                        <br />
                        (<a href="http://www.openstreetmap.org/user/forgot-password">Lost your password?</a>)
                    </p>
                    <p>
                        <input class="mac-button" name="action" type="submit" value="Edit" />
                        <input name="minrow" type="hidden" value="{$scan.min_row|escape}" />
                        <input name="mincolumn" type="hidden" value="{$scan.min_column|escape}" />
                        <input name="minzoom" type="hidden" value="{$scan.min_zoom|escape}" />
                        <input name="maxrow" type="hidden" value="{$scan.max_row|escape}" />
                        <input name="maxcolumn" type="hidden" value="{$scan.max_column|escape}" />
                        <input name="maxzoom" type="hidden" value="{$scan.max_zoom|escape}" />

                        <input name="bucket" type="hidden" value="{$constants.S3_BUCKET_ID|escape}" />
                        <input name="scan" type="hidden" value="{$scan.id|escape}" />
                    </p>
                </form>
            </div>
        {else}
            {if $step.number == $constants.STEP_FATAL_ERROR || $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
                <p>
                    {$step.number|step_description|escape}, giving up.
                </p>
                <p>
                    You might try uploading your scan again, making sure that
                    it’s at a reasonably high resolution (200+ dpi for a full
                    sheet of paper is normal) and right-side up. A legible 
                    <a href="http://en.wikipedia.org/wiki/QR_Code">QR code</a> is critical.
                    If this doesn’t help,
                    <a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">let us know</a>.
                </p>
                
                {if $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
                    <p>
                        Here’s the part of your scan where we tried to find a code:
                    </p>
                    <p>
                        <img width="65%" border="1" src="http://{$constants.S3_BUCKET_ID|escape}.s3.amazonaws.com/scans/{$scan.id|escape}/qrcode.jpg" />
                    </p>
                {/if}
                
            {else}
                <p>
                    Processing your scanned image.
                </p>
    
                <ol class="steps">
                    <li class="{if $step.number == 0}on{/if}">{0|step_description|escape}</li>
                    <li class="{if $step.number == 1}on{/if}">{1|step_description|escape}</li>
                    <li class="{if $step.number == 2}on{/if}">{2|step_description|escape}</li>
                    <li class="{if $step.number == 3}on{/if}">{3|step_description|escape}</li>
                    <li class="{if $step.number == 4}on{/if}">{4|step_description|escape}</li>
                    <li class="{if $step.number == 5}on{/if}">{5|step_description|escape}</li>
                    <li class="{if $step.number == 6}on{/if}">{6|step_description|escape}</li>
                </ol>
    
                {if $step.number >= 7}
                    <p>
                        {$step.number|step_description|escape}, please stand by.
                        We will try to process your scan again shortly.
                    </p>
                    
                    {if $step.number == $constants.STEP_BAD_QRCODE}
                        <p>
                            Here’s the part of your scan where we tried to find a code:
                        </p>
                        <p>
                            <img width="65%" border="1" src="http://{$constants.S3_BUCKET_ID|escape}.s3.amazonaws.com/scans/{$scan.id|escape}/qrcode.jpg" />
                        </p>
                    {/if}
                    
                {else}
                    <p>
                        This may take a little while, generally a few minutes.
                        You don’t need to keep this browser window open—you can
                        <a href="{$base_dir}/scan.php?id={$scan.id|escape}">bookmark this page</a>
                        and come back later.
                    </p>
                {/if}
            {/if}
        {/if}
    {/if}
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
