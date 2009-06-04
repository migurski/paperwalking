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
    
    $dbh =& get_db_connection();
    
    if($zoom && $north && $south && $east && $west)
    {
        $dbh->query('START TRANSACTION');
        
        $print = add_print($dbh);
        
        $print['north'] = $north;
        $print['south'] = $south;
        $print['east'] = $east;
        $print['west'] = $west;
        
        $print = set_print($dbh, $print);
        
        $dbh->query('COMMIT');
        
        $width = 360;
        $height = 456;
        
        $req = new HTTP_Request('http://'.WSCOMPOSE_HOSTPORT.'/?provider=CLOUDMADE_FINELINE');
        $req->addQueryString('latitude', ($north + $south) / 2);
        $req->addQueryString('longitude', ($east + $west) / 2);
        $req->addQueryString('zoom', $zoom);
        $req->addQueryString('width', $width);
        $req->addQueryString('height', $height);
        
        $res = $req->sendRequest();
        
        if(PEAR::isError($res))
            die_with_code(500, "{$res->message}\n{$q}\n");

        // post a preview
        $url = new Net_URL($print['preview_url']);
        $res = s3_post_file(ltrim($url->path, '/'), $req->getResponseBody(), 'image/png');
        
        if(PEAR::isError($res))
            die_with_code(500, "{$res->message}\n{$q}\n");
        
        $max_zoom = min(18, $zoom + 2);
        
        while($zoom < $max_zoom)
        {
            $zoom += 1;
            $width *= 2;
            $height *= 2;
        }

        $req = new HTTP_Request('http://'.WSCOMPOSE_HOSTPORT.'/?provider=CLOUDMADE_FINELINE');
        $req->addQueryString('latitude', ($north + $south) / 2);
        $req->addQueryString('longitude', ($east + $west) / 2);
        $req->addQueryString('zoom', $zoom);
        $req->addQueryString('width', $width);
        $req->addQueryString('height', $height);
        
        $res = $req->sendRequest();
        
        if(PEAR::isError($res))
            die_with_code(500, "{$res->message}\n{$q}\n");

        $print_url = 'http://'.get_domain_name().get_base_dir().'/print.php?id='.urlencode($print['id']);
    
        $pdf = new FPDF('P', 'pt', 'letter');
        $pdf->addPage();
        
        $icon_filename = realpath(dirname(__FILE__).'/../lib/print/icon.png');
        $pdf->image($icon_filename, 35.99, 42.87, 19.2, 25.6);
        
        $hand_filename = realpath(dirname(__FILE__).'/../lib/print/Hand.png');
        $pdf->image($hand_filename, 516, 30, 66, 48);
        
        $map_img = imagecreatefromstring($req->getResponseBody());
        $map_filename = tempnam(TMP_DIR, 'composed-map-');
        imagejpeg($map_img, $map_filename, 75);
        $pdf->image($map_filename, 36, 72, 540, 684, 'jpg');
        
        $pdf->setFont('Helvetica', 'B', 24);
        $pdf->text(62.61, 68.49, 'Walking Papers');
        
        $pdf->setFillColor(0xFF);
        $pdf->rect(35, 729, 200, 28, 'F');
        
        $ccbysa_filename = realpath(dirname(__FILE__).'/../lib/print/CCBYSA.png');
        $pdf->image($ccbysa_filename, 30, 732, 67, 30);

        $pdf->setFont('Helvetica', '', 9);
        $pdf->text(254, 57.74, 'Help improve OpenStreetMap by drawing on this map, then visit');
        $pdf->text(254, 68.74, $print_url);
        $pdf->text(99, 744.5, 'Map data ©2009 CC-BY-SA');
        $pdf->text(99, 755.5, 'OpenStreetMap.org contributors');

        $size = 64;
        $pad = 8;
        
        $pdf->setFillColor(0xFF);
        $pdf->rect(36 + 540 - $size - $pad, 36 + 720 - $size - $pad, $size + $pad * 2, $size + $pad * 2, 'F');

        $req = new HTTP_Request('http://chart.apis.google.com/chart?chs=264x264&cht=qr&chld=Q|0');
        $req->addQueryString('chl', $print_url);
        $res = $req->sendRequest();
        
        if(PEAR::isError($res))
            die_with_code(500, "{$res->message}\n{$q}\n");
        
        $code_img = imagecreatefromstring($req->getResponseBody());
        $code_filename = tempnam(TMP_DIR, 'composed-code-');
        imagepng($code_img, $code_filename);
        $pdf->image($code_filename, 36 + 540 - $size, 36 + 720 - $size, $size, $size, 'png');
        
        $pdf_content = $pdf->output('', 'S');
        
        // post the PDF
        $url = new Net_URL($print['pdf_url']);
        $res = s3_post_file(ltrim($url->path, '/'), $pdf_content, 'application/pdf');
        
        if(PEAR::isError($res))
            die_with_code(500, "{$res->message}\n{$q}\n");
        
        unlink($map_filename);
        unlink($code_filename);
        
        header("Location: {$print_url}");
    }
    
    /**** ... ****/
    
    
    $sm = get_smarty_instance();
    $sm->assign('url', $url);
    $sm->assign('width', $width);
    $sm->assign('height', $height);
    
    header("Content-Type: text/html; charset=UTF-8");
    print $sm->fetch("compose.html.tpl");

    print_r($map_headers);
    print_r($code_headers);

?>
