//%attributes = {}
/* If the sync process comes across a child folder that exists in the target project, but not in
the current project, this method is called to remove it. This is done by marking the folder's
contents for removal. The folder itself, in the folders.json file, will have already been removed
because of the way the other methods update that file.
*/

C_OBJECT:C1216($1;$oSyncInfo)
C_TEXT:C284($2;$tChildFolderName)

$oSyncInfo:=$1
$tChildFolderName:=$2

C_TEXT:C284($tFolderName;$tFormName;$tMethodName;$tClassName)
C_OBJECT:C1216($oChildFolderInfo)

  //Get a folder info as it was before things changed
$oChildFolderInfo:=$oSyncInfo.remove.groupObjects[$tChildFolderName]


  //Recursively remove child folders
If ($oChildFolderInfo.groups#Null:C1517)
	For each ($tFolderName;$oChildFolderInfo.groups)
		If ($oSyncInfo.added.groups.indexOf($tFolderName)=-1)  //Not added anywhere else
			
			DevSync_RemoveChildFolder ($oSyncInfo;$tFolderName)  //Recursively remove children folders
			
		End if 
	End for each 
End if 


  //Mark methods for removal
If ($oChildFolderInfo.methods#Null:C1517)
	For each ($tMethodName;$oChildFolderInfo.methods)
		
		$oSyncInfo.remove.methods.push($tMethodName)  //Mark for possible removal
		
	End for each 
End if 


  //Mark classes for removal
If ($oChildFolderInfo.classes#Null:C1517)
	For each ($tClassName;$oChildFolderInfo.classes)
		
		$oSyncInfo.remove.classes.push($tClassName)  //Mark for possible removal
		
	End for each 
End if 


  //Mark forms for removal
If ($oChildFolderInfo.forms#Null:C1517)
	For each ($tFormName;$oChildFolderInfo.forms)
		
		$oSyncInfo.remove.forms.push($tFormName)  //Mark for possible removal
		
	End for each 
End if 
