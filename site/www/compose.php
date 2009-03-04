<?php

    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'../lib');
    ini_set('include_path', ini_get('include_path').PATH_SEPARATOR.'/usr/home/migurski/pear/lib');
    require_once 'init.php';
    require_once 'data.php';
    
    $north = is_numeric($_POST['north']) ? floatval($_POST['north']) : null;
    $south = is_numeric($_POST['south']) ? floatval($_POST['south']) : null;
    $east = is_numeric($_POST['east']) ? floatval($_POST['east']) : null;
    $west = is_numeric($_POST['west']) ? floatval($_POST['west']) : null;
    $zoom = is_numeric($_POST['zoom']) ? intval($_POST['zoom']) : null;
    
    if($zoom && $north && $south && $east && $west)
    {
        $width = 360;
        $height = 480;
        
        $max_zoom = min(18, $zoom + 2);
        
        while($zoom < $max_zoom)
        {
            $zoom += 1;
            $width *= 2;
            $height *= 2;
        }

        $url = new Net_URL('http://osm.stamen.com:10010/?provider=CLOUDMADE_FINELINE');
        $url->addQueryString('latitude', ($north + $south) / 2);
        $url->addQueryString('longitude', ($east + $west) / 2);
        $url->addQueryString('zoom', $zoom);
        $url->addQueryString('width', $width);
        $url->addQueryString('height', $height);
        
        $url = $url->getURL();
        
        $req = new HTTP_Request($url);
        $res = $req->sendRequest();
        
        if(PEAR::isError($res))
            die_with_code(500, "{$res->message}\n{$q}\n");

        $pdf = new FPDF('P', 'pt', 'letter');
        $pdf->addPage();
        
        $map_img = imagecreatefromstring($req->getResponseBody());
        $map_filename = tempnam('/tmp', 'composed-map-');
        imagejpeg($map_img, $map_filename, 65);
        $pdf->image($map_filename, 36, 36, 540, 720, 'jpg');

        $size = 50;
        $pad = 8;
        
        $pdf->setFillColor(0xFF);
        $pdf->rect(36 + 540 - $size - $pad, 36 + 720 - $size - $pad, $size + $pad * 2, $size + $pad * 2, 'F');

        $req = new HTTP_Request('http://chart.apis.google.com/chart?chs=264x264&cht=qr&chld=Q|0');
        $req->addQueryString('chl', 'http://paperwalking/blahblahthisandthatandthese');
        $res = $req->sendRequest();
        
        if(PEAR::isError($res))
            die_with_code(500, "{$res->message}\n{$q}\n");
        
        $code_img = imagecreatefromstring($req->getResponseBody());
        $code_filename = tempnam('/tmp', 'composed-code-');
        imagepng($code_img, $code_filename);
        $pdf->image($code_filename, 36 + 540 - $size, 36 + 720 - $size, $size, $size, 'png');
        
        $pdf->output();
        die();
    }
    
    /**** ... ****/
    
    $dbh =& get_db_connection();
    
    
    $sm = get_smarty_instance();
    $sm->assign('url', $url);
    $sm->assign('width', $width);
    $sm->assign('height', $height);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("compose.html.tpl");

    print_r($map_headers);
    print_r($code_headers);

?>
