#!/bin/bash
blue="\e[96m"
normal="\033[0m"
greentext="\033[32m"
warning="\e[93m"
danger="\e[91m"
SAFEDELETEDIR="$HOME/.Trash"
RECURSIVE_DEL=
DIRONLY_DEL=
INTERACTIVE_DEL=
FILEONLY_DEL=
emptyargs=true
FILES=
EXIT_CODE=0

echo 
usage(){
  echo -e $warning"Usage: ./safedelete.sh [ -i | -d | -r | -f ] File ..."
  echo " -i : Interactive Prompt"
  echo " -d : Directory Delete Only"
  echo " -r : File and Dir Delete"
  echo -e " -f : File Delete only"$normal
  echo
  exit 1
}


while getopts "idrf" option; do
    case "$option" in

    i ) INTERACTIVE_DEL=1;;
    d ) DIRONLY_DEL=1;;
    r ) RECURSIVE_DEL=1;;
    f ) FILEONLY_DEL=1;;
    \? ) usage
        ;;
    esac
    emptyargs=false
done
shift $((OPTIND -1))


if [[ $emptyargs = true ]]; then
    usage
fi
#pass remaining arguments to files
FILES=("$@")

#check if Files are not empty after argument
if [[ ! ${FILES[@]} ]]; then
    echo -e $warning"Error: No File Specified to be deleted!!!"$normal
    usage
fi

#wrapper for prompts
delete(){
    local file=$1
    if [[ $INTERACTIVE_DEL = 1 ]]; then
        echo -e $blue"Are You Sure you want to Delete \"$file\"?"$normal
        echo -n "(yes/no): "

        read reply

        if [[ $reply = "yes" || $reply = "y" || ! -n $reply ]]; then
            trash $file
        else
            echo -e $danger"Cancelled by User!!\n"$normal
        fi
    else
        trash $file
    fi
}

trash(){
    local file=$1
    #basename is used to extract main filename
    #e.g basename /home/vagrant.txt will return vagrant.txt
    local base=$(basename "$file")
    local fullpath=$(realpath "$file")
    trashname="$SAFEDELETEDIR/$base"



    #check to see if previous versions already exist in trashdir
    #find a better way to make unique from test.txt.23-12-2019-19:24:38
    if [[ -e $trashname ]]; then 
        echo "Found in trash, renaming as $trashname.$(date +%d-%m-%Y-%T)"
        trashname="$trashname.$(date +%d-%m-%Y-%T)"
    fi

    #Moving to TrashDirectory. Change to mv command
    cp -r "$fullpath" "$trashname"
    echo -e $greentext"Deleting \"$file\" .....\n"$normal
    return 0
}


#ensure SafeDelete Folder Exists
if [[ ! -e $SAFEDELETEDIR ]]; then
    echo -e $blue"Safe Delete Recycle Bin does not Exist, Do you want to create it at \"$SAFEDELETEDIR\"?: "$normal
    echo -n "(yes/no): "

    read reply

    if [[ $reply = "yes" || $reply = "y" || ! -n $reply ]]; then
        mkdir -p "$SAFEDELETEDIR"
    else
        echo -e $danger"Exiting Script. SafeDelete Recycle Bin does not Exist"$normal
        exit 1
    fi
fi

#FILE DELETE
for file in "${FILES[@]}"; do
    #test if file Exist
    if [[ ! -e $file ]]; then
        echo -e $warning"\"$file\" does not Exist\n"$normal
        EXIT_CODE=1
        continue
    fi


    #check if file is not main directory
    if [[ $file = "/" ]]; then
        echo -e $danger"it is dangerous to operate recursively on /, exiting script"$normal
        exit 1
    fi

    #note places i am setting exit_code to 1 without calling
    #i want for loop to finish and if that was the only file,
    #the exit is called at the end of the script. this allows
    #you to skip invalid file and the script work for the valids ones

    #check if File is . or ..
    if [[ $file = "." || $file = ".." ]]; then
        echo -e $warning"$COMMAND: \".\" and \"..\" may not be removed"$normal
        EXIT_CODE=1
        continue
    fi

    #the same check also apply on /. /.. if basename
    if [[ $(basename $file) = "." || $(basename $file) = ".." ]]; then
        echo -e $warning"$COMMAND: \".\" and \"..\" may not be removed"$normal
        echo
        EXIT_CODE=1
        continue
    fi


    #if $RECURSIVE_DEL is set. Delete Dir or File irrespective its a file or directory
    if [[ -n $RECURSIVE_DEL ]]; then 
        delete "$file"
    else
        #check if file is Folder
        if [[ -d $file ]] && [[ ! -n $DIRONLY_DEL ]]; then
            echo -e $warning"Error Folder cannot be Deleted as recursive command is not passed and file is folder\n"$normal
            EXIT_CODE=1
            continue
        fi

        #Function to Delete What is Left
        delete "$file"
    fi

done
exit $EXIT_CODE