from pyspark.sql import SparkSession
import os
# os.environ.set('SPARK_MASTER_IP')
envmasterip=os.environ.get('SPARK_MASTER_IP')
sprk_url="spark://{}/:7077".format(envmasterip)
print(sprk_url)

logFile = "test.py"  # Should be some file on your system
# spark = SparkSession.builder\
#     .appName("SimpleApp")\
#     .master(sprk_url)\
#     .getOrCreate()
spark = SparkSession.builder\
    .appName("SimpleApp")\
    .getOrCreate()

logData = spark.read.text(logFile).cache()

numAs = logData.filter(logData.value.contains('a')).count()
numBs = logData.filter(logData.value.contains('b')).count()

print("Lines with a: %i, lines with b: %i" % (numAs, numBs))

spark.stop()