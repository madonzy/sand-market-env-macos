#!/bin/bash

if [ "$(ls -A ./shared/sample-data)" ]; then

	echo 'Install Sample Data'
	echo 'Copy Sample Data modules'
	touch ./shared/sample-data/sync-wait
	cp -rf ./shared/sample-data ./sample-data
	docker cp sample-data sand_market_box_web:/var/www
	rm -rf sample-data
	rm -rf ./shared/sample-data/sync-wait
	sleep 5

	echo 'Create symlinks For Sample Data modules, set valid permissions'
	docker-compose exec web php -f /home/magento2/magento2-sample-data/dev/tools/build-sample-data.php -- --ce-source="/home/magento2/magento2"
	docker-compose exec web chown -R :magento2 /home/magento2/magento2-sample-data
	docker-compose exec --user magento2 web find /home/magento2/magento2-sample-data -type d -exec chmod g+ws {} \;
	docker-compose exec --user magento2 web rm -rf /home/magento2/magento2/cache/* /home/magento2/magento2/page_cache/* /home/magento2/magento2/generation/*
	sleep 5
    
    echo 'Reindexing and upgrading database (this can take a while)'
    docker-compose exec --user magento2 web php /home/magento2/magento2/bin/magento setup:upgrade
    docker-compose exec --user magento2 web rm -rf magento2/var
    docker-compose exec --user magento2 web php /home/magento2/magento2/bin/magento indexer:reindex

    echo 'Sample Data was install successfully!'

fi