#!/bin/bash
# ------------------------------------------------------------------------------
# 
# Todi THANASI
#
# dataset.neo4j.properties
#
#
#
# Description:
# This is a template file to read the file names of the dataset before importing in Neo4J.
#
# This template is used by the script start_benchmarking.sh
#


# All the below mentioned files should be located in the import folder of the Neo4J.
neo4j.nodes.header=com-orkut.ungraph-nodes-header.txt
neo4j.nodes=com-orkut.ungraph-nodes.txt
neo4j.relationship.header=com-orkut.ungraph-relationship-header.txt
neo4j.relationship=com-orkut.ungraph-relationship-comma.txt
