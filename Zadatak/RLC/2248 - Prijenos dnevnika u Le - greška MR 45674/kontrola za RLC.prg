*****************************************
** 21.10.2020 g_tomislav MID 45674 - created based on g_branisl; MID:41697; 
** Univerzalna kontrola postojanja sheme knjiženja za odabran način leasinga ugovora i vrstu potraživanja

local lCid_terj, lCnacin_leas, lcSql, lnRecno, ln_imaM, ln_imaN

lCid_terj = allt(Fakture.id_terj)

lCnacin_leas = allt(GF_LOOKUP("pogodba.nacin_leas",fakture.id_cont,"pogodba.id_cont"))

TEXT TO lcSql NOSHOW

DECLARE @id_terj char(2)
DECLARE @nacin_leas char(2)

SET @id_terj = '{1}'
SET @nacin_leas = '{2}';

Select --test.* 
Isnull(kn_konto, vr_konto) as konto,
Isnull(kn_protikonto, vr_protikonto) as protikonto,
DELI_TERJATVE
From (

		Select pk.*
		/*
		,'I' as granica1,
		kn1.*,
		'I' as granica2,
		kn2.*,
		'I' as granica3
		*/
		,kn1.KONTO as kn_konto
		,kn2.KONTO as kn_protikonto
		, ak1.konto as vr_konto
		, ak2.konto as vr_protikonto

		From dbo.PLAN_KNJ pk
		Left Join dbo.VRST_TER vr on @id_terj = vr.id_terj
		Left Join dbo.KONTI_NL kn1 on CASE WHEN pk.konto <> '$KTERJA' THEN pk.konto ELSE vr.konto END = kn1.ID_KONTA
		Left Join dbo.KONTI_NL kn2 on CASE WHEN pk.PROTIKONTO <> '$PKTERJA' THEN pk.PROTIKONTO ELSE vr.protikonto END = kn2.ID_KONTA
		Left Join dbo.AKONPLAN ak1 on vr.konto = ak1.KONTO
		Left Join dbo.AKONPLAN ak2 on vr.protikonto = ak2.KONTO
		Where pk.ID_DOGODKA = 'ZAPADE_OST' AND pk.AKT_STORNO = '#'
		AND ISNULL(pk.ID_TERJ, @id_terj) = @id_terj
		AND ISNULL(kn1.nacin_leas, @nacin_leas) = @nacin_leas
		AND ISNULL(kn2.nacin_leas, @nacin_leas) = @nacin_leas

) test
where COALESCE(kn_konto, vr_konto) is not null and COALESCE(kn_protikonto, vr_protikonto) is not null

ENDTEXT

lcSql = STRTRAN(STRTRAN(lcSql, "{1}", lCid_terj), "{2}", lCnacin_leas)

GF_SQLExec(lcSql,"_shema")

*MOŽDA PROŠIRITI KONTROLU NA SAMO AKTIVNA KONTA
ln_imaN = 0
ln_imaM = 0

COUNT TO ln_imaN  FOR  ATC('N',DELI_TERJATVE)>0
COUNT TO ln_imaM  FOR  ATC('M',DELI_TERJATVE)>0


IF ln_imaN = 0 OR ln_imaM = 0 THEN
	REPLACE ni_napaka WITH .F. IN cur_extfunc_error
	POZOR("Za odabrano potraživanje ("+lCid_terj+") ne postoji shema knjiženja za tip ugovora "+lCnacin_leas+"!")
ENDIF
* KRAJ MR 45674
************************************************************************