loForm = GF_GetFormObject("REPRO_SELECT")
IF ISNULL(loForm) THEN 
	RETURN
ENDIF

****************************************************************************
* 02.03.2018. g_tomislav; MR 39782 izrada
IF loform.repro_type == "1" && 2 - Automatic, 1 - MANUAL
	IF INLIST(ReprogramPogodba.nacin_leas, "OR", "OF") AND POTRJENO("Da li radite prijevremeni otkup?")
		loForm.cnt_Status.cboId_rep_category.Value = "011"
	ENDIF
ENDIF
****************************************************************************




source_table

ReprogramPogodba




* Kreirao kategoriju reprograma 011



*obvesti("REPRO_SELECT_ID_POG_VALID")

*obvesti (trans(loform.repro_type)+gce+"2 THEN  Automatic else 1 - MANUAL")


*select * from ReprogramPogodba

loForm.cnt_Status.cboId_rep_category.Value = "002"

b) 
5) Samo ručni reprogram - za OF i OR 
GMC: s obzirom da može biti različitih reprograma (ne samo onih vezanih na prijevremeni otkup), predlažemo da se u onda slučaju ručnog reprograma za OF i OR u koraku unosa broja ugovora, prikaže pitanje "da li radite prijevremeni otkup", i onda na odgovor DA podesimo postavljanje posebne kategorije. Tada prilikom klika na gumb 'F3 - Novi zapis', da se na masci automatski podesi potraživanje na 23 (korisniku bi se odmah ponudilo ispravno potraživanje). 
RLHR: Ok, slažemo se s prijedlogom

GMC 13.2.2018: ok. 