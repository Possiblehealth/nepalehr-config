SELECT 
    SUM(plaster.Female) AS Female_Count_Plaster,
    SUM(plaster.Male) AS Male_Count_Plaster
FROM
    (SELECT 
        SUM(IF(first_concept.gender = 'F', 1, 0)) AS Female,
            SUM(IF(first_concept.gender = 'M', 1, 0)) AS Male,
            first_answers.answer_name AS first_concept_name,
            COUNT(DISTINCT (first_concept.person_id)) AS count
    FROM
        (SELECT 
        ca.answer_concept AS answer,
            IFNULL(answer_concept_short_name.name, answer_concept_fully_specified_name.name) AS answer_name
    FROM
        concept c
    INNER JOIN concept_datatype cd ON c.datatype_id = cd.concept_datatype_id
    INNER JOIN concept_name question_concept_name ON c.concept_id = question_concept_name.concept_id
        AND question_concept_name.concept_name_type = 'FULLY_SPECIFIED'
        AND question_concept_name.voided IS FALSE
    INNER JOIN concept_answer ca ON c.concept_id = ca.concept_id
    INNER JOIN concept_name answer_concept_fully_specified_name ON ca.answer_concept = answer_concept_fully_specified_name.concept_id
        AND answer_concept_fully_specified_name.concept_name_type = 'FULLY_SPECIFIED'
        AND answer_concept_fully_specified_name.name IN ('Cast application' , 'High Groin Cast', 'Slab application', 'Thumb Spica Cast', 'Figure 8 Bandage')
        AND answer_concept_fully_specified_name.voided
        IS FALSE
    LEFT JOIN concept_name answer_concept_short_name ON ca.answer_concept = answer_concept_short_name.concept_id
        AND answer_concept_short_name.concept_name_type = 'SHORT'
        AND answer_concept_short_name.voided
        IS FALSE
    WHERE
        question_concept_name.name IN ('Procedure Notes, Ortho Procedure, Procedure')
            AND cd.name = 'Coded'
    ORDER BY answer_name DESC) first_answers
    LEFT OUTER JOIN (SELECT DISTINCT
        o1.person_id,
            p1.gender,
            cn2.concept_id AS answer,
            cn1.concept_id AS question
    FROM
        obs o1
    INNER JOIN concept_name cn1 ON o1.concept_id = cn1.concept_id
        AND cn1.concept_name_type = 'FULLY_SPECIFIED'
        AND cn1.name IN ('Procedure Notes, Ortho Procedure, Procedure')
        AND o1.voided = 0
        AND cn1.voided = 0
    INNER JOIN concept_name cn2 ON o1.value_coded = cn2.concept_id
        AND cn2.concept_name_type = 'FULLY_SPECIFIED'
		AND cn2.name IN ('Cast application' , 'High Groin Cast', 'Slab application', 'Thumb Spica Cast', 'Figure 8 Bandage')

        AND cn2.voided = 0
    INNER JOIN encounter e ON o1.encounter_id = e.encounter_id
    INNER JOIN person p1 ON o1.person_id = p1.person_id
    WHERE
        DATE(e.encounter_datetime) BETWEEN '2016-7-16' AND '2017-7-16'
            AND o1.value_coded IS NOT NULL) first_concept ON first_concept.answer = first_answers.answer
    GROUP BY first_answers.answer_name) plaster;
    