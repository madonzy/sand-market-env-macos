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

if [ "$(ls -A ./shared/sample-data)" ]; then

	echo 'Install Sample Data'
	echo 'Copy Sample Data modules'
	cp -rf ./shared/sample-data ./sample-data
	docker cp sample-data sand_market_box_web:/var/www
	rm -rf sample-data
	rm -rf ./shared/sample-data/sync-wait
	sleep 5

	echo 'Create symlinks For Sample Data modules, set valid permissions and upgrading database'
	docker-compose exec web php -f /home/magento2/magento2-sample-data/dev/tools/build-sample-data.php -- --ce-source="/home/magento2/magento2"
	docker-compose exec web chown -R :magento2 /home/magento2/magento2-sample-data
	docker-compose exec --user magento2 web find /home/magento2/magento2-sample-data -type d -exec chmod g+ws {} \;
	docker-compose exec --user magento2 web rm -rf /home/magento2/magento2-sample-data/cache/* /home/magento2/magento2-sample-data/page_cache/* /home/magento2/magento2-sample-data/generation/*
	docker-compose exec --user magento2 web php /home/magento2/magento2/bin/magento setup:upgrade
    
    echo 'Reindexing (this can take a while)'
    docker-compose exec --user magento2 web php /home/magento2/magento2/bin/magento indexer:reindex
fi
