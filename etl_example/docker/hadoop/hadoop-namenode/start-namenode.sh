#!/bin/bash

NAME_DIR=`echo $HDFS_CONF_DFS_NAMENODE_DATA_DIR | perl -pe 's#file://##'`

if [ ! -d $NAME_DIR ]; then
    echo "Namenode name directory not found: $NAME_DIR"
    exit 2
fi

if [ -z "$CLUSTER_NAME" ]; then
    echo "Cluster name not specified"
    exit 2
fi

if [ "`ls -A $NAME_DIR`" == "" ]; then
    echo "Formatting namenode directory: $NAME_DIR"
    $HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR namenode -format $CLUSTER_NAME
fi

hdfs dfs -mkdir -p /user/spark/applicationHistory
hdfs dfs -chmod 777 /user/spark/applicationHistory

$HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR namenode