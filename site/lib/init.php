<?php

    putenv("TZ=America/Los_Angeles");
    define('DB_DSN', 'mysql://****:****@****/****');
    define('TMP_DIR', dirname(realpath(__FILE__)).'/../tmp');
    
    define('API_PASSWORD', '****');

    // Amazon S3
    define('AWS_ACCESS_KEY', '****');
    define('AWS_SECRET_KEY', '****');
    define('S3_BUCKET_ID',   '****');

?>
