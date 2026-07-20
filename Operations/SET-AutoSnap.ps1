# =============================================================================
# ========                    VM Snapshot Automation                   ========
# ========                             by                              ========
# ========                          VirtualDataPro                        ========
# ========                       v1.0 - 2/5/2015                       ========
# =============================================================================

Write-Host " "
Write-Host "******************** DO NOT CLOSE THIS WINDOW ********************" 
Write-Host " "
Write-Host "Preparing New Snapshot form..."
Add-PSSnapin VMware.VimAutomation.Core

Function New-SnapInfo{

#Load Assembly for creating form & button
    [void][System.Reflection.Assembly]::LoadWithPartialName( "System.Windows.Forms")
    [void][System.Reflection.Assembly]::LoadWithPartialName( "Microsoft.VisualBasic")

#Define the form size & placement
    $Form = New-Object "System.Windows.Forms.Form";
    $Form.Width = 400;
    $Form.Height = 190;
    $Form.Text = "Automated Snapshot Form";
    $Form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen;

#Define Text Label1
    $TextLabel1 = New-Object "System.Windows.Forms.Label";
    $TextLabel1.Left = 10;
    $TextLabel1.Top = 10;
    $TextLabel1.Text = "Incident #";

#Define Text Label2
    $TextLabel2 = New-Object "System.Windows.Forms.Label";
    $TextLabel2.Left = 10;
    $TextLabel2.Top = 50;
    $TextLabel2.Height = 40;
    $TextLabel2.Text = "Expiration (MM/DD/YYYY)";

#Define Text Label3
    $TextLabel3 = New-Object "System.Windows.Forms.Label";
    $TextLabel3.Left = 10;
    $TextLabel3.Top = 90;
    $TextLabel3.Text = "Reason";

#Define Text Label4
    $TextLabel4 = New-Object "System.Windows.Forms.Label";
    $TextLabel4.Left = 10;
    $TextLabel4.Top = 130;
    $TextLabel4.Text = "VM Name";

#Define Text Box1 for input
    $TextBox1 = New-Object "System.Windows.Forms.TextBox";
    $TextBox1.Left = 130;
    $TextBox1.Top = 10;
    $TextBox1.width = 150;

#Define Text Box2 for input
    $TextBox2 = New-Object "System.Windows.Forms.TextBox";
    $TextBox2.Left = 130;
    $TextBox2.Top = 50;
    $TextBox2.width = 150;

#Define Text Box3 for input
    $TextBox3 = New-Object "System.Windows.Forms.TextBox";
    $TextBox3.Left = 130;
    $TextBox3.Top = 90;
    $TextBox3.width = 150;

#Define Text Box4 for input
    $TextBox4 = New-Object "System.Windows.Forms.TextBox";
    $TextBox4.Left = 130;
    $TextBox4.Top = 130;
    $TextBox4.width = 150;

#Define default values for the input boxes
    $DefaultValue = ""
    $TextBox1.Text = $DefaultValue;
    $TextBox2.Text = $DefaultValue;
    $TextBox3.Text = $DefaultValue;
    $TextBox4.Text = $DefaultValue;

#Define OK button
    $Button = New-Object "System.Windows.Forms.Button";
    $Button.Left = 295;
    $Button.Top = 130;
    $Button.Width = 80;
    $Button.Text = "OK";

#This is when you have to close the form after getting values
    $EventHandler = [System.EventHandler]{
    $TextBox1.Text;
    $TextBox2.Text;
    $TextBox3.Text;
    $TextBox4.Text;
    $Form.Close();};
    $Button.Add_Click($EventHandler) ;

#Add controls to all the above objects defined
    $Form.Controls.Add($Button);
    $Form.Controls.Add($TextLabel1);
    $Form.Controls.Add($TextLabel2);
    $Form.Controls.Add($TextLabel3);
    $Form.Controls.Add($TextLabel4);
    $Form.Controls.Add($TextBox1);
    $Form.Controls.Add($TextBox2);
    $Form.Controls.Add($TextBox3);
    $Form.Controls.Add($TextBox4);
    $Ret = $Form.ShowDialog();

#Return Values
    Return $TextBox1.Text, $TextBox2.Text, $TextBox3.Text, $TextBox4.Text
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
$VMname = $SnapForm[3]
$Admin = [Environment]::UserName
$Date = Get-Date

#Input Validation
Write-Host "Verifying Requirements..."
If($Incident -eq "" -or $Incident.Contains(" ")){
    New-Popup "You MUST have an INC. Input may not contain spaces. Please use format INCXXXXXX" "ERROR:  Incident" 0 "OK" "STOP"
    Throw "You MUST have an INC. Input may not contain spaces. Please use format INCXXXXXX"
    BREAK
}
If (!$Expiration){
    New-Popup "You have entered an invalid expiration date." "ERROR:  Expiration Date" 0 "OK" "STOP"
    Throw "You have entered an invalid expiration date."
    BREAK
}
If($Expiration -le $Date -or $Expiration -ge ($Date+14d)){
    New-Popup "The entered Expiration Date exceeds policy maximums." "ERROR:  Expiration Date" 0 "OK" "STOP"
    Throw "The entered Expiration Date exceeds policy maximums."
    BREAK
}
If($Expiration -ge ($Date+7d)){
    New-Popup "The entered Expiration Date exceeds the Default. Has this been Justified?" "WARNING:  Expiration Date" 0 "OK" "Exclamation"
}
If($Reason -eq ""){
    New-Popup "You MUST have an Reason for taking this snapshot. Please refer to ticket before continuing" "ERROR:  Reason Missing" 0 "OK" "STOP"
    Throw "You MUST have an Reason for taking this snapshot. Please refer to ticket before continuing"
    BREAK
}
If($VMname -eq ""){
    New-Popup "OOPS! You've missed something. Please input a VM Name" "ERROR:  VM Missing" 0 "OK" "STOP"
    Throw "OOPS! You've missed something. Please input a VM Name"
    BREAK
}

#Connecting to vCenter
Write-Host "Connecting to vCenter..."
Connect-VIserver -Server $IP -Protocol https
Write-Host "Connected to vCenter!"


#VM Checks...
Write-Host "Checking VM..."
$VM = Get-vm $VMname
If(!$VM){
    New-Popup "Sorry! It seems this VM does not exist. Please check the Name of the VM and try again." "ERROR:  VM Does Not Exist" 0 "OK" "STOP"
    Throw "Sorry! It seems this VM does not exist. Please check the Name of the VM and try again."
    BREAK
}
If($VM.VMhost.Parent.Name -eq "VDI"){
    New-Popup "You may not snapshot a VM in the VDI cluster." "ERROR:  Cluster not appropriate!" 0 "OK" "STOP"
    Throw "You may not snapshot a VM in the VDI cluster"
    BREAK
}

#Snapshot Validation Checks...
Write-Host "Snapshot Validation In Progress..."
If($VM.ExtensionData.Snapshot){
    $VMsnap = $VM | Get-Snapshot
    $VMsnap
    If($VMsnap.Name.Contains("NBU_SNAPSHOT" -eq "True")){
        New-Popup "There is an active backup currently in progress. Please Try Again Later." "ERROR:  Active Backup In Progress" 0 "OK" "STOP"
        Throw "There is an active backup currently in progress. Please Try Again Later."
        BREAK
    }
    If($VMsnap.Name.contains("snapshot-") -eq "True" -or $VMsnap.Name.contains("vdm-initial-") -eq "True"){
        New-Popup "There is an active snapshot currently owned by another team and cannot be modified. Please contact a VM Administrator." "ERROR:  Snapshot Ownership Issue" 0 "OK" "STOP"
        Throw "There is an active snapshot currently owned by another team and cannot be modified. Please contact a VM Administrator."
        BREAK
    }        
    
    New-Popup "Looks like a snapshot already exists on this VM. Please remove." "ERROR:  VM Snapshot Already Exists" 0 "OK" "STOP"
    Throw "Looks like a snapshot already exists on this VM. Please remove."
    BREAK
    
}

#Description Formatting
$dDate = Get-Date -format d
$dExpiration = '{0:MM/dd/yyyy}' -f $expiration
$SnapDesc = "EXPIRATION:"+$dExpiration+": "+$Incident+" - "+$Reason+", Taken "+$dDate+" by "+$Admin+";"

#Taking Snapshot
Write-Host "Taking Snapshot, please wait..."
New-Snapshot $VM -Name $Incident -Description $SnapDesc

#Checking for successful VM Snapshot
$VM = Get-VM $VMname
If($VM.ExtensionData.Snapshot){
    New-Popup "Congratulations! Your snapshot request has completed!" "INFO: Snapshot Complete" 0 "OK" "Information"
}
Else{
    New-Popup "Something happened the snapshot did not complete successfully." "ERROR: Snapshot Failure" 0 "OK" "Stop"
}







