#!/usr/bin/env/python3.10

"""Task-05b Apache's Log Parser"""

from parseargs import ScriptArgs
import collections
import itertools
import re
import datetime


def grep_log(log_file, pattern=None, return_match=None) -> list:
    """
    Make looking for 'pattern' in 'log_file'. If 'return match'
    is True, then function returns exact matches only, else whole
    lines where matches found.
    :param log_file:
    :param pattern:
    :param return_match:
    :return:
    """
    grepped_list = []
    while True:
        line = log_file.readline()
        if not line:
            break
        found = re.search(pattern, line)
        if found:
            grepped_list.append(line if not return_match else found.group())
        else:
            continue
    log_file.seek(0)
    return grepped_list


def top_n_from_list(found_list, count, sort_by_name=False) -> dict:
    """
    :param found_list:
    :param count:
    :param sort_by_name:
    :return: dictionary with 'count' of most frequently repeated items from 'found_list'
    """
    counts = collections.Counter(found_list)
    sorted_list = sorted(found_list, key=counts.get if not sort_by_name else None,
                         reverse=True if not sort_by_name else False)
    ip_dict = dict()
    for each in sorted_list:
        if each in ip_dict.keys():
            ip_dict.update({each: ip_dict.get(each) + 1})
        else:
            ip_dict.update({each: 1})
    return {n: ip_dict[n] for n in list(ip_dict)[:count]}


def top_long_from_list(found_list, count, long) -> dict:
    """
    :param found_list:
    :param count:
    :param long:
    :return: dictionary with 'count' most long or short items from 'found_list'
    """
    sorted_list = sorted(found_list, key=len, reverse=long)
    req_dict = dict()
    for each in sorted_list:
        req_dict.update({each: len(each)})
    return {n: req_dict[n] for n in list(req_dict)[:count]}


def cut_requests(input_list, k) -> list:
    """
    :param input_list:
    :param k:
    :return: list of cutted requests from 'input_list' till k-th slash
    """
    output_list = []
    for each in input_list:
        temp = [x.start() for x in re.finditer('/', each)]
        result = each[0:temp[k - 1] if len(temp)>=k else temp[len(temp)-1]]
        output_list.append(result)
    return output_list


def time_distribution(log_file, time, entity_list=None) -> dict:
    """
    :param log_file:
    :param time:
    :param entity_list:
    :return: a dictionary with distribution of requests (or items specified in 'entity_list')
    per 'time' intervals in seconds.
    """
    time_dict = dict()
    unix_list = list()
    # Looking for log's start-time and end-time:
    while True:
        line = log_file.readline()
        if not line:
            break
        # Looking for pattern [08/Oct/2015:09:01:42 +0000]
        time_mark = re.search(r'[0-9]{2}/[A-Za-z]{3}/[0-9]{4}(:[0-9]{2}){3}', line)
        if time_mark:
            date_format = datetime.datetime.strptime(time_mark.group(), "%m/%b/%Y:%H:%M:%S")
            unix_time = datetime.datetime.timestamp(date_format)
            unix_list.append(unix_time)
        else:
            continue
    unix_list = sorted(unix_list)
    start_time = unix_list[0]
    end_time = unix_list[-1]
    # Fill all time-slots in distribution with 0:
    for k in range(0,int((end_time-start_time)/time)+1):
        time_dict.update({datetime.datetime.fromtimestamp(start_time+k*time):0})
    # If distribution parameter is not set. Distribution of all records in log:
    if not entity_list:
        for each in unix_list:
            if each % start_time >= time:
                start_time += time
            time_dict.update({datetime.datetime.fromtimestamp(start_time):
                                  time_dict[datetime.datetime.fromtimestamp(start_time)] + 1
                                  if time_dict.get(datetime.datetime.fromtimestamp(start_time))
                                  else 1})
    # When distribution parameter was set (by 50X errors or by workers or by anything else):
    else:
        for each in entity_list:
            time_mark = re.search(r'[0-9]{2}/[A-Za-z]{3}/[0-9]{4}(:[0-9]{2}){3}', each)
            if time_mark:
                date_format = datetime.datetime.strptime(time_mark.group(), "%m/%b/%Y:%H:%M:%S")
                unix_time = datetime.datetime.timestamp(date_format)
                for key, value in time_dict.items():
                    unix_in_dict = datetime.datetime.timestamp(key)
                    if unix_time%unix_in_dict < time:
                        time_dict.update({key:value+1})
            else:
                continue
    return time_dict


def print_result(result_dict: dict) -> None:
    """
    :param result_dict:
    :return: None. Prints dictionary to screen.
    """
    for key, value in result_dict.items():
        print(key, '=>', value)


def main(file, task, count, time, worker, long, short, k, sort_by_name) -> None:
    """
    Main function describes a general logic of a script depending on transferred arguments
    :param file:
    :param task:
    :param count:
    :param time:
    :param worker:
    :param long:
    :param short:
    :param k:
    :param sort_by_name:
    :return: None
    """
    log_file = open(file, 'rt')
    result = dict()
    if task == 1:
        pattern = r'\(((\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|unknown)(, )?)+\)'
        grepped_ips = grep_log(log_file,pattern,return_match=True)
        browser_ips = []
        for each in grepped_ips: browser_ips.append(each.strip('()').split(', ')[0])
        result = top_n_from_list(browser_ips, count)
        print('Browser IP(s), which meet most frequently:')
    elif task == 2:
        result = time_distribution(log_file,time)
        print(f'Requests count per {time}-seconds interval(s):')
    elif task == 3:
        pattern = r'"\w+/[0-9]+\..+?"'
        grepped_UA_list = grep_log(log_file, pattern, return_match=True)
        result = top_n_from_list(grepped_UA_list, count)
        print('Most frequent User-Agent(s):')
    elif task == 4:
        pattern = r'50[0-9] (([0-9]{1,8}|-) ){3}'
        greped_errors = grep_log(log_file, pattern)
        result = time_distribution(log_file, time, greped_errors)
        print(f'50X-errors count per {time}-seconds interval(s):')
    elif task == 5 or task == 6:
        pattern = r'"[A-Z]{3,7} .+ HTTP/[0-9]\.[0-9]"'
        grepped_req = grep_log(log_file, pattern, return_match=True)
        clear_req = []
        for each in grepped_req: clear_req.append(each.split()[1])
        if task == 5:
            result = top_long_from_list(clear_req, count, long if long or not short else False)
            print(f'{count} most {"short" if short else "long"} request(s):\n[Request => count of symbols]')
        else:
            cutted_req = cut_requests(clear_req, k)
            result = top_n_from_list(cutted_req, count)
            print(f'{count} most frequent requests to {k} slash:')
    elif task == 7:
        pattern = r'"[a-z]{3}://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(:[0-9]{2,5})?"'
        workers_list = grep_log(log_file, pattern, return_match=True)
        result = top_n_from_list(workers_list, len(workers_list))
        print(f'Requests count per each worker:')
    elif task == 8:
        pattern = r'https?://(?:[-\w.]|(?:%[\da-fA-F]{2}))+'
        grepped_refs = grep_log(log_file,pattern,return_match=True)
        result = top_n_from_list(grepped_refs, len(grepped_refs), sort_by_name)
        print(f'Referer statistics:')
    elif task == 9:
        pattern = r'"[a-z]{3}://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(:[0-9]{2,5})?"' if not worker else f'ajp://{worker}'
        greped_workers = grep_log(log_file, pattern)
        result = time_distribution(log_file, time, greped_workers)
        print(f'Requests count to worker {worker} per {time}-seconds interval(s):')
    elif task == 10:
        requests = time_distribution(log_file, time)
        most_load = top_n_from_list(requests, count)
        result = dict()
        for each in most_load.keys(): result.update({each:requests.get(each)})
        print(f'Top {count} {time}-seconds time intervals with most number of requests:')
    else:
        print('Incorrect task number. Select from 1 to 10.')
    print_result(result)
    log_file.close()

if __name__ == '__main__':
    args = ScriptArgs().get_args()
    main(file=args['file'], task = args['task'],
         count=args['number'] if args['number'] else 1,
         time=args['time'] if args['time'] else 60,
         worker=args['worker'],long=args['long'],
         short=args['short'],
         k=args['kslash'] if args['kslash'] else 2,
         sort_by_name=args['sortbyname'])
