#!/usr/bin/env bash
set -e

/data/walle-web/yii walle/setup --interactive=0
php-fpm
exec $@
