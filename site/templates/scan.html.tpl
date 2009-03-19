<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Scanned Walking Papers</title>
	<link rel="stylesheet" href="style.css" type="text/css" />
    <script type="text/javascript" src="modestmaps.js"></script>
	{if $scan && $scan.last_step != 6}
        <meta http-equiv="refresh" content="5" />
    {/if}
    <script type="text/javascript">
    // <![CDATA[{literal}
    
        function makeProviderFunction(bucket_id, scan_id)
        {
            return function(coord) {
                return 'http://' + bucket_id + '.s3.amazonaws.com/' + scan_id + '/' + coord.zoom +'-r'+ coord.row +'-c'+ coord.column + '.jpg';
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
    
    /* {/literal}]]> */
    </style>
</head>
<body>

    <h1><img src="icon.png" border="0" align="bottom" alt="" /> Walking Papers</h1>
    
    <p>
        <a href="print.php?id={$scan.print_id|escape}">Download more PDFs of this area</a>.
    </p>

    {if $scan}
        {if $scan.last_step == 6}
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
        
        {else}
            Please wait, currently {$step.description|lower|escape}.
        
        {/if}
    {/if}

</body>
</html>
