#!/usr/bin/env bash
vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

currentVersion=$(grep -A3 'parameters:' /var/www/jinya/config/packages/jinya.yaml | tail -n1); currentVersion=${currentVersion//*jinya_version: /};

if [[ currentVersion < VERSION ]]; then
	curl -fsSL -o /var/www/jinya.zip "https://files.jinya.de/cms/stable/$(VERSION).zip"
	unzip -o /var/www/jinya.zip -d /var/www/html
	cp /.htaccess /var/www/html/public/.htaccess
	chown -R www-data:www-data /var/www/html
	echo "APP_ENV=prod">/var/www/html/.env
	php /var/www/html/bin/console jinya:first-run:create-db
fi

exec "$@"