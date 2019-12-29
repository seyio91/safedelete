Safe Delete
A script to safely remove files to a trash directory than delete. (Equivalent to Recycle Bin in Windows). Default Moves a File to .Trash in the User's Home Directory. Deleting files that already exists in .Trash Directory are renamed by Appending Current Date to it.  
  
Usage: ./safedelete.sh [ -i | -d | -r | -f ] File Folder ...  
-i : Interactive Prompt  
-d : Directory Delete Only  
-r : File and Dir Delete  
-f : File Delete only  
  
  
To Do:  
Expand Script to be Interactive - Done  
Create Cronjob Archive SafeDelete Folder Weekly  
Recursive Delete through each Folder  
Command line argument to change Safe Delete Directory  
