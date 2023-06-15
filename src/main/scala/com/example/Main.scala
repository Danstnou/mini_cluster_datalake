package com.example

import org.apache.spark.sql.SparkSession

object Main extends App {
  val spark = SparkSession.builder().enableHiveSupport().getOrCreate()

  val (db, table) = ("test_repl_spotify", "charts")

  spark.sql(s"create database if not exists $db")

  val df = spark.read
    .format("jdbc")
    .option("driver", "org.postgresql.Driver")
    .option("url", "jdbc:postgresql://postgres:5432/spotify")
    .option("dbtable", table)
    .option("user", "airflow")
    .option("password", "airflow")
    .load()

  df.write.mode("overwrite").saveAsTable(s"$db.$table")
}