C_OBJECT($oProject)

If (Form.UI.SyncFolderCurrentPosition>0)
	
	//Remove from UI
	Form.UI.SyncFolderList.remove(Form.UI.SyncFolderCurrentPosition-1)
	
	//Update the DevSync state object
	$oProject:=DevSync_ThisProject
	$oProject.selectedFolders:=Form.UI.SyncFolderList.copy()  //Just copy UI list back
	
	//Save to disk
	DevSync_SaveState
	
End if 
