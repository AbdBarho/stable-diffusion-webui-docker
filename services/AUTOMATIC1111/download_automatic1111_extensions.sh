#!/bin/bash

# download_automatic1111_extensions.sh ensures that Automatic1111 extensions 
# are installed in a given directory and set at a particular git commit
#
# The first argument is a file containing a list of git repository URLs of
# extensions andcorresponding hashes, one repo/hash pair per line.  Comments
# are allowed in this file, following a hash.
#
# The second argument is the extensions directory where the extensions will 
# be installed.  
#
# If the repositories are already installed and the correct 
# commit is checked out, this script does not require internet access, and 
# should be fairly quick.
echo "Running download_automatic1111_extensions.sh, reading from repo/hash file " $1 ", putting extensions into " $2
mkdir -p $2 # Create the destination directory if it doesn't exist already.
command | while read -r line; do {   # read each line of repo/hash pairs.
  line_stripped_of_comments=$(echo $line | sed -e 's/\#.*//g') # strip everything after hash.
  if [[ $line_stripped_of_comments = *[![:space:]]* ]]; then # check if there's a non-comment, non-whitespace on this line
    git_repo_url=$(echo $line | awk '{print $1;}')
    commit_hash=$(echo $line | awk '{print $2;}')
    pushd $2 > /dev/null
    extension_name=$(echo $git_repo_url | sed  -e 's/.*\///' -e 's/\.git.*//')
    echo "Reading $git_repo_url, and putting hash $commit_hash into $2/$extension_name" 
    if [ ! -d "$extension_name" ]; then
      echo "$extension_name doesn't exist yet, cloning it"
      git clone "$git_repo_url" "$extension_name"
    else
      echo "$extension_name already present on disk"
    fi
    cd "$extension_name"
    if [ $(git rev-parse --verify HEAD) != $commit_hash ]; then
       echo "$extension_name is not at the right commit, checking out $commit_hash"
       git fetch --all
       git reset --hard $commit_hash
    else
      echo  "$extension_name is already at the right commit, $commit_hash"
    fi
    popd > /dev/null
  fi
}; done   < $1
echo "Finished running download_automatic1111_extensions.sh"
