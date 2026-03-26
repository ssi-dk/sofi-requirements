#!/bin/bash

set -euo pipefail

source .functions.sh

arg1=${1:-}
if [[ -z "$arg1" ]]
then
  echo "$#"
  components=`cat components.txt`
else
  components="$@"
fi

## Enable conda
module load tools $CONDA_VERSION
eval "$(conda shell.bash hook)"


for component in $components
do
  remove_environment $component;
done
