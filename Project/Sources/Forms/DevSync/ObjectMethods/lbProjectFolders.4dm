C_BLOB:C604($xBlob)
C_TEXT:C284($tFolderName;$tSystemFont;$tRef;$tSVGRef)
C_OBJECT:C1216($oProject)
C_PICTURE:C286($gChart)

Case of 
	: (Form event code:C388=On Begin Drag Over:K2:44)  //To lbSyncFolders
		  //Get the name of the folder they are dragging and put it into a "4DDD" pasteboard as blob
		$tFolderName:=Form:C1466.UI.VisibleFolderCurrentItem.name
		TEXT TO BLOB:C554($tFolderName;$xBlob;UTF8 text without length:K22:17)
		CLEAR PASTEBOARD:C402
		APPEND DATA TO PASTEBOARD:C403("4DDD";$xBlob)
		$0:=0
		
		  //Change the drag icon to be a picture of the folder name they are dragging
		$tSystemFont:=OBJECT Get font:C1069(*;"")  //Returns the system font
		$tSVGRef:=SVG_New (200;17)  //Listbox cell size, so it should fit
		$tRef:=SVG_New_textArea ($tSVGRef;$tFolderName;0;0;200;17;$tSystemFont;13;Plain:K14:1;Align left:K42:2)
		If (Is Windows:C1573=True:C214)
			SVG_SET_TEXT_RENDERING ($tRef;"optimizeLegibility")
		End if 
		$gChart:=SVG_Export_to_picture ($tSVGRef)
		SVG_CLEAR ($tSVGRef)
		SET DRAG ICON:C1272($gChart;0;0)
		
		
	: (Form event code:C388=On Double Clicked:K2:5)  //Adds a folder to sync without having to drag it
		If (Form:C1466.UI.VisibleFolderCurrentItem#Null:C1517)
			$tFolderName:=Form:C1466.UI.VisibleFolderCurrentItem.name
			
			  //Add it to the UI list
			Form:C1466.UI.SyncFolderList.push($tFolderName)
			
			  //Add it to the DevSync state object
			$oProject:=DevSync_ThisProject 
			$oProject.selectedFolders:=Form:C1466.UI.SyncFolderList.copy()
			
			  //Save to disk
			DevSync_SaveState 
			
			
			
		End if 
		
End case 
