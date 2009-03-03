<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Untitled</title>
    <script type="text/javascript" src="modestmaps.js"></script>
    <style type="text/css" title="text/css">
    /* <![CDATA[{literal} */
    
        #sheet
        {
            position: relative;
            background: white;
            border: 1px solid black;
            width: 360px;
            height: 480px;
            padding: 24px;
        }
        
        #sheet .dummy-code
        {
            position: absolute;
            background: white;
            color: white;
            width: 44px;
            height: 44px;
            padding: 4px;
            top: 456px;
            left: 336px;
        }
    
    /* {/literal}]]> */
    </style>
</head>
<body>

    <p><a href="javascript:map.zoomIn()">zoom in</a> | <a href="javascript:map.zoomOut()">zoom out</a>
    <br><a href="javascript:map.panLeft()">pan left</a> | <a href="javascript:map.panRight()">pan right</a> | <a href="javascript:map.panDown()">pan down</a> | <a href="javascript:map.panUp()">pan up</a></p>

    <div id="sheet">
        <div id="map"></div>
        <div class="dummy-code"><img src="http://chart.apis.google.com/chart?chs=44x44&amp;cht=qr&amp;chld=L%7C0&amp;chl=example" alt="" border="0" /></div>
    </div>
    
    <p id="info"></p>

    <form action="index.php" method="post" name="bounds">
        <input name="north" type="hidden" />
        <input name="south" type="hidden" />
        <input name="east" type="hidden" />
        <input name="west" type="hidden" />

        <input name="x" type="hidden" />
        <input name="y" type="hidden" />
        <input name="row" type="hidden" />
        <input name="column" type="hidden" />
        <input name="zoom" type="hidden" />
        <input name="width" type="hidden" />
        <input name="height" type="hidden" />

        <input type="submit" />
    </form>
    
    <script type="text/javascript">
    // <![CDATA[{literal}

        // "import" the namespace
        var mm = com.modestmaps;
        
        var tileURL = function(coord) {
            return 'http://tile.cloudmade.com/f1fe9c2761a15118800b210c0eda823c/2/256/' + coord.zoom + '/' + coord.column + '/' + coord.row + '.png';
        }
    
        function onMapChanged(map)
        {
            var printZoom = Math.min(18, map.coordinate.zoom + 2);
            var scaleDiff = Math.pow(2, printZoom - map.coordinate.zoom);

            var baseCoord = map.coordinate.zoomTo(printZoom).container();
            var basePoint = map.coordinatePoint(baseCoord);
            
            while(basePoint.x > 0) {
                baseCoord.column -= 1;
                basePoint.x -= 256 / scaleDiff;
            }
            
            while(basePoint.y > 0) {
                baseCoord.row -= 1;
                basePoint.y -= 256 / scaleDiff;
            }
            
            var northwest = map.pointLocation(new mm.Point(0, 0));
            var southeast = map.pointLocation(map.dimensions);
            
            var info = document.getElementById('info');
            info.innerHTML = northwest.toString() + ' - ' + southeast.toString() + ' @' + map.coordinate.zoom;
            
            var form = document.forms['bounds'];
            
            form.elements['north'].value = northwest.lat;
            form.elements['south'].value = southeast.lat;
            form.elements['east'].value = southeast.lon;
            form.elements['west'].value = northwest.lon;
            
            form.elements['x'].value = basePoint.x;
            form.elements['y'].value = basePoint.y;
            form.elements['row'].value = baseCoord.row;
            form.elements['column'].value = baseCoord.column;
            form.elements['zoom'].value = baseCoord.zoom;
            form.elements['width'].value = map.dimensions.x * scaleDiff;
            form.elements['height'].value = map.dimensions.y * scaleDiff;
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
