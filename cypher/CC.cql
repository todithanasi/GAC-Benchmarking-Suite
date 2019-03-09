CALL algo.unionFind.stream("Page", "LINK", {})
YIELD nodeId,setId
RETURN distinct(setId) as component, count(*) as component_size
ORDER BY component_size Desc
Limit 5



// CALL algo.unionFind.stream("Page", "LINK", {})
// YIELD nodeId,setId
// MATCH (u:Page) WHERE id(u) = nodeId
// RETURN u.pageID AS Page, setId
// Limit 5
