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
	select "school id", cast('School ID ' || "school id" || ' appears ' || count("school id") || ' times' as TEXT) as Reason
	from test_schools
	group by "school id"
	having count("school id") > 1
;
--select * from inv_schools_dupe_id
--drop table inv_schools_dupe_id


--Create table of invalid schools due to not having a "school id"
create temp table inv_schools_null_id
as 
	select "school id", cast ('School ID is null for ' || count("school id") || ' School(s)' as TEXT) as Reason
	from test_schools
	where "school id"=''
;

--Make Invalid_Schools table from above checks
create temp table invalid_schools
as
	select * from temp.inv_schools_dupe_id
    union all
    select * from temp.inv_schools_null_id
;
--select distinct "school id", group_concat(' ' || "reason") from invalid_schools group by "school id";

--------------------------------------------------
-------------Teachers.csv Tests-------------------
--------------------------------------------------

--Create Database for invalid teachers because their school id is in invalid_schools table
create temp table inv_teachers_inv_school
as
	Select "teacher id", cast('School ID ' || "school id" || ' for this teacher is in Invalid Schools list' as Text) as Reason
	from test_teachers
	where "school id" in (
		select "school id"
		from invalid_schools
	)
;

--Create table for teachers who have a school id not in the schools table
create temp table inv_teachers_no_school
as
	select "Teacher ID", cast('School ID ' || "School ID" || ' not in Schools list' AS TEXT) as Reason
	from test_teachers
	where "school id" not in (
		select "school id"
		from test_schools
		)
;


--Create invalid teacher table because they have a duplicate ID to another teacher   
create temp table inv_teachers_dupe_id
as
	select "teacher id", cast('Teacher ID ' || "teacher id" || ' appears ' || count("teacher id") || ' times' as TEXT) as Reason
	from test_teachers
	group by "teacher id"
	having count("teacher id")>1
	order by count("teacher id") desc
;

--Create table for invalid teachers because they have null in any required field
create temp table inv_teachers_null 
as
    select "teacher id", cast('Null in Required Field ' AS TEXT) as Reason
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
	select distinct test_teachers."teacher id", dupe_usernames."Reason"
	from test_teachers
	join (
        select "username", cast('Username ' || "Username" || ' appears ' || count("username") || ' times' as TEXT) as Reason
        from test_teachers
        group by "username"
        having count("username")>1
        order by count("username") desc
		) as dupe_usernames
	on test_teachers."username"=dupe_usernames."username"
	order by test_teachers."username" desc
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
--select distinct "teacher id", group_concat(' ' || "reason") from invalid_teachers group by "teacher id";
--drop table invalid_teachers

---------------------------------------
--------Students.csv Tests-------------
---------------------------------------

--Create table for invalid students because their school id is in invalid_schools table
create temp table inv_students_inv_school
as
	Select "student id", cast('School ID ' || "school id" || ' for this student is in Invalid Schools list' as Text) as Reason
	from test_students
	where "school id" in (
		select "school id"
		from invalid_schools
	)
;
--select * from inv_students_inv_school
--drop table inv_students_inv_school

--create table for students that have a school id that does not exist
create temp table inv_students_no_school
as
	select "Student ID", cast('School ID ' || "School ID" || ' not in Schools list' AS TEXT) as Reason
	from test_students
	where "school id" not in (
		select "school id"
		from test_schools
		)
;

--Create table for invalid students because they have duplicate student id's
create temp table inv_students_dupe_id
as
	select "student id", cast('Student ID ' || "student id" || ' appears ' || count("student id") || ' times' as TEXT) as Reason
	from test_students
	group by "student id"
	having count("student id")>1
	order by count("student id") desc
;
--select * from inv_students_dupe_id
--drop table inv_students_dupe_id

--Create table for invalid students because they have duplicate student numbers
create temp table inv_students_dupe_num
as
	select "student number", cast('Student Number ' || "student number" || ' appears ' || count("student number") || ' times' as TEXT) as Reason
	from test_students
	group by "student number"
	having count("student number")>1
	order by count("student number") desc
;
--select * from inv_students_dupe_num
--drop table inv_students_dupe_num

--Create table for invalid students because they have a null value in required field
create temp table inv_students_null 
as
    select "student id", cast('Null in Required Field' AS TEXT) as Reason
        from test_students
        WHERE "school id" = '' 
            OR "student id" = ''
            OR "student number" = ''
            OR "first name" = ''
            OR "last name" = ''
            OR "grade" = ''
;
--select * from inv_students_null
--drop table inv_students_null


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
--select distinct "student id", group_concat(' ' || "reason") from invalid_students group by "student id";
--drop table invalid_students


----------------------------------------------
------------Sections.csv Tests----------------
----------------------------------------------

--Create database for sections with a "teacher id" in the invalid teachers table
create temp table inv_sections_inv_teacher
as
	Select "section id", cast('Teacher ID ' || "teacher id" || ' for this section is in Invalid Teachers list' as Text) as Reason
	from test_sections
	where "teacher id" in (
		select "teacher id"
		from invalid_teachers
	)
;
--select * from inv_sections_inv_teacher
--drop table inv_sections_inv_teacher

--create table for sections that have teacher id's that are not in the teachers list
create temp table inv_sections_no_teacher
as
	select "section id", cast('Teacher ID ' || "Teacher ID" || ' not in Teachers list' AS TEXT) as Reason
	from test_sections
	where "teacher id" not in (
		select "teacher id"
		from test_teachers
		)
;

--Create database for sections with a duplicate section id
create temp table inv_sections_dupe_id
as    
	select "section id", cast('Section ID ' || "section id" || ' appears ' || count("section id") || ' times' as TEXT) as Reason
	from test_sections
	group by "section id"
	having count("section id")>1
	order by count("section id") desc
;
--select * from inv_sections_dupe_id
--drop table inv_sections_dupe_id

--Create invalid sections table from the above checks
create temp table invalid_sections
as
    select * from temp.inv_sections_inv_teacher
    UNION ALL
	select * from temp.inv_sections_no_teacher
	UNION ALL
    select * from temp.inv_sections_dupe_id
;
--select distinct "section id", group_concat(' ' || "reason") from invalid_sections group by "section id";
--drop table invalid_sections

---------------------------------------
-------Enrollments.csv Tests-----------
---------------------------------------
    
--Create table for enrollments that have a "section id" that is invalid    
create temp table inv_enrollments_inv_section
as
	Select "section id", cast('Section ID ' || "section id" || ' for this enrollment is in Invalid Sections list' as Text) as Reason
	from test_enrollments
	where "section id" in (
		select "section id"
		from invalid_sections
	)
;
--select * from inv_enrollments_inv_section
--drop table inv_enrollments_inv_section

--Create table for enrollments that have a "student id" that is invalid
create temp table inv_enrollments_inv_student
as
    select "section id", cast('Student ID ' || "student id" || ' for this enrollment is in Invalid Students list' as Text) as Reason
    from test_enrollments
    where "student id" in (
        select "student id"
        from invalid_students
        )
;
--select * from inv_enrollments_inv_student
--drop table inv_enrollments_inv_student

--Create table for enrollments that have a student id that is not in the students list
create temp table inv_enrollments_no_student
as
	select "section id", cast('Student ID ' || "student id" || ' for this enrollment is not in Students list' AS TEXT) as Reason
	from test_enrollments
	where "student id" not in (
		select "student id"
		from test_students
	)
;

--Create table for enrollments that have a teacher id that is not in the teachers list
create temp table inv_enrollments_no_section
as
select "section id", cast('Section ID ' || "section id" || ' is not in Sections list' AS TEXT) as Reason
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
--select distinct "section id", group_concat(' ' || "reason") from invalid_enrollments group by "section id";
--drop table invalid_enrollments

-------------------------------------------------
---------Saving results as CSV-------------------
-------------------------------------------------

.once ./output/invalid_schools.csv
select distinct "school id", group_concat(' ' || "reason") from invalid_schools group by "school id";

.once ./output/invalid_teachers.csv
select distinct "teacher id", group_concat(' ' || "reason") from invalid_teachers group by "teacher id";

.once ./output/invalid_students.csv
select distinct "student id", group_concat(' ' || "reason") from invalid_students group by "student id";

.once ./output/invalid_sections.csv
select distinct "section id", group_concat(' ' || "reason") from invalid_sections group by "section id";

.once ./output/invalid_enrollments.csv
select distinct "section id", group_concat(' ' || "reason") from invalid_enrollments group by "section id";

------------------------------------------------
--------Clean Up tables-------------------------
------------------------------------------------

drop table test_schools;
drop table test_teachers;
drop table test_students;
drop table test_sections;
drop table test_enrollments;
