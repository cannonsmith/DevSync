//%attributes = {"folder":"DevSync","lang":"en"}
//Given the passed in folder, add all nested descendents to the passed in
//collection.

C_TEXT($1; $tFolderName)
C_COLLECTION($2; $cDescendents)

$tFolderName:=$1
$cDescendents:=$2

C_TEXT($tChildFolderName)
C_OBJECT($oFolder)

$oFolder:=Form.ProjectFoldersObject[$tFolderName]
If ($oFolder#Null)
	
	If ($oFolder.groups#Null)
		
		For each ($tChildFolderName; $oFolder.groups)
			
			$cDescendents.push($tChildFolderName)
			DevSync_FolderDescendents($tChildFolderName; $cDescendents)
			
		End for each 
		
	End if 
	
End if 
