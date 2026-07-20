# geting started with new laptop

#Connecting to vCenter
add-pssnapin VMware.VImAutomation.Core
Connect-VIserver $vcenterserver -Protocol https

#Begin script
Write-Host " "
Write-Host "******************** DO NOT CLOSE THIS WINDOW ********************" 
Write-Host " "
Write-Host "Preparing New Snapshot form..."
Add-PSSnapin VMware.VimAutomation.Core

Function New-SnapInfo{

#Load Assembly for creating form & button
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")

#Define the form size & placement
    $Form = New-Object "System.Windows.Forms.Form";
    $Form.Width = 875;
    $Form.Height = 450;
    $Form.Text = "Automated Snapshot Form - List of Servers - Scheduled Task Setup";
    $Form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen;

#Define Text Label1
    $TextLabel1 = New-Object "System.Windows.Forms.Label";
    $TextLabel1.Left = 10;
    $TextLabel1.Top = 15;
    $TextLabel1.Text = "Incident #";

#Define Text Label2
    $TextLabel2 = New-Object "System.Windows.Forms.Label";
    $TextLabel2.Left = 10;
    $TextLabel2.Top = 55;
    $TextLabel2.Width = 150
    $TextLabel2.Text = "Expiration (MM/DD/YYYY)";

#Define Text Label3
    $TextLabel3 = New-Object "System.Windows.Forms.Label";
    $TextLabel3.Left = 10;
    $TextLabel3.Top = 95;
    $TextLabel3.Width = 150
    $TextLabel3.Text = "Reason for the Snapshot";

#Define Text Label4
    $TextLabel4 = New-Object "System.Windows.Forms.Label";
    $TextLabel4.Left = 10;
    $TextLabel4.Top = 135;
    $TextLabel4.Width = 150
    $TextLabel4.Text = "Memory Snaphot? Y or N";
    
#Define Text Label5
    $TextLabel5 = New-Object "System.Windows.Forms.Label";
    $TextLabel5.Left = 10;
    $TextLabel5.Top = 175;
    $TextLabel5.Width = 150
    $TextLabel5.Text = "Recipients (see example)";
    
#Define Text Label6
    $TextLabel6 = New-Object "System.Windows.Forms.Label";
    $TextLabel6.Left = 10;
    $TextLabel6.Top = 245;
    $TextLabel6.Width = 150
    $TextLabel6.Text = "Run Date (MM/DD/YYYY)";

#Define Text Label7
    $TextLabel7 = New-Object "System.Windows.Forms.Label";
    $TextLabel7.Left = 10;
    $TextLabel7.Top = 285;
    $TextLabel7.Width = 150
    $TextLabel7.Text = "Run Time (Military Time)"
    
#Define Text Label8
    $TextLabel8 = New-Object "System.Windows.Forms.Label";
    $TextLabel8.Left = 10;
    $TextLabel8.Top = 323;
    $TextLabel8.Width = 150
    $TextLabel8.Text = "DOMAIN\vmscripter Password"
    
#Define Text Label9
    $TextLabel9 = New-Object "System.Windows.Forms.Label";
    $TextLabel9.Left = 25;
    $TextLabel9.Top = 215;
    $TextLabel9.Width = 200
    $TextLabel9.Text = "*** SCHEDULED TASK SETUP ***"

#Define Text Box1 for input
    $TextBox1 = New-Object "System.Windows.Forms.TextBox";
    $TextBox1.Left = 160;
    $TextBox1.Top = 15;
    $TextBox1.width = 150;

#Define Text Box2 for input
    $TextBox2 = New-Object "System.Windows.Forms.TextBox";
    $TextBox2.Left = 160;
    $TextBox2.Top = 55;
    $TextBox2.width = 150;

#Define Text Box3 for input
    $TextBox3 = New-Object "System.Windows.Forms.TextBox";
    $TextBox3.Left = 160;
    $TextBox3.Top = 95;
    $TextBox3.width = 650;

#Define Text Box4 for input
    $TextBox4 = New-Object "System.Windows.Forms.TextBox";
    $TextBox4.Left = 160;
    $TextBox4.Top = 135;
    $TextBox4.width = 15;

#Define Text Box5 for input
    $TextBox5 = New-Object "System.Windows.Forms.TextBox";
    $TextBox5.Left = 160;
    $TextBox5.Top = 175;
    $TextBox5.width = 650;
    
#Define Text Box6 for input
    $TextBox6 = New-Object "System.Windows.Forms.TextBox";
    $TextBox6.Left = 160;
    $TextBox6.Top = 245;
    $TextBox6.width = 150;

#Define Text Box7 for input
    $TextBox7 = New-Object "System.Windows.Forms.TextBox";
    $TextBox7.Left = 160;
    $TextBox7.Top = 285;
    $TextBox7.width = 150;
    
#Define Text Box8 for input
    $TextBox8 = New-Object "System.Windows.Forms.TextBox";
    $TextBox8.Left = 160;
    $TextBox8.Top = 325;
    $TextBox8.width = 150;
        
#Define default values for the input boxes
    $DefaultValue = ""
    $EXPDate = (get-date).AddDays(+7).ToString("MM/dd/yyyy")
    $TextBox1.Text = "INC";
    $TextBox2.Text = $EXPDate;
    $TextBox3.Text = $DefaultValue;
    $TextBox4.Text = $DefaultValue;
    $TextBox5.Text = '$emailaddresses';
    $TextBox6.Text = $DefaultValue;
    $TextBox7.Text = $DefaultValue;
    $TextBox8.Text = $DefaultValue;
    
#Define OK button
    $Button = New-Object "System.Windows.Forms.Button";
    $Button.Left = 10;
    $Button.Top = 375;
    $Button.Width = 80;
    $Button.Text = "OK";

#This is when you have to close the form after getting values
    $EventHandler = [System.EventHandler]{
    $TextBox1.Text;
    $TextBox2.Text;
    $TextBox3.Text;
    $TextBox4.Text;
    $TextBox5.Text;
    $TextBox6.Text;
    $TextBox7.Text;
    $TextBox8.Text;
    $Form.Close();};
    $Button.Add_Click($EventHandler) ;

#Add controls to all the above objects defined
    $Form.Controls.Add($Button);
    $Form.Controls.Add($TextLabel1);
    $Form.Controls.Add($TextLabel2);
    $Form.Controls.Add($TextLabel3);
    $Form.Controls.Add($TextLabel4);
    $Form.Controls.Add($TextLabel5);
    $Form.Controls.Add($TextLabel6);
    $Form.Controls.Add($TextLabel7);
    $Form.Controls.Add($TextLabel8);
    $Form.Controls.Add($TextLabel9);
    $Form.Controls.Add($TextBox1);
    $Form.Controls.Add($TextBox2);
    $Form.Controls.Add($TextBox3);
    $Form.Controls.Add($TextBox4);
    $Form.Controls.Add($TextBox5);
    $Form.Controls.Add($TextBox6);
    $Form.Controls.Add($TextBox7);
    $Form.Controls.Add($TextBox8);
    $Ret = $Form.ShowDialog();

#Return Values
    Return $TextBox1.Text, $TextBox2.Text, $TextBox3.Text, $TextBox4.Text, $TextBox5.Text, $TextBox6.Text, $TextBox7.Text, $TextBox8.Text
}    #End New-SnapInfo Function

#New-Popup Function
Function New-Popup {
    Param (
        [Parameter(Position=0,Mandatory=$True,HelpMessage="Enter a message for the popup")]
        [ValidateNotNullorEmpty()]
        [string]$Message,
        
        [Parameter(Position=1,Mandatory=$True,HelpMessage="Enter a title for the popup")]
        [ValidateNotNullorEmpty()]
        [string]$Title,
        
        [Parameter(Position=2,HelpMessage="How many seconds to display? Use 0 require a button click.")]
        [ValidateScript({$_ -ge 0})]
        [int]$Time=0,
        
        [Parameter(Position=3,HelpMessage="Enter a button group")]
        [ValidateNotNullorEmpty()]
        [ValidateSet("OK","OKCancel","AbortRetryIgnore","YesNo","YesNoCancel","RetryCancel")]
        [string]$Buttons="OK",
        
        [Parameter(Position=4,HelpMessage="Enter an icon set")]
        [ValidateNotNullorEmpty()]
        [ValidateSet("Stop","Question","Exclamation","Information" )]
        [string]$Icon="Information"
    )

#Convert buttons to their integer equivalents
    Switch ($Buttons) {
        "OK"               {$ButtonValue = 0}
        "OKCancel"         {$ButtonValue = 1}
        "AbortRetryIgnore" {$ButtonValue = 2}
        "YesNo"            {$ButtonValue = 4}
        "YesNoCancel"      {$ButtonValue = 3}
        "RetryCancel"      {$ButtonValue = 5}
    }

#Set an integer value for Icon type
    Switch ($Icon) {
        "Stop"        {$iconValue = 16}
        "Question"    {$iconValue = 32}
        "Exclamation" {$iconValue = 48}
        "Information" {$iconValue = 64}
    }

#Create the COM Object
    Try {
        $wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
        #Button and icon type values are added together to create an integer value
        $wshell.Popup($Message,$Time,$Title,$ButtonValue+$iconValue)
    }
    Catch {
        #You should never really run into an exception in normal usage
        Write-Warning "Failed to create Wscript.Shell COM object"
        Write-Warning $_.exception.message
    }

} #End New-Popup Function


#Prompt user for Snapshot Requirements and Define Objects
$SnapForm = New-SnapInfo
$Incident = $SnapForm[0]
$Expiration = $SnapForm[1] -as [DateTime]
$Reason = $SnapForm[2]
$Memory = $SnapForm[3]
$Recipients = $SnapForm[4]
$RunDate = $SnapForm[5]
$RunTime = $SnapForm[6]
$RP = $SnapForm[7]

#Variables
$INCDate = get-date $RunDate -Format 'MM-dd-yyyy'
$INCPath = "D:\!Reports\Snapshots\$Incident"
$Servers = $Incident+"_Servers.txt"
$Admin = [Environment]::UserDomainName+"\"+[Environment]::UserName
$Path = $INCPath+"\"+$Servers
$EXP = (get-date $Expiration).ToString("MM/dd/yyyy")
$TestFile = $Incident+"_Test.txt"
$TestPath = $INCPath+"\"+$TestFile
#$VMlist = Get-Content $Path
#$TestPath

#Create INC direcotry and Servers file list and grant permissions
New-Item ($INCPath) -Type directory -f
New-Item $INCPath"\"$Servers -Type file -f
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show("ATTENTION! 
I will create the server list file, grant appropriate permissions and open it for you.  

Make sure there are no blank spaces in your VM server list.

Before proceeding, be sure to save and close when finished editing the list.
","Edit the Server List for "+$Incident)
icacls $INCPath /grant DOMAIN\Administrators:'(OI)(CI)R'
icacls $INCPath /grant DOMAIN\vmscripter:'(OI)(CI)F'
icacls $INCPath /grant ($Admin+':(OI)(CI)F')
Invoke-Item $Path

#Verify VMs existence
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show("I am going to test your list and make sure the VMs exist.

Please wait .... This could take a couple of minutes....

Results are being sent to a text file that will pop-up when ready.  Click OK","Testing VM Existence for "+$Incident)
$VMservers = Get-Content $Path

$Test =
foreach ($VMserver in $VMservers)
{
Try
{        Get-VM -Name $VMserver -ErrorAction Stop | Sort-Object Name
        Write-Output ($VMserver+"     Exists
    ")
}
Catch
{
    Write-Output ($VMserver+"     DOES NOT EXIST!
    ")
}
}

$Test | Out-String | Out-File $TestPath
Invoke-Item $TestPath

#Open VM list again to verify again
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show("I am opening your server list again, just in case you need to make a change.","Edit the Server List for "+$Incident)
Invoke-Item $Path

#Copy templates and rename file to INC path
$filePath = "D:\!Reports\Snapshots\"+$Incident+"\"+$Incident+".ps1"
$filePath2 = "D:\!Reports\Snapshots\"+$Incident+"\"+$Incident+"_ConfirmEmail.ps1"

Copy-Item "D:\!Reports\Snapshots\Template\SET-AutoSnap-Scheduled.ps1" $filePath
Copy-Item "D:\!Reports\Snapshots\Template\SET-Scheduled-ConfirmEmail.ps1" $filePath2

#Move content to script that will be used by Scheduled Tasks

$content = Get-Content -Path $filePath
$content2 = Get-Content -Path $filePath2

$Text = '$Incident = '+'"'+$Incident+'"'
$content[9] = "{0}`r`n{1}" -f $Text, $content[9]
$content2[9] = "{0}`r`n{1}" -f $Text, $content2[9]
$content | Set-Content $filePath
$content2 | Set-Content $filePath2

$Text = '$Reason = '+'"'+$Reason+'"'
$content[10] = "{0}`r`n{1}" -f $Text, $content[10]
$content2[10] = "{0}`r`n{1}" -f $Text, $content2[10]
$content | Set-Content $filePath
$content2 | Set-Content $filePath2

$Text = '$Memory = '+'"'+$Memory+'"'
$content[11] = "{0}`r`n{1}" -f $Text, $content[11]
$content2[11] = "{0}`r`n{1}" -f $Text, $content2[11]
$content | Set-Content $filePath
$content2 | Set-Content $filePath2

$Text = '$Recipients = '+$Recipients
$content[12] = "{0}`r`n{1}" -f $Text, $content[12]
$content2[12] = "{0}`r`n{1}" -f $Text, $content2[12]
$content | Set-Content $filePath
$content2 | Set-Content $filePath2

$Text = '$Admin = '+'"'+$Admin+'"'
$content[13] = "{0}`r`n{1}" -f $Text, $content[13]
$content2[13] = "{0}`r`n{1}" -f $Text, $content2[13]
$content | Set-Content $filePath
$content2 | Set-Content $filePath2

$Text = '$Path = '+'"'+$Path+'"'
$content[14] = "{0}`r`n{1}" -f $Text, $content[14]
$content2[14] = "{0}`r`n{1}" -f $Text, $content2[14]
$content | Set-Content $filePath
$content2 | Set-Content $filePath2

$Text = '$RunDate = '+'"'+$RunDate+'"'
$content[15] = "{0}`r`n{1}" -f $Text, $content[15]
$content2[15] = "{0}`r`n{1}" -f $Text, $content2[15]
$content | Set-Content $filePath
$content | Set-Content $filePath2

$Text = '$RunTime = '+'"'+$RunTime+'"'
$content[16] = "{0}`r`n{1}" -f $Text, $content[16]
$content2[16] = "{0}`r`n{1}" -f $Text, $content2[16]
$content | Set-Content $filePath
$content2 | Set-Content $filePath2

$Text = '$Expiration = '+'"'+$EXP+'"'
$content[17] = "{0}`r`n{1}" -f $Text, $content[17]
$content2[17] = "{0}`r`n{1}" -f $Text, $content2[17]
$content | Set-Content $filePath
$content2 | Set-Content $filePath2

#SCHEDULED TASKS
$TN = "\VMware\Snapshots\"+$Incident
$Program = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe\'
$TR = 'powershell -file "'+$filePath+'"'

#Create Scheduled Task
SCHTASKS /Create /tn $TN /SC Once /SD $RunDate /ST $RunTime /TR $TR /RU DOMAIN\vmscripter /RP $RP /F
Taskschd.msc

#Send confirmation email that task has been scheduled
Powershell -file $filePath2

#COMPLETED
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show("Completed Successfully!","Scheduled Task for "+$Incident)