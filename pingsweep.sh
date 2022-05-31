# #!/bin/bash is a hard-coded function that tells the Linux operating system to use 
# bash as a command interpreter. 
#
#!/bin/bash
# If the user input “$1” is empty “” then print “Type the IP address to scan. E.g., 
# ./pingsweep.sh 192.168.2” else, bypass the conditional statement above and execute 
# the script.
if [ “$1” == “” ]
then
echo “Type the IP address to scan.”
echo “Example: ./pingsweep.sh 192.168.2”
else
#  For every IP in sequence starting from 1 to 254, 
#  do a count one ping where the network address is the user input $1 
#  [the first three octets of the network in this case and defined when running the script], 
#  and the .$ip is the ‘seq 1 254’. List only the lines containing the “64 bytes” pattern. 
for ip in `seq 1 254` ; do
ping -c 1 $1.$ip | grep "64 bytes" | cut -d " " -f 4 | tr -d “:” &
done
fi
