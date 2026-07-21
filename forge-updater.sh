#!/bin/bash

# Set paths and desired branch
downloadPath="" # temporary location to hold the downloaded files, ex: '/tmp/forge'
extractPath="" # location of installed files, ex: '/home/[user]/.forge'
updateBranch="" # choose either 'daily' or 'stable' branch to update to


# Error if not configured
if ! [[ -n "$downloadPath" && -n "$extractPath" && -n "$updateBranch" ]]; then
    echo "Error: One or more of the variables are empty!"
    exit 1
fi

# Get the current version number from the local file
currentVersion=""
if [ -f "$extractPath/version.txt" ]; then
    currentVersion=$(cat "$extractPath/version.txt")
fi

# Get the lastest snapshot and stable versions
# Results saved as environment variables SNAPSHOT_VER and STABLE_VER
eval "$(gh api repos/Card-Forge/forge/releases | tee >(grep -Po '"name":"forge-installer-\K[0-9.]+-SNAPSHOT-[0-9.]+(?=\.jar")' | head -n 1 | awk '{print "SNAPSHOT_VER=" $0}') >(grep -Po '"tag_name":"\Kforge-[0-9.]+' | head -n 1 | awk '{print "STABLE_VER=" $0}') > /dev/null)"

# Check if wanted version is stable or snapshot and use corresponding web version
if [[ "$updateBranch" == "daily" ]]; then
    webVersion=$SNAPSHOT_VER
else
    webVersion=$STABLE_VER
fi

echo "web version: $webVersion"
echo "local version: $currentVersion"

# Compare versions
if [ "$webVersion" \> "$currentVersion" ]; then
    
    echo "New version available."
    echo "Downloading..."

    # Download the new version
    if [[ "$updateBranch" == "daily" ]]; then
        gh release download daily-snapshots -R Card-Forge/forge --dir $downloadPath
    else
        gh release download $webVersion -R Card-Forge/forge --dir $downloadPath
    fi

    echo "Extracting..."

    # Extract the downloaded file
    tar -xjf "$downloadPath/forge-installer-$webVersion.tar.bz2" -C "$extractPath" --overwrite
    
    # Copy the new version file
    cp "$downloadPath/version.txt" "$extractPath/version.txt"

    echo "New version '$webVersion' installed."
    
    # Delete old files
    find "$extractPath" -type f -name "forge-gui*.jar" ! -name "*${webVersion%%-*}*" -delete

    # Delete temp dir
    rm -r "$downloadPath"
    
    echo "Old and temporary files deleted."

else
    echo "No new version available."
fi

exit 0
