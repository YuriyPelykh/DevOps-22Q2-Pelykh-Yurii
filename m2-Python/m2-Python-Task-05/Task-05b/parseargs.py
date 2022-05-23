import argparse

class ScriptArgs:
    def __init__(self):

        self.args_parser = argparse.ArgumentParser(description='Password generator')

        self.args_parser.add_argument('-c', '--count',
                             type=int,
                             help='Count of generated passwords (default is 1)')
        self.args_parser.add_argument('-f', '--fromfile',
                             type=str,
                             help='Getting list of patterns from file and generate'
                                  ' for each random password')
        self.args_parser.add_argument('-l', '--length',
                             type=int,
                             help='Set length of password(s) and generate random'
                                  ' password(s) from set {small lateral ASCII,'
                                  ' big lateral ASCII, digit}. Default length - 8.')
        self.args_parser.add_argument('-t', '--template',
                             type=str,
                             help='Set template for generated password(s).'
                                  ' Token types: a - small literal ASCII, A - big'
                                  ' literal ASCII, d - digit, p - punctuations,'
                                  ' \'-\' - (same symbol), \'@\' - (same symbol),'
                                  ' [ ] - set type of token.')
        self.args_parser.add_argument('--verbose', '-v',
                             action='count',
                             default=0,
                             help='Verbose mode (-v | -vv | -vvv )')


    def get_args(self):
        return vars(self.args_parser.parse_args())
