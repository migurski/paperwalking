<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Walking Papers</title>
	<link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
	<link rel="stylesheet" href="{$base_dir}/index.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/modestmaps.js"></script>
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
    <script type="text/javascript" src="{$base_dir}/index.js"></script>
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    <p style="background: red; color: white;">
        For much of Saturday night / Sunday morning (Pacific time) it was not
        possible to make new prints, because I accidentally broke the site.
        Everything should be back to normal now. Sorry, Mike.
    </p>
    
    <p>
        Print maps, draw on them, scan them back in and help OpenStreetMap
        improve its coverage of local points of interests and street detail.
    </p>
    
    <h2>Make A Print</h2>
    
    <p>
        <a href="http://openstreetmap.org">OpenStreetMap</a> is a wiki-style map
        of the world that anyone can edit. In some places, participants are
        creating the first freely-available maps by GPS survey. In other places,
        such as the United States, basic roads exist, but lack local detail:
        locations of traffic signals, ATMs, cafés, schools, parks, and shops.
        What such partially-mapped places need is not more GPS traces, but
        additional knowledge about what exists on and around the street. Walking
        Papers is made to help you easily create printed maps, mark them with
        things you know, and then share that knowledge with OpenStreetMap.
    </p>

    <p>
        To get started, search for a town or city you know.
    </p>

    <form onsubmit="return getPlaces(this.elements['q'].value, this.elements['appid'].value);">
        <input type="text" name="q" size="24" />
        <input class="mac-button" type="submit" name="action" value="Find" />
        <input type="hidden" name="appid" value="{$constants.GEOPLANET_APPID|escape}" />
        <span id="watch-cursor" style="visibility: hidden;"><img src="{$base_dir}/watch.gif" align="top" vspace="4" /></span>
    </form>

    <div class="sheet">
        <div id="map"></div>
        <!-- <div class="dummy-qrcode"><img src="http://chart.apis.google.com/chart?chs=44x44&amp;cht=qr&amp;chld=L%7C0&amp;chl=example" alt="" border="0" /></div> -->
        <img class="slippy-nav" src="{$base_dir}/slippy-nav.png" width="43" height="57" border="0" alt="up" usemap="#slippy_nav"/>
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
        <span id="zoom-warning" style="display: none;">A zoom level of <b>14 or more</b> is recommended for street-level mapping.</span>
        <span id="info"></span>
    </p>

    <script type="text/javascript" language="javascript1.2">
    // <![CDATA[

        var map = makeMap('map', '{$constants.CLOUDMADE_KEY|escape}');
        
        // {literal}
        
        function onPlaces(res)
        {
            if(document.getElementById('watch-cursor'))
                document.getElementById('watch-cursor').style.visibility = 'hidden';
        
            if(res['places'] && res['places']['place'] && res['places']['place'][0])
            {
                var place = res['places']['place'][0];
                var bbox = place['boundingBox'];
        
                var sw = new mm.Location(bbox['southWest']['latitude'], bbox['southWest']['longitude']);
                var ne = new mm.Location(bbox['northEast']['latitude'], bbox['northEast']['longitude']);
                
                map.setExtent([sw, ne]);

            } else {
                alert("Sorry, I couldn't find a place by that name.");
            }
        }
        
        // {/literal}
    
    // ]]>
    </script>

    <form action="{$base_dir}/compose.php" method="post" name="bounds">
        <input name="north" type="hidden" />
        <input name="south" type="hidden" />
        <input name="east" type="hidden" />
        <input name="west" type="hidden" />
        <input name="zoom" type="hidden" />

        <input class="mac-button" type="submit" name="action" value="Print" />
    </form>

    <h2>Recent Scans</h2>
    
    <ol>
        {foreach from=$scans item="rscan"}
            <li>
                {if $rscan.print_place_woeid}
                    <a href="{$base_dir}/scan.php?id={$rscan.id|escape}">
                        <b id="scan-{$rscan.id|escape}">{$rscan.age|nice_relativetime|escape}
                            {if $rscan.will_edit == 'no'}✻{/if}</b>
                        <br />
                        {$rscan.print_place_name|escape}</a>

                {else}
                    <a href="{$base_dir}/scan.php?id={$rscan.id|escape}">
                        <b id="scan-{$rscan.id|escape}">{$rscan.age|nice_relativetime|escape}
                            {if $rscan.will_edit == 'no'}✻{/if}</b></a>
    
                    <script type="text/javascript" language="javascript1.2" defer="defer">
                    // <![CDATA[
                    
                        var onPlaces_{$rscan.id|escape} = new Function('res', "appendPlacename(res, document.getElementById('scan-{$rscan.id|escape}'))");
                        getPlacename({$rscan.print_latitude|escape}, {$rscan.print_longitude|escape}, '{$constants.FLICKR_KEY|escape}', 'onPlaces_{$rscan.id|escape}');
                
                    // ]]>
                    </script>
                {/if}

                {if $rscan.description}
                    <br />
                    {$rscan.description|escape}
                {/if}
            </li>
        {/foreach}
    </ol>
    
    <p>
        <a href="{$base_dir}/scans.php">More recent scans...</a>
    </p>
    
    <h2>Recent Prints</h2>
    
    <ol>
        {foreach from=$prints item="rprint"}
            <li>
                {if $rprint.place_woeid}
                    <a href="{$base_dir}/print.php?id={$rprint.id|escape}">
                        <b id="print-{$rprint.id|escape}">{$rprint.age|nice_relativetime|escape}</b>
                        <br />
                        {$rprint.place_name|escape}</a>

                {else}
                    <a href="{$base_dir}/print.php?id={$rprint.id|escape}">
                        <b id="print-{$rprint.id|escape}">{$rprint.age|nice_relativetime|escape}</b></a>
                    <script type="text/javascript" language="javascript1.2" defer="defer">
                    // <![CDATA[
                    
                        var onPlaces_{$rprint.id|escape} = new Function('res', "appendPlacename(res, document.getElementById('print-{$rprint.id|escape}'))");
                        getPlacename({$rprint.latitude|escape}, {$rprint.longitude|escape}, '{$constants.FLICKR_KEY|escape}', 'onPlaces_{$rprint.id|escape}');
                
                    // ]]>
                    </script>
                {/if}
            </li>
        {/foreach}
    </ol>
    
    <p>
        <a href="{$base_dir}/prints.php">More recent prints...</a>
    </p>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
