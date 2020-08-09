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

copy_project_to_new_project()
{
    echo "Copy $1 to $2"
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
