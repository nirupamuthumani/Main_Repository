--1. Get list of Patients order by DateOfBirth descending order--
select "Patient_ID", "FirstName","LastName" ,"DateOfBirth" from "Patients" order by "DateOfBirth" Asc
--2. Display the firstname and lastname of patients who speaks English language.--
select "FirstName", "LastName","Language_ID" from "Patients" where "Language_ID" = 'L_01';

--3.Write a query to get list of patient ID's whose PrimaryDiagnosis is 'Flu'  order by patient_ID --
 
select d."Patient_ID" ,pd."PrimaryDiagnosis" from public."Discharges" as d
Right join public."PrimaryDiagnosis" as pd 
on d."Diagnosis_ID"=pd."Diagnosis_ID" where "PrimaryDiagnosis"='Flu' order by "Patient_ID";

--4. Write a query to find the Patient_ID and Admission_ID for the patients whose Primary diaganosis is 'Heart Failure'--
select d."Patient_ID", d."Admission_ID" ,pd."PrimaryDiagnosis" from public."Discharges" as d
Right join public."PrimaryDiagnosis" as pd 
on d."Diagnosis_ID"=pd."Diagnosis_ID" where "PrimaryDiagnosis"='Heart Failure';

--5. Write a query to get list of patient ID's whose pulse is below the normal range--
select "Patient_ID","Pulse" from public."AmbulatoryVisits" where "Pulse" < 60;

--6. Write a query to find the list of patient_ID's discharged with Service in SID01, SID02, SID03
SELECT D."Patient_ID",D."Service_ID"
FROM "Discharges" D
WHERE D."Service_ID" IN ('SID01','SID02','SID03')

--7. Write a query to get list of patients who were admitted because of Stomachache.
SELECT P."FirstName" || ' ' || P."LastName" AS PatientName
FROM (("Patients" P
	  INNER JOIN "EDVisits" ED ON P."Patient_ID" = ED."Patient_ID")
	 INNER JOIN "ReasonForVisit" RV ON ED."Rsv_ID" = RV."Rsv_ID")
WHERE RV."ReasonForVisit" = 'Stomach Ache'	 

--8. Write a query to Update Service ID SID05 to Ortho
UPDATE "Service" 
SET "Service" = 'Ortho'
WHERE "Service_ID" = 'SID05'

--9. Get list of Patient ID's whose visit type was 'Followup' and VisitdepartmentID is 5 or 6
SELECT AV."Patient_ID",VT."VisitType",AV."VisitDepartmentID"
FROM ("AmbulatoryVisits" AV
	 INNER JOIN "VisitTypes" VT ON AV."AMVT_ID" = VT."AMVT_ID")
WHERE VT."VisitType" = 'Follow Up' AND 
	(AV."VisitDepartmentID" = 5 OR AV."VisitDepartmentID" = 6)

--10. Create index on ambulatory visit by selecting columns Visit_ID, AMVT_ID and VisitStatus_ID
CREATE INDEX ambulatory_visitid_amvtid_visitstatusid_idx
ON "AmbulatoryVisits"("Visit_ID","AMVT_ID","VisitStatus_ID")

-- 11. Create a trigger to execute after inserting a record into Patients table.Insert value to display result.

CREATE TABLE Audit_Patients(PID Integer NOT NULL PRIMARY KEY,entry_date VARCHAR(100) NOT NULL)

CREATE OR REPLACE FUNCTION auditlogfunc()
RETURNS TRIGGER AS $examp_table$
BEGIN 
INSERT INTO audit_patients(pid,entry_date) VALUES(NEW."Patient_ID",CURRENT_TIMESTAMP);
RETURN NEW;
END;
$examp_table$ LANGUAGE plpgsql;

CREATE TRIGGER patient_trigger AFTER INSERT ON public."Patients" FOR EACH ROW
EXECUTE PROCEDURE auditlogfunc()

INSERT into "Patients"("Patient_ID","FirstName","LastName") VALUES ('946','KKK','LLL')

select * from public."Patients" order by "Patient_ID" DESC LIMIT 5

select * from public.audit_patients

-- 12.Write a query to find the ProviderName and Provider Speciality for PS_ID ='PSID02'
SELECT PV."ProviderName" ProviderName,PS."ProviderSpeciality"
FROM "ProviderSpeciality"  PS JOIN "Providers" PV 
ON PV."PS_ID" = PS."PS_ID"
WHERE PV."PS_ID"='PSID02'

-- 13. Display the patient names and ages whose age is more than 50 years

SELECT "FirstName","Patients"."LastName",date_part('year',age("Patients"."DateOfBirth")) as Age
FROM "Patients" WHERE (date_part('year',age("Patients"."DateOfBirth"))) >50


-- 14.Write a query to get list of patient ID's and service whose are in service as'Nuerology'
SELECT RG."Patient_ID",S."Service" FROM "ReAdmissionRegistry" RG JOIN "Service" AS S 
ON RG."Service_ID" = S."Service_ID"
WHERE "Service" = 'Neurology'

-- 15.Create view on table Provider table on columns ProviderName and Provider_ID 

CREATE VIEW View_Provider("ProviderName","Provider_ID")
AS
SELECT "ProviderName","Provider_ID" FROM "Providers"

/*Q16: Write a query to Extract Year from ProviderDateOnStaff*/

SELECT to_char("ProviderDateOnStaff",'YYYY') as "ProviderYearOnStaff"
FROM public."Providers"

/*Q17:Write a query to get unique Patient_ID,race and Language of patients
whose race is White and also speak English.*/

select "Patient_ID","Race","Language" 
from public."Patients" as Pt
join public."Race" as R
on Pt."Race_ID" = R."Race_ID"
join public."Language" as L 
on  Pt."Language_ID" = L."Language_ID"
where 1=1
And R."Race" = 'White'
And L."Language" = 'English'

/*Q18:Get list of patient ID's whose service was 'Cardiology' and discharged to
'Home'*/

select "Patient_ID","Service","DischargeDisposition" 
from "ReAdmissionRegistry" RA join "DischargeDisposition" DD
on RA."Discharge_ID"= DD."Discharge_ID"
join "Service" S
on RA."Service_ID" = S."Service_ID"
where DD."DischargeDisposition" = 'Home'
AND S."Service"='Cardiology'
 
/*Q19: Write a query to get list of Provider names whose Providername is starting
with letter T */

select "ProviderName" from "Providers"
where "ProviderName" like 'T%'

/*Q20: List female patients over the age of 40 who have undergone surgery from
January-March 2019 */

select "FirstName" || ' ' || "LastName" as "PatientName"
,substring(G."Gender",1,1) as "Gender"
, EXTRACT(YEAR from AGE(CURRENT_DATE, Pt."DateOfBirth")) as "Age"
, AV."DateofVisit"
from "Patients" PT join "Gender" G
on PT."Gender_ID" = G."Gender_ID"
join "AmbulatoryVisits" AV
on PT."Patient_ID" = AV."Patient_ID"
join "Providers" P
on P."Provider_ID" = AV."Provider_ID"
join "ProviderSpeciality" PS
on PS."PS_ID"= P."PS_ID"
where 
G."Gender" = 'Female' AND
EXTRACT(YEAR from AGE(CURRENT_DATE, Pt."DateOfBirth")) > 40 AND
PS."ProviderSpeciality" = 'Surgery' AND
AV."DateofVisit" between to_date('20190101','YYYYMMDD') AND to_date('20190331','YYYYMMDD')

--21. Write a Query to get list of Male patients.--

select p."FirstName",p."LastName",g."Gender" from public."Patients" as p
join public."Gender" as g
on p."Gender_ID"= g."Gender_ID" where p."Gender_ID"='G001';

--22. Write a query to get list of patient ID's who has discharged to home--

select "Patient_ID",dd."DischargeDisposition" from public."Discharges" as d
join public."DischargeDisposition" as dd
on d."Discharge_ID"= dd."Discharge_ID" 
where dd."DischargeDisposition"='Home';

--23. Find the category of illness(Stomach Ache or Migraine) that has maximum
number of patients--
select max(edv."Patient_ID") from public."EDVisits" as edv
Right join public."ReasonForVisit" as rfv 
on edv."Rsv_ID"=rfv."Rsv_ID" where "ReasonForVisit"='Stomach Ache' or "ReasonForVisit"='Migraine';


--24. Write a query to get list of New Patient ID's.—
select av."Patient_ID",vt."VisitType" from public."AmbulatoryVisits" as av
join  public."VisitTypes" as vt
on av."AMVT_ID"= vt."AMVT_ID" 
where vt."VisitType"='New';
--25. Create trigger on table Readmission registry--

CREATE OR REPLACE FUNCTION insert_log()
  RETURNS trigger AS
$$
BEGIN
         INSERT INTO public."ReAdmissionRegistry"("Admission_ID","Patient_ID",
					  "AdmissionDate","DischargeDate",
					  "Service_ID","Diagnosis_ID",
					  "ExpectedLOS","ExpectedMortality")
 
         VALUES (NEW."Admission_ID",NEW."Patient_ID",
				CURRENT_DATE,NEW."DischargeDate",
				NEW."Service_ID",NEW."Diagnosis_ID",
				NEW."ExpectedLOS",NEW."ExpectedMortality")
 ;
 
    RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';


CREATE TRIGGER insert_trigger
  AFTER INSERT
  ON public."ReAdmissionRegistry"
  FOR EACH ROW
  EXECUTE PROCEDURE insert_log();


--26. Select all providers with a name starting 'h' followed by any character ,
--followed by 'r', followed by any character,followed by 'y
SELECT "ProviderName" 
FROM "Providers" 
WHERE "ProviderName" LIKE 'H_r_y%'

--27. Show the list of the patients who have cancelled their appointment--
SELECT P."FirstName" || ' ' || P."LastName" AS PatientName
FROM (("Patients" P
	   	JOIN "AmbulatoryVisits" AV ON P."Patient_ID" = AV."Patient_ID")
	   JOIN "VisitStatus" VS ON AV."VisitStatus_ID" = VS."VisitStatus_ID")
WHERE VS."VisitStatus" = 'Canceled'

--28. Write a query to get list of ProviderName's with a name starting 'ted--
SELECT "ProviderName" 
FROM "Providers" 
WHERE "ProviderName" LIKE 'Ted%'

--29. Create a view without using any schema or table and check the created--
--view using select statement--
CREATE VIEW BPLimit_view AS
 SELECT text 'BPS>130 & BPD>80' AS High_BP,
 	text 'BPS<90 & BPD<60' AS Low_BP
	
SELECT * FROM BPLimit_view

--30. Write a query to get unique list of Patient Id's whose reason for visit is car accident--
SELECT DISTINCT P."Patient_ID"
FROM (("Patients" P
	 INNER JOIN "EDVisits" ED ON P."Patient_ID" = ED."Patient_ID")
	 INNER JOIN "ReasonForVisit" RV ON ED."Rsv_ID" = RV."Rsv_ID")
WHERE RV."ReasonForVisit" = 'Car Accident'	 

/*31. Find which Visit type of patients are maximum in cancelling their appointment*/

SELECT COUNT("Patient_ID") AS PVType_Count,"VisitType"
FROM  "AmbulatoryVisits" AV JOIN "VisitTypes" V 
ON AV."AMVT_ID" = V."AMVT_ID" JOIN "VisitStatus" VS ON AV."VisitStatus_ID" = VS."VisitStatus_ID"
WHERE "VisitStatus"='Canceled' GROUP BY "VisitType" ORDER BY PVType_Count DESC LIMIT 1


-- 32. Write a query to Count number of patients by VisitdepartmentID where count greater than 50  

SELECT "VisitDepartmentID",count("Patient_ID") as "Patient_Count" from "AmbulatoryVisits"
GROUP BY("VisitDepartmentID") HAVING count("Patient_ID")> 50

-- 33. Write a query to get list of patient names whose visit type is new and visitdepartmentId is 2.*/

SELECT PT."FirstName",PT."LastName",VT."VisitType",AV."VisitDepartmentID" FROM "Patients" PT
JOIN "AmbulatoryVisits" AV ON PT."Patient_ID" = AV."Patient_ID"
JOIN "VisitTypes" VT ON VT."AMVT_ID" = AV."AMVT_ID" 
WHERE "VisitDepartmentID" = 2 AND "VisitType"='New'

-- 34. Write a query to find the most common reasons for hospital visit for patients between 50 and 60 years 

SELECT "ReasonForVisit" ,COUNT(P."Patient_ID") AS Patient_Count
FROM "Patients" P JOIN "EDVisits" EV ON EV."Patient_ID" = P."Patient_ID"
JOIN "ReasonForVisit" ON "ReasonForVisit"."Rsv_ID" = EV."Rsv_ID"
WHERE date_part('year',age(P."DateOfBirth")) BETWEEN 50 AND 60
GROUP BY "ReasonForVisit" ORDER BY Patient_Count DESC


-- 35. Get list of Patients whose gender is Male and who speak English and whose race is White
SELECT P."FirstName",P."LastName"
FROM "Patients" P JOIN "Gender" G ON G."Gender_ID" = P."Gender_ID"
JOIN "Language" L ON L."Language_ID" = P."Language_ID"
JOIN "Race" R ON R."Race_ID" = P."Race_ID"
Where (G."Gender"='Male' AND L."Language" = 'English' AND R."Race" ='White')

/*Q36: Create index on Patient table */

 create index "FirstNameIndex" on "Patients"("FirstName")

/*Q37: Write a query to get list of Provider ID's where ProviderDateOnStaff year is
2013 and 2010 */

select "Provider_ID", to_char("ProviderDateOnStaff",'YYYY') as "ProviderDateOnStaffYear" from "Providers"
where to_char("ProviderDateOnStaff",'YYYY') in('2013','2010')

/* Q38: Write a query to find out percentage of Ambulatory visits by visit type.*/

select VT."VisitType" as "Visit_Type"  
,count(AV."Visit_ID") "Visit_Count" 
,(select count("Visit_ID") from "AmbulatoryVisits") "Total_Count" 
,round(count(AV."Visit_ID")*100.0/(select count("Visit_ID") from "AmbulatoryVisits"),2) as "Visit_Percentage" 
from "AmbulatoryVisits"  AV 
join "VisitTypes" VT 
on AV."AMVT_ID" = VT."AMVT_ID" 
Group By "VisitType" 

/* Q39: Write a query to get list of patient names who has discharged. */

select "FirstName" || ' ' || "LastName" as "DischargedPatientName" 
from "Patients" PT join "Discharges" D 
on PT."Patient_ID" = D."Patient_ID" 
join "DischargeDisposition" DD 
on DD."Discharge_ID" = D."Discharge_ID" 
where DD."DischargeDisposition" = 'Home' 
order by "DischargedPatientName" 

/* Q40: Create view on table EdVisit by selecting some columns and filter data 
using Where condition */

Create View "EDVisitView" as 
select "EDVisit_ID", "Patient_ID", "Acuity" 
from "EDVisits"
where "Acuity" = 3

select * from "EDVisitView"

--41. Get list of patient names whose primary diagnosis as 'Spinal Cord injury'
having Expected LOS is greater than 15--


select 	p."FirstName",p."LastName",pd."PrimaryDiagnosis",rr."ExpectedLOS"
from public."Patients" as p
join public."ReAdmissionRegistry" as rr
on p."Patient_ID"=rr."Patient_ID" 
inner join public."PrimaryDiagnosis" as pd 
on rr."Diagnosis_ID"=pd."Diagnosis_ID" where pd."PrimaryDiagnosis"='Spinal Cord Injury'
AND rr."ExpectedLOS" >'15';

--42. Write a query to get list of Patient names who haven't discharged--

select p."FirstName",p."LastName",dd."DischargeDisposition" from public."Patients" as p
right join public."Discharges" as d on d."Patient_ID"=p."Patient_ID"
left join public."DischargeDisposition" as dd on d."Discharge_ID"= dd."Discharge_ID" 
where dd."DischargeDisposition"='Transfer';


--43. Write a query to get list of Provider names whose ProviderSpecialty is
Pediatrics.--


select p."ProviderName",ps."ProviderSpeciality" from public."Providers" as p
left join public."ProviderSpeciality" as ps on p."PS_ID"=ps."PS_ID"
where ps."ProviderSpeciality"='Pediatrics';


--44. Write a query to get list of patient ID's who has admitted on 1/7/2018 and
discharged on 1/15/2018--

select d."Patient_ID",d."AdmissionDate", cast(d."DischargeDate" as date )  from public."Discharges" as d 
where d."AdmissionDate" = '2018-01-07' and cast (d."DischargeDate" as date) = '2018-01-15 ' ;


--45. Write a query to find outpatients vs inpatients by monthwise (hint:
consider readmission/discharges and ambulatory visits table for inpatients
and outpatients)--



CREATE extension tablefunc;


SELECT * FROM
  CROSSTAB(
    $$
with cte as 
(
select count(av."Patient_ID") counts,
to_char(av."DateofVisit",'month')mns,date_part('year',av."DateofVisit")yrs,
'outpatients' type
from  public."AmbulatoryVisits" av 
GROUP BY mns,yrs
 
union all
select count(rr."Patient_ID") counts,
to_char(rr."AdmissionDate",'month') mns,date_part('year',rr."AdmissionDate")yrs,
'inpatients' type
from public."ReAdmissionRegistry"  rr 
GROUP BY mns,yrs	)
SELECT mns,yrs,type,counts FROM
  cte $$,
    $$ values
	(   'inpatients'  ),
	  ('outpatients')
	  $$)
     AS (
		 mns text,
		 yrs numeric,
		 inpatients numeric,
		 outpatients numeric
	 	 ) ;
	 

--46. Write a query to get list of Number of Ambulatory Visits by --
--Provider Speciality per month--
SELECT COUNT(AV."Visit_ID")AS NumberOfAmbulatoryVisits,PS."ProviderSpeciality",
TO_CHAR(AV."DateofVisit",'Month') AS Month,EXTRACT(year from AV."DateofVisit") AS Year
FROM (("AmbulatoryVisits" AV
JOIN "Providers" PR ON AV."Provider_ID" = PR."Provider_ID")
JOIN "ProviderSpeciality" PS ON PR."PS_ID" = PS."PS_ID")
GROUP BY PS."ProviderSpeciality",Month,Year
ORDER BY PS."ProviderSpeciality",Month,Year


--47.Write a query to find Average age for admission by service--
SELECT ROUND(AVG(EXTRACT('year' FROM AGE(P."DateOfBirth")))) AS Average_Age,S."Service"
FROM (("Patients" P
JOIN "Discharges" D ON P."Patient_ID" = D."Patient_ID" )
JOIN "Service" S ON D."Service_ID" = S."Service_ID")
GROUP BY S."Service"

--48. Write a query to get list of patient with their full names whose names
--contains "Ma"
SELECT P."FirstName" || ' ' || P."LastName" AS PatientName
FROM "Patients" P
WHERE (P."FirstName" LIKE 'Ma%' OR P."FirstName" LIKE '%Ma') OR 
	(P."LastName" LIKE 'Ma%' OR P."LastName" LIKE '%Ma')
	
--49. Update Visit Timestamp column in EDVisits table by selecting data type as
--timestamp with timezone
ALTER TABLE "EDVisits"
ALTER COLUMN "VisitTimestamp"
SET DATA TYPE timestamptz

--50. create a trigger function on AmbulatoryVisits by selecting any two columns.
	
--creating temporary table--
CREATE TABLE ambupdate(
	"Pat_ID" INTEGER NOT NULL,
	"VisitDate" DATE,
	"ScheduledDate" TIMESTAMP
	)
	
	
--creating Trigger Function--
CREATE OR REPLACE FUNCTION update()
RETURNS TRIGGER AS $NEW$
BEGIN	
	INSERT INTO ambupdate("Pat_ID","VisitDate","ScheduledDate")
	VALUES(NEW."Patient_ID",NEW."DateofVisit",NEW."DateScheduled");
	RETURN NEW;
END;
$NEW$ LANGUAGE plpgsql;

--creating trigger named update_ambulatory--
CREATE TRIGGER update_ambulatory
AFTER UPDATE ON "AmbulatoryVisits"
FOR EACH ROW
EXECUTE PROCEDURE update();

--update--
UPDATE "AmbulatoryVisits" 
SET "DateofVisit" = '2019-01-15' ,  "DateScheduled" = '2018-12-30 9:18:24'
WHERE "Patient_ID" = 5

-- 51. Insert number of days for Readmission in DaysToReadmission Column for patient ID's from 737 to 742

UPDATE "ReAdmissionRegistry" SET "DaysToReadmission" ='6'WHERE "Patient_ID" ='737'
UPDATE "ReAdmissionRegistry" SET "DaysToReadmission" ='8'WHERE "Patient_ID" ='738'
UPDATE "ReAdmissionRegistry" SET "DaysToReadmission" ='9'WHERE "Patient_ID" ='739'
UPDATE "ReAdmissionRegistry" SET "DaysToReadmission" ='10'WHERE "Patient_ID" ='740'
UPDATE "ReAdmissionRegistry" SET "DaysToReadmission" ='11'WHERE "Patient_ID" ='741'
UPDATE "ReAdmissionRegistry" SET "DaysToReadmission" ='12'WHERE "Patient_ID" ='742'

select "Patient_ID","DaysToReadmission" from public."ReAdmissionRegistry" WHERE "Patient_ID" BETWEEN '737' and '742'

-- 52. Get list of Provider names whose name is starting with K and ending with y(Hint:K-Upper, Y-Lower)

SELECT "ProviderName" FROM "Providers" WHERE "ProviderName" LIKE 'K%y'

-- 53. Write a query to Split provider First name and Last name into different column

SELECT "Providers"."ProviderName",SPLIT_PART("ProviderName",' ',1) AS "First name" , SPLIT_PART("ProviderName",' ',2) AS "Last name" 
FROM "Providers"

-- 54. Get list of Patient ID's order by Discharge date

SELECT "Patient_ID","DischargeDate" FROM "Discharges" ORDER BY "DischargeDate"


-- 55. Write a query to drop View by creating view on table Discharge by selecting columns

CREATE VIEW View_Discharges("ExpectedLOS","Discharge_ID")
AS
SELECT "ExpectedLOS","Discharge_ID" FROM "Discharges"

DROP VIEW view_discharges

/* Q56: Write a query to get list of Patient ID's where Visitdepartment ID is 1 and
BloodPressureSystolic is between 123 to 133 */

select PT."Patient_ID", AV."VisitDepartmentID", AV."BloodPressureSystolic"
from "Patients" PT join "AmbulatoryVisits" AV
on PT."Patient_ID"= AV."Patient_ID"
where
"VisitDepartmentID" = 1
And
AV."BloodPressureSystolic"  between 123 And 133

/* Q57: Write the query to create Index on table ReasonForVisit by selecting a
column and also write the query drop same index*/

create Index "ReasonForVisitIndex" on "ReasonForVisit"("ReasonForVisit")

drop index "ReasonForVisitIndex"

/* Q58: Write a query to Count number ofunique patients EDDisposition wise.*/

select EDD."EDDisposition", count(distinct("Patient_ID")) as "CountOfPatients"
from "EDVisits" EDV join "EDDisposition" EDD
on EDV."EDD_ID"= EDD."EDD_ID"
group by EDD."EDDisposition"

/* Q59: Write a query to get list of Patient ID's whree Visitdepartment ID is 5 or
BloodPressureSystolic is NOT NULL */

select PT."Patient_ID", AV."VisitDepartmentID", AV."BloodPressureSystolic"
from "AmbulatoryVisits" AV join "Patients" PT
on PT."Patient_ID" = AV."Patient_ID"
where 
AV."VisitDepartmentID" = 5
OR
AV."BloodPressureSystolic"  IS NOT NULL

/* Q60:Query to find the number of patients readmitted by Service*/

select S."Service", count(RA."Patient_ID") as "No.OfPatients"
from "Service" S join "ReAdmissionRegistry" RA
on S."Service_ID" = RA."Service_ID"
group by "Service"

--61. Write a query to list male patient ids and their names who are above 40
years of age and less than 60 years and have BloodPressureSystolic above
120 and BloodPressureDiastolic above 80--


select p."Patient_ID",p."FirstName",p."LastName", 
date_part('year',current_date)-date_part('year',"DateOfBirth") yrs
from public."Patients" as p
left join public."Gender" as g
on p."Gender_ID"= g."Gender_ID"
join public."AmbulatoryVisits" as av
on p."Patient_ID"=av."Patient_ID" 
where g."Gender"='Male' and 
av."BloodPressureSystolic">'120' and av."BloodPressureDiastolic">'80' and
date_part('year',current_date)-date_part('year',"DateOfBirth")
between 40 and 60 ;



--62. Query to find the number of outpatients who have visited month wise(use month names)--


select
count(p."Patient_ID"),to_char(av."DateofVisit",'month') month_visit,date_part('year',av."DateofVisit") year_visit
from public."Patients" p  
inner join public."AmbulatoryVisits" av 
on p."Patient_ID"= av."Patient_ID"
group by to_char(av."DateofVisit",'month'), date_part('year',av."DateofVisit")
order by to_char(av."DateofVisit",'month');




--63. Write a query to get list of patient ID's whose BloodPressureSystolic is
131,137,138--


select av."Patient_ID",av."BloodPressureSystolic" from public."AmbulatoryVisits" as av
where av."BloodPressureSystolic" in ('131','137','138');


--64. Query to classify expected LOS into 3 categories as per the duration. (Hint:
Use of CASE statement)--


select "Patient_ID","ExpectedLOS",

case 
when "ExpectedLOS" <'2' then 'NormalStay'
when "ExpectedLOS" >'2' and "ExpectedLOS"<'5' then 'ShortStay'
when "ExpectedLOS" >'5' then 'LongStay'
else 'NoStay' end category


from public."Discharges" order by "ExpectedLOS";


--65. Write a query to create a table to list the names of patients whose date of
birth is later than 1st jan 1960.Name the table as “Persons”--


select "FirstName","LastName","DateOfBirth" 
into "Persons"   /*Temptable*/
from public."Patients" 
where "DateOfBirth" > TO_DATE ('1960-01-01','YYYY-MM-DD')
order by "DateOfBirth";
select * from "Persons"



--66. Write a query to Count number of patients who has discharged after march3rd 2018
SELECT COUNT(D."Patient_ID")
FROM "Discharges" D
WHERE D."DischargeDate" > '2018-03-03 23:59:59'

--67. Replace ICU with emergency (Hint: Do not update or alter the table)--
select S."Service" ,
replace(S."Service", 'ICU','Emergency') as New_Column
from "Service" S

--68. Write a query to get Sum of ExpectedLOS for Service_ID 'SID01'--
SELECT ROUND(SUM(RAR."ExpectedLOS")) AS ExpectedLOS_Sum
FROM "ReAdmissionRegistry" RAR
WHERE RAR."Service_ID" = 'SID01'

--69. Create index on table Provider by selecting a column and filter by using
--WHERE condition
CREATE INDEX psid_idx
ON "Providers"("PS_ID")
WHERE "ProviderDateOnStaff" > '1999-12-31'

--70. List down all triggers in our HealthDB database
SELECT event_object_table AS table_name,trigger_name
FROM information_schema.triggers
GROUP BY table_name,trigger_name
ORDER BY table_name,trigger_name


-- 71. Partition the table according to Service_ID and use windows function to calculate percent rank. Order by ExpectedLOS

SELECT "Service_ID",PERCENT_RANK() OVER ( PARTITION BY "Service_ID" ORDER BY "ExpectedLOS") FROM "Discharges"

-- 72. Write a query by using common table expressions and case statements to display birthyear ranges

WITH DOBYears AS
(
	Select 
		  "Patient_ID",
	      "DateOfBirth",
		  EXTRACT('Year' from "DateOfBirth") AS DOBYear 
	FROM public."Patients"

)

SELECT "Patient_ID", "DateOfBirth",
CASE
WHEN DOBYear BETWEEN 1960 AND 1969 THEN '1960s'
WHEN DOBYear BETWEEN 1970 AND 1979 THEN '1970s'
WHEN DOBYear BETWEEN 1980 AND 1989 THEN '1980s'

END AS "Birth_Year Ranges"
FROM DOBYears ORDER BY "DateOfBirth" ASC

-- 73. Get list of Provider names whose ProviderSpeciality is Surgery

SELECT "ProviderName" , "ProviderSpeciality" FROM "Providers" P JOIN "ProviderSpeciality" PS
ON PS."PS_ID" = P."PS_ID" WHERE PS."ProviderSpeciality" = 'Surgery'

-- 74. List of patient from rows 11-20 without using where condition.

SELECT "Patient_ID","FirstName","LastName" FROM "Patients" ORDER BY "Patient_ID" LIMIT 10 OFFSET 10

-- 75. Give a query how to find triggers from table AmbulatoryVisits

SELECT  event_object_table AS table_name ,trigger_name         
FROM information_schema.triggers  
WHERE event_object_table ='AmbulatoryVisits'
GROUP BY table_name , trigger_name 
ORDER BY table_name ,trigger_name

/* Q76:Recreate the below expected output using Substring.*/

select "Gender" , substring("Gender",1,1) as "gender" from "Gender"

/* Q77: Obtain the below output by grouping the patients.*/

select "Patient_ID"
,"FirstName"
,substring("FirstName",1,1) as "patient_group"
from "Patients"
where "FirstName" Like 'L%'

/*Q78: Please go through the below screenshot and create the exact output.*/

select "FirstName"
,length("FirstName") 
from "Patients"

/*Q79: Please go through the below screenshot and create the exact output */

select "BloodPressureDiastolic","Pulse"
, ceil("BloodPressureDiastolic") as "bpd"
, ceil("Pulse") as "heartrate" from "AmbulatoryVisits"
offset 1 Limit 21


/*Q80: Please go through the below screenshot and create the exact output */

select "BloodPressureSystolic"
, 'The Systolic Blood Pressure is ' || round(cast("BloodPressureSystolic" as Decimal),2) as "Message"
from "AmbulatoryVisits"


