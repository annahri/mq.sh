#!/bin/bash
mailq=$(command -v mailq)
parser='/opt/mailq-parser/lib/parser.awk'

usage() {
    cmd=$(basename "$0")
    echo "Usage: $cmd [options] <subcommand>" >&2
    echo  >&2
    echo "Subcommands:" >&2
    echo "  show    Display the whole mail queue." >&2
    echo "  search  Display only mails on the queue based on criteria." >&2
    echo "          e.g. search recipient=user@example.com" >&2
    echo "               search sender=user@example.com" >&2
    echo "               search reason=quota" >&2
    echo "  brief   Display the whole mail queue briefly." >&2
    echo "  count   Prints the number of mail in the queue." >&2
    echo >&2
    echo "Global options:" >&2
    echo "  -f      Use file as an input instead of mailq's output." >&2
    echo "  -m      Define 'mailq' path." >&2 
    echo "          e.g. mailq in Zimbra: /opt/zimbra/common/sbin/mailq" >&2
    echo "  -p      Define 'parser.awk' location instead of the default one." >&2
    echo "  -h      Display this help info."
}

check_parser() {
    if [[ ! -f "$parser" ]]; then
        echo "This option requires \"parser.awk\"" >&2
        echo "It should be located in: $parser" >&2
        echo "Or use -p option to define its custom location." >&2
        exit 1
    fi
}

mq_show() {
    check_parser
    $mailq | awk -f "$parser"
}

mq_brief() {
    $mailq \
        | awk 'NR == 1 {RS=""; next} NF > 7 { printf "%s\t%s\t%s\n", $1, $7, $NF; ++i } END { printf "\nDisplayed %d result(s).\n", i }'
}

mq_count() {
    $mailq \
        | awk 'NR == 1 {RS=""; next} /^[A-F0-9]+/ { i++ } END { print i }'
}

mq_search() {
    check_parser
    if [[ -z "$1" ]]; then
        echo "Please specify a key-value pair." >&2
        echo "Available keys:" >&2
        echo " - sender / from" >&2
        echo " - recipient / to" >&2
        echo " - reason" >&2
        exit 2
    fi
    
    $mailq \
        | awk -vsearch="$1" -f "$parser"
}

main() {
    if [[ $# -eq 0 ]]; then
        usage
        exit
    fi

    while [[ $# -ne 0 ]]; do case "$1" in
        # Subcommands
        brief|count|show|search) subcommand="mq_${1}" ;;
        # Options
        -f|--file)
            if [[ ! -f "$2" ]]; then
                echo "Specified file doesn't exist." >&2
                exit 1
            fi

            mailq="cat $2"
            shift
            ;;
        -m|--mailq)
            if [[ ! -x "$2" ]]; then
                echo "Specified mailq path is invalid." >&2
                exit 1
            fi

            mailq="$2"
            shift
            ;;
        -p|--parser)
            if [[ ! -f "$2" ]]; then
                echo "Parser file doesn't exist in: $2" >&2
                exit 1
            fi

            parser="$2"
            shift
            ;;
        -h) usage; exit ;;
        *) args+=( "$1" ) ;;
    esac; shift; done

    "$subcommand" "${args[@]}"
}

main "$@"
