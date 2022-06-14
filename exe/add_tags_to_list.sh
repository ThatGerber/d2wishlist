#!/bin/bash
python_exe=$(command -v python3)
replace_exe="$(dirname "$0")/replace_list_tags.py"

"${python_exe}" "${replace_exe}" "${1}"
