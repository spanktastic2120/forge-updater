This is a shell script to update Forge to the latest version on the branch of your choice. 
The project this is forked from stopped working when Forge switch from their own website to GitHub for releases, so I made this version to use the gh CLI tool.

To use this script you must first install and autheticate gh, for help with that see: https://cli.github.com/manual/gh_auth_login
Then just copy the script and set the 3 variables at the top of the file: downloadPath, extractPath, and updateBranch

Every time the script is run it will check the current version against your installed version on the branch you specified, and if the current version is newer it will automatically download and install it as well as remove old versions and temporary files. As such, you can run this script on a schedule or set it as a pre-launch script in Lutris to always stay up to date. 
