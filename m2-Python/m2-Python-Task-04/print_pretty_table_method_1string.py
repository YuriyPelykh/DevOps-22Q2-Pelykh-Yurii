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