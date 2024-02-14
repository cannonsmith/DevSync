/* When a target checkbox is changed, we brute force rebuild the entire selectedProjects
key in the DevSync sate object for the current project and then save to disk.
*/

C_OBJECT($oThisProject; $oTargetProject)
C_COLLECTION($cSelectedProjects)

//Loop through entire listbox, adding selected projects
$cSelectedProjects:=New collection
For each ($oTargetProject; Form.UI.Projects)
	If ($oTargetProject.selected=True)
		$cSelectedProjects.push($oTargetProject.path)
	End if 
End for each 

//Find the current project in DevSync object and set the selectedProjects collection
$oThisProject:=DevSync_ThisProject
$oThisProject.selectedProjects:=$cSelectedProjects

//Save to disk
DevSync_SaveState
