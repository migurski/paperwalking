<?php

    putenv("TZ=America/Los_Angeles");
    define('DB_DSN', 'mysql://****:****@****/****');
    define('TMP_DIR', dirname(realpath(__FILE__)).'/../tmp');
    
    define('API_PASSWORD', '*** you choose this ***');

    // Yahoo GeoPlanet application ID
    define('GEOPLANET_APPID', '*** http://developer.yahoo.com/geo/geoplanet/ ***');

    // Cloudmade developer key
    define('CLOUDMADE_KEY', '*** http://developers.cloudmade.com/ ***');

    // Amazon S3
    define('AWS_ACCESS_KEY', '*** http://aws.amazon.com/ ***');
    define('AWS_SECRET_KEY', '****');
    define('S3_BUCKET_ID',   '****');

?>
