LOCAL lcSql, lcZn_prednos

loForm = GF_GetFormObject("frmdokument_vsi")
IF ISNULL(loForm) THEN
	RETURN 
ENDIF

local lcList_Condition, listId_cont
LcList_condition = ""
listId_cont = GF_CreateDelimitedList("rezultat", "id_cont", LcList_condition, ",",.f.)

GF_SQLEXEC("select id_cont, dat_sklen from pogodba where id_cont in ("+iif(len(alltrim(listId_cont ))=0,"0",listId_cont )+")","_pog_sklen")

select a.id_dokum, a.id_obl_zav, a.dat_aktiv, a.id_vrste, a.id_hipot, a.vrednost, a.zn_prednos, a.ocen_vred, a.status_akt ;
, a.velja_do,a.dat_korig_vred,a.kategorija1,b.dat_sklen,000000000000000.00 as KORIG_VRED ;
from rezultat a left join _pog_sklen b on a.id_cont=b.id_cont into cursor rezultat2 READWRITE ;

select rezultat2
scan

* resaled assets
IF rezultat2.velja_do <= DATE()
	LOOP
ENDIF

IF INLIST(rezultat2.id_obl_zav, "H1", "H2", "H4", "H6", "HL", "IE") THEN
	lcZn_prednos=NVL(rezultat2.zn_prednos,0)
	IF EMPTY(rezultat2.id_hipot) OR ISNULL(rezultat2.id_hipot)
		REPLACE rezultat2.KORIG_VRED WITH NVL(round(rezultat2.vrednost - lcZn_prednos, 2),0)
	ELSE
		TEXT TO lcSql NOSHOW
			SELECT dbo.gfn_GetValueTableFactor('{0}', GETDATE(), null, '{1}', 2) as si
		ENDTEXT

		lcSql = STRTRAN(lcSql, "{0}", DTOS(IIF(ISNULL(rezultat2.dat_korig_vred), (IIF(ISNULL(rezultat2.dat_aktiv), rezultat2.dat_sklen, rezultat2.dat_aktiv)), rezultat2.dat_korig_vred)))
		lcSql = STRTRAN(lcSql, "{1}", IIF(EMPTY(rezultat2.id_hipot), "null", ALLTRIM(rezultat2.id_hipot)))
		GF_SQLEXEC(lcSql, "korig_hipot")
		
		REPLACE rezultat2.KORIG_VRED WITH NVL(round((rezultat2.vrednost * korig_hipot.si) / 100 - lcZn_prednos, 2),0)
	ENDIF

	IF rezultat2.KORIG_VRED < 0 THEN
		REPLACE rezultat2.KORIG_VRED WITH 0
	ENDIF
ENDIF

* prevzete pogodbe (rezultat2 TV)
IF (rezultat2.id_obl_zav = "TV" AND rezultat2.kategorija1 = 'PU') THEN
	TEXT TO lcSql NOSHOW
		SELECT dbo.gfn_GetValueTableFactor('{0}', GETDATE(), '{1}', null, 2) as si
	ENDTEXT
	
	lcSql = STRTRAN(lcSql, "{0}", DTOS(IIF(ISNULL(rezultat2.dat_korig_vred), (IIF(ISNULL(rezultat2.dat_aktiv), rezultat2.dat_sklen, rezultat2.dat_aktiv)), rezultat2.dat_korig_vred)))
	lcSql = STRTRAN(lcSql, "{1}", rezultat2.id_vrste)
	GF_SQLEXEC(lcSql, "korig_tv")
	
	REPLACE rezultat2.KORIG_VRED WITH NVL(round((rezultat2.vrednost * korig_tv.si) / 100, 2),0)
ENDIF

* ostali dokumenti
IF !(INLIST(rezultat2.id_obl_zav, "H1", "H2", "H4", "H6", "HL", "IE") OR (rezultat2.id_obl_zav = "TV" AND rezultat2.kategorija1 = 'PU')) THEN
	lcOcen_vred=NVL(rezultat2.ocen_vred,0)
	REPLACE rezultat2.KORIG_VRED WITH lcOcen_vred
ENDIF

ENDSCAN

GF_AddColumnsToGrid("frmdokument_vsi", "BGridResult", "Korigirana vrijednost", "trans(LOOK(REZULTAT2.korig_vred,REZULTAT.ID_DOKUM,REZULTAT2.ID_DOKUM),gccif)", 130 , "")