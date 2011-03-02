<?php

// settings
$language			= "fr";								// "fr" / "en"
$project_title		= "Nom du projet / Name of the project";
$use_login			= false;							// set to true here if you want to use the login feature
$login_password		= "";
$logout_delay		= 5 * 60;							// in seconds

// text
$project_subtitle	= ($language == "fr") ? "Un projet de " : "A project by ";
$project_subtitle	.= "<a href=\"http://www.zero-un.com/\" target=\"_blank\"><img src=\"index_assets/logo_zero_un.jpg\" border=\"0\" /></a>";		// logo + link
$login_label		= ($language == "fr") ? "Entrez votre code d'accès :" : "Please enter your access code:";

// variables
$is_logged_in			= (!$use_login);

// make sure the user is logged in
if (!$is_logged_in)
{
	session_start();
	
	if (!isset($_SESSION["last_hit"]))
	{		
		if (isset($_POST["login"]) && $_POST["login"] == $login_password)
		{
			$_SESSION["last_hit"] = microtime(true);
			$is_logged_in = true;
		}
	}
	else
	{
		if (microtime(true) - $_SESSION["last_hit"] < $logout_delay)
		{
			$_SESSION["last_hit"] = microtime(true);
			$is_logged_in = true;
		}
		else
		{
			unset($_SESSION["last_hit"]);
		}
	}
}

// function that formats the link to a folder
function formatUrl($url)
{
	$parts = explode("@", $url);
	if (sizeof($parts) == 1) { $parts[] = ""; }
	return "?" . $parts[0] . "" . $parts[1] . "";
}

// function that formats the folder's description
function formatDescription($version, $folder_name_without_dateandversion)
{
	$label = str_replace("_", " ", $folder_name_without_dateandversion);
	if ($version != "")
	{
		return utf8_encode($label . " (" . $version . ")");
	}
	else
	{
		return utf8_encode($label);
	}
}

// functions that checks that a date is in the YYMMDD format
function isDateYYMMDD($dateAsString)
{
	return preg_match("/^[0-9]{6}/", $dateAsString);
}

// function that formats the dates
function formatDate($date)
{
	global $language;
	$months = ($language == "fr")	? array("janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre")
									: array("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
	$y = (int) substr($date, 0, 2) + 2000;
	$m = (int) substr($date, 2, 2);
	$d = (int) substr($date, 4, 2);
	
	if ($language == "fr")
	{
		$months = array("janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre");
		if ($d == 1) { $d = "1er"; }
		return $d . " " . $months[$m - 1] . " " . $y;
	}
	else
	{
		$months = array("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December");
		if ($d == 1) { $d = "1st"; }
		else if ($d == 2) { $d = "2nd"; }
		else if ($d == 3) { $d = "3rd"; }
		else if ($d == 21) { $d = "21st"; }
		else if ($d == 22) { $d = "22nd"; }
		else if ($d == 23) { $d = "23rd"; }
		else if ($d == 31) { $d = "31st"; }
		else { $d = $d . "th"; }
		return $months[$m - 1] . " " . $d . ", " . $y;
	}
}

// function that reads the current directory's content and puts it into an array
function readCurrentDirectory()
{
	$folders = array();
	if ($handle = opendir('.')) {
		while (false !== ($file = readdir($handle))) {
			if ($file != "." && $file != ".." && is_dir($file) && $file != "index_assets") {
				$folders[] = $file;
			}
		}
		closedir($handle);
	}
	rsort($folders);
	return $folders;
}

// function that redirects transparently to a subfolder
function redirect($url)
{
	echo("<body  style=\"margin:0 0 0 0;\"><iframe src=\"".urlencode($url)."\" width=\"100%\" height=\"100%\" frameborder=\"0\" marginwidth=\"0\" marginheight=\"0\"></iframe></body>");
	exit();
}

// save the list of subfolders into $folders
if ($is_logged_in)
{
	$folders = readCurrentDirectory();
}
else
{
	$folders = array();
}

// redirect to a subfolder if we have a query string
if ($_SERVER['QUERY_STRING'] != "")
{
	$folder_id = $_SERVER['QUERY_STRING'];
	$folder_id = substr($folder_id, 0, 6) . "@" . substr($folder_id, 6);
	$id_len = strlen($folder_id);
	foreach ($folders as $f)
	{
		if (substr($f, 0, $id_len) == $folder_id) { redirect($f); }
	}
}

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title><?php echo $project_title; ?></title>
<style type="text/css">
<!--
body {
	margin-left: 0px;
	margin-top: 0px;
	margin-right: 0px;
	margin-bottom: 0px;
	
	background-color: #FFFFFF;
	background-image: url(index_assets/page_bg.jpg);
	background-repeat: repeat-x;
}
#title {
	height: 83px;
	text-align: left;
	margin: 58px 0 0 49px;		/* top right bottom left */

	font-family: Arial, Helvetica, sans-serif;
	font-size: 28px;
	font-weight: bold;
	color: #D2DFD7;
}
#subtitle {
	height: 25px;
	text-align: left;
	margin: 8px 0 0 49px;		/* top right bottom left */

	font-family: Georgia, "Times New Roman", Times, serif;
	font-size: 13px;
	color: #8A928B;
}
#menu {
	text-align: left;
	margin: 53px 0 0 0;		/* top right bottom left */

	font-family: Georgia, "Times New Roman", Times, serif;
	font-size: 13px;
}
td
{
	padding: 0px 0 0 0;
}
a
{
	color: #0099FF;
	text-decoration: none;
}
a:hover
{
	text-decoration: underline;
}
a:visited
{
	color: #226B9B;
}
#loginBox {
	font-family:"Courier New", Courier, monospace;
	font-weight:bolder;
	font-size: 20px;
}
#loginButton {
	font-family:"Courier New", Courier, monospace;
	font-weight:bolder;
	font-size: 20px;
}
-->
</style>
</head>

<body>

<div id="title">
	<?php echo $project_title; ?>
</div>

<div id="subtitle">
	<?php echo $project_subtitle; ?>
</div>

<div id="menu">

	<?php if (!$is_logged_in) { ?>
  <table width="800" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="50" align="left" valign="top">&nbsp;</td>
        <td width="750" align="left" valign="top">
          <form action="" method="post">
		    <?php echo $login_label; ?>
            <br /><br />
            <input id="loginBox" name="login" type="password" />
            <input id="loginButton" type="submit" value=" &gt; " />
          </form>
        </td>
      </tr>
  </table>
	<?php } ?>
  
  <table width="800" border="0" cellpadding="0" cellspacing="0">
	<?php
    $last_date = "";
    $date = "";
    $url = "";
    $description = "";
    for ($i = 0; $i < sizeof($folders); $i ++)
    {
        $f = $folders[$i];
        $a = explode("_", $f, 2);
        if ((sizeof($a) == 2) && (strlen($a[0]) >= 6))
        {
			$b = explode("@", $a[0]);
			if (isDateYYMMDD($b[0]))
			{
				$date = formatDate($b[0]);
				if ($date == $last_date) { $date = ""; }		// do not repeat
				else { $last_date = $date; }					// save last date to detect repeats
				
				$version = (sizeof($b) == 1) ? "" : $b[1];
				$description = formatDescription($version, urldecode($a[1]));
				$url = formatUrl($a[0]);
            
			    if (($date != "") && ($i > 0)) {
					
    ?>
      <tr>
        <td colspan="3">&nbsp;</td>
      </tr>
	<?php
    			}
    ?>  
      <tr>
        <td width="180" align="right" valign="top"><?php echo $date; ?></td>
        <td width="30" align="right" valign="top">&nbsp;</td>
        <td width="590" align="left" valign="top"><a href="<?php echo $url; ?>"><?php echo $description; ?></td>
      </tr>
	<?php
			}
        }
    }
    ?>
    </table>  
</div>
<br />
<br />

</body>
</html>
