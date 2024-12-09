--select id_cont from dbo.default_events 
--group by id_cont 
--having count(*) > 2
select * from dbo.default_events where id_kupca = '030678'
select asset_clas , * from dbo.partner where id_kupca = '030678'

select distinct asset_clas from dbo.partner 
select distinct asset_clas from dbo.p_eval

Draga Diana,

u sklopu projekta novog EBA brojača u RETAIL segmenu, javila se potreba za razmjenom podataka sa RBHR na tjednoj bazi, pa Vas lijepo molimo da proslijedite slijedeći zahtjev u Gemicro.

Hvala,
Petra
**********************************************************************************************
Potrebno je kreirati 2 CSV file-a, u svrhu razmjene podataka sa RBHR:
1. Defaulted PI & Micro contracts
2. Cured from Default PI & Micro contracts

I) Kreiranja exporta:

Tabela 1. Defaulted PI & Micro contracts
Polja, na razini ugovora/ CONTRACT LEVEL:

- EFFECTIVE_DATE -> datum kada se povlače podaci/datum postavljanja tabele na lokaciju za razmjenu
- COCUNUT_ID -> Coconut klijenta (relevantno za Micro segment)
- REGISTRATION_NUMBER (OIB-unique external identification ID of the client) -> OIB klijenta
- CUST_ID (internal unique client ID) -> šifra partnera
- ACC_ID (internal unique contract ID) -> broj ugovora
- ASSET_CLASS_ID (01 for PI, 20 for Micro) -> segmentacija

- DEFAULT_STATUS -> status defaulta : TRUE/FALSE
- DEFAULT_START_DATE -> datum ulaska u default
- EBA_DPD -> EBA broj dana dugovanja
- ACC_STATUS -> Active/Closed

Tabela 2. Cured from Default PI & Micro contracts
Polja, na razini ugovora/ CONTRACT LEVEL:
- EFFECTIVE_DATE -> datum kada se povlače podaci/datum postavljanja tabele na lokaciju za razmjenu
- COCUNUT_ID -> Coconut klijenta (relevantno za Micro segment)
- REGISTRATION_NUMBER (OIB-unique external identification ID of the client) -> OIB klijenta
- CUST_ID (internal unique client ID) -> šifra partnera
- ACC_ID (internal unique contract ID) -> broj ugovora
- ASSET_CLASS_ID (01 for PI, 20 for Micro) -> segmentacija
- DEFAULT_STATUS -> status defaulta : TRUE/FALSE
- DEFAULT_START_DATE -> datum ulaska u default
- DEFAULT_END_DATE -> datum izlaska iz default
- EBA_DPD -> EBA broj dana dugovanja
- ACC_STATUS -> Active/Closed

II) Automatski job koji bi pokretao izvoz tih podataka i spremanje na dogovorenu lokaciju, uz info kroz LN odgovornim osobama u procesu. Disk za razmjenu [cid:_1_0CEA34C00CEA3198004869FAC12584A2]
Frekvencija pripremanja: TJEDNO ( prijedlog datuma za razmjenu datoteka: 01., 08., 15. i 22. u mjesecu)
