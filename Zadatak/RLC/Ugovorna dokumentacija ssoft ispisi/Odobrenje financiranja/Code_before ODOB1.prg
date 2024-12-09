GF_SQLExec("select * from dbo.ponudba where id_pon="+gf_quotedstr(allt(transf(result.id_pon))),"_ponuda")

GF_SQLExec("select * from dbo.partner where id_kupca="+gf_quotedstr(allt(transf(result.id_kupca))),"_partner")

GF_SQLExec("select datum_bil, prihodki, kapital, opis_kapital, id_tec_bil, fprihodki, ap_max, odhodki from dbo.p_bilanc where id_kupca="+gf_quotedstr(allt(transf(result.id_kupca)))+" order by datum_bil DESC","_bilans")

GF_SQLExec("select *, CASE ISNUMERIC(odobrit.boniteta) WHEN 0 THEN 0 ELSE round(cast(odobrit.boniteta as decimal),0) end as bondec from dbo.odobrit where id_doc="+gf_quotedstr(allt(transf(result.id_doc))),"_odobrit")

GF_SQLExec("select id_frame,isnull(velja_do,'') as velja_do, isnull(dat_izteka,'') as dat_izteka from dbo.frame_list where id_frame="+gf_quotedstr(allt(transf(result.id_frame))),"cur_frame_list")

*************************************************
* povlačenje osiguranja u Memo polje
* by Vilko

LOCAL lcSql, lnId_odobrit
lnId_odobrit = result.id_odobrit
*pamćenje trenutnog odobrenja

TEXT TO lcSql NOSHOW
	SELECT Z.id_obl_zav, isnull(Z.id_kupca,'') as id_kupca, isnull(D.opis,'') as opis, isnull(P.naz_kr_kup,'') as naz_kr_kup
	  FROM dbo.odobrit_zavar Z
	  LEFT JOIN dbo.partner P ON Z.id_kupca = P.id_kupca
	  LEFT JOIN dbo.dok D ON Z.id_obl_zav = D.id_obl_zav
	 WHERE Z.id_odobrit = {0}
ENDTEXT
lcSql = STRTRAN(lcSql, "{0}", TRANSFORM(lnId_odobrit))

GF_SQLExec(lcSql, "tmp_zavar")

CREATE CURSOR tmp_osig (opis M)

LOCAL lcOpis
lcOpis = ""

SELECT tmp_zavar
SCAN
	lcOpis = lcOpis + ALLTRIM(tmp_zavar.opis) + " - " + ALLTRIM(tmp_zavar.naz_kr_kup) + chr(13) + chr(10)
ENDSCAN
INSERT INTO tmp_osig (opis) VALUES (lcOpis)

IF USED("tmp_zavar")
	USE IN tmp_zavar
ENDIF
*************************************************
* povlačenje svih napomena iz statusa u Memo polje
*by Siniša

CREATE CURSOR tmp_history (komentar M)

LOCAL lcOpis_his
lcOpis_his = ""

SELECT _history
SCAN
	lcOpis_his = lcOpis_his + ALLTRIM(_history.comment) + chr(13) + chr(10)
ENDSCAN
INSERT INTO tmp_history (komentar) VALUES (lcOpis_his)

*************************************************
*povlačenje svih postojećih ugovora partnera
GF_SQLExec("select id_pog,pred_naj from dbo.pogodba where id_kupca="+gf_quotedstr(allt(transf(result.id_kupca))),"_pogodba")

CREATE CURSOR tmp_pogodba (ugovori M)

LOCAL lcOpis_pog
lcOpis_pog = ""

SELECT _pogodba
SCAN
	lcOpis_pog = lcOpis_pog + ALLTRIM(_pogodba.id_pog) + ", "
ENDSCAN
INSERT INTO tmp_pogodba (ugovori) VALUES (lcOpis_pog)
*************************************************
IF RECCOUNT("tmp_pogodba") =0
	APPEND BLANK IN tmp_pogodba
ENDIF
	
GF_SQLEXEC("Select * from rtip","_RTIP")
GF_SQLEXEC("Select * from dejavnos","_DEJA")