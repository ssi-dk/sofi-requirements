set -euo pipefail

STAGE="${BIFROST_STAGE:+${BIFROST_STAGE}_}"

checkout () {
  component=$1
  branch=${2:-main}
  pushd ../components
  echo "Getting repo for bifrost_$component"
  if [ ! -e bifrost_$component ]
  then
    git clone git@github.com:ssi-dk/bifrost_$component.git
  fi
  cd bifrost_$component
  git pull
  popd
}

copy_custom_content () {
  component=$1
  component_dir=../components/bifrost_$component
  if [ -e ${component}.frozen.yml ]; then
    cp ${component}.frozen.yml $component_dir/environment.yml;
  else
    cp ${component}.yml $component_dir/environment.yml
  fi
  cp install.sh $component_dir/
  if [ -e ${component}_ci.sh ]; then
    cp ${component}_ci.sh $component_dir/custom_install.sh
  fi
}

get_component_name() {
  echo "get_component_name yaml ${CONFIG_YAML_PATH}"
  local __resvar=$1
  local COMPONENT_NAME=$(grep "display_name:.*." $CONFIG_YAML_PATH | tr " " "\n" | grep -v "display_name:")
  eval $__resvar="'$COMPONENT_NAME'"
}

get_component_version() {
  local __resvar=$1
  echo "get_component_version yaml '${CONFIG_YAML_PATH}'"
  local COMPONENT_VERSION=$(grep -o "code:.*." $CONFIG_YAML_PATH | tr " " "\n" | grep -v "code:")
  echo $COMPONENT_VERSION
  eval $__resvar="'$COMPONENT_VERSION'"
}

get_config_yaml() {
  local __resvar=$1
  eval $__resvar="'bifrost_${component}/config.yaml'"
}

get_environment_name() {
  local __resvar=$1
  local SCRIPT_DIR=${2:-.}
  get_config_yaml config_yaml
  local CONFIG_YAML_PATH=$config_yaml
  
  echo "get_environment_name config_yaml $CONFIG_YAML_PATH"

  if [ ! -f "$CONFIG_YAML_PATH" ]; then
      echo "Error: config.yaml not found at $CONFIG_YAML_PATH"
      exit 1
  fi

  get_component_name name
  get_component_version version

  local _name_first=$(echo "$name" |tr '\n' ' '| awk -F ' ' '{print $1}')
  local _version_first=$(echo "$version" |tr '\n' ' '| awk '{print $1}')
  local _env_name="bifrost_${STAGE}${_name_first}_${_version_first}"
  echo "conda environment ${_env_name}"
  eval $__resvar="'$_env_name'"
}

install_component () {
  component=$1
  component_dir=../components/bifrost_$component
  pushd $component_dir
  echo "component ${component} and dir ${component_dir}"
  set +e
  bash ./install.sh -i COMP
  if [ $? -ne 0 ]
  then
    echo "Failed to install $component. Attempting to continue"
  fi
  set -e
  get_environment_name env_name
  conda activate $env_name
  get_config_yaml config_yaml
  local CONFIG_YAML_PATH=$config_yaml
  get_component_name name
  component_name=("bifrost_"$name)
  python -m $component_name -h
  conda deactivate
  popd
}  

freeze_component () {
  echo "Freeze component"
  component=$1
  component_dir=../components/bifrost_$component
  echo "before pushd component_dir is $component_dir"
  ls -l $component_dir
  ls -l $component_dir/bifrost_$component

  pushd $component_dir
  echo "component ${component} and dir ${component_dir}"

  get_environment_name env_name

  conda activate $env_name
  get_config_yaml config_yaml
  local CONFIG_YAML_PATH=$config_yaml
  get_component_name name
  component_name=("bifrost_"$name)
  popd
  conda env export | grep -vP '(^prefix:)|(serum-readfilter)' > ${name}.frozen.yml
  echo "      - -e ." >> ${name}.frozen.yml
  conda deactivate  
}  

remove_environment () {
  component=$1
  component_dir=../components/bifrost_$component
  pushd $component_dir > /dev/null
  get_environment_name env_name
  popd > /dev/null
  if conda info --envs | grep -q $env_name; then
    echo mamba env remove -n $env_name
    mamba env remove -n $env_name
  fi
}
