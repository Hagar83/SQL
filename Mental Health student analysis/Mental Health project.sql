-- Exploring data
SELECT COUNT(*)
FROM students;
--Exploring data by student type
SELECT inter_dom, COUNT(*) AS records_per_student_type
FROM students
GROUP BY inter_dom;
--Showing the difference between two types of students
SELECT *
FROM students 
WHERE inter_dom = 'Inter';

SELECT *
FROM students 
WHERE inter_dom= 'dom';


--summarizing statistics for tests' scores
SELECT
  ROUND(AVG(todep), 2) AS average_todep_score,
  ROUND(MIN(todep), 2) AS min_todep_score,
  ROUND(MAX(todep), 2) AS max_todep_score,
  COUNT(*) AS total_students
FROM students;

SELECT
  ROUND(AVG(tosc), 2) AS average_tosc_score,
  ROUND(MIN(tosc), 2) AS min_tosc_score,
  ROUND(MAX(tosc), 2) AS max_tosc_score,
  COUNT(*) AS total_students
FROM students;

SELECT
  ROUND(AVG(toas), 2) AS average_toas_score,
  ROUND(MIN(toas), 2) AS min_toas_score,
  ROUND(MAX(toas), 2) AS max_toas_score,
  COUNT(*) AS total_students
FROM students;

--summarizing statistics for tests' scores only for the international students

SELECT
  ROUND(AVG(todep), 2) AS average_todep_inter_score,
  ROUND(MIN(todep), 2) AS min_todep_inter_score,
  ROUND(MAX(todep), 2) AS max_todep_inter_score,
  COUNT(*) AS total_students
FROM students
WHERE inter_dom='Inter';


SELECT
  ROUND(AVG(tosc), 2) AS average_tosc_inter_score,
  ROUND(MIN(tosc), 2) AS min_tosc_inter_score,
  ROUND(MAX(tosc), 2) AS max_tosc_inter_score,
  COUNT(*) AS total_students
FROM students
WHERE inter_dom='Inter';

SELECT
  ROUND(AVG(toas), 2) AS average_toas_inter_score,
  ROUND(MIN(toas), 2) AS min_toas_inter_score,
  ROUND(MAX(toas), 2) AS max_toas_inter_score,
  COUNT(*) AS total_students
FROM students
WHERE inter_dom='Inter';


--How length of stay affects the tests' scores
SELECT
  stay,
  ROUND(AVG(todep), 2) AS average_phq,
  ROUND(AVG(tosc), 2) AS average_scs,
  ROUND(AVG(toas), 2) AS average_as
FROM students
WHERE inter_dom = 'Inter' 
GROUP BY stay
ORDER BY stay DESC;

