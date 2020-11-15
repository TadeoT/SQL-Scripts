-- EJERCICIO 1---
SELECT authors.au_lname, authors.au_fname , titles.title Titulo FROM authors  
                                    INNER JOIN  titleauthor ON authors.au_id = titleauthor.au_id
									INNER JOIN titles ON  titleauthor.title_id = titles.title_id
									ORDER BY authors.au_fname;


---EJERCICIO 2----

SELECT publishers.pub_name , employee.fname+','+employee.lname Empleado, employee.job_lvl FROM  employee
                                    INNER JOIN publishers ON employee.pub_id = publishers.pub_id
                                    WHERE employee.job_lvl > 200;
													

---EJERCICIO 3-s

SELECT authors.au_lname+', '+authors.au_fname , SUM(sales.qty * titles.price) INGRESOS FROM authors  
                                    INNER JOIN  titleauthor ON authors.au_id = titleauthor.au_id
									INNER JOIN titles ON  titleauthor.title_id = titles.title_id
                                    INNER JOIN sales ON titles.title_id = sales.title_id
                                    INNER JOIN stores ON sales.stor_id = stores.stor_id
									GROUP BY authors.au_lname, authors.au_fname
									order by INGRESOS desc;

---EJERCICIO 4---

SELECT titles.title from titles  GROUP BY titles.title HAVING  AVG(titles.price)>12

---EJERCICIO 5---

SELECT e1.lname, e1.fname, e1.hire_date FROM employee e1 WHERE e1.hire_date  =  (SELECT MAX(hire_date) FROM employee e2);

---EJERCICIO 6 ----

SELECT publishers.pub_name from titles INNER JOIN publishers ON publishers.pub_id = titles.pub_id WHERE titles.type = 'business';

---EJERCICIO 7---

SELECT titles.title_id, titles.title  FROM titles WHERE title_id NOT IN (SELECT sales.title_id FROM sales  WHERE YEAR(sales.ord_date) IN (1993, 1994)); 

---EJERCICIO 8---
SELECT t1.title, publishers.pub_name, t1.price 
FROM titles t1
INNER JOIN publishers ON publishers.pub_id = t1.pub_id 
WHERE t1.price < (SELECT AVG(titles.price) FROM titles WHERE t1.pub_id = titles.pub_id GROUP BY titles.pub_id); 

---EJERCICIO 9---
 
SELECT authors.au_lname NOMBRE, authors.au_fname APELLIDO, CASE authors.contract
 WHEN 1 then 'Contratado'
 WHEN 0 then 'No Contratado'
 END CONTRATADO   FROM authors WHERE authors.state = 'CA';

---EJERCICIO 10---
SELECT employee.lname, 
CASE 
	WHEN job_lvl > 200 THEN 'PUNTAJE MAYOR A 200'
	WHEN job_lvl< 100 THEN 'PUNTAJE MENOR A 100'
	ELSE  'PUNTAJE ENTRE 100 Y 200'
END NIVEL
FROM employee;








