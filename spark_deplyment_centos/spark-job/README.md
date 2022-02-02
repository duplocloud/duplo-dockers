### build  spark-job
* cd spark-job
* docker build -t duplocloud/anyservice:spark_3_2_centos_job_v1 .
### push
* docker login
* docker push duplocloud/anyservice:spark_3_2_centos_job_v1
 

###  duplo-ui: env  

```json
{
  "DUPLO_SPARK_MASTER_IP": "copy_master_ip_here" 
}

```