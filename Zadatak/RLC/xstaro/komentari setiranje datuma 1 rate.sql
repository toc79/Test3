Init (datum sklapanja se puni s današnjim datumom)
dat_sklen WITH DATE(), ;

Test na 3.0.4
Ako ponuda nema datum 1. rate, onda je txtZap_2ob  bude prazan.

Ako ponuda ima unesen datum 1. rate:
- ako se datum ponude jednak datumu sklapanja, tada je datum 1. rate na poonudi jednak datumu 1. rate na ugovoru - OK
- ako je datum sklapanja drugačiji od datuma ponude, dolazi do promjene datuma 1. rate (prema dolje (PROCEDURE set_zap_2ob koja je uzeta s 2.22. source) - U TOM SLUČAJU IM TREBA SETIRANJE.

U slučaju Tip dat. dok (TDD):
- ako je datum ponude i sklapanja različit, datum 1. rate bude kao na ponudi - OK.
- ako se datum sklapanja promijeni (u slučaju datuma ponude u prošlosti), tada dolazi do promejne datuma 1. rate na neodgovarajući. Prolaskom kroz polje Tip dat. dok se dobro setira - OK.
Oko takvog postavljanja datuma 1. rate s obzirom na promjenu datuma sklapanja, poslali smo mail 22.5.2017 15:09 sa zahtjeva GMC $MR(35539) ([Ticket #14574] Masovna aktivacija)
oko kojeg je otvoren GMI MR 63266 (bug je naveden u prilogu pod naslovom 'BUG prolaskom kroz polja kod unosa ugovora').
http://mail.gmi.si:81/support/maintenance.aspx?Mode=Read&Source=3&Document=63266&ID=63266


Možemo odmah ponuditi/podesiti
1. da koriste Tip dat. dok
2. programiranje datuma 1. rate u eksternoj funkciji POGODNA_MASKA_ZAP_2OB_WHEN (ulazak u polje polje txtZap_2ob tj. datum 1. rate)

ili 
3. možda da vidimo u GMI da li će se raditi kakva dorada (i na koji način). RLC za sada ne koristi Tip dat. dok





pripremio bi rješenje za rlc oko jednog zahtjeva,  pa mi je potrebna informacija da li se procedura 
PROCEDURE set_zap_2ob na masci pogodba_maska.SC2
mijenjala u 3.0 zapravo u zadnjoj kojoj možeš 
http://gmcv03/support/Maintenance.aspx?Mode=Read&Source=3&Document=38259&ID=38259
ako se nisu mijenjala, rješenja su 
1. da koriste datum_dok_tip
2. ili da se programira eksterna funkcija POGODBA_MASKA_ZAP_2OB_WHEN



Init
dat_sklen WITH DATE(), ;

Ako ponuda nema datum 1. rate, onda je txtZap_2ob  bude prazan.

Ako ponuda ima unesen datum 1. rate:
- ako se datum ne promijeni, bude kao na ponudi.
- ako se datum sklapanja promijeni, (i kod ugovora Tip dat. dok) dolazi do promjene datuma 1. rate. Prolaskom kroz polje Tip dat. dok se setira ispravno.

Kod ugovora s Tip dat. dok (TDD) 


Oko postavljanja datuma 1. rate s obzirom na promjenu datuma sklapanja, poslali smo mail 22.5.2017 15:09 sa zahtjeva GMC MR 35539([Ticket #14574] Masovna aktivacija)
oko kojeg je otvoren GMI MR 63266 (bug je naveden u prilogu pod naslovom 'BUG prolaskom kroz polja kod unosa ugovora')

Otvoren GMI MR 63266
u dijelu pod naslovom 
'BUG prolaskom kroz polja kod unosa ugovora'


22.5.2017 15:09
GMC MR 35539
[Ticket #14574] Masovna aktivacija


Poštovani, 


Ako zbog navedene logike će biti slučaja da datum 1. rate nije isti kao datum 1. rate na ponudi, tada može


