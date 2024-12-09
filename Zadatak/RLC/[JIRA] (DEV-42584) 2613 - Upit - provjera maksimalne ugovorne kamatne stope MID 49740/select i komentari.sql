--podešavanja na produkciji 

--LICENCA 
LE_CHECK_MAX_INTEREST_RATE

--ŠIFRANT PPKS

--po firmama
RLC
update dbo.NASTAVIT set check_max_ir = 1, ZAKONZOM = '01', ppom = '24', max_ir = '04' 
update dbo.REP_TYPE set DESCRIPTION = 'Objašnjenje kamatne stope' where ID_REP_TYPE = 'IRE'
update dbo.REP_TYPE set DESCRIPTION = 'Prijenos pravnog nasljedstva' where ID_REP_TYPE = 'LOT'
update dbo.REP_TYPE set DESCRIPTION = 'Posebnosti partnera' where ID_REP_TYPE = 'PPS'

insert into dbo.obr_zgod (datum, id_obr, vrednost, vnesel, dat_vnosa) values ('20240101', '24', 5.61, 'g_tomislav', getdate())
--eksterna funkcija POGODBA_AKT_CONTRACT_ACTIVATE


ESL
update dbo.NASTAVIT set check_max_ir = 1, ZAKONZOM = '01', ppom = '25' --, max_ir = '11' --došlo s hotfix 6 za verziju 7.15, koja je podešena 21.6.2024
update dbo.NASTAVIT set  max_ir = '11' -- 27.08.2024
update dbo.REP_TYPE set DESCRIPTION = 'Objašnjenje kamatne stope' where ID_REP_TYPE = 'IRE'
update dbo.REP_TYPE set DESCRIPTION = 'Prijenos pravnog nasljedstva' where ID_REP_TYPE = 'LOT'
update dbo.REP_TYPE set DESCRIPTION = 'Posebnosti partnera' where ID_REP_TYPE = 'PPS'
--eksterna funkcija POGODBA_AKT_CONTRACT_ACTIVATE
-- ispis REP_IND 
--PODESIO NA PRODUKCIJU

UCL
update dbo.NASTAVIT set check_max_ir = 1, ZAKONZOM = '01', ppom = '14'
update dbo.NASTAVIT set  max_ir = '04'
update dbo.REP_TYPE set DESCRIPTION = 'Objašnjenje kamatne stope' where ID_REP_TYPE = 'IRE'
update dbo.REP_TYPE set DESCRIPTION = 'Prijenos pravnog nasljedstva' where ID_REP_TYPE = 'LOT'
update dbo.REP_TYPE set DESCRIPTION = 'Posebnosti partnera' where ID_REP_TYPE = 'PPS'
--eksterna funkcija POGODBA_AKT_CONTRACT_ACTIVATE

BKS
update dbo.NASTAVIT set check_max_ir = 1, ZAKONZOM = '01', ppom = '09', max_ir = '04'
update dbo.REP_TYPE set DESCRIPTION = 'Objašnjenje kamatne stope' where ID_REP_TYPE = 'IRE'
update dbo.REP_TYPE set DESCRIPTION = 'Prijenos pravnog nasljedstva' where ID_REP_TYPE = 'LOT'
update dbo.REP_TYPE set DESCRIPTION = 'Posebnosti partnera' where ID_REP_TYPE = 'PPS'

--eksterna funkcija POGODBA_AKT_CONTRACT_ACTIVATE

--eksterna funkcija POGODBA_AKT_MULTIPLE_CONTRACT_ACTIVATE

-- nova_core_ExFunc__LE_ActivationContractMultiple_Check__Content ver_1.sql
-- u toj opciji aktivacije bez datuma se ne mogu aktivirati ugovori financijskog leasinga EMultipleActSingleErr

-- kraj potrebnih podešavanja za produkciju 

--TODO
/*Ostao je još jedan slučaj koji je Matjaž Barič rekao da će naknadno popraviti => mislim da je bilo riječ o slučaju kada se poveća indeks a smanji kamata zbog ograničavanja KS, i suprotno, kada se smanji indeks a poveća kamata => za oba slučaja se reprogram zbog promjene indeksa može napraviti podešavanje tolerance u custom_settings

*/


prebacivanje šifranta PPKS - prosječna ponderirana kamatna stopa i njegovih vrijednosti s testa na produkciju??
podešavanje šifranta kao neaktivnog??

--Na ESL sam podesio radi testiranja
select * from dbo.custom_settings where code = 'Nova.LE.RpgIndexChange.ClaimAmountTolerance'
update dbo.custom_settings set val = '100' where code = 'Nova.LE.RpgIndexChange.ClaimAmountTolerance' --bilo 0 

---------
--selecti
---------

select top 1 drzava, zakonzom, ppom, max_ir, check_max_ir, * from dbo.nastavit 
select * from dbo.REP_TYPE where ID_REP_TYPE in ('IRE', 'LOT', 'PPS')

select pog.id_pog, pog.dej_obr, x.max_ir_used , x.max_allowedIR, x.*
from dbo.pogodba pog
inner join dbo.PARTNER par on pog.id_kupca = par.id_kupca
inner join dbo.vrst_ose vo on par.vr_osebe = vo.vr_osebe
cross join dbo.NASTAVIT n
cross apply dbo.gfn_CalculateMaxAllowedIR(pog.dej_obr
			, pog.vr_val_zac
			, case when vo.sifra = 'FO' then 1 else 0 end
			, pog.nacin_leas, 
			cast(cast(getdate() as date) as datetime)
		) x
where n.check_max_ir = 1
and pog.id_cont = 70453
-- and pog.STATUS_AKT = 'A'
-- and n.check_max_ir = 1
-- and max_ir_used = 1

select id_cont, id_pog, 'EFaktZac' as err
from 
    dbo.pogodba po
    inner join dbo.nacini_l nl on po.nacin_leas = nl.nacin_leas
where
    nl.fakt_zac <> ''

Kamatna stopa: 18,0000
Najviša dopuštena KS: 11,2500
Datum reprograma: 11.4.2024. 0:00:00
Zakonska zatezna kamata: 12,5000
Datum ZZK: 1.1.2024. 0:00:00
Prosječno ponderirana KS: 5,6100
Datum PPKS: 1.1.2024. 0:00:00
Formula: ZZK * 1.5
Fizička osoba: True
Iznos: 17.219,71
Tip financiranja: OA

--provejra na maksimalnu unesenu stopu u šifrant radi provjere da li imaju za koga zateznu kamatu veću od zakonske 
select * from dbo.OBR_ZGOD
select o.*, oz.* 
from dbo.OBRESTI o
outer apply (select top 1 vrednost from dbo.obr_zgod where id_obr = o.id_obr order by datum desc) oz
order by vrednost desc


select kf.nacin_leas as tip_leas, kf.naziv, dbo.gfn_Nacin_leas_HR(nl.nacin_leas) as grupa_leas, tip_knjizenja as Booking_type,  * 
from dbo.NACINI_L nl
join dbo.KALK_FORM kf on nl.nacin_leas = kf.NACIN_LEAS
where kf.neaktiven = 0


select *
from dbo.rep_ind ri
where TIMESTAMP >= '20231223'
and exists (select * from dbo.reprogram ind where ind.ID_REP_TYPE = 'IND' and ind.ID_CONT = ri.ID_CONT and ABS(datediff(second, ind.[time], ri.[TIMESTAMP])) < 6) -- postoji IND reprogram unutar 5 sekundi
and exists (select * from dbo.reprogram ind where ind.ID_REP_TYPE = 'IRE' and ind.ID_CONT = ri.ID_CONT and ABS(datediff(second, ind.[time], ri.[TIMESTAMP])) < 6) -- postoji IRE reprogram unutar 5 sekundi

select ABS(datediff(second, ind.[time], ri.[TIMESTAMP])) as razlika_u_sekundama
	, datediff(second, ind.[time], ri.[TIMESTAMP]) as razlika_u_sekundama_bez_ABS
	, ri.[TIMESTAMP], ind.[time]
	, *
from dbo.rep_ind ri
cross apply (select * from dbo.reprogram ind where ind.ID_REP_TYPE = 'IND' and ind.ID_CONT = ri.ID_CONT) ind --and ABS(datediff(second, ind.[time], ri.[TIMESTAMP])) < 6) ind
where TIMESTAMP >= '20231223'


--selecti i skripte za testiranje 

select * from dbo.foureyes_request_type 
--update dbo.foureyes_request_type  set inactive = 1 where code = 'Le.InterestsHistory.Delete'
--update dbo.foureyes_request_type  set inactive = 1 where code = 'Le.Reprogram.Manual'
--update dbo.foureyes_request_type  set inactive = 1 where code = 'Le.Rep.IndexChange'
--update dbo.foureyes_request_type  set inactive = 1 where code = 'Le.InterestIndexHistory.InsertUpdate'
--update dbo.foureyes_request_type  set inactive = 1 where code = 'Le.InterestsHistory.InsertUpdate'

select * from dbo.CUSTOM_SETTINGS where code like '%staging%'

--update dbo.CUSTOM_SETTINGS set val = '1' where code = 'Nova.Config.Staging.Enabled'

/*p1 = 11
p2 = 26250
p3 = .T.
p4 = '2'
p5 = '20231222'
*/
declare @datum datetime = getdate()

select top 3 oz.vrednost, oz.id_obr, oz.datum  
        from   
            dbo.obr_zgod oz  
            inner join nastavit n on oz.id_obr = '04' --n.zakonzom  
        where  
            oz.datum < @datum 
        order by   
            oz.datum desc  

SELECT convert(datetime, '20230701') as datum_ponude, max_ir_used, max_allowedIR, * FROM dbo.gfn_CalculateMaxAllowedIR(11, 26250, 1, '2', '20230701')
SELECT convert(datetime, '20230702') as datum_ponude, max_ir_used, max_allowedIR, * FROM dbo.gfn_CalculateMaxAllowedIR(11, 26250, 1, '2', '20230702')
GMC 28.12.2023: podešeno je tako da npr. na datum ponude 1.7.2023 će maksimalna KS biti 8,25% (5,5*1,5), za na 2.7.2023 će biti 10,5% (7*1,5) za PPKSm, za sljedeću povijest kamatnih stopa iz šifranta 

podesiti oz.datum <= @datum ?

-- select cmair.*, p.obr_mera, p.vr_val, p.je_foseba, p.*
-- from dbo.ponudba p
-- join dbo.NACINI_L nl on p.nacin_leas = nl.nacin_leas
-- outer apply gfn_CalculateMaxAllowedIR(p.obr_mera, vr_val, je_foseba, nl.tip_knjizenja, p.dat_pon) cmair
-- where id_pon = '0301196'


-- select cmair.*, pog.obr_mera, pog.vr_val, p.je_foseba, pog.*
-- from dbo.pogodba pog
-- join dbo.ponudba p on pog.id_pon = p.id_pon
-- join dbo.NACINI_L nl on p.nacin_leas = nl.nacin_leas
-- outer apply gfn_CalculateMaxAllowedIR(pog.obr_mera, pog.vr_val, p.je_foseba, nl.tip_knjizenja, getdate()) cmair
-- where pog.id_cont = 83825

-- select cmair.*, pog.dej_obr, pog.obr_mera, pog.vr_val, p.je_foseba, pog.FIX_DEL, pog.RIND_ZADNJI
	-- , pog.FIX_DEL + pog.RIND_ZADNJI as new_dej_obr
	-- , pog.RIND_DAT_NEXT, pog.ID_RTIP, pog.ID_RIND_STRATEGIJE, pog.*
-- from dbo.pogodba pog
-- join dbo.ponudba p on pog.id_pon = p.id_pon
-- join dbo.NACINI_L nl on p.nacin_leas = nl.nacin_leas
-- outer apply gfn_CalculateMaxAllowedIR(pog.obr_mera, pog.vr_val, p.je_foseba, nl.tip_knjizenja, getdate()) cmair
-- where pog.id_cont = 83826
/*
FIX_DEL	RIND_ZADNJI	RIND_DAT_NEXT	ID_CONT
7.0500	3.9500	2024-03-10 00:00:00.000	83826
*/
--update dbo.pogodba set RIND_DAT_NEXT = '20231210'  where id_cont = 83826

gfn_CalculateMaxAllowedIR izračunava maksimalnu kamanu stopu
 
PPKS prosječna ponderirana kamatna stopa za potrošače za određeni period
za Potrošačko kreditiranje prosječna ponderiranja kamatna stopa postavka je 
ppom
sada je 7%
7 * 1,5 = 10,5

ZZK zakonska zatezna kamata za određeni period i vrstu osobe
za Zakon o obveznim odnosima (FO i PO)
zakonzom
sada je 12%
12 * 1.5 = 18

select dej_obr, count(*) as broj_ugovora from dbo.pogodba where status_akt = 'A' group by dej_obr order by 1 desc
Najveća je 
RLC  9.4550
ESL
12.4550	1
10.8310	1
10.8050	1
10.7050	2
10.5000	1
10.4550	2
10.4420	1
10.2050	1
10.1830	1
10.1660	1
10.1650	1
10.1050	1
10.0770	1
10.0240	1
10.0030	2
9.9980	1
9.9650	5
9.9630	1
9.9550	1
9.9450	6


Zapisuje se originalna marža tj. ne mijenja marža na ugovoru. 


RE: #Gemicro ID:49712#Customer ID:160578# Indeksacija - najviše dopuštene kamatne stope
Poštovani,
Potvrđujemo da ste dobro shvatili vezano za dolje iznimku, s time da se gleda iznos financiranja, a ne vrijednosti ugovora, preko 132.723,00 EUR.
Lp,Mario
Provjeriti kontrolu na ESL 
i ako je onda treba z aRPG zbog promjene indeksa doraditi gv_RepIndCandidates


https://www.teb.hr/novosti/2023/zatezne-i-ugovorne-kamate-od-172023/
nova objava
https://www.teb.hr/novosti/2024/zatezne-i-ugovorne-kamate-od-112024-do-3062024-1/


https://www.teb.hr/novosti/2023/prosjecne-ponderirane-kamatne-stope-na-stanja-stambenih-i-ostalih-potrosackih-kredita-nar-nov-br-7223/


https://narodne-novine.nn.hr/clanci/sluzbeni/2023_06_69_1143.html
nema novih objava


ako će varijabilna kamata biti veća od zakonske => to se ne može desiti


[Matjaž Barič wrote at 21.4.2023 14:52]
Pozdrav,
Kamatne stope će se unositi u Održavanje| Šifranti| Ugovori| Kamatne stope. U nastavit.zakonzom i nastavit.ppom će biti samo definirana šifra (ID_OBR). U funkciji čemo onda uzeti vrijednost KS (zato je jedan od parametra datum, kako bi uzeli zadnju vrijednost koja nije novija od tog datuma) i koristiti formulu koju ste poslali - u funkciji če se umnožiti sa 0.5 ili 0.75. Vjerojatno će morati dodati PPKS ako ju nemaju u tom šifrantu i unositi vrijednosti. Isto mogu dodati i novu ZZK te unositi vrijednost samo 2 puta godišnje.


Poštovani,

U okviru ovoga projekta uvođenja najviše dopuštene kamatne stope, morali bi također i podesiti ispis za one ugovore kod kojih je utvrđena da je premašena stopa, te primijenjena najviše dopuštena.
Naime, u obavijestima o novim iznosima kamata, klijente trebamo izvijestiti da je ugovorna kamata veća i da smo je smanjili do zakonom dozvoljene.

U privitku dostavljamo za primjer dva ispisa:
1. inicijalni ispis koji se trenutno šalje klijentima bez navođenja obavijesti da je premašena ugovorna kamata
2. željeni ispis koj sadrži informaciju da je ugovorna kamata viša od najviše dopuštete ugovorne kamate, i da će se u predmetnom razdoblju primijeniti najviše dopuštena kamatna stopa.

Za sva pitanja, stojim Vam na raspolaganju.
Lijepi pozdrav,
Mario 
1	External functions	POTROSACKO_KREDITIRANJE_IZNOS	EXT_FUNC	KALK_L_BTNDODAJ_RETURN                                                                              	KALK_L_BTNDODAJ_RETURN                                                                             	FOX                 
2	External functions	POTROSACKO_KREDITIRANJE_IZNOS	EXT_FUNC	KALK_L_PONUDBA_PREVERI_PODATKE                                                                      	KALK_L_PONUDBA_PREVERI_PODATKE                                                                      	FOX                 
3	External functions	POTROSACKO_KREDITIRANJE_IZNOS	EXT_FUNC	POGODBA_MASKA_PREVERI_PODATKE                                                                       	POGODBA_MASKA_PREVERI_PODATKE                                                                       	FOX                 
4	External functions	POTROSACKO_KREDITIRANJE_IZNOS	EXT_FUNC	POGODBA_MASKA_SET_DEF_VALUES                                                                        	POGODBA_MASKA_SET_DEF_VALUES                                                                        	FOX                 
5	External functions	POTROSACKO_KREDITIRANJE_IZNOS	EXT_FUNC	POGODBA_UPDATE_PREVERI_PODATKE                                                                      	POGODBA_UPDATE_PREVERI_PODATKE                                                                      	FOX                 
6	MRT reports	POTROSACKO_KREDITIRANJE_IZNOS		KALK_SSOFT_ESL                	KALK_SSOFT_ESL                	MRT
7	MRT reports	POTROSACKO_KREDITIRANJE_IZNOS		PLANP_ARCHIVE_DMS_SSOFT_ESL   	PLANP_ARCHIVE_DMS_SSOFT_ESL   	MRT
8	MRT reports	POTROSACKO_KREDITIRANJE_IZNOS		PLANP_PK_SSOFT_ESL            	PLANP_PK_SSOFT_ESL            	MRT
9	MRT reports	POTROSACKO_KREDITIRANJE_IZNOS		PLANP_SSOFT_ESL               	PLANP_SSOFT_ESL               	MRT
10	MRT reports	POTROSACKO_KREDITIRANJE_IZNOS		POGODBA_SSOFT_ESL             	POGODBA_SSOFT_ESL             	MRT
11	MRT reports	POTROSACKO_KREDITIRANJE_IZNOS		PONUDBA_SSOFT_ESL             	PONUDBA_SSOFT_ESL             	MRT
12	Print selection / Code before	POTROSACKO_KREDITIRANJE_IZNOS	frmPogDashboard	PLAN OTPLATE - POTR. KRED. TIJEKOM UG. Stimulsoft 	PLANP_PK_SSOFT_ESL            	MRT