#!/bin/bash

PROJ_DIR=/opt/notebooks/$GIT_REPO_NAME
DOTFILES=".bashrc .inputrc .vimrc"
PY_REPOS="Analytics-Tools/effodata_py.git Analytics-Tools/poirot_py.git"
R_REPOS="Analytics-Tools/effodata_r Analytics-Tools/poirot_r"

# Test whether this is a Python or R session. Python sessions' hostnames
# contain "jupyter" in them but R sessions' don't.
if [[ $HOSTNAME == *"jupyter"* ]]; then
    R_REPOS=""
else
    PY_REPOS=""
fi

# Install Python packages.
for repo in $PY_REPOS; do
    echo "Installing $repo..."
    output=$(pip install git+https://github.8451.com/$repo 2>1)
    if [ $? -eq 0 ]; then
        echo "Successful"
    else
        echo $'--------------------\nFAILED\n--------------------'
        echo "$output" $'\n'
    fi
done

# Install R packages -- this takes FOREVER.
if [[ -n "$R_REPOS" ]]; then
    echo "Installing 'remotes' from CRAN..."
    output=$(R -e 'install.packages("remotes")' 2>1 </dev/null)
    if [ $? -eq 0 ]; then
        echo "Successful"
    else
        echo $'--------------------\nFAILED\n--------------------'
        echo "$output" $'\n'
    fi
fi
for repo in $R_REPOS; do
    echo "Installing $repo..."
    output=$(R -e "remotes::install_github(repo = \"$repo\", host = 'github.8451.com/api/v3', auth_token = \"$GITHUB_ACCESS_TOKEN\", upgrade = 'never')" 2>1)
    if [ $? -eq 0 ]; then
        echo "Successful"
    else
        echo $'--------------------\nFAILED\n--------------------'
        echo "$output" $'\n'
    fi
done

# If you have dotfiles in your repo, copy them to $HOME (and overwrite the old ones).
for dotfile in $DOTFILES; do
    if [ -f "$PROJ_DIR/$dotfile" ]; then
        old_loc="$PROJ_DIR/$dotfile"
        new_loc="$HOME/$dotfile"
        cp "$old_loc" "$new_loc"
        echo "Copied $old_loc to $new_loc"
    fi
done

# Create a symlink to your home directory. 
ln -s $HOME $PROJ_DIR/home
# Update shell prompt so the long nonsense hostname isn't there.
export PS1="\[\e]0;\u@\u: \w\a\]\u@\u:\w$ "
