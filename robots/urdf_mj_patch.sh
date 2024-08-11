#!/bin/bash

# Check if the correct number of arguments was provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <urdf-file> <meshdir>"
    exit 1
fi

URDF_FILE=$1
MESHDIR=$2

# Define the XML snippet with the provided meshdir
XML_SNIPPET=" <mujoco>
      <compiler meshdir=\"$MESHDIR\" balanceinertia=\"true\" discardvisual=\"false\" />
    </mujoco>"

# Detect the first entry after the XML declaration and insert the XML snippet after it
awk -v snippet="$XML_SNIPPET" '
BEGIN { found_xml_declaration = 0 }
/^<\?xml version="1.0" \?>/ {
    print $0
    found_xml_declaration = 1
    next
}
NR == 1 && found_xml_declaration == 0 {
    print $0
    print snippet
    next
}
NR == 2 && found_xml_declaration == 1 {
    print $0
    print snippet
    next
}
{ print $0 }
' "$URDF_FILE" > temp_file && mv temp_file "$URDF_FILE"

sed -i 's|package:[^ ]*/||g' "$URDF_FILE"

echo "The XML snippet has been inserted after the first entry in $URDF_FILE with meshdir=\"$MESHDIR\"."
