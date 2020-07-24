//%attributes = {}
/* Build the list of projects for the UI. This includes all the projects from the DevSync
state object except the current project.
*/

C_OBJECT:C1216($oProject;$oThisProject;$oUIProject)
C_COLLECTION:C1488($cPath)

$oThisProject:=DevSync_ThisProject 

Form:C1466.UI.Projects:=New collection:C1472
For each ($oProject;Form:C1466.DevSyncObject.projectPaths)
	If ($oProject.path#Form:C1466.path.thisProject)  //Don't add the current project
		$oUIProject:=New object:C1471
		$oUIProject.path:=$oProject.path
		If ($oThisProject.selectedProjects.indexOf($oProject.path)=-1)
			$oUIProject.selected:=False:C215
		Else 
			$oUIProject.selected:=True:C214
		End if 
		$cPath:=Split string:C1554($oProject.path;Folder separator:K24:12)
		$oUIProject.label:=$cPath[$cPath.length-1]
		Form:C1466.UI.Projects.push($oUIProject)
	End if 
End for each 
