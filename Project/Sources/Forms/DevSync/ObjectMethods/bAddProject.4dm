C_OBJECT($oProject; $oUIProject)
C_COLLECTION($cPath)
C_TEXT($tFilename; $tFilepath)
ARRAY TEXT($atPaths; 0)

$tFilename:=Select document(""; ".4DProject"; "Choose the .4DProject file to add"; Package open+Use sheet window; $atPaths)
If ((OK=1) & (Size of array($atPaths)>0))
	$tFilepath:=$atPaths{1}
	If (Form.DevSyncObject.projectPaths.query("path = :1"; $tFilepath).length=0)  //If it isn't already there
		
		//Add to the DevSync state object as another project and save to disk
		$oProject:=New object
		$oProject.path:=$tFilepath
		$oProject.selectedProjects:=New collection  //Start without any selected projects to target
		$oProject.selectedFolders:=New collection
		Form.DevSyncObject.projectPaths.push($oProject)
		DevSync_SaveState
		
		//Add to the listbox in the UI
		$oUIProject:=New object
		$oUIProject.path:=$tFilepath
		$oUIProject.selected:=False
		$cPath:=Split string($tFilepath; Folder separator)
		$oUIProject.label:=$cPath[$cPath.length-1]
		Form.UI.Projects.push($oUIProject)
		
	End if 
End if 
