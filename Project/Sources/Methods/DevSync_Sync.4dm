//%attributes = {"folder":"DevSync","lang":"en"}
/* This method loops through each selected target, syncing the folders. When a folder is synced, we first check to
see if it has child folders. If it does, we sync those first. Doing descendents first makes it easier to keep track
of the folders.json groups, making sure they are correct.

For each target, this method:
1. Calculates all the paths needed for the syncing and stores them in an object that is passed around.
2. Loops through each sync folder, syncing it and then ensuring it is correctly set as the correct child (if it is
   a child).
3. Then it loops through all the groups, methods, classes, and forms that have been marked for deletion and actually
   deletes the files if they weren't added to another folder.

Note that this method was created in v18.2 which was before classes and method documentation files were added.
However, it tried to account for that so it should work by copying them as well. It just hasn't been tested yet.
*/

C_LONGINT($x; $lIndex)
C_OBJECT($oTargetProject; $oTargetFoldersJSON; $oSyncInfo; $oFolderInfo)
C_TEXT($tSyncFolder; $tCurrentSourceFolder; $tTargetSourceFolder; $tJSONString; $tFilepath; $tFolderpath)
C_TEXT($tTargetMethodFolder; $tTargetFormFolder; $tMethodName; $tFormName; $tChildFolderName; $tParentFolder)
C_TEXT($tTargetClassFolder; $tClassName; $tCurrentDocumentationFolder; $tTargetDocumentationFolder)
C_TEXT($tTargetMethodDocsFolder; $tTargetClassDocsFolder; $tTargetFormDocsFolder)
C_COLLECTION($cPath)
ARRAY TEXT($atProjectFolders; 0)

//Calculate the path to the current Sources folder
$cPath:=Split string(Form.path.thisProject; Folder separator)
$cPath.pop()
$tCurrentSourceFolder:=$cPath.push("Sources").join(Folder separator)+Folder separator

//Calculate the path to the current Documentation folder
$cPath:=Split string(Form.path.thisProject; Folder separator)
$cPath.remove($cPath.length-2; 2)
$tCurrentDocumentationFolder:=$cPath.push("Documentation").join(Folder separator)+Folder separator

Progress_Begin(0)

//Loop through target projects
For each ($oTargetProject; Form.UI.Projects)
	If ($oTargetProject.selected=True)  //Only sync it if it is selected
		
		Progress_SetMessage("Syncing to "+$oTargetProject.label)
		
		//Calculate the path to the target Sources folder
		$cPath:=Split string($oTargetProject.path; Folder separator)
		$cPath.pop()
		$tTargetSourceFolder:=$cPath.push("Sources").join(Folder separator)+Folder separator
		
		//Calculate the path to the target Documentation folder
		$cPath:=Split string($oTargetProject.path; Folder separator)
		$cPath.pop()
		$cPath.pop()
		$tTargetDocumentationFolder:=$cPath.push("Documentation").join(Folder separator)+Folder separator
		
		//Calculate the paths to the target Methods, Classes, and Forms folders
		$tTargetMethodFolder:=$tTargetSourceFolder+"Methods"+Folder separator
		$tTargetClassFolder:=$tTargetSourceFolder+"Classes"+Folder separator
		$tTargetFormFolder:=$tTargetSourceFolder+"Forms"+Folder separator
		
		//Calculate the paths to the target Methods, Classes, and Forms documentation folders
		$tTargetMethodDocsFolder:=$tTargetDocumentationFolder+"Methods"+Folder separator
		$tTargetClassDocsFolder:=$tTargetDocumentationFolder+"Classes"+Folder separator
		$tTargetFormDocsFolder:=$tTargetDocumentationFolder+"Forms"+Folder separator
		
		//Load the folders.json file from the target project. We will be changing it during the sync.
		$tJSONString:=Document to text($tTargetSourceFolder+"folders.json")
		$oTargetFoldersJSON:=JSON Parse($tJSONString)
		
		//Create an object to pass with the information DevSync_SyncFolder needs to use and pass back
		$oSyncInfo:=New object
		$oSyncInfo.CurrentSourceFolder:=$tCurrentSourceFolder
		$oSyncInfo.CurrentDocumentationFolder:=$tCurrentDocumentationFolder
		$oSyncInfo.TargetSourceFolder:=$tTargetSourceFolder
		$oSyncInfo.TargetMethodFolder:=$tTargetMethodFolder
		$oSyncInfo.TargetClassFolder:=$tTargetClassFolder
		$oSyncInfo.TargetFormFolder:=$tTargetFormFolder
		$oSyncInfo.TargetMethodDocsFolder:=$tTargetMethodDocsFolder
		$oSyncInfo.TargetClassDocsFolder:=$tTargetClassDocsFolder
		$oSyncInfo.TargetFormDocsFolder:=$tTargetFormDocsFolder
		$oSyncInfo.TargetFolderJSON:=$oTargetFoldersJSON
		
/* If we delete un-referenced methods, classes, forms, and child folders each time we sync a folder in
DevSync_SyncFolder, we run the risk of deleting something that was simply moved to another folder (either
further up or down the hierarchy chain). The only way to not delete something that is supposed to be there
is to keep track of everything that may need to be deleted and everything that for sure needs to stay and
then only delete the difference after all the folders have been synced. We use the following collections to
collect the lists needed to perform this operation at the end.
*/
		$oSyncInfo.added:=New object
		$oSyncInfo.added.groups:=New collection
		$oSyncInfo.added.methods:=New collection
		$oSyncInfo.added.classes:=New collection
		$oSyncInfo.added.forms:=New collection
		$oSyncInfo.remove:=New object
		$oSyncInfo.remove.groups:=New collection
		$oSyncInfo.remove.groupObjects:=New object  //Folder names will be keys, just like in folders.json
		$oSyncInfo.remove.methods:=New collection
		$oSyncInfo.remove.classes:=New collection
		$oSyncInfo.remove.forms:=New collection
		
		
/* Now we will Loop through each sync folder in the list and sync it to the target. Descendants of the sync
folder will also synced, from the bottom up and the folders.json file will be updated accordingly.
*/
		For each ($tSyncFolder; Form.UI.SyncFolderList)
			
			
			DevSync_SyncFolder($oSyncInfo; $tSyncFolder)  //This method does the main work of copying files to the target project
			
			
/* Now we need to make sure that this sync folder is correctly set as a child (if needed). For example:
			
Folder A
       ⮑Folder B
                ⮑Folder C
                         ⮑Folder D
			
Imagine Folder C is the sync folder. DevSync_SyncFolder will make sure that both Folder D and Folder C are
synced and have the correct children set up. Once control returns to this method, we need to ensure that
Folder C is a child of Folder B in the target project. We don't go further up the chain, however.
*/
			
			//Find the parent of this folder in the current project
			OB GET PROPERTY NAMES(Form.ProjectFoldersObject; $atProjectFolders)  //Get a list of all the folders from the current folders.json
			$tParentFolder:=""  //Default to no parent folder (i.e. the sync folder is at the top level in the Explorer)
			For ($x; 1; Size of array($atProjectFolders))
				$oFolderInfo:=Form.ProjectFoldersObject[$atProjectFolders{$x}]
				If ($oFolderInfo.groups#Null)
					If ($oFolderInfo.groups.indexOf($tSyncFolder)>=0)  //Then this is the parent
						$tParentFolder:=$atProjectFolders{$x}
						$x:=Size of array($atProjectFolders)+1  //Abort loop
					End if 
				End if 
			End for 
			
			
/* Now that we know the parent folder, we can make sure it is the same in the target project by removing it from
other folders (if found) and adding it to the correct one.
*/
			OB GET PROPERTY NAMES($oTargetFoldersJSON; $atProjectFolders)  //Get a list of all the folders from the target folders.json
			For ($x; 1; Size of array($atProjectFolders))
				$oFolderInfo:=$oTargetFoldersJSON[$atProjectFolders{$x}]
				If ($atProjectFolders{$x}=$tParentFolder)  //This is the parent so we make sure it is added here
					
					If ($oFolderInfo.groups=Null)  //Create a groups collection if it doesn't already exist
						$oFolderInfo.groups:=New collection
					End if 
					$oFolderInfo.groups.push($tSyncFolder)
					
				Else   //Not the parent, so make sure it doesn't exist in this folder's groups collection
					
					If ($oFolderInfo.groups#Null)
						$lIndex:=$oFolderInfo.groups.indexOf($tSyncFolder)
						If ($lIndex>=0)
							$oFolderInfo.groups.remove($lIndex)
						End if 
					End if 
					
				End if 
			End for 
			
		End for each 
		
		
/* Actually delete any child folders that were marked for deletion and never added somewhere else. These were child
folders in the target project that were not child folders in the parent project. Note that this is done before
removing methods, classes, and forms that are marked for deletion so that here we can simply mark a child folder's
methods, classes, and forms for deletion and let the later logic take care of both rather than reproducing it here.
*/
		For each ($tChildFolderName; $oSyncInfo.remove.groups)
			If ($oSyncInfo.added.groups.indexOf($tChildFolderName)=-1)  //A child folder marked to be removed that was never added
				
				DevSync_RemoveChildFolder($oSyncInfo; $tChildFolderName)
				
			End if 
		End for each 
		
		
		//Actually delete any methods that were marked for deletion and never added somewhere else.
		For each ($tMethodName; $oSyncInfo.remove.methods)
			If ($oSyncInfo.added.methods.indexOf($tMethodName)=-1)  //A method marked to be removed that was never added
				
				$tFilepath:=$tTargetMethodFolder+$tMethodName+".4dm"
				If (Test path name($tFilepath)=Is a document)
					DELETE DOCUMENT($tFilepath)
				End if 
				
				//If the method has documentation, delete it as well
				$tFilepath:=$tTargetMethodDocsFolder+$tMethodName+".md"
				If (Test path name($tFilepath)=Is a document)
					DELETE DOCUMENT($tFilepath)
				End if 
				
			End if 
		End for each 
		
		
		//Actually delete any classes that were marked for deletion and never added somewhere else.
		For each ($tClassName; $oSyncInfo.remove.classes)
			If ($oSyncInfo.added.classes.indexOf($tClassName)=-1)  //A class marked to be removed that was never added
				
				$tFilepath:=$tTargetClassFolder+$tClassName+".4dm"
				If (Test path name($tFilepath)=Is a document)
					DELETE DOCUMENT($tFilepath)
				End if 
				
				//If the class has documentation, delete it as well
				$tFilepath:=$tTargetClassDocsFolder+$tClassName+".md"
				If (Test path name($tFilepath)=Is a document)
					DELETE DOCUMENT($tFilepath)
				End if 
				
			End if 
		End for each 
		
		
		//Actually delete any forms that were marked for deletion and never added somewhere else.
		For each ($tFormName; $oSyncInfo.remove.forms)
			If ($oSyncInfo.added.forms.indexOf($tFormName)=-1)  //A form marked to be removed that was never added
				
				$tFolderpath:=$tTargetFormFolder+$tFormName+Folder separator
				If (Test path name($tFolderpath)=Is a folder)
					DELETE FOLDER($tFolderpath; Delete with contents)
				End if 
				
				//If the form has documentation, delete it as well
				$tFolderpath:=$tTargetFormDocsFolder+$tFormName+Folder separator
				If (Test path name($tFolderpath)=Is a folder)
					DELETE FOLDER($tFolderpath; Delete with contents)
				End if 
				
			End if 
		End for each 
		
		
		//Save the target folders.json changes back to the target project
		$tJSONString:=JSON Stringify($oTargetFoldersJSON; *)
		TEXT TO DOCUMENT($tTargetSourceFolder+"folders.json"; $tJSONString; "UTF-8")
		
		
	End if 
End for each 

Progress_End
