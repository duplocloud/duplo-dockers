#!/bin/bash -ex

master=$DUPLO_DOCKER_HOST
if [[ "x$SPARK_MASTER_IP" != "x" ]]; then
    master=$SPARK_MASTER_IP
    echo "todo master into spark-defaults.conf"
fi

echo "master ${master}"
if [[ "x$master" != "x" ]]; then
  export spark_master=${master}
  echo "spark.master spark://${master}:7077" >> /usr/local/spark-2.4.1-bin-without-hadoop/conf/spark-defaults.conf
fi
export spark_master=${master}
echo "spark.master spark://${master}:7077" >> /usr/local/spark-2.4.1-bin-without-hadoop/conf/spark-defaults.conf


############################## enable password ########################
# src: https://jupyter-notebook.readthedocs.io/en/stable/public_server.html
#c.NotebookApp.certfile = u'/absolute/path/to/your/certificate/mycert.pem'
#c.NotebookApp.keyfile = u'/absolute/path/to/your/certificate/mykey.key'
#c.NotebookApp.ip = '*'"
#c.NotebookApp.password = u'sha1:bcd259ccf...<your hashed password here>'
#c.NotebookApp.open_browser = False

#password generation in python
#from notebook.auth import passwd
#passwd() # enter -- Apatics123
#Enter password: ········
#Verify password: ·······
#'sha1:2f91c8295fe2:6ced4ef3d1041a1a669a9e18db5cb2772e870e9b'

echo "c.NotebookApp.ip = '*'" >> /home/jovyan/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.password = u'sha1:2f91c8295fe2:6ced4ef3d1041a1a669a9e18db5cb2772e870e9b'" >> /home/jovyan/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.open_browser = False" >> /home/jovyan/.jupyter/jupyter_notebook_config.py
############################## enable password ########################

echo "setup jupyter_notebook_config.py"

cd work
jupyter notebook
