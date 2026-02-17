import cx_Oracle
import pandas as pd
import datetime
import os
import logging
from tqdm import tqdm
import time
import multiprocessing

# Function to create a backup folder with the current date
def create_backup_folder():
    today_date = datetime.datetime.now().strftime("%Y-%m-%d")
    backup_folder = f"/u01/RA_OPS/tables_backup/{today_date}"
    os.makedirs(backup_folder, exist_ok=True)
    return backup_folder

# Function to backup view and materialized view DDL
def backup_views_ddl(backup_folder, connection):
    cursor = connection.cursor()
    cursor.execute("SELECT object_name, dbms_metadata.get_ddl('VIEW', object_name) FROM user_objects WHERE object_type = 'VIEW'")
    views_ddl = cursor.fetchall()

    cursor.execute("SELECT object_name, dbms_metadata.get_ddl('MATERIALIZED_VIEW', object_name) FROM user_objects WHERE object_type = 'MATERIALIZED VIEW'")
    materialized_views_ddl = cursor.fetchall()

    for object_name, ddl_lob in views_ddl:
        ddl = ddl_lob.read()
        with open(os.path.join(backup_folder, f"{object_name}.sql"), "w") as ddl_file:
            ddl_file.write(ddl)

    for object_name, ddl_lob in materialized_views_ddl:
        ddl = ddl_lob.read()
        with open(os.path.join(backup_folder, f"{object_name}.sql"), "w") as ddl_file:
            ddl_file.write(ddl)

    cursor.close()

# Set up logging to a file
log_file = "/u01/RA_OPS/script_log.txt"
logging.basicConfig(filename=log_file, level=logging.ERROR, format='%(asctime)s - %(levelname)s: %(message)s')

# Set Oracle environment variables
os.environ['ORACLE_HOME'] = '/home/oracle/app/product/12.2.0/client_1'
os.environ['PATH'] = '/home/oracle/app/product/12.2.0/client_1/bin:' + os.environ['PATH']
os.environ['TWO_TASK'] = 'incor.solutions.com.sa'

# Oracle connection string
oracle_connection_string = "recon_prd/recon123@incor.solutions.com.sa"

# Path to the Excel file
excel_file = "/u01/RA_OPS/sequence_updated3.xlsx"

# Function to log results to the log file
def log_result(table, status, elapsed_time):
    timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_line = f'"{table}","{status}","{timestamp}",{elapsed_time}\n'
    with open("/u01/RA_OPS/MVRefrshLogs.csv", "a") as log:
        log.write(log_line)

# Function to refresh a table
def refresh_table(table):
    connection = None
    cursor = None
    start_time = time.time()
    elapsed_time = 0

    try:
        connection = cx_Oracle.connect(oracle_connection_string)
        cursor = connection.cursor()
        cursor.callproc("DBMS_MVIEW.REFRESH", [table, 'C'])
    except cx_Oracle.DatabaseError as e:
        error_message = str(e).replace('\n', ' ').replace('"', '""')
        elapsed_time = time.time() - start_time
        log_result(table, f'error: {error_message}', elapsed_time)
        logging.error(f"Error refreshing materialized view {table}: {error_message}")
    else:
        elapsed_time = time.time() - start_time
        log_result(table, "success", elapsed_time)
    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()

# Function to refresh a table with a timeout
def refresh_table_with_timeout(table, timeout):
    try:
        p = multiprocessing.Process(target=refresh_table, args=(table,))
        p.start()
        p.join(timeout)

        if p.is_alive():
            p.terminate()
            p.join()
            logging.error(f"Timeout occurred while refreshing materialized view {table}.")
            log_result(table, "skipped (timeout)", timeout)
    except Exception as e:
        logging.error(f"Error refreshing materialized view {table}: {str(e)}")
        log_result(table, "skipped (error)", timeout)

# Specify the backup folder path
backup_folder = create_backup_folder()

# Establish Oracle database connection for backup
try:
    connection = cx_Oracle.connect(oracle_connection_string)
except cx_Oracle.DatabaseError as e:
    error_message = str(e)
    logging.error(f"Database connection error for backup: {error_message}")
    exit(1)

# Backup views and materialized views DDL
backup_views_ddl(backup_folder, connection)

# Close the Oracle database connection for backup
try:
    connection.close()
except cx_Oracle.InterfaceError:
    pass

# Establish Oracle database connection
try:
    connection = cx_Oracle.connect(oracle_connection_string)
except cx_Oracle.DatabaseError as e:
    error_message = str(e)
    logging.error(f"Database connection error: {error_message}")
    exit(1)

# Read data from the Excel file
try:
    df = pd.read_excel(excel_file)
except Exception as e:
    error_message = str(e)
    logging.error(f"Error reading Excel file: {error_message}")
    connection.close()
    exit(1)

# Extract table names from the Excel data
table_names = df['table']  # Replace 'table' with the actual column name in your Excel file

# Main loop to execute materialized view refresh operations with a timeout
timeout = 60 * 60  # 35 minutes
for table in tqdm(table_names, desc="Refreshing Materialized Views"):
    refresh_table_with_timeout(table, timeout)

# Close the Oracle database connection
try:
    connection.close()
except cx_Oracle.InterfaceError:
    pass

# Kill Oracle sessions
try:
    connection = cx_Oracle.connect(oracle_connection_string)
    cursor = connection.cursor()
    cursor.execute("ALTER SYSTEM KILL SESSION 'sid,serial#' IMMEDIATE")
    cursor.close()
    connection.close()
except cx_Oracle.DatabaseError as e:
    logging.error(f"Error killing Oracle sessions: {str(e)}")
