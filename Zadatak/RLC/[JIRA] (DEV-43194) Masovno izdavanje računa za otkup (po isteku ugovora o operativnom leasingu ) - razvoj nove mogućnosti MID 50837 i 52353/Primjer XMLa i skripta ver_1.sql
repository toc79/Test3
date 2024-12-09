-- 07.12.2023 g_tomislav - created based on g_branisl select with few modification

declare @prevzeta_id_cont int

select prevzeta, dbo.gfn_Id_cont4Id_pog(prevzeta) as prevzeta_id_cont
	, * 
from dbo.pogodba where nacin_leas = 'TP' and id_cont = 78891

select @prevzeta_id_cont = dbo.gfn_Id_cont4Id_pog(prevzeta) 
from dbo.pogodba pog
--join dbo.rac_out ro on pog.id_cont = ro.id_cont -- event ide prije zapisivanja ddv_id-a u dbo.fakture ili join na planp
inner join dbo.planp pp on pog.id_cont = pp.id_cont -- event ide prije zapisivanja ddv_id-a u dbo.fakture pa rac_out ili join na planp
where pog.nacin_leas = 'TP' 
and pp.ddv_id = '20230068096'
and pp.id_terj = '31'
--and ro.sif_rac = 'SPL'
and pog.id_cont = 78891


declare @result table (process_xml_cmd Varchar(max))

DECLARE @xml as varchar(max)
DECLARE @id_zapo Char(7)

DECLARE @ID_OPREME int, @NAZIV char (100), @NABAV_VRED decimal (18,2), @ID_ZAPO2 char(7), @KOM int, 
		@SER_ST varchar(100), @ZNAMKA varchar(30), @TIP varchar(50), @PRODANO bit, @NV_POPUST_PROCENT decimal(18,4),
		@NV_POPUST_ZNESEK decimal(18,2), @NV_BREZ_POPUSTA decimal(18,2), @LET_PRO char(4)

DECLARE POPR_ZAP_NER CURSOR FOR
select id_zapo
from dbo.zap_ner zn 
where zn.id_cont = @prevzeta_id_cont
and exists (select id_zapo from dbo.oprema o where o.prodano = 0 and zn.id_zapo = o.id_zapo)
group by zn.id_zapo


	OPEN POPR_ZAP_NER
	FETCH NEXT FROM POPR_ZAP_NER INTO @id_zapo

	WHILE @@FETCH_STATUS = 0    
	BEGIN  

	SET @xml = (
		Select 
		'<?xml version="1.0" encoding="utf-8" ?>
		<insert_update_zap_ner xmlns="urn:gmi:nova:leasing">
		<ali_v_os>'+CASE WHEN ISNULL(zn.ali_v_os,0) = 1 THEN 'true' ELSE 'false' END +'</ali_v_os>
		'+CASE WHEN zn.dat_fakt IS NOT NULL THEN +'<dat_fakt>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zn.dat_fakt), 126)+'</dat_fakt>' ELSE '' END+'
		'+CASE WHEN zn.dat_prev IS NOT NULL THEN +'<dat_prev>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zn.dat_prev), 126)+'</dat_prev>' ELSE '' END+'
		<id_cont>'+CAST(zn.id_cont AS Varchar(10))+'</id_cont>
		<id_dob>'+CAST(zn.id_dob AS Varchar(6))+'</id_dob>
		'+CASE WHEN zn.id_npr_enote IS NOT NULL THEN +'<id_npr_enote>'+CAST(zn.id_npr_enote AS Varchar(10))+'</id_npr_enote>' ELSE '' END+'
		<id_zapo>'+CAST(zn.id_zapo as Varchar(7))+'</id_zapo>
		<k_o>'+CAST(zn.k_o AS Varchar(100))+'</k_o>
		<kolicina>'+CAST(zn.kolicina AS Varchar(21))+'</kolicina>
		<let_pro>'+CAST(zn.let_pro AS Varchar(4))+'</let_pro>
		<m_enota>'+CAST(zn.m_enota AS Varchar(3))+'</m_enota>
		<mesto_upo>'+CAST(zn.mesto_upo AS Varchar(max))+'</mesto_upo>
		<nabav_vred>'+CAST(zn.nabav_vred AS Varchar(21))+'</nabav_vred>
		'+CASE WHEN zn.opis IS NOT NULL THEN +'<opis>'+CAST(zn.opis AS Varchar(max))+'</opis>' ELSE '' END+'
		<opombe>'+CAST(zn.opombe AS Varchar(max))+'</opombe>
		<parcelne_st>'+CAST(zn.opombe AS Varchar(max))+'</parcelne_st>
		'+CASE WHEN zn.pdat_prev IS NOT NULL THEN +'<pdat_prev>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zn.pdat_prev), 126)+'</pdat_prev>' ELSE '' END+'
		<prenos>'+CAST(zn.prenos AS Varchar(10))+'</prenos>
		<rabljeno>'+CASE WHEN ISNULL(zn.rabljeno,0) = 1 THEN 'true' ELSE 'false' END +'</rabljeno>
		<ser_st>'+CAST(zn.ser_st AS Varchar(100))+'</ser_st>
		<st_fakture>'+CAST(zn.st_fakture AS Varchar(20))+'</st_fakture>
		<st_pl_skl>'+CAST(zn.st_pl_skl AS Varchar(100))+'</st_pl_skl>
		<st_vlozka>'+CAST(zn.st_vlozka AS Varchar(500))+'</st_vlozka>
		<status_zk>'+CAST(zn.status_zk AS Varchar(1))+'</status_zk>
		<stopnja_am>'+CAST(zn.stopnja_am AS Varchar(21))+'</stopnja_am>
		'+CASE WHEN zn.sys_ts IS NOT NULL THEN+'<sys_ts>'+CAST(cast(zn.sys_ts as bigint) AS Varchar(50))+'</sys_ts>' ELSE '' END+'
		<zac_amort>'+CAST(zn.zac_amort AS Varchar(7))+'</zac_amort>'
		From dbo.zap_ner zn where zn.id_zapo = @id_zapo)

		DECLARE POPR_OPREMA CURSOR FOR
		Select [ID_OPREME]
			  ,[NAZIV]
			  ,[NABAV_VRED]
			  ,[ID_ZAPO]
			  ,[KOM]
			  ,[SER_ST]
			  ,[ZNAMKA]
			  ,[TIP]
			  ,[PRODANO]
			  ,[NV_POPUST_PROCENT]
			  ,[NV_POPUST_ZNESEK]
			  ,[NV_BREZ_POPUSTA]
			  ,[LET_PRO]
		From dbo.OPREMA where ID_ZAPO = @id_zapo
		AND [PRODANO] = 0 

		OPEN POPR_OPREMA
		FETCH NEXT FROM POPR_OPREMA INTO @ID_OPREME, @NAZIV, @NABAV_VRED, @ID_ZAPO2, @KOM, 
				@SER_ST, @ZNAMKA, @TIP, @PRODANO, @NV_POPUST_PROCENT, @NV_POPUST_ZNESEK, @NV_BREZ_POPUSTA, @LET_PRO

		WHILE @@FETCH_STATUS = 0    
			BEGIN  

			SET @xml = @xml +
				'<oprema>
				  <id_opreme>'+CAST(@ID_OPREME AS Varchar(15))+'</id_opreme>
				  <kom>'+CAST(@KOM AS Varchar(5))+'</kom>
				  <nabav_vred>'+CAST(@NABAV_VRED AS Varchar(25))+'</nabav_vred>
				  <naziv>'+CAST(@NAZIV AS Varchar(100))+'</naziv>
				  <ser_st>'+CAST(@SER_ST AS Varchar(100))+'</ser_st>
				  '+CASE WHEN @ZNAMKA IS NOT NULL THEN +'<znamka>'+CAST(@ZNAMKA AS Varchar(30))+'</znamka>' ELSE '' END+'
				  '+CASE WHEN @TIP IS NOT NULL THEN +'<tip>'+CAST(@TIP AS Varchar(50))+'</tip>' ELSE '' END+'
				  <prodano>true</prodano>
				  <deleted>false</deleted>
				  <nv_popust_procent>'+CAST(@nv_popust_procent AS Varchar(25))+'</nv_popust_procent>
				  <nv_popust_znesek>'+CAST(@nv_popust_znesek AS Varchar(25))+'</nv_popust_znesek>
				  <nv_brez_popusta>'+CAST(@nv_brez_popusta AS Varchar(25))+'</nv_brez_popusta>
				  '+CASE WHEN @let_pro IS NOT NULL THEN+'<let_pro>'+CAST(@let_pro AS Varchar(4))+'</let_pro>' ELSE '' END+'
				</oprema>'
		
		
			FETCH NEXT FROM POPR_OPREMA INTO @ID_OPREME, @NAZIV, @NABAV_VRED, @ID_ZAPO2, @KOM, 
				@SER_ST, @ZNAMKA, @TIP, @PRODANO, @NV_POPUST_PROCENT, @NV_POPUST_ZNESEK, @NV_BREZ_POPUSTA, @LET_PRO
		END

		CLOSE POPR_OPREMA    
		DEALLOCATE POPR_OPREMA   

	SET @xml = @xml + '</insert_update_zap_ner>'

	INSERT INTO @result (process_xml_cmd) VALUES (@xml)

	FETCH NEXT FROM POPR_ZAP_NER INTO @id_zapo
	END

	CLOSE POPR_ZAP_NER    
	DEALLOCATE POPR_ZAP_NER   


Select process_xml_cmd as process_xml_cmd
From @result

UNION ALL

--Obrada ZAP_REG
select 
'<?xml version="1.0" encoding="utf-8" ?>
<insert_update_zap_reg xmlns="urn:gmi:nova:leasing">
<is_update>true</is_update>
<id_zapo>'+CAST(zr.id_zapo as Varchar(7))+'</id_zapo>
<id_cont>'+CAST(zr.id_cont AS Varchar(10))+'</id_cont>
'+CASE WHEN zr.dat_prev IS NOT NULL THEN +'<dat_prev>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zr.dat_prev), 126)+'</dat_prev>' ELSE '' END+'
<vrsta>'+CAST(zr.vrsta as Varchar(30))+'</vrsta>
<znamka>'+CAST(zr.znamka as Varchar(20))+'</znamka>
'+CASE WHEN zr.id_model IS NOT NULL THEN+'<id_model>'+CAST(zr.id_model AS Varchar(10))+'</id_model>' ELSE '' END+'
<tip>'+CAST(zr.tip AS Varchar(50))+'</tip>
<st_sas>'+CAST(zr.st_sas AS Varchar(25))+'</st_sas>
<st_mot>'+CAST(RTRIM(ISNULL(zr.st_mot,'')) AS Varchar(50))+'</st_mot>
'+CASE WHEN zr.eurotax_id IS NOT NULL THEN+'<eurotax_id>'+CAST(zr.eurotax_id AS Varchar(30))+'</eurotax_id>' ELSE '' END+'
<let_pro>'+CAST(zr.let_pro AS Varchar(4))+'</let_pro>
<barva>'+CAST(zr.barva AS Varchar(50))+'</barva>
<reg_stev>'+CAST(zr.reg_stev AS Varchar(50))+'</reg_stev>
<st_promd>'+CAST(zr.st_promd AS Varchar(20))+'</st_promd>
'+CASE WHEN zr.dat_pd IS NOT NULL THEN +'<dat_pd>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zr.dat_pd), 126)+'</dat_pd>' ELSE '' END+'
'+CASE WHEN zr.velj_pd IS NOT NULL THEN +'<velj_pd>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zr.velj_pd), 126)+'</velj_pd>' ELSE '' END+'
<opis>'+CAST(zr.opis AS Varchar(100))+'</opis>
<spl_pog>'+CAST(ISNULL(zr.spl_pog, '') AS Varchar(30))+'</spl_pog>
<id_kupca>'+CAST(zr.id_kupca AS Varchar(6))+'</id_kupca>
<id_dob>'+CAST(zr.id_dob AS Varchar(6))+'</id_dob>
<ps_kw>'+CAST(zr.ps_kw AS Varchar(10))+'</ps_kw>
<kubik>'+CAST(zr.kubik AS Varchar(10))+'</kubik>
<vnesel>'+CAST(zr.vnesel AS Varchar(10))+'</vnesel>
<st_kljuc>'+CAST(zr.st_kljuc AS Varchar(15))+'</st_kljuc>
<identicar>'+CAST(zr.identicar AS Varchar(20))+'</identicar>
'+CASE WHEN zr.proizv_st IS NOT NULL THEN+'<proizv_st>'+CAST(zr.proizv_st AS Varchar(50))+'</proizv_st>' ELSE '' END+'
<komentar>'+CAST(ISNULL(zr.komentar,'') AS Varchar(max))+'</komentar>
<st_sedezev>'+CAST(zr.st_sedezev AS Varchar(3))+'</st_sedezev>
<nosilnost>'+CAST(zr.nosilnost AS Varchar(10))+'</nosilnost>
<mesto_upo>'+CAST(zr.mesto_upo AS Varchar(max))+'</mesto_upo>
<st_knj_vozila>'+CAST(zr.st_knj_vozila AS Varchar(7))+'</st_knj_vozila>
<stopnja_am>'+CAST(zr.stopnja_am AS Varchar(10))+'</stopnja_am>
<st_fakture>'+CAST(zr.st_fakture AS Varchar(20))+'</st_fakture>
'+CASE WHEN zr.dat_fakt IS NOT NULL THEN +'<dat_fakt>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zr.dat_fakt), 126)+'</dat_fakt>' ELSE '' END+'
<ali_v_os>'+CASE WHEN ISNULL(zr.ali_v_os,0) = 1 THEN 'true' ELSE 'false' END +'</ali_v_os>
<nabav_vred>'+CAST(zr.nabav_vred AS Varchar(25))+'</nabav_vred>
<prenos>'+CAST(zr.prenos AS Varchar(10))+'</prenos>
<teza_praz>'+CAST(zr.teza_praz AS Varchar(10))+'</teza_praz>
'+CASE WHEN zr.pdat_prev IS NOT NULL THEN +'<pdat_prev>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zr.pdat_prev), 126)+'</pdat_prev>' ELSE '' END+'
'+CASE WHEN zr.sys_ts IS NOT NULL THEN+'<sys_ts>'+CAST(cast(zr.sys_ts as bigint) AS Varchar(50))+'</sys_ts>' ELSE '' END+'
<kilometri>'+CAST(zr.kilometri AS Varchar(10))+'</kilometri>
'+CASE WHEN zr.dat_1upor IS NOT NULL THEN +'<dat_1upor>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zr.dat_1upor), 126)+'</dat_1upor>' ELSE '' END+'
<rabljeno>'+CASE WHEN ISNULL(zr.rabljeno,0) = 1 THEN 'true' ELSE 'false' END +'</rabljeno>
<prodano>true</prodano>
'+CASE WHEN zr.tip_goriva IS NOT NULL THEN+'<tip_goriva>'+CAST(zr.tip_goriva AS Varchar(50))+'</tip_goriva>' ELSE '' END+'
<update_dokument>
  <sifra_PROM>false</sifra_PROM>
  <sifra_KVOZ>false</sifra_KVOZ>
  <reg_stev>false</reg_stev>
</update_dokument>
<comment>Označavanje zapisnika prodanim automatskom obradom za otplaćene FL ugovore</comment>
<id_rep_category>000</id_rep_category>
<updated_values>
  <table_name>ZAP_REG</table_name>
  <name>PRODANO</name>
  <updated_value>true</updated_value>
</updated_values>
</insert_update_zap_reg>' as process_xml_cmd

from dbo.zap_reg zr 
where zr.id_cont = @prevzeta_id_cont
and zr.prodano = 0
Created: g_branisl - komentari su u SQL CANDIDATES
-- 15.03.2023 g_tomislav MID 50422 - dodan uvjet r.[status] != 4 DELETED OBJECT za tri Processxml-a (za insert_update_zap_ner nije dodan)

-- 07.12.2023 g_tomislav - created based on g_branisl select with few modification

declare @prevzeta_id_cont int

select prevzeta, dbo.gfn_Id_cont4Id_pog(prevzeta) as prevzeta_id_cont
	, * 
from dbo.pogodba where nacin_leas = 'TP' and id_cont = 78891

select @prevzeta_id_cont = dbo.gfn_Id_cont4Id_pog(prevzeta) 
from dbo.pogodba 
where nacin_leas = 'TP' 
and id_cont = 78891

if @prevzeta_id_cont is not null 
begin 
	declare @result table (process_xml_cmd Varchar(max))

	DECLARE @xml as varchar(max)
	DECLARE @id_zapo Char(7)

	DECLARE @ID_OPREME int, @NAZIV char (100), @NABAV_VRED decimal (18,2), @ID_ZAPO2 char(7), @KOM int, 
			@SER_ST varchar(100), @ZNAMKA varchar(30), @TIP varchar(50), @PRODANO bit, @NV_POPUST_PROCENT decimal(18,4),
			@NV_POPUST_ZNESEK decimal(18,2), @NV_BREZ_POPUSTA decimal(18,2), @LET_PRO char(4)

	DECLARE POPR_ZAP_NER CURSOR FOR
	select id_zapo
	from dbo.zap_ner zn 
	where zn.id_cont = @prevzeta_id_cont
	and exists (select id_zapo from dbo.oprema o where o.prodano = 0 and zn.id_zapo = o.id_zapo)
	group by zn.id_zapo


		OPEN POPR_ZAP_NER
		FETCH NEXT FROM POPR_ZAP_NER INTO @id_zapo

		WHILE @@FETCH_STATUS = 0    
		BEGIN  

		SET @xml = (
			Select 
			'<?xml version="1.0" encoding="utf-8" ?>
			<insert_update_zap_ner xmlns="urn:gmi:nova:leasing">
			<ali_v_os>'+CASE WHEN ISNULL(zn.ali_v_os,0) = 1 THEN 'true' ELSE 'false' END +'</ali_v_os>
			'+CASE WHEN zn.dat_fakt IS NOT NULL THEN +'<dat_fakt>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zn.dat_fakt), 126)+'</dat_fakt>' ELSE '' END+'
			'+CASE WHEN zn.dat_prev IS NOT NULL THEN +'<dat_prev>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zn.dat_prev), 126)+'</dat_prev>' ELSE '' END+'
			<id_cont>'+CAST(zn.id_cont AS Varchar(10))+'</id_cont>
			<id_dob>'+CAST(zn.id_dob AS Varchar(6))+'</id_dob>
			'+CASE WHEN zn.id_npr_enote IS NOT NULL THEN +'<id_npr_enote>'+CAST(zn.id_npr_enote AS Varchar(10))+'</id_npr_enote>' ELSE '' END+'
			<id_zapo>'+CAST(zn.id_zapo as Varchar(7))+'</id_zapo>
			<k_o>'+CAST(zn.k_o AS Varchar(100))+'</k_o>
			<kolicina>'+CAST(zn.kolicina AS Varchar(21))+'</kolicina>
			<let_pro>'+CAST(zn.let_pro AS Varchar(4))+'</let_pro>
			<m_enota>'+CAST(zn.m_enota AS Varchar(3))+'</m_enota>
			<mesto_upo>'+CAST(zn.mesto_upo AS Varchar(max))+'</mesto_upo>
			<nabav_vred>'+CAST(zn.nabav_vred AS Varchar(21))+'</nabav_vred>
			'+CASE WHEN zn.opis IS NOT NULL THEN +'<opis>'+CAST(zn.opis AS Varchar(max))+'</opis>' ELSE '' END+'
			<opombe>'+CAST(zn.opombe AS Varchar(max))+'</opombe>
			<parcelne_st>'+CAST(zn.opombe AS Varchar(max))+'</parcelne_st>
			'+CASE WHEN zn.pdat_prev IS NOT NULL THEN +'<pdat_prev>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zn.pdat_prev), 126)+'</pdat_prev>' ELSE '' END+'
			<prenos>'+CAST(zn.prenos AS Varchar(10))+'</prenos>
			<rabljeno>'+CASE WHEN ISNULL(zn.rabljeno,0) = 1 THEN 'true' ELSE 'false' END +'</rabljeno>
			<ser_st>'+CAST(zn.ser_st AS Varchar(100))+'</ser_st>
			<st_fakture>'+CAST(zn.st_fakture AS Varchar(20))+'</st_fakture>
			<st_pl_skl>'+CAST(zn.st_pl_skl AS Varchar(100))+'</st_pl_skl>
			<st_vlozka>'+CAST(zn.st_vlozka AS Varchar(500))+'</st_vlozka>
			<status_zk>'+CAST(zn.status_zk AS Varchar(1))+'</status_zk>
			<stopnja_am>'+CAST(zn.stopnja_am AS Varchar(21))+'</stopnja_am>
			'+CASE WHEN zn.sys_ts IS NOT NULL THEN+'<sys_ts>'+CAST(cast(zn.sys_ts as bigint) AS Varchar(50))+'</sys_ts>' ELSE '' END+'
			<zac_amort>'+CAST(zn.zac_amort AS Varchar(7))+'</zac_amort>'
			From dbo.zap_ner zn where zn.id_zapo = @id_zapo)

			DECLARE POPR_OPREMA CURSOR FOR
			Select [ID_OPREME]
				  ,[NAZIV]
				  ,[NABAV_VRED]
				  ,[ID_ZAPO]
				  ,[KOM]
				  ,[SER_ST]
				  ,[ZNAMKA]
				  ,[TIP]
				  ,[PRODANO]
				  ,[NV_POPUST_PROCENT]
				  ,[NV_POPUST_ZNESEK]
				  ,[NV_BREZ_POPUSTA]
				  ,[LET_PRO]
			From dbo.OPREMA where ID_ZAPO = @id_zapo
			AND [PRODANO] = 0 

			OPEN POPR_OPREMA
			FETCH NEXT FROM POPR_OPREMA INTO @ID_OPREME, @NAZIV, @NABAV_VRED, @ID_ZAPO2, @KOM, 
					@SER_ST, @ZNAMKA, @TIP, @PRODANO, @NV_POPUST_PROCENT, @NV_POPUST_ZNESEK, @NV_BREZ_POPUSTA, @LET_PRO

			WHILE @@FETCH_STATUS = 0    
				BEGIN  

				SET @xml = @xml +
					'<oprema>
					  <id_opreme>'+CAST(@ID_OPREME AS Varchar(15))+'</id_opreme>
					  <kom>'+CAST(@KOM AS Varchar(5))+'</kom>
					  <nabav_vred>'+CAST(@NABAV_VRED AS Varchar(25))+'</nabav_vred>
					  <naziv>'+CAST(@NAZIV AS Varchar(100))+'</naziv>
					  <ser_st>'+CAST(@SER_ST AS Varchar(100))+'</ser_st>
					  '+CASE WHEN @ZNAMKA IS NOT NULL THEN +'<znamka>'+CAST(@ZNAMKA AS Varchar(30))+'</znamka>' ELSE '' END+'
					  '+CASE WHEN @TIP IS NOT NULL THEN +'<tip>'+CAST(@TIP AS Varchar(50))+'</tip>' ELSE '' END+'
					  <prodano>true</prodano>
					  <deleted>false</deleted>
					  <nv_popust_procent>'+CAST(@nv_popust_procent AS Varchar(25))+'</nv_popust_procent>
					  <nv_popust_znesek>'+CAST(@nv_popust_znesek AS Varchar(25))+'</nv_popust_znesek>
					  <nv_brez_popusta>'+CAST(@nv_brez_popusta AS Varchar(25))+'</nv_brez_popusta>
					  '+CASE WHEN @let_pro IS NOT NULL THEN+'<let_pro>'+CAST(@let_pro AS Varchar(4))+'</let_pro>' ELSE '' END+'
					</oprema>'
			
			
				FETCH NEXT FROM POPR_OPREMA INTO @ID_OPREME, @NAZIV, @NABAV_VRED, @ID_ZAPO2, @KOM, 
					@SER_ST, @ZNAMKA, @TIP, @PRODANO, @NV_POPUST_PROCENT, @NV_POPUST_ZNESEK, @NV_BREZ_POPUSTA, @LET_PRO
			END

			CLOSE POPR_OPREMA    
			DEALLOCATE POPR_OPREMA   

		SET @xml = @xml + '</insert_update_zap_ner>'

		INSERT INTO @result (process_xml_cmd) VALUES (@xml)

		FETCH NEXT FROM POPR_ZAP_NER INTO @id_zapo
		END

		CLOSE POPR_ZAP_NER    
		DEALLOCATE POPR_ZAP_NER   


	Select process_xml_cmd as process_xml_cmd
	From @result

	UNION ALL

	--Obrada ZAP_REG
	select 
	'<?xml version="1.0" encoding="utf-8" ?>
	<insert_update_zap_reg xmlns="urn:gmi:nova:leasing">
	<is_update>true</is_update>
	<id_zapo>'+CAST(zr.id_zapo as Varchar(7))+'</id_zapo>
	<id_cont>'+CAST(zr.id_cont AS Varchar(10))+'</id_cont>
	'+CASE WHEN zr.dat_prev IS NOT NULL THEN +'<dat_prev>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zr.dat_prev), 126)+'</dat_prev>' ELSE '' END+'
	<vrsta>'+CAST(zr.vrsta as Varchar(30))+'</vrsta>
	<znamka>'+CAST(zr.znamka as Varchar(20))+'</znamka>
	'+CASE WHEN zr.id_model IS NOT NULL THEN+'<id_model>'+CAST(zr.id_model AS Varchar(10))+'</id_model>' ELSE '' END+'
	<tip>'+CAST(zr.tip AS Varchar(50))+'</tip>
	<st_sas>'+CAST(zr.st_sas AS Varchar(25))+'</st_sas>
	<st_mot>'+CAST(RTRIM(ISNULL(zr.st_mot,'')) AS Varchar(50))+'</st_mot>
	'+CASE WHEN zr.eurotax_id IS NOT NULL THEN+'<eurotax_id>'+CAST(zr.eurotax_id AS Varchar(30))+'</eurotax_id>' ELSE '' END+'
	<let_pro>'+CAST(zr.let_pro AS Varchar(4))+'</let_pro>
	<barva>'+CAST(zr.barva AS Varchar(50))+'</barva>
	<reg_stev>'+CAST(zr.reg_stev AS Varchar(50))+'</reg_stev>
	<st_promd>'+CAST(zr.st_promd AS Varchar(20))+'</st_promd>
	'+CASE WHEN zr.dat_pd IS NOT NULL THEN +'<dat_pd>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zr.dat_pd), 126)+'</dat_pd>' ELSE '' END+'
	'+CASE WHEN zr.velj_pd IS NOT NULL THEN +'<velj_pd>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zr.velj_pd), 126)+'</velj_pd>' ELSE '' END+'
	<opis>'+CAST(zr.opis AS Varchar(100))+'</opis>
	<spl_pog>'+CAST(ISNULL(zr.spl_pog, '') AS Varchar(30))+'</spl_pog>
	<id_kupca>'+CAST(zr.id_kupca AS Varchar(6))+'</id_kupca>
	<id_dob>'+CAST(zr.id_dob AS Varchar(6))+'</id_dob>
	<ps_kw>'+CAST(zr.ps_kw AS Varchar(10))+'</ps_kw>
	<kubik>'+CAST(zr.kubik AS Varchar(10))+'</kubik>
	<vnesel>'+CAST(zr.vnesel AS Varchar(10))+'</vnesel>
	<st_kljuc>'+CAST(zr.st_kljuc AS Varchar(15))+'</st_kljuc>
	<identicar>'+CAST(zr.identicar AS Varchar(20))+'</identicar>
	'+CASE WHEN zr.proizv_st IS NOT NULL THEN+'<proizv_st>'+CAST(zr.proizv_st AS Varchar(50))+'</proizv_st>' ELSE '' END+'
	<komentar>'+CAST(ISNULL(zr.komentar,'') AS Varchar(max))+'</komentar>
	<st_sedezev>'+CAST(zr.st_sedezev AS Varchar(3))+'</st_sedezev>
	<nosilnost>'+CAST(zr.nosilnost AS Varchar(10))+'</nosilnost>
	<mesto_upo>'+CAST(zr.mesto_upo AS Varchar(max))+'</mesto_upo>
	<st_knj_vozila>'+CAST(zr.st_knj_vozila AS Varchar(7))+'</st_knj_vozila>
	<stopnja_am>'+CAST(zr.stopnja_am AS Varchar(10))+'</stopnja_am>
	<st_fakture>'+CAST(zr.st_fakture AS Varchar(20))+'</st_fakture>
	'+CASE WHEN zr.dat_fakt IS NOT NULL THEN +'<dat_fakt>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zr.dat_fakt), 126)+'</dat_fakt>' ELSE '' END+'
	<ali_v_os>'+CASE WHEN ISNULL(zr.ali_v_os,0) = 1 THEN 'true' ELSE 'false' END +'</ali_v_os>
	<nabav_vred>'+CAST(zr.nabav_vred AS Varchar(25))+'</nabav_vred>
	<prenos>'+CAST(zr.prenos AS Varchar(10))+'</prenos>
	<teza_praz>'+CAST(zr.teza_praz AS Varchar(10))+'</teza_praz>
	'+CASE WHEN zr.pdat_prev IS NOT NULL THEN +'<pdat_prev>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zr.pdat_prev), 126)+'</pdat_prev>' ELSE '' END+'
	'+CASE WHEN zr.sys_ts IS NOT NULL THEN+'<sys_ts>'+CAST(cast(zr.sys_ts as bigint) AS Varchar(50))+'</sys_ts>' ELSE '' END+'
	<kilometri>'+CAST(zr.kilometri AS Varchar(10))+'</kilometri>
	'+CASE WHEN zr.dat_1upor IS NOT NULL THEN +'<dat_1upor>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zr.dat_1upor), 126)+'</dat_1upor>' ELSE '' END+'
	<rabljeno>'+CASE WHEN ISNULL(zr.rabljeno,0) = 1 THEN 'true' ELSE 'false' END +'</rabljeno>
	<prodano>true</prodano>
	'+CASE WHEN zr.tip_goriva IS NOT NULL THEN+'<tip_goriva>'+CAST(zr.tip_goriva AS Varchar(50))+'</tip_goriva>' ELSE '' END+'
	<update_dokument>
	  <sifra_PROM>false</sifra_PROM>
	  <sifra_KVOZ>false</sifra_KVOZ>
	  <reg_stev>false</reg_stev>
	</update_dokument>
	<comment>Označavanje zapisnika prodanim automatskom obradom za otplaćene FL ugovore</comment>
	<id_rep_category>000</id_rep_category>
	<updated_values>
	  <table_name>ZAP_REG</table_name>
	  <name>PRODANO</name>
	  <updated_value>true</updated_value>
	</updated_values>
	</insert_update_zap_reg>' as process_xml_cmd

	from dbo.zap_reg zr 
	where zr.id_cont = @prevzeta_id_cont
	and zr.prodano = 0
end