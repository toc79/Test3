-- USE [Nova_hls]
-- GO
-- /****** Object:  UserDefinedFunction [dbo].[gfn_Report_SumPartner]    Script Date: 12.1.2017. 14:21:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

------------------------------------------------------------------------------------------------------------
-- Function for getting data for PP_Izbor, search type 4
-- 
--
-- History:
-- 21.11.2003 Muri; created
-- 20.03.2004 Matjaz; Changes due to id_cont 2 PK transition
-- 09.06.2004 Muri & Matjaz; moved commented part of where statement to 
-- 			first level select and reorganized the whole function
-- 10.06.2004 Matjaz; moved CHARINDEX(PP.ID_Terj,@CriteriaTerj) from WHERE statement to each separate line, because it is used differently for separate columns
-- 30.08.2004 Muri; chenge inputparameter & WHERE statement
-- 01.09.2004 Muri, spremenil char in varchar(X) v varchar(8000), 
-- 24.09.2004 Muri; popravil WHERE za ObrokovALI
-- 28.02.2005 Darko: added @par_akt_...
-- 16.11.2005 Vilko; modified condition for aneks - in case of aneks type 1 or 2 added - or aneks = ''
-- 15.09.2006 Vik; Bug id 26237 - fixed conditions for planp (contract conditions must be also enforced) + beautification
-- 09.10.2006 Vilko; Bug ID 26307 - added fields se_neto, se_obresti, se_marza, se_regist, se_bruto, se_fin_davek
-- 16.01.2007 Jasna; changed field length naz_kr_kup (40-->80)
-- 12.07.2007 MatjazB; Bug ID 26756 - added parameters for criteria (STRM)
-- 29.01.2008 Vilko; Bug ID 27081 - added field boniteta
-- 17.11.2008 Matjaz; Bug ID 27564 - bugfix at candidate prepare - now also third party customers with no contracts are included
-- 24.02.2009 Ziga; MID 19319 - added conditions for criteria in last update for future debt
-- 24.02.2009 Ziga; Bug ID 27738 - removed unnecessary criteria @par_prevzetepog_enabled. Criteria @par_ZnesekObrok_enabled is now used.
-- 27.02.2009 Ziga; Bug ID 27740 - added condition AND evident = '*' for open claims and condition OR evident = '' for future claims
-- 03.04.2009 Ziga; MID 20109 - repaired calculation of field St_pogodb
-- 04.05.2009 PetraR; MID 20346 - added field partner.posrednik
-- 31.05.2010 MatjazB; MID 25383 - change type of parameter @par_Obrok and @par_ObrokALI from int to decimal(18,2)
-- 05.08.2010 MatjazB; MID 26412 - added check for @simulacija - date to is bigger then today (functionality before Bug ID 27740 and same as L4)
-- 19.05.2014 Jelena; Task ID 8059 - added Od_Robresti and Se_Robresti
-- 26.05.2015 Jure: TASK 8680 - Added support for claim OOBR when interpret longterm claims ONLY.
-- 01.06.2015 Domen; TaskID 8468 - Anonymize displaying of EMSO.
-- 07.07.2016 Nenad; GMC MID 35980 - speed optimization
------------------------------------------------------------------------------------------------------------C
ALTER                      FUNCTION [dbo].[gfn_Report_SumPartner] (
	@par_partner_enabled int,
	@par_partner_partner varchar(8000), 
	@par_obdobjepolje_enabled int,
	@par_obdobjepolje_datumod datetime,
	@par_obdobjepolje_datumdo datetime,
	@par_obdobjepolje_polje int,
	@par_tecajnica_enabled int,
	@par_tecajnica_tecajnica char(3),
	@par_tecajnica_datumtec datetime,
	@par_tecajnica_valuta char(3), 
	@par_ZnesekObrok_enabled as int,
	@par_Znesek as decimal(18,2),
	@par_ObrokALI as decimal(18,2),
	@par_Obrok as decimal(18,2),
	@par_aneks_enabled int,
	@par_aneks_anekstype int,
	@par_aneks_anekses varchar(8000), 
	@par_akt_enabled int,
	@par_akt_akttype int,
	@par_akt_akt varchar(8000),  
	@par_nacinleas_enabled int, 
	@par_nacinleas_nacinleas varchar(8000),
	@par_Aktivirane_enabled int,
	@par_Aktivirane as datetime,
	@par_strm_enabled int,
	@par_strm_strm varchar(8000), --@niz_strm
	@par_vnesel_enabled int,
	@par_vnesel_vnesel varchar(8000)
)
RETURNS @Result TABLE
   (
    ID_Kupca char(6), 
    Naz_kr_kup varchar(80),
    Emso char(13),
    Vr_osebe char(2),
    St_pogodb int,
    Debit decimal(18,2),
    Kredit decimal(18,2),
    Saldo decimal(18,2),
    Proc_plac decimal(18,2),
    Obrokov decimal(18,2),
    Obr_Pog decimal(18,2),
    Od_Neto decimal(18,2),
    Od_Obresti decimal(18,2),
    Od_Marza decimal(18,2),
    Od_Regist decimal(18,2),
    Od_Davek decimal(18,2),
	Od_Robresti decimal(18,2),
    Od_ONeto decimal(18,2),
    Od_ODavek decimal(18,2),
    Od_OMarza decimal(18,2),
    Se_neto decimal(18,2),
    Se_obresti decimal(18,2),
    Se_marza decimal(18,2),
    Se_regist decimal(18,2),
	Se_Robresti decimal(18,2), 
    Se_bruto decimal(18,2),
    Se_fin_davek decimal(18,2),
    Boniteta char(10),
    Posrednik bit
   )
AS
BEGIN
    DECLARE @CriteriaTerj varchar(255), @CriteriaTerj2 varchar(255), @CriteriaTerj_LOBR varchar(255)
    SET @CriteriaTerj_LOBR = (SELECT ID_Terj FROM dbo.vrst_ter WHERE Sif_terj = 'LOBR') 
	SET @CriteriaTerj = (SELECT ID_Terj FROM dbo.vrst_ter WHERE Sif_terj = 'LOBR')+ ',' + 
        (SELECT ID_Terj FROM dbo.vrst_ter WHERE Sif_terj = 'OOBR')
    SET @CriteriaTerj2 = 
        (SELECT ID_Terj FROM dbo.vrst_ter WHERE Sif_terj = 'POLO') + ',' + 
        (SELECT ID_Terj FROM dbo.vrst_ter WHERE Sif_terj = 'LOBR') + ',' + 
        (SELECT ID_Terj FROM dbo.vrst_ter WHERE Sif_terj = 'OPC') + ',' + 
        (SELECT ID_Terj FROM dbo.vrst_ter WHERE Sif_terj = 'OOBR')

    DECLARE @simulacija bit 
    SET @simulacija = CASE WHEN @par_obdobjepolje_datumdo > (SELECT GetDateNow FROM dbo.gv_GetDateNow) THEN 1 ELSE 0 END

	DECLARE @anonymize_ids bit
	SET @anonymize_ids = 0
	IF @par_vnesel_enabled = 1 and len(@par_vnesel_vnesel) > 0 BEGIN
		SET @anonymize_ids = dbo.gfn_AnonimizirajPodatke('frmparams_ppizbor', @par_vnesel_vnesel)
	END

	INSERT INTO @Result 
	SELECT	
		C.ID_Kupca, C.Naz_kr_kup, case when vo.SIFRA = 'FO' and @anonymize_ids = 1 then dbo.gfn_Anonimiziraj(C.Emso, 4, 'r') else C.Emso end as Emso, 
		C.Vr_Osebe, SUM(case when A.id_kupca = P.id_kupca then 1 else 0 end) AS St_pogodb, 
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, C.Boniteta, C.Posrednik
	FROM	
		dbo.Partner C 
		inner join (select distinct id_kupca, id_cont from dbo.planp) A ON c.id_kupca = a.id_kupca
		inner join dbo.Pogodba P ON A.id_cont = P.id_cont
		inner join dbo.VRST_OSE vo on vo.VR_OSEBE = C.vr_osebe
	WHERE	
		(@par_aneks_enabled = 0 OR (@par_aneks_anekstype = 1 AND (CHARINDEX(P.aneks, @par_aneks_anekses) = 0 OR P.aneks = '')) OR (@par_aneks_anekstype = 2 AND NOT(CHARINDEX(P.aneks, @par_aneks_anekses) = 0 OR P.aneks = ''))) AND
		1 = (CASE WHEN @par_akt_enabled = 1 THEN (CASE WHEN @par_akt_akttype = 1 THEN (CASE WHEN CHARINDEX(p.status_akt,@par_akt_akt) = 0 THEN 1 ELSE 0 END) ELSE (CASE WHEN CHARINDEX(p.status_akt,@par_akt_akt) = 0 THEN 0 ELSE 1 END) END) ELSE 1 END) AND
		
		(@par_partner_enabled = 0 OR C.ID_Kupca = @par_partner_partner) 
		AND
		(@par_nacinleas_enabled = 0 OR CHARINDEX(P.nacin_leas, @par_nacinleas_nacinleas) > 0) AND
		(@par_Aktivirane_enabled = 0 OR P.Dat_aktiv < @par_Aktivirane) AND
		(@par_strm_enabled = 0 OR (CHARINDEX(P.id_strm, @par_strm_strm) > 0))
	GROUP BY C.ID_Kupca, C.Naz_kr_kup, C.Emso, C.Vr_Osebe, C.Boniteta, C.Posrednik, vo.SIFRA
	
	UPDATE	@Result
	SET		Debit = T.Debit,
			Kredit = T.Kredit,
			Saldo = T.Saldo,
			Obrokov = T.Obrokov,
			Od_Neto = T.Od_Neto,
			Od_Obresti = T.Od_Obresti,
			Od_Regist = T.Od_Regist,
			Od_Marza = T.Od_Marza,
			Od_Davek = T.Od_Davek,
			Od_Robresti = T.Od_Robresti,
			Od_ONeto = T.Od_ONeto,
			Od_ODavek = T.Od_ODavek,
			Od_OMarza = T.Od_OMarza
	FROM		@Result AS R 
	inner join (
			Select x.id_kupca,
					SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, x.Od_Neto, x.ID_tec, @par_tecajnica_datumtec)) as Od_Neto,
					SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, x.Od_Obresti, x.ID_tec, @par_tecajnica_datumtec)) as Od_Obresti,
					SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, x.Od_Marza, x.ID_tec, @par_tecajnica_datumtec)) as Od_Marza,
					SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, x.Od_Regist, x.ID_tec, @par_tecajnica_datumtec)) as Od_Regist,
					SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, x.Od_Davek, x.ID_tec, @par_tecajnica_datumtec)) as Od_Davek, 
					SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, x.Od_Robresti, x.ID_tec, @par_tecajnica_datumtec)) as Od_Robresti, 
					SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, x.Od_ONeto, x.ID_tec, @par_tecajnica_datumtec)) as Od_ONeto,
					SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, x.Od_ODavek, x.ID_tec, @par_tecajnica_datumtec)) as Od_ODavek,
					SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, x.Od_OMarza, x.ID_tec, @par_tecajnica_datumtec)) as Od_OMarza,
					SUM(x.Obrokov) as Obrokov, -- DOLGUJE
					SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, X.Debit, X.ID_tec, @par_tecajnica_datumtec)) AS Debit,
					SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, X.Kredit, X.ID_tec, @par_tecajnica_datumtec)) AS Kredit,
					SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, X.Saldo, X.ID_tec, @par_tecajnica_datumtec)) AS Saldo		
			From (
				SELECT	PP.ID_Kupca, PP.ID_TEC,
					SUM(CASE WHEN CHARINDEX(PP.ID_Terj,@CriteriaTerj) > 0 AND (@simulacija = 1 OR (@simulacija = 0 AND pp.evident = '*')) THEN ((PP.saldo/PP.debit)*PP.neto) ELSE 0 END) as Od_Neto,
					SUM(CASE WHEN CHARINDEX(PP.ID_Terj,@CriteriaTerj) > 0 AND (@simulacija = 1 OR (@simulacija = 0 AND pp.evident = '*')) THEN ((PP.saldo/PP.debit)*PP.obresti) ELSE 0 END) as Od_Obresti,
					SUM(CASE WHEN CHARINDEX(PP.ID_Terj,@CriteriaTerj) > 0 AND (@simulacija = 1 OR (@simulacija = 0 AND pp.evident = '*')) THEN ((PP.saldo/PP.debit)*PP.marza) ELSE 0 END) as Od_Marza,
					SUM(CASE WHEN CHARINDEX(PP.ID_Terj,@CriteriaTerj) > 0 AND (@simulacija = 1 OR (@simulacija = 0 AND pp.evident = '*')) THEN ((PP.saldo/PP.debit)*PP.regist) ELSE 0 END) as Od_Regist,
					SUM(CASE WHEN CHARINDEX(PP.ID_Terj,@CriteriaTerj) > 0 AND (@simulacija = 1 OR (@simulacija = 0 AND pp.evident = '*')) THEN ((PP.saldo/PP.debit)*PP.davek) ELSE 0 END) as Od_Davek, 
					SUM(CASE WHEN CHARINDEX(PP.ID_Terj,@CriteriaTerj) > 0 AND (@simulacija = 1 OR (@simulacija = 0 AND pp.evident = '*')) THEN ((PP.saldo/PP.debit)*PP.robresti) ELSE 0 END) as Od_Robresti, 
					SUM(CASE WHEN CHARINDEX(PP.ID_Terj,@CriteriaTerj) = 0 AND (@simulacija = 1 OR (@simulacija = 0 AND pp.evident = '*')) THEN ((PP.saldo/PP.debit)*PP.neto) ELSE 0 END) as Od_ONeto,
					SUM(CASE WHEN CHARINDEX(PP.ID_Terj,@CriteriaTerj) = 0 AND (@simulacija = 1 OR (@simulacija = 0 AND pp.evident = '*')) THEN ((PP.saldo/PP.debit)*PP.davek) ELSE 0 END) as Od_ODavek,
					SUM(CASE WHEN CHARINDEX(PP.ID_Terj,@CriteriaTerj) = 0 AND (@simulacija = 1 OR (@simulacija = 0 AND pp.evident = '*')) THEN ((PP.saldo/PP.debit)*PP.marza) ELSE 0 END) as Od_OMarza,
					SUM(CASE WHEN CHARINDEX(PP.ID_Terj,@CriteriaTerj_LOBR) > 0 AND (@simulacija = 1 OR (@simulacija = 0 AND pp.evident = '*')) AND PP.Saldo > 0 THEN CASE WHEN PP.Debit = 0 THEN 0 ELSE PP.saldo/PP.debit END ELSE 0 END) as Obrokov, -- DOLGUJE
					SUM(CASE WHEN (@simulacija = 1 OR (@simulacija = 0 AND pp.evident = '*')) THEN PP.debit ELSE 0 END) AS Debit,
					SUM(CASE WHEN (@simulacija = 1 OR (@simulacija = 0 AND pp.evident = '*')) THEN PP.Kredit ELSE 0 END) AS Kredit,
					SUM(CASE WHEN (@simulacija = 1 OR (@simulacija = 0 AND pp.evident = '*')) THEN PP.Saldo ELSE 0 END) AS Saldo			
				FROM		
					dbo.PlanP PP
					INNER JOIN @Result R ON  R.ID_Kupca = PP.ID_Kupca
					inner join dbo.pogodba po on pp.id_cont = po.id_cont
				WHERE	
					(PP.Debit >0) AND
					(1 = (CASE WHEN @par_obdobjepolje_enabled = 1 
								THEN (CASE  WHEN @par_obdobjepolje_polje = '1'
									THEN (CASE WHEN (PP.Datum_dok between @par_obdobjepolje_datumod and @par_obdobjepolje_datumdo) THEN 1 ELSE 0 END)
									ELSE  (CASE WHEN (PP.Dat_zap between @par_obdobjepolje_datumod and @par_obdobjepolje_datumdo) THEN 1 ELSE 0 END)
									END)
								ELSE 1 
								END))  and
					(@par_aneks_enabled = 0 OR (@par_aneks_anekstype = 1 AND (CHARINDEX(po.aneks, @par_aneks_anekses) = 0 OR po.aneks = '')) OR (@par_aneks_anekstype = 2 AND NOT(CHARINDEX(po.aneks, @par_aneks_anekses) = 0 OR po.aneks = ''))) AND
					(@par_akt_enabled = 0 OR (@par_akt_akttype = 1 AND CHARINDEX(po.status_akt,@par_akt_akt) = 0) OR (@par_akt_akttype = 2 AND CHARINDEX(po.status_akt, @par_akt_akt) > 0)) AND
					(@par_nacinleas_enabled = 0 OR CHARINDEX(po.nacin_leas,@par_nacinleas_nacinleas) > 0) AND
					(@par_Aktivirane_enabled = 0 OR po.dat_aktiv < @par_Aktivirane) AND
					(@par_strm_enabled = 0 OR CHARINDEX(po.id_strm, @par_strm_strm) > 0)
				GROUP BY	PP.ID_Kupca, PP.ID_TEC
			)x
			group by x.id_kupca
	) T on R.ID_Kupca = T.ID_Kupca 


	-- delete unwanted records
    IF @par_ZnesekObrok_enabled = 1 BEGIN
	DELETE FROM @Result
	WHERE	
		((Debit-Kredit < @par_Znesek) AND (Obrokov < @par_ObrokALI ))  OR 
		Obrokov < @par_Obrok OR 
		Debit = 0
    END

	-- calculation of open redemption
	UPDATE @Result 
	   SET Se_bruto = T.Se_bruto,
	       Se_neto = T.Se_neto,
	       Se_obresti = T.Se_obresti,
	       Se_marza = T.Se_marza,
	       Se_regist = T.Se_regist,
		   Se_robresti = T.Se_robresti,
	       Se_fin_davek = T.Se_fin_davek
	  FROM @Result R 
	  INNER JOIN
			   (
				Select x.id_kupca, 
				SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, x.Se_Bruto, x.ID_tec, @par_tecajnica_datumtec)) AS Se_Bruto, 
    					   SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, x.Se_Neto, x.ID_tec, @par_tecajnica_datumtec)) AS Se_Neto,
    					   SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, x.Se_Obresti, x.ID_tec, @par_tecajnica_datumtec)) AS Se_Obresti,
    					   SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, x.Se_Marza, x.ID_tec, @par_tecajnica_datumtec)) AS Se_Marza,
    					   SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, x.Se_Regist, x.ID_tec, @par_tecajnica_datumtec)) AS Se_Regist,
						   SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, x.Se_Robresti, x.ID_tec, @par_tecajnica_datumtec)) AS Se_Robresti,
    					   SUM(dbo.gfn_Xchange(@par_tecajnica_tecajnica, x.Se_fin_davek, x.ID_tec, @par_tecajnica_datumtec)) AS Se_fin_davek
				From (
					SELECT PP.ID_kupca, PP.id_tec,
    						   SUM(PP.Debit) AS Se_Bruto, 
    						   SUM(PP.Neto) AS Se_Neto,
    						   SUM(PP.Obresti) AS Se_Obresti,
    						   SUM(PP.Marza) AS Se_Marza,
    						   SUM(PP.Regist) AS Se_Regist,
							   SUM(PP.Robresti) AS Se_Robresti,
    						   SUM(CASE WHEN P.DObrocno = 1 AND P.Pred_ddv = 0 THEN PP.Davek ELSE 0 END) AS Se_fin_davek
    					  FROM dbo.Planp PP 
						  inner join @Result R on pp.ID_KUPCA = R.id_kupca 
							INNER JOIN pogodba P ON PP.ID_Cont = P.ID_Cont 
					
    					 WHERE (CHARINDEX(PP.ID_Terj,@CriteriaTerj2) > 0) 
						   AND ((@par_obdobjepolje_polje = '2' AND ((PP.Dat_zap > @par_obdobjepolje_datumdo AND @simulacija = 1) OR (@simulacija = 0 AND (PP.Dat_zap > @par_obdobjepolje_datumdo OR pp.evident = '')))) OR
								(@par_obdobjepolje_polje = '1' AND ((PP.datum_dok > @par_obdobjepolje_datumdo AND @simulacija = 1) OR (@simulacija = 0 AND (PP.datum_dok > @par_obdobjepolje_datumdo OR pp.evident = '')))))
						   AND (@par_aneks_enabled = 0 OR (@par_aneks_anekstype = 1 AND (CHARINDEX(P.aneks, @par_aneks_anekses) = 0 OR P.aneks = '')) OR (@par_aneks_anekstype = 2 AND NOT(CHARINDEX(P.aneks, @par_aneks_anekses) = 0 OR P.aneks = '')))
						   AND (@par_akt_enabled = 0 OR (@par_akt_akttype = 1 AND CHARINDEX(p.status_akt, @par_akt_akt) = 0) OR (@par_akt_akttype = 2 AND NOT CHARINDEX(p.status_akt, @par_akt_akt) = 0))
						   AND (@par_nacinleas_enabled = 0 OR CHARINDEX(P.nacin_leas, @par_nacinleas_nacinleas) > 0)
						   AND (@par_Aktivirane_enabled = 0 OR P.Dat_aktiv < @par_Aktivirane)
						   AND (@par_strm_enabled = 0 OR (CHARINDEX(P.id_strm, @par_strm_strm) > 0))
    					 GROUP BY PP.ID_kupca, PP.ID_TEC		       
				)x
				Group by x.ID_KUPCA
			
				) T ON R.ID_kupca = T.ID_kupca


	-- this command is executed separately to improve performance
	UPDATE	@Result
	SET
		Obr_Pog = CASE WHEN  St_pogodb = 0 THEN 0 ELSE Obrokov / St_pogodb END,
		Proc_plac = CASE WHEN Debit = 0 THEN 0 ELSE Kredit/Debit*100 END
	RETURN
END

