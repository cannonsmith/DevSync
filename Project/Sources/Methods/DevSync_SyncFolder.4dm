//%attributes = {}
/* This method does the most of the work of syncing a folder. It will be called reciprically
to sync its children in such a way that the descendants that are furthest away will be
synced first and then back up the chain to this one.

This method takes care of three steps:
1. Copy child folders, methods, classes, and forms to the target project
2. Mark any child folders, methods, classes, or forms that are in the target project's folder,
   but not in the current project's folder, for possible deletion.
3. Update the target project's folder info (in folders.json) for this folder to match the current
   project's folder info.
*/

C_OBJECT:C1216($1;$oSyncInfo)
C_TEXT:C284($2;$tSyncFolderName)

$oSyncInfo:=$1
$tSyncFolderName:=$2

C_TEXT:C284($tChildFolderName;$tMethodName;$tTargetMethodFolder;$tTargetFormFolder;$tFilepath)
C_TEXT:C284($tClassName;$tTargetClassFolder;$tCurrentDocumentationFolder;$tTargetMethodDocsFolder)
C_TEXT:C284($tFolderpath;$tFormName;$tFolderName;$tCurrentSourceFolder;$tTargetSourceFolder)
C_TEXT:C284($tTargetClassDocsFolder;$tTargetFormDocsFolder)
C_OBJECT:C1216($oThisFolder;$oTargetFolder;$oTargetFoldersJSON)
ARRAY TEXT:C222($atSourceChildFolders;0)
ARRAY TEXT:C222($atSourceMethods;0)
ARRAY TEXT:C222($atSourceClasses;0)
ARRAY TEXT:C222($atSourceForms;0)

  //Pull out the parameters from the Sync Info object
$tCurrentSourceFolder:=$oSyncInfo.CurrentSourceFolder
$tCurrentDocumentationFolder:=$oSyncInfo.CurrentDocumentationFolder
$tTargetSourceFolder:=$oSyncInfo.TargetSourceFolder
$tTargetMethodFolder:=$oSyncInfo.TargetMethodFolder
$tTargetClassFolder:=$oSyncInfo.TargetClassFolder
$tTargetFormFolder:=$oSyncInfo.TargetFormFolder
$tTargetMethodDocsFolder:=$oSyncInfo.TargetMethodDocsFolder
$tTargetClassDocsFolder:=$oSyncInfo.TargetClassDocsFolder
$tTargetFormDocsFolder:=$oSyncInfo.TargetFormDocsFolder
$oTargetFoldersJSON:=$oSyncInfo.TargetFolderJSON


  //Get the object for this folder from the folders.json file
$oThisFolder:=Form:C1466.ProjectFoldersObject[$tSyncFolderName]

  //We want child folders to be processed first, so we call this method reciprocally for
  //each child that exists.
If ($oThisFolder.groups#Null:C1517)
	For each ($tChildFolderName;$oThisFolder.groups)
		DevSync_SyncFolder ($oSyncInfo;$tChildFolderName)
		APPEND TO ARRAY:C911($atSourceChildFolders;$tChildFolderName)  //Remember this for later in this method
		$oSyncInfo.added.groups.push($tChildFolderName)  //And for the entire project
	End for each 
End if 


  //Copy methods from the current project into the target project
If ($oThisFolder.methods#Null:C1517)
	For each ($tMethodName;$oThisFolder.methods)
		
		CREATE FOLDER:C475($tTargetMethodFolder;*)  //Ensure folder exists. Command does nothing if it already exists.
		
		$tFilepath:=$tCurrentSourceFolder+"Methods"+Folder separator:K24:12+$tMethodName+".4dm"
		COPY DOCUMENT:C541($tFilepath;$tTargetMethodFolder;*)  //Replaces if it already exists
		APPEND TO ARRAY:C911($atSourceMethods;$tMethodName)  //Remember this for later in this method
		$oSyncInfo.added.methods.push($tMethodName)  //And for the entire project
		
		  //Copy the documentation, if it exists, as well
		$tFilepath:=$tCurrentDocumentationFolder+"Methods"+Folder separator:K24:12+$tMethodName+".md"
		If (Test path name:C476($tFilepath)=Is a document:K24:1)
			CREATE FOLDER:C475($tTargetMethodDocsFolder;*)  //Ensure folder exists. Command does nothing if it already exists.
			COPY DOCUMENT:C541($tFilepath;$tTargetMethodDocsFolder;*)  //Replaces if it already exists
			  //No need to track the documentation separately from the method itself
		End if 
		
	End for each 
End if 


  //Copy classes from the current project into the target project
If ($oThisFolder.classes#Null:C1517)
	For each ($tClassName;$oThisFolder.classes)
		
		CREATE FOLDER:C475($tTargetClassFolder;*)  //Ensure folder exists. Command does nothing if it already exists.
		
		$tFilepath:=$tCurrentSourceFolder+"Classes"+Folder separator:K24:12+$tClassName+".4dm"
		COPY DOCUMENT:C541($tFilepath;$tTargetClassFolder;*)  //Replaces if it already exists
		APPEND TO ARRAY:C911($atSourceClasses;$tClassName)  //Remember this for later in this method
		$oSyncInfo.added.classes.push($tClassName)  //And for the entire project
		
		  //Copy the documentation, if it exists, as well
		$tFilepath:=$tCurrentSourceFolder+"Classes"+Folder separator:K24:12+$tClassName+".4dm"
		If (Test path name:C476($tFilepath)=Is a document:K24:1)
			CREATE FOLDER:C475($tTargetClassDocsFolder;*)  //Ensure folder exists. Command does nothing if it already exists.
			COPY DOCUMENT:C541($tFilepath;$tTargetClassFolder;*)  //Replaces if it already exists
			  //No need to track the documentation separately from the class itself
		End if 
		
	End for each 
End if 


  //Copy forms
If ($oThisFolder.forms#Null:C1517)
	For each ($tFormName;$oThisFolder.forms)
		
		CREATE FOLDER:C475($tTargetFormFolder;*)  //Ensure folder exists. Command does nothing if it already exists.
		
		$tFolderpath:=$tCurrentSourceFolder+"Forms"+Folder separator:K24:12+$tFormName+Folder separator:K24:12
		COPY DOCUMENT:C541($tFolderpath;$tTargetFormFolder;*)  //Replaces it if it already exists
		APPEND TO ARRAY:C911($atSourceForms;$tFormName)  //Remember this for later in this method
		$oSyncInfo.added.forms.push($tFormName)  //And for the entire project
		
		  //Copy the documentation, if it exists, as well
		$tFolderpath:=$tCurrentSourceFolder+"Forms"+Folder separator:K24:12+$tFormName+Folder separator:K24:12
		If (Test path name:C476($tFolderpath)=Is a folder:K24:2)
			CREATE FOLDER:C475($tTargetFormDocsFolder;*)  //Ensure folder exists. Command does nothing if it already exists.
			COPY DOCUMENT:C541($tFolderpath;$tTargetFormFolder;*)  //Replaces it if it already exists
			  //No need to track the documentation separately from the form itself
		End if 
		
	End for each 
End if 


/* Now that we've copied the assets to the target, we need to see if the target already had
assets in this folder that should no longer be there. If it does, we mark them for deletion.
The actual deletion happens back in DevSync_Sync as the last step so we don't delete any
assets from the project that were simply moved to another folder.
*/

  //Get the target folder object
$oTargetFolder:=$oTargetFoldersJSON[$tSyncFolderName]


  //Mark child folders for possible removal
If ($oTargetFolder#Null:C1517)
	If ($oTargetFolder.groups#Null:C1517)
		For each ($tFolderName;$oTargetFolder.groups)
			If (Find in array:C230($atSourceChildFolders;$tFolderName)=-1)  //This is a child folder that ay need to be removed
				
				$oSyncInfo.remove.groups.push($tFolderName)  //Mark for possible removal
				$oSyncInfo.remove.groupObjects[$tFolderName]:=OB Copy:C1225($oTargetFolder)  //Grab the folder object as it is now
				
			End if 
		End for each 
	End if 
End if 


  //Mark methods for possible removal
If ($oTargetFolder#Null:C1517)
	If ($oTargetFolder.methods#Null:C1517)
		For each ($tMethodName;$oTargetFolder.methods)
			If (Find in array:C230($atSourceMethods;$tMethodName)=-1)  //This is a method that needs to be removed
				
				$oSyncInfo.remove.methods.push($tMethodName)  //Mark for possible removal
				
			End if 
		End for each 
	End if 
End if 


  //Mark classes for possible removal
If ($oTargetFolder#Null:C1517)
	If ($oTargetFolder.classes#Null:C1517)
		For each ($tClassName;$oTargetFolder.classes)
			If (Find in array:C230($atSourceClasses;$tClassName)=-1)  //This is a class that needs to be removed
				
				$oSyncInfo.remove.classes.push($tClassName)  //Mark for possible removal
				
			End if 
		End for each 
	End if 
End if 


  //Mark forms for possible removal
If ($oTargetFolder#Null:C1517)
	If ($oTargetFolder.forms#Null:C1517)
		For each ($tFormName;$oTargetFolder.forms)
			If (Find in array:C230($atSourceForms;$tFormName)=-1)  //This is a form that needs to be removed
				
				$oSyncInfo.remove.forms.push($tFormName)  //Mark for possible removal
				
			End if 
		End for each 
	End if 
End if 


/* Update (or create) this folder information in the target folders.json object. Keep in mind that
this method will be called for the most deeply nested folders first, then their parents, etc. So
at this point we don't need to worry about ensuring this folder is written as the child of another
folder. We only care about the children. It will be written as a child when we move up a level. And
DevSync_Sync takes care of the top level sync folder as a special case. So at this level it is
simply a matter of copying the folder object for this project into the target project as is,
creating it if it doesn't already exist.
*/
$oTargetFoldersJSON[$tSyncFolderName]:=OB Copy:C1225($oThisFolder)


