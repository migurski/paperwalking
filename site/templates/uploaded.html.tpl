<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Uploaded Walking Papers</title>
	<link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <style type="text/css" title="text/css">
    /* <![CDATA[{literal} */
    
        form label
        {
            font-weight: bold;
        }
    
    /* {/literal}]]> */
    </style>
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    <h2>You Uploaded A Scanned Map</h2>
    
    <p>
        (explanation)
    </p>
    
    <form action="{$base_dir}/uploaded.php" method="post" enctype="multipart/form-data">
        {*
        <p>
            private?
            <input type="checkbox" value="yes" name="private" {if $scan.is_private == 'yes'}checked="checked"{/if} />
        </p>
        *}
    
        <p>
            <label>
                Do you plan to edit this yourself?
                <select name="edit">
                    <option label="Yes" value="yes" {if $scan.will_edit == 'yes'}selected="selected"{/if}>Yes</option>
                    <option label="No" value="no"  {if $scan.will_edit == 'no'}selected="selected"{/if}>No</option>
                </select>
            </label>
            <br />
            You don’t have to do your own OpenStreetMap editing. Saying “no”
            will let other visitors know about scans they can help with.
        </p>
    
        <p>
            <label for="descripion">Describe your additions.</label>
            <br />
            Did you add businesses, fix footpaths, mark traffic lights, outline parks,
            place mailboxes? Write a few words about the changes to this area.
            <br />
            <textarea name="description" rows="10" cols="40">{$scan.description|escape}</textarea>
        </p>
    
        <input type="hidden" name="scan" value="{$scan.id|escape}">
        <input class="mac-button" type="submit" value="Save">
    </form>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
