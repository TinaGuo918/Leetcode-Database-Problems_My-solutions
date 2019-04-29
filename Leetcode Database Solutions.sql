# 574. Winning Candidate

SELECT name as Name
FROM Candidate
WHERE id IN (
    SELECT candidateid
    FROM(
        SELECT candidateid,COUNT(candidateid) AS cnt
        FROM vote
        GROUP BY candidateid
        ORDER BY cnt desc
        LIMIT 1
    ) temp
) 
;

# 262. Trips and Users

SELECT request_at AS DAY, 
    ROUND(COUNT(CASE WHEN status LIKE 'cancelled_by%' THEN 1 END)/COUNT(status),2) AS 'Cancellation Rate'
FROM trips
WHERE client_id NOT IN (
            SELECT Users_id
            FROM users
            WHERE banned = 'YES'
        ) 
        AND
        (request_at BETWEEN '2013-10-01' AND '2013-10-03' )
GROUP BY request_at

# 610. Triangle Judgement

SELECT x, y, z,
       CASE WHEN x+y > z AND x+z > y AND y+z > x THEN 'Yes' 
       ELSE 'No' 
       END AS 'triangle'            
FROM triangle

# 608. Tree Node

SELECT id,
       CASE 
           WHEN p_id IS null THEN 'Root'
           WHEN id IN (SELECT id FROM tree WHERE id NOT IN (SELECT p_id FROM tree WHERE p_id IS NOT NULL) ) THEN 'Leaf'
           ELSE 'Inner'
           END AS Type
FROM tree
;
# id IN (SELECT id FROM tree WHERE id NOT IN (SELECT p_id FROM tree  WHERE p_id IS NOT NULL) )
# OR
# id NOT IN (SELECT id FROM tree WHERE id IN (SELECT p_id FROM tree) )

NOT IN returns 0 records when compared against an unknown value
Since NULL is an unknown, a NOT IN query containing a NULL or NULLs in the list of possible values will always return 0 records since there is no way to be sure that the NULL value is not the value being tested.

# 627.Swap Salary(use a single update statement)

UPDATE  salary
SET sex = CASE
            WHEN sex = 'f' THEN 'm'
            ELSE 'f'
            END;

# 618. Studnets Report By Geography

** Solution 1 **
SELECT America, Asia, Europe
FROM(
    SELECT continentorder,
          MAX(CASE WHEN continent = 'America' THEN name END )AS America,
          MAX(CASE WHEN continent = 'Europe' THEN name END )AS Europe,
          MAX(CASE WHEN continent = 'Asia' THEN name END )AS Asia
    FROM (
        SELECT *,
               ROW_NUMBER()OVER(PARTITION BY continent ORDER BY name) AS continentorder
        FROM student
        ) AS SOURCE
    GROUP BY continentorder
    )temp

** Solution 2 **
SELECT America, Asia, Europe
FROM(
    SELECT *,
           ROW_NUMBER()OVER(PARTITION BY continent ORDER BY name) AS continentorder
    FROM student
        ) AS SOURCE
PIVOT 
     (MAX(name)FOR continent in (America, Asia, Europe)) AS PVT


# 612.Shortest Distance in a Plane

SELECT 
    MIN(ROUND(SQRT(POWER(p1.x - p2.x, 2)+ POWER(P1.y-p2.y, 2)), 2)) AS shortest

FROM point_2d p1, point_2d p2
WHERE p1.x != p2.x OR p1.y != p2.y


# 613. Shortest Distance in a Line

SELECT 
     MIN(ABS(p1.x - p2.x)) AS shortest
FROM point p1, point p2
WHERE p1.x != p2.x

# 176. Second Highest Salary
** Solution 1**
SELECT
    IFNULL(
      (SELECT DISTINCT Salary
       FROM Employee
       ORDER BY Salary DESC
        LIMIT 1, 1),
    NULL) AS SecondHighestSalary
    
** Solution 2 **   
SELECT max(Salary) as SecondHighestSalary
FROM Employee
WHERE Salary < (SELECT max(Salary) FROM Employee)

# 197. Rising Temperature

SELECT w1.id AS 'Id'
FROM weather w1
JOIN weather w2
ON DATEDIFF(w1.recorddate, w2.recorddate) = 1 AND w1.temperature > w2.temperature;

# 607. Sales Person

SELECT name 
FROM salesperson 
WHERE sales_id NOT IN (
    SELECT sales_id
    FROM orders o
    INNER JOIN company c
    ON c.com_id = o.com_id
    WHERE c.name = 'RED'
);

# 178. Rank Scores

** Solution 1**

SELECT Score, 
       DENSE_RANK() OVER(ORDER BY score DESC) AS Rank
FROM Scores
;

** Solution 2**

SELECT Score,
(SELECT COUNT(DISTINCT Score) FROM Scores WHERE Score >= s.Score) Rank
FROM Scores s
ORDER BY Score DESC
;

# 177. Nth Highest Salary

CREATE FUNCTION getNthHighestSalary(@N INT) RETURNS INT AS
BEGIN
    RETURN (       
		SELECT TOP 1 A.Salary
		FROM (SELECT ID, Salary, DENSE_RANK() OVER(ORDER BY Salary DESC) RN
			FROM Employee ) A 
		WHERE A.RN = @N	  
    );
END

# 569. Median Employee Salary
SELECT t1.id as Id, t1.company as Company, t1.salary as Salary, t1.Rank
FROM
(
SELECT *,
          ROW_NUMBER() OVER(PARTITION BY company ORDER BY salary) AS RANK
    FROM employee
    ) t1
JOIN
(
    SELECT company, COUNT(*) AS CNT
    FROM employee 
    GROUP BY company
) t2
ON t1.company = t2.company
WHERE t1.RANK IN(
    CASE WHEN t2.CNT%2= 0 THEN t2.CNT/2 ELSE (t2.CNT+1)/2 END,
    CASE WHEN t2.CNT%2 = 0 THEN t2.CNT/2 + 1 ELSE (t2.CNT+1)/2 END
);

# 570.Managers with at Least 5 Direct Reports
SELECT Name
FROM employee
WHERE id IN (
    SELECT managerid
    FROM employee
    GROUP BY managerid
    HAVING COUNT(managerid) > = 5
) AND (id IS NOT NULL)
;

# 601. Human Traffic of Stadium

SELECT DISTINCT s1.*
FROM stadium s1, 
     stadium s2,
     stadium s3
WHERE ((s2.id  - s1.id = 1 and s3.id - s2.id = 1 and s3.id - s1.id = 2)
OR
(s1.id - s2.id = 1 and s3.id - s1.id= 1 and s3.id - s2.id = 2)
OR
(s2.id - s3.id = 1 and s1.id - s2.id = 1 and s1.id - s3.id = 2))
AND s1.people >= 100 AND s2.people >= 100 AND s3.people >= 100
ORDER BY id
;

# 578. Get Highest Answer Rate Question
SELECT question_id AS survey_log
FROM
(
    SELECT question_id,
           SUM( CASE WHEN action = 'show' THEN 1 ELSE 0 END) AS num_show,
           SUM( CASE WHEN action = 'answer' THEN 1 ELSE 0 END) AS num_answer
    FROM survey_log
    GROUP BY question_id
) temp
ORDER BY (num_answer/num_show) DESC
LIMIT 1
;

# 602. Friend Requests II: Who Has the Most Friends
SELECT id, COUNT(id) AS num
FROM(
    SELECT accepter_id AS id FROM request_accepted
    UNION ALL
    SELECT requester_id AS id FROM request_accepted
    ) temp
GROUP BY id
ORDER BY COUNT(id) DESC
LIMIT 1;

# 597. Friend Requests I: Overall Acceptance Rate
SELECT ROUND(
    IFNULL(
    COUNT(DISTINCT requester_id, accepter_id)/ COUNT(DISTINCT sender_id, send_to_id), 
        0),2) AS accept_rate
FROM request_accepted, friend_request

# 584. Find Customer Referee
SELECT name
FROM customer
WHERE referee_id != 2 OR referee_id IS NULL


# 571. Find Median Given Frequency of Numbers
with temp as (
select sum(frequency) over(order by number) as cum_total,
(sum(frequency) over(order by number) - frequency) as cum_excluded,
sum(frequency) over () as total,
number, frequency
from Numbers)

select avg(cast(number as decimal(6,2))) as median
from temp
where (total / 2.0) between cum_excluded and cum_total

# 579. Find Cumulative Salary of an Employee
SELECT t.id, t.month, T.cum_salary AS Salary
FROM
(
    SELECT *,
           ROW_NUMBER () OVER(PARTITION BY id ORDER BY month DESC) AS rank,
           SUM(salary) OVER(PARTITION BY id ORDER BY month) AS cum_salary
    FROM employee
) t
WHERE t.rank != 1
ORDER BY id, month DESC

# 626. Exchange Seats
SELECT
    (CASE
        WHEN id%2 != 0 AND counts != id THEN id + 1
        WHEN id%2 != 0 AND counts = id THEN id
        ELSE id - 1
    END) AS id,
    student
FROM
    seat,
    (SELECT
        COUNT(*) AS counts
    FROM
        seat) AS seat_counts
ORDER BY id ASC;

#181. Employees Earning More Than Their Managers
SELECT e1.Name AS Employee
FROM employee e1
LEFT JOIN employee e2
ON e1.managerId = e2.Id
WHERE e1.Salary > e2.Salary;

# 577. Employee Bonus
SELECT e.name, b.bonus
FROM Employee e
LEFT JOIN Bonus b
ON e.empId = b.empId
WHERE (b.bonus < 1000) OR (b.bonus IS NULL)

# 182. Duplicate Emails
SELECT Email
FROM Person
GROUP BY Email
Having COUNT(1) > 1
;

# 185. Department Top Three Salaries
SELECT Department, Employee, Salary
FROM
(
    SELECT d.name AS Department, e.name AS Employee, e.salary AS Salary,
           DENSE_RANK() OVER (PARTITION BY d.name ORDER BY Salary DESC) rk
    FROM Department d
    JOIN Employee e
    ON d.id = e.departmentid
    ) t1
WHERE t1.rk <= 3
;

# 184. Department Highest Salary

SELECT Department, Employee, Salary
FROM
(
    SELECT d.name AS Department, e.name AS Employee, e.salary AS Salary,
           DENSE_RANK() OVER (PARTITION BY d.name ORDER BY Salary DESC) rk
    FROM Department d
    JOIN Employee e
    ON d.id = e.departmentid
    ) t1
WHERE t1.rk = 1
;

# 196. Delete Duplicate Emails
DELETE p1 
FROM Person p1,
     Person p2
WHERE
    p1.Email = p2.Email AND p1.Id > p2.Id

# 586. Customer Placing the Largest Number of Orders
SELECT customer_number
FROM orders
GROUP BY customer_number
ORDER BY COUNT(*) DESC
LIMIT 1
;

# 580. Count Student Number in Departments
SELECT d.dept_name, COUNT(s.student_name) AS student_number
FROM department d
LEFT JOIN student s
ON d.dept_id = s.dept_id
GROUP BY d.dept_id
ORDER BY 2 DESC, 1 ASC
;

# 180. Consecutive Numbers
/**SOLUTION 1: USE LAG AND LEAD**/
select distinct aa.Num as ConsecutiveNums from
(select Num,
lag(Num, 1) over (order by Id) as lag1,
lag(Num, 2) over (order by Id) as lag2
from Logs) aa
where aa.Num = aa.lag1 and aa.lag1 = aa.lag2

select distinct Num as ConsecutiveNums
from (
select Num,
    Num - LEAD(Num) over (order by Id) as lead_dif_1,
    Num - LEAD(Num, 2) over (order by Id) as lead_dif_2
from Logs
)
where lead_dif_2 = 0
and lead_dif_1 = 0

/**SOLUTION 2: MYSQL**/
SELECT DISTINCT l1.num AS  ConsecutiveNums
FROM logs l1,
     logs l2,
     logs l3
WHERE l1.num = l2.num
      AND l2.num = l3.num
      AND l2.id - l1.id = 1 
      AND l3.id -l2.id = 1
;

SELECT DISTINCT s1.num AS ConsecutiveNums
FROM logs s1, 
     logs s2,
     logs s3
WHERE ((s2.id  - s1.id = 1 and s3.id - s2.id = 1 and s3.id - s1.id = 2)
OR
(s1.id - s2.id = 1 and s3.id - s1.id and s3.id - s2.id = 2)
OR
(s2.id - s3.id = 1 and s1.id - s2.id = 1 and s1.id - s3.id = 2))
AND s1.num = s2.num AND s2.num = s3.num

# 603. Consecutive Available Seats
SELECT DISTINCT c1.seat_id
FROM cinema c1,
     cinema c2
WHERE ABS(c1.seat_id - c2.seat_id) = 1 AND c1.free = true AND c2.free = true
ORDER BY c1.seat_id
;

# 175. Combine Two Tables
SELECT FirstName, LastName, City, State
FROM Person p
LEFT JOIN Address a
ON p.personid = a.personid
GROUP BY p.personid
;

# 596. Classes More Than 5 Students
SELECT class
FROM courses
GROUP BY class
HAVING COUNT(DISTINCT student) >= 5
;

# 619. Biggest Single Number
SELECT IFNULL(
    (SELECT num
    FROM my_numbers
    GROUP BY num
    HAVING COUNT(num) = 1
    ORDER BY 1 DESC
    LIMIT 1), NULL
) AS num
;

SELECT MAX(t.num) AS num
FROM(
	SELECT num
	FROM my_numbers
	GROUP BY num
	HAVING COUNT(num) = 1
) t
;

# 615. Average Salary: Departments VS Company
SELECT t2.pay_month, 
       t2.department_id,
       CASE WHEN t2.dept_salary > t1.com_avg THEN 'higher'
            WHEN t2.dept_salary = t1.com_avg THEN 'same'
            ELSE 'lower' 
            END AS comparison
       
FROM(
    SELECT DATE_FORMAT(pay_date, '%Y-%m') AS pay_month, AVG(amount) AS com_avg
    FROM Salary
    GROUP BY 1
) t1
JOIN 
(
    SELECT DATE_FORMAT(s.pay_date, '%Y-%m') AS pay_month,e.department_id, AVG(s.amount) AS dept_salary
    FROM salary s
    JOIN employee e
    ON s.employee_id = e.employee_id
    GROUP BY 1,2
) t2
ON t1.pay_month = t2.pay_month
ORDER BY 2 
;


