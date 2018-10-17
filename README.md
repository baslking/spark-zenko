# A simple Spark setup for semi-structured data queries using s3a with [Zenko](https://www.zenko.io)

This behaves something like AWS EMR/Athena and as many of you know much more about Spark than me you can take this much further and do more interesting things. This is provided as an example to gain understanding of Zenko cloudserver and Spark via Hadoop's s3a interface. 
We will be using  Scality's Zenko Cloudserver and Spark running in Docker containers

### Get Zenko up and Running

If you want to use the Orbit portal, at the time of the writing you needed to use the `pensieve-0` tagged version.  I think today you can drop the pensieve-o tag and just use zenko/cloudserver. 

```shell
	docker run --name zenko -d -p8000:8001 zenko/cloudserver:pensieve-0
```
You can find the instance ID in the file `~/localMetadata/uuid as root` in the Zenko instance
This particular build uses port 8001, so I mapped it to 8000, this can change in the future.

If you are using the Orbit version of Zenko Cloudserver you can create users with  access keys and secret keys via the  portal [webpage](https://admin.zenko.io/), otherwise the standard key pair is found in the file `~/conf/authdata.json ` with the simple key pair `accessKey1 / verySecretKey1` 

Note that you can do the same with Zenko with data stored on a remote cloud, or using the simple `scality/s3server:mem-latest` to run everything in memory.


#### Configure the aws s3 command line to store your data.
```shell
	aws configure --profile <myprofile>
```
and verify that all is well with a command like 
```shell
	aws s3 ls --profile <myprofile> --endpoint-url http://127.0.0.1:8000
```
### Find some data to use

An easily available 2013 Yelp review data set is selected to provide JSON based semi-structured data
It can be found on github in a number of places [here](https://github.com/rekiksab/Yelp) for instance

I chopped the large file up into smaller ones to limit the size. 
```shell
	split -l 20000 yelp_academic_dataset_review.json  yelp-
```
Upload some of the data to an S3 bucket, for instance:
```shell
	aws s3 mb  s3://test   --profile <myprofile> --endpoint-url http://127.0.0.1:8000
	for i in {a..g}; do  aws s3 cp yelp-a$i  s3://test/data/yelp-a$i   --profile <myprofile> --endpoint-url http://127.0.0.1:8000 ; done
 ```
### Getting [Apache Spark](http://spark.apache.org/) up and running and connected

We'll start with the Getty Docker image for Apache Spark on [github](https://github.com/gettyimages/docker-spark/blob/master/Dockerfile)
We need to configure it to a non AWS endpoint, and notably a local docker container. The configuration file, `hadoop.xml`,  that is added to the docker file is where the configuration happens. 

Build the Docker image from *this* directory (with the Dockerfile in it) with a command like:
```shell
	docker build . -t <myvanityname>/spark
```

Run your docker in interactive mode with access and secret keys as environment variables:
```shell
	docker run -it  --net=host --add-host=moby:127.0.0.1   -e "ACCESS_KEY=RIBMS4UWB075LTXTT5AK" -e "SECRET_KEY=oaFpImOKT13UZlMArT56sQm3DR16EFp6MsTi4HEb" -p 4040:4040 <myvanityname>/spark 
```

After starting the container, loading the required libraries and verifying the configuration, you should get a Spark banner and then the `spark-shell` prompt: `scala>`
#### Perform some Spark commands
Read in data from S3 in JSON format:
```Spark
	val cool = spark.read.json("s3a://test/data/yelp-a[a:e]")
```
Then you can examine the data that was read:
```Spark
	cool.show()
	cool.printSchema()
```
Now create a view that can be used for SQL queries:
```Spark
   cool.createOrReplaceTempView("coolviews")
```

Some sample SQL queries 
```Spark
	val coolest=spark.sql("SELECT * from coolviews order by votes.cool  desc")
	val funniest=spark.sql("SELECT * from coolviews order by votes.funny  desc")
	val starred=spark.sql("SELECT * from coolviews order by stars  desc")
	coolest.show()
	funniest.show()
	starred.show()
```

#### You can also do non-SQL commands with data that is not structured.  

For instance, we can read in one of these files as text, do a word count on all words in the file and write the result out to your bucket like this:
```Spark
	var blabla = sc.textFile("s3a://test/data/yelp-aa")
	val counts = blabla.flatMap(line => line.split(" ")).map(word => (word, 1)).reduceByKey(_ + _)
	counts.saveAsTextFile("s3a://test/output")
```
Which outputs files with counts of all unique "words" that were discovered
```Shell
	aws s3 ls  s3://test/output  --recursive   --profile <myprofile> --endpoint-url http://127.0.0.1:8000
		2017-12-06 14:55:33          0 output/_SUCCESS
		2017-12-06 14:55:32    1618973 output/part-00000
		2017-12-06 14:55:33    1606378 output/part-00001
```
---
Enjoy
 
