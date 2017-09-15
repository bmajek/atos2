#!/bin/bash
#
# Scripts collects information about all databases on servers given in servers.txt file
#
# #databases_inventory.sh
#
#
> inventory.txt
date > inventory.txt
> inventory.csv
echo "hostname;login;object_code;" >> 'inventory.csv'

for i in $(cat servers.txt)
do
	hostname_s=`echo -e "\n## Hostname: $i"`
	echo "$hostname_s"
	csv_line="$i"

	test_s=$(test_ssh $i 2>&1)
	test_s=`echo "$test_s" | grep -i -e "granted" -e "Object Code" -e "UNKNOWN"`
	test_s=`echo -e "$test_s\e[0m"`
	object_code=`echo "$test_s" | grep "Object Code" | cut -b 61-`
	obecjt_code=`echo -e "$object_code\e[0m"`
	echo -e "$object_code\e[0m"
		echo "$test_s"
		echo "$test_s" >> inventory.txt

	ssh_out=$(cat command.sh | ssh -o StrictHostKeyChecking=no -v a665004@$i 2>&1)
#	echo "$ssh_out"

	if [[ `echo $ssh_out | grep "Permission denied" | wc -l` > 0 ]] || [[ `echo $ssh_out | grep "Connection closed" | wc -l` > 0 ]] || [[ `echo $ssh_out | grep "key verification failed" | wc -l` > 0 ]]
		then

			if [[ `echo $test_s | grep "dba@" | wc -l` == 1 ]]
				then
					echo "Login using dba account..."
					ssh_out=$(cat command.sh | ssh -v -q -2 dba@$i 2>&1)
					echo "$sshdba_out"

					if [[ `echo $sshdba_out | grep "Permission denied"` > 0 ]]
						then
							echo "$hostname_s" >> inventory.txt
							csv_line="$csv_line;KO"
							echo "$sshdba_out"
							echo "$sshdba_out" >> inventory.txt
						else
							echo "$sshdba_out"
							echo "Login OK"
							csv_line="$csv_line;OK"
					fi
				else
					echo "$hostname_s" >> inventory.txt
					csv_line="$csv_line;KO"
#					echo "$ssh_out"
					echo "$ssh_out" >> inventory.txt
#					echo "$test_s"
					echo "$test_s" >> inventory.txt
			fi
		elif [[ `echo $ssh_out | grep "ssh: connect to host" | wc -l` > 0 ]] ;
			then
			echo "Timeout !!"
			csv_line="$csv_line;N/A"
		elif [[ `echo $ssh_out | grep "Exit status 0" | wc -l` > 0 ]] || [[ `echo $ssh_out | grep "Authentication succeeded" | wc -l` > 0 ]] ;
			then
			echo "Login OK"
			csv_line="$csv_line;OK"
		else
			echo "Unnknown issue"
			csv_line="$csv_line;N/A"

	fi

	if [[ `echo "$test_s" | grep -i "unknown" | grep -iv "Operating System" | wc -l` > 0 ]]	
		then
			csv_line="$csv_line;unknown;"
		else
			csv_line="$csv_line;$object_code;"
	fi

echo -e "$csv_line\e[0m" >> inventory.csv
done
echo "" >> inventory.csv

///////////////////////////////////////////////////////////////////////////////////////////////////////////////

======================================================================================

> inventory.txt
date > inventory.txt

for i in $(cat servers.txt)
do
	hostname_s=`echo -e "\n## Hostname: $i"`
	echo "$hostname_s"
	ssh_out=$(cat command.sh | ssh a665004@$i 2>&1)
	
	if [[ `echo $ssh_out | grep "Permission denied" | wc -l` == 1 ]]
		then
			
			test_s=`test_ssh $i | grep -i -e "granted" -e "Object Code" -e "UNKNOWN"`
			test_s=`echo -e "$test_s\e[0m"`

			if [[ `echo $test_s | grep "dba@" | wc -l` == 1 ]]
				then
					sshdba_out=$(cat command.sh | ssh -q -2 dba@$i 2>&1)

					if [[ `echo $sshdba_out | grep "Permission denied"` == 1 ]]
						then
							echo "$hostname_s" >> inventory.txt
							echo "$sshdba_out"
							echo "$sshdba_out" >> inventory.txt
							echo "$test_s"
							echo "$test_s" >> inventory.txt
						else
							echo "$sshdba_out"
							echo "Login OK"
					fi
				else
					echo "$hostname_s" >> inventory.txt
					echo "$ssh_out"
					echo "$ssh_out" >> inventory.txt
					echo "$test_s"
					echo "$test_s" >> inventory.txt
			fi
		else
			echo "Login OK"
	fi		
done


sudo su - mysql