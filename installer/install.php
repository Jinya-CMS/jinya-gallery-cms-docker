<?php
require_once __DIR__ . '/vendor/autoload.php';

use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Yaml\Yaml;

echo 'Start install' . PHP_EOL;
$containerVersion = getenv('VERSION');

echo 'Parse jinya config' . PHP_EOL;
if (file_exists('/var/www/html/config/packages/jinya.yaml')) {
    $jinyaConfig = Yaml::parseFile('/var/www/html/config/packages/jinya.yaml');
    $installedVersion = $jinyaConfig['parameters']['jinya_version'];
    $firstRun = false;
} else {
    $installedVersion = '0.0.0';
    $firstRun = true;
}

echo "Container version $containerVersion" . PHP_EOL;
echo "Installed version $installedVersion" . PHP_EOL;

if (version_compare($containerVersion, $installedVersion)) {
    echo 'Container is a newer version, than the installed one' . PHP_EOL;
    echo 'Download new version to update' . PHP_EOL;
    $file = fopen('/var/www/jinya.zip', 'wb');
    $curl = curl_init("https://files.jinya.de/cms/stable/$containerVersion.zip");
    curl_setopt($curl, CURLOPT_FILE, $file);

    $data = curl_exec($curl);
    curl_close($curl);
    fclose($file);

    echo 'Extract zip file' . PHP_EOL;
    $zip = new ZipArchive();
    if ($zip->open('/var/www/jinya.zip') === true) {
        $zip->extractTo('/var/www/html/');
        $zip->close();
        echo 'Extracted zip file' . PHP_EOL;
        $fs = new Filesystem();

        echo 'Copy htaccess to directories' . PHP_EOL;
        $fs->copy('/.htaccess', '/var/www/html/public/.htaccess', true);

        echo 'Create .env' . PHP_EOL;
        $fs->dumpFile('/var/www/html/.env', 'APP_ENV=prod');

        echo 'Change permissions' . PHP_EOL;
        $fs->chown('/var/www/html', 'www-data', true);
        $fs->chgrp('/var/www/html', 'www-data', true);

        echo 'Execute database migration' . PHP_EOL;
        if ($firstRun) {
            system('/usr/bin/php /var/www/html/bin/console jinya:first-run:create-db');
        } else {
            system('/usr/bin/php /var/www/html/bin/console doctrine:migrations:migrate');
        }
    }
}