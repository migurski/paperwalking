<h2>掃瞄的地圖</h2>
            
{if $scan.description}
    <p style="font-style: italic;">
        {$scan.description|escape}
    </p>
{/if}

<p>
    地圖涵蓋的區域接近於

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
    上傳的 {$scan.age|nice_relativetime|escape}.
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
    <a href="{$base_dir}/scan-large.php?id={$scan.id}">
        <img border="1" src="{$scan.base_url}/preview.jpg" /></a>
</p>
        
<p>
    下載一個 <a href="{$base_dir}/print.php?id={$scan.print_id|escape}"> 這個區域的新地圖 #{$scan.print_id|escape}</a>.
</p>

{if $scan.has_geotiff == "yes" || $scan.has_geojpeg == "yes"}
    <p>
        <a href="{$base_dir}/scan-large.php?id={$scan.id|escape}">這個掃瞄的地理資料</a>.
    </p>
{/if}
