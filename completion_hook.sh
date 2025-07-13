#!/bin/bash

# Completion Hook - Automatically triggers when build completes
# This script runs final checks and hands off to user with summary

REPO="GrimFandango42/travel-translator-app"
LOG_FILE="$HOME/completion_hook.log"

echo "🏁 Completion Hook Activated"
echo "==========================="

# Function to log with timestamp
log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_FILE"
}

# Function to check build final status
check_final_status() {
    local run_data=$(gh run list -R "$REPO" --limit 1 --json status,conclusion,databaseId,headBranch,headSha,createdAt,updatedAt --jq '.[0]' 2>/dev/null)
    
    if [ -z "$run_data" ] || [ "$run_data" = "null" ]; then
        log_msg "❌ Could not retrieve build data"
        return 1
    fi
    
    local run_id=$(echo "$run_data" | jq -r '.databaseId')
    local status=$(echo "$run_data" | jq -r '.status')
    local conclusion=$(echo "$run_data" | jq -r '.conclusion')
    local branch=$(echo "$run_data" | jq -r '.headBranch')
    local commit=$(echo "$run_data" | jq -r '.headSha' | head -c 7)
    local created=$(echo "$run_data" | jq -r '.createdAt')
    local updated=$(echo "$run_data" | jq -r '.updatedAt')
    
    echo ""
    log_msg "📊 FINAL BUILD STATUS"
    log_msg "===================="
    log_msg "🆔 Run ID: $run_id"
    log_msg "📊 Status: $status"
    log_msg "✅ Conclusion: $conclusion"
    log_msg "🌿 Branch: $branch"
    log_msg "🔗 Commit: $commit"
    log_msg "🕐 Created: $created"
    log_msg "🕐 Updated: $updated"
    log_msg "🔗 URL: https://github.com/$REPO/actions/runs/$run_id"
    
    if [ "$status" = "completed" ] && [ "$conclusion" = "success" ]; then
        return 0
    else
        return 1
    fi
}

# Function to verify artifacts
verify_artifacts() {
    local run_id="$1"
    
    log_msg "🔍 Verifying build artifacts..."
    
    local artifacts=$(gh run view "$run_id" -R "$REPO" --json artifacts --jq '.artifacts[] | {name: .name, size: .size_in_bytes}' 2>/dev/null)
    
    if [ -n "$artifacts" ]; then
        log_msg "📦 VERIFIED ARTIFACTS:"
        echo "$artifacts" | while read -r artifact; do
            local name=$(echo "$artifact" | jq -r '.name')
            local size=$(echo "$artifact" | jq -r '.size')
            local size_mb=$((size / 1024 / 1024))
            log_msg "   ✅ $name (${size_mb}MB)"
        done
        
        # Check for expected artifacts
        if echo "$artifacts" | grep -q "travel-translator-release-apk"; then
            log_msg "✅ Release APK verified"
        else
            log_msg "⚠️  Release APK not found"
        fi
        
        if echo "$artifacts" | grep -q "travel-translator-debug-apk"; then
            log_msg "✅ Debug APK verified"
        else
            log_msg "⚠️  Debug APK not found"
        fi
        
        return 0
    else
        log_msg "❌ No artifacts found"
        return 1
    fi
}

# Function to check release status
check_release_status() {
    log_msg "🔍 Checking release status..."
    
    local latest_release=$(gh release list -R "$REPO" --limit 1 --json tagName,name,createdAt,assets --jq '.[0]' 2>/dev/null)
    
    if [ -n "$latest_release" ] && [ "$latest_release" != "null" ]; then
        local tag=$(echo "$latest_release" | jq -r '.tagName')
        local name=$(echo "$latest_release" | jq -r '.name')
        local created=$(echo "$latest_release" | jq -r '.createdAt')
        local assets=$(echo "$latest_release" | jq -r '.assets[] | .name')
        
        log_msg "🚀 RELEASE VERIFIED:"
        log_msg "   📦 Name: $name"
        log_msg "   🏷️  Tag: $tag"
        log_msg "   🕐 Created: $created"
        log_msg "   🔗 URL: https://github.com/$REPO/releases/tag/$tag"
        
        if [ -n "$assets" ]; then
            log_msg "📱 RELEASE ASSETS:"
            echo "$assets" | while read -r asset; do
                log_msg "   📎 $asset"
            done
        fi
        
        return 0
    else
        log_msg "⚠️  No release found (may still be creating)"
        return 1
    fi
}

# Function to prepare deployment instructions
prepare_deployment() {
    local run_id="$1"
    
    log_msg "🚀 Preparing deployment instructions..."
    
    cat > "DEPLOYMENT_READY.md" << EOF
# 🎉 Travel Translator - Ready for Deployment!

## ✅ Build Completed Successfully
- **Build ID**: $run_id
- **Status**: ✅ SUCCESS
- **Time**: $(date)
- **Repository**: $REPO

## 📱 Download Options

### Option 1: Automatic Download (Recommended)
\`\`\`bash
./download_apk.sh
\`\`\`

### Option 2: Direct Phone Deployment
\`\`\`bash
./deploy_to_phone.sh
\`\`\`

### Option 3: Manual Download
- Visit: https://github.com/$REPO/actions/runs/$run_id
- Download "travel-translator-release-apk" artifact
- Extract ZIP file to get APK

## 🔗 Quick Links
- **GitHub Actions**: https://github.com/$REPO/actions
- **Latest Release**: https://github.com/$REPO/releases/latest
- **Repository**: https://github.com/$REPO

## 📱 Installation on Pixel Phone
1. Copy APK to your phone
2. Settings → Security → "Install unknown apps" → Enable
3. Tap APK file to install
4. Grant camera and microphone permissions
5. Start translating Japanese! 🇯🇵

## 🎯 Perfect for Japan Travel!
Your on-device Japanese to English translator is ready!
EOF
    
    log_msg "📄 Created DEPLOYMENT_READY.md"
}

# Function to send completion notification
send_completion_notification() {
    local success="$1"
    local run_id="$2"
    
    if command -v termux-notification &> /dev/null; then
        if [ "$success" = "true" ]; then
            termux-notification \
                --title "🎉 BUILD COMPLETE!" \
                --content "Travel Translator ready for deployment. Check terminal for details." \
                --priority high \
                --sound \
                --button1 "Deploy Now" \
                --button1-action "./deploy_to_phone.sh"
        else
            termux-notification \
                --title "❌ Build Issues" \
                --content "Check terminal for build status details" \
                --priority high
        fi
        
        log_msg "🔔 Completion notification sent"
    fi
}

# Function to create final summary
create_final_summary() {
    local success="$1"
    local run_id="$2"
    
    echo ""
    echo "════════════════════════════════════════"
    echo "🏁 COMPLETION HOOK SUMMARY"
    echo "════════════════════════════════════════"
    
    if [ "$success" = "true" ]; then
        echo "✅ BUILD STATUS: SUCCESS"
        echo "📦 BUILD ID: $run_id"
        echo "🚀 READY FOR DEPLOYMENT"
        echo ""
        echo "🎯 NEXT STEPS:"
        echo "   1. Run: ./deploy_to_phone.sh (for direct phone install)"
        echo "   2. Or: ./download_apk.sh (to download first)"
        echo "   3. Or: Check DEPLOYMENT_READY.md for all options"
        echo ""
        echo "📱 Your Travel Translator app is ready for Japan! 🇯🇵"
    else
        echo "❌ BUILD STATUS: ISSUES DETECTED"
        echo "🔧 CHECK REQUIRED"
        echo ""
        echo "🎯 TROUBLESHOOTING:"
        echo "   1. Check: https://github.com/$REPO/actions"
        echo "   2. Review build logs for errors"
        echo "   3. Fix issues and push again"
        echo "   4. Run: ./auto_monitor.sh to track next build"
    fi
    
    echo ""
    echo "📋 LOGS:"
    echo "   - Completion hook: $LOG_FILE"
    echo "   - Auto monitor: $HOME/auto_monitor.log"
    echo "   - Build monitor: $HOME/build_monitor.log"
    echo ""
    echo "🔗 REPOSITORY: https://github.com/$REPO"
    echo "════════════════════════════════════════"
}

# Main execution
main() {
    log_msg "🏁 Completion hook started"
    
    # Check if build completed successfully
    if check_final_status; then
        local run_id=$(gh run list -R "$REPO" --limit 1 --json databaseId --jq '.[0].databaseId')
        
        # Verify artifacts
        if verify_artifacts "$run_id"; then
            log_msg "✅ Artifacts verification passed"
        else
            log_msg "⚠️  Artifacts verification had issues"
        fi
        
        # Check release status
        if check_release_status; then
            log_msg "✅ Release verification passed"
        else
            log_msg "⚠️  Release verification had issues (may still be processing)"
        fi
        
        # Prepare deployment
        prepare_deployment "$run_id"
        
        # Send notification
        send_completion_notification "true" "$run_id"
        
        # Create summary
        create_final_summary "true" "$run_id"
        
        log_msg "✅ Completion hook finished successfully"
        exit 0
    else
        log_msg "❌ Build verification failed"
        
        # Send failure notification
        send_completion_notification "false" "unknown"
        
        # Create summary
        create_final_summary "false" "unknown"
        
        log_msg "❌ Completion hook finished with issues"
        exit 1
    fi
}

# Hook setup
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI not available"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ jq not available"
    exit 1
fi

# Run main function
main "$@"