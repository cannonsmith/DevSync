C_LONGINT:C283($lIndex)
C_TEXT:C284($tSelectedPath)
C_OBJECT:C1216($oProject)

If (Form:C1466.UI.ProjectCurrentItem#Null:C1517)
	$tSelectedPath:=Form:C1466.UI.ProjectCurrentItem.path
	
	  //Remove from the listbox UI
	$lIndex:=Form:C1466.UI.ProjectCurrentPosition-1
	Form:C1466.UI.Projects.remove($lIndex)
	
	  //Find and remove from the DevSync state object
	$oProject:=Form:C1466.DevSyncObject.projectPaths.query("path = :1";$tSelectedPath)[0]
	$lIndex:=Form:C1466.DevSyncObject.projectPaths.indexOf($oProject)
	Form:C1466.DevSyncObject.projectPaths.remove($lIndex)
	
	  //Also remove from any selections
	For each ($oProject;Form:C1466.DevSyncObject.projectPaths)
		
		$lIndex:=$oProject.selectedProjects.indexOf($tSelectedPath)
		If ($lIndex#-1)
			$oProject.selectedProjects.remove($lIndex)
		End if 
		
	End for each 
	
	  //Save to disk
	DevSync_SaveState 
	
	
End if 
