import numpy as np
import pandas as pd
import sys

if __name__ == '__main__':
    file_path = sys.argv[1]
    df = pd.read_csv(file_path, error_bad_lines=False)
    columns = ['_STATE', 'IDAY', 'IMONTH', 'IYEAR', 'NUMADULT', 'NUMMEN',
               'NUMWOMEN', 'CADULT', 'GENHLTH', 'PHYSHLTH',
               'MENTHLTH', 'POORHLTH', 'MEDCOST', 'CHECKUP1', 'EXERANY2',
               'SLEPTIM1', 'ADDEPEV2', 'SEX', 'MARITAL',
               'EDUCA', 'VETERAN3', 'EMPLOY1', 'CHILDREN', 'INCOME2',
               'WEIGHT2', 'HEIGHT3', 'PREGNANT', 'DECIDE',
               'AVEDRNK2', 'INSULIN', 'MSCODE', 'DRVISITS', 'CAREGIVE1']
    output = '.'.join(file_path.split('.')[:-1]) + '_clean.csv'
    try:
        filtered = df[columns]
    except KeyError as e:
        error_cols = eval(','.join(str(e).split(']')[0][1:].split(' ')) + ']')
        print('Not found columns', error_cols)
        filtered_colums = [col for col in columns if col not in error_cols]
        filtered = df[filtered_colums]
        for err in error_cols:
            filtered[err] = np.nan
    filtered = filtered.reindex_axis(sorted(filtered.columns), axis=1)
    filtered.to_csv(output, index=False)
