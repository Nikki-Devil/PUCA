#!/bin/bash
MailFrom=""
MailTo=""
MailServ=""
MailPass=""
MailPort=""

echo "Checking latest VS current version"
UpdAte="There is an update for :"

# Tailscale
LatestTail=$(curl https://api.github.com/repos/tailscale/tailscale/releases/latest -s | grep 'tag_name' | awk '{print substr($2, 2, length($2)-3) }')
CurrentTail=$(cat package-version/tailscale-v)

# Tailscale OPNsense
LatestTailOPN=$(curl https://raw.githubusercontent.com/opnsense/ports/master/security/tailscale/distinfo -s | grep 'SIZE' | grep '.zip' | awk '{print substr($2, 34, length($2)-38) }')
CurrentTailOPN=$(cat package-version/tailscaleOPN-v)

# Tailscale Android
LatestTailAnd='v'$(curl https://raw.githubusercontent.com/tailscale/tailscale-android/main/android/build.gradle -s | grep 'versionName' | awk '{print substr($2, 2, length($2)-28) }')'*'
CurrentTailAnd=$(cat package-version/tailscaleAnd-v)

# Tailscale PfSense
LatestTailPF=$(curl https://raw.githubusercontent.com/freebsd/freebsd-ports/master/security/tailscale/distinfo -s | grep 'SIZE' | grep '.zip' | awk '{print substr($2, 34, length($2)-38) }')
CurrentTailPF=$(cat package-version/tailscalePF-v)

# Mailcow
LatestMailcow=$(curl https://api.github.com/repos/mailcow/mailcow-dockerized/releases/latest -s | grep 'tag_name' | awk '{print substr($2, 2, length($2)-3) }')
CurrentMailcow=$(cat package-version/mailcow-v)

# Crafty Controller
LatestCrafty=$(curl -s https://gitlab.com/api/v4/projects/20430749/releases/ | jq '.[]' | jq -r '.name' | head -1 | awk '{print substr($2, 1) }')
CurrentCrafty=$(cat package-version/crafty-v)

echo "Fetched latest versions"

if [ "${CurrentTail}" != "${LatestTail}" ] ; then

	echo "There is an update for Tailscale"
	UpdAte=$UpdAte"\nTailscale : "${CurrentTail}" -> "${LatestTail}

	echo $LatestTail > tailscale-v

fi

if [ "${CurrentTailOPN}" != "${LatestTailOPN}" ] ; then

	echo "There is an update for OPNsense's Tailscale"
	UpdAte=$UpdAte"\nOPNsense's Tailscale : "${CurrentTailOPN}" -> "${LatestTailOPN}


	echo $LatestTailOPN > tailscaleOPN-v

fi

if [ "${CurrentTailAnd}" != "${LatestTailAnd}" ] ; then

	echo "There is an update for Android's Tailscale"
	UpdAte=$UpdAte"\nAndroid's Tailscale : "${CurrentTailAnd}" -> "${LatestTailAnd}


	echo $LatestTailAnd > tailscaleAnd-v

fi

if [ "${CurrentTailPF}" != "${LatestTailPF}" ] ; then

	echo "There is an update for PfSense's Tailscale"
	UpdAte=$UpdAte"\nPfSense's Tailscale : "${CurrentTailPF}" -> "${LatestTailPF}


	echo $LatestTailPF > tailscalePF-v

fi

if [ "${CurrentMailcow}" != "${LatestMailcow}" ] ; then

	echo "There is an update for Mailcow"
	UpdAte=$UpdAte"\nMailcow : "${CurrentMailcow}" -> "${LatestMailcow}


	echo $LatestMailcow > mailcow-v

fi

if [ "${CurrentCrafty}" != "${LatestCrafty}" ] ; then

	echo "There is an update for Crafty Controller"
	UpdAte=$UpdAte"\nCrafty Controller : "${CurrentCrafty}" -> "${LatestCrafty}


	echo $LatestCrafty > crafty-v

fi

if [ "${UpdAte}" != "There is an update for :" ] ; then

	curl --url 'smtps://'$MailServ':'$MailPort --ssl-reqd --mail-from $MailFrom --mail-rcpt $MailTo --user $MailFrom':'$MailPass -T <(echo -e 'From:'$MailFrom'\nTo:'$MailTo'\nSubject:PUCA - Package Update Checker Alert\n\n'$UpdAte)
	echo "List of package to update sent :"
	echo -e $UpdAte

else

	echo "No updates, nothing was sent"

fi
