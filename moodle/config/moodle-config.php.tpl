<?php
// Moodle configuration file; values are injected via environment variables.

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype = getenv('MOODLE_DBTYPE') ?: 'pgsql';
$CFG->dblibrary = 'native';
$CFG->dbhost = getenv('MOODLE_DBHOST') ?: '';
$CFG->dbname = getenv('MOODLE_DBNAME') ?: 'moodle';
$CFG->dbuser = getenv('MOODLE_DBUSER') ?: 'moodle';
$CFG->dbpass = getenv('MOODLE_DBPASS') ?: '';
$CFG->prefix = getenv('MOODLE_DBPREFIX') ?: 'mdl_';
$CFG->dboptions = array(
    'dbpersist' => 0,
    'dbport' => getenv('MOODLE_DBPORT') ?: '5432',
    'encoding' => 'utf8',
    'sslmode' => 'require',
);

$CFG->wwwroot = getenv('MOODLE_WWWROOT') ?: 'http://localhost';
$CFG->dataroot = getenv('MOODLE_DATAROOT') ?: '/var/www/moodledata';
$CFG->admin = 'admin';
$CFG->directorypermissions = 02777;

// Optional admin values used for automated installation.
$CFG->adminuser = getenv('MOODLE_ADMIN_USER') ?: '';
$CFG->adminpass = getenv('MOODLE_ADMIN_PASS') ?: '';
$CFG->adminemail = getenv('MOODLE_ADMIN_EMAIL') ?: '';

/**
 * Includes the Moodle setup library file.
 * 
 * This file contains core initialization and configuration setup required
 * for Moodle to function properly. It must be included after all other
 * configuration settings have been defined.
 */
require_once(__DIR__ . '/lib/setup.php');
