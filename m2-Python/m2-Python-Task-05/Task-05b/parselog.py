#!/usr/bin/env/python3.10

"""Task-05b"""

from parseargs import ScriptArgs
import re


def most_freq_browse_ips(file, ip_count) -> dict:
    pass


def main(file, task, ip_count) -> None:
    if task == 1:
        print(most_freq_browse_ips(file, ip_count))
    elif task == 2:
        pass
    elif task == 3:
        pass
    elif task == 4:
        pass
    elif task == 5:
        pass
    elif task == 6:
        pass
    elif task == 7:
        pass

if __name__ == '__main__':
    args = ScriptArgs().get_args()
    main(file=args['file'], task = args['task'],
         ip_count=args['ip_count'] if args['ip_count'] else 1)

