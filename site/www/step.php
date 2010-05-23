<?php
   /**
    * Scan step modification page, so that polling decoders can notify the user how
    * the scan is progressing. Some steps are simple progress, others are error markers.
    *
    * Requires global site API password and a scan ID, modifies the steps table.
    */

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    if($_POST['password'] != API_PASSWORD)
        die_with_code(401, 'Sorry, bad password');
    
    $scan_id = $_POST['scan'] ? $_POST['scan'] : null;
    $step_number = is_numeric($_POST['step']) ? $_POST['step'] : null;

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($scan_id && $step_number)
    {
        $bad_steps = array(STEP_ERROR, STEP_BAD_QRCODE);
        $steps_so_far = count(get_steps($dbh, $scan_id, 31));
        
        if(in_array($step_number, $bad_steps) && ($steps_so_far > 30))
        {
            $next_step = ($step_number == STEP_BAD_QRCODE)
                ? STEP_FATAL_QRCODE_ERROR
                : STEP_FATAL_ERROR;
            
            // sort of another magic number, presumably we've tried and tried and tried
            add_step($dbh, $scan_id, $next_step);
            echo "Too many errors\n"; // this is magic text! TODO: remove this responsibility from decode.py

        } else {
            add_step($dbh, $scan_id, $step_number);
            echo "OK\n";
        }
        
        exit();
    }

    die_with_code(400, "Missing scan ID or step number\n");

?>
