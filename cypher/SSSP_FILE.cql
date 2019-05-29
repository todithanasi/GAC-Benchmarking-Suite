MATCH (n:Page {pageID:'1'})
CALL algo.shortestPath.deltaStepping(n, 'WEIGHT', 3.0, {write:true, writeProperty:'sssp', concurrency:15 } )
YIELD nodeCount, loadDuration, evalDuration, writeDuration
RETURN nodeCount, loadDuration, evalDuration, writeDuration;
