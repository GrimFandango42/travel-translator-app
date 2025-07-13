#!/bin/bash

# Watch Build - Master script that orchestrates monitoring with hooks
# Automatically monitors, reports progress, and hands off when complete

REPO="GrimFandango42/travel-translator-app"

echo "👀 Watch Build - Automated CI/CD Monitor"
echo "======================================="
echo "📱 Repository: $REPO"
echo "🤖 Full automation with progress hooks"
echo ""

# Function to check current build status
check_current_build() {
    local status=$(gh run list -R "$REPO" --limit 1 --json status --jq '.[0].status' 2>/dev/null)
    echo "$status"
}

# Function to wait for build to start
wait_for_build_start() {
    echo "🔍 Checking for active builds..."
    
    local current_status=$(check_current_build)
    
    case "$current_status" in
        "in_progress"|"queued")
            echo "✅ Found active build: $current_status"
            return 0
            ;;
        "completed")
            echo "✅ Found recently completed build"
            return 0
            ;;
        *)
            echo "⏳ No active build found, waiting for build to start..."
            echo "💡 Push code changes to trigger a build"
            
            # Wait up to 2 minutes for a build to start
            for i in {1..24}; do
                sleep 5
                current_status=$(check_current_build)
                if [ "$current_status" = "in_progress" ] || [ "$current_status" = "queued" ]; then
                    echo "✅ Build started: $current_status"
                    return 0
                fi
                echo -n "."
            done
            
            echo ""
            echo "⏰ No build started within 2 minutes"
            echo "🔗 Check: https://github.com/$REPO/actions"
            return 1
            ;;
    esac
}

# Function to run auto monitor
run_auto_monitor() {
    echo ""
    echo "🚀 Starting automated monitoring with progress hooks..."
    echo "📊 Will track build progress and notify on completion"
    echo ""
    
    ./auto_monitor.sh
    return $?
}

# Function to run completion hook
run_completion_hook() {
    echo ""
    echo "🏁 Running completion hook for final verification..."
    echo ""
    
    ./completion_hook.sh
    return $?
}

# Function to show final options
show_final_options() {
    echo ""
    echo "🎯 YOUR OPTIONS NOW:"
    echo "=================="
    echo "1. 📱 Deploy to phone:    ./deploy_to_phone.sh"
    echo "2. 📥 Download APK:       ./download_apk.sh"
    echo "3. 👀 Watch next build:   ./watch_build.sh"
    echo "4. 🔄 Manual monitor:     ./build_monitor.sh"
    echo ""
    echo "📋 Check DEPLOYMENT_READY.md for detailed instructions"
    echo "🔗 Direct link: https://github.com/$REPO/actions"
    echo ""
}

# Main execution flow
main() {
    # Dependency checks
    if ! command -v gh &> /dev/null; then
        echo "❌ GitHub CLI not available"
        echo "📦 Install with: pkg install gh"
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        echo "❌ Not authenticated with GitHub"
        echo "🔑 Run: gh auth login"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo "❌ jq not available"
        echo "📦 Install with: pkg install jq"
        exit 1
    fi
    
    # Check if monitoring scripts exist
    if [ ! -f "./auto_monitor.sh" ]; then
        echo "❌ auto_monitor.sh not found"
        exit 1
    fi
    
    if [ ! -f "./completion_hook.sh" ]; then
        echo "❌ completion_hook.sh not found"
        exit 1
    fi
    
    echo "✅ All dependencies and scripts available"
    echo ""
    
    # Step 1: Wait for or find active build
    if ! wait_for_build_start; then
        echo ""
        echo "💡 To start a new build:"
        echo "   1. Make code changes"
        echo "   2. git add -A && git commit -m 'your changes'"
        echo "   3. git push origin main"
        echo "   4. ./watch_build.sh"
        exit 1
    fi
    
    # Step 2: Run auto monitor with progress hooks
    run_auto_monitor
    monitor_exit_code=$?
    
    # Step 3: Run completion hook for final verification
    if [ $monitor_exit_code -eq 0 ]; then
        run_completion_hook
        completion_exit_code=$?
        
        if [ $completion_exit_code -eq 0 ]; then
            echo ""
            echo "🎉 SUCCESS! Build completed and verified!"
            show_final_options
            exit 0
        else
            echo ""
            echo "⚠️  Build completed but verification had issues"
            show_final_options
            exit 1
        fi
    else
        echo ""
        echo "❌ Build monitoring detected issues"
        echo "🔧 Check the logs and GitHub Actions for details"
        echo "🔗 https://github.com/$REPO/actions"
        exit 1
    fi
}

# Handle script interruption
cleanup() {
    echo ""
    echo "🛑 Watch build interrupted by user"
    echo "💡 You can resume monitoring with: ./watch_build.sh"
    exit 0
}

trap cleanup INT TERM

# Run main function
main "$@"