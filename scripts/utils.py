def updatefile(file_name, updates):
    """
        file name: the file to be updated
        updates: list of (line_number, updated_string)
    """
    lines = []
    with open(file_name, mode='r', encoding="utf-8") as f:
        lines = f.readlines()
        for item in updates:
            lines[item[0]] = item[1] + "\n"
    with open(file_name, mode='w', encoding="utf-8") as f:
        if len(lines) > 0:
            f.writelines(lines)