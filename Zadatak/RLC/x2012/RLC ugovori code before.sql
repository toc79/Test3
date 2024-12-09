select neto+marza as neto, davek, debit as bruto from planplacil where sif_terj = 'MSTR' into cursor _MAN_STROS

local lnid_cont,lcId_kateg, lcid_strm
lnid_cont=pogodba.id_cont 
lcId_kateg="KATEGORIJA1" 
lcid_strm=pogodba.id_strm

GF_SQLEXEC("select id_cont,kategorija1,kategorija2,kategorija3 from pogodba where id_cont="+GF_QuotedStr(lnId_cont),"_ugkategorija") 

GF_SQLEXEC("select * from general_register where id_register="+GF_QuotedStr(lcId_kateg),"_kategorija1") 

GF_SQLEXEC("select * from strm1 where id_strm="+GF_QuotedStr(lcId_strm),"_strm1")

local lcvnesel
lcvnesel=pogodba.vnesel

GF_SQLEXEC("Select username,user_desc, phone, fax, email From users where username="+GF_QUotedStr(lcvnesel),"_vnesel")

GF_SQLEXEC("SELECT * FROM dbo.gfn_ContractDocumentation("+TRANSFORM(pogodba.id_cont)+") WHERE ali_na_pog = 1 AND dni_zap=0", 'dok_prije')

GF_SQLEXEC("SELECT * FROM dbo.gfn_ContractDocumentation("+TRANSFORM(pogodba.id_cont)+") WHERE ali_na_pog = 1 AND dni_zap>0", 'dok_poslje')

local lcmemo
CREATE CURSOR _print1(zav_memo_prije M(4), zav_memo_poslje M(4))
select _print1
append blank
lcMemo = GF_createZav_memo("dok_prije")
replace zav_memo_prije with lcMemo in _print1

lcMemo = GF_createZav_memo("dok_poslje")
replace zav_memo_poslje with lcMemo in _print1

sele pogodba




iif(pogodba.spl_pog="ZO","ZBIRNI INSTR. OSIGURANJA PREMA ODOBRENJU OKVIRA   ",allt(strtran(_print1.zav_memo_prije," 0 kom","")))



allt(iif(!(empty(_print1.zav_memo_poslje) or isnull(_print1.zav_memo_poslje)) and !(pogodba.spl_pog="ZO"),"a nakon preuzimanja objekta leasinga slijedeca sredstva osiguranja:"+chr(13)+strtran(_print1.zav_memo_poslje," 0 kom",""),""))