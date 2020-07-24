C_TEXT:C284($tFolderName)
C_OBJECT:C1216($oProject)
C_BLOB:C604($xBlob)

Case of 
	: (Form event code:C388=On Drag Over:K2:13)  //From lbProjectFolders listbox
		  //The name of the folder being dragged will be in the "4DDD" pasteboard as a blob
		GET PASTEBOARD DATA:C401("4DDD";$xBlob)
		If (BLOB size:C605($xBlob)>0)
			$0:=0
		Else 
			$0:=-1
		End if 
		
	: (Form event code:C388=On Drop:K2:12)  //From lbProjectFolders listbox
		  //The name of the folder being dragged will be in the "4DDD" pasteboard as a blob
		GET PASTEBOARD DATA:C401("4DDD";$xBlob)
		If (BLOB size:C605($xBlob)>0)
			$tFolderName:=BLOB to text:C555($xBlob;UTF8 text without length:K22:17)
			If (Form:C1466.UI.SyncFolderList.indexOf($tFolderName)=-1)  //If it isn't already in the list
				
				  //Add it to the UI list
				Form:C1466.UI.SyncFolderList.push($tFolderName)
				
				  //Add it to the DevSync object
				$oProject:=DevSync_ThisProject 
				$oProject.selectedFolders:=Form:C1466.UI.SyncFolderList.copy()
				
				  //Save to disk
				DevSync_SaveState 
				
				
			End if 
		End if 
		
		
	: (Form event code:C388=On Double Clicked:K2:5)  //Another way of removing a folder
		If (Form:C1466.UI.SyncFolderCurrentPosition>0)
			
			  //Remove from UI
			Form:C1466.UI.SyncFolderList.remove(Form:C1466.UI.SyncFolderCurrentPosition-1)
			
			  //Add it to the DevSync object
			$oProject:=DevSync_ThisProject 
			$oProject.selectedFolders:=Form:C1466.UI.SyncFolderList.copy()
			
			  //Save to disk
			DevSync_SaveState 
			
		End if 
		
		
End case 
