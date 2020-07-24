//%attributes = {}
/* As explained in DevSync__README, the DevSync state is shared among multiple projects and is
stored on disk. This method loads that state, creating it if needed. It automatically ensure
that the current project is added to the state if it isn't already there.
*/

C_TEXT:C284($tJSONString)
C_OBJECT:C1216($oProject)

/* Load the DevSync.json file into memory. If it doesn't exist on disk, create it as an empty
object and save it so we know it (and the full folder path) exists for the rest of the code.
*/
If (Test path name:C476(Form:C1466.path.DevSyncState)=Is a document:K24:1)
	
	$tJSONString:=Document to text:C1236(Form:C1466.path.DevSyncState)
	Form:C1466.DevSyncObject:=JSON Parse:C1218($tJSONString)
	
Else 
	
	CREATE FOLDER:C475(Form:C1466.path.DevSyncFolder;*)
	Form:C1466.DevSyncObject:=New object:C1471
	Form:C1466.DevSyncObject.projectPaths:=New collection:C1472
	DevSync_SaveState 
	
End if 


/* We want to make sure this project is in the list of projects in the DevSync state object. If
it isn't, we add it and save back to disk.
*/
If (Form:C1466.DevSyncObject.projectPaths.query("path = :1";Form:C1466.path.thisProject).length=0)
	
	$oProject:=New object:C1471
	$oProject.path:=Form:C1466.path.thisProject
	$oProject.selectedProjects:=New collection:C1472  //Start without any selected projects to target
	$oProject.selectedFolders:=New collection:C1472
	Form:C1466.DevSyncObject.projectPaths.push($oProject)
	DevSync_SaveState 
	
End if 
