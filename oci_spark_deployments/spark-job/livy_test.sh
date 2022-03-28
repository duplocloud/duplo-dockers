
export SPARK_MASTER_IP=`cat ./build/eks-sparkmaster-ip`
export livy_ip=`cat ./build/eks-sparklivy-ip`

export livy_ip=10.0.10.28


curl -X POST -d
'{"conf": {"kind": "spark"
,"className": "com.company.scala.ScyllaSpanByTest" ,
"jars":
"hdfs://hdfsserver:8020/user/spark/jars/Test-assembly-0.1.jar"
}}' -H "Content-Type: application/json" -H "X-Requested-By:
user" http://${livy_ip}:8999/sessions


# Vishak Nambiar
curl --location --request POST 'http://${livy_ip}:8998/sessions' \
--header 'X-Requested-By: user' \
--header 'Content-Type: application/json' \
--data-raw '{"kind":"pyspark", "name":"preprocess1"}'


curl --location --request POST 'http://${livy_ip}:8998/sessions/{session id from the previous requests response}/statements' \
--header 'X-Requested-By: admin' \
--header 'Content-Type: application/json' \
--data-raw '{
"kind": "pyspark",
"code": "from pyspark.sql import SparkSession \nimpornt os \nos.environ.set('\''SPARK_MASTER_IP'\'') \nenvmasterip=os.environ.get('\''SPARK_MASTER_IP'\'') \nsprk_url='\''spark://{}/:7077'\''.format(envmasterip) \nprint(sprk_url) \nlogFile = '\''test.py'\''  # Should be some file on \nyour system \nspark = SparkSession.builder.appName('\''SimpleApp'\'').getOrCreate() \nlogData = spark.read.text(logFile).cache() \numAs = logData.filter(logData.value.contains('\''a'\'')).count() \nnumBs = logData.filter(logData.value.contains('\''b'\'')).count() \nprint('\''Lines with a: %i, lines with b: %i'\'' % (numAs, numBs)) \nspark.stop() \n"
}'

