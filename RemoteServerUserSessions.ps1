<# ***** User Sessions on a Terminal Server *****

    05/26/2020 - Jason Franklin
        #Script to check all users on Terminal Servers
    05/28/2020 - Jason Franklin
        #Added SessionID to $Output table

******** Add revisions above ******** #>

#Enter variable for $Servers you want to see user sessions for

$Servers = @(

#ServerNamesHere

)
 
#Initialize $Sessions which will contain all sessions
[System.Collections.ArrayList]$Sessions = New-Object System.Collections.ArrayList($null)
 
#Go through each server
Foreach ($Server in $Servers)  {
	#Get the current sessions on $Server and also format the output
	$Ouput = (quser /server:$Server) -replace '\s{2,}', ',' | ConvertFrom-Csv
	
	#Go through each session in $Ouput
	Foreach ($session in $Ouput) {
	#Initialize a temporary hash where we will store the data
	$tmpHash = @{}
	
	#Check if SESSIONNAME isn't like "console" and isn't like "rdp-tcp*"
	If (($session.sessionname -notlike "console") -AND ($session.sessionname -notlike "rdp-tcp*")) {
		#If the script is in here, the values are shifted and we need to match them correctly
		$tmpHash = @{
		Username = $session.USERNAME
		SessionName = "" #Session name is empty in this case
		SessionID = $session.SESSIONNAME
		State = $session.ID
		IdleTime = $session.STATE
		LogonTime = $session."IDLE TIME"
		ServerName = $Server
		}
		}Else  {
		#If the script is in here, it means that the values are correct
		$tmpHash = @{
		Username = $session.USERNAME
		SessionName = $session.SESSIONNAME
		SessionID = $session.ID
		State = $session.STATE
		IdleTime = $session."IDLE TIME"
		LogonTime = $session."LOGON TIME"
		ServerName = $Server
		}
		}
		#Add the hash to $Sessions
		$Sessions.Add((New-Object PSObject -Property $tmpHash)) | Out-Null
	}
}
  
#Display the sessions, sort by name, and just show Username, ID and Server
$sessions | Sort Username | select Username, SessionID, ServerName | FT