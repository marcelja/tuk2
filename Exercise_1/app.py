import pyhdb
import yaml
from flask import Flask, send_from_directory, jsonify
app = Flask(__name__)


@app.route('/')
def root():
    return send_from_directory('static', 'map.html')


@app.route('/sql_statement')
def sql_result():
    cursor.execute('select state,count(*) from "Patient" group by state')
    result_json = {}
    for row in cursor.fetchall():
        result_json[row[0]] = row[1]
    return jsonify(result_json)


@app.route('/<path:path>')
def static_file(path):
    return send_from_directory('static', path)


if __name__ == "__main__":
    with open('../credentials.yml', 'r') as f:
        credentials = yaml.load(f)
    connection = pyhdb.connect(**credentials)
    cursor = connection.cursor()
    app.run(port=8000)
