CREATE TABLE age_groups (
   s int not null, -- start of range
   e int not null  -- end of range
);
INSERT INTO age_groups (s, e) VALUES (0, 9);
INSERT INTO age_groups (s, e) VALUES (10, 19);
INSERT INTO age_groups (s, e) VALUES (20, 29);
INSERT INTO age_groups (s, e) VALUES (30, 39);
INSERT INTO age_groups (s, e) VALUES (40, 49);
INSERT INTO age_groups (s, e) VALUES (50, 59);
INSERT INTO age_groups (s, e) VALUES (60, 69);
INSERT INTO age_groups (s, e) VALUES (70, 79);
INSERT INTO age_groups (s, e) VALUES (80, 89);
INSERT INTO age_groups (s, e) VALUES (90, 99);
INSERT INTO age_groups (s, e) VALUES (100, 200);

CREATE TABLE ten_most_common_diseases (
    icd9 varchar(10),
    total int
);

INSERT INTO ten_most_common_diseases (icd9, total)
SELECT
    "ICD9CODE" as icd9, count(*) as total
FROM "Diagnosis"
GROUP BY "ICD9CODE"
ORDER BY TOTAL DESC
LIMIT 10;