### build  spark
* cd spark3.2/spark
* docker build -t duplocloud/anyservice:spark_3_2_v1 .
### push
* docker login
* docker push duplocloud/anyservice:spark_3_2_v1

### build  spark notebook
* cd spark3.2/notebook
* docker build -t duplocloud/anyservice:spark_3_2_notebook_v1 .
### push
* docker login
* docker push duplocloud/anyservice:spark_3_2_notebook_v1


### run master
* docker run -itd -p8888:8888 -p8080:8080 -p7077:7077 -p6066:6066 -v ~/code:/home/ubuntu/work  -e DUPLO_SPARK_MASTER_IP 0.0.0.0 -e DUPLO_SPARK_NODE_TYPE master duplocloud/anyservice:spark_3_2_v1
### run slave
*  docker run -itd -p8888:8888 -p8080:8080   -p6066:6066  -e DUPLO_SPARK_MASTER_IP 0.0.0.0 -e DUPLO_SPARK_NODE_TYPE worker duplocloud/anyservice:spark_3_2_v1
### run notebook
*  docker run -itd -p8888:8888 -p8080:8080 -p7077:7077  -p6066:6066  -e DUPLO_SPARK_MASTER_IP 0.0.0.0 -e duplocloud/anyservice:spark_3_2_notebook_v1



### duplo-ui: env master (optional -- has default to match below )
```json
{ 
  "DUPLO_SPARK_NODE_TYPE": "master"
}

```

###  duplo-ui: env slave

```json
{
  "DUPLO_SPARK_MASTER_IP": "copy_master_ip_here",
  "DUPLO_SPARK_NODE_TYPE": "worker"
}

```


###  duplo-ui: env notebook

```json
{
  "DUPLO_SPARK_MASTER_IP": "copy_master_ip_here" 
}

```