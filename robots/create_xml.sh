#!/bin/bash

# Check if the input arguments are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <model_name> <model_mesh_dir>"
  exit 1
fi

model_name=$1
model_mesh_dir=$2

case1="$model_mesh_dir/$model_name.stl"
case2="$model_mesh_dir/$model_name.STL"

output_file="${model_name}.xml"


# Check if the mesh exists
if [ -f $case1 ]; then
  stl_file=$case1
elif [ -f  $case2  ]; then
  stl_file=$case2
else
  echo echo "Error: Mesh file '$model_name.stl' or '$model_name.STL' not found in directory '$model_mesh_dir'."
  exit 1
fi


#echo stl_file is: $stl_file

# Generate the XML content and write to the output file
cat <<EOF > "$output_file"
<mujoco model="$model_name">
    <compiler meshdir="assets" texturedir="assets"/>
    <asset>
        <material name="lightblue" rgba=".094 .545 .76 1"/>
        <mesh name="${model_name}_mesh" file="${stl_file}" />
    </asset>
    <default>
        <default class="collision">
            <geom condim="3" group="0" />
        </default>
        <default class="visual">
            <geom condim="3" group="1" conaffinity="0" contype="0" />
        </default>
    </default>
    <worldbody>
        <body name="${model_name}_base_link">
            <light mode="fixed" directional="false" diffuse=".8 .8 .8" specular="0.3 0.3 0.3" pos="0 0 -4.0" dir="0 0 1" />
            <geom class="visual" type="mesh" mesh="${model_name}_mesh" material="lightblue" />
            <geom class="collision" mesh="${model_name}_mesh"/>
        </body>
    </worldbody>
</mujoco>
EOF

# echo "XML file generated: $output_file"
