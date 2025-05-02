<?php
unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = getenv('MOODLE_DB_TYPE'); // Options: pgsql/mariadd/mysql.
$CFG->dblibrary = 'native';
$CFG->dbhost    = getenv('MOODLE_DB_HOST');
$CFG->dbname    = getenv('MOODLE_DB_NAME');
$CFG->dbuser    = getenv('MOODLE_DB_USER');
$CFG->dbpass    = getenv('MOODLE_DB_PASS');
$CFG->prefix    = 'mdl_';
$CFG->dboptions = [
    'dbpersist' => false,
    'dbsocket' => false,
    'dbport' => getenv('MOODLE_DB_PORT') ?: '',
];

$excludessl = filter_var(getenv('MOODLE_EXCLUDE_SSL') ?? false, FILTER_VALIDATE_BOOLEAN);
$CFG->sslproxy = $excludessl ? !$excludessl : true;

$reverseproxy = filter_var(getenv('MOODLE_REVERSE_PROXY') ?? false, FILTER_VALIDATE_BOOLEAN);
$CFG->reverseproxy = $reverseproxy ?: false;

$CFG->wwwroot   = getenv('MOODLE_WWWROOT');
$CFG->dataroot  = '/var/www/html/moodledata';

$CFG->directorypermissions = 02777;

require_once(__DIR__ . '/lib/setup.php');
