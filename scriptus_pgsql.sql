-- Write a query to find the shortest distance between these points rounded to 2 decimals.

-- | x  | y  |
-- |----|----|
-- | -1 | -1 |
-- | 0  | 0  |
-- | -1 | -2 |
 
-- The shortest distance is 1.00 from point (-1,-1) to (-1,2). So the output should be:
 

-- | shortest |
-- |----------|
-- | 1.00     |

-- Note: The longest distance among all the points are less than 10000.

with t as (
	select -1 x, -1 y union all
	select 0, 0 union all
	select -1, -2
), e as (
	select a.x x1, a.y y1, b.x x2, b.y y2 from t a cross join t b
)
select concat('p[', x1, ',',y1,'] -- > p[', x2, ',', y2, ']') route,
round(sqrt(power(x2 - x1, 2) + power(y2 - y1, 2))::numeric, 2) distance from e a where (x1 != x2 or y1 != y2)
and exists (select 1 from e where a.x1 = e.x2 and a.y1 = e.y2 and a.x2 = e.x1 and a.y2 = e.y1
and concat(a.x1, a.y1) < concat(e.x1, e.y1))
order by 1;

-- route                 |distance|
-- ----------------------|--------|
-- p[-1,-1] -- > p[-1,-2]|    1.00|
-- p[-1,-1] -- > p[0,0]  |    1.41|
-- p[-1,-2] -- > p[0,0]  |    2.24|



-- ********************************************************************************************* --
-- ********************************************************************************************* --

-- A "quite" student is the one who took at least one exam and didn't score neither the high score nor the low score.
-- Write an SQL query to report the students (student_id, student_name) being "quiet" in ALL exams.
-- Don't return the student who has never taken any exam. Return the result table ordered by student_id.
-- The query result format is in the following example.

-- Student table:
-- +-------------+---------------+
-- | student_id  | student_name  |
-- +-------------+---------------+
-- | 1           | Daniel        |
-- | 2           | Jade          |
-- | 3           | Stella        |
-- | 4           | Jonathan      |
-- | 5           | Will          |
-- +-------------+---------------+

-- Exam table:
-- +------------+--------------+-----------+
-- | exam_id    | student_id   | score     |
-- +------------+--------------+-----------+
-- | 10         |     1        |    70     |
-- | 10         |     2        |    80     |
-- | 10         |     3        |    90     |
-- | 20         |     1        |    80     |
-- | 30         |     1        |    70     |
-- | 30         |     3        |    80     |
-- | 30         |     4        |    90     |
-- | 40         |     1        |    60     |
-- | 40         |     2        |    70     |
-- | 40         |     4        |    80     |
-- +------------+--------------+-----------+

-- Result table:
-- +-------------+---------------+
-- | student_id  | student_name  |
-- +-------------+---------------+
-- | 2           | Jade          |
-- +-------------+---------------+

with students as (
	select 1 student_id, 'Daniel' student_name union all
	select 2, 'Jade' union all
	select 3, 'Stella' union all
	select 4, 'Jonathan' union all
	select 5, 'Will'
), exams as (
	select 10 exam_id, 1 student_id, 70 score union all
	select 10, 2, 80 union all
	select 10, 3, 90 union all
	select 20, 1, 80 union all
	select 30, 1, 70 union all
	select 30, 3, 80 union all
	select 30, 4, 90 union all
	select 40, 1, 60 union all
	select 40, 2, 70 union all
	select 40, 4, 80
)
select a.student_id, a.student_name from students a, (
select distinct student_id,
case when max(score) over (partition by student_id) < max(score) over ()
and min(score) over (partition by student_id) > min(score) over () then true else false end silent from exams) b
where a.student_id = b.student_id and b.silent order by 1;

-- student_id|student_name|
-- ----------|------------|
--          2|Jade        |
