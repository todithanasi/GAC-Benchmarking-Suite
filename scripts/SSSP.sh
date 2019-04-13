
flag=-1
isFirst=1


while [ $flag != 0 ]; do
echo "loop" + $flag
 if [ $isFirst = 1 ]; then
 /usr/local/mariadb/columnstore/mysql/bin/mysql --defaults-extra-file=/usr/local/mariadb/columnstore/mysql/my.cnf  --database=graph -u root --execute="
 DROP TABLE IF EXISTS cur;
CREATE TABLE cur (id INT NOT NULL, val INT) ENGINE=ColumnStore;
INSERT INTO cur SELECT message.id AS id, MIN(message.val) AS val FROM message GROUP BY id;"


 isFirst=0;
 else
 
 /usr/local/mariadb/columnstore/mysql/bin/mysql --defaults-extra-file=/usr/local/mariadb/columnstore/mysql/my.cnf  --database=graph -u root  --database=graph --execute="
 DROP TABLE IF EXISTS message;

 CREATE TABLE message (id INT NOT NULL, val INT) ENGINE=ColumnStore;
INSERT INTO message SELECT id, MIN(val) as val FROM (SELECT edges.src_id AS id, toupdate.val AS val FROM toupdate, edges WHERE edges.dest_id = toupdate.id UNION ALL  SELECT edges.dest_id AS id, toupdate.val AS val FROM toupdate, edges WHERE edges.src_id = toupdate.id) AS temp GROUP BY id;"
 fi

  /usr/local/mariadb/columnstore/mysql/bin/mysql --defaults-extra-file=/usr/local/mariadb/columnstore/mysql/my.cnf  --database=graph -u root  --database=graph --execute="
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
"

 flag=$(/usr/local/mariadb/columnstore/mysql/bin/mysql --defaults-extra-file=/usr/local/mariadb/columnstore/mysql/my.cnf  --database=graph -u root  --database=graph --execute="(SELECT COUNT(*) FROM toupdate);")
flag=${flag:9}
done;
  /usr/local/mariadb/columnstore/mysql/bin/mysql --defaults-extra-file=/usr/local/mariadb/columnstore/mysql/my.cnf  --database=graph -u root  --database=graph --execute="SELECT * FROM nextT LIMIT 5;"
