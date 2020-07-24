//%attributes = {}
/* Returns the object in DevSyncObject.projectPaths that represents the currently
running project.
*/

C_OBJECT:C1216($0;$oThisProject)

C_COLLECTION:C1488($cProjects)

$cProjects:=Form:C1466.DevSyncObject.projectPaths.query("path = :1";Form:C1466.path.thisProject)
If ($cProjects.length>0)
	$oThisProject:=$cProjects[0]
End if 

$0:=$oThisProject
