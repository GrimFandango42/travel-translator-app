#!/bin/bash

# GitHub Actions Build Monitor
# Automatically monitors builds and reports success/failure

REPO="GrimFandango42/travel-translator-app"
CHECK_INTERVAL=30  # seconds
MAX_CHECKS=20      # maximum number of checks (10 minutes total)

echo "🔍 Monitoring GitHub Actions builds for $REPO"
echo "📊 Checking every $CHECK_INTERVAL seconds for up to $((MAX_CHECKS * CHECK_INTERVAL / 60)) minutes"
echo "🎯 Looking for successful APK builds..."
echo ""

for ((i=1; i<=MAX_CHECKS; i++)); do
    echo "[$i/$MAX_CHECKS] Checking build status..."
    
    # Get latest build status
    BUILD_STATUS=$(gh run list -R $REPO --limit 1 --json status,conclusion,headBranch --jq '.[0]')
    STATUS=$(echo $BUILD_STATUS | jq -r '.status')
    CONCLUSION=$(echo $BUILD_STATUS | jq -r '.conclusion')
    BRANCH=$(echo $BUILD_STATUS | jq -r '.headBranch')
    
    if [ "$STATUS" = "completed" ]; then
        if [ "$CONCLUSION" = "success" ]; then
            echo "🎉 SUCCESS! Build completed successfully!"
            
            # Get build details
            RUN_ID=$(gh run list -R $REPO --limit 1 --json databaseId --jq '.[0].databaseId')
            
            echo ""
            echo "✅ APK Build Details:"
            echo "   📦 Artifacts available for download"
            echo "   🔗 Direct link: https://github.com/$REPO/actions/runs/$RUN_ID"
            echo "   📱 Download APK: Click 'travel-translator-apk' artifact"
            echo ""
            echo "🚀 Your Travel Translator app is ready for installation!"
            exit 0
        else
            echo "❌ Build failed with conclusion: $CONCLUSION"
            echo "🔧 Check logs at: https://github.com/$REPO/actions"
            
            # Continue monitoring in case there's a new build
        fi
    elif [ "$STATUS" = "in_progress" ]; then
        echo "⏳ Build in progress on branch: $BRANCH"
    else
        echo "🔄 Build status: $STATUS"
    fi
    
    if [ $i -lt $MAX_CHECKS ]; then
        echo "   ⏰ Next check in $CHECK_INTERVAL seconds..."
        sleep $CHECK_INTERVAL
    fi
done

echo ""
echo "⏰ Monitoring timeout reached. Check manually at:"
echo "🔗 https://github.com/$REPO/actions"