#!/bin/bash

set -e
cp  /hadoop-site.xml $HADOOP_CONF_DIR/core-site.xml 
# This only sets correctly for localhost, if it's a non-loopback this isn't needed, but it might cause problems...
echo SPARK_LOCAL_IP=127.0.0.1 > $SPARK_HOME/conf/spark-env.sh

if [[ "$ACCESS_KEY" && "$SECRET_KEY" ]]; then
    sed -i "s/ACCESS/$ACCESS_KEY/" $HADOOP_CONF_DIR/core-site.xml
    sed -i "s/SECRET/$SECRET_KEY/" $HADOOP_CONF_DIR/core-site.xml
    echo "Access key and secret key have been modified successfully"
fi

if [[ "$S3_ENDPOINT" ]]; then
    sed -i "s/http:\/\/127\.0\.0\.1:8000/$S3_ENDPOINT/" $HADOOP_CONF_DIR/core-site.xml
    echo "S3 Endpoint has been modified to $S3_ENDPOINT"
fi

exec "$@"
