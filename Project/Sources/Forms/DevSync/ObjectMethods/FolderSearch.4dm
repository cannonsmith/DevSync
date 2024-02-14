C_TEXT($tContainsSearch)

Case of 
	: (Form event code=On After Edit)
		If (Get edited text="")
			
			Form.UI.VisibleFolderList:=Form.UI.AllFolderList
			
		Else 
			
			$tContainsSearch:="@"+Get edited text+"@"
			Form.UI.VisibleFolderList:=Form.UI.AllFolderList.query("name = :1"; $tContainsSearch)
			
		End if 
		
		
End case 
