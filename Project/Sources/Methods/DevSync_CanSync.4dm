//%attributes = {}
  //Checks several things to ensure the sync will be successful.

C_BOOLEAN:C305($0;$fCanSync)

$fCanSync:=True:C214

C_TEXT:C284($tFolderName;$tInnerLoopFolderName;$tOuterLoopFolderName)
C_OBJECT:C1216($oProject)
C_COLLECTION:C1488($cDescendents)

  //Before we check to see if we can sync, we want to make sure our list of this projects folders is up to date
DevSync_LoadProjectFoldersUI 


  //Ensure that each selected target project exists
For each ($oProject;Form:C1466.UI.Projects) While ($fCanSync=True:C214)
	
	If ($oProject.selected=True:C214)  //We don't care to check projects that aren't selected as a target since they don't matter
		If (Test path name:C476($oProject.path)#Is a document:K24:1)
			ALERT:C41($oProject.label+" doesn't exist and should be removed from the list of targets.")
			$fCanSync:=False:C215
		End if 
	End if 
	
End for each 


  //Ensure they have some folders to sync
If ($fCanSync=True:C214)
	
	If (Form:C1466.UI.SyncFolderList.length=0)
		ALERT:C41("You need to add one or more folders to the sync list.")
		$fCanSync:=False:C215
	End if 
	
End if 


/* Ensure that each folder in the sync list exists. The UI was just updated above to ensure the list of folders was
up to date, so we can use the UI to double-check.
*/
For each ($tFolderName;Form:C1466.UI.SyncFolderList) While ($fCanSync=True:C214)
	
	If (Form:C1466.UI.AllFolderList.query("name = :1";$tFolderName).length=0)
		ALERT:C41($tFolderName+" doesn't exist and should be removed from the list of sync folders.")
		$fCanSync:=False:C215
	End if 
	
End for each 


/* Ensure that no folder in the sync folder is a child (or grandchild, etc.) of another folder in the sync folder list
To do this, we loop through each of the sync folders, getting a list of descendents for it. We then check to see
if any of the other folders in the sync folders list is one of the descendents.
*/
For each ($tOuterLoopFolderName;Form:C1466.UI.SyncFolderList) While ($fCanSync=True:C214)
	
	  //Get a list of all the descendents of this folder
	$cDescendents:=New collection:C1472
	DevSync_FolderDescendents ($tOuterLoopFolderName;$cDescendents)
	
	  //Loop through all the sync folders (except this one) and see if any of them are in the descendents list
	For each ($tInnerLoopFolderName;Form:C1466.UI.SyncFolderList) While ($fCanSync=True:C214)
		If ($tInnerLoopFolderName#$tOuterLoopFolderName)  //Ignore itself
			
			If ($cDescendents.indexOf($tInnerLoopFolderName)#-1)  //If this folder is a descendent
				ALERT:C41($tInnerLoopFolderName+" is a descendent of "+$tOuterLoopFolderName+" and should be removed. Parent and descendent folders should not both be added to the sync folders list.")
				$fCanSync:=False:C215
			End if 
			
		End if 
	End for each 
	
	
	If (Form:C1466.UI.AllFolderList.query("name = :1";$tFolderName).length=0)
		ALERT:C41($tFolderName+" doesn't exist and should be removed from the list of sync folders.")
		$fCanSync:=False:C215
	End if 
	
End for each 


  //Make sure the user wants this to happen
If ($fCanSync=True:C214)
	CONFIRM:C162("Are you sure you want to sync the methods and forms that are in the chosen sync folders list from this project to the target projects? This can't be undone.\r\rIMPORTANT: Make sure the target projects are not currently running. 4D doesn't always detect "+"changes between folders until a relaunch, so this is safest.";\
		"Sync Targets";"Cancel")
	If (OK=0)
		$fCanSync:=False:C215
	End if 
End if 



$0:=$fCanSync
