
** zadnji označen zapis ne uvažava pa su potrebne sljedeće 3 linije
SELECT result
SCAN FOR izbran = .t.
ENDSCAN


lcDelimetedList = GF_CreateDelimitedList("result", "id_cont", "izbran = .t.", ",")
GF_SQLEXEC("select id_cont, id_pog, dni_zap, zap_2ob, zap_opc, id_obd, opc_datzad, vr_val, opcija, st_obrok, dat_sklen, verified from pogodba where id_cont in ("+lcDelimetedList+")","_cur_akt0")
ltDat_podpisa 	= GF_GET_DATE("Unesite Datum potpisa", TTOD(_cur_akt0.dat_sklen), "", .T., "Masovna promjena datuma potpisa")
IF GF_NULLOREMPTY(ltDat_podpisa)
	return
ENDIF

select *, ltDat_podpisa as dat_podpisa_new  from _cur_akt0 into cursor _cur_akt

SELECT _cur_akt
SCAN

local lcOpomba, lcid_category, lnid_cont, lcpogodba_hash
	&&staviti napomenu koju trebas
lcOpomba="Prema zahtjevu br. xxxxxx"
	&&kategorija je ostalo 000 ili 999
lcid_category="000"
lnid_cont=_cur_akt.id_cont
lcpogodba_hash = TRANSFORM(GF_SQLEXECSCALAR("SELECT dbo.gfn_getContractDataHash("+ ALLTRIM(STR(lnid_cont)) +")"))
ltDat_podpisa2 = _cur_akt.dat_podpisa_new

GF_SQLEXEC("select * from pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba")
GF_SQLEXEC("Select * From pogodba where id_cont="+GF_QuotedStr(lnid_cont),"_pogodba_copy")

replace dat_podpisa with ltDat_podpisa2 in _pogodba

lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy")

&& ako je lcXML prazan ne šalji poziv ništa se nije promjenilo, nisu poslali novi fix_del
IF LEN(ALLTRIM(lcXml)) > 0 THEN
IF GF_ProcessXML(lcXML) THEN
&&=obvesti("OK za ugovor: " + allt(trans(lnid_cont)))
ELSE
obvesti("NOT OK za ugovor:" + allt(trans(lnid_cont)))
ENDIF
ELSE
obvesti("Za ugovor: "+ allt(trans(lnid_cont)) + " nije bilo promjene")
ENDIF
use in _pogodba
use in _pogodba_copy
endscan

obvesti("Postupak je završio")