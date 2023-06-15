from airflow import DAG
from airflow.contrib.operators.spark_submit_operator import SparkSubmitOperator
from airflow.utils.dates import days_ago

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': days_ago(1),
    'retries': 0
}

dag = DAG(
    dag_id="charts_load",
    default_args=default_args,
    schedule_interval=None,
    catchup=False,
    max_active_runs=1
)

with dag:
    spark_task = SparkSubmitOperator(task_id='spark_task', dag=dag,
                                     name="charts_load",
                                     application='/opt/airflow/dags/example_2.12-0.1.0-SNAPSHOT.jar',
                                     jars="/opt/airflow/dags/postgresql-42.5.0.jar",
                                     java_class='com.example.Main',
                                     verbose=False)
    spark_task
