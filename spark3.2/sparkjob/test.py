from pyspark.sql import SparkSession
envmasterip="10.221.1.95"
logFile = "/home/ubuntu/JOB.md"  # Should be some file on your system
spark = SparkSession.builder\
    .appName("SimpleApp")\
    .master("spark:/"+envmasterip+"/:7077")\
    .getOrCreate()

logData = spark.read.text(logFile).cache()

numAs = logData.filter(logData.value.contains('a')).count()
numBs = logData.filter(logData.value.contains('b')).count()

print("Lines with a: %i, lines with b: %i" % (numAs, numBs))

spark.stop()