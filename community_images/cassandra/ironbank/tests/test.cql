
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


CREATE TABLE schema1.cyclist_points (
   id UUID, 
   firstname text, 
   lastname text, 
   race_title text, 
   race_points int, 
   PRIMARY KEY (id, race_points ));


CREATE TABLE parts (part_type text,part_name text,part_num int,part_year text,serial_num text,PRIMARY KEY ((part_type, part_name), part_num, part_year));


SELECT sum(race_points) FROM schema1.cyclist_points WHERE id=e3b19ec4-774a-4d1c-9e5a-decec1e30aac AND race_points > 7;


CREATE TABLE ruling_stewards (
  steward_name text,
  king text,
  reign_start int,
  event text,
  PRIMARY KEY (steward_name, king, reign_start)
); 

SELECT * FROM ruling_stewards
WHERE king = 'Brego'
  AND reign_start >= 2450
  AND reign_start < 2500 
ALLOW FILTERING;


Select * 
FROM ruling_stewards
WHERE king = 'none'
  AND reign_start >= 1500
  AND reign_start < 3000 
LIMIT 10 
ALLOW FILTERING;



exit





