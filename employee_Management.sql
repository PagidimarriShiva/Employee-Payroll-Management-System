create database employees;
use employees;
 
 select * from jobdepartment;
 select * from employee;
 select * from qualification;
 select * from payroll;
 select * from leaves;
 select * from salary_bonus;
 
 -- duplicates check 
 select empid ,count(*) as total_employees
from employee
group by empid
having  count(*) >1;

 set sql_safe_updates=0;
UPDATE jobdepartment
SET salaryrange = REPLACE(salaryrange, '$', '');
  select * from jobdepartment;
 
 --  How many unique employees are currently in the system?
 SELECT COUNT(empid) AS total_unique_employees
FROM employee;

-- Which departments have the highest number of employees?
  select j.jobdept, count(e.empid) as No_of_Employees
  from jobdepartment j
  inner join employee e
  on j.jobid =e.jobid
  group by j.jobdept
  order by no_of_employees desc;
  
  -- What is the average salary per department?
SELECT 
    j.jobdept,
    ROUND(AVG(p.totalamount), 2) AS avg_salary
FROM jobdepartment j
INNER JOIN employee e
    ON j.jobid = e.jobid
INNER JOIN payroll p
    ON e.empid = p.empid
GROUP BY j.jobdept
ORDER BY avg_salary DESC;

-- Who are the top 5 highest-paid employees?
SELECT 
    e.firstname,
    e.lastname,
    p.totalamount AS highest_paid
FROM employee e
INNER JOIN payroll p
    ON e.empid = p.empid
ORDER BY p.totalamount DESC;

-- What is the total salary expenditure across the company?
SELECT 
    SUM(annual) AS company_total_salary_expenditure
FROM salary_bonus;

-- 2. JOB ROLE AND DEPARTMENT ANALYSIS
-- How many different job roles exist in each department?
SELECT 
    jobdept,
    COUNT(DISTINCT jobid) AS different_job_roles
FROM jobdepartment
GROUP BY jobdept;

--  What is the average salary range per department?
SELECT 
    jobdept,
    ROUND(
        AVG((
                SUBSTRING_INDEX(salaryrange, '-', 1) +
                SUBSTRING_INDEX(salaryrange, '-', -1)
            ) / 2),2) AS avg_salary
FROM jobdepartment
GROUP BY jobdept;

-- Which job roles offer the highest salary?
select j.jobdept,max(s.annual) as highest_salary
from jobdepartment j
inner join salary_bonus s
on j.jobid =s.jobid
group by j.jobdept
order by highest_salary desc
limit 1;

-- Which departments have the highest total salary allocation?
SELECT 
    j.jobdept,
    SUM(s.annual) AS total_salary_allocation
FROM jobdepartment j
INNER JOIN salary_bonus s
    ON j.jobid = s.jobid
GROUP BY j.jobdept
ORDER BY total_salary_allocation DESC;

-- 3. QUALIFICATION AND SKILLS ANALYSIS
-- How many employees have at least one qualification listed?
SELECT 
    COUNT(DISTINCT e.empid) AS employees_with_qualifications
FROM employee e
INNER JOIN qualification q
    ON e.empid = q.empid;
 
 -- Which positions require the most qualifications?
 SELECT 
    j.jobdept,
    COUNT(q.qualid) AS total_qualifications
FROM jobdepartment j
INNER JOIN employee e
    ON j.jobid = e.jobid
INNER JOIN qualification q
    ON e.empid = q.empid
GROUP BY j.jobdept
ORDER BY total_qualifications DESC;

--  Which employees have the highest number of qualifications?
SELECT 
    e.firstname,
    e.lastname,
    COUNT(q.qualid) AS total_qualifications
FROM employee e
INNER JOIN qualification q
    ON e.empid = q.empid
GROUP BY e.empid, e.firstname, e.lastname
ORDER BY total_qualifications DESC;

-- 4. LEAVE AND ABSENCE PATTERNS
--  Which month  had the most employees taking leaves?
SELECT 
    MONTH(date) AS leave_month,
    COUNT(leaveid) AS total_leaves
FROM leaves
GROUP BY MONTH(date)
ORDER BY total_leaves DESC;

-- What is the average number of leave days taken by its employees per department?
SELECT 
    j.jobdept,
    ROUND(COUNT(l.leaveid) * 1.0 / COUNT(DISTINCT e.empid), 2) AS avg_leave_days
FROM jobdepartment j
INNER JOIN employee e
    ON j.jobid = e.jobid
INNER JOIN leaves l
    ON e.empid = l.empid
GROUP BY j.jobdept
ORDER BY avg_leave_days DESC;

--  Which employees have taken the most leaves?
SELECT 
    e.firstname,
    e.lastname,
    COUNT(l.leaveid) AS leave_days
FROM employee e
INNER JOIN leaves l
    ON e.empid = l.empid
GROUP BY e.empid, e.firstname, e.lastname
ORDER BY leave_days DESC;

-- What is the total number of leave days taken company-wide?
SELECT 
    COUNT(leaveid) AS total_company_leave_days
FROM leaves;

-- How do leave days correlate with payroll amounts?
 SELECT e.empid, e.firstname, e.lastname,
    COUNT(l.leaveid) AS total_leave_days,
    p.totalamount AS payroll_amount
FROM employee e
INNER JOIN leaves l
    ON e.empid = l.empid
INNER JOIN payroll p
    ON e.empid = p.empid
GROUP BY  e.empid, e.firstname,
    e.lastname, p.totalamount
ORDER BY total_leave_days DESC;


-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- What is the total monthly payroll processed?
SELECT 
    MONTH(date) AS payroll_month,
    SUM(totalamount) AS total_monthly_payroll
FROM payroll
GROUP BY MONTH(date)
ORDER BY payroll_month;

--  What is the average bonus given per department?
select j.jobdept,round(avg(s.bonus),2) as avg_bonus
from jobdepartment j
inner join salary_bonus s
on j.jobid = s.jobid
group by j.jobdept;

-- Which department receives the highest total bonuses?
SELECT 
    j.jobdept, ROUND(SUM(s.bonus), 2) AS total_bonus
FROM jobdepartment j
INNER JOIN salary_bonus s
    ON j.jobid = s.jobid
GROUP BY j.jobdept
ORDER BY total_bonus DESC;

-- What is the average value of total_amount after considering leave deductions?
SELECT 
    ROUND(AVG(totalamount), 2) AS avg_total_amount_after_deductions
FROM payroll;

 WITH DepartmentSalary AS ( 
    SELECT JobID,
           AVG(TotalAmount) AS AvgSalary
    FROM Payroll
    GROUP BY JobID
)
SELECT *
FROM DepartmentSalary
WHERE AvgSalary > 50000;

SELECT
    EmpID,
    FirstName,
    TotalAmount,
    RANK() OVER(ORDER BY TotalAmount DESC) AS SalaryRank
FROM Employee e
JOIN Payroll p
ON e.EmpID=p.EmpID;

SELECT FirstName,
       LastName
FROM Employee
WHERE JobID IN
(
    SELECT JobID
    FROM Salary_Bonus
    WHERE Annual >
    (
        SELECT AVG(Annual)
        FROM Salary_Bonus
    )
);

CREATE VIEW EmployeeSalary AS
SELECT
e.EmpID, e.FirstName, j.JobDept, p.TotalAmount
FROM Employee e
JOIN Payroll p
ON e.EmpID=p.EmpID
JOIN JobDepartment j
ON e.JobID=j.JobID;

DELIMITER //

CREATE PROCEDURE GetEmployeeSalary(IN id INT)
BEGIN
SELECT *
FROM Payroll
WHERE EmpID=id;
END //

DELIMITER ;


CREATE INDEX idx_employee_jobid
ON Employee(JobID);

CREATE INDEX idx_payroll_empid
ON Payroll(EmpID);