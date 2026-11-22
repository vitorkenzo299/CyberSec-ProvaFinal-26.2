<?php
/** Plugin Name: ABC Place Academic Catalog; License: GPL-2.0-or-later */
if (!defined('ABSPATH')) { http_response_code(404); exit; }
// O laboratório demonstra a plataforma sem habilitar operação comercial.
add_filter('woocommerce_is_purchasable', '__return_false');
add_filter('woocommerce_variation_is_purchasable', '__return_false');
add_filter('xmlrpc_enabled', '__return_false');
add_filter('wp_is_application_passwords_available', '__return_false');
add_filter('rest_authentication_errors', function ($result) {
    if ($result || is_user_logged_in()) return $result;
    return new WP_Error('academic_catalog_read_only', 'API restrita no laboratório.', ['status'=>403]);
});
remove_action('wp_head', 'wp_generator');
add_action('send_headers', function () { header_remove('X-Powered-By'); });
