(5, SedVredPog, 0.061)
SELECT * FROM dbo.gfn_ContractPV(1,'20200714',1,'000538',0,'',0,'',0,0,'',0,0,'',1,2,1.23,1,'20200714',1,'000','20200714','HRK')

(5, SedVredPogDetail, 0.050)
			SELECT * FROM dbo.gfn_ContractPV_Details(
				1, '20200714',
				1, '000538     ',
				1, 2, 1.23,
				0,'',
				1, '20200714',
				'000', 'HRK')
				
				USE [Nova_hac_new]
GO
/****** Object:  UserDefinedFunction [dbo].[gfn_ContractPV]    Script Date: 14.07.2020. 11:27:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------------------------------------------------
-- Function for getting data for report : Current Value of Contract - List of contracts
--
-- History:
-- 01.04.2004 Muri; created
-- 28.06.2004 Muri;updated
-- 15.07.2004 Muri; added cursor
-- 01.09.2004 Muri, spremenil char in varchar(X) v varchar(8000), 
-- 01.12.2004 Matjaz; umaknil join na planp, ker je nepotreben
-- 07.12.2004 Muri; dodal "DiskontPercent" v @REsult
-- 21.12.2004 Muri; popravil klic funkcije gfn_ContractPV_Details
-- 28.02.2005 Darko: added parameters @par_akt_...
-- 02.06.2005 Matjaz; bugfix - aneks condition
-- 17.11.2005 Vilko; modified condition for aneks - in case of aneks type 1 added - or aneks = ''
-- 07.04.2006 Vilko; added new discount type (4 - Dejanska obr. mera iz pogodbe)
-- 25.07.2006 Matjaz; Bug ID 26100: changed @par_diskont_percent to decimal(18,4)
-- 15.09.2006 Vik; added partner.vr_osebe and partner.sif_dej to result 
-- 15.11.2006 Adrijan; Bug ID 26387 - fixed gfn_ContractPV_Details parameters order
-- 05.01.2006 Jelena; Bug Id 26409: deleted input parametars for tecajnica; added fields ID_Tec_new and ID_Val
-- 16.01.2007 Jasna; changed field length naz_kr_kup (40-->80)
-- 30.05.2007 Matjaz; Bug ID 26623 - added fields ZNPL (ODR) and DISK_VRED_BOD (discounted future debt)
-- 09.08.2007 Vilko; set cursor as FAST_FORWARD due faster execution
-- 06.02.2009 Ziga; Bug ID 27678 - changed length of field NazivVrste to varchar(150) in table @result according to length in table vrst_opr
-- 18.09.2009 MatjazB; MID 22067 - remove WHERE for records from dbo.gfn_ContractPV_Details
-- 21.04.2010 MatjazB; Bug ID 28241 - added new criteria tecajnica
------------------------------------------------------------------------------------------------------------
ALTER                        FUNCTION [dbo].[gfn_ContractPV]
(
@par_CurDate_Enbled int,
@par_CurDate_Date datetime,
@par_pogodba_enabled int,
@par_pogodba_number varchar(8000), 
@par_partner_enabled int,
@par_partner_number varchar(6),
@par_nacinleas_enabled int,
@par_nacinleas_nacinleas varchar(8000), 
@par_aneks_enabled int,
@par_aneks_anekstype int,
@par_aneks_anekses varchar(8000), 
@par_akt_enabled int,
@par_akt_akttype int,
@par_akt_akt varchar(8000),  
@par_diskont_enabled int,
@par_diskont_type int,
@par_diskont_percent decimal(18,4),
@par_izpisDatum_enbled int,
@par_izpisDatum_date datetime,
@par_tecajnic_enbled int,
@par_tecajnic_value char(3),
@par_tecajnic_date datetime,
@par_tecajnic_id_val char(3)
)  
RETURNS @result table
(
 ID_Pog char(11),
 ID_Cont int, 
 ID_Kupca char(6),
 ID_Tec_new char (3),
 ID_Val char(3),
 Naz_kr_kup varchar(80),
 Sif_Dej char(6),
 Vr_Osebe char(2),
 ID_Vrste char(4),
 Dat_Aktiv datetime,
 Traj_naj int,
 NazivVrste varchar(150),
 Nacin_leas char(2),
 Disk_r bit, 
 Davek decimal(18,2),
 St_Obrokov int,
 Net_Val decimal(18,2),
 ZNPL decimal(18,2),
 Disk_Vred_Bod decimal(18,2),
 Disk_Vred decimal(18,2),
 Disk_Obr decimal(18,2),
 DiskontPercent decimal(18,2)
)
AS  
BEGIN 
-- 1. PREPARE LIST OF CONTRACTS
DECLARE @tblVrstTer table (naziv char(2))
DECLARE @Opc char(2)
DECLARE @Obr char(2)
DECLARE @ID_Tec_new char(2)
 
INSERT INTO @tblVrstTer SELECT ID_Terj FROM Vrst_ter WHERE Sif_terj in ('LOBR','POLO','OPC ')
SET @Opc = (SELECT ID_Terj FROM Vrst_ter WHERE Sif_terj in ('OPC '))
SET @Obr = (SELECT ID_Terj FROM Vrst_ter WHERE Sif_terj in ('LOBR'))
 
INSERT INTO @result
 SELECT P.ID_Pog,
        P.ID_Cont,
        P.ID_Kupca,
        dbo.gfn_GetNewTec(@par_tecajnic_value) as ID_Tec_new,
        T.Id_val,
        C.Naz_kr_kup,
        C.sif_dej,
        C.vr_osebe,
        P.ID_Vrste,
        P.Dat_aktiv,
        P.Traj_naj,
        O.Naziv,
        L.Nacin_leas,
        L.Disk_r,
        0 AS Davek, 
        0 AS StObrokov,
        0 AS Net_Val, 
        0 AS ZNPL,
        0 AS Disk_Vred_Bod,
        0 AS Disk_Vred,
        0 AS Disk_Obr, 
        CASE
          WHEN @par_diskont_type = 1 THEN P.diskont
          WHEN @par_diskont_type = 2 THEN @par_diskont_percent
          WHEN @par_diskont_type = 3 THEN P.obr_mera
          WHEN @par_diskont_type = 4 THEN P.dej_obr
        END AS DiskontPercent --Odstotek diskonta glede na vhodne parametre
  FROM pogodba P
  INNER JOIN partner C ON P.ID_Kupca = C.ID_Kupca
  INNER JOIN nacini_l L ON P.Nacin_leas = L.Nacin_leas
  INNER JOIN vrst_opr O on P.ID_Vrste = O.ID_Vrste 
  INNER JOIN tecajnic T ON dbo.gfn_GetNewTec(@par_tecajnic_value) = T.ID_Tec
  WHERE (@par_aneks_enabled = 0 OR (@par_aneks_anekstype = 1 AND (CHARINDEX(P.aneks, @par_aneks_anekses) = 0 OR P.aneks = '')) OR (@par_aneks_anekstype = 2 AND NOT(CHARINDEX(P.Aneks, @par_aneks_anekses) = 0 OR P.aneks = '')))
    AND (@par_nacinleas_enabled = 0 OR CHARINDEX(L.Nacin_leas,@par_nacinleas_nacinleas) > 0)
    AND (@par_partner_enabled = 0 OR P.ID_Kupca = @par_partner_number)
    AND (@par_pogodba_enabled = 0 OR P.ID_Pog LIKE @par_pogodba_number)
    AND 1 = (CASE WHEN @par_akt_enabled = 1 THEN (CASE WHEN @par_akt_akttype = 1 THEN (CASE WHEN CHARINDEX(p.status_akt,@par_akt_akt) = 0 THEN 1 ELSE 0 END) ELSE (CASE WHEN CHARINDEX(p.status_akt,@par_akt_akt) = 0 THEN 0 ELSE 1 END) END) ELSE 1 END)
  GROUP BY P.ID_Pog, P.ID_Cont, P.ID_Kupca, C.Naz_kr_kup, C.sif_dej, C.vr_osebe,P.ID_Vrste, P.Dat_aktiv, P.Traj_naj, O.Naziv, L.Nacin_leas, L.Disk_r, 
           CASE WHEN @par_diskont_type = 1 THEN P.diskont WHEN @par_diskont_type = 2 THEN @par_diskont_percent WHEN @par_diskont_type = 3 THEN P.obr_mera WHEN @par_diskont_type = 4 THEN P.dej_obr END,
           T.Id_val
/*
-- update Id_val for real Id_tec (in case when Id_Tec_new <> null from tecajnica)
UPDATE  @result
   SET Id_val = T.ID_Val
FROM @result P
INNER JOIN Tecajnic T ON P.ID_Tec_new = T.ID_Tec	

*/
-- 2. CALCULATE SUM FIELDS
DECLARE @ID_Pog char(11)
DECLARE @ID_Cont int
DECLARE @DiskontPercent decimal(8,4)

DECLARE Result CURSOR FAST_FORWARD FOR 
 SELECT ID_cont, ID_Pog, DiskontPercent FROM @result ORDER BY ID_Cont
 OPEN Result
 
 FETCH NEXT FROM Result INTO @ID_Cont, @ID_Pog, @DiskontPercent
  WHILE @@FETCH_STATUS = 0
  BEGIN
   UPDATE @result
   SET Net_Val = C.Sum_Net_Val,
	ZNPL = C.Sum_ZNPL,
	Disk_Vred_Bod = C.Sum_Disk_Vred_Bod,
    Disk_Vred = C.Sum_Disk_Vred,
    Disk_Obr = C.Sum_Disk_Obr,
    Davek = C.Sum_Davek,
    St_Obrokov = C.StObrokov
   FROM @result P JOIN  
    (SELECT  ID_Cont, 
      Sum(Net_val) as Sum_Net_Val, 
	  Sum(CASE WHEN dat_zap <= @par_izpisDatum_date THEN Disk_vred ELSE 0 END) as Sum_ZNPL,
	  Sum(CASE WHEN dat_zap > @par_izpisDatum_date THEN Disk_vred ELSE 0 END) as Sum_Disk_Vred_Bod,
      Sum(Disk_vred) as Sum_Disk_Vred , 
      Sum(Disk_obr) as Sum_Disk_Obr, 
      Sum(Davek) as Sum_Davek, 
      Sum(CASE WHEN ID_Terj = @Obr THEN 1 ELSE 0 END) as StObrokov
    -- 8 in 9 parametra sta davčna stopnja!!
   FROM  dbo.gfn_ContractPV_Details(1,@par_CurDate_Date,1, @ID_Pog ,1,@par_diskont_type, @DiskontPercent,0,0,1,@par_izpisDatum_date, @par_tecajnic_value, @par_tecajnic_id_val)
--    WHERE ID_Terj IN (Select * from @tblVrstTer) -- MID 22067
    GROUP BY ID_Cont) as C
    ON P.ID_Cont = C.ID_Cont	
    WHERE P.ID_Cont = @ID_Cont  
 
   FETCH NEXT FROM Result INTO @ID_Cont, @ID_Pog, @DiskontPercent
  END
 
 CLOSE Result
DEALLOCATE Result 
RETURN 
END


USE [Nova_hac_new]
GO
/****** Object:  UserDefinedFunction [dbo].[gfn_ContractPV_Details]    Script Date: 14.07.2020. 11:30:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------------------------------------------------
-- Function for getting right base number for discount (osnova za diskont)
--
-- History:
-- 09.04.2004 Muri; created
-- 14.06.2004 Muri; updated
-- 24.09.2004 Muri; dodal ID_Kupca v rezultat
-- 01.12.2004 Matjaz; temeljito pregledal in popravil napake
-- 03.12.2004 Dare; v kurzor dodal polja: naz_kr_kup, naziv1_kup, naziv2_kup, id_poste, mesto
-- 07.12.2004 Muri; Dodal polje StroskiSkupaj
-- 07.12.2440 Dare: dodal polja : pred_naj, dat_sklen, id_vrste, ulica, join na vrst_opr, polje se_regis, sklic
-- 21.12.2004 Muri; Dodal parametra @par_davstop_enabled in @par_davstop_value
-- 23.12.2004 Muri; Dodal polji varscina in se_varsc
-- 07.01.2005 Matjaz; dodal id_grupe
-- 11.01.2005 Matjaz; fixed bug - residual value vas not correctly discounted due to incorrect value of @Dis_Od_OPC
-- 26.01.2005 Matjaz; changes due to id_poste length change
-- 13.02.2005 Matjaz; changed result.pred_naj from char(50) to varchar(100) due to change in table structure
-- 17.02.2005 Matjaz; changed value of field z_davkom to consider @par_izpisDatum_date rather then @par_CurDate_Date
-- 18.07.2005 Natasa: popravek buga - pri izracunu deleza obresti v prvem zapadlem obroku pri totalnem diskontu 
-- 		     uposteva samo obroke, do sedaj je gledal vse terjatve
-- 18.07.2005 Natasa: fixed bug in definition of table @tblVrstTer(naziv), select referenced to non existing field id_terj
--		     and clause ID_Terj IN (SELECT ID_Terj FROM @tblVrstTer) returned always true 
-- 14.09.2005 Natasa; added column sif_terj to result table
-- 12.01.2006 Matjaz; bugfix (bug_id 25778) - fixed calculation of correction in first installment to exclude residual value
-- 27.02.2006 Vilko; resized field ulica from C(30) to C(70)
-- 07.04.2006 Vilko; added new discount rate (4 - Dejanska obr. mera iz pogodbe)
-- 25.07.2006 Matjaz; Bug ID 26100: changed @par_diskont_percent to decimal(18,4)
-- 04.01.2007 Jelena; Bug Id 26409: changed @OutputTec as id_tec from pogodbe; deleted input parametars for tecajnica
-- 16.01.2007 Jasna; changed field length naz_kr_kup (40-->80)
-- 10.10.2007 Vilko; Bug ID 26808 - added column dat_zap_pp to result table - due date from planp
-- 19.02.2009 Ziga, Matjaz; Bug ID 27701 - changed calculation for field davek for claims that are not LOBR, OPC, POLO and have datum_dok > @par_izpisDatum_date
-- 18.05.2009 Ziga; Bug ID 27850 - repaired calculation for field davek, added also claim DDV
-- 05.10.2009 Ziga; MID 21575 - enlarged field for naziv_terj to varchar(150)
-- 21.04.2010 MatjazB; Bug ID 28241 - added paremeter for tecajnica and remove all parameters for costs
-- 20.04.2011 IgorS; Bug ID 28775 - changed data type from decimal(18,2) to char(2) for column id_obr in @result table
-- 02.01.2013 Josip; Task ID 7173 - added ol_na_nacin_fl
-- 27.05.2014 Josip; Task ID 8061 - added robresti
-- 28.05.2014 Jelena; Task ID 8061 - added nacini_l.ima_robresti
-- 21.10.2016 Jure; TASK 9700 - Removed column planp.id_obr
------------------------------------------------------------------------------------------------------------
/*
SELECT * FROM dbo.gfn_ContractPV_Details(
				1, '20200714',
				1, '000538     ',
				1, 2, 1.23,
				0,'',
				1, '20200714',
				'000', 'HRK')
*/				

ALTER FUNCTION [dbo].[gfn_ContractPV_Details]
(
@par_CurDate_Enbled int,
@par_CurDate_Date datetime,
@par_ID_Pog_Enabled int, -- we use criteria container 'criteria_pogodba'
@par_ID_Pog char(11),
@par_diskont_enabled int,
@par_diskont_type int, -- 1 - Diskont iz pogodbe, 2 - Določena, 3 - Totalni diskont, 4 - Dejanska obr. mera iz pogodbe
@par_diskont_percent decimal(18,4),
@par_davstop_enabled int,
@par_davstop_value char(2), 
@par_izpisDatum_enbled int,
@par_izpisDatum_date datetime,
@par_tecajnic_value char(3),
@par_tecajnic_id_val char(3)

)  
RETURNS @result table
(
	Zap_st int identity(1,1),
	Zap_obr smallint,
	Dat_Zap datetime,
	ID_Terj char(2), 
	sif_terj char(4),
	VrstaTerNaziv varchar(150),
	Net_val decimal(18,2) ,
	Disk_vred decimal(18,2) ,
	Disk_obr decimal(18,2) ,
	Pop_obresti decimal(18,2),
	Dni int,
	Debit decimal(18,2) ,
	Kredit decimal(18,2) ,
	Z_Davkom char(1),
	Zam_Obr decimal(18,2) ,
	id_tec char(3),
	id_val char(3),
	neto decimal(18,2) ,
	saldo decimal(18,2) ,
	dat_obr datetime,
	Davek  decimal(18,2) ,
	Marza  decimal(18,2) ,
	Obresti decimal(18,2) ,
	Regist decimal(18,2) ,
	Robresti decimal(18,2) ,
	ID_Obrv char(2), 
	ID_Obrs char(2),
	Disk_r bit, -- nastavitev za sprotno rabo
	OpcijaJeObrok bit, -- nastavitev za sprotno rabo
	St_Dok char(21), -- nastavitev za sprotno rabo
	ID_Pog char(11),
	pred_naj varchar(100),
	sklic char(24),
	dat_sklen datetime,
	id_vrste char(4),
	OutputTec char(3),
	OutputVal char(3),
	ID_Cont int,
	ID_Kupca char(6),
	naz_kr_kup varchar(80),
	naziv1_kup varchar(40), 
	naziv2_kup varchar(40),
	id_poste char(14),
	mesto char(30),
	ulica char(70),
	se_regis char(1),
	-- podatki o strokih iz parametrov
	Popust_percent decimal(18,2),	
	StroskiDodatneTerjatve_Znesek decimal(18,2),
	StroskiManipulativni_Znesek decimal(18,2),
	StroskiVraciloKaska_Znesek decimal(18,2),
	StroskiIzplaciloZavar_Znesek decimal(18,2),
	StroskiOdvetnik_Znesek decimal(18,2),
	StroskiSodisce_Znesek decimal(18,2),
	StroskiInkaso_Znesek decimal(18,2),
	StroskiOdobrenoLeasigoj_Znesek decimal(18,2),
	StroskiSkupaj decimal(18,2),
	varscina decimal(18,2), 
	se_varsc decimal(18,2),
	id_grupe char(3),
    dat_zap_pp datetime,
	ima_robresti bit
)
AS
BEGIN 

-- * 1. Pripravi si polja za davčno stopnjo
 --@par_davstop_enabled int,
 --@par_davstop_value char(2), --1= Iz pogodbe, 2=doloena, 3=Totalni diskont



-- * 1. Pripravi znesek Avansa
	DECLARE @par_ID_Kupca char(6)
	DECLARE @SumAvans decimal(18,2)
	
	SET	@par_ID_Kupca = (SELECT ID_Kupca FROM Pogodba WHERE ID_Pog = @par_ID_Pog )
	SET	@SumAvans = (
		SELECT 	Sum(Saldo)
		FROM		Avansi A
				JOIN Placila P ON A.ID_Plac = P.ID_Plac
		WHERE	id_Kupca = @par_ID_Kupca
		)
-- * 3. Najdi relevantne recorde
	DECLARE 	@SifObroka char(2)
	DECLARE	    @SifOpcija char(2)
	SET 		@SifObroka = (SELECT ID_Terj FROM Vrst_Ter WHERE Sif_terj = 'LOBR' )
	SET 		@SifOpcija = (SELECT ID_Terj FROM Vrst_Ter WHERE Sif_terj = 'OPC ' )
	 
	INSERT INTO	@result (
		zap_obr, dat_zap, id_terj, sif_terj, vrstaternaziv, net_val, disk_vred, disk_obr, pop_obresti,
		dni, debit, kredit, z_davkom, zam_obr, id_tec, id_val, neto, saldo, 
		dat_obr, davek , marza , obresti, regist, robresti, id_obrv, id_obrs, 
		disk_r, opcijajeobrok, st_dok, id_pog,pred_naj,sklic,dat_sklen, id_vrste, outputtec, outputval, 
		id_cont, id_kupca,naz_kr_kup, naziv1_kup,naziv2_kup, id_poste, mesto,ulica, se_regis,popust_percent, stroskidodatneterjatve_znesek, 
		stroskimanipulativni_znesek, stroskivracilokaska_znesek, stroskiizplacilozavar_znesek, 
		stroskiodvetnik_znesek, stroskisodisce_znesek, stroskiinkaso_znesek, 
		stroskiodobrenoleasigoj_znesek, stroskiskupaj, varscina, se_varsc, id_grupe, dat_zap_pp, ima_robresti)
	SELECT	PP.Zap_obr,
			PP.Datum_dok AS Dat_Zap,
			PP.ID_Terj ,
			vt.sif_terj, 
			VT.Naziv AS VrstaTerNaziv,
			PP.Saldo-(PP.Saldo*PP.Davek)/PP.Debit AS Net_Val,
			PP.Debit AS Disk_vred,
			0 AS Disk_Obr,
			0 AS Pop_obresti,
			DATEDIFF(dd,@par_izpisDatum_date,PP.datum_dok) AS Dni,
			PP.Debit,
			PP.Kredit,
			CASE WHEN PP.Datum_Dok <= @par_izpisDatum_date AND PP.Zaprto <> '*' THEN '*' ELSE ' ' END AS Z_Davkom, -- VITO razloi ali datum izpisa/trenutni datum
			0 AS Zam_Obr, --Dodaj v FOXu
			PP.ID_Tec,
			PP.ID_Val,
			PP.Neto,
			PP.Saldo,
			PP.Dat_Obr,
			CASE when PP.Datum_Dok > @par_izpisDatum_date and VT.sif_terj not in ('LOBR','OPC','POLO','DDV') then 0 else PP.Davek * PP.Saldo/PP.Debit end AS Davek,
			CASE WHEN PP.Datum_Dok <= @par_izpisDatum_date THEN 0 ELSE PP.Marza END AS Marza, 
			CASE WHEN PP.Datum_Dok <= @par_izpisDatum_date THEN 0 ELSE PP.Obresti END AS Obresti,
			CASE WHEN PP.Datum_Dok <= @par_izpisDatum_date THEN 0 ELSE PP.Regist END AS Regist,
			CASE WHEN PP.Datum_Dok <= @par_izpisDatum_date THEN 0 ELSE PP.Robresti END AS Robresti,
			P.ID_Obrv AS ID_Obrv,
			P.ID_Obrs AS ID_Obrs,
			P.Disk_r,
			CASE WHEN (NL.Ima_Opcijo = 0) AND ( P.Pred_DDV = 0) AND ((CASE WHEN P.Opcija > 0 THEN 1 ELSE 0 END) = 1) THEN 1 ELSE 0 END AS OpcijaJeObrok, --zadnji pogoj je enak polju "Opcija"
			PP.St_Dok,
			P.ID_Pog,
			p.pred_naj,p.sklic,p.dat_sklen, p.id_vrste,
			@par_tecajnic_value as OutputTec,
			@par_tecajnic_id_val as OutputVal,
			P.ID_Cont,
			P.ID_Kupca,c.naz_kr_Kup, c.naziv1_kup,c.naziv2_kup,c.id_poste, po.naziv as mesto, c.ulica, vo.se_regis,
			Popust_percent = 0,
			StroskiDodatneTerjatve_Znesek = 0,
			StroskiManipulativni_Znesek = 0,
			StroskiVraciloKaska_Znesek = 0,
			StroskiIzplaciloZavar_Znesek = 0,
			StroskiOdvetnik_Znesek = 0,
			StroskiSodisce_Znesek = 0,
			StroskiInkaso_Znesek = 0,
			StroskiOdobrenoLeasigoj_Znesek = 0,
			StroskiSkupaj = 0,
			P.Varscina,
			Se_varsc,
			vo.Id_grupe,
            PP.dat_zap as dat_zap_pp,
			Nl.ima_robresti

	FROM		Planp PP
	INNER JOIN dbo.Vrst_ter VT ON PP.ID_Terj = VT.ID_Terj
	INNER JOIN dbo.Pogodba P ON PP.ID_Cont = P.ID_Cont
	INNER JOIN dbo.Partner C ON PP.ID_Kupca = C.ID_kupca
	INNER JOIN dbo.Nacini_L NL ON PP.Nacin_leas = NL.Nacin_leas
	INNER JOIN dbo.poste po on c.id_poste = po.id_poste
	INNER JOIN dbo.vrst_opr VO on p.id_vrste = vo.id_vrste
	WHERE	PP.Saldo>0 AND
			P.ID_Pog = @par_ID_Pog
	ORDER BY	PP.Datum_dok

-- * Auriraj zneske zapadlim terjetvam -- VITO: Razloi vsebino!
	DECLARE @tblVrstTer table (ID_Terj char(2))
	DECLARE @Dav_ni_odk bit
	SET @Dav_ni_odk = (SELECT dav_ni_odk FROM loc_nast) --Preveri izvor nastavitve!
	
	INSERT INTO @tblVrstTer SELECT ID_Terj FROM Vrst_ter WHERE Sif_terj in ('LOBR','POLO','OPC ')
	
	UPDATE	@Result
	SET		Net_val = CASE WHEN @Dav_ni_odk = 1 THEN Saldo - Davek ELSE Saldo END,
			Disk_vred = CASE WHEN @Dav_ni_odk = 1 THEN Saldo - Davek ELSE Saldo END,
			Dni = 0
			-- Zam_Obr = 0,  -- ZAMUDNE OBRESTI - IZRAUNAJ V FOXU
	WHERE	Dat_Zap <= @par_izpisDatum_date OR
			ID_Terj NOT IN (SELECT ID_Terj FROM @tblVrstTer)					

-- * Izracunaj delez obresti v prvem zapadlem obroku pri totalnem diskontu
	DECLARE @dinamika int, @obresti_1 decimal(18,2), @st_dok_1 char(21), @razmerje decimal(18,12), @dat_zap_1 datetime
	SET @obresti_1 = 0
	SET @st_dok_1 = ''
	IF @par_diskont_type = 3 AND (SELECT tot_dis_tip FROM dbo.loc_nast) = '1' -- samo pri totalnem diskontu
	BEGIN
		SET @dinamika = (SELECT 12/obnaleto FROM dbo.obdobja o INNER JOIN dbo.pogodba p ON p.id_obd=o.id_obd WHERE P.ID_Pog = @par_ID_Pog)
		SET @st_dok_1 = (SELECT TOP 1 st_dok 
				FROM @Result 
				WHERE dat_zap > @par_izpisDatum_date 
				and ID_Terj IN (SELECT ID_Terj FROM @tblVrstTer) 
				and ID_Terj != @SifOpcija
				ORDER BY dat_zap)
		SET @dat_zap_1 = (SELECT dat_zap FROM @Result WHERE st_dok = @st_dok_1)
		SET @razmerje = cast(datediff(dd, @par_izpisDatum_date, dateadd(mm, -@Dinamika, @dat_zap_1)) as decimal(18,12))/cast(datediff(dd, @dat_zap_1, dateadd(mm, -@Dinamika, @dat_zap_1)) as decimal(18,12))
		SET @obresti_1 = (SELECT obresti * @razmerje FROM @Result WHERE st_dok = @st_dok_1)
	END

-- * Ugotovi ali je opcija obrok in najdi ST_DOK opcije
	DECLARE	@OpcijaJeObrok bit
	SET 	@OpcijaJeObrok = (SELECT TOP 1 OpcijaJeObrok FROM @result)
	DECLARE	@St_Dok_OPC char(21)  	-- e opcija ni obrok ostane NULL
	DECLARE	@Dis_Od_OPC_tmp datetime	-- e opcija ni obrok ostane NULL
	DECLARE	@Dis_Od_OPC datetime		-- e opcija ni obrok ostane NULL
	SET 	@St_Dok_OPC = NULLIF((SELECT TOP 1 St_Dok FROM @Result WHERE ID_Terj = @SifObroka AND OpcijaJeObrok = 1 ORDER BY Dat_Zap DESC ), NULL) 
--	SET		@Dis_Od_OPC_tmp = NULLIF((SELECT MAX(Dat_Zap) FROM @Result WHERE ID_Terj = @SifObroka AND OpcijaJeObrok = 1), NULL)	-- najveji datum LOBR
--	SET		@Dis_Od_OPC = CASE WHEN @OpcijaJeObrok = 1 THEN (CASE WHEN @Dis_Od_OPC_tmp > @par_izpisDatum_date THEN @Dis_Od_OPC_tmp ELSE @par_izpisDatum_date END )  ELSE NULL END -- Veji od Datuma Izpia ali datuma "Opcije" = Maximum
	SET		@Dis_Od_OPC_tmp = (SELECT MAX(Dat_Zap) FROM @Result)
	SET		@Dis_Od_OPC = CASE WHEN @Dis_Od_OPC_tmp > @par_izpisDatum_date THEN @Dis_Od_OPC_tmp ELSE @par_izpisDatum_date END -- Veji od Datuma Izpia ali datuma "Opcije" = Maximum


-- * Popravi disk_val, dni, Net_val
	DECLARE	@Disk_marza int
	SET		@Disk_marza = (SELECT Disk_marza FROM Loc_Nast)

	UPDATE	@Result
	SET		Disk_Vred = CASE	WHEN @par_diskont_type = 3 THEN --totalni diskont
							CASE WHEN st_dok = @st_dok_1 THEN Neto + (CASE WHEN ima_robresti = 1 THEN Robresti ELSE 0 END) + @obresti_1
									ELSE Neto + (CASE WHEN ima_robresti = 1 THEN Robresti ELSE 0 END) END
						ELSE
							(CASE 	WHEN (Disk_r = 0) AND (ID_Terj = @SifOpcija) THEN 
									Saldo-(Saldo*Davek)/Disk_Vred
								ELSE 
									dbo.gfn_PresentValueInterest(
										Saldo - (Saldo * Davek ) / Disk_vred - Regist - (CASE WHEN @Disk_marza = 1 THEN 0 ELSE Marza END),
										@par_diskont_percent,

										@par_izpisDatum_date,
										CASE WHEN ((OpcijaJeObrok = 0) AND (ID_Terj = @SifOpcija)) OR ((OpcijaJeObrok = 1) AND (St_Dok = @St_Dok_OPC)) THEN @Dis_Od_OPC ELSE Dat_zap END --prepisan pogoj iz CASE-ja
									)
								END)
						END,
			Dni = CASE	WHEN ((OpcijaJeObrok = 0) AND (ID_Terj = @SifOpcija)) OR ((OpcijaJeObrok = 1) AND (St_Dok = @St_Dok_OPC)) THEN -- isti pogoj kot pri Disk_vred
						(CASE WHEN DATEDIFF(dd, @par_izpisDatum_date, @Dis_Od_OPC) > 0  THEN DATEDIFF(dd, @par_izpisDatum_date, @Dis_Od_OPC) ELSE 0 END )  
					ELSE 
						(CASE WHEN DATEDIFF(dd, @par_izpisDatum_date, Dat_zap) > 0  THEN DATEDIFF(dd, @par_izpisDatum_date, Dat_zap) ELSE 0 END )
					END, 
			Net_Val = Net_Val - Regist, --Preveri kako je z odtevanjem ostalih strokov iz vhodnih parametrov -- VITO!
			Pop_obresti = (CASE WHEN @par_diskont_type = 3 AND st_dok = @st_dok_1 THEN -@obresti_1 ELSE 0 END)
	WHERE	Dat_zap > @par_izpisDatum_date AND
			ID_Terj IN (SELECT ID_Terj FROM @tblVrstTer)					
	
	UPDATE	@Result
	SET		Disk_Vred = CASE WHEN @par_diskont_type = 3 THEN Neto + (CASE WHEN ima_robresti = 1 THEN Robresti ELSE 0 END) ELSE Saldo-(Saldo*Davek)/Disk_vred END, -- Glej dokumentacijo! 
			Dni = 0,	
			Net_Val = CASE WHEN @par_diskont_type = 3 THEN Neto + (CASE WHEN ima_robresti = 1 THEN Robresti ELSE 0 END) ELSE Saldo-(Saldo*Davek)/Disk_vred END
	WHERE	Dat_zap <= @par_izpisDatum_date AND
			ID_Terj = @SifOpcija AND
			Z_Davkom <> '*'

-- * Konvertiraj v pravo teajnico
	UPDATE	@Result
	SET		Net_Val = dbo.gfn_Xchange(@par_tecajnic_value, Net_Val, ID_Tec, @par_CurDate_Date),
			Zam_Obr = 0, -- PRERAUNAJ V FOXu
			Disk_Vred = dbo.gfn_Xchange(@par_tecajnic_value, Disk_Vred, ID_Tec, @par_CurDate_Date),
			Regist = dbo.gfn_Xchange(@par_tecajnic_value, Regist, ID_Tec, @par_CurDate_Date),
			Davek = dbo.gfn_Xchange(@par_tecajnic_value, Davek, ID_Tec, @par_CurDate_Date)
		
	UPDATE	@Result
	SET		Disk_Obr = Net_Val - Disk_Vred
			
-- * Popravi Davek (replace davek with iif(empty(z_davkom) and !thisformset.aliDavek,davek,0) all)
	DECLARE	@TipKnjizenja char(1)
	DECLARE	@PredDDV bit
	DECLARE	@AliDavek bit
	DECLARE @ol_na_nacin_fl bit
	SET		@ol_na_nacin_fl = (SELECT ol_na_nacin_fl FROM nacini_l L JOIN Pogodba P ON L.Nacin_Leas = P.Nacin_Leas WHERE P.ID_Pog = @par_ID_Pog )
	SET		@TipKnjizenja = (SELECT Tip_Knjizenja FROM nacini_l L JOIN Pogodba P ON L.Nacin_Leas = P.Nacin_Leas WHERE P.ID_Pog = @par_ID_Pog )
	SET		@PredDDV = (SELECT pred_ddv FROM Pogodba P WHERE P.ID_Pog = @par_ID_Pog)
	SET		@AliDavek = CASE WHEN (@TipKnjizenja='2' AND @ol_na_nacin_fl = 0 AND @PredDDV=0) THEN 0 ELSE 1 END
	
	UPDATE	@Result
	SET		Davek = 0
	WHERE	(Z_Davkom<>'') OR (@AliDavek=1) -- VITO  - kaj to pomeni
	
	 
RETURN 
END



USE [Nova_hac_new]
GO
/****** Object:  UserDefinedFunction [dbo].[gfn_PresentValueInterest]    Script Date: 14.07.2020. 11:50:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
------------------------------------------------------------------------------------------------------------
-- Function for getting present value of interest
-- 
--
-- History:
-- 25.3.2004 Muri; created
-- 04.08.2009 Matjaz; MID 21608 - corrected declaration of @var_suma from decimal(18,2) to decimal(18,6) to increase accuracy and added round of the result
------------------------------------------------------------------------------------------------------------

ALTER   FUNCTION [dbo].[gfn_PresentValueInterest] 
(
@var_Znesek decimal(18,2),
@var_Procent decimal(18,4),
@var_Od datetime,
@var_Do datetime
)  

RETURNS decimal(18,2) AS  

BEGIN 

	DECLARE @var_Dni int
	DECLARE @var_Leto int
	DECLARE @var_LetoDni int
	DECLARE @var_DniObracun int
	DECLARE @var_ZacetekLeta datetime
	DECLARE @var_KonecLeta datetime
	DECLARE @var_Suma decimal(18,6)
	DECLARE @var_ObdobjeDni int
	DECLARE @result decimal(18,2)
	
	DECLARE @var_ZacetekObdobja datetime
	DECLARE @var_KonecObdobja datetime
	
	SET @var_Dni=DATEDIFF(dd,@var_Od,@var_Do)
	SET @var_Leto=DATEPART(yyyy,@var_Od)
	
	SET @var_ZacetekLeta = CAST(cast(@var_Leto as varchar(4))+ '0101' as datetime)
	SET @var_KonecLeta = CAST(cast((@var_Leto)+1 as varchar(4)) + '0101' as datetime)
	SET @var_LetoDni=DATEDIFF(dd,@var_ZacetekLeta, @var_KonecLeta)
	
	SET @var_Suma=@var_Znesek
	
	
	SET @var_ZacetekObdobja = @var_Od
	
	IF @var_Dni < (DATEDIFF(dd,@var_Od,@var_KonecLeta)-1)
		BEGIN
		SET @var_KonecObdobja = @var_Do
		END
	ELSE
		BEGIN
		SET @var_KonecObdobja = @var_KonecLeta
		END
	
	WHILE @var_Dni>0
	BEGIN
	
		SET @var_ObdobjeDni = DATEDIFF(dd,@var_ZacetekObdobja,@var_KonecObdobja)
		SET @var_Suma = ((CAST(@var_Suma as decimal(18,6))) / (POWER((1 + CAST(@var_Procent as decimal(18,6))/100),(CAST(@var_ObdobjeDni as decimal(18,6))/CAST(@var_LetoDni as decimal(18,6))))))
		
--		PRINT CAST(@var_ZacetekObdobja as varchar) + ' --> ' + CAST(@var_KonecObdobja as varchar)
--		PRINT 'Dni: ' + CAST(@var_Dni as varchar) + ' - Dni v obdobju: ' + CAST(@var_ObdobjeDni as varchar) + ' - Dni v letu: ' + CAST(@var_LetoDni as varchar) +  ' - Suma: ' + CAST(@var_Suma as varchar)

		SET @var_Dni = @var_Dni - DATEDIFF(dd,@var_ZacetekObdobja,@var_KonecObdobja)
		SET @var_Leto = DATEPART(yyyy,@var_KonecObdobja+1) --naslednje leto
		
		SET @var_ZacetekLeta = CAST(cast(@var_Leto as varchar(4))+ '0101' as datetime)
		SET @var_KonecLeta = CAST(cast((@var_Leto + 1) as varchar(4)) + '0101' as datetime)
		SET @var_LetoDni = DATEDIFF(dd,@var_ZacetekLeta, @var_KonecLeta)


		
		SET @var_ZacetekObdobja = @var_ZacetekLeta
		
		IF @var_Dni < @var_LetoDni
			BEGIN
			SET @var_KonecObdobja = @var_Do
			END
		ELSE
			BEGIN
			SET @var_KonecObdobja = @var_KonecLeta
			END
	END
	
	SET @result = round(@var_Suma, 2)
	RETURN @result


END
