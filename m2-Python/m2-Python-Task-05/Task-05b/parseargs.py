import argparse

class ScriptArgs:
    def __init__(self):

        self.args_parser = argparse.ArgumentParser(description='Password generator')

        self.args_parser.add_argument('-t', '--task',
                             type=int,
                             help='Task number')
        self.args_parser.add_argument('-f', '--file',
                             type=str,
                             help='Path to the logfile be parsed')
        self.args_parser.add_argument('-c', '--count',
                             type=int,
                             help='Count of some entities, if such is required in task.'
                                  ' Default count - 1.')
        self.args_parser.add_argument('-dt', '--time',
                            type=int,
                            help='Time interval in seconds for for statistics results.'
                                 ' Default is 30 seconds.')


    def get_args(self):
        return vars(self.args_parser.parse_args())
