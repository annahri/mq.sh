#!/bin/bash
mailq=$(command -v mailq)
parser='/opt/mailq-parser/lib/parser.awk'

main() {
    case "$1" in
        show)
            if [[ ! -f "$parser" ]]; then
                echo "This option requires \"parser.awk\"" >&2
                echo "It should be located in: $parser" >&2
                exit 1
            fi

            $mailq \
                | tail +2 \
                | awk -f "$parser"
            ;;
        brief)
            $mailq \
                | tail +2 \
                | awk 'BEGIN {RS=""; FS="\n"} {gsub(/^[ \t]*|[ \t]*$/,"",$3); print $1, $3}' \
                | awk '{print $1,$(NF-1)" => "$NF}' \
                | sed '$ d'
            ;;
        count)
            $mailq \
                | tail +2 \
                | grep -E -c '^[0-9A-F]{5,}'
            ;;
        search)
            if [[ ! -f "$parser" ]]; then
                echo "This option requires \"parser.awk\"" >&2
                echo "It should be located in: $parser" >&2
                exit 1
            fi

            if [[ -z "$2" ]]; then
                echo "Please specify a key-value pair." >&2
                echo "Available keys:" >&2
                echo " - sender / from" >&2
                echo " - recipient / to" >&2
                echo " - reason" >&2
                exit 2
            fi

            $mailq \
                | tail +2 \
                | awk -vsearch="$2" -f "$parser"
            ;;
        *)
            echo "z-queue [show|brief|count]"
            echo "or"
            echo "z-queue search [key=value]"
            ;;
    esac
}

main "$@"
