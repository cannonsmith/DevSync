C_TEXT($tFolderName)
C_OBJECT($oProject)
C_BLOB($xBlob)

Case of 
	: (Form event code=On Drag Over)  //From lbProjectFolders listbox
		//The name of the folder being dragged will be in the "4DDD" pasteboard as a blob
		GET PASTEBOARD DATA("4DDD"; $xBlob)
		If (BLOB size($xBlob)>0)
			$0:=0
		Else 
			$0:=-1
		End if 
		
	: (Form event code=On Drop)  //From lbProjectFolders listbox
		//The name of the folder being dragged will be in the "4DDD" pasteboard as a blob
		GET PASTEBOARD DATA("4DDD"; $xBlob)
		If (BLOB size($xBlob)>0)
			$tFolderName:=BLOB to text($xBlob; UTF8 text without length)
			If (Form.UI.SyncFolderList.indexOf($tFolderName)=-1)  //If it isn't already in the list
				
				//Add it to the UI list
				Form.UI.SyncFolderList.push($tFolderName)
				
				//Add it to the DevSync object
				$oProject:=DevSync_ThisProject
				$oProject.selectedFolders:=Form.UI.SyncFolderList.copy()
				
				//Save to disk
				DevSync_SaveState
				
				
			End if 
		End if 
		
		
	: (Form event code=On Double Clicked)  //Another way of removing a folder
		If (Form.UI.SyncFolderCurrentPosition>0)
			
			//Remove from UI
			Form.UI.SyncFolderList.remove(Form.UI.SyncFolderCurrentPosition-1)
			
			//Add it to the DevSync object
			$oProject:=DevSync_ThisProject
			$oProject.selectedFolders:=Form.UI.SyncFolderList.copy()
			
			//Save to disk
			DevSync_SaveState
			
		End if 
		
		
End case 
