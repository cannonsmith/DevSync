C_LONGINT($lIndex)
C_TEXT($tSelectedPath)
C_OBJECT($oProject)

If (Form.UI.ProjectCurrentItem#Null)
	$tSelectedPath:=Form.UI.ProjectCurrentItem.path
	
	//Remove from the listbox UI
	$lIndex:=Form.UI.ProjectCurrentPosition-1
	Form.UI.Projects.remove($lIndex)
	
	//Find and remove from the DevSync state object
	$oProject:=Form.DevSyncObject.projectPaths.query("path = :1"; $tSelectedPath)[0]
	$lIndex:=Form.DevSyncObject.projectPaths.indexOf($oProject)
	Form.DevSyncObject.projectPaths.remove($lIndex)
	
	//Also remove from any selections
	For each ($oProject; Form.DevSyncObject.projectPaths)
		
		$lIndex:=$oProject.selectedProjects.indexOf($tSelectedPath)
		If ($lIndex#-1)
			$oProject.selectedProjects.remove($lIndex)
		End if 
		
	End for each 
	
	//Save to disk
	DevSync_SaveState
	
	
End if 
