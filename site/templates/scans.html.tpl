<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="{$language|default:"en"}">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>{strip}
        {if $language == "de"}
            Zuletzt gescannt
        {elseif $language == "nl"}
            Recente scans
        {elseif $language == "es"}
            Últimos scans    
        {elseif $language == "fr"}
            Scans récents
        {elseif $language == "ja"}
            最近の取込データ
        {elseif $language == "it"}
            Scansioni recenti
        {elseif $language == "tr"}
            Son Taramalar
        {elseif $language == "ru"}
            Недавние сканы
        {elseif $language == "sv"}
            Senast inskannat
        {else}
            Recent Scans
        {/if}
    {/strip} (Walking Papers)</title>
    <link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <link rel="stylesheet" href="{$base_dir}/scans.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    <h2>{strip}
        {if $language == "de"}
            Zuletzt gescannt
        {elseif $language == "nl"}
            Recente scans
        {elseif $language == "es"}
          Últimos scans
        {elseif $language == "fr"}
            Scans récents
        {elseif $language == "ja"}
            最近の取込データ
        {elseif $language == "it"}
            Scansioni recenti
        {elseif $language == "tr"}
            Son Taramalar
        {elseif $language == "ru"}
            Недавние сканы
        {elseif $language == "sv"}
            Senaste inskanningarna
        {else}
            Recent Scans
        {/if}
    {/strip}</h2>
    
    {assign var="scans_count" value=$scans|@count}
    
    {if $page > 1 and $scans_count > 0}
        <p class="pagination">
            <span class="newer">← <a href="{$base_dir}/scans.php?perpage={$perpage|escape}&amp;page={$page-1|escape}">Newer</a></span>
            <span class="older"><a href="{$base_dir}/scans.php?perpage={$perpage|escape}&amp;page={$page+1|escape}">Older</a> →</span>
        </p>
    {/if}
    
    {assign var="cols" value=4}
    {assign var="cells" value=$scans|@count}
    {assign var="rows" value=$cells/$cols|@ceil}

    <table id="scans">
        {foreach from=1|@range:$rows item="row" name="rows"}
            <tr class="preview">
                {foreach from=1|@range:$cols item="col" name="cols"}
                    {assign var="index" value=$smarty.foreach.rows.index*$cols+$smarty.foreach.cols.index}
                    {assign var="scan" value=$scans.$index}

                    <td>
                        {if $scan}
                            <a href="{$base_dir}/scan.php?id={$scan.id|escape}">
                                <img border="1" src="{$scan.base_url}/preview.jpg" /></a>
                        {/if}
                    </td>
                {/foreach}
            </tr>

            <tr class="info">
                {foreach from=1|@range:$cols item="col" name="cols"}
                    {assign var="index" value=$smarty.foreach.rows.index*$cols+$smarty.foreach.cols.index}
                    {assign var="scan" value=$scans.$index}

                    <td>
                        {if $scan}
                            {if $scan.print_place_woeid}
                                <a href="{$base_dir}/scan.php?id={$scan.id|escape}">
                                    <b id="scan-{$scan.id|escape}">{$scan.age|nice_relativetime|escape}
                                        {if $scan.will_edit == 'no'}✻{/if}</b>
                                    <br />
                                    {$scan.print_place_name|escape}</a>
            
                            {else}
                                <a href="{$base_dir}/scan.php?id={$scan.id|escape}">
                                    <b id="scan-{$scan.id|escape}">{$scan.age|nice_relativetime|escape}
                                        {if $scan.will_edit == 'no'}✻{/if}</b></a>
                
                                <script type="text/javascript" language="javascript1.2" defer="defer">
                                // <![CDATA[
                                
                                    var onPlaces_{$scan.id|escape} = new Function('res', "appendPlacename(res, document.getElementById('scan-{$scan.id|escape}'))");
                                    getPlacename({$scan.print_latitude|escape}, {$scan.print_longitude|escape}, '{$constants.FLICKR_KEY|escape}', 'onPlaces_{$scan.id|escape}');
                            
                                // ]]>
                                </script>
                            {/if}
            
                            {if $scan.description}
                                <br />
                                {$scan.description|escape}
                            {/if}
                        {/if}
                    </td>
                {/foreach}
            </tr>
        {/foreach}
    </table>
    
    {*
    <ol start="{$offset+1}">
        {foreach from=$scans item="scan"}
            <li>
                {if $scan.print_place_woeid}
                    <a href="{$base_dir}/scan.php?id={$scan.id|escape}">
                        <b id="scan-{$scan.id|escape}">{$scan.age|nice_relativetime|escape}
                            {if $scan.will_edit == 'no'}✻{/if}</b>
                        <br />
                        {$scan.print_place_name|escape}</a>

                {else}
                    <a href="{$base_dir}/scan.php?id={$scan.id|escape}">
                        <b id="scan-{$scan.id|escape}">{$scan.age|nice_relativetime|escape}
                            {if $scan.will_edit == 'no'}✻{/if}</b></a>
    
                    <script type="text/javascript" language="javascript1.2" defer="defer">
                    // <![CDATA[
                    
                        var onPlaces_{$scan.id|escape} = new Function('res', "appendPlacename(res, document.getElementById('scan-{$scan.id|escape}'))");
                        getPlacename({$scan.print_latitude|escape}, {$scan.print_longitude|escape}, '{$constants.FLICKR_KEY|escape}', 'onPlaces_{$scan.id|escape}');
                
                    // ]]>
                    </script>
                {/if}

                {if $scan.description}
                    <br />
                    {$scan.description|escape}
                {/if}
            </li>
        {/foreach}
    </ol>
    *}
    
    <p class="pagination">
        {if $scans_count > 0}
            {if $page > 1}
                <span class="newer">← <a href="{$base_dir}/scans.php?perpage={$perpage|escape}&amp;page={$page-1|escape}">Newer</a></span>
            {/if}
            <span class="older"><a href="{$base_dir}/scans.php?perpage={$perpage|escape}&amp;page={$page+1|escape}">Older</a> →</span>
        {else}
            <span class="newer">← <a href="{$base_dir}/scans.php?perpage={$perpage|escape}&amp;page=1">Newest</a></span>
        {/if}
    </p>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
