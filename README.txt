---------------------------------------------------
-----------------Introduction----------------------
---------------------------------------------------
Welcome to Local File Tester v1.2!!!!

This is a local tool made by Roland Estrada to test CSV files according to the IXL Standard.

The IXL Standard documentation can be found here:

https://www.ixl.com/help_docs/IXL-Auto-Rostering-Specifications.pdf

Roland can be reached at the following contact info below for feedback:
restrada@ixl.com
Search "Roland" in Slack


---------------------------------------------------
-------------------About---------------------------
---------------------------------------------------
Local File Tester v1.2 is a SQL script that runs in SQLite.

SQLite was chosen because it allows for the creation of a lightweight, embedded database without
requiring the end user to install a database.

SQLite documentation can be found here:

https://www.sqlite.org/index.html

-------------------------------------------------
--------------Instructions-----------------------
-------------------------------------------------
1. Navigate to your "Local File Tester" folder
2. Navigate to the "Input" folder
3. Save the 5 CSV files you would like to test in the "Input" folder
3a. As of v1.2, these must be saved as "Schools.csv", "Students.csv", "Teachers.csv", "Sections.csv", and "Enrollments.csv" (without the quotes)
4. Go back to the "Local File Tester" folder, click the batch file "Run Local File Tester.bat"
5. After a brief pause, five CSV files will be in the Output folder. These will contain the invalid data from the input CSV files and the reason

------------------------------------------------
------------Local File Tester Tests-------------
------------------------------------------------
Local File Tester v1.2 makes the following checks on the CSV files. These checks will cause a value to be written to the Invalid CSV files in the Output.

--Schools.csv--
-Duplicate School ID
-Empty (null) School ID

--Students.csv--
-School ID in Invalid Schools list
-Duplicate Student ID
-Duplicate Student Number
-Empty (null) in a required field
-School ID is not in the Schools.csv

--Teachers.csv--
-School ID in Invalid Schools list
-Duplicate Teacher ID
-Missing (null) in a required field
-Duplicate username
-School ID is not in the Schools.csv

--Sections.csv
-Teacher ID in Invalid Teachers list
-Duplicate Section ID
-Teacher ID not in the Teachers.csv

--Enrollments
-Section ID in Invalid Sections list
-Student ID in Invalid Students list
-Section ID is not in the Sections.csv
-STudent ID is not in the Students.csv

---------------------------------------------
---------Biggest Changes in 1.2--------------
---------------------------------------------

The biggest change in Local File Tester v1.2 is the way that errors are output in CSV format, as well as the descriptiveness of those errors.

In v1.1, errors were generic. For example, if a student was invalid because their School ID was invalid, we would simply say "School ID is in Invalid Schools list". Users would have to select their School ID, navigate to the Invalid Schools list, then search that school to figure out why it was invalid.

In v1.2, we include more specific information in the error message by concatenating the value with the error message. This lets the user know exactly what the offending value is. Work still needs to be done to pull the full error into the final error output.

We also attempted to tackle the issue of multiple error entries. In v1.1 an entry could be invalid for multiple reasons. For example, a Student may be invalid because they go to an invalid school and they have a duplicate ID. This created a situation where the count of the output of errors could be significantly greater than the input of data. For larger data sets, this would not scale.

In v1.2 we make use of SQLite's GROUP_CONCAT function to select distinct values from each Invalid table, and concatenate all error results together. This function is documented here:

https://www.sqlite.org/lang_aggfunc.html

This makes certain errors more readable but presents some further challenges.

In the case of duplicate errors, we return the duplicate error twice, once for each duplicate value.

Additionally, it is not always easy to tell if a duplicate value is intentional and supported by IXL, or unintentional and not supported by IXL. A customer may intentionally send duplicate entries for a teacher because they teach in multiple schools. This situation is handled by IXL's code base. So work will need to be done to check those scenarios.

---------------------------------------------
-------Known Issues and Limitations----------
---------------------------------------------
--The 5 CSV files in the Input folder must be named "Schools.csv", "Students.csv", "Teachers.csv", "Sections.csv", and "Enrollments.csv".
Future releases of Local File Tester will allow users to select their own CSV files.

--The headers of the CSV files must match the headers in the IXL Standard documentation (https://www.ixl.com/help_docs/IXL-Auto-Rostering-Specifications.pdf)
For example, a Teachers.csv header called "Teacher_ID" (note the underscore) will cause Local File Tester to not behave correctly.
Future releases of Local File Tester will allow headers of different formatting.

--The Invalid CSV output will contain duplicates of a value if it is invalid for multiple reasons.
For example, the "Invalid_Teachers.csv" may contain a Teacher ID 123456 because it is missing a username, and will also list Teacher ID 123456 again if they
have an invalid School ID.
Future releases of Local File tester will output a single line for each value, with multiple reasons listed in the "Reasons" column.

--------------------------------------------
--------------Thank you!!!------------------
--------------------------------------------
Thank you for choosing Local File Tester as your premier CSV testing tool!
