//%attributes = {"folder":"DevSync","lang":"en"}
/* Call DevSyn_ShowWindow to open this window. It was made to "sync" 4D Explorer folders from one project to another.
Currently 4D's project mode doesn't allow a folder hierarchy of methods, forms, etc. in folders on disk. Instead,
they keep a representation of folder hierarchy for the 4D Explorer in the folders.json file. It also isn't possible
to drag folders (or any item) from one project to another like we could do with binary databases. Therefore, when
using the folder hierarchy in the Explorer, it is necessary to do several things when copying/updating a folder
from one project to another. The individual files (methods, forms, classes, documentation) must be found in the
Finder and copied to the respective places in the other project. Some files may need to be deleted. Most complex,
the folders.json file must be changed to ensure the everything is in the correct place.

I currently have 8 projects that share a good deal of core code. Correctly updating the code in all of them after
even a small change in one is time consuming and error prone. The DevSync window was made to simplify this process.

Participating projects can each have the DevSync module in them. That way the core code can be changed in any
project. DevSync_ShowWindow is called from the changed project. You can select just some or all target projects at
once and ask it to sync certain folders. It will then take care of all the details. Even syncing many changes will
happen very quickly.

The windows gathers its state when it is opened and doesn't automatically refresh on its own. Simply reopen the
window if you need it to refresh. This is a developer facing window that isn't used often, so it is kept simple
without a ton of error checking. The main state for this window is kept in a file on disk and is shared across
all participating projects. This file maintains a list of participating projects as well as window details for
each of them individually. See info on DevSync.json below.

When the window is opened, it first makes sure that the current project is added as a participating project.
Other projects can be added using the list on the right. Note that the currently running project is never visible
in this list as it doesn't make sense to target itself. You must actually check a target project for it to be
involved in the sync.

The window also displays a list of 4D Explorer folders in the Project Folders list. There is a search field which
can be used to quickly find the folder(s) you want to sync. Double-click or drag and drop a folder to the Sync
Folders list to include it in the next sync. If you want to sync a folder that has children, only include the
top most folder. There is no need to specify the child (or grandchild) folders as they will automatically be
included in the sync.

Note that this is only intended to sync folders. Therefore, there is no way to use it to sync non-folder items
that are at the top level of the Explorer window. Currently the following items are synced if they are in a
folder:
- Child folders (all the way down the chain)
- Methods
- Classes
- Forms
- Method documentation
- Class documentation
- Form documentation

This means that things like database methods (On Startup, etc.) and tables are not included in the sync.




Below are the object definitions for the DevSync.json file and for the Form object while the window is running.


### DevSync.json File Keys
This file is located (on Mac) at ~/Library/Application Support/4D/DevSync/DevSync.json and is where the state for
this window is kept. The same file is shared for every project. Keep in mind that part of the state this window
keeps track of is necessarily shared across multiple applications. All the state is kept in this file. It is
loaded into memory when the form loads. All state is kept in the form object and saved to disk each time there is
a change. Because it is a developer tool, there is very little error checking and we don't worry about multiple
projects trying to save to the DevSync.json file at the same time. "Refreshing" the window is done by reopening it.

- **projectPaths** is a collection of the objects representing the participating projects Each element is an
object with the following keys:
  - **path** is the full path to the .4DProject file.
  - **selectedProjects** is a collection of project paths that are currently selected in this project
  - **selectedFolders** is a collection of folders that have been added for syncing


### Form Object Keys
Form. keys:
- **path** contains some file/folder paths that will commonly be used. We only want to calculate them once.

  - **DevSyncFolder** is the path to the folder where DevSync.json is stored. On Mac this is at
    ~/Library/Application Support/4D/DevSync/.

  - **DevSyncState** is the path to the DevSync.json file itself which is in the above folder.

  - **foldersJSON** is the path to the folders.json file in the running project.

  - **thisProject** is the path to the .4DProject file for the currently running project.


- DevSyncObject is a copy of the object in DevSync.json. See below for the keys inside of it.

- ProjectFoldersObject is a copy of the object in folders.json.


- *UI** contains the things we need to run the UI on the form

  - **AllFolderList** is a collection of all the folders in this project. Each element is an object with a single
  key of "name".

  - **VisibleFolderList** is a collection that the folder listbox uses for display. When searching, this collection
  is updated on the fly from the UI.AllFolderList collection based on the search text.

  - **VisibleFolderCurrentItem**

  - **VisibleFolderCurrentPosition**

  - **SyncFolderList** is a collection of folder names that the user wants to sync.

  - **SyncFolderCurrentPosition**

  - **Projects** is a collection of projects that we can target when syncing. The current project is never
  part of the list. Each element in the collection has the following keys:
    - **path** is the full path to the .4DProject file
    - **selected** is true if the project will be targeted in the next sync; false otherwise.
    - **label** is the short name of the project to be displayed in the listbox

  - **ProjectCurrentItem** is the currently selected item in the projects listbox

  - **ProjectCurrentPosition** is the position (not index) of the selected item in the projects listbox



### Sync Info Object




*/
