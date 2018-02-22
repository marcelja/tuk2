import pyhdb
import yaml
from flask import Flask, send_from_directory, jsonify
app = Flask(__name__)


def execute_stmt(stmt):
    cursor.execute(stmt)
    result_json = {}
    for row in cursor.fetchall():
        if row[0] not in result_json:
            result_json[row[0]] = []
        result_json[row[0]].append(float(row[1]))
    return jsonify(result_json)


@app.route('/')
def root():
    return send_from_directory('static', 'map.html')


@app.route('/sql_statement/<key>')
def sql_statement(key):
    if key == "depression days":
        return execute_stmt('select t1.state, t1.c/t2.c, t1.year from (select count(*) as c,year,state from transformed_brfss where (menthlth=1 or menthlth=2) and year!=2017 group by year,state) t1,(select count(*) as c,year,state from transformed_brfss where (menthlth=1 or menthlth=2 or menthlth=0) and year!=2017 group by year,state) t2 where t1.year=t2.year and t1.state=t2.state order by t1.state, t1.year')
    elif key == "depression diagnosis":
        return execute_stmt('select t1.state, t1.c/t2.c, t1.year from (select count(*) as c,year,state from transformed_brfss where ADDEPEV2=1 and year!=2017 group by year,state) t1, (select count(*) as c,year,state from transformed_brfss where (ADDEPEV2=2 or addepev2=1) and year!=2017 group by year,state) t2 where t1.year=t2.year and t1.state=t2.state order by t1.state, t1.year')
    # elif key == "unemployment":
    #     return execute_stmt('select * from unemploymentrates order by state,year')
    elif key == "unable or unemployed":
        return execute_stmt('select t1.state, t1.c/t2.c, t1.year from (select count(*) as c,year,state from transformed_brfss where (employ1=1 or employ1=5) and year!=2017 group by year,state) t1, (select count(*) as c,year,state from transformed_brfss where (employ1!=-1) and year!=2017 group by year,state) t2 where t1.year=t2.year and t1.state=t2.state order by t1.state, t1.year')


@app.route('/<path:path>')
def static_file(path):
    return send_from_directory('static', path)


if __name__ == "__main__":
    with open('../credentials.yml', 'r') as f:
        credentials = yaml.load(f)
    connection = pyhdb.connect(**credentials)
    cursor = connection.cursor()
    app.run(host='0.0.0.0', port=80)
