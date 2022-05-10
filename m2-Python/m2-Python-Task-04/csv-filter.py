#!/usr/bin/env/ python3

"""Task-04 CSV (TSV, DSV) filter"""

import argparse
import re
import csv
import json


def parse_arguments() -> dict:
    """
    Parse script's arguments
    :return: a dictionary with all entered options
    """
    args_parser = argparse.ArgumentParser(description='CSV (TSV, DSV) filter')

    args_parser.add_argument('-c', '--column',
                             type=str,
                             help='Filtering by column number. Use exact column numbers or ranges.'
                                  ' Example: 1,4,67-93,110')
    args_parser.add_argument('-d', '--delimiter',
                             type=str,
                             help='A one-character string used to separate fields. It defaults to ","')
    args_parser.add_argument('-q', '--quotechar',
                             type=str,
                             help='A one-character string used to quote fields containing special'
                                  ' characters, such as the delimiter or quotechar, or which contain'
                                  ' new-line characters. It defaults to ".')
    args_parser.add_argument('-i', '--input',
                             type=str,
                             help='The path to CSV file to be filtered')
    args_parser.add_argument('-j', '--json',
                             action='count',
                             default=0,
                             help='Convert CSV to JSON format')
    args_parser.add_argument('-l', '--line',
                             type=str,
                             help='Filtering by line number. Use exact line numbers or ranges.'
                                  ' Example: 1,4,67-93,110')
    args_parser.add_argument('-o', '--output',
                             type=str,
                             help='Output flag. To console by default, into a file is optional'
                                  '(requires the path to output file)')
    args_parser.add_argument('-od', '--odelimiter',
                             type=str,
                             help='A one-character string used to separate fields in output file.'
                                  ' It defaults to ","')
    args_parser.add_argument('-oq', '--oquotechar',
                             type=str,
                             help='A one-character string for output file used to quote fields'
                                  ' containing special characters, such as the delimiter or quotechar,'
                                  ' or which contain new-line characters. It defaults to \'"\'.')
    args_parser.add_argument('-r', '--regex',
                             type=str,
                             help='Search by regex. See https://docs.python.org/3/library/re.html'
                                  ' for regular expressions syntax. Example:'
                                  ' -r \'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\'')
    args_parser.add_argument('-header', '--header',
                             action='count',
                             default=0,
                             help='Flag of header line. Header line included by default in output result.'
                                  ' Add "-header" or "--header" to exclude it.')
    return vars(args_parser.parse_args())


def get_dict(path, delimiter, quote_char, header) -> dict:
    """
    Converts csv to python dictionary
    :param quote_char:
    :param delimiter:
    :param header:
    :param path:
    :return: csv_dict
    """
    csv_dict = {}
    # with open(path, 'rt') as csv_file:
    #     csv_reader = csv.reader(csv_file, delimiter=delimiter, quotechar=quote_char)
    #     if header:
    #         next(csv_reader, None)
    #     i = int(header)
    #     for row in csv_reader:
    #         csv_dict.update({i: row})
    #         i += 1

    with open(path, newline='') as csvfile:
        dialect = csv.Sniffer().sniff(csvfile.read(1024))
        csvfile.seek(0)
        csv_reader = csv.reader(csvfile, dialect)
        if header:
            next(csv_reader, None)
        i = int(header)
        for row in csv_reader:
            csv_dict.update({i: row})
            i += 1

    return csv_dict


def parse_range(ranges) -> dict:
    """
    Makes dictionary with line or column ranges needed to be filtered
    :param ranges:
    :return: range_dict
    """
    range_dict = {}
    for each in ranges.split(','):
        pair = each.split('-')
        if len(pair) == 2 and int(pair[0]) <= int(pair[1]):
            range_dict.update({pair[0]: pair[1]})
        elif len(pair) == 1:
            range_dict.update({pair[0]: pair[0]})
        else:
            print('Incorrect line or column range. Enter from lower to larger:', pair)
            exit(-1)
    return range_dict


def filter_lines(csv_dict, lines_ranges, header) -> dict:
    """
    Filters by specified lines
    :param csv_dict:
    :param lines_ranges:
    :param header:
    :return: dictionary with a filtered lines
    """
    filtered = {}
    for key, value in lines_ranges.items():
        filtered.update(dict(list(csv_dict.items())[int(key) - int(header):
                                                    int(value) - int(header) + 1]))
    return filtered


def filter_columns(csv_dict, column_ranges) -> dict:
    """
    Filters by specified columns
    :param csv_dict:
    :param column_ranges:
    :return: dictionary with a filtered columns
    """
    filtered = {}
    for line, data in csv_dict.items():
        filtered_columns = []
        for start, end in column_ranges.items():
            filtered_columns += data[int(start) - 1:int(end)]
        filtered.update({line: filtered_columns})
    return filtered


def filter_by_regex(csv_dict, regex) -> dict:
    """
    Filter by regex
    :param csv_dict:
    :param regex:
    :return: dictionary of fields matched with regex
    """
    filtered = {}
    for line, data in csv_dict.items():
        filtered_columns = []
        for field in data:
            if re.search(regex, field):
                filtered_columns += [field, ]
        if filtered_columns:
            filtered.update({line: filtered_columns})
    return filtered


def save_to_file(csv_dict, path, json_format, o_delimiter, o_quote_char) -> None:
    """
    Saves filtered content to the file
    :param json_format:
    :param csv_dict:
    :param path:
    :param o_delimiter:
    :param o_quote_char:
    :return:
    """
    if not json_format:
        with open(path, 'wt', encoding='UTF8', newline='') as csv_output:
            csv_writer = csv.writer(csv_output, delimiter=o_delimiter,
                                    quotechar=o_quote_char, quoting=csv.QUOTE_MINIMAL)
            for line in csv_dict.values():
                csv_writer.writerow(line)
    else:
        with open(path, 'w') as json_file:
            json_file.write(json.dumps(csv_dict, indent=4))


def print_to_console(csv_dict) -> None:
    """
    Prints filtering result to console
    :param json:
    :param csv_dict:
    :return:
    """
    #template = ''
    # width = {}
    # for line in csv_dict.values():
    #     c = 0
    #     for column in line:
    #         print column
    #         width.update({c: len(column)})
    #         c += 1

    # for line in csv_dict.values():
    #     template = ''
    #     for i in len(line):
    #         template += f'{line[{i}]:}   '
    #     print(f'{line[0]:}   {line[1]:}')
    pass


def print_pretty_table(csv_dict, cell_sep=' | ', header_separator=True):
    """
    Prints filtering result to console
    :param csv_dict:
    :param cell_sep:
    :param header_separator:
    :return:
    """
    # data = []
    # for line in csv_dict.values():
    #     data += [line]
    #
    # rows = len(data)
    # cols = len(data[0])
    #
    # col_width = []
    # for col in range(cols):
    #     columns = [data[row][col] for row in range(rows)]
    #     col_width.append(len(max(columns, key=len)))
    #
    # separator = "-+-".join('-' * n for n in col_width)
    #
    # for i, row in enumerate(range(rows)):
    #     if i == 1 and header_separator:
    #         print(separator)
    #
    #     result = []
    #     for col in range(cols):
    #         item = data[row][col].rjust(col_width[col])
    #         result.append(item)
    #
    #     print(cell_sep.join(result))

    data = []
    for line in csv_dict.values():
        data += [line]

    rows = len(data)
    cols = len(data[0])

    col_width = []
    for col in range(cols):
        max_line = int()
        for row in range(rows):
            lines = data[row][col].strip().split('\r\n')
            if len(max(lines, key=len)) > max_line:
                max_line = len(max(lines, key=len))
        col_width.append(max_line)
    print(col_width)

    separator = "-+-".join('-' * n for n in col_width)

    for i, row in enumerate(range(rows)):
        if i == 1 and header_separator:
            print(separator)

        result = []
        for col in range(cols):
            item = data[row][col].rjust(col_width[col])
            result.append(item)

        print(cell_sep.join(result))


def filter_csv(column, delimiter, quotechar, input_file, json_format, line,
               output, o_delimiter, o_quote_char, regex, header) -> None:
    """
    Script's main logic
    :param json_format:
    :param column:
    :param delimiter:
    :param quotechar:
    :param input_file:
    :param line:
    :param output:
    :param o_delimiter:
    :param o_quote_char:
    :param regex:
    :param header:
    :return:
    """
    filtered = get_dict(input_file, delimiter, quotechar, header)
    if line:
        lines_ranges = parse_range(line)
        filtered = filter_lines(filtered, lines_ranges, header)
    if column:
        columns_ranges = parse_range(column)
        filtered = filter_columns(filtered, columns_ranges)
    if regex:
        filtered = filter_by_regex(filtered, regex)
    if output:
        save_to_file(filtered, output, json_format, o_delimiter, o_quote_char)
    else:
        #print_to_console(filtered)
        print_pretty_table(filtered, header_separator=not header)
        #print(filtered)


def main():
    """
    :return:
    """
    args = parse_arguments()

    filter_csv(column=args['column'],
               delimiter=args['delimiter'] if args['delimiter'] else ',',
               quotechar=args['quotechar'] if args['quotechar'] else '"',
               input_file=args['input'], json_format=args['json'],
               line=args['line'], output=args['output'],
               o_delimiter=args['odelimiter'] if args['odelimiter'] else ',',
               o_quote_char=args['oquotechar'] if args['oquotechar'] else '"',
               regex=args['regex'], header=args['header'])


if __name__ == '__main__':
    main()
