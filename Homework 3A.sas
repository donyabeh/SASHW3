*1a;
filename bpfile '/home/u62368731/sasuser.v94/Homework/HT Screening.txt';
data hypertension_screening;
	infile bpfile;
	input ID $ 1-3 sex $ 4 DOB mmddyy6. visit mmddyy6. prim_dx $ 17-18 sec_dx $ 19-20 HR 21-23
	SBP 24-26 DBP 27-29 vitamins $ 30 pregnant $ 31;
	age_at_visit = INT(YRDIF(DOB,visit,'age'));
run;

*1b;
data hyp_indicator;
	set hypertension_screening;
	*High Diastolic indicator variable;
	if sex = 'M' and age_at_visit <= 30 and DBP > 88 then high_diastolic = 1;
	else if sex = 'M' and age_at_visit >= 31 and age_at_visit <= 65 and DBP > 92 then high_diastolic = 1;
	else if sex = 'M' and age_at_visit >= 66 and DBP > 94 then high_diastolic = 1;
	if sex = 'F' and age_at_visit <= 30 and DBP > 86 then high_diastolic = 1;
	else if sex = 'F' and age_at_visit >= 31 and age_at_visit <= 65 and DBP > 88 then high_diastolic = 1;
	else if sex = 'F' and age_at_visit >= 66 and DBP > 92 then high_diastolic = 1;
	else high_diastolic = 0;
	*High Systolic indicator variable;
	if sex = 'M' and age_at_visit <= 30 and SBP > 152 then high_systolic = 1;
	else if sex = 'M' and age_at_visit >= 31 and age_at_visit <= 65 and SBP > 162 then high_systolic = 1;
	else if sex = 'M' and age_at_visit >= 66 and SBP > 94 then high_systolic = 1;
	if sex = 'F' and age_at_visit <= 30 and SBP > 150 then high_systolic = 1;
	else if sex = 'F' and age_at_visit >= 31 and age_at_visit <= 65 and SBP > 158 then high_systolic = 1;
	else if sex = 'F' and age_at_visit >= 66 and SBP > 164 then high_systolic = 1;
	else high_systolic = 0;
	*Hypertension indicator variable;
	if high_diastolic = 1 or high_systolic = 1 then hypertension = 1;
	else if high_diastolic = 0 or high_systolic = 0 then hypertension = 0;
run;

*1c;
proc print data = hyp_indicator;
	var ID age_at_visit sex high_diastolic high_systolic hypertension;
run;

proc freq data = hyp_indicator;
	tables high_diastolic high_systolic hypertension;
run;

*1d,e;
libname saveLoc '/home/u62368731/sasuser.v94/lectures/Permanent SAS Datasets';
data saveLoc.hyp_patients;
	set hyp_indicator;
	if hypertension = 1;
run;

*2a;
filename nicFile '/home/u62368731/sasuser.v94/Homework/nicotine.csv';
data nic_use;
	infile nicFile dlm = ',' dsd firstobs = 2;
	input id $ state :$10. enrolldate :mmddyy10. age ever100Cigs :$3. smkLast30Days :$3. daysSmoked daysVaped daysChewed;
run;

*2b; 
data new_nic_use;
	set nic_use;
	*part 2e edit below;
	days_used_nicotine = SUM(daysSmoked,daysVaped,daysChewed);
	if smkLast30Days = 'Yes' then smoking_status = 2;
	else if smkLast30Days = 'No' and ever100Cigs = 'Yes' then smoking_status = 1;
	else if smkLast30Days = 'No' and ever100Cigs = 'No' then smoking_status = 0;
	*part 2d edit below;
	else if daysSmoked or daysVaped or daysChewed ^= . then smoking_status = 2;
	else smoking_status = -9;
run;

*2c;
proc freq data = new_nic_use;
	tables smoking_status;
run;
*911 of the observations have never smoked, 268 of the observations are former smokers, 283 of the observations 
are current smokers, and 11 of the observations' smoking status could not be assesed;

*2d;
data missing_smokers;
	set new_nic_use;
	if smoking_status = -9;
run;
*There is one person in the given missing smokers set that did not have data for whether they smoked in the last 30 days or 
ever smoked 100 cigarettes. However, this person has data stating that they have smoked for 22 days, 
vaped 25 times, and chewed tobacco in the last 30 days. This would make that observation a current smoker for their smoking status.
If a person has missing data for days smoked, vaped, or chewed tobacco in the last 30 days, they would fall under the current smoker status.;

*2f;
proc means data = new_nic_use;
	var days_used_nicotine;
run;
*The sample size for the number of days that a person used nicotine in the past 30 days is 284. The mean is 46.7676056
and the standard deviation is 15.2225727;

*HW 3B;
*1a;
filename raceFile "/home/u62368731/sasuser.v94/Homework/Big Sur Marathon.csv"; 
 
data big_sur_marathon; 
  infile '/home/u62368731/sasuser.v94/Homework/Big Sur Marathon.csv' dlm=',' dsd firstobs=2; 
  input bib (name team city) (:$30.) state :$3. elapsedTime :stimer8. pace :stimer5.  
        event :$8. eventPlace  
        age ageDivPlace gender :$1. genderPlace; 
        *adding first and last name variable that scans first word of name and last word of name with specification of space delimited data;
        first = scan(name, 1, ' ');
        last = scan(name, -1, ' ');
run; 

*1b;
*The first method does not work well because SAS does not take into account the last names that are separated by a hyphen. 
SAS only reads in the word before the hyphen as their last name;
*The default delimeters are as follows exclamation point, dollar sign, percent sign, ampersand, open and closed parenthesees,
asterisk, plus sign, comma, hyphen, period, forward slash, semicolon, less than sign, carrot symbol, and the 
pipe symbol. The default delimeter that is the problem for this current task is the hyphen;

*1c;
proc print data = big_sur_marathon (obs = 10);
	var name first last gender elapsedTime;
	format elapsedTime time8.;
run;

*1d;
filename raceFile "/home/u62368731/sasuser.v94/Homework/Big Sur Marathon.csv"; 
 
data big_sur_marathon; 
  infile '/home/u62368731/sasuser.v94/Homework/Big Sur Marathon.csv' dlm=',' dsd firstobs=2; 
  input bib (name team city) (:$30.) state :$3. elapsedTime :stimer8. pace :stimer5.  
        event :$8. eventPlace  
        age ageDivPlace gender :$1. genderPlace; 
        first = substr(name, 1, index(name, ' '));
        last = substr(name, index(name, ' '));
run;
*This method does not work for people that have middle names, as it is read in as a last name;


*2a;
filename crimFile "/home/u62368731/sasuser.v94/Homework/CP Crime Scrape 20220927.csv"; 
 
data cpCrime; 
  infile crimFile dsd firstobs=2; 
  input timeOccur :anydtdte19. location :$80. disposition :$32. incident :$128.; 
run;

*2b;
data cpCrime_days;
	set cpCrime;
	day_of_week = weekday(timeOccur);
run;

proc freq data = cpCrime_days;
	tables day_of_week;
run;
*Friday has the highest crime rate at a frequency of 263, as well as Saturday, having a frequency just below Friday of 235.
Weekends tend to have the highest crime rate;

*2c;
data cpCrime_days;
	set cpCrime_days;
	*sorts through location variable for "off campus" and finds position;
	if index(location, 'Off Campus') then incident_off_campus = 1;
	else incident_off_campus = 0;
run;

proc freq data = cpCrime_days;
	tables incident_off_campus;
run;
*I found that 115 accidents occured off campus, which is 8.71% of the incidents in this report;

*2d;
data cpCrime_locations;
	set cpCrime_days;
	if incident_off_campus;
	new_location = upcase(substr(location, 14));
run;


*3;
filename cannFile "/home/u62368731/sasuser.v94/Homework/Cannabis Control License Search 080819.csv"; 
 
data cannabLics; 
  infile cannFile firstobs=4 dlm=',' dsd; 
  input license :$21. type :$60. owner :$100. contactInfo :$200. structure :$30. address :$80.  
        status :$8. issueDate :mmddyy10. expireDate :mmddyy10. activities :$150. use :$9.; 
run; 

*3a;
data cannabLics_recoded;
	set cannabLics;
	length county $ 30;
	if address = '' then county = '';
	*creates county variable, looks through address variable for starting position ': ' and skips over 2 characters to read county;
	else county = propcase(substr(address, index(address, ': ')+2));
run;

*3b;
proc freq data = cannabLics_recoded;
	tables county / missing;
run;
*The most prevalent county is Los Angeles with a frequency of 1509 observations. It makes sense that 
Los Angeles has the most owners of Cannabis Licenses because it is a larger county than most with a high density of people. The 
missing option added the frequency distribution of missing counties.;	

*3c;
data cannabis_licenses;
	set cannabLics_recoded;
	if index(address, 'CA') then in_california = 1;
	else in_california = 0;
run;

proc freq data = cannabis_licenses;
	tables in_california;
run;
*There are no addresses outside of California, but there are 203 values that have a missing address or state specification;

*3d;
data cannabis_licenses_2;
	set cannabis_licenses;
	length zipCodes $ 10;
	if address = '' then zipCodes = '';
	else zipCodes = substr(address, index(address, 'CA ')+3, 5);
run;	

proc freq data = cannabis_licenses_2;
	tables zipCodes;
run;
*The most prevalent zip code is 94621 with a frequency of 257 businesses in this area. This zip code is in Oakland, California.;

*3e;
data cannabis_licenses_3;
	set cannabis_licenses_2;
	length sascity $ 20;
	if address = '' then sascity = '';
	else do;
	sascity = zipcity(zipCodes);
	sascity = substr(sascity, 1, index(sascity, ',')-1);
	end;
	*finding city through sas function then editing city to delete the leading state;
run;

proc print data = cannabis_licenses_3 (obs = 10);
	var license sascity county zipCodes;
run;

*3f;
data cannabis_licenses_3;
	set cannabis_licenses_3;
	license_prefix = scan(license, 1, '-');
run;

*3g;
*Those who have the event organizer cannabis licenses are missing zip codes. This makes sense because event organizers usually
travel to multiple corporations, so they would not have a fixed address as to where they sell cannabis;
