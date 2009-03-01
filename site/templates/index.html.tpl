<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Untitled</title>
    <script type="text/javascript" src="modestmaps.js"></script>
</head>
<body>

    <p><a href="javascript:map.zoomIn()">zoom in</a> | <a href="javascript:map.zoomOut()">zoom out</a>
    <br><a href="javascript:map.panLeft()">pan left</a> | <a href="javascript:map.panRight()">pan right</a> | <a href="javascript:map.panDown()">pan down</a> | <a href="javascript:map.panUp()">pan up</a></p>

    <div id="sheet" style="background: white; border: 1px solid black; width: 360px; height: 480px; padding: 24px;">
        <div id="map"></div>
    </div>
    
    <p id="info"></p>
    
    <script type="text/javascript">
    // <![CDATA[{literal}

        // "import" the namespace
        var mm = com.modestmaps;
        
        var tileURL = function(coord) {
            // really f1fe9c2761a15118800b210c0eda823c
            return 'http://tile.cloudmade.com/5888c1bc969c5579bb881c14e9a45562/997/256/' + coord.zoom + '/' + coord.column + '/' + coord.row + '.png';
        }
    
        function onMapChanged(map)
        {
            var northwest = map.pointLocation(new mm.Point(0, 0));
            var southeast = map.pointLocation(map.dimensions);
            
            var info = document.getElementById('info');
            info.innerHTML = northwest.toString() + ' - ' + southeast.toString() + ' @' + map.coordinate.zoom;
        }

        var map = new mm.Map('map', new mm.MapProvider(tileURL), new mm.Point(360, 480))
        map.addCallback('zoomed',    function(m, a) { return onMapChanged(m); });
        map.addCallback('centered',  function(m, a) { return onMapChanged(m); });
        map.addCallback('extentset', function(m, a) { return onMapChanged(m); });
        map.addCallback('panned',    function(m, a) { return onMapChanged(m); });

        map.setCenterZoom(new mm.Location(37.660, -122.168), 9);
        map.draw();
        
    // {/literal}]]>
    </script>
    
</body>
</html>
