### build  spark
* cd sparkjpb
* docker build -t duplocloud/anyservice:spark_job_3_2_v1 .
### push
* docker login
* docker push duplocloud/anyservice:spark_job_3_2_v1


```
cd base

cd ../base
docker build -t duplocloud/anyservice:spark_3_2_centos_base_v1 . 

cd ../spark; 
docker build -t duplocloud/anyservice:spark_3_2_centos_v1 .   
 
cd ../spark-notebook
docker build -t duplocloud/anyservice:spark_3_2_centos_notebook_v1 . 


cd ../spark-livy
docker build -t duplocloud/anyservice:spark_3_2_centos_livy_v1 . 


cd ../spark-job
docker build -t duplocloud/anyservice:spark_3_2_centos_job_v1 . 



docker push duplocloud/anyservice:spark_3_2_centos_base_v1   
docker push duplocloud/anyservice:spark_3_2_centos_v1   
docker push duplocloud/anyservice:spark_3_2_centos_notebook_v1   
docker push duplocloud/anyservice:spark_3_2_centos_livy_v1   
docker push duplocloud/anyservice:spark_3_2_centos_job_v1  


docker build -t duplocloud/anyservice:spark_3_2_centos_e_job_v1 . 
docker push duplocloud/anyservice:spark_3_2_centos_e_job_v1  



```
 
```
cd base

cd ../base
docker build -t duplocloud/anyservice:spark_3_2_centos_base_v1 .
docker push duplocloud/anyservice:spark_3_2_centos_base_v1  

cd ../spark
docker build -t duplocloud/anyservice:spark_3_2_centos_v1 .
docker push duplocloud/anyservice:spark_3_2_centos_v1  


cd ../spark-notebook
docker build -t duplocloud/anyservice:spark_3_2_centos_notebook_v1 .
docker push duplocloud/anyservice:spark_3_2_centos_notebook_v1  


cd ../spark-livy
docker build -t duplocloud/anyservice:spark_3_2_centos_livy_v1 .
docker push duplocloud/anyservice:spark_3_2_centos_livy_v1  


cd ../spark-job
docker build -t duplocloud/anyservice:spark_3_2_centos_job_v1 .
docker push duplocloud/anyservice:spark_3_2_centos_job_v1  


```
###  duplo-ui 

```json
{
  "DUPLO_SPARK_MASTER_IP": "copy_master_ip_here",
 

}

```