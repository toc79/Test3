** Created - unknown
** 11.08.2021 g_tomislav MID 47311 - bugfix: txtst_fakture and txtnabav_vred can not be null
** 15.10.20221 g_tomislav MID 47311 - added ROUND on txtstopnja_am. Added calculation for OF leasing type for KREDIT_NETO. Added order by e.id_rac_in

local lcSql, lcId_pog, lcSql2, lnNabVred, lnVarOpc

&& KURSOR SA POTREBNIM INFORMACIJAMA IZ UGOVOR, VRSTE OPREME, PARTNER, GK - URA
lcId_Pog = fa_dnev_maska.txtid_pog.Value

TEXT TO lcSql NOSHOW

SELECT --A.ID_CONT, A.ID_VRSTE, A.ID_KUPCA, 
	--dbo.GFN_XCHANGE('000', A.OPCIJA, A.ID_TEC, A.DAT_SKLEN) AS OPCIJA1, 
	--dbo.GFN_XCHANGE('000', A.VARSCINA, A.ID_TEC, A.DAT_SKLEN) AS VARSCINA1,
	--CAST(A.OPCIJA*A.PO_TECAJU AS DECIMAL (18,2)) AS OPCIJA2, 
	--B.NAZIV, ISNULL(F.KONTO,'99999') AS KONTO,  
	A.TRAJ_NAJ,
	CAST(ISNULL(PP.NETO,0)*A.PO_TECAJU AS DECIMAL(18,2)) AS OPCIJA3,
	CAST(A.VARSCINA*A.PO_TECAJU AS DECIMAL(18,2)) AS VARSCINA2,
	B.ID_GRUPE, C.NAZ_KR_KUP, D.ID_NOMEN AS NOMENKLATURA, 
	E.DDV_ID, E.DATUM, 
	case when a.nacin_leas = 'OF' then isnull(of1.sum_kredit_dom, 0) else E.KREDIT_NETO end AS KREDIT_NETO, 
	ISNULL(G.ID_KNJIZBE,'XXX') AS ID_KNJIZBE,
	CASE 
		WHEN A.TRAJ_NAJ BETWEEN 0 AND 5 THEN 1
		WHEN A.TRAJ_NAJ BETWEEN 6 AND 11 THEN 6
		WHEN A.TRAJ_NAJ BETWEEN 12 AND 23 THEN 12
		WHEN A.TRAJ_NAJ BETWEEN 24 AND 35 THEN 24
		WHEN A.TRAJ_NAJ BETWEEN 36 AND 47 THEN 36
		WHEN A.TRAJ_NAJ BETWEEN 48 AND 59 THEN 48
		WHEN A.TRAJ_NAJ = 60 THEN 60
		WHEN A.TRAJ_NAJ BETWEEN 61 AND 180 THEN 61
		ELSE 999
	END AS BUCKET
FROM POGODBA A
INNER JOIN VRST_OPR B ON A.ID_VRSTE = B.ID_VRSTE
INNER JOIN PARTNER C ON A.ID_KUPCA = C.ID_KUPCA
LEFT JOIN FA_NOMENKL D ON B.ID_GRUPE = D.OZNAKA1
LEFT JOIN RAC_IN E ON A.ID_CONT = E.ID_CONT
LEFT JOIN GL F ON E.DDV_ID = F.ST_DOK AND E.KREDIT_NETO = F.DEBIT_DOM
LEFT JOIN FA_KONTI_VK G ON F.KONTO = G.KONTO
LEFT JOIN (Select id_cont, neto, robresti 
		From PLANP a
		INNER JOIN VRST_TER VT ON a.ID_TERJ = VT.id_terj AND VT.sif_terj = 'OPC') PP ON a.ID_CONT = PP.ID_CONT
outer apply (select sum(kredit_dom) as sum_kredit_dom from dbo.lsk where konto = '500101' and vrsta_dok = 'AKT' and id_cont = a.id_cont) of1 
WHERE A.ID_CONT = dbo.GFN_ID_CONT4ID_POG({0})
order by e.id_rac_in -- there can be more than one incoming invoice 

ENDTEXT

lcSql = STRTRAN(lcSql, '{0}', "'"+lcId_Pog+"'")
GF_SqlExec(lcSql,"_Pogodba")


&& KURSOR SA ODGOVARAJUĆIM POSTOTOKOM (DEFINIRANA TABELA OD STRANE RLC KOJA SE NALAZI U GENERAL_REGISTER)
&& ULAZNI PARAMETRI SU: 1. POGODBA.ID_GRUPE, 2. POGODBA.TRAJ_NAJ
&& NA TEMELJU ULAZNIH PARAMETARA ODREĐUJE SE "BUCKET" KOJEM PRIPRADA UGOVOR
&& SVAKI BUCKET SADRŽI POSTOTAK KOJI SE KORISTI ZA IZRAČUNE, IZUZETAK SU BUCKETI KOJI NISU DEFINIRANI VRIJDNOŠĆU ILI UG. KOJI PRELAZE 180 MJ.

TEXT TO lcSql2 NOSHOW
SELECT ID_KEY AS BUCKET, VALUE AS GRUPA, VAL_NUM AS FA_OPC,VAL_CHAR AS BUCKET_ID FROM GENERAL_REGISTER WHERE ID_REGISTER = 'FA_OPC_MAP' AND NEAKTIVEN = 0 AND VALUE = '{0}' AND CAST(VAL_CHAR AS INT) = {1}
ENDTEXT

lcSql2 = STRTRAN(lcSql2, '{1}', allt(trans(_pogodba.bucket)))
lcSql2 = STRTRAN(lcSql2, '{0}', _pogodba.id_grupe)

GF_SqlExec(lcSql2,"_FA_PARAM")

IF RECCOUNT("_FA_PARAM") = 0
	APPEND BLANK IN _FA_PARAM
ENDIF

&& POPUNJAVANJE PODATAKA NA FORMI 
fa_dnev_maska.txtnaziv2.Value = _pogodba.naz_kr_kup
fa_dnev_maska.txtid_nomen.Value = _pogodba.nomenklatura
fa_dnev_maska.txtid_grupe.Value = _pogodba.id_grupe
fa_dnev_maska.txtid_sobe.Value = '00001'
fa_dnev_maska.txtstopnja_am.Value = ROUND(100/(_pogodba.traj_naj/12), 2)
fa_dnev_maska.txtid_knjizbe.Value = _pogodba.id_knjizbe
fa_dnev_maska.txtid_AMOR_SK.Value = _pogodba.id_grupe
fa_dnev_maska.txtst_fakture.Value = NVL(_pogodba.ddv_id, "")
fa_dnev_maska.txtnabav_vred.Value = NVL(_pogodba.kredit_neto, 0)

&& IZRAČUN PODATAKA NA TEMLJU PODATAKA DOBIVENIH U PRIPREMI
lnNabVred = fa_dnev_maska.txtnabav_vred.Value
lnVarOpc = _pogodba.opcija3+_pogodba.varscina2
lnNeAVred = (lnNabVred*_FA_PARAM.FA_OPC)/100

IF _FA_PARAM.FA_OPC = 999.99 OR EMPTY(_FA_PARAM.FA_OPC) OR ISNULL(_FA_PARAM.FA_OPC) THEN
	lnAmOsn = lnNabVred-lnVarOpc
	lnAmoSt = 100/(_pogodba.traj_naj/12)
	lnznesek = lnAmOsn*lnAmoSt/100
	lnAmInt = lnznesek/lnNabVred*100

	fa_dnev_maska.txtst_amint.Value = lnAmInt
	fa_dnev_maska.txtneam_vred.Value = lnVarOpc
ELSE
	lnAmOsn = lnNabVred-lnNeAVred
	lnAmoSt = 100/(_pogodba.traj_naj/12)
	
	fa_dnev_maska.txtst_amint.Value = (lnAmOsn*(lnAmoSt/100))/(lnNabVred/100)
	fa_dnev_maska.txtneam_vred.Value = lnNeAVred
ENDIF

&& ODREĐIVANJE POČETKA AMORTIZACIJE
IF MONT(_Pogodba.DATUM) < 12 THEN
	LcZacAmo = TRANS(YEAR(_Pogodba.DATUM))+'/'+TRANS(MONT(_Pogodba.DATUM)+1)
ELSE
	lcZacAmo = TRANS(YEAR(_Pogodba.DATUM)+1)+'/01'
ENDIF

IF LEN(ALLTRIM(lcZacAmo)) = 6 AND VAL(SUBSTR(lcZacAmo, 6, 1)) < 10
	lcZacAmo = SUBSTR(lcZacAmo, 1, 4) + '/0' + SUBSTR(lcZacAmo, 6, 1)
ENDIF 

fa_dnev_maska.txtzac_amort.Value = lcZacAmo

lnMaxProc = GF_LOOKUP('FA_AMOR_SK.ST_AMINT',fa_dnev_maska.txtid_AMOR_SK.Value,'FA_AMOR_SK.ID_AMOR_SK')

IF fa_dnev_maska.txtst_amint.Value > lnMaxProc THEN
	POZOR("INTERNA AMORTIZACIJSKA STOPA JE VEĆA OD ZAKONSKI DOZVOLJENE STOPE !! ("+ALLT(TRANS(lnMaxProc,GCCIF))+"%)")
	fa_dnev_maska.txtst_amint.SetFocus
ENDIF