/*
4. Molimo info koji sve kandidati izlaze na opciji ispisi/Opomene/Obavijesti za neplaćena potraživanja.
GMC: prikazana su svi ugovori koji su obrađeni zadnjom pripremom opomena, a to pak ugovori koji su kandidati za izdavanjem opomena 1., 2. i 3. (tj.isti koji se vide u tim pregledima) i uz njih i ostali ugovoti koji nisu kandidati za izdavanje opomena (npr. kojima se obrisao datum opomena i sl.). Tako da za njih možete vidjeti stanje duga, potraživanja te ostale podatke.

*/

----------------------------------------------------------------------------------------------------------
-- This function return all data needed for booking reminder 
--
-- History: gfn_GetReminderData
-- 29.06.2004 Dare; created 
-- 27.09.2004 Matjaz; changes due to new table tip_poro; also changed g.id_poroka = b.id_cont into g.id_cont = b.id_cont
-- 05.11.2004 Dare ; changed where (for st_opomina = 4)
-- 22.03.2005 Vilko; added field dat_sklen from table pogodba
-- 03.06.2005 Matjaz; added columns for partner and porok
-- 05.08.2005 Vilko; added new criteria - id_strm and vr_osebe
-- 08.08.2005 Vilko; added new criteria - id_pog and id_kupca
-- 28.09.2005 Matjaz; added column A.na_dan
-- 28.09.2005 Matjaz; replaced zap_reg with gfn_zap_reg_single_per_contract() - before it was not working at all (it allways took the same id_zapo)
-- 16.11.2005 Darko: added field emso
-- 03.07.2006 Darko; BUG 26037 - added dav_obv
-- 02.02.2007 Vilko; Task ID 4978 - added some new fields from za_opom
-- 31.07.2007 Vilko; MODIFIED ON SITE - added fields B.dat_1op, B.dat_2op, B.dat_3op
-- 08.08.2007 Jože; MID 10239 - added column drzavljan
-- 30.10.2007 Matjaz; Task ID 5195 - added field is_epartner
-- 06.08.2008 MatjazB; Maintenance ID 16437 - added field a.cas_prip
-- 20.11.2008 Vilko; MODIFIED ON SITE - added field porok_neaktiven
-- 23.01.2009 Vilko; Task ID 5475 - added field porok_dav_stev
-- 20.10.2009 Jelena; MID 22287 - added field patrner.stev_reg
-- 19.11.2009 Jelena; MID 22287 - added fields porok_emso and porok_stev_reg
-- 04.02.2010 Siniša + Jelena; MID 23930 -  fixed sufficiant space in field TIP rtrim(field)
-- 27.07.2010 Ziga; Task ID 5877 - added fields id_klavzule and klavzula from table klavzule_sifr
-- 15.09.2011 Vilko; MID 31693 - added field kraj
-- 18.12.2012 Jelena; Task ID 6875 - added fields prepoved_opom_dni and ne_opom_do
-- 19.09.2012 IgorS; MID ID 36018 - corrected st_opomina 
-- 20.12.2012 Josip; MID 38165 GMC(25004) - added fields ro_izdal, ro_dat_vnosa
--
-- History:
-- 27.06.2014 Uros; Mid 45565 - created, added status_par, status_pog, grupe_par
-- 03.11.2014 Jelena; Task ID 8142 - added field status_op
-- 23.10.2015 Jelena; Task ID 7037 - added fields st_poro, oznacen_poro and stros_op_por
-- 20.11.2015 Jelena; Task ID 7037 - stros_op_por is get from za_opom
-- 01.12.2015 Jelena; Task ID 7037 - added stros_lj and warrantor_candidate
-- 13.04.2016 Jelena; bug found on testing for version 2.22 - added isnull(tp.poroki_od,0) for warrantor_candidate 
-- 06.03.2018; Jelena; TID 12921 - GDPR
-- 04.04.2018 Ales; TID 13004 - removed is_epartner
-- 30.07.2019 TadejV; MID 83894 - added field @par_izpisani_enabled
-- 23.01.2020 MitjaM; BID 37948 - added stringToFox, changed varchar(250) to varchar(max)
-- 20.10.2022 MitjaM; BID 39687 - added parameter @par_izpisani_value
-- 09.11.2022 Martin; BID 39684 - casted varchar to text
-- 22.12.2022 Jelena; TID 25748 - candidates for issuance are not closed contracts
-- 17.08.2023 Jadranka; BID 40059 - correction duplicat reminder  
----------------------------------------------------------------------------------------------------------
--EXEC  dbo.grp_GetReminderData 1,4,0,'',0,'',0,'',0,'',0,'' 
CREATE PROCEDURE [dbo].[grp_GetReminderData] 
	@par_st_opomina_enabled bit,
	@par_st_opomina_value int,
	@par_id_pog_enabled bit,
	@par_id_pog_value char(11),
	@par_id_kupca_enabled bit,
	@par_id_kupca_value char(6),
	@par_id_strm_enabled bit,
	@par_id_strm_value varchar(1000),
	@par_vrsta_osebe_enabled bit,
	@par_vrsta_osebe_value varchar(1000),
	@par_izpisani_enabled bit,
    @par_izpisani_value int
AS
BEGIN

	create table #grupe_partnerja (id_kupca char(6), naziv_grupe varchar(max))
	
	declare @grupe_id_kupca char(6), @grupe_id_kupca_old char(6), @id_grupe int, @id_grupe_naziv varchar(100)
	set @grupe_id_kupca_old = ''
	declare _cur_grupe cursor fast_forward for
	select
		a.id_kupca, a.id_grupe, b.opis as naziv_grupe
	from 
		dbo.pov_part a 
		inner join dbo.grupe_p b on a.id_grupe = b.id_grupe
	union
	select
		a.id_kupcab as id_kupca, a.id_grupe, b.opis as naziv_grupe
	from 
		dbo.pov_part a 
		inner join dbo.grupe_p b on a.id_grupe = b.id_grupe
	order by id_kupca

	open _cur_grupe
	fetch next from _cur_grupe into @grupe_id_kupca, @id_grupe, @id_grupe_naziv

	while @@FETCH_STATUS = 0
	begin
		if @grupe_id_kupca_old <> @grupe_id_kupca
			insert into #grupe_partnerja values (@grupe_id_kupca, cast(@id_grupe as varchar(10)) + '-' + rtrim(@id_grupe_naziv))
		else
			update #grupe_partnerja 
				set naziv_grupe = rtrim(naziv_grupe) + ', ' + cast(@id_grupe as varchar(10)) + '-' + rtrim(@id_grupe_naziv)
			where id_kupca = @grupe_id_kupca

		
		set @grupe_id_kupca_old = @grupe_id_kupca
		
		fetch next from _cur_grupe into @grupe_id_kupca, @id_grupe, @id_grupe_naziv
	end
	close _cur_grupe
	deallocate _cur_grupe

	DECLARE @id_kupca char(8)
	if @par_id_kupca_enabled = 1 
		set @id_kupca = @par_id_kupca_value 
	else
		set @id_kupca = null



	SELECT 
		   A.oznacen, A.izpisan, A.dok_opom, A.saldo_val, A.saldo_dom, A.zobr_val, A.zobr_dom, A.poobl_odvzem, 
		   A.kraj_odvzem, A.dat_odvzem, A.ura_odvzem, A.id_kupca, A.ddv_id, A.odprt_obr, A.odprt_ost, A.proc_obr,
		   A.proc_ost, A.obrok, A.se_obrokov, A.id_opom, A.datum_dok, A.dat_zap, A.id_tec,
		   --CASE WHEN @par_st_opomina_value = 4 THEN 4 ELSE A.st_opomina END AS st_opomina,
		   A.st_opomina as st_opomina,
		   A.na_dan, A.tec_opom, A.stros_op_val, A.stros_op_dom, A.stros_op_osnova_dom, A.stros_op_davek_dom,
		   A.po_opodpov, A.zap_op, A.id_za_opom_type,
		   B.id_pog,  B.nacin_leas, B.id_strm, B.id_vrste, B.aneks, B.sklic, B.pred_naj, B.dat_sklen, B.id_cont,
		   B.dat_1op, B.dat_2op, B.dat_3op,
		   C.naz_kr_kup AS naziv_lj, C.naziv1_kup, C.naziv2_kup, C.ulica, C.id_poste, C.dav_stev, C.vr_osebe,
		   C.naz_kr_kup, C.polni_naz, C.mesto, C.ulica_sed, C.id_poste_sed, C.mesto_sed,C.emso, C.dav_obv, C.drzavljan,
		   D.naziv, D.stevilka AS st_poste, D.naziv AS posta_naziv,
		   E.naziv AS referent_naziv,
		   F.naz_kr_kup AS dobavitelj_naziv,
		   G.id_poroka, H.dav_stev AS porok_dav_stev, H.emso AS porok_emso, H.stev_reg AS porok_stev_reg,
		   H.naz_kr_kup AS porok_naziv, H.naziv1_kup AS porok_naziv1_kup, H.naziv2_kup AS porok_naziv2_kup, H.ulica AS porok_ulica,
		   H.id_poste AS porok_id_poste, H.naz_kr_kup AS porok_naz_kr_kup, H.polni_naz AS porok_polni_naz, H.neaktiven AS porok_neaktiven, 
		   H.mesto AS porok_mesto, H.ulica_sed AS porok_ulica_sed, H.id_poste_sed AS porok_id_poste_sed, H.mesto_sed AS porok_mesto_sed,
		   rtrim(I.znamka) + ' ' + rtrim(I.tip) as tip, I.reg_stev, I.st_sas,  I.st_mot,
		   J.ne_prek_do, 
		   K.se_regis, 
		   L.id_val, L.naziv AS tecajnic_naziv,
		   M.naziv AS porok_posta_naziv,
		   a.cas_prip, C.stev_reg,
		   KS.id_klavzule, CAST(KS.klavzula as [text]) as klavzula,
		   C.id_poste + space(1) + D.naziv AS kraj,
		   A.prepoved_opom_dni, A.ne_opom_do,
		   ro.izdal as ro_izdal, ro.dat_vnosa as ro_dat_vnosa,
		   B.status as status_pog, C.p_status as status_par,
		   CAST(ISNULL(tgp.naziv_grupe,'') as [text]) as grupe_par,
		   dbo.gfn_StringToFOX(ISNULL(tgp.naziv_grupe,'')) as grupe_par1,
		   OL.status as status_op,
		   isnull(A.ST_POROKOV, 0) st_poro,
		   isnull(A.STROS_PORO,0) as stros_op_por,
		   A.oznacen_poro, isnull(A.stros_lj,0) as stros_lj,
		   isnull(TP.poroki_od,0) as poroki_od,
		   CASE  WHEN a.ST_OPOMINA >= isnull(tp.poroki_od,0)  THEN 1 ELSE 0 END as warrantor_candidate
	  FROM dbo.za_opom A
	 INNER JOIN dbo.pogodba B ON A.id_cont = B.id_cont 
	 INNER JOIN dbo.gfn_Partner_Pseudo('grp_GetReminderData', @id_kupca) C ON A.id_kupca = C.id_kupca
	 INNER JOIN dbo.poste D ON C.id_poste = D.id_poste 
	 INNER JOIN dbo.referent E ON B.id_ref = E.id_ref 
	 INNER JOIN dbo.gfn_Partner_Pseudo('grp_GetReminderData', null) F ON B.id_dob = F.id_kupca 
	 INNER JOIN dbo.vrst_opr K ON B.id_vrste = K.id_vrste
	 INNER JOIN dbo.tecajnic L ON A.id_tec = L.id_tec
	  LEFT JOIN (SELECT * FROM pog_poro P WHERE dbo.gfn_IsMainGuarantor(P.id_poroka, P.id_cont) = 1) G ON G.id_cont = B.id_cont and g.neaktiven = 0
	  LEFT JOIN dbo.gfn_Partner_Pseudo('grp_GetReminderData', null) H ON G.id_poroka = H.id_kupca
	  LEFT JOIN dbo.gfn_zap_reg_single_per_contract() I ON  B.id_cont = I.id_cont
	  LEFT JOIN dbo.pog_pos J ON A.id_cont = J.id_cont 
	  LEFT JOIN dbo.poste M ON H.id_poste = M.id_poste
	  LEFT JOIN dbo.rac_out RO ON RO.ddv_id = A.ddv_id
	  LEFT JOIN dbo.klavzule_sifr KS ON KS.id_klavzule = RO.id_klavzule
	  LEFT JOIN #grupe_partnerja tgp ON tgp.id_kupca = B.id_kupca
	  INNER JOIN dbo.za_opom_log OL ON A.id_za_opom_log = OL.id_za_opom_log
	  INNER JOIN dbo.za_opom_type TP ON A.id_za_opom_type = TP.id_za_opom_type
	 WHERE  b.STATUS_AKT <> 'Z'
       AND (@par_st_opomina_value = 4 OR A.st_opomina = @par_st_opomina_value)
	   AND (@par_id_pog_enabled = 0 OR B.id_pog = @par_id_pog_value)
	   AND (@par_id_kupca_enabled = 0 OR A.id_kupca = @par_id_kupca_value)
	   AND (@par_id_strm_enabled = 0 OR CHARINDEX(B.id_strm, @par_id_strm_value) > 0)
	   AND (@par_vrsta_osebe_enabled = 0 OR CHARINDEX(C.vr_osebe, @par_vrsta_osebe_value) > 0)
	   AND (@par_izpisani_enabled = 0 OR A.izpisan = @par_izpisani_value)
	 ORDER BY B.id_pog

END

