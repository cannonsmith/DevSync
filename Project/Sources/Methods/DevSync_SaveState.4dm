//%attributes = {"folder":"DevSync","lang":"en"}
//This method saves the DevSync state back to disk.

C_TEXT($tJSONString)

$tJSONString:=JSON Stringify(Form.DevSyncObject; *)
TEXT TO DOCUMENT(Form.path.DevSyncState; $tJSONString; "UTF-8")
