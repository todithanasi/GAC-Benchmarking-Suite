CALL algo.pageRank("Page", "LINKS",
{iterations:10, dampingFactor:0.85, write: true, writeProperty: 'pagerank', concurrency:15, graph:'huge'  })
YIELD nodes, iterations, loadMillis, computeMillis, writeMillis, dampingFactor, write, writeProperty;
