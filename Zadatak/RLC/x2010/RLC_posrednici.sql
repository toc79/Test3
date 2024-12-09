


--kreiranje privremene tabele koju æeš koristiti za update
drop table dbo.[_partner_pos]

CREATE TABLE dbo.[_partner_pos] (
	[id_kupca] [char] (6) COLLATE Croatian_CI_AS NOT NULL ,
        [posrednik] [bit] NULL
) ON [PRIMARY]

--provjera podataka
select * from _partner_pos

--primjer inserta iz podataka koje dobijemo u excelu
insert into _partner_pos --(id_kupca,posrednik) values ('000009','4c')
select id_kupca,0   from partner where posrednik=1



--ovo se sad izvodi kroz program i ovo upišeš u opciju Ostalo| Održavatelj| Sql query s time da u polje Result alias upišeš rezultat(to æe ti biti ime cursora) i pokreneš ovaj select
Select id_kupca,posrednik from _partner_pos order by id_kupca

--ovo puštaš u dio Execute fox script
#INCLUDE locs.h
LOCAL lcSql, lcNewId, lcVr_osebe, lcE, lcObvesti, lcXML, lcId_kupca, lcXmlDiff, lcSQLString, lnErrorCount, lnUkupno, lcOpomba

lcOpomba = "Ažuriranje podatka Posrednik partnera prema zahtjevu 18881"
select rezultat

lnUkupno=RECCOUNT()
lnErrorCount=0
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
		       d_vrednot, ne_na_bl, watch_from, neaktiven, kategorija1, kategorija2, kategorija3, tuja_pio, ident_stevilka
		  FROM dbo.partner
	ENDTEXT
	lcSQLString = lcSQLString + " WHERE id_kupca= "+GF_QuotedStr(allt(rezultat.id_kupca))
	GF_SQLEXEC(lcSQLString, 'partner')

        SELECT * FROM partner INTO CURSOR _partner_copy

        REPLACE posrednik WITH rezultat.posrednik in partner

        lcE = CHR(13) + CHR(10)
        lcE = CHR(13) + CHR(10)
	lcXML = "<?xml version='1.0' encoding='utf-8' ?>" + LcE
        lcXML = lcXML + '<rpg_partner_update xmlns="urn:gmi:nova:leasing">'

        REPLACE id WITH ALLTRIM(GObj_Comm.GetUserName()) IN partner

        lcXmlDiff = GF_CreateUpdateDifFieldsXML('PARTNER', "partner", "_partner_copy")
	IF EMPTY(lcXmlDiff) THEN
		pozor("Nijedan podatak nije promijenjen.")
        ENDIF

        lcXmlDiff = lcXmlDiff + '<updated_values>' + lcE
	lcXmlDiff = lcXmlDiff + GF_CreateNode("table_name", "partner", "C", 1)+ lcE
	lcXmlDiff = lcXmlDiff + GF_CreateNode("name", "dat_poprave", "C", 1)+ lcE
	lcXmlDiff = lcXmlDiff + GF_CreateNode("updated_value", DATETIME(), "T", 1)+ lcE
	lcXmlDiff = lcXmlDiff + '</updated_values>'

	lcXML = "<?xml version='1.0' encoding='utf-8' ?>"
	lcXML = lcXML + '<rpg_partner_update xmlns="urn:gmi:nova:leasing">' + lcE
	lcXML = lcXML + '<common_parameters>'+ lcE
	lcXML = lcXML + GF_CreateNode("id_kupca", partner.id_kupca, "C", 1)+ lcE
	lcXML = lcXML + GF_CreateNode("comment", lcOpomba, "C", 1)+ lcE
	lcXML = lcXML + GF_CreateNode("sys_ts", partner.sys_ts, "I", 1) + lcE
	lcXML = lcXML + '</common_parameters>'+ lcE

	lcXML = lcXML + lcXmlDiff
	lcXML = lcXML + "</rpg_partner_update>"

        IF !GF_ProcessXml(lcXML) THEN
	   lnErrorCount=lnErrorCount+1
	ENDIF
endscan
=obvesti("Ukupno: "+allt(trans(lnUkupno))+". Greške: "+allt(trans(lnErrorCount)))
