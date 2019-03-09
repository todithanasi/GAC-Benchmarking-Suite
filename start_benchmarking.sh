#!/bin/bash
# ==============================================================================
# 
# Todi THANASI
# 
# start_benchmarking.sh
#
# Parameters:
# $1: BENCH_ENGINE - Must be one of these values: SPARK, NEO4J, ENGINE3, ENGINE4
# $2: BENCH_ALGORITHM - Must be one of these values: PR, CC, SSSP
# $3: BENCH_BENCHMARKING - Must be one of these values: 0 or 1. Value 0 means you run the algorithm in the selected engine but we do not log time. Value 1 means log time.
# $4: BENCH_WARMUP - Number of warmups for the benchmarking. Working only if BENCH_BENCHMARKING = 1
# $5: BENCH_ITERATIONS: Number of iterations for the benchmarking. Working only if BENCH_BENCHMARKING = 1
# $6: BENCH_DATASET_PROPERTIES_FILE: Provide the file location of the properties file. Please check the templates folder for more information ex: dataset.neo4j.properties.
#
#
# Global parameters:
# Check file set_env_global_configurations.sh
# 
# Return:
#
# Description:
# File that manages start of Benchmarking.
# 
#
# ==============================================================================




# ------------------------------------------------------------------------------
# Reading scripts directory.
# ------------------------------------------------------------------------------
if [ "x${BENCH_SCRIPTS_DIR}" == "x" ]; then
  export BENCH_SCRIPTS_DIR=$PWD
fi  

# ------------------------------------------------------------------------------
# Set environment global configurations.
# ------------------------------------------------------------------------------

. $BENCH_SCRIPTS_DIR/set_env_global_configurations.sh

# ------------------------------------------------------------------------------
# Parameters
# ------------------------------------------------------------------------------

if [ -z "$1" ];then
    echo ""
    echo "Error! Parameter BENCH_ENGINE not set! Quit ..."
    echo ""
    #
    exit 1
fi
export BENCH_ENGINE=$1

if [ -z "$2" ];then
    echo ""
    echo "Error! Parameter BENCH_ALGORITHM not set! Quit ..."
    echo ""
    #
    exit 1
fi
export BENCH_ALGORITHM=$2

if [ -z "$3" ];then
    echo ""
    echo "Error! Parameter BENCH_BENCHMARKING not set! Quit ..."
    echo ""
    #
    exit 1
fi
export BENCH_BENCHMARKING=$3

if [ -z "$4" ];then
    echo ""
    echo "Error! Parameter BENCH_WARMUP not set! Quit ..."
    echo ""
    #
    exit 1
fi
export BENCH_WARMUP=$4

if [ -z "$5" ];then
    echo ""
    echo "Error! Parameter BENCH_ITERATIONS not set! Quit ..."
    echo ""
    #
    exit 1
fi
export BENCH_ITERATIONS=$5

if [ -z "$6" ];then
    echo ""
    echo "Error! Parameter BENCH_DATASET_PROPERTIES_FILE not set! Quit ..."
    echo ""
    #
    exit 1
fi
export BENCH_DATASET_PROPERTIES_FILE=$6


if [ "${BENCH_ENGINE}" != "SPARK" -a "${BENCH_ENGINE}" != "NEO4J" -a "${BENCH_ENGINE}" != "ENGINE3" -a "${BENCH_ENGINE}" != "ENGINE4" ]; then
  export BENCH_ERROR=1
  export BENCH_ERRORMSG='BENCH_ENGINE value is wrong! Check description in the script start_benchmarking.sh'
  . $BENCH_SCRIPTS_DIR/handle_errors.sh
fi

if [ "${BENCH_ALGORITHM}" != "PR" -a "${BENCH_ALGORITHM}" != "CC" -a "${BENCH_ALGORITHM}" != "SSSP" ]; then
  export BENCH_ERROR=1
  export BENCH_ERRORMSG='BENCH_ALGORITHM value is wrong! Check description in the script start_benchmarking.sh'
  . $BENCH_SCRIPTS_DIR/handle_errors.sh
fi

if [ "${BENCH_BENCHMARKING}" != "0" -a "${BENCH_BENCHMARKING}" != "1" ]; then
  export BENCH_ERROR=1
  export BENCH_ERRORMSG='BENCH_BENCHMARKING value is wrong! Check description in the script start_benchmarking.sh'
  . $BENCH_SCRIPTS_DIR/handle_errors.sh
fi

#TODO: Check that is a number and not a string.
if [ $BENCH_WARMUP -lt 0 ]; then
  export BENCH_ERROR=1
  export BENCH_ERRORMSG='BENCH_WARMUP value is wrong! Check description in the script start_benchmarking.sh'
  . $BENCH_SCRIPTS_DIR/handle_errors.sh
fi

if [ $BENCH_ITERATIONS -lt 0 ]; then
  export BENCH_ERROR=1
  export BENCH_ERRORMSG='BENCH_ITERATIONS value is wrong! Check description in the script start_benchmarking.sh'
  . $BENCH_SCRIPTS_DIR/handle_errors.sh
fi


if [ ! -f $BENCH_DATASET_PROPERTIES_FILE ]; then
  export BENCH_ERROR=2
  export BENCH_ERRORMSG='File does not exist or there is no read access! BENCH_DATASET_PROPERTIES_FILE value is wrong! Check description in the script start_benchmarking.sh'
  . $BENCH_SCRIPTS_DIR/handle_errors.sh
fi

echo ""
echo "*******************************************************************************"
echo "*******************************************************************************"
echo "*******************************************************************************"
echo "******                                                                   ******"
echo "******                        Benchmarking Start                         ******"
echo "******                                                                   ******"
echo "******                          TODI THANASI                             ******"
echo "******                                                                   ******"
echo "******                                                                   ******"
echo "*******************************************************************************"
echo "*******************************************************************************"
echo "*******************************************************************************"
echo ""

# ------------------------------------------------------------------------------
# SPARK
# ------------------------------------------------------------------------------

if [ "${BENCH_ENGINE}" == "SPARK" ]; then
  if [ "${BENCH_ALGORITHM}" == "PR" ]; then
  . $BENCH_SPARK_ROOT/bin/spark $BENCH_SPARK_JAR
  fi
  if [ "${BENCH_ALGORITHM}" == "CC" ]; then
  . $BENCH_SPARK_ROOT/bin/spark $BENCH_SPARK_JAR
  fi
  if [ "${BENCH_ALGORITHM}" == "SSSP" ]; then
  . $BENCH_SPARK_ROOT/bin/spark $BENCH_SPARK_JAR
  fi
  rc=$?
  echo "Returncode: $rc"
  exit $rc
fi


# ------------------------------------------------------------------------------
# NEO4J
# ------------------------------------------------------------------------------
if [ "${BENCH_ENGINE}" == "NEO4J" ]; then
	# Parse dataset properties file
	# TODO: Check if the values of the parameters are not empty.
	# TODO: Change the graph (instead on running it on the default) on which we run these commands.
	while IFS== read key value;do
		[[ "$key" =~ ^#.*$ ]] && continue
		if [ "${key}" == "neo4j.nodes.header" ]; then
			export BENCH_NEO4J_NODES_HEADER=$value
		fi
		if [ "${key}" == "neo4j.nodes" ]; then
			export BENCH_NEO4J_NODES=$value
		fi
		if [ "${key}" == "neo4j.relationship.header" ]; then
			export BENCH_NEO4J_RELATIONSHIP_HEADER=$value
		fi
		if [ "${key}" == "neo4j.relationship" ]; then
			export BENCH_NEO4J_RELATIONSHIP=$value
		fi
	done < $BENCH_DATASET_PROPERTIES_FILE

  if [ "${BENCH_ALGORITHM}" == "PR" ]; then
	if [ $BENCH_BENCHMARKING -eq 1 ]; then
		echo "*******************************************************************************" >> $BENCH_LOGS_DIR/Pagerank_Log.log
		env | sort | grep 'BENCH' >> $BENCH_LOGS_DIR/Pagerank_Log.log
		echo "*******************************************************************************" >> $BENCH_LOGS_DIR/Pagerank_Log.log
		for i in `seq 1 $BENCH_WARMUP`
		do
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Loading graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_NEO4J_ROOT}/bin/neo4j-admin import --nodes:Page "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES}" --relationships:LINK "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP}" 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "Pagerank Warmup $i GraphLoader Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/Pagerank_Log.log
			${BENCH_NEO4J_ROOT}/bin/neo4j start
			
			# Pause for a few seconds to give time Neo4J to prepare.
			sleep 10
			
			# Run Pagerank algorithm.
	    		BENCH_START_TIME=$(($(date +%s%N)/1000000))
			cat $BENCH_SCRIPTS_DIR/cypher/PR.cql | ${BENCH_NEO4J_ROOT}/bin/cypher-shell -u ${BENCH_NEO4J_SHELL_USERNAME} -p ${BENCH_NEO4J_SHELL_PASSWORD} 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "Pagerank Warmup $i Computation Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/Pagerank_Log.log
		done
		for i in `seq 1 $BENCH_ITERATIONS`
		do
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Loading graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_NEO4J_ROOT}/bin/neo4j-admin import --nodes:Page "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES}" --relationships:LINK "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP}" 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "Pagerank Iteration $i GraphLoader Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/Pagerank_Log.log
			${BENCH_NEO4J_ROOT}/bin/neo4j start
			
			# Pause for a few seconds to give time Neo4J to prepare.
			sleep 10
			
			# Run Pagerank algorithm.
	    		BENCH_START_TIME=$(($(date +%s%N)/1000000))
			cat $BENCH_SCRIPTS_DIR/cypher/PR.cql | ${BENCH_NEO4J_ROOT}/bin/cypher-shell -u ${BENCH_NEO4J_SHELL_USERNAME} -p ${BENCH_NEO4J_SHELL_PASSWORD} 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "Pagerank Iteration $i Computation Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/Pagerank_Log.log
		done
	else
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Loading graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
			${BENCH_NEO4J_ROOT}/bin/neo4j-admin import --nodes:Page "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES}" --relationships:LINK "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP}" 
			${BENCH_NEO4J_ROOT}/bin/neo4j start
			
			# Pause for a few seconds to give time Neo4J to prepare.
			sleep 10
			cat $BENCH_SCRIPTS_DIR/cypher/PR.cql | ${BENCH_NEO4J_ROOT}/bin/cypher-shell -u ${BENCH_NEO4J_SHELL_USERNAME} -p ${BENCH_NEO4J_SHELL_PASSWORD} 
	fi
  fi
  if [ "${BENCH_ALGORITHM}" == "CC" ]; then
	if [ $BENCH_BENCHMARKING -eq 1 ]; then
		echo "*******************************************************************************" >> $BENCH_LOGS_DIR/ConnectedComponents_Log.log
		env | sort | grep 'BENCH' >> $BENCH_LOGS_DIR/ConnectedComponents_Log.log
		echo "*******************************************************************************" >> $BENCH_LOGS_DIR/ConnectedComponents_Log.log
		for i in `seq 1 $BENCH_WARMUP`
		do
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Loading graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_NEO4J_ROOT}/bin/neo4j-admin import --nodes:Page "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES}" --relationships:LINK "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP}" 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "ConnectedComponents Warmup $i GraphLoader Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/ConnectedComponents_Log.log
			${BENCH_NEO4J_ROOT}/bin/neo4j start
			
			# Pause for a few seconds to give time Neo4J to prepare.
			sleep 10
			
			# Run ConnectedComponents algorithm.
	    		BENCH_START_TIME=$(($(date +%s%N)/1000000))
			cat $BENCH_SCRIPTS_DIR/cypher/CC.cql | ${BENCH_NEO4J_ROOT}/bin/cypher-shell -u ${BENCH_NEO4J_SHELL_USERNAME} -p ${BENCH_NEO4J_SHELL_PASSWORD} 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "ConnectedComponents Warmup $i Computation Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/ConnectedComponents_Log.log
		done
		for i in `seq 1 $BENCH_ITERATIONS`
		do
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Loading graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_NEO4J_ROOT}/bin/neo4j-admin import --nodes:Page "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES}" --relationships:LINK "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP}" 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "ConnectedComponents Iteration $i GraphLoader Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/ConnectedComponents_Log.log
			${BENCH_NEO4J_ROOT}/bin/neo4j start
			
			# Pause for a few seconds to give time Neo4J to prepare.
			sleep 10
			
			# Run ConnectedComponents algorithm.
	    		BENCH_START_TIME=$(($(date +%s%N)/1000000))
			cat $BENCH_SCRIPTS_DIR/cypher/CC.cql | ${BENCH_NEO4J_ROOT}/bin/cypher-shell -u ${BENCH_NEO4J_SHELL_USERNAME} -p ${BENCH_NEO4J_SHELL_PASSWORD} 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "ConnectedComponents Iteration $i Computation Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/ConnectedComponents_Log.log
		done
	else
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Loading graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
			${BENCH_NEO4J_ROOT}/bin/neo4j-admin import --nodes:Page "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES}" --relationships:LINK "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP}" 
			${BENCH_NEO4J_ROOT}/bin/neo4j start
			
			# Pause for a few seconds to give time Neo4J to prepare.
			sleep 10
		        cat $BENCH_SCRIPTS_DIR/cypher/CC.cql | ${BENCH_NEO4J_ROOT}/bin/cypher-shell -u ${BENCH_NEO4J_SHELL_USERNAME} -p ${BENCH_NEO4J_SHELL_PASSWORD} 
	fi
  fi
  if [ "${BENCH_ALGORITHM}" == "SSSP" ]; then
	if [ $BENCH_BENCHMARKING -eq 1 ]; then
		echo "*******************************************************************************" >> $BENCH_LOGS_DIR/SSSP_Log.log
		env | sort | grep 'BENCH' >> $BENCH_LOGS_DIR/SSSP_Log.log
		echo "*******************************************************************************" >> $BENCH_LOGS_DIR/SSSP_Log.log
		for i in `seq 1 $BENCH_WARMUP`
		do
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Loading graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_NEO4J_ROOT}/bin/neo4j-admin import --nodes:Page "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES}" --relationships:LINK "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP}" 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "SSSP Warmup $i GraphLoader Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/SSSP_Log.log
			${BENCH_NEO4J_ROOT}/bin/neo4j start
			
			# Pause for a few seconds to give time Neo4J to prepare.
			sleep 10
			
			# Run SSSP algorithm.
	    		BENCH_START_TIME=$(($(date +%s%N)/1000000))
			cat $BENCH_SCRIPTS_DIR/cypher/SSSP.cql | ${BENCH_NEO4J_ROOT}/bin/cypher-shell -u ${BENCH_NEO4J_SHELL_USERNAME} -p ${BENCH_NEO4J_SHELL_PASSWORD} 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "SSSP Warmup $i Computation Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/SSSP_Log.log
		done
		for i in `seq 1 $BENCH_ITERATIONS`
		do
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Loading graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_NEO4J_ROOT}/bin/neo4j-admin import --nodes:Page "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES}" --relationships:LINK "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP}" 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "SSSP Iteration $i GraphLoader Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/SSSP_Log.log
			${BENCH_NEO4J_ROOT}/bin/neo4j start
			
			# Pause for a few seconds to give time Neo4J to prepare.
			sleep 10
			
			# Run SSSP algorithm.
	    		BENCH_START_TIME=$(($(date +%s%N)/1000000))
			cat $BENCH_SCRIPTS_DIR/cypher/SSSP.cql | ${BENCH_NEO4J_ROOT}/bin/cypher-shell -u ${BENCH_NEO4J_SHELL_USERNAME} -p ${BENCH_NEO4J_SHELL_PASSWORD} 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "SSSP Iteration $i Computation Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/SSSP_Log.log
		done
	else
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Loading graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
			${BENCH_NEO4J_ROOT}/bin/neo4j-admin import --nodes:Page "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES}" --relationships:LINK "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP}" 
			${BENCH_NEO4J_ROOT}/bin/neo4j start
			
			# Pause for a few seconds to give time Neo4J to prepare.
			sleep 10
		        cat $BENCH_SCRIPTS_DIR/cypher/SSSP.cql | ${BENCH_NEO4J_ROOT}/bin/cypher-shell -u ${BENCH_NEO4J_SHELL_USERNAME} -p ${BENCH_NEO4J_SHELL_PASSWORD} 
	fi
  fi
  rc=$?
  echo "Returncode: $rc"
  exit $rc
fi


# ------------------------------------------------------------------------------
# ENGINE3
# ------------------------------------------------------------------------------

if [ "${BENCH_ENGINE}" == "ENGINE3" ]; then
  if [ "${BENCH_ALGORITHM}" == "PR" ]; then

  fi
  if [ "${BENCH_ALGORITHM}" == "CC" ]; then

  fi
  if [ "${BENCH_ALGORITHM}" == "SSSP" ]; then

  fi
fi

# ------------------------------------------------------------------------------
# ENGINE4
# ------------------------------------------------------------------------------

if [ "${BENCH_ENGINE}" == "ENGINE4" ]; then
  if [ "${BENCH_ALGORITHM}" == "PR" ]; then
  
  fi
  if [ "${BENCH_ALGORITHM}" == "CC" ]; then
 
  fi
  if [ "${BENCH_ALGORITHM}" == "SSSP" ]; then
 
  fi
fi


# ------------------------------------------------------------------------------
# end
# ------------------------------------------------------------------------------
