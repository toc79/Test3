select top 10 * from dbo.lsk where konto = '018202' -- 0 zapisa

select *  from dbo.gl where konto = '018202' and id_cont = 73556

select sum(debit_dom) as sum_debit_dom  from dbo.gl where konto = '018202' and id_cont = 73556

select PREVZETA, * from dbo.pogodba where id_cont = 73556

outer apply (select sum(kredit_dom) as sum_kredit_dom from dbo.lsk where konto = '500101' and vrsta_dok = 'AKT' and id_cont = a.id_cont) of1 

outer apply (select sum(debit_dom) as sum_debit_dom from dbo.gl where konto in ('018001','018101','018201','018202','018301','018302','018303','018304','018305','018401','018501','018601','018602','018603','018604','018605','018606','018607','018608' and id_cont = a.id_cont)) ol1

'018001','018101','018201','018202','018301','018302','018303','018304','018305','018401','018501','018601','018602','018603','018604','018605','018606','018607','018608'

Zbog slučaja da ugovor može imati više od jedne uknjižbe na takvom kontu, podesio bih da se izračuna suma
Primjer ugovora 65014/21    na testu

Aktivirana nabavna vrijednost - povlači iznos potražnog salda po ugovoru na kontu 500101 iz Leasinga
fa_dnev_maska.txtnabav_vred.Value = NVL(_pogodba.kredit_neto, 0)
rac_in.kredit_neto
Sada se uzima iznos s  ulaznog računa. 
select pog.VR_VAL_ZAC, pog.VR_VAL, dbo.gfn_VrValToNeto(pog.id_cont) as vr_val_to_neto, lsk.* 
from dbo.lsk lsk
join dbo.pogodba pog on lsk.id_cont = pog.id_cont
where konto ='500101'
and pog.STATUS_AKT='A' and pog.NACIN_LEAS='OF'
ne može se koristiti dbo.gfn_VrValToNeto(pog.id_cont) nije točno

500101 konto aktiviranja AKT Obračunski konto - HIBRID nabavna vrijednost (glavnica)        



Vrijedn. koja se ne amortizira - iznos jamčevina+Otkup kolona Neto iz otplatnog plana pomnožena sa tečajem na dan sklapanja sa maske ugovora
fa_dnev_maska.txtneam_vred.Value = lnVarOpc
lnVarOpc = _pogodba.opcija3+_pogodba.varscina2

CAST(ISNULL(PP.NETO,0)*A.PO_TECAJU AS DECIMAL(18,2)) AS OPCIJA3
od OPC iz planp

CAST(A.VARSCINA*A.PO_TECAJU AS DECIMAL(18,2)) AS VARSCINA2 iz pogodbe

za OF on nem aOPC već 21 

Također, kada se povuku ti podaci, morao bi biti moguć automatski izračun amostizacijske stope kao kod redovne aktivacije
fa_dnev_maska.txtstopnja_am.Value = 100/(_pogodba.traj_naj/12)



65188/21

65556/21

Poštovana/i, 

1. Za brži uvoz imamo postojeću funkcionalnost uvoza novih nabava iz excel datoteke (XLT predložak koji se sprema kao XML spreedsheet 2003). Cijena te funkcionalnosti je 2 MAN/DAY (man/day = 632€). Za podešavanje funkcionalnosti (na test i/ili na produkciju) nam je potrebno još dodatno 3 sata po 79€.

Radi bržeg unosa tih podataka u excel može vam se kreirati novi izvještaj koji će se pokretati na dodatnu rutinu. Izvještaj može biti: 
a) jednostavan da prikazuje samo listu novih ugovora za koje treba unijeti nove nabave ili 
b) kompleksniji koji će imati iste kolone kao excel tj. unosna maska za unos novih nabava . Nakon prikaza podataka bi onda kopirali te podatke u excel za uvoz novih nabava. Logika na izvještaju bi bila kao što je u dodatnoj rutini koja popunjava podatke na masci za unos novih nabava?

2. za OF ugovore:
a) Aktivirana nabavna vrijednost - da se povlači iznos potražnog salda po ugovoru na kontu 500101 iz Leasinga => to možemo podesiti. Sada se uzima iznos s ulaznog računa pa ako ugovor nema ulaznog računa ide iznos 0, za sve tipove leasinga. Da li ugovor uvijek mora imati ulazni račun, ovo pitam jer tada će se uvijek popuniti podatak s ulaznog računa i dorada nije potrebna?

b) Vrijedn. koja se ne amortizira - iznos jamčevina+Otkup kolona Neto iz otplatnog plana pomnožena sa tečajem na dan sklapanja sa maske ugovora => na primjeru ugovora 65188/21 sa slike, OF ugovori nemaju potraživanje za otkup (šifra 23) a koji se koristi da bi se dobio/izračunao iznos već je otkup u potraživanju RATA (šifra 21), pa bi onda tako podesili za OF.

c) ".. morao bi biti moguć automatski izračun amostizacijske stope kao kod redovne aktivacije ..."
Amortizacijska stopa => sada se za ugovor 65188/21 izračuna iznos 92,30 tj. 92,31 kada se prođe kroz polje "Ugovor". Možete detaljnije objasniti kako bi se trebalo izračunati zato jer se sada izračunava taj iznos?
Ja sam primijetio da bi izračunati iznos trebalo zaokružiti na 2 decimale. To sam sada podesio na nova_test pa možete testirati, više se neće prikazati 92,30 već 92,31.

d) podatak "Interna amor. stopa" za ugovor 65188/21 ne bude popunjena tj. budu zvjezdice zato jer je nabavna vrijednost 0. Trebate u takvim slučajevima unijeti ispravnu vrijednost (neki postotak) pa će se tek onda moći spremiti zapis. 

$SIGN 



Ponuda

1. a)
povući iz Leasinga koji su ugovori aktivirani tokom tekućeg mjeseca => bolje u zadnjih npr. 31 dana (status aktivnosti A), a nisu unešeni u Nove nabave. Od informacija bi bilo dobro da imamo broj i vrstu ugovora.
 Predlažem da prihvatimo ponuđeno rješenje:
   Gemicro     a) jednostavan da prikazuje samo listu novih ugovora za koje treba unijeti nove nabave
   
   
   2. za OF ugovore:
a) Aktivirana nabavna vrijednost - da se povlači iznos potražnog salda po ugovoru na kontu 500101 iz Leasinga => to možemo podesiti   RLHR: Ok











