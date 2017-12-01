SELECT firstICD9 as "First Disease", secondICD9 as "Second Disease", count(*) as "Appearences"
FROM
  (SELECT diagnosis.ICD9CODE as firstICD9, transcript.VISITYEAR
    FROM "Diagnosis" as diagnosis
    INNER JOIN "Transcript" as transcript
    ON diagnosis.PATIENTGUID = transcript.PATIENTGUID
    GROUP BY diagnosis.ICD9CODE, diagnosis.PATIENTGUID, transcript.VISITYEAR) as first
INNER JOIN
  (SELECT diagnosis.ICD9CODE as secondICD9, transcript.VISITYEAR
    FROM "Diagnosis" as diagnosis
    INNER JOIN "Transcript" as transcript
    ON diagnosis.PATIENTGUID = transcript.PATIENTGUID
    GROUP BY diagnosis.ICD9CODE, diagnosis.PATIENTGUID, transcript.VISITYEAR) as second
ON firstICD9 < secondICD9 AND first.VISITYEAR = second.VISITYEAR
GROUP BY firstICD9, secondICD9
ORDER BY "Appearences" DESC
LIMIT 10;