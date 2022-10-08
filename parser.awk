#!/bin/awk -f

BEGIN {
    RS = "\n\n"
    reset = "\033[0m"
    red = "\033[31m"
    green = "\033[32m"
    yellow = "\033[33m"
    blue = "\033[34m"
}

function print_range(start, end) {
    result = $start

    for (i = start + 1; i <= end; i++) {
        result = result" "$i
    }

    gsub(/^\(|\)$/, "", result)
    return result
}

function explain_msg(message) {
    if (message ~ "^host") {
        match(message, /host (.*)\[(.*)\] said: ([0-9]{3}[- ][0-9]+\.[0-9]+\.[0-9]+) (.*)$/, array)
        print "REASON"
        print " => HOSTNAME: " blue array[1] reset
        print " => IP: " yellow array[2] reset
        print " => ERROR CODE: " yellow array[3] reset
        print " => MESSAGE: " red array[4] reset
    } else if (message ~ "^connect") {
        print "REASON: " red message reset
    }
}

function search_by(pattern, search_array, search_string) {
    x = 0
    gsub(pattern, "", search_string)
    for (key in search_array) {
        if (search_array[key] != search_string) continue
        display(key, sender[key], recipient[key], q_body[key])
        x++
    }

    print "Returned " yellow x reset " result(s)."
}

function display(qid, msg1, msg2, msg3) {
    printf "== %s ==\n", qid
    print "SENDER: " blue msg1 reset
    print "RECIPIENT: " blue msg2 reset
    explain_msg(msg3)
    print ""
}

{
    if (NF < 7) next

    size[$1] = $2
    timestamp[$1] = print_range(3, 6)
    sender[$1] = $7
    q_body[$1] = print_range(8, NF - 1)
    recipient[$1] = $NF
    x++

    if (! search) {
        display($1, sender[$1], recipient[$1], q_body[$1])
    }
}

END {
    if (! search) {
        print "Displayed " yellow x reset " result(s)."
        exit
    }

    if (search ~ "^(from|sender)=") {
        search_by("^(from|sender)=", sender, search)
    } else if (search ~ "^(to|recipient)=") {
        search_by("^(to|recipient)=", recipient, search)
    } else if (search ~ "^q?id=") {
        gsub(/^q?id=/, "", search)
        if (sender[search] == "") exit
        display(search, sender[search], recipient[search], q_body[search])
    } else if (search ~ "^reason=") {
        gsub(/^reason=/, "", search)
        x = 0
        for (key in q_body) {
            if (q_body[key] !~ search) continue
            display(key, sender[key], recipient[key], q_body[key])
            x++
        }
        print "Returned " yellow x reset " result(s)."
    } else {
        print red "Unknown format or key." reset
        print "Examples:"
        print "  search recipient=aa@example.com"
        print "  search sender=bb@example.com"
        print "  search \"reason=Over quota\""
        exit
    }
}
