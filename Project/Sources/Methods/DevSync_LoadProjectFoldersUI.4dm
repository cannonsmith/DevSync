//%attributes = {}
  //Get a list of all the folders in this project. We keep the entire folders.json file in
  //memory as well as convert the list of folders into a collection for the UI.

C_LONGINT:C283($x)
C_TEXT:C284($tJSONString;$tSearch)

  //Load the entire folders.json file into an object
$tJSONString:=Document to text:C1236(Form:C1466.path.foldersJSON)
Form:C1466.ProjectFoldersObject:=JSON Parse:C1218($tJSONString)


/* We want to use a collection in the listbox that lists all the folders in the project so we
aren't dealing with arrays (process vars). And we want each element to be an object so we
can more easily search. So we do a little manipulating to prepare the two collections used
for the folder listbox.
*/
OB GET PROPERTY NAMES:C1232(Form:C1466.ProjectFoldersObject;$atFolders)
Form:C1466.UI.AllFolderList:=New collection:C1472
For ($x;1;Size of array:C274($atFolders))
	Form:C1466.UI.AllFolderList.push(New object:C1471("name";$atFolders{$x}))
End for 
Form:C1466.UI.VisibleFolderList:=Form:C1466.UI.AllFolderList  //Start by showing all folders.


/*Check to see if there is a search string. If so, we respect that since this method can run
  after the window is already loaded.
*/
$tSearch:=OBJECT Get pointer:C1124(Object named:K67:5;"FolderSearch")->
If ($tSearch#"")
	$tSearch:="@"+$tSearch+"@"
	Form:C1466.UI.VisibleFolderList:=Form:C1466.UI.AllFolderList.query("name = :1";$tSearch)
End if 
