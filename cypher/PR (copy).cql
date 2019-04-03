CALL algo.pageRank.stream("Page", "LINKS",
{iterations:20})
YIELD nodeId, score
Return nodeId, score
LIMIT 5;
