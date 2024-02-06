-- Active: 1706867141244@@localhost@3306@project

--extracting shots--
SELECT * FROM shotlist;

SELECT * FROM shotlist WHERE shot_size = "extreme close up"; 

--picking crew based on their payment
SELECT * FROM crew WHERE payment < 300; --the number could be any variable

--picking the crew who are getting payed less than average 
SELECT name FROM crew WHERE payment > (SELECT AVG(payment) FROM crew);

--picking the writers who get payed less than the average pay for writers 
SELECT name FROM crew WHERE _role = "Writer" AND payment < (select AVG(payment) FROM crew WHERE _role = "Writer");

--selecting the department with the highest average pay
SELECT DISTINCT _role FROM crew WHERE payment > (select AVG(payment) FROM crew)

--creating a budget calculation based on all the payments made by a shot in a shooting SCHEDULE
SELECT * FROM crew_budget;
