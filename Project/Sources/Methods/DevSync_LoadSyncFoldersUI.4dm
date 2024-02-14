//%attributes = {"folder":"DevSync","lang":"en"}
/* Build the list of sync folders for the UI. This comes from the DevSync state object
and is a simple copy
*/

C_OBJECT($oThisProject)

$oThisProject:=DevSync_ThisProject
Form.UI.SyncFolderList:=$oThisProject.selectedFolders.copy()
