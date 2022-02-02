from pyspark.sql import SparkSession
import os

envmasterip= os.environ.get('SPARK_MASTER_IP')
sprk_url= "spark:/{0}/:7077".format(envmasterip)
print(sprk_url)

logFile = "test.py"  # Should be some file on your system
spark = SparkSession.builder\
    .appName("SimpleApp")\
    .master(sprk_url)\
    .getOrCreate()

logData = spark.read.text(logFile).cache()

numAs = logData.filter(logData.value.contains('a')).count()
numBs = logData.filter(logData.value.contains('b')).count()

print("Lines with a: %i, lines with b: %i" % (numAs, numBs))

spark.stop()