<?php
/**
 * Plugin Name: CwCloud Email API plugin
 * Plugin URI:  https://doc.cloud.comwork.io
 * Description: Replaces WordPress SMTP with the custom email API.
 * Version:     1.0.0
 * Author:      Idriss Neumann
 * Author URI:  https://www.comwork.io
 */

function custom_email_send($phpmailer) {
    $api_endpoint = 'https://CWCLOUD_ENDPOINT_URL';

    $data = array(
        'from' => $phpmailer->From,
        'to' => $phpmailer->AddAddress,
        'bcc' => $phpmailer->AddBCC,
        'subject' => $phpmailer->Subject,
        'content' => $phpmailer->Body
    );

    $json_data = json_encode($data);
    $bearer_token = getenv('CWCLOUD_API_TOKEN');

    $headers = array(
        'Accept: application/json',
        'Content-Type: application/json',
        'Authorization: Bearer ' . $bearer_token
    );

    $ch = curl_init($api_endpoint);
    curl_setopt($ch, CURLOPT_POST, 1);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $json_data);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    curl_close($ch);

    $phpmailer->ClearAllRecipients();
    $phpmailer->ClearAttachments();
    $phpmailer->ClearCustomHeaders();
    $phpmailer->ClearReplyTos();
}

add_action('phpmailer_init', 'custom_email_send');
