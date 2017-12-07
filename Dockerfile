FROM gettyimages/spark
MAINTAINER Brad King <brad.king@scality.com>


COPY hadoop-site.xml /hadoop-site.xml
# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh

# Run entrypoint script and start in foreground
ENTRYPOINT ["/entrypoint.sh", "bin/spark-shell"]

