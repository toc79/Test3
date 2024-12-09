BG,G1,G2,GL,GO,JZ,IN,M1,M2,M3,M4,M5,M6,MI,ZA,ZD,ZJ,ZK,ZN,ZS,ZV,ZO,RA
,AK,AO,BK,BO,BP,OE,OK,OL,OP,OR,OS,OZ,PN,PO,PV,VB,VK,VL,VP,VR,ZA,ZD,AK,AP                                                                                                                                

BG,C2,C3,D1,E1,E2,ED,EG,EL,EN,EO,EP,EZ,G1,G2,GL,GO,H1,H2,IJ,IN,JZ,KO,M1,M2,M3,M4,M5,M6,M7,M8,MI,Z1,Z2,Z3,Z4,ZA,ZD,ZJ,ZK,ZN,ZO,ZS,ZU,ZV,ZW,ZY,ZZ,

select * from dok where id_obl_zav in ('BG','C2','C3','D1','E1','E2','ED','EG','EL','EN','EO','EP','EZ','G1','G2','GL','GO','H1','H2','IJ','IN','JZ','KO','M1','M2','M3','M4','M5','M6','M7','M8','MI','Z1','Z2','Z3','Z4','ZA','ZD','ZJ','ZK','ZN','ZO','ZS','ZU','ZV','ZW','ZY','ZZ')


select * from pogodba where id_pog in ('38368/11','38367/11','38373/11')
select * from pogodba where id_pog in ('38331/11','38332/11','38327/11','38328/11','38330/11','38329/11')


--PROVJERE
select * from dok where id_obl_zav in ('BG','C2','C3','D1','E1','E2','ED','EG','EL','EN','EO','EP','EZ','G1','G2','GL','GO','H1','H2','IJ','IN','JZ','KO','M1','M2','M3','M4','M5','M6','M7','M8','MI','Z1','Z2','Z3','Z4','ZA','ZD','ZJ','ZK','ZN','ZO','ZS','ZU','ZV','ZW','ZY','ZZ')

DECLARE @lista varchar(300)
	SET @lista = (Select value from dbo.GENERAL_REGISTER Where ID_REGISTER = 'RLC Reporting list' and id_key = 'RLC_IOP_LISTA' AND  neaktiven = 0)-- and id_key = 'RLC_OBV_HIPOT' and


/*1*/select * from dok where id_obl_zav in ('BG','C2','C3','D1','E1','E2','ED','EG','EL','EN','EO','EP','EZ','G1','G2','GL','GO','H1','H2','IJ','IN','JZ','KO','M1','M2','M3','M4','M5','M6','M7','M8','MI','Z1','Z2','Z3','Z4','ZA','ZD','ZJ','ZK','ZN','ZO','ZS','ZU','ZV','ZW','ZY','ZZ')
AND ID_OBL_ZAV IN (
Select LTRIM(RTRIM(id)) as id 
From dbo.gfn_GetTableFromList(@lista) 
)--41 od 48

/*2*/select * from DOK 
WHERE id_obl_zav not in ('BG','C2','C3','D1','E1','E2','ED','EG','EL','EN','EO','EP','EZ','G1','G2','GL','GO','H1','H2','IJ','IN','JZ','KO','M1','M2','M3','M4','M5','M6','M7','M8','MI','Z1','Z2','Z3','Z4','ZA','ZD','ZJ','ZK','ZN','ZO','ZS','ZU','ZV','ZW','ZY','ZZ')
AND ID_OBL_ZAV IN (
Select LTRIM(RTRIM(id)) as id 
From dbo.gfn_GetTableFromList(@lista) 
)--RA nedostaje u listi dokumentacije a ima ga u RLC_IOP_LISTA

/*3*/select * from dok where id_obl_zav in ('BG','C2','C3','D1','E1','E2','ED','EG','EL','EN','EO','EP','EZ','G1','G2','GL','GO','H1','H2','IJ','IN','JZ','KO','M1','M2','M3','M4','M5','M6','M7','M8','MI','Z1','Z2','Z3','Z4','ZA','ZD','ZJ','ZK','ZN','ZO','ZS','ZU','ZV','ZW','ZY','ZZ')
AND ID_OBL_ZAV not IN (
Select LTRIM(RTRIM(id)) as id 
From dbo.gfn_GetTableFromList(@lista) 
)--u RLC_IOP_LISTA nedostaju 'C2','C3','D1','H1','H2','ZY','ZZ'
--PROVJERE

SELECT id_cont 
FROM dbo.krov_pog a 
LEFT JOIN dbo.krov_pog_pogodba b ON a.id_krov_pog = b.id_krov_pog
WHERE a.ID_KROV_POG = 5 --        146

select * from frame_pogodba
SELECT f.id_cont FROM dbo.frame_list a LEFT JOIN dbo.frame_pogodba f ON a.id_frame = f.id_frame WHERE a.id_frame=68

Lista dokumenata za izvještaje 

 pri unosu Datuma vraćanja kontrola bi trebala raditi na naćin: 
1.
a) Ako je Datum vraćanja prazan predložiti datum unosa, i ako: 
- datum vraćanja je u skladu sa "Kontrolom 60 dana" dozvoliti spremanje. 
- datum vraćanja nije u skladu sa Kontrolom 60 dana --> prikazati Poruka/Upozorenje: "Datum povrata je veći od zakonskog datuma vraćanja" 
i dozvoliti ručni unos Datuma vraćanja 


b) Kontrola ručno unesenog Datuma vraćanja, kao Poruke/Upozorenja, radi na isti način kako je gore opisano. 

dvije, prva bi se pokretala prilikom prikaza maske za popravak dokumenta, druga nakon klika na spremanje podataka dokumenta). 



Poštovani, 
sukladno telefonskom razgovoru, dorade bi bile sljedeće: 
A) na izvještaj: 

1) (CA) Praćenje povrata instrumenata po saldiranim ugovorima 
a) možemo dodati kolonu 'Kontrola 60 dana' kao vrijednost 'DA' u slučaju da je podatak 'Datum vraćanja instrumenata' <= 60 dana od datuma 'Datum zadnje uplate'. U suprotnom će biti vrijednost NE. 
b) možemo dodati kriterije pretrage na izvještaj 
- prikaži sve dokumente 
- prikaži samo dokumente kojima je Datum vraćanja nepopunjen (prazno) 
- prikaži samo dokumente sa tzv. nelogičnim datumima vraćanja u odnosu na Kontrolu 60 dana (tj. kada podatak 'Datum vraćanja instrumenata' nije <= 60 dana od datuma 'Datum zadnje uplate'). 


2) (CA) Praćenje povrata instrumenata po krovnim ugovorima 
a) možemo dodati kolonu 'Kontrola 60 dana' kao vrijednost 'DA' u slučaju da je podatak 'Datum vraćanja instrumenata' <= 60 dana od datuma 'Dat. Zad uplate'. U suprotnom će biti vrijednost NE. 
Za informaciju, podatak 'Datum vraćanja instrumenata' na izvještaju se dobiva sa dokumenta ZZ i ZY. 

b) Za podatak 'Dat. Zad uplate' bi promijenili, da se uzima datum zadnje uplate po zaključenim ugovorima na krovnom ugovoru? Ili možemo dodati taj podatak u novu kolonu. 

c) možemo dodati kriterije pretrage na izvještaj 
- prikaži sve dokumente 
- prikaži samo dokumente kojima je Datum vraćanja nepopunjen (prazno) 
- prikaži samo dokumente sa tzv. nelogičnim datumima vraćanja u odnosu na Kontrolu 60 dana (tj. kada podatak 'Datum vraćanja instrumenata' nije <= 60 dana od datuma 'Dat. Zad uplate'). 

3. (CA) Praćenje povrata instrumenata po okvirima 
a) da bi mogli dodati kolonu 'Kontrola 60 dana', potrebno je na izvještaju dodati podatak datum zadnje uplate, po zaključenim ugovorima na okviru. Tada možemo u koloni 'Kontrola 60 dana' dobiti vrijednost 'DA' u slučaju da je podatak 'Datum vraćanja instrumenata' <= 60 dana od datuma zadnje uplate. U suprotnom će biti vrijednost NE. 

b) Da li na dodatnu rutinu ' Pregled ugovora i dokumentacije okvira' je potrebno isto tako dodati taj podatak/kolonu 'Kontrola 60 dana'? 

c) možemo dodati kriterije pretrage na izvještaj 
- prikaži sve dokumente 
- prikaži samo dokumente kojima je Datum vraćanja nepopunjen (prazno) 
- prikaži samo dokumente sa tzv. nelogičnim datumima vraćanja u odnosu na Kontrolu 60 dana (tj. kada datum 'Datum vraćanja instrumenata' nije <= 60 dana od datuma zadnje uplate ). 


B) Automatsko nuđenje 'Datuma vraćanja' kod popravka dokumenta 

Na mapi dokumenta (samo kod popravka postojećeg dokumenta, dok kod unosa novog dokumenta ne) bi radili dvije kontrole/funkcionalnosti, kod: 
1) prikaza mape dokumenta: 
- ako je 'Datum vraćanja' prazan predložili bi datum unosa tj današnji datum. 
- ako nije u skladu s 'Kontrolom 60 dana', prikazati poruku/upozorenje: "Datum vraćanja je veći od zakonskog datuma vraćanja koji je XX.XX.XXXX.", te bi za XX.XX.XXXX prikazali datum vraćanja kao podatak 'Datum zadnje uplate' + 60 dana po ugovoru (u slučaju okvira/krovnog ugovora bi prikazali datum zadnje uplate po zaključenim ugovorima vezanom na njih). 

2) spremanja podataka partnera 
- ako datum vraćanja je u skladu sa "Kontrolom 60 dana" dozvoliti spremanje. 
- ako datum vraćanja nije u skladu sa Kontrolom 60 dana, u tom slučaju prikazati poruku/upozorenje: "Datum vraćanja je veći od zakonskog datuma vraćanja koji je XX.XX.XXXX." te bi za XX.XX.XXXX prikazali datum vraćanja kao podatak 'Datum zadnje uplate' + 60 dana po ugovoru (u slučaju okvira/krovnog ugovora bi prikazali datum zadnje uplate po zaključenom ugovoru vezanom na njih). Na poruci upozorenja bi mogli odabrati, da li želite nastaviti sa spremanjem. Odgovorom na NE, bi se moglo ponovno ručno unijeti datum vraćanja. 

Kontrole bi se pokretale samo u slučaju ako je dokument vezan na 
- ugovor koji je zaključen tj. istekao je (i nije vezan na okvir/krovni ugovor) 
- okvir ili krovni okvir koji je zaključen. 


Molim provjeru da li je dobro sve definirano kako bi vam mogli pripremiti ponudu za navedene dorade. 


Ovdje bi još dodao da kako će koji ugovor na okvirima/krovnim ugovorima biti zaključen, tako će se 'zakonski datum vraćanja' stalno mijenjati, te ćete ga morati redovito provjeravati. 

Za izvještaje 
(CA) Praćenje povrata instrumenata po saldiranim ugovorima 
(CA) Praćenje povrata instrumenata po krovnim ugovorima 
je u Posebnom šifrantu (Održavanje | Šifranti | Posebni šifranti) definiran ID šifrant 'RLC Reporting list' s ključem 'RLC_IOP_LISTA'. U polju 'Opisna vrijednost' je upisana lista svih šifri vrsta dokumenta za koje se prikazuju podaci. Molimo da testirate navedenu funkcionalnost na testu tj. unos nove šifre dokumenta npr. KO (odvojiti sa zarezom), te prikaz podataka na izvještaju. 


31.10.2016
- lista ugovora je ista kao na izvještaju

