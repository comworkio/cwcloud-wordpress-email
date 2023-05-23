<?php
/**
 * Plugin Name: CwCloud Email API plugin
 * Plugin URI:  https://doc.cloud.comwork.io
 * Description: Replaces WordPress SMTP with the custom email API.
 * Version:     1.0.0
 * Author:      Idriss Neumann
 * Author URI:  https://www.comwork.io
 */

function custom_email_plugin_settings() {
    add_options_page(
        'Custom Email Plugin Settings',
        'Custom Email Plugin',
        'manage_options',
        'custom-email-plugin-settings',
        'custom_email_plugin_settings_page'
    );
}

add_action('admin_menu', 'custom_email_plugin_settings');

function custom_email_plugin_settings_page() {
    ?>
    <div class="wrap">
        <h1>Custom Email Plugin Settings</h1>
        <form method="post" action="options.php">
            <?php
            settings_fields('custom-email-plugin-settings');
            do_settings_sections('custom-email-plugin-settings');
            submit_button();
            ?>
        </form>
    </div>
    <?php
}

function custom_email_plugin_register_settings() {
    add_settings_section(
        'custom-email-plugin-section',
        'API Settings',
        'custom_email_plugin_section_callback',
        'custom-email-plugin-settings'
    );

    add_settings_field(
        'cwcloud-api-secret',
        'Bearer Token',
        'custom_email_plugin_bearer_token_callback',
        'custom-email-plugin-settings',
        'custom-email-plugin-section'
    );

    register_setting(
        'custom-email-plugin-settings',
        'cwcloud-api-secret'
    );
}
add_action('admin_init', 'custom_email_plugin_register_settings');

function custom_email_plugin_section_callback() {
    echo 'Enter your API secret key below:';
}

function custom_email_plugin_bearer_token_callback() {
    $token = get_option('cwcloud-api-secret');
    echo '<input type="text" name="cwcloud-api-secret" value="' . esc_attr($token) . '" />';
}

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

add_action('phpmailer_init', 'custom_email_send');
