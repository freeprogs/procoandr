#!/bin/bash

# This file is a part of procoandr v1.0.0
#
# Copy Java-files and resource files from one Android project to a
# new Android project.
#
# A developer can continue develop a project making its full copy as a
# completely new project with same Java-sources, layouts, libraries
# and pictures.
#
# License: GPLv3 http://www.gnu.org/licenses/
# Copyright (C) 2020, Slava freeprogs.feedback@yandex.ru

progname=`basename $0`

# Print an error message to stderr
# error(str)
# args:
#   str - string to output
# return:
#   none
error()
{
    echo "error: $progname: $1" >&2
}

# Print an message to stdout
# msg(str)
# args:
#   str - string to output
# return:
#   none
msg()
{
    echo "$progname: $1"
}

# Print short help about this script
# usage()
# args:
#   none
# return:
#   none
usage()
{
    echo "Try \`$progname --help' for more information." >&2
}

# Print full help about this script
# help_info()
# args:
#   none
# return:
#   none
help_info()
{
    echo "usage: $progname srcdir dstdir" >&2
}

# Translate name in any case to lower case
# get_small_name(name)
# args:
#   name - string with a name
# return:
#   name in lower case
get_small_name()
{
    echo -n "${1,,}"
}

# Check directory existence
# check_dir_existence(dir)
# args:
#   dir - string with a path to directory
# return:
#   0 if the directory exists
#   1 if the directory doesn't exist
check_dir_existence()
{
    [ -d "$1" ]
}

# Remove the manifest file
# manifest_remove_file(file)
# args:
#   file - path to the manifest file
# return:
#   0 if success
#   1 if fail
manifest_remove_file()
{
    rm -f "$1" &>/dev/null
}

# Copy the manifest file from one directory to another
# manifest_copy_file(src, dst)
# args:
#   src - path to the manifest file
#   dst - path where to copy the manifest file
# return:
#   0 if success
#   1 if fail
manifest_copy_file()
{
    cp "$1" "$2" &>/dev/null
}

# Replace names in the manifest file
# manifest_replace_names(file, str_in, str_out)
# args:
#   file    - path to the manifest file
#   str_in  - string to replace
#   str_out - string substituted
# return:
#   0 if success
#   1 if fail
manifest_replace_names()
{
    sed -i 's/'"$2"'/'"$3"'/g' "$1" &>/dev/null
}

# Remove the old manifest file, copy new manifest file and replace
# contents in the new manifest file
# copy_manifest(srcname, dstname, srcsmall, dstsmall)
# args:
#   srcname  - path to the source project with the manifest
#   dstname  - path to the destination project where the new manifest will be
#   srcsmall - string to replace in the manifest file
#   dstsmall - strint to substitute in the manifest file
# return:
#   0 if success
#   1 if fail
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

# Remove Java-files in the directory
# javafiles_remove_files(dir)
# args:
#   dir - path to the Java-files
# return:
#   0 if success
#   1 if fail
javafiles_remove_files()
{
    rm -f "$1/"*.java &>/dev/null
}

# Copy Java-files from one project to another
# javafiles_copy_files(src, dst)
# args:
#   src - path to the Java-files in the source project
#   dst - path to the Java-files in the destination project
# return:
#   0 if success
#   1 if fail
javafiles_copy_files()
{
    cp "$1/"*.java "$2" &>/dev/null
}

# Replace names in the Java-files
# javafiles_replace_names(dir, srcupper, dstupper, srclower, dstlower)
# args:
#   dir - path to the Java-files
#   srcupper - a name in upper case to replace
#   dstupper - a name in upper case to substitute
#   srclower - a name in lower case to replace
#   dstlower - a name in lower case to substitute
# return:
#   0 if success
#   1 if fail
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

# Remove old Java-files, copy new Java-files and replace contents in
# the new Java-files
# copy_java_files(srcupper, dstupper, srclower, dstlower)
# args:
#   srcupper - a name in upper case to replace
#   dstupper - a name in upper case to substitute
#   srclower - a name in lower case to replace
#   dstlower - a name in lower case to substitute
# return:
#   0 if success
#   1 if fail
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

# Remove resources in the directory
# resources_remove_files(dir)
# args:
#   dir - path to directory should be deleted
# return:
#   0 if success
#   1 if fail
resources_remove_files()
{
    rm -rf "$1" &>/dev/null
}

# Copy resources from the old directory to the new directory
# resources_copy_files(src, dst)
# args:
#   src - path to the old resource files
#   dst - path to the new resource files
# return:
#   0 if success
#   1 if fail
resources_copy_files()
{
    cp -R "$1" "$2" &>/dev/null
}

# Replace names in resources files
# resources_replace_names(dir)
# args:
#   dir - path to the resources files
# return:
#   0 if success
#   1 if fail
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

# Remove old resource files, copy new resource files and replace contents in
# the new resource files
# copy_resources(srcupper, dstupper, srclower, dstlower))
# args:
#   srcupper - a name in upper case to replace
#   dstupper - a name in upper case to substitute
#   srclower - a name in lower case to replace
#   dstlower - a name in lower case to substitute
# return:
#   0 if success
#   1 if fail
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

# Copy libraries files
# libraries_copy_files(src, dst)
# args:
#   src - path to the old library files
#   dst - path to the new library files
# return:
#   0 if success
#   1 if fail
libraries_copy_files()
{
    cp "$1"/* "$2" &>/dev/null
}

# Copy old libraries files to new libraries files
# copy_libraries(src, dst))
# args:
#   src - path to the old library files
#   dst - path to the new library files
# return:
#   0 if success
#   1 if fail
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

# Copy manifest, Java-files, resourses, libraries from source to destination
# copy_project_to_new_project(src, dst)
# args:
#   src - path to the source project
#   dst - path to the destination project
# return:
#   0 if success
#   1 if fail
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

# Run main script operations.
# Read cmdline option and copy source project to destination project
# main(cmdarg)
# main(src, dst)
# args:
#   cmdarg - command line argument (--help)
#   src - source project
#   dst - destination project
# return:
#   0 if success
#   1 if fail
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
        copy_project_to_new_project "$1" "$2" || return 1
        msg "$1 has copied to $2 -> Ok"
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
