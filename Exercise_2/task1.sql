CREATE LOCAL TEMPORARY TABLE #age_groups (
   s int not null, -- start of range
   e int not null  -- end of range
);
INSERT INTO #age_groups (s, e) VALUES (0, 9);
INSERT INTO #age_groups (s, e) VALUES (10, 19);
INSERT INTO #age_groups (s, e) VALUES (20, 29);
INSERT INTO #age_groups (s, e) VALUES (30, 39);
INSERT INTO #age_groups (s, e) VALUES (40, 49);
INSERT INTO #age_groups (s, e) VALUES (50, 59);
INSERT INTO #age_groups (s, e) VALUES (60, 69);
INSERT INTO #age_groups (s, e) VALUES (70, 79);
INSERT INTO #age_groups (s, e) VALUES (80, 89);
INSERT INTO #age_groups (s, e) VALUES (90, 99);
INSERT INTO #age_groups (s, e) VALUES (100, 200);

--DROP TABLE #ten_most_common_diseases;
CREATE LOCAL TEMPORARY TABLE #ten_most_common_diseases (
    icd9 varchar(10),
    total int
);

INSERT INTO #ten_most_common_diseases (icd9, total)
SELECT
    "ICD9CODE" as icd9, count(*) as total
FROM "Diagnosis"
GROUP BY "ICD9CODE"
ORDER BY TOTAL DESC
LIMIT 10;

SELECT first.agegroup as AgeGroup, first.total as "1", second.total as "2", third.total as "3", fourth.total as "4", fivth.total as "5", sixth.total as "6", seventh.total as "7", eigth.total as "8", ninth.total as "9", tenth.total as "10"
FROM
  (select concat(concat(#age_groups.s, '-'), #age_groups.e) as AgeGroup, count(*) as total
  from #age_groups
  inner join (
    select
      diagnosis."ICD9CODE",
      patient.age
    from  "Diagnosis" as diagnosis
    inner join (SELECT (year(CURRENT_DATE) - CAST("YEAROFBIRTH" as INTEGER)) as age, "PATIENTGUID" FROM "Patient") patient
    on diagnosis."PATIENTGUID" = patient."PATIENTGUID"
    where diagnosis."ICD9CODE" IN (SELECT "ICD9" FROM (SELECT "ICD9", "TOTAL" FROM #ten_most_common_diseases LIMIT 1) ORDER BY "TOTAL" ASC)
  ) as x on x.age between #age_groups.s and #age_groups.e
  group by #age_groups.s, #age_groups.e) as first
FULL OUTER JOIN
  (select concat(concat(#age_groups.s, '-'), #age_groups.e) as AgeGroup, count(*) as total
  from #age_groups
  inner join (
    select
      diagnosis."ICD9CODE",
      patient.age
    from  "Diagnosis" as diagnosis
    inner join (SELECT (year(CURRENT_DATE) - CAST("YEAROFBIRTH" as INTEGER)) as age, "PATIENTGUID" FROM "Patient") patient
    on diagnosis."PATIENTGUID" = patient."PATIENTGUID"
    where diagnosis."ICD9CODE" IN (SELECT "ICD9" FROM (SELECT "ICD9", "TOTAL" FROM #ten_most_common_diseases LIMIT 2) ORDER BY "TOTAL" ASC LIMIT 1)
  ) as x on x.age between #age_groups.s and #age_groups.e
  group by #age_groups.s, #age_groups.e) as second
ON first.agegroup=second.agegroup
FULL OUTER JOIN
  (select concat(concat(#age_groups.s, '-'), #age_groups.e) as AgeGroup, count(*) as total
  from #age_groups
  inner join (
    select
      diagnosis."ICD9CODE",
      patient.age
    from  "Diagnosis" as diagnosis
    inner join (SELECT (year(CURRENT_DATE) - CAST("YEAROFBIRTH" as INTEGER)) as age, "PATIENTGUID" FROM "Patient") patient
    on diagnosis."PATIENTGUID" = patient."PATIENTGUID"
    where diagnosis."ICD9CODE" IN (SELECT "ICD9" FROM (SELECT "ICD9", "TOTAL" FROM #ten_most_common_diseases LIMIT 3) ORDER BY "TOTAL" ASC LIMIT 1)
  ) as x on x.age between #age_groups.s and #age_groups.e
  group by #age_groups.s, #age_groups.e) as third
ON first.agegroup=third.agegroup
FULL OUTER JOIN
  (select concat(concat(#age_groups.s, '-'), #age_groups.e) as AgeGroup, count(*) as total
  from #age_groups
  inner join (
    select
      diagnosis."ICD9CODE",
      patient.age
    from  "Diagnosis" as diagnosis
    inner join (SELECT (year(CURRENT_DATE) - CAST("YEAROFBIRTH" as INTEGER)) as age, "PATIENTGUID" FROM "Patient") patient
    on diagnosis."PATIENTGUID" = patient."PATIENTGUID"
    where diagnosis."ICD9CODE" IN (SELECT "ICD9" FROM (SELECT "ICD9", "TOTAL" FROM #ten_most_common_diseases LIMIT 4) ORDER BY "TOTAL" ASC LIMIT 1)
  ) as x on x.age between #age_groups.s and #age_groups.e
  group by #age_groups.s, #age_groups.e) as fourth
ON first.agegroup=fourth.agegroup
FULL OUTER JOIN
  (select concat(concat(#age_groups.s, '-'), #age_groups.e) as AgeGroup, count(*) as total
  from #age_groups
  inner join (
    select
      diagnosis."ICD9CODE",
      patient.age
    from  "Diagnosis" as diagnosis
    inner join (SELECT (year(CURRENT_DATE) - CAST("YEAROFBIRTH" as INTEGER)) as age, "PATIENTGUID" FROM "Patient") patient
    on diagnosis."PATIENTGUID" = patient."PATIENTGUID"
    where diagnosis."ICD9CODE" IN (SELECT "ICD9" FROM (SELECT "ICD9", "TOTAL" FROM #ten_most_common_diseases LIMIT 5) ORDER BY "TOTAL" ASC LIMIT 1)
  ) as x on x.age between #age_groups.s and #age_groups.e
  group by #age_groups.s, #age_groups.e) as fivth
ON first.agegroup=fivth.agegroup
FULL OUTER JOIN
  (select concat(concat(#age_groups.s, '-'), #age_groups.e) as AgeGroup, count(*) as total
  from #age_groups
  inner join (
    select
      diagnosis."ICD9CODE",
      patient.age
    from  "Diagnosis" as diagnosis
    inner join (SELECT (year(CURRENT_DATE) - CAST("YEAROFBIRTH" as INTEGER)) as age, "PATIENTGUID" FROM "Patient") patient
    on diagnosis."PATIENTGUID" = patient."PATIENTGUID"
    where diagnosis."ICD9CODE" IN (SELECT "ICD9" FROM (SELECT "ICD9", "TOTAL" FROM #ten_most_common_diseases LIMIT 6) ORDER BY "TOTAL" ASC LIMIT 1)
  ) as x on x.age between #age_groups.s and #age_groups.e
  group by #age_groups.s, #age_groups.e) as sixth
ON first.agegroup=sixth.agegroup
FULL OUTER JOIN
  (select concat(concat(#age_groups.s, '-'), #age_groups.e) as AgeGroup, count(*) as total
  from #age_groups
  inner join (
    select
      diagnosis."ICD9CODE",
      patient.age
    from  "Diagnosis" as diagnosis
    inner join (SELECT (year(CURRENT_DATE) - CAST("YEAROFBIRTH" as INTEGER)) as age, "PATIENTGUID" FROM "Patient") patient
    on diagnosis."PATIENTGUID" = patient."PATIENTGUID"
    where diagnosis."ICD9CODE" IN (SELECT "ICD9" FROM (SELECT "ICD9", "TOTAL" FROM #ten_most_common_diseases LIMIT 7) ORDER BY "TOTAL" ASC LIMIT 1)
  ) as x on x.age between #age_groups.s and #age_groups.e
  group by #age_groups.s, #age_groups.e) as seventh
ON first.agegroup=seventh.agegroup
FULL OUTER JOIN
  (select concat(concat(#age_groups.s, '-'), #age_groups.e) as AgeGroup, count(*) as total
  from #age_groups
  inner join (
    select
      diagnosis."ICD9CODE",
      patient.age
    from  "Diagnosis" as diagnosis
    inner join (SELECT (year(CURRENT_DATE) - CAST("YEAROFBIRTH" as INTEGER)) as age, "PATIENTGUID" FROM "Patient") patient
    on diagnosis."PATIENTGUID" = patient."PATIENTGUID"
    where diagnosis."ICD9CODE" IN (SELECT "ICD9" FROM (SELECT "ICD9", "TOTAL" FROM #ten_most_common_diseases LIMIT 8) ORDER BY "TOTAL" ASC LIMIT 1)
  ) as x on x.age between #age_groups.s and #age_groups.e
  group by #age_groups.s, #age_groups.e) as eigth
ON first.agegroup=eigth.agegroup
FULL OUTER JOIN
  (select concat(concat(#age_groups.s, '-'), #age_groups.e) as AgeGroup, count(*) as total
  from #age_groups
  inner join (
    select
      diagnosis."ICD9CODE",
      patient.age
    from  "Diagnosis" as diagnosis
    inner join (SELECT (year(CURRENT_DATE) - CAST("YEAROFBIRTH" as INTEGER)) as age, "PATIENTGUID" FROM "Patient") patient
    on diagnosis."PATIENTGUID" = patient."PATIENTGUID"
    where diagnosis."ICD9CODE" IN (SELECT "ICD9" FROM (SELECT "ICD9", "TOTAL" FROM #ten_most_common_diseases LIMIT 9) ORDER BY "TOTAL" ASC LIMIT 1)
  ) as x on x.age between #age_groups.s and #age_groups.e
  group by #age_groups.s, #age_groups.e) as ninth
ON first.agegroup=ninth.agegroup
FULL OUTER JOIN
  (select concat(concat(#age_groups.s, '-'), #age_groups.e) as AgeGroup, count(*) as total
  from #age_groups
  inner join (
    select
      diagnosis."ICD9CODE",
      patient.age
    from  "Diagnosis" as diagnosis
    inner join (SELECT (year(CURRENT_DATE) - CAST("YEAROFBIRTH" as INTEGER)) as age, "PATIENTGUID" FROM "Patient") patient
    on diagnosis."PATIENTGUID" = patient."PATIENTGUID"
    where diagnosis."ICD9CODE" IN (SELECT "ICD9" FROM (SELECT "ICD9", "TOTAL" FROM #ten_most_common_diseases LIMIT 10) ORDER BY "TOTAL" ASC LIMIT 1)
  ) as x on x.age between #age_groups.s and #age_groups.e
  group by #age_groups.s, #age_groups.e) as tenth
ON first.agegroup=tenth.agegroup
ORDER BY AgeGroup;