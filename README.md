# pingsweep
A ping sweep script is a basic scanning technique used to determine which hosts are alive or not within a specified IP range or network subnet.

If you are a server/network admin, cybersecurity engineer, ethical hacker, etc., knowing how to quickly code a ping sweep script will save you A LOT of time and frustration especially when all you get is a Linux terminal and no third-party network scanning tools at your disposal for troubleshooting. 

To practice along, all you need is a Linux/UNIX terminal. I will be using Kali Linux in this guide, but any other LINUX/UNIX alternative will work the same. 

How Does Ping Sweep work?
A ping sweep bash script uses [as implied] the ping utility to scan a network for hosts’ IP status in a network. To create a ping sweep bash script, we need to quickly understand how the ping utility works first – don’t worry, I won’t bore you with theory. You will learn the basics on the way.

Let’s assume we have a class C network 192.168.2/24. In this network, we can have a maximum of 254 IPs. We could start pinging each of the 254 IPs manually [the stupid way] or use a simple bash script that takes no longer than 5 minutes to code and instantly gets the IPs status of an entire network in seconds.

NOTE: Some secured hosts might block ICMP echo requests [ping] so this method worlds great when used in tandem with various NMAP flag options [in case NMAP is installed on your system]. 

I cover extensively NMAP commands, flags, various basic and advanced host scanning technics on this website. If you’re looking to master NMAP scanning techniques, start here: 10 Basic NMAP Commands And How To Use Them.

With that out of the way, let’s get our hands dirty.

STEP 1: Find Your IP Address
Start by finding the IP address of our machine first. Open a Linux/UNIX terminal and type:

ifconfig
Or

ip addr
The IP address for my host eth0 interface is 192.168.2.7, as shown in Figure 1.1 below.

![image](https://user-images.githubusercontent.com/92907451/171230359-a5b63bea-3996-47be-97c5-b45de78e0391.png)
Figure 1.1: Ping Sweep Script: ifconfig.

STEP 2: Write Ping Output To A File
Now let’s ping this IP address one time using the -c 1 count parameter and write the output to a file named ips.txt. The ips.txt file will be created automatically [Figure 1.2].

The -c 1 stands for count 1 meaning we will use 1 ICMP echo packet to ping an IP address.


ping -c 1 192.168.2.7 > ips.txt
![image](https://user-images.githubusercontent.com/92907451/171230502-33bf5ebe-99ba-47c9-9c5c-8e69ac8787db.png)
Figure 1.2: Ping Sweep Script: ping -c example.

Let’s see how the ping output is written in the ips.txt looks like using the cat command.

NOTE: the cat command is a standard UNIX utility that reads files sequentially, writing them to standard output. In other words, you can read the content of a file without opening it directly in the terminal.

cat ips.txt
![image](https://user-images.githubusercontent.com/92907451/171230628-8bbfcb40-9bdd-4f8a-9d9e-ad0ee0aa1545.png)
Figure 1.3: Ping Sweep Script: ping -c example.

As you can see above, we executed a ping 192.168.2.7 IP with a count of 1, and we got 64 bytes from 192.168.2.7: icmp_seq=1 ttl=64 time=0.018 ms reply from this 192.168.2.7. This means the host is up [reachable] and not blocking our ICMP echo requests.

But what happens if we ping an IP that is not assigned to any host in a network? Let’s have a look. 

Let’s will execute the above ping command, but this time we will target an IP that is not assigned to any host in this network. Let’s choose the 192.168.2.77 IP I know is not assigned to any host in my network and see what happens.  

ping -c 1 192.168.2.77 > ips.txt
Since there is no host assigned to this IP, the output will show Destination Host Unreachable with […] +1 errors, 100% packet loss.

![image](https://user-images.githubusercontent.com/92907451/171230728-5792796d-5ced-40e6-bcb9-e630f1b86eba.png)
Figure 1.4: Ping Sweep Script: Destination Host Unreachable.
Let’s compare the ping output between the reachable IP 192.168.2.7 and the unreachable IP 192.168.2.77 [Figure 1.5].


![image](https://user-images.githubusercontent.com/92907451/171230934-5ff403a4-2895-4c82-ad3a-24ae0923460e.png)
![image](https://user-images.githubusercontent.com/92907451/171230954-7834ad30-f247-436a-8eb3-e3e75cf5551b.png)
Figure 1.5: Ping Sweep Script: Reachable vs. unreachable hosts.
The output looks different, right? 

This is important because we will need to find a way to filter the hosts that are reachable from those that are unreachable in our script. To do that, we need to look for a string that’s unique to hosts that are reachable. We can see that the “64 bytes“ string only appears when a host is reachable. 

STEP 3: Filter The Ping Output
Let’s use the grep command to search the ips.txt file and list only the IPs with a 64 bytes string in their response. 

NOTE: grep is a UNIX utility that searches for patterns in a file and prints each line that matches that pattern. In the example below, we choose the “64 bytes” as a pattern.

cat ips.txt | grep “64 bytes”
![image](https://user-images.githubusercontent.com/92907451/171231071-55fc35d9-c51c-4d80-9262-aaf40e116fb6.png)
Figure 1.6: Ping Sweep Script: grep for “64 bytes” string.
The grep command output [Figure 1.6] lists only the host IP that matches the 64 bytes pattern in our ips.txt file.

Let’s narrow the grep output further to show only the host IP address. To do that, we can use the cut command with a space delimiter -d and a field -f of that space set to 4. 

cat ip.txt | grep “64 bytes” | cut -d “ “ -f 4
The output filters out the IP address followed by a column “:”

![image](https://user-images.githubusercontent.com/92907451/171231123-70d5fb7c-2432-48d4-8265-21cee625c3e9.png)
Figure 1.7: Ping Sweep Script: filter IPs only.
To filter out the column “:” we can use the translate tr parameter with a delimiter -d “:” as seen in the Figure 1.8 below.

cat ip.txt | grep “64 bytes” | cut -d “ “ -f 4 | tr -d “:”
![image](https://user-images.githubusercontent.com/92907451/171231148-75ce13f0-05e1-49ba-afc7-41cf0da69cc3.png)
Figure 1.8: Ping Sweep Script: remove unwanted column.
STEP 4: Create The Ping Sweep Script
To create the shell script (.sh), I will be using nano text editor. Feel free to use any other text editor available on your system. We will create/save the ping sweep script in the Desktop folder on our machine.

To navigate to your Desktop folder, type in the terminal:

cd ~/Desktop
Let’s create a new file and name it pingsweep.sh

nano pingsweep.sh
![image](https://user-images.githubusercontent.com/92907451/171231183-38356e49-5abc-482d-a814-794540f00baf.png)
Figure 1.9: Ping Sweep Script: create the pingsweep.sh.
The first thing we need to do is instruct the operating system to use the bash as a command interpreter. To do that, we will start by adding the following at the very top of our script [Figure 1.9]:

!/bin/bash
NOTE: #!/bin/bash is a hard-coded function that tells the Linux operating system to use bash as a command interpreter. 

Next, we will proceed creating a for loop:

for ip in `seq 1 10` ; do
ping -c 1 $1.$ip | grep "64 bytes" | cut -d " " -f 4 | tr -d “:” &
done
This is how we read the above loop statement: For every IP in sequence starting from 1 to 254, do a count one ping where the network address is the user input $1 [the first three octets of the network in this case and defined when running the script], and the .$ip is the ‘seq 1 254’. List only the lines containing the “64 bytes” pattern. 

Where: 

`seq 1 254` =  sequence starting from 1 to 254 [pay attention to the backticks “]

-c 1 = count 1 

$1 = user input [the first 3 octets of the network in this case]

.$ip = the sequence starting with 1 to 254

-d = delimiter

tr = translate

& = allows multithreading [ping all the IPs at once]

The rest of the command is used to filter out the unnecessary ping information and is explained in the previous section.

At shit point, your pingsweep.sh script should look like in Figure 1.10 below:

![image](https://user-images.githubusercontent.com/92907451/171231242-5efd8f7d-12cb-49fc-bc3b-a4a20d92357c.png)
Figure 1.10: Ping Sweep Script: create a For loop.
Type Ctrl+X [to exit the file] than Y [to save the pingsweep.sh file] when prompted.

The pingsweep.sh file will be saved on your Desktop [Figure 1.11].

![image](https://user-images.githubusercontent.com/92907451/171231279-09f601ef-9569-49ef-a4f8-d35acf623b9d.png)
Figure 1.11: Save the Ping Sweep Script.
At this point, our pingsweep.sh script is ready for a test run.

STEP 5: Execute The Ping Sweep Script
To run our ping sweep script, we need to make the pingsweep.sh file executable first. To do that, type in the terminal:

chmod +x pingsweep.sh
To execute the pingsweep.sh script, type in the terminal:

./pingsweep.sh 192.168.2 > ips.txt
Next, let’s view the content of ips.txt file, using the following command:

cat ips.txt
The output should look similar as in the Figure 1.12 below:

![image](https://user-images.githubusercontent.com/92907451/171231314-17579001-620d-4d5f-b05c-e1ec3df692dd.png)
Figure 1.12: Ping Sweep Script reachable IPs.
As you can see above, 192.168.2.1, 192.168.2.7, and 192.168.2.5 IPs are the “alive” hosts in my network. 

NOTE: Your output might look different depending on the network ID and hosts reachable in your network.

One shortcoming is that we need to remember how to run our ping sweep script each time we want to execute it. 

Let’s fix that by making some quick improvements [comments] to the pingsweep.sh script in case we forget how to run it next time.

Add the following code lines immediately after #!/bin/bash:

if [ “$1” == “” ]
then
echo “Type the IP address to scan.”
echo “Example: ./pingsweep.sh 192.168.2”
else
This is how we interpret the above statement: If the user input “$1” is empty “” then print “Type the IP address to scan. E.g., ./pingsweep.sh 192.168.2” else, bypass the conditional statement above and execute the script.

To indicate the end of the inner “if” statement above, we need to add the keyword “fi” at the end of the script. Every “if” statement must be ended with “fi”. 

Finally, this is how our ping sweep script [pingsweep.sh] should look like: 

#!/bin/bash
if [ “$1” == “” ]
then
echo “Type the IP address to scan.”
echo “Example: ./pingsweep.sh 192.168.2”
else
for ip in `seq 1 254` ; do
ping -c 1 $1.$ip | grep "64 bytes" | cut -d " " -f 4 | tr -d “:” &
done
fi
Now that we created our simple yet useful ping sweep script, let’s discuss what we could do more with it.

Ping Sweep Script With NMAP
The ping sweep alone can be a good way of scanning for host reachability in a network where no other tools are available. I can’t remember how many times a ping sweep saved me countless hours as a network engineer. 

However, when used in tandem with NMAP [considering that your system has NMAP installed], it can become a pretty powerful way to enhance a network scan.

If you don’t have NMAP installed on your machine, here is a step-by-step guide to install it on Windows, macOS, Linux, and UNIX [FreeBSD].

For instance, we could use NMAP to scan for a specific port e.g., TCP port 80, for every reachable IP in our list [ips.txt]. 

To do so, scan your network for reachable IPs first using the pingsweep.sh script and write the output to the ips.txt file by typing the following command in the terminal. 

NOTE: You need to run the command in the same directory where pingsweep.sh file is located.

./pingsweep.sh 192.168.2 > ips.txt
Scan the TCP port 80 for all active IPs in the ips.txt by executing the following line in the terminal:

for ip in $(cat ips.txt); do nmap -p 80 -T4 $ip & done 
This is how you interpret the above command: For “ip” in the “ips.txt” file, run nmap, and scan the port “-p” 80 at speed “-T4” for every IP “$ip” simultaneously “&” and finish “done”.

In my case, the output for the ping sweep script with NMAP is shown in Figure 1.13 below:

![image](https://user-images.githubusercontent.com/92907451/171231451-a830555c-29be-4a93-a7cb-c3b393beb93a.png)
Figure 1.13: Ping Sweep Script with NMAP output.
Conclusion
Many ping sweep utilities out there can do much more than the script we created above. However, in many situations, when dealing with hardened networks, all you end up with is a Linux/UNIX terminal. 

Knowing how to quickly put together a simple ping sweep script can save you a lot of time, frustration as well as impressing your fellow admins with your bash scripting skills.
