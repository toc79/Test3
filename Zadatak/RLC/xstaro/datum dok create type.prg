Poštovani, 
na testu na kalkulaciji na stranici Ponuda smo vam podesili polje 'Dat. prve rate' kao obavezan za unos.

Molim da provjerite podešavanja te izračun EKS-a. 

Ako je EKS na ponudi (klikom na gumb 'EKS') i na ispisu ponude identičan, tada bi na ispisu 
PONUDA 
PODLOGA ZA REPROGRAM stimulsoft 
podesili da se ispisuje EKS sa ponude, a isključili bi funkcionalnost posebnog izračuna EKS-a.

Molim provjeru i povratnu informaciju.

DELETE FROM dbo.DATUM_DOK_CREATE_TYPE
DBCC CHECKIDENT ( 'DATUM_DOK_CREATE_TYPE', RESEED, 0 )
DBCC CHECKIDENT ( 'DATUM_DOK_CREATE_TYPE', NORESEED )

INSERT INTO dbo.DATUM_DOK_CREATE_TYPE(naziv,odmik,delovni_dan,neaktiven) VALUES('Prvi dan u mjesecu',1,0,0)
INSERT INTO dbo.DATUM_DOK_CREATE_TYPE(naziv,odmik,delovni_dan,neaktiven) VALUES('Prvi radni dan u mjesecu',1,1,0)
INSERT INTO dbo.DATUM_DOK_CREATE_TYPE(naziv,odmik,delovni_dan,neaktiven) VALUES('Zadnji radni dan u mjesecu',-1,1,0)
INSERT INTO dbo.DATUM_DOK_CREATE_TYPE(naziv,odmik,delovni_dan,neaktiven) VALUES('Zadnji dan u mjesecu mesecu',-1,0,0)




select * from CUSTOM_SETTINGS where code like 'Nova.LE.Kalkulacija.DDT' --false
UPDATE CUSTOM_SETTINGS SET val = 'true' where code =  'Nova.LE.Kalkulacija.DDT'


select id_datum_dok_create_type, vnesel,* from dbo.PONUDBA where id_datum_dok_create_type IS NOT NULL
UPDATE dbo.PONUDBA SET id_datum_dok_create_type= NULL where id_datum_dok_create_type IS NOT NULL

select id_datum_dok_create_type, vnesel,* from dbo.POGODBA where id_datum_dok_create_type IS NOT NULL
UPDATE dbo.POGODBA SET id_datum_dok_create_type= NULL where id_datum_dok_create_type IS NOT NULL


loForm = GF_GetFormObject("frmKalkulacija")

IF ISNULL(loForm) THEN 
 RETURN
ENDIF

loForm.pgfSve.pgPon.pgfPon.pgOsn.txtZap_2ob.obvezen = .T.
loForm.pgfSve.pgPon.pgfPon.pgOsn.txtZap_2ob.BackColor = 8454143


Poštovani, 
predlažemo da uz polje 'Dat. prve rate' koristite i funkcionalnost određivanja tipa datuma dokumenta. Tu funkcionalnost smo podesili na testu te se tip odabire u polju 'Tip dat. dok.' (podesili smo da je to polje obavezno).
S ovom funkcionalnošću je moguće odrediti kada će biti datum dokumenta rata, trenutno je na testu podešeno opcije
- Prvi dan u mjesecu 
- Prvi radni dan u mjesecu
- Zadnji radni dan u mjesecu
- Zadnji dan u mjesecu.

Time kod svakog promjene datuma rate (na ugovoru, planu otplate ili reprogramu) u slučaju da je unesen drugačiji datum, će se javljati odgovarajuća obavijest.

Cijena ove fun
