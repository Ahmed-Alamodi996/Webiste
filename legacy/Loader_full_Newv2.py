import json
import psycopg2.pool
import pandas as pd
from datetime import datetime, date
import os
import cx_Oracle
import csv
import shutil
import logging
import time
import openpyxl
from os.path import join
import re 

log_folder = "/u01/RA_OPS/Test_New_Loader/Final/LOGs/"
os.makedirs(log_folder, exist_ok=True)  # Create the folder if it doesn't exist

# Get the current date and time with hour and minute
current_date = datetime.now().strftime("%Y-%m-%d_%H-%M")

# Construct the log file path
log_filename = f"new_log_{current_date}.csv"
log_filepath = os.path.join(log_folder, log_filename)

# Configure logging to write logs to the specified file
logging.basicConfig(
    filename=log_filepath,
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)


# Set Oracle environment variables for character set and language
os.environ['NLS_LANG'] = 'AMERICAN_AMERICA.AL32UTF8'
os.environ['NLS_NCHAR'] = 'TRUE'

# Load configuration from config.json
try:
    with open('config.json') as config_file:
        config = json.load(config_file)
except Exception as e:
    logging.error("Error loading config.json: %s", e)
    exit()
def truncate_string(s, max_length):
    if len(s) > max_length:
        return s[:max_length]
    return s
# PostgreSQL and Oracle connection details
pg_config = config['postgresql']
oracle_config = config['oracle']

# Set ORACLE_HOME environment variable
os.environ['ORACLE_HOME'] = oracle_config['oracle_home']
#truncate_long_strings
def check_and_truncate(cell, max_length=4000):
    # Check if the cell is a string
    if isinstance(cell, str):
        # Truncate the cell if its byte length exceeds max_length
        while len(cell.encode('utf-8')) > max_length:
            cell = cell[:-1]
        if len(cell.encode('utf-8')) < len(cell):
            logging.warning("Truncating a cell to fit within byte limit.")
    return cell
# Function to retry file movement
def move_file(source, destination):
    max_retries = 3
    retries = 0
    while retries < max_retries:
        try:
            shutil.copy(source, destination)
            return True
        except Exception as e:
            logging.error("Error moving file %s to %s: %s", source, destination, e)
            retries += 1
            if retries < max_retries:
                logging.info("Retrying file movement in 5 seconds...")
                time.sleep(5)
            else:
                return False
def move_file2(source, destination):
    max_retries = 3
    retries = 0
    while retries < max_retries:
        try:
            shutil.move(source, destination)
            return True
        except Exception as e:
            logging.error("Error moving file %s to %s: %s", source, destination, e)
            retries += 1
            if retries < max_retries:
                logging.info("Retrying file movement in 5 seconds...")
                time.sleep(5)
            else:
                return False
# Create a connection pool for PostgreSQL
try:
    pg_conn_pool = psycopg2.pool.ThreadedConnectionPool(
        minconn=1,
        maxconn=5,
        host=pg_config['host'],
        port=pg_config['port'],
        database=pg_config['database'],
        user=pg_config['username'],
        password=pg_config['password']
    )
except psycopg2.Error as e:
    logging.error("Error creating PostgreSQL connection pool: %s", e)
    exit()

def process_postgres_data_in_batches(table_name, selected_columns, where_condition, batch_size=2000000):
    """Process PostgreSQL data in batches to avoid timeout issues with large datasets."""
    pg_conn = get_pg_connection()
    if pg_conn is None:
        logging.error("Error getting PostgreSQL connection. Skipping export for %s.", table_name)
        return None, 0, "Failed to connect to PostgreSQL"
    
    try:
        # Create an empty DataFrame to store all data
        all_data = pd.DataFrame()
        
        # First, try to get the total count of records to process
        count_query = f"SELECT COUNT(*) FROM {table_name} WHERE {where_condition}"
        #logging.info(f"Executing count query: {count_query}")
        
        total_records = 0
        try:
            with pg_conn.cursor() as cursor:
                cursor.execute(count_query)
                total_records = cursor.fetchone()[0]
            logging.info(f"Total records to process for {table_name}: {total_records}")
        except Exception as count_err:
            #logging.error(f"Error getting record count for {table_name}: {count_err}")
            #logging.info(f"Will proceed with fetching data without knowing total count")
            total_records = float('inf')  # Set to infinity to allow at least one iteration
        
        # Modify the approach - instead of using LIMIT/OFFSET which can cause issues,
        # we'll use a prepared statement approach with explicit type handling
        
        # Modify the query to avoid using LIMIT if that's causing issues
        batch_query = f"""
            SELECT {', '.join(selected_columns)} 
            FROM {table_name}
            WHERE {where_condition}
        """
        
        #logging.info(f"Executing query: {batch_query}")
        
        try:
            # Use pandas read_sql with explicit dtype=object to prevent type inference
            # This ensures all data is treated as strings
            data_frame = pd.read_sql(batch_query, pg_conn, dtype=object)
            
            # After fetching data, convert everything to strings explicitly
            for col in data_frame.columns:
                data_frame[col] = data_frame[col].astype(str)
                
                # Replace 'None' and 'nan' values with empty strings
                data_frame[col] = data_frame[col].replace(['None', 'nan', 'NaN', 'NaT'], '')
                
                # Clean numeric strings that might cause conversion issues
                data_frame[col] = data_frame[col].apply(lambda x: x.split('.')[0] if isinstance(x, str) and '.' in x and x.split('.')[1].replace('0', '') == '' else x)
            
            # Apply the standard transformations
            data_frame = data_frame.replace(',', '', regex=True)
            data_frame = data_frame.replace('"', '', regex=True)
            data_frame = data_frame.replace('\n', '', regex=True)
            data_frame = data_frame.replace('  ', ' ', regex=True)
            
            num_records_exported = len(data_frame)
            logging.info(f"Successfully retrieved {num_records_exported} records for {table_name}")
            
            return data_frame, num_records_exported, ""
            
        except Exception as e:
            #logging.error(f"Error executing main query for {table_name}: {e}")
            
            # Try an alternative approach with very explicit type handling
            #logging.info(f"Attempting alternative approach for {table_name}")
            
            try:
                # Create a cursor and execute the query
                with pg_conn.cursor() as cursor:
                    cursor.execute(batch_query)
                    columns = [desc[0] for desc in cursor.description]
                    
                    # Fetch all data as tuples and convert manually
                    rows = []
                    for row in cursor.fetchall():
                        # Convert each value to string explicitly
                        safe_row = []
                        for val in row:
                            if val is None:
                                safe_row.append('')
                            else:
                                # Handle decimal values explicitly
                                try:
                                    str_val = str(val)
                                    if '.' in str_val:
                                        parts = str_val.split('.')
                                        if parts[1].replace('0', '') == '':
                                            str_val = parts[0]
                                    safe_row.append(str_val)
                                except:
                                    safe_row.append(str(val))
                        rows.append(safe_row)
                    
                    # Create DataFrame from manually processed data
                    data_frame = pd.DataFrame(rows, columns=columns)
                    
                    # Apply the standard transformations
                    data_frame = data_frame.replace(',', '', regex=True)
                    data_frame = data_frame.replace('"', '', regex=True)
                    data_frame = data_frame.replace('\n', '', regex=True)
                    data_frame = data_frame.replace('  ', ' ', regex=True)
                    
                    num_records_exported = len(data_frame)
                    logging.info(f"Successfully retrieved {num_records_exported} records for {table_name} using alternative approach")
                    
                    return data_frame, num_records_exported, ""
                    
            except Exception as alt_err:
                logging.error(f"Alternative approach also failed for {table_name}: {alt_err}")
                return None, 0, str(alt_err)
    
    except Exception as e:
        logging.error("Error fetching data for %s from PostgreSQL: %s", table_name, e)
        return None, 0, str(e)
    finally:
        release_pg_connection(pg_conn)

# Function to get a connection from the pool
def get_pg_connection():
    try:
        conn = pg_conn_pool.getconn()
        return conn
    except Exception as e:
        logging.error("Error getting PostgreSQL connection from pool: %s", e)
        return None

# Function to release a connection back to the pool
def release_pg_connection(conn):
    try:
        pg_conn_pool.putconn(conn)
    except Exception as e:
        logging.error("Error releasing PostgreSQL connection back to pool: %s", e)

# Open the log.csv file to check for duplicate filenames
existing_filenames = set()
if os.path.exists('log.csv'):
    with open('log.csv', 'r', newline='') as log_file:
        log_reader = csv.reader(log_file)
        next(log_reader)  # Skip the header row
        for row in log_reader:
            existing_filenames.add(row[3])  # Assuming filename is in the 4th column (index 3)

# Read data mapping from data_mapping.xlsx
try:
    data_mapping = pd.read_excel('data_mapping.xlsx', sheet_name='Sheet1',dtype={'File_ext': str})  # Adjust sheet name if needed
except Exception as e:
    logging.error("Error reading data mapping from data_mapping.xlsx: %s", e)
    exit()

# Open the log.csv file in append mode and define the header
log_header = ["Table Name", "Error", "Number of Records Exported", "Exported Filename", "Export Datetime",
              "Time Taken", "Destination Table Name", "Number of Records Imported", "Error Message","backup_folder"]

with open('log.csv', 'a', newline='', buffering=1) as log_file:
    log_writer = csv.writer(log_file)

    # Write the header to the log file if it's a new file
    if log_file.tell() == 0:
        log_writer.writerow(log_header)

    # Get the current system day in dd format
    system_day = date.today().strftime('%d')
    logging.info("System Day: %s", system_day)

    # Loop through each row in the data mapping
    for index, row in data_mapping.iterrows():
        try:
            # Check if the specified day is a valid integer
            specified_day = int(row['Date'])
        except ValueError:
            logging.warning("Skipping row %d (Index %d): Invalid day format in data mapping.", index + 2, index)
            continue

        if specified_day != int(system_day):
            continue  # Skip rows with a different day

        table_name = row['source_table_name']
        selected_columns = row['source_columns'].split(',')
        where_condition = row['where_condition']
        destination_table = row['destination_table_name']
        destination_columns = row['destination_columns'].split(',')
        Date_Format = row['Date_Format']
        source_columns = row['source_columns'].split(',')
        data_type = row.get('type', '').lower()  # Get the data type and convert to lowercase
        skip=row['skip']
        PROCESS_DATE=row['Date_column']
        csv_file_name = f"{table_name}_{ datetime.now().strftime('%b-%Y')}.csv"
        File_name=row['File_name']
        File_name_Orignal=row['File_name_Orignal']
        if File_name_Orignal.lower() != 'no':
             if ' ' in File_name_Orignal:
               selected_columns.append(f'"{File_name_Orignal}"')
             else:
               selected_columns.append(File_name_Orignal)

  # Add the column name to the list

        if data_type == 'postgres':
            # Example PostgreSQL code for export and load
            if csv_file_name in existing_filenames:
                logging.info("Skipping processing for %s. This filename has already been processed.", csv_file_name)
            else:
                data_frame, num_records_exported, error_message = process_postgres_data_in_batches(
                            table_name, 
                            selected_columns, 
                            where_condition,
                            batch_size=2000000  # Adjust this based on your data size and memory constraints
                        )                

                # Get the current date and time for export
                export_datetime = datetime.now()
                export_datetime2 = export_datetime.strftime("%Y-%m-%d %H:%M:%S")
                # Calculate time taken for export
                start_time = datetime.now()
                time_taken = export_datetime - start_time
                
                if num_records_exported > 0:
                    # Export data to CSV with table name and date in the filename
                    try:
                        if File_name_Orignal.lower() != 'no':
                         special_value = data_frame[File_name_Orignal].iloc[1]
                        else:
                         special_value = csv_file_name
                        if special_value in existing_filenames:
                         logging.info("Skipping processing for %s. This filename has already been processed.", csv_file_name)
                         continue# Skip processing and move on to the next data item                        
                        # Specify the encoding as 'utf-8-sig' to handle non-ASCII characters like Arabic
                        csv_file_name = f"{table_name}_{export_datetime.strftime('%b-%Y')}.csv"
                        #for col in data_frame.columns:
                          #  data_frame[col] = data_frame[col].str[:4000]
                        data_frame = data_frame.astype(str)
                        ##
                        def remove_decimal(val):
                            if pd.isnull(val) or val == 'nan' or val == 'NaT' or val == 'None':
                                return ''
                            elif isinstance(val, str) and '.' in val:
                                try:
                                    # Try to convert to float first to handle decimal numbers properly
                                    float_val = float(val)
                                    # Then check if it's a whole number
                                    if float_val.is_integer():
                                        return str(int(float_val))
                                    return str(float_val)  # Return as string to avoid further type issues
                                except ValueError:
                                    return val
                            return val if not pd.isnull(val) else ''

                        # Apply the function to each element in the DataFrame
                        data_frame = data_frame.applymap(remove_decimal)

                        # Export to CSV
                        data_frame.to_csv(special_value, index=False, encoding='utf-8-sig', header=False, quotechar='"', na_rep='')
                        logging.info("Data exported for %s to %s", table_name, csv_file_name)
                    except Exception as e:
                        logging.error("Error exporting data for %s: %s", table_name, e)
                else:
                    logging.warning("No records to export for %s. Skipping export.", table_name)
                    continue
                if File_name_Orignal.lower() != 'no':
                   special_value = data_frame[File_name_Orignal].iloc[1]
                else:
                   special_value = csv_file_name
                # Check if the filename has already been processed
                if special_value in existing_filenames:
                    logging.info("Skipping processing for %s. This filename has already been processed.", csv_file_name)
                    continue  # Skip processing and move on to the next data item

                #
                # Generate CTL file
                # Generate CTL file content
                def excel_to_python_format(excel_format):
                    format_mapping = {
                        "yyyy-mm-dd": "%Y-%m-%d",
                        "dd-mm-yyyy": "%d-%m-%Y",
                        "dd-Mon-yyyy": "%d-%b-%Y"
                        # Add more mappings as needed
                    }
                    return format_mapping.get(excel_format, "%Y-%m-%d")  # Default to a standard format if not found

                python_date_format = excel_to_python_format(Date_Format) 

                # Assuming this is the name of your column
                # Determine what value to include in the LOAD DATA statement
                value_to_include = f'"{special_value}"' if special_value.lower() != 'no' else '"FILENAME" CONSTANT'
                formatted_date = export_datetime.strftime(python_date_format) if export_datetime else ''
                ctl_content = f"""
                OPTIONS (SKIP={int(skip)})
                LOAD DATA
                INFILE '{special_value}'
                INTO TABLE {destination_table}
                APPEND
                FIELDS TERMINATED BY ","
                OPTIONALLY ENCLOSED BY '"'
                TRAILING NULLCOLS
                (
                    {', '.join(['"' + col + '"' for col in destination_columns])},
                    "FILENAME" CONSTANT '{special_value}',
                    {PROCESS_DATE} CONSTANT '{formatted_date}'
                )
                """

                logging.debug("Generated CTL content for %s:\n%s", table_name, ctl_content)  # Debugging message

                # Modify this section to generate CTL file without date in the filename
                ctl_file_name = f"{destination_table}.ctl"
                backup_folder = row['Bkup_folder']
                current_date = datetime.now().strftime('%Y-%m-%d')
                if not os.path.exists(backup_folder):
                    try:
                        os.makedirs(backup_folder)
                        logging.info("Created backup folder: %s", backup_folder)
                    except Exception as e:
                        logging.error("Error creating backup folder: %s", e)
                ctl_file_path = os.path.join(backup_folder, ctl_file_name)
                with open(ctl_file_path, 'w') as ctl_file:
                    ctl_file.write(ctl_content)

                # Run SQL*Loader with the -silent option
                sqlldr_command = (
                    f"{oracle_config['oracle_home']}/bin/sqlldr "
                    f"{oracle_config['username']}/{oracle_config['password']}@{oracle_config['host']}:{oracle_config['port']}/{oracle_config['sid']} "
                    f"control={ctl_file_path} log={backup_folder}/{destination_table}_{current_date}.log silent=feedback"
                )

                logging.debug("Executing SQL*Loader command:\n%s", sqlldr_command)  # Debugging message

                return_code = os.system(sqlldr_command)

                # Parse the SQL*Loader log to extract the number of records loaded
                sqlldr_log_file = f"{backup_folder}/{destination_table}_{current_date}.log"
                num_records_imported = 0

                try:
                    with open(sqlldr_log_file, 'r') as log_file:
                        for line in log_file:
                            if "Rows successfully loaded" in line:
                                num_records_imported = int(line.split()[0])
                                break
                except Exception as e:
                    logging.error("Error parsing SQL*Loader log file: %s", e)

                # Log the number of records imported
                logging.info("Data loaded for %s from %s (%d records imported)", destination_table, special_value, num_records_imported)
                export_datetime = datetime.now()
                export_datetime2 = export_datetime.strftime("%Y-%m-%d %H:%M:%S")
                # Calculate time taken for export
                start_time = datetime.now()
                time_taken = export_datetime - start_time
                # Update the log_record to include the correct number of imported records
                log_record = [
                    table_name,  # Table Name
                    "No" if num_records_exported > 0 and error_message == "" else "Yes",  # Error
                    num_records_exported,  # Number of Records Exported (from the original file)
                    special_value,  # Exported Filename
                    export_datetime2,  # Export Datetime
                    time_taken.total_seconds(),  # Time Taken in seconds
                    destination_table,  # Destination Table Name
                    num_records_imported,  # Number of Records Imported (into Oracle)
                    error_message if error_message else "",
                    backup_folder,
                    # Error Message
                ]
                log_writer.writerow(log_record)
               

# Later in your code, when you need to log again


                # Define the backup folder based on the data mapping
                backup_folder = row['Bkup_folder']

                # Create the backup folder if it doesn't exist
                if not os.path.exists(backup_folder):
                    try:
                        os.makedirs(backup_folder)
                        logging.info("Created backup folder: %s", backup_folder)
                    except Exception as e:
                        logging.error("Error creating backup folder: %s", e)

                # Move the exported file to the backup folder
                if os.path.exists(backup_folder):
                    try:
                        move_file2(special_value, os.path.join(backup_folder, special_value))
                    except Exception as e:
                        # This will log an error only if the move_file2 function raises an exception
                        logging.error("Error moving %s to backup folder %s: %s", special_value, backup_folder, e)
                else:
                    logging.warning("Backup folder does not exist: %s. File not moved.", backup_folder)

        elif data_type == 'excel':
            # Excel processing code (unchanged, except for the CSV conversion part)
            source_directory = row['source_table_name']  # Assuming 'source_table_name' is the source directory
            files = [f for f in os.listdir(source_directory) if f.endswith(('.xls', '.xlsx'))]
            

            for excel_file_name in files:
                current_date = datetime.now().strftime('%Y-%m-%d')
                excel_file_path = os.path.join(source_directory, excel_file_name)

                csv_file_name = f"{os.path.splitext(excel_file_name)[0]}.csv"
                backup_folder = row['Bkup_folder']
                csv_file_path = os.path.join(backup_folder, csv_file_name)
                if not os.path.exists(backup_folder):
                    try:
                        os.makedirs(backup_folder)
                        logging.info("Created backup folder: %s", backup_folder)
                    except Exception as e:
                        logging.error("Error creating backup folder: %s", e)

                if csv_file_name in existing_filenames:
                    logging.info("Skipping %s. This file has already been processed.", csv_file_name)
                    continue
                if excel_file_name in existing_filenames:
                                    logging.info("Skipping %s. This file has already been processed.", excel_file_name)
                                    continue

                try:
                    df = pd.read_excel(excel_file_path,engine='openpyxl')
                    df = df.replace(',','', regex=True)
                    df = df.replace('"','', regex=True)
                   # df = df.replace('/\n/','', regex=True)
                    df = df.replace('\n','', regex=True)
                    df = df.replace('  ',' ', regex=True)
                   # pattern = r'[^a-zA-Z0-9\u0600-\u06FF\:\[\]\-\_\. ]'
                   # df = df.replace(pattern, '', regex=True)
                    header=source_columns
                    df = df.applymap(check_and_truncate)
                    df.to_csv(csv_file_path,sep=',',index=False,  quotechar='"',columns=header)
                    logging.info("Converted %s to CSV format.", excel_file_name)
                except Exception as e:
                    logging.error("Error converting %s to CSV: %s", excel_file_name, e)
                    continue

                try:
                    data_frame = pd.read_csv(csv_file_path)
                    num_records_exported = len(data_frame)
                except Exception as e:
                    logging.error("Error reading %s: %s", csv_file_name, e)
                    continue

                # Generate the CTL file content (similar to the Excel processing code)
                ctl_content = f"""
                OPTIONS (SKIP={int(skip)})
                LOAD DATA
                INFILE '{csv_file_path}'
                INTO TABLE {destination_table}
                APPEND
                FIELDS TERMINATED BY ","
                OPTIONALLY ENCLOSED BY '"'
                TRAILING NULLCOLS
                (
                    {', '.join(['"' + col + '"' for col in destination_columns])},
                    "FILENAME" CONSTANT '{csv_file_name}',
                    {PROCESS_DATE} CONSTANT '{current_date}'
                )
                """
                # Create a CTL file with a unique name based on the data file
                ctl_file_name = f"{destination_table}_{current_date}.ctl"
                backup_folder = row['Bkup_folder']
                ctl_file_path = os.path.join(backup_folder, ctl_file_name)

                with open(ctl_file_path, 'w') as ctl_file:
                    ctl_file.write(ctl_content)

                # Run SQL*Loader with the -silent option
                sqlldr_command = (
                    f"{oracle_config['oracle_home']}/bin/sqlldr "
                    f"{oracle_config['username']}/{oracle_config['password']}@{oracle_config['host']}:{oracle_config['port']}/{oracle_config['sid']} "
                    f"control={ctl_file_path} log={backup_folder}/{destination_table}_{current_date}.log silent=feedback"
                )

                logging.debug("Executing SQL*Loader command:\n%s", sqlldr_command)  # Debugging message

                return_code = os.system(sqlldr_command)

                # Parse the SQL*Loader log to extract the number of records loaded
                sqlldr_log_file = f"{backup_folder}/{destination_table}_{current_date}.log"
                num_records_imported = 0

                try:
                    with open(sqlldr_log_file, 'r') as log_file:
                        for line in log_file:
                            if "Rows successfully loaded" in line:
                                num_records_imported = int(line.split()[0])
                                break
                except Exception as e:
                    logging.error("Error parsing SQL*Loader log file: %s", e)

                # Log the number of records imported
                logging.info("Data loaded for %s from %s (%d records imported)", destination_table, csv_file_name, num_records_imported)
                export_datetime = datetime.now()
                export_datetime2 = export_datetime.strftime("%Y-%m-%d %H:%M:%S")
                    # Calculate time taken for export
                start_time = datetime.now()
                time_taken = export_datetime - start_time
                # Update the log_record to include the correct number of imported records
                error_message = ""
                log_record = [
                    table_name,  # Table Name
                    "No" if num_records_exported > 0 and error_message == "" else "Yes",  # Error
                    num_records_exported,  # Number of Records Exported (from the original file)
                    csv_file_name,  # Exported Filename
                    export_datetime2,  # Export Datetime
                    time_taken.total_seconds(),  # Time Taken in seconds
                    destination_table,  # Destination Table Name
                    num_records_imported,  # Number of Records Imported (into Oracle)
                    error_message if error_message else "",  # Error Message
                    backup_folder,
                ]

                log_writer.writerow(log_record)

                # Define the backup folder based on the data mapping
                backup_folder = row['Bkup_folder']

                # Create the backup folder if it doesn't exist
                if not os.path.exists(backup_folder):
                    try:
                        os.makedirs(backup_folder)
                        logging.info("Created backup folder: %s", backup_folder)
                    except Exception as e:
                        logging.error("Error creating backup folder: %s", e)

                # Move the exported file to the backup folder
                if os.path.exists(backup_folder):
                    if not move_file(excel_file_path, os.path.join(backup_folder, excel_file_name)):
                        logging.error("Error moving %s to backup folder: %s", excel_file_name, backup_folder)
                else:
                    logging.warning("Backup folder does not exist: %s. File not moved.", backup_folder)
                    
        elif data_type == 'csv':                     
            # CSV processing code (without the need for conversion)
            source_directory = row['source_table_name']  # Assuming 'source_table_name' is the source directory
            file_ext=str(row['File_ext'])
            files = []
            if pd.isna(file_ext) or file_ext == 'all':
                # If file_ext is NaN or empty, select all files that end with '.csv'
                files = [f for f in os.listdir(source_directory) if f.endswith('.csv')]
            elif isinstance(file_ext, str):
                # If file_ext is a non-empty string, filter files based on 'file_ext'
                files = [f for f in os.listdir(source_directory) if f.endswith('.csv') and file_ext in f]
            else:
                # Handle unexpected file_ext values (optional, based on your use case)
                files = [] 
            for csv_file_name in files:
             try:
                    backup_folder = row['Bkup_folder']
                    n_skip = int(row['skip'])
                    if not os.path.exists(backup_folder):
                       os.makedirs(backup_folder)
                    current_date = datetime.now().strftime('%Y-%m-%d')
                    csv_file_path = os.path.join(source_directory, csv_file_name)
                    backup_folder = row['Bkup_folder']
                    csv_file_path2 = os.path.join(backup_folder, csv_file_name)
                    match = re.search(r'[A-Za-z]{3}-\d{4}', csv_file_name)
                    date_part = match.group(0) if match else ''
                    File_name=row['File_name']
                    if  pd.isna(File_name) or File_name == '':
                        final_file_name = "updated_" + csv_file_name.replace(' ', '_')
                    else:
                        final_file_name = File_name.replace(' ', '_') + "_" + date_part + ".csv"

                    final_csv_file_path = os.path.join(backup_folder, final_file_name.replace(' ', '_'))
                   # final_csv_file_path = final_csv_file_path.replace(' ', '_')
                    # Check if the directory exists and create it if it doesn't
                    csv_dir = os.path.dirname(csv_file_path)
                    if not os.path.exists(csv_dir):
                       os.makedirs(csv_dir)

                    # Check if the filename has already been processed
                    if csv_file_name in existing_filenames:
                        logging.info("Skipping processing for %s. This filename has already been processed.", csv_file_name)
                        continue  # Skip processing and move on to the next data item
                    # Count the number of records in the CSV file
                    data_frame = pd.read_csv(csv_file_path,encoding='iso-8859-1',dtype=str,skiprows=n_skip)
                    #data_frame.columns = [col.replace('\ufeff', '') for col in data_frame.columns]
                    num_records_exported = len(data_frame)
                    data_frame = data_frame.replace(',','', regex=True)
                    data_frame = data_frame.replace('"','', regex=True)
                    #data_frame = data_frame.replace('/\n','', regex=True)
                    data_frame = data_frame.replace('\n','', regex=True)
                    data_frame = data_frame.replace('  ',' ', regex=True)
                    #pattern = r'[^a-zA-Z0-9\u0600-\u06FF\:\[\]\-\_\. ]'
                    #data_frame = data_frame.replace(pattern, '', regex=True)
                    header=source_columns
                    #data_frame = data_frame.applymap(check_and_truncate) 
                    data_frame = data_frame[header]
                    #data_frame_to_save = data_frame.iloc[n_skip:]
                    data_frame_to_save = data_frame
                    data_frame_to_save.to_csv(final_csv_file_path, sep=',', index=False, quotechar='"', columns=header)
                    # Generate the CTL file content
                    #OPTIONS (SKIP=1)
                    ctl_content = f"""
                    OPTIONS (SKIP=1)
                    LOAD DATA
                    INFILE '{final_csv_file_path}'
                    INTO TABLE {destination_table}
                    APPEND
                    FIELDS TERMINATED BY ","
                    OPTIONALLY ENCLOSED BY '"'
                    TRAILING NULLCOLS
                    (
                        {', '.join(['"' + col + '"' for col in destination_columns])},
                        "FILENAME" CONSTANT '{final_file_name}',
                        {PROCESS_DATE} CONSTANT '{current_date}'
                    )
                    """
                    # Create a CTL file with a unique name based on the data file
                    #BADFILE '{csv_file_path}'
                    ctl_file_name = f"{destination_table}_{current_date}.ctl"
                    #backup_folder = row['Bkup_folder']
                    #if not os.path.exists(backup_folder):
                    #   os.makedirs(backup_folder)
                    ctl_file_path = os.path.join(backup_folder, ctl_file_name)

                    with open(ctl_file_path, 'w') as ctl_file:
                        ctl_file.write(ctl_content)

                    # Run SQL*Loader with the -silent option
                    sqlldr_command = (
                        f"{oracle_config['oracle_home']}/bin/sqlldr "
                        f"{oracle_config['username']}/{oracle_config['password']}@{oracle_config['host']}:{oracle_config['port']}/{oracle_config['sid']} "
                        f"control={ctl_file_path} log={backup_folder}/{destination_table}_{current_date}.log silent=feedback"
                    )

                    logging.debug("Executing SQL*Loader command:\n%s", sqlldr_command)  # Debugging message

                    return_code = os.system(sqlldr_command)

                    # Parse the SQL*Loader log to extract the number of records loaded
                    sqlldr_log_file = f"{backup_folder}/{destination_table}_{current_date}.log"
                    num_records_imported = 0
                    error_message = ""  # Define error_message here
                    try:
                        with open(sqlldr_log_file, 'r') as log_file:
                            for line in log_file:
                                if "Rows successfully loaded" in line:
                                    num_records_imported = int(line.split()[0])
                                    break
                                elif "Record 1: Rejected - Error on table" in line:
                                    error_message = line.strip()  # Capture the error message
                    except Exception as e:
                        logging.error("Error parsing SQL*Loader log file: %s", e)

                    # Log the number of records imported
                    logging.info("Data loaded for %s from %s (%d records imported)", destination_table, csv_file_name, num_records_imported)
                    export_datetime = datetime.now()
                    export_datetime2 = export_datetime.strftime("%Y-%m-%d %H:%M:%S")
                        # Calculate time taken for export
                    start_time = datetime.now()
                    time_taken = export_datetime - start_time
                    # Update the log_record to include the correct number of imported records
                    log_record = [
                        table_name,  # Table Name
                        "No" if num_records_exported > 0 and error_message == "" else "Yes",  # Error
                        num_records_exported,  # Number of Records Exported (from the original file)
                        csv_file_name,  # Exported Filename
                        export_datetime2,  # Export Datetime
                        time_taken.total_seconds(),  # Time Taken in seconds
                        destination_table,  # Destination Table Name
                        num_records_imported,  # Number of Records Imported (into Oracle)
                        error_message if error_message else "",  # Error Message
                        backup_folder,
                    ]

                    log_writer.writerow(log_record)

                    # Define the backup folder based on the data mapping
                    backup_folder = row['Bkup_folder']

                    # Create the backup folder if it doesn't exist
                    if not os.path.exists(backup_folder):
                        try:
                            os.makedirs(backup_folder)
                            logging.info("Created backup folder: %s", backup_folder)
                        except Exception as e:
                            logging.error("Error creating backup folder: %s", e)

                    # Move the exported file to the backup folder
                    if os.path.exists(backup_folder):
                        if not move_file(csv_file_path, os.path.join(backup_folder, csv_file_name)):
                            logging.error("Error moving %s to backup folder: %s", csv_file_name, backup_folder)
                    else:
                        logging.warning("Backup folder does not exist: %s. File not moved.", backup_folder)
             except Exception as e:
                            logging.error("Skipped error: %s, File: %s, Exception: %s", e, csv_file_name, str(e))
        else:
            logging.warning("Skipping row %d (Index %d): Invalid data type in data mapping.", index + 2, index)

# Close the PostgreSQL connection pool
pg_conn_pool.closeall()

logging.info("Data export and load process completed.")