--Primjer inserta 
-- DROP TABLE dbo._tmp_kategorije
CREATE TABLE dbo._tmp_kategorije (sifra_kategorije varchar(20) NOT NULL
, id_pog varchar(30) NULL
, id_entiteta varchar(100) NULL
, id_kategorije_sifrant_new varchar(200)
, val_string_new varchar(max)
, val_decimal_new decimal(24,8)
, val_datetime_new datetime) --
INSERT INTO dbo._tmp_kategorije VALUES ('P1', NULL, '001537', NULL, '7719', NULL, NULL)


*Kandidati će biti kao u excelu samo za postojeće partnere
select * from _tmp_kategorije a
JOIN dbo.PARTNER b ON a.id_entiteta = b.id_kupca

*1. Provjera brisanja kategorije 2 i 3 partnera
select kategorija2, * from partner where kategorija2 is not null and kategorija2 !=''
select kategorija3, * from partner where kategorija3 is not null and kategorija3 !=''
jedan više je na PROD provjeriti koji je to id_kupca

*PROMJENA SQL
select c.id_entiteta, a.entiteta , c.val_string_new, a.id_kategorije_tip
from _tmp_kategorije c 
LEFT JOIN dbo.kategorije_tip a ON c.sifra_kategorije = a.sifra
left join dbo.kategorije_entiteta b on a.id_kategorije_tip = b.id_kategorije_tip and b.id_entiteta = c.id_entiteta
where c.id_entiteta is not null
order by c.id_entiteta

*FOX kategorije_entiteta_maska.scx PROCEDURE shrani
#INCLUDE locs.h

LOCAL lnErrorCount, lnUkupno, lnNepromjenjeni
SELE rezultat
lnUkupno = RECCOUNT()
lnErrorCount = 0
lnNepromjenjeni = 0
GO TOP

SCAN
	LOCAL lcSql, laPar[2], lcTekst, lcOpis 
	TEXT TO lcSql NOSHOW
		select 
		b.id_kategorije_entiteta, a.id_kategorije_tip, c.id_entiteta, a.tip_polja
		, c.id_kategorije_sifrant_new, c.val_string_new, c.val_decimal_new, c.val_datetime_new -- ili prema kategorije_entiteta b tabeli, početno su kreirane da imaju odgovarajući format u kursoru dolje 
		, a.prosti_vnos, b.val_string, b.val_datetime, b.val_decimal, b.id_kategorije_sifrant
		FROM dbo.kategorije_tip a
		left join dbo.kategorije_entiteta b on a.id_kategorije_tip = b.id_kategorije_tip and b.id_entiteta = ?p2
		LEFT JOIN dbo._tmp_kategorije c ON b.id_entiteta= c.id_entiteta
		where a.entiteta = ?p1 and a.neaktiven = 0
		order by a.id_kategorije_tip
	ENDTEXT

	laPar[1] = rezultat.entiteta
	laPar[2] = rezultat.id_entiteta

	GF_SqlExec_P(lcSql, @laPar, "kategorije")

	SELECT kategorije
	REPLACE ALL id_entiteta WITH rezultat.id_entiteta && AKO SU PRAZNE VRIJEDNOSTI ŠIFRANTA ZA TAJ ENTITET
	*Setirnje u NULL, početno su kreirane da imaju odgovarajući format u kursoru
	REPLACE ALL id_kategorije_sifrant_new WITH .NULL.
	REPLACE ALL val_string_new WITH .NULL.
	REPLACE ALL val_decimal_new WITH .NULL.
	REPLACE ALL val_datetime_new WITH .NULL.
	
	*Setiranje samo odgovarajućih vrijednosti, ostale se ne smiju setirati moraju biti NULL
	*REPLACE val_datetime_new WITH rezultat.val_datetime_new FOR rezultat.id_kategorije_tip = kategorije.id_kategorije_tip  && OVO JE PROMJENJIVO
	REPLACE val_string_new WITH rezultat.val_string_new FOR rezultat.id_kategorije_tip = kategorije.id_kategorije_tip  && OVO JE PROMJENJIVO
	LOCATE 
		
		LOCAL lcText, lcXml, lcS, loObjVal
		lcS = SPACE(4)
		*IF Thisform.preveri_podatke(Thisform) 
		 	*lcText = INFSAVED_LOC
			lcXml = "<kategorije_entiteta_insert_update xmlns='urn:gmi:nova:core_bl'>" + gcE
			SELECT kategorije
			SCAN 
				lcXml = lcXml + "<kategorija_entiteta>" + gcE
				IF !GF_NullOrEmpty(kategorije.id_kategorije_entiteta) THEN
					lcXml = lcXml + lcS + GF_CreateNode("id_kategorije_entiteta", kategorije.id_kategorije_entiteta, "I", 1) + gcE
				ENDIF 
				lcXml = lcXml + lcS + GF_CreateNode("id_kategorije_tip", kategorije.id_kategorije_tip, "I", 1) + gcE
				lcXml = lcXml + lcS + GF_CreateNode("id_entiteta", kategorije.id_entiteta, "C", 1) + gcE
				
				*loObjVal = "Thisform." + ALLTRIM(kategorije.obj_name) + ".Value"
				DO CASE 
					CASE ALLTRIM(UPPER(kategorije.tip_polja)) == "TEXT"
						*IF !GF_NullOrEmpty(&loObjVal) THEN 
						IF !GF_NullOrEmpty(kategorije.val_string) OR !GF_NullOrEmpty(kategorije.val_string_new) THEN 
							*lcXml = lcXml + lcS + GF_CreateNode("val_string", &loObjVal, "C", 1) + gcE
							lcXml = lcXml + lcS + GF_CreateNode("val_string", IIF(GF_NullOrEmpty(kategorije.val_string_new), kategorije.val_string , kategorije.val_string_new), "C", 1) + gcE
						ENDIF 
		
					CASE ALLTRIM(UPPER(kategorije.tip_polja)) == "DATETIME"
						IF !GF_NullOrEmpty(kategorije.val_datetime) OR !GF_NullOrEmpty(kategorije.val_datetime_new) THEN 
							lcXml = lcXml + lcS + GF_CreateNode("val_datetime", IIF(GF_NullOrEmpty(kategorije.val_datetime_new), kategorije.val_datetime, kategorije.val_datetime_new), "D", 1) + gcE
						ENDIF 
		
					CASE ALLTRIM(UPPER(kategorije.tip_polja)) == "NUMBER"
						IF !GF_NullOrEmpty(kategorije.val_decimal) OR kategorije.prosti_vnos OR !GF_NullOrEmpty(kategorije.val_decimal_new)THEN 
							lcXml = lcXml + lcS + GF_CreateNode("val_decimal", IIF(GF_NullOrEmpty(kategorije.val_decimal_new), kategorije.val_decimal, kategorije.val_decimal_new) , "N", 1) + gcE
						ENDIF 
					
					CASE ALLTRIM(UPPER(kategorije.tip_polja)) == "COMBOBOX"
						IF !GF_NullOrEmpty(kategorije.id_kategorije_sifrant) OR !GF_NullOrEmpty(kategorije.id_kategorije_sifrant) THEN 
							lcXml = lcXml + lcS + GF_CreateNode("id_kategorije_sifrant", IIF(GF_NullOrEmpty(kategorije.id_kategorije_sifrant_new), kategorije.id_kategorije_sifrant, kategorije.id_kategorije_sifrant_new) , "I", 1) + gcE
						ENDIF 
				ENDCASE 
				
				lcXml = lcXml + "</kategorija_entiteta>" + gcE
			ENDSCAN
			lcXml = lcXml + "</kategorije_entiteta_insert_update>" + gcE
		
			IF !GF_ProcessXml(lcXml) THEN
				lnErrorCount = lnErrorCount + 1 && RETURN .F.
			ENDIF
ENDSCAN

=obvesti("Ukupno: "+allt(trans(lnUkupno))+". Greške: "+allt(trans(lnErrorCount)))


select * from reprogram where time>=getdate()-1 and [user] = 'g_tomislav'
--UPDATE reprogram SET [user] = 'g_system' where time>=getdate()-1 and [user] = 'g_tomislav'


begin tran
UPDATE dbo.kategorije_entiteta SET vnesel_username = 'g_system' WHERE vnesel_username = 'g_tomislav'
UPDATE dbo.kategorije_entiteta SET poprava_username = 'g_system' WHERE poprava_username = 'g_tomislav'
--commit
--rollback

select vnesel_username, vnesel_date, * from dbo.kategorije_entiteta 
where vnesel_username = 'g_tomislav'
select poprava_username, poprava_date, *  from dbo.kategorije_entiteta 
where poprava_username= 'g_tomislav'

			*obvesti(lcText)
			** nastavimo, da se lahko zapusti formo
			*Thisform.Tip_vnosne_maske = 0
			*Thisform.Release 
		*ELSE
		*	RETURN .F.
		*ENDIF
	*ENDPROC

	*U2 POGODBA
<kategorije_entiteta_insert_update xmlns='urn:gmi:nova:core_bl'>
<kategorija_entiteta>
    <id_kategorije_tip>1</id_kategorije_tip>
    <id_entiteta>58406</id_entiteta>
</kategorija_entiteta>
<kategorija_entiteta>
    <id_kategorije_tip>2</id_kategorije_tip>
    <id_entiteta>58406</id_entiteta>
    <val_datetime>2017-10-18T00:00:00.000</val_datetime>
</kategorija_entiteta>
<kategorija_entiteta>
    <id_kategorije_tip>7</id_kategorije_tip>
    <id_entiteta>58406</id_entiteta>
</kategorija_entiteta>
</kategorije_entiteta_insert_update>

*P1 PARTNAR
<kategorije_entiteta_insert_update xmlns='urn:gmi:nova:core_bl'>
<kategorija_entiteta>
    <id_kategorije_tip>3</id_kategorije_tip>
    <id_entiteta>031540</id_entiteta>
    <val_string>test Fraud P1</val_string>
</kategorija_entiteta>
<kategorija_entiteta>
    <id_kategorije_tip>12</id_kategorije_tip>
    <id_entiteta>031540</id_entiteta>
</kategorija_entiteta>
</kategorije_entiteta_insert_update>

*P2 Partner
<kategorije_entiteta_insert_update xmlns='urn:gmi:nova:core_bl'>
<kategorija_entiteta>
    <id_kategorije_tip>3</id_kategorije_tip>
    <id_entiteta>001095</id_entiteta>
</kategorija_entiteta>
<kategorija_entiteta>
    <id_kategorije_tip>12</id_kategorije_tip>
    <id_entiteta>001095</id_entiteta>
    <val_string>Test P2 Ostalo</val_string>
</kategorija_entiteta>
</kategorije_entiteta_insert_update>

** Promjena
<kategorije_entiteta_insert_update xmlns='urn:gmi:nova:core_bl'>
<kategorija_entiteta>
    <id_kategorije_tip>3</id_kategorije_tip>
    <id_entiteta>001095</id_entiteta>
</kategorija_entiteta>
<kategorija_entiteta>
    <id_kategorije_entiteta>39</id_kategorije_entiteta>
    <id_kategorije_tip>12</id_kategorije_tip>
    <id_entiteta>001095</id_entiteta>
    <val_string>Test P2 Ostalo Promjena</val_string>
</kategorija_entiteta>
</kategorije_entiteta_insert_update>

*Promejna bez promjene podataka -> NETREBA SE RADITI PROVJERA PODATAKA U SQLu ALI BI SE MOGLO
<kategorije_entiteta_insert_update xmlns='urn:gmi:nova:core_bl'>
<kategorija_entiteta>
    <id_kategorije_tip>3</id_kategorije_tip>
    <id_entiteta>001095</id_entiteta>
</kategorija_entiteta>
<kategorija_entiteta>
    <id_kategorije_entiteta>39</id_kategorije_entiteta>
    <id_kategorije_tip>12</id_kategorije_tip>
    <id_entiteta>001095</id_entiteta>
    <val_string>Test P2 Ostalo Promjena</val_string>
</kategorija_entiteta>
</kategorije_entiteta_insert_update>


select c.id_entiteta, a.entiteta, 
b.id_kategorije_entiteta, a.id_kategorije_tip, a.tip_polja
, c.id_kategorije_sifrant_new, c.val_string_new, c.val_decimal_new, c.val_datetime_new
--, b.val_datetime, b.val_string
--, c.*, 
--	a.id_kategorije_tip, a.entiteta, a.sifra, a.naziv, a.tip_polja, a.maska, a.prosti_vnos, a.obvezen, a.neaktiven, 
--	b.id_kategorije_entiteta, b.id_entiteta, b.id_kategorije_sifrant, b.val_string, b.val_decimal, b.val_datetime
--	--, cast('' as varchar(50)) as obj_name
from _tmp_kategorije c 
	LEFT JOIN dbo.kategorije_tip a ON c.sifra_kategorije = a.sifra
	left join dbo.kategorije_entiteta b on a.id_kategorije_tip = b.id_kategorije_tip and b.id_entiteta = c.id_entiteta
where c.id_entiteta is not null
-- a.entiteta = ?p1 and a.neaktiven = 0
order by b.id_kategorije_entiteta DESC, a.id_kategorije_tip