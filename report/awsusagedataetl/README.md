
# install 

## install prerequisite  
* tested with python 10 

## install requirements  
* install requirments and generate reports.
```bash
pip install -r requirments.txt
python aws-billing-reports.py
```


## Generated CSV reports 

 ```
 aws --region us-west-2 ecr get-login-password | docker login --username AWS --password-stdin xxx.dkr.ecr.us-west-2.amazonaws.com

ver=usagedataetl:v25
docker build -t $ver .
docker tag  $ver   xxx.dkr.ecr.us-west-2.amazonaws.com/$ver
docker push xxx.dkr.ecr.us-west-2.amazonaws.com/$ver
echo xxx.dkr.ecr.us-west-2.amazonaws.com/$ver

 ```

## Genergate cumulative csv reports
* lambda
* cloudwatch rule with every 5 hours execution
* 