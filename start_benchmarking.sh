#!/bin/bash
# ==============================================================================
# 
# Todi THANASI
# 
# start_benchmarking.sh
#
# Parameters:
# $1: BENCH_ENGINE - Must be one of these values: SPARK, NEO4J, MARIADB, MARIADBCOL
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


if [ "${BENCH_ENGINE}" != "SPARK" -a "${BENCH_ENGINE}" != "NEO4J" -a "${BENCH_ENGINE}" != "MARIADB" -a "${BENCH_ENGINE}" != "MARIADBCOL" ]; then
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
# All functions for implementing the algoriths.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# MARIADB PR
# ------------------------------------------------------------------------------

function MARIADB_PR_CREATE_DATABASE() 
{
echo "DROP DATABASE IF EXISTS  $BENCH_MARIADB_DATABASE_NAME; CREATE DATABASE $BENCH_MARIADB_DATABASE_NAME;"
}


function MARIADB_PR_CREATE_TABLES() 
{
echo "CREATE TABLE $BENCH_MARIADB_DATABASE_NAME.Nodes (
node_id INT NOT NULL) ENGINE=MEMORY;
CREATE TABLE $BENCH_MARIADB_DATABASE_NAME.Edges (
src_id  int not null,
dest_id  int not null
) ENGINE=MEMORY;"
}


function MARIADB_PR_DISABLE_FEATURES() 
{
echo "SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET AUTOCOMMIT = 0;"
}


function MARIADB_PR_CREATE_PRIMARYKEY() 
{
echo "ALTER TABLE $BENCH_MARIADB_DATABASE_NAME.Nodes ADD PRIMARY KEY (node_id);
ALTER TABLE $BENCH_MARIADB_DATABASE_NAME.Edges ADD PRIMARY KEY (src_id, dest_id);"
}


function MARIADB_PR_CREATE_INDEX() 
{
echo "CREATE INDEX idx_src ON Edges(src_id);
CREATE INDEX idx_dest ON Edges(dest_id);
CREATE INDEX idx_node ON Nodes(node_id);"
}


function MARIADB_PR_CREATE_HELP_TABLES() 
{
echo "CREATE TABLE nextT (id INT NOT NULL, val double) ENGINE=MEMORY
SELECT node_id AS id, CAST(0 AS double) AS  val FROM Nodes;
CREATE INDEX idx_nextT ON nextT(id);
CREATE TABLE out_cnts (node_id INT NOT NULL, cnt INT) ENGINE=MEMORY
SELECT Nodes.node_id, count(dest_id) as cnt from Nodes left outer join Edges on Nodes.node_id = Edges.src_id group by Nodes.node_id ;
CREATE INDEX idx_cnts ON out_cnts(node_id);
CREATE TABLE message(id int not null, val double) ENGINE=MEMORY;
INSERT INTO message(SELECT *, CAST(0 as double) FROM Nodes);"
}

function MARIADB_PR_ENABLE_FEATURES() 
{
echo "SET UNIQUE_CHECKS = 1;
SET FOREIGN_KEY_CHECKS = 1;
COMMIT;
SET AUTOCOMMIT = 1;"
}

function MARIADB_PR_RUN_PR() 
{
echo "CALL PagerankNew();"
}

# ------------------------------------------------------------------------------
# MARIADB CC
# ------------------------------------------------------------------------------

function MARIADB_CC_CREATE_DATABASE() 
{
echo "DROP DATABASE IF EXISTS  $BENCH_MARIADB_DATABASE_NAME; CREATE DATABASE $BENCH_MARIADB_DATABASE_NAME;"
}


function MARIADB_CC_CREATE_TABLES() 
{
echo "CREATE TABLE $BENCH_MARIADB_DATABASE_NAME.Nodes (
node_id INT NOT NULL) ENGINE=MEMORY;
CREATE TABLE $BENCH_MARIADB_DATABASE_NAME.Edges (
src_id  int not null,
dest_id  int not null
) ENGINE=MEMORY;"
}


function MARIADB_CC_DISABLE_FEATURES() 
{
echo "SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET AUTOCOMMIT = 0;"
}

function MARIADB_CC_CREATE_PRIMARYKEY() 
{
echo "ALTER TABLE $BENCH_MARIADB_DATABASE_NAME.Nodes ADD PRIMARY KEY (node_id);
ALTER TABLE $BENCH_MARIADB_DATABASE_NAME.Edges ADD PRIMARY KEY (src_id, dest_id);"
}

function MARIADB_CC_CREATE_INDEX() 
{
echo "CREATE INDEX idx_src ON Edges(src_id);
CREATE INDEX idx_dest ON Edges(dest_id);
CREATE INDEX idx_node ON Nodes(node_id);"
}


function MARIADB_CC_CREATE_HELP_TABLES() 
{
echo "CREATE TABLE nextT (id INT NOT NULL, val INT) ENGINE=MEMORY
(SELECT node_id AS id, CAST(2147483647 AS INT) AS  val FROM Nodes);
CREATE INDEX idx_nextT ON nextT(id);
CREATE TABLE message(id int, val INT) ENGINE=MEMORY;
INSERT INTO message (SELECT *, CAST(node_id as INT) FROM Nodes);
DROP INDEX IF EXISTS idx_message ON message;
CREATE INDEX idx_message ON message(id);"
}

function MARIADB_CC_ENABLE_FEATURES() 
{
echo "SET UNIQUE_CHECKS = 1;
SET FOREIGN_KEY_CHECKS = 1;
COMMIT;
SET AUTOCOMMIT = 1;"
}

function MARIADB_CC_RUN_CC() 
{
echo "CALL WCC();"
}

# ------------------------------------------------------------------------------
# MARIADB SSSP
# ------------------------------------------------------------------------------

function MARIADB_SSSP_CREATE_DATABASE() 
{
echo "DROP DATABASE IF EXISTS  $BENCH_MARIADB_DATABASE_NAME; CREATE DATABASE $BENCH_MARIADB_DATABASE_NAME;"
}


function MARIADB_SSSP_CREATE_TABLES() 
{
echo "CREATE TABLE $BENCH_MARIADB_DATABASE_NAME.Nodes (
node_id INT NOT NULL) ENGINE=MEMORY;
CREATE TABLE $BENCH_MARIADB_DATABASE_NAME.Edges (
src_id  int not null,
dest_id  int not null,
weight int not null default 1
) ENGINE=MEMORY;"
}

function MARIADB_SSSP_DISABLE_FEATURES() 
{
echo "SET FOREIGN_KEY_CHECKS = 0;
SET UNIQUE_CHECKS = 0;
SET AUTOCOMMIT = 0;"
}

function MARIADB_SSSP_CREATE_PRIMARYKEY() 
{
echo "ALTER TABLE $BENCH_MARIADB_DATABASE_NAME.Nodes ADD PRIMARY KEY (node_id);
ALTER TABLE $BENCH_MARIADB_DATABASE_NAME.Edges ADD PRIMARY KEY (src_id, dest_id);"
}


function MARIADB_SSSP_CREATE_INDEX() 
{
echo "CREATE INDEX idx_src ON Edges(src_id);
CREATE INDEX idx_dest ON Edges(dest_id);
CREATE INDEX idx_node ON Nodes(node_id);"
}


function MARIADB_SSSP_CREATE_HELP_TABLES() 
{
echo "CREATE TABLE nextT (id INT NOT NULL, val INT) ENGINE=MEMORY
(SELECT node_id AS id, CAST(2147483647 AS INT) AS  val FROM Nodes);
CREATE INDEX idx_nextT ON nextT(id);
CREATE TABLE message(id int, val INT) ENGINE=MEMORY;
INSERT INTO message VALUES(1, CAST(0 as INT));"
}

function MARIADB_SSSP_ENABLE_FEATURES() 
{
echo "SET UNIQUE_CHECKS = 1;
SET FOREIGN_KEY_CHECKS = 1;
COMMIT;
SET AUTOCOMMIT = 1;"
}

function MARIADB_SSSP_RUN_SSSP() 
{
echo "CALL SSSP();"
}



# ------------------------------------------------------------------------------
# MARIADBCOL PR
# ------------------------------------------------------------------------------


function MARIADBCOL_PR_CREATE_DATABASE() 
{
echo "DROP DATABASE IF EXISTS  $BENCH_MARIADBCOL_DATABASE_NAME; CREATE DATABASE $BENCH_MARIADBCOL_DATABASE_NAME;"
}


function MARIADBCOL_PR_CREATE_TABLES() 
{
echo "CREATE TABLE $BENCH_MARIADBCOL_DATABASE_NAME.nodes (
node_id INT NOT NULL) ENGINE=ColumnStore;
CREATE TABLE $BENCH_MARIADBCOL_DATABASE_NAME.edges (
src_id  int not null,
dest_id  int not null
) ENGINE=ColumnStore;"
}


function MARIADBCOL_PR_CREATE_HELP_TABLES() 
{
echo "CREATE TABLE nextT (id INT NOT NULL, val double) ENGINE=ColumnStore; 
INSERT INTO nextT SELECT node_id AS id, CAST(0 AS double) AS  val FROM nodes; 
CREATE TABLE out_cnts (node_id INT NOT NULL, cnt INT) ENGINE=ColumnStore; 
INSERT INTO out_cnts select nodes.node_id, count(dest_id) as cnt from nodes left outer join edges on nodes.node_id = edges.src_id group by nodes.node_id; 
CREATE TABLE message(id int not null, val double) ENGINE=ColumnStore; 
INSERT INTO message(SELECT *, CAST(0 as double) FROM nodes);"
}

function MARIADBCOL_PR_RUN_PR() 
{
echo "set infinidb_vtable_mode = 2; CALL PagerankNew();"
}

# ------------------------------------------------------------------------------
# MARIADBCOL CC
# ------------------------------------------------------------------------------

function MARIADBCOL_CC_CREATE_DATABASE() 
{
echo "DROP DATABASE IF EXISTS  $BENCH_MARIADBCOL_DATABASE_NAME; CREATE DATABASE $BENCH_MARIADBCOL_DATABASE_NAME;"
}


function MARIADBCOL_CC_CREATE_TABLES() 
{
echo "CREATE TABLE $BENCH_MARIADBCOL_DATABASE_NAME.nodes (
node_id INT NOT NULL) ENGINE=ColumnStore;
CREATE TABLE $BENCH_MARIADBCOL_DATABASE_NAME.edges (
src_id  int not null,
dest_id  int not null
) ENGINE=ColumnStore;"
}


function MARIADBCOL_CC_CREATE_HELP_TABLES() 
{
echo "CREATE TABLE nextT (id INT NOT NULL, val INT) ENGINE=ColumnStore;
INSERT INTO nextT SELECT node_id AS id, CAST(2147483647 AS INT) AS  val FROM nodes;
CREATE TABLE message(id int, val INT) ENGINE=ColumnStore;
INSERT INTO message (SELECT *, CAST(node_id as INT) FROM nodes);"
}

function MARIADBCOL_CC_RUN_CC() 
{
echo "set infinidb_vtable_mode = 2; CALL WCC();"
}

# ------------------------------------------------------------------------------
# MARIADBCOL SSSP
# ------------------------------------------------------------------------------
function MARIADBCOL_SSSP_CREATE_DATABASE() 
{
echo "DROP DATABASE IF EXISTS  $BENCH_MARIADBCOL_DATABASE_NAME; CREATE DATABASE $BENCH_MARIADBCOL_DATABASE_NAME;"
}


function MARIADBCOL_SSSP_CREATE_TABLES() 
{
echo "CREATE TABLE $BENCH_MARIADBCOL_DATABASE_NAME.nodes (
node_id INT NOT NULL) ENGINE=ColumnStore;
CREATE TABLE $BENCH_MARIADBCOL_DATABASE_NAME.edges (
src_id  int not null,
dest_id  int not null,
weight int not null default 1
) ENGINE=ColumnStore;"
}


function MARIADBCOL_SSSP_CREATE_HELP_TABLES() 
{
echo "CREATE TABLE nextT (id INT NOT NULL, val INT) ENGINE=ColumnStore;
INSERT INTO nextT SELECT node_id AS id, CAST(2147483647 AS INT) AS  val FROM nodes;
CREATE TABLE message(id int, val INT) ENGINE=ColumnStore;
INSERT INTO message VALUES(1, CAST(0 as INT));"
}

function MARIADBCOL_SSSP_RUN_SSSP() 
{
echo "set infinidb_vtable_mode = 2; CALL SSSP();"
}

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
	# TODO: Log the query of the cypher file for the case of Neo4j because we miss the parameters (ex: Pagerank Iterantions).
	# TODO: Read the parameter values for the different algorithms in Neo4J. Do not hard code in the cypher file. 
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
		echo "*******************************************************************************" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		env | sort | grep 'BENCH' >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		echo "*******************************************************************************" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		for i in `seq 1 $BENCH_WARMUP`
		do
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Load graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_NEO4J_ROOT}/bin/neo4j-admin import --nodes:Page "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES}" --relationships:LINK "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP}" 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "Pagerank Warmup $i GraphLoader Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
			${BENCH_NEO4J_ROOT}/bin/neo4j start
			
			# Pause for a few seconds to give time Neo4J to prepare.
			sleep 10
			
			# Run Pagerank algorithm.
	    		BENCH_START_TIME=$(($(date +%s%N)/1000000))
			cat $BENCH_SCRIPTS_DIR/cypher/PR.cql | ${BENCH_NEO4J_ROOT}/bin/cypher-shell -u ${BENCH_NEO4J_SHELL_USERNAME} -p ${BENCH_NEO4J_SHELL_PASSWORD} 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "Pagerank Warmup $i Computation Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		done
		for i in `seq 1 $BENCH_ITERATIONS`
		do
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Load graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_NEO4J_ROOT}/bin/neo4j-admin import --nodes:Page "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES}" --relationships:LINK "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP}" 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "Pagerank Iteration $i GraphLoader Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
			${BENCH_NEO4J_ROOT}/bin/neo4j start
			
			# Pause for a few seconds to give time Neo4J to prepare.
			sleep 10
			
			# Run Pagerank algorithm.
	    		BENCH_START_TIME=$(($(date +%s%N)/1000000))
			cat $BENCH_SCRIPTS_DIR/cypher/PR.cql | ${BENCH_NEO4J_ROOT}/bin/cypher-shell -u ${BENCH_NEO4J_SHELL_USERNAME} -p ${BENCH_NEO4J_SHELL_PASSWORD} 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "Pagerank Iteration $i Computation Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		done
	else
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Load graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
			${BENCH_NEO4J_ROOT}/bin/neo4j-admin import --nodes:Page "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES}" --relationships:LINK "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP}" 
			${BENCH_NEO4J_ROOT}/bin/neo4j start
			
			# Pause for a few seconds to give time Neo4J to prepare.
			sleep 10
			cat $BENCH_SCRIPTS_DIR/cypher/PR.cql | ${BENCH_NEO4J_ROOT}/bin/cypher-shell -u ${BENCH_NEO4J_SHELL_USERNAME} -p ${BENCH_NEO4J_SHELL_PASSWORD} 
	fi
  fi
  if [ "${BENCH_ALGORITHM}" == "CC" ]; then
	if [ $BENCH_BENCHMARKING -eq 1 ]; then
		echo "*******************************************************************************" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		env | sort | grep 'BENCH' >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		echo "*******************************************************************************" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		for i in `seq 1 $BENCH_WARMUP`
		do
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Load graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_NEO4J_ROOT}/bin/neo4j-admin import --nodes:Page "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES}" --relationships:LINK "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP}" 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "ConnectedComponents Warmup $i GraphLoader Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
			${BENCH_NEO4J_ROOT}/bin/neo4j start
			
			# Pause for a few seconds to give time Neo4J to prepare.
			sleep 10
			
			# Run ConnectedComponents algorithm.
	    		BENCH_START_TIME=$(($(date +%s%N)/1000000))
			cat $BENCH_SCRIPTS_DIR/cypher/CC.cql | ${BENCH_NEO4J_ROOT}/bin/cypher-shell -u ${BENCH_NEO4J_SHELL_USERNAME} -p ${BENCH_NEO4J_SHELL_PASSWORD} 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "ConnectedComponents Warmup $i Computation Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		done
		for i in `seq 1 $BENCH_ITERATIONS`
		do
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Load graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_NEO4J_ROOT}/bin/neo4j-admin import --nodes:Page "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES}" --relationships:LINK "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP}" 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "ConnectedComponents Iteration $i GraphLoader Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
			${BENCH_NEO4J_ROOT}/bin/neo4j start
			
			# Pause for a few seconds to give time Neo4J to prepare.
			sleep 10
			
			# Run ConnectedComponents algorithm.
	    		BENCH_START_TIME=$(($(date +%s%N)/1000000))
			cat $BENCH_SCRIPTS_DIR/cypher/CC.cql | ${BENCH_NEO4J_ROOT}/bin/cypher-shell -u ${BENCH_NEO4J_SHELL_USERNAME} -p ${BENCH_NEO4J_SHELL_PASSWORD} 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "ConnectedComponents Iteration $i Computation Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		done
	else
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Load graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
			${BENCH_NEO4J_ROOT}/bin/neo4j-admin import --nodes:Page "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES}" --relationships:LINK "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP}" 
			${BENCH_NEO4J_ROOT}/bin/neo4j start
			
			# Pause for a few seconds to give time Neo4J to prepare.
			sleep 10
		        cat $BENCH_SCRIPTS_DIR/cypher/CC.cql | ${BENCH_NEO4J_ROOT}/bin/cypher-shell -u ${BENCH_NEO4J_SHELL_USERNAME} -p ${BENCH_NEO4J_SHELL_PASSWORD} 
	fi
  fi
  if [ "${BENCH_ALGORITHM}" == "SSSP" ]; then
	if [ $BENCH_BENCHMARKING -eq 1 ]; then
		echo "*******************************************************************************" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		env | sort | grep 'BENCH' >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		echo "*******************************************************************************" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		for i in `seq 1 $BENCH_WARMUP`
		do
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Load graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_NEO4J_ROOT}/bin/neo4j-admin import --nodes:Page "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES}" --relationships:LINK "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP}" 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "SSSP Warmup $i GraphLoader Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
			${BENCH_NEO4J_ROOT}/bin/neo4j start
			
			# Pause for a few seconds to give time Neo4J to prepare.
			sleep 10
			
			# Run SSSP algorithm.
	    		BENCH_START_TIME=$(($(date +%s%N)/1000000))
			cat $BENCH_SCRIPTS_DIR/cypher/SSSP.cql | ${BENCH_NEO4J_ROOT}/bin/cypher-shell -u ${BENCH_NEO4J_SHELL_USERNAME} -p ${BENCH_NEO4J_SHELL_PASSWORD} 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "SSSP Warmup $i Computation Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		done
		for i in `seq 1 $BENCH_ITERATIONS`
		do
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Load graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_NEO4J_ROOT}/bin/neo4j-admin import --nodes:Page "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_NODES}" --relationships:LINK "${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP_HEADER},${BENCH_NEO4J_ROOT}/import/${BENCH_NEO4J_RELATIONSHIP}" 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "SSSP Iteration $i GraphLoader Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
			${BENCH_NEO4J_ROOT}/bin/neo4j start
			
			# Pause for a few seconds to give time Neo4J to prepare.
			sleep 10
			
			# Run SSSP algorithm.
	    		BENCH_START_TIME=$(($(date +%s%N)/1000000))
			cat $BENCH_SCRIPTS_DIR/cypher/SSSP.cql | ${BENCH_NEO4J_ROOT}/bin/cypher-shell -u ${BENCH_NEO4J_SHELL_USERNAME} -p ${BENCH_NEO4J_SHELL_PASSWORD} 
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "SSSP Iteration $i Computation Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		done
	else
			# Delete graph. We need to stop first Neo4J, delete and start again the service. We do not measure the time here.
			${BENCH_NEO4J_ROOT}/bin/neo4j stop
			rm -rf ${BENCH_NEO4J_ROOT}/data/databases/graph.db		

			# Load graph. It can be imported only if Neo4j is not running. Start Neo4J after importing.
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
# MARIADB
# ------------------------------------------------------------------------------

# NOTE: The shell user should have enough permissions (GRANTS) to access the new database that is being created below. ($BENCH_MARIADB_DATABASE_NAME)

if [ "${BENCH_ENGINE}" == "MARIADB" ]; then

	while IFS== read key value;do
		[[ "$key" =~ ^#.*$ ]] && continue
		if [ "${key}" == "mariadb.nodes" ]; then
			export BENCH_MARIADB_NODES_FILE=$value
		fi
		if [ "${key}" == "mariadb.relationship" ]; then
			export BENCH_MARIADB_RELATIONSHIP_FILE=$value
		fi
	done < $BENCH_DATASET_PROPERTIES_FILE	

	if [ $BENCH_BENCHMARKING -eq 1 ]; then
		echo "*******************************************************************************" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		env | sort | grep 'BENCH' >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		echo "*******************************************************************************" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		for i in `seq 1 $BENCH_WARMUP`
		do
			# Load graph dataset.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))

			# Login into mariadb shell. Create Database and tables.
			${BENCH_MARIADB_MYSQL}  --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_DATABASE)"
			${BENCH_MARIADB_MYSQL}  --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_TABLES)"
			
			# Disable some DB features to speedup the import of the dataset.
			${BENCH_MARIADB_MYSQL}  --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_DISABLE_FEATURES)"
			
			# Load
			${BENCH_MARIADB_MYSQL}  --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="
			LOAD DATA LOCAL INFILE '$BENCH_MARIADB_NODES_FILE'   INTO TABLE $BENCH_MARIADB_DATABASE_NAME.Nodes FIELDS TERMINATED BY ','  LINES TERMINATED BY '\n';"
			${BENCH_MARIADB_MYSQL}  --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="
			LOAD DATA LOCAL INFILE '$BENCH_MARIADB_RELATIONSHIP_FILE'   INTO TABLE $BENCH_MARIADB_DATABASE_NAME.Edges FIELDS TERMINATED BY ','  LINES TERMINATED BY '\n';"
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "${BENCH_ALGORITHM} Warmup $i GraphLoader Total:  $BENCH_TOTAL_TIME"
			echo "${BENCH_ALGORITHM} Warmup $i GraphLoader Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log

			# Create Primary Key.
			# BENCH_START_TIME=$(($(date +%s%N)/1000000))
			# ${BENCH_MARIADB_MYSQL} --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_PRIMARYKEY)"
			# BENCH_END_TIME=$(($(date +%s%N)/1000000))
			# BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			# echo "${BENCH_ALGORITHM} Warmup $i Create Primary Key Total:  $BENCH_TOTAL_TIME"
			# echo "${BENCH_ALGORITHM} Warmup $i Create Primary Key Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log

			# Create Index.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_MARIADB_MYSQL}  --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_INDEX)"
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "${BENCH_ALGORITHM} Warmup $i Create Index Total:  $BENCH_TOTAL_TIME"
			echo "${BENCH_ALGORITHM} Warmup $i Create Index Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log


			# Create help tables.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_MARIADB_MYSQL}  --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_HELP_TABLES)"
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "${BENCH_ALGORITHM} Warmup $i Create help tables Total:  $BENCH_TOTAL_TIME"
			echo "${BENCH_ALGORITHM} Warmup $i Create help tables Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		
			# Enable DB features.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_MARIADB_MYSQL}  --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_ENABLE_FEATURES)"

			# Create stored procedure.
			${BENCH_MARIADB_MYSQL}  --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" < $BENCH_SQL_SCRIPTS_DIR/${BENCH_ALGORITHM}_${BENCH_ENGINE}.sql
			
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "${BENCH_ALGORITHM} Warmup $i Create Stored Procedure Total:  $BENCH_TOTAL_TIME"
			echo "${BENCH_ALGORITHM} Warmup $i Create Stored Procedure Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
			
			# Run algorithm.
	    		BENCH_START_TIME=$(($(date +%s%N)/1000000))

			${BENCH_MARIADB_MYSQL}  --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_RUN_${BENCH_ALGORITHM})"

			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "${BENCH_ALGORITHM} Warmup $i Computation Total:  $BENCH_TOTAL_TIME"
			echo "${BENCH_ALGORITHM} Warmup $i Computation Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log


		done
		for i in `seq 1 $BENCH_ITERATIONS`
		do
			# Load graph dataset.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))

			# Login into mariadb shell. Create Database and tables.
			cd ${BENCH_MARIADB_ROOT}
			${BENCH_MARIADB_MYSQL}  --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_DATABASE)"
			${BENCH_MARIADB_MYSQL}  --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_TABLES)"
			
			# Disable some DB features to speedup the import of the dataset.
			${BENCH_MARIADB_MYSQL}  --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_DISABLE_FEATURES)"
			
			# Load
			${BENCH_MARIADB_MYSQL}  --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="
			LOAD DATA LOCAL INFILE '$BENCH_MARIADB_NODES_FILE'   INTO TABLE $BENCH_MARIADB_DATABASE_NAME.Nodes FIELDS TERMINATED BY ','  LINES TERMINATED BY '\n';"
			${BENCH_MARIADB_MYSQL}  --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="
			LOAD DATA LOCAL INFILE '$BENCH_MARIADB_RELATIONSHIP_FILE'   INTO TABLE $BENCH_MARIADB_DATABASE_NAME.Edges FIELDS TERMINATED BY ','  LINES TERMINATED BY '\n';"
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "${BENCH_ALGORITHM} Iteration $i GraphLoader Total:  $BENCH_TOTAL_TIME"
			echo "${BENCH_ALGORITHM} Iteration $i GraphLoader Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log

			# Create Primary Key.
			# BENCH_START_TIME=$(($(date +%s%N)/1000000))
			# ${BENCH_MARIADB_MYSQL} --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_PRIMARYKEY)"
			# BENCH_END_TIME=$(($(date +%s%N)/1000000))
			# BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			# echo "${BENCH_ALGORITHM} Iteration $i Create Primary Key Total:  $BENCH_TOTAL_TIME"
			# echo "${BENCH_ALGORITHM} Iteration $i Create Primary Key Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log

			# Create Index.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_MARIADB_MYSQL}   --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_INDEX)"
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "${BENCH_ALGORITHM} Iteration $i Create Index Total:  $BENCH_TOTAL_TIME"
			echo "${BENCH_ALGORITHM} Iteration $i Create Index Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log


			# Create help tables.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_MARIADB_MYSQL}   --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_HELP_TABLES)"
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "${BENCH_ALGORITHM} Iteration $i Create help tables Total:  $BENCH_TOTAL_TIME"
			echo "${BENCH_ALGORITHM} Iteration $i Create help tables Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		
			# Enable DB features.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_MARIADB_MYSQL}  --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_ENABLE_FEATURES)"

			# Create stored procedure.
			${BENCH_MARIADB_MYSQL}   --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" < $BENCH_SQL_SCRIPTS_DIR/${BENCH_ALGORITHM}_${BENCH_ENGINE}.sql
			
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "${BENCH_ALGORITHM} Iteration $i Create Stored Procedure Total:  $BENCH_TOTAL_TIME"
			echo "${BENCH_ALGORITHM} Iteration $i Create Stored Procedure Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
			
			# Run algorithm.
	    		BENCH_START_TIME=$(($(date +%s%N)/1000000))

			${BENCH_MARIADB_MYSQL}  --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_RUN_${BENCH_ALGORITHM})"

			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "${BENCH_ALGORITHM} Iteration $i Computation Total:  $BENCH_TOTAL_TIME"
			echo "${BENCH_ALGORITHM} Iteration $i Computation Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log

		done
	else
			# Load graph dataset.

			# Login into mariadb shell. Create Database and tables.
			cd ${BENCH_MARIADB_ROOT}
			${BENCH_MARIADB_MYSQL} --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --execute="$(${BENCH_ENGINE}_{BENCH_ALGORITHM}_CREATE_DATABASE)"
			${BENCH_MARIADB_MYSQL} --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_TABLES)"
			
			# Disable some DB features to speedup the import of the dataset.
			${BENCH_MARIADB_MYSQL} --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_DISABLE_FEATURES)"
			
			# Load
			${BENCH_MARIADB_MYSQL} --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="
			LOAD DATA LOCAL INFILE '$BENCH_MARIADB_NODES_FILE'   INTO TABLE $BENCH_MARIADB_DATABASE_NAME.Nodes FIELDS TERMINATED BY ','  LINES TERMINATED BY '\n';"
			${BENCH_MARIADB_MYSQL} --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="
			LOAD DATA LOCAL INFILE '$BENCH_MARIADB_RELATIONSHIP_FILE'   INTO TABLE $BENCH_MARIADB_DATABASE_NAME.Edges FIELDS TERMINATED BY ','  LINES TERMINATED BY '\n';"

			# Create Primary Key.
			# ${BENCH_MARIADB_MYSQL} --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_PRIMARYKEY)"


			# Create Index.
			${BENCH_MARIADB_MYSQL} --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_INDEX)"

			# Create help tables.
			${BENCH_MARIADB_MYSQL} --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_HELP_TABLES)"

			# Enable DB features.
			${BENCH_MARIADB_MYSQL} --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_ENABLE_FEATURES)"

			# Create stored procedure.
			${BENCH_MARIADB_MYSQL} --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" < $BENCH_SQL_SCRIPTS_DIR/${BENCH_ALGORITHM}_${BENCH_ENGINE}.sql

			# Run algorithm.
			${BENCH_MARIADB_MYSQL} --user="${BENCH_MARIADB_SHELL_USERNAME}" --password="${BENCH_MARIADB_SHELL_PASSWORD}" --database="$BENCH_MARIADB_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_RUN_${BENCH_ALGORITHM})"

	fi
  rc=$?
  echo "Returncode: $rc"
  exit $rc
fi

# ------------------------------------------------------------------------------
# MARIADBCOL
# ------------------------------------------------------------------------------

if [ "${BENCH_ENGINE}" == "MARIADBCOL" ]; then

	while IFS== read key value;do
		[[ "$key" =~ ^#.*$ ]] && continue
		if [ "${key}" == "mariadbcol.nodes" ]; then
			export BENCH_MARIADBCOL_NODES_FILE=$value
		fi
		if [ "${key}" == "mariadbcol.relationship" ]; then
			export BENCH_MARIADBCOL_RELATIONSHIP_FILE=$value
		fi
	done < $BENCH_DATASET_PROPERTIES_FILE	

	if [ $BENCH_BENCHMARKING -eq 1 ]; then
		echo "*******************************************************************************" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		env | sort | grep 'BENCH' >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		echo "*******************************************************************************" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		for i in `seq 1 $BENCH_WARMUP`
		do
			# Load graph dataset.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))

			# Login into mariadb shell. Create Database and tables.
			${BENCH_MARIADBCOL_MYSQL} --user="${BENCH_MARIADBCOL_SHELL_USERNAME}" --password="${BENCH_MARIADBCOL_SHELL_PASSWORD}" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_DATABASE)"
			${BENCH_MARIADBCOL_MYSQL} --user="${BENCH_MARIADBCOL_SHELL_USERNAME}" --password="${BENCH_MARIADBCOL_SHELL_PASSWORD}" --database="$BENCH_MARIADBCOL_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_TABLES)"
						
			
			# Load
			$BENCH_MARIADBCOL_CPIMPORT graph nodes "$BENCH_MARIADBCOL_NODES_FILE"  -s ","
			$BENCH_MARIADBCOL_CPIMPORT graph edges "$BENCH_MARIADBCOL_RELATIONSHIP_FILE"  -s ","
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "${BENCH_ALGORITHM} Warmup $i GraphLoader Total:  $BENCH_TOTAL_TIME"
			echo "${BENCH_ALGORITHM} Warmup $i GraphLoader Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log


			# Create help tables.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_MARIADBCOL_MYSQL} --user="${BENCH_MARIADBCOL_SHELL_USERNAME}" --password="${BENCH_MARIADBCOL_SHELL_PASSWORD}" --database="$BENCH_MARIADBCOL_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_HELP_TABLES)"
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "${BENCH_ALGORITHM} Warmup $i Create help tables Total:  $BENCH_TOTAL_TIME"
			echo "${BENCH_ALGORITHM} Warmup $i Create help tables Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log

			# Create stored procedure.
			# ${BENCH_MARIADBCOL_MYSQL} --user="${BENCH_MARIADBCOL_SHELL_USERNAME}" --password="${BENCH_MARIADBCOL_SHELL_PASSWORD}" --database="$BENCH_MARIADBCOL_DATABASE_NAME" < $BENCH_SQL_SCRIPTS_DIR/${BENCH_ALGORITHM}_${BENCH_ENGINE}.sql
			
			# Run algorithm.
	    		BENCH_START_TIME=$(($(date +%s%N)/1000000))

			# ${BENCH_MARIADBCOL_MYSQL} --user="${BENCH_MARIADBCOL_SHELL_USERNAME}" --password="${BENCH_MARIADBCOL_SHELL_PASSWORD}" --database="$BENCH_MARIADBCOL_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_{BENCH_ALGORITHM}_RUN_{BENCH_ALGORITHM})"
			$BENCH_SHELL_SCRIPTS_DIR/${BENCH_ALGORITHM}.sh
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "${BENCH_ALGORITHM} Warmup $i Computation Total:  $BENCH_TOTAL_TIME"
			echo "${BENCH_ALGORITHM} Warmup $i Computation Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log

		done
		for i in `seq 1 $BENCH_ITERATIONS`
		do
			# Load graph dataset.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))

			# Login into mariadb shell. Create Database and tables.
			${BENCH_MARIADBCOL_MYSQL} --user="${BENCH_MARIADBCOL_SHELL_USERNAME}" --password="${BENCH_MARIADBCOL_SHELL_PASSWORD}" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_DATABASE)"
			${BENCH_MARIADBCOL_MYSQL} --user="${BENCH_MARIADBCOL_SHELL_USERNAME}" --password="${BENCH_MARIADBCOL_SHELL_PASSWORD}" --database="$BENCH_MARIADBCOL_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_TABLES)"
			

			# Load
			$BENCH_MARIADBCOL_CPIMPORT graph nodes "$BENCH_MARIADBCOL_NODES_FILE"  -s ","
			$BENCH_MARIADBCOL_CPIMPORT graph edges "$BENCH_MARIADBCOL_RELATIONSHIP_FILE"  -s ","
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "${BENCH_ALGORITHM} Iteration $i GraphLoader Total:  $BENCH_TOTAL_TIME"
			echo "${BENCH_ALGORITHM} Iteration $i GraphLoader Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log


			# Create help tables.
			BENCH_START_TIME=$(($(date +%s%N)/1000000))
			${BENCH_MARIADBCOL_MYSQL} --user="${BENCH_MARIADBCOL_SHELL_USERNAME}" --password="${BENCH_MARIADBCOL_SHELL_PASSWORD}" --database="$BENCH_MARIADBCOL_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_HELP_TABLES)"
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "${BENCH_ALGORITHM} Iteration $i Create help tables Total:  $BENCH_TOTAL_TIME"
			echo "${BENCH_ALGORITHM} Iteration $i Create help tables Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log
		
			# Create stored procedure.
			# ${BENCH_MARIADBCOL_MYSQL} --user="${BENCH_MARIADBCOL_SHELL_USERNAME}" --password="${BENCH_MARIADBCOL_SHELL_PASSWORD}" --database="$BENCH_MARIADBCOL_DATABASE_NAME" < $BENCH_SQL_SCRIPTS_DIR/${BENCH_ALGORITHM}_${BENCH_ENGINE}.sql
			
			
			# Run algorithm.
	    		BENCH_START_TIME=$(($(date +%s%N)/1000000))

			# ${BENCH_MARIADBCOL_MYSQL} --user="${BENCH_MARIADBCOL_SHELL_USERNAME}" --password="${BENCH_MARIADBCOL_SHELL_PASSWORD}" --database="$BENCH_MARIADBCOL_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_{BENCH_ALGORITHM}_RUN_{BENCH_ALGORITHM})"
			$BENCH_SHELL_SCRIPTS_DIR/${BENCH_ALGORITHM}.sh
			BENCH_END_TIME=$(($(date +%s%N)/1000000))
			BENCH_TOTAL_TIME=$(echo "scale=3; $(($BENCH_END_TIME - $BENCH_START_TIME)) / 1000" | bc)
			echo "${BENCH_ALGORITHM} Iteration $i Computation Total:  $BENCH_TOTAL_TIME"
			echo "${BENCH_ALGORITHM} Iteration $i Computation Total:  $BENCH_TOTAL_TIME" >> $BENCH_LOGS_DIR/${BENCH_ENGINE}_${BENCH_ALGORITHM}_Log.log

		done
	else
			# Load graph dataset.

			# Login into mariadb shell. Create Database and tables.
			${BENCH_MARIADBCOL_MYSQL} --user="${BENCH_MARIADBCOL_SHELL_USERNAME}" --password="${BENCH_MARIADBCOL_SHELL_PASSWORD}" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_DATABASE);"
			${BENCH_MARIADBCOL_MYSQL} --user="${BENCH_MARIADBCOL_SHELL_USERNAME}" --password="${BENCH_MARIADBCOL_SHELL_PASSWORD}" --database="$BENCH_MARIADBCOL_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_TABLES)"
			
			
			# Load
			$BENCH_MARIADBCOL_CPIMPORT graph nodes "$BENCH_MARIADBCOL_NODES_FILE"  -s ","
			$BENCH_MARIADBCOL_CPIMPORT graph edges "$BENCH_MARIADBCOL_RELATIONSHIP_FILE"  -s ","

			# Create help tables.
			${BENCH_MARIADBCOL_MYSQL} --user="${BENCH_MARIADBCOL_SHELL_USERNAME}" --password="${BENCH_MARIADBCOL_SHELL_PASSWORD}" --database="$BENCH_MARIADBCOL_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_${BENCH_ALGORITHM}_CREATE_HELP_TABLES)"

			# Create stored procedure.
			${BENCH_MARIADBCOL_MYSQL} --user="${BENCH_MARIADBCOL_SHELL_USERNAME}" --password="${BENCH_MARIADBCOL_SHELL_PASSWORD}" --database="$BENCH_MARIADBCOL_DATABASE_NAME" < $BENCH_SQL_SCRIPTS_DIR/${BENCH_ALGORITHM}_${BENCH_ENGINE}.sql

			# Run algorithm.
			# ${BENCH_MARIADBCOL_MYSQL} --user="${BENCH_MARIADBCOL_SHELL_USERNAME}" --password="${BENCH_MARIADBCOL_SHELL_PASSWORD}" --database="$BENCH_MARIADBCOL_DATABASE_NAME" --execute="$(${BENCH_ENGINE}_{BENCH_ALGORITHM}_RUN_{BENCH_ALGORITHM})"
			$BENCH_SHELL_SCRIPTS_DIR/${BENCH_ALGORITHM}.sh
	fi
  rc=$?
  echo "Returncode: $rc"
  exit $rc
fi


# ------------------------------------------------------------------------------
# end
# ------------------------------------------------------------------------------
