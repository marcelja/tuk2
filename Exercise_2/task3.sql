SELECT firstICD9 as "First Disease", secondICD9 as "Second Disease", count(*) as "Appearences"
FROM
  (SELECT (CASE
            WHEN LOCATE(UPPER(diagnosis.ICD9CODE), 'V') > 0 THEN 'V'
            WHEN LOCATE(UPPER(diagnosis.ICD9CODE), 'E') > 0 THEN 'E'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 0 AND 139 THEN '0-139'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 140 AND 239 THEN '140-239'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 240 AND 279 THEN '240-279'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 280 AND 289 THEN '280-289'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 290 AND 319 THEN '290-319'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 320 AND 389 THEN '320-389'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 390 AND 459 THEN '390-459'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 460 AND 519 THEN '460-519'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 520 AND 579 THEN '520-579'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 580 AND 629 THEN '580-629'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 630 AND 679 THEN '630-679'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 680 AND 709 THEN '680-709'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 710 AND 739 THEN '710-739'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 740 AND 759 THEN '740-759'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 760 AND 779 THEN '760-779'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 780 AND 799 THEN '780-799'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 800 AND 999 THEN '800-999'
            ELSE diagnosis.ICD9CODE
          END) as firstICD9, transcript.VISITYEAR
    FROM "Diagnosis" as diagnosis
    INNER JOIN "Transcript" as transcript
    ON diagnosis.PATIENTGUID = transcript.PATIENTGUID
    GROUP BY diagnosis.ICD9CODE, diagnosis.PATIENTGUID, transcript.VISITYEAR) as first
INNER JOIN
  (SELECT (CASE
            WHEN LOCATE(UPPER(diagnosis.ICD9CODE), 'V') > 0 THEN 'V'
            WHEN LOCATE(UPPER(diagnosis.ICD9CODE), 'E') > 0 THEN 'E'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 0 AND 139 THEN '0-139'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 140 AND 239 THEN '140-239'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 240 AND 279 THEN '240-279'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 280 AND 289 THEN '280-289'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 290 AND 319 THEN '290-319'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 320 AND 389 THEN '320-389'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 390 AND 459 THEN '390-459'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 460 AND 519 THEN '460-519'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 520 AND 579 THEN '520-579'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 580 AND 629 THEN '580-629'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 630 AND 679 THEN '630-679'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 680 AND 709 THEN '680-709'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 710 AND 739 THEN '710-739'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 740 AND 759 THEN '740-759'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 760 AND 779 THEN '760-779'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 780 AND 799 THEN '780-799'
            WHEN CAST(CAST(diagnosis.ICD9CODE as FLOAT) as INT) BETWEEN 800 AND 999 THEN '800-999'
            ELSE diagnosis.ICD9CODE
          END) as secondICD9, transcript.VISITYEAR
    FROM "Diagnosis" as diagnosis
    INNER JOIN "Transcript" as transcript
    ON diagnosis.PATIENTGUID = transcript.PATIENTGUID
    GROUP BY diagnosis.ICD9CODE, diagnosis.PATIENTGUID, transcript.VISITYEAR) as second
ON firstICD9 < secondICD9 AND first.VISITYEAR = second.VISITYEAR
GROUP BY firstICD9, secondICD9
ORDER BY "Appearences" DESC
LIMIT 10;