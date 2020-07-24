//%attributes = {}
  //Given the passed in folder, add all nested descendents to the passed in
  //collection.

C_TEXT:C284($1;$tFolderName)
C_COLLECTION:C1488($2;$cDescendents)

$tFolderName:=$1
$cDescendents:=$2

C_TEXT:C284($tChildFolderName)
C_OBJECT:C1216($oFolder)

$oFolder:=Form:C1466.ProjectFoldersObject[$tFolderName]
If ($oFolder#Null:C1517)
	
	If ($oFolder.groups#Null:C1517)
		
		For each ($tChildFolderName;$oFolder.groups)
			
			$cDescendents.push($tChildFolderName)
			DevSync_FolderDescendents ($tChildFolderName;$cDescendents)
			
		End for each 
		
	End if 
	
End if 
