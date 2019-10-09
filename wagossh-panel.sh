#!/bin/bash
#Made By WagoVPN
# Terminal Color
RED='\033[01;31m';
RESET='\033[0m';
GREEN='\033[01;32m';
WHITE='\033[01;37m';
YELLOW='\033[00;33m';
echo -e "                $GREEN Please wait it may take for a while..$RESET"
apt-get update &> /dev/null
apt-get -y install apt-transport-https lsb-release ca-certificates &> /dev/null
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg &> /dev/null
cat << EOF > /etc/apt/sources.list.d/php.list
deb https://packages.sury.org/php/ $(lsb_release -sc) main
EOF
apt-get update &> /dev/null
apt-get -y install php5.6 php5.6-fpm php7.0-cli libssh2-1 php-ssh2 libapache2-mod-php5.6 php5.6-cli gcc make autoconf libc-dev pkg-config &> /dev/null
apt-get -y purge apache2 nginx &> /dev/null && apt-get install nginx -y &> /dev/null
rm /etc/nginx/sites-enabled/default && rm /etc/nginx/sites-available/default
wget  --quiet -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/Dreyannz/AutoScriptVPS/master/Files/Nginx/nginx.conf"
mkdir -p /home/vps/public_html
wget  --quiet -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/Dreyannz/AutoScriptVPS/master/Files/Nginx/vps.conf"
sed -i 's/listen = \/run\/php\/php5.6-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php/5.6/fpm/pool.d/www.conf
service php5.6-fpm restart && service nginx restart
echo -e "                $GREEN Package update done..$RESET"
MYIP=$(curl -4 icanhazip.com); &> /dev/null
clear
echo ""
echo ""
echo ""
echo -e "                $GREEN Changing root password$RESET"
passwd
clear
wagoname=""
wagopass=""

echo ""
echo "Server Name:"
read wagoname
echo ""
echo -e " $GREEN root password$RESET"
echo "Root Password:"
read wagopass
echo ""
clear

wagoip="s/serverip/$MYIP/g";
wagop="s/serverpass/$wagopass/g";
wagon="s/servername/$wagoname/g";

rm -rf /home/vps/public_html/index.php &> /dev/null
/bin/cat <<"EOM" >/home/vps/public_html/index.php
<?php

/* Site Data */
$site_name        = "WagoSHH|VPN";
$site_description = "WagoSSH|VPN";
$site_template    = "sketchy"; // (flatly, darkly, sketchy, lumen, materia)
/* Server Data */
/* Format: Server_Name, IP_Address, Root_Pass, Account_Validity */
/* Example: 1=>array(1=>"LadyClare Server 1","123.456.789","LadyClare","5"), */
$server_lists_array=array(
			1=>array(1=>"servername","serverip","serverpass","5"),
			2=>array(1=>"servername","serverip","serverpass","5"),
			3=>array(1=>"servername","serverip","serverpass","5"),
	);			
/* Service Variables */	
$port_ssh= '22, 222'; 				// SSH Ports
$port_dropbear= '442, 109, 143'; 			// Dropbear Ports
$port_ssl= '445'; 				// SSL Ports
$port_squid= '3128, 8080, 8888'; 		// Squid Ports
$ovpn_client= ''.$hosts.':88/client.ovpn';		// OpenVPN Client Config


for ($row = 1;$row < 101;$row++) {
    if ($_POST['server'] == $server_lists_array[$row][1]) {
        $hosts = $server_lists_array[$row][2];
        $root_pass = $server_lists_array[$row][3];
        $expiration = $server_lists_array[$row][4];
        break;
    }
}
$error = false;
if (isset($_POST['user'])) {
    $username = trim($_POST['user']);
    $username = strip_tags($username);
    $username = htmlspecialchars($username);
    $password1 = trim($_POST['password']);
    $password1 = strip_tags($password1);
    $password1 = htmlspecialchars($password1);
    $cpassword = $_POST['confirmpassword'];
    $cpassword = strip_tags($cpassword);
    $cpassword = htmlspecialchars($cpassword);
    $password1 = $_POST['password'];
    $nDays = $expiration;
    $datess = date('m/d/y', strtotime('+' . $nDays . ' days'));
    $password = escapeshellarg(crypt($password1));
    if (empty($username)) {
        $error = true;
        $nameError = "Please Enter A Username.";
    } else if (strlen($username) < 3) {
        $error = true;
        $nameError = "Username Must Have Atleast 3 Characters.";
    }
    if (empty($password1)) {
        $error = true;
        $passError = "Please Enter A Password.";
    } else if (strlen($password1) < 3) {
        $error = true;
        $passError = "Password Must Have Atleast 3 Characters.";
    }
    if ($password1 != $cpassword) {
        $error = true;
        $cpaseror = "Password Didn't Match.";
    }
    if (!$error) {
        date_default_timezone_set('UTC');
        date_default_timezone_set("Asia/Manila");
        $my_date = date("Y-m-d H:i:s");
        $connection = ssh2_connect($hosts, 22);
        if (ssh2_auth_password($connection, 'root', $root_pass)) {
            $show = true;
            ssh2_exec($connection, "useradd $username -m -p $password -e $datess -d  /tmp/$username -s /bin/false");
            $succ = 'Added Succesfully';
            if ($res) {
                $errTyp = "success";
                $errMSG = "Successfully registered, you may Check your credentials";
                $username = '';
                $password = '';
                $cpassword = '';
            } else {
                $errTyp = "danger";
                $errMSG = "Something went wrong, try again later...";
            }
        } else {
            die('Connection Failed...');
        }
    }
}
?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />  
<title><?php echo $site_name;?></title>
<link rel="shortcut icon" type="image/x-icon" href="/logo.png" height="200" width"200">
<meta name="description" content="<?php echo $site_description;?>"/>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootswatch/4.1.1/<?php echo $site_template;?>/bootstrap.min.css">
<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.0.13/css/all.css">
</head>
<body>
	<div class="navbar navbar-expand-lg navbar-dark bg-danger">
		<div class="container">
			<a class="navbar-brand" href="/"><?php echo $site_name;?></a>
			<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navigatebar" aria-controls="navigatebar" aria-expanded="false" aria-label="Toggle navigation">
			<span class="navbar-toggler-icon"></span>
			</button>
			<div class="collapse navbar-collapse" id="navigatebar">
			</div>
		</div>
	</div>
	<header id="header" align="center">
		<img src="https://github.com/omayanrey/WagoVPN/raw/master/71749063_2441026242599582_391209613006995456_n.jpg" alt="" height="350" width"350"/>
	</header>
	<div align="center">
    	<div class="col-md-4" align="center">
			<div align="center">
				<div align="center" class="card-body">
					<form method="post" align="center" class="softether-create">
						<div class="form-group">
							<div class="alert-danger">
								<span class="text-light"><?php echo $nameError; ?></span>
							</div>					
							<div class="alert-danger">
								<span class="text-light"><?php echo $passError; ?></span>
							</div>
							<div class="alert-danger">
								<span class="text-light"><?php echo $cpaseror; ?></span>
							</div>
						</div>
						<div class="form-group">												
							<?php
								if($show == true) 
									{
										echo '<div class="card alert-danger">';
										echo '<table class="table-danger">';
										echo '<tr>'; echo '<td> </td>'; echo '<td> </td>'; echo '</tr>';			
										echo '<tr>'; echo '<td>Host</td>'; echo '<td>'; echo $hosts; echo '</td>'; echo '</tr>';
										echo '<tr>'; echo '<td>Username</td>'; echo '<td>'; echo $username; echo '</td>'; echo '</tr>';
										echo '<tr>'; echo '<td>Password</td>'; echo '<td>'; echo $password1; echo '</td>'; echo '</tr>';
										echo '<tr>'; echo '<td>SSH Port</td>'; echo '<td>'; echo $port_ssh; echo '</td>'; echo '</tr>';
										echo '<tr>'; echo '<td>Dropbear Port</td>'; echo '<td>'; echo $port_dropbear; echo '</td>'; echo '</tr>';
										echo '<tr>'; echo '<td>SSL Port</td>'; echo '<td>'; echo $port_ssl; echo '</td>'; echo '</tr>';
										echo '<tr>'; echo '<td>Squid Port</td>'; echo '<td>'; echo $port_squid; echo '</td>'; echo '</tr>';
										echo '<tr>'; echo '<td>OpenVPN Config</td>'; echo '<td>';echo '<a href="http://';echo $hosts; echo ":88/"; echo "client.ovpn"; echo'">download config</a>'; echo '</td>'; echo '</tr>';
										echo '<tr>'; echo '<td>Expiration Date</td>'; echo '<td>'; echo $datess; echo '</td>'; echo '</tr>';																							
										echo '<tr>'; echo '<td> </td>'; echo '<td> </td>'; echo '</tr>';
										echo '</table>';
										echo '</div>';
									}										
							?>

						</div>
						<div class="form-group">
							<div class="input-group">									
								<div class="input-group-prepend">
									<span class="input-group-text"><i class="fas fa-globe" style="color:red;"></i></span>
								</div>
								<select class="custom-select" name="server" >
									<option disabled selected value>Select Server</option> 
										<optgroup label="WagoSSH Servers">
										<?php
										for ($row = 1;$row < 101;$row++) {
											if (!empty($server_lists_array[$row][1])) {
											echo '<option>';
											echo $server_lists_array[$row][1];
											echo '</option>';
											} else {
											break;
											}
											}
										?>
									</optgroup>														
								</select> 
							</div>
						</div>								
						
						<div class="form-group">								
							<div class="input-group">									
								<div class="input-group-prepend">
									<span class="input-group-text"><i class="fas fa-user-circle" style="color:red;"></i></span>
								</div>
									<input type="text" class="form-control" id="username" placeholder="Username" name="user" autocomplete="off" >
							</div>
						</div>
						<div class="form-group">								
							<div class="input-group">
								<div class="input-group-prepend">
									<span class="input-group-text"><i class="fas fa-key" style="color:red;"></i></span>
								</div>
									<input type="text" class="form-control" id="password" placeholder="Password" name="password" autocomplete="off"  >
							</div>						
						</div>						
						<div class="form-group">									
							<div class="input-group">									
								<div class="input-group-prepend">
									<span class="input-group-text"><i class="fas fa-key" style="color:red;"></i></span>
								</div>
									<input type="text" class="form-control" id="confirm" placeholder="Confirm Password" name="confirmpassword" autocomplete="off" >
							</div>						
						</div>						
						<div class="form-group ">
							<button type="submit" id="button" class="btn btn-danger btn-block btn-action">CREATE ACCOUNT</button>
						</div>
					</form>					
				</div>
			</div>
		</div>
	</div>
</body>
</html>
EOM


sed -i $wagoip /home/vps/public_html/index.php;
sed -i $wagop /home/vps/public_html/index.php;
sed -i $wagon /home/vps/public_html/index.php;


rm *.sh *.zip &> /dev/null
rm -rf ~/.bash_history ~/wagov3 && history -c & history -w
rm .bash_history
