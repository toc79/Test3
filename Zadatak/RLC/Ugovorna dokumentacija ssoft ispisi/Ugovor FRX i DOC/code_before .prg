LOCAL lcStariAlias,lcid_pon,lcid_strm,lnid_cont,lcId_kateg,lcvnesel,lcPPOM
lcStariAlias = ALIAS()
lcid_pon=pogodba.id_pon
lcPPOM = GF_GeneralRegister('RLC Reporting list','RLC_PPOM_NL','VALUE')

GF_SQLEXEC("select * from ponudba where id_pon="+GF_QuotedStr(lcId_pon),"_ponudba")

select neto+marza as neto, davek, debit as bruto from planplacil where sif_terj = 'MSTR' into cursor _MAN_STROS
Select Sum(neto) as neto, sum(obresti) as kamata, sum(davek) as davek, sum(debit) as debit From planplacil where id_terj="21" into cursor _rata_bruto

select id_cont,id_strm, vnesel from pogodba into cursor _pogodba_test

lcid_strm =_pogodba_test.id_strm
lcvnesel =_pogodba_test.vnesel
lcId_kateg="KATEGORIJA1" 
lnid_cont=_pogodba_test.id_cont

GF_SQLEXEC("select * from strm1 where id_strm="+GF_QuotedStr(lcid_strm),"_strm1")
GF_SQLEXEC("Select username,user_desc, phone, fax, email From users where username="+GF_QUotedStr(lcvnesel),"_vnesel")
GF_SQLEXEC("select id_cont,kategorija1,kategorija2,kategorija3 from pogodba where id_cont="+GF_QuotedStr(lnId_cont),"_ugkategorija")
GF_SQLEXEC("select * from general_register where id_register="+GF_QuotedStr(lcId_kateg),"_kategorija1")
GF_SQLEXEC("select * from rtip","_RTIP")

*!* UGOVORNA DOKUMENTACIJA
RF_FRM_DOK()

*!* PPOM UGOVORI
Select nacin_leas, lcPPOM as PPOM_NL, IIF(ATC(nacin_leas, NVL(lcPPOM, '')) > 0, 1, 0) as PPOM From pogodba INTO CURSOR _PPOM


If !Empty(lcStariAlias) THEN
	Select (lcStariAlias)
ENDIF