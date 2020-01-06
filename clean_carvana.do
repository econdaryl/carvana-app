clear all

import delimited using carvana_aug.csv, clear varn(1)
gen month = "august"
tempfile august
save "`august'"

import delimited using carvana.csv, clear varn(1)
gen month = "july"
append using "`august'"
split make
destring make1, gen(year)
destring price, replace ignore(",")
destring mileage, replace ignore(",miles")
drop make
gen make = make2
replace make = make2 + " " + make3 if !missing(make3)
drop make1 make2 make3
order make model trim mileage price year
duplicates drop make model trim mileage price, force

// Mazda
replace trim = "Touring" if make == "Mazda" & inlist(trim, "i Touring", "s Touring", "MAZDASPEED3 Touring")
replace trim = "Sport" if make == "Mazda" & inlist(trim, "i Sport", "s Sport")
replace trim = "Grand Touring" if make == "Mazda" & inlist(trim, "i Grand Touring", "s Grand Touring")
// Honda
replace trim = "EX-L" if make == "Honda" & regexm(trim, "EX-L")
replace trim = "Sport" if make == "Honda" & trim == "Sport w/Honda Sensing"
replace trim = "EX" if make == "Honda" & trim == "EX w/Honda Sensing"
replace trim = "LX" if make == "Honda" & trim == "LX w/Honda Sensing"
// Nissan
replace trim = "2.5 S" if make == "Nissan" & trim == "2.5 S (2017.5)"
replace trim = "2.5 SV" if make == "Nissan" & trim == "2.5 SV (2017.5)"
replace trim = "SV" if make == "Nissan" & trim == "SV (2017.5)"
// Kia
replace trim = "Soul" if make == "Kia" & model == "Soul"
// Hyundai
replace trim = "Limited" if make == "Hyundai" & trim == "Limited 2.0T"
replace trim = "Sport" if make == "Hyundai" & trim == "Sport 2.0T"

export delimited using carvana_clean.csv, replace
