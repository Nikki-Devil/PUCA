#!/bin/bash
# Check mail.conf and set curl's mailing settings accordingly
echo "Setting up Mailing configs"

UpdAte="There is an update for :"
MailFrom=$( cat config/mail.conf | grep MailFrom | cut -d \" -f 2)
MailTo=$( cat config/mail.conf | grep MailTo | cut -d \" -f 2)
MailServ=$( cat config/mail.conf | grep MailServ | cut -d \" -f 2)
MailPort=$( cat config/mail.conf | grep MailPort | cut -d \" -f 2)

isUnsecure=$( cat config/mail.conf | grep UnsecureMail | cut -d \" -f 2)

if [ "${isUnsecure}" = "yes" ] ; then

        echo "This is highly unrecommended"
        UpdAte=$UpdAte"\nTailscale : "${CurrentTail}" -> "${LatestTail}

        echo $LatestTail > tailscale-v

fi

MailProtocol="smtps"
MailProtocolReq="--ssl-reqd"

# Check pass.conf and set the password accordingly
MailPass=


# Check if updater is active and fetch it's configs

# Need to implement updater


# Fetch package list
echo "Setting package list"
PackageList=
PackageLink=
PackageCurlEnd=
PackageMessage=
PackageCurrentVersion=


# Fetch latest releases
echo "Fetch latest releases"


# Error catch

# Misconfigurations


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


# Check if there is updates then set the new version locally if there is
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


# Check if there was an update and send the email if there was

if [ "${UpdAte}" != "There is an update for :" ] ; then

	# Need to implement the updater

	curl --url $MailProtocol'://'$MailServ':'$MailPort $MailProtocolReq --mail-from $MailFrom --mail-rcpt $MailTo --user $MailFrom':'$MailPass -T <(echo -e 'From:'$MailFrom'\nTo:'$MailTo'\nSubject:PUCA - Package Update Checker Alert\n\n'$UpdAte)
	echo "List of package to update sent :"
	echo -e $UpdAte

else

	echo "No updates, nothing was sent"

fi
