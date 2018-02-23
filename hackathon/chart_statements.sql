employment:
SELECT count(*), employ1, addepev2 from transformed_brfss where employ1 != -1 and addepev2 = 1 group by employ1 order by employ1;

marital:
SELECT count(*), addepev2 from transformed_brfss where marital = 1 and (employ1 = 1 or employ1 = 5) group by addepev2;

gender:
SELECT COUNT(*), SEX, ADDEPEV2 FROM TRANSFORMED_BRFSS WHERE (EMPLOY1 = 1 or EMPLOY1 = 5) and addepev2 != -1 and sex != -1 GROUP BY SEX, ADDEPEV2
