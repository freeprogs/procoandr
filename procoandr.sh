#!/bin/bash

# This file is a part of procoandr v0.0.0
#
# Copy Java-files and resource files from one Android project to a
# new Android project.
#
# A developer can continue develop a project making its full copy as a
# completely new project with same Java-sorces, layouts, libraries and
# pictures.
#
# License: GPLv3 http://www.gnu.org/licenses/
# Copyright (C) 2020, Slava freeprogs.feedback@yandex.ru

progname=`basename $0`

# Print an error message to stderr
# error(str)
error()
{
    echo "error: $progname: $1" >&2
}

# Print an message to stdout
# msg(str)
msg()
{
    echo "$progname: $1"
}

# Print program usage to stderr
# usage()
usage()
{
    echo "Try \`$progname --help' for more information." >&2
}

# Print program help info to stderr
# help_info()
help_info()
{
    echo "usage: $progname srcdir dstdir" >&2
}

get_small_name()
{
    echo -n "${1,,}"
}

check_dir_existence()
{
    [ -d "$1" ]
}

manifest_remove_file()
{
    rm -f "$1" &>/dev/null
}

manifest_copy_file()
{
    cp "$1" "$2" &>/dev/null
}

manifest_replace_names()
{
    sed -i 's/'"$2"'/'"$3"'/g' "$1" &>/dev/null
}

copy_manifest()
{
    local src_name_exact
    local src_name_small
    local dst_name_exact
    local dst_name_small
    local src_path_to_manifest
    local dst_path_to_manifest

    src_name_exact=$1
    dst_name_exact=$2
    src_name_small=$3
    dst_name_small=$4

    src_path_to_manifest="${src_name_exact}/app/src/main/AndroidManifest.xml"
    dst_path_to_manifest="${dst_name_exact}/app/src/main/AndroidManifest.xml"

    manifest_remove_file "$dst_path_to_manifest" || {
        error "Can't remove the manifest file in destination: $dst_path_to_manifest"
        return 1
    }
    manifest_copy_file "$src_path_to_manifest" "$dst_path_to_manifest" || {
        error "Can't copy the manifest file from source to destination: \
$src_path_to_manifest to $dst_path_to_manifest"
        return 1
    }
    manifest_replace_names "$dst_path_to_manifest" "$src_name_small" "$dst_name_small" || {
        error "Can't replace project name in manifest: \
$src_name_small to $dst_name_small"
        return 1
    }
    return 0
}

javafiles_remove_files()
{
    rm -f "$1/"*.java &>/dev/null
}

javafiles_copy_files()
{
    cp "$1/"*.java "$2" &>/dev/null
}

javafiles_replace_names()
{
    local dpath
    local fpath

    dpath=$1

    for fpath in "$dpath/"*.java; do
        sed -i 's/'"$2"'/'"$3"'/g' "$fpath" &>/dev/null
        sed -i 's/'"$4"'/'"$5"'/g' "$fpath" &>/dev/null
    done
}

copy_java_files()
{
    local src_name_exact
    local src_name_small
    local dst_name_exact
    local dst_name_small
    local src_path_to_javafiles
    local dst_path_to_javafiles

    src_name_exact=$1
    dst_name_exact=$2
    src_name_small=$3
    dst_name_small=$4

    src_path_to_javafiles="${src_name_exact}/app/src/main/java/com/example/${src_name_small}/"
    dst_path_to_javafiles="${dst_name_exact}/app/src/main/java/com/example/${dst_name_small}/"

    javafiles_remove_files "$dst_path_to_javafiles" || {
        error "Can't remove Java-files in destination: $dst_path_to_javafiles"
        return 1
    }
    javafiles_copy_files "$src_path_to_javafiles" "$dst_path_to_javafiles" || {
        error "Can't copy Java-files from source to destination: \
$src_path_to_javafiles to $dst_path_to_javafiles"
        return 1
    }
    javafiles_replace_names "$dst_path_to_javafiles" \
                            "$src_name_small" "$dst_name_small" \
                            "$src_name_exact" "$dst_name_exact" || {
        error "Can't replace project name in Java-files: \
$src_name_small to $dst_name_small and $src_name_exact to $dst_name_exact"
        return 1
    }
    return 0
}

resources_remove_files()
{
    rm -rf "$1" &>/dev/null
}

resources_copy_files()
{
    cp -R "$1" "$2" &>/dev/null
}

resources_replace_names()
{
    local dpath
    local files_list
    local fname
    local fpath

    dpath=$1
    files_list=("menu/menu_main.xml"
                "values/strings.xml"
                "navigation/nav_graph.xml")

    for fname in "${files_list[@]}"; do
        fpath="$dpath/$fname"
        sed -i 's/'"$2"'/'"$3"'/g' "$fpath" &>/dev/null
        sed -i 's/'"$4"'/'"$5"'/g' "$fpath" &>/dev/null
    done
}

copy_resources()
{
    local src_name_exact
    local src_name_small
    local dst_name_exact
    local dst_name_small
    local src_path_to_resources
    local dst_path_to_resources

    src_name_exact=$1
    dst_name_exact=$2
    src_name_small=$3
    dst_name_small=$4

    src_path_to_resources="${src_name_exact}/app/src/main/res"
    dst_path_to_resources="${dst_name_exact}/app/src/main/res"

    resources_remove_files "$dst_path_to_resources" || {
        error "Can't remove resources files in destination: $dst_path_to_resources"
        return 1
    }
    resources_copy_files "$src_path_to_resources" "$dst_path_to_resources" || {
        error "Can't copy resources files from source to destination: \
$src_path_to_resources to $dst_path_to_resources"
        return 1
    }
    resources_replace_names "$dst_path_to_resources" \
                            "$src_name_small" "$dst_name_small" \
                            "$src_name_exact" "$dst_name_exact" || {
        error "Can't replace project name in resources files: \
$src_name_small to $dst_name_small and $src_name_exact to $dst_name_exact"
        return 1
    }
    return 0
}

libraries_copy_files()
{
    cp "$1"/* "$2" &>/dev/null
}

copy_libraries()
{
    local src_name_exact
    local dst_name_exact
    local src_path_to_libraries
    local dst_path_to_libraries

    src_name_exact=$1
    dst_name_exact=$2

    src_path_to_libraries="${src_name_exact}/app/libs"
    dst_path_to_libraries="${dst_name_exact}/app/libs"

    libraries_copy_files "$src_path_to_libraries" "$dst_path_to_libraries" || {
        error "Can't copy libraries files from source to destination: \
$src_path_to_libraries to $dst_path_to_libraries"
        return 1
    }
    return 0
}

copy_project_to_new_project()
{
    local src_name_exact
    local src_name_small
    local dst_name_exact
    local dst_name_small

    src_name_exact="$1"
    src_name_small=`get_small_name $src_name_exact`
    dst_name_exact="$2"
    dst_name_small=`get_small_name $dst_name_exact`

    check_dir_existence "$src_name_exact" || {
        error "Can't find the source directory: $src_name_exact"
        return 1
    }
    check_dir_existence "$dst_name_exact" || {
        error "Can't find the destination directory: $dst_name_exact"
        return 1
    }

    copy_manifest "$src_name_exact" "$dst_name_exact" \
                  "$src_name_small" "$dst_name_small" || {
        error "Can't copy manifest"
        return 1
    }

    copy_java_files "$src_name_exact" "$dst_name_exact" \
                    "$src_name_small" "$dst_name_small" || {
        error "Can't copy Java-files"
        return 1
    }

    copy_resources "$src_name_exact" "$dst_name_exact" \
                   "$src_name_small" "$dst_name_small" || {
        error "Can't copy resources"
        return 1
    }

    copy_libraries "$src_name_exact" "$dst_name_exact" || {
        error "Can't copy libraries"
        return 1
    }

    return 0
}

main()
{
    case $# in
    0)
        usage || return 1
        ;;
    1)
        [ "$1" = "--help" ] && {
            help_info
            return 1
        }
        usage
        return 1
        ;;
    2)
        copy_project_to_new_project "$1" "$2"
        ;;
    *)
        usage
        error "unknown arglist: \"$*\""
        return 1
        ;;
    esac
    return 0
}

main "$@" || exit 1

exit 0
