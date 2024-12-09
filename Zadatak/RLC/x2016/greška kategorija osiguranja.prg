<thipot_iu_register xmlns='urn:gmi:nova:leasing'>
<is_update>true</is_update>
<id_hipot>01</id_hipot>
<opis>TERETNA VOZILA</opis>
<b2grupa></b2grupa>
<id_fgroup>44</id_fgroup>
<list_id_obl_zav>AB,AO</list_id_obl_zav>
<eval_frequency></eval_frequency>
</thipot_iu_register>

<thipot_iu_register xmlns='urn:gmi:nova:leasing'>
<is_update>true</is_update>
<id_hipot>64</id_hipot>
<opis>test kategorije osiguranja</opis>
<b2grupa></b2grupa>
<id_fgroup>73</id_fgroup>
<list_id_obl_zav>X2</list_id_obl_zav>
<eval_frequency>10</eval_frequency>
</thipot_iu_register>


2.21.6 GREŠKA
<thipot_iu_register xmlns='urn:gmi:nova:leasing'>
<is_update>true</is_update>
<id_hipot>ST</id_hipot>
<opis>Stanovanje</opis>
<b2grupa></b2grupa>
<id_fgroup>63</id_fgroup>
<list_id_obl_zav></list_id_obl_zav>
<eval_frequency></eval_frequency>
</thipot_iu_register>

Napaka:
Error while handling ProcessXml request: The 'urn:gmi:nova:leasing:eval_frequency' element is invalid - The value '' is invalid according to its datatype 'http://www.w3.org/2001/XMLSchema:int' - The string '' is not a valid Int32 value.

BEZ GREŠKE
<thipot_iu_register xmlns='urn:gmi:nova:leasing'>
<is_update>true</is_update>
<id_hipot>ST</id_hipot>
<opis>Stanovanje</opis>
<b2grupa></b2grupa>
<id_fgroup>63</id_fgroup>
<list_id_obl_zav></list_id_obl_zav>
<eval_frequency>365</eval_frequency>
</thipot_iu_register>

Poštovani, greška se javlja iz razloga što za polje PRED. DINAMIKA VRED. nije unešena vrijednost (do )

2.20.5		2	Task	9000	LE	Svi	Svi	poboljšanje postojeće funkcionalnosti	Održavanje | Šifranti | Dokumentacija | Kategorije osiguranja	1	0	0	22.10.2015 11:57:11		HETA Asset Resolution d.o.o.		[USER]
Meni: Održavanje | Šifranti | Dokumentacija | Kategorije osiguranja
- Na masku za unos/popravak kategorije osiguranja, dodano je novo polje 'Pred. dinamika vred. ___ (u danima)' u koje unesemo predviđenu dinamiku (frekvenciju) vrednovanja u danima za Basel II izvještavanje, tj. broj dana do predloženog sljedećeg vrednovanja.
- U tabelu šifranta dodana je i odgovarajuća kolona 'Pred. dinamika vred.'.

Meni: Ugovor | Dokumentacija | Procjene osiguranja
- Kolona 'Br. osiguranja iz dok./jed. nekr.' u tabeli pregleda je preimenovana u 'Br. osig. iz dok./jed. nekr.'. Osim toga, dodana je kolona 'Vr., opis osig. iz dok.' (kada se radi o procjeni za osiguranje iz dokumentacije, u njemu se ispiše šifra i opis vrste tog dokumenta). 
- Na masci za unos nove procjene, sada se datum procjene više ne predlaže (polje 'Datum procjene' je prazno).
- Kod promjene datuma procjene postojeće procjene za osiguranje iz dokumentacije, program, ako je za kategoriju izabranog osiguranja u šifrantu kategorija osiguranja definirana predviđena dinamika vrednovanja, predlaže odgovarajući popravak vrijednosti u poljima 'Vrijedi do' i 'Pred. datum vred.' s obzirom na tu definiranu pred. dinamiku vred. Ako pred. dinamika vred. za kategoriju izabranog osiguranja nije definirana, definirana je za vrstu izabranog osiguranja u šifrantu vrsta dokumenta, program predlaže popravak datuma važnosti i predviđenog datuma vrednovanja procjene na osnovu te definirane dinamike.
