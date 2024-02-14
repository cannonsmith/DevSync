//%attributes = {"folder":"DevSync","lang":"en"}
/* Build the list of projects for the UI. This includes all the projects from the DevSync
state object except the current project.
*/

C_OBJECT($oProject; $oThisProject; $oUIProject)
C_COLLECTION($cPath)

$oThisProject:=DevSync_ThisProject

Form.UI.Projects:=New collection
For each ($oProject; Form.DevSyncObject.projectPaths)
	If ($oProject.path#Form.path.thisProject)  //Don't add the current project
		$oUIProject:=New object
		$oUIProject.path:=$oProject.path
		If ($oThisProject.selectedProjects.indexOf($oProject.path)=-1)
			$oUIProject.selected:=False
		Else 
			$oUIProject.selected:=True
		End if 
		$cPath:=Split string($oProject.path; Folder separator)
		$oUIProject.label:=$cPath[$cPath.length-1]
		Form.UI.Projects.push($oUIProject)
	End if 
End for each 
