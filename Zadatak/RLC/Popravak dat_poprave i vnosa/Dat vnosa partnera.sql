-- L4 '2000-01-12'
-- Migracija u NOVA '2006-10-06'

select a.id_kupca, a.naz_kr_kup, a.dat_vnosa, a.vnesel, a.dat_poprave 
from partner a
left join (
	select id_kupca, [time] from ARH_PARTNER WHERE ACTION = 'I'
) b ON a.id_kupca = b.id_kupca 
where a.dat_vnosa < '2000-01-12' 
order by a.id_kupca, a.dat_vnosa

--DROP TABLE dbo._tmp_partner_dat_vnosa
CREATE TABLE dbo._tmp_partner_dat_vnosa (
id_kupca varchar(6) NOT NULL, 
novi_dat_vnosa datetime NOT NULL)
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000000', '1999-10-01')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000001', '1999-10-29')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000002', '1999-11-03')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000003', '1999-11-03')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000004', '1999-11-03')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000005', '1999-11-03')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000006', '1999-11-03')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000007', '1999-11-03')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000008', '1999-11-03')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000009', '1999-11-03')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000010', '1999-11-03')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000011', '1999-11-05')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000012', '1999-11-05')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000013', '1999-11-05')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000014', '1999-11-05')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000015', '1999-11-05')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000016', '1999-11-05')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000017', '1999-11-05')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000018', '1999-11-05')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000022', '1999-11-05')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000023', '1999-11-05')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000024', '1999-11-05')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000025', '1999-11-05')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000026', '1999-11-08')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000027', '1999-11-08')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000028', '1999-11-08')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000030', '1999-11-08')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000032', '1999-11-08')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000033', '1999-11-16')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000034', '1999-11-16')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000035', '1999-11-16')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000036', '1999-11-16')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000037', '1999-11-16')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000038', '1999-11-16')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000039', '1999-11-23')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000040', '1999-11-23')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000041', '1999-11-23')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000042', '1999-11-23')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000043', '1999-11-23')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000044', '1999-11-23')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000045', '1999-11-23')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000047', '1999-11-30')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000048', '1999-11-30')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000049', '1999-11-30')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000050', '1999-11-30')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000051', '1999-12-09')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000052', '1999-12-09')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000053', '1999-12-09')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000056', '1999-12-16')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000057', '1999-12-16')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000059', '1999-12-16')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000060', '1999-12-16')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000061', '1999-12-17')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000063', '1999-12-17')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000064', '1999-12-17')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000065', '1999-12-17')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000066', '1999-12-18')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000067', '1999-12-19')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000068', '1999-12-20')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000069', '1999-12-21')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000070', '1999-12-22')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000071', '1999-12-22')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000072', '1999-12-22')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000073', '1999-12-22')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000074', '1999-12-22')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000075', '1999-12-22')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000076', '1999-12-23')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000078', '1999-12-23')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000079', '1999-12-24')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000080', '1999-12-24')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000081', '1999-12-24')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000082', '1999-12-24')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000083', '1999-12-28')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000084', '1999-12-28')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000085', '1999-12-28')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000086', '1999-12-28')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000087', '1999-12-28')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000088', '1999-12-28')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000089', '1999-12-28')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000091', '1999-12-28')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000093', '1999-12-28')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000094', '1999-12-28')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000095', '1999-12-28')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000097', '1999-12-28')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000098', '2000-01-05')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000099', '2000-01-07')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000100', '2000-01-07')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000101', '2000-01-10')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000102', '2000-01-10')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000103', '2000-01-10')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000104', '2000-01-10')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000105', '2000-01-10')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000112', '2000-01-10')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000118', '2000-01-10')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000119', '2000-01-10')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('000120', '2000-01-10')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('006051', '2003-04-16')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('006052', '2003-04-16')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('006053', '2003-04-16')
INSERT INTO dbo._tmp_partner_dat_vnosa VALUES ('011889', '2007-07-04')


select * from dbo._tmp_partner_dat_vnosa

begin tran 
UPDATE dbo.PARTNER SET dat_vnosa = b.novi_dat_vnosa
--Select b.*, a.dat_vnosa, * 
FROM dbo.partner a
JOIN dbo._tmp_partner_dat_vnosa b ON a.id_kupca = b.id_kupca
--rollback
--commit

/* 
#INCLUDE locs.h
LOCAL lcXML, lcXmlDiff, lcSQLString, lnErrorCount, lnUkupno, lcOpomba, lnNepromjenjeni

lcOpomba = "Promjena podatka partnera prema zahtjevu 1777 MR(38819)"
select rezultat

lnUkupno=RECCOUNT()
lnErrorCount=0
lnNepromjenjeni=0
go top
scan
      TEXT TO lcSQLString NOSHOW
		SELECT ban_tr1, ban_tr2, ban_zr, boniteta, clan_eu, cona, d_os_izk, dat_opomin, 
			   dat_roj, dat_vnosa, dav_obv, dav_stev, delodajale, direktor, dobavite, email, 
			   emso, emso_kon, ext_id, fax, http, id, id_kupca, id_poste, id_poste_k, id_poste_sed, 
			   id_skis, kontakt, kr_os_izk, kraj_roj, kupci, mesto, mesto_sed, naz_kr_kup, 
			   naziv1_kup, naziv2_kup, opombe, polni_naz, posrednik, sif_dej, st_os_izk, 
			   cast(sys_ts as bigint) as sys_ts, tel_dir, telefon, telefon_k, tr1, tr2, ulica, 
			   ulica_k, ulica_sed, vnesel, vr_osebe, zr1, zr2, zr3, p_kateg, p_oblika, priimek,
			   ime, stev_reg, dat_reg, sod_reg, drzavljan, dat_poprave,ulica_d, id_poste_d, mesto_d, p_status, kontakt_d,
			   tip_os_izk, zac_pos, spol, zak_stan, st_otrok, poklic, izobrazba, vrst_preb, akad_naziv, asset_clas,
			   ustanovit, opis_dej, dob_kup, del_mesto, zap_od, zap_do, tip_zap, gsm, telefon_s, skrbnik_1, skrbnik_2,
			   d_vrednot, ne_na_bl, watch_from, neaktiven, kategorija1, kategorija2, kategorija3, tuja_pio, ident_stevilka,
			   izd_os_izk, kategorija4, kategorija5, kategorija6, ulica_st, ulica_st_sed, d_velj_os_izk, drzavljanstvo, drzava_rojstva --dodano u 2.22
		FROM dbo.partner
	ENDTEXT
	lcSQLString = lcSQLString + " WHERE id_kupca= "+GF_QuotedStr(allt(rezultat.id_kupca))
	GF_SQLEXEC(lcSQLString, "partner")

        SELECT * FROM partner INTO CURSOR _partner_copy

REPLACE dat_vnosa WITH rezultat.novi_dat_vnosa in partner
REPLACE id WITH 'g_system' IN partner
        
	lcXML = "<?xml version='1.0' encoding='utf-8' ?>" + gcE
    lcXML = lcXML + '<rpg_partner_update xmlns="urn:gmi:nova:leasing">'
    lcXmlDiff = GF_CreateUpdateDifFieldsXML('PARTNER', "partner", "_partner_copy")

&& izbaciti ako možda ima puno zapisa na kojima nema promjene
	IF EMPTY(lcXmlDiff) THEN
		lnNepromjenjeni=lnNepromjenjeni+1
		** pozor("Nijedan podatak nije promijenjen.")
	ENDIF
		
  	lcXML = "<?xml version='1.0' encoding='utf-8' ?>"
	lcXML = lcXML + '<rpg_partner_update xmlns="urn:gmi:nova:leasing">' + gcE
	lcXML = lcXML + '<common_parameters>'+ gcE
	lcXML = lcXML + GF_CreateNode("id_kupca", partner.id_kupca, "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("comment", lcOpomba, "C", 1)+ gcE
	lcXML = lcXML + GF_CreateNode("sys_ts", partner.sys_ts, "I", 1) + gcE
	lcXML = lcXML + '</common_parameters>'+ gcE

	lcXmlDiff = lcXmlDiff + '<updated_values>' + gcE
	lcXmlDiff = lcXmlDiff + GF_CreateNode("table_name", "partner", "C", 1)+ gcE
	lcXmlDiff = lcXmlDiff + GF_CreateNode("name", "dat_poprave", "C", 1)+ gcE
	lcXmlDiff = lcXmlDiff + GF_CreateNode("updated_value", DATETIME(), "T", 1)+ gcE
	lcXmlDiff = lcXmlDiff + '</updated_values>'
	
	lcXML = lcXML + lcXmlDiff
	lcXML = lcXML + "</rpg_partner_update>"

	IF !GF_ProcessXml(lcXML) THEN
	   lnErrorCount=lnErrorCount+1
	ENDIF
endscan
=obvesti("Ukupno: "+allt(trans(lnUkupno))+". Greške: "+allt(trans(lnErrorCount))+". Nepromijenjeni: "+allt(trans(lnNepromjenjeni))) */