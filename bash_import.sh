#!/bin/env bash

# Description:
#   Python-like import, which allows to include only specific functions/variables from an external script
#
# Usage:
#   - Global:
#   from test.lib import "*"
#
#   - Selective:
#   from test.lib import function_name, variable_name
#
#   - Namespaced (functions/variables will be available as 'MyNamespace.{name}'):
#   from test.lib import function_name, variable_name as MyNamespace
#
function from () {
    function realpath { echo "$(cd "$(dirname "$1")"; pwd)/"$(basename "$1")""; }

    local module_name;
    local module_path;
    local action;
    local namespace;
    local needed_modules;
    local -a params;

    POSITIONAL=()
    while [[ $# -gt 0 ]]; do
        key="$1"

        case $key in
            as)
                [[ -z "${2//[[:blank:]]/}" ]] && { printf "You did not specify a namespace after the 'as' keyword.\n" >&2; return 1; }
                namespace="${2}.";
                shift # past argument
                shift # past value
                break;
            ;;
            *)    # unknown option
                POSITIONAL+=("$1") # save it in an array for later
                shift # past argument
            ;;
        esac
    done
    set -- "${POSITIONAL[@]}" # restore positional parameters

    
    module_name="$1";
    module_path=$(realpath "$module_name");
    action="${2,,}";
    shift 2;

    [[ ! -f "$module_path" ]] && { printf "Argument is not a file\n" >&2; return 1; };
    [[ "$action" != "import" ]] && { printf "Command '%s' not supported\n" "$action" >&2; return 1; };

    needed_modules="$@";
    IFS="," read -ra params <<< "${needed_modules//[[:blank:]]/}"

    if [[ ${params[@]} == "*" ]]; then
        . "$module_path";
        return 0;
    fi;

    # set -x
    . <(
        . "$module_path";
        
        for param in "${params[@]}"; do
            declare -p "${param}" 2>/dev/null | sed -re "s/declare (-[[:alnum:]-])/declare -g \1/; s/([[:alnum:]_.-]+)=/${namespace}\1=/"; 
            __variable_rc=$?;
            
            declare -f "${param}" 2>/dev/null | sed "1s/^/${namespace}/"; 
            __function_rc=$?;
            
            (( (__function_rc + __variable_rc) > 0 )) && {
                printf "No variable/function named '%s' was found.\n" "${param}" >&2;
                return 2;
            } 
        done
    );
    # set +x
}
