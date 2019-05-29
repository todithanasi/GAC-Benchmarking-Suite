MATCH (n:Page {pageID:'2'})
CALL algo.shortestPath.deltaStepping.stream(n, 'WEIGHT', 3.0, {concurrency:15}  )
YIELD nodeId, distance
RETURN algo.getNodeById(nodeId).pageID AS destination, distance
LIMIT 5;
