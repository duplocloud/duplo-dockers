

```

root@7ed5fe2f2e04:/home# kubectl get pod job1-sparkmaster-846d456fc-zn8t9                                                                                                        
NAME                               READY   STATUS    RESTARTS   AGE                                                                                                              
job1-sparkmaster-846d456fc-zn8t9   1/1     Running   0          29m                                                                                                              
root@7ed5fe2f2e04:/home# kubectl describe pod job1-sparkmaster-846d456fc-zn8t9                                                                                                   
Name:               job1-sparkmaster-846d456fc-zn8t9                                                                                                                             
Namespace:          duploservices-sparkdemo                                                                                                                                      
Priority:           0                                                                                                                                                            
PriorityClassName:  <none>                                                                                                                                                       
Node:               ip-10-221-1-78.us-west-2.compute.internal/10.221.1.78                                                                                                        
Start Time:         Fri, 28 Jan 2022 03:35:02 +0000                                                                                                                              
Labels:             app=job1-sparkmaster                                                                                                                                         
                    owner=duploservices                                                                                                                                          
                    pod-template-hash=846d456fc                                                                                                                                  
                    tenantid=ffc39ee6-5a3c-46c0-adc4-87826065e42f                                                                                                                
                    tenantname=duploservices-sparkdemo                                                                                                                           
Annotations:        duplocloud.net/managed-annotations:                                                                                                                          
                    duplocloud.net/managed-labels:                                                                                                                               
                    kubernetes.io/psp: eks.privileged                                                                                                                            
Status:             Running                                                                                                                                                      
IP:                 10.221.1.78                                                                                                                                                  
Controlled By:      ReplicaSet/job1-sparkmaster-846d456fc                                                                                                                        
Containers:                                                                                                                                                                      
  job1-sparkmaster:                                                                                                                                                              
    Container ID:   docker://80e4057d059c5e84578b925a7b027f9d1b2d18c52740a79cd21e4fdcd2ab9388                                                                                    
    Image:          duplocloud/anyservice:spark_3_2_v6                                                                                                                           
    Image ID:       docker-pullable://duplocloud/anyservice@sha256:9eba33f610633038d119c0523df1c8a9661fcb0c55361c5d98e9c7a9efe8d8b5                                              
    Port:           <none>                                                                                                                                                       
    Host Port:      <none>                                                                                                                                                       
    State:          Running                                                                                                                                                      
      Started:      Fri, 28 Jan 2022 03:35:50 +0000                                                                                                                              
    Ready:          True                                                                                                                                                         
    Restart Count:  0                                                                                                                                                            
    Environment:                                                                                                                                                                 
      DUPLO_SPARK_MASTER_IP:  0.0.0.0                                                                                                                                            
      DUPLO_SPARK_NODE_TYPE:  master                                                                                                                                             
      DOCKER_IMAGE:           duplocloud/anyservice:spark_3_2_v6                                                                                                                 
    Mounts:                                                                                                                                                                      
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-hpb75 (ro)                                                                                                
Conditions:                                                                                                                                                                      
  Type              Status                                                                                                                                                       
  Initialized       True                                                                                                                                                         
  Ready             True                                                                                                                                                         
  ContainersReady   True                                                                                                                                                         
  PodScheduled      True                                                                                                                                                         
Volumes:                                                                                                                                                                         
  default-token-hpb75:                                                                                                                                                           
    Type:        Secret (a volume populated by a Secret)                                                                                                                         
    SecretName:  default-token-hpb75                                                                                                                                             
    Optional:    false                                                                                                                                                           
QoS Class:       BestEffort                                                                                                                                                      
Node-Selectors:  allocationtags=job1-sparkmaster                                                                                                                                 
                 tenantname=duploservices-sparkdemo                                                                                                                              
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s                                                                                                                 
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:                                                                                                                                                                          
  Type    Reason     Age   From                                                Message                                                                                           
  ----    ------     ----  ----                                                -------                                                                                           
  Normal  Scheduled  29m   default-scheduler                                   Successfully assigned duploservices-sparkdemo/job1-sparkmaster-846d456fc-zn8t9 to ip-10-221-1-78.u
s-west-2.compute.internal                                                                                                                                                        
  Normal  Pulling    29m   kubelet, ip-10-221-1-78.us-west-2.compute.internal  Pulling image "duplocloud/anyservice:spark_3_2_v6"                                                
  Normal  Pulled     29m   kubelet, ip-10-221-1-78.us-west-2.compute.internal  Successfully pulled image "duplocloud/anyservice:spark_3_2_v6"                                    
  Normal  Created    29m   kubelet, ip-10-221-1-78.us-west-2.compute.internal  Created container job1-sparkmaster                                                                
  Normal  Started    29m   kubelet, ip-10-221-1-78.us-west-2.compute.internal  Started container job1-sparkmaster                                                                
```