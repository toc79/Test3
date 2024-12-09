--podešavanja na produkciji
select IMA_VRED, polji_vrednost_obvezni, * from dbo.dok where ID_OBL_ZAV in ('ZE', 'ZB', 'ZC', 'Z2', 'Z4', 'ZY')
update dbo.dok set IMA_VRED = 1, polji_vrednost_obvezni = 1 where ID_OBL_ZAV in ('ZE')
update dbo.dok set IMA_VRED = 1, polji_vrednost_obvezni = 0 where ID_OBL_ZAV in ('ZB', 'ZC', 'Z2', 'Z4', 'ZY')

select IMA_VRED, polji_vrednost_obvezni, * from dbo.dok where ID_OBL_ZAV between 'B1' and 'B6' --in ('ZE', 'ZB', 'ZC', 'Z2', 'Z4', 'ZY')
update dbo.dok set IMA_VRED = 1 where ID_OBL_ZAV between 'B1' and 'B6'

-- 3 eksterne funkcije

-- dodatna rutina Pregled iskorištenosti limita ZT zadužnice
update dbo.dok set je_collat = 1 where ID_OBL_ZAV in ('ZT')

--provjeriti  da li je dorađena gv_ObstojaKrovDok i procedura za insert dokumenata iz odobrenja na ugovor

-- Provjere
-- Svi dokumenti imaju IMA_PART podešen
select IMA_VRED, polji_vrednost_obvezni, ima_part, * from dbo.dok where ID_OBL_ZAV in ('B1', 'B2', 'B3', 'B4', 'B5', 'B6', 'ZE', 'ZB', 'ZC', 'Z2', 'Z4', 'ZY') -- 


--KRAJ podešavanja na produkciji




declare @id varchar(100) = '0290392'

--select  * into #planp from dbo.gfn_GenerateAmortisationPlan4Offer(@id)

select ost_obr_b
	, traj_naj
	, opcija
	, (ost_obr_b * traj_naj) + opcija as iznosZaB3_B6
	, pon.*
from dbo.ponudba pon
where pon.id_pon = @id

/*
Testiranje

TODO za GMI?
kod unosa šifre partnera Osobe u tablici osiguranja, poslije se ne može obrisati ta šifra. Tako radi i u 7.15


Kontrola za obavezna unos parnera vrijede za dokumente ugovora (za krovne dokumente nije napravljeno po podešavanje).

update dbo.dok set ali_na_pog = 1 where ID_OBL_ZAV in ('ZE') -- da bi se prikazao i prenio na ugovor
pa to javiti RLC da testiraju ispis ugovora i ostale ispise vezane na ugovor 

još jednom testirati i provjeriti u sourcu prebacivanje dokumenata na ugovor sa odobrenja 

ne pune se iz odobrenja svi podaci već prema proceduri gsp_TransferDocFromApproval

Pozdrav, 

testirao sam implementaciju te da bi se napravile dorade za RLC prema zahtjevu, potrebne su još sljedeće dvije dorade: 
A) dorada dbo.gv_ObstojaKrovDok dodavanje kolone id_cont i id_obl_zav, kako bi se mogao odgovarajuće podesiti uvjet u novim eksternim funkcijama. U privitku šaljem primjer dorađenog view-a.

B) Prebacivanje podataka dokumenta sa odobrenja (dbo.odobrit_zavar) na dokument ugovora. Naime, kod dokumenta ALI_NA_POG = 1, podaci dokumenta odobrenja se prenesu u masku za unos ugovora i onda se tako kreira dokument ugovora te je to u redu. 
Kod dokumenta ALI_NA_POG = 0, prenese se samo podatak KOLICINA, što je vidljivo u proceduri dbo.gsp_TransferDocFromApproval.
Možda bi najbolje rješenje bilo da se napravi dorada procedure dbo.gsp_TransferDocFromApproval na način da se dodaju i ostale kolone/podaci popunjeni na dokumentu odobrenja (dbo.odobrit_zavar). U privitku šaljem primjer dorađene procedure. 

*/

select top 2 * from dbo.gv_ObstojaKrovDok
--select top 2 * from dbo.gfn_Odobrit_Zavar_View
select top 2 * from dbo.odobrit_zavar

select * from dbo.gv_ObstojaKrovDok 
where id_cont is null 
and id_obl_zav = 'ZT'
and id_kupca_dok = '019623'

SELECT TOP 200 id_dokum,opis,id_kupca_dok,naz_kr_kup_dok,id_frame,opis_frame,st_krov_pog,opis_kp,id_kupca_entity,naz_kr_kup_entity,vrednost FROM dbo.gv_ObstojaKrovDok WHERE id_cont is null and id_obl_zav = 'ZT' and id_kupca_dok = '038855' ORDER BY 1 ASC


/*--------------------------------------------------------------------------------------------------------
 View: used for searching documentation select for documentation collection preview
 History:
26.03.2018 MatjazB; Task 13002 - created
06.05.2024 MitjaM; MID 130876 - added vrednost
--------------------------------------------------------------------------------------------------------*/
--CREATE VIEW [dbo].[gv_ObstojaKrovDok]
--AS
select * from (
	select
		d.id_dokum, 
		case 
			when d.id_krov_dok is not null then rtrim(ltrim(d.opis)) + ' (' + cast(d.id_krov_dok as varchar(20)) + ')'
			else d.opis
		end as opis,
		d.id_kupca as id_kupca_dok, 
		case 
			when fl.id_kupca is not null then fl.id_kupca
			when kp.id_kupca is not null then kp.id_kupca
			when pog.id_kupca is not null then pog.id_kupca
			else null
		end as id_kupca_entity,
		case 
			when fl.id_kupca is not null then p1.naz_kr_kup
			when kp.id_kupca is not null then p2.naz_kr_kup
			when pog.id_kupca is not null then p3.naz_kr_kup
			else null
		end as naz_kr_kup_entity,
		fl.id_frame, fl.opis as opis_frame, 
		p.naz_kr_kup as naz_kr_kup_dok, 
		kp.id_krov_pog, kp.st_krov_pog, kp.opis_pog as opis_kp,
		d.VREDNOST
		, d.id_cont--, d.id_krov_pog, d.id_frame --d.id_pon , d.id_odobrit
		, d.id_obl_zav
	from
		dbo.dokument d
		left join dbo.frame_list fl on fl.id_frame = d.id_frame
		left join dbo.krov_pog kp on kp.id_krov_pog = d.id_krov_pog
		left join dbo.pogodba pog on pog.id_cont = d.id_cont
		left join dbo.partner p on p.id_kupca = d.id_kupca
		left join dbo.partner p1 on p1.id_kupca = fl.id_kupca
		left join dbo.partner p2 on p2.id_kupca = kp.id_kupca
		left join dbo.partner p3 on p3.id_kupca = pog.id_kupca
	) a
where id_cont is null 
and id_obl_zav = 'ZT'
and id_kupca_dok = '019623'




Poštovana/i,

šaljem komentare na vaše natuknice:
- U tabu Osiguranje, prilikom odabira vrste dokumenta omogućiti odabir bilo kojeg partnera, umjesto trenutne mogućnosti odabira samo primatelja leasinga
GMC: može se unijeti i jamci uneseni u tablicu iznad. Želite dakle unijeti i neke druge partnere pa molim samo detaljnije objašnjenje u koju svrhu bi ih unosili (npr. prema slici to bi mogao biti partner garancije povratnog otkupa ili dobavljač).

- Partner unesen u dokument u odobrenje se treba preslikati u polje Partner (dokument.id_kupca) dokumenta u ugovoru
GMC: koliko sam testirao, kod unosa ugovora se prenese taj podatak pa tu ne bi trebalo biti dorade? Da li ste mislili na dokumente kojima se ne može unijeti podatak u polje Partner? Da li su to dokumenti navedeni ispod B1, B2, B3, B4, B5, B6, ZE, ZB, ZC, Z2, Z4, ZY?

- U tabu Osiguranje (npr.u stupac „Do iznosa“, omogućiti unos iznosa, koji će se također preslikati u dokument u ugovoru (dokument.vrednost)
GMC: koliko sam testirao, kod unosa ugovora se prenese taj podatak u Vrijednost pa tu ne bi trebalo biti dorade? Da li ste mislili na dokumente kojima se ne može unijeti podatak u polje Vrijednost te koji su to dokumenti?

- Podesiti obavezan unos partnera u odobrenju za dokumente B1, B2, B3, B4, B5, B6, ZE, ZB, ZC, Z2, Z4, ZY
GMC: ok. Da li taj podatak mora biti obavezan i kod unosa/popravka dokumenta na masci/mapi dokumenta?

- Podesiti obavezan unos iznosa u odobrenju za dokumente ZE, ZB, ZC, Z2, Z4, ZY
GMC: ok. Da li taj podatak mora biti obavezan i kod unosa/popravka dokumenta na masci/mapi dokumenta?

- Dodati ili prenamijeniti jedan stupac u kojem bi se omogućio opcionalan unos broja ovjere zadužnice „Broj OV“, koji bi se preslikao u polje „Broj“ (dokument.stevilka) u dokumentu u ugovoru
GMC: ok



za GMI

Poštovani,
Molimo doradu u modulu odobrenja.

- U tabu Osiguranje, prilikom odabira vrste dokumenta omogućiti odabir bilo kojeg partnera, umjesto trenutne mogućnosti odabira samo primatelja leasinga
GMC: može se unijeti i jamci uneseni u tablicu iznad. Klijent dakle želi i neke druge partnere npr. prema slici to bi mogao biti partner garancije povratnog otkupa ili dobavljač.

- Partner unesen u dokument u odobrenje se treba preslikati u polje Partner (dokument.id_kupca) dokumenta u ugovoru
GMC: koliko sam testirao, kod unosa ugovora se prenese taj podatak pa tu ne bi trebalo biti dorade? Možda klijent misli na neke dokumente kojima polje Partner nije omogućena pa je ovdje potrebno samo podesiti Ima partnera u šifrantu?

- U tabu Osiguranje (npr.u stupac „Do iznosa“, omogućiti unos iznosa, koji će se također preslikati u dokument u ugovoru (dokument.vrednost)
GMC: koliko sam testirao, kod unosa ugovora se prenese taj podatak pa tu ne bi trebalo biti dorade? Možda klijent misli na neke dokumente kojima polje Vrijednost nije omogućena pa je ovdje potrebno samo podesiti Ima vrijednost u šifrantu?

- Podesiti obavezan unos partnera u odobrenju za dokumente B1, B2, B3, B4, B5, B6, ZE, ZB, ZC, Z2, Z4, ZY
GMC: možemo mi/GMC podesiti kontrolu kroz eksternu funkciju ODOBRIT_MASKA_CUSTOM_CHECK kod spremanja odobrenja, isto tako i na masci frmDokument _maska u ext_func DOKUMENT_MASKA_SET_CTRL_MANDATORY? Ili bi se dodao novi parametar/kolona u DBO.DOK i na svim mjestima u aplikaciji da se podesi obaveznost unosa tog podatka?

- Podesiti obavezan unos iznosa u odobrenju za dokumente ZE, ZB, ZC, Z2, Z4, ZY
GMC: možemo mi/GMC podesiti kontrolu kroz eksternu funkciju ODOBRIT_MASKA_CUSTOM_CHECK kod spremanja odobrenja, isto tako i na masci frmDokument _maska u ext_func DOKUMENT_MASKA_SET_CTRL_MANDATORY? Ili bi se dodao novi parametar/kolona u DBO.DOK i na svim mjestima u aplikaciji da se podesi obaveznost unosa tog podatka?
=> u šifrantu imamo postavku Obavezan unos vrijednosti pa ne treba u ext_func

- Dodati ili prenamijeniti jedan stupac u kojem bi se omogućio opcionalan unos broja ovjere zadužnice „Broj OV“, koji bi se preslikao u polje „Broj“ (dokument.stevilka) u dokumentu u ugovoru
GMC: u dbo.Odobrit_zavar nema kolone stevilka niti na masci. Da li bi se dodala kolona stevilka i podesilo preslikavanje na ugovorni dokument?


- Podesiti obavezan unos iznosa u odobrenju za dokumente ZE, ZB, ZC, Z2, Z4, ZY



