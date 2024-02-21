<?php
/**
 * Plugin Name: CwCloud Email API plugin
 * Plugin URI:  https://doc.cloud.comwork.io
 * Description: Replaces WordPress SMTP with the CwCloud email API.
 * Version:     1.0.0
 * Author:      Idriss Neumann
 * Author URI:  https://www.comwork.io
 */

function cwcloud_email_plugin_settings() {
    add_options_page(
        'CwCloud Email Plugin Settings',
        'CwCloud Email Plugin',
        'manage_options',
        'cwcloud-email-plugin-settings',
        'cwcloud_email_plugin_settings_page'
    );
}

add_action('admin_menu', 'cwcloud_email_plugin_settings');

function cwcloud_email_plugin_settings_page() {
    ?>
    <div class="wrap">
        <h1>CwCloud Email Plugin Settings</h1>
        <form method="post" action="options.php">
            <?php
            settings_fields('cwcloud-email-plugin-settings');
            do_settings_sections('cwcloud-email-plugin-settings');
            submit_button();
            ?>
        </form>
    </div>
    <?php
}

function cwcloud_email_plugin_register_settings() {
    add_settings_section(
        'cwcloud-email-plugin-section',
        'API Settings',
        'cwcloud_email_plugin_section_callback',
        'cwcloud-email-plugin-settings'
    );

    add_settings_field(
        'cwcloud-api-secret',
        'Secret Key',
        'cwcloud_email_plugin_secret_token_callback',
        'cwcloud-email-plugin-settings',
        'cwcloud-email-plugin-section'
    );

    register_setting(
        'cwcloud-email-plugin-settings',
        'cwcloud-api-secret'
    );
}
add_action('admin_init', 'cwcloud_email_plugin_register_settings');

function cwcloud_email_plugin_section_callback() {
    echo 'Enter your API secret key below:';
}

function cwcloud_email_plugin_secret_token_callback() {
    $token = get_option('cwcloud-api-secret');
    echo '<input type="text" name="cwcloud-api-secret" value="' . esc_attr($token) . '" />';
}

function cwcloud_email_send($phpmailer) {
    $api_endpoint = 'https://CWCLOUD_ENDPOINT_URL/v1/email';

    $from_addr = $phpmailer->From;
    $to_addr = $phpmailer->AddAddress;

    if (!$to_addr && !empty($tmp_to_addr = $phpmailer->getToAddresses()) && !empty($tmp_to_addr[0]) && $tmp_to_addr[0][0]) {
        $to_addr = $tmp_to_addr[0][0];
    }

    if (!$to_addr) {
        $to_addr = $from_addr;
    }

    $bcc_addr = $phpmailer->AddBCC ? $phpmailer->AddBCC : null;

    $data = array(
        'from' => $from_addr,
        'to' => $to_addr,
        'bcc' => $bcc_addr,
        'subject' => $phpmailer->Subject,
        'content' => $phpmailer->Body
    );

    $json_data = json_encode($data);
    $secret_key = getenv('CWCLOUD_API_SECRET_KEY');

    $headers = array(
        'Accept: application/json',
        'Content-Type: application/json',
        'X-Auth-Token: ' . get_option('cwcloud-api-secret')
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

add_action('phpmailer_init', 'cwcloud_email_send');
