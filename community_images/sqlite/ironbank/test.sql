CREATE TABLE test_table(
    id INTEGER PRIMARY KEY,
    text_column TEXT,
    number_column INTEGER
);

-- Insert some sample data
INSERT INTO test_table(text_column, number_column) VALUES ('A', 10);
INSERT INTO test_table(text_column, number_column) VALUES ('B', -20);
INSERT INTO test_table(text_column, number_column) VALUES ('C', 30);
INSERT INTO test_table(text_column, number_column) VALUES ('D', -40);

-- ABS()
SELECT ABS(number_column) AS abs_result FROM test_table;

-- CHANGES()
INSERT INTO test_table(text_column, number_column) VALUES ('E', 50);
SELECT CHANGES() AS changes_result;

-- CHAR()
SELECT CHAR(65, 66, 67) AS char_result;

-- COALESCE()
SELECT COALESCE(NULL, 'Not Null Value') AS coalesce_result;

-- GLOB()
SELECT GLOB('*.txt', 'hello.txt') AS glob_result;

-- HEX()
SELECT HEX('hello') AS hex_result;

-- IFNULL()
SELECT IFNULL(NULL, 'Not Null Value') AS ifnull_result;

-- IIF()
SELECT IIF(1 = 1, 'True', 'False') AS iif_result;

-- INSTR()
SELECT INSTR('hello world', 'world') AS instr_result;

-- LAST_INSERT_ROWID()
SELECT LAST_INSERT_ROWID() AS last_insert_rowid_result;

-- LENGTH()
SELECT LENGTH('Hello') AS length_result;

-- LIKE()
SELECT 'Hello' LIKE 'H%' AS like_result;

-- LIKELIHOOD()
SELECT LIKELIHOOD(1, 0.5) AS likelihood_result;

-- LIKELY()
SELECT LIKELY(1) AS likely_result;

-- LOWER()
SELECT LOWER('Hello') AS lower_result;

-- LTRIM()
SELECT LTRIM('   Hello') AS ltrim_result;

-- MAX()
SELECT MAX(10, 20, 30) AS max_result;

-- MIN()
SELECT MIN(10, 20, 30) AS min_result;

-- NULLIF()
SELECT NULLIF('Hello', 'Hello') AS nullif_result;

-- PRINTF()
SELECT PRINTF('%.2f', 3.14159) AS printf_result;

-- QUOTE()
SELECT QUOTE("It's a quote") AS quote_result;

-- RANDOM()
SELECT RANDOM() AS random_result;

-- REPLACE()
SELECT REPLACE('Hello World', 'World', 'Stack') AS replace_result;

-- ROUND()
SELECT ROUND(3.14159) AS round_result;

-- RTRIM()
SELECT RTRIM('Hello   ') AS rtrim_result;

-- SQLITE_COMPILEOPTION_GET()
SELECT SQLITE_COMPILEOPTION_GET(1) AS sqlite_compileoption_get_result;

-- SQLITE_COMPILEOPTION_USED()
SELECT SQLITE_COMPILEOPTION_USED('ENABLE_FTS3') AS sqlite_compileoption_used_result;

-- SQLITE_SOURCE_ID()
SELECT SQLITE_SOURCE_ID() AS sqlite_source_id_result;

-- SQLITE_VERSION()
SELECT SQLITE_VERSION() AS sqlite_version_result;

-- SUBSTR()
SELECT SUBSTR('Hello', 2) AS substr_result;

-- SUBSTRING()
SELECT SUBSTRING('Hello', 2) AS substring_result;

-- TOTAL_CHANGES()
SELECT TOTAL_CHANGES() AS total_changes_result;

-- TRIM()
SELECT TRIM('   Hello   ') AS trim_result;

-- TYPEOF()
SELECT TYPEOF('Hello') AS typeof_result;

-- UNICODE()
SELECT UNICODE('Hello') AS unicode_result;

-- UPPER()
SELECT UPPER('hello') AS upper_result;

-- ZEROBLOB()
SELECT ZEROBLOB(10) AS zeroblob_result;

SELECT JSON_ARRAY(1, 'two', 3.14, NULL);
-- Test AVG
SELECT AVG(number_column) AS avg_result FROM test_table;

-- Test COUNT
SELECT COUNT(*) AS count_result FROM test_table;

-- Test SUM
SELECT SUM(number_column) AS sum_result FROM test_table;
-- Test DATE
SELECT DATE('now') AS date_result;

-- Test TIME
SELECT TIME('now') AS time_result;

-- Test DATETIME
SELECT DATETIME('now') AS datetime_result;
