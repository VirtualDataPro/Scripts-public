Function New-SnapInfo{

#Load Assembly for creating form & button
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")

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