<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    $user_id = $_COOKIE['visitor'] ? $_COOKIE['visitor'] : null;

    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    if($user_id)
        $user = get_user($dbh, $user_id);

    if($user)
        setcookie('visitor', $user['id'], time() + 86400 * 31);
    


    $res = $dbh->query('SELECT COUNT(*) FROM prints');
    
    if(PEAR::isError($res)) 
        die_with_code(500, "{$res->message}\n");

    $print_count = end($res->fetchRow());
    


    $res = $dbh->query('SELECT COUNT(*)
                        FROM scans
                        WHERE last_step = '.STEP_FINISHED);
    
    if(PEAR::isError($res)) 
        die_with_code(500, "{$res->message}\n");

    $scan_count = end($res->fetchRow());
    
    
    
    $hemisphere_count = array('northern' => 0, 'southern' => 0, 'eastern' => 0, 'western' => 0);
    
    $res = $dbh->query('SELECT (north + south) / 2 AS latitude,
                               (east + west) / 2 AS longitude
                        FROM prints');

    if(PEAR::isError($res)) 
        die_with_code(500, "{$res->message}\n");

    while($row = $res->fetchRow(DB_FETCHMODE_ASSOC))
    {
        $hemisphere_count['northern'] += ($row['latitude'] > 0 ? 1 : 0);
        $hemisphere_count['southern'] += ($row['latitude'] < 0 ? 1 : 0);
        $hemisphere_count['eastern'] += ($row['longitude'] > 0 ? 1 : 0);
        $hemisphere_count['western'] += ($row['longitude'] < 0 ? 1 : 0);
    }

    $hemisphere_percent = array(
        'northern' => round(100 * $hemisphere_count['northern'] / ($hemisphere_count['northern'] + $hemisphere_count['southern'])),
        'southern' => round(100 * $hemisphere_count['southern'] / ($hemisphere_count['northern'] + $hemisphere_count['southern'])),
        'eastern' => round(100 * $hemisphere_count['eastern'] / ($hemisphere_count['eastern'] + $hemisphere_count['western'])),
        'western' => round(100 * $hemisphere_count['western'] / ($hemisphere_count['eastern'] + $hemisphere_count['western']))
    );
    
    
    
    $zooms = array(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    
    if(in_array('zoom', array_keys(table_columns($dbh, 'prints'))))
    {
        $res = $dbh->query('SELECT zoom, count(*) AS prints
                            FROM prints
                            WHERE zoom
                            GROUP BY zoom
                            ORDER BY zoom');
    
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n");
    
        while($row = $res->fetchRow(DB_FETCHMODE_ASSOC))
            $zooms[$row['zoom']] = $row['prints'];
    }
    
    
    
    $country_names = array();
    $country_counts = array();
    $country_percents = array();
    
    if(in_array('country_woeid', array_keys(table_columns($dbh, 'prints'))))
    {
        $res = $dbh->query('SELECT country_woeid, country_name, COUNT(*) AS print_count
                            FROM prints
                            WHERE country_woeid
                            GROUP BY country_woeid
                            ORDER BY print_count DESC');
    
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n");
    
        $total = 0;
        
        while($row = $res->fetchRow(DB_FETCHMODE_ASSOC))
        {
            $total += $row['print_count'];
        
            if($country_counts[$row['country_woeid']]) {
                $country_counts[$row['country_woeid']] += $row['print_count'];

            } else {
                $country_names[$row['country_woeid']] = $row['country_name'];
                $country_counts[$row['country_woeid']] = $row['print_count'];
            }
        }
        
        foreach($country_counts as $woeid => $count)
            $country_percents[$woeid] = 100 * $count / $total;
    }
    


    $sm = get_smarty_instance();
    //$sm->assign('print_count', $print_count);
    //$sm->assign('scan_count', $scan_count);
    $sm->assign('print_percent', round(100 * $print_count / ($print_count + $scan_count)));
    $sm->assign('scan_percent', round(100 * $scan_count / ($print_count + $scan_count)));
    //$sm->assign('hemisphere_count', $hemisphere_count);
    $sm->assign('hemisphere_percent', $hemisphere_percent);
    $sm->assign('country_names', $country_names);
    //$sm->assign('country_counts', $country_counts);
    $sm->assign('country_percents', $country_percents);
    $sm->assign('zooms', $zooms);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("errata.html.tpl");

?>
