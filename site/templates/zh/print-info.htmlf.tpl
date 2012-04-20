<h2>印地圖</h2>

<p>
    列印附近地區的地圖
    {if $print.place_woeid}
        <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.latitude|escape}&amp;lon={$print.longitude|escape}&amp;zoom=15&amp;layers=B000FTF">
            {$print.latitude|nice_degree:"lat"|escape}, {$print.longitude|nice_degree:"lon"|escape}</a>
        <br />
        {$print.place_name|escape}

    {else}
        <a id="print-location" href="http://www.openstreetmap.org/?lat={$print.latitude|escape}&amp;lon={$print.longitude|escape}&amp;zoom=15&amp;layers=B000FTF">
            {$print.latitude|nice_degree:"lat"|escape}, {$print.longitude|nice_degree:"lon"|escape}</a>
    {/if}
    <br />
    Created {$print.age|nice_relativetime|escape}.
    <span class="date-created" style="display: none;">{$print.created|escape}</span>
</p>

<p>
    <a href="{$print.pdf_url|escape}">
        <img src="{$base_dir}/tiny-doc.png" border="0" align="bottom"/>
        下載PDF地圖以列印出來</a>
</p>

<p>
    <a href="{$print.pdf_url|escape}">下載地圖</a> 開始這個區域的街道層級繪圖。
    加入更詳細的資訊，如公司行號、公園、學校、建物、路徑、郵筒、提款機和其它有意義的地標。
    當你完成後，將已註記的地圖<a href="{$base_dir}/upload.php">送出掃瞄</a>，
    並直接到OpenStreetMap追蹤你的手寫註記在的地圖上有沒有任何改變。
</p>
