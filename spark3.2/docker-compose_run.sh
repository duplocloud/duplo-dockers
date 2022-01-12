
echo "curret path `pwd`"
mkdir -p code
mkdir -p logs/master
mkdir -p logs/worker1
mkdir -p logs/notebook

docker-compose up -d
echo "===to end ==="
echi "docker-compose  down"
docker-compose logs

# docker-compose  down


