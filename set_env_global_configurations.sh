#!/bin/bash
# ===========================================================================
#
# Todi THANASI
#
# set_env_global_configurations.sh
#
# Parameters:
#
# Global parameters:
#
# Return:
#
# Description:
# Global default configuration file for Benchmarking.
# Note: Only command export allowed here!
#
# ===========================================================================



# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# General settings not related to a specific engine.
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------

export BENCH_LOGS_DIR=$PWD/logs
export BENCH_SQL_SCRIPTS_DIR=$PWD/sql
export BENCH_SHELL_SCRIPTS_DIR=$PWD/scripts

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# Spark and GraphX settings.
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------

# Path of the root installation folder of Spark. Place the path of one level up from the bin folder.
export BENCH_SPARK_ROOT=/share/hadoop/todi_thanasi/spark-2.4.2-bin-hadoop2.7

# Path of the jar file that you want to execute. 
export BENCH_SPARK_JAR=/share/hadoop/todi_thanasi/GraphX/sourcecode_2.11-0.1.jar

# SPARK Master URL. 
export BENCH_SPARK_MASTER_URL=spark://cloud-11.dima.tu-berlin.de:7077

# SPARK output path for saving the algorithm result.
export BENCH_SPARK_OUTPUT=hdfs://cloud-11:44000/user/hadoop/thanasi/

# ---------------------------------------------------------------------------
# PageRank algorithm default settings in Spark.
# ---------------------------------------------------------------------------
export BENCH_SPARK_PAGERANK_ITERATIONS= 

#Parallelism
#inputPath
#OutputPath

# ---------------------------------------------------------------------------
# Connected Components algorithm default settings in Spark.
# ---------------------------------------------------------------------------

#Parallelism
#inputPath
#OutputPath

# ---------------------------------------------------------------------------
# SSSP algorithm default settings in Spark.
# ---------------------------------------------------------------------------

#Parallelism
#inputPath
#OutputPath
#vertexidToStart SSSP

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# Neo4J
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------

# Path of the root installation folder of Neo4J. Place the path of one level up from the bin folder.
export BENCH_NEO4J_ROOT=/home/bdm/SDM-Software/neo4j-community-3.5.3

# Username and password to access Neo4J shell.
export BENCH_NEO4J_SHELL_USERNAME=neo4j
export BENCH_NEO4J_SHELL_PASSWORD=master2019

# ---------------------------------------------------------------------------
# PageRank algorithm default settings in Neo4J.
# ---------------------------------------------------------------------------

export BENCH_NEO4J_PAGERANK_ITERATIONS=10

# ---------------------------------------------------------------------------
# Connected Components algorithm default settings in Neo4J.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# SSSP algorithm default settings in Neo4J.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# MARIADB
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------

# Path of the root installation folder of MariaDB.
export BENCH_MARIADB_ROOT=/usr/sbin/

export BENCH_MARIADB_DATABASE_NAME=Graph

# Username and password to access Neo4J shell.
export BENCH_MARIADB_SHELL_USERNAME=user2
export BENCH_MARIADB_SHELL_PASSWORD='p@$$w0rd'

# Use "mysql" when just MariaDB is installed. For MariaDB columnar should be provided full path and the extra argument.
export BENCH_MARIADB_MYSQL='/usr/local/mariadb/columnstore/mysql/bin/mysql --defaults-extra-file=/usr/local/mariadb/columnstore/mysql/my.cnf'

# ---------------------------------------------------------------------------
# PageRank algorithm default settings in MariaDB.
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# Connected Components algorithm default settings in MariaDB.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# SSSP algorithm default settings in MariaDB.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# MARIADBCOL
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------

# Path of the root installation folder of MariaDB Columnar.
export BENCH_MARIADBCOL_ROOT=/usr/sbin/

export BENCH_MARIADBCOL_DATABASE_NAME=graph

# Username and password to access Neo4J shell.
export BENCH_MARIADBCOL_SHELL_USERNAME=user2
export BENCH_MARIADBCOL_SHELL_PASSWORD='p@$$w0rd'

# For MariaDB columnar should be provided full path and the extra argument.
export BENCH_MARIADBCOL_MYSQL='/usr/local/mariadb/columnstore/mysql/bin/mysql --defaults-extra-file=/usr/local/mariadb/columnstore/mysql/my.cnf'


export BENCH_MARIADBCOL_CPIMPORT='/usr/local/mariadb/columnstore/bin/cpimport'
# ---------------------------------------------------------------------------
# PageRank algorithm default settings in MARIADBCOL.
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# Connected Components algorithm default settings in MARIADBCOL.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# SSSP algorithm default settings in MARIADBCOL.
# ---------------------------------------------------------------------------
