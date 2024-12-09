-- kalk_form_stros nova_hls
str_of = '#vr_val' ili '#net_nal'
 Str_financ_OF = "#net_nal" u obj_LEAS.prg
df_str =
round((1 + (GF_LOOKUP("dav_stop.davek", GF_ClaimTaxRateID2("SFIN", 0, ponudba.id_dav_st, #nacin_leas), "dav_stop.id_dav_st")/100)) * lfInterest (#Str_financ_O, Date(), Date() + IIF(#Dni_financ = 0 OR #Str_procent != #Dni_financ, #Str_procent, #Dni_financ), #Obr_financ, #Obresti_f_method_is_conform ), 2)
--ESL
lnIznos = round((1 + (GF_LOOKUP("dav_stop.davek", GF_ClaimTaxRateID2("SFIN", 0, ponudba.id_dav_st, ponudba.nacin_leas), "dav_stop.id_dav_st")/100)) * lfInterest (ponudba.net_nal, Date(), Date() + lnBrojDana, ponudba.Obr_financ, llObresti_f_method_is_conform ), 2) 

! GF_CustomSettingsAsBool("IntercalaryInt_UseLinearMethod")

--rlc
round((1 + (GF_LOOKUP("dav_stop.davek", GF_ClaimTaxRateID2("SFIN", 0, ponudba.id_dav_st,  #nacin_leas), "dav_stop.id_dav_st")/100)) * lfInterest (#Str_financ_O, Date(), Date() + 30, #Obr_financ, ! GF_CustomSettingsAsBool("IntercalaryInt_UseLinearMethod")), 2)


select * from dbo.vrst_ter_fikt
select * from dbo.kalk_form_stros
--DELETE FROM dbo.kalk_form_stros WHERE id_stroska = 'KO'
--UPDATE dbo.kalk_form_stros SET neaktiven = 1 WHERE id_terj = '1A' -- i dalje je greška
--DELETE FROM dbo.kalk_form_stros WHERE id_terj = '1A' 
--UPDATE dbo.kalk_form_stros SET neaktiven = 1

select distinct id_stroska from dbo.pon_terj_stros
select distinct id_terj from dbo.pon_terj_stros


select * from CUSTOM_SETTINGS where code like '%Nova.LE.OfferCostsDatZap%'
--UPDATE CUSTOM_SETTINGS SET val = 'True' where code like '%Nova.LE.OfferCostsDatZap%'


Bug 36013

--Do sada podešeno

select * from dbo.vrst_ter_fikt

insert into dbo.vrst_ter_fikt
values('KO','KAOS','Kasko osiguranje',1,NULL)

INSERT INTO dbo.kalk_form_stros(pogoj,str_of,df_str,df_str_p,id_stroska,id_terj,opis,disable_str,disable_str_p,vrstni_red,predlaga_na_ponudbi,neaktiven) VALUES('select @add = case when ''{nl}'' = ''F1'' then 1 else 0 end','#vr_val','round(#str_osnova*#str_procent/100,2)','round(#str_znesek*100/#str_osnova,4)','KO',NULL,NULL,0,0,10,1,0)
INSERT INTO dbo.kalk_form_stros(pogoj,str_of,df_str,df_str_p,id_stroska,id_terj,opis,disable_str,disable_str_p,vrstni_red,predlaga_na_ponudbi,neaktiven) VALUES('select @add = case when ''{nl}'' = ''F2'' then 1 else 0 end','#vr_val','round(#str_osnova*#str_procent/100,2)','round(#str_znesek*100/#str_osnova,4)','KO',NULL,NULL,0,0,10,1,0)
INSERT INTO dbo.kalk_form_stros(pogoj,str_of,df_str,df_str_p,id_stroska,id_terj,opis,disable_str,disable_str_p,vrstni_red,predlaga_na_ponudbi,neaktiven) VALUES('select @add = case when ''{nl}'' = ''F3'' then 1 else 0 end','#vr_val','round(#str_osnova*#str_procent/100,2)','round(#str_znesek*100/#str_osnova,4)','KO',NULL,NULL,0,0,10,1,0)
INSERT INTO dbo.kalk_form_stros(pogoj,str_of,df_str,df_str_p,id_stroska,id_terj,opis,disable_str,disable_str_p,vrstni_red,predlaga_na_ponudbi,neaktiven) VALUES('select @add = case when ''{nl}'' = ''F4'' then 1 else 0 end','#vr_val','round(#str_osnova*#str_procent/100,2)','round(#str_znesek*100/#str_osnova,4)','KO',NULL,NULL,0,0,10,1,0)
INSERT INTO dbo.kalk_form_stros(pogoj,str_of,df_str,df_str_p,id_stroska,id_terj,opis,disable_str,disable_str_p,vrstni_red,predlaga_na_ponudbi,neaktiven) VALUES('select @add = case when ''{nl}'' = ''F5'' then 1 else 0 end','#vr_val','round(#str_osnova*#str_procent/100,2)','round(#str_znesek*100/#str_osnova,4)','KO',NULL,NULL,0,0,10,1,0)

{IIF(Offer.je_foseba, "Izračun", "Ponudu")}

Vrsta leasinga:        {IIF(Offer.lease_type_tip_knjizenja == "1", "OPERATIVNI", "FINANCIJSKI")} LEASING

INFORMATIVNA LEASING PONUDA br.: {Offer.id_data_offer}

--NOVO
{IIF(Offer.lease_type_tip_knjizenja == "1" || ! Offer.customer_is_private_person, "INFORMATIVNA LEASING PONUDA", "INFORMATIVNI LEASING IZRAČUN")} br.: {Offer.id_data_offer}

Poštovani,
zahvaljujemo na upitu te Vam prema dogovoru dostavljamo na uvid sljedeću ponudu:


--NOVO
Poštovani,
zahvaljujemo na upitu te Vam prema dogovoru dostavljamo na uvid sljedeću {IIF(Offer.lease_type_tip_knjizenja == "1" || ! Offer.customer_is_private_person, "ponudu", "izračun")}:


Poštovana/i, 

na testu smo napravili promjene prema točkama 1, 2, 3 i 6. Molim provjeru.

Oko točke 5 i kontrole za EKS, za podešavanja kontrola (koji će onemogućiti nastavak) kod spremanja ponude i kod spremanja neaktivnog ugovora vam šaljemo ponudu u privitku. Kontrola će uspoređivati uneseni granični EKS u šifrant sa onim na ponudi/ugovoru.
Oko šifranta 'Zakonski dozvoljene EKS' (opcija Održavanje | Šifranti | Ugovori | Zakonski dozvoljene EKS) možda je najbolje da vi sami na testu unesete zapis zato jer ćete vi sami nadalje uređivati zakonski EKS. Npr. u polje unosite:
Br. mjeseci  financiranja = 0
Najviša EKS = 6,8200 (ili 6,5400)
Zadnja unesena EKS = informativno polje te u nju nije predviđen unos 
Granični iznos = 0
Zadnji unesen iznos = informativno polje te u nju nije predviđen unos 
Vr. osobe = FO.
Nakon spremanja testirajte unos ponude/ugovora.

7. Za promjenu ispisa 'Ponuda za financiranje' na portalu da se na svim mjestima gdje se spominje ponuda za financijski leasing i fizičku osobu riječ ponuda zamijeni u IZRAČUN, vam u privitku šaljemo dodatnu ponudu (u prošlom mailu smo naveli da promjenu nećemo naplatiti se odnosila samo na promjenu na jednom mjestu, dok u slučaju promjene na svim mjestima potrebno nam je više vremena). 



U izračun EKS-a ukoliko je objekt leasinga vozilo je uključeno: rok otplate, nominalna kamata, trošak obrade, interkalarna kamata za period od 30 dana, te minimalno zahtjevani troškovi kasko osiguranja koji su poznati ¤podjetje¤, a koji pokrivaju rizik od krađe i totalne štete u iznosu od ¤ZnesekKO¤ ¤pon_idval¤ godišnje i to za cijelo vrijeme trajanja leasing ugovora.

IIF(LOOKUP(vrst_opr.id_grupe, ponudba.id_vrste, vrst_opr.id_vrste) != "VBO", "U izračun EKS-a ukoliko je objekt leasinga vozilo je uključeno: rok otplate, nominalna kamata, trošak obrade, interkalarna kamata za period od 30 dana, te minimalno zahtjevani troškovi kasko osiguranja koji su poznati "+ALLT(GOBJ_Settings.GetVal("p_podjetje"))+", a koji pokrivaju rizik od krađe i totalne štete u iznosu od "+allt(trans(NVL(LOOKUP(pon_terj_stros.znesek, "KO", pon_terj_stros.id_stroska), 0), gccif))+" "+allt(ponudba.id_val)+" godišnje i to za cijelo vrijeme trajanja leasing ugovora.", "")


U izračun EKS-a ukoliko je objekt leasinga plovilo je uključeno: rok otplate, nominalna kamata, trošak obrade, interkalarna kamata za period od 30 dana, te troškovi kasko osiguranja koji su poznati ¤podjetje¤, a u iznosu od ¤ZnesekKO¤ ¤pon_idval¤ godišnje i to za cijelo vrijeme trajanja leasing ugovora.

IIF(LOOKUP(vrst_opr.id_grupe, ponudba.id_vrste, vrst_opr.id_vrste) != "VBO", "U izračun EKS-a ukoliko je objekt leasinga vozilo je uključeno: rok otplate, nominalna kamata, trošak obrade, interkalarna kamata za period od 30 dana, te minimalno zahtjevani troškovi kasko osiguranja koji su poznati "+ALLT(GOBJ_Settings.GetVal("p_podjetje"))+", a koji pokrivaju rizik od krađe i totalne štete u iznosu od "+allt(trans(NVL(LOOKUP(pon_terj_stros.znesek, "KO", pon_terj_stros.id_stroska), 0), gccif))+" "+allt(ponudba.id_val)+" godišnje i to za cijelo vrijeme trajanja leasing ugovora.", "U izračun EKS-a ukoliko je objekt leasinga plovilo je uključeno: rok otplate, nominalna kamata, trošak obrade, interkalarna kamata za period od 30 dana, te troškovi kasko osiguranja koji su poznati "+ALLT(GOBJ_Settings.GetVal("p_podjetje"))+", a u iznosu od "+allt(trans(NVL(LOOKUP(pon_terj_stros.znesek, "KO", pon_terj_stros.id_stroska), 0), gccif))+" "+allt(ponudba.id_val)+" godišnje i to za cijelo vrijeme trajanja leasing ugovora.")

U izračun EKS-a ukoliko se radi o rabljenom objektu leasinga za kojeg je potrebno izvršiti procjenu objekta leasinga od strane ovlaštenog sudskog vještaka uključeni su i troškovi procjene u iznosu od ¤ZnesekPR¤ ¤pon_idval¤ jednokratno.

IIF(_cb_pon_terj_stros_PR.znesek > 0, CHR(13)+"U izračun EKS-a ukoliko se radi o rabljenom objektu leasinga za kojeg je potrebno izvršiti procjenu objekta leasinga od strane ovlaštenog sudskog vještaka uključeni su i troškovi procjene u iznosu od "+allt(trans(_cb_pon_terj_stros_PR.znesek, gccif))+" "+allt(ponudba.id_val)+" jednokratno.", "")
