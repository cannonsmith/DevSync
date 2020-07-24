//%attributes = {}
  //This method saves the DevSync state back to disk.

C_TEXT:C284($tJSONString)

$tJSONString:=JSON Stringify:C1217(Form:C1466.DevSyncObject;*)
TEXT TO DOCUMENT:C1237(Form:C1466.path.DevSyncState;$tJSONString;"UTF-8")
