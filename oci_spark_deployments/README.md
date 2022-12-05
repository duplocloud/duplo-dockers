##   refactoring scripts
``` 
cd /home/pravin/flex-e4-pravin/
cd  ./flex_ashburn_spark_dep


ls ../
duplo_env.sh  flex_ashburn_spark_dep  tf_build_dockers.sh.log  tf_create.sh.log  tf_destory.sh.log  version_dockers.log  versions.log
cat ../duplo_env.sh 

sudo ./tf_build_dockers.sh 1 1 deljob1 v35 
sudo ./tf_destory.sh 1 1 deljob1 v35

sudo ./tf_create.sh 1 1 deljob1 v35 
sudo ./tf_destory.sh 1 1 deljob1 v35
```


### build  spark
* cd sparkjpb
* docker build -t duplocloud/anyservice:spark_job_3_2_v1 .
### push
* docker login
* docker push duplocloud/anyservice:spark_job_3_2_v1


```
cd base

cd ../base
docker build -t duplocloud/anyservice:spark_3_2_ia_base_v1 . 

cd ../spark; 
docker build -t duplocloud/anyservice:spark_3_2_ia_v1 .   
 
cd ../spark-notebook
docker build -t duplocloud/anyservice:spark_3_2_ia_notebook_v1 . 


cd ../spark-livy
docker build -t duplocloud/anyservice:spark_3_2_ia_livy_v1 . 


cd ../spark-job
docker build -t duplocloud/anyservice:spark_3_2_ia_job_v1 . 



docker push duplocloud/anyservice:spark_3_2_ia_base_v1   
docker push duplocloud/anyservice:spark_3_2_ia_v1   
docker push duplocloud/anyservice:spark_3_2_ia_notebook_v1   
docker push duplocloud/anyservice:spark_3_2_ia_livy_v1   
docker push duplocloud/anyservice:spark_3_2_ia_job_v1  

```
 
```
cd base

cd ../base
docker build -t duplocloud/anyservice:spark_3_2_ia_base_v1 .
docker push duplocloud/anyservice:spark_3_2_ia_base_v1  

cd ../spark
docker build -t duplocloud/anyservice:spark_3_2_ia_v1 .
docker push duplocloud/anyservice:spark_3_2_ia_v1  


cd ../spark-notebook
docker build -t duplocloud/anyservice:spark_3_2_ia_notebook_v1 .
docker push duplocloud/anyservice:spark_3_2_ia_notebook_v1  


cd ../spark-livy
docker build -t duplocloud/anyservice:spark_3_2_ia_livy_v1 .
docker push duplocloud/anyservice:spark_3_2_ia_livy_v1  


cd ../spark-job
docker build -t duplocloud/anyservice:spark_3_2_ia_job_v1 .
docker push duplocloud/anyservice:spark_3_2_ia_job_v1  


```
###  duplo-ui 

```json
{
  "DUPLO_SPARK_MASTER_IP": "copy_master_ip_here",
 

}

```