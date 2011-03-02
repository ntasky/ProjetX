<?

function formatDate($date)
{
	$months = array("janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre");
	$y = (int) substr($date, 0, 2) + 2000;
	$m = (int) substr($date, 2, 2);
	$d = (int) substr($date, 4, 2);
	if ($d == 1) { $d = "1er"; }
	return $d . " " . $months[$m - 1] . " " . $y;
}

function readCurrentDirectory()
{
	$folders = array();
	if ($handle = opendir('.')) {
		while (false !== ($file = readdir($handle))) {
			if ($file != "." && $file != ".." && is_dir($file)) {
				$folders[] = $file;
			}
		}
		closedir($handle);
	}
	rsort($folders);
	return $folders;
}

$folders = readCurrentDirectory();

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title></title>
<style type="text/css">
<!--
body {
	font-family: Georgia, "Times New Roman", Times, serif;
	font-size: 12px;
}
-->
</style>
</head>

<body>
<table width="1000" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="18%" align="left" valign="top">&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;<img src="logo.png" alt="logo" /></td>
    <td width="82%" align="left" valign="top"><br />
        <br />
          <br />
        <br />
        <br />
        <br />
      <br />
    <?
	for ($i = 0; $i < sizeof($folders); $i ++)
	{
		$f = $folders[$i];
		$a = explode("_", $f, 2);
		if ((sizeof($a) == 2) && (strlen($a[0]) >= 6))
		{
			echo "" . formatDate($a[0]) . " - ";
			echo "<a href=\"" . $f . "/\">" . utf8_encode(urldecode($a[1])) . "</a>";
			echo "<br/>";
		}
	}
	?>  
  </tr>
</table>
<br />
<br />
</body>
</html>
