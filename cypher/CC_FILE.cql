CALL algo.unionFind('Page', 'LINK', {defaultValue:1.0, write: true, writeProperty: 'component', concurrency:15, graph:'huge'});

// CALL algo.unionFind.stream("Page", "LINK", {})
// YIELD nodeId,setId
// MATCH (u:Page) WHERE id(u) = nodeId
// RETURN u.pageID AS Page, setId
// Limit 5
