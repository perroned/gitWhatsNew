#!/bin/bash
# ---------------------------------------------------
# Created by Danny Perrone (perroned) on May 1, 2015
# ---------------------------------------------------

# declare variables
declare -a branches # array of branch name
branchesToShow=3 # default to 3 branches shown
commitsToShow=3 # default to 3 commits shown (per branch)
currentBranch='' # holds the name of the current branch
onlyMyself=false # whether the user only wants to see their own commits
showCommitId=false # whether the user wants to see the commit identifier code
userEmail='' # stores user's Git email
userName='' # stores the user's Git username

# display statastics about the repo
function displayHeader {
    printf "Current branch  : $currentBranch\n"
    echo "Untracked files : "$(untrackedFileCount)
    echo "Uncommited files: "$(uncomittedFileCount)
    echo
}

# loops through each branch, and display the commits for the branch
function displayLog {
    displayHeader

    for branch in $branches; do
        if [[ "$branch" == "$currentBranch" ]]; then 
            echo "* On branch ==> $branch *"
        else
            echo "$branch:"
        fi
        commit=()
        numOfCommits=0
        toIgnore=false

        while read -r line
        do
            if [[ "$line" =~ ^commit.* ]]; then
                toIgnore=false
                if [[ $showCommitId ]]; then 
                    commit+=("\n\tCommit: $(echo $line | cut -d' ' -f2)\n") # take the commit ID
                else
                    commit+=("\n") # the user doesn't want to see the commit ID, add a blank line
                fi
            elif [[ "$line" =~ ^Author.* ]]; then
                # skip if the commit isn't from the user and they only want to see their own
                if [[ ($onlyMyself && !("$line" =~ ^Author:\ $userName\ \<$userEmail\>$)) ]]; then
                    toIgnore=true # mark the rest of the fields as ones to be ignored
                    unset commit[${#commit[@]}-1] # remove the last element which is the commit ID or blank line
                    continue # move to the next commit and try again
                fi

                ((numOfCommits++)) # count this commit, see if we've reached the end
                if [[ $numOfCommits -gt $commitsToShow ]]; then
                    unset commit[${#commit[@]}-1] # remove the last element for the commit line
                    break # we're done for this branch. Stop reading commits
                fi

                commit+=("\t$line\n") # add the author
            elif [[ $toIgnore == false && "$line" =~ ^Date.* ]]; then
                commit+=("\t$(echo $line | sed 's/[-+][0-9]\{4\}$//')\n\n") # cut off timezone
            elif [[ $toIgnore == false && "$line" =~ ^$ ]]; then : # blank line
            else
                if [[ $toIgnore == false ]]; then
                    commit+=("\t\t$line\n") # this is a commit title or message. Append it
                fi
            fi
        done < <(git log "$branch") # read the results of 'git log' for the specific branch
        echo -e "${commit[@]}" # print the built commit array
    done
}

# returns an array of the branches last modified
function getBranches {
    # retrieve the branches in order of last commit
    eval "$(git for-each-ref --count=$branchesToShow --sort=-committerdate --shell --format='branches+=(%(refname))' refs/heads/)"
    branches=${branches[@]/refs\/heads\// } # remove te path to the branch names
}

# retrieves the name of the current branch. Only needs to be called once, stored for faster querying
function getCurrentBranch {
    # read the first line of the Git head file, retrieve where the head is at (current branch)
    currentBranch=$(head -1 ./.git/HEAD | rev | cut -d'/' -f 1 | rev)
}

# retrieves the name and email the user has saved in Git. Only needs to be called once, stored for faster querying
function getUserCredentials {
    userName=$(git config --global user.name)
    userEmail=$(git config --global user.email)
}

# attempts to move to the tree root of the Git repo
function moveToBaseOrDie {
    # go to the root of the working git tree
    treeRoot="$(git rev-parse --show-cdup)"
    if [[ "$treeRoot" != "" ]]; then 
        cd "$treeRoot"
    fi
    # check for .git directory
    if [ ! -d ".git" ]; then
        echo "fatal: Not a git repository (or any of the parent directories): .git" >&2
        exit -1
    fi
}

# process the options the user has passed
function processArgs {
    # usage
    if [[ $* =~ .*-[\ ]*help.* ]]; then
        echo -e "Usage: $(basename $0) [-b number] [-c number] [--me] [--id]" >&2
        echo -e "where:" >&2
        echo -e "\t-b" >&2
        echo -e "\t\t\tthe number of branches to show" >&2
        echo -e "\t-c" >&2
        echo -e "\t\t\tthe number of commits to show (per branch)" >&2
        echo -e "\t--me" >&2
        echo -e "\t\t\tonly display commits from you" >&2
        echo -e "\t--id" >&2
        echo -e "\t\t\tdisplay the ID of commits" >&2
        exit 1
    fi
    # process number of branches to show
    if [[ "$*" =~ .*-[\ ]*b[\ ]*[0-9]+.* ]]; then
        branchesToShow=$(echo "$*" | sed 's/.*-[\ ]*b[\ ]*\([0-9]\+\).*/\1/')
    fi
    # process number of commits to show
    if [[ "$*" =~ .*-[\ ]*c[\ ]*[0-9]+.* ]]; then
        commitsToShow=$(echo "$*" | sed 's/.*-[\ ]*c[\ ]*\([0-9]\+\).*/\1/')
    fi
    # determine if there is a filter for commits from only the user
    if [[ "$*" =~ .*--?[\ ]?me.* ]]; then
        onlyMyself=true
    fi
    # determine if the user wants to see commit IDs
    if [[ "$*" =~ .*--?[\ ]?[iI][dD].* ]]; then
        showCommitId=true
    fi
}

# Get number of total uncommited files
function uncomittedFileCount {
    expr $(git status --porcelain 2>/dev/null| egrep "^(M| M)" | wc -l)
}

# Returns the number of untracked files
function untrackedFileCount {
    expr $(git status --porcelain 2>/dev/null| grep "^??" | wc -l)
}

# -------------------
# start of main
# -------------------
processArgs "$*"
moveToBaseOrDie
getCurrentBranch
getBranches

if [[ $onlyMyself ]]; then
    getUserCredentials
fi

displayLog
