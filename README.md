# Мини datalake-cluster
Данный spark-compose поможет создать мини datalake-cluster, в котором мы можем запустить даг airflow.  
В демонстрационном даге находится SparkSubmitOperator, запускающий spark-job, который читает таблицу из бд postgres, и сохраняет её в hive-таблицу. 

# Запуск примера
Скачиваем проект и разархивируем его в удобную вам папку. 
У меня, этой папкой будет:

**C:\Users\danel\Downloads\mini_cluster_datalake-master**

В командной строке от имени администратора устанавливаем папку с образами как текущую: 
`cd C:\Users\danel\Downloads\mini_cluster_datalake-master\mini_cluster_datalake`

Строим и поднимаем контейнеры:

`docker build -t hadoop-base docker/hadoop/hadoop-base && docker build -t hive-base docker/hive/hive-base && docker build -t spark-base docker/spark/spark-base && docker-compose up -d --build` 

<img width="448" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/4039950a-cb69-4525-bcbd-b3fa6d590709">

Подождите около 2-3 минут, пока все контейнеры найдут друг друга, и в файле: 

`C:\Users\danel\Downloads\mini_cluster_datalake-master\mini_cluster_datalake\mnt\hadoop\namenode\start-namenode.sh`

закомментируйте следующие строки:

<img width="517" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/079e70c7-d7c3-4de5-af3c-efe93d34b85e">

Сохраните файл, и перезапустите контейнер namenode

<img width="80%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/b0ae5ffb-aca1-428e-8e7e-7a3c2411636d">

## Подготовим источник
Переходим к [ui pgadmin](http://localhost:5050/login?next=%2F):

И указываем логин:
`admin@admin.com`

и пароль: 
`root`

<img width="80%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/223b67df-13b7-4fb1-9047-69c93241fa0a">

Нам необходимо импортировать бд. Создаём подключение:

<img width="70%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/6761f0e3-b3c3-4d87-954d-f5e3997ca0a4">
<img width="70%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/7e0661ae-180b-4ccf-9403-412f72e54f14">

Имя/адрес сервера: `postgres`

Порт: `5432` 

Служебная база данных: `postgres`

Имя пользователя: `airflow` 

Пароль: `airflow`

Создаём базу данных с названием **spotify**:

<img width="100%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/f5486b49-b5c0-4227-8176-ce9fe7fc2d12">

Создаём таблицу charts, и производим import готовой. 
Переходим к запроснику:

<img width="30%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/c97add83-c58d-40e9-a0c9-21b8b3141612">


И запускаем запрос создания таблицы: 

```CREATE TABLE IF NOT EXISTS public.charts  
(  

    id bigint,  

    country text COLLATE pg_catalog."default",  

    date timestamp without time zone,  

    "position" bigint,  

    uri text COLLATE pg_catalog."default",  

    track text COLLATE pg_catalog."default",  

    title text COLLATE pg_catalog."default",  

    artist text COLLATE pg_catalog."default"  

)
```
<img width="70%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/de62f85d-4e2d-457b-84aa-20f5c23d0748">

Нажмите правой кнопкой на пункт Таблицы, затем Обновить, чтобы наша таблица появилась.
Выполняем import таблицы (файл spotify в корне проекта).

<img width="30%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/1fbbc25f-2141-4b8f-81ac-59082a6f1f9b">

<img width="50%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/904492ec-cc9f-4287-8b9a-d66ae357deee">

<img width="50%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/e1867a93-6dd8-4816-ab30-fcd8ec62af30">


Мы только что загрузили файл в Storage Manager. Теперь выберем его для import’а. Формат выбираем binary:

<img width="50%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/a60a2750-1a34-4bc6-b549-10780021654a">

Нажимаем OK. Дожидаемся копирования: 

<img width="50%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/38a8df02-928b-4435-9df8-d03819176dd0">

И выполним запрос в запроснике, чтобы убедиться, что данные появились:
<img width="50%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/5d3f6bdb-bc88-4176-bda9-91981e746b86">


Источник готов. 

## Теперь настроим airflow.

Переходим в [ui](http://localhost:8080/):  
Указываем логин: `admin@airflow.com`
И пароль: `airflow`

Нас сразу будет ожидать демонстрационный даг **charts_load**:

<img width="80%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/13ae19c6-3353-490b-a954-b3fe38d60cae">

Но осталось сконфигурировать connection spark_default для SparkSubmitOperator’а. 

Переходим к Admin -> Connections: 

<img width="50%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/d4c0b197-78a8-4d60-9e0d-cb98d339c77f">

Находим **spark_default** и устанавливаем: 

host: `spark://spark-master`

port: `7077`

<img width="30%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/9e1ecc36-c41f-4ef3-8dde-5aec50931aaf">

Сохраняем (Save) и теперь можем запустить даг charts_load

<img width="80%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/c926258e-0325-44a1-acbf-5c0012149c2f">

## Работа с Hue

После завершения работы дага, можем проверить, что данные из источника, сохранились в hive. 

Переходим в [hue](http://localhost:32762), вводим логин: `hue` и пароль: `Hue` и нажимаем на Create Account 

<img width="30%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/e4f1e417-b782-4d5f-93aa-a58fc46fdfc7">

Выполняем запрос `SELECT * FROM test_repl_spotify.charts limit 3;` в hive:

<img width="60%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/33858f82-2459-489c-9d80-a265273c3fbc">

<img width="60%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/4caf1f8f-cb89-4ca4-9704-30ff0445b67d">

Посмотрим .parquet файлы таблицы, через File Browser в hue:

`http://localhost:32762/hue/filebrowser/view=/user/hive/warehouse/test_repl_spotify.db#/user/hive/warehouse/test_repl_spotify.db/charts`

<img width="60%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/57627856-2e2a-4ad0-82b6-77fd4734dc25">

После работы, можно завершить все контейнеры:

<img width="100%" alt="image" src="https://github.com/Danstnou/mini_cluster_datalake/assets/36561095/d46407e1-6891-453c-81dd-a89eab34e0ae">

И таким же образом можно запустить. 

