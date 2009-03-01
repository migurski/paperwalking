<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Untitled</title>
    <script type="text/javascript" src="modestmaps.js"></script>
    <script type="text/javascript">
    // <![CDATA[{literal}
    
        function makeProviderFunction(bucket_id, scan_id)
        {
            return function(coord) {
                return 'http://' + bucket_id + '.s3.amazonaws.com/' + scan_id + '/' + parseInt(coord.zoom) +'-r'+ parseInt(coord.row) +'-c'+ parseInt(coord.column) + '.jpg';
            }
        }

    // {/literal}]]>
    </script>
</head>
<body>
    
    <p><a href="javascript:map.zoomIn()">zoom in</a> | <a href="javascript:map.zoomOut()">zoom out</a>
    <br><a href="javascript:map.panLeft()">pan left</a> | <a href="javascript:map.panRight()">pan right</a> | <a href="javascript:map.panDown()">pan down</a> | <a href="javascript:map.panUp()">pan up</a></p>
    <div id="map">
    </div>
    
    <script type="text/javascript">
    // <![CDATA[

        // "import" the namespace
        var mm = com.modestmaps;
    
        var provider = new mm.MapProvider(makeProviderFunction('{$constants.S3_BUCKET_ID|escape}', '{$scan.id|escape}'));
        var map_el = document.getElementById('map');
        var map = new mm.Map(map_el, provider, new mm.Point(640,480))
        
        var northwest = provider.coordinateLocation(new mm.Coordinate({$scan.min_row}, {$scan.min_column}, {$scan.min_zoom}));
        var southeast = provider.coordinateLocation(new mm.Coordinate({$scan.max_row}, {$scan.max_column}, {$scan.max_zoom}));
        
        map_el.style.backgroundColor = '#ccc';
        map.setExtent([northwest, southeast]);
        
        map.draw();

    // ]]>
    </script>

    <pre>{$scan|@print_r:1|escape}</pre>
    <pre>{$step|@print_r:1|escape}</pre>
    
</body>
</html>
