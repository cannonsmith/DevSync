C_BLOB($xBlob)
C_TEXT($tFolderName; $tSystemFont; $tRef; $tSVGRef)
C_OBJECT($oProject)
C_PICTURE($gChart)

Case of 
	: (Form event code=On Begin Drag Over)  //To lbSyncFolders
		//Get the name of the folder they are dragging and put it into a "4DDD" pasteboard as blob
		$tFolderName:=Form.UI.VisibleFolderCurrentItem.name
		TEXT TO BLOB($tFolderName; $xBlob; UTF8 text without length)
		CLEAR PASTEBOARD
		APPEND DATA TO PASTEBOARD("4DDD"; $xBlob)
		$0:=0
		
		//Change the drag icon to be a picture of the folder name they are dragging
		$tSystemFont:=OBJECT Get font(*; "")  //Returns the system font
		$tSVGRef:=SVG_New(200; 17)  //Listbox cell size, so it should fit
		$tRef:=SVG_New_textArea($tSVGRef; $tFolderName; 0; 0; 200; 17; $tSystemFont; 13; Plain; Align left)
		If (Is Windows=True)
			SVG_SET_TEXT_RENDERING($tRef; "optimizeLegibility")
		End if 
		$gChart:=SVG_Export_to_picture($tSVGRef)
		SVG_CLEAR($tSVGRef)
		SET DRAG ICON($gChart; 0; 0)
		
		
	: (Form event code=On Double Clicked)  //Adds a folder to sync without having to drag it
		If (Form.UI.VisibleFolderCurrentItem#Null)
			$tFolderName:=Form.UI.VisibleFolderCurrentItem.name
			
			//Add it to the UI list
			Form.UI.SyncFolderList.push($tFolderName)
			
			//Add it to the DevSync state object
			$oProject:=DevSync_ThisProject
			$oProject.selectedFolders:=Form.UI.SyncFolderList.copy()
			
			//Save to disk
			DevSync_SaveState
			
			
			
		End if 
		
End case 
