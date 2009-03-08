<?php

    require_once 'JSON.php';
    require_once 'PEAR.php';
    require_once 'DB.php';
    require_once 'output.php';
    require_once 'FPDF/fpdf.php';
    require_once 'Crypt/HMAC.php';
    require_once 'HTTP/Request.php';
    require_once 'Net/URL.php';
    
    function &get_db_connection()
    {
        return DB::connect(DB_DSN);
    }
    
    if(!function_exists('json_encode'))
    {
        function json_encode($value)
        {
            $json = new Services_JSON(SERVICES_JSON_LOOSE_TYPE);
            return $json->encode($value);
        }
    }
    
    function generate_id()
    {
        $chars = 'qwrtypsdfghjklzxcvbnm0123456789';
        $id = '';
        
        while(strlen($id) < 8)
            $id .= substr($chars, rand(0, strlen($chars) - 1), 1);

        return $id;
    }
    
    function add_print(&$dbh)
    {
        while(true)
        {
            $print_id = generate_id();
            
            $q = sprintf('INSERT INTO prints
                          SET id = %s',
                         $dbh->quoteSmart($print_id));

            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res)) 
            {
                if($res->getCode() == DB_ERROR_ALREADY_EXISTS)
                    continue;
    
                die_with_code(500, "{$res->message}\n{$q}\n");
            }
            
            return get_print($dbh, $print_id);
        }
    }
    
    function add_scan(&$dbh)
    {
        while(true)
        {
            $scan_id = generate_id();
            
            $q = sprintf('INSERT INTO scans
                          SET id = %s',
                         $dbh->quoteSmart($scan_id));

            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res)) 
            {
                if($res->getCode() == DB_ERROR_ALREADY_EXISTS)
                    continue;
    
                die_with_code(500, "{$res->message}\n{$q}\n");
            }
            
            add_step($dbh, $scan_id, 0, 'Getting ready to upload');
            
            return get_scan($dbh, $scan_id);
        }
    }
    
    function add_step(&$dbh, $scan_id, $number, $description)
    {
        $q = sprintf('INSERT INTO steps
                      SET scan_id = %s, number = %d, description = %s',
                     $dbh->quoteSmart($scan_id),
                     $number,
                     $dbh->quoteSmart($description));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
        {
            if($res->getCode() == DB_ERROR_ALREADY_EXISTS)
                return false;

            die_with_code(500, "{$res->message}\n{$q}\n");
        }

        $q = sprintf('UPDATE scans
                      SET last_step = %s
                      WHERE id = %s',
                     $number,
                     $dbh->quoteSmart($scan_id));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        return true;
    }
    
    function add_message(&$dbh, $content)
    {
        $q = sprintf('INSERT INTO messages
                      SET content = %s, available = NOW()',
                     $dbh->quoteSmart($content));

        error_log(preg_replace('/\s+/', ' ', $q));

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        return true;
    }
    
    function get_print(&$dbh, $print_id)
    {
        $q = sprintf('SELECT id, north, south, east, west,
                             UNIX_TIMESTAMP(created) AS created
                      FROM prints
                      WHERE id = %s',
                     $dbh->quoteSmart($print_id));
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $row = $res->fetchRow(DB_FETCHMODE_ASSOC);
        
        $row['pdf_url'] = sprintf('http://%s.s3.amazonaws.com/prints/%s/walking-paper-%s.pdf', S3_BUCKET_ID, $print_id, $print_id);
        $row['preview_url'] = sprintf('http://%s.s3.amazonaws.com/prints/%s/preview.png', S3_BUCKET_ID, $print_id);
        
        return $row;
    }
    
    function get_scan(&$dbh, $scan_id)
    {
        $q = sprintf('SELECT *
                      FROM scans
                      WHERE id = %s',
                     $dbh->quoteSmart($scan_id));
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        return $res->fetchRow(DB_FETCHMODE_ASSOC);
    }
    
    function get_step(&$dbh, $scan_id, $number=false)
    {
        if(is_numeric($number)) {
            $q = sprintf('SELECT *
                          FROM steps
                          WHERE scan_id = %s
                            AND number = %d',
                         $dbh->quoteSmart($scan_id),
                         $number);

        } else {
            $q = sprintf('SELECT *
                          FROM steps
                          WHERE scan_id = %s
                          ORDER BY created DESC
                          LIMIT 1',
                         $dbh->quoteSmart($scan_id));
        }
                     
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        return $res->fetchRow(DB_FETCHMODE_ASSOC);
    }
    
    /*
    function get_message(&$dbh, $message_id)
    {
        $q = sprintf('SELECT id, content
                      FROM messages
                      WHERE available < NOW()
                        AND deleted = 0
                        AND id = %d',
                     $message_id);
    
        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        return $res->fetchRow(DB_FETCHMODE_ASSOC);
    }
    */
    
    function get_message(&$dbh, $timeout)
    {
        $res = $dbh->query('LOCK TABLES messages WRITE');
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        $q = sprintf('SELECT id, content
                      FROM messages
                      WHERE available < NOW()
                        AND deleted = 0');

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        if($msg = $res->fetchRow(DB_FETCHMODE_ASSOC)) {
            postpone_message($dbh, $msg['id'], $timeout);

        } else {
            $msg = false;
        }

        $res = $dbh->query('UNLOCK TABLES');
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");
        
        return $msg;
    }
    
    function set_print(&$dbh, $print)
    {
        $old_print = get_print($dbh, $print['id']);
        
        if(!$old_print)
            return false;

        $update_clauses = array();

        foreach(array('north', 'south', 'east', 'west', 'user_name') as $field)
            if(!is_null($print[$field]))
                if($print[$field] != $old_print[$field])
                    $update_clauses[] = sprintf('%s = %s', $field, $dbh->quoteSmart($print[$field]));

        if(empty($update_clauses)) {
            error_log("skipping print {$print['id']} update since there's nothing to change");

        } else {
            $update_clauses = join(', ', $update_clauses);
            
            $q = sprintf("UPDATE prints
                          SET {$update_clauses}
                          WHERE id = %s",
                         $dbh->quoteSmart($print['id']));
    
            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res))
                die_with_code(500, "{$res->message}\n{$q}\n");
        }

        return get_print($dbh, $print['id']);
    }
    
    function set_scan(&$dbh, $scan)
    {
        $old_scan = get_scan($dbh, $scan['id']);
        
        if(!$old_scan)
            return false;

        $update_clauses = array();

        foreach(array('print_id', 'last_step', 'user_name', 'min_row', 'min_column', 'min_zoom', 'max_row', 'max_column', 'max_zoom') as $field)
            if(!is_null($scan[$field]))
                if($scan[$field] != $old_scan[$field])
                    $update_clauses[] = sprintf('%s = %s', $field, $dbh->quoteSmart($scan[$field]));

        if(empty($update_clauses)) {
            error_log("skipping scan {$scan['id']} update since there's nothing to change");

        } else {
            $update_clauses = join(', ', $update_clauses);
            
            $q = sprintf("UPDATE scans
                          SET {$update_clauses}
                          WHERE id = %s",
                         $dbh->quoteSmart($scan['id']));
    
            error_log(preg_replace('/\s+/', ' ', $q));
    
            $res = $dbh->query($q);
            
            if(PEAR::isError($res))
                die_with_code(500, "{$res->message}\n{$q}\n");
        }

        return get_scan($dbh, $scan['id']);
    }
    
    function postpone_message(&$dbh, $message_id, $timeout)
    {
        $q = sprintf('UPDATE messages
                      SET available = NOW() + INTERVAL %d SECOND
                      WHERE id = %d',
                     $timeout,
                     $message_id);

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");
    }
    
    function delete_message(&$dbh, $message_id)
    {
        $q = sprintf('UPDATE messages
                      SET deleted = 1, available = NOW()
                      WHERE id = %d',
                     $message_id);

        $res = $dbh->query($q);
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");
    }
    
    function verify_s3_etag($object_id, $expected_etag)
    {
        $url = s3_signed_object_url($object_id, time() + 300, 'HEAD');
        
        $req = new HTTP_Request($url);
        $req->setMethod('HEAD');
        $res = $req->sendRequest();
        
        if(PEAR::isError($res)) 
            die_with_code(500, "{$res->message}\n{$q}\n");

        if($req->getResponseCode() == 200)
            return $req->getResponseHeader('etag') == $expected_etag;

        return false;
    }

   /**
    * @param    $object_id      Name to assigned
    * @param    $content_bytes  Content of file
    * @param    $mime_type      MIME/Type to assign
    * @return   mixed   URL of uploaded file on success, false or PEAR_Error on failure.
    */
    function s3_post_file($object_id, $content_bytes, $mime_type)
    {
        $bucket_id = S3_BUCKET_ID;
        
        $content_md5_hex = md5($content_bytes);
        $date = date('D, d M Y H:i:s T');
        
        $content_md5 = '';
        
        for($i = 0; $i < strlen($content_md5_hex); $i += 2)
            $content_md5 .= chr(hexdec(substr($content_md5_hex, $i, 2)));

        $content_md5 = base64_encode($content_md5);
        
        $sign_string = "PUT\n{$content_md5}\n{$mime_type}\n{$date}\nx-amz-acl:public-read\n/{$bucket_id}/{$object_id}";
            
        //error_log("String to sign: {$sign_string}");
        
        $crypt_hmac = new Crypt_HMAC(AWS_SECRET_KEY, 'sha1');
        $hashed = $crypt_hmac->hash($sign_string);
        
        $signature = '';
        
        for($i = 0; $i < strlen($hashed); $i += 2)
            $signature .= chr(hexdec(substr($hashed, $i, 2)));
            
        $authorization = sprintf('AWS %s:%s', AWS_ACCESS_KEY, base64_encode($signature));
        
        //error_log("Authorization header: {$authorization}");
        
        $url = "http://{$bucket_id}.s3.amazonaws.com/{$object_id}";
        
        $req = new HTTP_Request($url);

        $req->setMethod('PUT');
        $req->addHeader('Date', $date);
        $req->addHeader('X-Amz-Acl', 'public-read');
        $req->addHeader('Content-Type', $mime_type);
        $req->addHeader('Content-MD5', $content_md5);
        $req->addHeader('Content-Length', strlen($content_bytes));
        $req->addHeader('Authorization', $authorization);
        $req->setBody($content_bytes);
        
        $res = $req->sendRequest();
        
        if(PEAR::isError($res))
            return $res;
        
        if($req->getResponseCode() == 200)
            return $url;

        return false;
    }

   /**
    * Sign a string with the AWS secret key, return it raw.
    */
    function s3_sign_auth_string($string)
    {
        $crypt_hmac = new Crypt_HMAC(AWS_SECRET_KEY, 'sha1');
        $hashed = $crypt_hmac->hash($string);

        $signature = '';

        for($i = 0; $i < strlen($hashed); $i += 2)
            $signature .= chr(hexdec(substr($hashed, $i, 2)));

        return $signature;
    }
    
   /**
    * @param    int     $expires    Expiration timestamp
    * @param    string  $format     Response format for redirect URL
    * @return   array   Associative array with:
    *                   - "access": AWS access key
    *                   - "policy": base64-encoded policy
    *                   - "signature": base64-encoded, signed policy
    *                   - "acl": allowed ACL
    *                   - "key": upload key
    *                   - "bucket": bucket ID
    *                   - "redirect": URL
    */
    function s3_get_post_details($scan_id, $expires, $format=null)
    {
        $acl = 'public-read';
        $key = "{$scan_id}/\${filename}";
        $redirect = 'http://'.get_domain_name().get_base_dir().'/uploaded.php?scan='.rawurlencode($scan_id).(is_null($format) ? '' : "&format={$format}");
        $access = AWS_ACCESS_KEY;
        $bucket = S3_BUCKET_ID;
        
        $policy = array('expiration' => gmdate('Y-m-d', $expires).'T'.gmdate('H:i:s', $expires).'Z',
                        'conditions' => array(
                            array('bucket' => $bucket),
                            array('acl' => $acl),
                            array('starts-with', '$key', "{$scan_id}/"),
                            array('redirect' => $redirect)));

        $policy = base64_encode(json_encode($policy));
        $signature = base64_encode(s3_sign_auth_string($policy));

        return compact('access', 'policy', 'signature', 'acl', 'key', 'redirect', 'bucket');
    }
    
   /**
    * @param    string  object_id   S3 object ID
    * @param    int     $expires    Expiration timestamp
    * @param    string  $method     HTTP method, default GET
    * @return   string  Signed URL
    */
    function s3_signed_object_url($object_id, $expires, $method='GET')
    {
        $object_id_scrubbed = str_replace('+', '%20', str_replace('%2F', '/', rawurlencode($object_id)));
        $sign_string = s3_sign_auth_string(sprintf("%s\n\n\n%d\n/%s/%s", $method, $expires, S3_BUCKET_ID, $object_id_scrubbed));
        
        return sprintf('http://%s.s3.amazonaws.com/%s?Signature=%s&AWSAccessKeyId=%s&Expires=%d',
                       S3_BUCKET_ID,
                       $object_id_scrubbed,
                       urlencode(base64_encode($sign_string)),
                       urlencode(AWS_ACCESS_KEY),
                       urlencode($expires));
    }
    
   /**
    * @param    string  object_id   S3 object ID
    * @return   string  Signed URL
    */
    function s3_unsigned_object_url($object_id)
    {
        $object_id_scrubbed = str_replace('+', '%20', str_replace('%2F', '/', rawurlencode($object_id)));
        
        return sprintf('http://%s.s3.amazonaws.com/%s',
                       S3_BUCKET_ID,
                       $object_id_scrubbed);
    }
    
?>