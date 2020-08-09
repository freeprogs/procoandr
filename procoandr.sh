#!/bin/bash

# This script

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

copy_manifest()
{
    echo "Copy manifest in $1 to $2"
    echo "Replace name from $1 to $2 and from $3 to $4"
}

copy_java_files()
{
    echo "Copy Java-files in $1 to $2"
    echo "Replace name from $1 to $2 and from $3 to $4"
}

copy_resources()
{
    echo "Copy resources in $1 to $2"
    echo "Replace name from $1 to $2 and from $3 to $4"
}

copy_libraries()
{
    echo "Copy libraries in $1 to $2"
    echo "Replace name from $1 to $2 and from $3 to $4"
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

    copy_libraries "$src_name_exact" "$dst_name_exact" \
                   "$src_name_small" "$dst_name_small" || {
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
