import os
import pandas as pd
import cx_Oracle
from datetime import datetime
import shutil
import logging

# Set up logging to console and file
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Create a file handler for logging to CSV
log_file = 'extract_tables_to_excel_log.csv'
file_handler = logging.FileHandler(log_file)
file_handler.setLevel(logging.INFO)
file_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
logger.addHandler(file_handler)

# Set Oracle environment variables (adjust paths as needed)
os.environ['ORACLE_HOME'] = '/home/oracle/app/product/12.2.0/client_1'
os.environ['PATH'] = '/home/oracle/app/product/12.2.0/client_1/bin:' + os.environ['PATH']
os.environ['TNS_ADMIN'] = '/home/oracle/app/product/12.2.0/client_1/network/admin'

# Oracle connection details
oracle_connection_string = "recon_prd/recon123@incor.solutions.com.sa"
target_folder = "/home/sdev/ROOT/AutoExport"
target_folder2 = "/home/sdev/ROOT2/Extracts"
target_folder3 = "/home/sdev/ROOT2/Reconcilaition Results"
def copy_folder_with_existing_check(output_folder, target_folder):
    target_path = os.path.join(target_folder, os.path.basename(output_folder))
    
    if os.path.exists(target_path):
        logger.info(f"Folder '{target_path}' already exists. Copying files into the existing folder.")
        try:
            for item in os.listdir(output_folder):
                source_item = os.path.join(output_folder, item)
                target_item = os.path.join(target_path, item)

                if os.path.isdir(source_item):
                    shutil.copytree(source_item, target_item, dirs_exist_ok=True)
                else:
                    shutil.copy2(source_item, target_item)
            logger.info(f"Copied files from '{output_folder}' to existing folder '{target_path}'")
        except Exception as e:
            error_msg = f"Error copying files to '{target_path}': {str(e)}"
            logger.error(error_msg)
            print(error_msg)
    else:
        try:
            shutil.copytree(output_folder, target_path)
            logger.info(f"Copied folder '{output_folder}' to '{target_path}'")
        except Exception as e:
            error_msg = f"Error copying folder '{output_folder}' to '{target_path}': {str(e)}"
            logger.error(error_msg)
            print(error_msg)
# Function to export tables from Oracle database and create or insert into historical tables
def export_tables_from_oracle():
    # Path to list of tables CSV file
    tables_csv_path = '/u01/RA_OPS/Export_BACKUP/listoftables.csv'
    
    # Read list of tables from CSV file
    try:
        tables_df = pd.read_csv(tables_csv_path)
        table_names = tables_df['TableName'].tolist()
        keys = tables_df['Key'].tolist()
        if 'WhereCondition' in tables_df.columns:
            where_conditions = tables_df['WhereCondition'].tolist()
        else:
            where_conditions = [''] * len(table_names)
    except Exception as e:
        error_msg = f"Error reading tables from CSV file: {str(e)}"
        logger.error(error_msg)
        print(error_msg)
        return
    where_conditions = ['' if pd.isna(condition) or condition == 'nan' else condition 
                   for condition in where_conditions]
    
    # Get current month and year for folder name
    current_date = datetime.now()
    folder_name = current_date.strftime('%B-%Y')  # Example: 'July-2024'
    output_folder = f"/u01/RA_OPS/Export_BACKUP/{folder_name}"
    # Output folder path
    os.makedirs(output_folder, exist_ok=True)
    
    # Connect to Oracle database
    try:
        connection = cx_Oracle.connect(oracle_connection_string)
        cursor = connection.cursor()
    except cx_Oracle.Error as e:
        error_msg = f"Error connecting to Oracle database: {str(e)}"
        logger.error(error_msg)
        print(error_msg)
        return

    try:
        for table_name, key, where_condition in zip(table_names, keys, where_conditions):  # Strip any leading/trailing spaces
            table_name = table_name.strip()
            key_column = key
            
            # Fetch data from the table
            where_clause = f"WHERE {where_condition}" if where_condition else ""
            query = f"SELECT rownum as row_id,{key_column} as key_,x.*, 'NULL' as previous_case, 'NULL' as previous_comments, 'NULL' as comments, to_date(sysdate,'dd-Mon-yy') as date_time FROM {table_name} x {where_clause}"
            try:
                df = pd.read_sql(query, con=connection)
            except Exception as e:
                error_msg = f"Error fetching data from table '{table_name}': {str(e)}"
                logger.error(error_msg)
                print(error_msg)
                continue
            
            # Export data to CSV
            output_file = os.path.join(output_folder, f"{table_name}.csv")
            try:
                df.to_csv(output_file, index=False)
                logger.info(f"Exported table '{table_name}' to '{output_file}'")
                #copy_folder_with_existing_check(output_folder, target_folder)
                copy_folder_with_existing_check(output_folder, target_folder2)
                #copy_folder_with_existing_check(output_folder, target_folder3)
            except Exception as e:
                error_msg = f"Error exporting data to CSV for table '{table_name}': {str(e)}"
                logger.error(error_msg)
                print(error_msg)
                continue
            
            # Check if _historical table exists
            historical_table_name = f"{table_name}_historical"
            try:
                cursor.execute(f"SELECT count(*) FROM user_tables WHERE table_name = '{historical_table_name.upper()}'")
                table_exists = cursor.fetchone()[0] == 1
            except cx_Oracle.Error as e:
                error_msg = f"Error checking existence of table '{historical_table_name}': {str(e)}"
                logger.error(error_msg)
                print(error_msg)
                continue
            
            try:
                if not table_exists:
                    # If _historical table does not exist, create it
                    create_table_query = f"CREATE TABLE {historical_table_name} AS SELECT rownum as row_id,{key_column} as key_,x.*, 'NULL' as previous_case, 'NULL' as previous_comments, 'NULL' as comments, to_date(sysdate,'dd-Mon-yy') as date_time FROM {table_name} x"
                    cursor.execute(create_table_query)
                    logger.info(f"Created table '{historical_table_name}'")
                
                # Delete existing data for current month and year
                current_month_year = current_date.strftime('%b-%y')  # Format like 'Jul-24'
                delete_query = f"DELETE FROM {historical_table_name} WHERE to_char(date_time, 'Mon-YY') = '{current_month_year}'"
                cursor.execute(delete_query)
                logger.info(f"Deleted existing data for '{current_month_year}' from '{historical_table_name}'")
                
                # Insert data into _historical table
                if not df.empty:
                    insert_query = f"INSERT INTO {historical_table_name} SELECT rownum as row_id,{key_column} as key_,x.*, 'NULL' as previous_case, 'NULL' as previous_comments, 'NULL' as comments, to_date(sysdate,'dd-Mon-yy') as date_time FROM {table_name} x"
                    cursor.execute(insert_query)
                    connection.commit()
                    logger.info(f"Inserted data into '{historical_table_name}'")
                else:
                    logger.warning(f"No data to insert into '{historical_table_name}'")
            
            except cx_Oracle.Error as e:
                error_msg = f"Error processing table '{table_name}': {str(e)}"
                logger.error(error_msg)
                print(error_msg)
                continue
    
    finally:
        # Close cursor and connection
        if cursor:
            cursor.close()
        if connection:
            connection.close()
    
    # Copy the created folder to /home/sdev/ROOT/AutoExport
   
# Example usage
if __name__ == "__main__":
    export_tables_from_oracle()
