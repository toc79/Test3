/*
SELECT * FROM dbo.gfn_ContractPV_Details(
				1, '20200714',
				1, '000538     ',
				1, 2, 1.23,
				0,'',
				1, '20200714',
				'000', 'HRK')
RLC
SELECT * FROM dbo.gfn_ContractPV_Details(
				1, '20200714',
				1, '63336/20   ',
				1, 2, 2.77,
				0,'',
				1, '20200531',
				'006', 'EUR')
*/				

-- ALTER FUNCTION [dbo].[gfn_ContractPV_Details]
-- (
DECLARE 
@par_CurDate_Enbled int = 1,
@par_CurDate_Date datetime = '20200714',
@par_ID_Pog_Enabled int = 1, -- we use criteria container 'criteria_pogodba'
@par_ID_Pog char(11) = '63336/20',
@par_diskont_enabled int = 1,
@par_diskont_type int = 2, -- 1 - Diskont iz pogodbe, 2 - Določena, 3 - Totalni diskont, 4 - Dejanska obr. mera iz pogodbe
@par_diskont_percent decimal(18,4) = 2.77,
@par_davstop_enabled int = 0,
@par_davstop_value char(2) = '', 
@par_izpisDatum_enbled int = 1,
@par_izpisDatum_date datetime = '20200531',
@par_tecajnic_value char(3) = '006',
@par_tecajnic_id_val char(3) = 'EUR'

-- )  
--RETURNS 
declare @result table
(
	Zap_st int identity(1,1),
	Zap_obr smallint,
	Dat_Zap datetime,
	ID_Terj char(2), 
	sif_terj char(4),
	VrstaTerNaziv varchar(150),
	Net_val decimal(18,2) ,
	Disk_vred decimal(18,2) ,
	Disk_Vred_TEST decimal(18,2) ,
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
--AS
--BEGIN 

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
		zap_obr, dat_zap, id_terj, sif_terj, vrstaternaziv, net_val, disk_vred, Disk_vred_TEST, disk_obr, pop_obresti,
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
			0 as Disk_vred_TEST,
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

--select * from @Result 

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
	
-- select * from @Result 

	UPDATE	@Result
	SET		Disk_Vred = CASE WHEN @par_diskont_type = 3 THEN Neto + (CASE WHEN ima_robresti = 1 THEN Robresti ELSE 0 END) ELSE Saldo-(Saldo*Davek)/Disk_vred END, -- Glej dokumentacijo! 
			Dni = 0,	
			Net_Val = CASE WHEN @par_diskont_type = 3 THEN Neto + (CASE WHEN ima_robresti = 1 THEN Robresti ELSE 0 END) ELSE Saldo-(Saldo*Davek)/Disk_vred END
	WHERE	Dat_zap <= @par_izpisDatum_date AND
			ID_Terj = @SifOpcija AND
			Z_Davkom <> '*'
-- select * from @Result 
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
	
UPDATE @Result	SET	Disk_Vred_TEST =  	dbo.gfn_PresentValueInterest(
										Saldo - (Saldo * Davek ) / Disk_vred - Regist - (CASE WHEN @Disk_marza = 1 THEN 0 ELSE Marza END),
										@par_diskont_percent,

										@par_izpisDatum_date,
										CASE WHEN ((OpcijaJeObrok = 0) AND (ID_Terj = @SifOpcija)) OR ((OpcijaJeObrok = 1) AND (St_Dok = @St_Dok_OPC)) THEN @Dis_Od_OPC ELSE Dat_zap END --prepisan pogoj iz CASE-ja
									)
	 
--RETURN 
--END
select * from @Result