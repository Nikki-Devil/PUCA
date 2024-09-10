# PUCA
Package Update Checker Alert

This needs to be updated
Currently, PUCA is a work in progress project to simplify update checking
This is supposed to check a configurable list of packages and send an email via Curl request and SMPT when seeing a difference between last check and the current one
The First Alpha is working but isn't readible and not really usable outside the scope it was tested on

Current Alpha isn't working as a rewrite of the Curl command was done and all the settings are being migrating to config files



## Planned features :
- Config fetching
- Mail settings fetched from config file
	- Ask mail password / file or config mail password fetching
- Iterator instead of separated if for package list

## Planned for later :
- Auto-Updater
	- Self-application (apt)
	- SSH Linux support (apt)
        	- SSH config fetcher
	        	- SSH Key fetching
			- Package/server config fetching
	- Support for different linux package manager ? (snap, flatpak)
	- SSH Windows support ? (winget, chocolatey)
	- Support for FreeBSD based OS (pkg)
- Default package config file list
