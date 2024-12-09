insert into dbo.GENERAL_REGISTER (ID_REGISTER, ID_KEY, VALUE, VAL_CHAR, VAL_NUM, neaktiven, VAL_BIT) values ('DOCUMENT_COLORING_BY_DUE_DATE', '00', 'Kolaterali, d_vrednot', 'IE', 30, 0, 0)

select * from general_register where id_register='DOCUMENT_COLORING_BY_DUE_DATE'

select * from custom_settings where code='Nova.LE.FrameViewUseBookedNotDuedDebitAll4ObligoCalc'

select leas_kred, tip_knjizenja, finbruto, ol_na_nacin_fl,base_nl,* from nacini_l

MR GMI 55440 

Meni: Pregledi | Pregled korištenja okvira 
- Za okvire tipa REV (revolving okvir) dodana je nova postavka s kojom određujemo da li se u izračun obliga uzimaju proknjižena nedospjela bruto potraživanja i dospjela neproknjižena potraživanja koja čine financiranu glavnicu i financirani PDV (jedna postavka za dva slučaja) ili se od proknjiženih nedospjelih potraživanja uvažavaju samo dugoročna potraživanja (posebna dodatna postavka). 
- Postavke se odnose na izračun polja ""Korišteno VAL"" i ""Razlika VAL"" na stranici ""Lista okvira"" te polja ""Obligo"" na stranici ""Detaljan pregled korištenja okvira"". 

[ADMIN] 
- U tabeli custom_settings je dodana nova postavka Nova.LE.FrameViewUseBookedNotDuedDebitAll4ObligoCalc koja omogućava da se u izračun obliga uključe sva proknjiženih nedospjelih bruto potraživanja i dospjela neproknjižena potraživanja koja čine financiranu glavnicu i financirani PDV na pregledu korištenja okvira za revolving okvire (tip okvira = REV). Ako je vrijednost postavke ""True"" kod izračuna obliga za revolving okvire se uvažavaju proknjižena nedospjela i dospjela neproknjižena potraživanja koja čine financiranu glavnicu i financirani PDV. Ako je postavka ima drugu vrijednost izračun obliga se izvodi prema dosadašnjem izračunu tj. od proknjiženih nedospjelih potraživanja uvažavaju se samo dugoročna potraživanja.



Poštovani, 
1. oko bojanja dokumentacije na pregledima, na testu imate primjere podešavanja te vam je u release notes naveden primjer. Oko detalja me možete kontaktirati na telefon. 
Dodatno smo na testu i produkciji dodali/podesili još jedan zapis u poseban šifrant DOCUMENT_COLORING_BY_DUE_DATE, koji je predviđen za RL grupaciju oko IE dokumenta (zapis ključa 00 Kolaterali, d_vrednot za IE dokument). 
Molim provjeru. 

2. Oko pregleda korištenja okvira, bila je rađena dorada za poduzeća u BiH da se za REV tip okvira u obligo ulazi i proknjiženi nedospijeli PDV. Dorada je trebala biti samo za FF tip leansiga (stari tip koji se u HR više ne koristi, dok u BiH da) i samo za potraživanje PDV, ali zbog našeg propusta/greške je u obligo ulazio i proknjiženi nedospjeli PDV od rata tj. u vašem slučaju za OL tip leasinga. 
Sada smo na testu napravili popravak te se proknjiženi nedospjeli PDV ne prikazuje u obligu, kao što je bilo do sada. Molim provjeru i potvarnu informaciju 

3. Oko dorade Document 55440 
"Meni: Pregledi | Pregled korištenja okvira 
- Za okvire tipa REV (revolving okvir) dodana je nova postavka s kojom određujemo da li se u izračun obliga uzimaju proknjižena nedospjela bruto potraživanja i dospjela neproknjižena potraživanja koja čine financiranu glavnicu i financirani PDV (jedna postavka za dva slučaja) ili se od proknjiženih nedospjelih potraživanja uvažavaju samo dugoročna potraživanja (posebna dodatna postavka). 
- Postavke se odnose na izračun polja "Korišteno VAL" i "Razlika VAL" na stranici "Lista okvira" te polja "Obligo" na stranici "Detaljan pregled korištenja okvira"." 

koju ste naveli u prilogu, ta funkcionalnost/postavka kod vas nije aktivirana. 

Tomislav Krnjak 
Održavanje / Support 

Gemicro d.o.o. 
Nova cesta 83, HR-10000 Zagreb, Hrvatska 
T: +385 (0)1 3688983 
F: +385 (0)1 3688979 
www.gemicro.hr


uz gfn_FrameView treba podesiti i na: 
- gfn_FrameView_ContractDetailsCollection 
- gfn_FrameView_ContractDetailsNotCollection
- gfn_FrameView_ContractDetailCollectionChild
