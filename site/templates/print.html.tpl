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

    <p>
        <a href="../tmp/{$print.id|escape}.pdf">Download a PDF</a>, created {$print.created|nice_datetime|escape}.
        
        <span class="date-created" style="display: none;">{$print.created|escape}</span>
    </p>
    <p>
        ({$print.south|nice_degree:"lat"|escape}, {$print.west|nice_degree:"lon"|escape})
        to ({$print.north|nice_degree:"lat"|escape}, {$print.east|nice_degree:"lon"|escape})

        <span class="bounding-box" style="display: none;">
            <span class="north">{$print.north|escape}</span>
            <span class="south">{$print.south|escape}</span>
            <span class="east">{$print.east|escape}</span>
            <span class="west">{$print.west|escape}</span>
        </span>
    </p>
    
</body>
</html>
