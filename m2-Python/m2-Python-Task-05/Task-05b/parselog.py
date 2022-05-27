#!/usr/bin/env/python3.10

"""Task-05b"""

from parseargs import ScriptArgs
import collections
import itertools
import re
import datetime


def top_n_from_list(found_list, count) -> dict:
    counts = collections.Counter(found_list)
    sorted_list = sorted(found_list, key=counts.get, reverse=True)
    ip_dict = dict()
    for each in sorted_list:
        if each in ip_dict.keys():
            ip_dict.update({each: ip_dict.get(each) + 1})
        else:
            ip_dict.update({each: 1})
    return {n: ip_dict[n] for n in list(ip_dict)[:count]}


def most_freq_browse_ips(file, count) -> dict:
    log_file = open(file, 'rt')
    found_list = []
    while True:
        line = log_file.readline()
        if not line:
            break
        #search by pattern: (xxx.xxx.xxx.xxx|unknown, xxx.xxx.xxx.xxx|unknown, ...)
        found = re.search(r'\(((\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|unknown)(, )?)+\)', line)
        if found:
            #1-st IP is client's IP, others - are proxies
            found_list.append(found.group().strip('()').split(', ')[0])
        else:
            continue
    log_file.close()
    return top_n_from_list(found_list, count)


def request_freq(file, time) -> dict:
    log_file = open(file, 'rt')
    time_dict = dict()
    unix_list = list()

    while True:
        line = log_file.readline()
        if not line:
            break
        # [08/Oct/2015:09:01:42 +0000]
        time_mark = re.search(r'[0-9]{2}/[A-Za-z]{3}/[0-9]{4}(:[0-9]{2}){3}', line)
        if time_mark:
            date_format = datetime.datetime.strptime(time_mark.group(), "%m/%b/%Y:%H:%M:%S")
            unix_time = datetime.datetime.timestamp(date_format)
            unix_list.append(unix_time)

            #print(unix_time - ((unix_time+0)%time+30))
            time_slot = unix_time-(unix_time+0)%time
            #print(time_slot)
            slot_read = datetime.datetime.fromtimestamp(time_slot)
            time_dict.update({slot_read:time_dict[slot_read]+1
                             if time_dict.get(slot_read)
                             else 1})
        else:
            continue
    log_file.close()
    sorted_list = sorted(unix_list)
    print(sorted_list[:10])
    print(datetime.datetime.fromtimestamp(sorted_list[0]), datetime.datetime.fromtimestamp(sorted_list[1]),
          datetime.datetime.fromtimestamp(sorted_list[2]), datetime.datetime.fromtimestamp(sorted_list[4]))
    return time_dict


def most_freq_user_agents(file, count) -> dict:
    log_file = open(file, 'rt')
    found_list = []
    while True:
        line = log_file.readline()
        if not line:
            break
        #search by pattern: "Xxxxx/0.0 ..."
        found = re.search(r'"\w+/[0-9]+\..+"', line)
        if found:
            found_list.append(found.group())
        else:
            continue
    log_file.close()
    return top_n_from_list(found_list, count)


def print_result(result_dict: dict) -> None:
    for key, value in result_dict.items():
        print(key, '=>', value)


def main(file, task, count, time) -> None:
    if task == 1:
        print('Browser IPs, which meet most frequently:\n', most_freq_browse_ips(file, count))
    elif task == 2:
        print(f'Requests per {time} seconds intervals:\n')
        print_result(request_freq(file, time))
    elif task == 3:
        print('Most frequent User-Agents:\n', most_freq_user_agents(file, count))
    elif task == 4:
        print('Most frequent User-Agents:\n', most_freq_user_agents(file, count))
    elif task == 5:
        pass
    elif task == 6:
        pass
    elif task == 7:
        pass

if __name__ == '__main__':
    args = ScriptArgs().get_args()
    main(file=args['file'], task = args['task'],
         count=args['count'] if args['count'] else 1,
         time=args['time'] if args['time'] else 60)

