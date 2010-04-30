{if $step.number == $constants.STEP_FATAL_ERROR || $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
    <p>
        {$step.number|step_description|escape}, giving up.
    </p>
    <p>
        Probeer eventueel opnieuw de scan te uploaden, zorg er daarbij voor
        dat de resolutie voldoende is (meer dan 200 dpi) en met de rechterzijde naar boven.
        Hierbij is het belangrijk dat de <a href="http://en.wikipedia.org/wiki/QR_Code">QR Code</a>
        goed leesbaar is. Wanneer dat niet helpt, 
        <a href="mailto:info@walking-papers.org?subject=Problem%20with%20scan%20#{$scan.id|escape}">laat het ons weten</a>.
    </p>
    
    {if $step.number == $constants.STEP_FATAL_QRCODE_ERROR}
        <p>
            Hier is een deel van de scan waarop ons systeem geprobeerd heeft de code te vinden:
        </p>
        <p>
            <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
        </p>
    {/if}
    
{else}
    <p>
        De gescande afbeelding wordt verwerkt.
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
            {$step.number|step_description|escape}, een ogenblik geduld alstublieft.
            We proberen de scan opnieuw te verwerken.
        </p>
        
        {if $step.number == $constants.STEP_BAD_QRCODE}
            <p>
                Hier is het deel van de scan waarop ons systeem geprobeerd heeft de code te vinden:
            </p>
            <p>
                <img width="65%" border="1" src="{$scan.base_url}/qrcode.jpg" />
            </p>
        {/if}
        
    {else}
        <p>
            Het kan even duren, meestal een paar minuten.
            Het is niet nodig deze pagina open te houden, je kunt ook een 
            <a href="{$base_dir}/scan.php?id={$scan.id|escape}">bookmark</a> van deze pagina
            maken en later terugkomen.
        </p>
    {/if}
{/if}
