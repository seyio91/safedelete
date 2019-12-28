#!/bin/bash
SAFEDELETEDIR="$HOME/.Trash"
RECURSIVE_DEL=
DIRONLY_DEL=
INTERACTIVE_DEL=
FILEONLY_DEL=
emptyargs=true
#variable to store multiple files is many files are passed to command
FILES=
EXIT_CODE=0

usage(){
  echo "usage: ./solution.sh [-i | -d | -r] file folder ....."
  echo " -i : Interactive Prompt"
  echo " -d : Directory Delete Only"
  echo " -r : File and Dir"
  echo " -f : File Delete only"
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

#only run when other checks pass
FILES=("$@")

#check if Files are not empty after argument
if [[ ! ${FILES[@]} ]]; then
    echo "File Argument Missing in Command"
    usage
fi

#wrapper for prompts
delete(){
    local file=$1
    if [[ $INTERACTIVE_DEL = 1 ]]; then
        echo "Are You Sure you want to delete $file"
        echo -n "(yes/no): "

        read reply

        if [[ $reply = "yes" || $reply = "y" || ! -n $reply ]]; then
            trash $file
        else
            echo -e "Cancelled\n"
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
    #find a better way to make unique
    if [[ -e $trashname ]]; then 
        echo "Found in trash, renaming as $trashname.$(date +%d-%m-%Y-%T)"
        trashname="$trashname.$(date +%d-%m-%Y-%T)"
        #this returns test.txt.23-12-2019-19:24:38
    fi

    #Moving to TrashDirectory
    cp -r "$fullpath" "$trashname"
    echo -e "Deleting File: $file .....\n"
    return 0
}


#ensure SafeDelete Folder Exists
if [[ ! -e $SAFEDELETEDIR ]]; then
    echo "Safe Delete Recycle Bin does not Exist, Do you want to create it at \"$SAFEDELETEDIR\"? :"
    echo -n "(yes/no): "

    read reply

    if [[ $reply = "yes" || $reply = "y" || ! -n $reply ]]; then
        mkdir -p "$SAFEDELETEDIR"
    else
        echo "Exiting SafeDelete. SafeDelete Recycle Bin does not Exist"
        exit 1
    fi
fi

#FILE DELETE
for file in "${FILES[@]}"; do
    #test if file Exist
    if [[ ! -e $file ]]; then
        echo -e "File $file does not Exist\n"
        EXIT_CODE=1
        continue
    fi


    #check if file is not main directory
    if [[ $file = "/" ]]; then
        echo "it is dangerous to operate recursively on /, exiting script"
        exit 1
    fi

    #note places i am setting exit_code to 1 without calling
    #i want for loop to finish and if that was the only file,
    #the exit is called at the end of the script. this allows
    #you to skip invalid file and script work for the valids ones
    #check if File is . or ..
    if [[ $file = "." || $file = ".." ]]; then
        echo "$COMMAND: \".\" and \"..\" may not be removed"
        EXIT_CODE=1
        continue
    fi

    #the same check also apply on /. /.. if basename
    if [[ $(basename $file) = "." || $(basename $file) = ".." ]]; then
        echo "$COMMAND: \".\" and \"..\" may not be removed"
        echo
        EXIT_CODE=1
        continue
    fi

    #add other conditions to Eliminate here
    # if [[ $INTERACTIVE_DEL = 1 ]]; then

    # fi

    #if $RECURSIVE_DEL is set. Delete Dir or File without Caring If anything is inside
    if [[ -n $RECURSIVE_DEL ]]; then 
        delete "$file"
    else
        #check if file is Folder
        if [[ -d $file ]] && [[ ! -n $DIRONLY_DEL ]]; then
            echo -e "Error Folder cannot be Deleted as recursive command is not passed and file is folder\n"
            EXIT_CODE=1
            continue
        fi

        #Function to Delete What is Left
        delete "$file"
    fi

done
exit $EXIT_CODE