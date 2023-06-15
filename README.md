# Поднимаем контейнеры: 

docker build -t hadoop-base docker/hadoop/hadoop-base && docker build -t hive-base docker/hive/hive-base && docker build -t spark-base docker/spark/spark-base && docker-compose up -d --build 

# После запуска:
Подождите около 2-3 минут, пока все контейнеры найдут друг друга, и в файле: 
.\mini_cluster_datalake\mnt\hadoop\namenode\start-namenode.sh 
закомментируйте следующие строки: 
 <img width="518" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/200e63db-5d18-4117-8198-6404489bfeb7">

Сохраните файл, и перезапустите контейнер namenode.
