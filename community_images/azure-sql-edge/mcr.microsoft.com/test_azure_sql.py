#!/usr/bin/env python

import pyodbc
server = 'tcp:localhost,57000'
database = 'master'
username = 'SA'
password = 'Str#ng_Passw#rd'

#Connection String
cnxn = pyodbc.connect('DRIVER={ODBC Driver 18 for SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+password+';sslverify=0;TrustServerCertificate=yes')
cursor = cnxn.cursor()

#Sample select query
cursor.execute("SELECT @@version;")
row = cursor.fetchone()
while row:
    print(row[0])
    row = cursor.fetchone()

show_tables_query = '''
select schema_name(t.schema_id) as schema_name,
       t.name as table_name,
       t.create_date,
       t.modify_date
from sys.tables t
order by schema_name,
         table_name;
'''
cursor.execute(show_tables_query)
row = cursor.fetchone()
while row:
    print('row is ' + str(row))
    row = cursor.fetchone()

#Sample insert query
#cursor.execute("INSERT SalesLT.Product (Name, ProductNumber, StandardCost, ListPrice, SellStartDate) OUTPUT INSERTED.ProductID VALUES ('SQL Server Express New 20', 'SQLEXPRESS New 20', 0, 0, CURRENT_TIMESTAMP )")
#row = cursor.fetchone()
#while row:
#    print('Inserted Product key is ' + str(row[0]))
#    row = cursor.fetchone()