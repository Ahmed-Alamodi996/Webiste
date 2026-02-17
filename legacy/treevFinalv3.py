import cx_Oracle
import os
import csv
import re
from collections import deque

def set_oracle_environment():
    os.environ['ORACLE_HOME'] = '/home/oracle/app/product/12.2.0/client_1'
    os.environ['PATH'] = os.path.join(os.environ['ORACLE_HOME'], 'bin') + os.pathsep + os.environ['PATH']
    os.environ['TWO_TASK'] = 'incor.solutions.com.sa'

def get_oracle_connection():
    oracle_connection_string = "recon_prd/recon123@incor.solutions.com.sa"
    return cx_Oracle.connect(oracle_connection_string)

def get_all_views_and_mviews(connection):
    # This query gets all views and materialized views, including invalid ones
    query = """
    SELECT object_name, object_type, status
    FROM all_objects
    WHERE object_type IN ('VIEW', 'MATERIALIZED VIEW') AND owner = 'RECON_PRD'
    """
    cursor = connection.cursor()
    cursor.execute(query)
    return cursor.fetchall()

def get_all_invalid_objects(connection):
    # This query specifically targets invalid objects
    query = """
    SELECT object_name, object_type, status
    FROM all_objects
    WHERE object_type IN ('VIEW', 'MATERIALIZED VIEW') 
    AND owner = 'RECON_PRD'
    AND status = 'INVALID'
    """
    cursor = connection.cursor()
    cursor.execute(query)
    return cursor.fetchall()

def get_mview_containers(connection):
    # This query finds materialized view containers that might not appear in all_objects
    query = """
    SELECT mview_name
    FROM all_mviews
    WHERE owner = 'RECON_PRD'
    """
    cursor = connection.cursor()
    cursor.execute(query)
    return [row[0] for row in cursor.fetchall()]

def get_mview_query_text(connection):
    # Get the query text for materialized views to extract dependencies
    query = """
    SELECT mview_name, query
    FROM all_mviews
    WHERE owner = 'RECON_PRD'
    """
    cursor = connection.cursor()
    cursor.execute(query)
    result = {}
    for row in cursor:
        result[row[0]] = row[1]
    return result

def get_view_definitions(connection):
    # Get view definitions for extracting dependencies
    query = """
    SELECT view_name, text
    FROM all_views
    WHERE owner = 'RECON_PRD'
    """
    cursor = connection.cursor()
    cursor.execute(query)
    result = {}
    for row in cursor:
        result[row[0]] = row[1]
    return result

def extract_dependencies_from_sql(sql_text, all_objects_names):
    """Extract potential dependencies from SQL text by looking for object names."""
    # This is a simple extraction and might not catch all dependencies
    # Convert to uppercase for case-insensitive comparison
    sql_text = sql_text.upper()
    dependencies = set()
    
    # Remove string literals to avoid false positives
    sql_text = re.sub(r"'[^']*'", "", sql_text)
    
    # Remove comments
    sql_text = re.sub(r"--.*$", "", sql_text, flags=re.MULTILINE)
    sql_text = re.sub(r"/\*.*?\*/", "", sql_text, flags=re.DOTALL)
    
    # Check for each object name in the SQL
    for obj_name in all_objects_names:
        # Look for the object name surrounded by spaces, parentheses, or other delimiters
        pattern = r'\b' + re.escape(obj_name.upper()) + r'\b'
        if re.search(pattern, sql_text):
            dependencies.add(obj_name)
    
    return dependencies

def get_dependent_views_and_mviews(connection):
    # First get dependencies from all_dependencies
    query = """
    SELECT d.name, d.referenced_name
    FROM all_dependencies d
    JOIN all_objects o ON d.name = o.object_name AND d.owner = o.owner
    WHERE o.object_type IN ('VIEW', 'MATERIALIZED VIEW') 
      AND o.owner = 'RECON_PRD' 
      AND d.referenced_owner = 'RECON_PRD'
      AND d.referenced_name IN (
          SELECT object_name
          FROM all_objects
          WHERE object_type IN ('VIEW', 'MATERIALIZED VIEW')
            AND owner = 'RECON_PRD'
      )
    AND name!=referenced_name
    """
    cursor = connection.cursor()
    cursor.execute(query)
    dependencies = {}
    for row in cursor:
        dependent, referenced = row
        if dependent not in dependencies:
            dependencies[dependent] = set()
        dependencies[dependent].add(referenced)
    
    return dependencies

def get_mview_errors(connection):
    # This query gets error information for materialized views
    # Try different column names for different Oracle versions
    queries = [
        """
        SELECT name, line, position, text
        FROM all_errors
        WHERE owner = 'RECON_PRD'
        AND type = 'MATERIALIZED VIEW'
        ORDER BY name, sequence
        """,
        """
        SELECT obj_name, line, position, text
        FROM all_errors
        WHERE owner = 'RECON_PRD'
        AND type = 'MATERIALIZED VIEW'
        ORDER BY obj_name, sequence
        """
    ]
    
    for query in queries:
        try:
            cursor = connection.cursor()
            cursor.execute(query)
            errors = {}
            for row in cursor:
                obj_name, line, position, text = row
                if obj_name not in errors:
                    errors[obj_name] = []
                errors[obj_name].append(f"Line {line}, Position {position}: {text}")
            return errors
        except cx_Oracle.DatabaseError as e:
            continue
    
    print("Warning: Couldn't retrieve materialized view errors with any known column names.")
    return {}

def enhance_dependencies_with_definitions(dependencies, mview_queries, view_definitions, all_objects_names):
    """Add dependencies derived from SQL definitions for views and materialized views."""
    enhanced_dependencies = dependencies.copy()
    
    # Process materialized view queries
    for mview_name, query_text in mview_queries.items():
        # Skip if no text available
        if not query_text:
            continue
            
        # Extract potential dependencies from query text
        extracted_deps = extract_dependencies_from_sql(query_text, all_objects_names)
        
        # Add these dependencies to our graph
        if extracted_deps:
            if mview_name not in enhanced_dependencies:
                enhanced_dependencies[mview_name] = set()
            enhanced_dependencies[mview_name].update(extracted_deps)
            
            # Remove self-dependency if it exists
            if mview_name in enhanced_dependencies[mview_name]:
                enhanced_dependencies[mview_name].remove(mview_name)
    
    # Process view definitions
    for view_name, definition in view_definitions.items():
        # Skip if no text available
        if not definition:
            continue
            
        # Extract potential dependencies from definition
        extracted_deps = extract_dependencies_from_sql(definition, all_objects_names)
        
        # Add these dependencies to our graph
        if extracted_deps:
            if view_name not in enhanced_dependencies:
                enhanced_dependencies[view_name] = set()
            enhanced_dependencies[view_name].update(extracted_deps)
            
            # Remove self-dependency if it exists
            if view_name in enhanced_dependencies[view_name]:
                enhanced_dependencies[view_name].remove(view_name)
    
    return enhanced_dependencies

def topological_sort(dependencies, all_objects):
    # Create a set of all unique objects (both from dependencies and all_objects)
    all_unique_objects = set()
    
    # Add all objects from all_objects
    for name, _, _ in all_objects:
        all_unique_objects.add(name)
    
    # Add all objects from dependencies (both keys and values)
    for dependent, referenced_set in dependencies.items():
        all_unique_objects.add(dependent)
        all_unique_objects.update(referenced_set)
    
    # Initialize in_degree for all objects
    in_degree = {item: 0 for item in all_unique_objects}
    
    # Calculate in-degree for each object
    for deps in dependencies.values():
        for item in deps:
            if item in in_degree:  # Only count if it's a view or materialized view
                in_degree[item] += 1

    # Start with objects that have no dependencies
    queue = deque([item for item in in_degree if in_degree[item] == 0])
    sorted_order = []

    while queue:
        item = queue.popleft()
        sorted_order.append(item)
        if item in dependencies:
            for dependent in dependencies[item]:
                if dependent in in_degree:  # Only process if it's a view or materialized view
                    in_degree[dependent] -= 1
                    if in_degree[dependent] == 0:
                        queue.append(dependent)

    # Check for cycles
    if len(sorted_order) < len(in_degree):
        print(f"Warning: Cycle detected or unresolvable dependencies exist. Processed {len(sorted_order)} of {len(in_degree)} objects.")
        
        # Add remaining objects (those in potential cycles)
        remaining_objects = [item for item in all_unique_objects if item not in sorted_order]
        print(f"Adding {len(remaining_objects)} objects with potential cyclic dependencies")
        
        # Try to sort the remaining objects based on their dependency count
        # Objects with more dependencies should come later
        remaining_with_deps = []
        for obj in remaining_objects:
            dep_count = len(dependencies.get(obj, set()))
            remaining_with_deps.append((obj, dep_count))
        
        # Sort by dependency count (descending)
        remaining_with_deps.sort(key=lambda x: x[1])
        sorted_remaining = [obj for obj, _ in remaining_with_deps]
        
        sorted_order.extend(sorted_remaining)

    return sorted_order

def write_to_csv(file_path, sorted_order, all_views_mviews, mview_containers, invalid_objects, mview_errors, dependencies):
    # Convert all_views_mviews to dictionary for easier lookup
    all_views_mviews_dict = {name: (obj_type, status) for name, obj_type, status in all_views_mviews}
    
    # Create a set of invalid object names for quicker lookup
    invalid_names = {name for name, _, _ in invalid_objects}
    
    # Create a set of all processed objects
    processed_objects = set()
    
    with open(file_path, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(['ObjectName', 'Type', 'Status', 'SequenceNumber', 'ErrorInfo', 'DependsOn'])
        
        seq_num = 1
        # Process items in sorted_order first
        for object_name in sorted_order:
            error_info = ""
            if object_name in mview_errors:
                error_info = "; ".join(mview_errors[object_name][:3])  # Limit to first 3 errors
                if len(mview_errors[object_name]) > 3:
                    error_info += f"; ... ({len(mview_errors[object_name])-3} more errors)"
            
            # Get dependency info
            depends_on = ", ".join(dependencies.get(object_name, set())) if object_name in dependencies else ""
            
            if object_name in all_views_mviews_dict:
                obj_type, status = all_views_mviews_dict[object_name]
                writer.writerow([object_name, obj_type, status, seq_num, error_info, depends_on])
                processed_objects.add(object_name)
            elif object_name in invalid_names:
                # Handle invalid objects that might be in sorted_order
                invalid_obj = next((obj for obj in invalid_objects if obj[0] == object_name), None)
                if invalid_obj:
                    name, obj_type, status = invalid_obj
                    writer.writerow([name, obj_type, status, seq_num, error_info, depends_on])
                    processed_objects.add(name)
            else:
                # Object not found in regular metadata, assume it's a missing materialized view
                writer.writerow([object_name, "MATERIALIZED VIEW", "UNKNOWN", seq_num, error_info, depends_on])
                processed_objects.add(object_name)
            seq_num += 1
        
        # Process any remaining objects from all_views_mviews that weren't in sorted_order
        for name, (obj_type, status) in all_views_mviews_dict.items():
            if name not in processed_objects:
                error_info = ""
                if name in mview_errors:
                    error_info = "; ".join(mview_errors[name][:3])
                    if len(mview_errors[name]) > 3:
                        error_info += f"; ... ({len(mview_errors[name])-3} more errors)"
                
                depends_on = ", ".join(dependencies.get(name, set())) if name in dependencies else ""
                
                writer.writerow([name, obj_type, status, seq_num, error_info, depends_on])
                processed_objects.add(name)
                seq_num += 1
                print(f"Added object not in dependency graph: {name} ({obj_type}, {status})")
        
        # Process any materialized views from all_mviews that aren't in the metadata
        for mview_name in mview_containers:
            if mview_name not in processed_objects:
                error_info = ""
                if mview_name in mview_errors:
                    error_info = "; ".join(mview_errors[mview_name][:3])
                    if len(mview_errors[mview_name]) > 3:
                        error_info += f"; ... ({len(mview_errors[mview_name])-3} more errors)"
                
                depends_on = ", ".join(dependencies.get(mview_name, set())) if mview_name in dependencies else ""
                
                writer.writerow([mview_name, "MATERIALIZED VIEW", "NOT_IN_ALL_OBJECTS", seq_num, error_info, depends_on])
                processed_objects.add(mview_name)
                seq_num += 1
                print(f"Added materialized view not in metadata: {mview_name}")
        
        # Process any invalid objects that weren't processed yet
        for name, obj_type, status in invalid_objects:
            if name not in processed_objects:
                error_info = ""
                if name in mview_errors:
                    error_info = "; ".join(mview_errors[name][:3])
                    if len(mview_errors[name]) > 3:
                        error_info += f"; ... ({len(mview_errors[name])-3} more errors)"
                
                depends_on = ", ".join(dependencies.get(name, set())) if name in dependencies else ""
                
                writer.writerow([name, obj_type, status, seq_num, error_info, depends_on])
                processed_objects.add(name)
                seq_num += 1
                print(f"Added invalid object: {name} ({obj_type}, {status})")
    
    return processed_objects

def create_cleaned_csv(original_csv, cleaned_csv):
    import pandas as pd

    # Load the full CSV
    df = pd.read_csv(original_csv)

    # Sort by SequenceNumber
    df = df.sort_values(by='SequenceNumber', ascending=False)

    # Drop rows where Type is VIEW
    df = df[df['Type'] != 'VIEW']


    # Rename ObjectName to table and keep only that column
    cleaned_df = df[['ObjectName']].rename(columns={'ObjectName': 'table'})

    # Write to new cleaned CSV
    cleaned_df.to_csv(cleaned_csv, index=False)
    print(f"Cleaned CSV written to {cleaned_csv}")
def main():
    set_oracle_environment()
    connection = get_oracle_connection()

    # Get all views and materialized views, including valid and invalid
    all_views_mviews = get_all_views_and_mviews(connection)
    all_objects_names = [name for name, _, _ in all_views_mviews]
    
    # Get specifically invalid objects
    invalid_objects = get_all_invalid_objects(connection)
    print(f"Found {len(invalid_objects)} invalid objects")
    
    # Get materialized view containers that might not be in all_objects
    mview_containers = get_mview_containers(connection)
    print(f"Found {len(mview_containers)} materialized views from all_mviews")
    
    # Get materialized view query text for dependency extraction
    mview_queries = get_mview_query_text(connection)
    print(f"Retrieved query text for {len(mview_queries)} materialized views")
    
    # Get view definitions for dependency extraction
    view_definitions = get_view_definitions(connection)
    print(f"Retrieved definitions for {len(view_definitions)} views")
    
    # Get errors for materialized views
    mview_errors = get_mview_errors(connection)
    if mview_errors:
        print(f"Found errors for {len(mview_errors)} materialized views")
    
    # Get dependencies from metadata
    base_dependencies = get_dependent_views_and_mviews(connection)
    print(f"Found {len(base_dependencies)} objects with dependencies in metadata")
    
    # Enhance dependencies with extracted information from SQL text
    dependencies = enhance_dependencies_with_definitions(base_dependencies, mview_queries, view_definitions, all_objects_names)
    
    # Print dependency stats
    additional_deps = len(dependencies) - len(base_dependencies)
    if additional_deps > 0:
        print(f"Added dependencies for {additional_deps} additional objects from SQL definitions")
    
    # Perform topological sort
    sorted_order = topological_sort(dependencies, all_views_mviews)

    output_file_path = 'sorted_views_materialized_views.csv'  # Update to your desired path
    cleaned_file_path = 'cleaned_sorted_views.csv'
    processed_objects = write_to_csv(output_file_path, sorted_order, all_views_mviews, mview_containers, invalid_objects, mview_errors, dependencies)
    create_cleaned_csv(output_file_path, cleaned_file_path)

    print(f"Data written to {output_file_path}. Processed {len(sorted_order)} objects in dependency graph.")
    print(f"Total of {len(processed_objects)} objects written to CSV.")
    connection.close()

if __name__ == "__main__":
    main()