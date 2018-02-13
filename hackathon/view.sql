create view transformed_brfss as
SELECT CASE
  WHEN sleptim1 < 6 THEN 0
  WHEN sleptim1 >= 6 AND sleptim1 < 9 THEN 1
  WHEN sleptim1 >= 9 AND sleptim1 <= 24 THEN 2
  ELSE '-1'
  END as sleeptime,
CASE
  WHEN checkup1 = 1 THEN 1
  WHEN checkup1 = 2 THEN 2
  WHEN checkup1 = 3 OR checkup1 = 4 THEN 3
  ELSE '-1'
  END as checkup,
CASE
  WHEN medcost = 1 THEN 1
  WHEN medcost = 2 THEN 2
  ELSE '-1'
  END as medicalCost,
CASE
  WHEN drvisits <= 76 THEN drvisits
  WHEN drvisits = 88 THEN 0
  ELSE '-1'
  END as drvisits,
CASE
  WHEN income2 <= 8 THEN income2
  ELSE '-1'
  END as income,
CASE
  WHEN veteran3 <= 2 THEN veteran3
  ELSE '-1'
  END as veteran,
CASE
  WHEN caregive1 <= 2 THEN caregive1
  WHEN caregive1 = 8 THEN 3
  ELSE '-1'
  END as caregiver,
CASE
  when educa=1 then 0
  WHEN educa=2 or educa=3 THEN 1
  WHEN educa=4 THEN 2
  WHEN educa=5 or educa=6 THEN 3
  ELSE -1
  END educa,
CASE
  when employ1=1 or employ1=2 then 0
  WHEN employ1=3 or employ1=4 THEN 1
  WHEN employ1>=5 and employ1<=8 THEN employ1-3
  else -1
  END employ1,
CASE
  when weight2=9999 or weight2=7777 or weight2 is null then -1
  WHEN weight2>=9000 THEN weight2-9000
  WHEN weight2<1000 THEN weight2*0.453592
  else -1
  END weight2,
CASE
  when height3=9999 or height3=7777 or height3 is null then -1
  WHEN height3>=9000 THEN height3-9000
  WHEN height3<=712 THEN to_integer(height3/100) * 30.48 + mod(height3,100) * 2.54
  else -1
  END height3,
CASE
  when marital=1 then 0
  WHEN marital=2 or marital=4 THEN 1
  WHEN marital=3 THEN 2
  WHEN marital=5 or marital=6 THEN 3
  else -1
  END marital,
  CASE 
  WHEN NUMADULT is NULL THEN -1
  WHEN NUMADULT >= 6 THEN 6
  ELSE NUMADULT END AS NUMADULT,
  CASE 
  WHEN NUMMEN is NULL THEN -1
  WHEN NUMMEN >= 6 THEN 6
  ELSE NUMMEN END AS NUMMEN,
  CASE 
  WHEN NUMWOMEN is NULL THEN -1
  WHEN NUMWOMEN >= 6 THEN 6
  ELSE NUMWOMEN END AS NUMWOMEN,
  CASE 
  WHEN CHILDREN = 88 THEN 0
  WHEN CHILDREN = 99 or CHILDREN is NULL THEN -1
  WHEN CHILDREN >= 6 THEN 6
  ELSE CHILDREN END AS CHILDREN,
CASE
  WHEN SEX = 9 THEN -1
  ELSE SEX END AS SEX,
CASE
  WHEN GENHLTH = 7 or GENHLTH = 9 or GENHLTH is NULL THEN -1
  ELSE GENHLTH END AS GENHLTH,
CASE
  WHEN EXERANY2 = 7 or EXERANY2 = 9 or EXERANY2 is NULL THEN -1
  ELSE EXERANY2 END AS EXERANY2,
CASE
  WHEN ADDEPEV2 = 7 or ADDEPEV2 = 9 or ADDEPEV2 is NULL THEN -1
  ELSE ADDEPEV2 END AS ADDEPEV2,
CASE
  WHEN PREGNANT = 7 or PREGNANT = 9 or PREGNANT is NULL THEN -1
  ELSE PREGNANT END AS PREGNANT,
CASE
  WHEN DECIDE = 7 or DECIDE = 9 or DECIDE is NULL THEN -1
  ELSE DECIDE END AS DECIDE,
CASE 
  WHEN PHYSHLTH = 88 THEN 0
  WHEN PHYSHLTH = 99 or PHYSHLTH is NULL THEN -1
  WHEN PHYSHLTH > 0 and PHYSHLTH < 10 THEN 0
  WHEN PHYSHLTH >= 10 and PHYSHLTH < 20 THEN 1
  WHEN PHYSHLTH >= 20 and PHYSHLTH < 30 THEN 2
  ELSE PHYSHLTH END as PHYSHLTH,
CASE 
  WHEN MSCODE = 4 or MSCODE is NULL THEN -1
  ELSE MSCODE END AS MSCODE,
CASE 
  WHEN MENTHLTH = 88 THEN 0
  WHEN MENTHLTH = 99 or MENTHLTH is NULL THEN -1
  WHEN MENTHLTH > 0 and MENTHLTH < 10 THEN 0
  WHEN MENTHLTH >= 10 and MENTHLTH < 20 THEN 1
  WHEN MENTHLTH >= 20 and MENTHLTH < 30 THEN 2
  ELSE MENTHLTH END as MENTHLTH, iyear as year, imonth as month, _state as state
  FROM BRFSS;