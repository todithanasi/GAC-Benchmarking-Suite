CALL algo.pageRank.stream("Page", "LINKS",
{iterations:10, dampingFactor:0.85, concurrency:15, graph:'huge' })
YIELD nodeId, score
Return nodeId, score
LIMIT 5;
