#!/bin/bash

# Auto Monitor with Hooks - Checks build progress and reports back
# Automatically monitors GitHub Actions and provides status updates

REPO="GrimFandango42/travel-translator-app"
CHECK_INTERVAL=30
MAX_CHECKS=30  # 15 minutes max
LOG_FILE="$HOME/auto_monitor.log"

echo "🤖 Auto Monitor with Progress Hooks"
echo "=================================="
echo "📱 Repository: $REPO"
echo "⏱️  Check interval: $CHECK_INTERVAL seconds"
echo "📋 Auto-monitoring build progress..."
echo ""

# Function to log and display
log_and_show() {
    local message="$1"
    echo "$(date '+%H:%M:%S'): $message" | tee -a "$LOG_FILE"
}

# Function to get detailed build status
get_build_details() {
    local run_data=$(gh run list -R "$REPO" --limit 1 --json status,conclusion,databaseId,headBranch,headSha,createdAt,updatedAt,jobs --jq '.[0]' 2>/dev/null)
    echo "$run_data"
}

# Function to check individual job status
check_job_progress() {
    local run_id="$1"
    local jobs=$(gh run view "$run_id" -R "$REPO" --json jobs --jq '.jobs[] | {name: .name, status: .status, conclusion: .conclusion}' 2>/dev/null)
    
    if [ -n "$jobs" ]; then
        echo "📊 JOB PROGRESS:"
        echo "$jobs" | while read -r job; do
            local job_name=$(echo "$job" | jq -r '.name')
            local job_status=$(echo "$job" | jq -r '.status')
            local job_conclusion=$(echo "$job" | jq -r '.conclusion')
            
            case "$job_status" in
                "completed")
                    if [ "$job_conclusion" = "success" ]; then
                        echo "   ✅ $job_name: PASSED"
                    else
                        echo "   ❌ $job_name: FAILED ($job_conclusion)"
                    fi
                    ;;
                "in_progress")
                    echo "   🔄 $job_name: RUNNING"
                    ;;
                "queued")
                    echo "   ⏳ $job_name: QUEUED"
                    ;;
                *)
                    echo "   📊 $job_name: $job_status"
                    ;;
            esac
        done
        echo ""
    fi
}

# Function to send progress update
send_progress_update() {
    local status="$1"
    local run_id="$2"
    local progress="$3"
    
    log_and_show "🔄 PROGRESS UPDATE: $status"
    log_and_show "📦 Build ID: $run_id"
    log_and_show "📊 Progress: $progress"
    
    # Send Termux notification if available
    if command -v termux-notification &> /dev/null; then
        termux-notification \
            --title "Build Progress: $status" \
            --content "Build $run_id - $progress" \
            --priority default
    fi
}

# Function to handle build completion
handle_build_completion() {
    local run_id="$1"
    local conclusion="$2"
    
    if [ "$conclusion" = "success" ]; then
        log_and_show "🎉 BUILD COMPLETED SUCCESSFULLY!"
        log_and_show "📦 Build ID: $run_id"
        log_and_show "🔗 URL: https://github.com/$REPO/actions/runs/$run_id"
        
        # Check for artifacts
        local artifacts=$(gh run view "$run_id" -R "$REPO" --json artifacts --jq '.artifacts[].name' 2>/dev/null)
        if [ -n "$artifacts" ]; then
            log_and_show "📦 AVAILABLE ARTIFACTS:"
            echo "$artifacts" | while read -r artifact; do
                log_and_show "   - $artifact"
            done
        fi
        
        # Check for releases
        local latest_release=$(gh release list -R "$REPO" --limit 1 --json tagName,name --jq '.[0]' 2>/dev/null)
        if [ -n "$latest_release" ] && [ "$latest_release" != "null" ]; then
            local tag=$(echo "$latest_release" | jq -r '.tagName')
            local name=$(echo "$latest_release" | jq -r '.name')
            log_and_show "🚀 RELEASE CREATED: $name ($tag)"
            log_and_show "🔗 Release URL: https://github.com/$REPO/releases/tag/$tag"
        fi
        
        echo ""
        log_and_show "🎯 DEPLOYMENT OPTIONS:"
        log_and_show "   1. Download APK: ./download_apk.sh"
        log_and_show "   2. Deploy to phone: ./deploy_to_phone.sh"
        log_and_show "   3. Direct download: https://github.com/$REPO/actions/runs/$run_id"
        
        # Send success notification
        if command -v termux-notification &> /dev/null; then
            termux-notification \
                --title "🎉 Build Success!" \
                --content "Travel Translator APK ready for download" \
                --priority high \
                --sound
        fi
        
        return 0
    else
        log_and_show "❌ BUILD FAILED: $conclusion"
        log_and_show "🔧 Check logs: https://github.com/$REPO/actions/runs/$run_id"
        
        # Send failure notification
        if command -v termux-notification &> /dev/null; then
            termux-notification \
                --title "❌ Build Failed" \
                --content "Check GitHub Actions for details" \
                --priority high
        fi
        
        return 1
    fi
}

# Main monitoring loop with hooks
main_monitor() {
    log_and_show "🚀 Starting auto-monitor with progress hooks..."
    
    local last_status=""
    local last_run_id=""
    local build_started=false
    
    for ((i=1; i<=MAX_CHECKS; i++)); do
        log_and_show "[$i/$MAX_CHECKS] Checking build status..."
        
        local run_data=$(get_build_details)
        if [ -z "$run_data" ] || [ "$run_data" = "null" ]; then
            log_and_show "⚠️  No build data available"
            sleep "$CHECK_INTERVAL"
            continue
        fi
        
        local run_id=$(echo "$run_data" | jq -r '.databaseId')
        local status=$(echo "$run_data" | jq -r '.status')
        local conclusion=$(echo "$run_data" | jq -r '.conclusion')
        local branch=$(echo "$run_data" | jq -r '.headBranch')
        local commit=$(echo "$run_data" | jq -r '.headSha' | head -c 7)
        
        # Hook: Status change detection
        if [ "$status" != "$last_status" ] || [ "$run_id" != "$last_run_id" ]; then
            case "$status" in
                "queued")
                    send_progress_update "QUEUED" "$run_id" "Build queued on $branch"
                    ;;
                "in_progress")
                    if [ "$build_started" = false ]; then
                        send_progress_update "STARTED" "$run_id" "Build started on $branch ($commit)"
                        build_started=true
                    else
                        send_progress_update "RUNNING" "$run_id" "Build in progress..."
                    fi
                    ;;
                "completed")
                    handle_build_completion "$run_id" "$conclusion"
                    return $?
                    ;;
            esac
            
            last_status="$status"
            last_run_id="$run_id"
        fi
        
        # Hook: Progress details for running builds
        if [ "$status" = "in_progress" ]; then
            check_job_progress "$run_id"
        fi
        
        # Hook: Progress indicator
        local progress_bar=""
        local progress_percent=$((i * 100 / MAX_CHECKS))
        for ((j=0; j<progress_percent/5; j++)); do
            progress_bar="${progress_bar}█"
        done
        for ((j=progress_percent/5; j<20; j++)); do
            progress_bar="${progress_bar}░"
        done
        
        log_and_show "⏳ Progress: [$progress_bar] ${progress_percent}%"
        
        if [ $i -lt $MAX_CHECKS ]; then
            sleep "$CHECK_INTERVAL"
        fi
    done
    
    # Hook: Timeout handling
    log_and_show "⏰ Monitoring timeout reached"
    log_and_show "🔗 Check manually: https://github.com/$REPO/actions"
    
    if command -v termux-notification &> /dev/null; then
        termux-notification \
            --title "⏰ Monitor Timeout" \
            --content "Check GitHub Actions manually" \
            --priority normal
    fi
    
    return 2
}

# Hook: Pre-execution checks
echo "🔍 Pre-execution checks..."
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI not available"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ jq not available"
    exit 1
fi

echo "✅ All dependencies available"
echo ""

# Hook: Initialize logging
echo "$(date): Auto-monitor started" > "$LOG_FILE"

# Hook: Trap signals for cleanup
cleanup() {
    log_and_show "🛑 Auto-monitor stopped by user"
    exit 0
}
trap cleanup INT TERM

# Start monitoring
main_monitor
exit_code=$?

# Hook: Final status report
case $exit_code in
    0)
        log_and_show "✅ Monitoring completed successfully"
        echo ""
        echo "🎉 Your Travel Translator app is ready!"
        echo "📱 Perfect for traveling in Japan!"
        ;;
    1)
        log_and_show "❌ Build failed during monitoring"
        echo ""
        echo "🔧 Check the build logs and try again"
        ;;
    2)
        log_and_show "⏰ Monitoring timed out"
        echo ""
        echo "🔍 Check GitHub Actions manually"
        ;;
esac

echo ""
echo "📋 Full log: $LOG_FILE"
echo "🔗 Repository: https://github.com/$REPO"