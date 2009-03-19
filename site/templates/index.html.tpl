<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Walking Papers</title>
	<link rel="stylesheet" href="style.css" type="text/css" />
    <script type="text/javascript" src="modestmaps.js"></script>
    <style type="text/css" title="text/css">
    /* <![CDATA[{literal} */
    
        #print-button
        {
            cursor: pointer;
        	font-family: Chicago, Verdana, sans-serif;
        	font-size: 12px !important;
        	background: url('print-button.png');
        	border: none;
        	width: 50px;
        	height: 20px;
        }
        
    /* {/literal}]]> */
    </style>
</head>
<body>

    <h1><img src="icon.png" border="0" align="bottom" alt="" /> Walking Papers</h1>
    
    <p>
        Print maps, draw on them, scan them back in and help OpenStreetMap
        improve its coverage of local points of interests and street detail.
    </p>
    
    <h2>Print a map</h2>
    
    <p>
        <a href="http://OpenStreetMap.org">OpenStreetMap</a> is a wiki-style map
        of the world that anyone can edit. In some places, participants are
        creating the first freely-available maps by GPS survey. In other places,
        such as the United States, basic roads exist, but lack local detail:
        locations of traffic signals, ATMs, cafés, schools, parks, and shops.
        What such partially-mapped places need is not more GPS traces, but
        additional knowledge about what exists on and around the street. Paper
        Walking is made to help you easily create printed maps, mark them with
        things you know, and then share that knowledge with OpenStreetMap.
    </p>

    <p>
        To get started, pan and zoom the map below to place you know:
    </p>

    <div class="sheet">
        <div id="map"></div>
        <!-- <div class="dummy-qrcode"><img src="http://chart.apis.google.com/chart?chs=44x44&amp;cht=qr&amp;chld=L%7C0&amp;chl=example" alt="" border="0" /></div> -->
        <img class="slippy-nav" src="slippy-nav.png" width="43" height="57" border="0" alt="up" usemap="#slippy_nav"/>
        <map name="slippy_nav">
            <area shape="rect" alt="out" coords="14,31,28,41" href="javascript:map.zoomOut()">
            <area shape="rect" alt="in" coords="14,14,28,30" href="javascript:map.zoomIn()">
            <area shape="rect" alt="right" coords="29,21,42,35" href="javascript:map.panRight()">
            <area shape="rect" alt="down" coords="14,42,28,56" href="javascript:map.panDown()">
            <area shape="rect" alt="up" coords="14,0,28,13" href="javascript:map.panUp()">
            <area shape="rect" alt="left" coords="0,21,13,35" href="javascript:map.panLeft()">
        </map>
        <div class="dog-ear"> </div>
    </div>
    
    <p>
        <span id="info"></span>
        <span id="zoom-warning" style="display: none;">A zoom level of <b>14 or more</b> is recommended for street-level mapping.</span>
    </p>

    <form action="compose.php" method="post" name="bounds">
        <input name="north" type="hidden" />
        <input name="south" type="hidden" />
        <input name="east" type="hidden" />
        <input name="west" type="hidden" />
        <input name="zoom" type="hidden" />

        <input id="print-button" type="submit" name="action" value="Print" />
    </form>
    
    <script type="text/javascript">
    // <![CDATA[{literal}

        // "import" the namespace
        var mm = com.modestmaps;
        
        var tileURL = function(coord) {
            return 'http://tile.cloudmade.com/f1fe9c2761a15118800b210c0eda823c/997/256/' + coord.zoom + '/' + coord.column + '/' + coord.row + '.png';
        }
        
        function formatDegree(value, axis)
        {
            var dir = value;
            var val = Math.abs(value);
            
            var deg = Math.floor(val);
            val = (val - deg) * 60;
            
            var min = Math.floor(val);
            val = (val - min) * 60;
            
            var sec = Math.floor(val);
            
            var str = deg + '°';
            
            if(min <= 9)
                str += '0';

            str += min + "'";
            
            if(sec <= 9)
                str += '0';

            str += sec + '"';
            
            if(axis == 'lat') {
                str += (dir >= 0) ? 'N' : 'S';
            
            } else {
                str += (dir >= 0) ? 'E' : 'W';
            }
            
            return str;
        }
        
        function onMapChanged(map)
        {
            var center = map.getCenter();
            var info = document.getElementById('info');
            var warn = document.getElementById('zoom-warning');

            info.innerHTML = formatDegree(center.lat, 'lat') + ', ' + formatDegree(center.lon, 'lon') + ' at zoom level ' + map.coordinate.zoom + '.';
            warn.style.display = (map.getZoom() < 16) ? 'inline' : 'none';
            
            var northwest = map.pointLocation(new mm.Point(0, 0));
            var southeast = map.pointLocation(map.dimensions);
            var form = document.forms['bounds'];
            
            form.elements['north'].value = northwest.lat;
            form.elements['south'].value = southeast.lat;
            form.elements['east'].value = southeast.lon;
            form.elements['west'].value = northwest.lon;
            form.elements['zoom'].value = map.coordinate.zoom;
        }

        var map = new mm.Map('map', new mm.MapProvider(tileURL), new mm.Point(360, 456))
        map.addCallback('zoomed',    function(m, a) { return onMapChanged(m); });
        map.addCallback('centered',  function(m, a) { return onMapChanged(m); });
        map.addCallback('extentset', function(m, a) { return onMapChanged(m); });
        map.addCallback('panned',    function(m, a) { return onMapChanged(m); });

        map.setCenterZoom(new mm.Location(37.660, -122.168), 9);
        map.draw();
        
    // {/literal}]]>
    </script>
    
    <p>
        blah
    </p>
    
</body>
</html>
