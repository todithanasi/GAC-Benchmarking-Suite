MATCH (n:Page {pageID:'0'})
CALL algo.shortestPath.deltaStepping.stream(n, 'LINK', 3.0)
YIELD nodeId, distance

RETURN algo.getNodeById(nodeId).name AS destination, distance
LIMIT 5;
