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
 DROP TABLE IF EXISTS cur_alias;
CREATE TABLE cur (id INT NOT NULL, val double) ENGINE=MEMORY
SELECT message.id AS id, CAST(SUM(message.val)*0.85 + 0.15 AS double) AS val FROM message GROUP BY id;


 SET isFirst = 0;
 ELSE

 DROP TABLE IF EXISTS message;
 CREATE TABLE message (id INT NOT NULL, val double) ENGINE=MEMORY
(SELECT Edges.dest_id AS id, CAST(SUM(cur_alias.val/out_cnts.cnt) *0.85 + 0.15 AS double) AS val FROM cur_alias, Edges, out_cnts WHERE Edges.src_id = cur_alias.id AND out_cnts.node_id = cur_alias.id AND out_cnts.cnt > 0 group by Edges.dest_id) ;

 DROP TABLE IF EXISTS cur_alias;
 END IF; 

 DROP TABLE IF EXISTS cur;

 CREATE TABLE cur(id INT NOT NULL, val double) ENGINE=MEMORY
  (SELECT message.id AS id, CAST(SUM(message.val)*0.85 + 0.15 AS double) AS val FROM message GROUP BY id) ;

 DROP TABLE IF EXISTS message;

DROP INDEX IF EXISTS idx_cur ON cur;
CREATE INDEX idx_cur ON cur(id);
 
 UPDATE nextT INNER JOIN cur ON cur.Id = nextT.Id SET nextT.val = cur.val;


 DROP TABLE IF EXISTS message;
 CREATE TABLE message (id INT NOT NULL, val double) ENGINE=MEMORY
(SELECT Edges.dest_id AS id, CAST(SUM(cur.val/out_cnts.cnt) *0.85 + 0.15 AS double) AS val FROM cur, Edges, out_cnts WHERE Edges.src_id = cur.id AND out_cnts.node_id = cur.id AND out_cnts.cnt > 0 group by Edges.dest_id) ;

DROP INDEX IF EXISTS idx_message ON message;
CREATE INDEX idx_message ON message(id);
 ALTER TABLE cur RENAME TO cur_alias;
DROP INDEX IF EXISTS idx_cur_alias ON cur_alias;
CREATE INDEX idx_cur_alias ON cur_alias(id);
 SET flag = flag - 1;

END WHILE;
 SELECT * FROM nextT LIMIT 5;
END; //
DELIMITER ;
