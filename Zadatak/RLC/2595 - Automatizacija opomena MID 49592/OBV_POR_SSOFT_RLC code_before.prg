SELECT za_opom
SCAN FOR oznacen = .t.
ENDSCAN

local lcList_Condition, opomin_list
LcList_condition = "oznacen=.t."
opomin_list = GF_CreateDelimitedList("za_opom", "id_cont", LcList_condition, ",")

gf_sqlexec("select a.id_cont,a.id_poroka,a.vloga,a.oznaka,a.opis,b.naz_kr_kup,b.ulica,b.id_poste,b.mesto from dbo.pog_poro a INNER JOIN dbo.partner b on a.id_poroka=b.id_kupca where a.oznaka in ('0','1') and a. neaktiven = 0 and a.id_cont in ("+iif(len(alltrim(opomin_list))=0,"0",opomin_list)+")","_za_opom_poro")



select str(b.id_opom) + ";" + a.id_poroka as id_ispis from _za_opom_poro a INNER JOIN za_opom b on a.id_cont=b.id_cont into cursor rezultat

selec rezultat   

IF reccount() = 0 THEN
	=POZOR("Nema podataka za ispis!")
	RETURN .F.
endif

OBJ_ReportSelector.PrepareDataForMRT("rezultat", "id_ispis")