# mq.sh - Postfix's Mailq Parser

![Screenshot](./screenshot.jpg)

## Usage

```
Usage: mq.sh [options] <subcommand>

Subcommands:
  show    Display the whole mail queue.
  search  Display only mails on the queue based on criteria.
          e.g. search recipient=user@example.com
               search sender=user@example.com
               search reason=quota
  brief   Display the whole mail queue briefly.
  count   Prints the number of mail in the queue.

Global options:
  -f      Use file as an input instead of mailq's output.
  -m      Define 'mailq' path.
          e.g. mailq in Zimbra: /opt/zimbra/common/sbin/mailq
  -p      Define 'parser.awk' location instead of the default one.
  -h      Display this help info.
```

## Installation

Put both `mq.sh` and `parser.awk` in:

```
/opt/mailq-parser/bin

and

/opt/mailq-parser/lib
```

respectively.

Then add `/opt/mailq-parser/bin` to your `PATH`.
