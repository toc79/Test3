/*
http://mail.gmi.si:81/support_prod/task.aspx?Mode=Read&Document=10209&Source=2&ID=10209

select * from dbo.ext_func where ID_EXT_FUNC like '%poci%'
select * from dbo.CUSTOM_SETTINGS where code like '%poci%'
code	val	description
Nova.LE.EnableCalculationOfPOCIControl	true	Is button for POCI visible on rpg mask.


Pozdrav,

1. molim da nam proslijedite odgovor koji ste slali RLCu kako bi i mi imali tu informaciju.

2. Da li postoji kakva projektna dokumentacija pa da nam i to pošaljete?

3. Oni bi htjeli da im se dostavi specifikacija tj. koje točno varijable uzima kod izračuna diskontoranog cashflowa.
To se koliko vidim računa u proceduri grp_PociCalculationResponse, pa bi im za to odgovorili da se diskontirani tok (za novi i stari plan otplate) za iznos Duguje računa prema konformnoj metodi za 365 dana, a u izračunu se koristi podatak EKS (trenutnog ili onog unesenog na masci) i Dat.dok (datum dokumenta). Ispravite me ako sam nešto krivo napisao.

4. Nisam našao točnu informaciju kako se ugovor označava s POCI flagom, navedeno je u tasku TASK 10209:
"Direktiva za izračun POCI narekuje, da se pogodba označi s POCI flagom v primeru, ko je razlika med vsoto diskontiranih plačil pred restrukturo in po restrukturi večja od določenega odstotka vseh plačil."
da li to znači da ako je relativna razlika (relative_diff) negativna da se onda POCI flag dodaje na ugovor ili ako je taj postotak veći od određenog u nekoj postavci ili to RLC treba definirati?

5. Trenutno znači ne postoji automatizam koji bi dodavao POCI oznaku na ugovor (kategorija entiteta)?



		Thisform.p_tip_izracuna = "K"
		Thisform.p_metoda_izracuna = "K365"

Iz kreditnih ugovora => "izaberemo između R - relativne kamatne stope i K - konformne kamatne stope (kamatna stopa se može izračunati po relativnom ili konformnom izračunu);"

Ugovor se označi sa POCI oznakom u slučaju kada je razlika između sume diskontiranih plaćanja prije restrukture i nakon restrukture veća od određenog postotka svih plaćanja.

<poci_calculation xmlns='urn:gmi:nova:leasing'>
<id_cont>64030</id_cont>
<eom>6.2933</eom> 									//trenutna EKS
<tip_izracuna>K</tip_izracuna>
<metoda_izracuna>K365</metoda_izracuna>
<id_reprogram_old>1512933</id_reprogram_old>
<id_reprogram_new>1660660</id_reprogram_new>
</poci_calculation>

gfn_GetPOCIValue
grp_PociCalculationResponse

        public static DataTable grp_pocicalculationresponse(IDataProviderSp provider, 

GBL_POCI_calculation


Gumb za POCI izračun
Gumb 'POCI izračun' Alt text, koji je vidljiv samo ako je tako određeno u odgovarajućoj prilagođenoj postavci ('Nova.LE.EnableCalculationOfPOCIControl') i omogućen u alatnoj traci samo za reprograme koji imaju spremljen otplatni plan. Preko navedenog gumba pristupamo do maske POCI izračun na kojoj možemo izračunati kriterije za oznaku POCI (POCI flag). Ugovor se označi sa POCI oznakom u slučaju kada je razlika između sume diskontiranih plaćanja prije restrukture i nakon restrukture veća od određenog postotka svih plaćanja. Ugovorima sa POCI oznakom potrebno je temeljito promijeniti i prilagoditi vrijednosti u uvjete. Promjena takvih ugovora se radi ručno uz nadzor bez automatizma. Oznake POCI nije moguće naknadno maknuti sa ugovora. 

Gornji dio maske za POCI izračun sadrži slijedeća informativna polja, koja se predispune i onemogućena su: **Ugovor, Predmet ugovora, Partner, Indeks kamata, Stvarna OM %, Kamatna stopa %, Izl. kam. stopa %, te par polja Način vraćanja glavnice: način vraćanja glavnice (ako se sa kursorom pozicioniramo na samo polje, program ispiše sljedeću obavijest: Glavnica se vraća na početku razdoblja (1 - begin, 0 - end)") i način izračuna kamate (ako se sa kursorom pozicioniramo na samo polje, program ispiše sljedeću obavijest: "Način izračuna kamate (L - linearni, K - konformni)"). Slijede polja Početni reprogram i Završni reprogram, u kojima je potrebno odabrati jedan od ponuđenih reprograma (na izbor imamo one koji imaju spremljen stari i novi otplatni plan) i po želji možemo promijeniti vrijednost u polju Trenutna vrijednost EKS (koje označava kamatnu stopu koja se koristi za diskont). Dokle god ne kliknemo na gumb 'Izračun' Alt text donji dio maske će biti onemogućen.

Alt text

Klikom na gumb 'Izračun' Alt text napravi se automatski izračun sume diskontiranih budućih plaćanja na temelju plana otplate prije i poslije restrukture, te se izračuna razlika između tih suma. Nakon toga se napuni tabela Plan otplate prije ** i Plan otplate poslije, te se izračunata vrijednost ispiše u poljima Datum diskonta (minimalni datum iz početnog i završnog plana otplate), te vrijednosti u poljima Svota disk. vrijednosti (Plan otplate prije, Plan otplate poslije, Apsolutna razlika** i Relativna razlika).

Ukoliko želimo izmijeniti podatke to možemo preko gumba 'Počni ispočetka' Alt text.

Alt text

Na toj masci imamo 3 eksterne funkcije i to su:

eksterna funkcija (POCI_IZRACUN_INIT) koje se pokreće kod otvaranja maske i namijenjena je provjeri ugovora i podešavanju vrijednosti za izračun diskontne vrijednosti;

eksterna funkcija (POCI_IZRACUN_BEFORE_CALCULATE) koja se izvršava prije izračuna (kod klika na gumb 'Izračun');

eksterna funkcija (POCI_IZRACUN_AFTER_CALCULATE) koja se izvršava nakon izračuna i namijenjena je proizvoljnoj implementaciji.


*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
-- Procedure: calculate POCI and return results  
  
-- [GMI_GENERATE_DATA_WRAPPER]  
  
-- History:  
-- 14.06.2017 MatjazB; Task 10209 - Created  
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
  
CREATE PROCEDURE [dbo].[grp_PociCalculationResponse]   
 @par_Id_Cont int = null,  
 @par_Eom decimal(8,4) = null,  
 @par_TipOm char(1) = null,  
 @par_MetodaIzracuna char(4) = null,  
 @par_RepOld int = null,  
 @par_RepNew int = null  
AS  
BEGIN  
    declare @om float, @dn float, @mi float, @minold datetime, @minnew datetime   
    declare @min_datum_dok datetime, @sum_old decimal(18,2), @sum_new decimal(18,2)   
  
    if @par_MetodaIzracuna = 'K360'  
        set @mi = 360  
    else -- default K365  
        set @mi = 365  
  
    set @om = @par_Eom / 100  
    if @par_TipOm = 'K'  
        set @dn = cast(power((1 + @om), (1 / @mi)) as decimal(8,4))  
    else  
        set @dn = 1 + @om / (@mi * 100)  
   
    -- star planp  
    select datum_dok, debit, debit as diskont_vred, old    
    into #old  
    from dbo.rep_planp   
    where id_reprogram = @par_RepOld and old = 1  
  
    -- nov_planp  
    select datum_dok, debit, debit as diskont_vred, old     
    into #new  
    from dbo.rep_planp   
    where id_reprogram = @par_RepNew and old = 0  
  
    -- minimalni datum  
    select @minold = min(datum_dok) from #old  
    select @minnew = min(datum_dok) from #new  
    set @min_datum_dok = dbo.gfn_MinDateTime(@minold, @minnew)  
  
    -- diskontirana vrednost old  
    update #old set diskont_vred = debit / POWER(@dn, DATEDIFF(dd, @min_datum_dok, datum_dok))  
  
    -- diskontirana vrednost new  
    update #new set diskont_vred = debit / POWER(@dn, DATEDIFF(dd, @min_datum_dok, datum_dok))  
  
    ---------------------------------- vrnemo 3 rezultate ----------------------------------  
    select datum_dok, debit, diskont_vred from #old order by datum_dok desc  
    select datum_dok, debit, diskont_vred from #new order by datum_dok desc  
  
    select @sum_old = SUM(diskont_vred) from #old  
    select @sum_new = SUM(diskont_vred) from #new  
      
    -- ostali podatki  
    select   
        @min_datum_dok min_dat_dok,   
        @sum_old sum_old,   
        @sum_new sum_new,   
        ABS(@sum_old - @sum_new) absolute_diff,   
        100 * ((@sum_new - @sum_old) / @sum_old) relative_diff  
  
END  




  
----------------------------------------------------------------------------------------------------------  
-- This function returns POCI value of the chosen entity.  
--  
-- History:  
-- 26.10.2017 Nejc; TASK 11604 - Created   
-- 27.05.2019 MatjazB; Bug 37455 - cast id_cont  
----------------------------------------------------------------------------------------------------------  
CREATE FUNCTION [dbo].[gfn_GetPOCIValue](@entieta char(10), @id_cont int, @sifra char(10))  
returns varchar(200) as  
BEGIN  
 DECLARE @res2 varchar(200), @rowCnt int  
 DECLARE @result table(vrednost varchar(200))  
  
 insert into @result(vrednost)  
 select   
  s.vrednost  
 from   
  dbo.kategorije_entiteta as e  
  inner join dbo.kategorije_tip t on t.id_kategorije_tip = e.id_kategorije_tip   
  inner join dbo.kategorije_sifrant s on s.id_kategorije_sifrant = e.id_kategorije_sifrant  
 where  
  e.id_entiteta = cast(@id_cont as varchar(100)) AND  
  t.entiteta = @entieta AND  
  t.sifra = @sifra  
   
 set @rowCnt = @@ROWCOUNT  
   
 if @rowCnt = 1  
  return (select vrednost from @result)  
  
 if @rowCnt = 0   
  return NULL  
  
 return 'Error!'  
END  
  