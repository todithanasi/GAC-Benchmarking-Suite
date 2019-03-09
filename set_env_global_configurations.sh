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


######## How to get another variavble value =${AML_CUSTOM}

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# General settings not related to a specific engine.
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------

export BENCH_LOGS_DIR=$PWD/logs

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# Spark and GraphX settings.
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------

# Path of the root installation folder of Spark. Place the path of one level up from the bin folder.
export BENCH_SPARK_ROOT=

# Path of the jar file that you want to execute. 
export BENCH_SPARK_JAR=


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
# Engine3
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# PageRank algorithm default settings in Engine3.
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# Connected Components algorithm default settings in Engine3.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# SSSP algorithm default settings in Engine3.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# Engine4
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# PageRank algorithm default settings in Engine4.
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# Connected Components algorithm default settings in Engine4.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# SSSP algorithm default settings in Engine4.
# ---------------------------------------------------------------------------
