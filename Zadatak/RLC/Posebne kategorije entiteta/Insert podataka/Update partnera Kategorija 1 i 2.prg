select kategorija2, kategorija3, * from partner a 
inner join dbo._tmp_kategorije b ON a.id_kupca = b.id_entiteta
WHERE a.kategorija2 IS NOT NULL OR a.kategorija3 IS NOT NULL

*ovo pu�ta� u dio Execute fox script
#INCLUDE locs.h
LOCAL lcXML, lcXmlDiff, lcSQLString, lnErrorCount, lnUkupno, lcOpomba, lnNepromjenjeni, lcXmlDiffTest

lcOpomba = "A�uriranje podatka partnera prema zahtjevu 1797 (MR 39141)"
select rezultat

lnUkupno = RECCOUNT()
lnErrorCount = 0
lnNepromjenjeni = 0
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

REPLACE kategorija2 WITH .NULL. in partner
REPLACE kategorija3 WITH .NULL. in partner
        
	* lcXML = "<?xml version='1.0' encoding='utf-8' ?>" + gcE
    * lcXML = lcXML + '<rpg_partner_update xmlns="urn:gmi:nova:leasing">'
    lcXmlDiffTest = GF_CreateUpdateDifFieldsXML('PARTNER', "partner", "_partner_copy")

	IF EMPTY(lcXmlDiffTest) THEN
		lnNepromjenjeni=lnNepromjenjeni+1
		** pozor("Nijedan podatak nije promijenjen.") && izbaciti ako mo�da ima puno zapisa na kojima nema promjene
		*ENDIF
	ELSE
		REPLACE id WITH 'g_system' IN partner
		
		lcXML = "<?xml version='1.0' encoding='utf-8' ?>" + gcE
		lcXML = lcXML + '<rpg_partner_update xmlns="urn:gmi:nova:leasing">'
		lcXmlDiff = GF_CreateUpdateDifFieldsXML('PARTNER', "partner", "_partner_copy")
	
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
	ENDIF
ENDSCAN
=obvesti("Ukupno: "+allt(trans(lnUkupno))+". Gre�ke: "+allt(trans(lnErrorCount))+". Nepromijenjeni: "+allt(trans(lnNepromjenjeni)))

----
select * from reprogram where time>=getdate()-1 and [user] = 'g_tomislav'
UPDATE reprogram SET [user] = 'g_system' where time>=getdate()-1 and [user] = 'g_tomislav'