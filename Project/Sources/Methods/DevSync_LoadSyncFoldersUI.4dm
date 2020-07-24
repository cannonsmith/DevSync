//%attributes = {}
/* Build the list of sync folders for the UI. This comes from the DevSync state object
and is a simple copy
*/

C_OBJECT:C1216($oThisProject)

$oThisProject:=DevSync_ThisProject 
Form:C1466.UI.SyncFolderList:=$oThisProject.selectedFolders.copy()
