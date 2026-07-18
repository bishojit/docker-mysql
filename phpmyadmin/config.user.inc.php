<?php
/**
 * phpMyAdmin security-hardening overrides.
 *
 * This file is merged on top of the image-generated config (which already sets
 * the server host, cookie auth and a random blowfish secret from PMA_* env).
 * Mounted read-only at /etc/phpmyadmin/config.user.inc.php.
 */

declare(strict_types=1);

/* Only ever connect to the bundled MySQL — no free-form server field. */
$cfg['AllowArbitraryServer'] = false;

/* Idle session lifetime in seconds; the user is logged out afterwards. */
$cfg['LoginCookieValidity'] = 1440;

/* Do not persist credentials beyond the browser session. */
$cfg['LoginCookieStore'] = 0;

/* Reduce information disclosure and outbound calls. */
$cfg['VersionCheck']     = false;
$cfg['ShowServerInfo']   = false;
$cfg['SendErrorReports'] = 'never';
