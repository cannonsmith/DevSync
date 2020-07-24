C_OBJECT:C1216($oProject)

If (Form:C1466.UI.SyncFolderCurrentPosition>0)
	
	  //Remove from UI
	Form:C1466.UI.SyncFolderList.remove(Form:C1466.UI.SyncFolderCurrentPosition-1)
	
	  //Update the DevSync state object
	$oProject:=DevSync_ThisProject 
	$oProject.selectedFolders:=Form:C1466.UI.SyncFolderList.copy()  //Just copy UI list back
	
	  //Save to disk
	DevSync_SaveState 
	
End if 
