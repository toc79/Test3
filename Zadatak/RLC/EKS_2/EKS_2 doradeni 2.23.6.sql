DECLARE @id_dav_st char(2), @prv_obr decimal(18,2), @man_str decimal(18,2), @marza_av decimal(7,4), @stroski_zt decimal(18,2), @stroski_pz decimal(18,2),
@zav_fin decimal(18,2), @str_financ decimal(18,2),@akont decimal(18,2),@st_obrok int,@vr_val decimal(18,2),@beg_end tinyint,@rabat_nam decimal(7,4),@rabat_njim decimal(7,4),
@dej_obr decimal(7,4),@obr_mera decimal(7,4),@oststr decimal(18,2),@id_obd char(3),@ost_obr decimal(18,2),@opcija decimal(18,2),@varscina decimal(18,2),@ddv decimal(18,2),
@dobrocno bit,@stroski_x decimal(18,2),@nacin_leas char(2), @izvoz bit,@marza_ob decimal(7,4),@opc_datzad smallint,@opc_imaobr bit,@disk_r bit,@nacin_ms smallint,
@dat_pol datetime, @zapade_zt datetime, @zapade_pz datetime, @zapade_zf datetime,@zap_2ob datetime,@zap_opc datetime,@dni_zap int,@traj_naj int,@moratorij_mes int,
@dav_obv bit, @eom_neto bit, @dav_n char(1), @vr_val_eom decimal(18,2), @nl char(2), @robresti_val decimal(18,2)

set @izvoz = 0

Select * 
INTO #ponudba
From dbo.ponudba
Where id_pon = '$_0'

Select @nl = (Select dbo.gfn_Nacin_leas_HR(nacin_leas) From #ponudba)

IF (CHARINDEX(@nl,'OL,ZA,NA') = 0 )
	BEGIN
	Select @dobrocno = a.dobrocno, @eom_neto = a.eom_neto
	From dbo.kalk_form a 
	inner join #ponudba b on a.nacin_leas = b.nacin_leas 

	Select @opc_datzad = a.opc_datzad, @dni_zap = a.dni_zap, @dav_n = a.dav_n
	From dbo.nacini_l a 
	inner join #ponudba b on a.nacin_leas = b.nacin_leas

	Select @id_dav_st = id_dav_st, @prv_obr = prv_obr, @man_str = man_str, @marza_av = marza_av, @stroski_zt = stroski_zt,
	@stroski_pz = stroski_pz, @zav_fin = zav_fin, @str_financ = str_financ, @akont = akont, @st_obrok = st_obrok, @vr_val = vr_val,
	@beg_end = beg_end, @rabat_nam = rabat_nam, @rabat_njim = rabat_njim, @dej_obr = dej_obr, @obr_mera = obr_mera,
	@oststr = oststr, @id_obd = id_obd, @ost_obr = ost_obr, @opcija = opcija, @stroski_x = stroski_x, @nacin_leas = nacin_leas, 
	@marza_ob = marza_ob, @opc_imaobr = opc_imaobr, @disk_r = disk_r, @nacin_ms = nacin_ms, @dat_pol = dat_pon, @zapade_zt = dat_pon,
	@zapade_pz = dat_pon, @zapade_zf = dat_pon, @zap_2ob = DATEADD(mm, DATEDIFF(mm, 0, dateadd(mm, 1+moratorij_mes, dat_pon)), 0), @zap_opc = null, 
	@traj_naj = traj_naj, @moratorij_mes = moratorij_mes, @dav_obv = case when je_foseba = 1 then 0 else 1 end, @robresti_val = robresti_val
	From #ponudba

	Select @eom_neto =  case when @eom_neto = 1 and @dav_obv = 1 then 1 Else 0 end

	Select @vr_val_eom = Case when @dav_n = 'D' And @eom_neto = 0 then vr_val * (1 + (dav_vred/100)) else vr_val end From #ponudba

/*
sa 2.15 maknuti su parametri
@stroski_zt, 
@stroski_pz, 
@zav_fin,
@akont, 
@stroski_x, 
@zapade_zt,  
@zapade_pz,  
@zapade_zf,  

a dodani su 
@list_costs varchar(8000), 
@list_dates bit,
@id_datum_dok_create_type int

sa 2.17 verzijom dodan je PPMV
@robresti_val decimal(18,2)
*/
	
	DECLARE @pon_stros_list varchar(8000)
	SET @pon_stros_list = ''

	SELECT @pon_stros_list = rtrim(@pon_stros_list) + cast(rtrim(b.sif_terj) as varchar(4)) + ',' + CAST(a.znesek as varchar(200)) + ',' FROM dbo.pon_terj_stros a
	INNER JOIN dbo.vrst_ter b ON a.id_terj = b.id_terj
	WHERE a.id_terj IS NOT NULL AND a.znesek <> 0 AND a.id_pon = '$_0'

	SET @pon_stros_list = substring(@pon_stros_list, 0, len(@pon_stros_list))
	
	SELECT a.*, b.rac_eom, b.sif_terj, b.naziv AS vrst_ter_naziv
	INTO #planplacil
	-- FROM dbo.gfn_GenerateAmortisationPlan(@id_dav_st, @prv_obr, @man_str, @marza_av,
	-- @str_financ, @st_obrok,  @vr_val, @beg_end,  @rabat_nam,  @rabat_njim,  @dej_obr,  @obr_mera,  @oststr, @id_obd,  @ost_obr,
	-- @opcija, @varscina, @ddv, @dobrocno, @nacin_leas, @izvoz,  @marza_ob,  @opc_datzad, @opc_imaobr,  @disk_r,  @nacin_ms,
	-- @dat_pol, @zap_2ob,  @zap_opc,  @dni_zap,  @traj_naj,  @moratorij_mes, @pon_stros_list, 0, null, @robresti_val) a
	FROM dbo.gfn_GenerateAmortisationPlan4Offer('$_0') a
	
	INNER JOIN dbo.vrst_ter b ON a.id_terj = b.id_terj
	WHERE b.rac_eom = 1

	Select debit - case when @eom_neto = 1 then davek else 0 end as debit, dat_zap
	INTO #tmp_pp
	From #planplacil
	Order by dat_zap

	insert into #tmp_pp
	Select 0, dat_pon
	From #ponudba

	DECLARE @lnVred_opr decimal(18,2), @lnZac_vred float, @lnKon_Vred float, @lnIzr_dis_vred float, @lnKontrola int,
	@lnIzr_eom float, @ldMin_dat datetime, @debit float, @izr_diskont float, @dat_zap datetime, @lndni_na_leto float, @lnst_dni float, @lnFaktor float,
	@izr_tmp float, @lnLeto int, @lnEOM decimal(8,4)

	SET @lnVred_opr = @vr_val_eom 
	SET @lnZac_vred     = 0
	SET @lnKon_Vred     = 0
	SET @lnIzr_dis_vred = 0
	SET @lnKontrola     = 0
	SET @lnIzr_eom      = 50 --začetna vrednost naj bo 50%
	SET @ldMin_dat = (Select min(dat_zap) From #tmp_pp) 

		WHILE (@lnIzr_dis_vred != @lnVred_opr) And (@lnKontrola < 50)
		BEGIN
			DECLARE tmpCursor Cursor For SELECT debit, dat_zap FROM #tmp_pp Order by dat_zap
			SET @izr_diskont = 0
			SET @izr_tmp = 0
			Open tmpCursor
				
				FETCH NEXT From tmpCursor INTO @debit, @dat_zap
				
				WHILE @@fetch_status = 0
				BEGIN
										IF YEAR(@dat_zap) = YEAR(@ldMin_dat)
										BEGIN
											SET @lndni_na_leto = (Select Case When dbo.gfn_IsLeapYear(Year(@dat_zap)) = 1 Then 366 Else 365 End) --IIF(GF_DateIsLeap(lpDat_zap),366,365)
											SET @lnst_dni= DateDiff(d, @ldMin_dat, @dat_zap)
											SET @lnFaktor= power(1+(@lnIzr_eom/100), @lnst_dni / @lndni_na_leto) -- (1+lpOM/100)^(lnst_dni/lndni_na_leto)
											SET @izr_tmp = @debit / @lnFaktor
										END
										ELSE
										BEGIN
											--** prvo od dat_zap do 01.01
											SET @lndni_na_leto= (Select Case When dbo.gfn_IsLeapYear(Year(@dat_zap)) = 1 Then 366 Else 365 End)
											SET @lnst_dni= DateDiff(d, dbo.gfn_GenerateDateTime(YEAR(@dat_zap), 1, 1), @dat_zap)
											SET @lnFaktor= power(1+(@lnIzr_eom/100), @lnst_dni / @lndni_na_leto) -- (1+lpOM/100)^(lnst_dni/lndni_na_leto)
											SET @izr_tmp = @debit / @lnFaktor

											--** če obstaja več let med dat_zap in dat_izr se računa še za vsa vmes
											SET @lnLeto = YEAR(@dat_zap) - 1
											WHILE @lnLeto > YEAR(@ldMin_dat)
											BEGIN
												SET @lnFaktor = 1 + (@lnIzr_eom/100) 
												SET @izr_tmp = @izr_tmp / @lnFaktor
												SET @lnLeto = @lnLeto - 1
											END
											
											--** kot zadnje še za leto od 31.12. do dat_izr
											SET @lndni_na_leto = (Select Case When dbo.gfn_IsLeapYear(Year(@ldMin_dat)) = 1 Then 366 Else 365 End) --lndni_na_leto= IIF(GF_DateIsLeap(lpDat_izr),366,365)
											SET @lnst_dni = DateDiff(d, @ldMin_dat, dbo.gfn_GenerateDateTime(YEAR(@ldMin_dat), 12, 31))+1  --DATE(YEAR(lpDat_izr),12,31)-lpDat_izr+1
											SET @lnFaktor= power(1+(@lnIzr_eom/100), @lnst_dni / @lndni_na_leto)  -- (1+lpOM/100)^(lnst_dni/lndni_na_leto)
											SET @izr_tmp = @izr_tmp / @lnFaktor
										END
					
					SET @izr_diskont = @izr_diskont + @izr_tmp
					FETCH NEXT From tmpCursor INTO @debit, @dat_zap
				END
				
				CLOSE tmpCursor 
				DEALLOCATE tmpCursor
				
			SET @lnIzr_dis_vred = Round(@izr_diskont,2)
			
			IF @lnIzr_dis_vred < @lnVred_opr
			BEGIN
				SET @lnKon_Vred = @lnIzr_eom
				SET @lnIzr_eom = (@lnKon_Vred + @lnZac_vred)/2
			END
			ELSE
			BEGIN
				IF @lnKon_Vred>0
				BEGIN
					SET @lnZac_vred = @lnIzr_eom
					SET @lnIzr_eom = (@lnKon_Vred + @lnZac_vred)/2
				END
				ELSE
				BEGIN
					SET @lnIzr_eom = @lnIzr_eom * 2
				END
			SET @lnKontrola = @lnKontrola + 1
			END
		END
		
		print @lnIzr_dis_vred 
		print @lnVred_opr
		print @lnKontrola
		print @lnIzr_eom
		
		SET @lnEOM = @lnIzr_eom --(Select CASE WHEN @lnIzr_eom > 50 THEN -1 ELSE @lnIzr_eom END)
		
		drop table #planplacil
		drop table #tmp_pp
		END 
Else
	BEGIN
		SET @lnEOM = 0.0000
	END

drop table #ponudba	

Select @lnEOM as EKS