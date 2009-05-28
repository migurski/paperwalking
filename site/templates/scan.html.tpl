<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Scanned Walking Papers</title>
	<link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
	<link rel="stylesheet" href="{$base_dir}/scan.css" type="text/css" />
	{if $scan && $scan.last_step != 6 && $scan.last_step != $constants.STEP_FATAL_ERROR}
        <meta http-equiv="refresh" content="5" />
    {else}
        <script type="text/javascript" src="http://www.openstreetmap.org/javascripts/swfobject.js"></script>
        <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
        <script type="text/javascript" src="{$base_dir}/script.js"></script>
        <script type="text/javascript" src="{$base_dir}/scan.js"></script>
    {/if}
</head>
<body>

    <h1><a href="{$base_dir}/"><img src="{$base_dir}/icon.png" border="0" align="bottom" alt="" /> Walking Papers</a></h1>
    
    {if $scan}
        {if $scan.last_step == 6}
            <p>
                <a href="{$base_dir}/print.php?id={$scan.print_id|escape}">Download fresh maps of this area</a>.
                <br/>
                Uploaded {$scan.age|nice_relativetime|escape}.
            </p>
    
            <div id="editor">
                <p>
                    Scanned map of the area surrounding
                    <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.latitude|escape}&amp;lon={$print.longitude|escape}&amp;zoom=15&amp;layers=B000FTF">
                        {$print.latitude|nice_degree:"lat"|escape}, {$print.longitude|nice_degree:"lon"|escape}</a>
                </p>
                
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
                    
                    getPlacename(lat, lon, flickrKey, 'onPlaces');
                    makeStaticMap('mini-map', lat, lon, cloudmadeKey);
            
                // ]]>
                </script>
            
                <form onsubmit="return editInPotlatch(this.elements);">
                    <p>
                        You’ll need to first log in to OpenStreetMap to do any editing,
                        log in below or
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
            {if $step.number == $constants.STEP_FATAL_ERROR}
                <p>Giving up, {$step.number|step_description|lower|escape}.</p>
                
            {else}
                <p>Processing your scanned image.</p>
    
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
                    <p>Please stand by, currently {$step.number|step_description|lower|escape}.</p>
                {/if}
            {/if}
        {/if}
    {/if}
    
    <p id="footer">
        &copy;2009 <a href="http://mike.teczno.com">Michal Migurski</a>, <a href="http://stamen.com">Stamen Design</a>
    </p>
    
</body>
</html>
