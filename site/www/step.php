<?php

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
        if($step_number == STEP_ERROR)
        {
            // sort of a magic number, presumably we've tried and tried and tried
            if(count(get_steps($dbh, $scan_id, 31)) > 30)
            {
                add_step($dbh, $scan_id, STEP_FATAL_ERROR);
                echo "Too many errors\n";
                exit();
            }
        }
        
        add_step($dbh, $scan_id, $step_number);
        echo "OK\n";
        exit();
    }

    die_with_code(400, "Missing scan ID or step number\n");

?>
