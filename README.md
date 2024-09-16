# PUCA
Do you, like me, check regularly (or not) if your favorite app/package or even OS has an update ?
Does it takes too much time and you forget to check for some update ?
PUCA is there for you !

Package Update Checker Alert, or PUCA for short, is a bash script that's configurable
It uses jq, curl and an SMTP server to function properly and should be able to run on any Linux out there if it has internet access and these two packages installed

## How it works
It works by taking the configuration of the SMTP mail and it's password, fetching info on a package/app/os that's inside a json file (one file for one thing to check), comparing the latest version fetched locally against the latest version online using curl
After everything is compared, it saves the new latest inside the json and send a curl request on the SMTP server with the informations to send an email

## How to use it
First of all, you will need to install "curl" and "jq" :
````bash
sudo apt update && sudo apt install curl jq -y
```

You will then need to download the latest release of PUCA, or clone the repo, on your machine
After doing this, copy or move `config/mail.conf.example` as `config/mail.conf` and `config/pass.conf.example` as `config/pass.conf`
Add the email settings to `config/mail.conf` and configure your way of giving the script the email password to `config/pass.conf`

Then add the json of each package inside the configured folder (by default : `package-list/`)


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
