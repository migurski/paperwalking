<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Print Walking Papers</title>
	<link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
</head>
<body>

    <span id="print-info" style="display: none;">
        <span class="print">{$print.id|escape}</span>
        <span class="north">{$print.north|escape}</span>
        <span class="south">{$print.south|escape}</span>
        <span class="east">{$print.east|escape}</span>
        <span class="west">{$print.west|escape}</span>
    </span>

    <h1><a href="{$base_dir}/"><img src="{$base_dir}/icon.png" border="0" align="bottom" alt="" /> Walking Papers</a></h1>
    
    <p>
        <a href="{$print.pdf_url|escape}">Download a PDF</a>, created {$print.created|nice_datetime|escape}.
        
        <span class="date-created" style="display: none;">{$print.created|escape}</span>
    </p>
    <p>
        ({$print.south|nice_degree:"lat"|escape}, {$print.west|nice_degree:"lon"|escape})
        to ({$print.north|nice_degree:"lat"|escape}, {$print.east|nice_degree:"lon"|escape})
    </p>

    <p>
        Do you have a piece of paper that looks like the one below?
        <a href="{$base_dir}/upload.php">Post a scan</a> and we’ll <small>mumblemumble</small>.
    </p>

    <div class="sheet">
        <img src="{$print.preview_url|escape}"/>
        <div class="dummy-qrcode"><img src="http://chart.apis.google.com/chart?chs=44x44&amp;cht=qr&amp;chld=L%7C0&amp;chl=example" alt="" border="0" /></div>
        <div class="dog-ear"> </div>
    </div>
    
    <p id="footer">
        &copy;2009 <a href="http://mike.teczno.com">Michal Migurski</a>, <a href="http://stamen.com">Stamen Design</a>
    </p>
    
</body>
</html>
