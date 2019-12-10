import json

def convert_to_sql_from_json(json_data):
    sql_statements = ""
    json_dict = json.loads(json_data)
    for insert in json_dict["insertions"]:
        columns = "("
        values = "("
        for column, value in insert.items():
            columns += "{}, ".format(column)
            if not value:
                values += "NULL, "
            else:
                values += "'{}', ".format(value)
        columns = columns[0:-3] + ")"
        values = values[0:-3] + ")"
        sql_statements += "INSERT INTO {} {} VALUES {};\n".format(json_dict["view"], columns, values)

    for delete in json_dict["deletions"]:
        where = ""
        for column, value in delete.items():
            if not value:
                continue
            where += "{}='{}' AND ".format(column)
        where = where[0:-5]
        sql_statements += "DELETE FROM {} WHERE {};\n".format(json_dict["view"], where)

    return sql_statements

