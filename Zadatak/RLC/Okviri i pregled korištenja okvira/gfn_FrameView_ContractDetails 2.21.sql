--USE [Nova_hls]
GO
/****** Object:  UserDefinedFunction [dbo].[gfn_FrameView_ContractDetails]    Script Date: 8.4.2016. 10:39:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------------------------------------------------
-- Function for getting data for report : Frame View - returns contracts for selected frame
--
-- History:
-- 20.05.2005 Vilko; created
-- 22.07.2005 Vilko; renamed function
-- 18.01.2006 Vilko; added field obligo
-- 06.02.2006 Vilko; added new parameter for username
-- 30.08.2006 Vilko; Maintenance ID 2253 - replaced P.* with fields from pogodba
-- 24.04.2009 Vilko; MID 20096 - fixed calculation of obligo - replaced P.dat_sklen with @par_trenutnidatum
-- 12.04.2010 Ziga; MID 24705 - added new frame type for Summit Ford with frame_type code = 'RFO'
-- 04.05.2010 Ziga; MID 25145 - repaired obligo for frame type REV and RFO for active contracts that do not exists in planp_ds (all claims are closed), obligo for such contracts is 0.
-- 19.05.2010 Ziga; MID 25373 - used parameter @par_trenutnidatum intead of getdate() according to compatibility problem with SQL Server 2000
-- 27.12.2011 Jasna; MID 30918 - added new frame type RNE for RL Srbija
-- 14.02.2012 Vilko; Bug ID 29073 - added field users_vnesel
-- 28.03.2012 Ziga; MID 34209 - modified calculation of obligo for frame type RFO - future interests tax is excluded
-- 30.05.2014 IgorS; Task ID 8109 - added function gfn_VrValToBrutoInternal for vr_bruto
-- 04.06.2014 IgorS & MatjažS; Task ID 8109 - added robresti for obligo calculation for frame type REV
-- 27.01.2016 Jelena; MID 53439 - refactoring due to the introduction of the collection frames; gfn_FrameView_ContractDetailsNotCollection is the same as old gfn_FrameView_ContractDetails
------------------------------------------------------------------------------------------------------------
ALTER   FUNCTION [dbo].[gfn_FrameView_ContractDetails] 
(
    @par_frame_enabled int,
    @par_frame_number int, 
    @par_partner_enabled int,
    @par_partner_number varchar(6),
    @par_dat_odobritve_enabled int,
    @par_dat_odobritve_from datetime,
    @par_dat_odobritve_to datetime,
    @par_razlika bit,
    @par_username_enabled int,
    @par_username_value char(10),
    @par_trenutnidatum_enabled int,
    @par_trenutnidatum datetime
)  

RETURNS 
@result TABLE (
			akc_nal tinyint, 
			akont decimal(18,2), 
			ali_pp bit, 
			ali_sdr bit, 
			aneks char(1), 
			beg_end tinyint, 
			brez_davka_dom decimal(18,2), 
			bruto decimal(18,2), 
			cena_dkm decimal(18,2), 
			dakont datetime, 
			dat_1op datetime, 
			dat_2op datetime, 
			dat_3op datetime, 
			dat_aktiv datetime, 
			dat_arhiv datetime, 
			dat_kkf datetime, 
			dat_od1 datetime, 
			dat_podpisa datetime, 
			dat_pol datetime, 
			dat_predr datetime, 
			dat_sklen datetime, 
			dat_zakl datetime, 
			datum_odob datetime, 
			dav_osno decimal(18,2), 
			dav_osno_dom decimal(18,2), 
			ddv decimal(18,2), 
			ddv_dom decimal(18,2), 
			ddv_id char(14),
			dej_obr decimal(7,4), 
			disk_r bit, 
			diskont decimal(7,4), 
			dni_financ int, 
			dni_zap int, 
			dobrocno bit, 
			dovol_km decimal(10,0), 
			dva_pp bit, 
			ef_obrm decimal(8,4), 
			fix_del decimal(8,4), 
			id char(10), 
			id_cont int, 
			id_dav_op char(2), 
			id_dav_st char(2), 
			id_dob char(6), 
			id_kredpog char(15), 
			id_kupca char(6), 
			id_kupca1 char(6), 
			id_obd char(3), 
			id_obrs char(2), 
			id_obrv char(2), 
			id_odobrit int,
			id_pog char(11),
			id_pog_zav char(15),
			id_pon char(7),
			id_posrednik varchar(10), 
			id_prod int, 
			id_ref char(5),
			id_rtip char(5),
			id_sklic char(7),
			id_strm char(4),
			id_svet char(5),
			id_tec char(3),
			id_tecvr char(3),
			id_val char(3),
			id_vrste char(4),
			izv_kom tinyint,
			izv_naj tinyint,
			izvoz bit, 
			kasko decimal(18,2), 
			kategorija char(3),
			kdo_odb char(5),
			kk_memo varchar(1000),
			kon_naj datetime,
			konsolid char(1),
			man_str decimal(18,2), 
			marza_av decimal(7,4), 
			marza_ob decimal(7,4), 
			menic tinyint, 
			mpc decimal(18,2), 
			nacin_leas char(2), 
			nacin_ms tinyint, 
			naziv_tuje char(50),
			neobdav_dom decimal(18,2), 
			net_nal decimal(18,2), 
			next_rpg_num tinyint, 
			njih_st char(15), 
			obl_zt bit, 
			obr_financ decimal(10,4), 
			obr_marz decimal(18,2), 
			obr_mera decimal(7,4), 
			obr_merak decimal(7,4), 
			obr_vir decimal(7,4), 
			obr_vir1 decimal(7,4), 
			obrok1 decimal(18,2),
			om_varsc decimal(7,4), 
			opc_datzad tinyint, 
			opc_imaobr bit, 
			opcija decimal(18,2), 
			opis_pred varchar(1000),
			opombe varchar(1500),
			ost_obr decimal(18,2),
			oststr decimal(18,2),
			plac_zac decimal(18,2),
			po_tecaju decimal(20,10),
			pred_ddv bit,
			pred_naj varchar(100),
			predr_do datetime,
			prejme_do datetime,
			prenos char(10),
			prevzeta char(11),
			prv_obr decimal(18,2),
			prza_eom bit,
			pszav char(35),
			pyr decimal(18,2),
			pz_let tinyint,
			pz_zavar char(2),
			rabat decimal(20,2),
			rabat_nam decimal(7,4),
			rabat_njim decimal(7,4),
			ref1 char(5),
			refinanc char(20),
			rind_datum datetime,
			rind_faktor decimal(5,3),
			rind_tdol decimal(8,4),
			rind_tgor decimal(8,4),
			rind_zadnji decimal(8,4),
			rind_zahte bit,
			se_varsc decimal(18,2),
			sklic char(24),
			spl_pog char(5),
			st_obrok int,
			st_predr char(20),
			status char(2),
			status_akt char(1),
			str_financ decimal(18,2),
			stroski_pz decimal(18,2),
			stroski_x decimal(18,2),
			stroski_zt decimal(18,2),
			subleasing char(1),
			sys_ts varchar(23),
			traj_naj int,
			trojna_opc bit,
			varscina decimal(18,2),
			verified bit,
			vnesel char(10),
			vr_prom char(1),
			vr_sit decimal(18,2),
			vr_val decimal(18,2),
			vr_val_zac decimal(18,2),
			vred_val decimal(18,2),
			za_odobrit char(1),
			zac_naj datetime,
			zap_2ob datetime,
			zap_opc datetime,
			zapade_pz datetime,
			zapade_zf datetime,
			zapade_zt datetime,
			zav_fin decimal(18,2),
			ze_avansa decimal(18,2),
			ze_proviz bit,
			zn_ref1 decimal(18,2),
			zn_refinan decimal(18,2),
			zt_zavar char(2),
			users_vnesel char(150),
			naz_kr_kup varchar(80),
	        obligo decimal(18,2)
    )

AS  
	BEGIN	

	DECLARE  @id_parent int, @je_krovni_okvir bit

	SELECT @id_parent = F.id_parent, @je_krovni_okvir = F.je_krovni_okvir 
	FROM dbo.frame_list F
	WHERE (@par_frame_enabled = 0 OR F.id_frame = @par_frame_number)
			AND (@par_partner_enabled = 0 OR F.id_kupca  = @par_partner_number)
			AND (@par_dat_odobritve_enabled = 0 OR F.dat_odobritve BETWEEN @par_dat_odobritve_from AND @par_dat_odobritve_to)


	    --navadni okvir in child od krovnega okvira
		IF @je_krovni_okvir = 0 
			INSERT INTO @result
			SELECT * FROM 
			dbo.gfn_FrameView_ContractDetailsNotCollection(@par_frame_enabled, @par_frame_number, @par_partner_enabled, @par_partner_number, @par_dat_odobritve_enabled, @par_dat_odobritve_from,
											@par_dat_odobritve_to, @par_razlika, @par_username_enabled, @par_username_value, @par_trenutnidatum_enabled, @par_trenutnidatum)
		ELSE
		--krovni okvir
		IF @je_krovni_okvir = 1 
			INSERT INTO @result
			SELECT * FROM 
			dbo.gfn_FrameView_ContractDetailsCollection(@par_frame_enabled, @par_frame_number, @par_partner_enabled, @par_partner_number, @par_dat_odobritve_enabled, @par_dat_odobritve_from,
								    		   @par_dat_odobritve_to, @par_razlika, @par_username_enabled, @par_username_value, @par_trenutnidatum_enabled, @par_trenutnidatum)

	RETURN 
END
