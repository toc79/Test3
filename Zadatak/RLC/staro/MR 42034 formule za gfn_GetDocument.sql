select LEN(OPIS1) ,   LEN(OPOMBE), * from dbo.arh_dokument 
where 
LEN(OPIS1) > 4000  OR  LEN(OPOMBE) > 2000

897589
838664
897589
897589

lista na testu za testiranje nove funkcije

select LEN(OPIS1) ,   LEN(OPOMBE), * from dbo.arh_dokument 
where 
LEN(OPIS1) > 4000  OR  LEN(OPOMBE) > 2000


------------------------------------------------------------------------------------------------------------------------------------------------------
-- Function: this function returns all candidates for 1., 2. or 3. reminder from table dok_opom
-- Parameters:
-- @st_opom - reminder number (1, 2, 3)
-- History:
-- 04.05.2005 Adrijan; created
-- 30.10.2007 Matjaz; Task ID 5195 - added field is_epartner
-- 27.07.2010 Ziga; Task ID 5877 - added fields id_klavzule and klavzula from table klavzule_sifr
-- 03.01.2011 IgorS; Bug ID 28641 - added fields valuta, debit, debit_neto, debit_davek, id_dav_st
-- 06.01.2011 IgorS; Bug ID 28641 - added fields opis_dav_stop, neobdav, brez_davka
-- 05.12.2011 Vilko; Bug ID 28641 - modified field datum_zapadlosti - now is set from planp.dat_zap and no more from rac_out.valuta
-- 20.12.2012 Jost; Bug ID 29762 - changed fields 'dat_1op', 'dat_2op', 'dat_3op' 
-- 20.12.2012 Josip; MID 38165 GMC(25004) - added fields ro_izdal, ro_dat_vnosa
-- 16.05.2013 Jost; Bug ID 29762 - fixing: select dat_1op, dat_2op, dat_3op - use '' instead of ''''
-- 05.06.2017 Jure; BUG 33182 - Added call of function dbo.gfn_GetDocument
-- 10.10.2017 Blaz; BID 33384 - implemented gfn_StringToFOX
-- 23.03.2018 Nejc; TID 12991 - GDPR
-- 04.04.2018 Ales; TID 13004 - removed is_epartner
------------------------------------------------------------------------------------------------------------------------------------------------------
--CREATE FUNCTION [dbo].[gfn_DocumentationReminderCandidates2_Arh] 
--(
--1,1,0,0,'',0,0,'',0,'',0,'',0,'',0,'19000101',0,0,'',0,'',0,1,0)
DECLARE 
	@criteria_st_opom_enabled bit = 1,
	@criteria_st_opom_st int = 1,
	@par_aneks_enabled int = 0,
	@par_aneks_anekstype int = 0,
	@par_aneks_anekses varchar(8000) = '',
	@par_akt_enabled int = 0,
	@par_akt_akttype int = 0,
	@par_akt_akt varchar(8000) = '',
	@par_status_enabled bit = 0,
	@par_status_statusi varchar(8000) = '',
	@par_strm_enabled int = 0,
	@par_strm_strm varchar(8000) = '',
	@par_vrstadoc_enabled int = 0,
	@par_vrstadoc_nacinleas varchar(8000) = '',
	@par_dat_zap_enabled bit = 0,
	@par_dat_zap_dat datetime = '19000101', 
	@par_partner_enabled bit = 0,
	@par_partner_type int = 0, -- 1- exclude these, 2- include only these
	@par_partner_partners varchar(8000) = '',
	@par_paket_enabled bit = 0,
	@par_paket_id char(23) = '',
	@par_izpisan_enabled bit = 0,
	@par_izdanNeizpisan_enabled bit  = 1,
	@par_neizdani_enabled bit  = 0
--)  
--RETURNS TABLE AS
--RETURN
--(
select * from dbo.dokument where id_dokum in 
(
	SELECT
		--TOP 100 percent
		A.id_opom
		--A.id_dokum, 
		--A.datum, 
		--A.status_akt, 
		--A.st_opomin AS st_opomina, 
		--A.dat_prip, 
		--A.pripravil, 
		----CAST(0 as bit) AS oznacen, 
		--A.id_paketa, 
		--A.dok_opom, 
		--A.ddv_id, 
		--A.ddv_date, 
		--A.izpisan,
		--D.id_cont, 
		--D.id_zapo, 
		--D.opis1, 
		--D.opis, 
		--D.vrednost, 
		--D.opombe, 
		--D.stevilka, 
		--D.id_tec, 
		--D.kolicina, 
		--D.st_nalepke, 
		--D.dat_obv, 
		--D.datum_dok, 
		--D.id_kupca, 
		--D.reg_stev, 
		--D.potrebno, 
		--D.ima, 
		--D.id_obl_zav,
		----dbo.gfn_StringToFOX(D.opis1) AS opis1_cut, dbo.gfn_StringToFOX(D.opombe) AS opombe_cut,  
		--CASE A.id_paketa WHEN '' THEN NULL ELSE D.dat_1op END as dat_1op,
		--CASE A.id_paketa WHEN '' THEN NULL ELSE D.dat_2op END as dat_2op,
		--CASE A.id_paketa WHEN '' THEN NULL ELSE D.dat_3op END as dat_3op,
		--B.dni_opom AS dok_dni_opom, 
		--C.id_pog AS pogodba_id_pog, 
		--C.pred_naj AS pogodba_pred_naj, 
		--C.aneks AS pogodba_aneks, 
		--C.status AS pogodba_status, 
		--C.id_kupca AS pogodba_id_kupca,
		--C.nacin_leas AS pogodba_nacin_leas,
		--C.id_strm AS pogodba_id_strm, 
		--C.status_akt AS pogodba_status_akt,
		--C.sklic AS pogodba_sklic,
		--P.naz_kr_kup AS partner_naz_kr_kup, 
		--P.telefon AS partner_telefon,  
		--P.ulica AS partner_ulica, 
		--P.id_poste AS partner_id_poste,
		--P.mesto AS partner_mesto,
		--P.naziv1_kup AS partner_naziv1_kup,
		--P.naziv2_kup AS partner_naziv2_kup,
		--P.polni_naz AS partner_polni_naz,
		--P.dav_stev AS partner_dav_stev,
		--P.dav_obv AS partner_dav_obv,
		--P.ulica_sed AS partner_ulica_sed,
		--P.id_poste_sed AS partner_id_poste_sed,
		--P.mesto_sed AS partner_mesto_sed,
		--P.emso AS partner_emso,
		--P.vr_osebe AS partner_vr_osebe,
		--P.mesto AS poste_naziv,
		--R.st_sas AS zap_reg_st_sas, 
		--R.reg_stev AS zap_reg_reg_stev,
		--PDS.max_dat_zap,
		----dbo.gfn_edoc_is_edoc_partner(c.id_kupca) as is_epartner,
		--ks.id_klavzule, 
		----cast(ks.klavzula as varchar(max)) as klavzula,
		--pp.dat_zap as datum_zapadlosti,
		--ro.debit,
		--ro.debit_neto, 
		--ro.debit_davek,
		--ro.brez_davka,
		--ro.neobdav,
		--ro.id_dav_st as sifra_davcne_stopnje,
		--DS.opis as opis_dav_stop,
		--ro.izdal as ro_izdal, 
		--ro.dat_vnosa as ro_dat_vnosa
	FROM 
		dbo.arh_dok_opom A
		--cross apply dbo.gfn_GetDocument(a.id_dokum) as D -- dobimo tudi brisane dokumente in njihove vrednosti
		--INNER JOIN dbo.dok B ON D.id_obl_zav = B.id_obl_zav
		--INNER JOIN dbo.pogodba C ON D.id_cont = C.id_cont
		--INNER JOIN dbo.gfn_Partner_Pseudo('gfn_DocumentationReminderCandidates2_Arh',(case when @par_partner_enabled = 1 AND @par_partner_type=2 then 'Kupci' else null end)) P ON C.id_kupca = P.id_kupca
		--LEFT JOIN dbo.zap_reg R on R.id_zapo = D.id_zapo
		--LEFT JOIN dbo.rac_out ro on ro.ddv_id = A.ddv_id
		--LEFT JOIN dbo.klavzule_sifr ks on ks.id_klavzule = ro.id_klavzule
		--LEFT JOIN 
		--(
		--	SELECT 
		--		id_cont, MAX(max_dat_zap) AS max_dat_zap
		--	FROM 
		--		dbo.planp_ds 
		--	GROUP BY 
		--		id_cont
		--) PDS ON PDS.id_cont = D.id_cont
		--LEFT JOIN dbo.dav_stop DS on DS.id_dav_st = ro.id_dav_st
		--LEFT JOIN dbo.planp pp ON pp.st_dok = ro.st_dok
	 WHERE 
		--(@criteria_st_opom_enabled = 0 OR st_opomin = @criteria_st_opom_st) AND 
		--(
		--	@par_aneks_enabled = 0 OR 
		--	CASE 
		--		WHEN @par_aneks_anekstype = 1 THEN 
		--		CASE 
		--			WHEN CHARINDEX(C.aneks, @par_aneks_anekses) = 0 OR aneks = '' THEN 1 
		--			ELSE 0 
		--		END 
		--	ELSE 
		--		CASE 
		--			WHEN CHARINDEX(C.aneks, @par_aneks_anekses) = 0 OR aneks = '' THEN 0 
		--			ELSE 1 
		--		END 
		--	END = 1
		--) AND 
		--(
		--	@par_akt_enabled = 0 OR 
		--	CASE 
		--		WHEN @par_akt_akttype = 1 THEN 
		--		CASE 
		--			WHEN CHARINDEX(C.status_akt, @par_akt_akt) = 0 THEN 1 
		--			ELSE 0 
		--		END
		--	ELSE 
		--		CASE 
		--			WHEN CHARINDEX(C.status_akt, @par_akt_akt) = 0 THEN 0 
		--			ELSE 1 
		--		END
		--	END = 1
		--) AND 
		--(@par_status_enabled = 0 OR CHARINDEX(C.status, @par_status_statusi) > 0) AND 
		--(@par_strm_enabled = 0 OR CHARINDEX(C.id_strm, @par_strm_strm) > 0) AND
		--(@par_vrstadoc_enabled = 0 OR CHARINDEX(D.id_obl_zav,@par_vrstadoc_nacinleas) > 0) AND
		--(@par_dat_zap_enabled = 0 OR (PDS.max_dat_zap > @par_dat_zap_dat AND PDS.max_dat_zap IS NOT NULL)) AND
		--(
		--	@par_partner_enabled = 0 OR 
		--	CASE 
		--		WHEN @par_partner_type = 1	THEN 
		--		CASE 
		--			WHEN CHARINDEX(P.id_kupca, @par_partner_partners) > 0 THEN 0 
		--			ELSE 1 
		--		END
		--	ELSE 
		--		CASE 
		--			WHEN CHARINDEX(P.id_kupca, @par_partner_partners) > 0 THEN 1 
		--			ELSE 0 
		--		END
		--	END = 1
		--) AND 
		(@par_paket_enabled = 0 OR A.id_paketa = @par_paket_id) AND
		(@par_izpisan_enabled = 0 OR A.izpisan = 1) AND
		(@par_izdanNeizpisan_enabled = CAST (0 AS bit) OR (A.id_paketa != '' AND A.izpisan = 0)) AND
		(@par_neizdani_enabled = 0 OR A.id_paketa = '')
--	ORDER BY 1 --C.id_pog
--)
) 
AND LEN(OPIS1) > 4000  or LEN(OPOMBE) > 2000
