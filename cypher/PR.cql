CALL algo.pageRank.stream("Page", "LINKS",
{iterations:20})
YIELD nodeId, score
Limit 5
