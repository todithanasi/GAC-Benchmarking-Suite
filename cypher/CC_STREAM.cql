CALL algo.unionFind.stream("Page", "LINK", {defaultValue:1.0, write: true, writeProperty: 'component', concurrency:15, graph:'huge'})
YIELD nodeId,setId
RETURN distinct(setId) as component, count(*) as component_size
ORDER BY component_size Desc
Limit 5;



// CALL algo.unionFind.stream("Page", "LINK", {})
// YIELD nodeId,setId
// MATCH (u:Page) WHERE id(u) = nodeId
// RETURN u.pageID AS Page, setId
// Limit 5
