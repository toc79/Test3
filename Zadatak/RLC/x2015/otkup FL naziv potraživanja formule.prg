Molim Vas da nas pismenim putem obavijestite da li prihvaćate opciju kupnje objekta leasinga čija otkupna vrijednost iznosi (iznos treba povući iz otplatnog plana) čime ostvarujete pravo na stjecanje vlasništva nad objektom leasinga, a nakon podmirenja otkupne vrijednosti i ispunjenja svih ugovorenih uvjeta kako je u ugovoru definirano. 
Opciju kupnje:	1. Prihvaćam 
                2. Ne prihvaćam         

Datum _____________ 

Pečat i potpis primatelja leasinga. 

Ispunjeni dopis molim vratiti na fax 01/6595-050 ili putem maila leasing.vodjenje@rl-hr.hr



LcList_condition=""
lcListaUg = GF_CreateDelimitedList("odgnaopc", "id_cont", LcList_condition, ",",.F.)

GF_SQLEXEC("SELECT a.id_cont, dbo.gfn_GetOpcSt_dok(a.id_cont,a.nacin_leas) as OpcSt_dok, b.DEBIT FROM dbo.pogodba a LEFT JOIN dbo.planp b ON a.id_cont=b.id_cont AND dbo.gfn_GetOpcSt_dok(a.id_cont,a.nacin_leas)=b.st_dok WHERE a.id_cont in ("+lcListaUg+")","_cb_opcija")

LcList_condition=""  && Mora biti 
GF_CreateDelimitedList("za_pz", "id_za_pz", LcList_condition, ",",.t.) --SA NAVODNICIMA provjereno na primjeru i u kodu








allt(trans(NLV(look(_cb_opcija.debit,odgnaopc.id_cont,_cb_opcija.id_cont),0),gccif))+' '+allt(NLV(look(_cb_opcija.id_val,odgnaopc.id_cont,_cb_opcija.id_cont),''))

" čime ostvarujete pravo na stjecanje vlasništva nad objektom leasinga, a nakon podmirenja otkupne vrijednosti i ispunjenja svih ugovorenih uvjeta kako je u ugovoru definirano."+chr(13)+"Opciju kupnje:"+chr(9)+"1. Prihvaćam"+chr(13)
+
chr(9)+chr(9)+chr(9)+chr(9)+"2. Ne prihvaćam"+chr(13)+chr(13)+"Datum ______________"+chr(13)+chr(13)+"Pečat i potpis primatelja leasinga."+chr(13)+chr(13)+"Ispunjeni dopis molim vratiti na fax 01/6595-050 ili putem maila leasing.vodjenje@rl-hr.hr"

chr(9)+chr(9)+chr(9)+chr(9)+"2. Ne prihvaćam"+chr(13)+chr(13)+"Datum ______________"+chr(13)+chr(13)+"Pečat i potpis primatelja leasinga."+chr(13)+chr(13)+"Ispunjeni dopis molim vratiti na fax "+allt(gobj_settings.GetVal("p_fax"))
+
" ili putem maila leasing.vodjenje@rl-hr.hr"


DECLARE @datum datetime
SET @datum = getdate()
	
SELECT a.ID_CONT, a.DAT_ZAP, a.ID_KUPCA, a.ID_TERJ, a.ZAP_OBR, a.ST_DOK, a.ROBRESTI, a.REGIST, 
	dbo.gfn_xchange('000', a.MARZA, a.ID_TEC,a.DAT_PRIP) AS MARZA_DOM, 
	dbo.gfn_xchange('000', a.DAVEK, a.ID_TEC,a.DAT_PRIP) AS DAVEK_DOM,
	dbo.gfn_xchange('000', a.DEBIT, a.ID_TEC,a.DAT_PRIP) AS DEBIT_DOM,
	dbo.gfn_xchange('000', a.OBRESTI, a.ID_TEC,a.DAT_PRIP) AS OBRESTI_DOM,
	dbo.gfn_xchange('000', a.NETO, a.ID_TEC,a.DAT_PRIP) AS NETO_DOM,
	RTRIM(CONVERT(char, DATEADD(mm, DATEDIFF(mm, 0, a.DATUM_DOK), 0), 104)) as dat_poc,
	RTRIM(CONVERT(char, DATEADD(mm, DATEDIFF(mm, -1, a.DATUM_DOK), -1), 104)) as dat_do,
	a.ID_VAL, a.DEBIT,
	a.DAT_PRIP, a.VNESEL, a.IZPISAN, a.OBL_DOP, a.ID_TEC, a.DAV_VRED, a.POLOZNICA, a.DAT_IZPIS, a.SALDO, a.NACIN_LEAS, a.DATUM_DOK, a.VR_OSEBE, a.STATUS_DD,
	a.naziv_terj, a.naz_kr_kup, a.ulica, a.mesto, a.naziv1_kup, a.naziv2_kup, a.dav_stev, a.id_poste, a.polni_naz, a.ulica_sed, a.id_poste_sed, a.mesto_sed, a.emso,  
	a.id_dav_st, a.dat_aktiv, a.id_pog, a.sklic, a.id_strm, a.ddv_id, a.naz_poste, a.st_poste, a.se_regis, a.dolg, a.tecajnica, a.dolg1, a.preplacilo,
	a.str_financ, a.leas_kred, a.tip_knjizenja, a.stev_reg, reg.opis as OPIS, reg.reg_stev as REG_STEV, reg.st_sas as ST_SAS, opr.opis as OPIS1,
	CASE WHEN LEN(RTRIM(a.dav_stev)) = 11 THEN 0 ELSE 1 END AS OIB_NOT_OK,
	CASE WHEN a.VR_OSEBE = 'SP' AND LEN(a.stev_reg)>0 THEN 1 ELSE 0 END AS PRINT_MBO,
	CASE WHEN a.VR_OSEBE NOT IN ('SP','FO') AND LEN(a.emso)>0 AND LEN(a.emso)<13 THEN 1 ELSE 0 END AS PRINT_MB,
	CASE WHEN a.dat_zap <= @datum THEN CAST(a.dolg-a.debit AS DECIMAL(18,2)) ELSE a.dolg END AS PRINT_DOLG,
	CASE WHEN a.datum_dok < '20130101' then 0 else 1 end as PRINT_DDV_HR,
	dbo.gfn_transformDDV_ID_HR(a.ddv_id,pog.dat_aktiv) as Fis_BrRac
	, CASE WHEN a.vr_osebe = 'FO' or a.vr_osebe = 'F1' THEN 1 ELSE 0 END as je_FO
	, ISNULL(dbo.gfn_GetOpcSt_dok(a.id_cont,a.nacin_leas),'0') as PRINT_OPC
	FROM dbo.gft_Print_NoticeForInstallments(getdate()) a
	INNER JOIN dbo.pogodba pog ON a.id_cont = pog.id_cont
	LEFT JOIN dbo.zap_reg reg ON a.id_cont = reg.id_cont
	LEFT JOIN dbo.zap_ner opr ON a.id_cont = opr.id_cont
where a.id_najem_ob=@id


OTKUPNA VRIJEDNOST OBJEKTA LEASINGA

{Format("{0:G2}",najem_ob.ZAP_OBR)}. {IIF(najem_ob.leas_kred=="K" && najem_ob.tip_knjizenja=="2","RATA ZAJMA", 
IIF(najem_ob.leas_kred=="L" && najem_ob.tip_knjizenja=="2","RATA LEASINGA",IIF(najem_ob.PRINT_OPC != "0","OTKUPNA VRIJEDNOST OBJEKTA LEASINGA",najem_ob.naziv_terj.Trim())))} za razdoblje: {Format("{0:dd.MM.yyyy}", najem_ob.dat_poc)}. - {Format("{0:dd.MM.yyyy}", najem_ob.dat_do)}. 

{IIF(najem_ob.PRINT_OPC != "0" && najem_ob.leas_kred == "L" && najem_ob.tip_knjizenja == "2","OTKUPNA VRIJEDNOST OBJEKTA LEASINGA", Format("{0:G2}",najem_ob.ZAP_OBR)+". "+IIF(najem_ob.leas_kred=="K" && najem_ob.tip_knjizenja=="2","RATA ZAJMA", IIF(najem_ob.leas_kred=="L" && najem_ob.tip_knjizenja=="2", "RATA LEASINGA", najem_ob.naziv_terj.Trim()))+" za razdoblje: "+Format("{0:dd.MM.yyyy}", najem_ob.dat_poc)+". - "+Format("{0:dd.MM.yyyy}", najem_ob.dat_do)+".")}
