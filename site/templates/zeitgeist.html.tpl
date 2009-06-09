<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Errata (Walking Papers)</title>
	<link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    <h2>Zeitgeist</h2>
    
    <h3>Countries</h3>
    
    <p>
        Share of prints for top ten countries.
    </p>
    
    <p>
        <img src="http://chart.apis.google.com/chart?cht=p&amp;chd=t:{"urlencode"|@array_map:$country_percents|@join:","|escape}&amp;chs=408x180&amp;chl={"urlencode"|@array_map:$country_names|@join:"|"|escape}">
    </p>
    
    <h3>Numbers</h3>
    
    <p>
        Number of prints vs. number of scans.
    </p>
    
    <p>
        <img src="http://chart.apis.google.com/chart?cht=p&amp;chd=t:{$print_percent|escape},{$scan_percent|escape}&amp;chs=408x120&amp;chl=Prints|Scans">
    </p>
    
    <p>
        Why are there so many prints? It’s easy to create a print and less-easy to make a scan. We’re in the early days of this site,
        and I imagine that it may take some time for the initial excitement of printing out paper maps to translate into submitted,
        annotated scanned images. Bring it on!
    </p>
    
    <h3>Scans</h3>
    
    <p>
        Number of scans that have finished successfully, failed for some reason, or are still in progress.
    </p>
    
    <p>
        {if $scan_states.progress}
            <img src="http://chart.apis.google.com/chart?cht=p&amp;chp=2.8274&amp;chd=t:{$scan_states.progress|escape},{$scan_states.finished|escape},{$scan_states.failed|escape}&amp;chs=408x120&amp;chl=In+Progress|Finished|Failed">

        {else}
            <img src="http://chart.apis.google.com/chart?cht=p&amp;chp=2.8274&amp;chd=t:{$scan_states.finished|escape},{$scan_states.failed|escape}&amp;chs=408x120&amp;chl=Finished|Failed">
        {/if}
    </p>
    
    <p>
        Why do scans fail? Based on the errors we’ve seen, scans seem to fail for one of three reasons:
    </p>
    
    <ol>
        <li>Many users have been uploading the same print PDF’s downloaded from this site. Scans need to be bitmap images, ideally JPEG’s.</li>
        <li>Some users have submitted scans that are at a low resolution, or low-quality photographs instead of scans. Check the print pages for an address where you can mail us paper to have scanned!</li>
        <li>Some scans have come out of printers with failing ink cartridges, which makes important details such as the QR code in the lower-right corner illegible.</li>
    </ol>
    
    <h3>Zoom Levels</h3>
    
    <p>
        Number of prints at each zoom level. Zoom level 0 is the whole world,
        while zoom level 14 is recommended as a minimum for street-level mapping.
    </p>
    
    <p>
        <img src="http://chart.apis.google.com/chart?cht=bvs&amp;chbh=a&amp;chs=408x120&amp;chxt=r&amp;chxr=0,0,{$zooms|@max}&amp;chds=0,{$zooms|@max}&amp;chl=0|1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18&amp;chd=t:{$zooms.0|escape},{$zooms.1|escape},{$zooms.2|escape},{$zooms.3|escape},{$zooms.4|escape},{$zooms.5|escape},{$zooms.6|escape},{$zooms.7|escape},{$zooms.8|escape},{$zooms.9|escape},{$zooms.10|escape},{$zooms.11|escape},{$zooms.12|escape},{$zooms.13|escape},{$zooms.14|escape},{$zooms.15|escape},{$zooms.16|escape},{$zooms.17|escape},{$zooms.18|escape}" />
    </p>
    
    <h3>Hemispheres</h3>
    
    <p>
        Number of prints by hemisphere.
    </p>
    
    <p>
        <img src="http://chart.apis.google.com/chart?cht=p&amp;chp=1.2566&amp;chd=t:{$hemisphere_percent.western|escape},{$hemisphere_percent.eastern|escape}&amp;chs=408x120&amp;chl=Western|Eastern">
    </p>
    
    <p>
        <img src="http://chart.apis.google.com/chart?cht=p&amp;chp=2.8274&amp;chd=t:{$hemisphere_percent.northern|escape},{$hemisphere_percent.southern|escape}&amp;chs=408x120&amp;chl=Northern|Southern">
    </p>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
