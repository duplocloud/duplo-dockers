### build 
* cd spark3.2/spark
* docker build -t duplocloud/anyservice:spark_3_2_v1 .
### run
* docker run -itd -p8888:8888 -p8080:8080 -p7077:7077 -p6066:6066 duplocloud/anyservice:spark_3_2_v1
### push
* docker login
* docker push duplocloud/anyservice:spark_3_2_v1