ZADUZ 'Zadužnica - Obična'  
iif(RF_TIP_POG(pogodba.nacin_leas)=="F1" or RF_TIP_POG(pogodba.nacin_leas)=="ZP",allt(trans(round(_c1.debit*pogodba.st_obrok,2)+pogodba.opcija,gccif)),+allt(iif(pogodba.nacin_leas="O",transform(round(pogodba.st_obrok*pogodba.ost_obr,2),gccif),""))+allt(iif(pogodba.nacin_leas="FF",transform(round(pogodba.st_obrok*pogodba.ost_obr,2)+pogodba.opcija,gccif),"")))


iif(RF_TIP_POG(pogodba.nacin_leas)=="F1" or RF_TIP_POG(pogodba.nacin_leas)=="ZP",allt(trans(round(_c1.debit*pogodba.st_obrok,2)+pogodba.opcija,gccif)),+allt(iif(pogodba.nacin_leas="O",transform(round(pogodba.st_obrok*pogodba.ost_obr,2),gccif),""))+allt(iif(pogodba.nacin_leas="FF",transform(round(pogodba.st_obrok*pogodba.ost_obr,2)+pogodba.opcija,gccif),"")))


"(slovima: "+iif(RF_TIP_POG(pogodba.nacin_leas)=="F1" or RF_TIP_POG(pogodba.nacin_leas)=="ZP",crocif(round(_c1.debit*pogodba.st_obrok,2)+pogodba.opcija,"Z"),"")+iif(pogodba.nacin_leas="O",crocif(round(pogodba.st_obrok*pogodba.ost_obr,2),"Z"),"")+iif(pogodba.nacin_leas="FF",crocif(round(pogodba.st_obrok*pogodba.ost_obr,2)+pogodba.opcija,"Z"),"")+" "+alltr(GF_LOOKUP("valute.naziv",pogodba.id_val,"valute.id_val"))+")"


* novo
iif(RF_TIP_POG(pogodba.nacin_leas)=="F1" or RF_TIP_POG(pogodba.nacin_leas)=="ZP", allt(trans(round(_c1.debit*pogodba.st_obrok,2)+pogodba.opcija,gccif)), allt(iif(pogodba.nacin_leas="O",transform(round(pogodba.st_obrok*pogodba.ost_obr,2),gccif), "")) +allt(iif(pogodba.nacin_leas="FF",transform(round(pogodba.st_obrok*pogodba.ost_obr,2)+pogodba.opcija,gccif),"")))


txt2
IIF(RF_TIP_POG(POGODBA.NACIN_LEAS)="F"," redovne kamate po stopi od "+ALLT(TRANS(POGODBA.OBR_MERA,GCCIF))+" % godišnje, promjenjiva, sukladno odluci Vjerovnika, te","")



ZADUZ_J1 'Zadužnica - Obična' za jamca 
iif(pogodba.nacin_leas="F1" or pogodba.nacin_leas="F2" or pogodba.nacin_leas="PD" or pogodba.nacin_leas="ZP",allt(trans(round(_c1.debit*pogodba.st_obrok,2)+pogodba.opcija,gccif)),+allt(iif(pogodba.nacin_leas="O",transform(round(pogodba.st_obrok*pogodba.ost_obr,2),gccif),""))+allt(iif(pogodba.nacin_leas="FF",transform(round(pogodba.st_obrok*pogodba.ost_obr,2)+pogodba.opcija,gccif),"")))


iif(pogodba.nacin_leas="F1" or pogodba.nacin_leas="F2" or pogodba.nacin_leas="PD" or pogodba.nacin_leas="ZP",allt(trans(round(_c1.debit*pogodba.st_obrok,2)+pogodba.opcija,gccif)),+allt(iif(pogodba.nacin_leas="O",transform(round(pogodba.st_obrok*pogodba.ost_obr,2),gccif),""))+allt(iif(pogodba.nacin_leas="FF",transform(round(pogodba.st_obrok*pogodba.ost_obr,2)+pogodba.opcija,gccif),"")))

"(slovima: "+iif(pogodba.nacin_leas="F1" or pogodba.nacin_leas="F2" or pogodba.nacin_leas="PD" or pogodba.nacin_leas="ZP",crocif(round(_c1.debit*pogodba.st_obrok,2)+pogodba.opcija,"Z"),"")+iif(pogodba.nacin_leas="O",crocif(round(pogodba.st_obrok*pogodba.ost_obr,2),"Z"),"")+iif(pogodba.nacin_leas="FF",crocif(round(pogodba.st_obrok*pogodba.ost_obr,2)+pogodba.opcija,"Z"),"")+" "+alltr(GF_LOOKUP("valute.naziv",pogodba.id_val,"valute.id_val"))+")"


ZADUZ_FRAME -> NETREBA


ZADUZ code_before 
local lcid_cont
lcid_cont=pogodba.id_cont

Select * from pog_poro where oznaka="1" and vr_osebe != "FO" into cursor _jam
select * from pog_poro where oznaka="0" and vr_osebe != "FO" into cursor _jamci
Select * from _jamci where oznaka="0" and recno() = 1 into cursor _dod1
Select * from _jamci where oznaka="0" and recno() = 2 into cursor _dod2
Select * from _jamci where oznaka="0" and recno() = 3 into cursor _dod3


Select debit from planplacil where sif_terj="LOBR" into cursor _c1

GF_SQLEXEC("SELECT A.ID_OBR, A.DATUM, A.VREDNOST FROM OBR_ZGOD A INNER JOIN(SELECT ID_OBR, MAX(DATUM) AS MDAT FROM OBR_ZGOD GROUP BY ID_OBR) B ON A.ID_OBR = B.ID_OBR AND A.DATUM = B.MDAT","_OBRESTI")


ZADUZ_J1 code_before
local lcid_cont, lcid_kup
lcid_cont=pogodba.id_cont
lcid_kup=pog_poro.id_kupca


Select * from pog_poro where oznaka="1" and vr_osebe != "FO" and id_kupca#lcid_kup into cursor _jam
select * from pog_poro where oznaka="0" and vr_osebe != "FO" and id_kupca#lcid_kup into cursor _jamci

Select * from _jamci where oznaka="0" and recno() = 1 into cursor _dod1
Select * from _jamci where oznaka="0" and recno() = 2 into cursor _dod2
Select * from _jamci where oznaka="0" and recno() = 3 into cursor _dod3

Select debit from planplacil where sif_terj="LOBR" into cursor _c1

GF_SQLEXEC("SELECT A.ID_OBR, A.DATUM, A.VREDNOST FROM OBR_ZGOD A INNER JOIN(SELECT ID_OBR, MAX(DATUM) AS MDAT FROM OBR_ZGOD GROUP BY ID_OBR) B ON A.ID_OBR = B.ID_OBR AND A.DATUM = B.MDAT","_OBRESTI")

*Odgovor
Poštovani, 
u prilogu vam šaljemo ponudu za doradu ispisa 
'Zadužnica - Obična'  
'Zadužnica - Obična'  za jamca 
prema zahtjevu tj. micanje rečenice za ugovore financijskog leasinga.

Dodatno sam provjerio/usporedio formulu za iznos u točci 1 te na oba ispisa je mala razlika u prikazu iznosa npr. za F4 ugovor. Tako za ugovor 54568/17 (F4) na produkciji na ispis 'Zadužnica - Obična' se prikaže/izračuna iznos dok za ispis za jamca  ne. Da li je to u redu ili bi trebalo formule na oba ispisa biti identične?

$SIGN
