Ponuda za prijevremeni otkup
PON_PRED_ODKUP_ID_POG_VALID  i  PON_PRED_ODKUP_MASKA_CALC

Ručni reprogram
REPRO_SELECT_ID_POG_VALID - dodavanje broja ugovora

REPRO_MASKA_INIT - klik na gumb za popravak zapisa

REPRO_SELECT_PREVERI_PODATKE_CUSTOM - klik na malu zelenu kvačicu 

Automatski reprogram
REPRO_AVTOM_CHANGE_OFFER_CHECK - odabir ponude na masci za parametre
REPRO_AVTOM_CHANGE_OFFER_PREPERE - odabir ponude na masci za parametre

Račun za otkup
FAKTURA_ZA_ODKUP_MASKA_CUSTOM_CHECK (kod spremanja preveri podatke)
Imamo popravak pojedinačnog zapisa i popravak više zapisa odjednom masovnih zapisa (trebalo bi oba slučaja uzeti u obzir). Za masovni imamo još OPC_FAKT_IZPIS_BTNPOPRAVEC_CLICK koje je pokreće na INIT.

Poštovani, 
za OR ugovore predlažemo da napravimo kontrolu na način da se prikaže obavijest upozorenja u slučaju da ugovor ima jamčevinu, npr. "Provjerite da li se jamčevina prikazuje u sumi buduće glavnice!"
Kontrolu bi radili u sljedećim opcijama:
1) Ponuda za prijevremeni zaključak
Imamo na raspolaganju dvije eksterne funkcije u kojoj možemo programirati kontrole, u koraku: 
a) unosa broja ugovora i 
b) klika na gumb "Pripremi ponudu"
pa molimo da nam definirate u kojem trenutku (pod a) ili b)) želite da se prikazuje poruka upozorenja (po meni je nepotrebno dodati kontrolu na oba koraka).
2) Račun za otkup - u koraku klika na gumb "Spremi".
3) Automatski ili ručni reprogram - u koraku unosa broja ugovora.

Dodatno bi još napravili još kontrole u opciji:
4) Račun za otkup - gdje bi u slučaju da OR ugovor ima dva otkupa u planu otplate, prikazali dodatnu poruku/upozorenje npr. "Potrebno je obrisati oba zapisa iz računa za otkup, spojit ih ručnim reprogramom, na ugovoru maknuti oznaku 'Priprema obavijesti za otkup' i pustiti dnevnu rutinu trojna opcija.". S porukom možemo onemogućiti nastavak spremanja ako je to potrebno.

5) Automatski ili ručni reprogram - za OF i OR da kada korisnik odabere kategoriju (dodala bi se nova "Kategorija reprograma" npr. "Prijevremeni otkup kod hibrida") i klikne na gumb 'F3 - Novi zapis', da se onda na masci automatski podesi potraživanje na 23 (korisniku bi se odmah ponudilo ispravno potraživanje).

U prilogu vam šaljemo ponudu za navedene kontrole.
 

