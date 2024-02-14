//%attributes = {"folder":"DevSync","lang":"en"}
/* Returns the object in DevSyncObject.projectPaths that represents the currently
running project.
*/

C_OBJECT($0; $oThisProject)

C_COLLECTION($cProjects)

$cProjects:=Form.DevSyncObject.projectPaths.query("path = :1"; Form.path.thisProject)
If ($cProjects.length>0)
	$oThisProject:=$cProjects[0]
End if 

$0:=$oThisProject
