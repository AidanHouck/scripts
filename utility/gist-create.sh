#!/usr/bin/env bash

# Create a gist of the given file automatically

if [ -z "$1" ]; then
        echo Error: Please supply a file name
        exit 1
fi

if [ -z "$2" ]; then
        # Default to public
        OPT_FLAG="-p"
elif [[ "$2" == "private" ]]; then
        OPT_FLAG=""
elif [[ "$2" == "public" ]]; then
        OPT_FLAG="-p"
else
        echo Error: Please specify either 'public' or 'private' for gist visibility
        exit 1
fi

gh gist create "$1" -d "$(head -n 3 "$1" | tail -n 1)" $OPT_FLAG
