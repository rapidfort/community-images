
CREATE KEYSPACE schema1 WITH replication = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };

USE schema1;

CREATE TABLE users (
                 user_id varchar PRIMARY KEY,
                 first varchar,
                 last varchar,
                 age int
               );

INSERT INTO users (user_id, first, last, age)
               VALUES ('jsmith', 'John', 'Smith', 42);

SELECT * FROM users;

exit
