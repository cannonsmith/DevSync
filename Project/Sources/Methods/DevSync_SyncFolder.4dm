//%attributes = {"folder":"DevSync","lang":"en"}
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

C_OBJECT($1; $oSyncInfo)
C_TEXT($2; $tSyncFolderName)

$oSyncInfo:=$1
$tSyncFolderName:=$2

C_TEXT($tChildFolderName; $tMethodName; $tTargetMethodFolder; $tTargetFormFolder; $tFilepath)
C_TEXT($tClassName; $tTargetClassFolder; $tCurrentDocumentationFolder; $tTargetMethodDocsFolder)
C_TEXT($tFolderpath; $tFormName; $tFolderName; $tCurrentSourceFolder; $tTargetSourceFolder)
C_TEXT($tTargetClassDocsFolder; $tTargetFormDocsFolder)
C_OBJECT($oThisFolder; $oTargetFolder; $oTargetFoldersJSON)
ARRAY TEXT($atSourceChildFolders; 0)
ARRAY TEXT($atSourceMethods; 0)
ARRAY TEXT($atSourceClasses; 0)
ARRAY TEXT($atSourceForms; 0)

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
$oThisFolder:=Form.ProjectFoldersObject[$tSyncFolderName]

//We want child folders to be processed first, so we call this method reciprocally for
//each child that exists.
If ($oThisFolder.groups#Null)
	For each ($tChildFolderName; $oThisFolder.groups)
		DevSync_SyncFolder($oSyncInfo; $tChildFolderName)
		APPEND TO ARRAY($atSourceChildFolders; $tChildFolderName)  //Remember this for later in this method
		$oSyncInfo.added.groups.push($tChildFolderName)  //And for the entire project
	End for each 
End if 


//Copy methods from the current project into the target project
If ($oThisFolder.methods#Null)
	For each ($tMethodName; $oThisFolder.methods)
		
		CREATE FOLDER($tTargetMethodFolder; *)  //Ensure folder exists. Command does nothing if it already exists.
		
		$tFilepath:=$tCurrentSourceFolder+"Methods"+Folder separator+$tMethodName+".4dm"
		COPY DOCUMENT($tFilepath; $tTargetMethodFolder; *)  //Replaces if it already exists
		APPEND TO ARRAY($atSourceMethods; $tMethodName)  //Remember this for later in this method
		$oSyncInfo.added.methods.push($tMethodName)  //And for the entire project
		
		//Copy the documentation, if it exists, as well
		$tFilepath:=$tCurrentDocumentationFolder+"Methods"+Folder separator+$tMethodName+".md"
		If (Test path name($tFilepath)=Is a document)
			CREATE FOLDER($tTargetMethodDocsFolder; *)  //Ensure folder exists. Command does nothing if it already exists.
			COPY DOCUMENT($tFilepath; $tTargetMethodDocsFolder; *)  //Replaces if it already exists
			//No need to track the documentation separately from the method itself
		End if 
		
	End for each 
End if 


//Copy classes from the current project into the target project
If ($oThisFolder.classes#Null)
	For each ($tClassName; $oThisFolder.classes)
		
		CREATE FOLDER($tTargetClassFolder; *)  //Ensure folder exists. Command does nothing if it already exists.
		
		$tFilepath:=$tCurrentSourceFolder+"Classes"+Folder separator+$tClassName+".4dm"
		COPY DOCUMENT($tFilepath; $tTargetClassFolder; *)  //Replaces if it already exists
		APPEND TO ARRAY($atSourceClasses; $tClassName)  //Remember this for later in this method
		$oSyncInfo.added.classes.push($tClassName)  //And for the entire project
		
		//Copy the documentation, if it exists, as well
		$tFilepath:=$tCurrentSourceFolder+"Classes"+Folder separator+$tClassName+".4dm"
		If (Test path name($tFilepath)=Is a document)
			CREATE FOLDER($tTargetClassDocsFolder; *)  //Ensure folder exists. Command does nothing if it already exists.
			COPY DOCUMENT($tFilepath; $tTargetClassFolder; *)  //Replaces if it already exists
			//No need to track the documentation separately from the class itself
		End if 
		
	End for each 
End if 


//Copy forms
If ($oThisFolder.forms#Null)
	For each ($tFormName; $oThisFolder.forms)
		
		CREATE FOLDER($tTargetFormFolder; *)  //Ensure folder exists. Command does nothing if it already exists.
		
		$tFolderpath:=$tCurrentSourceFolder+"Forms"+Folder separator+$tFormName+Folder separator
		COPY DOCUMENT($tFolderpath; $tTargetFormFolder; *)  //Replaces it if it already exists
		APPEND TO ARRAY($atSourceForms; $tFormName)  //Remember this for later in this method
		$oSyncInfo.added.forms.push($tFormName)  //And for the entire project
		
		//Copy the documentation, if it exists, as well
		$tFolderpath:=$tCurrentSourceFolder+"Forms"+Folder separator+$tFormName+Folder separator
		If (Test path name($tFolderpath)=Is a folder)
			CREATE FOLDER($tTargetFormDocsFolder; *)  //Ensure folder exists. Command does nothing if it already exists.
			COPY DOCUMENT($tFolderpath; $tTargetFormFolder; *)  //Replaces it if it already exists
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
If ($oTargetFolder#Null)
	If ($oTargetFolder.groups#Null)
		For each ($tFolderName; $oTargetFolder.groups)
			If (Find in array($atSourceChildFolders; $tFolderName)=-1)  //This is a child folder that ay need to be removed
				
				$oSyncInfo.remove.groups.push($tFolderName)  //Mark for possible removal
				$oSyncInfo.remove.groupObjects[$tFolderName]:=OB Copy($oTargetFolder)  //Grab the folder object as it is now
				
			End if 
		End for each 
	End if 
End if 


//Mark methods for possible removal
If ($oTargetFolder#Null)
	If ($oTargetFolder.methods#Null)
		For each ($tMethodName; $oTargetFolder.methods)
			If (Find in array($atSourceMethods; $tMethodName)=-1)  //This is a method that needs to be removed
				
				$oSyncInfo.remove.methods.push($tMethodName)  //Mark for possible removal
				
			End if 
		End for each 
	End if 
End if 


//Mark classes for possible removal
If ($oTargetFolder#Null)
	If ($oTargetFolder.classes#Null)
		For each ($tClassName; $oTargetFolder.classes)
			If (Find in array($atSourceClasses; $tClassName)=-1)  //This is a class that needs to be removed
				
				$oSyncInfo.remove.classes.push($tClassName)  //Mark for possible removal
				
			End if 
		End for each 
	End if 
End if 


//Mark forms for possible removal
If ($oTargetFolder#Null)
	If ($oTargetFolder.forms#Null)
		For each ($tFormName; $oTargetFolder.forms)
			If (Find in array($atSourceForms; $tFormName)=-1)  //This is a form that needs to be removed
				
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
$oTargetFoldersJSON[$tSyncFolderName]:=OB Copy($oThisFolder)


