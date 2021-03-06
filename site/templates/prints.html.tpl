<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="{$language|default:"en"}">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>{strip}
        {if $language == "de"}
            Zuletzt gedruckt
        {elseif $language == "nl"}
            Recente afdrukken
        {elseif $language == "es"}
            Últimas impresiones
        {elseif $language == "fr"}
            Impressions récentes
        {elseif $language == "ja"}
            最近の印刷
        {elseif $language == "it"}
            Stampe recenti
        {elseif $language == "tr"}
            Son Baskılar
        {elseif $language == "ru"}
            Недавние распечатки
        {elseif $language == "sv"}
            Senaste Utskrifter
        {elseif $language == "id"}
            Terakhir Cetak
        {else}
            Recent Prints
        {/if}
    {/strip} (Walking Papers)</title>
    <link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    <h2>{strip}
        {if $language == "de"}
            Zuletzt gedruckt
        {elseif $language == "nl"}
            Recente afdrukken
        {elseif $language == "es"}
            Últimas impresiones     
        {elseif $language == "fr"}
            Impressions récentes
        {elseif $language == "ja"}
            最近の印刷
        {elseif $language == "it"}
            Stampe recenti    
        {elseif $language == "tr"}
            Son Baskılar
        {elseif $language == "ru"}
            Недавние распечатки
        {elseif $language == "sv"}
            Senaste Utskrifter
        {elseif $language == "id"}
            Terakhir Cetak
        {else}
            Recent Prints
        {/if}
    {/strip}</h2>
    
    {assign var="prints_count" value=$prints|@count}
    
    {if $page > 1 and $prints_count > 0}
        <p class="pagination">
            <span class="newer">← <a href="{$base_dir}/prints.php?perpage={$perpage|escape}&amp;page={$page-1|escape}">Newer</a></span>
            <span class="older"><a href="{$base_dir}/prints.php?perpage={$perpage|escape}&amp;page={$page+1|escape}">Older</a> →</span>
        </p>
    {/if}
    
    <ol start="{$offset+1}">
        {foreach from=$prints item="print"}
            <li>
                {if $print.last_step != $constants.STEP_FINISHED}
                    <strike>
                        <b id="print-{$print.id|escape}">{$print.age|nice_relativetime|escape}</b></strike>
                
                {elseif $print.place_woeid}
                    <a href="{$base_dir}/print.php?id={$print.id|escape}">
                        <b id="print-{$print.id|escape}">{$print.age|nice_relativetime|escape}</b>
                        <br />
                        {$print.place_name|escape} ({$print.paper_size|ucwords|escape})</a>
                        <br />

                {else}
                    <a href="{$base_dir}/print.php?id={$print.id|escape}">
                        <b id="print-{$print.id|escape}">{$print.age|nice_relativetime|escape}</b></a>
                    <script type="text/javascript" language="javascript1.2" defer="defer">
                    // <![CDATA[
                    
                        var onPlaces_{$print.id|escape} = new Function('res', "appendPlacename(res, document.getElementById('print-{$print.id|escape}'))");
                        getPlacename({$print.latitude|escape}, {$print.longitude|escape}, '{$constants.FLICKR_KEY|escape}', 'onPlaces_{$print.id|escape}');
                
                    // ]]>
                    </script>
                {/if}
            </li>
        {/foreach}
    </ol>
    
    <p class="pagination">
        {if $prints_count > 0}
            {if $page > 1}
                <span class="newer">← <a href="{$base_dir}/prints.php?perpage={$perpage|escape}&amp;page={$page-1|escape}">Newer</a></span>
            {/if}
            <span class="older"><a href="{$base_dir}/prints.php?perpage={$perpage|escape}&amp;page={$page+1|escape}">Older</a> →</span>
        {else}
            <span class="newer">← <a href="{$base_dir}/prints.php?perpage={$perpage|escape}&amp;page=1">Newest</a></span>
        {/if}
    </p>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
