### build  spark
* cd spark3.2/spark-livy
* docker build -t duplocloud/anyservice:spark_3_2_livy_v4 .
* docker build -f Dockerfile.centos -t duplocloud/anyservice:spark_3_2_centos_livy_v4 .
* docker build -f Dockerfile.ubuntu -t duplocloud/anyservice:spark_3_2_ubuntu_livy_v4 .
### push
* docker login
* docker push duplocloud/anyservice:spark_3_2_livy_v4
* docker push duplocloud/anyservice:spark_3_2_centos_livy_v4
* docker push duplocloud/anyservice:spark_3_2_ubuntu_livy_v4
  