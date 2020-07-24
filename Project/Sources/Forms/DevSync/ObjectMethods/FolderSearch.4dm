C_TEXT:C284($tContainsSearch)

Case of 
	: (Form event code:C388=On After Edit:K2:43)
		If (Get edited text:C655="")
			
			Form:C1466.UI.VisibleFolderList:=Form:C1466.UI.AllFolderList
			
		Else 
			
			$tContainsSearch:="@"+Get edited text:C655+"@"
			Form:C1466.UI.VisibleFolderList:=Form:C1466.UI.AllFolderList.query("name = :1";$tContainsSearch)
			
		End if 
		
		
End case 
