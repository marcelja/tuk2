import glob
import json


ATTRIBUTE_EXCEPTIONS = {
    'diagnosis.startyear': 'smallint',
    'medication.medicationname': 'nvarchar(256)'
}
HANA_CSV_PATH = '/home/team04/practice_fusion'


class DataImporter():
    def __init__(self, csv_path, attributes_json):
        self.csv_path = csv_path
        with open(attributes_json) as json_data:
            self.attributes = json.load(json_data)

    def create_tables(self):
        for file in glob.glob(self.csv_path + '/*.csv'):
            self._create_table(file)
        print()
        for file in glob.glob(self.csv_path + '/*.csv'):
            self._import_stmt(file)

    def _run_sql(self, statement):
        print(statement)

    def _import_stmt(self, csv_file):
        table_name = csv_file.split('/')[-1].replace('.csv', '')
        print('import from csv file \'{}/{}.csv\' into "{}";'.format(HANA_CSV_PATH,
                                                                     table_name,
                                                                     table_name))

    def _create_table(self, csv_file):
        with open(csv_file, 'r') as f:
            header = f.readline()

        header = header.replace('"', '').replace('\n', '').split(',')
        table_name = csv_file.split('/')[-1].replace('.csv', '')

        create_statement = 'create column table "' + table_name + '" ('
        for attribute in header:
            create_statement += ',' + self._add_attribute(attribute,
                                                          table_name)
        create_statement = create_statement.replace(',', '', 1) + ');'
        self._run_sql(create_statement)

    def _add_attribute(self, attribute, table_name):
        table_attribute = table_name.lower() + '.' + attribute.lower()

        if table_name.lower() + 'guid' == attribute.lower():
            return attribute + ' nvarchar(36) primary key not null'
        elif attribute[-4:].lower() == 'guid':
            return attribute + ' nvarchar(36) not null'
        elif table_attribute in ATTRIBUTE_EXCEPTIONS:
            return attribute + ' ' + ATTRIBUTE_EXCEPTIONS[table_attribute]
        else:
            return attribute + ' ' + self.attributes[attribute.lower()]


def main():
    data_importer = DataImporter('csv_files/', 'attributes.json')
    data_importer.create_tables()


if __name__ == '__main__':
    main()
