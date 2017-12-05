# A simple Spark setup for semi-structured data queries using s3a

This behaves much like AWS EMR and as many of you know much more about Spark than me you can take this much further/

## This uses Scality's Zenko Cloudserver and Spark running in Docker containers


### Get Zenko up and Running

```shell
docker run -d 
````

We start with the Getty Docker image for Apache Sparc on [github](https://github.com/gettyimages/docker-spark/blob/master/Dockerfile)
So we configure it to a non AWS endpoint, and notably a local docker container.

An easily available 2013 Yelp review data set is selected to provide JSON based semi-structured data
It can be found on github in a number of places[here for instance](https://github.com/rekiksab/Yelp)

I chopped the large file up into smaller ones to 
```shell
split -l 20000 yelp_academic_dataset_review.json  yelp-
```

```Spark
val cool = spark.read.json("s3a://test/data/yelp-a[a:e]")
```
Then you can examine the data:
```Spark
cool.show()
cool.printSchema()
```
Now create a view that can be used for SQL queries:
cool.createOrReplaceTempView("coolviews")

Some sample commands 
```Spark
val coolest=spark.sql("SELECT * from coolviews order by votes.cool  desc")
val funniest=spark.sql("SELECT * from coolviews order by votes.funny  desc")
val starred=spark.sql("SELECT * from coolviews order by stars  desc")
coolest.show()
funniest.show()
starred.show()
```

