loForm = GF_GetFormObject("frmRepro_maska")
IF ISNULL(loForm) THEN 
	RETURN
ENDIF

****************************************************************************
* 02.03.2018. g_tomislav MR 39782 - izrada
* thisform.source_table = pnSource  && 1 - ReprogramNew, 2 - ReprogramCosts
IF loForm.source_table = 1 AND loForm.tip_vnosne_maske = 1 && Samo Novi zapis
	
	LOCAL lcId_rep_category
	lcId_rep_category = loForm.ParentForm.cnt_status.cboId_rep_category.Value
		
	IF INLIST(ReprogramPogodba.nacin_leas, "OR", "OF") AND  lcId_rep_category = "011"
		LOCAL lcIdTerj, llFirst
		llFirst = .T.
		SELECT _vrstterj
		LOCATE FOR _vrstterj.sif_terj = "OPC"
		IF FOUND()
			lcIdTerj = _vrstterj.id_terj
			llFirst = .F.
			loForm.cmbTerjatev.Value = lcIdTerj
		ENDIF

		&& Ako ne može odabrati OPC, javi poruku
		IF llFirst
			POZOR("Potraživanje za otkup se ne nalazi na listi te ga nije moguće automatski odabrati!") &&Thisform.cmbTerjatev.ListItemId = 1
		ENDIF
	ENDIF
ENDIF
****************************************************************************




ldRepNaDan = Thisform.ParentForm.cnt_status.txtRepNaDan.Value



IF Thisform.source_table = 1 THEN 
	LOCAL lcIdTerj
	SELECT _vrstterj
	LOCATE FOR _vrstterj.sif_terj = "LOBR"
	IF FOUND()
		lcIdTerj = _vrstterj.id_terj
		llFirst = .F.
		Thisform.cmbTerjatev.Value = lcIdTerj
	ENDIF
ENDIF
&& Če ni izbran LOBR, se izbere prvi
IF llFirst
	Thisform.cmbTerjatev.ListItemId = 1
ENDIF







"5) Samo ručni reprogram - za OF i OR 
GMC: s obzirom da može biti različitih reprograma (ne samo onih vezanih na prijevremeni otkup), predlažemo da se u onda slučaju ručnog reprograma za OF i OR u koraku unosa broja ugovora, prikaže pitanje "da li radite prijevremeni otkup", i onda na odgovor DA podesimo postavljanje posebne kategorije. Tada prilikom klika na gumb 'F3 - Novi zapis', da se na masci automatski podesi potraživanje na 23 (korisniku bi se odmah ponudilo ispravno potraživanje). 
RLHR: Ok, slažemo se s prijedlogom"





*thisform.tip_vnosne_maske = pnTip
*thisform.source_table = pnSource  && 1 - ReprogramNew, 2 - ReprogramCosts
obvesti(trans(loForm.tip_vnosne_maske))
obvesti(trans(loForm.source_table))
Popravljeni plan otplate: source_table = 1
novi zapis tip_vnosne_maske = 1
popravak tip_vnosne_maske = 2 

Dodatni troškovi: source_table = 2
novi zapis tip_vnosne_maske = 1
popravak tip_vnosne_maske = 2 
