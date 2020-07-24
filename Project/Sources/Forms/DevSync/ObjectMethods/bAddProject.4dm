C_OBJECT:C1216($oProject;$oUIProject)
C_COLLECTION:C1488($cPath)
C_TEXT:C284($tFilename;$tFilepath)
ARRAY TEXT:C222($atPaths;0)

$tFilename:=Select document:C905("";".4DProject";"Choose the .4DProject file to add";Package open:K24:8+Use sheet window:K24:11;$atPaths)
If ((OK=1) & (Size of array:C274($atPaths)>0))
	$tFilepath:=$atPaths{1}
	If (Form:C1466.DevSyncObject.projectPaths.query("path = :1";$tFilepath).length=0)  //If it isn't already there
		
		  //Add to the DevSync state object as another project and save to disk
		$oProject:=New object:C1471
		$oProject.path:=$tFilepath
		$oProject.selectedProjects:=New collection:C1472  //Start without any selected projects to target
		$oProject.selectedFolders:=New collection:C1472
		Form:C1466.DevSyncObject.projectPaths.push($oProject)
		DevSync_SaveState 
		
		  //Add to the listbox in the UI
		$oUIProject:=New object:C1471
		$oUIProject.path:=$tFilepath
		$oUIProject.selected:=False:C215
		$cPath:=Split string:C1554($tFilepath;Folder separator:K24:12)
		$oUIProject.label:=$cPath[$cPath.length-1]
		Form:C1466.UI.Projects.push($oUIProject)
		
	End if 
End if 
