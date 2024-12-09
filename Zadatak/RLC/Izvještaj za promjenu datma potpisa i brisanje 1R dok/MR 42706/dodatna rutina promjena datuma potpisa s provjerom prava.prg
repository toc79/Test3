#include locs.h
local ldDatPodpisa_new, lnBrOznacenih, lcId_contList, lnBrIzmjenjenih

select rezultat 
go top

select * from rezultat into cursor _ugovori_promjena where oznacen = .T.

lnBrOznacenih = RECCOUNT("_ugovori_promjena")

IF GOBJ_Permissions.GetPermission("ContractUpdate") < 2 THEN 
	pozor(STRTRAN(PERMISSION_DENIED, "{0}", "ContractUpdate"))
	RETURN .F.
ENDIF 


IF GOBJ_Permissions.GetPermission("ActiveContractUpdate") < 2 THEN 
	pozor(STRTRAN(PERMISSION_DENIED, "{0}", "ActiveContractUpdate"))
	RETURN .F.
ENDIF 

IF lnBrOznacenih == 0
	obvesti("Niti jedan zapis nije označen!")
	RETURN .F.
ENDIF
	

ldDatPodpisa_new = GF_GET_DATE('Unesite novi datum potpisa', {..}, '99.99.9999', .T., 'Novi datum potpisa')

IF GF_NULLOREMPTY(ldDatPodpisa_new)
	RETURN .F.
ENDIF

IF ldDatPodpisa_new > DATE() .or. ldDatPodpisa_new < DATE() - 8
	IF !POTRJENO("Unešeni datum " + tran(ldDatPodpisa_new) + " je izvan definiranog razdoblja po kojem datum ne smije biti u budućnost niti stariji od 8 dana. Da li ipak želite nastaviti sa promjenom datuma potpisa klijenta?")
		RETURN .F.
	ENDIF
ENDIF

IF !POTRJENO("Želite li za " + tran(lnBrOznacenih) + " označenih ugovora izmjeniti datum potpisa klijenta u " + tran(ldDatPodpisa_new) + ".?")
	RETURN .F.
ENDIF

lcId_contList = GF_CreateDelimitedList("_ugovori_promjena", "id_cont", "1=1", ", ", .F.)
	
GF_SQLEXEC("SELECT id_cont, dbo.gfn_GetContractDataHash(id_cont) as pogodba_hash FROM dbo.pogodba where id_cont IN (" + lcId_contList + ")","_izmjena_dat_podpisa")

lnBrIzmjenjenih = 0

select _izmjena_dat_podpisa
go top
scan
	wait wind ("Pripremam podatke!") nowait
	local lcpogodba_hash, lcOpomba, lcid_category, lnid_cont, lcXML, lcId_pog
	
	lcpogodba_hash = _izmjena_dat_podpisa.pogodba_hash
	lnid_cont = _izmjena_dat_podpisa.id_cont

	lcOpomba = "Masovna promjena datuma potpisa preko posebnog izvještaja Izmjena datuma potpisa ugovora."
	lcid_category = "000"
	
	GF_SQLEXEC("select * from pogodba where id_cont = " + GF_QuotedStr(lnid_cont),"_pogodba")
	GF_SQLEXEC("Select * From pogodba where id_cont = " + GF_QuotedStr(lnid_cont),"_pogodba_copy")
	
	lcId_pog = _pogodba.id_pog
	
	replace dat_podpisa with ldDatPodpisa_new in _pogodba
	
	lcXML = GF_CreateContractUpdateXML(lnid_cont, ALLTRIM(lcOpomba), lcpogodba_hash, lcid_category, "_pogodba", "_pogodba_copy")
	
	IF LEN(ALLTRIM(lcXml)) > 0 THEN
		IF GF_ProcessXML(lcXML) THEN
			lnBrIzmjenjenih = lnBrIzmjenjenih + 1
		ELSE
			obvesti("NOT OK za ugovor:" + allt(trans(lcId_pog)))
		ENDIF
	ELSE
		obvesti("Za ugovor: "+ allt(trans(lcId_pog)) + " je poslani datum potpisa jednak trenutnom!")
	ENDIF
	
	use in _pogodba
	use in _pogodba_copy
endscan
	
obvesti("Datum potpisa klijenta uspješno izmjenjen za " + tran(lnBrIzmjenjenih) + " ugovora!")

use in _ugovori_promjena
use in _izmjena_dat_podpisa