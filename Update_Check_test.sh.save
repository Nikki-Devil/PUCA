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

	echo -e "\033[38;5;9mMail server connexion is set to unsecure. No SSL/TLS encryption will be done\nThis is highly unrecommended\033[0m"
        MailProtocol="smtp"
	MailProtocolReq=""

elif [ "${isUnsecure}" = "no" ] ; then

	echo "Mail server connexion will use SSL/TLS encryption"
	MailProtocol="smtps"
	MailProtocolReq="--ssl-reqd"

# Misconfig error
else

	echo -e "\033[38;5;9mError MisSec : UnsecureMail is misconfigured or not set.\nSSL/TLS encryption will then be used as default\033[0m"
	MailProtocol="smtps"
	MailProtocolReq="--ssl-reqd"

fi


# Check pass.conf and set the password accordingly
AskMailPass=$( cat config/pass.conf | grep "askmailpass=" | cut -d \" -f 2)

if [ "${AskMailPass}" = "yes" ] ; then

        echo "What's the email password ?"
        read MailPass

elif [ "${AskMailPass}" = "no" ] ; then

	echo -e "\033[38;5;9mThe password of the sender's email will taken from the config\nThis is highly unrecommended as it's unsecure\033[0m"
	MailPass=$( cat config/pass.conf | grep "mailpass=" | cut -d \" -f 2 | tail -1 )

elif  [ "${AskMailPass}" = "file" ] ; then

	echo "Fetching password"
	PassPath=$( cat config/pass.conf | grep "mailpassfile=" | cut -d \" -f 2)

	if test -f $PassPath ; then
		echo "File exists"
		MailPass=$( cat $PassPath )

	else

		echo -e "\033[38;5;9mError MisFilePass : The file doesn't exist.\nThe password will be set to 'NONE'\033[0m"
		MailPass="NONE"

	fi

# Misconfig error
else

        echo -e "\033[38;5;9mError MisAskPass : pass.conf is misconfigured.\nThe password will be set to 'NONE'\033[0m"
	MailPass="NONE"

fi


# Check if updater is active and fetch it's configs

# Need to implement updater


# Fetch package list
echo "Setting package list :"
PackageList=''
PackageCounter=0
for files in package-list/* ;

	do echo $files ;
#	PackageList=$(echo -e $files"\n"$PackageList)

	typeset -A PackageArray
	while IFS== read -r key value ;
		do PackageArray["$key"]="$value"
		PackageArray["filename"]="$files"
	done < <(jq -r '.package | to_entries | .[] | .key + "=" + .value ' $files)
	typeset -p PackageArray
	echo -e "PackageLink = '${PackageArray[link]}'\n'$PackageLink'"
	echo -e "PackageCurlEnd = '${PackageArray[curlend]}'\n'$PackageCurlEnd'"
	echo -e "PackageMessage = '${PackageArray[message]}'\n'$PackageMessage'"
	echo -e "PackageCurrentVersion = '${PackageArray[currentversion]}'\n'$PackageCurrentVersion"
	echo -e "PackageFileSave = '$files'\n'$PackageFileSave'"

	PackageCounter=$((PackageCounter + 1))

done

#PackageLink=''
#PackageCurlEnd=''
#PackageMessage=''
#PackageCurrentVersion=''
#for filenumber in $PackageCounter ;

#	PackageBreakdown=$(echo $(cat -e $PackageList))
#	PackageLink=$(echo -e $(cat -e $PackageBreakdown)"\n"$PackageLink)

#done

echo $PackageLink

# Fetch latest releases
echo "Fetch latest releases"


# Error catch
# Misconfigurations

exit


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
