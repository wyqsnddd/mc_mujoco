#!/bin/bash

# Check if the input arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <models_dir> <If it is an environment folder>"
  exit 1
fi


input=$1
if_env=$2


# Loop over the objects folder

FileExists(){
  if [[ ! -f $1 ]]; then
    echo "[Error] The file:  $1 does not exist"
    exit 1
  fi
}


IsURDF(){
  if [[ ! $1 == *.urdf ]]; then
    echo "[Error] The file:  $1 does not fulfill the pattern: *.urdf"
    exit 1
  fi
}

# check if the folder exists
FolderExists(){
  if [ ! -d $1 ]; then
    echo "The folder:  $input does not exist"
    echo "Usage: $0 <mc_int_obj_description_dir>"
    exit 1
  fi
}

NotYetExists(){
  if [ -f "@MC_MUJOCO_SHARE_DESTINATION@/object/$1" ];then
    echo "[Error] @MC_MUJOCO_SHARE_DESTINATION@/object/$1" already exists in the mc_mujoco folder:
    echo "Please considering another name for the new object $1"
    exit 1
  fi
}

CreateInstallationFile(){

  if [ -f $2 ]; then
    echo "The .in.yaml file $2 already exists"
    exit 1
  fi


  echo "[info] env is: $3"

  if $3; then

  cat <<EOF > "$2"
xmlModelPath: @MC_MUJOCO_SHARE_DESTINATION@/env/${1}.xml
EOF

  echo "setup_env_object($name env)" >> "CMakeLists.txt"
  else
    cat <<EOF > "$2"
xmlModelPath: @MC_MUJOCO_SHARE_DESTINATION@/object/${1}.xml
EOF

  echo "setup_env_object($name object)" >> "CMakeLists.txt"

  fi

}


FolderExists $input
FolderExists $input/urdf
FolderExists $input/rsdf
FolderExists $input/meshes


# sed -i 's|package:[^ ]*/||g' example.txt

MeshCount(){
  grep "<mesh" $1 | wc -l
}


for file in `ls $input/urdf`
do
  IsURDF $file
  # NotYetExists $file
  name=${file%.urdf}
  echo $name


  nMesh=$(MeshCount "$input/urdf/${name}.urdf")
  echo nMesh is $nMesh

  if [ $nMesh -eq 1 ]; then
    # a. creating the mujoco configuration file: *.xml
    source create_xml.sh "$name" "$input/meshes/${name}"
    # b. creating the installation file: *.in.xml
    # CreateInstallationFile $name "$name.in.yaml"
    # c. setup CMakeLists.txt
    # echo "setup_env_object($name object)" >> "CMakeLists.txt"
  else
    echo "Multiple mesh entries detected"

    # copy the compilation option into the URDF

    # Modify the meshdir

    # Modify the mesh entries

    meshdir=$input/meshes/$name
    cp $input/urdf/${name}.urdf .
    source urdf_mj_patch.sh ${name}.urdf $meshdir


    # Apply the Mujoco executable "compile"


    mj_compile=$(find ${HOME}/.mujoco/ -type f -name compile -executable | sort -V | tail -n 1)

    if [ -z "$mj_compile" ]; then
        echo "Error: No executable 'compile' found in ${HOME}/.mujoco/"
        return 1
    else
        echo "$mj_compile"
    fi

    ${mj_compile} ${name}.urdf ${name}.xml

    LINK_SNIPPET="<body name=\"${name}_base_link\"/>"

    COL_DEF="<default>\n  <default class=\"collision\">\n    <geom condim=\"3\" group=\"0\" />\n  </default>\n</default>"

    COL_SNIPPET="<geom class=\"collision\" mesh=\"${name}\"/>"

    # Use sed to insert the snippet after the first <worldbody> entry
    #
    sed -i "/<worldbody>/ a ${LINK_SNIPPET}" "${name}.xml"
    sed -i "/<worldbody>/ a ${COL_SNIPPET}" "${name}.xml"
    # Insert the COL_DEF snippet before the first <worldbody> entry
    sed -i "/<compiler/ a ${COL_DEF}" "${name}.xml"

    if [  $? -ne 0 ]; then
      echo [Error] failed to run ${mj_compile}
    fi

  fi
  # b. creating the installation file: *.in.xml and setup CMakeLists.txt
  CreateInstallationFile $name "$name.in.yaml" $if_env



done


#IsURDF "longtable.urdf"
echo "Pass"
