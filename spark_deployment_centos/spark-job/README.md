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


```

docker run -itd 
-e duplo_token="replace token" \
-e duplo_host="https://xxx.duplocloud.net" \
-e AWS_RUNNER=duplo-admin \
-e AWS_REGION=us-west-2 \
-e AWS_ACCOUNT_ID=xxxx \
duplocloud/anyservice:spark_3_2_centos_job_v1
 

 [
      { Name : "duplo_token", Value : "xxxxx" },
      { Name : "duplo_host", Value : "https://xxx.duplocloud.net" },
      { Name : "AWS_RUNNER", Value : "duplo-admin" },
      { Name : "AWS_REGION", Value : "us-west-2" },
      { Name : "AWS_ACCOUNT_ID", Value : "xxx" },
    ]
```