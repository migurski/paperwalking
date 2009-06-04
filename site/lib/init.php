<?php

    putenv("TZ=America/Los_Angeles");
    define('DB_DSN', 'mysql://****:****@****/****');
    define('TMP_DIR', dirname(realpath(__FILE__)).'/../tmp');
    
    define('API_PASSWORD', '*** you choose this ***');

    // ws-compose.py host:port
    define('WSCOMPOSE_HOSTPORT', '*** python port of http://modestmaps.com/ ***');

    // Yahoo GeoPlanet application ID
    define('GEOPLANET_APPID', '*** http://developer.yahoo.com/geo/geoplanet/ ***');

    // Cloudmade developer key
    define('CLOUDMADE_KEY', '*** http://developers.cloudmade.com/ ***');

    // Flickr application key
    define('FLICKR_KEY', '*** http://www.flickr.com/services/api/keys/ ***');

    // Amazon S3
    define('AWS_ACCESS_KEY', '*** http://aws.amazon.com/ ***');
    define('AWS_SECRET_KEY', '****');
    define('S3_BUCKET_ID',   '****');

?>
