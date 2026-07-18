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
