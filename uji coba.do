use "C:\Users\LENOVO\Downloads\data.dta",clear

describe

**## DV
label var payAmt "Payment Amt"
label var l_payAmt "Log(Payment Amt)"
label var payAmtAvg "Payment Amt Avg"
label var l_payAmtAvg "Log(Payment Amt Avg)"

**## IV
label var bscRepetition "BSC Repetition"

**## Controls
label var bscNum "BSC Num"
label var l_bscNum "Log(BSC Num)"
label var viewNum "View Num"
label var l_viewNum "Log(View Num)"
label var senPos "Sen Positive"
label var senNeg "Sen Negative"
label var sessDuration "Sess Duration"
label var l_sessDuration "Log(Sess Duration)"

label var prodNum "Prod Num"
label var l_prodNum "Log(Prod Num)"
label var prodVariety "Prod Variety"
label var prodPriceAvg "Prod Price Avg"
label var l_prodPriceAvg "Log(Prod Price Avg)"
label var prodDiscountAvg "Prod Discount Avg"

label var invlHour "Invl Hour"
label var invl "Invl"

reghdfe l_payAmtAvg bscRepetition l_bscNum l_viewNum sen* c.invl##c.invl i.invlHour, absorb(storesessid)

estadd local Session_FE "Yes", replace
estadd local Store_FE "No", replace
estadd local Date_FE "No", replace
est store r_1

gen start_date = date(sessStartDate, "YMD")
format start_date %td

reghdfe l_payAmtAvg bscRepetition l_bscNum l_viewNum sen* c.invl##c.invl i.invlHour l_sessDuration prodNum prodVariety l_prodPriceAvg prodDiscountAvg, absorb(storeId start_date)

estadd local Session_FE "No", replace
estadd local Store_FE "Yes", replace
estadd local Date_FE "Yes", replace
est store r_2

esttab r_*, b(%5.3f) p(%5.3f) stats(Session_FE Store_FE Date_FE N r2 r2_a, fmt(%3s %3s %3s %12.0f %10.3f %10.3f)) star(* 0.1 ** 0.05 *** 0.01) sfmt(%10.3f) label
esttab r_* using hipotesa1.rtf, b(%5.3f) p(%5.3f) stats(Session_FE Store_FE Date_FE N r2 r2_a, fmt(%3s %3s %3s %12.0f %10.3f %10.3f)) star(* 0.1 ** 0.05 *** 0.01) sfmt(%10.3f) label replace


**# Summary.rtf
**## interval-level
tabstat payAmtAvg bscRepetition bscNum viewNum sen* invlHour if bscRepetition != ., statistics(N mean sd min median max) columns(statistics) format(%20.3f)
outreg2 using "Summary interval level.rtf", replace ctitle("Interval-level Statistics") stats(N mean sd min median max) keep(payAmtAvg bscRepetition bscNum viewNum sen* invlHour) dec(3)

**## session-level
sort storesessid invl
by storesessid: gen obsN = _n 

tabstat sessDuration prodNum prodVariety prodPriceAvg prodDiscountAvg if obsN == 1, statistics(N mean sd min median max) columns(statistics) format(%20.3f)
outreg2 using "Summary session level.rtf", append ctitle("Session-level Statistics") stats(N mean sd min median max) keep(sessDuration prodNum prodVariety prodPriceAvg prodDiscountAvg) dec(3)

sort storesessid invl
by storesessid: gen obsN = _n 

tabstat coo, statistics(N mean sd min max median) columns(statistics) format(%20.3f)
tabstat fami_rating, statistics(N mean sd min max median) columns(statistics) format(%20.3f)


**# Robustness.rtf
**## R1: DV: Payment Amt

reghdfe l_payAmt bscRepetition l_bscNum l_viewNum sen* c.invl##c.invl i.invlHour, absorb(storesessid)
estadd local Session_FE "Yes", replace
estadd local Store_FE "No", replace
estadd local Date_FE "No", replace
est store r_1

reghdfe l_payAmt bscRepetition l_bscNum l_viewNum sen* c.invl##c.invl i.invlHour l_sessDuration prodNum prodVariety l_prodPriceAvg prodDiscountAv, absorb(storeid start_date)
estadd local Session_FE "No", replace
estadd local Store_FE "Yes", replace
estadd local Date_FE "Yes", replace
est store r_2

esttab r_*, b(%5.3f) p(%5.3f) stats(Session_FE Store_FE Date_FE N r2 r2_a, fmt(%3s %3s %3s %12.0f %10.3f %10.3f)) star(* 0.1 ** 0.05 *** 0.01) sfmt(%10.3f) label
esttab r_* using robust1.1.rtf, b(%5.3f) p(%5.3f) stats(Session_FE Store_FE Date_FE N r2 r2_a, fmt(%3s %3s %3s %12.0f %10.3f %10.3f)) star(* 0.1 ** 0.05 *** 0.01) sfmt(%10.3f) label replace


**## R3: use tf instead of tf-idf
gen bscRepetitionTfnum = real(bscrepetitiontf_stop)
label var bscRepetitionTfnum "BSC Repetition (tf)"


reghdfe l_payAmtAvg bscRepetitionTf l_bscNum l_viewNum sen* l_sessDuration prodNum prodVariety l_prodPriceAvg prodDiscountAvg, absorb(storeid sessstartdate)
estadd local Session_FE "No", replace
estadd local Store_FE "Yes", replace
estadd local Date_FE "Yes", replace
est store r_2

esttab r_*, b(%5.3f) p(%5.3f) stats(Session_FE Store_FE Date_FE N r2 r2_a, fmt(%3s %3s %3s %12.0f %10.3f %10.3f)) star(* 0.1 ** 0.05 *** 0.01) sfmt(%10.3f) label
esttab r_* using robust2.1.rtf, b(%5.3f) p(%5.3f) stats(Session_FE Store_FE Date_FE N r2 r2_a, fmt(%3s %3s %3s %12.0f %10.3f %10.3f)) star(* 0.1 ** 0.05 *** 0.01) sfmt(%10.3f) label replace


**## R4: without stopwords filtering
gen bscRepetitionWStop = real(bscrepetitiontfidf)
label var bscRepetitionWStop "BSC Repetition (w/ stopwords)"

reghdfe l_payAmtAvg bscRepetitionWStop l_bscNum l_viewNum sen* c.invl##c.invl i.invlHour, absorb(storesessid)
estadd local Session_FE "Yes", replace
estadd local Store_FE "No", replace
estadd local Date_FE "No", replace
est store r_1

reghdfe l_payAmtAvg bscRepetitionWStop l_bscNum l_viewNum sen* c.invl##c.invl i.invlHour l_sessDuration prodNum prodVariety l_prodPriceAvg prodDiscountAvg, absorb(storeid sessstartdate)
estadd local Session_FE "No", replace
estadd local Store_FE "Yes", replace
estadd local Date_FE "Yes", replace
est store r_2

esttab r_*, b(%5.3f) p(%5.3f) stats(Session_FE Store_FE Date_FE N r2 r2_a, fmt(%3s %3s %3s %12.0f %10.3f %10.3f)) star(* 0.1 ** 0.05 *** 0.01) sfmt(%10.3f) label
esttab r_* using robust3.1.rtf, b(%5.3f) p(%5.3f) stats(Session_FE Store_FE Date_FE N r2 r2_a, fmt(%3s %3s %3s %12.0f %10.3f %10.3f)) star(* 0.1 ** 0.05 *** 0.01) sfmt(%10.3f) label replace

**# Moderation.rtf
import delimited "data 1.2.csv", clear
// DV
gen payAmt = salesamt5min
label var payAmt "Payment Amt"

gen l_payAmt = log(1 + payAmt)
label var l_payAmt "Log(Payment Amt)"

gen payAmtAvg = salesamt5min / viewsnum5min
label var payAmtAvg "Payment Amt Avg"

gen l_payAmtAvg = log(1 + payAmtAvg)
label var l_payAmtAvg "Log(Payment Amt Avg)"

// IV
gen bscRepetition = bscrepetitiontfidf_stop
label var bscRepetition "BSC Repetition"

// Controls
gen bscNum = bscnum
label var bscNum "BSC Num"
gen l_bscNum = log(1 + bscNum)
label var l_bscNum "Log(BSC Num)"

gen viewNum = viewsnum5min
label var viewNum "View Num"
gen l_viewNum = log(1 + viewsnum5min)
label var l_viewNum "Log(View Num)"

gen senPos = positivenum / bscnum
label var senPos "Sen Positive"
gen senNeg = negativenum / bscnum
label var senNeg "Sen Negative"

gen sessDuration = sessduration
label var sessDuration "Sess Duration"
gen l_sessDuration = log(1 + sessDuration)
label var l_sessDuration "Log(Sess Duration)"

gen prodNum = prodnum
label var prodNum "Prod Num"
gen l_prodNum = log(1 + prodNum)
label var l_prodNum "Log(Prod Num)"

gen prodVariety = prodvariety_tf
label var prodVariety "Prod Variety"

gen prodPriceAvg = prodpriceavg
label var prodPriceAvg "Prod Price Avg"
gen l_prodPriceAvg = log(1 + prodpriceavg)
label var l_prodPriceAvg "Log(Prod Price Avg)"

gen prodDiscountAvg = proddiscountavg
label var prodDiscountAvg "Prod Discount Avg"

gen invlHour = invlstarthour
label var invlHour "Invl Hour"

gen invl = invlno5min
label var invl "Invl"

**## Coo
gen bscRepetitionnum = real(bscRepetition)
**# model 1
reghdfe l_payAmtAvg c.bscRepetitionnum##c.coo l_bscNum l_viewNum sen* c.invl##c.invl i.invlHour, absorb(sessstartdate)
estadd local Session_FE "No", replace
estadd local Store_FE "No", replace
estadd local Date_FE "Yes", replace
est store r_1

esttab r_*, b(%5.3f) p(%5.3f) stats(Session_FE Store_FE Date_FE N r2 r2_a, fmt(%3s %3s %3s %12.0f %10.3f %10.3f)) star(* 0.1 ** 0.05 *** 0.01) sfmt(%10.3f) label
esttab r_* using moderation1.1.rtf, b(%5.3f) p(%5.3f) stats(Session_FE Store_FE Date_FE N r2 r2_a, fmt(%3s %3s %3s %12.0f %10.3f %10.3f)) star(* 0.1 ** 0.05 *** 0.01) sfmt(%10.3f) label replace


**## Brand Familiarity
// model 1
reghdfe l_payAmtAvg c.bscRepetitionnum##c.fami_rating l_bscNum l_viewNum c.invl##c.invl i.invlHour, absorb(sessstartdate)
estadd local Session_FE "No", replace
estadd local Store_FE "No", replace
estadd local Date_FE "Yes", replace
est store r_2

esttab r_*, b(%5.3f) p(%5.3f) stats(Session_FE Store_FE Date_FE N r2 r2_a, fmt(%3s %3s %3s %12.0f %10.3f %10.3f)) star(* 0.1 ** 0.05 *** 0.01) sfmt(%10.3f) label
esttab r_* using moderation2.rtf, b(%5.3f) p(%5.3f) stats(Session_FE Store_FE Date_FE N r2 r2_a, fmt(%3s %3s %3s %12.0f %10.3f %10.3f)) star(* 0.1 ** 0.05 *** 0.01) sfmt(%10.3f) label replace
