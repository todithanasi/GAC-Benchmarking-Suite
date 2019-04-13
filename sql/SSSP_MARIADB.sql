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

 CREATE TABLE cur (id INT NOT NULL, val INT) ENGINE=MEMORY
(SELECT message.id AS id, MIN(message.val) AS val FROM message GROUP BY id); 


DROP INDEX IF EXISTS idx_cur ON cur;
CREATE INDEX idx_cur ON cur(id);

 SET isFirst = 0;

 ELSE

 DROP TABLE IF EXISTS message;



CREATE TABLE message (id INT NOT NULL, val INT) ENGINE=MEMORY
(SELECT Edges.dest_id AS id, CAST(MIN(toupdate.val + Edges.weight) AS INT) AS val FROM toupdate, Edges WHERE Edges.src_id = toupdate.id GROUP BY Edges.dest_id);

DROP INDEX IF EXISTS idx_message ON message;
CREATE INDEX idx_message ON message(id);

 END IF;



 DROP TABLE IF EXISTS cur;

 

 CREATE TABLE cur (id INT NOT NULL, val INT) ENGINE=MEMORY
(SELECT message.id AS id, MIN(message.val) AS val FROM message GROUP BY id);


DROP INDEX IF EXISTS idx_cur ON cur;
CREATE INDEX idx_cur ON cur(id);

 DROP TABLE IF EXISTS message;



 DROP TABLE IF EXISTS toupdate;

 

CREATE TABLE toupdate (id INT NOT NULL, val INT) ENGINE=MEMORY
(SELECT cur.id AS id, cur.val AS val FROM cur, nextT WHERE cur.id = nextT.id  AND cur.val < nextT.val);

DROP INDEX IF EXISTS idx_toupdate ON toupdate;
CREATE INDEX idx_toupdate ON toupdate(id);


 UPDATE nextT INNER JOIN toupdate ON nextT.id = toupdate.id  SET nextT.val = toupdate.val;



 DROP TABLE IF EXISTS message;

 CREATE TABLE message (id INT NOT NULL, val INT) ENGINE=MEMORY
 (SELECT Edges.dest_id AS id, CAST(MIN(toupdate.val + Edges.weight) AS INT) AS val FROM toupdate, Edges WHERE Edges.src_id = toupdate.id GROUP BY Edges.dest_id);

DROP INDEX IF EXISTS idx_message ON message;
CREATE INDEX idx_message ON message(id);

 DROP TABLE IF EXISTS cur;



 SET flag = (SELECT COUNT(*) FROM toupdate);

END WHILE;

SELECT * FROM nextT LIMIT 1000;

END; //

DELIMITER ;
