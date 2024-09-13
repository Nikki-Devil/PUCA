# PUCA
Package Update Checker Alert

This needs to be updated
Currently, PUCA is a work in progress project to simplify update checking
It's used to check a configurable list of packages and send an email via Curl request on an SMPT server when seeing a difference between last check and the current one


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
