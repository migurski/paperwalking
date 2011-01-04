{if $step.number == $constants.STEP_FATAL_ERROR || $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
    <p>
        {$step.number|step_description|escape}, giving up.
    </p>
    <p>
        You might try uploading your scan again, making sure that
        it’s at a reasonably high resolution (200+ dpi for a full
        sheet of paper is normal) and right-side up. A legible 
        <a href="http://en.wikipedia.org/wiki/QR_Code">QR code</a> is critical.
        If this doesn’t help,
        <a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">let us know</a>.
    </p>
    
    {if $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
        <p>
            Here’s the part of your scan where we tried to find a code:
        </p>
        <p>
            <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
        </p>
        <p>
            Does it look like a <a href="http://en.wikipedia.org/w/index.php?title=QR_Code&amp;oldid=405297309">QR code</a>?
        </p>
        <p>
            All is not lost. Fill this:
        </p>
        <p>
            <img border="1" src="{$base_dir}/img/sample-print-top.png" />
        </p>
        <p>
            ...in here:
        </p>
        <form action="{$base_dir}/scan.php?id={$scan.id|escape}" method="post">
            <input name="qrcode_contents" type="text" />
            <input name="action" type="hidden" value="override QR code" />
            <input class="mac-button" type="submit" value="Save" />
        </form>
    {/if}
    
{else}
    <p>
        Processing your scanned image.
    </p>

    <ol class="steps">
        <li class="{if $step.number == 0}on{/if}">{0|step_description|escape}</li>
        <li class="{if $step.number == 1}on{/if}">{1|step_description|escape}</li>
        <li class="{if $step.number == 2}on{/if}">{2|step_description|escape}</li>
        <li class="{if $step.number == 3}on{/if}">{3|step_description|escape}</li>
        <li class="{if $step.number == 4}on{/if}">{4|step_description|escape}</li>
        <li class="{if $step.number == 5}on{/if}">{5|step_description|escape}</li>
        <li class="{if $step.number == 6}on{/if}">{6|step_description|escape}</li>
    </ol>

    {if $step.number >= 7}
        <p>
            {$step.number|step_description|escape}, please stand by.
            We will try to process your scan again shortly.
        </p>
        
        {if $step.number == $constants.STEP_BAD_QRCODE}
            <p>
                Here’s the part of your scan where we tried to find a code:
            </p>
            <p>
                <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
            </p>
        {/if}
        
    {else}
        <p>
            This may take a little while, generally a few minutes.
            You don’t need to keep this browser window open—you can
            <a href="{$base_dir}/scan.php?id={$scan.id|escape}">bookmark this page</a>
            and come back later.
        </p>
    {/if}
{/if}
