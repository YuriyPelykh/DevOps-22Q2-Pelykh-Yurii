import argparse

class ScriptArgs:
    def __init__(self):

        self.args_parser = argparse.ArgumentParser(description='Apache log parser')

        self.args_parser.add_argument('-t', '--task',
                                      type=int,
                                      help='Task number')
        self.args_parser.add_argument('-f', '--file',
                                      type=str,
                                      help='Path to the logfile')
        self.args_parser.add_argument('-n', '--number',
                                      type=int,
                                      help='Number of entities in result, if such is required in task.'
                                           ' Default is 1.')
        self.args_parser.add_argument('-dt', '--time',
                                      type=int,
                                      help='Time interval in seconds for for statistics results.'
                                           ' Default is 30 seconds.')
        self.args_parser.add_argument('-w', '--worker',
                                      type=str,
                                      help='Worker to look for. E.g.: "10.2.1.160" or "10.2.1.160:8009".')
        self.args_parser.add_argument('-l', '--long',
                                      action='count',
                                      default=0,
                                      help='Show longest requests. Used in Task 5. This is default value.')
        self.args_parser.add_argument('-s', '--short',
                                      action='count',
                                      default=0,
                                      help='Show shortest requests. Used in Task 5.')
        self.args_parser.add_argument('-k', '--kslash',
                                      type=int,
                                      help='Count of slashes to leave. Used in Task 6. Default is 2.')
        self.args_parser.add_argument('-sn', '--sortbyname',
                                      action='count',
                                      default=0,
                                      help='Key of sorting results by name, used in Task 8. Default'
                                           ' - sorting by number of requests')


    def get_args(self):
        return vars(self.args_parser.parse_args())
