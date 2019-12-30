## Safe Delete  
A script to safely remove files to a trash directory than delete. (Equivalent to Recycle Bin in Windows). Default Moves a File to .Trash in the User's Home Directory. Deleting files that already exists in .Trash Directory are renamed by Appending Current Date to it.  
  
Users can choose default directory by setting the $SAFEDELETEDIR variable in the command line. Script Checks if Variable is set and creates the Set Directory or it Uses the Default in ~/.Trash. This can be temporarily overwritten by using the -t flag  
  
*Usage: ./safedelete.sh [ -i | -d | -r | -f ] File Folder ...  
-i : Interactive Prompt  
-d : Directory Delete Only  
-r : File and Dir Delete  
-f : File Delete only
-t : Temporary Safe Delete Directory*
  
  
**To Delete a File**  
./safedelete.sh -f file1.txt file2.txt  
  
**To Delete a Directory**  
./safedelete.sh -d dir1/ dir2/  
  
**To Delete Both Files and Directory**  
./safedelete.sh -r file1.txt dir1/  
  
**To Pass Temp Trash Directory inline**  
./safedelete.sh -t /home/newtrashdir -r file1.txt dir1/  
  
  
**To Do:**  
- Expand Script to be Interactive - Done  
- Create Cronjob to Archive SafeDelete Folder Weekly  
- Recursive Delete through each Folder  
- Command line argument to change Safe Delete Directory - Done  
- Add Combining Arguments  
