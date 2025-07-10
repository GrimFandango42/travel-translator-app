#!/bin/bash

# CI/CD Webhook Automation Script
# Automatically triggers deployment when GitHub Actions completes

REPO="GrimFandango42/travel-translator-app"
WEBHOOK_PORT=8080
WEBHOOK_URL="http://localhost:$WEBHOOK_PORT/webhook"
CHECK_INTERVAL=60  # seconds
LOG_FILE="$HOME/webhook_automation.log"

echo "🔔 CI/CD Webhook Automation Started"
echo "=================================="
echo "📊 Repository: $REPO"
echo "🌐 Webhook URL: $WEBHOOK_URL"
echo "📋 Log file: $LOG_FILE"
echo "⏱️  Check interval: $CHECK_INTERVAL seconds"
echo ""

# Create log file
mkdir -p "$(dirname "$LOG_FILE")"
echo "$(date): Webhook automation started" >> "$LOG_FILE"

# Function to log messages
log_message() {
    echo "$(date): $1" >> "$LOG_FILE"
    echo "$1"
}

# Function to check for new successful builds
check_builds() {
    local last_run_id_file="$HOME/.last_build_id"
    
    # Get latest successful build
    local latest_run_id=$(gh run list -R "$REPO" --workflow="Enhanced CI/CD Pipeline" --status=success --limit=1 --json=databaseId --jq='.[0].databaseId' 2>/dev/null)
    
    if [ -z "$latest_run_id" ] || [ "$latest_run_id" = "null" ]; then
        return 1
    fi
    
    # Check if this is a new build
    local last_run_id=""
    if [ -f "$last_run_id_file" ]; then
        last_run_id=$(cat "$last_run_id_file")
    fi
    
    if [ "$latest_run_id" != "$last_run_id" ]; then
        echo "$latest_run_id" > "$last_run_id_file"
        return 0  # New build found
    fi
    
    return 1  # No new build
}

# Function to handle successful build
handle_successful_build() {
    local run_id="$1"
    log_message "🎉 New successful build detected: $run_id"
    
    # Get build info
    local build_url="https://github.com/$REPO/actions/runs/$run_id"
    local commit_sha=$(gh run view "$run_id" -R "$REPO" --json headSha --jq '.headSha' 2>/dev/null)
    local branch=$(gh run view "$run_id" -R "$REPO" --json headBranch --jq '.headBranch' 2>/dev/null)
    
    log_message "📊 Build URL: $build_url"
    log_message "🔗 Commit: $commit_sha"
    log_message "🌿 Branch: $branch"
    
    # Send notification
    echo ""
    echo "🚀 NEW BUILD READY FOR DEPLOYMENT!"
    echo "=================================="
    echo "📦 Build ID: $run_id"
    echo "🔗 Build URL: $build_url"
    echo "🌿 Branch: $branch"
    echo "🔗 Commit: $commit_sha"
    echo ""
    
    # Auto-deploy if enabled
    if [ -f ".auto_deploy" ]; then
        log_message "🚀 Auto-deploy enabled, starting deployment..."
        echo "🤖 Auto-deploying to phone..."
        
        if [ -f "./deploy_to_phone.sh" ]; then
            ./deploy_to_phone.sh
            if [ $? -eq 0 ]; then
                log_message "✅ Auto-deployment successful"
                echo "✅ Auto-deployment completed successfully!"
            else
                log_message "❌ Auto-deployment failed"
                echo "❌ Auto-deployment failed, check logs"
            fi
        else
            log_message "❌ deploy_to_phone.sh not found"
            echo "❌ Deployment script not found"
        fi
    else
        echo "💡 To enable auto-deployment, create .auto_deploy file"
        echo "💡 Manual deployment: ./deploy_to_phone.sh"
    fi
    
    echo ""
    echo "📱 Ready for installation on your Pixel phone!"
    echo "🇯🇵 Perfect for traveling in Japan!"
}

# Function to start simple webhook listener
start_webhook_listener() {
    log_message "🌐 Starting webhook listener on port $WEBHOOK_PORT..."
    
    # Simple webhook listener using netcat
    while true; do
        {
            echo "HTTP/1.1 200 OK"
            echo "Content-Type: application/json"
            echo "Content-Length: 25"
            echo ""
            echo '{"status": "received"}'
        } | nc -l -p "$WEBHOOK_PORT" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            log_message "📨 Webhook received, checking for new builds..."
            if check_builds; then
                local run_id=$(cat "$HOME/.last_build_id")
                handle_successful_build "$run_id"
            fi
        fi
        
        sleep 1
    done
}

# Main monitoring loop
main_loop() {
    log_message "🔍 Starting build monitoring..."
    
    while true; do
        if check_builds; then
            local run_id=$(cat "$HOME/.last_build_id")
            handle_successful_build "$run_id"
        fi
        
        sleep "$CHECK_INTERVAL"
    done
}

# Handle script termination
cleanup() {
    log_message "🛑 Webhook automation stopped"
    echo ""
    echo "🛑 Webhook automation stopped"
    exit 0
}

trap cleanup INT TERM

# Check dependencies
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed"
    echo "📦 Install with: pkg install gh"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub"
    echo "🔑 Run: gh auth login"
    exit 1
fi

# Start monitoring
echo "🎯 Starting automated build monitoring..."
echo "💡 Press Ctrl+C to stop"
echo ""

# Create auto-deploy hint
echo "💡 To enable auto-deployment when builds complete:"
echo "   touch .auto_deploy"
echo ""

# Start main monitoring loop
main_loop