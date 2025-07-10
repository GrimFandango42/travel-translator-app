#!/bin/bash

# Enhanced Build Monitor with Notifications
# Monitors GitHub Actions builds with status updates and notifications

REPO="GrimFandango42/travel-translator-app"
CHECK_INTERVAL=30  # seconds
MAX_CHECKS=40      # 20 minutes total
LOG_FILE="$HOME/build_monitor.log"
STATUS_FILE="$HOME/.build_status"

echo "📊 Enhanced Build Monitor for Travel Translator"
echo "=============================================="
echo "📱 Repository: $REPO"
echo "⏱️  Check interval: $CHECK_INTERVAL seconds"
echo "📋 Log file: $LOG_FILE"
echo "📊 Status file: $STATUS_FILE"
echo ""

# Create necessary files
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
touch "$STATUS_FILE"

# Function to log with timestamp
log_message() {
    local message="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $message" >> "$LOG_FILE"
    echo "$message"
}

# Function to update status
update_status() {
    local status="$1"
    local run_id="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    cat > "$STATUS_FILE" << EOF
{
  "status": "$status",
  "run_id": "$run_id",
  "timestamp": "$timestamp",
  "repository": "$REPO"
}
EOF
}

# Function to send notification (if Termux:API is available)
send_notification() {
    local title="$1"
    local message="$2"
    
    if command -v termux-notification &> /dev/null; then
        termux-notification --title "$title" --content "$message" --priority high
        log_message "🔔 Notification sent: $title"
    fi
}

# Function to get build status with details
get_build_status() {
    local run_data=$(gh run list -R "$REPO" --limit 1 --json status,conclusion,databaseId,headBranch,headSha,createdAt,updatedAt --jq '.[0]' 2>/dev/null)
    
    if [ -z "$run_data" ] || [ "$run_data" = "null" ]; then
        return 1
    fi
    
    echo "$run_data"
}

# Function to display build summary
display_build_summary() {
    local run_data="$1"
    
    local run_id=$(echo "$run_data" | jq -r '.databaseId')
    local status=$(echo "$run_data" | jq -r '.status')
    local conclusion=$(echo "$run_data" | jq -r '.conclusion')
    local branch=$(echo "$run_data" | jq -r '.headBranch')
    local commit=$(echo "$run_data" | jq -r '.headSha' | head -c 7)
    local created=$(echo "$run_data" | jq -r '.createdAt')
    local updated=$(echo "$run_data" | jq -r '.updatedAt')
    
    echo "📊 BUILD SUMMARY"
    echo "================="
    echo "🆔 Run ID: $run_id"
    echo "📊 Status: $status"
    echo "✅ Conclusion: $conclusion"
    echo "🌿 Branch: $branch"
    echo "🔗 Commit: $commit"
    echo "🕐 Created: $created"
    echo "🕐 Updated: $updated"
    echo "🔗 URL: https://github.com/$REPO/actions/runs/$run_id"
    echo ""
}

# Function to check for artifacts
check_artifacts() {
    local run_id="$1"
    
    local artifacts=$(gh run view "$run_id" -R "$REPO" --json artifacts --jq '.artifacts[] | .name' 2>/dev/null)
    
    if [ -n "$artifacts" ]; then
        echo "📦 AVAILABLE ARTIFACTS:"
        echo "$artifacts" | while read -r artifact; do
            echo "  - $artifact"
        done
        echo ""
    fi
}

# Function to show deployment options
show_deployment_options() {
    local run_id="$1"
    
    echo "🚀 DEPLOYMENT OPTIONS:"
    echo "====================="
    echo "1. Manual download: ./download_apk.sh"
    echo "2. Auto-deploy to phone: ./deploy_to_phone.sh"
    echo "3. Start webhook listener: ./webhook_listener.sh"
    echo "4. Enable auto-deploy: touch .auto_deploy"
    echo ""
    echo "🔗 Direct download: https://github.com/$REPO/actions/runs/$run_id"
    echo "📦 GitHub releases: https://github.com/$REPO/releases"
    echo ""
}

# Function to monitor build progress
monitor_build_progress() {
    local last_status=""
    local last_run_id=""
    
    log_message "🔍 Starting build monitoring..."
    
    for ((i=1; i<=MAX_CHECKS; i++)); do
        echo "[$i/$MAX_CHECKS] Checking build status..."
        
        local run_data=$(get_build_status)
        if [ $? -ne 0 ]; then
            log_message "❌ Failed to get build status"
            sleep "$CHECK_INTERVAL"
            continue
        fi
        
        local run_id=$(echo "$run_data" | jq -r '.databaseId')
        local status=$(echo "$run_data" | jq -r '.status')
        local conclusion=$(echo "$run_data" | jq -r '.conclusion')
        local branch=$(echo "$run_data" | jq -r '.headBranch')
        
        # Check if status changed
        if [ "$status" != "$last_status" ] || [ "$run_id" != "$last_run_id" ]; then
            log_message "🔄 Status changed: $status (Run: $run_id)"
            update_status "$status" "$run_id"
            
            case "$status" in
                "queued")
                    log_message "⏳ Build queued on branch: $branch"
                    send_notification "Build Queued" "Travel Translator build is queued"
                    ;;
                "in_progress")
                    log_message "🏗️ Build in progress on branch: $branch"
                    send_notification "Build Started" "Travel Translator build is in progress"
                    ;;
                "completed")
                    if [ "$conclusion" = "success" ]; then
                        log_message "🎉 Build completed successfully!"
                        send_notification "Build Success! 🎉" "Travel Translator APK is ready for download"
                        
                        echo ""
                        display_build_summary "$run_data"
                        check_artifacts "$run_id"
                        show_deployment_options "$run_id"
                        
                        log_message "✅ Build monitoring completed successfully"
                        return 0
                    else
                        log_message "❌ Build failed with conclusion: $conclusion"
                        send_notification "Build Failed ❌" "Travel Translator build failed: $conclusion"
                        
                        echo ""
                        display_build_summary "$run_data"
                        echo "🔧 Check build logs: https://github.com/$REPO/actions/runs/$run_id"
                        
                        log_message "❌ Build monitoring completed with failure"
                        return 1
                    fi
                    ;;
            esac
            
            last_status="$status"
            last_run_id="$run_id"
        else
            echo "   Status unchanged: $status"
        fi
        
        if [ $i -lt $MAX_CHECKS ]; then
            echo "   ⏰ Next check in $CHECK_INTERVAL seconds..."
            sleep "$CHECK_INTERVAL"
        fi
    done
    
    log_message "⏰ Monitoring timeout reached"
    echo ""
    echo "⏰ Monitoring timeout reached after $((MAX_CHECKS * CHECK_INTERVAL / 60)) minutes"
    echo "🔗 Check manually: https://github.com/$REPO/actions"
}

# Function to show current status
show_current_status() {
    if [ -f "$STATUS_FILE" ]; then
        echo "📊 CURRENT STATUS:"
        cat "$STATUS_FILE" | jq -r '"Status: \(.status) | Run ID: \(.run_id) | Updated: \(.timestamp)"'
        echo ""
    fi
}

# Main execution
main() {
    # Check dependencies
    if ! command -v gh &> /dev/null; then
        echo "❌ GitHub CLI (gh) is not installed"
        echo "📦 Install with: pkg install gh"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo "❌ jq is not installed"
        echo "📦 Install with: pkg install jq"
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        echo "❌ Not authenticated with GitHub"
        echo "🔑 Run: gh auth login"
        exit 1
    fi
    
    # Show current status
    show_current_status
    
    # Start monitoring
    log_message "🚀 Build monitor started"
    echo "💡 Press Ctrl+C to stop monitoring"
    echo ""
    
    # Handle cleanup on exit
    trap 'log_message "🛑 Build monitor stopped"; exit 0' INT TERM
    
    # Start monitoring loop
    monitor_build_progress
}

# Run main function
main "$@"