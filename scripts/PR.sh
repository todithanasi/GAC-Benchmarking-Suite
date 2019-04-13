
flag=10
isFirst=1


while [ $flag != 0 ]; do
echo "loop" + $flag
 if [ $isFirst = 1 ]; then
 /usr/local/mariadb/columnstore/mysql/bin/mysql --defaults-extra-file=/usr/local/mariadb/columnstore/mysql/my.cnf  --database=graph -u root --execute="
 DROP TABLE IF EXISTS cur;
 DROP TABLE IF EXISTS curnew;
CREATE TABLE cur (id INT NOT NULL, val double) ENGINE=ColumnStore;
INSERT INTO cur SELECT message.id AS id, CAST(SUM(message.val)*0.85 + 0.15 AS double) AS val FROM message GROUP BY id;"


 isFirst=0;
 else
 
 /usr/local/mariadb/columnstore/mysql/bin/mysql --defaults-extra-file=/usr/local/mariadb/columnstore/mysql/my.cnf  --database=graph -u root  --database=graph --execute="
 DROP TABLE IF EXISTS message;
 CREATE TABLE message (id INT NOT NULL, val double) ENGINE=ColumnStore;
INSERT INTO message SELECT edges.dest_id AS id, CAST(SUM(curnew.val/out_cnts.cnt) *0.85 + 0.15 AS double) AS val FROM curnew, edges, out_cnts WHERE edges.src_id = curnew.id AND out_cnts.node_id = curnew.id AND out_cnts.cnt > 0 group by edges.dest_id;

 DROP TABLE IF EXISTS curnew;"
 fi

  /usr/local/mariadb/columnstore/mysql/bin/mysql --defaults-extra-file=/usr/local/mariadb/columnstore/mysql/my.cnf  --database=graph -u root  --database=graph --execute="
 DROP TABLE IF EXISTS cur;

 CREATE TABLE cur(id INT NOT NULL, val double) ENGINE=ColumnStore;
 INSERT INTO cur SELECT message.id AS id, CAST(SUM(message.val)*0.85 + 0.15 AS double) AS val FROM message GROUP BY id;

 DROP TABLE IF EXISTS message;
 
 UPDATE nextT INNER JOIN cur ON cur.Id = nextT.Id SET nextT.val = cur.val;


 DROP TABLE IF EXISTS message;
 CREATE TABLE message (id INT NOT NULL, val double) ENGINE=ColumnStore;
INSERT INTO message SELECT edges.dest_id AS id, CAST(SUM(cur.val/out_cnts.cnt) *0.85 + 0.15 AS double) AS val FROM cur, edges, out_cnts WHERE edges.src_id = cur.id AND out_cnts.node_id = cur.id AND out_cnts.cnt > 0 group by edges.dest_id ;

ALTER TABLE cur RENAME TO curnew;
 "
# RENAME TABLE cur TO curnew;
 flag=$((flag-1));

done;
  /usr/local/mariadb/columnstore/mysql/bin/mysql --defaults-extra-file=/usr/local/mariadb/columnstore/mysql/my.cnf  --database=graph -u root  --database=graph --execute="SELECT * FROM nextT LIMIT 5;"
