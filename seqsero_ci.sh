#!/bin/bash
#Script executes these command with some safeguards in place in case it fails:
#wget https://github.com/denglab/SeqSero/archive/v1.0.1.tar.gz
#tar zfx v1.0.1.tar.gz && rm v1.0.1.tar.gz

ENV_NAME=$1

SEQSERO_LINK=https://github.com/denglab/SeqSero/archive/v1.0.1.tar.gz
SEQSERO_ARCHIVE_NAME=v1.0.1.tar.gz
SEQSERO_FOLDER=SeqSero-1.0.1
SEQSERO_ENV_FILE=envs/SeqSero.yaml
SEQSERO_ENV_NAME=bifrost_SeqSero

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR # avoiding small edge case where bashrc sourcing changes your directory

function exit_function() {
  echo "to rerun use the command:"
  echo "bash -i $SCRIPT_DIR/custom_install.sh $ENV_NAME"
  exit 1
}

CONDA_BASE=$(conda info --base)
source $CONDA_BASE/etc/profile.d/conda.sh

if ! (conda env list | grep "$ENV_NAME")
then
  echo "conda environment specified is not found"
  exit_function
else
  conda activate $ENV_NAME
fi

if test -d "$SCRIPT_DIR/$SEQSERO_FOLDER"
then
  echo "$SCRIPT_DIR/$SEQSERO_FOLDER already exists, if you want to overwrite, please remove old database folder"
  echo "You can use:"
  echo "rm -rf $SCRIPT_DIR/$SEQSERO_FOLDER"
  exit_function
else
  wget --version
  WGET_IS_AVAILABLE=$?
  if [ $WGET_IS_AVAILABLE -eq 0 ]
  then
    echo "#################Downloading SeqSero from $SEQSERO_LINK"
    if ! wget $SEQSERO_LINK
    then
      echo >&2 "wget command failed"
      exit_function
    else
      echo "#################Extracting SeqSero script from archive"
      if ! tar -zxf $SEQSERO_ARCHIVE_NAME
      then
        echo >&2 "tar command failed"
        exit_function
      else
        rm $SEQSERO_ARCHIVE_NAME
        echo "SeqSero tool successfully downloaded"
      fi
    fi
  else
    echo "wget is not installed"
    echo "you can try activating the conda env for this tool"
    exit_function
  fi
fi

if ! (conda env list | grep "$SEQSERO_ENV_NAME")
then
  #check if environment.yml file exists
  if test -f "$SEQSERO_ENV_FILE";
  then
    echo "Making conda env"
    echo "$SEQSERO_ENV_NAME will be created"
    conda env create --file "$SEQSERO_ENV_FILE" --name $SEQSERO_ENV_NAME
  else
    echo "SeqSero.yml file cannot be found in the envs/ folder"
    exit_function
  fi
else
  echo "Environment $SEQSERO_ENV_NAME is already created"
  echo -e "\nIf you want to update it, please remove it first:"
  echo "conda env remove --name $SEQSERO_ENV_NAME"
  echo "If not, installation is complete"
  exit_function
fi