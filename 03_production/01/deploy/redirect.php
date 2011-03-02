<?

// This script is used to refresh the HTML page when changing language (in PagesManager._onChangeSWFAddress)
// It can also be used to share deep links on sites like Facebook that ignore everything after the #
//
// For example, to go to the page #/contact/ you can use:
// redirect.php?/contact/
//

$page = $_SERVER['QUERY_STRING'];
$url = $_SERVER['PHP_SELF'];
$parts = explode("/", $url);
$parts[sizeof($parts) - 1] = "#" . $page;
$url = implode("/", $parts);
header('Location: ' . $url);
?>