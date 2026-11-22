<?php
/**
 * ABC Place MySQL connection requiring a trusted RDS certificate and host name.
 * Uses the documented wpdb drop-in interface. GPL-2.0-or-later.
 * Reference: https://developer.wordpress.org/reference/classes/wpdb/
 */
if (!defined('ABSPATH')) { http_response_code(404); exit; }
class ABCPlace_TLS_DB extends wpdb {
    public function db_connect($allow_bail=true) {
        mysqli_report(MYSQLI_REPORT_OFF);
        $this->dbh = mysqli_init();
        mysqli_options($this->dbh, MYSQLI_OPT_CONNECT_TIMEOUT, 8);
        mysqli_ssl_set($this->dbh, null, null, '/opt/cyberfinal/rds-ca-bundle.pem', null, null);
        mysqli_options($this->dbh, MYSQLI_OPT_SSL_VERIFY_SERVER_CERT, true);
        if (!@mysqli_real_connect($this->dbh, DB_HOST, DB_USER, DB_PASSWORD, DB_NAME, 3306, null, MYSQLI_CLIENT_SSL)) {
            $this->dbh = null;
            if ($allow_bail) $this->bail('Banco acadêmico indisponível.');
            return false;
        }
        $this->init_charset();
        $this->set_charset($this->dbh);
        $this->set_sql_mode();
        $this->ready=true;
        $this->select(DB_NAME,$this->dbh);
        return true;
    }
}
$wpdb = new ABCPlace_TLS_DB(DB_USER, DB_PASSWORD, DB_NAME, DB_HOST);
