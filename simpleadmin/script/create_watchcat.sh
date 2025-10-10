#!/bin/sh

# Function to create and run the Watchcat script with better process management
create_and_run_watchcat_script() {
    local ip=$1
    local timeout=$2
    local failure_count=$3
    local script_path="/tmp/watchcat.sh"
    local pid_file="/tmp/watchcat.pid"
    local log_file="/tmp/watchcat.log"
    local json_file="/tmp/watchcat.json"

    # Stop any existing watchcat process
    if [ -f "$pid_file" ]; then
        old_pid=$(cat "$pid_file")
        if ps -p "$old_pid" > /dev/null 2>&1; then
            kill "$old_pid" 2>/dev/null
            echo "Stopped existing watchcat process (PID: $old_pid)"
        fi
        rm -f "$pid_file"
    fi

    # Create the script with the watchcat logic
    cat << EOF > "$script_path"
#!/bin/sh

failures=0
log_file="$log_file"

# Function to log with timestamp
log_message() {
    echo "\$(date): \$1" >> "\$log_file"
}

# Ensure log file exists
touch "\$log_file"

log_message "Watchcat started - monitoring $ip (timeout: ${timeout}s, failure limit: $failure_count)"

while :; do
    if ping -c 1 -W $timeout "$ip" > /dev/null 2>&1; then
        if [ "\$failures" -gt 0 ]; then
            log_message "Ping to $ip successful - resetting failure count (was \$failures)"
        fi
        failures=0
    else
        failures=\$((failures + 1))
        log_message "Ping to $ip failed (\$failures/$failure_count consecutive failures)"
        
        if [ "\$failures" -ge "$failure_count" ]; then
            log_message "CRITICAL: Rebooting system due to \$failures consecutive ping failures"
            /sbin/reboot
            exit 0
        fi
    fi
    sleep $timeout
done
EOF

    # Make the watchcat script executable
    chmod +x "$script_path"

    # Create a JSON status file
    echo "{\"enabled\": true, \"track_ip\": \"$ip\", \"ping_timeout\": $timeout, \"ping_failure_count\": $failure_count}" > "$json_file"

    # Check if the script was created successfully
    if [ -f "$script_path" ]; then
        # Run the script in the background and capture PID
        nohup /bin/sh "$script_path" >/dev/null 2>&1 &
        watchcat_pid=$!
        
        # Save the PID for monitoring
        echo "$watchcat_pid" > "$pid_file"
        
        # Verify the process started
        sleep 1
        if ps -p "$watchcat_pid" > /dev/null 2>&1; then
            echo "Watchcat script created and running (PID: $watchcat_pid)"
        else
            echo "Failed to start the Watchcat process"
            rm -f "$pid_file"
        fi
    else
        echo "Failed to create the Watchcat script."
        echo "Please check the script path: $script_path"
    fi
}
}

# Check if the script is called with the required parameters
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <IP> <timeout> <failure_count>"
    exit 1
fi

# Call the function with the provided arguments
create_and_run_watchcat_script "$1" "$2" "$3"