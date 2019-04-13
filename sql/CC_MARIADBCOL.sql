DROP PROCEDURE IF EXISTS WCC;

DELIMITER //

CREATE PROCEDURE WCC() COMMENT 'WCC'

BEGIN

DECLARE flag int DEFAULT -1;

DECLARE isFirst int DEFAULT 1;



WHILE flag != 0 DO

SELECT "loop" + flag;

 IF (isFirst = 1) THEN

 

 DROP TABLE IF EXISTS cur;

CREATE TABLE cur (id INT NOT NULL, val INT) ENGINE=ColumnStore;
INSERT INTO cur SELECT message.id AS id, MIN(message.val) AS val FROM message GROUP BY id;

 SET isFirst = 0;

 ELSE

 DROP TABLE IF EXISTS message;

 CREATE TABLE message (id INT NOT NULL, val INT) ENGINE=ColumnStore;
INSERT INTO message SELECT id, MIN(val) as val FROM (SELECT edges.src_id AS id, toupdate.val AS val FROM toupdate, edges WHERE edges.dest_id = toupdate.id UNION ALL  SELECT edges.dest_id AS id, toupdate.val AS val FROM toupdate, edges WHERE edges.src_id = toupdate.id) AS temp GROUP BY id;

 END IF;




 DROP TABLE IF EXISTS cur;

 CREATE TABLE cur (id INT NOT NULL, val INT) ENGINE=ColumnStore;
INSERT INTO cur SELECT message.id AS id, MIN(message.val) AS val FROM message GROUP BY id;



 DROP TABLE IF EXISTS message;



 DROP TABLE IF EXISTS toupdate;

 CREATE TABLE toupdate (id INT NOT NULL, val INT) ENGINE=ColumnStore;
INSERT INTO toupdate SELECT cur.id AS id, cur.val AS val FROM cur, nextT WHERE cur.id = nextT.id  AND cur.val < nextT.val;



 UPDATE nextT INNER JOIN toupdate ON nextT.id = toupdate.id  SET nextT.val = toupdate.val;

 DROP TABLE IF EXISTS message;

 CREATE TABLE message (id INT NOT NULL, val INT) ENGINE=ColumnStore;
INSERT INTO message SELECT id, MIN(val) as val FROM (SELECT edges.src_id AS id, toupdate.val AS val FROM toupdate, edges WHERE edges.dest_id = toupdate.id  UNION  ALL SELECT edges.dest_id AS id, toupdate.val AS val FROM toupdate, edges WHERE edges.src_id = toupdate.id) AS temp GROUP BY id;


 DROP TABLE IF EXISTS cur;



 SET flag = (SELECT COUNT(*) FROM toupdate);

END WHILE;

 SELECT * FROM nextT LIMIT 5;

END; //

DELIMITER ;
