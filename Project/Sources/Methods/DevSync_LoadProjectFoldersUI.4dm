//%attributes = {"folder":"DevSync","lang":"en"}
//Get a list of all the folders in this project. We keep the entire folders.json file in
//memory as well as convert the list of folders into a collection for the UI.

C_LONGINT($x)
C_TEXT($tJSONString; $tSearch)

//Load the entire folders.json file into an object
$tJSONString:=Document to text(Form.path.foldersJSON)
Form.ProjectFoldersObject:=JSON Parse($tJSONString)


/* We want to use a collection in the listbox that lists all the folders in the project so we
aren't dealing with arrays (process vars). And we want each element to be an object so we
can more easily search. So we do a little manipulating to prepare the two collections used
for the folder listbox.
*/
OB GET PROPERTY NAMES(Form.ProjectFoldersObject; $atFolders)
Form.UI.AllFolderList:=New collection
For ($x; 1; Size of array($atFolders))
	Form.UI.AllFolderList.push(New object("name"; $atFolders{$x}))
End for 
Form.UI.VisibleFolderList:=Form.UI.AllFolderList  //Start by showing all folders.


/*Check to see if there is a search string. If so, we respect that since this method can run
  after the window is already loaded.
*/
$tSearch:=OBJECT Get pointer(Object named; "FolderSearch")->
If ($tSearch#"")
	$tSearch:="@"+$tSearch+"@"
	Form.UI.VisibleFolderList:=Form.UI.AllFolderList.query("name = :1"; $tSearch)
End if 
