-- ============================================================
-- Revenue Assurance Platform - Legacy Data Migration
-- Generated: 2026-02-17T07:44:31.057908+00:00
-- ============================================================
-- This migration loads ALL configurations from legacy scripts:
--
-- Source Files Migrated:
--   1. data_mapping.xlsx (Sheet1: 198 rows, Skip: 20 rows)
--   2. sequence_updated3.xlsx (485 materialized views)
--   3. manage_jobs.py (3 job configs + paths)
--   4. extract_tables_to_excel2.py (export config + credentials)
--   5. Refresh_withkill.py (refresh config + timeout settings)
--   6. treevFinalv3.py (dependency scan config)
--
-- Hardcoded Credentials Removed:
--   - Oracle: recon_prd/recon123@incor.solutions.com.sa -> ORACLE_PASSWORD env var
--   - PostgreSQL: config.json credentials -> PG_SOURCE_PASSWORD env var
--   - ORACLE_HOME: /home/oracle/app/product/12.2.0/client_1 -> ORACLE_HOME env var
--
-- Legacy Paths Preserved (in config JSON for reference):
--   - /u01/RA_OPS/Test_New_Loader/Final/ (loader work dir)
--   - /u01/RA_OPS/ (refresh/export work dir)
--   - /u01/RA_OPS/Export_BACKUP/ (export output)
--   - /home/sdev/ROOT/AutoExport (export target)
--   - /home/sdev/ROOT2/Extracts (export target)
-- ============================================================

BEGIN;


-- ============================================================
-- CONNECTION PROFILES (Replace hardcoded credentials)
-- ============================================================
-- Legacy: config.json -> postgresql section
-- Legacy: oracle_connection_string = "recon_prd/recon123@incor.solutions.com.sa"
-- Now: credentials stored in environment variables, NOT in database

INSERT INTO ra_meta.connection_profiles (id, name, db_type, host, port, database_name, username, password_env_var, extra_params, is_active)
VALUES
    -- PostgreSQL source (from config.json used by Loader_full_Newv2.py)
    ('638ae819-becd-4ec0-bd79-358da43c35c1', 'PostgreSQL - Cloud Marketplace', 'postgresql',
     'SET_VIA_ENV', 5432, 'SET_VIA_ENV', 'SET_VIA_ENV',
     'PG_SOURCE_PASSWORD',
     '{"description": "PostgreSQL source for marketplace/cloud data tables", "legacy_config": "config.json -> postgresql"}',
     TRUE),

    -- Oracle target (data warehouse - used by ALL scripts)
    ('6b6159b6-1269-4396-9858-0bf0f5c5c04b', 'Oracle - Revenue Assurance DWH', 'oracle',
     'incor.solutions.com.sa', 1521, 'ORCL', 'recon_prd',
     'ORACLE_PASSWORD',
     '{"description": "Oracle DWH for revenue assurance", "legacy_connection": "recon_prd@incor.solutions.com.sa", "oracle_home": "/home/oracle/app/product/12.2.0/client_1"}',
     TRUE),

    -- Oracle connection for exports (extract_tables_to_excel2.py)
    ('27cf97fa-070e-4628-b2b7-5a21f0b24f91', 'Oracle - Export Source', 'oracle',
     'incor.solutions.com.sa', 1521, 'ORCL', 'recon_prd',
     'ORACLE_PASSWORD',
     '{"description": "Oracle source for table exports and historical snapshots", "legacy_script": "extract_tables_to_excel2.py", "export_targets": ["/home/sdev/ROOT/AutoExport", "/home/sdev/ROOT2/Extracts"]}',
     TRUE)
ON CONFLICT DO NOTHING;



-- ============================================================
-- TABLE CONFIGURATIONS (Migrated from data_mapping.xlsx)
-- 198 active mappings from Sheet1 + 20 from Skip sheet
-- ============================================================

INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'e9e3b0b3-9bc2-47d7-b98e-6c93cc453138',
    'A_PRICE_LIST_postgres_0',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_pricelist',
    'id,slug,is_active,cloned_from_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_service_management_pricelist)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_PRICE_LIST',
    'ID,SLUG,Is Active,Cloned From ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'd49f4ac4-4bb6-4e80-8cf3-5a9c0688e131',
    'A_ACCOUNTS_postgres_1',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_accounts_account',
    'id,created,modified,name,customer_id_type,customer_id,customer_number,mobile_no,land_line,email,website,country,city,currency,status,status_reason,trial_status,district,building_number,street_name,postal_code,additional_number,address1,address2,region,zip_code,security_classification_level,trial_suspension_date,is_testing,site_id,super_admin_role_id,suspension_date,name_ar',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_accounts_account)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_ACCOUNTS',
    'ID,CREATED,MODIFIED,NAME,Customer ID Type,Customer ID,Customer Number,Mobile No,Land Line,EMAIL,WEBSITE,COUNTRY,CITY,CURRENCY,STATUS,Status Reason,Trial Status,DISTRICT,Building Number,Street Name,Postal Code,Additional Number,Add Res S1,Add Res S2,REGION,Zip Code,Security Classification Level,Trial Suspension Date,Is Testing,Site ID,Super Admin Role ID,Suspension Date,Name Ar',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '9f969d2d-93bf-41b2-904d-85789505c75b',
    'A_CUSTOMERS_DEAL_CUSTOM_SERVICE_postgres_2',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_customers_dealcustomservice',
    'id,created,modified,is_auto,project_number,deal_id,service_id,duration',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_customers_dealcustomservice)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_CUSTOMERS_DEAL_CUSTOM_SERVICE',
    'ID,CREATED,MODIFIED,Is Auto,Project Number,Deal ID,Service ID,DURATION',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '7c338615-4d86-44c5-afb1-2d3906cf4779',
    'a_deals_postgres_3',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_customers_deal',
    'id,created,modified,min_amount,max_amount,status,expiry_date,start_date,end_date,renew,type,catalog_updated,accepted_by_id,account_manager_id,agreement_id,cloned_from_id,customer_id,price_list_id,special_offer_id,duration,po_number,version,op_number,created_by_id,source_file',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_customers_deal)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'a_deals',
    'ID,CREATED,MODIFIED,Min Amount,Max Amount,STATUS,Expiry Date,Start Date,End Date,RENEW,Type,Catalog Updated,Accepted By ID,Account Manager ID,Agreement ID,Cloned From ID,Customer ID,Price List ID,Special Offer ID,DURATION,Po Number,VERSION,Op Number,Created By ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '6ed15c76-9f2e-4248-a1e8-3a4c7c293687',
    'A_FLAVOR_TRANSLATION_postgres_4',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_flavor_translation',
    'id,language_code,name,description,master_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_service_management_flavor_translation)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_FLAVOR_TRANSLATION',
    'ID,Language Code,NAME,DESCRIPTION,Master ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '000cc652-bc42-43a2-9f1a-0748fd821f07',
    'A_KILLBILL_INVOICES_ITEMS_postgres_5',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'invoice_items_kb',
    'record_id,id,type,invoice_id,account_id,bundle_id,subscription_id,description,plan_name,phase_name,usage_name,start_date,end_date,amount,rate,currency,linked_item_id,created_by,created_date,account_record_id,tenant_record_id,child_account_id,quantity,product_name,catalog_effective_date',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from invoice_items_kb)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_KILLBILL_INVOICES_ITEMS',
    'RECORD_ID,ID,type,INVOICE_ID,ACCOUNT_ID,BUNDLE_ID,SUBSCRIPTION_ID,DESCRIPTION,PLAN_NAME,PHASE_NAME,USAGE_NAME,START_DATE,END_DATE,AMOUNT,RATE,CURRENCY,LINKED_ITEM_ID,CREATED_BY,CREATED_DATE,ACCOUNT_RECORD_ID,TENANT_RECORD_ID,CHILD_ACCOUNT_ID,QUANTITY,PRODUCT_NAME,CATALOG_EFFECTIVE_DATE',
    'dd-mm-yyyy',
    'PROCCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'a21e0192-7de4-433d-bfec-0fec2a71b077',
    'a_phase_postgres_6',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_phase',
    'id,created,modified,type,duration_unit,duration_number,billing_period,commitment,cloned_from_id,plan_price_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_service_management_phase)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'a_phase',
    'ID,CREATED,MODIFIED,Type,Duration Unit,Duration Number,Billing Period,COMMITMENT,Cloned From ID,Plan Price ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '46d5c3a8-a63a-4ac1-8405-6774e82d48cf',
    'A_PHASE_PRICE_postgres_7',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_phaseprice',
    'id,type,currency,value,cloned_from_id,phase_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_service_management_phaseprice)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_PHASE_PRICE',
    'ID,Type,CURRENCY,VALUE,Cloned From ID,Phase ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '3078afdc-93be-4091-949c-9206f6af5752',
    'PRD_GRANITE_csv_8',
    'csv',
    NULL,
    '/home/sdev/ROOT/Granite/DIA',
    'S.No.,Circuit Name,Order Number,Parent Order No,Bandwidth,Category,Status,Order Stage,Order Stage Start Date,Track Order,Department,Sector,Customer Name,Fict Billing No,Customer Ref,Svc Priority,Isp Name,Account Manager,Projectid,A Site Name,A City,A Side Clli,A District,A Site Number,Z Site Name,Z Side Clli,Z City,Z District,Z Site Number,Ordered,Completed,Installed,In Service,Customer Id,Icms No,A Side Ref Tel Number,Z Side Ref Tel Number,Sam Info,Access Technology Z,Customer Sam Info,Access Technology A,Mrs Installed,Used Access Technology A,Used Access Technology Z,Ntu Provided Loc A,Ntu Provided Loc B,Ntu Model Loc A,Ntu Model Loc B',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_GRANITE',
    'S_NO,CIRCUIT_NAME,ORDER_NUMBER,PARENT_ORDER_NO,BANDWIDTH,CATEGORY,STATUS,ORDER_STAGE,ORDER_STAGE_START_DATE,TRACK_ORDER,DEPARTMENT,SECTOR,CUSTOMER_NAME,FICT_BILLING_NO,CUSTOMER_REF,SVC_PRIORITY,ISP_NAME,ACCOUNT_MANAGER,PROJECTID,A_SITE_NAME,A_CITY,A_SIDE_CLLI,A_DISTRICT,A_SITE_NUMBER,Z_SITE_NAME,Z_SIDE_CLLI,Z_CITY,Z_DISTRICT,Z_SITE_NUMBER,ORDERED,COMPLETED,INSTALLED,IN_SERVICE,CUSTOMER_ID,ICMS_NO,A_SIDE_REF_TEL_NUMBER,Z_SIDE_REF_TEL_NUMBER,SAM_INFO,ACCESS_TECHNOLOGY_Z,CUSTOMER_SAM_INFO,ACCESS_TECHNOLOGY_A,MRS_INSTALLED,USED_ACCESS_TECHNOLOGY_A,USED_ACCESS_TECHNOLOGY_Z,NTU_PROVIDED_LOC_A,NTU_PROVIDED_LOC_B,NTU_MODEL_LOC_A,NTU_MODEL_LOC_B',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    'Granite',
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/GraniteDIA',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_pattern": "Granite", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'b0c4735d-af24-4ddf-9c13-e034239aaf2c',
    'PRD_GRANITE_csv_9',
    'csv',
    NULL,
    '/home/sdev/ROOT/Granite/VSAT',
    'S.No.,Circuit Name,Order Number,Parent Order No,Bandwidth,Category,Status,Order Stage,Order Stage Start Date,Track Order,Department,Sector,Customer Name,Fict Billing No,Customer Ref,Svc Priority,Isp Name,Account Manager,Projectid,A Site Name,A City,A Side Clli,A District,A Site Number,Z Site Name,Z Side Clli,Z City,Z District,Z Site Number,Ordered,Completed,Installed,In Service,Customer Id,Icms No,A Side Ref Tel Number,Z Side Ref Tel Number,Sam Info,Access Technology Z,Customer Sam Info,Access Technology A,Mrs Installed,Used Access Technology A,Used Access Technology Z,Ntu Provided Loc A,Ntu Provided Loc B,Ntu Model Loc A,Ntu Model Loc B',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_GRANITE',
    'S_NO,CIRCUIT_NAME,ORDER_NUMBER,PARENT_ORDER_NO,BANDWIDTH,CATEGORY,STATUS,ORDER_STAGE,ORDER_STAGE_START_DATE,TRACK_ORDER,DEPARTMENT,SECTOR,CUSTOMER_NAME,FICT_BILLING_NO,CUSTOMER_REF,SVC_PRIORITY,ISP_NAME,ACCOUNT_MANAGER,PROJECTID,A_SITE_NAME,A_CITY,A_SIDE_CLLI,A_DISTRICT,A_SITE_NUMBER,Z_SITE_NAME,Z_SIDE_CLLI,Z_CITY,Z_DISTRICT,Z_SITE_NUMBER,ORDERED,COMPLETED,INSTALLED,IN_SERVICE,CUSTOMER_ID,ICMS_NO,A_SIDE_REF_TEL_NUMBER,Z_SIDE_REF_TEL_NUMBER,SAM_INFO,ACCESS_TECHNOLOGY_Z,CUSTOMER_SAM_INFO,ACCESS_TECHNOLOGY_A,MRS_INSTALLED,USED_ACCESS_TECHNOLOGY_A,USED_ACCESS_TECHNOLOGY_Z,NTU_PROVIDED_LOC_A,NTU_PROVIDED_LOC_B,NTU_MODEL_LOC_A,NTU_MODEL_LOC_B',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    'Granite',
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/GraniteVSAT',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_pattern": "Granite", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'abf95a43-aaf9-4c45-846c-1a9eb0d4f85d',
    'PRD_GRANITE_MS_csv_10',
    'csv',
    NULL,
    '/home/sdev/ROOT/Granite/MS',
    'S.No.,Circuit Name,Order Number,Parent Order No,Bandwidth,Category,Status,Order Stage,Order Stage Start Date,Track Order,Department,Sector,Customer Name,Fict Billing No,Customer Ref,Svc Priority,Isp Name,Account Manager,Projectid,A Site Name,A City,A Side Clli,A District,A Site Number,Z Site Name,Z Side Clli,Z City,Z District,Z Site Number,Ordered,Completed,Installed,In Service,Customer Id,Icms No,A Side Ref Tel Number,Z Side Ref Tel Number,Sam Info,Access Technology Z,Customer Sam Info,Access Technology A,Mrs Installed,Used Access Technology A,Used Access Technology Z,Ntu Provided Loc A,Ntu Provided Loc B,Ntu Model Loc A,Ntu Model Loc B',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_GRANITE_MS',
    'S_NO,CIRCUIT_NAME,ORDER_NUMBER,PARENT_ORDER_NO,BANDWIDTH,CATEGORY,STATUS,ORDER_STAGE,ORDER_STAGE_START_DATE,TRACK_ORDER,DEPARTMENT,SECTOR,CUSTOMER_NAME,FICT_BILLING_NO,CUSTOMER_REF,SVC_PRIORITY,ISP_NAME,ACCOUNT_MANAGER,PROJECTID,A_SITE_NAME,A_CITY,A_SIDE_CLLI,A_DISTRICT,A_SITE_NUMBER,Z_SITE_NAME,Z_SIDE_CLLI,Z_CITY,Z_DISTRICT,Z_SITE_NUMBER,ORDERED,COMPLETED,INSTALLED,IN_SERVICE,CUSTOMER_ID,ICMS_NO,A_SIDE_REF_TEL_NUMBER,Z_SIDE_REF_TEL_NUMBER,SAM_INFO,ACCESS_TECHNOLOGY_Z,CUSTOMER_SAM_INFO,ACCESS_TECHNOLOGY_A,MRS_INSTALLED,USED_ACCESS_TECHNOLOGY_A,USED_ACCESS_TECHNOLOGY_Z,NTU_PROVIDED_LOC_A,NTU_PROVIDED_LOC_B,NTU_MODEL_LOC_A,NTU_MODEL_LOC_B',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    'MS',
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/GraniteMS',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_pattern": "MS", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'f98447f2-a52d-45a5-b3e3-0a90223eb48a',
    'PRD_PROJECTS_FINANCIAL_L1_postgres_11',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'ERP_FC_Data_Dashboard',
    'PROJECT_NUMBER,
PROJECT_NAME,
PROJECT_STATUS_NAME PROJECT_TRACK_STATUS,
closing_status PROJECT_STATUS,
PROJECT_MANAGER,
DIRCTOR_NAME DIRECTOR,
VP_name VICE_PRESIDENT,
ACCOUNT_MANAGER,
SALES_CLASS,
BU,
STCS_FCPROJECT_TYPE STCS_FC_PROJECT_TYPE,
MICROSOFT_LICENSES MICROSOFT_LICENSES,
CUSTOMER_SEGMENT,
CUSTOMER_SEGMENT_CODE,
CHANNEL_SEGMENT,
CHANNEL_SEGMENT_CODE,
to_char(to_date(PROJECT_START_DATE,''mm/dd/yyyy hh24:mi:ss''),''mm/dd/yyyy hh24:mi:ss'') PROJECT_START_DATE,
to_char(to_date(PROJECT_END_DATE,''mm/dd/yyyy hh24:mi:ss''),''mm/dd/yyyy hh24:mi:ss'') PROJECT_END_DATE,
CUSTOMER_NAME,
CUSTOMER_ACCOUNT,
SECTOR,
CUSTOMER_CLASS_CODE,
EBU_CUSTOMER_SEGMENT,
EBU_SEGMENT_CODE,
CRM_NUMBER,
PO_NUMBER,
to_char(to_date(PO_START_DATE,''mm/dd/yyyy hh24:mi:ss''),''mm/dd/yyyy hh24:mi:ss'')PO_START_DATE,
to_char(to_date(PO_EXPIRATION_DATE,''mm/dd/yyyy hh24:mi:ss''),''mm/dd/yyyy hh24:mi:ss'')PO_EXPIRATION_DATE,
PARENT_PROJECT_NUMBER,
RLA_YES_NO,
BILLING_TYPE,
CUSTOMER_CLASSIFICATION,
to_char(to_date(LATEST_BASELINED_DATE,''mm/dd/yyyy hh24:mi:ss''),''mm/dd/yyyy hh24:mi:ss'')LATEST_BASELINED_DATE,
LAST_CHANGE_REASON,
RLA,
BUDGETED_REVENUE_CURRENT,
BUDGETED_COST_CURRENT,
BUDGETED_COST_ORIGINAL,
BUDGETED_REVENUE_ORIGINAL,
MARGIN_PER MARGIN_PERCENTAGE,
ORIGINAL_MARGIN_PER ORIGINAL_MARGIN_PERCENTAGE,
BILLING_SELECT_DATE,
BILLING_YTD,
BILLING_BEFORE_DATE,
REVENUE_SELECT_DATE,
REVENUE_YTD,
REVENUE_BEFORE_DATE,
ADJUSTED_REVENUE,
ADJUSTED_REVENUE_YTD,
ADJUSTED_REVENUE_SELECTED_DT,
ADJUSTED_BILLED,
ADJUSTED_BILLED_YTD,
ADJUSTED_BILLED_SELECTED_DT,
STC_EXCULDED_AMT,
COGS_SELECT_DATE,
COGS_YTD,
COGS_BEFORE_DATE,
ACTUAL_BILLING_PTD TOTAL_ACTUAL_BILLING,
TOTAL_BILLING total_billing_PTD,
TOTAL_REVENUE TOTAL_REVENUE_PTD,
TOTAL_COGS TOTAL_COGS_PTD,
REVENUE_BALANCE,
COST_BALANCE,
UNEARNED,
UNBILLED,
UNEARNED_SELECTED_DATES,
UNBILLED_SELECTED_DATES,
BILLING_BALANCE,
BILLING_YTD+ADJUSTED_BILLED_SELECTED_DT ACTUAL_BILLING_YTD',
    'to_Date("DWH_RUN_DATE",''yyyy-mm-dd'') = (
 select
  max(to_Date("DWH_RUN_DATE",''yyyy-mm-dd''))
 from
  ERP_FC_Data_Dashboard)
  and "PL_END_DATE" >= DATE_TRUNC(''MONTH'', CURRENT_DATE) - INTERVAL ''1 month''
   AND "PL_END_DATE" < DATE_TRUNC(''MONTH'', CURRENT_DATE)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_PROJECTS_FINANCIAL_L1',
    'PROJECT_NUMBER,PROJECT_NAME,PROJECT_TRACK_STATUS,PROJECT_STATUS,PROJECT_MANAGER,DIRECTOR,VICE_PRESIDENT,ACCOUNT_MANAGER,SALES_CLASS,BU,STCS_FC_PROJECT_TYPE,MICROSOFT_LICENSES,CUSTOMER_SEGMENT,CUSTOMER_SEGMENT_CODE,CHANNEL_SEGMENT,CHANNEL_SEGMENT_CODE,PROJECT_START_DATE,PROJECT_END_DATE,CUSTOMER_NAME,CUSTOMER_ACCOUNT,SECTOR,CUSTOMER_CLASS_CODE,EBU_CUSTOMER_SEGMENT,EBU_SEGMENT_CODE,CRM_NUMBER,PO_NUMBER,PO_START_DATE,PO_EXPIRATION_DATE,PARENT_PROJECT_NUMBER,RLA_YES_NO,BILLING_TYPE,CUSTOMER_CLASSIFICATION,LATEST_BASELINED_DATE,LAST_CHANGE_REASON,RLA,BUDGETED_REVENUE_CURRENT,BUDGETED_COST_CURRENT,BUDGETED_COST_ORIGINAL,BUDGETED_REVENUE_ORIGINAL,MARGIN_PERCENTAGE,ORIGINAL_MARGIN_PERCENTAGE,BILLING_SELECT_DATE,BILLING_YTD,BILLING_BEFORE_DATE,REVENUE_SELECT_DATE,REVENUE_YTD,REVENUE_BEFORE_DATE,ADJUSTED_REVENUE,ADJUSTED_REVENUE_YTD,ADJUSTED_REVENUE_SELECTED_DT,ADJUSTED_BILLED,ADJUSTED_BILLED_YTD,ADJUSTED_BILLED_SELECTED_DT,STC_EXCULDED_AMT,COGS_SELECT_DATE,COGS_YTD,COGS_BEFORE_DATE,TOTAL_ACTUAL_BILLING,TOTAL_BILLING_PTD,TOTAL_REVENUE_PTD,TOTAL_COGS_PTD,REVENUE_BALANCE,COST_BALANCE,UNEARNED,UNBILLED,UNEARNED_SELECTED_DATES,UNBILLED_SELECTED_DATES,BILLING_BALANCE,ACTUAL_BILLING_YTD',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    'STCS_Project_Revenue_and_Cost_Report_08-',
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_Project_Revenue_and_Cost_Report',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_pattern": "STCS_Project_Revenue_and_Cost_Report_08-", "file_extension_filter": "all", "note": "Run on 8th"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '7e38ba7c-0e79-4ff0-864e-fd4996b94bd7',
    'PRD_PROJECTS_FINANCIAL_L3_NEW_postgres_12',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'RA_ERP_FC_L3_DATA_DASHBOARD',
    'PROJECT_NUMBER,
 PROJECT_NAME,
 PROJECT_STATUS_NAME,
 TASK_NAME,
 SERVICES_TYPE_FINAL_L3,
 SERVICES_TYPE_FINAL_L1,
 SERVICE_TYPE_DESC_L1,
 PROJECT_MANAGER,
 ACCOUNT_MANAGER,
 SALES_CLASS,
 BU,
 STCS_FCPROJECT_TYPE,
 MICROSOFT_LICENSES ,
 CUSTOMER_SEGMENT,
 CUSTOMER_SEGMENT_CODE,
 CHANNEL_SEGMENT,
 CHANNEL_SEGMENT_CODE,
 to_char(to_date(PROJECT_START_DATE,''mm/dd/yyyy hh24:mi:ss''),''mm/dd/yyyy hh24:mi:ss'')PROJECT_START_DATE,
 to_char(to_date(PROJECT_END_DATE,''mm/dd/yyyy hh24:mi:ss''),''mm/dd/yyyy hh24:mi:ss'')PROJECT_END_DATE ,
 CUSTOMER_NAME,
 CUSTOMER_ACCOUNT,
 null DIMOND_CUSTOMER,
 null PARENT_ACCOUNT,
 SECTOR,
 CUSTOMER_CLASS_CODE,
 EBU_CUSTOMER_SEGMENT,
 EBU_SEGMENT_CODE,
 CRM_NUMBER,
 CLOSING_STATUS,
 PO_NUMBER,
 null RLA_CLOSE_DATE,
 to_char(to_date(PO_START_DATE,''mm/dd/yyyy hh24:mi:ss''),''mm/dd/yyyy hh24:mi:ss'')PO_START_DATE,
 to_char(to_date(PO_EXPIRATION_DATE,''mm/dd/yyyy hh24:mi:ss''),''mm/dd/yyyy hh24:mi:ss'')PO_EXPIRATION_DATE,
 PARENT_PROJECT_NUMBER,
 RLA_YES_NO,
 BILLING_TYPE,
 CUSTOMER_CLASSIFICATION,
 LATEST_BASELINED_DATE,
 LAST_CHANGE_REASON,
 RLA,
 BUDGETED_REVENUE_CURRENT,
 BUDGETED_COST_CURRENT,
 BUDGETED_COST_ORIGINAL,
 BUDGETED_REVENUE_ORIGINAL,
 MARGIN_PER,
    ORIGINAL_MARGIN_PER,
 REVENUE_SELECT_DATE,
 REVENUE_BEFORE_DATE,
 REVENUE_YTD,
 REVENUE_STC_SHARE,
 COGS_SELECT_DATE,
 COGS_BEFORE_DATE,
 COGS_YTD,
 TOTAL_REVENUE PTD,
 TOTAL_COGS PTD,
null TOTAL_COGS_PTD_RLA,
 REVENUE_BALANCE,
 COST_BALANCE',
    'to_Date("DWH_RUN_DATE",''yyyy-mm-dd'') = (
 select
  max(to_Date("DWH_RUN_DATE",''yyyy-mm-dd''))
 from
 RA_ERP_FC_L3_DATA_DASHBOARD)
  and "PL_END_DATE" >= DATE_TRUNC(''MONTH'', CURRENT_DATE) - INTERVAL ''1 month''
   AND "PL_END_DATE" < DATE_TRUNC(''MONTH'', CURRENT_DATE)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_PROJECTS_FINANCIAL_L3_NEW',
    'PROJECT_NUMBER,PROJECT_NAME,PROJECT_STATUS,TASK_NAME,SERVICES_TYPE_FINAL_L3,SERVICES_TYPE_FINAL_L1,SERVICE_TYPE_DESC_L1,PROJECT_MANAGER,ACCOUNT_MANAGER,SALES_CLASS,BU,STCS_FC_PROJECT_TYPE,MICROSOFT_LICENSES,CUSTOMER_SEGMENT,CUSTOMER_SEGMENT_CODE,CHANNEL_SEGMENT,CHANNEL_SEGMENT_CODE,PROJECT_START_DATE,PROJECT_END_DATE,CUSTOMER_NAME,CUSTOMER_ACCOUNT,DIMOND_CUSTOMER,PARENT_ACCOUNT,SECTOR,CUSTOMER_CLASS_CODE,EBU_CUSTOMER_SEGMENT,EBU_SEGMENT_CODE,CRM_NUMBER,CLOSING_STATUS,PO_NUMBER,RLA_CLOSE_DATE,PO_START_DATE,PO_EXPIRATION_DATE,PARENT_PROJECT_NUMBER,RLA_YES_NO,BILLING_TYPE,CUSTOMER_CLASSIFICATION,LATEST_BASELINED_DATE,LAST_CHANGE_REASON,RLA,BUDGETED_REVENUE_CURRENT,BUDGETED_COST_CURRENT,BUDGETED_COST_ORIGINAL,BUDGETED_REVENUE_ORIGINAL,MARGIN_PERCENTAGE,ORIGINAL_MARGIN_PERCENTAGE,REVENUE_SELECT_DATE,REVENUE_BEFORE_DATE,REVENUE_YTD,REVENUE_STC_SHARE,COGS_SELECT_DATE,COGS_BEFORE_DATE,COGS_YTD,TOTAL_REVENUE_PTD,TOTAL_COGS_PTD,TOTAL_COGS_PTD_RLA,REVENUE_BALANCE,COST_BALANCE',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_Project_Revenue_and_Cost_for_L3_Report',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_extension_filter": "all", "note": "Run on 8th"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'e3ed0c91-03ca-45a9-bdf5-b6505e91d993',
    'PRD_STCS_REVENUE_GL_postgres_13',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'STCS_REVENUE_ASSURANCE_GL',
    'DOCUMENT_NUMBER,
 JE_LINE_NUM,
 JE_HEADER_ID,
 to_char(to_date(EFFECTIVE_DATE,''mm/dd/yyyy hh24:mi:ss''),''mm/dd/yyyy hh24:mi:ss'')EFFECTIVE_DATE,
 to_char(to_date(HEADER_CREATED_DATE,''mm/dd/yyyy hh24:mi:ss''),''mm/dd/yyyy hh24:mi:ss'')HEADER_CREATED_DATE,
 to_char(to_date(POSTED_DATE,''mm/dd/yyyy hh24:mi:ss''),''mm/dd/yyyy hh24:mi:ss'')POSTED_DATE,
 CREATED_by,
 POSTED_by,
 BATCH_STATUS,
 COMPANNY_ID,
 ACCOUNT_ID,
 COST_CENTER_ID,
 PRODUCT_ID,
 PRODUCT_DESC,
 "CUSTOMER_ID" GL_CODE5,
 "CHANNEL_ID" GL_CODE6,
 "INDUSTRY_ID" GL_CODE7,
 "PROJECT_SEGMENT" GL_CODE8,
 "SEGMENT9" GL_CODE9,
 "SEGMENT10" GL_CODE10,
 "JE_SOURCE" source,
 "JE_CATEGORY" CATEGORY,
 "ACCOUNTED_DR" DR,
 "ACCOUNTED_CR" CR,
  "NET_REV" NET_AMOUNT,
 "ACCOUNT_ID" NATURAL_ACCOUNT,
 "NARRATION" NARRATION',
    'POSTED_DATE >= DATE_TRUNC(''MONTH'',
 CURRENT_DATE) - interval ''1 month''
 and POSTED_DATE < DATE_TRUNC(''MONTH'',
 CURRENT_DATE)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_STCS_REVENUE_GL',
    'DOCUMENT_NUMBER,JE_LINE_NUM,JE_HEADER_ID,EFFECTIVEDATE,CREATEDDATE,POSTEDDATE,CREATED_BY,POSTED_BY,STATUS,COMPANY,ACCOUNT,COST_CENTER,PRODUCT,PRODUCT_DESC,GL_CODE5,GL_CODE6,GL_CODE7,GL_CODE8,GL_CODE9,GL_CODE10,SOURCE,CATEGORY,DR,CR,NET_AMOUNT,NATURAL_ACCOUNT,NARRATION',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_Revenue_Assurance_GL_Report',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_extension_filter": "all", "note": "Run on 8th"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'a293aa2d-d128-4ea4-8909-f9c1f4855063',
    'PRD_STCS_RAISED_INVOICES_postgres_14',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'PROJECT_INVOICE_DTL',
    'distinct PROJECT_SEGMENT PROJECT_NUMBER,
PROJECT_NAME PROJECT_NAME,
PROJECT_DESCRIPTION PROJECT_DESCRIPTION,
PM_PROJECT_REFERENCE PM_PROJECT_REFERENCE,
CUSTOMER_ACCOUNT CUSTOMER_ACCOUNT,
DRAFT_INVOICE_NUM,
TRANSFER_STATUS_CODE,
to_char(to_date(INVOICE_DATE,''mm/dd/yyyy hh24:mi:ss''),''mm/dd/yyyy hh24:mi:ss'') INVOICE_DATE,
CUSTOMER_INVOICE_NUMBER RA_INVOICE_NUMBER,
CASE SUBSTRING(GL_PERIOD_NAME, 1, 3)
        WHEN ''JAN'' THEN ''01''
        WHEN ''FEB'' THEN ''02''
        WHEN ''MAR'' THEN ''03''
        WHEN ''APR'' THEN ''04''
        WHEN ''MAY'' THEN ''05''
        WHEN ''JUN'' THEN ''06''
        WHEN ''JUL'' THEN ''07''
        WHEN ''AUG'' THEN ''08''
        WHEN ''SEP'' THEN ''09''
        WHEN ''OCT'' THEN ''10''
        WHEN ''NOV'' THEN ''11''
        WHEN ''DEC'' THEN ''12''
    END || ''/01/'' || ''20'' || SUBSTRING(GL_PERIOD_NAME, 5, 2) || '' 00:00:00'' AS GL_PERIOD_NAME,
CASE SUBSTRING(SERVICE_PERIOD, 1, 3)
        WHEN ''JAN'' THEN ''01''
        WHEN ''FEB'' THEN ''02''
        WHEN ''MAR'' THEN ''03''
        WHEN ''APR'' THEN ''04''
        WHEN ''MAY'' THEN ''05''
        WHEN ''JUN'' THEN ''06''
        WHEN ''JUL'' THEN ''07''
        WHEN ''AUG'' THEN ''08''
        WHEN ''SEP'' THEN ''09''
        WHEN ''OCT'' THEN ''10''
        WHEN ''NOV'' THEN ''11''
        WHEN ''DEC'' THEN ''12''
    END || ''/01/'' || ''20'' || SUBSTRING(SERVICE_PERIOD, 5, 2) || '' 00:00:00'' SERVICE_PERIOD,
WORK_ORDER_NUMBER,
ATTRIBUTE9,
ATTRIBUTE11,
ATTRIBUTE12,
  to_char(to_date(CREATION_DATE,''mm/dd/yyyy hh24:mi:ss''),''mm/dd/yyyy hh24:mi:ss'')CREATION_DATE,
 CASE SUBSTRING(COC_DATE, 4, 3)
        WHEN ''Jan'' THEN ''01''
        WHEN ''Feb'' THEN ''02''
        WHEN ''Mar'' THEN ''03''
        WHEN ''Apr'' THEN ''04''
        WHEN ''May'' THEN ''05''
        WHEN ''Jun'' THEN ''06''
        WHEN ''Jul'' THEN ''07''
        WHEN ''Aug'' THEN ''08''
        WHEN ''Sep'' THEN ''09''
        WHEN ''Oct'' THEN ''10''
        WHEN ''Nov'' THEN ''11''
        WHEN ''Dec'' THEN ''12''
    END || ''/'' || 
    SUBSTRING(COC_DATE, 1, 2) || ''/'' || 
    SUBSTRING(COC_DATE, 8, 4) || 
    '' 00:00:00'' AS  COC_DATE,
LINE_NUM,
text,
TASK_NUMBER,
AMOUNT INVOICE_LINE_AMOUNT,
TOTAL_INVOICE_AMOUNT',
    'PROJECT_SEGMENT like ''%1%'' or PROJECT_SEGMENT is null ',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_STCS_RAISED_INVOICES',
    'PROJECT_NUMBER,PROJECT_NAME,PROJECT_DESCRIPTION,PM_PROJECT_REFERENCE,CUSTOMER_ACCOUNT,DRAFT_INVOICE_NUM,TRANSFER_STATUS_CODE,INVOICE_DATE,RA_INVOICE_NUMBER,GL_PERIOD_NAME,SERVICE_PERIOD,WORK_ORDER_NUMBER,ATTRIBUTE9,ATTRIBUTE11,ATTRIBUTE12,CREATION_DATE,COC_DATE,LINE_NUM,TEXT,TASK_NUMBER,INVOICE_LINE_AMOUNT,TOTAL_INVOICE_AMOUNT',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_Project_Invoice_Details_for_Revenue_Assuarance',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '49f51df1-8c06-401c-87f6-79dcea5cd2e9',
    'A_FLAVOR_postgres_15',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_flavor',
    'id,created,modified,price,"order",slug,retired,billable_unit_id,cloned_from_id,override_id,price_list_id,product_id,sub_product_category_id,uuid',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_service_management_flavor)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_FLAVOR',
    'ID,CREATED,MODIFIED,PRICE,Order,SLUG,RETIRED,Bill Able Unit ID,Cloned From ID,Override ID,Price List ID,Product ID,Sub Product Category ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'c5e342dc-407b-48f4-96ae-984b86bf8d4c',
    'A_PLAN_postgres_16',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_plan',
    'category_type,cloned_from_id,created,datacenter_id,id,maximum_allowed_subscriptions,modified,mrc_category_type,mrc_stcs_chart_of_accounts_category,"order",otc_category_type,otc_stcs_chart_of_accounts_category,retired,service_id,slug,stcs_chart_of_accounts_category,"type",mrc_sub_product_category_id,otc_sub_product_category_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_service_management_plan)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_PLAN',
    'Category Type,Cloned From ID,CREATED,Datacenter ID,ID,Maximum Allowed Subscriptions,MODIFIED,Mrc Category Type,Mrc St Cs Chart Of Accounts Category,Order,Otc Category Type,Otc St Cs Chart Of Accounts Category,RETIRED,Service ID,SLUG,St Cs Chart Of Accounts Category,Type,Mrc Sub Product Category ID,Otc Sub Product Category ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'f02b81a2-b347-4aef-b26d-dba16a521f61',
    'A_PLAN_TRANSLATION_postgres_17',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_plan_translation',
    'id,language_code,"name",master_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_service_management_plan_translation)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_PLAN_TRANSLATION',
    'ID,Language Code,NAME,Master ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '28d4e2bc-4fe4-4802-97b6-5858f2b5b33c',
    'A_PLAN_PRICE_postgres_18',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_planprice',
    'id,created,modified,slug,cloned_from_id,override_id,plan_id,price_list_id,sub_product_category_id,uuid',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_service_management_planprice)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_PLAN_PRICE',
    'ID,CREATED,MODIFIED,SLUG,Cloned From ID,Override ID,Plan ID,Price List ID,Sub Product Category ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'c3d93b36-29ad-4bd2-95e9-6a3edf1133d6',
    'A_PRODUCT_postgres_19',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_product',
    'id,created,modified,"order",slug,category_type,stcs_chart_of_accounts_category,cloned_from_id,datacenter_id,service_id,uuid,source_file',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_service_management_product)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_PRODUCT',
    'ID,CREATED,MODIFIED,Order,SLUG,Category Type,St Cs Chart Of Accounts Category,Cloned From ID,Datacenter ID,Service ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'a019591b-9605-4afb-96cb-0c4c896d08cd',
    'PRD_STCS_CORPORATE_REVREPORT_postgres_20',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'STCS_Corporate_Revenue_Report_new',
    'Account_Number,
Customer_Name,
Customer_Segment,
Industry_type,
Channel,
Trx_Number,
to_Char(to_timestamp(Trx_Date,''YYYY-MM-DDTHH24:MI:SS''),''YYYY-MM-DDTHH24:MI:SS'')||''.000+03:00'' Trx_Date,
HDR_INVOICE_CURRENCY_CODE Invoice_Currency_Code,
LNS_LINE_NUMBER Line_Number,
LNS_DESCRIPTION Description,
Quantity_Invoiced,
LNS_UNIT_SELLING_PRICE Unit_Selling_Price,
Interface_Line_Context,
LNS_ORDER_NUMBER Interface_Line_Attribute1,
to_char(to_Date(Bill_from_Date,''yyyy-mm-dd''),''dd-Mon-yy'')Bill_from_Date,
to_char(to_Date(Bill_to_Date,''yyyy-mm-dd''),''dd-Mon-yy'') Bill_to_Date,
Account_class,
Amount,
to_Char(to_timestamp(Gl_Date,''YYYY-MM-DDTHH24:MI:SS''),''YYYY-MM-DDTHH24:MI:SS'')||''.000+03:00'' Gl_Date,
Party_Name,
Segment2,
Customer_Trx_Line_ID,
Item_Code,
CATEGORY_SET_NAME,
Order_line_number,
Circuit_name,
fict_billing_no,
L1,
L2,
L3,
ORDER_NUMBER Order_Number,
Billing_cycle,
ACCOUNT_MANAGER Account_Manager ,
SALES_MANAGER Sales_Manager ,
null Sales_Director,
null Sales_GM ,
order_Type,
REFERENCE_ORDER,
REFERENCE_ORDER_LINE,
OLD_ERP_ORDER_NUMBER,
OLD_ERP_ORDER_LINE,
OLD_ERP_LINE_ID,
MIGRATION_PURPOSE_ONLY,
DYN_OFF_SHLF_RQST,
DYNMCS_ORDER_TYPE',
    '"TRX_NUMBER" in (''2023021533'',
''2023021435'',
''2023021517'',
''2023021096'',
''2023020917'',
''2023041903'',
''2023021421'',
''2023041894'',
''2023041900'',
''2023042572'',
''2023062161'',
''2023061564'',
''2023061582'',
''2023041769'',
''2023042404'',
''2023062164'',
''2023041759'',
''2023041775'',
''2023042094'',
''2023051945'',
''2023041965'',
''2023061578'',
''2023051955'',
''2023072049'',
''2023052016'',
''2023072627'',
''2023071583'',
''2023072003'',
''2023070372'',
''2023071770'',
''2023051999'',
''2023071968'',
''2023071561'',
''2023071919'',
''2023071539'',
''2023071564'',
''2023071998'',
''2023071821'',
''2023071845'',
''2023051993'',
''2023072006'',
''2023052001'',
''2023052024'',
''2023051990'',
''2023051980'',
''2023071783'',
''2023072008'',
''2023071736'',
''2023071960'',
''2023071575'',
''2023071528'',
''2023070528'',
''2023070535'',
''2023081862'',
''2023071758'',
''2023071733'',
''2023071616'',
''2023072000'',
''2023071943'',
''2023071781'',
''2023071631'',
''2023070436'',
''2023091269'',
''2023060675'',
''2023092494'',
''2023060665'',
''2023102026'',
''2023120113'',
''2023091300'',
''2023120120'',
''2023091304'',
''2023102023'',
''2023120137'',
''2025061823'',
''2023091293'',
''2024042098'',
''2024041097'',
''2024042101'',
''2024042163'',
''2024042102'',
''2024042161'',
''2024052090'',
''2024052154'',
''2024052092'',
''2025061779'',
''2025021415'',
''2025021401'',
''2025061809'',
''2024062201'',
''2024062203'',
''2025061813'',
''2024062196'',
''2024032180'',
''2025021410'',
''2025021405'',
''2024012060'',
''2024012061'',
''2024032286'',
''2023111750'',
''2024032287'',
''2023111391'',
''2023111451'',
''2024032130'',
''2024032035'',
''2024120344'',
''2023112039'',
''2024120211'',
''2024120327'',
''2024120276'',
''2024120481'',
''2024032048'',
''2024120195'',
''2024120325'',
''2024081022'',
''2024120284'',
''2024032058'',
''2024082234'',
''2024120557'',
''2024120305'',
''2024081492'',
''2024082249'',
''2024021052'',
''2024022062'',
''2025011660'',
''2024082250'',
''2025011650'',
''2025011606'',
''2024092130'',
''2025010006'',
''2024092173'',
''2024092183'',
''2024092191'',
''2024092185'',
''2024092188'',
''2022022505'',
''2022022551'',
''2022022513'',
''2022022499'',
''2022022501'',
''2024112138'',
''2025031698'',
''2025031662'',
''2025031666'',
''2025031697'',
''2024111068'',
''2025051699'',
''2025050859'',
''2025051686'',
''2025031709'',
''2025041742'',
''2024102174'',
''2025040862'',
''2025031700'',
''2024111087'',
''2025051697'',
''2024112173'',
''2025051691'',
''2024111140'',
''2024111338'',
''2024111155'',
''2024111107'',
''2024111185'',
''2024111204'',
''2022022835'',
''2022022576'',
''2022022564'',
''2022022580'',
''2022012589'',
''2022011826'',
''2022012838'',
''2022012123'',
''2022012126'',
''2022010364'',
''2022011455'',
''2022011628'',
''2022012142'',
''2022010380'',
''2022011457'',
''2021100321'',
''2021100432'',
''2021110553'',
''2021100390'',
''2021110369'',
''2021110292'',
''2021100205'',
''2021111422'',
''2021111764'',
''2021111431'',
''2021101410'',
''2021101390'',
''2021111424'',
''2021101957'',
''2021101363'',
''2021111412'',
''2021101391'',
''2021100945'',
''2021101374'',
''2021123194'',
''2021112467'',
''2021102124'',
''2021102050'',
''2021122451'',
''2021102440'',
''2021112171'',
''2021122361'',
''2022032590'',
''2022032609'',
''2022032595'',
''2022031941'',
''2022033101'',
''2022032612'',
''2022031792'',
''2022052350'',
''2022032602'',
''2022032647'',
''2022032593'',
''2022032654'',
''2022052381'',
''2022052395'',
''2022052372'',
''2022032611'',
''2022052360'',
''2022052331'',
''2022052657'',
''2022052346'',
''2022052658'',
''2022052379'',
''2022062459'',
''2022052404'',
''2022052700'',
''2022052680'',
''2022052334'',
''2022062457'',
''2022052392'',
''2022042163'',
''2022042174'',
''2022052403'',
''2022052385'',
''2022062454'',
''2022041415'',
''2022052400'',
''2022042637'',
''2022042570'',
''2022042178'',
''2022042293'',
''2022042162'',
''2022042271'',
''2022092502'',
''2022092465'',
''2022042231'',
''2022042187'',
''2022042222'',
''2022042156'',
''2022042181'',
''2022042205'',
''2022062488'',
''2022092526'',
''2022092466'',
''2022092483'',
''2022071470'',
''2022092484'',
''2022072164'',
''2022092458'',
''2022092514'',
''2022092520'',
''2022072308'',
''2022072170'',
''2022092525'',
''2022082053'',
''2022112744'',
''2022112893'',
''2022101426'',
''2022082848'',
''2022082069'',
''2022082088'',
''2022082750'',
''2022082081'',
''2022082388'',
''2022082337'',
''2022082090'',
''2022082057'',
''2022100003'',
''2022092878'',
''2022092875'',
''2022062982'',
''2022111719'',
''2022111733'',
''2022082041'',
''2022082036'',
''2022082043'',
''2022120274'',
''2022092527'',
''2022112827'',
''2022092529'',
''2022102478'',
''2022122620'',
''2022111638'',
''2022112398'',
''2022112603'',
''2022112659'',
''2022112408'',
''2022112509'',
''2022112622'',
''2022102462'',
''2022112834'',
''2022112302'',
''2022112190'',
''2022112381'',
''2022102501'',
''2022112456'',
''2022102502'',
''2022100028'',
''2022112670'',
''2023031309'',
''2023010292'',
''2022102474'',
''2023031599'',
''2023031246'',
''2023031217'',
''2022102467'',
''2022102457'',
''2022102464'',
''2023031243'',
''2023012042'',
''2022102471'',
''2023031579'',
''2023011590'',
''2023011039'',
''2023031229'',
''2023031235'',
''2023020488'',
''2023022266'',
''2023020487'',
''2023020564'',
''2023020334'',
''2023032109'',
''2023031586'',
''2023020456'',
''2023032111'',
''2023020513'',
''2023020528'',
''2023021436'',
''2023021008'',
''2023020975'',
''2023021867'',
''2023021316'',
''2023020930'',
''2023020911'',
''2023020490'',
''2023021346'',
''2023021175'',
''2023021484'',
''2023020504'',
''2023021329'',
''2023020868'',
''2023020863'',
''2023020333'',
''2023010540'',
''2023020388'',
''2023021278'',
''2023022267'',
''2023020389'',
''2023020475'',
''2023020529'',
''2023011672'',
''2023020563'',
''2023020904'',
''2023020335'',
''2023020296'',
''2023020302'',
''2023011324'',
''2023021741'',
''2023020421'',
''2023020704'',
''2023022311'',
''2023021445'',
''2023020705'',
''2023020965'',
''2023022120'',
''2023021074'',
''2023021970'',
''2023021492'',
''2023022112'',
''2023010797'',
''2023020194'',
''2023022002'',
''2023020899'',
''2023022347'',
''2023021541'',
''2023021455'',
''2023021156'',
''2023021056'',
''2023020646'',
''2023020985'',
''2023020387'',
''2023020330'',
''2023021540'',
''2023021846'',
''2023022275'',
''2023021428'',
''2023020425'',
''2023021449'',
''2023022345'',
''2023020870'',
''2023021095'',
''2023020339'',
''2023020918'',
''2023021166'',
''2023020300'',
''2023022010'',
''2023020886'',
''2023020908'',
''2023021854'',
''2023042571'',
''2023020926'',
''2023020992'',
''2023020967'',
''2023020879'',
''2023021473'',
''2023021482'',
''2023020892'',
''2023021437'',
''2023061566'',
''2023041892'',
''2023042474'',
''2023061596'',
''2023061591'',
''2023061570'',
''2023042188'',
''2023041791'',
''2023041792'',
''2023051957'',
''2023061575'',
''2023051978'',
''2023052006'',
''2023072319'',
''2023071510'',
''2023072002'',
''2023051989'',
''2023071674'',
''2023071967'',
''2023071816'',
''2023071646'',
''2023071871'',
''2023071649'',
''2023071419'',
''2023060215'',
''2023071824'',
''2023071548'',
''2023071701'',
''2023081873'',
''2023060673'',
''2023051979'',
''2023081861'',
''2023060645'',
''2023081858'',
''2023071571'',
''2023071999'',
''2023091302'',
''2023081874'',
''2023071779'',
''2023071673'',
''2023072010'',
''2023071567'',
''2023071658'',
''2023071897'',
''2023071811'',
''2023071574'',
''2023071865'',
''2023060086'',
''2023081867'',
''2023091295'',
''2023091306'',
''2023120115'',
''2023102034'',
''2023120118'',
''2023102020'',
''2023091310'',
''2023102015'',
''2023101113'',
''2023060661'',
''2023120135'',
''2023102029'',
''2023120143'',
''2023120164'',
''2023120178'',
''2023120134'',
''2023122564'',
''2023122577'',
''2024042148'',
''2024042169'',
''2025061825'',
''2024052163'',
''2025061826'',
''2025061785'',
''2024052143'',
''2025061782'',
''2024042152'',
''2024062143'',
''2024052089'',
''2024052145'',
''2025061811'',
''2025061816'',
''2024062192'',
''2025061780'',
''2024052158'',
''2024062202'',
''2024062578'',
''2025021644'',
''2025021416'',
''2024062189'',
''2025020526'',
''2025021403'',
''2024012069'',
''2024032132'',
''2023111470'',
''2024032134'',
''2024010112'',
''2024032135'',
''2024011391'',
''2023111605'',
''2024032147'',
''2024032177'',
''2023111811'',
''2024012071'',
''2023111504'',
''2023111388'',
''2023111542'',
''2023111565'',
''2024032044'',
''2024032041'',
''2023111379'',
''2023111814'',
''2023111669'',
''2024120525'',
''2024120278'',
''2024120524'',
''2024120206'',
''2024120237'',
''2024120563'',
''2024120324'',
''2024120468'',
''2024120307'',
''2024022113'',
''2024081496'',
''2024082242'',
''2024081493'',
''2024022064'',
''2024082241'',
''2024022059'',
''2024022067'',
''2024022072'',
''2025021412'',
''2024022068'',
''2024082248'',
''2024082233'',
''2024082238'',
''2024092017'',
''2022022526'',
''2022022547'')',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_STCS_CORPORATE_REVREPORT',
    'ACCOUNT_NUMBER,CUSTOMER_NAME,CUSTOMER_SEGMENT,INDUSTRY_TYPE,CHANNEL,TRX_NUMBER,TRX_DATE,INVOICE_CURRENCY_CODE,LINE_NUMBER,DESCRIPTION,QUANTITY_INVOICED,UNIT_SELLING_PRICE,INTERFACE_LINE_CONTEXT,INTERFACE_LINE_ATTRIBUTE1,BILL_FROM_DATE,BILL_TO_DATE,ACCOUNT_CLASS,AMOUNT,GL_DATE,PARTY_NAME,SEGMENT2,CUSTOMER_TRX_LINE_ID,ITEM_CODE,CATEGORY_SET_NAME,ORDER_LINE_NUMBER,CIRCUIT_NAME,FICT_BILLING_NO,L1,L2,L3,ORDER_NUMBER,BILLING_CYCLE,ACCOUNT_MANAGER,SALES_MANAGER,SALES_DIRECTOR,SALES_GM,ORDER_TYPE,REFERENCE_ORDER,REFERENCE_ORDER_LINE,OLD_ERP_ORDER_NUMBER,OLD_ERP_ORDER_LINE,OLD_ERP_LINE_ID,MIGRATION_PURPOSE_ONLY,DYN_OFF_SHLF_RQST,DYNMCS_ORDER_TYPE',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_Corporate_Revenue_Report',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'd7a1cc4e-2134-4c4f-9e97-9cfc5e6f1fc5',
    'PRD_PROJECT_AP_PO_REPORT_postgres_21',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'PO_COSTING',
    'EXPENDITURE_ITEM_KEY EXPENDITURE_ITEM_ID,
PROJECT_NUMBER,
TASK_NUMBER,
ACCT_BURDENED_COST,
EXPENDITURE_TYPE,
to_char(to_date(EXPENDITURE_ITEM_DATE,''mm/dd/yyyyhh24:mi:ss''),''mm/dd/yyyyhh24:mi:ss'')EXPENDITURE_ITEM_DATE,
QUANTITY,
UNIT_OF_MEASUREUNIT_OF_MEASURE_M,
PROJECT_CURRENCY_CODE,
BURDEN_COST,
PROJECT_BURDENED_COST,
ACCRUED_REVENUE,
BILL_AMOUNT,
EXPENDITURE_COMMENT,
EXPENDITURE_ORGANIZATION_NAME,
DENOM_CURRENCY_CODE,
DENOM_RAW_COST,
DENOM_BURDENED_COST,
ACCT_CURRENCY_CODE,
ACCT_RATE_TYPE,
ACCT_RATE_TYPEUSER_ACCT_RATE_TYPE,
ACCT_RATE_DATE,
ACCT_EXCHANGE_RATE,
ACCT_RAW_COST,
PROJECT_RATE_TYPE,
PROJFUNC_COST_EXCHANGE_RATE,
COST_DISTRIBUTED_FLAG,
RAW_COST,
PROJECT_RAW_COST,
RAW_COST_RATE,
COST_DIST_REJECTION_CODE,
RAW_COST_RATEBURDENED_COST_RATE,
PROJECT_NAME,
PROJECT_TYPE,
TASK_NAME,
EXPENDITURE_CATEGORY,
REVENUE_CATEGORY_CODE,
EMPLOYEE_NAME,
EMPLOYEE_NUMBER,
JOB_NAME,
USER_TRANSACTION_SOURCE,
EXPENDITURE_GROUP,
GL_ACCOUNTED_FLAG,
COSTED_FLAG,
EXPENDITURE_ID,
INVOICE_NUMBER,
EXPENDITURE_STATUS_CODE,
to_char(to_date(EXPENDITURE_ENDING_DATE,''mm/dd/yyyyhh24:mi:ss''),''mm/dd/yyyyhh24:mi:ss'')EXPENDITURE_ENDING_DATE,
TRANSACTION_SOURCE,
CC_PRVDR_ORGANIZATION_NAME,
PRVDR_ORG_NAME,
CC_RECVR_ORGANIZATION_NAME,
DOCUMENT_TYPE,
PO_NUMBER_U,
PO_LINE_U,
PO_DISTRIBUTION_NUMBER_U,
RECEIPT_NUMBER_U,
VENDOR_NUMBER,
VENDOR_NAME,
COSTED_ACCOUNT,
VOUCHER_NUMBER,
AP_INVOICE_NUMBER,
REQUESTION_NUMBER,
INVOICE_DESCRIPTION,
SUPPLIER_ITEM_CODE,
PAYROLL_GL,
Rct_Quantity',
    'EXPENDITURE_ITEM_DATE >= DATE_TRUNC(''MONTH'',
 CURRENT_DATE) - interval ''1 month''
 and EXPENDITURE_ITEM_DATE < DATE_TRUNC(''MONTH'',
 CURRENT_DATE)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_PROJECT_AP_PO_REPORT',
    'EXPENDITURE_ITEM_ID,PROJECT_NUMBER,TASK_NUMBER,ACCT_BURDENED_COST,EXPENDITURE_TYPE,EXPENDITURE_ITEM_DATE,QUANTITY,UNIT_OF_MEASURE_M,PROJECT_CURRENCY_CODE,BURDENED_COST,PROJECT_BURDENED_COST,ACCRUED_REVENUE,BILL_AMOUNT,EXPENDITURE_COMMENT,EXPENDITURE_ORGANIZATION_NAME,DENOM_CURRENCY_CODE,DENOM_RAW_COST,DENOM_BURDENED_COST,ACCT_CURRENCY_CODE,ACCT_RATE_TYPE,USER_ACCT_RATE_TYPE,ACCT_RATE_DATE,ACCT_EXCHANGE_RATE,ACCT_RAW_COST,PROJECT_RATE_TYPE,PROJFUNC_COST_EXCHANGE_RATE,COST_DISTRIBUTED_FLAG,RAW_COST,PROJECT_RAW_COST,RAW_COST_RATE,COST_DIST_REJECTION_CODE,BURDENED_COST_RATE,PROJECT_NAME,PROJECT_TYPE,TASK_NAME,EXPENDITURE_CATEGORY,REVENUE_CATEGORY_CODE,EMPLOYEE_NAME,EMPLOYEE_NUMBER,JOB_NAME,USER_TRANSACTION_SOURCE,EXPENDITURE_GROUP,GL_ACCOUNTED_FLAG,COSTED_FLAG,EXPENDITURE_ID,INVOICE_NUMBER,EXPENDITURE_STATUS_CODE,EXPENDITURE_ENDING_DATE,TRANSACTION_SOURCE,CC_PRVDR_ORGANIZATION_NAME,PRVDR_ORG_NAME,CC_RECVR_ORGANIZATION_NAME,DOCUMENT_TYPE,PO_NUMBER_U,PO_LINE_U,PO_DISTRIBUTION_NUMBER_U,RECEIPT_NUMBER_U,VENDOR_NUMBER,VENDOR_NAME,COSTED_ACCOUNT,VOUCHER_NUMBER,AP_INVOICE_NUMBER,REQUESTION_NUMBER,INVOICE_DESCRIPTION,SUPPLIER_ITEM_CODE,PAYROLL_GL,RECEVIED_QTY',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_AP_and_PO_Costing_Report',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '83bfbd4b-adac-4803-9e23-d415be04be7a',
    'PRD_STCS_PROJECT_ADVANCES_DETAILS_csv_22',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/STCS Project Advances Details Report',
    'Advance Request Number,Account Number,Party Name,STCS Order Number,Advance Request Date,Currency,Amount,Base Amount,Invoice Number,VAT Amount,VAT Code,Agreement Type,Requested By,Terms,Description,Amount Applied,Receipt Number,Created By,Receipt Date,Collected (Yes/No),Invoiced (Yes/No),Comments,Attribute 2,Last Update Date,Min user,Max User,Agreement Comments',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_STCS_PROJECT_ADVANCES_DETAILS',
    'ADVANCE_REQUEST_NUMBER,ACCOUNT_NUMBER,PARTY_NAME,STCS_ORDER_NUMBER,ADVANCE_REQUEST_DATE,CURRENCY,AMOUNT,BASE_AMOUNT,INVOICE_NUMBER,VAT_AMOUNT,VAT_CODE,AGREEMENT_TYPE,REQUESTED_BY,TERMS,DESCRIPTION,AMOUNT_APPLIED,RECEIPT_NUMBER,CREATED_BY,RECEIPT_DATE,COLLECTED,INVOICED,COMMENTS,ATTRIBUTE_2,LAST_UPDATE_DATE,MIN_USER,MAX_USER,AGREEMENT_COMMENTS',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    3,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_Project_Advances_Details_Report',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '62e6679c-dc6b-4c69-84dc-9daba1f44aa1',
    'PRD_STC_I_SUPPLIER_csv_23',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/STCS I Supplier',
    'Invoice Number,Invoice Date,Actual Documents Receiving Date in AP,Type,Currency, Amount ,Due,Status,Detailed Invoice Status,Payment Status,Payment Number,PO Number,Receipt',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_STC_I_SUPPLIER',
    'INVOICE_NUMBER,INVOICE_DATE,ACTUAL_DOCUMENTS_RECEIVING_DATE_IN_AP,TYPE,CURRENCY,AMOUNT,DUE,STATUS,DETAILED_INVOICE_STATUS,ON_HOLD,PAYMENT_STATUS,PAYMENT_NUMBER,PO_NUMBER,RECEIPT',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_I_Supplier',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '48fb28dd-599e-4e22-aaf1-df0f450b1dcf',
    'PRD_CUSTOMER_COLLECTIONS_WITH_INVOICE_PROJECT_csv_24',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/Customer Collections with Invoice and Project Report',
    'SR.,Customer Num.,Customer Name,Classification,Sector,Region,Division,Legal,Sales Office,Amount,Apply,Receipt Ref#,Receipt Number,Receipt Date,Adjust Offset,Chq #,Bank,Sales.,Collector,Applied Amount,Invoice Number,Project Number,Project Organization',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_CUSTOMER_COLLECTIONS_WITH_INVOICE_PROJECT',
    'SR,CUSTOMER_NUM,CUSTOMER_NAME,CLASSIFICATION,SECTOR,REGION,DIVISION,LEGAL,SALES_OFFICE,AMOUNT,APPLY,RECEIPT_REF,RECEIPT_NUMBER,RECEIPT_DATE,ADJUST_OFFSET,CHQ,BANK,SALES,COLLECTOR,APPLIED_AMOUNT,INVOICE_NUMBER,PROJECT_NUMBER,PROJECT_ORGANIZATION',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/Customer_Collections_with_Invoice_and_Project_Report',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'a0673b87-90fe-4197-8ae6-50df0d0960fe',
    'A_PRODUCT_TRANS_postgres_25',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_product_translation',
    'ID,language_Code,Master_ID,NAME',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_service_management_product_translation)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_PRODUCT_TRANS',
    'ID,Language Code,Master ID,NAME',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '0d54d1a4-4a84-4955-b888-29103e914d1c',
    'A_QUANTIFIABLE_ITEM_postgres_26',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_quantifiableitem',
    'Cloned_From_ID,CREATED,ID,MODIFIED,"order",Service_ID,Unit_ID',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
  stc_marketplace_service_management_quantifiableitem)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_QUANTIFIABLE_ITEM',
    'Cloned From ID,CREATED,ID,MODIFIED,Order,Service ID,Unit ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '7b008f9a-590f-4af0-a22c-0437858eec32',
    'A_QUANTIFIABLE_ITEM_TRANSLATION_postgres_27',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_quantifiableitem_translation',
    'DESCRIPTION,ID,Language_Code,Master_ID,NAME',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
stc_marketplace_service_management_quantifiableitem_translation)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_QUANTIFIABLE_ITEM_TRANSLATION',
    'DESCRIPTION,ID,Language Code,Master ID,NAME',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '19992b8a-13fb-4725-9ce3-11b7db486113',
    'A_SERVICE_postgres_28',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_service',
    'Approval_Date,
AVAILABILITY,
Billing_Type,
Cancel_Validations_URL,
Cloned_From_ID,
CREATED,
DELETED,
Depends_On_ID,
document,
events_timeout,
events_timeout_unit,
ID,
Is_Beta,
Is_Featured,
Is_Private,
Landing_Page_URL,
LOGO,
Management_Link,
MODIFIED,
multi_datacenters,
Owner_Email,
Service_Provider_ID,
SLUG,
STATUS,
User_Management_Type,
Owner_ID,
CATEGORY,
Publish_Date,
Allow_Remote_Creation',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
stc_marketplace_service_management_service)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_SERVICE',
    'Approval Date,AVAILABILITY,Billing Type,Cancel Validations URL,Cloned From ID,CREATED,DELETED,Depends On ID,DOCUMENT,Events Time Out,Events Time Out Unit,ID,Is Beta,Is Featured,Is Private,Landing Page URL,LOGO,Management Link,MODIFIED,Multi Data Centers,Owner Email,Service Provider ID,SLUG,STATUS,User Management Type,Owner ID,CATEGORY,Publish Date,Allow Remote Creation',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'ecb786f8-763f-4e25-a496-21e35c4458ad',
    'A_SERVICE_ITEM_UNIT_postgres_29',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_item_units',
    'ID,Item_ID,Unit_ID',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
stc_marketplace_service_management_item_units)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_SERVICE_ITEM_UNIT',
    'ID,Item ID,Unit ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'e1e6c1f4-af46-4f38-bb99-f3ab18bfc454',
    'A_SERVICE_ITEM_postgres_30',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_item',
    'Cloned_From_ID,CREATED,ID,Is_Feature,MODIFIED,"order",Service_ID',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
stc_marketplace_service_management_item)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_SERVICE_ITEM',
    'Cloned From ID,CREATED,ID,Is Feature,MODIFIED,Order,Service ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'ddfe7d2b-21d1-490c-a8b0-6268e6a1a45c',
    'A_SERVICE_TRANSLATION_postgres_31',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_service_translation',
    'Agreement_Terms,ID,Language_Code,Master_ID,NAME,Short_Description,TITLE',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
stc_marketplace_service_management_service_translation)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_SERVICE_TRANSLATION',
    'Agreement Terms,ID,Language Code,Master ID,NAME,Short Description,TITLE',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '55f56d9c-4f79-4cdb-a2d2-8d3e94c8b6b8',
    'KILLBILL_SUBSCRIPTIONS_postgres_32',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'killbill_subscriptions',
    'RECORD_ID,
 ID,
 BUNDLE_ID,
 CATEGORY,
 START_DATE,
 BUNDLE_START_DATE,
 CHARGED_THROUGH_DATE,
 CREATED_BY,
 CREATED_DATE,
 UPDATED_BY,
 UPDATED_DATE,
 ACCOUNT_RECORD_ID,
 TENANT_RECORD_ID,
 MIGRATED,
 EXTERNAL_KEY',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
killbill_subscriptions)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'KILLBILL_SUBSCRIPTIONS',
    'RECORD_ID,ID,BUNDLE_ID,CATEGORY,START_DATE,BUNDLE_START_DATE,CHARGED_THROUGH_DATE,CREATED_BY,CREATED_DATE,UPDATED_BY,UPDATED_DATE,ACCOUNT_RECORD_ID,TENANT_RECORD_ID,MIGRATED,EXTERNAL_KEY',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'de15737c-e3c1-4ca5-9faa-720cf7d6e579',
    'PRD_CLOUD_KILLBILL_INVOICE_ITEMS_postgres_33',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'invoice_items_kb',
    'RECORD_ID,
 ID,
 type,
 INVOICE_ID,
 ACCOUNT_ID,
 BUNDLE_ID,
 SUBSCRIPTION_ID,
 DESCRIPTION,
 PLAN_NAME,
 PHASE_NAME,
 USAGE_NAME,
 START_DATE,
 END_DATE,
 AMOUNT,
 RATE,
 CURRENCY,
 LINKED_ITEM_ID,
 CREATED_BY,
 CREATED_DATE,
 ACCOUNT_RECORD_ID,
 TENANT_RECORD_ID,
 CHILD_ACCOUNT_ID,
 QUANTITY,
 PRODUCT_NAME,
 CATALOG_EFFECTIVE_DATE,null EXTERNAL_KEY',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
invoice_items_kb)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_CLOUD_KILLBILL_INVOICE_ITEMS',
    'RECORD_ID,ID,TYPE,INVOICE_ID,ACCOUNT_ID,BUNDLE_ID,SUBSCRIPTION_ID,DESCRIPTION,PLAN_NAME,PHASE_NAME,USAGE_NAME,START_DATE,END_DATE,AMOUNT,RATE,CURRENCY,LINKED_ITEM_ID,CREATED_BY,CREATED_DATE,ACCOUNT_RECORD_ID,TENANT_RECORD_ID,CHILD_ACCOUNT_ID,QUANTITY,PRODUCT_NAME,CATALOG_EFFECTIVE_DATE,EXTERNAL_KEY',
    'dd-Mon-yyyy',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '5e54d79f-f4fe-4ea7-8fd0-71c88a0cdcc4',
    'A_QUANTIFIABLE_ITEM_PRICE_postgres_34',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_quantifiableitemprice',
    'Cloned_From_ID,
 CREATED,
 CURRENCY,
 Fixed_Price,
 ID,
 MAX,
 MIN,
 MODIFIED,
 Plan_Price_ID,
 PRICE,
 Quantifiable_Item_ID',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
stc_marketplace_service_management_quantifiableitemprice)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_QUANTIFIABLE_ITEM_PRICE',
    'Cloned From ID,CREATED,CURRENCY,Fixed Price,ID,MAX,MIN,MODIFIED,Plan Price ID,PRICE,Quantifiable Item ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '416cd49e-db97-4479-9ab2-a8839d92c269',
    'A_PLAN_TO_ITEM_MAPPING_postgres_35',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_planitem',
    'Cloned_From_ID,CREATED,ID,Item_ID,MODIFIED,Plan_ID,QUANTITY,Unit_ID',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
stc_marketplace_service_management_planitem)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_PLAN_TO_ITEM_MAPPING',
    'Cloned From ID,CREATED,ID,Item ID,MODIFIED,Plan ID,QUANTITY,Unit ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'd4058193-004b-45cb-83c7-9f98b06c7ccd',
    'A_PLAN_ITEM_TRANSLATION_postgres_36',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_item_translation',
    'ID,Language_Code,Master_ID,NAME',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
stc_marketplace_service_management_planitem)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_PLAN_ITEM_TRANSLATION',
    'ID,Language Code,Master ID,NAME',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '906ddd68-f3ff-4286-b94c-829c505d27bb',
    'CUSTOMERS_SERVICE_COMMITMENT_postgres_37',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_customers_servicecommitment',
    'CATEGORY,Commitment_Amount,CREATED,Deal_ID,ID,MODIFIED,Service_ID',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
stc_marketplace_customers_servicecommitment)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'CUSTOMERS_SERVICE_COMMITMENT',
    'CATEGORY,Commitment Amount,CREATED,Deal ID,ID,MODIFIED,Service ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '39aee7d4-4df6-4038-9f24-6d0a73eacd27',
    'PRD_VDC_FIN_CUSTOMER_INFO_postgres_38',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'vdc_customer_info',
    'ID,CUSTOMER_ID,CUSTOMER_NAME,PROJECT_ID,USER_ID,SUBSCRIPTION_ID,CREATED,UPDATED,VDC_CONFIG_ID,STATUS,TRIAL_STATUS,CUST_TYPE',
    'source_file is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_VDC_FIN_CUSTOMER_INFO',
    'ID,CUSTOMER_ID,CUSTOMER_NAME,PROJECT_ID,USER_ID,SUBSCRIPTION_ID,CREATED,UPDATED,VDC_CONFIG_ID,STATUS,TRIAL_STATUS,CUST_TYPE',
    'dd-mm-yyyy',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '2be8bae0-fdc3-45d4-a563-01f5affd3a3f',
    'PRD_VDC_FIN_INSATNCE_IMAGE_postgres_39',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'ombilling_instance_image',
    'ID,INSTANCE_ID,IMAGE_ID,VOLUME_ID,CREATED_AT,CREATED,UPDATED',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
ombilling_instance_image)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_VDC_FIN_INSATNCE_IMAGE',
    'ID,INSTANCE_ID,IMAGE_ID,VOLUME_ID,CREATED_AT,CREATED,UPDATED',
    'dd-mm-yyyy',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '0c242514-f78d-484d-bfff-ad9a483fbeb4',
    'PRD_VDC_FIN_SLUG_MAPPING_postgres_40',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'ombilling_slug_mapping',
    'ID,SERVICE,SDP_FLAVOR,OPENSTACK_FLAVOR,SLUG,VDC_ID,CREATED,UPDATED,LIC_FLAVOR',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
ombilling_slug_mapping)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_VDC_FIN_SLUG_MAPPING',
    'ID,SERVICE,SDP_FLAVOR,OPENSTACK_FLAVOR,SLUG,VDC_ID,CREATED,UPDATED,LIC_FLAVOR',
    'dd-mm-yyyy',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '79ae136b-6265-45f3-8ae6-07d0502b1fdb',
    'PRD_DYNAMICS_AOL_postgres_41',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'active_order_line',
    'stcs_circuitid,
 stcs_name,
 stcs_servicecategoryname,
 stcs_ordertypename,
 stcs_productname,
 stcs_otc,
 stcs_mrc,
 stcs_totalamount,
 stcs_orderlinestatusname,
 stcs_orderlinestatusreasonname,
 to_char(createdon,
 ''YYYY-MM-DD HH24:MI:SS'')createdon,
 stcs_accountname,
 stcs_erpbillingaccountname,
 stcs_sendtobillingname,
 stcs_fict_billing_no,
 stcs_financeapprovalstatusname,
 stcs_sendtoerpname,
 stcs_sendtoerpstatusname,
 stcs_speedvaluename,
 to_char(stcs_closuredate,
 ''YYYY-MM-DD HH24:MI:SS'') stcs_closuredate,
 stcs_ordernaturename,
 stcs_subscriptionname,
 stcs_backdateapprovalstatusname,
 stcs_ongoingerporderlineid,
 stcs_ongoingerporderline,
 stcs_ongoingerpordernumber,
 stcs_baseorderlinename,
 stcs_dynamics_order_number,
 stcs_masterorderlinename,
 stcs_ordername,
 stcs_order_number,
 to_char(stcs_erpexpirationdate,
 ''YYYY-MM-DD HH24:MI:SS'')stcs_erpexpirationdate,
  to_char(stcs_expirationdate,
 ''YYYY-MM-DD HH24:MI:SS'') stcs_expirationdate,
 stcs_expirydate,
 stcs_reusestatusname, stcs_accesstypename,
   stcs_diadmaincircuitid,
   stcs_dspcircuitid,
   stcs_circuitvaluename,
   stcs_workordernumber,
   stcs_uninstallworkordernumber,
   stcs_granitenumber,
   stcs_customer_typename,
   stcs_opportunitynumber',
    'stcs_servicecategoryname in (''AwalISP'') or stcs_servicecategoryname like ''%SAT%''',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_DYNAMICS_AOL',
    'CIRCUIT_ID,NAME,SERVICE_CATEGORY,ORDER_TYPE_ORDER_ORDER,PRODUCT,OTC,MRC,TOTAL_AMOUNT,ORDER_LINE_STATUS,ORDER_LINE_STATUS_REASON,CREATED_ON,ACCOUNT,ERP_BILLING_ACCOUNT,SEND_TO_BILLING,FICT_BILLING_NO,FINANCE_TEAM_APPROVAL_STATUS,SEND_TO_ERP,SEND_TO_ERP_STATUS,SPEED,CLOSURE_DATE,ORDER_NATURE,SUBSCRIPTION,BACKDATE_APPROVAL_STATUS,ONGOING_ERP_ORDER_LINE,ONGOING_ERP_ORDER_LINE_ID,ONGOING_ERP_ORDER_NUMBER,BASE_ORDER_LINE,DYNAMICS_ORDER_NUMBER,MASTER_ORDER_LINE,ORDER_1,ORDER_NUMBER,ERP_EXPIRATION_DATE,EXPIRATION_DATE,EXPIRY_DATE,ORDERLINE_USED,STCS_ACCESSTYPENAME,STCS_DIADMAINCIRCUITID,STCS_DSPCIRCUITID,STCS_CIRCUITVALUENAME,STCS_WORKORDERNUMBER,STCS_UNINSTALLWORKORDERNUMBER,STCS_GRANITENUMBER,STCS_CUSTOMER_TYPENAME,STCS_OPPORTUNITYNUMBER',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    'Active Order line - AwalISP',
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Dynamic/Dynamic_AOL',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_pattern": "Active Order line - AwalISP"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '9d1afcb1-76a2-4d94-a6ca-41a996b93028',
    'KILLBILL_ACCOUNTS_postgres_42',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'killbill_accounts',
    'RECORD_ID,
ID,
EXTERNAL_KEY,
EMAIL,
NAME,
FIRST_NAME_LENGTH,
CURRENCY,
BILLING_CYCLE_DAY_LOCAL,
PAYMENT_METHOD_ID,
TIME_ZONE,
LOCALE,
ADDRESS1,
ADDRESS2,
COMPANY_NAME,
CITY,
STATE_OR_PROVINCE,
COUNTRY,
POSTAL_CODE,
PHONE,
MIGRATED,
CREATED_DATE,
CREATED_BY,
UPDATED_DATE,
UPDATED_BY,
TENANT_RECORD_ID,
PARENT_ACCOUNT_ID,
IS_PAYMENT_DELEGATED_TO_PARENT,
REFERENCE_TIME',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
killbill_accounts)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'KILLBILL_ACCOUNTS',
    'RECORD_ID,ID,EXTERNAL_KEY,EMAIL,NAME,FIRST_NAME_LENGTH,CURRENCY,BILLING_CYCLE_DAY_LOCAL,PAYMENT_METHOD_ID,TIME_ZONE,LOCALE,ADDRESS1,ADDRESS2,COMPANY_NAME,CITY,STATE_OR_PROVINCE,COUNTRY,POSTAL_CODE,PHONE,MIGRATED,CREATED_DATE,CREATED_BY,UPDATED_DATE,UPDATED_BY,TENANT_RECORD_ID,PARENT_ACCOUNT_ID,IS_PAYMENT_DELEGATED_TO_PARENT,REFERENCE_TIME',
    'dd-mm-yyyy',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '028a8e86-b37e-4795-94d9-52f74ab46a67',
    'A_KILLBILL_INVOICES_postgres_43',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'killbill_invoices',
    'RECORD_ID,
ID,
ACCOUNT_ID,
INVOICE_DATE,
TARGET_DATE,
CURRENCY,
MIGRATED,
CREATED_BY,
CREATED_DATE,
ACCOUNT_RECORD_ID,
TENANT_RECORD_ID,
PARENT_INVOICE,
STATUS',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
killbill_invoices)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_KILLBILL_INVOICES',
    'RECORD_ID,ID,ACCOUNT_ID,INVOICE_DATE,TARGET_DATE,CURRENCY,MIGRATED,CREATED_BY,CREATED_DATE,ACCOUNT_RECORD_ID,TENANT_RECORD_ID,PARENT_INVOICE,STATUS',
    'dd-mm-yyyy',
    'PROCCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'a29471bd-eb88-4fc1-bfa5-c2216758e689',
    'PRD_WORK_ORDER_TICKET_postgres_44',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'WorkOrders',
    '"number" NUMBER_1,
dv_parent PARENT_CASE,
dv_account CUSTOMER,
dv_asset ASSET,
dv_assignment_group ASSIGNMENT_GROUP,
dv_assigned_to ASSIGNED_TO,
dv_caller CONTACT,
closed_at CLOSED_AT,
dv_closed_by CLOSED_BY,
expected_start EXPECTED_START,
expected_end ESTIMATED_END,
dv_impact IMPACT,
dv_initiated_from INITIATED_FROM,
opened_at OPENED_AT,
dv_opened_by OPENED_BY,
null OPENED_FOR,
dv_priority PRIORITY,
dv_qualification_group QUALIFICATION_GROUP,
dv_state STATE,
dv_u_subscribed_services SUBSCRIBED_SERVICES,
null URGENCY,
work_start WORK_START,
work_end WORK_END,
u_order_type ORDER_TYPE',
    '"number" like ''W%'' or "number" is null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_WORK_ORDER_TICKET',
    'NUMBER_1,PARENT_CASE,CUSTOMER,ASSET,ASSIGNMENT_GROUP,ASSIGNED_TO,CONTACT,CLOSED_AT,CLOSED_BY,EXPECTED_START,ESTIMATED_END,IMPACT,INITIATED_FROM,OPENED_AT,OPENED_BY,OPENED_FOR,PRIORITY,QUALIFICATION_GROUP,STATE,SUBSCRIBED_SERVICES,URGENCY,WORK_START,WORK_END,ORDER_TYPE',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/ServiceNow',
    TRUE,
    '{"legacy_sheet": "Sheet1"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'e33df3a2-5f71-416f-b7e8-fa0eba0828f6',
    'PRD_GRANITE_MRS_FILES_csv_45',
    'csv',
    NULL,
    '/home/sdev/ROOT/Granite/MRS',
    'S.No.,Circuit Name,Order Number,Parent Order No,Bandwidth,Category,Status,Order Stage,Order Stage Start Date,Track Order,Department,Sector,Customer Name,Fict Billing No,Customer Ref,Svc Priority,Isp Name,Account Manager,Projectid,A Site Name,A City,A Side Clli,A District,A Site Number,Z Site Name,Z Side Clli,Z City,Z District,Z Site Number,Ordered,Completed,Installed,In Service,Customer Id,Icms No,A Side Ref Tel Number,Z Side Ref Tel Number,Sam Info,Access Technology Z,Customer Sam Info,Access Technology A,Mrs Installed,Used Access Technology A,Used Access Technology Z,Ntu Provided Loc A,Ntu Provided Loc B,Ntu Model Loc A,Ntu Model Loc B',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_GRANITE_MRS_FILES',
    'S_NO,CIRCUIT_NAME,ORDER_NUMBER,PARENT_ORDER_NO,BANDWIDTH,CATEGORY,STATUS,ORDER_STAGE,ORDER_STAGE_START_DATE,TRACK_ORDER,DEPARTMENT,SECTOR,CUSTOMER_NAME,FICT_BILLING_NO,CUSTOMER_REF,SVC_PRIORITY,ISP_NAME,ACCOUNT_MANAGER,PROJECTID,A_SITE_NAME,A_CITY,A_SIDE_CLLI,A_DISTRICT,A_SITE_NUMBER,Z_SITE_NAME,Z_SIDE_CLLI,Z_CITY,Z_DISTRICT,Z_SITE_NUMBER,ORDERED,COMPLETED,INSTALLED,IN_SERVICE,CUSTOMER_ID,ICMS_NO,A_SIDE_REF_TEL_NUMBER,Z_SIDE_REF_TEL_NUMBER,SAM_INFO,ACCESS_TECHNOLOGY_Z,CUSTOMER_SAM_INFO,ACCESS_TECHNOLOGY_A,MRS_INSTALLED,USED_ACCESS_TECHNOLOGY_A,USED_ACCESS_TECHNOLOGY_Z,NTU_PROVIDED_LOC_A,NTU_PROVIDED_LOC_B,NTU_MODEL_LOC_A,NTU_MODEL_LOC_B',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    'Granite_MRS',
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/GraniteMRS',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_pattern": "Granite_MRS", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'e66befab-2411-4af7-8168-cce3bcaad860',
    'PRD_CLOUDEVENT_LOG_postgres_46',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_events_event',
    'API_VERSION,
 CONTENT_TYPE_ID,
 CREATED,
 ID,
 MODIFIED,
 NEXT_RETRY_TIME,
 OBJECT_ID,
 REFERENCE,
 SERVICE_ID,
 SIGNATURE,
 STATUS,
 content_type_id,
 URL
 webhook_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
stc_marketplace_events_event)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_CLOUDEVENT_LOG',
    'API_VERSION,CONTENT_TYPE_ID,CREATED,ID,MODIFIED,NEXT_RETRY_TIME,OBJECT_ID,REFERENCE,SERVICE_ID,SIGNATURE,STATUS,TYPE,URL,WEB_HOOK_ID',
    'dd-Mon-yyyy',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'c58f4cee-43b2-43f4-8990-9d8588022128',
    'STCS_STC_SERVICES_DB_PUBLIC_STC_ACCOUNT_postgres_47',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_account',
    'ID,
 CARTWHEEL_ACCOUNT_ID,
 CUSTOMER_NUMBER,
 CUSTOMER_ID,
 CUSTOMER_ID_TYPE,
 MOBILE_NO,
 ACCOUNT_NUMBER,
 SERVICE_CODE,
 FICTIOUS_SERVICE_NUMBER,
 CREATED_AT,
 LAST_UPDATED,
 EFFECTIVE_DATE,
 STATUS,
 type,
 IS_TESTING_ACCOUNT,
 SERVICE_ORDER_CREATION_DATE,
 IS_BSST_ACCOUNT,
 STC_SERVICE_ORDER,
 BILL_LANGUAGE,
 CUSTOMER_NAME,
 ORDER_TYPE,
 ORDER_REASON,
 STC_SERVICE_STATUS,
 STC_RESPONSE_ID,
 STC_TASK_ID,
 SERVICE_ORDER_CREATED_AT,
 ORDER_STATUS,
 ERROR_CODE,
 ERROR_DESC',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
stc_account)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'STCS_STC_SERVICES_DB_PUBLIC_STC_ACCOUNT',
    'ID,CARTWHEEL_ACCOUNT_ID,CUSTOMER_NUMBER,CUSTOMER_ID,CUSTOMER_ID_TYPE,MOBILE_NO,ACCOUNT_NUMBER,SERVICE_CODE,FICTIOUS_SERVICE_NUMBER,CREATED_AT,LAST_UPDATED,EFFECTIVE_DATE,STATUS,type,IS_TESTING_ACCOUNT,SERVICE_ORDER_CREATION_DATE,IS_BSST_ACCOUNT,STC_SERVICE_ORDER,BILL_LANGUAGE,CUSTOMER_NAME,ORDER_TYPE,ORDER_REASON,STC_SERVICE_STATUS,STC_RESPONSE_ID,STC_TASK_ID,SERVICE_ORDER_CREATED_AT,ORDER_STATUS,ERROR_CODE,ERROR_DESC',
    'dd-mm-yyyy',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '63c9a85b-97de-4d9f-9e86-e5a1110100dd',
    'STC_SERVICES_DB_PUBLIC_INVOICE_ITEM_postgres_48',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_invoice_item',
    'INVOICE_ITEM_ID,
 INVOICE_ID,
 ACCOUNT_ID,
 AMOUNT,
 CATEGORY,
 CREATION_DATE,
 START_DATE,
 END_DATE,
 INVOICE_ITEM_TYPE,
 CBA_ADJ_AMOUNT,
 INVOICE_TYPE,
 STATUS,
 STATUS_REASON,
 APPROVER_ID,
 CREATED_AT,
 UPDATED_AT,
 INVOICE_DATE',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')
) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
stc_invoice_item)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'STC_SERVICES_DB_PUBLIC_INVOICE_ITEM',
    'INVOICE_ITEM_ID,INVOICE_ID,ACCOUNT_ID,AMOUNT,CATEGORY,CREATION_DATE,START_DATE,END_DATE,INVOICE_ITEM_TYPE,CBA_ADJ_AMOUNT,INVOICE_TYPE,STATUS,STATUS_REASON,APPROVER_ID,CREATED_AT,UPDATED_AT,INVOICE_DATE',
    'dd-mm-yyyy',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '3ad7458e-08b0-4cec-876c-4cc2575b1af7',
    'A_STC_CDR_INVOICES_postgres_49',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_cdr x
full join
    (
 select
  cdr_id,
  invoice_item_id,
  "Source_File" as source_file2
 from
  stc_cdr_invoices) a
on
 x.id = a.cdr_id
 and
    SUBSTRING(x.Source_File,
 9,
 10) = SUBSTRING(a.source_file2,
 18,
 10)',
    'ID,
CDR_BATCH_ID,
ACCOUNT_ID,
CATEGORY,
AMOUNT,
date,
STATUS,
IS_BILLED,
BILLED_DATE,
IS_BSST,
VAT_PERIOD,
CREATED_AT,
INVOICE_ID,
a.invoice_item_id,
a.cdr_id',
    '( TO_DATE(to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
  stc_cdr)
 and
TO_DATE( to_Date(replace((SUBSTRING(source_file2
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),
 ''yyyy-MM-dd'')) = (
 select
  max (
   to_Date(replace((SUBSTRING(source_file
 from
  ''\d{4}_\d{2}_\d{2}'')),
  ''_'',
  ''-''),
  ''yyyy-MM-dd''))
 from
  stc_cdr_invoices))',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_STC_CDR_INVOICES',
    'ID,CDR_BATCH_ID,ACCOUNT_ID,CATEGORY,AMOUNT,date,STATUS,IS_BILLED,BILLED_DATE,IS_BSST,VAT_PERIOD,CREATED_AT,INVOICE_ID,INVOICE_ITEM_ID,CDR_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'bb81690b-404e-4c2c-9b41-5e6a605ae636',
    'A_SUBSCRIPTION_SUBSCRIPTION_postgres_50',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_subscription_subscription',
    'attachment,base_subscription_id,canceled_at,created,customer_id,datacenter_id,dismissed,end_date,id,installment_duration_id,instructions,items_fixed_price,items_price,landing_page_url,management_page_url,modified,name,override_fixed_price,override_price,parent_subscription_id,plan_id,plan_price_id,price_list_id,project_number,service_id,start,status,status_message,status_reason,opportunity_number,partner_name,created_remotely,null as extra_fields_unmasked',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_subscription_subscription)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_SUBSCRIPTION_SUBSCRIPTION',
    'ATTACHMENT,Base Subscription ID,Canceled At,CREATED,Customer ID,Datacenter ID,DISMISSED,End Date,ID,Installment Duration ID,INSTRUCTIONS,Items Fixed Price,Items Price,Landing Page URL,Management Page URL,MODIFIED,NAME,Override Fixed Price,Override Price,Parent Subscription ID,Plan ID,Plan Price ID,Price List ID,Project Number,Service ID,Start,STATUS,Status Message,Status Reason,Opportunity Number,Partner Name,Created Remotely,Extra Fields Unmasked',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '0afa123a-de2c-45fa-aa33-6537205d4147',
    'A_MODAR_USAGE_postgres_51',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'modar_usage',
    'id,uuid,tenant_id,service_id,subscription_id,slug_name,quantity,calculation_time,next_usage_date,reported,customer_type,created_at,updated_at,deleted_at,deleted,resource_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from modar_usage)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_MODAR_USAGE',
    'ID,UUID,TENANT_ID,SERVICE_ID,SUBSCRIPTION_ID,SLUG_NAME,QUANTITY,CALCULATION_TIME,NEXT_USAGE_DATE,REPORTED,CUSTOMER_TYPE,CREATED_AT,UPDATED_AT,DELETED_AT,DELETED,RESOURCE_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'c366df35-a19e-4639-a882-abef7647a151',
    'A_SDDC_FLEX_USAGE_postgres_52',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'sddc_usage',
    'id,uuid,tenant_id,service_id,subscription_id,slug_name,quantity,calculation_time,next_usage_date,reported,customer_type,created_at,updated_at,deleted_at,deleted,resource_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from sddc_usage)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_SDDC_FLEX_USAGE',
    'ID,UUID,TENANT_ID,SERVICE_ID,SUBSCRIPTION_ID,SLUG_NAME,QUANTITY,CALCULATION_TIME,NEXT_USAGE_DATE,REPORTED,CUSTOMER_TYPE,CREATED_AT,UPDATED_AT,DELETED_AT,DELETED,RESOURCE_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'fd1a94c6-cba0-436e-bbac-a79227cb7b81',
    'A_VCD_ALL_USAGES_postgres_53',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'vcd_all_usages',
    'id,customer_id,subscription_id,project_id,slug_name,resource_type,count,reported,time_from,time_to,customer_type,created_at,updated_at,deleted_at,deleted,resource_id,ip_ref_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from vcd_all_usages)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_VCD_ALL_USAGES',
    'ID,CUSTOMER_ID,SUBSCRIPTION_ID,PROJECT_ID,SLUG_NAME,RESOURCE_TYPE,COUNT,REPORTED,TIME_FROM,TIME_TO,CUSTOMER_TYPE,CREATED_AT,UPDATED_AT,DELETED_AT,DELETED,RESOURCE_ID,IP_REF_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '977ae05a-1aa9-429b-ae43-4ab79b6c041b',
    'PRD_VDC_FIN_FIP_postgres_54',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'fip',
    'ip_id,ip,project_id,tenant_name,subscription_id,customer_id,create_date,delete_date,updated as update_date,status as billing_status',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from fip)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_VDC_FIN_FIP',
    'IP_ID,IP,PROJECT_ID,TENANT_NAME,SUBSCRIPTION_ID,CUSTOMER_ID,CREATE_DATE,DELETE_DATE,UPDATE_DATE,BILLING_STATUS',
    'dd-Mon-yyyy',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '9bd2cc39-cf78-47a7-a7b1-b3d9b1c330e7',
    'PRD_VDC_FIN_INSTANCE_postgres_55',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'instance',
    'instance_name,instance_id,project_id, customer_name as tenant_name, subscription_id,customer_id,create_date,delete_date, updated as update_date, flavor_name, recon_status as billing_status, sub_status as vm_status, flavor as flvor_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from instance)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_VDC_FIN_INSTANCE',
    'INSTANCE_NAME,INSTANCE_ID,PROJECT_ID,TENANT_NAME,SUBSCRIPTION_ID,CUSTOMER_ID,CREATE_DATE,DELETE_DATE,UPDATE_DATE,FLAVOR_NAME,BILLING_STATUS,VM_STATUS,FLVOR_ID',
    'dd-mm-yyyy',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'fde1cbd6-41a6-4aa6-8628-77e6a37e9038',
    'PRD_VDC_FIN_VOLUME_postgres_56',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'volume',
    'volume_id,display_name,project_id,tenant_name,subscription_id,customer_id,create_date,delete_date,updated as update_date, recon_status as billing_status, size as siz, unit_type as volume_type',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from volume)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_VDC_FIN_VOLUME',
    'VOLUME_ID,DISPLAY_NAME,PROJECT_ID,TENANT_NAME,SUBSCRIPTION_ID,CUSTOMER_ID,CREATE_DATE,DELETE_DATE,UPDATE_DATE,BILLING_STATUS,SIZ,VOLUME_TYPE',
    'dd-mm-yyyy',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '571d7054-df67-4a4d-acae-a7e575634ab6',
    'A_USAGE_REPORT_DETAIL_postgres_57',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'vdc_usage_report_details_data',
    'id,report_id,slug,count,service,report_unit,created,updated',
    'UPDATED >= date_trunc(''month'', CURRENT_DATE - interval ''1 month'')
and UPDATED< date_trunc(''month'', CURRENT_DATE)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_USAGE_REPORT_DETAIL',
    'ID,REPORT_ID,SLUG,COUNT,SERVICE,REPORT_UNIT,CREATED,UPDATED',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Source_File"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '95c90fe6-b346-48f3-9010-0685703b89de',
    'PRD_EDGE_GATEWAY_postgres_58',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'edge_gateway',
    'id,organization_id,org_vdc_id,edge_name,edge_gateway_id,edge_gateway_type,status,created,updated,vdc_name,ha_enabled',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from edge_gateway)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_EDGE_GATEWAY',
    'ID,ORGANIZATION_ID,ORG_VDC_ID,EDGE_NAME,EDGE_GATEWAY_ID,EDGE_GATEWAY_TYPE,STATUS,CREATED,UPDATED,VDC_NAME,HA_ENABLED',
    'dd-Mon-yyyy',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_extension_filter": "all", "file_name_original_col": "SOURCE_FILE"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'e50f0cb0-aadb-4755-b854-0e6c81924a5f',
    'PRD_PO_DISTRIBUTION_postgres_59',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'PO_DISTRIBUTION_REPORT',
    'PO_NUMBER,PO_STATUS,to_char(to_date(PO_CREATION_DATE,''mm/dd/yyyy hh24:mi:ss''),''mm/dd/yyyy hh24:mi:ss'') as PO_CREATION_DATE,US_ORG_NAME_DESTINATION,DISTRIBUTION_TYPE,PO_LINE_NUMBER,RELEASE_NUM,HEADER_ATTRIBUTE,DIM_ORG_NAME_SHIP_TO,FULL_NAME_DELIVER_TO,SECTION_ORGANIZATION_NAME,DEPT_ORGANIZATION_NAME,SECTR_ORGANIZATION_NAME,DIV_ORGANIZATION_NAME,PO_CHARGE_ACCOUNT,PROJECT_NUMBER,PROJECT_NAME,STCS_CHANNEL_SEGMENT,STCS_PROJECT_BILLING_METHOD,STCS_SERVICE_TYPE,ERP_SALES_CLASS,ERP_CUSTOMER_SEGMENT,CUSTOMER_CLASS_CODE,PORTFOLIO,ERP_CUSTOMER_NAME,PROJECT_MANAGER,TASK_NUMBER,EXPENDITURE_TYPE,CLOSER_CODE,PO_DISTRIBUTION_KEY,PR_NUMBER,LINE_TYPE,VENDOR_NAME,VENDOR_NUMBER,VENDOR_CATEGORY,COUNTRY,ITEM_CODE,PO_LINES_VENDOR_PRODUCT_NUM,PO_DESCRIPTION,ITEM_DESC,UOM,HEADERS_CURRENCY_CODE,RATE,LINES_UNIT_PRICE,QUANTITY_ORDERED,QUANTITY_DELIVERED,QUANTITY_BILLED,QUANTITY_CANCELLED,QUANTITY_OPEN_FOR_GRN,AMOUNT_BILLED,AMOUNT_ORDERED,AMOUNT_DELIVERED,AMOUNT_CANCELLED,AMOUNT_OPEN_FOR_GRN,AMOUNT_BILLED_SAR,AMOUNT_ORDERED_SAR,AMOUNT_DELIVERED_SAR,AMOUNT_CANCELLED_SAR,AMOUNT_OPEN_FOR_GRN_SAR,PARTNER_NAME',
    'PO_NUMBER is null or PO_NUMBER is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_PO_DISTRIBUTION',
    'PO_NUMBER,PO_STATUS,PO_CREATION_DATE,US_ORG_NAME_DESTINATION,DISTRIBUTION_TYPE,PO_LINE_NUMBER,RELEASE_NUM,HEADER_ATTRIBUTE,DIM_ORG_NAME_SHIP_TO,FULL_NAME_DELIVER_TO,SECTION_ORGANIZATION_NAME,DEPT_ORGANIZATION_NAME,SECTR_ORGANIZATION_NAME,DIV_ORGANIZATION_NAME,PO_CHARGE_ACCOUNT,PROJECT_NUMBER,PROJECT_NAME,STCS_CHANNEL_SEGMENT,STCS_PROJECT_BILLING_METHOD,STCS_SERVICE_TYPE,ERP_SALES_CLASS,ERP_CUSTOMER_SEGMENT,CUSTOMER_CLASS_CODE,PORTFOLIO,ERP_CUSTOMER_NAME,PROJECT_MANAGER,TASK_NUMBER,EXPENDITURE_TYPE,CLOSER_CODE,PO_DISTRIBUTION_KEY,PR_NUMBER,LINE_TYPE,VENDOR_NAME,VENDOR_NUMBER,VENDOR_CATEGORY,COUNTRY,ITEM_CODE,PO_LINES_VENDOR_PRODUCT_NUM,PO_DESCRIPTION,ITEM_DESC,UOM,HEADERS_CURRENCY_CODE,RATE,LINES_UNIT_PRICE,QUANTITY_ORDERED,QUANTITY_DELIVERED,QUANTITY_BILLED,QUANTITY_CANCELLED,QUANTITY_OPEN_FOR_GRN,AMOUNT_BILLED,AMOUNT_ORDERED,AMOUNT_DELIVERED,AMOUNT_CANCELLED,AMOUNT_OPEN_FOR_GRN,AMOUNT_BILLED_SAR,AMOUNT_ORDERED_SAR,AMOUNT_DELIVERED_SAR,AMOUNT_CANCELLED_SAR,AMOUNT_OPEN_FOR_GRN_SAR',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_PO_distribution',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '0ef96d90-2039-4c9a-9fe6-56c7cfe3d6a2',
    'PRD_STCS_GRN_PROJECT_REPORT_postgres_60',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'NEW_GRN_REPORT',
    'null,ORGANIZATION_CODE,ORG_NAME,GRN_NO,SUBSTRING(GRN_DATE, 1,7) || SUBSTRING(GRN_DATE, 10,2) as GRN_DATE,SUBSTRING(GRN_CREATION_DATE, 1,7) || SUBSTRING(GRN_CREATION_DATE, 10,2) as GRN_CREATION_DATE,RECEIVER,PO_NUM as PO_NUMBER,PO_TYPE,SUPP_NAME as SUPPLIER_NAME,SUPP_SITE as SUPPLIER_SITE,COUNTRY,PO_CURR as PO_CURRENCY,LINE_NUM as PO_LINE_NO,PO_REL_NO as PO_RELEASE_NO,STCS_ITEM_CODE,STCS_ITEM_DESC,SUPP_ITEM_CODE as SUPPLIER_ITEM_CODE,GRN_QTY as GRN_QUANTITY,UOM,PO_UNIT_PRICE_IN_SAR,TOTAL_PRICE_IN_SAR,DEST_TYPE as DESTINATION_TYPE,CHARGE_ACCOUNT as CHARGE_ACCOUNT,SUBINVENTORY,MAWB_NUM as MAWB_NUMBER,INV_LOCATOR as LOCATOR,RET_TO_SUPP as RETURN_TO_SUPPLIER,RET_QTY as RETURN_QUANTITY,PROJECT_NAME as PROJECT,PROJECT_DESC ,PROJECT_ORG,COMMERCIALINV,SHIPSET,PACKING_SLIP',
    'ORGANIZATION_CODE is null or ORGANIZATION_CODE is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_STCS_GRN_PROJECT_REPORT',
    'SR_NO,ORGANIZATION_CODE,ORG_NAME,GRN_NO,GRN_DATE,GRN_CREATION_DATE,RECEIVER,PO_NUMBER,PO_TYPE,SUPPLIER_NAME,SUPPLIER_SITE,COUNTRY,PO_CURRENCY,PO_LINE_NO,PO_RELEASE_NO,STCS_ITEM_CODE,STCS_ITEM_DESC,SUPPLIER_ITEM_CODE,GRN_QUANTITY,UOM,PO_UNIT_PRICE_IN_SAR,TOTAL_PRICE_IN_SAR,DESTINATION_TYPE,CHARGE_ACCOUNT,SUBINVENTORY,MAWB_NUMBER,LOCATOR,RETURN_TO_SUPPLIER,RETURN_QUANTITY,PROJECT,PROJECT_DESC,PROJECT_ORG',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_GRN_Report',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '536c8881-b679-464c-9a96-c5bfae03d7dd',
    'PRD_STCS_PO_PROJECT_REPORT_postgres_61',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'PO_PROJECT_REPORT',
    'PO_NUMBER,to_Char(to_timestamp(PO_DATE,''YYYY-MM-DDTHH24:MI:SS''),''YYYY-MM-DDTHH24:MI:SS'')||''.000+03:00'' as PO_DATE,CANCELLATION_STATUS,PO_STATUS,PO_AMOUNT,CURRENCY_CODE as CURRENCY,AMOUNT_IN_SAR as PO_AMOUNT_IN_SAR,VENDOR_NAME,PROJECT_NUMBER',
    'PO_NUMBER is null or PO_NUMBER is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_STCS_PO_PROJECT_REPORT',
    'PO_NUMBER,PO_DATE,CANCELLATION_STATUS,PO_STATUS,PO_AMOUNT,CURRENCY,PO_AMOUNT_IN_SAR,VENDOR_NAME,PROJECT_NUMBER',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_PO_Project_Report',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '4243c670-0133-41cb-9391-75bdd2a748f4',
    'STC_MP_service_management_flavoritem_postgres_62',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_service_management_flavoritem',
    'id,value,cloned_from_id,flavor_id,item_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_service_management_flavoritem)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'STC_MP_service_management_flavoritem',
    'ID,VALUE,CLONED_FROM_ID,FLAVOR_ID,ITEM_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'eb7cc314-254b-4b9a-b2c9-cbde9848d45c',
    'CS_ORDERS_postgres_63',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'cs_orders',
    'id,user_id,service_id,subscription_id,order_name,dc_name,request_type,status,created_at,updated_at,deleted_at,deleted,external_system_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from cs_orders)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'CS_ORDERS',
    'ID,USER_ID,SERVICE_ID,SUBSCRIPTION_ID,ORDER_NAME,DC_NAME,REQUEST_TYPE,STATUS,CREATED_AT,UPDATED_AT,DELETED_AT,DELETED,EXTERNAL_SYSTEM_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '7e92c666-88e2-4012-b012-110d4f3e96f7',
    'MP_SUB_QUANTIFIABLE_INSTALLMENT_postgres_64',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_subscription_subscriptionquantifiableinstallmen',
    'id,created,modified,quantity,quantifiable_installment_item_price_id,subscription_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_subscription_subscriptionquantifiableinstallmen)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'MP_SUB_QUANTIFIABLE_INSTALLMENT',
    'ID,CREATED,MODIFIED,QUANTITY,QUANTIFIABLE_INSTALLMENT_ITEM_PRICE_ID,SUBSCRIPTION_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '115c5a13-e1c3-4345-b8a2-42038efde442',
    'CS_RESOURCES_postgres_65',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'cs_resources',
    'id,name,service_id,subscription_id,bill_period,repeated,created_time,retire_time,billing_cycle_day,status,sub_status,recon_status,provisioned_date,de_provisioned_date,updated_time,consider_update,slug_name,quantity,unit_type,order_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from cs_resources)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'CS_RESOURCES',
    'ID,RESOURCE_NAME,SERVICE_ID,SUBSCRIPTION_ID,BILL_PERIOD,REPEATED,CREATED_TIME,RETIRE_TIME,BILLING_CYCLE_DAY,STATUS,SUB_STATUS,RECON_STATUS,PROVISIONED_DATE,DE_PROVISIONED_DATE,UPDATED_TIME,CONSIDER_UPDATE,SLUG_NAME,QUANTITY,UNIT_TYPE,ORDER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'a7b03a06-3b22-44d6-a97a-16910188529e',
    'MP_VIRTUALCREDIT_ACCOUNTMANAGERCREDIT_postgres_66',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_virtualcredit_accountmanagercredit',
    'id,created,modified,amount,account_manager_id,sales_manager_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_virtualcredit_accountmanagercredit)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'MP_VIRTUALCREDIT_ACCOUNTMANAGERCREDIT',
    'ID,CREATED,MODIFIED,AMOUNT,ACCOUNT_MANAGER_ID,SALES_MANAGER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '36aefdac-3597-4531-9ce2-d8766fe9e58f',
    'MP_VIRTUALCREDIT_DIRECTCUSTOMERCREDITTRANSACTION_postgres_67',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_virtualcredit_directcustomercredittransaction',
    'id,created,modified,amount,reason,customer_id,sales_manager_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_virtualcredit_directcustomercredittransaction)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'MP_VIRTUALCREDIT_DIRECTCUSTOMERCREDITTRANSACTION',
    'ID,CREATED,MODIFIED,AMOUNT,REASON,CUSTOMER_ID,SALES_MANAGER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '02b6382a-2ee1-4824-9798-28a72e4839f1',
    'MP_VIRTUALCREDIT_CUSTOMERCREDIT_postgres_68',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_virtualcredit_customercredit',
    'id,created,modified,amount,account_manager_id,customer_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_virtualcredit_customercredit)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'MP_VIRTUALCREDIT_CUSTOMERCREDIT',
    'ID,CREATED,MODIFIED,AMOUNT,ACCOUNT_MANAGER_ID,CUSTOMER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '620c552e-24da-4ab0-8997-e52b8fd6c7a0',
    'MP_VIRTUALCREDIT_postgres_69',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_virtualcredit_virtualcredit',
    'id,created,modified,po_number,amount,attachment,added_by_id,returned_from_account_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_virtualcredit_virtualcredit)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'MP_VIRTUALCREDIT',
    'ID,CREATED,MODIFIED,PO_NUMBER,AMOUNT,ATTACHMENT,ADDED_BY_ID,RETURNED_FROM_ACCOUNT_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '5627dc00-a521-4746-8e2b-2264f32c590d',
    'MP_VOUCHERS_VOUCHERCREDITPOOL_postgres_70',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_vouchers_vouchercreditpool',
    'id,created,modified,po_number,attachment,amount,type,reason,user_id,voucher_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_vouchers_vouchercreditpool)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'MP_VOUCHERS_VOUCHERCREDITPOOL',
    'ID,CREATED,MODIFIED,PO_NUMBER,ATTACHMENT,AMOUNT,VOUCHER_TYPE,REASON,USER_ID,VOUCHER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '577f6c7a-0491-4f8b-8939-256c47addfda',
    'MP_VOUCHERTRANSACTION_postgres_71',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_vouchers_vouchertransaction',
    'id,created,modified,amount,customer_id,voucher_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_vouchers_vouchertransaction)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'MP_VOUCHERTRANSACTION',
    'ID,CREATED,MODIFIED,AMOUNT,CUSTOMER_ID,VOUCHER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '755a3990-7049-4077-bd75-dd4cd36563c4',
    'MP_VOUCHER_SERVICES_postgres_72',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_vouchers_voucher_services',
    'id,voucher_id,service_id',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_vouchers_voucher_services)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'MP_VOUCHER_SERVICES',
    'ID,VOUCHER_ID,SERVICE_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '6522e3e7-780e-460b-b0b2-ff077ca6ae52',
    'MP_VOUCHER_postgres_73',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_vouchers_voucher',
    'id,created,modified,amount,code,status,duration,customer_id,user_id,expiry_date,end_date',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_vouchers_voucher)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'MP_VOUCHER',
    'ID,CREATED,MODIFIED,AMOUNT,CODE,STATUS,DURATION,CUSTOMER_ID,USER_ID,EXPIRY_DATE,END_DATE',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '4c517a04-4b3c-4c0d-a03a-c102651b390b',
    'PRD_ACTIVEDIA_postgres_74',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'Row_Data',
    'null s_no,circuit_id as circuitid,ip_address as p2p,null,english_name as customername,service_staus as graniteservicestaus,speed,interface_ipaddress,ip_custom,pe_interface,case when ismrs_1 = 1 then ''true'' when ismrs_1 = 0 then ''false'' when ismrs_1 is null then null end as ismrs,pe_status,pe,pe_gef,decomissioneddate,activation_date,case when sam = 1 then ''true'' when sam = 0 then ''false'' when sam is null then null end as sam',
    'name=''AWALISP''',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_ACTIVEDIA',
    'S_NO,CIRCUITID,P2P,SHORTCODE,CUSTOMERNAME,GRANITESERVICESTAUS,SPEED,INTERFACE_IPADDRESS,IP_CUSTOM,PE_INTERFACE,ISMRS,PE_STATUS,PE,PE_GEF,DECOMISSIONDATE,ACTIVATION_DATE,ISSAM',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    'PRD_ACTIVEDIA',
    'PRD_ACTIVEDIA',
    '/u01/RA_OPS/Test_New_Loader/Final/ACTIVEDIA',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_pattern": "PRD_ACTIVEDIA", "file_extension_filter": "PRD_ACTIVEDIA"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '2bff9edf-331c-4573-aea0-906a4cfedf00',
    'PRD_ACTIVESHABIK_postgres_75',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'Row_Data',
    'null s_no,circuit_id,router_serial_number,oob_mac_address,site_name as address,ip_address,null tags',
    'name=''SHABIK''',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_ACTIVESHABIK',
    'S_NO,NAME,SERIAL,MAC,ADDRESS,LANIP,TAGS',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    'PRD_ACTIVESHABIK',
    'PRD_ACTIVESHABIK',
    '/u01/RA_OPS/Test_New_Loader/Final/ACTIVEDIA',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_pattern": "PRD_ACTIVESHABIK", "file_extension_filter": "PRD_ACTIVESHABIK"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'e9c37a2b-73f8-4c82-988b-0dddfc22f7fe',
    'PRD_ACTIVE_MLS_postgres_76',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'Row_Data',
    'circuit_id,router_serial_number,oob_mac_address,site_name as address,ip_address,null tags',
    'name=''MLS''',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_ACTIVE_MLS',
    'NAME,SERIAL,MAC,ADDRESS,LANIP,TAGS',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    'PRD_ACTIVE_MLS',
    'PRD_ACTIVE_MLS',
    '/u01/RA_OPS/Test_New_Loader/Final/ACTIVEDIA',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_pattern": "PRD_ACTIVE_MLS", "file_extension_filter": "PRD_ACTIVE_MLS"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '361cc9bb-fc53-4133-b92e-175c11dcee0a',
    'PRD_ACTIVEMODAR_postgres_77',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'Row_Data',
    'null s_no,circuit_id,english_name as customername,english_name_1 as regionname,english_name_2 as cityname,site_name as sitename,latitude,longitude,name_5 as network,router_serial_number as serial,oob_mac_address as mac,ip_address as lanip,comments as note,null tags,null devicetype,case when wifianlaytics = 1 then ''true'' when wifianlaytics = 0 then ''false'' when wifianlaytics is null then null end as wifianlaytics, case when locationbasedservice = 1 then ''true'' when locationbasedservice = 0 then ''false'' when locationbasedservice is null then null end as locationbasedservice',
    'name=''SmartNetwork''',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_ACTIVEMODAR',
    'S_NO,CIRCUITID,CUSTOMERNAME,REGIONNAME,CITYNAME,SITENAME,LATITUDE,LONGITUDE,NETWORK,SERIAL,MAC,LANIP,NOTE,TAGS,DEVICETYPE,WIFIANLAYTICS,LOCATIONBASEDSERVICE',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    'PRD_ACTIVEMODAR',
    'PRD_ACTIVEMODAR',
    '/u01/RA_OPS/Test_New_Loader/Final/ACTIVEDIA',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_pattern": "PRD_ACTIVEMODAR", "file_extension_filter": "PRD_ACTIVEMODAR"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'b5865f99-b817-4f08-a979-bd6ca8a56461',
    'PRD_ACTIVEVSAT_postgres_78',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'Row_Data',
    'null S_NO,Circuit_ID,IP_ADDRESS,null SHORTCODE,english_name,FICT_BILLING_NO,GraniteBW,case when Hajj = 1 then ''Yes'' when Hajj = 0 then ''No'' when Hajj is null then null end as Hajj,LATITUDE,LONGITUDE,Service_Staus,Site_Name,english_name_1,english_name_2,case when VIP = 1 then ''True'' when VIP = 0 then ''False'' when VIP is null then null end as VIP,Product,ParentCustomerName,MainApplication,null MOBILITYVAS,null MRSVAS,ActualAccessSpeed,null MODEMTYPE,null MODEMSERIALNUMBER,null ANTENNATYPE,null ANTENNASIZE,case when IsMRS = 1 then ''True'' when IsMRS = 0 then ''False'' when IsMRS is null then null end as IsMRS,null CONTRACTEDBANDWIDTHDOWNLOADCIRBPS,null CONTRACTEDBANDWIDTHUPLOADCIRBPS,CONTRACTEDBANDWIDTHDOWNLOADMIRBPS,CONTRACTEDBANDWIDTHUPLOADMIRBPS,CONTRACTEDBANDWIDTHDOWNLOADPOOLBPS,CONTRACTEDBANDWIDTHUPLOADPOOLBPS,ACTUALBANDWIDTHRESERVATIONDOWNLOADCIRBPS,ACTUALBANDWIDTHRESERVATIONUPLOADCIRBPS,ACTUALBANDWIDTHRESERVATIONDOWNLOADMIRBPS,ACTUALBANDWIDTHRESERVATIONUPLOADMIRBPS,ACTUALBANDWIDTHRESERVATIONDOWNLOADPOOLBPS,ACTUALBANDWIDTHRESERVATIONUPLOADPOOLBPS,PARENTCUSTOMERNAME,null MAINBACKHAULINGCIRCUIT,null BACKUPBACKHAULINGCIRCUIT,VSATInstallationDate,VSATDecommissioningDate,ParentCustomerNameAR,null CUSTOMERID,null CUSTOMERIDTYPE,null CUSTOMERWEBSITE,null CUSTOMERSECTOR,null CUSTOMERTYPE,null STCVIP,null BANDWIDTHASSIGNMENTMETHOD,PackageClass,null TOPOLOGY,null HUBNETWORKINROUTEGROUP,null NETWORKINROUTEGROUPCAPACITY,null STCPE,null STCVLAN,null MODEMMANAGEMENTIPTYPE,null MODEMMANAGEMENTIP,null MODEMLANIPTYPE,null MODEMLANIP,null MRSIP,null SITENAMEAR,null SITENATURE,null ANTENNACODE,null BUCTYPE,null BUCSIZE,null BUCSERIAL,null LNBTYPE,null LNBSERIAL,null MODEMLICENSE,null ACCELERATORTYPE,null ACCELERATORLICENSE,null ACCELERATORSERIAL,null GRANITEORDERSTAGE,null ORDERINGRECEIVEDATE,null DECOMMISSIONINGRECEIVEDATE,null HUB_SITE_NAME,null HUB_SITENAMEAR,null HUB_SITENATURE,null HUB_LATITUDE,null HUB_LONGITUDE,null HUB_ANTENNATYPE,null HUB_ANTENNASIZE,null HUB_ANTENNACODE,null HUB_BUCTYPE,null HUB_BUCSIZE,null HUB_BUCSERIAL,null HUB_LNBTYPE,null HUB_LNBSERIAL,null HUB_MODEMTYPE,null HUB_MODEMLICENSE,null HUB_MODEMSERIALNUMBER,null HUB_ACCELERATORTYPE,null HUB_ACCELERATORLICENSE,null HUB_ACCELERATORSERIAL,null LNB_LO_FREQUENCY,null HUB_LNB_LO_FREQUENCY,null HUB_CITY,null HUB_REGION,null HUBNETWORK,null HUBNETWORKFORWARDCAPACITY,null NETWORKRETURNCAPACITY,null INROUTEGROUP,null INROUTEGROUPCAPACITY,null SATELITE,case when SAM = 1 then ''True'' when SAM = 0 then ''False'' when SAM is null then null end as ISSAM',
    'name=''VSAT''',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_ACTIVEVSAT',
    'S_NO,CIRCUITID,IP_ADDRESS,SHORTCODE,CUSTOMERNAME,FICT_BILLING_NO,GRANITE_ACCESS_SPEED,HAJJ,LATITUDE,LONGITUDE,SERVICESTAUS,SITENAME,CITYNAME,REGIONNAME,VIP,PRODUCT,GRANITECUSTOMERNAME,MAINAPPLICATION,MOBILITYVAS,MRSVAS,ACTUALACCESSSPEED,MODEMTYPE,MODEMSERIALNUMBER,ANTENNATYPE,ANTENNASIZE,ISMRS,CONTRACTEDBANDWIDTHDOWNLOADCIRBPS,CONTRACTEDBANDWIDTHUPLOADCIRBPS,CONTRACTEDBANDWIDTHDOWNLOADMIRBPS,CONTRACTEDBANDWIDTHUPLOADMIRBPS,CONTRACTEDBANDWIDTHDOWNLOADPOOLBPS,CONTRACTEDBANDWIDTHUPLOADPOOLBPS,ACTUALBANDWIDTHRESERVATIONDOWNLOADCIRBPS,ACTUALBANDWIDTHRESERVATIONUPLOADCIRBPS,ACTUALBANDWIDTHRESERVATIONDOWNLOADMIRBPS,ACTUALBANDWIDTHRESERVATIONUPLOADMIRBPS,ACTUALBANDWIDTHRESERVATIONDOWNLOADPOOLBPS,ACTUALBANDWIDTHRESERVATIONUPLOADPOOLBPS,PARENTCUSTOMERNAME,MAINBACKHAULINGCIRCUIT,BACKUPBACKHAULINGCIRCUIT,VSATINSTALLATIONDATE,VSATDECOMMISSIONINGDATE,PARENTCUSTOMERNAMEAR,CUSTOMERID,CUSTOMERIDTYPE,CUSTOMERWEBSITE,CUSTOMERSECTOR,CUSTOMERTYPE,STCVIP,BANDWIDTHASSIGNMENTMETHOD,PACKAGECLASS,TOPOLOGY,HUBNETWORKINROUTEGROUP,NETWORKINROUTEGROUPCAPACITY,STCPE,STCVLAN,MODEMMANAGEMENTIPTYPE,MODEMMANAGEMENTIP,MODEMLANIPTYPE,MODEMLANIP,MRSIP,SITENAMEAR,SITENATURE,ANTENNACODE,BUCTYPE,BUCSIZE,BUCSERIAL,LNBTYPE,LNBSERIAL,MODEMLICENSE,ACCELERATORTYPE,ACCELERATORLICENSE,ACCELERATORSERIAL,GRANITEORDERSTAGE,ORDERINGRECEIVEDATE,DECOMMISSIONINGRECEIVEDATE,HUB_SITE_NAME,HUB_SITENAMEAR,HUB_SITENATURE,HUB_LATITUDE,HUB_LONGITUDE,HUB_ANTENNATYPE,HUB_ANTENNASIZE,HUB_ANTENNACODE,HUB_BUCTYPE,HUB_BUCSIZE,HUB_BUCSERIAL,HUB_LNBTYPE,HUB_LNBSERIAL,HUB_MODEMTYPE,HUB_MODEMLICENSE,HUB_MODEMSERIALNUMBER,HUB_ACCELERATORTYPE,HUB_ACCELERATORLICENSE,HUB_ACCELERATORSERIAL,LNB_LO_FREQUENCY,HUB_LNB_LO_FREQUENCY,HUB_CITY,HUB_REGION,HUBNETWORK,HUBNETWORKFORWARDCAPACITY,NETWORKRETURNCAPACITY,INROUTEGROUP,INROUTEGROUPCAPACITY,SATELITE,ISSAM',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    'PRD_ACTIVEVSAT',
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/ACTIVEDIA',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_pattern": "PRD_ACTIVEVSAT"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'dcc7fd87-e962-4f87-b1f0-9883b90c4734',
    'PRD_ACTIVEMRS_postgres_79',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'Row_Data',
    'null S_NO,Circuit_ID,english_name,RegistrationNumber,null CUSTOMERCONTACTNUMBER,Service_Staus,Activation_Date,In_Service_Date,decomissionedDate,Bandwidth,GraniteBW,Name_3,Name_3,ICMS_NO,FICT_BILLING_NO,ORDER_NUMBER,Router_Model_Number,Router_Serial_Number,IP_Address,english_name_1,english_name_2,Site_Name,null CIRCUITGROUP,null "COMMENTS",case when Hajj = 1 then ''Yes'' when Hajj = 0 then ''No'' when Hajj is null then null end as Hajj,case when ISR_Router = 1 then ''Yes'' when ISR_Router = 0 then ''No'' when ISR_Router is null then null end as ISR_Router,LATITUDE,LONGITUDE,Proposal_Reference,Service_Category,null PE_ID,null MACHINE_TYPE,english_name_3,circuit_type,null OOB_IP_ADDRESS,null OOB_MAC_ADDRESS,null OOB_SERIAL_NUMBER,null OOB_SIM_ID,case when VIP = 1 then ''Yes'' when VIP = 0 then ''No'' when VIP is null then null end as VIP,null IP_ADDRESSTYPE,Access_Tech,case when ACCESSIBLE = 1 then ''Yes'' when ACCESSIBLE = 0 then ''No'' when ACCESSIBLE is null then null end as ACCESSIBLE,Gender,case when HQ = 1 then ''Yes'' when HQ = 0 then ''No'' when HQ is null then null end as HQ,null ROYAL,null NO_TICKET_FLAG,null DAILY_POWERED_OFF,PMO_Router_Model,PMO_Router_Type,Name_3,null BATCH_NUMBER,case when MANAGED = 1 then ''True'' when MANAGED = 0 then ''False'' when MANAGED is null then null end as MANAGED,null MOE_FUTURE_GATE,null MOE_ID,Name_2,Management_Cost,null TSS_COST,case when SAM = 1 then ''Yes'' when SAM = 0 then ''No'' when SAM is null then null end as ISSAM,null SAMINFO,CircuitStatus,case when Suspended = 1 then ''Yes'' when Suspended = 0 then ''No'' when Suspended is null then null end as Suspended',
    'name=''MRS''',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_ACTIVEMRS',
    'S_NO,CIRCUITID,CUSTOMERNAME,CUSTOMERREGNUM,CUSTOMERCONTACTNUMBER,SERVICESTAUS,ACTIVATION_DATE,IN_SERVICEDATE,DECOMISSIONDATE,BANDWIDTH,GRANITEBW,CUSTOMERBEHAVIOR,GRANTIESLA,ICMS_NO,FICT_BILLING_NO,ORDERNUMBER,ROUTER_MODELNUMBER,ROUTER_SERIALNUMER,IP_ADDRESS,REGIONNAME,CITYNAME,SITENAME,CIRCUITGROUP,COMMENTS,HAJJ,ISROUTER,LATITUDE,LONGITUDE,PROPOSAL_REFERENCE,SERVICE_CATEGORY,PE_ID,MACHINE_TYPE,DIRECTORATENAME,CIRCUITTYPE,OOB_IP_ADDRESS,OOB_MAC_ADDRESS,OOB_SERIAL_NUMBER,OOB_SIM_ID,VIP,IP_ADDRESSTYPE,ACCESS_TECH,ACCESSIBLE,GENDER,HQ,ROYAL,NO_TICKET_FLAG,DAILY_POWERED_OFF,PMO_ROUTER_MODEL,PMO_ROUTER_TYPE,PMO_SLA,BATCH_NUMBER,MANAGED,MOE_FUTURE_GATE,MOE_ID,GRANITE_SERVICE_CATEGORY,MANAGEMENT_COST,TSS_COST,ISSAM,SAMINFO,CIRCUITSTATUS,SUSPENDED',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    'PRD_ACTIVEMRS',
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/PRD_ACTIVEMRS',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_pattern": "PRD_ACTIVEMRS"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'e1c38136-644a-479d-9fa3-5b87a232b258',
    'PRD_ACTIVECLOUDCONNECTIVITY_postgres_80',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'Row_Data',
    'null S_NO,Circuit_ID,english_name,Service_Staus,IP_Address,IP_Custom_1,PE_Interface_1,PE_1,CustomerNamePE_1,Speed_1,case when IsMRS_2 = 1 then ''True'' when IsMRS_2 = 0 then ''False'' when IsMRS_2 is null then null end as ISMRS,case when SAM = 1 then ''True'' when SAM = 0 then ''False'' when SAM is null then null end as ISSAM',
    'name=''CloudConnectivity''',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_ACTIVECLOUDCONNECTIVITY',
    'S_NO,CIRCUITID,CUSTOMERNAME,GRANITE_STATUS,P2P,IP_CUSTOM,PE_INTERFACE,PE,CUSTOMERNAMEPE,SPEED,ISMRS,ISSAM',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    'PRD_ACTIVECLOUDCONNECTIVITY',
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/ACTIVEDIA',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_pattern": "PRD_ACTIVECLOUDCONNECTIVITY"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'b84ad3e8-728a-40a2-ad22-32b5d3736008',
    'PRD_STCS_PR_PROJECT_REPORT_postgres_81',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'PR_PROJECT_REPORT',
    'REQUISITION_NUM as PR_NUMBER, LINE_NUM as PR_LINENUM, PR_STATUS, PR_TOTAL PR_AMOUNT, to_Char(to_timestamp(CREATION_DATE,''YYYY-MM-DDTHH24:MI:SS''),''YYYY-MM-DDTHH24:MI:SS'')||''.000+03:00'' as PR_CREATIONDATE, CREATOR_NAME as PR_CREATORNAME, REQUESTER_NAME as PR_REQUESTERNAME,PROJECT_NUMBER,TASK_NUMBER',
    'REQUISITION_NUM is null or REQUISITION_NUM is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_STCS_PR_PROJECT_REPORT',
    'PR_NUMBER,PR_LINENUM,PR_STATUS,PR_AMOUNT,PR_CREATIONDATE,PR_CREATORNAME,PR_REQUESTERNAME,PROJECT_NUMBER,TASK_NUMBER',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_PR_PROJECT_REPORT',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '06e46b79-af08-4e50-9885-f336be3b4721',
    'PRD_STCS_ON_HAND_QTY_PROJECT_postgres_82',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'ONHAND_QUANTITIES',
    '''; ''||ITEM_CODE, INVENTORY_ITEM_ID, ORGANIZATION_ID,ORGANIZATION_NAME,null ALLOCATED_QUANTITY,RESERVED_QUANTITY,SUPPLIER_ITEM_CODE,"COMMIDITY" as COMMODITY, "ITEM_DESCRIPTION" as DESCRIPTION,ON_HAND_QUANTITY,ALLOCATED_QUANTITY as ALLOCATED_QUANTITY_1,ITEM_COST,SUBINVENTORY_CODE as SUB_INVENTORY_CODE,LOCATOR_PROJECT_NUMBER,LOCATOR_TASK_NUMBER,LOCATOR_PO_NUMBER,PO_UNIT_PRICE,MATERIAL_COST as MATERIAL_COST_BASE_ON_PO_PRICE,PROJECT_MANAGER as PROJECT_MANAGER_REQUESTOR,LOCATOR_LOCATION--,LOCATOR_SEGMENT5,TOTAL_COST',
    'ITEM_CODE is not null or ITEM_CODE is null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_STCS_ON_HAND_QTY_PROJECT',
    'ITEM_CODE,INVENTORY_ITEM_ID,ORGANIZATION_ID,ORGANIZATION_NAME,ALLOCATED_QUANTITY,RESERVED_QUANTITY,SUPPLIER_ITEM_CODE,COMMODITY,DESCRIPTION,ON_HAND_QUANTITY,ALLOCATED_QUANTITY_1,ITEM_COST,SUB_INVENTORY_CODE,LOCATOR_PROJECT_NUMBER,LOCATOR_TASK_NUMBER,LOCATOR_PO_NUMBER,PO_UNIT_PRICE,MATERIAL_COST_BASE_ON_PO_PRICE,PROJECT_MANAGER_REQUESTOR,LOCATOR_LOCATION,LOCATOR_SEGMENT5,TOTAL_COST',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_On-Hand_Quantity_Report',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'f5051ec6-875d-4908-a838-12a116ad5e4d',
    'STC_GL_RBM_R_postgres_83',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'gls_revunue',
    'MAIN_REVENUE_CODE_NAME,SUB_REVENUE_CODE_NAME,VENDOR_SHARE,VENDOR_NAME,BILL_STATEMENT_RUN_DATE,BILL_STATEMENT_START_DATE,STATEMENT_CHARGE_START_DATE,STATEMENT_CHARGE_END_DATE,SERVICE_NUMBER,CIRCUIT_NAME,SERVICE_ACTIVATION_DATE,SERVICE_DISCONNECTION_DATE,STATEMENT_CHARGE_AMT,STATEMENT_DISCOUNT_AMT,COMPANY_ID,CUSTOMER_NUMBER,BILLING_ACCOUNT_NUMBER,IRB_PROD_NAME,IRB_PROD_ID,IRB_OFFERING_ID,IRB_OFFERING_NAME,CRM_OFFERING_ID,CRM_OFFERING_NAME,CRM_PRODUCT_ID,CRM_PRODUCT_NAME,CHARGE_TYPE,BILL_SEQUENCE_NUMBER,BILL_VERSION,GL_ACCOUNT,CUSTOMER_SEGMENT,CUSTOMER_TYPE,CUSTOMER_SUBTYPE,BILL_CYCLE,CUSTOMER_NAME_ENGLISH,CUSTOMER_NAME_ARABIC,SourceFileName',
    'TO_DATE(
    TO_CHAR(BILL_STATEMENT_RUN_DATE,''yyyy-mm-dd''),
    ''yyyy-mm-dd''
) BETWEEN DATE_TRUNC(''month'',CURRENT_DATE - interval ''1 month'')
    AND DATE_TRUNC(''month'',CURRENT_DATE - interval ''1 month'') + interval ''1 month'' - interval ''1 day''',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'STC_GL_RBM_R',
    'MAIN_REVENUE_CODE_NAME,SUB_REVENUE_CODE_NAME,VENDOR_SHARE,VENDOR_NAME,BILL_STATEMENT_RUN_DATE,BILL_STATEMENT_START_DATE,STATEMENT_CHARGE_START_DATE,STATEMENT_CHARGE_END_DATE,SERVICE_NUMBER,CIRCUIT_NAME,SERVICE_ACTIVATION_DATE,SERVICE_DISCONNECTION_DATE,STATEMENT_CHARGE_AMT,STATEMENT_DISCOUNT_AMT,COMPANY_ID,CUSTOMER_NUMBER,BILLING_ACCOUNT_NUMBER,IRB_PROD_NAME,IRB_PROD_ID,IRB_OFFERING_ID,IRB_OFFERING_NAME,CRM_OFFERING_ID,CRM_OFFERING_NAME,CRM_PRODUCT_ID,CRM_PRODUCT_NAME,CHARGE_TYPE,BILL_SEQUENCE_NUMBER,BILL_VERSION,GL_ACCOUNT,CUSTOMER_SEGMENT,CUSTOMER_TYPE,CUSTOMER_SUBTYPE,BILL_CYCLE,CUSTOMER_NAME_ENGLISH,CUSTOMER_NAME_ARABIC,SOURCEFILENAME',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/gls',
    TRUE,
    '{"legacy_sheet": "Sheet1", "note": "Run on 8th"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '9ebe30c6-e41b-4b7e-83b3-dcabdd093c84',
    'STC_GL_RBM_D_postgres_84',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'gls_revunue_discount',
    'CUSTOMER_ID,CUSTOMER_NUMBER,BILLING_ACCOUNT_NUMBER,CUST_ARABIC_NAME,CUST_ENGLISH_NAME,CUSTOMER_TYPE,CUSTOMER_SUBTYPE,CUSTOMER_SEGMENT,BILL_DATE,CHARGE_START_DATE,CHARGE_END_DT,STATEMENT_CHARGE_AMT,BILL_SEQ,REVENUE_CODE_ID,REVENUE_CODE_NAME,STC_REVENUE_CODE,STC_REVENUE_PCT,STCS_REVENUE_CODE,STCS_REVENUE_PCT,BILL_CYCLE,ACTUAL_BILL_DATE,SourceFileName',
    'TO_DATE(
    TO_CHAR(ACTUAL_BILL_DATE,''yyyy-mm-dd''),
    ''yyyy-mm-dd''
) BETWEEN DATE_TRUNC(''month'',CURRENT_DATE - interval ''1 month'')
    AND DATE_TRUNC(''month'',CURRENT_DATE - interval ''1 month'') + interval ''1 month'' - interval ''1 day''',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'STC_GL_RBM_D',
    'CUSTOMER_ID,CUSTOMER_NUMBER,BILLING_ACCOUNT_NUMBER,CUST_ARABIC_NAME,CUST_ENGLISH_NAME,CUSTOMER_TYPE,CUSTOMER_SUBTYPE,CUSTOMER_SEGMENT,BILL_DATE,CHARGE_START_DATE,CHARGE_END_DT,STATEMENT_CHARGE_AMT,BILL_SEQ,REVENUE_CODE_ID,REVENUE_CODE_NAME,STC_REVENUE_CODE,STC_REVENUE_PCT,STCS_REVENUE_CODE,STCS_REVENUE_PCT,BILL_CYCLE,ACTUAL_BILL_DATE,SOURCEFILENAME',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/gls',
    TRUE,
    '{"legacy_sheet": "Sheet1", "note": "Run on 8th"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'b27baf6c-b036-4c4f-93a0-9b87a80668ab',
    'STC_GL_RBM_u_postgres_85',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'gls_revunue_usage',
    'CUSTOMER_ID,CUSTOMER_NUMBER,BILLING_ACCOUNT_NUMBER,CUST_ARABIC_NAME,CUST_ENGLISH_NAME,CUSTOMER_TYPE,CUSTOMER_SUBTYPE,CUSTOMER_SEGMENT,BILL_DATE,CHARGE_START_DATE,CHARGE_END_DT,STATEMENT_CHARGE_AMT,BILL_SEQ,REVENUE_CODE_ID,REVENUE_CODE_NAME,STC_REVENUE_CODE,STC_REVENUE_PCT,STCS_REVENUE_CODE,STCS_REVENUE_PCT,BILL_CYCLE,ACTUAL_BILL_DATE,SourceFileName',
    'TO_DATE(
    TO_CHAR(ACTUAL_BILL_DATE,''yyyy-mm-dd''),
    ''yyyy-mm-dd''
) BETWEEN DATE_TRUNC(''month'',CURRENT_DATE - interval ''1 month'')
    AND DATE_TRUNC(''month'',CURRENT_DATE - interval ''1 month'') + interval ''1 month'' - interval ''1 day''',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'STC_GL_RBM_u',
    'CUSTOMER_ID,CUSTOMER_NUMBER,BILLING_ACCOUNT_NUMBER,CUST_ARABIC_NAME,CUST_ENGLISH_NAME,CUSTOMER_TYPE,CUSTOMER_SUBTYPE,CUSTOMER_SEGMENT,BILL_DATE,CHARGE_START_DATE,CHARGE_END_DT,STATEMENT_CHARGE_AMT,BILL_SEQ,REVENUE_CODE_ID,REVENUE_CODE_NAME,STC_REVENUE_CODE,STC_REVENUE_PCT,STCS_REVENUE_CODE,STCS_REVENUE_PCT,BILL_CYCLE,ACTUAL_BILL_DATE,SOURCEFILENAME',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/gls',
    TRUE,
    '{"legacy_sheet": "Sheet1", "note": "Run on 8th"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'ef216a42-30bc-4278-a6d3-5fa5e96633e5',
    'prd_erp_postgres_86',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'RA_CUSTOMER_REVENUE_ASSURANCE',
    '"PROJECT_ORDER_ID",
"TYPE_OF_INVOICE",
"PROJECT_ORDER_NUMBER",
"BLANKET_ORDER_NUMBER",
"AGREEMENT_EXPIRY_DATE",
"ORDER_LINE_NUMBER",
"UNIT_SELLING_PRICE",
case when length ("EXPIRY")=9 then TO_CHAR(
  cast(
    ''20'' || SUBSTRING("EXPIRY", 8, 4) || ''-'' || 
    case UPPER(SUBSTRING("EXPIRY", 4, 3))
        when ''JAN'' then ''01''
        when ''FEB'' then ''02''
        when ''MAR'' then ''03''
        when ''APR'' then ''04''
        when ''MAY'' then ''05''
        when ''JUN'' then ''06''
        when ''JUL'' then ''07''
        when ''AUG'' then ''08''
        when ''SEP'' then ''09''
        when ''OCT'' then ''10''
        when ''NOV'' then ''11''
        when ''DEC'' then ''12''
        else null
    end || ''-'' ||
    SUBSTRING("EXPIRY", 1, 2)
  as DATE),
  ''MM/DD/YYYY HH24:MI:SS''
) else TO_CHAR(
  cast(
    SUBSTRING("EXPIRY", 8, 4) || ''-'' || 
    case UPPER(SUBSTRING("EXPIRY", 4, 3))
        when ''JAN'' then ''01''
        when ''FEB'' then ''02''
        when ''MAR'' then ''03''
        when ''APR'' then ''04''
        when ''MAY'' then ''05''
        when ''JUN'' then ''06''
        when ''JUL'' then ''07''
        when ''AUG'' then ''08''
        when ''SEP'' then ''09''
        when ''OCT'' then ''10''
        when ''NOV'' then ''11''
        when ''DEC'' then ''12''
        else null
    end || ''-'' ||
    SUBSTRING("EXPIRY", 1, 2)
  as DATE),
  ''MM/DD/YYYY HH24:MI:SS''
) end "EXPIRY" ,
TO_CHAR(
  cast(
    SUBSTRING("ACTIVATION_DATE", 8, 4) || ''-'' || 
    case UPPER(SUBSTRING("ACTIVATION_DATE", 4, 3))
        when ''JAN'' then ''01''
        when ''FEB'' then ''02''
        when ''MAR'' then ''03''
        when ''APR'' then ''04''
        when ''MAY'' then ''05''
        when ''JUN'' then ''06''
        when ''JUL'' then ''07''
        when ''AUG'' then ''08''
        when ''SEP'' then ''09''
        when ''OCT'' then ''10''
        when ''NOV'' then ''11''
        when ''DEC'' then ''12''
        else null
    end || ''-'' ||
    SUBSTRING("ACTIVATION_DATE", 1, 2)
  as DATE),
  ''MM/DD/YYYY HH24:MI:SS''
)"ACTIVATION_DATE",
"DESCRIPTION_CUSTOMER_NAME",
"CLASS_CODE_DIA",
"DRAFT_INVOICE_NUMBER",
"TRANSFER_STATUS_CODE",
"PA_DATE",
case when length ("BILL_THROUGH_DATE")=9 then TO_CHAR(
  cast(
    ''20'' || SUBSTRING("BILL_THROUGH_DATE", 8, 4) || ''-'' || 
    case UPPER(SUBSTRING("BILL_THROUGH_DATE", 4, 3))
        when ''JAN'' then ''01''
        when ''FEB'' then ''02''
        when ''MAR'' then ''03''
        when ''APR'' then ''04''
        when ''MAY'' then ''05''
        when ''JUN'' then ''06''
        when ''JUL'' then ''07''
        when ''AUG'' then ''08''
        when ''SEP'' then ''09''
        when ''OCT'' then ''10''
        when ''NOV'' then ''11''
        when ''DEC'' then ''12''
        else null
    end || ''-'' ||
    SUBSTRING("BILL_THROUGH_DATE", 1, 2)
  as DATE),
  ''MM/DD/YYYY HH24:MI:SS''
) else TO_CHAR(
  cast(
    SUBSTRING("BILL_THROUGH_DATE", 8, 4) || ''-'' || 
    case UPPER(SUBSTRING("BILL_THROUGH_DATE", 4, 3))
        when ''JAN'' then ''01''
        when ''FEB'' then ''02''
        when ''MAR'' then ''03''
        when ''APR'' then ''04''
        when ''MAY'' then ''05''
        when ''JUN'' then ''06''
        when ''JUL'' then ''07''
        when ''AUG'' then ''08''
        when ''SEP'' then ''09''
        when ''OCT'' then ''10''
        when ''NOV'' then ''11''
        when ''DEC'' then ''12''
        else null
    end || ''-'' ||
    SUBSTRING("BILL_THROUGH_DATE", 1, 2)
  as DATE),
  ''MM/DD/YYYY HH24:MI:SS''
) end"BILL_THROUGH_DATE",
case when length ("START_DATE")=9 then TO_CHAR(
  cast(
    ''20'' || SUBSTRING("START_DATE", 8, 4) || ''-'' || 
    case UPPER(SUBSTRING("START_DATE", 4, 3))
        when ''JAN'' then ''01''
        when ''FEB'' then ''02''
        when ''MAR'' then ''03''
        when ''APR'' then ''04''
        when ''MAY'' then ''05''
        when ''JUN'' then ''06''
        when ''JUL'' then ''07''
        when ''AUG'' then ''08''
        when ''SEP'' then ''09''
        when ''OCT'' then ''10''
        when ''NOV'' then ''11''
        when ''DEC'' then ''12''
        else null
    end || ''-'' ||
    SUBSTRING("START_DATE", 1, 2)
  as DATE),
  ''MM/DD/YYYY HH24:MI:SS''
) else TO_CHAR(
  cast(
    SUBSTRING("START_DATE", 8, 4) || ''-'' || 
    case UPPER(SUBSTRING("START_DATE", 4, 3))
        when ''JAN'' then ''01''
        when ''FEB'' then ''02''
        when ''MAR'' then ''03''
        when ''APR'' then ''04''
        when ''MAY'' then ''05''
        when ''JUN'' then ''06''
        when ''JUL'' then ''07''
        when ''AUG'' then ''08''
        when ''SEP'' then ''09''
        when ''OCT'' then ''10''
        when ''NOV'' then ''11''
        when ''DEC'' then ''12''
        else null
    end || ''-'' ||
    SUBSTRING("START_DATE", 1, 2)
  as DATE),
  ''MM/DD/YYYY HH24:MI:SS''
) end "START_DATE",
case when length ("END_DATE")=9 then TO_CHAR(
  cast(
    ''20'' || SUBSTRING("END_DATE", 8, 4) || ''-'' || 
    case UPPER(SUBSTRING("END_DATE", 4, 3))
        when ''JAN'' then ''01''
        when ''FEB'' then ''02''
        when ''MAR'' then ''03''
        when ''APR'' then ''04''
        when ''MAY'' then ''05''
        when ''JUN'' then ''06''
        when ''JUL'' then ''07''
        when ''AUG'' then ''08''
        when ''SEP'' then ''09''
        when ''OCT'' then ''10''
        when ''NOV'' then ''11''
        when ''DEC'' then ''12''
        else null
    end || ''-'' ||
    SUBSTRING("END_DATE", 1, 2)
  as DATE),
  ''MM/DD/YYYY HH24:MI:SS''
) else TO_CHAR(
  cast(
    SUBSTRING("END_DATE", 8, 4) || ''-'' || 
    case UPPER(SUBSTRING("END_DATE", 4, 3))
        when ''JAN'' then ''01''
        when ''FEB'' then ''02''
        when ''MAR'' then ''03''
        when ''APR'' then ''04''
        when ''MAY'' then ''05''
        when ''JUN'' then ''06''
        when ''JUL'' then ''07''
        when ''AUG'' then ''08''
        when ''SEP'' then ''09''
        when ''OCT'' then ''10''
        when ''NOV'' then ''11''
        when ''DEC'' then ''12''
        else null
    end || ''-'' ||
    SUBSTRING("END_DATE", 1, 2)
  as DATE),
  ''MM/DD/YYYY HH24:MI:SS''
) end  "END_DATE",
TO_CHAR(
  cast(
    ''20'' || SUBSTRING("INVOICE_DATE", 8, 4) || ''-'' || 
    case UPPER(SUBSTRING("INVOICE_DATE", 4, 3))
        when ''JAN'' then ''01''
        when ''FEB'' then ''02''
        when ''MAR'' then ''03''
        when ''APR'' then ''04''
        when ''MAY'' then ''05''
        when ''JUN'' then ''06''
        when ''JUL'' then ''07''
        when ''AUG'' then ''08''
        when ''SEP'' then ''09''
        when ''OCT'' then ''10''
        when ''NOV'' then ''11''
        when ''DEC'' then ''12''
        else null
    end || ''-'' ||
    SUBSTRING("INVOICE_DATE", 1, 2)
  as DATE),
  ''YYYY-mm-dd''
)|| ''T00:00:00.000+03:00'' "INVOICE_DATE",
"RA_INVOICE_NUMBER",
TO_CHAR(
  cast(
    ''20'' || SUBSTRING("GL_DATE", 8, 4) || ''-'' || 
    case UPPER(SUBSTRING("GL_DATE", 4, 3))
        when ''JAN'' then ''01''
        when ''FEB'' then ''02''
        when ''MAR'' then ''03''
        when ''APR'' then ''04''
        when ''MAY'' then ''05''
        when ''JUN'' then ''06''
        when ''JUL'' then ''07''
        when ''AUG'' then ''08''
        when ''SEP'' then ''09''
        when ''OCT'' then ''10''
        when ''NOV'' then ''11''
        when ''DEC'' then ''12''
        else null
    end || ''-'' ||
    SUBSTRING("GL_DATE", 1, 2)
  as DATE),
  ''YYYY-mm-dd''
)|| ''T00:00:00.000+03:00'' "GL_DATE",
"AMOUNT",
"TEXT",
"INVOICE_LINE_NUMBER",
"EVENT_NUMBER",
"TASK_NUMBER",
"RESOURCE_NAME",
"CIRCUIT_NUMBER_SERVICE_NAME",
"CKT_BILL_NUMBER_FICT",
"CUSTOMER_ACCOUNT_NUMBER",
"BILLING_CYCLE",
"STATUS",
"ACCOUNTING_STATUS",
"COMPLETE_FLAG",
"INVENTORY_ITEM_ID",
"L1",
"L1_DESC",
"L2",
"L2_DESC",
"L3",
"L3_DESC",
"L5",
"L5_DESC",
"CHANNEL",
"REFERENCE_ORDER",
replace("REFERENCE_ORDER_LINE", ''||'', ''|'')"REFERENCE_ORDER_LINE",
"OLD_ERP_ORDER_NUMBER",
"OLD_ERP_ORDER_LINE",
"OLD_ERP_LINE_ID",
"MIGRATION_PURPOSE_ONLY",
"DYN_OFF_SHLF_RQST",
"DYNMCS_ORDER_TYPE",
TO_CHAR(
    cast(
      SUBSTRING(RETURN_ORDER_FROM, 1, 4) || ''-'' ||
      SUBSTRING(RETURN_ORDER_FROM, 6, 2) || ''-'' ||
      SUBSTRING(RETURN_ORDER_FROM, 9, 2) || '' '' ||
      SUBSTRING(RETURN_ORDER_FROM, 12, 8)
    as TIMESTAMP),
    ''FMMM/FMDD/YYYY FMHH24:MI''
  )"RETURN_ORDER_FROM",
TO_CHAR(
    cast(
      SUBSTRING("RETURN_ORDER_TO", 1, 4) || ''-'' ||
      SUBSTRING("RETURN_ORDER_TO", 6, 2) || ''-'' ||
      SUBSTRING("RETURN_ORDER_TO", 9, 2) || '' '' ||
      SUBSTRING("RETURN_ORDER_TO", 12, 8)
    as TIMESTAMP),
    ''FMMM/FMDD/YYYY FMHH24:MI''
  )"RETURN_ORDER_TO",
"RETURN_ORDER_DETAIL",
"EBU_CO_ID"',
    'TO_date(
  cast(
    ''20'' || SUBSTRING("GL_DATE", 8, 4) || ''-'' || 
    case UPPER(SUBSTRING("GL_DATE", 4, 3))
        when ''JAN'' then ''01''
        when ''FEB'' then ''02''
        when ''MAR'' then ''03''
        when ''APR'' then ''04''
        when ''MAY'' then ''05''
        when ''JUN'' then ''06''
        when ''JUL'' then ''07''
        when ''AUG'' then ''08''
        when ''SEP'' then ''09''
        when ''OCT'' then ''10''
        when ''NOV'' then ''11''
        when ''DEC'' then ''12''
        else null
    end || ''-'' ||
    SUBSTRING("GL_DATE", 1, 2)
  as DATE),
  ''dd-mm-yyyy''
) >= DATE_TRUNC(''MONTH'',
 CURRENT_DATE) - interval ''1 month''
 and TO_date(
  cast(
    ''20'' || SUBSTRING("GL_DATE", 8, 4) || ''-'' || 
    case UPPER(SUBSTRING("GL_DATE", 4, 3))
        when ''JAN'' then ''01''
        when ''FEB'' then ''02''
        when ''MAR'' then ''03''
        when ''APR'' then ''04''
        when ''MAY'' then ''05''
        when ''JUN'' then ''06''
        when ''JUL'' then ''07''
        when ''AUG'' then ''08''
        when ''SEP'' then ''09''
        when ''OCT'' then ''10''
        when ''NOV'' then ''11''
        when ''DEC'' then ''12''
        else null
    end || ''-'' ||
    SUBSTRING("GL_DATE", 1, 2)
  as DATE),
  ''dd-mm-yyyy''
) < DATE_TRUNC(''MONTH'',
 CURRENT_DATE)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'prd_erp',
    'PROJECT_ORDER_ID,TYPE_OF_INVOICE,PROJECT_ORDER_NUMBER,BLANKET_ORDER_NUMBER,AGGREMENT_EXPIRY_DATE,ORDER_LINE_NUMBER,UNIT_SELLING_PRICE,EXPIRY,ACTIVATION_DATE,DESCRIPTION_CUSTOMER_NAME,CLASS_CODE_DIA,DRAFT_INVOICE_NUMBER,TRANSFER_STATUS_CODE,PA_DATE,BILL_THROUGH_DATE,START_DATE,END_DATE,INVOICE_DATE,RA_INVOICE_NUMBER,GL_DATE,AMOUNT,TEXT,INVOICE_LINE_NUMBER,EVENT_NUMBER,TASK_NUMBER,RESOURCE_NAME,CIRCUIT_NUMBER_SERVICENAME,CKT_BILL_NUMBER_FICT,CUSTOMER_ACCOUNT_NUMBER,BILLING_CYCLE,STATUS,ACCOUNTING_STATUS,COMPLETE_FLAG,INVENTORY_ITEM_ID,L1,L1_DESC,L2,L2_DESC,L3,L3_DESC,L5,L5_DESC,CHANNEL,REFERENCE_ORDER,REFERENCE_ORDER_LINE,OLD_ERP_ORDER_NUMBER,OLD_ERP_ORDER_LINE,OLD_ERP_LINE_ID,MIGRATION_PURPOSE_ONLY,DYN_OFF_SHLF_RQST,DYNMCS_ORDER_TYPE,RETURN_ORDER_FROM,RETURN_ORDER_TO,RETURN_ORDER_DETAIL,EBU_CO_ID',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_Customer_Revenue_Assurance_Report',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '720c3815-47c7-4530-ad4b-84bd622ceedd',
    'PRD_STCS_MOVER_ORDER_REPORT_csv_87',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/STCS Move Orders Report',
    'Order Number,Line Number,Transaction Type Name,Item Code,Supplier Item Code,Item Category,Item Desc,UOM,Quantity,Quantity Delivered,ATTRIBUTE2,Item Cost,Total Cost,Transaction Date,Creation Date,User Name,From Subinventory Code,Project Number From Locator,Task Number,Po Numbers,Segment4,Segment5,Charge Account,Charge Account Description,Asset Flag,Po Number,Po Type,Project Number,Vendor Name,Vendor Site,Vendor Country,Sales Agreement',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_STCS_MOVER_ORDER_REPORT',
    'ORDER_NUMBER,LINE_NUMBER,TRANSACTION_TYPE_NAME,ITEM_CODE,SUPPLIER_ITEM_CODE,ITEM_CATEGORY,ITEM_DESC,UOM,QUANTITY,QUANTITY_DELIVERED,ATTRIBUTE2,ITEM_COST,TOTAL_COST,TRANSACTION_DATE,CREATION_DATE,USER_NAME,FROM_SUBINVENTORY_CODE,PROJECT_NUMBER_FROM_LOCATOR,TASK_NUMBER,PO_NUMBERS,SEGMENT4,SEGMENT5,CHARGE_ACCOUNT,CHARGE_ACCOUNT_DESCRIPTION,ASSET_FLAG,PO_NUMBER,PO_TYPE,PROJECT_NUMBER,VENDOR_NAME,VENDOR_SITE,VENDOR_COUNTRY,SALES_AGREEMENT',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_Move_Orders_Report',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '181070fa-d60f-4570-bc39-6f71a3aa8208',
    'PRD_INVOICES_WITHOUT_PO_csv_88',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/Invoices Without PO',
    'EMPLOYEE_NUMBER,LINE_DESC,VENDOR_NAME,INVOICE_NUMBER,INVOICE_GROSS_AMOUNT,CURRENCY,PAYMENT_ID,PAYMENT_DATE,WITH-HOLD,INVOICE_TYPE,AMOUNT_PAID,REQUEST_NUM,LINE_NUMBER,LINE_AMOUNT,BUDGET_CODE,VEDNOR_SITE_NUMBER,INVOICE_DATE,INVOICE_DESCRIPTION,PAYMENT_TERMS_NAME,CREATED_BY,CREATION_DATE,PAYMENT_TYPE,TAX_RATE,TAX_AMOUNT,STATUS,CATEGORY_TYPE,COST_CENTER,ACCOUNT_NUMBER,PROJECT_NUMBER,PRODUCT_NUMBER',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_INVOICES_WITHOUT_PO',
    'EMPLOYEE_NUMBER,LINE_DESC,VENDOR_NAME,INVOICE_NUMBER,INVOICE_GROSS_AMOUNT,CURRENCY,PAYMENT_ID,PAYMENT_DATE,WITH_HOLD,INVOICE_TYPE,AMOUNT_PAID,REQUEST_NUM,LINE_NUMBER,LINE_AMOUNT,BUDGET_CODE,VEDNOR_SITE_NUMBER,INVOICE_DATE,INVOICE_DESCRIPTION,PAYMENT_TERMS_NAME,CREATED_BY,CREATION_DATE,PAYMENT_TYPE,TAX_RATE,TAX_AMOUNT,STATUS,CATEGORY_TYPE,COST_CENTER,ACCOUNT_NUMBER,PROJECT_NUMBER,PRODUCT_NUMBER',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/Invoices_Without_PO',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_extension_filter": "all"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'ba58ade7-003a-4e9a-9237-7e67fe4f2328',
    'PRD_DYNAMICS_PRODUCT_DETADV_postgres_89',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'BSCH_Bayan.product_details',
    'stcs_orderlinename,
stcs_erpolnnumber,
stcs_erpexecutiondate,
stcs_erpexpirationdate,
stcs_erpitemcodename,
stcs_quantity,
	coalesce(case when stcs_mrc is not null then stcs_finalsolutionscomponentprice else 0 end , stcs_mrc) MRC,
	coalesce(case when stcs_otc is not null then stcs_finalsolutionscomponentprice else 0 end, stcs_otc)OTC ,
statecodename,
stcs_uom,
stcs_billingcyclename,
stcs_billingtypename,
stcs_partialbillingname,
stcs_erpintegrationname,
stcs_olderpitemcodename,
stcs_ongoingerplineid,stcs_actiontypename',
    'stcs_productcategoryname in (''Internet Services'',''Data Services'')',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_DYNAMICS_PRODUCT_DETADV',
    'ORDER_LINE,PRODUCT_LINE_ID,ERP_EXECUTION_DATE,ERP_EXPIRATION_DATE,ERP_ITEM_CODE,QUANTITY,MRC,OTC,OTC_EXTENDED,STATUS,UOM,BILLING_CYCLE,BILLINGTYPE,PARTIAL_BILLING,ERP_INTEGRATION,OLD_ERP_ITEM_CODE,ONGOING_ERP_LINE_ID,STCS_ACTIONTYPENAME',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    15,
    0,
    'Product Detail',
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Dynamic/Dynamic_Product',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_pattern": "Product Detail"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'a969d640-b0ae-4387-95b6-79375b1a7989',
    'PRD_DYNAMICS_ALLORDERS_postgres_90',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    '"BSCH_Bayan"."order"',
    'name,
replace(customeridname,'','',''''),
stcs_servicecategoryname,
stcs_ordernaturename,
stcs_ordertypename,
null as CREATED_ON,
stcs_sourcesystemname,
stcs_sourcesystemordernumber,
stcs_orderstatusreasonname,
totalamount',
    'name is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_DYNAMICS_ALLORDERS',
    'NAME,CUSTOMER,SERVICE_CATEGORY,ORDER_NATURE,ORDER_TYPE,CREATED_ON,SOURCE_SYSTEM,SOURCE_SYSTEM_ORDER_NUMBER,STATUS_REASON,TOTAL_AMOUNT',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    'All Orders',
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Dynamic/Dynamic_All_Orders',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_pattern": "All Orders"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'e0b955cc-54cc-4e01-95b8-faf778c5a42e',
    'prd_dynamics_product_detail_postgres_91',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'BSCH_Bayan.product_details',
    'stcs_orderlinename,
stcs_erpolnnumber,
stcs_erpexecutiondate,
stcs_erpexpirationdate,
stcs_erpitemcodename,
stcs_quantity,
	coalesce(case when stcs_mrc is not null then stcs_finalsolutionscomponentprice else 0 end , stcs_mrc) MRC,
	coalesce(case when stcs_otc is not null then stcs_finalsolutionscomponentprice else 0 end, stcs_otc)OTC ,
stcs_otcextended,
statecodename,
stcs_uom,
stcs_billingcyclename,
stcs_billingtypename,
stcs_partialbillingname,
stcs_erpintegrationname,
stcs_olderpitemcodename,
stcs_ongoingerplineid,
stcs_productlevel4name,
stcs_productlevel5name,
stcs_productlevel6name,
stcs_productlevel7name,
stcs_productcategoryname,
stcs_productname,stcs_actiontypename',
    'stcs_productcategoryname not in (''Internet Services'',''Data Services'')',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'prd_dynamics_product_detail',
    'ORDER_LINE,PRODUCT_LINE_ID,ERP_EXECUTION_DATE,ERP_EXPIRATION_DATE,ERP_ITEM_CODE,QUANTITY,MRC,OTC,OTC_EXTENDED,STATUS,UOM,BILLING_CYCLE,BILLINGTYPE,PARTIAL_BILLING,ERP_INTEGRATION,OLD_ERP_ITEM_CODE,ONGOING_ERP_LINE_ID,PRODUCT_LEVEL_4,PRODUCT_LEVEL_5,PRODUCT_LEVEL_6,PRODUCT_LEVEL_7,PRODUCT_MAIN_CATEGORY,PRODUCT_SUB_CATEGORY,STCS_ACTIONTYPENAME',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    15,
    0,
    'Others_Product Detail',
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Dynamic/Dynamic_Product/Others',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_pattern": "Others_Product Detail"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '90b5fa1c-96e8-40a1-937f-ee6483c252c7',
    'prd_dynamics_active_order_line_postgres_92',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'active_order_line',
    'stcs_circuitid,
stcs_name,
stcs_servicecategoryname,
stcs_ordertypename,
stcs_productname,
stcs_otc,
stcs_mrc,
stcs_totalamount,
stcs_orderlinestatusname,
stcs_orderlinestatusreasonname,
to_char(createdon,
''YYYY-MM-DD HH24:MI:SS'')createdon,
stcs_accountname,
stcs_erpbillingaccountname,
stcs_sendtobillingname,
stcs_fict_billing_no,
stcs_financeapprovalstatusname,
stcs_sendtoerpname,
stcs_sendtoerpstatusname,
stcs_speedvaluename,
to_char(stcs_closuredate,
''YYYY-MM-DD HH24:MI:SS'') stcs_closuredate,
stcs_ordernaturename,
stcs_subscriptionname,
stcs_backdateapprovalstatusname,
stcs_ongoingerporderlineid,
stcs_ongoingerporderline,
stcs_ongoingerpordernumber,
stcs_baseorderlinename,
stcs_dynamics_order_number,
stcs_masterorderlinename,
stcs_ordername,
stcs_order_number,
to_char(stcs_erpexpirationdate,
''YYYY-MM-DD HH24:MI:SS'')stcs_erpexpirationdate,
to_char(stcs_expirationdate,
''YYYY-MM-DD HH24:MI:SS'') stcs_expirationdate,
stcs_expirydate,
stcs_reusestatusname,
stcs_routermodelnumber,
stcs_routerserialnumber,
stcs_uninstallworkordernumber,
stcs_workordernumber,
stcs_granitenumber',
    'stcs_servicecategoryname not in (''AwalISP'') and stcs_servicecategoryname not like ''%SAT%''',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'prd_dynamics_active_order_line',
    'CIRCUIT_ID,NAME,SERVICE_CATEGORY,ORDER_TYPE_ORDER_ORDER,PRODUCT,OTC,MRC,TOTAL_AMOUNT,ORDER_LINE_STATUS,ORDER_LINE_STATUS_REASON,CREATED_ON,ACCOUNT,ERP_BILLING_ACCOUNT,SEND_TO_BILLING,FICT_BILLING_NO,FINANCE_TEAM_APPROVAL_STATUS,SEND_TO_ERP,SEND_TO_ERP_STATUS,SPEED,CLOSURE_DATE,ORDER_NATURE,SUBSCRIPTION,BACKDATE_APPROVAL_STATUS,ONGOING_ERP_ORDER_LINE,ONGOING_ERP_ORDER_LINE_ID,ONGOING_ERP_ORDER_NUMBER,BASE_ORDER_LINE,DYNAMICS_ORDER_NUMBER,MASTER_ORDER_LINE,ORDER_1,ORDER_NUMBER,ERP_EXPIRATION_DATE,EXPIRATION_DATE,EXPIRY_DATE,ORDERLINE_USED,ROUTER_MODEL_NUMBER,ROUTER_SERIAL_NUMBER,UNINSTALL_WORK_ORDER_NUMBER,WORK_ORDER_NUMBER,STCS_GRANITENUMBER',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    'OThers_Active Order line ',
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Dynamic/Dynamic_AOL/Others',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_pattern": "OThers_Active Order line "}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '8c8563f7-de0c-4bce-9c0e-ee21d2a02033',
    'PRD_STCSPO_OUTSTAN_PROJECT_RET_postgres_93',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'PO_outstanding_full_report',
    'DEPARTMENT as REQUESTOR_DEPARTMENT,DEPARTMENT as VP_BU,VENDOR_NAME as SUPPLIER_NAME,SEGMENT1 as SUPPLIER_NUMBER,REQ_NUMBER as PR,to_char(to_timestamp(CREATION_DATE,''YYYY-MM-DDTHH24:MI:SS''),''MM/DD/YYYY HH24:MI'') as PR_CREATION_DATE,
 CASE SUBSTRING(PR_FIRST_APPROVAL_DATE, 4, 3)
        WHEN upper(''Jan'') THEN ''01''
        WHEN  upper(''Feb'') THEN ''02''
        WHEN  upper(''Mar'') THEN ''03''
        WHEN  upper(''Apr'') THEN ''04''
        WHEN  upper(''May'') THEN ''05''
        WHEN  upper(''Jun'') THEN ''06''
        WHEN  upper(''Jul'') THEN ''07''
        WHEN  upper(''Aug'') THEN ''08''
        WHEN  upper(''Sep'') THEN ''09''
        WHEN  upper(''Oct'') THEN ''10''
        WHEN  upper(''Nov'') THEN ''11''
        WHEN  upper(''Dec'') THEN ''12''
    END || ''/'' || 
    SUBSTRING(PR_FIRST_APPROVAL_DATE, 1, 2) || ''/'' || SUBSTRING(PR_FIRST_APPROVAL_DATE, 8, 15) as PR_FIRST_APPROVAL_DATE,
to_char(to_timestamp(REQ_APR_DATE,''YYYY-MM-DDTHH24:MI:SS''),''MM/DD/YYYY HH24:MI'') as PR_APPROVAL_DATE,CASE SUBSTRING(P_PR_FIN_FST_APR_DT, 4, 3)
        WHEN upper(''Jan'') THEN ''01''
        WHEN  upper(''Feb'') THEN ''02''
        WHEN  upper(''Mar'') THEN ''03''
        WHEN  upper(''Apr'') THEN ''04''
        WHEN  upper(''May'') THEN ''05''
        WHEN  upper(''Jun'') THEN ''06''
        WHEN  upper(''Jul'') THEN ''07''
        WHEN  upper(''Aug'') THEN ''08''
        WHEN  upper(''Sep'') THEN ''09''
        WHEN  upper(''Oct'') THEN ''10''
        WHEN  upper(''Nov'') THEN ''11''
        WHEN  upper(''Dec'') THEN ''12''
    END || ''/'' || 
    SUBSTRING(P_PR_FIN_FST_APR_DT, 1, 2) || ''/'' || SUBSTRING(P_PR_FIN_FST_APR_DT, 8, 15) as FINANCE_FIRST_APPR_DATE_FOR_PR,
 CASE SUBSTRING(P_PROC_FST_APR_DT, 4, 3)
        WHEN upper(''Jan'') THEN ''01''
        WHEN  upper(''Feb'') THEN ''02''
        WHEN  upper(''Mar'') THEN ''03''
        WHEN  upper(''Apr'') THEN ''04''
        WHEN  upper(''May'') THEN ''05''
        WHEN  upper(''Jun'') THEN ''06''
        WHEN  upper(''Jul'') THEN ''07''
        WHEN  upper(''Aug'') THEN ''08''
        WHEN  upper(''Sep'') THEN ''09''
        WHEN  upper(''Oct'') THEN ''10''
        WHEN  upper(''Nov'') THEN ''11''
        WHEN  upper(''Dec'') THEN ''12''
    END || ''/'' || 
    SUBSTRING(P_PROC_FST_APR_DT, 1, 2) || ''/'' || SUBSTRING(P_PROC_FST_APR_DT, 8, 15) as PROCUR_FIRST_APPR_DATE_FOR_PR,REQUESTOR,PO_NUMBER,INCOTERMS_CODE,INCOTERMS_FREIGHT_TERMS,to_char(to_timestamp(PO_APR_DATE,''YYYY-MM-DDTHH24:MI:SS''),''MM/DD/YYYY HH24:MI'') as PO_APPROVE_DATE,V_PO_EXPIRY_DATE as PO_EXPIRY_DATE, -- need to get correct data as this gives 0 all the time
to_char(to_timestamp(New_Formula,''YYYY-MM-DDTHH24:MI:SS''),''DD-Mon-YY'') as PO_ACKNOWLEDGEMENT_DATE,to_char(to_timestamp(FIRST_PO_APR_DATE,''YYYY-MM-DDTHH24:MI:SS''),''MM/DD/YYYY HH24:MI'') as FIRST_PO_APPROVE_DATE,ATTRIBUTE6 as ADVANCE_PAYMENT,NAME as TERM_NAME,to_char(to_timestamp(END_DATE_ACTIVE,''YYYY-MM-DDTHH24:MI:SS''),''MM/DD/YYYY HH24:MI'') as TERM_END_DATE,PROJECT_NUM as PROJECT_NUMBER,PROJECT_MANAGER,PROJECT_MANAGER_DEPT as PROJECT_MANAGER_DEPARTMENT,CLOSED_CODE as PO_CLOSURE_STATUS,PO_AMOUNT,PR_AMOUNT,MANUAL_PO as MANUAL_POS,NO_OF_QUOTAIONS as NO_OF_QUOTATIONS,DEPARTMENT_AND_BUS as DEPARTMENT_NO,BUYER as BUYER_NAME,SOURCING_TYPE,CURRENCY,SUPPLIER_SITE,SITE_COUNTRY as SUPPLIER_SITE_COUNTRY,ORDERED_AMOUNT_IN_SAR,RECEIVED_AMOUNT_IN_SAR,PENDING_GRN_AMOUNT_IN_SAR as PENDING_AMOUNT_IN_SAR,INVOICED_AMOUNT_IN_SAR as INVOICED_AMOUNT,ATTRIBUTE1 as WHT_CODE,ATTRIBUTE2 as AGREEMENT_NUMBER,to_char(to_timestamp(CREATION_DATE_1,''YYYY-MM-DDTHH24:MI:SS''),''MM/DD/YYYY HH24:MI'') as CREATION_DATE,DAYS_BETWEEN_PR_AND_PO as DAYS_B_PR_AND_PO_FIRST_APPROV,PO_TYPE,PO_APPROVAL_STATUS,PO_CANCEL_FLAG,TYPE as TYPE_STANDARD_BLANKET,ATTRIBUTE2_1 as BID_REFERENCE_NUMBER,PO_CANCEL_FLAG as RELATED_PARTY_TRANSACTION',
    'where PO_NUMBER is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_STCSPO_OUTSTAN_PROJECT_RET',
    'REQUESTOR_DEPARTMENT,VP_BU,SUPPLIER_NAME,SUPPLIER_NUMBER,PR,PR_CREATION_DATE,PR_FIRST_APPROVAL_DATE,PR_APPROVAL_DATE,FINANCE_FIRST_APPR_DATE_FOR_PR,PROCUR_FIRST_APPR_DATE_FOR_PR,REQUESTOR,PO_NUMBER,INCOTERMS_CODE,INCOTERMS_FREIGHT_TERMS,PO_APPROVE_DATE,PO_EXPIRY_DATE,PO_ACKNOWLEDGEMENT_DATE,FIRST_PO_APPROVE_DATE,ADVANCE_PAYMENT,TERM_NAME,TERM_END_DATE,PROJECT_NUMBER,PROJECT_MANAGER,PROJECT_MANAGER_DEPARTMENT,PO_CLOSURE_STATUS,PO_AMOUNT,PR_AMOUNT,MANUAL_POS,NO_OF_QUOTATIONS,DEPARTMENT_NO,BUYER_NAME,SOURCING_TYPE,CURRENCY,SUPPLIER_SITE,SUPPLIER_SITE_COUNTRY,ORDERED_AMOUNT_IN_SAR,RECEIVED_AMOUNT_IN_SAR,PENDING_AMOUNT_IN_SAR,INVOICED_AMOUNT,WHT_CODE,AGREEMENT_NUMBER,CREATION_DATE,DAYS_BW_PR_AND_PO_FIRST_APPROV,PO_TYPE,PO_APPROVAL_STATUS,PO_CANCEL_FLAG,TYPE_STANDARD_BLANKET,BID_REFERENCE_NUMBER,RELATED_PARTY_TRANSACTION,FILENAME,PROCESS_DATE',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/PO_outstanding_full_report',
    TRUE,
    '{"legacy_sheet": "Sheet1"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'f2f252bb-4aea-46c6-baa0-b5e2b78f5111',
    'INVOICE_ITEMS_KB_Item_prices_postgres_94',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'invoice_items_kb',
    'record_id,id,type,invoice_id,account_id,bundle_id,subscription_id,description,plan_name,phase_name,usage_name,start_date,end_date,amount,rate,currency,linked_item_id,created_by,created_date,account_record_id,tenant_record_id,child_account_id,quantity,item_details,product_name,catalog_effective_date',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from invoice_items_kb)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'INVOICE_ITEMS_KB_Item_prices',
    'RECORD_ID,ID,TYPE,INVOICE_ID,ACCOUNT_ID,BUNDLE_ID,SUBSCRIPTION_ID,DESCRIPTION,PLAN_NAME,PHASE_NAME,USAGE_NAME,START_DATE,END_DATE,AMOUNT,RATE,CURRENCY,LINKED_ITEM_ID,CREATED_BY,CREATED_DATE,ACCOUNT_RECORD_ID,TENANT_RECORD_ID,CHILD_ACCOUNT_ID,QUANTITY,PRODUCT_NAME,CATALOG_EFFECTIVE_DATE,SOURCE_FILE,ITEM1_TIERUNIT,ITEM1_,ITEM1_TIERPRICE,ITEM1_QUANTITY,ITEM1_AMOUNT,ITEM2_TIERUNIT,ITEM2_,ITEM2_TIERPRICE,ITEM2_QUANTITY,ITEM2_AMOUNT,ITEM3_TIERUNIT,ITEM3_,ITEM3_TIERPRICE,ITEM3_QUANTITY,ITEM3_AMOUNT,ITEM4_TIERUNIT,ITEM4_,ITEM4_TIERPRICE,ITEM4_QUANTITY,ITEM4_AMOUNT,ITEM5_TIERUNIT,ITEM5_,ITEM5_TIERPRICE,ITEM5_QUANTITY,ITEM5_AMOUNT,ITEM6_TIERUNIT,ITEM6_,ITEM6_TIERPRICE,ITEM6_QUANTITY,ITEM6_AMOUNT,ITEM7_TIERUNIT,ITEM7_,ITEM7_TIERPRICE,ITEM7_QUANTITY,ITEM7_AMOUNT,ITEM8_TIERUNIT,ITEM8_,ITEM8_TIERPRICE,ITEM8_QUANTITY,ITEM8_AMOUNT,ITEM9_TIERUNIT,ITEM9_,ITEM9_TIERPRICE,ITEM9_QUANTITY,ITEM9_AMOUNT,ITEM10_TIERUNIT,ITEM10_,ITEM10_TIERPRICE,ITEM10_QUANTITY,ITEM10_AMOUNT,ITEM11_TIERUNIT,ITEM11_,ITEM11_TIERPRICE,ITEM11_QUANTITY,ITEM11_AMOUNT,ITEM12_TIERUNIT,ITEM12_,ITEM12_TIERPRICE,ITEM12_QUANTITY,ITEM12_AMOUNT,ITEM13_TIERUNIT,ITEM13_,ITEM13_TIERPRICE,ITEM13_QUANTITY,ITEM13_AMOUNT,ITEM14_TIERUNIT,ITEM14_,ITEM14_TIERPRICE,ITEM14_QUANTITY,ITEM14_AMOUNT,ITEM15_TIERUNIT,ITEM15_,ITEM15_TIERPRICE,ITEM15_QUANTITY,ITEM15_AMOUNT,ITEM16_TIERUNIT,ITEM16_,ITEM16_TIERPRICE,ITEM16_QUANTITY,ITEM16_AMOUNT,ITEM17_TIERUNIT,ITEM17_,ITEM17_TIERPRICE,ITEM17_QUANTITY,ITEM17_AMOUNT,ITEM18_TIERUNIT,ITEM18_,ITEM18_TIERPRICE,ITEM18_QUANTITY,ITEM18_AMOUNT,ITEM19_TIERUNIT,ITEM19_,ITEM19_TIERPRICE,ITEM19_QUANTITY,ITEM19_AMOUNT',
    'dd-mm-yyyy',
    'PROCCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    FALSE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file", "note": "exclude", "json_mapping": "tierUnit,tierUnit,tierPrice,tierPrice,quantity, quantity,amount, amount", "json_key": "item_details"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '10c46e7f-9592-4dd6-b0b1-c337a5478e7a',
    'assets_details_postgres_95',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'assets_details',
    'OWNER_ACCNT_ID,BILL_ACCNT_ID,CIRCUIT_NUMBER,SERVICE_NUMBER,CIRCUIT_IN_SERVICE_DATE,DECOMMISSION_DATE,PRODUCT_SUBSCRIBED,PRODUCT_TYPE,MRC_NRC,ROOT_PROD_ID,PRICE,QTY,PRODUCT_ID,PRODUCT_NAME,PRODUCT_DESCRIPTION,TYPE,RBM_PRODUCT_ID,RBM_PRODUCT_DESCRIPTION,RBM_TARIFF_ID,SERVICE_STATUS,ASSET_ID,SourceFileName',
    'PRODUCT_TYPE not in (''GSM'',''LL'')',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'assets_details',
    'OWNER_ACCNT_ID,BILL_ACCNT_ID,CIRCUIT_NUMBER,SERVICE_NUMBER,CIRCUIT_IN_SERVICE_DATE,DECOMMISSION_DATE,PRODUCT_SUBSCRIBED,PRODUCT_TYPE,MRC_NRC,ROOT_PROD_ID,PRICE,QTY,PRODUCT_ID,PRODUCT_NAME,PRODUCT_DESCRIPTION,TYPE,RBM_PRODUCT_ID,RBM_PRODUCT_DESCRIPTION,RBM_TARIFF_ID,SERVICE_STATUS,ASSET_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/stccrm',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "SourceFileName"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'b6180625-e3b2-4405-9eb7-3dca997889d5',
    'assets_attributes_details_postgres_96',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'assets_attributes_details',
    'ASSET_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE,SourceFileName',
    'ATTRIBUTE_NAME not in (''Activate Immediately'',''Network Support'',''Full Bar'',''Rate Plan Value'',''ESDP Group Type'',''Access Media'',''Circuit Number'',''Microwave Vendor'',''Drop Wire Distance'',''School Name'',''School Id'',''Quality of Service'',''MoE Directorate'',''IP Variant'',''Main Circuit'',''MOE Directorate'')
',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'assets_attributes_details',
    'ASSET_ID,ATTRIBUTE_NAME,ATTRIBUTE_VALUE',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/stccrm',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "SourceFileName"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'cf00cb8e-7883-4cd9-9b99-634adc8e1948',
    'A_veeam_vendor_order_postgres_97',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'veeam_vendor_order',
    'Id,"Company Name",Instanceuid,Status,"Dc Name"',
    'TO_DATE(
   to_Date(replace((SUBSTRING("Source File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING("Source File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from veeam_vendor_order)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_veeam_vendor_order',
    'ID,COMPANY_NAME,INSTANCEUID,STATUS,DC_NAME',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Source File"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '7fca97e6-910f-4b1b-9497-e376814646be',
    'A_veeam_usage_postgres_98',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'veeam_usage',
    'Id,"Company Name","Tenant Id","Slug Name",Quantity,"Dc Name",Type,"Calculation Time","Next Usage Date",Reported,"Service Id"',
    'TO_DATE(
   to_Date(replace((SUBSTRING("Source File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING("Source File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from veeam_usage)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_veeam_usage',
    'ID,COMPANY_NAME,TENANT_ID,SLUG_NAME,QUANTITY,DC_NAME,TYPE,CALCULATION_TIME,NEXT_USAGE_DATE,REPORTED,SERVICE_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Source File"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '29428fb7-3845-4ae1-8295-a75155507bb9',
    'A_subscription_subscription_quantifiable_item_price_postgres_99',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'subscription_subscriptionquantifiableitemprice',
    'Created,Id,Modified,"Quantifiable Item Price Id",Quantity,"Subscription Id"',
    'TO_DATE(
   to_Date(replace((SUBSTRING("Source File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING("Source File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from subscription_subscriptionquantifiableitemprice)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_subscription_subscription_quantifiable_item_price',
    'CREATED,ID,MODIFIED,Quantifiable Item Price ID,QUANTITY,Subscription ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Source File"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '8765070e-4743-472c-9e6e-f5d9a360b314',
    'A_revenue_report_postgres_100',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'revenue_report',
    '"Subscription Id","Cdr Account Id","Cdr Amount","Cdr Id","Invoice Description","Invoice Item Id","Invoice Category Key","Invoice Id","Plan Id","Product Id","Stcs Chart Of Accounts Category","Type","Billed Date","Invoice End Date","Invoice Start Date","Base Subscription Id","Invoice Item Status","Project Number","Service Id","Cba Adj Amount","Cdr Sent Date","Stc Invoice Type","Created Date","Cdr Sent Status","Op Number","Po Number","Invoice Date","Deal Id","Invoice Category","Mp Id","Amount","Customer Name","Customer Number","Stc Account Number","Service Provider Name","Service Name","Is Private","Name","Status","Product Name","Category Type","Product Category","Product Sub Category","Adjustment Amount","Net Amount","Stc Category"',
    'TO_DATE(
   to_Date(replace((SUBSTRING("Source File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING("Source File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from revenue_report)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_revenue_report',
    'SUBSCRIPTION_ID,CDR_ACCOUNT_ID,CDR_AMOUNT,CDR_ID,INVOICE_DESCRIPTION,INVOICE_ITEM_ID,INVOICE_CATEGORY_KEY,INVOICE_ID,PLAN_ID,PRODUCT_ID,STCS_CHART_OF_ACCOUNTS_CATEGORY,TYPE,BILLED_DATE,INVOICE_END_DATE,INVOICE_START_DATE,BASE_SUBSCRIPTION_ID,INVOICE_ITEM_STATUS,PROJECT_NUMBER,SERVICE_ID,CBA_ADJ_AMOUNT,CDR_SENT_DATE,STC_INVOICE_TYPE,CREATED_DATE,CDR_SENT_STATUS,OP_NUMBER,PO_NUMBER,INVOICE_DATE,DEAL_ID,INVOICE_CATEGORY,MP_ID,AMOUNT,CUSTOMER_NAME,CUSTOMER_NUMBER,STC_ACCOUNT_NUMBER,SERVICE_PROVIDER_NAME,SERVICE_NAME,IS_PRIVATE,NAME,STATUS,PRODUCT_NAME,CATEGORY_TYPE,PRODUCT_CATEGORY,PRODUCT_SUB_CATEGORY,ADJUSTMENT_AMOUNT,NET_AMOUNT,STC_CATEGORY',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Source File"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'b91457d3-aabc-4272-a597-8cf2d9113ba6',
    'A_palo_alto_vendor_portal_postgres_101',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'palo_alto_vendor_portal',
    'Id,Uuid,Cpuid,Serialnumber',
    'TO_DATE(
   to_Date(replace((SUBSTRING("Source File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING("Source File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from palo_alto_vendor_portal)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_palo_alto_vendor_portal',
    'ID,UUID,CPUID,SERIALNUMBER',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Source File"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'a6eae9e2-aea4-476e-9616-c8def19dfa28',
    'A_ip_list_postgres_102',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'ip_list',
    'Id,"Organization Id","Edge Gateway Id","Ip Address",Status,Created,Updated,"Org Vdc Id"',
    'TO_DATE(
   to_Date(replace((SUBSTRING("Source File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING("Source File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from ip_list)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_ip_list',
    'ID,ORGANIZATION_ID,EDGE_GATEWAY_ID,IP_ADDRESS,STATUS,CREATED,UPDATED,ORG_VDC_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Source File"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'bd0b047a-8a5c-445e-a778-312c41e49cfe',
    'A_dim_dns_vendor_platform_postgres_103',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'dim_dns_vendor_platform',
    'Name,"Mp Subscription Status","Mp Subscription","Zone Status"',
    'TO_DATE(
   to_Date(replace((SUBSTRING("Source File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING("Source File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from dim_dns_vendor_platform)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_dim_dns_vendor_platform',
    'NAME,MP_SUBSCRIPTION_STATUS,MP_SUBSCRIPTION,ZONE_STATUS',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Source File"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '006b24f4-9ce6-452c-9484-c701d038b201',
    'A_customers_customer_event_postgres_104',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'customers_customer_event',
    'Created,"Event Type",Status,"Event Id","Service Id","Mp Account Id","Subscription Id","Customer Name","Customer Id"',
    'TO_DATE(
   to_Date(replace((SUBSTRING("Source File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING("Source File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from customers_customer_event)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_customers_customer_event',
    'CREATED,EVENT_TYPE,STATUS,EVENT_ID,SERVICE_ID,MP_ACCOUNT_ID,SUBSCRIPTION_ID,CUSTOMER_NAME,CUSTOMER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Source File"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '93b3faf4-b6d4-4c82-9e60-818b295055fb',
    'A_USAGE_REPORT_NEW_postgres_105',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'vdc_usage_report',
    '"Created","Updated","Time From","Time To","Vdc Id","Reported","Resource Type","Sub Id","Id","Customer Id"',
    '"Time From" >= date_trunc(''month'', CURRENT_DATE - interval ''1 month'')
and "Time From"< date_trunc(''month'', CURRENT_DATE)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'A_USAGE_REPORT_NEW',
    'CREATED_2,UPDATED_2,TIME_FROM,TIME_TO,VDC_ID,REPORTED,RESOURCE_TYPE,SUB_ID,ID_2,CUSTOMER_ID_2',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Source File"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '920deff4-c5a9-41b4-ae84-a539e804c443',
    'mp_deploymentplanproduct_postgres_106',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'deploymentplanproduct',
    'Id,Quantity,"Flavor Id","Plan Id","Cloned From Id"',
    'TO_DATE(
   to_Date(replace((SUBSTRING(Sourcefile
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(Sourcefile
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from deploymentplanproduct)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'mp_deploymentplanproduct',
    'ID,QUANTITY,FLAVOR_ID,PLAN_ID,CLONED_FROM_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'ccce205d-ba7c-4e2f-ab5b-c092f852f2dd',
    'mp_revenue_report_finance_postgres_107',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'revenue_report_finance',
    'subscription_id,cdr_account_id,cdr_amount,cdr_id,invoice_description,invoice_item_id,invoice_category_key,invoice_id,plan_id,product_id,stcs_chart_of_accounts_category,type,billed_date,invoice_end_date,invoice_start_date,base_subscription_id,invoice_item_status,project_number,service_id,cba_adj_amount,cdr_sent_date,stc_invoice_type,created_date,cdr_sent_status,op_number,po_number,invoice_date,deal_id,invoice_category,mp_id,amount,customer_name,customer_Number,stc_account_number,service_provider_name,service_name,is_private,name,status,product_name,category_type,product_category,product_sub_category,adjustment_amount,net_amount,stc_category',
    'TO_DATE(
   to_Date(replace((SUBSTRING("Source_File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING("Source_File"
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from revenue_report_finance)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'mp_revenue_report_finance',
    'SUBSCRIPTION_ID,CDR_ACCOUNT_ID,CDR_AMOUNT,CDR_ID,INVOICE_DESCRIPTION,INVOICE_ITEM_ID,INVOICE_CATEGORY_KEY,INVOICE_ID,PLAN_ID,PRODUCT_ID,STCS_CHART_OF_ACCOUNTS_CATEGORY,type,BILLED_DATE,INVOICE_END_DATE,INVOICE_START_DATE,BASE_SUBSCRIPTION_ID,INVOICE_ITEM_STATUS,PROJECT_NUMBER,SERVICE_ID,CBA_ADJ_AMOUNT,CDR_SENT_DATE,STC_INVOICE_TYPE,CREATED_DATE,CDR_SENT_STATUS,OP_NUMBER,PO_NUMBER,INVOICE_DATE,DEAL_ID,INVOICE_CATEGORY,MP_ID,AMOUNT,CUSTOMER_NAME,customer_Number,STC_ACCOUNT_NUMBER,SERVICE_PROVIDER_NAME,SERVICE_NAME,IS_PRIVATE,name,STATUS,PRODUCT_NAME,CATEGORY_TYPE,PRODUCT_CATEGORY,PRODUCT_SUB_CATEGORY,ADJUSTMENT_AMOUNT,NET_AMOUNT,STC_CATEGORY',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Source_File"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'dae2f1bc-169f-412d-93f6-8deab062bf06',
    'PRD_EVENT_FILEVALT_DNS_FILTER_postgres_108',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'stc_marketplace_events_event',
    'nvl(substring(payload::text from ''"DomainName".*?"value": "([^"]*)"''), replace(replace(substring(callback_message::text from ''"landing_page_url": "([^"]*)"''), ''https://'', ''''), ''/admin'', '''')),object_id,"type",status,case when lower(payload) like ''%dns%'' then ''Cloud DNS''else ''Filevalt''end as product',
    '(lower(payload) like ''%dns%''
		or callback_message like ''%filevalt.com%'')
	and "type" = ''subscription.created''
and TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from stc_marketplace_events_event)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_EVENT_FILEVALT_DNS_FILTER',
    'CALLBACK_MESSAGE_PAYLOAD_DOMAIN,PAYLOAD,TYPE,STATUS,PRODUCT',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'fb500855-1392-4687-a9d1-f85104e10707',
    'STCS_PROJECTS_HEADER_ALL_REPORT_postgres_109',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'STCS_PROJECT_HEADER_ALL',
    '"Project Segment" ,
"Project Name",
"Project Description",
"Project Organization" ,
"Business Unit",
"Service Type",
"Channel Segment",
"Agile Project",
"Account Number",
"Erp Region",
"Customer Name",
"Project Status Desc",
TO_CHAR("Project Start Date", ''DD-Mon-YY'') "Project Start Date",
TO_CHAR( "Project Finish Date", ''DD-Mon-YY'') "Project Finish Date",
TO_CHAR("Project Closed Date", ''DD-Mon-YY'') "Project Closed Date",
"Bid Reference",
"Customer Po Number",
TO_CHAR("Po Issuance Date", ''DD-Mon-YY'')"Po Issuance Date",
"Stcs Fc Project Type",
TO_CHAR("Po Start Date", ''DD-Mon-YY'')"Po Start Date",
TO_CHAR("Po Expiration Date", ''DD-Mon-YY'') "Po Expiration Date",
"Contract Number",
"Parent Project",
"Project Manager",
"Engagement Manager",
"Pm Email Address",
"Account Manager",
TO_CHAR("Project Creation Date", ''DD-Mon-YY'')"Project Creation Date",
TO_CHAR("Rla Baselined Date", ''DD-Mon-YY'')"Rla Baselined Date",
TO_CHAR("Po Baselined Date" , ''DD-Mon-YY'') "Po Baselined Date" ,
"Po Value",
"Rla Value",
"Planned Cost",
"Profit Margin",
"Invoiced Amount",
"Ebu Customer Segment",
"Erp Customer Segment",
TO_CHAR("Last Invoice Date" , ''DD-Mon-YY'') "Last Invoice Date",
TO_CHAR("Last Revenue Date" , ''DD-Mon-YY'') "Last Revenue Date",
TO_CHAR( "End Customer Po Date To Stc", ''DD-Mon-YY'') "End Customer Po Date To Stc",
TO_CHAR("Po Issuance Date" , ''DD-Mon-YY'') "Po Issuance Date",
"Incurred Cost" ,
"Total Billing" ,
"Billing Allocation" ,
TO_CHAR( "Original Baseline Date" , ''DD-Mon-YY'')  "Original Baseline Date" ,
"Margin Per"',
    '"Project Segment" is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'STCS_PROJECTS_HEADER_ALL_REPORT',
    'PROJECT_NUMBER,NAME,DESCRIPTION,PROJECT_ORGANIZATION,BUSINESS_UNIT,SERVICE_TYPE,CHANNEL_SEGMENT,AGILEPROJECT,ACCOUNT_NUMBER,REGION,CUSTOMER_NAME,STATUS,START_DATE,FINISH_DATE,CLOSED,BID_REFERENCE,PO_NUMBER,PO_ISSUANCE_DATE,FC_PROJECT_TYPE,PO_START_DATE,PO_EXPIRATION_DATE,CONTRACT_NUMBER,PARENT_PROJECT,PROJECT_MANAGER,ENGAGEMENT_MANAGER,PM_EMAIL_ADDRESS,ACCOUNT_MANAGER,CREATION_DATE,RLA_BASELINED_DATE,PO_BASELINED_DATE,PO_VALUE,RLA_VALUE,PLANNED_COST,PROFIT_MARGIN,INVOICED_AMOUNT,EBU_CUSTOMER_SEGMENT,CUSTOMER_SEGMENTS,LAST_INVOICE_DATE,LAST_REVENUE_DATE,END_CUSTOMER_PO_DATE_TO_STC,PO_ISSUANCE_DATE_1,INCURRED_COST,TOTAL_BILLING,BILLING_ALLOCATION,ORIGINAL_BASE_LINE_DATE,MARGIN_PER',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/Header',
    TRUE,
    '{"legacy_sheet": "Sheet1"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '0145f466-9f90-4816-a88d-a27d3ac0d8dd',
    'opportunity_postgres_110',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    '"BSCH_Bayan".opportunity',
    'name,statecode,statecodename,opportunityratingcode,opportunityratingcodename,closeprobability,estimatedclosedate,stcs_totalcontractvaluetcv,statuscode,statuscodename,stcs_roadmapstatus,stcs_roadmapstatusname,stcs_opportunitytypename,stcs_opportunityrecordtypename,owneridname,stcs_opportunitynaturename,stcs_initialvalue,parentaccountidname,stcs_businessunitname,isrevenuesystemcalculatedname,modifiedon,modifiedbyname,stcs_opportunitynumber,description,stcs_processstagename,opportunityid,stcs_type,stcs_typename,totalamount,stcs_sourceopportunityname,stcs_solutiontypename,stcs_solutioncost,stcs_projectstatus,stcs_projectdurationmonth,stcs_outsourcing,stcs_managedservices,stcs_managedservicestandard,stcs_erpprojectnumber,stcs_digitalservices,stcs_cybersecurity,stcs_connectivitycommunicationownername,stcs_connectivitycommunication_base,stcs_connectivitycommunication,stcs_cloud,stcs_awardedtypename',
    'name is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'opportunity',
    'NAME,STATECODE,STATECODENAME,OPPORTUNITYRATINGCODE,OPPORTUNITYRATINGCODENAME,CLOSEPROBABILITY,ESTIMATEDCLOSEDATE,STCS_TOTALCONTRACTVALUETCV,STATUSCODE,STATUSCODENAME,STCS_ROADMAPSTATUS,STCS_ROADMAPSTATUSNAME,STCS_OPPORTUNITYTYPENAME,STCS_OPPORTUNITYRECORDTYPENAME,OWNERIDNAME,STCS_OPPORTUNITYNATURENAME,STCS_INITIALVALUE,PARENTACCOUNTIDNAME,STCS_BUSINESSUNITNAME,ISREVENUESYSTEMCALCULATEDNAME,MODIFIEDON,MODIFIEDBYNAME,STCS_OPPORTUNITYNUMBER,DESCRIPTION,STCS_PROCESSSTAGENAME,OPPORTUNITYID,STCS_TYPE,STCS_TYPENAME,TOTALAMOUNT,STCS_SOURCEOPPORTUNITYNAME,STCS_SOLUTIONTYPENAME,STCS_SOLUTIONCOST,STCS_PROJECTSTATUS,STCS_PROJECTDURATIONMONTH,STCS_OUTSOURCING,STCS_MANAGEDSERVICES,STCS_MANAGEDSERVICESTANDARD,STCS_ERPPROJECTNUMBER,STCS_DIGITALSERVICES,STCS_CYBERSECURITY,STCS_CONNECTIVITYCOMMUNICATIONOWNERNAME,STCS_CONNECTIVITYCOMMUNICATION_BASE,STCS_CONNECTIVITYCOMMUNICATION,STCS_CLOUD,STCS_AWARDEDTYPENAME',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/OP',
    TRUE,
    '{"legacy_sheet": "Sheet1"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'f3f40bfd-36e9-468c-aacf-78db2783c1d3',
    'ombilling_resources_postgres_111',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'ombilling_resources',
    'id,"name",resource_id,resource_service,status,sub_status,recon_status,customer_info_id,provisioned_date,de_provisioned_date,updated_time,consider_update,parent_id,flavor,"size",unit_type,image,image_type,image_visibility,image_state,created,updated,flavor_name,image_name,deleted_by,os_type,volume_type,app_type',
    'TO_DATE(
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')
) = (select max (
   to_Date(replace((SUBSTRING(source_file
from
 ''\d{4}_\d{2}_\d{2}'')),
 ''_'',
 ''-''),''yyyy-MM-dd'')) from ombilling_resources)',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'ombilling_resources',
    'ID,NAME,RESOURCE_ID,RESOURCE_SERVICE,STATUS,SUB_STATUS,RECON_STATUS,CUSTOMER_INFO_ID,PROVISIONED_DATE,DE_PROVISIONED_DATE,UPDATED_TIME,CONSIDER_UPDATE,PARENT_ID,FLAVOR,SIZE,UNIT_TYPE,IMAGE,IMAGE_TYPE,IMAGE_VISIBILITY,IMAGE_STATE,CREATED,UPDATED,FLAVOR_NAME,IMAGE_NAME,DELETED_BY,OS_TYPE,VOLUME_TYPE,APP_TYPE',
    'dd-Mon-yyyy',
    'PROCESS_DATE',
    10,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "source_file"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'de8c96e8-1612-45ab-9f72-7bf251028f58',
    'SOLUTIONS_A_customers_customer_event_postgres_112',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.customers_customerevent',
    'Created,"Event Type",Status,"Event Id","Service Id","Mp Account Id","Subscription Id","Customer Name","Customer Id"',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_customers_customer_event',
    'CREATED,EVENT_TYPE,STATUS,EVENT_ID,SERVICE_ID,MP_ACCOUNT_ID,SUBSCRIPTION_ID,CUSTOMER_NAME,CUSTOMER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'c78b5a31-96f2-4722-b40c-643b37bf4be7',
    'SOLUTIONS_A_KILLBILL_INVOICES_ITEMS_postgres_113',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.kill_bill_invoice_items',
    'record_id,id,type,invoice_id,account_id,bundle_id,subscription_id,description,plan_name,phase_name,usage_name,start_date,end_date,amount,rate,currency,linked_item_id,created_by,created_date,account_record_id,tenant_record_id,child_account_id,quantity,product_name,catalog_effective_date',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_KILLBILL_INVOICES_ITEMS',
    'RECORD_ID,ID,type,INVOICE_ID,ACCOUNT_ID,BUNDLE_ID,SUBSCRIPTION_ID,DESCRIPTION,PLAN_NAME,PHASE_NAME,USAGE_NAME,START_DATE,END_DATE,AMOUNT,RATE,CURRENCY,LINKED_ITEM_ID,CREATED_BY,CREATED_DATE,ACCOUNT_RECORD_ID,TENANT_RECORD_ID,CHILD_ACCOUNT_ID,QUANTITY,PRODUCT_NAME,CATALOG_EFFECTIVE_DATE',
    'dd-mm-yyyy',
    'PROCCESS_DATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'e05c04c4-bdd3-4282-a75f-eab2af3cdaaa',
    'SOLUTIONS_A_KILLBILL_INVOICES_ITEMS_postgres_114',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.kill_bill_invoice_items',
    'RECORD_ID,
 ID,
 type,
 INVOICE_ID,
 ACCOUNT_ID,
 BUNDLE_ID,
 SUBSCRIPTION_ID,
 DESCRIPTION,
 PLAN_NAME,
 PHASE_NAME,
 USAGE_NAME,
 START_DATE,
 END_DATE,
 AMOUNT,
 RATE,
 CURRENCY,
 LINKED_ITEM_ID,
 CREATED_BY,
 CREATED_DATE,
 ACCOUNT_RECORD_ID,
 TENANT_RECORD_ID,
 CHILD_ACCOUNT_ID,
 QUANTITY,
 PRODUCT_NAME,
 CATALOG_EFFECTIVE_DATE,null EXTERNAL_KEY',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_KILLBILL_INVOICES_ITEMS',
    'RECORD_ID,ID,TYPE,INVOICE_ID,ACCOUNT_ID,BUNDLE_ID,SUBSCRIPTION_ID,DESCRIPTION,PLAN_NAME,PHASE_NAME,USAGE_NAME,START_DATE,END_DATE,AMOUNT,RATE,CURRENCY,LINKED_ITEM_ID,CREATED_BY,CREATED_DATE,ACCOUNT_RECORD_ID,TENANT_RECORD_ID,CHILD_ACCOUNT_ID,QUANTITY,PRODUCT_NAME,CATALOG_EFFECTIVE_DATE,EXTERNAL_KEY',
    'dd-Mon-yyyy',
    'PROCESS_DATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'cc89863c-ca82-46cf-9328-a1e073d55665',
    'SOLUTIONS_A_KILLBILL_INVOICES_ITEMS_postgres_115',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.kill_bill_invoice_items',
    'record_id,id,type,invoice_id,account_id,bundle_id,subscription_id,description,plan_name,phase_name,usage_name,start_date,end_date,amount,rate,currency,linked_item_id,created_by,created_date,account_record_id,tenant_record_id,child_account_id,quantity,item_details,product_name,catalog_effective_date',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_KILLBILL_INVOICES_ITEMS',
    'RECORD_ID,ID,TYPE,INVOICE_ID,ACCOUNT_ID,BUNDLE_ID,SUBSCRIPTION_ID,DESCRIPTION,PLAN_NAME,PHASE_NAME,USAGE_NAME,START_DATE,END_DATE,AMOUNT,RATE,CURRENCY,LINKED_ITEM_ID,CREATED_BY,CREATED_DATE,ACCOUNT_RECORD_ID,TENANT_RECORD_ID,CHILD_ACCOUNT_ID,QUANTITY,PRODUCT_NAME,CATALOG_EFFECTIVE_DATE,"Sourcefile",ITEM1_TIERUNIT,ITEM1_,ITEM1_TIERPRICE,ITEM1_QUANTITY,ITEM1_AMOUNT,ITEM2_TIERUNIT,ITEM2_,ITEM2_TIERPRICE,ITEM2_QUANTITY,ITEM2_AMOUNT,ITEM3_TIERUNIT,ITEM3_,ITEM3_TIERPRICE,ITEM3_QUANTITY,ITEM3_AMOUNT,ITEM4_TIERUNIT,ITEM4_,ITEM4_TIERPRICE,ITEM4_QUANTITY,ITEM4_AMOUNT,ITEM5_TIERUNIT,ITEM5_,ITEM5_TIERPRICE,ITEM5_QUANTITY,ITEM5_AMOUNT,ITEM6_TIERUNIT,ITEM6_,ITEM6_TIERPRICE,ITEM6_QUANTITY,ITEM6_AMOUNT,ITEM7_TIERUNIT,ITEM7_,ITEM7_TIERPRICE,ITEM7_QUANTITY,ITEM7_AMOUNT,ITEM8_TIERUNIT,ITEM8_,ITEM8_TIERPRICE,ITEM8_QUANTITY,ITEM8_AMOUNT,ITEM9_TIERUNIT,ITEM9_,ITEM9_TIERPRICE,ITEM9_QUANTITY,ITEM9_AMOUNT,ITEM10_TIERUNIT,ITEM10_,ITEM10_TIERPRICE,ITEM10_QUANTITY,ITEM10_AMOUNT,ITEM11_TIERUNIT,ITEM11_,ITEM11_TIERPRICE,ITEM11_QUANTITY,ITEM11_AMOUNT,ITEM12_TIERUNIT,ITEM12_,ITEM12_TIERPRICE,ITEM12_QUANTITY,ITEM12_AMOUNT,ITEM13_TIERUNIT,ITEM13_,ITEM13_TIERPRICE,ITEM13_QUANTITY,ITEM13_AMOUNT,ITEM14_TIERUNIT,ITEM14_,ITEM14_TIERPRICE,ITEM14_QUANTITY,ITEM14_AMOUNT,ITEM15_TIERUNIT,ITEM15_,ITEM15_TIERPRICE,ITEM15_QUANTITY,ITEM15_AMOUNT,ITEM16_TIERUNIT,ITEM16_,ITEM16_TIERPRICE,ITEM16_QUANTITY,ITEM16_AMOUNT,ITEM17_TIERUNIT,ITEM17_,ITEM17_TIERPRICE,ITEM17_QUANTITY,ITEM17_AMOUNT,ITEM18_TIERUNIT,ITEM18_,ITEM18_TIERPRICE,ITEM18_QUANTITY,ITEM18_AMOUNT,ITEM19_TIERUNIT,ITEM19_,ITEM19_TIERPRICE,ITEM19_QUANTITY,ITEM19_AMOUNT',
    'dd-mm-yyyy',
    'PROCCESS_DATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    FALSE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile", "note": "exclude", "json_mapping": "tierUnit,tierUnit,tierPrice,tierPrice,quantity, quantity,amount, amount", "json_key": "item_details"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'd47e153e-e585-46de-8808-8fdfa0ada1ee',
    'SOLUTIONS_KILLBILL_ACCOUNTS_postgres_116',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.kill_bill_accounts',
    'RECORD_ID,
ID,
EXTERNAL_KEY,
EMAIL,
NAME,
FIRST_NAME_LENGTH,
CURRENCY,
BILLING_CYCLE_DAY_LOCAL,
PAYMENT_METHOD_ID,
TIME_ZONE,
LOCALE,
ADDRESS1,
ADDRESS2,
COMPANY_NAME,
CITY,
STATE_OR_PROVINCE,
COUNTRY,
POSTAL_CODE,
PHONE,
MIGRATED,
CREATED_DATE,
CREATED_BY,
UPDATED_DATE,
UPDATED_BY,
TENANT_RECORD_ID,
PARENT_ACCOUNT_ID,
IS_PAYMENT_DELEGATED_TO_PARENT,
REFERENCE_TIME',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_KILLBILL_ACCOUNTS',
    'RECORD_ID,ID,EXTERNAL_KEY,EMAIL,NAME,FIRST_NAME_LENGTH,CURRENCY,BILLING_CYCLE_DAY_LOCAL,PAYMENT_METHOD_ID,TIME_ZONE,LOCALE,ADDRESS1,ADDRESS2,COMPANY_NAME,CITY,STATE_OR_PROVINCE,COUNTRY,POSTAL_CODE,PHONE,MIGRATED,CREATED_DATE,CREATED_BY,UPDATED_DATE,UPDATED_BY,TENANT_RECORD_ID,PARENT_ACCOUNT_ID,IS_PAYMENT_DELEGATED_TO_PARENT,REFERENCE_TIME',
    'dd-mm-yyyy',
    'PROCESS_DATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'a1bc75bd-f96f-440e-a0a7-be796e03c8ad',
    'SOLUTIONS_A_KILLBILL_INVOICES_postgres_117',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.kill_bill_invoices',
    'RECORD_ID,
ID,
ACCOUNT_ID,
INVOICE_DATE,
TARGET_DATE,
CURRENCY,
MIGRATED,
CREATED_BY,
CREATED_DATE,
ACCOUNT_RECORD_ID,
TENANT_RECORD_ID,
PARENT_INVOICE,
STATUS',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_KILLBILL_INVOICES',
    'RECORD_ID,ID,ACCOUNT_ID,INVOICE_DATE,TARGET_DATE,CURRENCY,MIGRATED,CREATED_BY,CREATED_DATE,ACCOUNT_RECORD_ID,TENANT_RECORD_ID,PARENT_INVOICE,STATUS',
    'dd-mm-yyyy',
    'PROCCESS_DATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'a829f1b0-f7ba-40b6-be40-21081f057928',
    'SOLUTIONS_KILLBILL_SUBSCRIPTIONS_postgres_118',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.kill_bill_subscriptions',
    'RECORD_ID,
 ID,
 BUNDLE_ID,
 CATEGORY,
 START_DATE,
 BUNDLE_START_DATE,
 CHARGED_THROUGH_DATE,
 CREATED_BY,
 CREATED_DATE,
 UPDATED_BY,
 UPDATED_DATE,
 ACCOUNT_RECORD_ID,
 TENANT_RECORD_ID,
 MIGRATED,
 EXTERNAL_KEY',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_KILLBILL_SUBSCRIPTIONS',
    'RECORD_ID,ID,BUNDLE_ID,CATEGORY,START_DATE,BUNDLE_START_DATE,CHARGED_THROUGH_DATE,CREATED_BY,CREATED_DATE,UPDATED_BY,UPDATED_DATE,ACCOUNT_RECORD_ID,TENANT_RECORD_ID,MIGRATED,EXTERNAL_KEY',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'f2c3f12e-5547-4a28-a6aa-a7d4cbdf12ca',
    'SOLUTIONS_A_ACCOUNTS_postgres_119',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_account',
    'id,created,modified,name,customer_id_type,customer_id,customer_number,mobile_no,land_line,email,website,country,city,currency,status,status_reason,trial_status,district,building_number,street_name,postal_code,additional_number,address1,address2,region,zip_code,security_classification_level,trial_suspension_date,is_testing,site_id,super_admin_role_id,suspension_date,name_ar',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_ACCOUNTS',
    'ID,CREATED,MODIFIED,NAME,Customer ID Type,Customer ID,Customer Number,Mobile No,Land Line,EMAIL,WEBSITE,COUNTRY,CITY,CURRENCY,STATUS,Status Reason,Trial Status,DISTRICT,Building Number,Street Name,Postal Code,Additional Number,Add Res S1,Add Res S2,REGION,Zip Code,Security Classification Level,Trial Suspension Date,Is Testing,Site ID,Super Admin Role ID,Suspension Date,Name Ar',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'fce8698e-0748-4f1d-9b2d-db2d5a60f7fb',
    'SOLUTIONS_a_deals_postgres_120',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_deal',
    'id,created,modified,min_amount,max_amount,status,expiry_date,start_date,end_date,renew,type,catalog_updated,accepted_by_id,account_manager_id,agreement_id,cloned_from_id,customer_id,price_list_id,special_offer_id,duration,po_number,version,op_number,created_by_id,"Sourcefile"',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_a_deals',
    'ID,CREATED,MODIFIED,Min Amount,Max Amount,STATUS,Expiry Date,Start Date,End Date,RENEW,Type,Catalog Updated,Accepted By ID,Account Manager ID,Agreement ID,Cloned From ID,Customer ID,Price List ID,Special Offer ID,DURATION,Po Number,VERSION,Op Number,Created By ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'a19ab3e8-98ed-446f-a2ed-374f39782ff6',
    'SOLUTIONS_A_CUSTOMERS_DEAL_CUSTOM_SERVICE_postgres_121',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.customers_dealcustomservice',
    'id,created,modified,is_auto,project_number,deal_id,service_id,duration',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_CUSTOMERS_DEAL_CUSTOM_SERVICE',
    'ID,CREATED,MODIFIED,Is Auto,Project Number,Deal ID,Service ID,DURATION',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'c8864723-0fc9-4902-854e-9bdad12b7396',
    'SOLUTIONS_CUSTOMERS_SERVICE_COMMITMENT_postgres_122',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.servicecommitment',
    'CATEGORY,Commitment_Amount,CREATED,Deal_ID,ID,MODIFIED,Service_ID',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_CUSTOMERS_SERVICE_COMMITMENT',
    'CATEGORY,Commitment Amount,CREATED,Deal ID,ID,MODIFIED,Service ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '818cd608-4c0b-4198-9196-6536ebec7075',
    'SOLUTIONS_PRD_CLOUDEVENT_LOG_postgres_123',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.events_event',
    'API_VERSION,
 CONTENT_TYPE_ID,
 CREATED,
 ID,
 MODIFIED,
 NEXT_RETRY_TIME,
 OBJECT_ID,
 REFERENCE,
 SERVICE_ID,
 SIGNATURE,
 STATUS,
 content_type_id,
 URL
 webhook_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_PRD_CLOUDEVENT_LOG',
    'API_VERSION,CONTENT_TYPE_ID,CREATED,ID,MODIFIED,NEXT_RETRY_TIME,OBJECT_ID,REFERENCE,SERVICE_ID,SIGNATURE,STATUS,TYPE,URL,WEB_HOOK_ID',
    'dd-Mon-yyyy',
    'PROCESS_DATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '2e5158a1-7f02-4b38-8258-2ae92e754c14',
    'SOLUTIONS_PRD_CLOUDEVENT_LOG_postgres_124',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.events_event',
    'nvl(substring(payload::text from ''"DomainName".*?"value": "([^"]*)"''), replace(replace(substring(callback_message::text from ''"landing_page_url": "([^"]*)"''), ''https://'', ''''), ''/admin'', '''')),object_id,"type",status,case when lower(payload) like ''%dns%'' then ''Cloud DNS''else ''Filevalt''end as product',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_PRD_CLOUDEVENT_LOG',
    'CALLBACK_MESSAGE_PAYLOAD_DOMAIN,PAYLOAD,TYPE,STATUS,PRODUCT',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '59e2219f-b6bf-4266-9c0b-0ec0416da0dd',
    'SOLUTIONS_A_FLAVOR_postgres_125',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_flavor',
    'id,created,modified,price,"order",slug,retired,billable_unit_id,cloned_from_id,override_id,price_list_id,product_id,sub_product_category_id,uuid',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_FLAVOR',
    'ID,CREATED,MODIFIED,PRICE,Order,SLUG,RETIRED,Bill Able Unit ID,Cloned From ID,Override ID,Price List ID,Product ID,Sub Product Category ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '3bb0a33f-4896-483f-a31a-ebcf577041b7',
    'SOLUTIONS_A_FLAVOR_TRANSLATION_postgres_126',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_flavor_translation',
    'id,language_code,name,description,master_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_FLAVOR_TRANSLATION',
    'ID,Language Code,NAME,DESCRIPTION,Master ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'f66fb943-3e6b-4963-846f-d93ed015eadd',
    'SOLUTIONS_STC_MP_service_management_flavoritem_postgres_127',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_flavoritem',
    'id,value,cloned_from_id,flavor_id,item_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_STC_MP_service_management_flavoritem',
    'ID,VALUE,CLONED_FROM_ID,FLAVOR_ID,ITEM_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '7f843e52-ffb1-41f4-a939-bb433a902f79',
    'SOLUTIONS_A_SERVICE_ITEM_postgres_128',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_service_item',
    'Cloned_From_ID,CREATED,ID,Is_Feature,MODIFIED,"order",Service_ID',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_SERVICE_ITEM',
    'Cloned From ID,CREATED,ID,Is Feature,MODIFIED,Order,Service ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'b785b11d-3b05-4ceb-bb81-6599d7abea5c',
    'SOLUTIONS_A_PLAN_ITEM_TRANSLATION_postgres_129',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_item_translation',
    'ID,Language_Code,Master_ID,NAME',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PLAN_ITEM_TRANSLATION',
    'ID,Language Code,Master ID,NAME',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'e3df8aad-6707-477c-8fcd-26a48066ac0b',
    'SOLUTIONS_A_SERVICE_ITEM_UNIT_postgres_130',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_item_units',
    'ID,Item_ID,Unit_ID',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_SERVICE_ITEM_UNIT',
    'ID,Item ID,Unit ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'f28afecc-7324-4607-9b8c-7bc375819841',
    'SOLUTIONS_a_phase_postgres_131',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_service_phase',
    'id,created,modified,type,duration_unit,duration_number,billing_period,commitment,cloned_from_id,plan_price_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_a_phase',
    'ID,CREATED,MODIFIED,Type,Duration Unit,Duration Number,Billing Period,COMMITMENT,Cloned From ID,Plan Price ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '8dc675cd-407e-4f52-b819-d8ec84d30c5d',
    'SOLUTIONS_A_PHASE_PRICE_postgres_132',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_service_phaseprice',
    'id,type,currency,value,cloned_from_id,phase_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PHASE_PRICE',
    'ID,Type,CURRENCY,VALUE,Cloned From ID,Phase ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '1f375f5f-2902-442e-b819-14e07279c80f',
    'SOLUTIONS_A_PLAN_postgres_133',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_plan',
    'category_type,cloned_from_id,created,datacenter_id,id,maximum_allowed_subscriptions,modified,mrc_category_type,mrc_stcs_chart_of_accounts_category,"order",otc_category_type,otc_stcs_chart_of_accounts_category,retired,service_id,slug,stcs_chart_of_accounts_category,"type",mrc_sub_product_category_id,otc_sub_product_category_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PLAN',
    'Category Type,Cloned From ID,CREATED,Datacenter ID,ID,Maximum Allowed Subscriptions,MODIFIED,Mrc Category Type,Mrc St Cs Chart Of Accounts Category,Order,Otc Category Type,Otc St Cs Chart Of Accounts Category,RETIRED,Service ID,SLUG,St Cs Chart Of Accounts Category,Type,Mrc Sub Product Category ID,Otc Sub Product Category ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '004c9583-933f-45a6-8b35-158b07b438ec',
    'SOLUTIONS_A_PLAN_TRANSLATION_postgres_134',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_plan_translation',
    'id,language_code,"name",master_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PLAN_TRANSLATION',
    'ID,Language Code,NAME,Master ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '6f5213fb-1e40-4d7b-b2f5-bddae1d8c13d',
    'SOLUTIONS_A_PLAN_TO_ITEM_MAPPING_postgres_135',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_planitem',
    'Cloned_From_ID,CREATED,ID,Item_ID,MODIFIED,Plan_ID,QUANTITY,Unit_ID',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PLAN_TO_ITEM_MAPPING',
    'Cloned From ID,CREATED,ID,Item ID,MODIFIED,Plan ID,QUANTITY,Unit ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'b3de872e-0e75-4c42-a144-76156d3c3b8c',
    'SOLUTIONS_A_PLAN_PRICE_postgres_136',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_planprice',
    'id,created,modified,slug,cloned_from_id,override_id,plan_id,price_list_id,sub_product_category_id,uuid',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PLAN_PRICE',
    'ID,CREATED,MODIFIED,SLUG,Cloned From ID,Override ID,Plan ID,Price List ID,Sub Product Category ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '22f4e6f0-5ec5-4033-ac9e-73b972eac9e2',
    'SOLUTIONS_A_PRICE_LIST_postgres_137',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_pricelist',
    'id,slug,is_active,cloned_from_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PRICE_LIST',
    'ID,SLUG,Is Active,Cloned From ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'a9a896bd-e64d-40b8-906f-d4997e311629',
    'SOLUTIONS_A_PRODUCT_postgres_138',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_product',
    'id,created,modified,"order",slug,category_type,stcs_chart_of_accounts_category,cloned_from_id,datacenter_id,service_id,uuid,"Sourcefile"',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PRODUCT',
    'ID,CREATED,MODIFIED,Order,SLUG,Category Type,St Cs Chart Of Accounts Category,Cloned From ID,Datacenter ID,Service ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'c4a72de0-0ae1-4c0a-86f6-efe439d28406',
    'SOLUTIONS_A_PRODUCT_TRANS_postgres_139',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_product_translation',
    'ID,language_Code,Master_ID,NAME',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PRODUCT_TRANS',
    'ID,Language Code,Master ID,NAME',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '097f1fa1-46e6-4171-92da-af5c90759760',
    'SOLUTIONS_A_QUANTIFIABLE_ITEM_postgres_140',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_quantifiableitem',
    'Cloned_From_ID,CREATED,ID,MODIFIED,"order",Service_ID,Unit_ID',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_QUANTIFIABLE_ITEM',
    'Cloned From ID,CREATED,ID,MODIFIED,Order,Service ID,Unit ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '1efad167-c7e4-4e63-b0ec-612793377131',
    'SOLUTIONS_A_QUANTIFIABLE_ITEM_TRANSLATION_postgres_141',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_service_quantifiableitem_translati',
    'DESCRIPTION,ID,Language_Code,Master_ID,NAME',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_QUANTIFIABLE_ITEM_TRANSLATION',
    'DESCRIPTION,ID,Language Code,Master ID,NAME',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '806507d9-79b3-4788-ada8-ac118af82cc7',
    'SOLUTIONS_A_QUANTIFIABLE_ITEM_PRICE_postgres_142',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_quantifiableitemprice',
    'Cloned_From_ID,
 CREATED,
 CURRENCY,
 Fixed_Price,
 ID,
 MAX,
 MIN,
 MODIFIED,
 Plan_Price_ID,
 PRICE,
 Quantifiable_Item_ID',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_QUANTIFIABLE_ITEM_PRICE',
    'Cloned From ID,CREATED,CURRENCY,Fixed Price,ID,MAX,MIN,MODIFIED,Plan Price ID,PRICE,Quantifiable Item ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '1402eb3f-daab-4310-aee3-2d0563f8f1bb',
    'SOLUTIONS_A_SERVICE_postgres_143',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_service',
    'Approval_Date,
AVAILABILITY,
Billing_Type,
Cancel_Validations_URL,
Cloned_From_ID,
CREATED,
DELETED,
Depends_On_ID,
document,
events_timeout,
events_timeout_unit,
ID,
Is_Beta,
Is_Featured,
Is_Private,
Landing_Page_URL,
LOGO,
Management_Link,
MODIFIED,
multi_datacenters,
Owner_Email,
Service_Provider_ID,
SLUG,
STATUS,
User_Management_Type,
Owner_ID,
CATEGORY,
Publish_Date,
Allow_Remote_Creation',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_SERVICE',
    'Approval Date,AVAILABILITY,Billing Type,Cancel Validations URL,Cloned From ID,CREATED,DELETED,Depends On ID,DOCUMENT,Events Time Out,Events Time Out Unit,ID,Is Beta,Is Featured,Is Private,Landing Page URL,LOGO,Management Link,MODIFIED,Multi Data Centers,Owner Email,Service Provider ID,SLUG,STATUS,User Management Type,Owner ID,CATEGORY,Publish Date,Allow Remote Creation',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'e4e5d342-290d-4680-acc8-6eca78146c33',
    'SOLUTIONS_A_SERVICE_TRANSLATION_postgres_144',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_service_translation',
    'Agreement_Terms,ID,Language_Code,Master_ID,NAME,Short_Description,TITLE',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_SERVICE_TRANSLATION',
    'Agreement Terms,ID,Language Code,Master ID,NAME,Short Description,TITLE',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'f7d3ca63-ff46-46a6-aece-8bb84542112b',
    'SOLUTIONS_A_SUBSCRIPTION_SUBSCRIPTION_postgres_145',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.subscription_subscription',
    'attachment,base_subscription_id,canceled_at,created,customer_id,datacenter_id,dismissed,end_date,id,installment_duration_id,instructions,items_fixed_price,items_price,landing_page_url,management_page_url,modified,name,override_fixed_price,override_price,parent_subscription_id,plan_id,plan_price_id,price_list_id,project_number,service_id,start,status,status_message,status_reason,opportunity_number,partner_name,created_remotely,null as extra_fields_unmasked',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_SUBSCRIPTION_SUBSCRIPTION',
    'ATTACHMENT,Base Subscription ID,Canceled At,CREATED,Customer ID,Datacenter ID,DISMISSED,End Date,ID,Installment Duration ID,INSTRUCTIONS,Items Fixed Price,Items Price,Landing Page URL,Management Page URL,MODIFIED,NAME,Override Fixed Price,Override Price,Parent Subscription ID,Plan ID,Plan Price ID,Price List ID,Project Number,Service ID,Start,STATUS,Status Message,Status Reason,Opportunity Number,Partner Name,Created Remotely,Extra Fields Unmasked',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'dedba856-4439-4423-843c-c724f8955b0a',
    'SOLUTIONS_MP_SUB_QUANTIFIABLE_INSTALLMENT_postgres_146',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.subscription_subscriptionquantifiableinstallmentitemprice',
    'id,created,modified,quantity,quantifiable_installment_item_price_id,subscription_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_SUB_QUANTIFIABLE_INSTALLMENT',
    'ID,CREATED,MODIFIED,QUANTITY,QUANTIFIABLE_INSTALLMENT_ITEM_PRICE_ID,SUBSCRIPTION_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'b1650683-a8e2-44fe-8347-57abab22a8f2',
    'SOLUTIONS_MP_VIRTUALCREDIT_ACCOUNTMANAGERCREDIT_postgres_147',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.virtualcredit_accountmanagercredit',
    'id,created,modified,amount,account_manager_id,sales_manager_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_VIRTUALCREDIT_ACCOUNTMANAGERCREDIT',
    'ID,CREATED,MODIFIED,AMOUNT,ACCOUNT_MANAGER_ID,SALES_MANAGER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'd2d5a9aa-e4a9-44d7-894c-2ae34bebc69a',
    'SOLUTIONS_MP_VIRTUALCREDIT_CUSTOMERCREDIT_postgres_148',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.virtualcredit_customercredit',
    'id,created,modified,amount,account_manager_id,customer_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_VIRTUALCREDIT_CUSTOMERCREDIT',
    'ID,CREATED,MODIFIED,AMOUNT,ACCOUNT_MANAGER_ID,CUSTOMER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '969054c2-ded5-4ffe-b8ef-960691099ab3',
    'SOLUTIONS_MP_VIRTUALCREDIT_DIRECTCUSTOMERCREDITTRANSACTION_postgres_149',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.virtualcredit_directcustomercredittransaction',
    'id,created,modified,amount,reason,customer_id,sales_manager_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_VIRTUALCREDIT_DIRECTCUSTOMERCREDITTRANSACTION',
    'ID,CREATED,MODIFIED,AMOUNT,REASON,CUSTOMER_ID,SALES_MANAGER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'e0e50315-be15-4e7e-84ac-127e2074ee45',
    'SOLUTIONS_MP_VIRTUALCREDIT_postgres_150',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.virtualcredit_virtualcredit',
    'id,created,modified,po_number,amount,attachment,added_by_id,returned_from_account_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_VIRTUALCREDIT',
    'ID,CREATED,MODIFIED,PO_NUMBER,AMOUNT,ATTACHMENT,ADDED_BY_ID,RETURNED_FROM_ACCOUNT_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '8ea6c15d-0cdf-47ae-bf6d-dfc8a0641859',
    'SOLUTIONS_MP_VOUCHER_postgres_151',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.vouchers_voucher',
    'id,created,modified,amount,code,status,duration,customer_id,user_id,expiry_date,end_date',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_VOUCHER',
    'ID,CREATED,MODIFIED,AMOUNT,CODE,STATUS,DURATION,CUSTOMER_ID,USER_ID,EXPIRY_DATE,END_DATE',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '1915c718-b438-4bb8-85c2-74c95c35a5dd',
    'SOLUTIONS_MP_VOUCHER_SERVICES_postgres_152',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.vouchers_voucher_services',
    'id,voucher_id,service_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_VOUCHER_SERVICES',
    'ID,VOUCHER_ID,SERVICE_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'a6de6593-497a-4fd6-82ea-1e17636068b3',
    'SOLUTIONS_MP_VOUCHERS_VOUCHERCREDITPOOL_postgres_153',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.vouchers_vouchercreditpool',
    'id,created,modified,po_number,attachment,amount,type,reason,user_id,voucher_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_VOUCHERS_VOUCHERCREDITPOOL',
    'ID,CREATED,MODIFIED,PO_NUMBER,ATTACHMENT,AMOUNT,VOUCHER_TYPE,REASON,USER_ID,VOUCHER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'da554949-4691-4ba3-a429-3a3f72eeb6f0',
    'SOLUTIONS_MP_VOUCHERTRANSACTION_postgres_154',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.vouchers_vouchertransaction',
    'id,created,modified,amount,customer_id,voucher_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_VOUCHERTRANSACTION',
    'ID,CREATED,MODIFIED,AMOUNT,CUSTOMER_ID,VOUCHER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '1dd09c7d-e79f-4df8-b692-b9e65d9a2cdc',
    'SOLUTIONS_A_customers_customer_event_postgres_155',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.customers_customerevent',
    'Created,"Event Type",Status,"Event Id","Service Id","Mp Account Id","Subscription Id","Customer Name","Customer Id"',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_customers_customer_event',
    'CREATED,EVENT_TYPE,STATUS,EVENT_ID,SERVICE_ID,MP_ACCOUNT_ID,SUBSCRIPTION_ID,CUSTOMER_NAME,CUSTOMER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '40308a91-bf2d-463a-bb48-da585bcc1ebc',
    'SOLUTIONS_A_KILLBILL_INVOICES_ITEMS_postgres_156',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.kill_bill_invoice_items',
    'record_id,id,type,invoice_id,account_id,bundle_id,subscription_id,description,plan_name,phase_name,usage_name,start_date,end_date,amount,rate,currency,linked_item_id,created_by,created_date,account_record_id,tenant_record_id,child_account_id,quantity,product_name,catalog_effective_date',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_KILLBILL_INVOICES_ITEMS',
    'RECORD_ID,ID,type,INVOICE_ID,ACCOUNT_ID,BUNDLE_ID,SUBSCRIPTION_ID,DESCRIPTION,PLAN_NAME,PHASE_NAME,USAGE_NAME,START_DATE,END_DATE,AMOUNT,RATE,CURRENCY,LINKED_ITEM_ID,CREATED_BY,CREATED_DATE,ACCOUNT_RECORD_ID,TENANT_RECORD_ID,CHILD_ACCOUNT_ID,QUANTITY,PRODUCT_NAME,CATALOG_EFFECTIVE_DATE',
    'dd-mm-yyyy',
    'PROCCESS_DATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '6a7f9795-6efd-48d9-946e-0d03a1c37717',
    'SOLUTIONS_A_KILLBILL_INVOICES_ITEMS_postgres_157',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.kill_bill_invoice_items',
    'RECORD_ID,
 ID,
 type,
 INVOICE_ID,
 ACCOUNT_ID,
 BUNDLE_ID,
 SUBSCRIPTION_ID,
 DESCRIPTION,
 PLAN_NAME,
 PHASE_NAME,
 USAGE_NAME,
 START_DATE,
 END_DATE,
 AMOUNT,
 RATE,
 CURRENCY,
 LINKED_ITEM_ID,
 CREATED_BY,
 CREATED_DATE,
 ACCOUNT_RECORD_ID,
 TENANT_RECORD_ID,
 CHILD_ACCOUNT_ID,
 QUANTITY,
 PRODUCT_NAME,
 CATALOG_EFFECTIVE_DATE,null EXTERNAL_KEY',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_KILLBILL_INVOICES_ITEMS',
    'RECORD_ID,ID,TYPE,INVOICE_ID,ACCOUNT_ID,BUNDLE_ID,SUBSCRIPTION_ID,DESCRIPTION,PLAN_NAME,PHASE_NAME,USAGE_NAME,START_DATE,END_DATE,AMOUNT,RATE,CURRENCY,LINKED_ITEM_ID,CREATED_BY,CREATED_DATE,ACCOUNT_RECORD_ID,TENANT_RECORD_ID,CHILD_ACCOUNT_ID,QUANTITY,PRODUCT_NAME,CATALOG_EFFECTIVE_DATE,EXTERNAL_KEY',
    'dd-Mon-yyyy',
    'PROCESS_DATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '5a685a46-7620-44fc-92d9-9a530d2364b6',
    'SOLUTIONS_A_KILLBILL_INVOICES_ITEMS_postgres_158',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.kill_bill_invoice_items',
    'record_id,id,type,invoice_id,account_id,bundle_id,subscription_id,description,plan_name,phase_name,usage_name,start_date,end_date,amount,rate,currency,linked_item_id,created_by,created_date,account_record_id,tenant_record_id,child_account_id,quantity,item_details,product_name,catalog_effective_date',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_KILLBILL_INVOICES_ITEMS',
    'RECORD_ID,ID,TYPE,INVOICE_ID,ACCOUNT_ID,BUNDLE_ID,SUBSCRIPTION_ID,DESCRIPTION,PLAN_NAME,PHASE_NAME,USAGE_NAME,START_DATE,END_DATE,AMOUNT,RATE,CURRENCY,LINKED_ITEM_ID,CREATED_BY,CREATED_DATE,ACCOUNT_RECORD_ID,TENANT_RECORD_ID,CHILD_ACCOUNT_ID,QUANTITY,PRODUCT_NAME,CATALOG_EFFECTIVE_DATE,"Sourcefile",ITEM1_TIERUNIT,ITEM1_,ITEM1_TIERPRICE,ITEM1_QUANTITY,ITEM1_AMOUNT,ITEM2_TIERUNIT,ITEM2_,ITEM2_TIERPRICE,ITEM2_QUANTITY,ITEM2_AMOUNT,ITEM3_TIERUNIT,ITEM3_,ITEM3_TIERPRICE,ITEM3_QUANTITY,ITEM3_AMOUNT,ITEM4_TIERUNIT,ITEM4_,ITEM4_TIERPRICE,ITEM4_QUANTITY,ITEM4_AMOUNT,ITEM5_TIERUNIT,ITEM5_,ITEM5_TIERPRICE,ITEM5_QUANTITY,ITEM5_AMOUNT,ITEM6_TIERUNIT,ITEM6_,ITEM6_TIERPRICE,ITEM6_QUANTITY,ITEM6_AMOUNT,ITEM7_TIERUNIT,ITEM7_,ITEM7_TIERPRICE,ITEM7_QUANTITY,ITEM7_AMOUNT,ITEM8_TIERUNIT,ITEM8_,ITEM8_TIERPRICE,ITEM8_QUANTITY,ITEM8_AMOUNT,ITEM9_TIERUNIT,ITEM9_,ITEM9_TIERPRICE,ITEM9_QUANTITY,ITEM9_AMOUNT,ITEM10_TIERUNIT,ITEM10_,ITEM10_TIERPRICE,ITEM10_QUANTITY,ITEM10_AMOUNT,ITEM11_TIERUNIT,ITEM11_,ITEM11_TIERPRICE,ITEM11_QUANTITY,ITEM11_AMOUNT,ITEM12_TIERUNIT,ITEM12_,ITEM12_TIERPRICE,ITEM12_QUANTITY,ITEM12_AMOUNT,ITEM13_TIERUNIT,ITEM13_,ITEM13_TIERPRICE,ITEM13_QUANTITY,ITEM13_AMOUNT,ITEM14_TIERUNIT,ITEM14_,ITEM14_TIERPRICE,ITEM14_QUANTITY,ITEM14_AMOUNT,ITEM15_TIERUNIT,ITEM15_,ITEM15_TIERPRICE,ITEM15_QUANTITY,ITEM15_AMOUNT,ITEM16_TIERUNIT,ITEM16_,ITEM16_TIERPRICE,ITEM16_QUANTITY,ITEM16_AMOUNT,ITEM17_TIERUNIT,ITEM17_,ITEM17_TIERPRICE,ITEM17_QUANTITY,ITEM17_AMOUNT,ITEM18_TIERUNIT,ITEM18_,ITEM18_TIERPRICE,ITEM18_QUANTITY,ITEM18_AMOUNT,ITEM19_TIERUNIT,ITEM19_,ITEM19_TIERPRICE,ITEM19_QUANTITY,ITEM19_AMOUNT',
    'dd-mm-yyyy',
    'PROCCESS_DATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    FALSE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile", "note": "exclude", "json_mapping": "tierUnit,tierUnit,tierPrice,tierPrice,quantity, quantity,amount, amount", "json_key": "item_details"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '12e8d74c-42db-46c6-a78a-470dbe7925ba',
    'SOLUTIONS_KILLBILL_ACCOUNTS_postgres_159',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.kill_bill_accounts',
    'RECORD_ID,
ID,
EXTERNAL_KEY,
EMAIL,
NAME,
FIRST_NAME_LENGTH,
CURRENCY,
BILLING_CYCLE_DAY_LOCAL,
PAYMENT_METHOD_ID,
TIME_ZONE,
LOCALE,
ADDRESS1,
ADDRESS2,
COMPANY_NAME,
CITY,
STATE_OR_PROVINCE,
COUNTRY,
POSTAL_CODE,
PHONE,
MIGRATED,
CREATED_DATE,
CREATED_BY,
UPDATED_DATE,
UPDATED_BY,
TENANT_RECORD_ID,
PARENT_ACCOUNT_ID,
IS_PAYMENT_DELEGATED_TO_PARENT,
REFERENCE_TIME',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_KILLBILL_ACCOUNTS',
    'RECORD_ID,ID,EXTERNAL_KEY,EMAIL,NAME,FIRST_NAME_LENGTH,CURRENCY,BILLING_CYCLE_DAY_LOCAL,PAYMENT_METHOD_ID,TIME_ZONE,LOCALE,ADDRESS1,ADDRESS2,COMPANY_NAME,CITY,STATE_OR_PROVINCE,COUNTRY,POSTAL_CODE,PHONE,MIGRATED,CREATED_DATE,CREATED_BY,UPDATED_DATE,UPDATED_BY,TENANT_RECORD_ID,PARENT_ACCOUNT_ID,IS_PAYMENT_DELEGATED_TO_PARENT,REFERENCE_TIME',
    'dd-mm-yyyy',
    'PROCESS_DATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'accde9a1-7eea-46a2-9f6b-4ff7468b7014',
    'SOLUTIONS_A_KILLBILL_INVOICES_postgres_160',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.kill_bill_invoices',
    'RECORD_ID,
ID,
ACCOUNT_ID,
INVOICE_DATE,
TARGET_DATE,
CURRENCY,
MIGRATED,
CREATED_BY,
CREATED_DATE,
ACCOUNT_RECORD_ID,
TENANT_RECORD_ID,
PARENT_INVOICE,
STATUS',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_KILLBILL_INVOICES',
    'RECORD_ID,ID,ACCOUNT_ID,INVOICE_DATE,TARGET_DATE,CURRENCY,MIGRATED,CREATED_BY,CREATED_DATE,ACCOUNT_RECORD_ID,TENANT_RECORD_ID,PARENT_INVOICE,STATUS',
    'dd-mm-yyyy',
    'PROCCESS_DATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '047bd19a-f403-4f40-81ac-09577e7aec61',
    'SOLUTIONS_KILLBILL_SUBSCRIPTIONS_postgres_161',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.kill_bill_subscriptions',
    'RECORD_ID,
 ID,
 BUNDLE_ID,
 CATEGORY,
 START_DATE,
 BUNDLE_START_DATE,
 CHARGED_THROUGH_DATE,
 CREATED_BY,
 CREATED_DATE,
 UPDATED_BY,
 UPDATED_DATE,
 ACCOUNT_RECORD_ID,
 TENANT_RECORD_ID,
 MIGRATED,
 EXTERNAL_KEY',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_KILLBILL_SUBSCRIPTIONS',
    'RECORD_ID,ID,BUNDLE_ID,CATEGORY,START_DATE,BUNDLE_START_DATE,CHARGED_THROUGH_DATE,CREATED_BY,CREATED_DATE,UPDATED_BY,UPDATED_DATE,ACCOUNT_RECORD_ID,TENANT_RECORD_ID,MIGRATED,EXTERNAL_KEY',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '0b0259eb-1377-43c5-abe9-7033850a898d',
    'SOLUTIONS_A_ACCOUNTS_postgres_162',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_account',
    'id,created,modified,name,customer_id_type,customer_id,customer_number,mobile_no,land_line,email,website,country,city,currency,status,status_reason,trial_status,district,building_number,street_name,postal_code,additional_number,address1,address2,region,zip_code,security_classification_level,trial_suspension_date,is_testing,site_id,super_admin_role_id,suspension_date,name_ar',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_ACCOUNTS',
    'ID,CREATED,MODIFIED,NAME,Customer ID Type,Customer ID,Customer Number,Mobile No,Land Line,EMAIL,WEBSITE,COUNTRY,CITY,CURRENCY,STATUS,Status Reason,Trial Status,DISTRICT,Building Number,Street Name,Postal Code,Additional Number,Add Res S1,Add Res S2,REGION,Zip Code,Security Classification Level,Trial Suspension Date,Is Testing,Site ID,Super Admin Role ID,Suspension Date,Name Ar',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '97ccb997-f966-4f30-be5a-afb437163203',
    'SOLUTIONS_a_deals_postgres_163',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_deal',
    'id,created,modified,min_amount,max_amount,status,expiry_date,start_date,end_date,renew,type,catalog_updated,accepted_by_id,account_manager_id,agreement_id,cloned_from_id,customer_id,price_list_id,special_offer_id,duration,po_number,version,op_number,created_by_id,"Sourcefile"',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_a_deals',
    'ID,CREATED,MODIFIED,Min Amount,Max Amount,STATUS,Expiry Date,Start Date,End Date,RENEW,Type,Catalog Updated,Accepted By ID,Account Manager ID,Agreement ID,Cloned From ID,Customer ID,Price List ID,Special Offer ID,DURATION,Po Number,VERSION,Op Number,Created By ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '565aa3d5-bf33-4a4e-a20f-8a20101bc560',
    'SOLUTIONS_A_CUSTOMERS_DEAL_CUSTOM_SERVICE_postgres_164',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.customers_dealcustomservice',
    'id,created,modified,is_auto,project_number,deal_id,service_id,duration',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_CUSTOMERS_DEAL_CUSTOM_SERVICE',
    'ID,CREATED,MODIFIED,Is Auto,Project Number,Deal ID,Service ID,DURATION',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '3e7ad1c6-7e9f-40a2-a7c1-15aee16857cc',
    'SOLUTIONS_CUSTOMERS_SERVICE_COMMITMENT_postgres_165',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.servicecommitment',
    'CATEGORY,Commitment_Amount,CREATED,Deal_ID,ID,MODIFIED,Service_ID',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_CUSTOMERS_SERVICE_COMMITMENT',
    'CATEGORY,Commitment Amount,CREATED,Deal ID,ID,MODIFIED,Service ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '8fd20534-a39b-4e4b-bccb-d15caefc47d4',
    'SOLUTIONS_PRD_CLOUDEVENT_LOG_postgres_166',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.events_event',
    'API_VERSION,
 CONTENT_TYPE_ID,
 CREATED,
 ID,
 MODIFIED,
 NEXT_RETRY_TIME,
 OBJECT_ID,
 REFERENCE,
 SERVICE_ID,
 SIGNATURE,
 STATUS,
 content_type_id,
 URL
 webhook_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_PRD_CLOUDEVENT_LOG',
    'API_VERSION,CONTENT_TYPE_ID,CREATED,ID,MODIFIED,NEXT_RETRY_TIME,OBJECT_ID,REFERENCE,SERVICE_ID,SIGNATURE,STATUS,TYPE,URL,WEB_HOOK_ID',
    'dd-Mon-yyyy',
    'PROCESS_DATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'db873269-3797-4fc6-9b1f-ca7125efdbfb',
    'SOLUTIONS_PRD_CLOUDEVENT_LOG_postgres_167',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.events_event',
    'nvl(substring(payload::text from ''"DomainName".*?"value": "([^"]*)"''), replace(replace(substring(callback_message::text from ''"landing_page_url": "([^"]*)"''), ''https://'', ''''), ''/admin'', '''')),object_id,"type",status,case when lower(payload) like ''%dns%'' then ''Cloud DNS''else ''Filevalt''end as product',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_PRD_CLOUDEVENT_LOG',
    'CALLBACK_MESSAGE_PAYLOAD_DOMAIN,PAYLOAD,TYPE,STATUS,PRODUCT',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'cfe657e0-4cb8-406e-b624-a7e68d6962ef',
    'SOLUTIONS_A_FLAVOR_postgres_168',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_flavor',
    'id,created,modified,price,"order",slug,retired,billable_unit_id,cloned_from_id,override_id,price_list_id,product_id,sub_product_category_id,uuid',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_FLAVOR',
    'ID,CREATED,MODIFIED,PRICE,Order,SLUG,RETIRED,Bill Able Unit ID,Cloned From ID,Override ID,Price List ID,Product ID,Sub Product Category ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '32780b69-c48b-4d9a-865f-376441226261',
    'SOLUTIONS_A_FLAVOR_TRANSLATION_postgres_169',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_flavor_translation',
    'id,language_code,name,description,master_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_FLAVOR_TRANSLATION',
    'ID,Language Code,NAME,DESCRIPTION,Master ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '630f3d1a-a8d6-4c3d-b28a-d52a537f2b92',
    'SOLUTIONS_STC_MP_service_management_flavoritem_postgres_170',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_flavoritem',
    'id,value,cloned_from_id,flavor_id,item_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_STC_MP_service_management_flavoritem',
    'ID,VALUE,CLONED_FROM_ID,FLAVOR_ID,ITEM_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '1dde8d0a-0d42-4477-adba-ed52644cdda5',
    'SOLUTIONS_A_SERVICE_ITEM_postgres_171',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_service_item',
    'Cloned_From_ID,CREATED,ID,Is_Feature,MODIFIED,"order",Service_ID',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_SERVICE_ITEM',
    'Cloned From ID,CREATED,ID,Is Feature,MODIFIED,Order,Service ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '87df0795-5d0f-4fba-b636-f78c8d01fdc8',
    'SOLUTIONS_A_PLAN_ITEM_TRANSLATION_postgres_172',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_item_translation',
    'ID,Language_Code,Master_ID,NAME',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PLAN_ITEM_TRANSLATION',
    'ID,Language Code,Master ID,NAME',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '8543964d-dfcb-4ea0-a1bb-4719d975b9e4',
    'SOLUTIONS_A_SERVICE_ITEM_UNIT_postgres_173',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_item_units',
    'ID,Item_ID,Unit_ID',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_SERVICE_ITEM_UNIT',
    'ID,Item ID,Unit ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'd5ca6b94-122f-4c3b-9434-fe7a36d4ad96',
    'SOLUTIONS_a_phase_postgres_174',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_service_phase',
    'id,created,modified,type,duration_unit,duration_number,billing_period,commitment,cloned_from_id,plan_price_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_a_phase',
    'ID,CREATED,MODIFIED,Type,Duration Unit,Duration Number,Billing Period,COMMITMENT,Cloned From ID,Plan Price ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '2eb65814-8eea-40ce-b5c9-5cc393988f7f',
    'SOLUTIONS_A_PHASE_PRICE_postgres_175',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_service_phaseprice',
    'id,type,currency,value,cloned_from_id,phase_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PHASE_PRICE',
    'ID,Type,CURRENCY,VALUE,Cloned From ID,Phase ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '765d5bda-e9d6-4276-a169-4b2aefb23990',
    'SOLUTIONS_A_PLAN_postgres_176',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_plan',
    'category_type,cloned_from_id,created,datacenter_id,id,maximum_allowed_subscriptions,modified,mrc_category_type,mrc_stcs_chart_of_accounts_category,"order",otc_category_type,otc_stcs_chart_of_accounts_category,retired,service_id,slug,stcs_chart_of_accounts_category,"type",mrc_sub_product_category_id,otc_sub_product_category_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PLAN',
    'Category Type,Cloned From ID,CREATED,Datacenter ID,ID,Maximum Allowed Subscriptions,MODIFIED,Mrc Category Type,Mrc St Cs Chart Of Accounts Category,Order,Otc Category Type,Otc St Cs Chart Of Accounts Category,RETIRED,Service ID,SLUG,St Cs Chart Of Accounts Category,Type,Mrc Sub Product Category ID,Otc Sub Product Category ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '71afea36-c0b6-4f7b-8822-f20565a55eba',
    'SOLUTIONS_A_PLAN_TRANSLATION_postgres_177',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_plan_translation',
    'id,language_code,"name",master_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PLAN_TRANSLATION',
    'ID,Language Code,NAME,Master ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'c69498a8-0388-430e-b2cb-7b78d65d005b',
    'SOLUTIONS_A_PLAN_TO_ITEM_MAPPING_postgres_178',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_planitem',
    'Cloned_From_ID,CREATED,ID,Item_ID,MODIFIED,Plan_ID,QUANTITY,Unit_ID',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PLAN_TO_ITEM_MAPPING',
    'Cloned From ID,CREATED,ID,Item ID,MODIFIED,Plan ID,QUANTITY,Unit ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '28e71e46-f80c-4318-86fd-4ddb2f36034f',
    'SOLUTIONS_A_PLAN_PRICE_postgres_179',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_planprice',
    'id,created,modified,slug,cloned_from_id,override_id,plan_id,price_list_id,sub_product_category_id,uuid',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PLAN_PRICE',
    'ID,CREATED,MODIFIED,SLUG,Cloned From ID,Override ID,Plan ID,Price List ID,Sub Product Category ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '8c248100-09c4-4f3d-a641-9e14ee9455b3',
    'SOLUTIONS_A_PRICE_LIST_postgres_180',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_pricelist',
    'id,slug,is_active,cloned_from_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PRICE_LIST',
    'ID,SLUG,Is Active,Cloned From ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '6019247b-e2fb-40d0-b0c5-be9305058f3e',
    'SOLUTIONS_A_PRODUCT_postgres_181',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_product',
    'id,created,modified,"order",slug,category_type,stcs_chart_of_accounts_category,cloned_from_id,datacenter_id,service_id,uuid,"Sourcefile"',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PRODUCT',
    'ID,CREATED,MODIFIED,Order,SLUG,Category Type,St Cs Chart Of Accounts Category,Cloned From ID,Datacenter ID,Service ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '8f2c73e7-25cd-478b-9534-ee14b929fd4f',
    'SOLUTIONS_A_PRODUCT_TRANS_postgres_182',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_product_translation',
    'ID,language_Code,Master_ID,NAME',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_PRODUCT_TRANS',
    'ID,Language Code,Master ID,NAME',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '7e717dbf-8d28-4b97-9f62-34c499116fe4',
    'SOLUTIONS_A_QUANTIFIABLE_ITEM_postgres_183',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_quantifiableitem',
    'Cloned_From_ID,CREATED,ID,MODIFIED,"order",Service_ID,Unit_ID',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_QUANTIFIABLE_ITEM',
    'Cloned From ID,CREATED,ID,MODIFIED,Order,Service ID,Unit ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '697ba129-1400-44d4-a34d-5985d4a95d8d',
    'SOLUTIONS_A_QUANTIFIABLE_ITEM_TRANSLATION_postgres_184',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_service_quantifiableitem_translati',
    'DESCRIPTION,ID,Language_Code,Master_ID,NAME',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_QUANTIFIABLE_ITEM_TRANSLATION',
    'DESCRIPTION,ID,Language Code,Master ID,NAME',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '35fd176f-8579-43ab-88b6-9d1ec831ca5c',
    'SOLUTIONS_A_QUANTIFIABLE_ITEM_PRICE_postgres_185',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_quantifiableitemprice',
    'Cloned_From_ID,
 CREATED,
 CURRENCY,
 Fixed_Price,
 ID,
 MAX,
 MIN,
 MODIFIED,
 Plan_Price_ID,
 PRICE,
 Quantifiable_Item_ID',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_QUANTIFIABLE_ITEM_PRICE',
    'Cloned From ID,CREATED,CURRENCY,Fixed Price,ID,MAX,MIN,MODIFIED,Plan Price ID,PRICE,Quantifiable Item ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'd0c72eb2-47fd-4369-9a87-e5f99b8d8d20',
    'SOLUTIONS_A_SERVICE_postgres_186',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_service',
    'Approval_Date,
AVAILABILITY,
Billing_Type,
Cancel_Validations_URL,
Cloned_From_ID,
CREATED,
DELETED,
Depends_On_ID,
document,
events_timeout,
events_timeout_unit,
ID,
Is_Beta,
Is_Featured,
Is_Private,
Landing_Page_URL,
LOGO,
Management_Link,
MODIFIED,
multi_datacenters,
Owner_Email,
Service_Provider_ID,
SLUG,
STATUS,
User_Management_Type,
Owner_ID,
CATEGORY,
Publish_Date,
Allow_Remote_Creation',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_SERVICE',
    'Approval Date,AVAILABILITY,Billing Type,Cancel Validations URL,Cloned From ID,CREATED,DELETED,Depends On ID,DOCUMENT,Events Time Out,Events Time Out Unit,ID,Is Beta,Is Featured,Is Private,Landing Page URL,LOGO,Management Link,MODIFIED,Multi Data Centers,Owner Email,Service Provider ID,SLUG,STATUS,User Management Type,Owner ID,CATEGORY,Publish Date,Allow Remote Creation',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '951f84e3-9cfa-49ae-b78e-632d1e157bb2',
    'SOLUTIONS_A_SERVICE_TRANSLATION_postgres_187',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.solutions_service_management_service_translation',
    'Agreement_Terms,ID,Language_Code,Master_ID,NAME,Short_Description,TITLE',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_SERVICE_TRANSLATION',
    'Agreement Terms,ID,Language Code,Master ID,NAME,Short Description,TITLE',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '708af1f8-2d4b-47b7-ba02-d7ef4680e0b2',
    'SOLUTIONS_A_SUBSCRIPTION_SUBSCRIPTION_postgres_188',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.subscription_subscription',
    'attachment,base_subscription_id,canceled_at,created,customer_id,datacenter_id,dismissed,end_date,id,installment_duration_id,instructions,items_fixed_price,items_price,landing_page_url,management_page_url,modified,name,override_fixed_price,override_price,parent_subscription_id,plan_id,plan_price_id,price_list_id,project_number,service_id,start,status,status_message,status_reason,opportunity_number,partner_name,created_remotely,null as extra_fields_unmasked',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_A_SUBSCRIPTION_SUBSCRIPTION',
    'ATTACHMENT,Base Subscription ID,Canceled At,CREATED,Customer ID,Datacenter ID,DISMISSED,End Date,ID,Installment Duration ID,INSTRUCTIONS,Items Fixed Price,Items Price,Landing Page URL,Management Page URL,MODIFIED,NAME,Override Fixed Price,Override Price,Parent Subscription ID,Plan ID,Plan Price ID,Price List ID,Project Number,Service ID,Start,STATUS,Status Message,Status Reason,Opportunity Number,Partner Name,Created Remotely,Extra Fields Unmasked',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '81d889b0-e214-4825-a028-3ab5896bd2d2',
    'SOLUTIONS_MP_SUB_QUANTIFIABLE_INSTALLMENT_postgres_189',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.subscription_subscriptionquantifiableinstallmentitemprice',
    'id,created,modified,quantity,quantifiable_installment_item_price_id,subscription_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_SUB_QUANTIFIABLE_INSTALLMENT',
    'ID,CREATED,MODIFIED,QUANTITY,QUANTIFIABLE_INSTALLMENT_ITEM_PRICE_ID,SUBSCRIPTION_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'f569785d-6ba3-4fad-80d6-45bf06afe214',
    'SOLUTIONS_MP_VIRTUALCREDIT_ACCOUNTMANAGERCREDIT_postgres_190',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.virtualcredit_accountmanagercredit',
    'id,created,modified,amount,account_manager_id,sales_manager_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_VIRTUALCREDIT_ACCOUNTMANAGERCREDIT',
    'ID,CREATED,MODIFIED,AMOUNT,ACCOUNT_MANAGER_ID,SALES_MANAGER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'bc480e47-91b0-41f6-81c0-f74012cab028',
    'SOLUTIONS_MP_VIRTUALCREDIT_CUSTOMERCREDIT_postgres_191',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.virtualcredit_customercredit',
    'id,created,modified,amount,account_manager_id,customer_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_VIRTUALCREDIT_CUSTOMERCREDIT',
    'ID,CREATED,MODIFIED,AMOUNT,ACCOUNT_MANAGER_ID,CUSTOMER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'f1caef62-0b2a-4ca3-8a9e-2fd84af16947',
    'SOLUTIONS_MP_VIRTUALCREDIT_DIRECTCUSTOMERCREDITTRANSACTION_postgres_192',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.virtualcredit_directcustomercredittransaction',
    'id,created,modified,amount,reason,customer_id,sales_manager_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_VIRTUALCREDIT_DIRECTCUSTOMERCREDITTRANSACTION',
    'ID,CREATED,MODIFIED,AMOUNT,REASON,CUSTOMER_ID,SALES_MANAGER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'b44213fd-f6f7-4501-aaa1-9f407f96e632',
    'SOLUTIONS_MP_VIRTUALCREDIT_postgres_193',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.virtualcredit_virtualcredit',
    'id,created,modified,po_number,amount,attachment,added_by_id,returned_from_account_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_VIRTUALCREDIT',
    'ID,CREATED,MODIFIED,PO_NUMBER,AMOUNT,ATTACHMENT,ADDED_BY_ID,RETURNED_FROM_ACCOUNT_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '8dfcc73d-626e-41a0-ad5d-bb0d0e29ee61',
    'SOLUTIONS_MP_VOUCHER_postgres_194',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.vouchers_voucher',
    'id,created,modified,amount,code,status,duration,customer_id,user_id,expiry_date,end_date',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_VOUCHER',
    'ID,CREATED,MODIFIED,AMOUNT,CODE,STATUS,DURATION,CUSTOMER_ID,USER_ID,EXPIRY_DATE,END_DATE',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'a81eb1e8-ad59-49fc-9aa5-bd336395db13',
    'SOLUTIONS_MP_VOUCHER_SERVICES_postgres_195',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.vouchers_voucher_services',
    'id,voucher_id,service_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_VOUCHER_SERVICES',
    'ID,VOUCHER_ID,SERVICE_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '0745b668-dd76-49e2-94e9-e625008320cd',
    'SOLUTIONS_MP_VOUCHERS_VOUCHERCREDITPOOL_postgres_196',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.vouchers_vouchercreditpool',
    'id,created,modified,po_number,attachment,amount,type,reason,user_id,voucher_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_VOUCHERS_VOUCHERCREDITPOOL',
    'ID,CREATED,MODIFIED,PO_NUMBER,ATTACHMENT,AMOUNT,VOUCHER_TYPE,REASON,USER_ID,VOUCHER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '96157fa8-f0dd-4fdb-98fa-fe517498be5f',
    'SOLUTIONS_MP_VOUCHERTRANSACTION_postgres_197',
    'postgres',
    '638ae819-becd-4ec0-bd79-358da43c35c1',
    'marketplace_solutions.vouchers_vouchertransaction',
    'id,created,modified,amount,customer_id,voucher_id',
    'Sourcefile  is not null',
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'SOLUTIONS_MP_VOUCHERTRANSACTION',
    'ID,CREATED,MODIFIED,AMOUNT,CUSTOMER_ID,VOUCHER_ID',
    'dd-Mon-yyyy',
    'PROCESSDATE',
    15,
    0,
    NULL,
    NULL,
    '/u01/RA_OPS/Test_New_Loader/Final/Cloud_Solutions',
    TRUE,
    '{"legacy_sheet": "Sheet1", "file_name_original_col": "Sourcefile"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '143b0eb9-260c-42c3-bb94-94661e47fac2',
    'PRD_OUTSOURCING_DEPENDANT_csv_198',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/ERP EMP/Dependant',
    'EMPLOYEE_NUMBER,PROJECT_EMPLOYEE_FLAG,GRADE,DATE_OF_BIRTH,RELATIONSHIP,AGE',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_OUTSOURCING_DEPENDANT',
    'EMPLOYEE_NUMBER,PROJECT_EMPLOYEE_FLAG,GRADE,DATE_OF_BIRTH,RELATIONSHIP,AGE',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    11,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/ERP_EMP/Dependant',
    FALSE,
    '{"legacy_sheet": "Skip", "file_extension_filter": "all", "note": "Skip"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '95aacdb2-6e12-446b-9618-be2b6ebc88c0',
    'PRD_OUTSOURCING_LEAVES_csv_199',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/ERP EMP/Leaves',
    'EMPLOYEE_NUMBER,ABSENCE_TYPE,DATE_START,DATE_END,ABSENCE_DAYS',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_OUTSOURCING_LEAVES',
    'EMPLOYEE_NUMBER,ABSENCE_TYPE,DATE_START,DATE_END,ABSENCE_DAYS',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    11,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/ERP_EMP/Leaves',
    FALSE,
    '{"legacy_sheet": "Skip", "file_extension_filter": "all", "note": "Skip"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '35368c54-dc9b-4177-8335-254ed3dedbd0',
    'PRD_OUTPUTS_OUTSOURCING_csv_200',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/ERP EMP/Outsourcing',
    'EMPLOYEE_NUMBER,ORIGINAL_DATE_OF_HIRE,NATIONALITY,PROJECT_EMPLOYEE_FLAG,JOB,GRADE,POSITION,COST_CENTER,LOCATION,SUPERVISOR_EMPLOYEE_NUMBER,SUPERVISOR_FULL_NAME,BASIC_SALARY,HOUSING_ALLOWANCE,TRANSPORTATION_ALLOWANCE,COST_OF_LIVING_ALLOWANCE,MOBILE_ALLOWANCE,CAR_ALLOWANCE,CAR_GASOLINE_ALLOWANCE,RESPONSIBILTY_ALLOWANCE,JOB_ALLOWANCE,AREA_ALLOWANCE,DRIVER_ALLOWANCE,INTERENT_ALLOWANCE,MERIT_INCREASE_SUM_ALLOWANCE,SECONDMENT_ALLOWANCE,COMPUTER_ALLOWANCE,TECHNICAL_ALLOWANCE,TOTAL_PACKAGE',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_OUTPUTS_OUTSOURCING',
    'EMPLOYEE_NUMBER,ORIGINAL_DATE_OF_HIRE,NATIONALITY,PROJECT_EMPLOYEE_FLAG,JOB,GRADE,POSITION,COST_CENTER,LOCATION,SUPERVISOR_EMPLOYEE_NUMBER,SUPERVISOR_FULL_NAME,BASIC_SALARY,HOUSING_ALLOWANCE,TRANSPORTATION_ALLOWANCE,COST_OF_LIVING_ALLOWANCE,MOBILE_ALLOWANCE,CAR_ALLOWANCE,CAR_GASOLINE_ALLOWANCE,RESPONSIBILTY_ALLOWANCE,JOB_ALLOWANCE,AREA_ALLOWANCE,DRIVER_ALLOWANCE,INTERENT_ALLOWANCE,MERIT_INCREASE_SUM_ALLOWANCE,SECONDMENT_ALLOWANCE,COMPUTER_ALLOWANCE,TECHNICAL_ALLOWANCE,TOTAL_PACKAGE',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    11,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/ERP_EMP/Outsourcing',
    FALSE,
    '{"legacy_sheet": "Skip", "file_extension_filter": "all", "note": "Skip"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'f0a05a0d-972a-4f26-806b-98a15428b4e7',
    'PRD_OUTSOURCING_PAYROLL_RUN_csv_201',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/ERP EMP/Payroll',
    'EMPLOYEE_NUMBER,PERIOD_NAME,CLASSIFICATION_NAME,ELEMENT_NAME,PAYMENT',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_OUTSOURCING_PAYROLL_RUN',
    'EMPLOYEE_NUMBER,PERIOD_NAME,CLASSIFICATION_NAME,ELEMENT_NAME,PAYMENT',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    11,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/ERP_EMP/Payroll',
    FALSE,
    '{"legacy_sheet": "Skip", "file_extension_filter": "all", "note": "Skip"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'b7c1b06e-5be1-419e-9088-d5e5fab7dbe8',
    'prd_erp_csv_202',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/STCS Customer Revenue Assurance Report',
    'Project Order Id,Type Of Invoice,Project Order Number,Blanket Order Number,Agreement Expiry Date,ORDER_Line Number,Unit Selling Price,Expiry,Activation_Date,Description Customer Name,Class Code Dia,Draft Invoice Number,Transfer Status Code,Pa Date,Bill Through Date,Start Date,End Date,Invoice Date,Ra Invoice Number,Gl Date,Amount,Text,INVOICE_LINE_NUMBER,Event Number,Task Number,Resource Name,Circuit Number Service name,Ckt_Bill Number Fict,Customer Account Number,Billing Cycle,Status,Accounting Status,Complete Flag,Inventory Item Id,L1,L1 Desc,L2,L2 Desc,L3,L3 Desc,L5,L5 Desc,Channel,REFERENCE_ORDER,REFERENCE_ORDER_LINE,OLD_ERP_ORDER_NUMBER,OLD_ERP_ORDER_LINE,OLD_ERP_LINE_ID,MIGRATION_PURPOSE_ONLY,DYN_OFF_SHLF_RQST,DYNMCS_ORDER_TYPE,RETURN_ORDER_FROM,RETURN_ORDER_TO,RETURN_ORDER_DETAIL,EBU_CO_ID',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'prd_erp',
    'PROJECT_ORDER_ID,TYPE_OF_INVOICE,PROJECT_ORDER_NUMBER,BLANKET_ORDER_NUMBER,AGGREMENT_EXPIRY_DATE,ORDER_LINE_NUMBER,UNIT_SELLING_PRICE,EXPIRY,ACTIVATION_DATE,DESCRIPTION_CUSTOMER_NAME,CLASS_CODE_DIA,DRAFT_INVOICE_NUMBER,TRANSFER_STATUS_CODE,PA_DATE,BILL_THROUGH_DATE,START_DATE,END_DATE,INVOICE_DATE,RA_INVOICE_NUMBER,GL_DATE,AMOUNT,TEXT,INVOICE_LINE_NUMBER,EVENT_NUMBER,TASK_NUMBER,RESOURCE_NAME,CIRCUIT_NUMBER_SERVICENAME,CKT_BILL_NUMBER_FICT,CUSTOMER_ACCOUNT_NUMBER,BILLING_CYCLE,STATUS,ACCOUNTING_STATUS,COMPLETE_FLAG,INVENTORY_ITEM_ID,L1,L1_DESC,L2,L2_DESC,L3,L3_DESC,L5,L5_DESC,CHANNEL,REFERENCE_ORDER,REFERENCE_ORDER_LINE,OLD_ERP_ORDER_NUMBER,OLD_ERP_ORDER_LINE,OLD_ERP_LINE_ID,MIGRATION_PURPOSE_ONLY,DYN_OFF_SHLF_RQST,DYNMCS_ORDER_TYPE,RETURN_ORDER_FROM,RETURN_ORDER_TO,RETURN_ORDER_DETAIL,EBU_CO_ID',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    30,
    1,
    NULL,
    '02',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_Customer_Revenue_Assurance_Report',
    FALSE,
    '{"legacy_sheet": "Skip", "file_extension_filter": "02", "note": "Skip"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '517d047b-d18a-486f-b2ae-109822ab0312',
    'PRD_STCS_AR_INVOICE_WITH_ORIGINAL_AMOUNT_REPORT_csv_203',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/STCS AR Invoice with original amount report',
    'Account Number,Invoice Line Nature,Customer Name,Orignal Amount,Local Currency Amount,Currency,Trx Number,Trx Date,GL Date,CRT Registration Number,Sector,Customer Group,Legal - Yes/No,Sales Class,Business Unit,Customer Segment,Industry Type Segment,Industry,Customer Leagal,Sales Division,Region,Customer Class Code,Collector,L1,L1 Desc,L2,L2 Desc,L3,L3 Desc,Interface Line Context,Project Number / SO,Project Organization,Project Service Type,Interface Line Attribute9,Product,Service Type,Project/Task Description,Ordline Service,Last Invoice Date,FICT Billing No,Charge From Date,Activation Date,Termination,Delivery By,Reference SO,Reference Line,OL Attribute10,OL Attribute11,OL Attribute12,OL Attribute13,CRM Duration,CRM Agreement Line Status,Service Type,RCTLA Order Number / Project Number,Sales Order Line Number,RCTLA Order Type / Project Draft Invoice,RCTLA Delivery / Project Agreement,RCTLA Bill From / Project Type,RCTLA Bill To / Project Number,Inv. SO_Line Id/Project Line Number,Billing Cycle / ProjectLine Type,Partila Yes No,Prod Cat,Circuit,Channel,Customer Seg,Discount,Industry Type Seg,Work Order,Job Order,Customer PO,Status,Tax Rate Code,Tax Rate %,Tax Amount,Tax Amount in SAR,Line Amount inculding VAT,Compelete Flag,Order Number,Order Line Number,Order Key,OM Fulfillment Code,PARENT_ORDER,PARENT_ORDER_LINE,OLD_ERP_ORDER_NUMBER,OLD_ERP_ORDER_LINE,OLD_ERP_LINE_ID,MIGRATION_PURPOSE_ONLY,Order Line ID,RQST_TYPE,DYNMCS_ORDER_TYPE,UNIT_SELLING_PRICE',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_STCS_AR_INVOICE_WITH_ORIGINAL_AMOUNT_REPORT',
    'ACCOUNT_NUMBER,INVOICE_LINE_NATURE,CUSTOMER_NAME,ORIGNAL_AMOUNT,LOCAL_CURRENCY_AMOUNT,CURRENCY,TRX_NUMBER,TRX_DATE,GL_DATE,CRT_REGISTRATION_NUMBER,SECTOR,CUSTOMER_GROUP,LEGAL_YES_NO,SALES_CLASS,BUSINESS_UNIT,CUSTOMER_SEGMENT,INDUSTRY_TYPE_SEGMENT,INDUSTRY,CUSTOMER_LEAGAL,SALES_DIVISION,REGION,CUSTOMER_CLASS_CODE,COLLECTOR,L1,L1_DESC,L2,L2_DESC,L3,L3_DESC,INTERFACE_LINE_CONTEXT,PROJECT_NUMBER_SO,PROJECT_ORGANIZATION,PROJECT_SERVICE_TYPE,INTERFACE_LINE_ATTRIBUTE9,PRODUCT,SERVICE_TYPE,PROJECTTASK_DESCRIPTION,ORDLINE_SERVICE,LAST_INVOICE_DATE,FICT_BILLING_NO,CHARGE_FROM_DATE,ACTIVATION_DATE,TERMINATION,DELIVERY_BY,REFERENCE_SO,REFERENCE_LINE,OL_ATTRIBUTE10,OL_ATTRIBUTE11,OL_ATTRIBUTE12,OL_ATTRIBUTE13,CRM_DURATION,CRM_AGREEMENT_LINE_STATUS,SERVICE_TYPE_1,RCTLA_ORDER_NUMBER_PROJECT_NUMBER,SALES_ORDER_LINE_NUMBER,RCTLA_ORDER_TYPE_PROJECT_DRAFT_INVOICE,RCTLA_DELIVERY_PROJECT_AGREEMENT,RCTLA_BILL_FROM_PROJECT_TYPE,RCTLA_BILL_TO_PROJECT_NUMBER,INV_SO_LINE_IDPROJECT_LINE_NUMBER,BILLING_CYCLE_PROJECTLINE_TYPE,PARTILA_YES_NO,PROD_CAT,CIRCUIT,CHANNEL,CUSTOMER_SEG,DISCOUNT,INDUSTRY_TYPE_SEG,WORK_ORDER,JOB_ORDER,CUSTOMER_PO,STATUS,TAX_RATE_CODE,TAX_RATE,TAX_AMOUNT,TAX_AMOUNT_IN_SAR,LINE_AMOUNT_INCULDING_VAT,COMPELETE_FLAG,ORDER_NUMBER,ORDER_LINE_NUMBER,ORDER_KEY,OM_FULFILLMENT_CODE,PARENT_ORDER,PARENT_ORDER_LINE,OLD_ERP_ORDER_NUMBER,OLD_ERP_ORDER_LINE,OLD_ERP_LINE_ID,MIGRATION_PURPOSE_ONLY,ORDER_LINE_ID,RQST_TYPE,DYNMCS_ORDER_TYPE,UNIT_SELLING_PRICE',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    11,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_AR_Invoice_with_original_amount_report',
    FALSE,
    '{"legacy_sheet": "Skip", "file_extension_filter": "all", "note": "Skip"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '3c177767-45f8-4e07-bdbe-730779659568',
    'PRD_STCS_ON_HAND_QTY_PROJECT_csv_204',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/STCS On-Hand Quantity Report',
    'Item Code,Inventory Item ID,Organization Id,Organization Name,Allocated Quantity,Reserved Quantity,Supplier Item Code,Commodity,Description,On-Hand Quantity,Allocated Quantity,Item Cost,Sub-Inventory Code,Locator Project Number ,Locator Task Number,Locator PO Number,PO Unit Price,Material Cost (Based on PO Price),Project Manager / Requestor,Locator Location,Locator Segment5,Total Cost',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_STCS_ON_HAND_QTY_PROJECT',
    'ITEM_CODE,INVENTORY_ITEM_ID,ORGANIZATION_ID,ORGANIZATION_NAME,ALLOCATED_QUANTITY,RESERVED_QUANTITY,SUPPLIER_ITEM_CODE,COMMODITY,DESCRIPTION,ON_HAND_QUANTITY,ALLOCATED_QUANTITY_1,ITEM_COST,SUB_INVENTORY_CODE,LOCATOR_PROJECT_NUMBER,LOCATOR_TASK_NUMBER,LOCATOR_PO_NUMBER,PO_UNIT_PRICE,MATERIAL_COST_BASE_ON_PO_PRICE,PROJECT_MANAGER_REQUESTOR,LOCATOR_LOCATION,LOCATOR_SEGMENT5,TOTAL_COST',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    11,
    4,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_On-Hand_Quantity_Report',
    FALSE,
    '{"legacy_sheet": "Skip", "file_extension_filter": "all", "note": "Skip"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '1c54caad-824a-4264-8aba-022ec73bede6',
    'PRD_STCS_AR_TOTAL_INVOICE_REPORT_csv_205',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/STCS AR Total Invoice Report',
    'Trx Number,Trx Date,Gl Date,Due Date,Region ,Account Number,Customer Name,Customer Class Code,Customer Group,Business_Unit,Sales_Class,PO Number,Project Number,Return Order Justification,Project/Order Organization ,Service Type ,Balance Due,Amount Due Original,Sales Sector,Creation Date,User Name,Currency,Interface Header Context,Ct Reference,Invoice Currency Total,Total lines local Currency,Local Currency Total,Tax_code_Detail,Invoice Print?,Status,Tax Amount,Total Orginal Amount with VAT,Credit Limit,Collected Amount,Created By,Related Invoice,Billing Period',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_STCS_AR_TOTAL_INVOICE_REPORT',
    'TRX_NUMBER,TRX_DATE,GL_DATE,DUE_DATE,REGION,ACCOUNT_NUMBER,CUSTOMER_NAME,CUSTOMER_CLASS_CODE,CUSTOMER_GROUP,BUSINESS_UNIT,SALES_CLASS,PO_NUMBER,PROJECT_NUMBER,RETURN_ORDER_JUSTIFICATION,PROJECTORDER_ORGANIZATION,SERVICE_TYPE,BALANCE_DUE,AMOUNT_DUE_ORIGINAL,SALES_SECTOR,CREATION_DATE,USER_NAME,CURRENCY,INTERFACE_HEADER_CONTEXT,CT_REFERENCE,INVOICE_CURRENCY_TOTAL,TOTAL_LINES_LOCAL_CURRENCY,LOCAL_CURRENCY_TOTAL,TAX_CODE_DETAIL,INVOICE_PRINT,STATUS,TAX_AMOUNT,TOTAL_ORGINAL_AMOUNT_WITH_VAT,CREDIT_LIMIT,COLLECTED_AMOUNT,CREATED_BY,RELATED_INVOICE,BILLING_PERIOD',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    11,
    6,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_AR_Total_Invoice_Report',
    FALSE,
    '{"legacy_sheet": "Skip", "file_extension_filter": "all", "note": "Skip"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '4b1f7045-5ca3-4cf0-934b-ecc562f29055',
    'PRD_PROJECT_INVENTORY_REPORT_csv_206',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/STCS Project Inventory Report',
    'Sup Name,Sup Num,Project Number,Project Name,Task Number,Expenditure Item Date,Expenditure Type,Task Name,Acct Burdened Cost,Acct Currency Code,Po Number,Move Order Header Po,Receipt Num,Receipt Date,Requisition,Item,Supplier Item Code,Description,Quantity,Unit Price,Amount,Ap Invice Number,Rfd Number,Rfd Date,Debit Account,Gl Period Name,Subinventory,Locator',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_PROJECT_INVENTORY_REPORT',
    'SUP_NAME,SUP_NUM,PROJECT_NUMBER,PROJECT_NAME,TASK_NUMBER,EXPENDITURE_ITEM_DATE,EXPENDITURE_TYPE,TASK_NAME,ACCT_BURDENED_COST,ACCT_CURRENCY_CODE,PO_NUMBER,MOVE_ORDER_HEADER_PO,RECEIPT_NUM,RECEIPT_DATE,REQUISITION,ITEM,SUPPLIER_ITEM_CODE,DESCRIPTION,QUANTITY,UNIT_PRICE,AMOUNT,AP_INVICE_NUMBER,RFD_NUMBER,RFD_DATE,DEBIT_ACCOUNT,GL_PERIOD_NAME,SUBINVENTORY,LOCATOR',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    11,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_Project_Inventory_Report',
    FALSE,
    '{"legacy_sheet": "Skip", "file_extension_filter": "all", "note": "Skip"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '0192cfaa-2e31-46c5-930d-315c409add72',
    'PRD_PO_DISTRIBUTION_csv_207',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/STCS PO_distribution',
    'PO_NUMBER,PO_STATUS,PO_CREATION_DATE,US_ORG_NAME_DESTINATION,DISTRIBUTION_TYPE,PO_LINE_NUMBER,RELEASE_NUM,HEADER_ATTRIBUTE,DIM_ORG_NAME_SHIP_TO,FULL_NAME_DELIVER_TO,SECTION_ORGANIZATION_NAME,DEPT_ORGANIZATION_NAME,SECTR_ORGANIZATION_NAME,DIV_ORGANIZATION_NAME,PO_CHARGE_ACCOUNT,PROJECT_NUMBER,PROJECT_NAME,STCS_CHANNEL_SEGMENT,STCS_PROJECT_BILLING_METHOD,STCS_SERVICE_TYPE,ERP_SALES_CLASS,ERP_CUSTOMER_SEGMENT,CUSTOMER_CLASS_CODE,PORTFOLIO,ERP_CUSTOMER_NAME,PROJECT_MANAGER,TASK_NUMBER,EXPENDITURE_TYPE,CLOSER_CODE,PO_DISTRIBUTION_KEY,PR_NUMBER,LINE_TYPE,VENDOR_NAME,VENDOR_NUMBER,VENDOR_CATEGORY,COUNTRY,ITEM_CODE,PO_LINES_VENDOR_PRODUCT_NUM,PO_DESCRIPTION,ITEM_DESC,UOM,HEADERS_CURRENCY_CODE,RATE,LINES_UNIT_PRICE,QUANTITY_ORDERED,QUANTITY_DELIVERED,QUANTITY_BILLED,QUANTITY_CANCELLED,QUANTITY_OPEN_FOR_GRN,AMOUNT_BILLED,AMOUNT_ORDERED,AMOUNT_DELIVERED,AMOUNT_CANCELLED,AMOUNT_OPEN_FOR_GRN,AMOUNT_BILLED_SAR,AMOUNT_ORDERED_SAR,AMOUNT_DELIVERED_SAR,AMOUNT_CANCELLED_SAR,AMOUNT_OPEN_FOR_GRN_SAR',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_PO_DISTRIBUTION',
    'PO_NUMBER,PO_STATUS,PO_CREATION_DATE,US_ORG_NAME_DESTINATION,DISTRIBUTION_TYPE,PO_LINE_NUMBER,RELEASE_NUM,HEADER_ATTRIBUTE,DIM_ORG_NAME_SHIP_TO,FULL_NAME_DELIVER_TO,SECTION_ORGANIZATION_NAME,DEPT_ORGANIZATION_NAME,SECTR_ORGANIZATION_NAME,DIV_ORGANIZATION_NAME,PO_CHARGE_ACCOUNT,PROJECT_NUMBER,PROJECT_NAME,STCS_CHANNEL_SEGMENT,STCS_PROJECT_BILLING_METHOD,STCS_SERVICE_TYPE,ERP_SALES_CLASS,ERP_CUSTOMER_SEGMENT,CUSTOMER_CLASS_CODE,PORTFOLIO,ERP_CUSTOMER_NAME,PROJECT_MANAGER,TASK_NUMBER,EXPENDITURE_TYPE,CLOSER_CODE,PO_DISTRIBUTION_KEY,PR_NUMBER,LINE_TYPE,VENDOR_NAME,VENDOR_NUMBER,VENDOR_CATEGORY,COUNTRY,ITEM_CODE,PO_LINES_VENDOR_PRODUCT_NUM,PO_DESCRIPTION,ITEM_DESC,UOM,HEADERS_CURRENCY_CODE,RATE,LINES_UNIT_PRICE,QUANTITY_ORDERED,QUANTITY_DELIVERED,QUANTITY_BILLED,QUANTITY_CANCELLED,QUANTITY_OPEN_FOR_GRN,AMOUNT_BILLED,AMOUNT_ORDERED,AMOUNT_DELIVERED,AMOUNT_CANCELLED,AMOUNT_OPEN_FOR_GRN,AMOUNT_BILLED_SAR,AMOUNT_ORDERED_SAR,AMOUNT_DELIVERED_SAR,AMOUNT_CANCELLED_SAR,AMOUNT_OPEN_FOR_GRN_SAR',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    11,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_PO_distribution',
    FALSE,
    '{"legacy_sheet": "Skip", "file_extension_filter": "all", "note": "Skip"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'bb70f1ab-03f8-4f28-ac40-1a0c0493360b',
    'PRD_STCS_GRN_PROJECT_REPORT_csv_208',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/STCS GRN Report',
    'Sr.no,Organization Code,Org Name,GRN NO,GRN Date,GRN Creation Date,Receiver,PO Number,PO Type,Supplier Name,Supplier Site,Country,PO Currency,PO Line No,PO release NO,STCS Item code,STCS Item Desc,Supplier Item Code,GRN quantity,UOM,PO Unit price in SAR,Total Price in SAR,Destination Type,Charge Account,Subinventory,MAWB Number,Locator,Return To Supplier,Return Quantity,Project ,Project Desc,Project ORG',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_STCS_GRN_PROJECT_REPORT',
    'SR_NO,ORGANIZATION_CODE,ORG_NAME,GRN_NO,GRN_DATE,GRN_CREATION_DATE,RECEIVER,PO_NUMBER,PO_TYPE,SUPPLIER_NAME,SUPPLIER_SITE,COUNTRY,PO_CURRENCY,PO_LINE_NO,PO_RELEASE_NO,STCS_ITEM_CODE,STCS_ITEM_DESC,SUPPLIER_ITEM_CODE,GRN_QUANTITY,UOM,PO_UNIT_PRICE_IN_SAR,TOTAL_PRICE_IN_SAR,DESTINATION_TYPE,CHARGE_ACCOUNT,SUBINVENTORY,MAWB_NUMBER,LOCATOR,RETURN_TO_SUPPLIER,RETURN_QUANTITY,PROJECT,PROJECT_DESC,PROJECT_ORG',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    11,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_GRN_Report',
    FALSE,
    '{"legacy_sheet": "Skip", "file_extension_filter": "all", "note": "Skip"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '6afe7be6-c571-4cf6-95a2-c9d04ca9164a',
    'PRD_STCS_PR_PROJECT_REPORT_csv_209',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/STCS PR Project Report',
    'PR number,PR Line Num,PR Status,PR Amount,PR Creation Date,PR Creator Name,PR Requester Name,Project Number ,Task Number',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_STCS_PR_PROJECT_REPORT',
    'PR_NUMBER,PR_LINENUM,PR_STATUS,PR_AMOUNT,PR_CREATIONDATE,PR_CREATORNAME,PR_REQUESTERNAME,PROJECT_NUMBER,TASK_NUMBER',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    11,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_PR_Project_Report',
    FALSE,
    '{"legacy_sheet": "Skip", "file_extension_filter": "all", "note": "Skip"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '95c83abd-0d15-45b4-801e-1a2c1cbeb692',
    'PRD_STCSPO_OUTSTAN_PROJECT_RET_csv_210',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/STCS PO Outstanding Report',
    'Requestor Department,VP BU,Supplier name,Supplier Number,PR #,PR Creation Date,PR First Approval Date,PR Approval Date,Finance First Approval Date for PR,Procurement First Approval Date for PR,Requestor,PO Number,Incoterms Code,Incoterms/Freight Terms,PO Approve Date,PO Expiry Date,PO Acknowledgement Date,First PO Approve Date,Advance Payment,Term name,Term End Date,Project Number,Project Manager,Project Manager Department,PO Closure Status,PO Amount,PR Amount,Manual PO''s,No. of Quotations,Department No.,Buyer Name,Sourcing Type,Currency,Supplier Site,Supplier Site Country,Ordered Amount in SAR,Received Amount in SAR,Pending Amount in SAR ( Not yet Received GRN),Invoiced Amount,WHT Code,Agreement Number,Creation Date,No of Days between PR Approved and PO First Approved,PO Type,PO Approval Status,PO Cancel Flag,Type (Standard/Blanket),Bid Reference Number,Related Party Transaction',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'PRD_STCSPO_OUTSTAN_PROJECT_RET',
    'REQUESTOR_DEPARTMENT,VP_BU,SUPPLIER_NAME,SUPPLIER_NUMBER,PR,PR_CREATION_DATE,PR_FIRST_APPROVAL_DATE,PR_APPROVAL_DATE,FINANCE_FIRST_APPR_DATE_FOR_PR,PROCUR_FIRST_APPR_DATE_FOR_PR,REQUESTOR,PO_NUMBER,INCOTERMS_CODE,INCOTERMS_FREIGHT_TERMS,PO_APPROVE_DATE,PO_EXPIRY_DATE,PO_ACKNOWLEDGEMENT_DATE,FIRST_PO_APPROVE_DATE,ADVANCE_PAYMENT,TERM_NAME,TERM_END_DATE,PROJECT_NUMBER,PROJECT_MANAGER,PROJECT_MANAGER_DEPARTMENT,PO_CLOSURE_STATUS,PO_AMOUNT,PR_AMOUNT,MANUAL_POS,NO_OF_QUOTATIONS,DEPARTMENT_NO,BUYER_NAME,SOURCING_TYPE,CURRENCY,SUPPLIER_SITE,SUPPLIER_SITE_COUNTRY,ORDERED_AMOUNT_IN_SAR,RECEIVED_AMOUNT_IN_SAR,PENDING_AMOUNT_IN_SAR,INVOICED_AMOUNT,WHT_CODE,AGREEMENT_NUMBER,CREATION_DATE,DAYS_BW_PR_AND_PO_FIRST_APPROV,PO_TYPE,PO_APPROVAL_STATUS,PO_CANCEL_FLAG,TYPE_STANDARD_BLANKET,BID_REFERENCE_NUMBER,RELATED_PARTY_TRANSACTION',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    11,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_PO_Outstanding_Report',
    FALSE,
    '{"legacy_sheet": "Skip", "file_extension_filter": "all", "note": "Skip"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'cf8dfff8-902f-4138-ac7c-cccd4677767c',
    'STCS_PROJECTS_HEADER_ALL_REPORT_csv_211',
    'csv',
    NULL,
    '/home/sdev/ROOT/ERP/STCS Projects Header all Report',
    'Project Number,Name,Description,Project Organization,Business Unit,Service Type,Channel Segment,AGILEPROJECT,Account Number,Region,Customer Name,Status,Start Date,Finish Date,Closed ,Bid Reference,Po Number,Po Issuance Date,Fc Project Type,Po Start Date,Po Expiration Date,Contract Number,Parent Project,Project Manager,Engagement Manager,Pm Email Address,Account Manager,Creation Date,RLA Baselined Date,Po Baselined Date,Po Value,RLA Value,Planned Cost,Profit Margin,Invoiced Amount,EBU_Customer_Segment,Customer Segments,Last Invoice Date,Last Revenue Date,End Customer PO date to STC,PO Issuance Date,Incurred Cost,Total Billing,Billing Allocation,Original Base Line Date,Margin Per',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'STCS_PROJECTS_HEADER_ALL_REPORT',
    'PROJECT_NUMBER,NAME,DESCRIPTION,PROJECT_ORGANIZATION,BUSINESS_UNIT,SERVICE_TYPE,CHANNEL_SEGMENT,AGILEPROJECT,ACCOUNT_NUMBER,REGION,CUSTOMER_NAME,STATUS,START_DATE,FINISH_DATE,CLOSED,BID_REFERENCE,PO_NUMBER,PO_ISSUANCE_DATE,FC_PROJECT_TYPE,PO_START_DATE,PO_EXPIRATION_DATE,CONTRACT_NUMBER,PARENT_PROJECT,PROJECT_MANAGER,ENGAGEMENT_MANAGER,PM_EMAIL_ADDRESS,ACCOUNT_MANAGER,CREATION_DATE,RLA_BASELINED_DATE,PO_BASELINED_DATE,PO_VALUE,RLA_VALUE,PLANNED_COST,PROFIT_MARGIN,INVOICED_AMOUNT,EBU_CUSTOMER_SEGMENT,CUSTOMER_SEGMENTS,LAST_INVOICE_DATE,LAST_REVENUE_DATE,END_CUSTOMER_PO_DATE_TO_STC,PO_ISSUANCE_DATE_1,INCURRED_COST,TOTAL_BILLING,BILLING_ALLOCATION,ORIGINAL_BASE_LINE_DATE,MARGIN_PER',
    'yyyy-mm-dd',
    'PROCESS_DATE',
    11,
    0,
    NULL,
    'all',
    '/u01/RA_OPS/Test_New_Loader/Final/ERP/STCS_Projects_Header_all_Report',
    FALSE,
    '{"legacy_sheet": "Skip", "file_extension_filter": "all", "note": "Skip"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'cb796eb5-33df-4f93-832e-7b0272cc3815',
    'None_csv_212',
    'csv',
    NULL,
    'stc_cdr',
    'None',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'None',
    'None',
    NULL,
    NULL,
    NULL,
    0,
    NULL,
    NULL,
    NULL,
    FALSE,
    '{"legacy_sheet": "Skip", "note": "New"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '66a6b5e4-0b3b-4e78-9ffc-b4892b382486',
    'None_csv_213',
    'csv',
    NULL,
    'stc_cdr_invoices',
    'None',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'None',
    'None',
    NULL,
    NULL,
    NULL,
    0,
    NULL,
    NULL,
    NULL,
    FALSE,
    '{"legacy_sheet": "Skip", "note": "New"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '2edc1981-9491-4908-8b45-0218abd601c0',
    'None_csv_214',
    'csv',
    NULL,
    'stc_marketplace_customers_customerevent',
    'None',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'None',
    'None',
    NULL,
    NULL,
    NULL,
    0,
    NULL,
    NULL,
    NULL,
    FALSE,
    '{"legacy_sheet": "Skip", "note": "New"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    '730d55f9-a3e1-4220-8be1-ebf83b0412fc',
    'None_csv_215',
    'csv',
    NULL,
    'stc_marketplace_subscription_subscriptionuser',
    'None',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'None',
    'None',
    NULL,
    NULL,
    NULL,
    0,
    NULL,
    NULL,
    NULL,
    FALSE,
    '{"legacy_sheet": "Skip", "note": "New"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'def62607-8544-4940-b17d-34a708228495',
    'None_csv_216',
    'csv',
    NULL,
    'vdc_customer_info',
    'None',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'None',
    'None',
    NULL,
    NULL,
    NULL,
    0,
    NULL,
    NULL,
    NULL,
    FALSE,
    '{"legacy_sheet": "Skip", "note": "New"}'
);
INSERT INTO ra_meta.table_config (
    id, name, source_type, source_connection_id, source_table_name, source_columns,
    where_condition, destination_connection_id, destination_table_name, destination_columns,
    date_format, date_column, schedule_day, skip_rows,
    file_name_pattern, file_extension_filter, backup_folder, is_enabled, config_json
) VALUES (
    'c2832e09-7fec-407e-ab7a-f1b0ef77aa59',
    'None_csv_217',
    'csv',
    NULL,
    'ombilling_resources',
    'None',
    NULL,
    '6b6159b6-1269-4396-9858-0bf0f5c5c04b',
    'None',
    'None',
    NULL,
    NULL,
    NULL,
    0,
    NULL,
    NULL,
    NULL,
    FALSE,
    '{"legacy_sheet": "Skip", "note": "New"}'
);


-- ============================================================
-- MV REFRESH SEQUENCE (Migrated from sequence_updated3.xlsx)
-- 485 materialized views in dependency-sorted refresh order
-- This is the static fallback sequence. The platform dynamically
-- computes dependency order via the Dependency Engine service,
-- but this seed data preserves the proven legacy sequence.
-- ============================================================

CREATE TABLE IF NOT EXISTS ra_meta.mv_refresh_sequence (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mv_name         VARCHAR(255) NOT NULL,
    refresh_order   INTEGER NOT NULL,
    refresh_type    VARCHAR(20) DEFAULT 'COMPLETE',
    timeout_seconds INTEGER DEFAULT 3600,
    is_enabled      BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_mv_refresh_seq_order ON ra_meta.mv_refresh_sequence (refresh_order);
CREATE INDEX IF NOT EXISTS idx_mv_refresh_seq_name ON ra_meta.mv_refresh_sequence (mv_name);

INSERT INTO ra_meta.mv_refresh_sequence (id, mv_name, refresh_order, refresh_type, timeout_seconds, is_enabled, created_at)
VALUES
    (gen_random_uuid(), 'PRD_ERP_CLEANUP1_MV', 1, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_STC_GLS_RBM_NEW_MV_OLD', 2, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_STC_GLS_RBM_NEW_MV', 3, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_MP_PRICE_LIST_pre1_MV', 4, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_CLEANUP_MV', 5, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_STCGLVSDETAILS_MV', 6, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_MP_PRICE_LIST_PRE3_MV', 7, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_MP_PRICE_LIST_PRE_MV', 8, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_ERP_CN_MV', 9, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_CLEANUP', 10, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_MP_PRICE_LIST_MV', 11, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_CLEANUP2_MV', 12, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_STC_GLS_RBM_NEW_MV2', 13, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STC_GL_RBM_D_MV', 14, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_MP_SUB_MV1', 15, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_RANK', 16, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_RANK', 17, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_MP_SUBS_MV2', 18, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_DIA_MV', 19, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_DIA_MV', 20, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_MRS_AGGREGATE', 21, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNAMICS_MERGE_MV', 22, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STC_GL_RBM_MV_AGGREGATED', 23, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNAMIC_MERGE_OTHERPRODUCT', 24, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'ACTIVEMRS_MV', 25, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ACTIVEVSAT_MV1', 26, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_MP_SUBS_MV_FINAL', 27, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'A_USAGE_REPORT_DETAIL_MV', 28, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'A_USAGE_REPORT_NEW_MV', 29, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ACTIVEDIA_MV1', 30, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_RANK_OP2', 31, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ACTIVEMRS_MV', 32, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'MP_PRICE_LIST_BASE_MV', 33, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_VSAT_MV', 34, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_INVOICES_R_STCS_STC_VS_GL_V1', 35, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_PRICSUB_MV1', 36, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNAMICS_RANK_ERP', 37, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_GL_CLEANUP_MV', 38, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STC_GL_RBM_MV_AGGREGATED_1MV', 39, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_INVOICE_SUB_MV', 40, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_MP_INVOICES_MV', 41, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'MV_PAY_BY_PLATE_PREP', 42, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'MV_TICKETS_KIOSK_PREP', 43, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CR_DR_RBM_STC_GL_SUM', 44, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNAMICS_MERGE_MRS_MV', 45, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNAMICS_RANK_AGW', 46, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ACTIVEVSAT_MV', 47, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_VSAT_MV', 48, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_GL_DIA_CLEANUPMV', 49, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'VDC_USAGE_REPORT_MV', 50, 'COMPLETE', 3600, TRUE, NOW());
INSERT INTO ra_meta.mv_refresh_sequence (id, mv_name, refresh_order, refresh_type, timeout_seconds, is_enabled, created_at)
VALUES
    (gen_random_uuid(), 'PRD_ACTIVEDIA_MV', 51, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERPVSGRANITEDIA_RECON12', 52, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_ERPVSGL_NEW', 53, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_MS_RANK', 54, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJECT_BILL_MASTER_PRICE', 55, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ACTIVEMRS_VS_GRANITEOP2', 56, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_MP_INVOICES_VI_CDR_MV', 57, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STC_MP_SUBS_MV', 58, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_VSAT_PRICEMAT_CLEANUP_MV', 59, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'A_STC_CDR_INVOICES_RNK_MV', 60, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_INVOICES_R_STCS_STC_VS_GL', 61, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNAMICS_RANK_GRANITE', 62, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_SUB_VIEW_MV', 63, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_MP_SUBS_MV', 64, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DIA_PRICEMAT_CLEANUP_MV', 65, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_GL_VSAT_CLEANUPMV', 66, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GL_CLOUDDATA_TREND', 67, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CDR_CLOUDDATA_TREND', 68, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_STC_GLVSERP_DIA_MV', 69, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_ERP_RA_REPORT_MV', 70, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STC_GR_LAST', 71, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_EPM_PLAND_ACT_BASE_REV_MV', 72, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STC_GL_RBM_R_1MV', 73, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_FLEET_MV1', 74, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_FLEET_MV', 75, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ALL_PRD_RAW_CASES', 76, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_INVOICE_CLEANUP_MV', 77, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_INFO_PRICE_SUB_DEAL_BCS_MV', 78, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_MP_SUBS_MV', 79, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_MODAR_MV1', 80, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_MODAR_MV', 81, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_ISPAN_MV', 82, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_ISPAN_MV1', 83, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_RBM_GL_VS_EMAILS_REF', 84, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'MP_CLOUD_SETTLEMTN2', 85, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'MV_PBP_TICKETS_MATCHED', 86, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'MV_CARD_TRANS_PREP', 87, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_RBM_GL_ERP_SUM_MV', 88, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_SHABIK_MV1', 89, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_SHABIK_MV', 90, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_MS_DELAY_CLEANUP', 91, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_DYNAMICS_MV', 92, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DIA_VSAT_GR_ER_MAP_PROJ_MV', 93, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNAMICS_RANK_MRS_MV', 94, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_MLS_MV', 95, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_MLS_MV1', 96, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNBANDWIDTH_MV_AGW', 97, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_UNIFIED_MV', 98, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRA_RANK_VSAT_TEST', 99, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_ERPVSGL_NEW_VSAT_MV', 100, 'COMPLETE', 3600, TRUE, NOW());
INSERT INTO ra_meta.mv_refresh_sequence (id, mv_name, refresh_order, refresh_type, timeout_seconds, is_enabled, created_at)
VALUES
    (gen_random_uuid(), 'PRD_GL_ERP_MV', 101, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_DIA_GL_CLEANUP2_MV', 102, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_BILLING_CN_VALIDATION', 103, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_VDC_USG_MP_SUBS_PRICELIST_MV', 104, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_RAQIB_MV', 105, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_RAQIB_MV1', 106, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_DYNAMIC_DIA_MV', 107, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJECTS_COST_MERGED_MV', 108, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_VMWARE_USG_MP_SUBS_PRICELIST_MV', 109, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERPVSGRANITEDIA_BANDWIDTH', 110, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITEACTIVEDIA_RECON12', 111, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERPVSGRANITEDIA_RECON12_MV', 112, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITEVSACTIVE_BANDWIDTH', 113, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_INVOICE_ALL_MV', 114, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCGL_ERP_BILLING_1MV', 115, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PROJECTS_GL', 116, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STC_GL_RBM_MV_AGGREGATED_2MV', 117, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_RANK_CRMASSET', 118, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_RANK_OP', 119, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_MP_SUBS_MV_TEST', 120, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MN_TREND_CUSTOMER_SUB_USG1', 121, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITEMS_STCSGL_MV', 122, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PJCT_BILL_FINANCIAL_L1_MV', 123, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNBANDWIDTH_MV_ERP', 124, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_CLOUD_MV1', 125, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_CLOUD_MV', 126, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_VSAT_CANCELLED_MV', 127, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_MV1', 128, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_MV', 129, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_PRICELIST_SUB_MV', 130, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_REVENUE_TREND_GL', 131, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ACTIVEMRS_GRANITE_CRMASSET', 132, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MIDDLEWARE_EVENTLOG_MV', 133, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'OMBILLING_VDC_USAGE_SUBS_MV', 134, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJECTS_EXPIRED_CHECK', 135, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_VSAT_PRICEMAT_RECON', 136, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_CLOUD_INVOICESVSCDRS_MV', 137, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_L1_ERP_GRAN_MDS', 138, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_EPM_PLAND_ACT_BASE_BILL_MV', 139, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_INFOFI_MV', 140, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_INFOFI_MV1', 141, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_SUBVSINVOICE_MV', 142, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_MRS_DELAY_CLEANUP', 143, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'MP_CLOUD_SETTLEMTN3', 144, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DELAY_DEV_DIA_CLEANUP_MV', 145, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRA_RANK_DIA_TEST', 146, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_MES_MV1', 147, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_MES_MV', 148, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'VDC_UNREPORTED_USAGE_MV', 149, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STC_GL_RBM_U_1MV', 150, 'COMPLETE', 3600, TRUE, NOW());
INSERT INTO ra_meta.mv_refresh_sequence (id, mv_name, refresh_order, refresh_type, timeout_seconds, is_enabled, created_at)
VALUES
    (gen_random_uuid(), 'PRD_STCS_GL_EMM_MV', 151, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_EMM_MV1', 152, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CUST_COMPLAINT_VSAT_DIA', 153, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DIA_PRICEMAT_RECON', 154, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DELAY_DEL_VSAT_CLEANUP_MV', 155, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_RBM_GL_VS_STCS_GL', 156, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNBANDWIDTH_MV', 157, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_STC_GLVSERP_VSAT_MV', 158, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'VDC_USAGE_REPORT_MV_GROUPED', 159, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_MP_INVOICES_MV_GROUPED', 160, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_VSAT_GL_CLEANUP2_MV', 161, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_CDR_STCGL_MV', 162, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_SUBS_ERROR_MV', 163, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MONTHLY_REVENUE_GL_CDR_2', 164, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MONTHLY_REVENUE_GL_CDR_1', 165, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_MRS_MV1', 166, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_MRS_MV', 167, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJECT_ONHAND_VS_INVENTORY', 168, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_EPM_PLANNED_ACTUAL_REV_MV', 169, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJECTS_L1_STAGNANT_MV', 170, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CONTRACT_SHARE_RECON_CLOUD', 171, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_ERP_DUPLCATION_MV', 172, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DIA_INCIDENT_SERVICE_MV', 173, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_REG_CAN_VS_ISPAN_REV_MV', 174, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_VMWARE_PUBCLOUD_CUST_MP_MV', 175, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_INVOICESVSCDRS_MV', 176, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_EVENT_LOG_VS_MP_SUBS_MV', 177, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'OMBILLING_VDC_USAGE_SUBS_MV_2024', 178, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PRJCT_BILING_ALCN_FIN_L1', 179, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'TEST_MV', 180, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJ_CLOUD_ACT_STANDARD_MV', 181, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRAN_CUSTOMERTREND_MES_MV', 182, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_REV_GL_VALIDATION_CLOUD', 183, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_MS_CRM', 184, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MONTHLY_TREND_REV_GL_VSAT', 185, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'DYNAMICS_ALLORDERS_MV', 186, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PMATRIX_VS_STCSGL_MRS', 187, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DIGITAL_GL_INVOICES_RECON', 188, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCSREV_VS_EMAIL_FLEET', 189, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CAN_PR_STCS_RAISED_INVOICE', 190, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MS_INCIDENT_SERVICES_MV', 191, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_NUMBEROFINVOICES_SUB_MV', 192, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MP_BCS_VS_BCS_SUB_INFO_MV', 193, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'CLOUD_REVUNUE_MV', 194, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_REV_PROJ_L1_MV', 195, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MS_SERVICE_CASES_MV', 196, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MONTHLY_TREND_REVENUE_CDR_MV', 197, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ALL_CLOUD_DELAY_DEV', 198, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MODAR_CHECK', 199, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCSREV_VS_EMAIL_MODAR', 200, 'COMPLETE', 3600, TRUE, NOW());
INSERT INTO ra_meta.mv_refresh_sequence (id, mv_name, refresh_order, refresh_type, timeout_seconds, is_enabled, created_at)
VALUES
    (gen_random_uuid(), 'PRD_STCSREV_VS_EMAIL_ISPAN', 201, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJECTS_PO_VS_GRN', 202, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_AMALNET_GL_INVOICES_RECON', 203, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'ERP_MV', 204, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_REVN_GL_VS_RBM_GL_1', 205, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'MP_CLOUD_SETTLEMTN4', 206, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'MV_COMPLETE_RECONCILIATION', 207, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'ACTIVEVSAT_MV', 208, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_ERP_ACCOUNTS', 209, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CUSTOMER_TREND_RAQIB_MV', 210, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GL_SAMPLE_PRODUCT_MV', 211, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DIA_VSAT_TOTAL_RECOG_MV', 212, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_AGEIN_CORP_STATUS_MV', 213, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_RBM_GL_ERP_AGEING_DR_CR_MV', 214, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCSREV_VS_EMAIL_SHABIK', 215, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_WORKORDER_GRANITE_MRS', 216, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_EVENT_VS_STCS_MP_MV', 217, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DELAY_DEV_MS_RECON', 218, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_DYNAMICS_MV_LASTORDER', 219, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJECT_AP_PO_INV_VS_L1_MV', 220, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_EMM_SERVICE_CASES_MV', 221, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_SAHAL_EMP_VS_APPO_MANP_MP', 222, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNVSACTIVE_MRS_RECON_MV2', 223, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MRS_GL_INVOICES_RECON', 224, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJECTS_L1VI_L3_MARGIN_MV', 225, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CREDIT_ADJUST_PROJECT_MV', 226, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DIA_VSAT_ERP_RECOG_CORP_MV', 227, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCSREV_VS_EMAIL_MLS', 228, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_NUMBER_OF_INVOICES_INV', 229, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYN_RAQIB_UPL_PRI_RECON_MV', 230, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_SHABIK_INCIDENT_SERVICE_MV', 231, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_RAQIB_DYN_VS_GL_MV', 232, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_GRDIA_ACTDEACT_RNK_1_2', 233, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STC_ASSETS', 234, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNACTIVE_BANDWIDTH', 235, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DIA_VSAT_SUM_RECOG_MV', 236, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_RAQIB_INCIDENT_SERVICE_MV', 237, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_SERVICE_DEV_ACT_GL_FLEET', 238, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_EVENT_LOG_MV', 239, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_OPVSERP_MV', 240, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MTREND_CUST_CLOUD_PRODUCTS', 241, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_EVENT_DUNNING_ANALY', 242, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANIVSACTVSAT_RECON12', 243, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITEVSERP_RECON', 244, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MSS_GL_INVOICES_RECON', 245, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_ERP_DUPLACTE_ACTIVE', 246, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_GRVSAT_ACTDEACT_RECON', 247, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_ERPVSGL_NEWSUM_VSATMV', 248, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_DIA_GL_RECON_MV', 249, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_SAMPL_VALIDATION_DIA_VSAT', 250, 'COMPLETE', 3600, TRUE, NOW());
INSERT INTO ra_meta.mv_refresh_sequence (id, mv_name, refresh_order, refresh_type, timeout_seconds, is_enabled, created_at)
VALUES
    (gen_random_uuid(), 'PRD_VDC_PRICERECON_MV', 251, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_RANK_ALL_STATUS', 252, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCSREV_VS_EMAIL_RAQIB', 253, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CASE_CUST_COUNT', 254, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_QTR_MANUAL_ADJUST_STANDARD', 255, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_VSAT_TICKET_CLEANUP_MV', 256, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MN_CORP_REV_DIA_VSAT', 257, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_COST_REV_OUTSOURCE_DETAILS', 258, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_CLEANUP3_MV', 259, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJECT_PO_PR_GRN_OUT_MV', 260, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_FLEET_SERVICE_CASES_MV', 261, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_VSAT_INCIDENT_SERVICE_MV', 262, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_SERVICES_PL_PROV_L1_SAMP', 263, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_COLLECTION_VS_BILLING', 264, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DIGITALGS_GL_INVOICES_RECON', 265, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNVSERP_RECON12', 266, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERPVSGRANITEVSAT_BANDWIDTH', 267, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DOWNTIME_EVENT_LOG_MV', 268, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MNS_GL_INVOICES_RECON', 269, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_ERP_EXPIRY_DATE_CHANGE_MV', 270, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_COST_MERGED_VS_FINA_L1_MV', 271, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_VMWARE_PRICERECON_MV', 272, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_DIA_CANCELLED_MV', 273, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_CDRVSINVOICE_RECON1', 274, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MN_TREND_CUSTOMER_USG', 275, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CONTRACT_SHARE_RECONS_MES', 276, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJECTS_L3_STAGNANT', 277, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CEA_BID_PO_DIST_RECON_MV', 278, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERPVSACTIVEVSAT_BANDWIDTH', 279, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJECT_SERVICE_CASES_MV', 280, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_VS_PM_FLEET_MV', 281, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MN_TREND_CUSTOMER_CLOUD', 282, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_ERPVSGL_NEW_SUM_MV', 283, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCGL_ERP_BILLING_OTHERS_RECON', 284, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CONTRACT_SHARE_RECONS_ML', 285, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_CLOUD_INVOICESVSCDRS_MV2', 286, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_SAHAL_EMP_VS_APPO_MANP_MV', 287, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'VI_MV', 288, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJECT_ACTIVE_CLOUD_MV', 289, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCGL_VS_PROJECT_L1', 290, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_INVOICE_VS_EMAIL_GLRECON', 291, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CONTRACT_SHARE_RECON_FLEET', 292, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_SERVICECASES_BC_MV', 293, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DIA_VSAT_GR_ER_MAP_PROJ_MV2', 294, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CONTRACT_SHARE_RECON_ISPAN', 295, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DELAY_DEV_PROJECTS', 296, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CREDIT_NOTE_DIA_VSAT_RECON', 297, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CONTRACT_SHARE_RECONS', 298, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'ACTIVEDIA_MV', 299, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PMATRIX_VS_DYNAMICS_FLEET', 300, 'COMPLETE', 3600, TRUE, NOW());
INSERT INTO ra_meta.mv_refresh_sequence (id, mv_name, refresh_order, refresh_type, timeout_seconds, is_enabled, created_at)
VALUES
    (gen_random_uuid(), 'PRD_SAHAL_VS_ERP_SALARY_MV', 301, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'DUP_ROWS_CHECK_GL_RBM', 302, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_NEW_DYN_OL_ERP_SAME_CM_MV', 303, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ACTIVEGRANITEMRS_RECON12', 304, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_REV_STND_L1_MV', 305, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_GL_MV_OLD', 306, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_ORDER_PEND_RECON_MV', 307, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MP_SUB_PLIST_USG_MODAR', 308, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MN_TREND_CUSTOMERCLOUD_SUB', 309, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_PRICELIST_USAGE_MV', 310, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MONTHLY_TREND_REV_GL_OTHERS', 311, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PRBILL_L1_GRA_MS_STCSGL_MV', 312, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJECT_ERP_VS_L1_PO', 313, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_SUB_USAGE_MV', 314, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MRS_SERVICE_CASES_MV', 315, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJ_ADV_RASIED_INV_MV', 316, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'GRANITE_MV', 317, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MON_TREND_ANAL_ISPAN', 318, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCGL_PROJBILL_L1_MLS', 319, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNERP_BANDWIDTH', 320, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRA_CUSTOMER_TREND_MV_VSAT', 321, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'SUBS_WITH_NO_PRICES_LINKED_WITH_DEFAULT_PRICES', 322, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_CDR_VS_INVOICES', 323, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CONTRACT_SHARE_RECONS_MRS', 324, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CUSTOMER_COMPLAINT_MRS', 325, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCSREV_VS_EMAIL_CLOUD', 326, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_VSAT_CANCELLED2_MV', 327, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_LOG_MP_BKP_AS_A_SERVICE_MV', 328, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_COST_REV_OUTSOURCING_RECON', 329, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DIA_VSAT_PAYMENT_ANA_MV', 330, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MONTH_TRENDREV_ISPAN', 331, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MONTH_TRENDREV_STCBILL_ALL', 332, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_INVOICES_SUBS_MV', 333, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_BILLING_FINANCL1_STCSGL_MV', 334, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'ACTIVEMODAR_MV', 335, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CUST_COMPLAINT_VSAT_FAULTY', 336, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNAMICVSGRANITE_MRS_RECON', 337, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_I_SUPP_VS_BILL_ALL', 338, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CASE_ROOT_CAUSE_COUNT', 339, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNVSACTIVE_MRS_RECON_MV', 340, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_AGW_VS_PROVISIONING_MODAR', 341, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_SAHAL_VS_ERP_VACATION_MV', 342, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CONTRACT_SHARE_REC_INFOFI', 343, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_SERVICE_CASES_MV', 344, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_VS_CORP_REV_DIA_VSAT', 345, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_SAHALEMP_APOMANP_RESIGN_MV', 346, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERPVSACTIVEVSAT_RECON12', 347, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_LOG_MP_FILEVALT_RAW_MV', 348, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_AGW_VS_PROVISIONING_SHABIK', 349, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_VSAT_CANCELRECON', 350, 'COMPLETE', 3600, TRUE, NOW());
INSERT INTO ra_meta.mv_refresh_sequence (id, mv_name, refresh_order, refresh_type, timeout_seconds, is_enabled, created_at)
VALUES
    (gen_random_uuid(), 'PRD_GRAN_CUSTOMERTREND_WIFI_MV', 351, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_BILL_RPT_VALIDATION_CLOUD', 352, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PMATRIX_VS_PRICELIST_MODAR', 353, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'FILE_VLIDATION', 354, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJ_AP_PO_VS_MATERIAL_MV', 355, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_BILL_SUB_INV_WITHOUT_PO_MV', 356, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERPVSACTIVEDIA_BANDWIDTH', 357, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_REVENUE_TREND_GL_2', 358, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ACTVSGRA_MRS_BANDWIDTH', 359, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ACTIVEVSERP_RECON', 360, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PRODUCT_DETADV', 361, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_COLO_DCO_ALL_VS_MP_SUB_MV', 362, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MP_SUB_VS_INVOICE_BILL_MV', 363, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MID_WARE_EVENTLOG_RECON_MV', 364, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DNS_CREDIT_ERP_SUM_MV', 365, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'OMBILLING_VDC_USAGE_SUBS_MV_MONTHLY', 366, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MN_TREND_GRANITE_MS', 367, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERPVSGRANITEVSAT_RECON12', 368, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_REV_GL_VALIDATION', 369, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_LOG_MP_BKP_AS_SERVICE_2_MV', 370, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_TAWASOL_DIA_VSAT_ALL_GL_MV', 371, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_L1_ERP_GRAN_DIA', 372, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNAMICVSGRANITE_WIFI_REC', 373, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CHARGE_APPLIED_RECON_VSAT', 374, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_FLEET_GL_INVOICES_RECON', 375, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'ACTIVESHABIK_MV', 376, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CONTRACT_SHARE_RECONS_MSS', 377, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNVSGRANITE_MRS_RECON_2', 378, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MN_TREND_CUSTOMER_SUB', 379, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJECTS_EXPIRED_DIA', 380, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PAY_BY_PLATEVSICMS_MV', 381, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MN_TREND_GRANITE_MRS', 382, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNAMICS_RAQIB_CAN_RECON', 383, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CEA_V_TAWASOL_VS_GL_DET_MV', 384, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_MRS_CAN_RECON', 385, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MP_EXPIRED_DEALS', 386, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MONTHLY_TREND_REV_GL_DIA_VSAT', 387, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCSREV_VS_EMAIL_INFOFI', 388, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNVSGRAN_RECON12', 389, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNVSACTIVE_RECON12', 390, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'NEW_MV', 391, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_SUBVSINV_RECON', 392, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_MS_CAN_RECON', 393, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'DYNAMICS_PRODUCT_DETADV_MV', 394, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJECT_ACTIVE_STANDARD_MV', 395, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_QTR_MANUAL_ADJUST_PROJECTS', 396, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GL_ERP_VSAT_MV', 397, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DELAY_DEV_MRS_RECON', 398, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'STCS_MP_SUBS_PRICE_LIST_MV', 399, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MONTHLY_TREND_REVENUE_GL_MV', 400, 'COMPLETE', 3600, TRUE, NOW());
INSERT INTO ra_meta.mv_refresh_sequence (id, mv_name, refresh_order, refresh_type, timeout_seconds, is_enabled, created_at)
VALUES
    (gen_random_uuid(), 'PRD_DELAY_DEV_DIA_RECON', 401, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRA_CUSTOMERTREND_MLS_MV', 402, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_GRDIA_ACTDEACT_RECON', 403, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'MP_CLOUD_SETTLEMTN', 404, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_GL_VSAT_AGE_DNS_CR_MV', 405, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ALL_CLOUD_CAN_RECON', 406, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCSREV_VS_EMAIL_MES', 407, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_DYNAMIC_VSAT_MV', 408, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_INCIDENT_SERVICE_MV', 409, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MASTERISPAN_VS_REG_CAN_MV', 410, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERPVSACTIVEDIA_RECON12', 411, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MODAR_SERVICE_CASES_MV', 412, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CEA_TAWASOL_GL_SUM_MV', 413, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_VMWARE_PRICE_RECON_MV', 414, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DIA_TICKET_CLEANUP_MV', 415, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_VSAT_RNK_1_2', 416, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CONTRACT_SHARE_REC_WI_FI', 417, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANVSACTVSAT_BANDWIDTH', 418, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CEA_VS_FINANCIAL_L1_MV', 419, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_GL_INVOICES_RECON', 420, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_MON_TREND_FLEET_MV', 421, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_RAISED_INV_AGEING_SLA_MV', 422, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCSREV_VS_EMAIL_EMM', 423, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_LOG_MP_DNS_RAW_MV', 424, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MODAR_INCIDENT_SERVICE_MV', 425, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MRS_INCIDENT_SERVICES_MV', 426, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DIA_TICKET_RECON_ROOTCAUSE', 427, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MN_TREND_CUSTOMERSCLOUD_USAGE', 428, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ACTIVEMRS_VS_GRANITERANKOP', 429, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_BILL_SUBS_INV_WITHOUT_PO', 430, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CUSTOMER_TREND_FLEET_MV', 431, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ISPAN_GL_INVOICES_RECON', 432, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_TRIALPERIOD_RECON_MV', 433, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CONTRACT_SHARE_RECON_DIGIT', 434, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_SHABIK_SERVICE_CASES_MV', 435, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'ACTIVECLOUDCONNECTIVITY_MV', 436, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PMATRIX_VS_STCSGL_FLEET', 437, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_EVENT_DUNNING_ANALY2', 438, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_EPM_PLANNED_ACTUAL_BILL_MV', 439, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_VDC_VS_MP_SUBS_MV', 440, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CHARGE_APPLIED_RECON_DIA', 441, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_APPO_MAN_VS_ERP_PAYROLL_MV', 442, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DELAY_DEV_VSAT_RECON', 443, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_RANK_DYN', 444, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJECTS_CLOUD_EXP', 445, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'MP_BILLING_VALIDATION_SUBSCRIPTIONBASED_MV', 446, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_EMP_SALARY_VS_APPO_MANP_MV', 447, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRAN_CUSTOMER_TREND_MV_DIA', 448, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_REVENUE_GLVSINVOICES', 449, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_REVN_GL_VS_RBM_GL', 450, 'COMPLETE', 3600, TRUE, NOW());
INSERT INTO ra_meta.mv_refresh_sequence (id, mv_name, refresh_order, refresh_type, timeout_seconds, is_enabled, created_at)
VALUES
    (gen_random_uuid(), 'PRD_DYNGRANITE_BANDWIDTH', 451, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_RAQIB_SERVICE_CASES_MV', 452, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_PRICE_CATALOG_MV', 453, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_REG_CAN_MTREND_ISPAN', 454, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DIA_GL_INVOICES_RECON', 455, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MRS_DYN_WORK_MOVE_MV', 456, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'ERP_BILLING_VALIDATION', 457, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNAMICS_GRANITEMRS_RECON', 458, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_VDC_MP_SUBS_INVOICES_MV', 459, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCGL_ERP_BILLING_DIA_VSAT_RECON', 460, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_FLEET_PORTAL_DYN_MV', 461, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_VSAT_TICKET_RECON_ROOTCAUSE', 462, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_GL_DIA_RECON_OLD', 463, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MODAR_USG_MP_SUB_VS_AGW_MV', 464, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_SHABIK_', 465, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_ERP_VSAT_GL_RECON_MV', 466, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MLS_SERVICE_CASES_MV', 467, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DYNAMICS_RANK_ERP_TEST', 468, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'SUBS_PRICES_CONFIGURED_RECON', 469, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCS_GL_PO_CHECK_MV', 470, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DIA_VSAT_TICKET_ROOTCAUSE', 471, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_SUB_VS_INV_MV', 472, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'GRANITE_MS_MV', 473, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'MP_MAX_PROCESSDATE', 474, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'DYNAMICS_AOL_MV', 475, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_CLOUD_MN_GL_CDR_TREND_RPT', 476, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_VSAT_GL_INVOICES_RECON', 477, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DELAY_DEV_PROJECTS_L3', 478, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_SDDC_PVTCLO_QTY_CUST_MP_MV', 479, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_STCSREV_VS_EMAIL_MRS', 480, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_PROJECTS_EMP_L1_L3_MV', 481, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_MONTHLY_TREND_REV_STCBILLING_MS', 482, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_GRANITE_DIA_CAN_RECON', 483, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DIA_TICKET_CLEANUP_1_MV', 484, 'COMPLETE', 3600, TRUE, NOW()),
    (gen_random_uuid(), 'PRD_DIA_MDS_L1_PROJECT_SAMP_MV', 485, 'COMPLETE', 3600, TRUE, NOW());


-- ============================================================
-- JOB DEFINITIONS (Migrated from manage_jobs.py JOB_CONFIGS)
-- ============================================================
-- Legacy: manage_jobs.py defined 3 jobs: loader, refresh, extract
-- Now: stored in ra_meta.jobs with cron schedules and configs

INSERT INTO ra_meta.jobs (id, name, job_type, description, schedule_cron, config, is_enabled, max_retries, timeout_seconds)
VALUES
    -- 1. Data Loader Job (legacy: Loader_full_Newv2.py)
    -- Reads data_mapping.xlsx, loads CSV/Excel/PostgreSQL data into Oracle via SQL*Loader
    -- Legacy schedule: cron-based, runs on specific days (Date column in mapping)
    ('8613c024-3fb9-4ff7-8789-63e434b3b896',
     'Daily ETL Loader',
     'load',
     'Loads data from PostgreSQL/CSV/Excel sources into Oracle DWH via SQL*Loader. '
     'Processes all table_config entries matching the current day. '
     'Legacy script: Loader_full_Newv2.py + data_mapping.xlsx',
     '0 2 * * *',
     '{
        "description": "Migrated from Loader_full_Newv2.py",
        "legacy_script": "Loader_full_Newv2.py",
        "legacy_config": "data_mapping.xlsx",
        "legacy_work_dir": "/u01/RA_OPS/Test_New_Loader/Final",
        "legacy_log_path": "/u01/RA_OPS/Test_New_Loader/Final/LOGs",
        "batch_size": 2000000,
        "nls_lang": "AMERICAN_AMERICA.AL32UTF8"
     }',
     TRUE, 3, 7200),

    -- 2. MV Refresh Job (legacy: Refresh_withkill.py)
    -- Refreshes 485 materialized views in dependency order with timeout per MV
    -- Legacy: reads sequence_updated3.xlsx, refreshes sequentially with 60min timeout
    ('15a38d65-af40-409b-bb00-f4d91928cb1f',
     'Daily MV Refresh',
     'refresh',
     'Refreshes all 485 materialized views in dependency-sorted order. '
     'Platform enhancement: parallel refresh within topological levels. '
     'Legacy script: Refresh_withkill.py + sequence_updated3.xlsx',
     '0 4 * * *',
     '{
        "description": "Migrated from Refresh_withkill.py",
        "legacy_script": "Refresh_withkill.py",
        "legacy_config": "sequence_updated3.xlsx",
        "legacy_work_dir": "/u01/RA_OPS",
        "legacy_log_path": "/u01/RA_OPS/MVRefrshLogs.csv",
        "legacy_error_log": "/u01/RA_OPS/script_log.txt",
        "schema_owner": "RECON_PRD",
        "refresh_type": "COMPLETE",
        "timeout_per_mv": 3600,
        "max_parallel": 4,
        "backup_ddl_before_refresh": true,
        "backup_folder": "/u01/RA_OPS/tables_backup"
     }',
     TRUE, 2, 86400),

    -- 3. Oracle Export Job (legacy: extract_tables_to_excel2.py)
    -- Exports Oracle tables to CSV and creates/updates _historical snapshots
    -- Legacy: reads listoftables.csv, exports to monthly folders
    ('ca3906eb-ab5d-4197-8c87-e84a57fd9764',
     'Monthly Oracle Export',
     'export',
     'Exports Oracle tables to CSV files and maintains historical snapshots. '
     'Creates monthly folders (e.g., February-2026/). '
     'Copies to target folders for downstream consumption. '
     'Legacy script: extract_tables_to_excel2.py + listoftables.csv',
     '0 1 1 * *',
     '{
        "description": "Migrated from extract_tables_to_excel2.py",
        "legacy_script": "extract_tables_to_excel2.py",
        "legacy_config": "/u01/RA_OPS/Export_BACKUP/listoftables.csv",
        "legacy_work_dir": "/u01/RA_OPS",
        "schema_owner": "RECON_PRD",
        "output_base_folder": "/u01/RA_OPS/Export_BACKUP",
        "copy_targets": [
            "/home/sdev/ROOT/AutoExport",
            "/home/sdev/ROOT2/Extracts"
        ],
        "create_historical_tables": true,
        "export_format": "csv"
     }',
     TRUE, 3, 14400),

    -- 4. Dependency Graph Scan (legacy: treevFinalv3.py)
    -- Scans Oracle metadata + parses SQL to build view/MV dependency graph
    -- Generates topological sort for refresh ordering
    ('e0cdd8e8-d0eb-4c0b-b80a-32002f32a8c4',
     'Weekly Dependency Scan',
     'dependency_scan',
     'Scans Oracle all_dependencies + parses SQL definitions to build '
     'the full dependency graph for views and materialized views. '
     'Generates topological ordering for optimal parallel MV refresh. '
     'Legacy script: treevFinalv3.py',
     '0 0 * * 0',
     '{
        "description": "Migrated from treevFinalv3.py",
        "legacy_script": "treevFinalv3.py",
        "schema_owner": "RECON_PRD",
        "output_csv": "sorted_views_materialized_views.csv",
        "cleaned_csv": "cleaned_sorted_views.csv",
        "scan_invalid_objects": true,
        "extract_sql_dependencies": true
     }',
     TRUE, 3, 1800)
ON CONFLICT (name) DO NOTHING;



-- ============================================================
-- EXPORT TABLE LIST (Migrated from listoftables.csv)
-- Used by extract_tables_to_excel2.py for Oracle -> CSV exports
-- ============================================================
-- NOTE: The actual table list is loaded from the Oracle server at runtime.
-- The legacy script read from: /u01/RA_OPS/Export_BACKUP/listoftables.csv
-- Format: TableName, Key, WhereCondition
-- This configuration is now stored in ra_meta.table_config with source_type='oracle'
-- and job_type='export'. The export job reads these configs dynamically.
--
-- To migrate the actual listoftables.csv content, run the Python migration
-- script which reads the CSV and inserts into table_config.
-- See: migrations/migrate_export_tables.py



-- ============================================================
-- DATA QUALITY RULES (Extracted from legacy processing logic)
-- ============================================================
-- These rules codify the data cleaning patterns from Loader_full_Newv2.py:
-- 1. Remove commas from values (breaks CSV/SQL*Loader)
-- 2. Remove double quotes from values
-- 3. Remove newlines from values
-- 4. Collapse double spaces to single space
-- 5. Truncate strings to 4000 chars (Oracle VARCHAR2 limit)
-- 6. Remove decimal .0 from integer-like values
-- 7. Replace None/NaN/NaT with empty string

INSERT INTO ra_meta.data_quality_rules (id, table_config_id, rule_name, rule_type, column_name, rule_expression, severity, is_enabled)
SELECT
    gen_random_uuid(),
    tc.id,
    'Remove commas from values',
    'custom',
    NULL,
    'REPLACE(value, '','', '''')',
    'warning',
    TRUE
FROM ra_meta.table_config tc
WHERE tc.source_type IN ('csv', 'excel', 'postgres')
LIMIT 1;

-- Generic rules applied to all loaded data (documented as platform defaults)
INSERT INTO ra_meta.data_quality_rules (id, table_config_id, rule_name, rule_type, column_name, rule_expression, severity, is_enabled)
VALUES
    (gen_random_uuid(), (SELECT id FROM ra_meta.table_config LIMIT 1),
     'Max field length check (Oracle VARCHAR2)', 'range', NULL,
     'LENGTH(value) <= 4000', 'error', TRUE),

    (gen_random_uuid(), (SELECT id FROM ra_meta.table_config LIMIT 1),
     'No embedded newlines', 'regex', NULL,
     'value NOT LIKE ''%\n%''', 'warning', TRUE),

    (gen_random_uuid(), (SELECT id FROM ra_meta.table_config LIMIT 1),
     'No embedded commas in unquoted fields', 'regex', NULL,
     'value NOT LIKE ''%,%''', 'warning', TRUE)
ON CONFLICT DO NOTHING;



-- ============================================================
-- SLA POLICIES (Updated with actual legacy timeout values)
-- ============================================================
-- Legacy: Refresh_withkill.py used 60-minute timeout per MV
-- Legacy: Loader had no explicit timeout (relied on SQL*Loader defaults)
-- Legacy: Export had no explicit timeout

UPDATE ra_meta.sla_policies SET max_duration_minutes = 60 WHERE job_type = 'export' AND name = 'Export SLA';
UPDATE ra_meta.sla_policies SET max_duration_minutes = 120 WHERE job_type = 'load' AND name = 'Load SLA';
UPDATE ra_meta.sla_policies SET max_duration_minutes = 1440 WHERE job_type = 'refresh' AND name = 'Refresh SLA';
UPDATE ra_meta.sla_policies SET max_duration_minutes = 30 WHERE job_type = 'dependency_scan' AND name = 'Dependency Scan SLA';


-- ============================================================
-- MIGRATION AUDIT RECORD
-- ============================================================
INSERT INTO ra_meta.audit_logs (action, resource_type, details)
VALUES (
    'migration.legacy_data_loaded',
    'system',
    '{
        "migration_script": "002_seed_legacy_data.sql",
        "table_configs_loaded": 218,
        "mv_refresh_entries": 485,
        "jobs_created": 4,
        "connection_profiles": 3,
        "source_files": ["data_mapping.xlsx", "sequence_updated3.xlsx", "manage_jobs.py", "extract_tables_to_excel2.py", "Refresh_withkill.py", "treevFinalv3.py"]
    }'
);

COMMIT;
