#!/usr/bin/env python3

"""Task-03"""

import argparse
import random
import string
import re
import logging

log = logging.getLogger("Password generator")


def parse_arguments() -> dict:
    """
    Define script arguments
    :return: a dictionary with all entered parameters for a password generator
    """
    args_parser = argparse.ArgumentParser(description='Password generator')

    args_parser.add_argument('-c', '--count',
                             type=int,
                             help='Count of generated passwords (default is 1)')
    args_parser.add_argument('-f', '--fromfile',
                             type=str,
                             help='Getting list of patterns from file and generate'
                                  ' for each random password')
    args_parser.add_argument('-l', '--length',
                             type=int,
                             help='Set length of password(s) and generate random'
                                  ' password(s) from set {small lateral ASCII,'
                                  ' big lateral ASCII, digit}. Default length - 8.')
    args_parser.add_argument('-t', '--template',
                             type=str,
                             help='Set template for generated password(s).'
                                  ' Token types: a - small literal ASCII, A - big'
                                  ' literal ASCII, d - digit, p - punctuations,'
                                  ' \'-\' - (same symbol), \'@\' - (same symbol),'
                                  ' [ ] - set type of token.')
    args_parser.add_argument('--verbose', '-v',
                             action='count',
                             default=0,
                             help='Verbose mode (-v | -vv | -vvv )')
    return vars(args_parser.parse_args())


def get_logging_level(level) -> int:
    """
    :param level:
    :return: loggin.LEVEL object
    """
    levels = {0: logging.CRITICAL,
              1: logging.CRITICAL,
              2: logging.WARNING,
              3: logging.DEBUG}
    return levels[level]


def randomize(token, count=1) -> str:
    """
    Make a specified count of randomly generated
    symbols of specified (with token) type (upper- or lowercase letters,
    digits, punctuations, "-" and "@").
    :param token:
    :param count:
    :return: str - random sequence
    """
    tokens = {'a': string.ascii_lowercase,
              'A': string.ascii_uppercase,
              'd': string.digits,
              'p': string.punctuation,
              '-': '-',
              '@': '@'}
    charset = ''
    for t in token:
        charset += tokens.get(t)
    return ''.join(random.choice(charset) for x in range(count))


def generate_from_template(template) -> str:
    """
    Password generate from a specified password pattern.
    :param template:
    :return: password
    """
    while True:
        found = re.search(r'\[.*?\]\d+', template)
        if not found:
            break
        template = template.replace(found.group(), re.sub('[%\[\]]', '', found.group()))
    passwd = ''
    for token in template.strip('%').split('%'):
        if token == '-' or token == '@':
            passwd += token
        else:
            token_set = re.search(r'\D+', token)
            number = re.search(r'\d+', token)
            try:
                passwd += randomize(token_set.group(), int(number.group()))
            except AttributeError:
                log.error('Incorrect template format. Each token should'
                          ' have literal pointer and count of repeats.')
                exit(-1)
    return passwd


def get_templates_from_file(path) -> list:
    """
    Gets all password patterns specified in a file.
    :param path:
    :return: list of templatest
    """
    file = open(path, 'rt')
    templates_list = []
    while True:
        line = file.readline()
        if not line:
            break
        for each in line.strip().split():
            templates_list.append(each)
    file.close()
    return templates_list


def make_password(fromfile, template, count, length) -> None:
    """
    Generate specified 'count' of passwords for some 'template',
    for list of templates, specified in some file
    (fromfile), or random sequence of specified 'length'.
    :param fromfile:
    :param template:
    :param count:
    :param length:
    :return: generated passwords to standard output stream
    """
    for n in range(0, count):
        if fromfile:
            log.info('Making password from templates file')
            for each in get_templates_from_file(fromfile):
                print(generate_from_template(each))
        elif template:
            log.info('Making password from specified template')
            print(generate_from_template(template))
        else:
            log.info('Making password of specified length')
            print(randomize('aAd', length))


def main() -> None:
    """
    :return: generated passwords to standard output stream
    """
    args = parse_arguments()

    log_level = get_logging_level(args['verbose'])
    log.setLevel(log_level)

    console_handler = logging.StreamHandler()
    console_handler.setLevel(log_level)

    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    console_handler.setFormatter(formatter)

    log.addHandler(console_handler)

    make_password(fromfile=args['fromfile'], template=args['template'],
                  count=args['count'] if args['count'] else 1,
                  length=args['length'] if args['length'] else 8)


if __name__ == '__main__':
    main()
