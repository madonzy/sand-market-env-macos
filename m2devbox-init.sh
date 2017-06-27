#!/bin/bash
touch ./shared/webroot/sync-wait
echo 'Build docker images'
docker-compose up --build -d
web_port=$(docker-compose port web 80)
web_port=${web_port#*:}

echo 'Copy Webroot'
cp -rf ./shared/webroot ./magento2
docker cp magento2 sand_market_box_web:/var/www
rm -rf magento2
rm -rf ./shared/webroot/sync-wait
sleep 5

echo 'Install Magento'

docker-compose exec --user magento2 web m2init magento:install --no-interaction --webserver-home-port=$web_port 