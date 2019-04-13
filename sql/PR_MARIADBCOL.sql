DROP PROCEDURE IF EXISTS PagerankNew;
DELIMITER //
CREATE PROCEDURE PagerankNew() COMMENT 'PagerankNew'
BEGIN
DECLARE flag int DEFAULT 10;
DECLARE isFirst int DEFAULT 1;


WHILE flag != 0 DO
SELECT "loop" + flag;
 IF (isFirst = 1) THEN

 DROP TABLE IF EXISTS cur;
 DROP TABLE IF EXISTS curnew;
CREATE TABLE cur (id INT NOT NULL, val double) ENGINE=ColumnStore;
INSERT INTO cur SELECT message.id AS id, CAST(SUM(message.val)*0.85 + 0.15 AS double) AS val FROM message GROUP BY id;


 SET isFirst = 0;
 ELSE

 DROP TABLE IF EXISTS message;
 CREATE TABLE message (id INT NOT NULL, val double) ENGINE=ColumnStore;
INSERT INTO message SELECT edges.dest_id AS id, CAST(SUM(curnew.val/out_cnts.cnt) *0.85 + 0.15 AS double) AS val FROM curnew, edges, out_cnts WHERE edges.src_id = curnew.id AND out_cnts.node_id = curnew.id AND out_cnts.cnt > 0 group by edges.dest_id;

 DROP TABLE IF EXISTS curnew;
 END IF; 

 DROP TABLE IF EXISTS cur;

 CREATE TABLE cur(id INT NOT NULL, val double) ENGINE=ColumnStore;
 INSERT INTO cur SELECT message.id AS id, CAST(SUM(message.val)*0.85 + 0.15 AS double) AS val FROM message GROUP BY id;

 DROP TABLE IF EXISTS message;


 UPDATE nextT INNER JOIN cur ON cur.Id = nextT.Id SET nextT.val = cur.val;


 DROP TABLE IF EXISTS message;
 CREATE TABLE message (id INT NOT NULL, val double) ENGINE=ColumnStore;
INSERT INTO message SELECT edges.dest_id AS id, CAST(SUM(cur.val/out_cnts.cnt) *0.85 + 0.15 AS double) AS val FROM cur, edges, out_cnts WHERE edges.src_id = cur.id AND out_cnts.node_id = cur.id AND out_cnts.cnt > 0 group by edges.dest_id ;

 ALTER TABLE cur RENAME TO curnew;
 SET flag = flag - 1;

END WHILE;
 SELECT * FROM nextT LIMIT 5;
END; //
DELIMITER ;
