#!/bin/bash
# Make log file
RunningFolder=$(pwd)
if [[ ! -d "RunningFolder/logs" ]]; then

        mkdir "$RunningFolder/logs/"

fi

RunningDate=$(date "+%Y.%m.%d-%H:%M")
LogFile=$(echo "logs/$RunningDate")

# Check mail.conf and set curl's mailing settings accordingly
echo "Setting up Mailing configs" >> $LogFile

mkdir /tmp/PUCA/
UpdAte="There is an update for :"
MailFrom=$( cat config/mail.conf | grep MailFrom | cut -d \" -f 2)
MailTo=$( cat config/mail.conf | grep MailTo | cut -d \" -f 2)
MailServ=$( cat config/mail.conf | grep MailServ | cut -d \" -f 2)
MailPort=$( cat config/mail.conf | grep MailPort | cut -d \" -f 2)
PackageListPath=$( cat config/mail.conf | grep ListPath | cut -d \" -f 2)

isUnsecure=$( cat config/mail.conf | grep UnsecureMail | cut -d \" -f 2)

if [ "${isUnsecure}" = "yes" ] ; then

	echo -e "\033[38;5;9mMail server connexion is set to unsecure. No SSL/TLS encryption will be done\nThis is highly unrecommended\033[0m" >> $LogFile
        MailProtocol="smtp"
	MailProtocolReq=""

elif [ "${isUnsecure}" = "no" ] ; then

	echo "Mail server connexion will use SSL/TLS encryption" >> $LogFile
	MailProtocol="smtps"
	MailProtocolReq="--ssl-reqd"

# Misconfig error
else

	echo -e "\033[38;5;9mError MisSec : UnsecureMail is misconfigured or not set.\nSSL/TLS encryption will then be used as default\033[0m" >> $LogFile
	MailProtocol="smtps"
	MailProtocolReq="--ssl-reqd"

fi


# Check pass.conf and set the password accordingly
AskMailPass=$( cat config/pass.conf | grep "askmailpass=" | cut -d \" -f 2)

if [ "${AskMailPass}" = "yes" ] ; then

        echo "What's the email password ?" >> $LogFile
        echo "What's the email password ?"
        read MailPass

elif [ "${AskMailPass}" = "no" ] ; then

	echo -e "\033[38;5;9mThe password of the sender's email will taken from the config\nThis is highly unrecommended as it's unsecure\033[0m" >> $LogFile
	MailPass=$( cat config/pass.conf | grep "mailpass=" | cut -d \" -f 2 | tail -1 )

elif  [ "${AskMailPass}" = "file" ] ; then

	echo "Fetching password" >> $LogFile
	PassPath=$( cat config/pass.conf | grep "mailpassfile=" | cut -d \" -f 2)

	if test -f $PassPath ; then
		echo "File exists" >> $LogFile
		MailPass=$( cat $PassPath )

	else

		echo -e "\033[38;5;9mError MisFilePass : The file doesn't exist.\nThe password will be set to 'NONE'\033[0m" >> $LogFile
		MailPass="NONE"

	fi

else

        echo -e "\033[38;5;9mError MisAskPass : pass.conf is misconfigured.\nThe password will be set to 'NONE'\033[0m" >> $LogFile
	MailPass="NONE"

fi


# Check if updater is active and fetch it's configs $**$

# Need to implement updater


# Set package list conf
echo "Setting package list" >> $LogFile
PackageList=''
PackageCounter=0
declare -A PackageArrays


# Might add an error handler function to replace every exiting errors in the future $**$
if [[ ! -d "$PackageListPath" ]]; then

	echo -e "\033[38;5;9mError MisListPath : The package list folder doesn't exist." >> $LogFile
	echo -e "The script will exit in 5 min or when a key is pressed." >> $LogFile
	echo -e "Exiting with error MisListPath...\033[0m" >> $LogFile
	echo -e "\033[38;5;9mError MisListPath : The package list folder doesn't exist."
	read -t 300 -p "The script will exit in 5 min or when a key is pressed."
	echo -e "Exiting with error MisListPath...\033[0m"
	exit 1

elif [[ -z "$(ls -A "$PackageListPath" 2>/dev/null)" ]]; then

        echo -e "\033[38;5;9mError MisListFiles : The package list folder is empty." >> $LogFile
        read -t 300 -p "The script will exit in 5 min or when a key is pressed." >> $LogFile
        echo -e "Exiting with error MisListFiles...\033[0m" >> $LogFile
        echo -e "\033[38;5;9mError MisListFiles : The package list folder is empty."
        read -t 300 -p "The script will exit in 5 min or when a key is pressed."
        echo -e "Exiting with error MisListFiles...\033[0m"
        exit 1

fi


# Fetch package info
PackageFilesArray=("$PackageListPath"*)
for JsonFiles in "$PackageListPath"* ; do

	JsonKeys=($(jq -r '.package | keys[]' "$JsonFiles"))
	for JsonKey in "${JsonKeys[@]}"; do
		ValueOfKey=$(jq -r ".package.$JsonKey" "$JsonFiles")
		PackageArrays["$PackageCounter:$JsonKey"]="$ValueOfKey"
	done

	PackageCounter=$((PackageCounter + 1))

done


echo "Total packages processed : "$((PackageCounter)) >> $LogFile


# Fetch latest release and compare it
echo "Fetch latest release and compare it" >> $LogFile
CurlIteration=0
PackageLink=""
PackageVersionSearch=""
PackageCurrentVersion=""
PackageMessage=""
FetchedLatest=""

while [ $CurlIteration != $PackageCounter ] ; do

	PackageLink="${PackageArrays["$CurlIteration:link"]}"
	PackageVersionSearch="${PackageArrays["$CurlIteration:search"]}"
	PackageCurrentVersion="${PackageArrays["$CurlIteration:currentversion"]}"
	PackageMessage="${PackageArrays["$CurlIteration:message"]}"
	FetchedLatest=$(curl -s "$PackageLink" | eval "$PackageVersionSearch")

	# Compare
	if [ "$FetchedLatest" != "$PackageCurrentVersion" ]; then
		echo "Update detected for package : $PackageMessage" >> $LogFile
		echo "Current : $PackageCurrentVersion ; Latest : $FetchedLatest" >> $LogFile

		UpdAte=$UpdAte"\nNew version found for "${PackageMessage}" : "${PackageCurrentVersion}" -> "${FetchedLatest}
		PackageArrays["$CurlIteration:FetchedCurrentVersion"]="$FetchedLatest"
		PackageCurrentFilePath="${PackageFilesArray[$CurlIteration]}"
		jq ".package.currentversion = \"$FetchedLatest\"" "$PackageCurrentFilePath" > /tmp/PUCA/tmp.$$.json && mv /tmp/PUCA/tmp.$$.json "$PackageCurrentFilePath"
		echo $PackageCurrentFilePath >> $LogFile

	fi

	CurlIteration=$((CurlIteration + 1))
	# Buffer for Github's API
	read -t 2

done


# Check if there was an update and send the email if there was

if [ "${UpdAte}" != "There is an update for :" ] ; then

	# Need to implement the updater

	curl --url $MailProtocol'://'$MailServ':'$MailPort $MailProtocolReq --mail-from $MailFrom --mail-rcpt $MailTo --user $MailFrom':'$MailPass -T <(echo -e 'From:'$MailFrom'\nTo:'$MailTo'\nSubject:PUCA - Package Update Checker Alert\n\n'$UpdAte)
	echo "List of package to update sent :" >> $LogFile
	echo -e $UpdAte >> $LogFile

else

	echo "No updates, nothing was sent" >> $LogFile

fi

# Clean tmp folder
rm -rf /tmp/PUCA/

echo "Done." >> $LogFile

exit 0
