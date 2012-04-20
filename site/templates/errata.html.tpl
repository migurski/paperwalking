<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="{$language|default:"en"}">
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <title>{strip}
        {if $language == "de"}
            Fehlerverzeichnis
        {elseif $language == "nl"}
            Foutenlijst
        {elseif $language == "es"}
            Fe de erratas    
        {elseif $language == "fr"}
            Erreurs
        {elseif $language == "ja"}
            訂正
        {elseif $language == "tr"}
            Erratum
        {else}
            Errata
        {/if}
    {/strip} (Walking Papers)</title>
    <link rel="stylesheet" href="{$base_dir}/style.css" type="text/css" />
    <script type="text/javascript" src="{$base_dir}/script.js"></script>
</head>
<body>

    {include file="navigation.htmlf.tpl"}
    
    <h2>
        {if $language == "de"}
            Fehlerverzeichnis
        {elseif $language == "nl"}
            Foutenlijst
        {elseif $language == "es"}
            Fe de erratas
        {elseif $language == "fr"}
            Erreurs
        {elseif $language == "tr"}
            Erratum
        {else}
            Errata
        {/if}
    </h2>
    
    <p>
        {if $language == "de"}
            
        {elseif $language == "nl"}
            I have been informed that “Errata” does not mean what I thought it meant:
            <i><a href="http://dictionary.reference.com/search?q=errata">Errata</a> -
            a list of errors and their corrections inserted, usually on a separate
            page or slip of paper, in a book or other publication.</i>
        {elseif $language = "ja"}
            "訂正"ページを提供しているけれども、間違いとその訂正が一覧になっている本などによく入っている、いわゆる正誤表とはちがいます。 
        {elseif $language ="zh"}
            我被通知勘誤表 “Errata” 並非字典中這個字的意思:
            <i><a href="http://dictionary.reference.com/search?q=errata">Errata</a> -
            一列的錯誤和插入他們的修正，通常使用在區別出的一頁或一堆文件、一本書或其它出版。</i>
        {else}
            I have been informed that “Errata” does not mean what I thought it meant:
            <i><a href="http://dictionary.reference.com/search?q=errata">Errata</a> -
            a list of errors and their corrections inserted, usually on a separate
            page or slip of paper, in a book or other publication.</i>
    </p>
   
    <p>
        {if $language == "de"}
            Diese Seite wurde zu <a href="{$base_dir}/zeitgeist.php">Statistik</a> verschoben.
        {if $language == "es"}
            Esta página se ha trasladado a <a href="{$base_dir}/zeitgeist.php">Estadísticas</a>.      
        {elseif $language == "nl"}
            I thought it was more like a list of random, “erratic” stuff that didn’t fit anyplace else.
            So, this page has <a href="{$base_dir}/zeitgeist.php">moved to “zeitgeist”</a>.
        {elseif $language == "ja"}
            このページは、<a href="{$base_dir}/zeitgeist.php">moved to “zeitgeist”</a>に移動しました。
        {elseif $language == "zh"}
            我想過它更像一個隨機列表，奇怪的東西不適於任何地方，所以將這個頁移到<a href="{$base_dir}/zeitgeist.php">統計</a>
        {else}
            I thought it was more like a list of random, “erratic” stuff that didn’t fit anyplace else.
            So, this page has <a href="{$base_dir}/zeitgeist.php">moved to “zeitgeist”</a>.
        {/if}
    </p>
    
    {include file="footer.htmlf.tpl"}
    
</body>
</html>
