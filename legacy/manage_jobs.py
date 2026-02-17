import os
import subprocess
import time
import signal
from datetime import datetime
from pathlib import Path
import psutil

LOG_DIR = "/u01/RA_OPS/logs"

# Job configurations with their dependencies
JOB_CONFIGS = {
    "loader": {
        "script": "Loader_full_Newv2.py",
        "work_dir": "/u01/RA_OPS/Test_New_Loader/Final",
        "config_file": "/u01/RA_OPS/Test_New_Loader/Final/data_mapping.xlsx",
        "log_path": "/u01/RA_OPS/Test_New_Loader/Final/LOGs",
        "description": "Data Loader"
    },
    "refresh": {
        "script": "Refresh_withkill.py",
        "work_dir": "/u01/RA_OPS",
        "config_file": "/u01/RA_OPS/sequence_updated3.xlsx",
        "log_path": "/u01/RA_OPS/script_log.txt",
        "description": "Data Refresh"
    },
    "extract": {
        "script": "extract_tables_to_excel.py",
        "work_dir": "/u01/RA_OPS",
        "config_file": "/u01/RA_OPS/Export_BACKUP/listoftables.csv",
        "log_path": "/u01/RA_OPS/extract_tables_to_excel_log.csv",
        "description": "Extract to Excel"
    }
}

def print_colored(text, color_code):
    """Print colored text with ANSI codes"""
    print(f"\033[{color_code}m{text}\033[0m")

def print_success(text):
    print_colored(f"[✓] {text}", "92")

def print_error(text):
    print_colored(f"[!] {text}", "91")

def print_warning(text):
    print_colored(f"[!] {text}", "93")

def print_info(text):
    print_colored(f"[+] {text}", "96")

def ensure_log_dir():
    """Create log directory if it doesn't exist"""
    try:
        Path(LOG_DIR).mkdir(parents=True, exist_ok=True)
        return True
    except PermissionError:
        print_error(f"Permission denied creating log directory: {LOG_DIR}")
        return False
    except Exception as e:
        print_error(f"Failed to create log directory: {e}")
        return False

def validate_job_config(job_key):
    """Validate that all required files and directories exist for a job"""
    config = JOB_CONFIGS.get(job_key)
    if not config:
        print_error(f"Unknown job configuration: {job_key}")
        return False
    
    issues = []
    
    # Check work directory
    if not os.path.exists(config["work_dir"]):
        issues.append(f"Work directory not found: {config['work_dir']}")
    
    # Check script file
    script_path = os.path.join(config["work_dir"], config["script"])
    if not os.path.exists(script_path):
        issues.append(f"Script file not found: {script_path}")
    
    # Check configuration file
    if not os.path.exists(config["config_file"]):
        issues.append(f"Configuration file not found: {config['config_file']}")
    
    # Check if log directory is accessible
    log_dir = os.path.dirname(config["log_path"])
    if not os.path.exists(log_dir):
        try:
            Path(log_dir).mkdir(parents=True, exist_ok=True)
            print_info(f"Created log directory: {log_dir}")
        except Exception as e:
            issues.append(f"Cannot create log directory {log_dir}: {e}")
    
    if issues:
        print_error(f"Validation failed for {config['description']}:")
        for issue in issues:
            print_error(f"  - {issue}")
        return False
    
    print_success(f"Validation passed for {config['description']}")
    return True

def get_managed_processes():
    """Get list of our managed Python processes"""
    managed_scripts = [config["script"] for config in JOB_CONFIGS.values()]
    processes = []
    
    try:
        for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
            try:
                if proc.info['name'] == 'python' or proc.info['name'] == 'python3':
                    cmdline = ' '.join(proc.info['cmdline'])
                    for script in managed_scripts:
                        if script in cmdline:
                            processes.append({
                                'pid': proc.info['pid'],
                                'script': script,
                                'cmdline': cmdline
                            })
                            break
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue
    except Exception as e:
        print_error(f"Error getting process list: {e}")
    
    return processes

def is_job_running(job_key):
    """Check if a specific job is currently running"""
    config = JOB_CONFIGS.get(job_key)
    if not config:
        return False
    
    processes = get_managed_processes()
    return any(proc['script'] == config['script'] for proc in processes)

def get_job_status():
    """Get status of all managed jobs"""
    print_info("Job Status:")
    for job_key, config in JOB_CONFIGS.items():
        status = "RUNNING" if is_job_running(job_key) else "STOPPED"
        color = "92" if status == "RUNNING" else "91"
        print_colored(f"  {config['description']:<20} : {status}", color)

def run_script(job_key):
    """Run a script with enhanced error handling and validation"""
    if not validate_job_config(job_key):
        return False
    
    config = JOB_CONFIGS[job_key]
    
    # Check if job is already running
    if is_job_running(job_key):
        print_warning(f"{config['description']} is already running!")
        choice = input("Do you want to continue anyway? [y/N]: ").strip().lower()
        if choice != 'y':
            print_info("Operation cancelled.")
            return False
    
    try:
        # Change to work directory
        original_dir = os.getcwd()
        os.chdir(config["work_dir"])
        
        # Create timestamped log file
        ts = datetime.now().strftime("%Y%m%d%H%M%S")
        log_file = os.path.join(LOG_DIR, f"{job_key}_{ts}.log")
        
        # Run the script
        cmd = f"nohup python {config['script']} > {log_file} 2>&1 &"
        process = subprocess.Popen(cmd, shell=True)
        
        # Wait a moment to check if process started successfully
        time.sleep(2)
        
        # Verify the process started
        if is_job_running(job_key):
            print_success(f"Started {config['description']} in background")
            print_info(f"Log file: {log_file}")
        else:
            print_error(f"Failed to start {config['description']}")
            # Show recent log entries if available
            if os.path.exists(log_file):
                print_info("Recent log entries:")
                subprocess.run(f"tail -n 10 {log_file}", shell=True)
            return False
        
        # Restore original directory
        os.chdir(original_dir)
        return True
        
    except FileNotFoundError:
        print_error(f"Python interpreter not found")
        return False
    except PermissionError:
        print_error(f"Permission denied accessing {config['work_dir']}")
        return False
    except Exception as e:
        print_error(f"Unexpected error running {config['description']}: {e}")
        return False

def list_all_python_processes():
    """List all running Python processes with better formatting"""
    print_info("All Python processes:")
    try:
        result = subprocess.run(
            "ps -eo user,pid,ppid,%cpu,%mem,cmd | grep python | grep -v grep",
            shell=True, capture_output=True, text=True
        )
        
        if result.stdout.strip():
            print("\nUSER       PID    PPID  %CPU %MEM COMMAND")
            print("-" * 80)
            print(result.stdout.strip())
        else:
            print_info("No Python processes found.")
            
    except Exception as e:
        print_error(f"Error listing processes: {e}")

def list_managed_processes():
    """List only our managed processes"""
    print_info("Managed Python processes:")
    processes = get_managed_processes()
    
    if not processes:
        print_info("No managed processes are currently running.")
        return
    
    print("\nPID    SCRIPT                    COMMAND")
    print("-" * 60)
    for proc in processes:
        print(f"{proc['pid']:<6} {proc['script']:<25} {proc['cmdline'][:50]}...")

def kill_processes_safely():
    """Kill processes with confirmation and better targeting"""
    processes = get_managed_processes()
    
    if not processes:
        print_info("No managed processes are currently running.")
        return
    
    print_warning("The following managed processes are running:")
    for proc in processes:
        print(f"  PID {proc['pid']}: {proc['script']}")
    
    choice = input("\nDo you want to kill these processes? [y/N]: ").strip().lower()
    if choice != 'y':
        print_info("Operation cancelled.")
        return
    
    # First try graceful termination
    print_info("Attempting graceful termination...")
    for proc in processes:
        try:
            os.kill(proc['pid'], signal.SIGTERM)
            print_info(f"Sent SIGTERM to PID {proc['pid']}")
        except ProcessLookupError:
            print_warning(f"PID {proc['pid']} already terminated")
        except PermissionError:
            print_error(f"Permission denied for PID {proc['pid']}")
        except Exception as e:
            print_error(f"Error terminating PID {proc['pid']}: {e}")
    
    # Wait for graceful termination
    time.sleep(3)
    
    # Check for remaining processes and force kill if necessary
    remaining = get_managed_processes()
    if remaining:
        print_warning("Some processes are still running. Force killing...")
        for proc in remaining:
            try:
                os.kill(proc['pid'], signal.SIGKILL)
                print_warning(f"Force killed PID {proc['pid']}")
            except ProcessLookupError:
                print_info(f"PID {proc['pid']} already terminated")
            except Exception as e:
                print_error(f"Error force killing PID {proc['pid']}: {e}")
    
    # Final check
    final_check = get_managed_processes()
    if not final_check:
        print_success("All managed processes terminated successfully.")
    else:
        print_error("Some processes could not be terminated:")
        for proc in final_check:
            print_error(f"  PID {proc['pid']}: {proc['script']}")

def view_logs():
    """Enhanced log viewing with better navigation"""
    print_info("Available log files:")
    ensure_log_dir()
    
    try:
        logs = sorted([f for f in os.listdir(LOG_DIR) if f.endswith('.log')], reverse=True)
        if not logs:
            print_info("No log files found.")
            return
        
        print("\nRecent logs:")
        for i, log in enumerate(logs[:20]):  # Show only last 20 logs
            size = os.path.getsize(os.path.join(LOG_DIR, log))
            mtime = datetime.fromtimestamp(os.path.getmtime(os.path.join(LOG_DIR, log)))
            print(f"{i + 1:2d}) {log:<40} ({size:>8} bytes, {mtime.strftime('%Y-%m-%d %H:%M')})")
        
        if len(logs) > 20:
            print(f"... and {len(logs) - 20} more files")
        
        choice = input("\nEnter log number to view tail (or Enter to cancel): ").strip()
        if choice.isdigit() and 1 <= int(choice) <= min(20, len(logs)):
            log_path = os.path.join(LOG_DIR, logs[int(choice) - 1])
            lines = input("Number of lines to show [30]: ").strip() or "30"
            print(f"\n--- Tail {lines} lines of {log_path} ---\n")
            subprocess.run(f"tail -n {lines} '{log_path}'", shell=True)
        else:
            print_info("Cancelled.")
            
    except Exception as e:
        print_error(f"Error reading logs: {e}")

def show_log_paths():
    """Show log paths with existence check"""
    print_info("Log File Paths:")
    
    log_paths = {
        "Job Manager Logs": LOG_DIR,
        "Loader Run Logs": "/u01/RA_OPS/Test_New_Loader/Final/LOGs",
        "Loader Full Logs": "/u01/RA_OPS/Test_New_Loader/Final/log.csv",
        "Refresh Error Logs": "/u01/RA_OPS/script_log.txt",
        "Refresh Full Logs": "/u01/RA_OPS/MVRefrshLogs.csv",
        "Extract to Excel Logs": "/u01/RA_OPS/extract_tables_to_excel_log.csv"
    }
    
    for name, path in log_paths.items():
        exists = "✓" if os.path.exists(path) else "✗"
        color = "92" if exists == "✓" else "91"
        print_colored(f"  {exists} {name:<25} : {path}", color)

def show_config_paths():
    """Show configuration paths with existence check"""
    print_info("Configuration File Paths:")
    
    for job_key, config in JOB_CONFIGS.items():
        exists = "✓" if os.path.exists(config["config_file"]) else "✗"
        color = "92" if exists == "✓" else "91"
        print_colored(f"  {exists} {config['description']:<25} : {config['config_file']}", color)

def monitor_jobs():
    """Real-time job monitoring"""
    print_info("Real-time job monitoring (Press Ctrl+C to stop)")
    
    try:
        while True:
            os.system('clear' if os.name == 'posix' else 'cls')
            print("=== Job Monitor ===")
            print(f"Last update: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
            print()
            
            get_job_status()
            print()
            
            # Show recent log activity
            try:
                recent_logs = []
                if os.path.exists(LOG_DIR):
                    for log_file in os.listdir(LOG_DIR):
                        if log_file.endswith('.log'):
                            log_path = os.path.join(LOG_DIR, log_file)
                            mtime = os.path.getmtime(log_path)
                            if time.time() - mtime < 300:  # Last 5 minutes
                                recent_logs.append((log_file, mtime))
                
                if recent_logs:
                    print_info("Recent log activity (last 5 minutes):")
                    for log_file, mtime in sorted(recent_logs, key=lambda x: x[1], reverse=True):
                        timestamp = datetime.fromtimestamp(mtime).strftime('%H:%M:%S')
                        print(f"  {timestamp} - {log_file}")
                else:
                    print_info("No recent log activity")
                    
            except Exception as e:
                print_error(f"Error checking log activity: {e}")
            
            print("\nPress Ctrl+C to return to main menu...")
            time.sleep(10)
            
    except KeyboardInterrupt:
        print_info("\nMonitoring stopped.")

def run_job_by_key(job_key):
    """Generic job runner"""
    config = JOB_CONFIGS.get(job_key)
    if not config:
        print_error(f"Unknown job: {job_key}")
        return
    
    print_info(f"Running {config['description']}...")
    run_script(job_key)

def show_menu():
    """Enhanced main menu"""
    if not ensure_log_dir():
        print_error("Cannot create log directory. Some features may not work.")
    
    while True:
        print("\n" + "=" * 50)
        print("       Enhanced Python Job Manager")
        print("=" * 50)
        
        # Show quick status
        print_info("Quick Status:")
        for job_key, config in JOB_CONFIGS.items():
            status = "RUNNING" if is_job_running(job_key) else "STOPPED"
            color = "92" if status == "RUNNING" else "90"
            print_colored(f"  {config['description']:<20} : {status}", color)
        
        print("\n--- Job Control ---")
        print("1) Run Loader")
        print("2) Run Refresh") 
        print("3) Run Extract Tables to Excel")
        print("4) Monitor Jobs (Real-time)")
        print("\n--- Process Management ---")
        print("5) List managed processes")
        print("6) List all Python processes")
        print("7) Kill managed processes")
        print("\n--- Logs & Configuration ---")
        print("8) View log files")
        print("9) Show log paths")
        print("10) Show configuration paths")
        print("\n11) Exit")

        choice = input("\nSelect an option [1-11]: ").strip()
        
        try:
            if choice == '1':
                run_job_by_key('loader')
            elif choice == '2':
                run_job_by_key('refresh')
            elif choice == '3':
                run_job_by_key('extract')
            elif choice == '4':
                monitor_jobs()
            elif choice == '5':
                list_managed_processes()
            elif choice == '6':
                list_all_python_processes()
            elif choice == '7':
                kill_processes_safely()
            elif choice == '8':
                view_logs()
            elif choice == '9':
                show_log_paths()
            elif choice == '10':
                show_config_paths()
            elif choice == '11':
                print_success("Goodbye!")
                break
            else:
                print_error("Invalid option. Please try again.")
                
        except KeyboardInterrupt:
            print_info("\nOperation interrupted by user.")
        except Exception as e:
            print_error(f"Unexpected error: {e}")
        
        if choice != '11':
            input("\nPress Enter to continue...")

if __name__ == "__main__":
    try:
        show_menu()
    except KeyboardInterrupt:
        print_info("\nProgram interrupted by user. Goodbye!")
    except Exception as e:
        print_error(f"Fatal error: {e}")