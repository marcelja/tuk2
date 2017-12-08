import pyhdb
import yaml
from flask import Flask, send_from_directory, jsonify
app = Flask(__name__)


statements = {
    'patients': 'select state,count(*) number from "Patient" p where 1=1 {} group by state',
    'doctor_visits': 'select state,count(*) number from "Patient" p, "Transcript" t where t.patientguid=p.patientguid {} group by state',
    'rel_patients': 'select result.state,number/population * 100 from ( select state,count(*) number from "Patient" p where 1=1 {} group by state) result, statepopulation sp where result.state=sp.state',
    'rel_doctor_visits': 'select result.state,number/population * 100 from (select state,count(*) number from "Patient" p, "Transcript" t where t.patientguid=p.patientguid {} group by state) result, statepopulation sp where result.state=sp.state',
    'average_bmi': 'select state,avg(bmi) number from "Patient" p, "Transcript" t where t.patientguid=p.patientguid and bmi > 15 and bmi < 40 {} group by state'
}


def execute_stmt(stmt):
    print('Execute: ' + stmt)
    cursor.execute(stmt)
    result_json = {}
    for row in cursor.fetchall():
        result_json[row[0]] = float(row[1])
    return jsonify(result_json)


@app.route('/')
def root():
    return send_from_directory('static', 'map.html')


# http://localhost:8000/sql_statement/doctor_visits/gender=f,yearofbirth=1994
@app.route('/sql_statement/<key>/<filters>')
def sql_statement_filter(key, filters):
    print('statement for ' + key + ' ' + filters)
    filters = filters.upper()
    filter_stmt = ''
    for f in filters.split(','):
        filter_stmt += 'and ' + f.split('=')[0] + '=\'' + f.split('=')[1] + '\' '
    if key in statements:
        return execute_stmt(statements[key].format(filter_stmt))
    else:
        return 'Wrong url.'


@app.route('/sql_statement/<key>')
def sql_statement(key):
    print('Statement for: ' + key)
    if key in statements:
        return execute_stmt(statements[key].format(''))
    else:
        return 'Wrong url.'


@app.route('/<path:path>')
def static_file(path):
    return send_from_directory('static', path)


if __name__ == "__main__":
    with open('../credentials.yml', 'r') as f:
        credentials = yaml.load(f)
    connection = pyhdb.connect(**credentials)
    cursor = connection.cursor()
    app.run(port=8000)
