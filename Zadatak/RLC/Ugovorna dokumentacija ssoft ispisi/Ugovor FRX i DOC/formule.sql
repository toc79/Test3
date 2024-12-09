koji se sastoji od razmjernog dijela vrijednosti objekta leasinga bez PDV-a u iznosu od {Format("{0:N2}", pogodba.OST_OBR_N_BP)} {pogodba.id_val}, PDV-a u iznosu od {Format("{0:N2}", pogodba.OST_OBR_DDV)} {pogodba.id_val}{IIF(pogodba.robresti_val>0,", te razmjernog dijela posebnog poreza na motorna vozila u iznosu od "+Format("{0:N2}", pogodba.OST_OBR_PPMV)+" "+pogodba.id_val.Trim(),"")}. Ukupan broj obroka je {pogodba.st_obrok}.
Mjesečni obroci obračunavaju se svakog 1. (prvog) u mjesecu. Primatelj leasinga dužan je platiti mjesečni obrok u roku od {Format("{0:N0}", pogodba.dni_zap)} ({Gmi_Utils.NumberToWordsInt(pogodba.dni_zap, Gmi_Utils.WordLang.HR, true)}) dana, tj. do datuma dospijeća označenog na računu.
Ukupni iznos naknade je {Format("{0:N2}",((pogodba.ost_obr * pogodba.st_obrok)+pogodba.prv_obr+pogodba.man_str+pogodba.str_notar))} {pogodba.id_val} ({IIF(pogodba.robresti_val>0,"PDV i poseban porez na motorna vozila su uključeni","PDV je uključen")}), a od toga trošak obrade po ovom ugovoru iznosi 



<br>
Ukupni iznos naknade je {Format("{0:N2}",((pogodba.ost_obr * pogodba.st_obrok)+pogodba.prv_obr+pogodba.man_str))} {pogodba.id_val} ({IIF(pogodba.robresti_val>0,"PDV i poseban porez na motorna vozila su uključeni","PDV uključen")}), a od toga trošak obrade po ovom ugovoru iznosi {Format("{0:N2}",pogodba.man_str)} {pogodba.id_val} (PDV uključen).


'Ukupni iznos naknade je '+ukupni_iznos+' ('+IIF(pogodba.robresti_val>0,'PDV i poseban porez na motorna vozila su uključeni','PDV je uključen')+'), a od toga trošak obrade po ovom ugovoru iznosi '+naknada+' (PDV uključen)'+txtppmv+'.'


allt(trans((pogodba.ost_obr*pogodba.st_obrok)+pogodba.prv_obr+_MAN_STROS.BRUTO+gf_xchange(pogodba.id_tec,_ponudba.str_notar,'000',_ponudba.dat_pon),gccif))+" "+allt(pogodba.id_val)

naknada
allt(trans(_MAN_STROS.BRUTO,gccif))+' '+allt(pogodba.id_val)

txtppmv
IIF(pogodba.ponudba_str_notar>0,"i Poseban porez na motorna vozila koji iznosi "+allt(trans(gf_xchange(pogodba.id_tec,_ponudba.str_notar,"000",_ponudba.dat_pon),gccif))+" "+allt(pogodba.id_val),"")


ČLANAK 4

'Primatelj leasinga ovlašten je s Objektom leasinga'+km_sat_novo+txtkmsat
km_sat_novo
iif(ali_reg,' prijeći '+allt(gstr(pogodba.dovol_km))+' km '+rc_god_mjesec+'.',' koristi '+allt(gstr(pogodba.dovol_km))+' radnih sati godišnje.')
rc_god_mjesec
iif(empty(_ugkategorija.kategorija1) or isnull(_ugkategorija.kategorija1),'godišnje',allt(look(_kategorija1.value,_ugkategorija.kategorija1,_kategorija1.id_key)))

txtkmsat
'Primatelj leasinga je obvezan platiti Davatelju leasinga naknadu u iznosu od '+alltr(transf(pogodba.cena_dkm,gccif))+' '+allt(pogodba.id_val)+km_sat1
km_sat1
iif(ali_reg,' za svaki prijeđeni km povrh dopuštenih.',' za svaki korišteni radni sat povrh dopuštenih.')

--NOVO netočno
Primatelj leasinga ovlašten je upotrebljavati objekt leasinga na uobičajen način pažnjom dobrog gospodarstvenika.
Primatelj leasinga ovlašten je s Objektom leasinga {IIF(pogodba.print_se_regis == 1, "prijeći "+pogodba.dovol_km_int +" km "+IIF(IsNull(pogodba,pogodba.kateg1_value),"godišnje",pogodba.kateg1_value), "koristi " + pogodba.dovol_km_int +" radnih sati godišnje")}. Primatelj leasinga je obvezan platiti Davatelju leasinga naknadu u iznosu od {Format("{0:N2}",pogodba.cena_dkm)} {pogodba.id_val} za svaki {IIF(pogodba.print_se_regis == 1, "prijeđeni km", "korišteni radni sat")} povrh dopuštenih.

--NOVO 2
Primatelj leasinga ovlašten je upotrebljavati objekt leasinga na uobičajen način pažnjom dobrog gospodarstvenika.
Primatelj leasinga ovlašten je s Objektom leasinga {IIF(pogodba.print_se_regis == 1, "prijeći "+pogodba.dovol_km_int +" km "+IIF(String.IsNullOrEmpty(pogodba.kateg1_value), "godišnje", pogodba.kateg1_value.Trim()), "koristi " + pogodba.dovol_km_int +" radnih sati godišnje")}. Primatelj leasinga je obvezan platiti Davatelju leasinga naknadu u iznosu od {Format("{0:N2}",pogodba.cena_dkm)} {pogodba.id_val} za svaki {IIF(pogodba.print_se_regis == 1, "prijeđeni km", "korišteni radni sat")} povrh dopuštenih.


-- ODGOVOR
--polje 'Važ. opis' iz šifranta vrste dokumentacije je izbačeno iz prikaza dokumentacije
