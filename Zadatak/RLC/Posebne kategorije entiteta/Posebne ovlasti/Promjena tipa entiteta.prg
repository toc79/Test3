loForm = GF_GetFormObject("frmKategorije_entiteta_maska")
IF ISNULL(loForm) THEN 
 RETURN
ENDIF

LOCAL laPar[1], lcOnemogucavanje, lcPostavljanje, lcSifra

* TODO
* napraviti popunjavanje RLC_ENTITETI_OVLASTI prema kategorije.entiteta čime se može dobiti mogućnost, 
* ako ne postoji niti jedan zapis u general_register da su sva polja omogućena, 
* ili još detaljnije da je tip/šifra entiteta omogućena

TEXT TO lcSql NOSHOW
	SELECT a.* FROM (
	SELECT SUBSTRING(val_char, 0, CHARINDEX(';', val_char) ) AS sifra
	, SUBSTRING(val_char, CHARINDEX(';', val_char) + 1, LEN(val_char) ) AS rola
	, dbo.gfn_UserIsInRole(?p1, SUBSTRING(val_char, CHARINDEX(';', val_char) + 1, LEN(val_char) )) as JeURoli --neaktivne role vraća 0
	, * 
	FROM dbo.general_register 
	WHERE id_register = 'RLC_ENTITETI_OVLASTI'
	AND neaktiven = 0
	) a 
	WHERE a.JeURoli = 1
ENDTEXT

laPar[1] = allt(GObj_Comm.getUserName())

GF_SqlExec_P(lcSql, @laPar, "_ef_RLC_ENTITETI_OVLASTI")

lcPostavljanje = ""

select kategorije
GO TOP
SCAN 
	lcOnemogucavanje = "loForm."+kategorije.obj_name+".Enabled = .F."
	&lcOnemogucavanje
	
	lcSifra = kategorije.sifra
	select TOP 1 * FROM _ef_RLC_ENTITETI_OVLASTI WHERE sifra = lcSifra ORDER BY JeURoli INTO CURSOR _ef_ima_ovlast

	IF RECCOUNT() > 0
		lcPostavljanje = "loForm."+kategorije.obj_name+".Enabled = .T."
		&lcPostavljanje
	ENDIF
	
	IF USED ("_ef_ima_ovlast") 
		USE IN _ef_ima_ovlast
	ENDIF
	
ENDSCAN


IF USED ("_ef_RLC_ENTITETI_OVLASTI") 
	USE IN _ef_RLC_ENTITETI_OVLASTI
ENDIF
	


--select dbo.gfn_UserIsInRole('g_tomislav', 'contractad')
--SELECT dbo.gfn_UserIsInRole('g_tomislav', 'contractad'), * FROM dbo.kategorije_tip

SELECT a.* FROM (
SELECT CHARINDEX(';', val_char) AS charindex
, SUBSTRING(val_char, 0, CHARINDEX(';', val_char) ) AS tip
, SUBSTRING(val_char, CHARINDEX(';', val_char) + 1, LEN(val_char) ) AS rola
--, dbo.gfn_UserIsInRole('g_tomislav', SUBSTRING(val_char, CHARINDEX(';', val_char) + 1, LEN(val_char) )) as JeURoli
, dbo.gfn_UserIsInRole('anad', SUBSTRING(val_char, CHARINDEX(';', val_char) + 1, LEN(val_char) )) as JeURoli
, * 
FROM dbo.general_register 
WHERE id_register = 'RLC_ENTITETI_OVLASTI'
AND neaktiven = 0
) a 
WHERE a.JeURoli = 1
	
	

begin tran
UPDATE kategorije_tip set tip_polja = 'DATETIME' WHERE id_kategorije_tip = 2 --bilo TEXT
--commit
--rollback

select * from kategorije_entiteta
select * from kategorije_sifrant
select * from kategorije_tip



ext_func

loForm = GF_GetFormObject("frmKategorije_entiteta_maska")
IF ISNULL(loForm) THEN 
 RETURN
ENDIF

*select * from kategorije

*loForm.Combobox1.Enabled = .f.
*loForm.Textbox2.Enabled = .f.

lcTest = "loForm.Combobox1.Enabled"

&lcTest = .f.


Pozdrav, 
mi možemo napraviti to u KATEGORIJE_ENTITETA_MASKA_INIT (i s obzirom na dinamički prikaz polja) gdje bi napravili onemogućavanje polja glede na npr. ako korisnik nije u određenoj roli (akcije unos/popravak/brisanje bi gledali kao na jednu te istu akciju radi jednostavnosti). Kod takvog rješenja RLC bi imao dodatni dodatni trošak prilikom svakog uvođenja novog tipa entiteta kategorije_tip.id_kategorije_tip jer bi mi morali dorađivati ext_func. Eventualno bi mi možda mogli iskoristiti dbo.general register koji bi na neki način stimulirao custom functionalities (dbo.USERS_CUSTOM_FUNCS), koji pak onda RLC može koristiti umjesto custom functionalities, te onda ne bi bilo potrebno dorađivati ext_func sa svakim novim entitetom.

Ali ipak je korisniku ugodnije rješenje da se to napravi kroz aplikaciju pa bi molili da vi napravite analizu za trošak implementacije koji bi onda prezentirali korisniku.

Oko implementacije s obzirom na specifičnu masku, možda bi bilo najbolje da se podrži samo jedna opcija/akcija koja će vrijediti za unos/popravak/brisanje te se s obzirom na nju onemogući polje za unos/popravak/brisanje entiteta?

Iz moje kratke analize smatram da nije potrebno dodavati nove tablice, nego je potrebno dodati nove ovlasti/prava za pregled i editiranje novih vrijednosti svih entitera, koja će onda vrijediti i za pojedinačne entitete preko dbo.USERS_CUSTOM_FUNCS. Ili se može koristiti postojeća ovlasti npr. KategorijeTipUpdate za dbo.USERS_CUSTOM_FUNCS, tada ne treba dodavati nove ovlasti, ali to ima svoje nedostatke oko gubitka dosljednosti logike unosa custom funtionalities. 
Također sam id_kategorije_tip je po nama dobar ključ (npr. id_obl_zav nije ništa "bolji" sistemski ključ od ID_KATEGORIJE_TIP).

          KategorijeTipSifrant (1083)	All activities related to categories	Sve aktivnosti vezane uz kategorije_tip in kategorije_sifrant
               KategorijeSifrantInsert (1087)	All activities related to entering new kategorije_sifrant	Unos šifrant kategorije
               KategorijeSifrantUpdate (1088)	All activities related to updating existing kategorije_sifrant	Popravak šifrant kategorije
               KategorijeTipInsert (1085)	All activities related to entering new kategorije_tip	Unos tipa kategorije
               KategorijeTipSifrantView (1084)	All activites related to viewing kategorije_tip and kategorije_sifrant	Pregled za kategorije_tip i kategorije_sifrant
               KategorijeTipUpdate (1086)	All activities related to updating existing kategorije_tip	Popravak tipa kategorije


sp_helptext grp_Kategorije_entitete_view

(1,kategorija_entiteta)EXEC  dbo.grp_Kategorije_entitete_view 1,'DOKUMENT,P_EVAL,PARTNER,POGODBA',0,'',0,'',1 
___________________________________________________
(1,_tmpcur)	declare @pravice table (val int, entiteta char(10));
	insert into @pravice (val, entiteta)
	select MAX(a.val) as val, a.entiteta
	from (
	    select dbo.gfn_UserCanDoByName('g_tomislav', 'ContractDashboard') as val, 'POGODBA' as entiteta
	    union
	    select dbo.gfn_UserCanDoByName('g_tomislav', 'partnerView') as val, 'PARTNER' as entiteta
	    union
	    select dbo.gfn_UserCanDoByName('g_tomislav', 'ContractDocumentationView') as val, 'DOKUMENT' as entiteta
	    union
	    select dbo.gfn_UserCanDoByName('g_tomislav', 'CollectionDocumentationView') as val, 'DOKUMENT' as entiteta
	    union
	    select dbo.gfn_UserCanDoByName('g_tomislav', 'PartnerEvalView_E') as val, 'P_EVAL' as entiteta
	    union
	    select dbo.gfn_UserCanDoByName('g_tomislav', 'PartnerEvalView_Other') as val, 'P_EVAL' as entiteta
	) a
	group by a.entiteta

	select
	    a.entiteta
	from
	    dbo.gfn_kategorije_entitete() a
	    inner join @pravice b on a.entiteta = b.entiteta
	where b.val = 2
	order by a.entiteta
	
	
Poštovani, 
od kolega iz Slovenije smo dobili odgovor, oko našeg prijedloga da se napravi funkcionalnost posebnih ovlasti za unos/popravak/brisanje pojedine šifre(tipa) kategorije entiteta koristeći Custom functionalities (kao što je npr. za dokumente), da se njima čini da bi to bio veliki projekt i veliki trošak za stranku (vas) s obzirom na specifičnosti i funkcionalnosti maske (detaljnija analiza prema kojoj bi se dobila realna slika kompleksnosti i trošak bi vam se također naplatila bez obzira na prihvat ponude) pa je onda predloženo da vam mi (GMC) napravimo rješenje koristeći eksternu funkciju koja nam je na raspolaganju na masci za unos/pregled/popravak 'Posebne kategorije' tj. šifri kategorije entiteta, koja se poziva u koraku prije prikaza maske.

Testirali smo mogućnosti te bi naš prijedlog onda bio sljedeći: 
a) da u Posebnom šifrantu kreiramo novi šifrant i u njemu napravimo razradu tj. veze između pojedine šifre (tipa) kategorije entiteta i role (ili usera), tko smije tj. će imati omogućeno polje za popravak (unos/popravak/brisanje je jedna te ista funkcionalnost) za pojedinu šifru kategorije entiteta (polje ŠIFRA u šifrantu 'Posebne kategorije entiteta - šifrant'). Na neki način bi taj šifrant simulirao/zamijenio custom functionalities iz admin konzole. Tu razradu, koji bi vi sami mogli unositi i koja bi se morala unositi prema određenim pravilima (za što bih vam pripremio upute naknadno), bi onda iskoristili u 

b) eksternoj funkciji u kojoj bi podesili na temelju navedene razrade, da li je polje za pojedinu šifru kategorije entiteta, za trenutnog logiranog korisnika, omogućeno ili ne.

Također kod unosa nove šifre kategorije entiteta, nije potrebna intervencija s naše strane oko programiranja eksterne funkcije, nego će biti potrebno s vaše strane samo dodati novi zapis u posebni šifrant (za što bih vam pripremio upute naknadno, u biti bi taj zapis treba sadržavati šifru i naziv role koji bi se onda mogao prepoznati u eksternoj funkciji).

Točna procjena potrebnog vremena i time iznosa ponude za navedeno ovisi o kompleksnosti funkcionalnosti u eksternoj funkciji.

c) U eksternoj funkciji najjednostavnije je da se podesi da su početno za sve šifre (i novo unesene) polja onemogućena (disable-na) za popravak, te da se obavezno mora unijeti zapis u posebni šifrant što znači da je razradu tj. posebne ovlasti potrebno unijeti za sve šifre kategorija entiteta. Kompliciranije rješenje je da npr. ako nema posebne ovlasti za pojedinu šifru kategorije entiteta, da je ista omogućeno za sve korisnike (slično kako funkcionira custom functionalities) čime se ta provjera i o(ne)mogućavanje polja bude dodatno radilo za svaku šifru posebno.

Molimo provjeru i povratnu informaciju da li vam prijedlog odgovora te i oko kompleksnosti funkcionalnosti. Oko detalja me možete kontaktirati na telefon.


Za U1 bi trebali imati (najmanje) jedan zapis, također za U2 bi morali imali (najmanje) jedan zapis.

Entitet	Šifra	Naziv	Tip polja	Maska	Proizvoljna dužina	Obvezan	Neaktivan
POGODBA	U1	Broj inicijalne ponude	Tekst		.F.	.F.	.F.
POGODBA	U2	ORCA ID-CONFIRM. DATE	Datum		.F.	.F.	.F.




