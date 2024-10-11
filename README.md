# PortAnalysis
powershell port and service scanning script

We use two scripts to analyze the ports and associated services working on our equipment.

The first script uses netstat to scan the computer in 1 second intervals up to 20 and then in 1 minute intervals up to 10.
You can modify these values although I have not defined them as a variable yet. In a future revision it will be improved.

The second script takes the first log and translates it into a new file resolving the DNS names it finds and the associated services to make the log more understandable.
Remember To change the Log Paths before to use the script.

https://www.youtube.com/watch?v=H4tbig_n6UU&ab_channel=Conecta2enred
