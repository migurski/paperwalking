<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    $scan_id = $_POST['scan'] ? $_POST['scan'] : null;
    $step_number = is_numeric($_POST['step']) ? $_POST['step'] : null;
    
    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($scan_id && $step_number)
    {
        switch($step_number)
        {
            case 2:
                $description = 'Sifted';
                break;

            case 3:
                $description = 'Needles found';
                break;

            case 4:
                $description = 'QR code read';
                break;

            case 5:
                $description = 'Tiled';
                break;

            case 6:
                $description = 'Finished uploading';
                break;

            case 99:
                $description = 'An error has occured';
                break;

            default:
                die_with_code(400, "Unrecognized step number, should be 2 - 6\n");
        }
        
        add_step($dbh, $scan_id, $step_number, $description);
        echo "OK\n";
        exit();
    }

    die_with_code(400, "Missing scan ID or step number\n");

?>
