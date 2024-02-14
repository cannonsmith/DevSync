//%attributes = {"folder":"DevSync","lang":"en"}
//Initialize the model for the form. The form object definitions can be found in DevSync__README.


//Calculate static paths and store in the form object so we don't have to recalculate every time we access.
Form.path:=New object

Form.path.DevSyncFolder:=System folder(User preferences_user)+"4D"+Folder separator+"DevSync"+Folder separator

Form.path.DevSyncState:=Form.path.DevSyncFolder+"DevSync.json"

Form.path.foldersJSON:=Get 4D folder(Database folder)+"Project"+Folder separator+"Sources"+Folder separator+\
"folders.json"

Form.path.thisProject:=Structure file


//Much of the UI related state will be in Form.UI, so we get that object created before it is needed
Form.UI:=New object
