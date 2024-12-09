Poštovana,

sukladno dogovoru sa sastanka, Gemicro će provjeriti da li je moguće:
1. kod popravka ugovora, napraviti kontrolu koja će prije snimanja prikazati obavijest o staroj/novoj vrijednosti polja: šifra indeksa, vrijednost indeksa, marža
2. kod automatskog reprograma prije potvrđivanja reprograma napraviti kontrolu koja će prikazati obavijest o staroj/novoj vrijednosti polja: kamatna stopa, marža i vrijednost indeksa
3. Gemicro će poslati u Sloveniju zahtjev da se u pregledu reprograma kod automatskog reprograma dodaju još detaljnije informacije u slučaju kada dođe do promjene kamatne stope, kako bi korisnik imao vidljive podatke o podacima koji utječu na izračun kamatne stope (marža, datum indeksa, vrijednost indeksa)
4. provjeriti i dostaviti popis ugovora kojima je došlo do promjene marže prilikom automatskog reprograma, a koji su vezanu uz izvedene indekse
5. kod reprograma zbog promjene indeksa, napraviti kontrolu koja će obavijestiti da za ugovore koji su vezani uz izvedeni indeks postoje kandidati kod kojih dolazi do promjene kamatne stope

Nakon što povjerimo pojedine stavke, dostavit ćemo vam službenu ponudu i rok implementacije.

Poštovana/a, 

u privitku vam šaljemo ponudu za točke 
1. kontrola prije snimanja kod popravka aktivnog ugovora (na neaktivnom se ti podaci ne mogu promijeniti) prema zahtjevu;
2. kod automatskog reprograma (nema promjene indeksa već samo iznosa ukupne kamate u odlomku "Kamatna stopa" u polju "Ukupna izlazna". Mi ćemo na temelju tog podataka napraviti kontrolu i prokazati vrijednosti polja: kamatna stopa, marža i vrijednost indeksa) prema zahtjevu; 
4. provjeru i dostavu popis ugovora prema zahtjevu
5. kontrola kod reprograma zbog promjene indeksa prema zahtjevu


	
Izrada kontrole kod popravka aktivnog ugovora prema zahtjevu
Izrada kontrole kod automatskog reprograma prema zahtjevu  



--analiza 
1. pogodba_update_proveri_podatke
kod popravka ugovora je moguće promijeniti samo indeks i fix_del, ukupna stopa dej_obr/obr_mera ostane ista

FIx_del : U tom slučaju , promijeni se rind_zadnji.
Promjenjena polja: pogodba.FIX_DEL [5,85 -> 2,00], pogodba.RIND_DATUM [1.7.2017. -> 2.9.2019.], pogodba.RIND_ZADNJI [0,16 -> 4,01]
Promjenjena polja: pogodba.FIX_DEL [6,23 -> 6,50], pogodba.RIND_ZADNJI [-0,23 -> -0,50] --7203/18
select distinct a.id_cont
from dbo.reprogram rep
--join dbo.ponudba pon on pog.id_pon = pon.id_pon
left join dbo.pogodba a ON a.id_cont = rep.id_cont
left join dbo.RTIP b on a.ID_RTIP = b.id_rtip
where --a.id_cont = 8560--id_pog = '7098/18'
b.id_rtip_base is not null
and rep.ID_REP_TYPE = 'UPD'
and auto_desc like '%FIX_DEL%'
and a.status_akt != 'Z'
--55 ugovora


Index: promjeni se rind_zadnji i fix del 
Promjenjena polja: pogodba.FIX_DEL [2,00 -> 6,01], pogodba.ID_RTIP [EUR3 -> EUR3I], pogodba.RIND_ZADNJI [4,01 -> 0,00]
Promjena rind_datum u ovom koraku ne radi promjenu tih trijednosti.
select pog.fix_del pog_fix_del, RIND_ZADNJI, rind_datum, DEJ_OBR, OBR_MERA, obr_merak, * 
from dbo.arh_pogodba pog
where 
pog.id_cont = 8084

--Kontrola 

*OBVESTI('POGODBA_UPDATE_PREVERI_PODATKE')
IF _pogodba_copy.id_rtip != pogodba.id_rtip OR _pogodba_copy.rind_zadnji != pogodba.rind_zadnji OR _pogodba_copy.fix_del != pogodba.fix_del
	IF !POTRJENO("Na ugovoru su promijenjeni sljedeći podaci:"+gce+"stara vrijednost  ->  nova vrijednost"+gce ;
			+"Indeks kamata: "+trans(_pogodba_copy.id_rtip)+"  ->  "+trans(pogodba.id_rtip)+gce ;
			+"Vrijednost indeksa: "+trans(_pogodba_copy.rind_zadnji)+"  ->  "+trans(pogodba.rind_zadnji)+gce ;
			+"Marža (fiksni dio): "+trans(_pogodba_copy.fix_del)+"  ->  "+trans(pogodba.fix_del)+gce ;
			+"Da li želite nastaviti sa spremanjem?")
		RETURN .F. 
	ENDIF
ENDIF




a) promejna indeksa, odgovor DA želim promijeniti datum zadnjeg indeksa na ugovoru, promijeni se rind_zadnji i fix_del
Promjenjena polja: pogodba.FIX_DEL [6,23 -> 6,00], pogodba.ID_RTIP [EUR3 -> EUR3I], pogodba.RIND_ZADNJI [-0,23 -> 0,00], pogodba.KK_MEMO [ -> ]
select distinct a.id_cont
from dbo.reprogram rep
--join dbo.ponudba pon on pog.id_pon = pon.id_pon
left join dbo.pogodba a ON a.id_cont = rep.id_cont
left join dbo.RTIP b on a.ID_RTIP = b.id_rtip
where --a.id_cont = 8560--id_pog = '7098/18'
b.id_rtip_base is not null
and rep.ID_REP_TYPE = 'UPD'
and auto_desc like '%RIND_ZADNJI%'
and a.status_akt != 'Z'
-- ugovora


b) promejna indeksa, odgovor NE želim promijeniti datum zadnjeg indeksa na ugovoru, promijeni se samo id_rtip
Promjenjena polja: pogodba.ID_RTIP [EUR3 -> EUR3I], pogodba.KK_MEMO [ -> ] --7101/18         
Provjera tih ugovora nije potrebna
Kod reprograma zbog promejne indeksa se kod takvog ugovora NE mijenja fix_del, mijenja se rind_zadnji i naravno obr_mera


2. ext_func repro_select_preveri_podatke_custom
a) promjena kamatne stope
RIND_ZADNJI i ID_RTIP SE NE MIJENJA, mjenja se fix_del i time i obr_mera i dej_obr tako da bi se trebalo izračunati iz new_interest_rate

USE NOVA_HLS
select fix_del, id_rtip, rind_zadnji, obr_mera, dej_obr,* from dbo.ARH_pogodba where id_cont = 8560--id_pog = '7098/18'
_automatic_rpg.new_interest_rate => "Kamatna stopa" u polju "Ukupna izlazna"

Promjena kamatne stope (6,0000) -> (5,5000)
Iznos rate (1.988,75 -> 1.967,15)
 Iznos (HRK,000) |      Staro |       Novo |   Razlika 
        Glavnica |  75.129,25 |  75.129,25 |      0,00 
          Kamate |  10.784,75 |   9.851,63 |   -933,12 
           Marža |       0,00 |       0,00 |      0,00 
  Dodatne usluge |       0,00 |       0,00 |      0,00 
           Porez |  21.478,50 |  21.245,22 |   -233,28 
         PPMV/ZM |       0,00 |       0,00 |      0,00 
          Ukupno | 107.392,50 | 106.226,10 | -1.166,40 

Stara trenutna EKS: 5,9658 -> Nova trenutna EKS: 5,6865


b) promjena datuma indeksa => nemamo novi datum indeksa u kursoru _automatic_rpg !!?? IPAK IMAMO :) Nemamo fix_del
Promijeni se Obr_mera i rind_zadnji, fix_del se ne promijeni (ali može se na masci promijeniti).
select fix_del, id_rtip, rind_zadnji, obr_mera, dej_obr,* from dbo.ARH_pogodba where id_cont = 8755--id_pog = ''
fix_del	id_rtip	rind_zadnji	obr_mera	dej_obr
4.3000	EUR12	1.7000	6.0000	6.0000
4.3000	EUR12	1.2000	5.5000	5.5000

u nodu automatic_rpg
new_interest_rate>5.5000</new_interest_rate><new_index_rate>1.2000</new_index_rate><new_index_date>2018-04-01T00:00:00</new_index_date>


SELECT id_cont, obr_mera, fix_del, rind_zadnji, rind_datum, b.id_tiprep, * FROM dbo.arh_pogodba a JOIN dbo.rtip b ON a.id_rtip = b.id_rtip where id_cont = 8748

5. 
*obvesti("REP_IND_AFTER_INIT")

*//////////////////////////////////////////////
* 16.12.2019 g_tomislav MR 43505 - created;

GF_SQLEXEC("SELECT id_rtip FROM dbo.rtip WHERE id_rtip_base IS NOT NULL", "_ef_izvedeni")

SELECT a.id_pog, a.id_rtip, a.rind_zadnji, a.indeks, a.sprememba, a.obrok_bruto, a.nov_obrok_bruto FROM rep_pog a ;
INNER JOIN _ef_izvedeni b ON a.id_rtip = b.id_rtip ;
WHERE (!GF_NULLOREMPTY(a.sprememba) AND a.sprememba != 0) OR (!GF_NULLOREMPTY(a.nov_obrok_bruto) AND a.obrok_bruto != a.nov_obrok_bruto);
INTO CURSOR _ef_izv_ugovori

IF RECCOUNT("_ef_izv_ugovori") > 0
	IF POTRJENO("Na ugovorima s izvedenim ugovorima je došlo da promjene vrijednosti indeksa ili iznosa nove rate. Da li želite vidjeti listu tih ugovora?")
		SELECT id_pog AS Ugovori, id_rtip AS Rev_indeks, rind_zadnji AS Stari_indeks, indeks AS Novi_indeks, sprememba AS Promjena, obrok_bruto AS Trenutna_rata, nov_obrok_bruto AS Nova_rata, obrok_bruto - nov_obrok_bruto AS Razlika_rata FROM _ef_izv_ugovori 
	ENDIF
ENDIF
* END MR 43505//////////////////////////////////////////////

rep_pog.sprememba
SELECT id_rtip, sprememba as promejna_vrijednosti_indeksa, obrok_bruto, nov_obrok_bruto, * ;
FROM rep_pog a ;
filip 


4. provjeriti i dostaviti popis ugovora kojima je došlo do promjene marže prilikom automatskog reprograma, a koji su vezanu uz izvedene indekse
--preko usporedne ponude i ugovora
select pog.fix_del - pon.fix_del AS razlika, pog.fix_del pog_fix_del, pon.fix_del pon_fix_del, pog.status_akt, pog.id_pog, pog.id_kupca 
from dbo.pogodba pog
join dbo.ponudba pon on pog.id_pon = pon.id_pon
where 
exists (select a.* 
from dbo.pogodba a
join dbo.RTIP b on a.ID_RTIP = b.id_rtip
where --a.id_cont = 8560--id_pog = '7098/18'
b.id_rtip_base is not null
and a.id_cont = pog.id_cont
)
and pog.fix_del != pon.fix_del
and pog.status_akt != 'Z'
order by razlika 
--547 zapisa, 159 ugovora ima negativnu razlika u
--status_akt != 'Z' ima 134 ugovora, 52 ugovora ima negativnu razliku

--DORAĐENI
select pog.id_pog AS Ugovor, pog.id_kupca AS Partner, pog.id_rtip Indeks,  pon.fix_del Marza_ponuda, pog.fix_del Marza_ugovor, pog.fix_del - pon.fix_del AS Marza_razlika, 
pog.fix_del - pon.fix_del AS razlika, pog.fix_del pog_fix_del, pon.fix_del pon_fix_del, pog.status_akt, pog.id_pog, pog.id_kupca 
from dbo.pogodba pog
join dbo.ponudba pon on pog.id_pon = pon.id_pon
join dbo.RTIP rtip on pog.ID_RTIP = rtip.id_rtip
where 
rtip.id_rtip_base is not null
and pog.fix_del != pon.fix_del
and pog.status_akt != 'Z'
order by pog.id_pog 
--547 zapisa, 159 ugovora ima negativnu razlika u
--status_akt != 'Z' ima 124 ugovora, 


select b.id_rtip, b.naziv
	, a.* 
from dbo.pogodba a
join dbo.RTIP b on a.ID_RTIP = b.id_rtip
where --a.id_cont = 8560--id_pog = '7098/18'
b.id_rtip_base is not null
and a.status_akt != 'Z'
--95198
-- a.status_akt != 'Z' 3642 ugovora



--automatski reprogram
select a.ID_POG Ugovor, a.ID_KUPCA Partner, a.ID_RTIP Indeks, rep.time Datum_reprograma, rep.COMMENT Opis, LEFT(rep.auto_desc, 43) Napomena
	, rep.*
from dbo.reprogram rep
--join dbo.ponudba pon on pog.id_pon = pon.id_pon
inner join dbo.pogodba a ON a.id_cont = rep.id_cont
inner join dbo.RTIP b on a.ID_RTIP = b.id_rtip
where --a.id_cont = 8560--id_pog = '7098/18'
b.id_rtip_base is not null
and a.status_akt != 'Z'
and rep.ID_REP_TYPE = 'RPG'
and auto_desc like '%Promjena kamatne stope%'
order by a.id_pog
--3182 zapisa
-- a.status_akt != 'Z' 1860 zapisa
--distinct a.id_cont 1823


--IND reprogram zbog promjene indeksa 
select a.ID_POG Ugovor, a.ID_KUPCA Partner, a.ID_RTIP Indeks, rep.time Datum_reprograma, rep.COMMENT Opis, LEFT(rep.auto_desc, 55) Napomena 
 	, * 
from dbo.reprogram rep
--join dbo.ponudba pon on pog.id_pon = pon.id_pon
left join dbo.pogodba a ON a.id_cont = rep.id_cont
left join dbo.RTIP b on a.ID_RTIP = b.id_rtip
where --a.id_cont = 8560--id_pog = '7098/18'
b.id_rtip_base is not null
and rep.ID_REP_TYPE = 'IND'
and a.status_akt != 'Z'
order by a.id_pog
--7708
-- a.status_akt != 'Z'  3375

-- i select za UPD iznad u točki 2.

Poštovana/i, 

na testu smo podesili kontrole prema točkama 1, 2 i 5.
U privitku vam šaljmo popis ugovora u tri lista/sheeta:
- 'Ponuda ugovor marža' u kojemu su prikazani svi nezaključeni ugovori na kojima je došlo do promejne fiksni dio marže u odnosu ma fiksni dio marže s ponude;
- 'Automatski reprogram' u kojemu su prikazani svi nezaključeni ugovori kod kojih je rađen automatski reprogram i došlo je do promjene kamatne stope 
- 'Rpg zbog promjene indeksa' u kojemu su prikazani svi nezaključeni ugovori kod kojih je rađen reprogram zbog promjene indeksa.


<obresti_diff>-933.12</obresti_diff>
opomba
Promjena kamatne stope (6,0000) -> (5,5000)Iznos rate (1.988,75 -> 1.967,15) Iznos (HRK,000) |      Staro |       Novo |   Razlika         Glavnica |  75.129,25 |  75.129,25 |      0,00           Kamate |  10.784,75 |   9.851,63 |  


<root>
  <reprogram_diff>
    <neto_old>75129.25</neto_old>
    <neto_new>75129.25</neto_new>
    <neto_diff>0.00</neto_diff>
    <robresti_old>0</robresti_old>
    <robresti_new>0</robresti_new>
    <robresti_diff>0</robresti_diff>
    <obresti_old>10784.75</obresti_old>
    <obresti_new>9851.63</obresti_new>
    <obresti_diff>-933.12</obresti_diff>
    <marza_old>0</marza_old>
    <marza_new>0</marza_new>
    <marza_diff>0</marza_diff>
    <regist_old>0</regist_old>
    <regist_new>0</regist_new>
    <regist_diff>0</regist_diff>
    <davek_old>21478.50</davek_old>
    <davek_new>21245.22</davek_new>
    <davek_diff>-233.28</davek_diff>
    <debit_old>107392.50</debit_old>
    <debit_new>106226.10</debit_new>
    <debit_diff>-1166.40</debit_diff>
    <id_tec>000</id_tec>
    <id_val>HRK</id_val>
    <eom_old>5.9658</eom_old>
    <eom_new>5.6865</eom_new>
    <eom_diff>-0.2793</eom_diff>
    <dat_zap>0001-01-01T00:00:00+01:00</dat_zap>
    <datum_dok>0001-01-01T00:00:00+01:00</datum_dok>
    <id_spr_ddv>0</id_spr_ddv>
  </reprogram_diff>
</root>


