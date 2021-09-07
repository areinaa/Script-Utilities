#!/bin/bash
clear
pwd=`pwd`
hour=$(date +%H:%M)
date=$(date +%d-%m-%y)

# $1 memory, $2 mail

if [ ! -d saves ]
then
mkdir saves
fi


if [ "$1" = "AUTO1" ] && [ ! -z "$2" ]
then
	echo "Content:" >> list.txt
	find saves -maxdepth 2 >> list.txt
	tar -cf $pwd/saves'_'$date'_'$hour $pwd/saves
	echo "$date, $hour: Directory sent to $2 automatically." >> log.txt
	echo "Saves directory from $date $hour ." | mail -s "Automatic Backup" -a saves'_'$date'_'$hour -a list.txt -a log.txt $2
	rm saves'_'$date'_'$hour
	rm list.txt

	exit
fi

if [ "$1" = "AUTO1" ] && [ -z "$2" ] 
then
	echo " "
	echo "No email detected, one is needed as argument 2"
	echo " "

	exit
fi


if [ "$1" = "AUTO2" ]
then
	find saves -ctime +10 -exec rm -rf {} \;
	echo "$date, $hour: Files older than 10 days deleted automatically." >> log.txt

	exit
fi

echo " "
echo "--------Script Backups--------"
echo " "
echo "-Backups already made:"
find saves -maxdepth 1
echo "------------------------------"
echo "-list current directory:"
ls -d */ | awk '{ print $NF }'
echo "-------------------------------"
echo " "

echo "What directory do you want to back up?"
read path

while [ ! -d  $path ]
	do
	echo "Directory not found, try again."
	echo " "
	echo "What directory do you want to back up?"
	read $path
done


if [ -d  $path ]
then
echo "Directory  $path/  found."
echo " "
echo "Listing directory in MB..."
du -hca --max-depth=2 --block-size=M $path | awk 'NR<=25'
echo "------------------------------------"
echo "Do you want to look up for a keyword? (WORD/N)"
read word

if [ $word = N ]
then
	echo ""	
else
	echo "-Found results:"
	grep -i -R -c $word $path
	echo "---------------------"
	echo "Show matching text?(Y/N)"
	read mostrar

	if [ $mostrar != Y ]
	then
		echo ""
	else
		echo "Showing text..."
		grep --color=always -i -R $word $path
		echo "-----------------------------------------------------------------"
		echo " "

	fi

fi

if [ -z "$1" ]
then
	echo "tar directory? (Y/N)"
	read compr
else

	arg1="$1"

	# check the current size
	check=`du -hs $path`
	check=${check%K*}
	echo "Directory size is  $check K"

	if (( $(echo "$check > $arg1" |bc -l) ))
 	then
        	echo "Directory size is higher than $arg1 K. Forcing compression"
		compr=S
		echo " "
	else
		echo "Tar directory? (Y/N)"
	        read compr

	fi

fi

backupdir="saves/$path"

if [ $compr = S ]
then #Compress
	if [ -e $backupdir'_'$date'_'$hour ]
	then
		echo "A backup of this directory already exists. Replace it with a new one or create an additional one?(S/N)"
		read comprsust
		if [ $comprsust = S ]
		then
			echo "Replacing backup..."
			rm $backupdir'_'$date'_'$hour
                        rm -r $backupdir'_'$date'_'$hour/*
			rmdir $backupdir'_'$date'_'$hour			
			tar -cvf $pwd/saves/$path'_'$date'_'$hour $pwd/$path

			echo "$date, $hour: /$path backup compressed. The previous one has been replaced." >> log.txt

		else
			echo "Creating an additional backup..."
			tar -cvf $pwd/saves/$path'_'$date'_'$hour'2' $pwd/$path
			echo "$date, $hour: Additional backup of /$path compressed." >> log.txt

		fi
	
	else
		echo  "Creating backup"
		tar -cvf $pwd/saves/$path'_'$date'_'$hour $pwd/$path
		echo "$date, $hour: Backup of /$path created and compressed" >> log.txt

	fi
	echo "Backup created. An email has been sent. Write CONT to skip this step."

	#SEND EMAIL
	echo "Introduce an email "
	read correo
	if [ $correo = "CONT" ]
	then
		echo "Email not sent"
	else
		echo "Directory content: " >> list.txt
		find $path -maxdepth 7 >> list.txt
		echo "A backup of /$path was created at $hour of $date. File attached to this email." | mail -s "Security backup" -a $backupdir'_'$date'_'$hour -a list.txt $correo
		rm list.txt
		echo "EMAIL SENT."
		echo "----------------"
		echo " "
	fi

else #NO COMPRESSION
        if [ -e $backupdir'_'$date'_'$hour ]
        then
                echo "A backup of this directory already exists. Replace it with a new one or create an additional one?(S/N)"
                read nocsust
                if [ $nocsust = S ]
                then
                        echo "Replacing backup."
						rm $backupdir'_'$date'_'$hour
                        rm -r $backupdir'_'$date'_'$hour/*
						cp -R $path/* $backupdir'_'$date'_'$hour
						echo "$date, $hour: Copia de /$path sin comprimir. La anterior ha sido sustituida." >> log.txt

                else
                        echo "Creating an additional backup..."
						mkdir $backupdir'_'$date'_'$hour'2'
						cp -R $path/* $backupdir'_'$date'_'$hour'2'
						echo "$date, $hour: Additional backup of /$path created." >> log.txt

                fi

        else
                echo "Creating an additional backup..."
				mkdir $backupdir'_'$date'_'$hour
				cp -R $path/* $backupdir'_'$date'_'$hour
				echo "$date, $hour: Backup of /$path created." >> log.txt

        fi
	echo "Backup completed"
	echo " "

fi	
else
	echo "Directory not found, try again."
	echo " "
fi

echo " "
echo "------------------"
echo "END"
