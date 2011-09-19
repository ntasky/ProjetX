fl.outputPanel.clear();
var output = "";
var loaderIndex = -1;

// search fot the loader
for (var i=0; i < fl.documents.length; i++)
{
	if (fl.documents[i].name == "loader.fla" || fl.documents[i].name == "loader.xfl")
	{
		loaderIndex = i;
	}
}

if (loaderIndex != -1)
{
	for (var i=0; i < fl.documents.length; i++)
	{
		// publish the core
		if (i != loaderIndex)
		{
			//add the script for the versioning number
			
			var path = fl.documents[i].path;
			var pathElements = path.split("\\");
			var versionNumber;
			for (var j = pathElements.length - 1; j > 0 ; j--)
			{
				versionNumber = parseFloat(pathElements[j]);
				if (!isNaN(versionNumber)) break;
			}
			
			var actions = fl.documents[i].timelines[0].layers[0].frames[0];
			var savedLength = actions.actionScript.length;
			if (savedLength > 0)
			{
				actions.actionScript += "\nvar versionNumber:int = " + versionNumber + ";";
			}
			else
			{
				actions.actionScript = "var versionNumber:int = " + versionNumber + ";";
			}
			
			fl.documents[i].publish();
			actions.actionScript = actions.actionScript.substring(0, savedLength);
		}
	}
	
	// test by publishing the loader
	fl.documents[loaderIndex].testMovie();
	output += "publish V." + versionNumber + " ok !\n";
}
else
{
	output += "loader was not found"
}

fl.trace(output);