<form id="language" action="{$base_dir}/language.php" method="post">
    <p>
        Language:
        <input type="hidden" name="referer" value="{* http://{$domain|escape} *}{$request.uri|escape}"/>
        <button type="submit" class="{if $language == "en"}selected{/if}" name="language" value="en">English</button>
        <button type="submit" class="{if $language == "de"}selected{/if}" name="language" value="de">Deutsche</button>
    </p>
</form>

<h1><a href="{$base_dir}/"><img src="{$base_dir}/icon.png" border="0" align="bottom" alt="" /> Walking Papers</a></h1>

<p id="navigation">
    <a href="{$base_dir}/">Home</a>
    <a href="{$base_dir}/prints.php">Prints</a>
    <a href="{$base_dir}/scans.php">Scans</a>
    <a href="{$base_dir}/upload.php">Upload</a>
    <a href="{$base_dir}/zeitgeist.php">Zeitgeist</a>
    <a href="{$base_dir}/about.php">About</a>
</p>
