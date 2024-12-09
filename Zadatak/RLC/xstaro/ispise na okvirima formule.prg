zadužnica na ugovoru
u iznosu glavnice od (1): ¤idval¤ ¤iznos¤ ¤iznoscro¤ ¤txtVAL¤(Ugovor o ¤tipleas¤ broj ¤idpog¤)

allt(pogodba.id_val)

local lcid_cont
lcid_cont=pogodba.id_cont

Select * from pog_poro where oznaka="1" and vr_osebe != "FO" into cursor _jam
select * from pog_poro where oznaka="0" and vr_osebe != "FO" into cursor _jamci
Select * from _jamci where oznaka="0" and recno() = 1 into cursor _dod1
Select * from _jamci where oznaka="0" and recno() = 2 into cursor _dod2
Select * from _jamci where oznaka="0" and recno() = 3 into cursor _dod3


Select debit from planplacil where sif_terj="LOBR" into cursor _c1

GF_SQLEXEC("SELECT A.ID_OBR, A.DATUM, A.VREDNOST FROM OBR_ZGOD A INNER JOIN(SELECT ID_OBR, MAX(DATUM) AS MDAT FROM OBR_ZGOD GROUP BY ID_OBR) B ON A.ID_OBR = B.ID_OBR AND A.DATUM = B.MDAT","_OBRESTI")

iif(RF_TIP_POG(pogodba.nacin_leas)=="F1" or RF_TIP_POG(pogodba.nacin_leas)=="ZP",allt(trans(round(_c1.debit*pogodba.st_obrok,2)+pogodba.opcija,gccif)),+allt(iif(pogodba.nacin_leas="O",transform(round(pogodba.st_obrok*pogodba.ost_obr,2),gccif),""))+allt(iif(pogodba.nacin_leas="FF",transform(round(pogodba.st_obrok*pogodba.ost_obr,2)+pogodba.opcija,gccif),"")))

"(slovima: "+iif(RF_TIP_POG(pogodba.nacin_leas)=="F1" or RF_TIP_POG(pogodba.nacin_leas)=="ZP",crocif(round(_c1.debit*pogodba.st_obrok,2)+pogodba.opcija,"Z"),"")+iif(pogodba.nacin_leas="O",crocif(round(pogodba.st_obrok*pogodba.ost_obr,2),"Z"),"")+iif(pogodba.nacin_leas="FF",crocif(round(pogodba.st_obrok*pogodba.ost_obr,2)+pogodba.opcija,"Z"),"")+" "+alltr(GF_LOOKUP("valute.naziv",pogodba.id_val,"valute.id_val"))+")"


iif(pogodba.id_tec="000","","u kunskoj protuvrijednosti koristeći "+allt(pogodba.tecajnic_naziv)+" na dan dospijeća ")



Ispisi
OBAVIJEST O ODOBRENJU OKVIRA
UGOVOR O OKVIRU  
Zadužnica - Obična za okvir
Mjenično očitovanje za okvir  