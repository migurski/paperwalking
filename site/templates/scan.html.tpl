<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Scanned Walking Papers</title>
	<link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
	{if $scan && $scan.last_step != 6 && $scan.last_step != $constants.STEP_FATAL_ERROR}
        <meta http-equiv="refresh" content="5" />
    {/if}
    <script type="text/javascript">
    // <![CDATA[{literal}
    
        function makeProviderFunction(bucket_id, scan_id)
        {
            return function(coord) {
                return 'http://' + bucket_id + '.s3.amazonaws.com/scans/' + scan_id + '/' + coord.zoom +'/'+ coord.column +'/'+ coord.row + '.jpg';
            }
        }

    // {/literal}]]>
    </script>
    <style type="text/css" title="text/css">
    /* <![CDATA[{literal} */
    
        #map
        {
            width: 408px;
            height: 528px;
            border: solid 1px black;
        }
        
        #editor
        {
        	width: 960px;
        	height: 600px;
        	border: 8px solid #ddd;
        }
        
        ol.steps li { color: silver; }
        ol.steps li.on { color: black; }
    
    /* {/literal}]]> */
    </style>
</head>
<body>

    <h1><a href="{$base_dir}/"><img src="{$base_dir}/icon.png" border="0" align="bottom" alt="" /> Walking Papers</a></h1>
    
    {if $scan}
        {if $scan.last_step == 6}
            <p>
                <a href="{$base_dir}/print.php?id={$scan.print_id|escape}">Download more PDFs of this area</a>.
            </p>
        
            {*
            <p>
                <a href="javascript:map.zoomIn()">zoom in</a> | <a href="javascript:map.zoomOut()">zoom out</a>
                <br>
                <a href="javascript:map.panLeft()">pan left</a> | <a href="javascript:map.panRight()">pan right</a> | <a href="javascript:map.panDown()">pan down</a> | <a href="javascript:map.panUp()">pan up</a>
            </p>

            <p id="map"></p>
            
            <script type="text/javascript">
            // <![CDATA[
        
                // "import" the namespace
                var mm = com.modestmaps;
            
                var provider = new mm.MapProvider(makeProviderFunction('{$constants.S3_BUCKET_ID|escape}', '{$scan.id|escape}'));
                var map_el = document.getElementById('map');
                var map = new mm.Map(map_el, provider, new mm.Point(408, 528));
                
                var northwest = provider.coordinateLocation(new mm.Coordinate({$scan.min_row}, {$scan.min_column}, {$scan.min_zoom}));
                var southeast = provider.coordinateLocation(new mm.Coordinate({$scan.max_row}, {$scan.max_column}, {$scan.max_zoom}));
                
                map_el.style.backgroundColor = '#ccc';
                map.setExtent([northwest, southeast]);
                
                map.draw();
        
            // ]]>
            </script>
            *}

            <p id="editor">
                You need a Flash player to use Potlatch, the
                OpenStreetMap Flash editor. You can <a href="http://www.adobe.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash">download Flash Player from Adobe.com</a>.
                <a href="http://wiki.openstreetmap.org/index.php/Editing">Several other options</a> are also available
                for editing OpenStreetMap.
            </p>

            <script src="http://www.openstreetmap.org/javascripts/swfobject.js?1218150545" type="text/javascript"></script>
            <script type="text/javascript" defer="defer">
            // <![CDATA[{literal}
            
                //var brokenContentSize = $("content").offsetWidth == 0;
                
                var fo = new SWFObject("http://www.openstreetmap.org/potlatch/potlatch.swf?d="+Math.round(Math.random()*1000), "potlatch", "100%", "100%", "6", "#FFFFFF");
                
                // 700,600 for fixed size, 100%,100% for resizable
                
                var changesaved=true;
                var isIE=false; if (document.all && window.print) { isIE=true; }
                
                window.onbeforeunload = function()
                {
                    if(!changesaved && !isIE) {
                        return "You have unsaved changes.";
                    }
                }
                
                function markChanged(a) { alert('markChanged'); changesaved=a; }
                
                function doSWF(custombg, lat, lon, zoom)
                {
                    if(zoom < 11)
                        zoom = 11;
                    
                    fo.addVariable('scale', zoom);
                    fo.addVariable('token', 'user:pass');
                    fo.addVariable('custombg', custombg);
                    fo.addVariable('lat', lat);
                    fo.addVariable('long', lon);
                    
                    fo.write("editor");
                }
                
                //doSWF(37.780484, -122.477989, 17);
            
                // {/literal}
                
                var mm = com.modestmaps;
                var tl = (new mm.Coordinate({$scan.min_row}, {$scan.min_column}, {$scan.min_zoom})).zoomTo({$scan.max_zoom}).zoomBy(-1);
                var br = (new mm.Coordinate({$scan.max_row}, {$scan.max_column}, {$scan.max_zoom})).zoomBy(-1);
                var center = new mm.Coordinate((tl.row + br.row) / 2, (tl.column + br.column) / 2, tl.zoom)

                var provider = new mm.MapProvider(makeProviderFunction('{$constants.S3_BUCKET_ID|escape}', '{$scan.id|escape}'));
                var center = provider.coordinateLocation(center);
                
                var custombg = 'http://{$constants.S3_BUCKET_ID|escape}.s3.amazonaws.com/scans/{$scan.id|escape}/!/!/!.jpg';

                doSWF(custombg, center.lat, center.lon, tl.zoom);
                
            // ]]>
            </script>
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
