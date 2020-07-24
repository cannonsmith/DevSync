# DevSync
This code is intended to solve a very specific problem. I have multiple 4D projects which share a great deal of foundational type code. Occasionally I am working in one of them and end up making changes or enhancements to this foundational code and want these changes to propogate to the other projects automatically. Furthermore, I make extensive use of folders in the 4D Explorer window to organize my code (methods and forms) into what I think of as modules. My folder hierarchy is often 3 to 4 levels deep.

To accomplish this when working in binary mode, I would launch a second copy of 4D and use it to open each database in turn, copying the changed folder by dragging and dropping between databases. This process is no longer possible in project mode. In theory we should now be able to do this by copying files directly on disk, but the folder structure in the 4D Explorer is not mirrored on disk thus making it difficult to ensure all files are copied (or deleted) correctly.

The DevSync code solves this by automatically copying the following items of a folder from the currently running project to other projects:
	- Child folders (all the way down the chain)
	- Methods
	- Classes
	- Forms
	- Method documentation
	- Class documentation
	- Form documentation

Importantly, it also updates the folders.json file in each target project so that the folder structure remains correct.

To use this code, copy the methods and forms into each project where it makes sense (i.e. projects that have the same code in folders). It doesn't matter which project you make changes to. Run the `DevSync_ShowWindow` method to open the window and sync changes to the other projects. More specific details for using the window are available in the `DevSync__README` method.

# Caveats
This code was created using 4D v18.2. Initial testing shows it to be working, but it hasn't been extensively used yet so be careful if you use it yourself. While v18.2 does not support classes or method documentation, the module is anticipating the existence of these items and should work correctly in v18 R3 and higher. However, this is not tested yet.

The `DevSync_Sync` method has three lines of code which refer to updating a progress window. You will probably have to replace these three lines with calls to your own progress functionality or remove them. The `DevSync_ShowWindow` will open the window using the `DIALOG(...;*)` parameter, but you may need to remove that depending on where you call it from.

Finally, note that the sync will not try to do anything with tables that are in folders, nor will it copy things that aren't in Explorer folders like database methods or items at the top level of the 4D Explorer window.

# Misc
If this code is useful to you, feel free to use it or change it as needed. If you find bugs, please report them in GitHub as an issue.
