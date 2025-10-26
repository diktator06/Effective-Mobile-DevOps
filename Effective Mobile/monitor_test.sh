#!/bin/bash

LOG_FILE="/var/log/monitoring.log"
PID_FILE="/var/run/monitor_test.pid"
PROCESS_NAME="test"
MONITORING_URL="https://test.com/monitoring/test/api"

log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

get_process_pid() {
    pgrep -x "$PROCESS_NAME" | head -n 1
}

send_heartbeat() {
    local exit_code=0
    curl -sSf --max-time 10 --connect-timeout 5 "$MONITORING_URL" > /dev/null 2>&1 || exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        log_message "ERROR" "Monitoring server is not accessible (HTTP code: $exit_code)"
    fi
    
    return $exit_code
}

main() {
    local current_pid=$(get_process_pid)
    
    if [ -z "$current_pid" ]; then
        if [ -f "$PID_FILE" ]; then
            rm -f "$PID_FILE"
        fi
        exit 0
    fi
    
    if [ -f "$PID_FILE" ]; then
        local previous_pid=$(cat "$PID_FILE" 2>/dev/null)
        
        if [ -n "$previous_pid" ] && [ "$previous_pid" != "$current_pid" ]; then
            log_message "INFO" "Process '$PROCESS_NAME' was restarted (old PID: $previous_pid, new PID: $current_pid)"
        fi
    fi
    
    echo "$current_pid" > "$PID_FILE"
    send_heartbeat
}

main

