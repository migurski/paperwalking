<p>
    如果上面的影像看起來像一個
    <a href="http://en.wikipedia.org/w/index.php?title=QR_Code&amp;oldid=405297309">QR碼</a>，
    這有可能是我們使用的 <a href="http://code.google.com/p/zxing/"> 套件</a>，
    在讀這個QR碼的時候發生一些解讀的問題，
    有可能是有污點、模糊或有些不知道的原因。

</p>
<p>
    在你的掃瞄圖中的右上角輸入文字來協助完這個步驟:
</p>
<form action="{$base_dir}/scan.php?id={$scan.id|escape}" method="post">
    <input name="qrcode_contents" type="text" size="48" placeholder="http://{$domain}{$base_dir}/print.php?id=0000" />
    <input name="action" type="hidden" value="override QR code" />
    <input class="mac-button" type="submit" value="Save" />
</form>
<p>
    這裡是案例:
</p>
<p>
    <img border="1" src="{$base_dir}/img/sample-print-top.png" />
</p>
