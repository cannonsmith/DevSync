//%attributes = {"folder":"DevSync","lang":"en"}
/* As explained in DevSync__README, the DevSync state is shared among multiple projects and is
stored on disk. This method loads that state, creating it if needed. It automatically ensure
that the current project is added to the state if it isn't already there.
*/

C_TEXT($tJSONString)
C_OBJECT($oProject)

/* Load the DevSync.json file into memory. If it doesn't exist on disk, create it as an empty
object and save it so we know it (and the full folder path) exists for the rest of the code.
*/
If (Test path name(Form.path.DevSyncState)=Is a document)
	
	$tJSONString:=Document to text(Form.path.DevSyncState)
	Form.DevSyncObject:=JSON Parse($tJSONString)
	
Else 
	
	CREATE FOLDER(Form.path.DevSyncFolder; *)
	Form.DevSyncObject:=New object
	Form.DevSyncObject.projectPaths:=New collection
	DevSync_SaveState
	
End if 


/* We want to make sure this project is in the list of projects in the DevSync state object. If
it isn't, we add it and save back to disk.
*/
If (Form.DevSyncObject.projectPaths.query("path = :1"; Form.path.thisProject).length=0)
	
	$oProject:=New object
	$oProject.path:=Form.path.thisProject
	$oProject.selectedProjects:=New collection  //Start without any selected projects to target
	$oProject.selectedFolders:=New collection
	Form.DevSyncObject.projectPaths.push($oProject)
	DevSync_SaveState
	
End if 
