/*
Local CSV File Tester by Roland Estrada
Test CSV files for Auto Rostering according to IXL Standard
https://www.ixl.com/help_docs/IXL-Auto-Rostering-Specifications.pdf 
restrada@ixl.com
*/
----------------------------------------------
---------sqlite configuration-----------------
----------------------------------------------

.open test.db
.mode csv
.headers on

----------------------------------------------
--------Load Tables from CSV------------------
----------------------------------------------

.import ./Input/schools.csv test_schools
.import ./Input/teachers.csv test_teachers
.import ./Input/students.csv test_students
.import ./Input/sections.csv test_sections
.import ./Input/enrollments.csv test_enrollments


-----------------------------------------------
------------Schools.csv Tests-----------------
-----------------------------------------------

--Create table of invalid schools due to having duplicate "school id"
create temp table inv_schools_dupe_id
as	
	select *, cast ('Duplicate School ID' as TEXT) as Reason
	from test_schools
	where "school id" in (
		select "school id"
		from test_schools
		group by "school id"
		having count(*)>1
		)
;

--Create table of invalid schools due to not having a "school id"
create temp table inv_schools_null_id
as 
    select *, cast('Null in Required Field' as TEXT) as Reason
    from test_schools
    where "school id" = ''
;

--Make Invalid_Schools table from above checks
create temp table invalid_schools
as
	select * from temp.inv_schools_dupe_id
    union all
    select * from temp.inv_schools_null_id
;

--------------------------------------------------
-------------Teachers.csv Tests-------------------
--------------------------------------------------

--Create Database for invalid teachers because their school id is in invalid_schools table
create temp table inv_teachers_inv_school
as
    select *, cast('School ID is in Invalid Schools List' AS TEXT) as Reason
        from test_teachers
        where "school id" in (
            select "school id"
            from invalid_schools
			)
;

--Create table for teachers who have a school id not in the schools table
create temp table inv_teachers_no_school
as
	select *, cast('School ID not in Schools list' AS TEXT) as Reason
	from test_teachers
	where "school id" not in (
		select "school id"
		from test_schools
		)
;


--Create invalid teacher table because they have a duplicate ID to another teacher   
create temp table inv_teachers_dupe_id
as
    select *, cast('Duplicate Teacher ID' AS TEXT) as Reason
    from test_teachers
    where "teacher id" in (
        select "teacher id" 
        from test_teachers
        Group by "teacher id"
        having count(*)>1
      )
    order by "teacher id"
;

--Create table for invalid teachers because they have null in any required field
create temp table inv_teachers_null 
as
    select *, cast('Null in Required Field' AS TEXT) as Reason
        from test_teachers
        WHERE "school id" = '' 
            OR "teacher id" = '' 
            OR "first name" = '' 
            OR "last name" = '' 
            OR "e-mail" = '' 
            OR "username" = ''
;

--Create table for invalid teachers because they have a duplicate username
create temp table inv_teachers_dupe_username
as
    select *, cast('Duplicate username' AS TEXT) as Reason
    from test_teachers
    where "username" in (
        select "username"
        from test_teachers
        group by "username"
        having count(*)>1
        )
        order by "username"
;

--Creates the invalid_teachers table from the above checks
create temp table invalid_teachers
as
      select * from temp.inv_teachers_inv_school
      union all
	  select * from temp.inv_teachers_no_school
	  union all
      select * from temp.inv_teachers_dupe_id
      union all
      select * from temp.inv_teachers_null
      union all
      select * from temp.inv_teachers_dupe_username
;

---------------------------------------
--------Students.csv Tests-------------
---------------------------------------

--Create table for invalid students because their school id is in invalid_schools table
create temp table inv_students_inv_school
as
    select *, cast('School ID in Invalid Schools List' AS TEXT) as Reason
    from test_students
    where "school id" in (
        select "school id" 
        from temp.invalid_schools
        )
;

--create table for students that have a school id that does not exist
create temp table inv_students_no_school
as
	select *, cast('School ID not in Schools list' AS TEXT) as Reason
	from test_students
	where "school id" not in (
		select "school id"
		from test_schools
	)
;

--Create table for invalid students because they have duplicate student id's
create temp table inv_students_dupe_id
as
    select *, cast ('Duplicate Student ID' AS TEXT) as Reason
    from test_students
    where "student id" in (
        select "student id"
        from test_students
        group by "student id"
        having count(*)>1
        )
        order by "student id"
;

--Create table for invalid students because they have duplicate student numbers
create temp table inv_students_dupe_num
as
    select *, cast ('Duplicate Student Number' AS TEXT) as Reason
    from test_students
    where "student number" in (
        select "student number"
        from test_students
        group by "student number"
        having count(*)>1
        )
        order by "student number"
;

--Create table for invalid students because they have a null value in required field
create temp table inv_students_null 
as
    select *, cast('Null in Required Field' AS TEXT) as Reason
        from test_students
        WHERE "school id" = '' 
            OR "student id" = ''
            OR "student number" = ''
            OR "first name" = ''
            OR "last name" = ''
            OR "grade" = ''
;

--Create invalid_students table from the above checks
create temp table invalid_students
as
    select * from temp.inv_students_inv_school
    union all
	select * from temp.inv_students_no_school
	union all
    select * from temp.inv_students_dupe_id
    union all
    select * from temp.inv_students_dupe_num
    union all
    select * from temp.inv_students_null
;

----------------------------------------------
------------Sections.csv Tests----------------
----------------------------------------------

--Create database for sections with a "teacher id" in the invalid teachers table
create temp table inv_sections_inv_teacher
as
select *, cast('Teacher ID is in Invalid Teachers List' AS TEXT) as Reason
from test_sections
where "teacher id" in (
    select "teacher id"
    from invalid_teachers
    )
;

--create table for sections that have teacher id's that are not in the teachers list
create temp table inv_sections_no_teacher
as
	select *, cast('Teacher ID not in Teachers list' AS TEXT) as Reason
	from test_sections
	where "teacher id" not in (
		select "teacher id"
		from test_teachers
	)
;

--Create database for sections with a duplicate section id
create temp table inv_sections_dupe_id
as    
    select *, cast('Duplicate Section ID' AS TEXT) as Reason
    from test_sections
    where "section id" in (
        select "section id"
        from test_sections
        group by "section id"
        having count(*) > 1
        )
    order by "section id"
;

--Create invalid sections table from the above checks
create temp table invalid_sections
as
    select * from temp.inv_sections_inv_teacher
    UNION ALL
	select * from temp.inv_sections_no_teacher
	UNION ALL
    select * from temp.inv_sections_dupe_id
;

---------------------------------------
-------Enrollments.csv Tests-----------
---------------------------------------
    
--Create table for enrollments that have a "section id" that is invalid    
create temp table inv_enrollments_inv_section
as
    select *, cast('Section ID in Invalid Sections List' AS TEXT) as Reason
    from test_enrollments
    where "section id" in (
        select "section id"
        from invalid_sections
        )
;

--Create table for enrollments that have a "student id" that is invalid
create temp table inv_enrollments_inv_student
as
    select *, cast ('Student ID in Invalid Students List' AS TEXT) as Reason
    from test_enrollments
    where "student id" in (
        select "student id"
        from invalid_students
        )
;

--Create table for enrollments that have a student id that is not in the students list
create temp table inv_enrollments_no_student
as
select *, cast('Student ID not in Students list' AS TEXT) as Reason
	from test_enrollments
	where "student id" not in (
		select "student id"
		from test_students
	)
;

--Create table for enrollments that have a teacher id that is not in the teachers list
create temp table inv_enrollments_no_section
as
select *, cast('Section ID not in Sections list' AS TEXT) as Reason
	from test_enrollments
	where "section id" not in (
		select "section id"
		from test_sections
	)
;

--create a table for all Invalid Enrollments
create temp table invalid_enrollments
as
    select * from temp.inv_enrollments_inv_section
    union all
    select * from temp.inv_enrollments_inv_student
	union all
	select * from temp.inv_enrollments_no_student
	union all
	select * from temp.inv_enrollments_no_section
;

-------------------------------------------------
---------Saving results as CSV-------------------
-------------------------------------------------

.once ./Output/invalid_schools.csv
select * from invalid_schools;

.once ./Output/invalid_teachers.csv
select * from invalid_teachers;

.once ./Output/invalid_students.csv
select * from invalid_students;

.once ./Output/invalid_sections.csv
select * from invalid_sections;

.once ./Output/invalid_enrollments.csv
select * from invalid_enrollments;

------------------------------------------------
--------Clean Up tables-------------------------
------------------------------------------------

drop table test_schools;
drop table test_teachers;
drop table test_students;
drop table test_sections;
drop table test_enrollments;