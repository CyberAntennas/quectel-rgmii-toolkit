#!/bin/sh

# Function to remove the Watchcat script and clean up all related files
remove_watchcat_script() {
    local script_path="/tmp/watchcat.sh"
    local json_path="/tmp/watchcat.json"
    local pid_file="/tmp/watchcat.pid"
    local log_file="/tmp/watchcat.log"

    # Stop the watchcat process if running
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        if ps -p "$pid" > /dev/null 2>&1; then
            kill "$pid" 2>/dev/null
            echo "Stopped watchcat process (PID: $pid)"
            
            # Wait a moment for process to terminate
            sleep 1
            
            # Force kill if still running
            if ps -p "$pid" > /dev/null 2>&1; then
                kill -9 "$pid" 2>/dev/null
                echo "Force killed watchcat process (PID: $pid)"
            fi
        else
            echo "Watchcat PID file exists but process not running"
        fi
        rm -f "$pid_file"
        echo "Removed PID file: $pid_file"
    else
        echo "No watchcat PID file found"
    fi

    # Remove the watchcat script if it exists
    if [ -f "$script_path" ]; then
        rm -f "$script_path"
        echo "Removed script: $script_path"
    else
        echo "Script $script_path does not exist"
    fi

    # Create disabled status JSON
    echo "{\"enabled\": false}" > "$json_path"
    echo "Updated status in: $json_path"

    # Archive the log file instead of deleting it
    if [ -f "$log_file" ]; then
        mv "$log_file" "${log_file}.bak"
        echo "Archived log file to: ${log_file}.bak"
    else
        echo "Log file $log_file does not exist"
    fi

    echo "Watchcat successfully disabled and cleaned up"
}

# Call the function to remove the scripts
remove_watchcat_script