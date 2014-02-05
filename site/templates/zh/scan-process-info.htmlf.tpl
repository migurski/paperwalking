{if $scan.last_step == $constants.STEP_FATAL_ERROR || $scan.last_step == $constants.STEP_FATAL_QRCODE_ERROR}
    <p>
        {$scan.last_step|step_description|escape}, giving up.
    </p>
    <p>
        你可能要再嘗試上傳你的掃瞄圖一次，並確定圖在在合理的解析度範圍中
        (200以上的dpi對於一張圖而言是相當正常的)且正面朝上，一個清晰可讀的
        <a href="http://en.wikipedia.org/wiki/QR_Code">QR碼</a>是相當需要的。
        如果這個沒幫助的話，
        <a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">讓我們知道/a>.
    </p>
    
    {if $scan.last_step == $constants.STEP_FATAL_QRCODE_ERROR}
        <p>
            這裡是你的掃瞄的一部份，我們試著找出代碼:
        </p>
        <p>
            <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
        </p>
        
        {* TODO: duplicate this file to languages other than English *}
        {include file="en/scan-process-qrcode.htmlf.tpl"}
    {/if}
    
{else}
    <p>
        處理你的掃瞄影像圖中。
    </p>

    <ol class="steps">
        <li class="{if $scan.last_step == 0}on{/if}">{0|step_description|escape}</li>
        <li class="{if $scan.last_step == 1}on{/if}">{1|step_description|escape}</li>
        <li class="{if $scan.last_step == 2}on{/if}">{2|step_description|escape}</li>
        <li class="{if $scan.last_step == 3}on{/if}">{3|step_description|escape}</li>
        <li class="{if $scan.last_step == 4}on{/if}">{4|step_description|escape}</li>
        <li class="{if $scan.last_step == 5}on{/if}">{5|step_description|escape}</li>
        <li class="{if $scan.last_step == 6}on{/if}">{6|step_description|escape}</li>
    </ol>

    {if $scan.last_step >= 7}
        <p>
            {$scan.last_step|step_description|escape}, 請等一下。
            我們很快地將試著再次處理你的掃瞄影像圖。
        </p>
        
        {if $scan.last_step == $constants.STEP_BAD_QRCODE}
            <p>
                這裡是你的掃瞄的一部份，我們試著找出代碼:
            </p>
            <p>
                <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
            </p>
        {/if}
        
    {else}
        <p>
            這也許會花一些時間，一般而言會幾分鐘，你不用將這個瀏覽的視窗開著，你可以T
            <a href="{$base_dir}/scan.php?id={$scan.id|escape}">加這個頁到你的書籤中</a>
            然後等一會兒再回來看看。
        </p>
    {/if}
{/if}
