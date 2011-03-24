fl.outputPanel.clear();
var output = "";
var loaderIndex = -1;

for (var i=0; i < fl.documents.length; i++)
{
	if (fl.documents[i].name == "loader.fla")
	{
		loaderIndex = i
	}
}

if (loaderIndex != -1)
{
	for (var i=0; i < fl.documents.length; i++)
	{
		if (i != loaderIndex)
		{
			fl.documents[i].publish();
			output += fl.documents[i].name + ": export ok !\n";
		}
	}
	fl.documents[loaderIndex].testMovie();
	output += fl.documents[loaderIndex].name + ": publish ok !\n";
}
else
{
	output += "loader.fla was not found"
}

fl.trace(output);