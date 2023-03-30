#!/usr/bin/env python

import pyodbc

def main():
    def _execute_and_print(cursor, query, fetch_rows=False):
        cursor.execute(query)
        if fetch_rows:
            row = cursor.fetchone()
            while row:
                print('row is ' + str(row))
                row = cursor.fetchone()

    server = 'tcp:localhost,57000'
    database = 'master'
    username = 'SA'
    password = 'Str#ng_Passw#rd'

    #Connection String
    cnxn = pyodbc.connect('DRIVER={ODBC Driver 18 for SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+password+';sslverify=0;TrustServerCertificate=yes')
    cursor = cnxn.cursor()

    #Sample select query
    version_query = "SELECT @@version;"
    _execute_and_print(cursor, version_query, fetch_rows=True)

    show_tables_query = '''
    select schema_name(t.schema_id) as schema_name,
        t.name as table_name,
        t.create_date,
        t.modify_date
    from sys.tables t
    order by schema_name,
            table_name;
    '''
    _execute_and_print(cursor, show_tables_query, fetch_rows=True)

    create_table_query = """
    IF EXISTS ( SELECT [name] FROM sys.tables WHERE [name] = 'HotelMaster' )   
    DROP TABLE HotelMaster
        
    CREATE TABLE HotelMaster   
    (   
    RoomID int identity(1,1), 
    RoomNo VARCHAR(100)  NOT NULL , 
    RoomType VARCHAR(100)  NOT NULL ,
    Prize    VARCHAR(100)  NOT NULL
    CONSTRAINT [PK_HotelMaster] PRIMARY KEY CLUSTERED         
    (        
    RoomID ASC   
        
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]        
    ) ON [PRIMARY]      
    
    Insert into HotelMaster(RoomNo,RoomType,Prize) Values('101','Single','50$')
    Insert into HotelMaster(RoomNo,RoomType,Prize) Values('102','Double','80$')
    Insert into HotelMaster(RoomNo,RoomType,Prize) Values('103','Single','100$')
    Insert into HotelMaster(RoomNo,RoomType,Prize) Values('104','Double','50$')
    Insert into HotelMaster(RoomNo,RoomType,Prize) Values('105','Single','100$')
    """
    _execute_and_print(cursor, create_table_query)
    select_query = """
    select * from dbo.HotelMaster
    """
    _execute_and_print(cursor, select_query, fetch_rows=True)

    stored_procedure_query = """
    CREATE PROCEDURE dbo.uspGetEmployeesTest2
        @RoomType nvarchar(50),
        @Prize nvarchar(50)
    AS

    SET NOCOUNT ON;
    SELECT RoomNo, RoomType, Prize
    FROM dbo.HotelMaster
    WHERE RoomType = @RoomType AND Prize = @Prize

    EXECUTE dbo.uspGetEmployeesTest2 N'Single', N'100$';
    """

    backup_query = """
    BACKUP DATABASE dbo
    TO DISK = N'/var/opt/mssql/backup/yourDatabaseBackup.bak'  
    WITH NOFORMAT, NOINIT, NAME = N'yourDatabaseName-Full Database Backup', 
    SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 10
    """
    _execute_and_print(cursor, stored_procedure_query)
    
    get_row_count_query = "SELECT COUNT(*) FROM dbo.HotelMaster"
    _execute_and_print(cursor, get_row_count_query, fetch_rows=True)

    get_single_room_count_query = "SELECT COUNT(*) FROM dbo.HotelMaster WHERE RoomType = 'Single'"
    _execute_and_print(cursor, get_single_room_count_query, fetch_rows=True)

    drop_table_query = "DROP TABLE dbo.HotelMaster"
    _execute_and_print(cursor, drop_table_query)

if __name__ == "__main__":
    main()