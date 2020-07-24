//%attributes = {}
  //Initialize the model for the form. The form object definitions can be found in DevSync__README.


  //Calculate static paths and store in the form object so we don't have to recalculate every time we access.
Form:C1466.path:=New object:C1471

Form:C1466.path.DevSyncFolder:=System folder:C487(User preferences_user:K41:4)+"4D"+Folder separator:K24:12+"DevSync"+Folder separator:K24:12

Form:C1466.path.DevSyncState:=Form:C1466.path.DevSyncFolder+"DevSync.json"

Form:C1466.path.foldersJSON:=Get 4D folder:C485(Database folder:K5:14)+"Project"+Folder separator:K24:12+"Sources"+Folder separator:K24:12+\
"folders.json"

Form:C1466.path.thisProject:=Structure file:C489


  //Much of the UI related state will be in Form.UI, so we get that object created before it is needed
Form:C1466.UI:=New object:C1471
