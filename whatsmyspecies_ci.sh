#Script executes these command with some safeguards in place in case it fails:
#mkdir minikraken && cd minikraken
#wget -q https://ccb.jhu.edu/software/kraken/dl/minikraken_20171019_8GB.tgz
#tar -zxf minikraken_20171019_8GB.tgz --strip-components=1
#rm minikraken_20171019_8GB.tgz
#wget -O minikraken_100mers_distrib.txt -q https://ccb.jhu.edu/software/bracken/dl/minikraken_8GB_100mers_distrib.txt
#chmod +r minikraken_100mers_distrib.txt
ENV_NAME=$1
#conda activate $ENV_NAME

MINIKRAKEN_DB_LINK=https://ccb.jhu.edu/software/kraken/dl/minikraken_20171019_8GB.tgz
MINIKRAKEN_BRACKEN_LINK=https://ccb.jhu.edu/software/bracken/dl/minikraken_8GB_100mers_distrib.txt
MINIKRAKEN_BRACKEN_FILE=minikraken_100mers_distrib.txt

function exit_function() {
  echo "to rerun use the command:"
  echo "bash -i $SCRIPT_DIR/custom_install.sh $ENV_NAME"
  exit 1
}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
RESOURCES="$SCRIPT_DIR/resources"
if test -d "$RESOURCES/minikraken"
then
  echo "$RESOURCES/minikraken" already exists, if you want to overwrite, please remove old database folder
  echo "You can use:"
  echo "rm -rf $RESOURCES/minikraken"
  exit_function
fi
if test -d "$RESOURCES"
then
  cd $RESOURCES
  mkdir minikraken
  cd minikraken
  wget --version
  WGET_IS_AVAILABLE=$?
  if [ $WGET_IS_AVAILABLE -eq 0 ]
  then
    echo "#################Downloading minikraken db from $MINIKRAKEN_DB_LINK"
    if ! wget $MINIKRAKEN_DB_LINK
    then
      echo >&2 "wget command failed"
      exit_function
    else
      MINIKRAKEN_DB_FILE=$(find $RESOURCES/minikraken/ -name "minikraken_*")
      echo "#################Extracting the minikraken db from archive"
      if ! tar -zxf $MINIKRAKEN_DB_FILE --strip-components=1
      then
        echo >&2 "tar command failed"
        exit_function
      else
        rm $MINIKRAKEN_DB_FILE
        echo "#################Downloading minikraken bracken file database"
        if ! wget -O $MINIKRAKEN_BRACKEN_FILE -q $MINIKRAKEN_BRACKEN_LINK
        then
          echo >&2 "wget bracken file command failed"
          exit_function
        else
          chmod +r minikraken_100mers_distrib.txt
          echo "kraken db successfully downloaded"
        fi
      fi
    fi
  else
    echo "wget is not installed"
    echo "you can try activating the conda env for this tool"
    exit_function
  fi
else
  echo "resources folder is expected in the script directory"
  exit_function
fi