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

### docker-compose 
```shell
cd /Users/brighu/_duplo_code/duplo-dockers/spark3.2
docker-compose_run.sh
```




````text

/Users/brighu/_duplo_code/duplo-dockers/spark3.2/code or relative path  by cd /Users/brighu/_duplo_code/duplo-dockers/spark3.2/code
docker run -itd -p8888:8888 -p8080:8080 -p7077:7077 -p6066:6066 -v code:/home/ubuntu/work  -e DUPLO_SPARK_MASTER_IP 0.0.0.0 -e DUPLO_SPARK_NODE_TYPE master duplocloud/anyservice:spark_3_2_v1


(base) brighu:spark3.2 brighu$ docker ps 
>>>>
CONTAINER ID   IMAGE                                COMMAND                  CREATED              STATUS              PORTS                                                                                                                                                                        NAMES
d49d8c0b7ff7   duplocloud/anyservice:spark_3_2_v1   "/usr/local/bin/tini…"   About a minute ago   Up About a minute   0.0.0.0:6066->6066/tcp, :::6066->6066/tcp, 0.0.0.0:7077->7077/tcp, :::7077->7077/tcp, 0.0.0.0:8080->8080/tcp, :::8080->8080/tcp, 0.0.0.0:8888->8888/tcp, :::8888->8888/tcp   elated_chaplygin

============
(base) brighu:spark3.2 brighu$ docker logs d49d8c0b7ff7
>>>>
totalk=2034968K 80% max_mem=1627974K 40% min_mem=813987K
SPARK_OPTS  before 
spark_master_ip = 0.0.0.0 xms = 813987K xms = 1627974K --driver-java-options=-Xms813987K --driver-java-options=-Xmx1627974K --driver-java-options=-Dlog4j.logLevel=info
SPARK_OPTS --driver-java-options=-Xms813987K --driver-java-options=-Xmx1627974K --driver-java-options=-Dlog4j.logLevel=info after 
Using Spark's default log4j profile: org/apache/spark/log4j-defaults.properties
...
...
22/01/12 19:30:16 INFO Master: Starting Spark master at spark://0.0.0.0:7077
22/01/12 19:30:16 INFO Master: Running Spark version 3.2.0
22/01/12 19:30:16 INFO Utils: Successfully started service 'MasterUI' on port 8080.
22/01/12 19:30:17 INFO MasterWebUI: Bound MasterWebUI to 0.0.0.0, and started at http://d49d8c0b7ff7:8080
22/01/12 19:30:17 INFO Master: I have been elected leader! New state: ALIVE
 

=======
(base) brighu:spark3.2 brighu$ docker exec -it d49d8c0b7ff7 bash
>>>>>>
ubuntu@d49d8c0b7ff7:~$ netstat -an 
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State      
tcp        0      0 0.0.0.0:7077            0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:8080            0.0.0.0:*               LISTEN     
Active UNIX domain sockets (servers and established)
Proto RefCnt Flags       Type       State         I-Node   Path
unix  2      [ ]         STREAM     CONNECTED     364486   
ubuntu@d49d8c0b7ff7:~$ 

```` 
### run master
* docker run -itd -p8080:8080 -p7077:7077 -p6066:6066 -v code:/home/ubuntu/work  -e DUPLO_SPARK_MASTER_IP=0.0.0.0 -e DUPLO_SPARK_NODE_TYPE=master duplocloud/anyservice:spark_3_2_v3

* ## run slave
* docker run -itd   -v code:/home/ubuntu/work  -e DUPLO_SPARK_MASTER_IP=0.0.0.0 -e DUPLO_SPARK_NODE_TYPE=worker duplocloud/anyservice:spark_3_2_v3

* docker run -itd   -p6066:6066  -e DUPLO_SPARK_MASTER_IP=0.0.0.0 -e DUPLO_SPARK_NODE_TYPE=worker duplocloud/anyservice:spark_3_2_v3
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