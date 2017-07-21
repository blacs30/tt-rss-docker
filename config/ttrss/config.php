<?php
include_once "config-user.php";

if( ! defined("DB_TYPE") && getenv("DB_TYPE") !== False ){
  define('DB_TYPE', getenv("DB_TYPE"));
}
if( ! defined("DB_HOST") && getenv("DB_HOST") !== False ){
  define('DB_HOST', getenv("DB_HOST"));
}
if( ! defined("DB_USER") && getenv("DB_USER") !== False ){
  define('DB_USER', getenv("DB_USER"));
}
if( ! defined("DB_NAME") && getenv("DB_NAME") !== False ){
  define('DB_NAME', getenv("DB_NAME"));
}
if( ! defined("DB_PASS") && getenv("DB_PASS") !== False ){
  define('DB_PASS', getenv("DB_PASS"));
}
if( ! defined("DB_PORT") && getenv("DB_PORT") !== False ){
  define('DB_PORT', getenv("DB_PORT"));
}

if( ! defined("SELF_URL_PATH") && getenv("SELF_URL_PATH") !== False ){
  define('SELF_URL_PATH', getenv("SELF_URL_PATH"));
}
if( ! defined("SINGLE_USER_MODE") && getenv("SINGLE_USER_MODE") !== False ){
  define('SINGLE_USER_MODE', filter_var(getenv("SINGLE_USER_MODE"), FILTER_VALIDATE_BOOLEAN) );
}

// setting default values, see config.php-dist fom tt-rss GIT for details

if( ! defined("MYSQL_CHARSET") ){
  define('MYSQL_CHARSET', 'UTF8');
}

if( ! defined("FEED_CRYPT_KEY") ){
  define('FEED_CRYPT_KEY', '');
}

if( ! defined("SINGLE_USER_MODE") ){
  define('SINGLE_USER_MODE', false);
}
if( ! defined("SIMPLE_UPDATE_MODE") ){
  define('SIMPLE_UPDATE_MODE', false);
}
if( ! defined("PHP_EXECUTABLE") ){
  define('PHP_EXECUTABLE', '/usr/bin/php');
}
if( ! defined("LOCK_DIRECTORY") ){
  define('LOCK_DIRECTORY', 'lock');
}
if( ! defined("CACHE_DIR") ){
  define('CACHE_DIR', 'cache');
}
if( ! defined("ICONS_DIR") ){
  define('ICONS_DIR', "feed-icons");
}
if( ! defined("ICONS_URL") ){
  define('ICONS_URL', "feed-icons");
}
if( ! defined("AUTH_AUTO_CREATE") ){
  define('AUTH_AUTO_CREATE', true);
}
if( ! defined("AUTH_AUTO_LOGIN") ){
  define('AUTH_AUTO_LOGIN', true);
}
if( ! defined("FORCE_ARTICLE_PURGE") ){
  define('FORCE_ARTICLE_PURGE', 0);
}
if( ! defined("SPHINX_SERVER") ){
  define('SPHINX_SERVER', 'localhost:9312');
}
if( ! defined("SPHINX_INDEX") ){
  define('SPHINX_INDEX', 'ttrss, delta');
}
if( ! defined("ENABLE_REGISTRATION") ){
  define('ENABLE_REGISTRATION', false);
}
if( ! defined("REG_NOTIFY_ADDRESS") ){
  define('REG_NOTIFY_ADDRESS', 'user@your.domain.dom');
}
if( ! defined("REG_MAX_USERS") ){
  define('REG_MAX_USERS', 10);
}
if( ! defined("SESSION_COOKIE_LIFETIME") ){
  define('SESSION_COOKIE_LIFETIME', 86400);
}
if( ! defined("SMTP_FROM_NAME") ){
  define('SMTP_FROM_NAME', 'Tiny Tiny RSS');
}
if( ! defined("SMTP_FROM_ADDRESS") ){
  define('SMTP_FROM_ADDRESS', 'noreply@your.domain.dom');
}
if( ! defined("DIGEST_SUBJECT") ){
  define('DIGEST_SUBJECT', '[tt-rss] New headlines for last 24 hours');
}
if( ! defined("SMTP_SERVER") ){
  define('SMTP_SERVER', '');
}
if( ! defined("SMTP_LOGIN") ){
  define('SMTP_LOGIN', '');
}
if( ! defined("SMTP_PASSWORD") ){
  define('SMTP_PASSWORD', '');
}
if( ! defined("SMTP_SECURE") ){
  define('SMTP_SECURE', '');
}
if( ! defined("CHECK_FOR_UPDATES") ){
  define('CHECK_FOR_UPDATES', true);
}
if( ! defined("ENABLE_GZIP_OUTPUT") ){
  define('ENABLE_GZIP_OUTPUT', false);
}
if( ! defined("PLUGINS") ){
  define('PLUGINS', 'auth_internal, note');
}
if( ! defined("LOG_DESTINATION") ){
  define('LOG_DESTINATION', 'sql');
}
if( ! defined("CONFIG_VERSION") ){
  define('CONFIG_VERSION', 26);
}

?>