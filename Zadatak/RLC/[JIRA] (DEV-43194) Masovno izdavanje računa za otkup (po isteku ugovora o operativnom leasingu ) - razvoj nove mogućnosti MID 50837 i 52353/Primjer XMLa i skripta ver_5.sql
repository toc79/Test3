-- 12.12.2023 g_tomislav MID 50837 - created based on g_branisl script with few modification. For TP claims/contract changing PRODATO for original i new zap_reg/zap_ner 

declare @ddv_id varchar(14) = {3}
declare @id_cont int, @id_cont_third_party int 

select @id_cont = f.id_cont
	, @id_cont_third_party = f.id_cont_third_party
from dbo.fakture f
where f.id_terj = '31'
and f.nacin_leas_third_party = 'TP' 
and f.ddv_id = @ddv_id

if @id_cont_third_party is not null
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
	where zn.id_cont in (@id_cont, @id_cont_third_party)
	and exists (select * from dbo.oprema o where o.prodano = 0 and zn.id_zapo = o.id_zapo)
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
			<let_pro>'+CAST(rtrim(zn.let_pro) AS Varchar(4))+'</let_pro>
			<m_enota>'+CAST(rtrim(zn.m_enota) AS Varchar(3))+'</m_enota>
			<mesto_upo>'+CAST(zn.mesto_upo AS Varchar(max))+'</mesto_upo>
			<nabav_vred>'+CAST(zn.nabav_vred AS Varchar(21))+'</nabav_vred>
			'+CASE WHEN zn.opis IS NOT NULL THEN +'<opis>'+CAST(zn.opis AS Varchar(max))+'</opis>' ELSE '' END+'
			<opombe>'+CAST(zn.opombe AS Varchar(max))+'</opombe>
			<parcelne_st>'+CAST(zn.opombe AS Varchar(max))+'</parcelne_st>
			'+CASE WHEN zn.pdat_prev IS NOT NULL THEN +'<pdat_prev>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zn.pdat_prev), 126)+'</pdat_prev>' ELSE '' END+'
			<prenos>'+CAST(rtrim(zn.prenos) AS Varchar(10))+'</prenos>
			<rabljeno>'+CASE WHEN ISNULL(zn.rabljeno,0) = 1 THEN 'true' ELSE 'false' END +'</rabljeno>
			<ser_st>'+CAST(zn.ser_st AS Varchar(100))+'</ser_st>
			<st_fakture>'+CAST(rtrim(zn.st_fakture) AS Varchar(20))+'</st_fakture>
			<st_pl_skl>'+CAST(zn.st_pl_skl AS Varchar(100))+'</st_pl_skl>
			<st_vlozka>'+CAST(zn.st_vlozka AS Varchar(500))+'</st_vlozka>
			<status_zk>'+CAST(zn.status_zk AS Varchar(1))+'</status_zk>
			<stopnja_am>'+CAST(zn.stopnja_am AS Varchar(21))+'</stopnja_am>
			'+CASE WHEN zn.sys_ts IS NOT NULL THEN+'<sys_ts>'+CAST(cast(zn.sys_ts as bigint) AS Varchar(50))+'</sys_ts>' ELSE '' END+'
			<zac_amort>'+CAST(rtrim(zn.zac_amort) AS Varchar(7))+'</zac_amort>'
			+case when zn.DELOV_UR is not null then '<DELOV_UR>'+CAST(zn.DELOV_UR AS Varchar(10))+'</DELOV_UR>' else '' end
			-- IF !GF_NullOrEmpty(zap_ner.DELOV_UR) THEN
				-- lcXML = lcXML + GF_CreateNode("DELOV_UR", zap_ner.DELOV_UR, "N", 1) + gcE
			-- ENDIF
			+case when zn.fakt_prem_stop is not null then '<fakt_prem_stop>'+CAST(zn.fakt_prem_stop AS Varchar(21))+'</fakt_prem_stop>' else '' end
			-- IF !GF_NULLOREMPTY(zap_ner.fakt_prem_stop) THEN
				-- lcXml = lcXml + GF_CreateNode("fakt_prem_stop", zap_ner.fakt_prem_stop, "N", 1) + gcE
			-- ENDIF
			+case when zn.novonabav_vred is not null then '<novonabav_vred>'+CAST(zn.novonabav_vred AS Varchar(21))+'</novonabav_vred>' else '' end
			-- IF !GF_NULLOREMPTY(zap_ner.novonabav_vred) THEN
				-- lcXml = lcXml + GF_CreateNode("novonabav_vred", zap_ner.novonabav_vred, "N", 1) + gcE
			-- ENDIF	
			+case when zn.kategorija1 is not null then '<kategorija1>'+rtrim(zn.kategorija1)+'</kategorija1>' else '' end
			-- IF !GF_NULLOREMPTY(zap_ner.kategorija1) THEN
				-- lcXml = lcXml + GF_CreateNode("kategorija1", zap_ner.kategorija1, "C", 1) + gcE
			-- ENDIF
			+case when zn.kategorija2 is not null then '<kategorija2>'+rtrim(zn.kategorija2)+'</kategorija2>' else '' end
			-- IF !GF_NULLOREMPTY(zap_ner.kategorija2) THEN
				-- lcXml = lcXml + GF_CreateNode("kategorija2", zap_ner.kategorija2, "C", 1) + gcE
			-- ENDIF
			+case when zn.kategorija3 is not null then '<kategorija3>'+rtrim(zn.kategorija3)+'</kategorija3>' else '' end
			-- IF !GF_NULLOREMPTY(zap_ner.kategorija3) THEN
				-- lcXml = lcXml + GF_CreateNode("kategorija3", zap_ner.kategorija3, "C", 1) + gcE
			-- ENDIF
			+case when zn.id_znamke is not null then '<id_znamke>'+rtrim(zn.id_znamke)+'</id_znamke>' else '' end
			-- IF !GF_NULLOREMPTY(zap_ner.id_znamke) THEN
				-- lcXml = lcXml + GF_CreateNode("id_znamke", zap_ner.id_znamke, "C", 1) + gcE
			-- ENDIF
			+case when zn.epc is not null then '<epc>'+rtrim(zn.epc)+'</epc>' else '' end
			-- IF !GF_NULLOREMPTY(zap_ner.epc) THEN
				-- lcXml = lcXml + GF_CreateNode("epc", zap_ner.epc, "C", 1) + gcE
			-- ENDIF
			+case when zn.epc_date is not null then +'<epc_date>'+convert(varchar(30), dbo.gfn_getdatepart(zn.epc_date), 126)+'</epc_date>' else '' end
			-- IF !GF_NULLOREMPTY(zap_ner.epc_date) THEN
				-- lcXml = lcXml + GF_CreateNode("epc_date", zap_ner.epc_date, "D", 1) + gcE
			-- ENDIF
			+case when zn.co2_emission is not null then 
			'<co2_emission>'+CAST(zn.co2_emission AS Varchar(21))+'</co2_emission>' 
			+'<co2_unit>'+rtrim(zn.co2_unit)+'</co2_unit>'
			else '' end
			-- IF !ISNULL(zap_ner.co2_emission) THEN
				-- lcXml = lcXml + GF_CreateNode("co2_emission", zap_ner.co2_emission, "N", 1) + gcE
				-- lcXml = lcXml + GF_CreateNode("co2_unit",zap_ner.co2_unit, "C", 1) + gcE
			-- ENDIF
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
			From dbo.OPREMA where ID_ZAPO = @id_zapo --AND [PRODANO] = 0 -- oprema details by default are always prepared 

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
					  <naziv>'+CAST(rtrim(@NAZIV) AS Varchar(100))+'</naziv>
					  <ser_st>'+CAST(@SER_ST AS Varchar(100))+'</ser_st>
					  '+CASE WHEN @ZNAMKA IS NOT NULL THEN +'<znamka>'+CAST(@ZNAMKA AS Varchar(30))+'</znamka>' ELSE '' END+'
					  '+CASE WHEN @TIP IS NOT NULL THEN +'<tip>'+CAST(@TIP AS Varchar(50))+'</tip>' ELSE '' END+'
					  <prodano>true</prodano>
					  <deleted>false</deleted>
					  <nv_popust_procent>'+CAST(@nv_popust_procent AS Varchar(25))+'</nv_popust_procent>
					  <nv_popust_znesek>'+CAST(@nv_popust_znesek AS Varchar(25))+'</nv_popust_znesek>
					  <nv_brez_popusta>'+CAST(@nv_brez_popusta AS Varchar(25))+'</nv_brez_popusta>
					  '+CASE WHEN @let_pro IS NOT NULL THEN+'<let_pro>'+CAST(@let_pro AS Varchar(4))+'</let_pro>' ELSE '' END
					  +case when @PRODANO = 1 then '' else '
					  <updated_values> 
						<table_name>OPREMA</table_name>
						<name>PRODANO</name>
						<updated_value>true</updated_value>
						</updated_values>' end +' 
					</oprema>'
			
				FETCH NEXT FROM POPR_OPREMA INTO @ID_OPREME, @NAZIV, @NABAV_VRED, @ID_ZAPO2, @KOM, 
					@SER_ST, @ZNAMKA, @TIP, @PRODANO, @NV_POPUST_PROCENT, @NV_POPUST_ZNESEK, @NV_BREZ_POPUSTA, @LET_PRO
			END

			CLOSE POPR_OPREMA    
			DEALLOCATE POPR_OPREMA   

		SET @xml = @xml + '
			<comment>Označavanje zapisnika prodanim automatskom obradom (event)</comment>
			<id_rep_category>999</id_rep_category>
			</insert_update_zap_ner>'

		INSERT INTO @result (process_xml_cmd) VALUES (@xml)

		FETCH NEXT FROM POPR_ZAP_NER INTO @id_zapo
		END

		CLOSE POPR_ZAP_NER    
		DEALLOCATE POPR_ZAP_NER   


	Select process_xml_cmd as xml
		, cast(1 as bit) as via_queue
		, 60 as delay
		, cast(0 as bit) as via_esb
		, 'nova.le' as esb_target
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
		<vrsta>'+CAST(rtrim(zr.vrsta) as Varchar(30))+'</vrsta>
		<znamka>'+CAST(rtrim(zr.znamka) as Varchar(20))+'</znamka>
		'+CASE WHEN zr.id_model IS NOT NULL THEN+'<id_model>'+CAST(zr.id_model AS Varchar(10))+'</id_model>' ELSE '' END+'
		<tip>'+CAST(zr.tip AS Varchar(50))+'</tip>
		<st_sas>'+CAST(rtrim(zr.st_sas) AS Varchar(25))+'</st_sas>
		<st_mot>'+CAST(RTRIM(ISNULL(zr.st_mot,'')) AS Varchar(50))+'</st_mot>
		'+CASE WHEN zr.eurotax_id IS NOT NULL THEN+'<eurotax_id>'+CAST(zr.eurotax_id AS Varchar(30))+'</eurotax_id>' ELSE '' END+'
		<let_pro>'+CAST(zr.let_pro AS Varchar(4))+'</let_pro>
		<barva>'+CAST(zr.barva AS Varchar(50))+'</barva>
		<reg_stev>'+CAST(rtrim(zr.reg_stev) AS Varchar(50))+'</reg_stev>
		<st_promd>'+CAST(rtrim(zr.st_promd) AS Varchar(20))+'</st_promd>
		'+CASE WHEN zr.dat_pd IS NOT NULL THEN +'<dat_pd>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zr.dat_pd), 126)+'</dat_pd>' ELSE '' END+'
		'+CASE WHEN zr.velj_pd IS NOT NULL THEN +'<velj_pd>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zr.velj_pd), 126)+'</velj_pd>' ELSE '' END+'
		<opis>'+CAST(zr.opis AS Varchar(100))+'</opis>
		<spl_pog>'+CAST(ISNULL(zr.spl_pog, '') AS Varchar(30))+'</spl_pog>
		<id_kupca>'+CAST(zr.id_kupca AS Varchar(6))+'</id_kupca>
		<id_dob>'+CAST(zr.id_dob AS Varchar(6))+'</id_dob>
		<ps_kw>'+CAST(rtrim(zr.ps_kw) AS Varchar(10))+'</ps_kw>
		<kubik>'+CAST(rtrim(zr.kubik) AS Varchar(10))+'</kubik>
		<vnesel>'+CAST(rtrim(zr.vnesel) AS Varchar(10))+'</vnesel>
		<st_kljuc>'+CAST(rtrim(zr.st_kljuc) AS Varchar(15))+'</st_kljuc>
		<identicar>'+CAST(rtrim(zr.identicar) AS Varchar(20))+'</identicar>
		'+CASE WHEN zr.proizv_st IS NOT NULL THEN+'<proizv_st>'+CAST(rtrim(zr.proizv_st) AS Varchar(50))+'</proizv_st>' ELSE '' END+'
		<komentar>'+CAST(ISNULL(zr.komentar,'') AS Varchar(max))+'</komentar>
		<st_sedezev>'+CAST(zr.st_sedezev AS Varchar(3))+'</st_sedezev>
		<nosilnost>'+CAST(rtrim(zr.nosilnost) AS Varchar(10))+'</nosilnost>
		<mesto_upo>'+CAST(zr.mesto_upo AS Varchar(max))+'</mesto_upo>
		<st_knj_vozila>'+CAST(zr.st_knj_vozila AS Varchar(7))+'</st_knj_vozila>
		<stopnja_am>'+CAST(zr.stopnja_am AS Varchar(10))+'</stopnja_am>
		<st_fakture>'+CAST(rtrim(zr.st_fakture) AS Varchar(20))+'</st_fakture>
		'+CASE WHEN zr.dat_fakt IS NOT NULL THEN +'<dat_fakt>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zr.dat_fakt), 126)+'</dat_fakt>' ELSE '' END+'
		<ali_v_os>'+CASE WHEN ISNULL(zr.ali_v_os,0) = 1 THEN 'true' ELSE 'false' END +'</ali_v_os>
		<nabav_vred>'+CAST(zr.nabav_vred AS Varchar(25))+'</nabav_vred>
		<prenos>'+CAST(rtrim(zr.prenos) AS Varchar(10))+'</prenos>
		<teza_praz>'+CAST(rtrim(zr.teza_praz) AS Varchar(10))+'</teza_praz>
		'+CASE WHEN zr.pdat_prev IS NOT NULL THEN +'<pdat_prev>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zr.pdat_prev), 126)+'</pdat_prev>' ELSE '' END+'
		'+CASE WHEN zr.sys_ts IS NOT NULL THEN+'<sys_ts>'+CAST(cast(zr.sys_ts as bigint) AS Varchar(50))+'</sys_ts>' ELSE '' END+'
		<kilometri>'+CAST(zr.kilometri AS Varchar(10))+'</kilometri>
		'+CASE WHEN zr.dat_1upor IS NOT NULL THEN +'<dat_1upor>'+CONVERT(Varchar(30), dbo.gfn_getDatePart(zr.dat_1upor), 126)+'</dat_1upor>' ELSE '' END+'
		<rabljeno>'+CASE WHEN ISNULL(zr.rabljeno,0) = 1 THEN 'true' ELSE 'false' END +'</rabljeno>
		<prodano>true</prodano>
		'+CASE WHEN zr.tip_goriva IS NOT NULL THEN+'<tip_goriva>'+CAST(zr.tip_goriva AS Varchar(50))+'</tip_goriva>' ELSE '' END
		+case when zr.dodatni_podatki is not null then '<dodatni_podatki>'+rtrim(zr.dodatni_podatki)+'</dodatni_podatki>' else '' end
		-- IF !GF_NULLOREMPTY(zap_reg.dodatni_podatki)
			-- lcXML = lcXML + GF_CreateNode("dodatni_podatki", zap_reg.dodatni_podatki, "C", 1) + gcE
		-- ENDIF
		+case when zr.fakt_prem_stop is not null then '<fakt_prem_stop>'+CAST(zr.fakt_prem_stop AS Varchar(21))+'</fakt_prem_stop>' else '' end
		-- IF !GF_NULLOREMPTY(zap_reg.fakt_prem_stop) THEN
			-- lcXml = lcXml + GF_CreateNode("fakt_prem_stop", zap_reg.fakt_prem_stop, "N", 1) + gcE
		-- ENDIF
		+case when zr.novonabav_vred is not null then '<novonabav_vred>'+CAST(zr.novonabav_vred AS Varchar(21))+'</novonabav_vred>' else '' end
		-- IF !GF_NULLOREMPTY(zap_reg.novonabav_vred) THEN
			-- lcXml = lcXml + GF_CreateNode("novonabav_vred", zap_reg.novonabav_vred, "N", 1) + gcE
		-- ENDIF
		+case when zr.kategorija1 is not null then '<kategorija1>'+rtrim(zr.kategorija1)+'</kategorija1>' else '' end
		-- IF !GF_NULLOREMPTY(zap_reg.kategorija1) THEN
			-- lcXml = lcXml + GF_CreateNode("kategorija1", zap_reg.kategorija1, "C", 1) + gcE
		-- ENDIF
		+case when zr.kategorija2 is not null then '<kategorija2>'+rtrim(zr.kategorija2)+'</kategorija2>' else '' end
		-- IF !GF_NULLOREMPTY(zap_reg.kategorija2) THEN
			-- lcXml = lcXml + GF_CreateNode("kategorija2", zap_reg.kategorija2, "C", 1) + gcE
		-- ENDIF
		+case when zr.kategorija3 is not null then '<kategorija3>'+rtrim(zr.kategorija3)+'</kategorija3>' else '' end
		-- IF !GF_NULLOREMPTY(zap_reg.kategorija3) THEN
			-- lcXml = lcXml + GF_CreateNode("kategorija3", zap_reg.kategorija3, "C", 1) + gcE
		-- ENDIF
		+case when zr.epc is not null then '<epc>'+rtrim(zr.epc)+'</epc>' else '' end
		-- IF !GF_NULLOREMPTY(zap_reg.epc) THEN
			-- lcXml = lcXml + GF_CreateNode("epc", zap_reg.epc, "C", 1) + gcE
		-- ENDIF
		+case when zr.epc_date is not null then +'<epc_date>'+convert(varchar(30), dbo.gfn_getdatepart(zr.epc_date), 126)+'</epc_date>' else '' end
		-- IF !GF_NULLOREMPTY(zap_reg.epc_date) THEN
			-- lcXml = lcXml + GF_CreateNode("epc_date", zap_reg.epc_date, "D", 1) + gcE
		-- ENDIF
		+case when zr.co2_emission is not null then 
			'<co2_emission>'+CAST(zr.co2_emission AS Varchar(21))+'</co2_emission>' 
			+'<co2_unit>'+rtrim(zr.co2_unit)+'</co2_unit>'
			else '' end
		-- IF !ISNULL(zap_reg.co2_emission) THEN
			-- lcXml = lcXml + GF_CreateNode("co2_emission", zap_reg.co2_emission, "N", 1) + gcE
			-- lcXml = lcXml + GF_CreateNode("co2_unit",zap_reg.co2_unit, "C", 1) + gcE
		-- ENDIF
		
		+'<update_dokument>
		  <sifra_PROM>false</sifra_PROM>
		  <sifra_KVOZ>false</sifra_KVOZ>
		  <reg_stev>false</reg_stev>
		</update_dokument>
		<comment>Označavanje zapisnika prodanim automatskom obradom (event)</comment>
		<id_rep_category>999</id_rep_category>
		<updated_values>
		  <table_name>ZAP_REG</table_name>
		  <name>PRODANO</name>
		  <updated_value>true</updated_value>
		</updated_values>
		</insert_update_zap_reg>' as xml
		, cast(1 as bit) as via_queue
		, 60 as delay
		, cast(0 as bit) as via_esb
		, 'nova.le' as esb_target
	from dbo.zap_reg zr 
	where zr.id_cont in (@id_cont, @id_cont_third_party)
	and zr.prodano = 0
end