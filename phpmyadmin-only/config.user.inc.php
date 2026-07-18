<?php
/**
 * phpMyAdmin security-hardening overrides (standalone).
 *
 * NOTE: whether the "arbitrary server" login field appears is controlled by the
 * PMA_ARBITRARY env var, so it is intentionally NOT set here.
 * Mounted read-only at /etc/phpmyadmin/config.user.inc.php.
 */

declare(strict_types=1);

/* Idle session lifetime in seconds; the user is logged out afterwards. */
$cfg['LoginCookieValidity'] = 1440;

/* Do not persist credentials beyond the browser session. */
$cfg['LoginCookieStore'] = 0;

/* Reduce information disclosure and outbound calls. */
$cfg['VersionCheck']     = false;
$cfg['ShowServerInfo']   = false;
$cfg['SendErrorReports'] = 'never';

/*
 * Encrypt the phpMyAdmin <-> MySQL connection (fixes "SSL is not being used").
 * MySQL 8.4 serves TLS by default with a self-signed auto-generated cert, so we
 * encrypt WITHOUT identity verification (verifying that self-signed cert fails).
 * The PMA_SSL_VERIFY env var can't do this — the image only honours the value 1,
 * so `ssl_verify` must be set to false here in PHP.
 * `1` below is the server index; it is 1 for a single PMA_HOST.
 */
$cfg['Servers'][1]['ssl']        = true;
$cfg['Servers'][1]['ssl_verify'] = false;
