DROP PROCEDURE IF EXISTS SSSP;

DELIMITER //

CREATE PROCEDURE SSSP() COMMENT 'SSSP'

BEGIN



DECLARE flag int DEFAULT -1;

DECLARE isFirst int DEFAULT 1;



WHILE flag != 0 DO

SELECT "loop" + flag;

 IF (isFirst = 1) THEN

 

 DROP TABLE IF EXISTS cur;

 CREATE TABLE cur (id INT NOT NULL, val INT) ENGINE=ColumnStore;
INSERT INTO  cur SELECT message.id AS id, MIN(message.val) AS val FROM message GROUP BY id; 



 SET isFirst = 0;

 ELSE

 DROP TABLE IF EXISTS message;



CREATE TABLE message (id INT NOT NULL, val INT) ENGINE=ColumnStore;
INSERT INTO  message SELECT edges.dest_id AS id, CAST(MIN(toupdate.val + edges.weight) AS INT) AS val FROM toupdate, edges WHERE edges.src_id = toupdate.id GROUP BY edges.dest_id;



 END IF;



 DROP TABLE IF EXISTS cur;

 

 CREATE TABLE cur (id INT NOT NULL, val INT) ENGINE=ColumnStore;
INSERT INTO cur SELECT message.id AS id, MIN(message.val) AS val FROM message GROUP BY id;



 DROP TABLE IF EXISTS message;



 DROP TABLE IF EXISTS toupdate;

 

CREATE TABLE toupdate (id INT NOT NULL, val INT) ENGINE=ColumnStore;
INSERT INTO  toupdate SELECT cur.id AS id, cur.val AS val FROM cur, nextT WHERE cur.id = nextT.id  AND cur.val < nextT.val;



 UPDATE nextT INNER JOIN toupdate ON nextT.id = toupdate.id  SET nextT.val = toupdate.val;



 DROP TABLE IF EXISTS message;

 CREATE TABLE message (id INT NOT NULL, val INT) ENGINE=ColumnStore;
INSERT INTO message SELECT edges.dest_id AS id, CAST(MIN(toupdate.val + edges.weight) AS INT) AS val FROM toupdate, edges WHERE edges.src_id = toupdate.id GROUP BY edges.dest_id;


 DROP TABLE IF EXISTS cur;



 SET flag = (SELECT COUNT(*) FROM toupdate);

END WHILE;

SELECT * FROM nextT LIMIT 5;

END; //

DELIMITER ;
