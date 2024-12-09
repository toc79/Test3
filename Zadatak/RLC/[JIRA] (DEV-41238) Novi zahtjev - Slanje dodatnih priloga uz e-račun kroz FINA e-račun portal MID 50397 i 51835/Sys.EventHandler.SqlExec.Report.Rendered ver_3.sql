-- 29.02.2024 g_tomislav MID 51835 - set izpisan and opombe in rep_ind for FAK_LOBR_SSOFT_RLC for LOBR and FINA partners (ident_stevilka)

declare @rendered_report_name varchar(100), @id_rendered varchar(100), @max_id_rep_ind int
set @rendered_report_name = {3}
set @id_rendered = ltrim(rtrim({5})) 

if @id_rendered != '-1' --When we run Stimulsoft Designer, event is triggered with id_object = -1 
begin 
	if @rendered_report_name = 'FAK_LOBR_SSOFT_RLC'
	begin
		set @max_id_rep_ind = isnull((select rep_ind.max_id_rep_ind
			from (
				select nf.id_cont, nf.id_kupca 
				from dbo.najem_fa nf
				inner join dbo.vrst_ter vt on nf.id_terj = vt.id_terj
				and vt.sif_terj = 'LOBR'
				and nf.ddv_id = @id_rendered
			) nf
			inner join dbo.partner par on nf.id_kupca = par.id_kupca	
			inner join (select max(id_rep_ind) as max_id_rep_ind, id_cont from dbo.rep_ind where izpisan = 0 and ddv_date > '20230630' group by id_cont) as rep_ind on nf.id_cont = rep_ind.id_cont
			where par.ident_stevilka is not null and par.ident_stevilka != ''
			), 0)
		
		if @max_id_rep_ind != 0 
		begin
			update dbo.rep_ind set izpisan = 1 where izpisan = 0 and id_rep_ind = @max_id_rep_ind
			update dbo.rep_ind set opombe = @id_rendered +iif(opombe != '', char(13) + opombe, '') where charindex(@id_rendered, opombe) = 0 and id_rep_ind = @max_id_rep_ind
		end
	end
end


/* 

odlučio sam se za inner join jer kod cross apply mi se javilo da je NULL eliminates by set or other operation TAKO NEŠTO 

--test case
declare @id varchar(30) = '20240011699'
select opombe, IZPISAN, * from dbo.rep_ind where charindex(@id, opombe) > 0 or ID_REP_IND = 177550
select  * from dbo.najem_fa where ddv_id = @id
select * from dbo.edoc_exported_files where document_id = '177550' and id_edoc_doctype = 'TaxChngIx'
select * from dbo.EDOC_EXPORTED_FILES_CHANNELS where id_file = 1243327

select * from dbo.xdoc_document where id_xdoc_template = 54 and doc_id = '177550' order by id_xdoc_run_history desc

--delete from dbo.EDOC_EXPORTED_FILES_CHANNELS where id_file = 1243326
--delete from dbo.edoc_exported_files where document_id = '177550' and id_edoc_doctype = 'TaxChngIx'

--update dbo.rep_ind set izpisan = 0, opombe = '' where ID_REP_IND = 177550

-- 28.02.2024 g_tomislav MID 50397 - created automatic rendering OBV_IND_SSOFT_RLC for not printed after FAK_LOBR_SSOFT_RLC and ZBR_FAKT_SSOFT_RLC for LOBR and FINA partners
-- nema potrebe ovaj event koristiti, jer treba označiti obavijesti u REP_IND kao označene, a to 


KADA SE STAVI DELAY, ONDA IDE U QUEUE  !!!! :) :) :) :) :) :) :) :) :) :) :) :) :) :) :) :) 

-- cross apply radi brže od inner join kada nema rezultata (0) što će biti u većini pokretanja evenata (inner join je brži kada ima pogodaka)
=> trebalo bi testirati s Actual executing plan
--ponovno testiranje s Actual executing plan na kraju bude sve isto na Compability level 120 SQL Server 2014 !!



kad ima pogodaka rezultat je 2 retka

(2 rows affected)

 SQL Server Execution Times:
   CPU time = 31 ms,  elapsed time = 28 ms.

cross apply radi sporije

(2 rows affected)

 SQL Server Execution Times:
   CPU time = 47 ms,  elapsed time = 44 ms.

Completion time: 2023-10-26T13:31:36.7250452+02:00



kada nema pogodaka rezultata

(0 rows affected)

 SQL Server Execution Times:
   CPU time = 31 ms,  elapsed time = 28 ms.

cross apply radi brže

(0 rows affected)

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 0 ms.

Completion time: 2023-10-26T13:32:24.8964402+02:00

*/

-- ZA TESTIRANJE
-- 26.10.2023 g_tomislav MID 50397

declare @rendered_report_name varchar(100), @rep_name varchar(100), @sql_code_after varchar(1000), @delay int, @retry_count int, @id_rendered varchar(100)

set @rendered_report_name = 'ZBR_FAKT_SSOFT_RLC'--{3}
set @rep_name = 'ERROR'
set @id_rendered = iif(@rendered_report_name = 'FAK_LOBR_SSOFT_RLC', '20230001825', '455') --{5} 
set @delay = 240
set @retry_count = 3

set statistics time on

if @id_rendered != '-1' -- Kod pokretanja designera se okine event s id_object = -1 pa treba i to hendlat
begin 
	if @rendered_report_name in ('FAK_LOBR_SSOFT_RLC', 'ZBR_FAKT_SSOFT_RLC')
	begin
		set @rep_name = 'OBV_IND_SSOFT_RLC' 
		set @delay = 0 -- za zakomnetirati poslije testa 

		select 
			@rep_name as report, 
			convert(varchar(30), rep_ind.max_id_rep_ind) as id,
			@delay as delay,
			'update dbo.rep_ind set izpisan = 1 where id_rep_ind  = ' +convert(varchar(30), rep_ind.max_id_rep_ind) +' and izpisan = 0;' 
			 +'update dbo.rep_ind set opombe = ' +rtrim(nf.ddv_id) +iif(rep_ind.opombe != '', char(13), '') +rep_ind.opombe +' where id_rep_ind  = ' +convert(varchar(30), rep_ind.max_id_rep_ind) +' and opombe not like ''%' +rtrim(ddv_id) +'%''' 
				as sql_code_after,
			@retry_count as retry_count 
			
		from (
			select id_cont, id_kupca, ddv_id from dbo.najem_fa where @rendered_report_name in ('FAK_LOBR_SSOFT_RLC') and ddv_id = @id_rendered
			union
			select nf.id_cont, nf.id_kupca, nf.ddv_id from dbo.najem_fa nf where @rendered_report_name in ('ZBR_FAKT_SSOFT_RLC') and exists (select * from dbo.zbirniki where id_zbirnik = try_convert(int, @id_rendered) and ddv_id = nf.ddv_id)
		) nf
		inner join dbo.partner par on nf.id_kupca = par.id_kupca
		inner join (select ri2.max_id_rep_ind, ri1.opombe, ri1.id_cont 
					from dbo.rep_ind ri1 
					inner join (
						select max(id_rep_ind) as max_id_rep_ind, id_cont from dbo.rep_ind where izpisan = 0 and ddv_date > '20230630' group by id_cont
						) ri2 on ri1.id_cont = ri2.id_cont and ri1.id_rep_ind = ri2.max_id_rep_ind
					) as rep_ind on nf.id_cont = rep_ind.id_cont
		where 1=1 -- odkomentirati poslije TESTA
		and par.ident_stevilka is not null and par.ident_stevilka != '' -- only for FINA
	end
end


print '
cross apply radi sporije'

if @id_rendered != '-1' -- Kod pokretanja designera se okine event s id_object = -1 pa treba i to hendlat
begin 
	if @rendered_report_name in ('FAK_LOBR_SSOFT_RLC', 'ZBR_FAKT_SSOFT_RLC')
	begin
		set @rep_name = 'OBV_IND_SSOFT_RLC' 
		set @delay = 0 -- za zakomnetirati poslije testa 

		select 
			@rep_name as report, 
			convert(varchar(30), rep_ind.max_id_rep_ind) as id,
			@delay as delay,
			'update dbo.rep_ind set izpisan = 1 where id_rep_ind  = ' +convert(varchar(30), rep_ind.max_id_rep_ind) +' and izpisan = 0;' 
			 +'update dbo.rep_ind set opombe = ' +rtrim(nf.ddv_id) +iif(rep_ind.opombe != '', char(13), '') +rep_ind.opombe +' where id_rep_ind  = ' +convert(varchar(30), rep_ind.max_id_rep_ind) +' and opombe not like ''%' +rtrim(ddv_id) +'%''' 
				as sql_code_after,
			@retry_count as retry_count 
			
		from (
			select id_cont, id_kupca, ddv_id from dbo.najem_fa where @rendered_report_name in ('FAK_LOBR_SSOFT_RLC') and ddv_id = @id_rendered
			union
			select nf.id_cont, nf.id_kupca, nf.ddv_id from dbo.najem_fa nf where @rendered_report_name in ('ZBR_FAKT_SSOFT_RLC') and exists (select * from dbo.zbirniki where id_zbirnik = try_convert(int, @id_rendered) and ddv_id = nf.ddv_id)
		) nf
		inner join dbo.partner par on nf.id_kupca = par.id_kupca
		cross apply (select ri2.max_id_rep_ind, ri1.opombe 
					from dbo.rep_ind ri1 
					cross apply (select max(id_rep_ind) as max_id_rep_ind from dbo.rep_ind where izpisan = 0 and ddv_date > '20230630' and id_cont = nf.id_cont ) ri2 --inner join on ri1.id_rep_ind = ri2.max_id_rep_ind
					where 1=1 
					--and ri1.id_cont = nf.id_cont 
					and ri1.id_rep_ind = ri2.max_id_rep_ind
					) as rep_ind
		where 1=1 -- odkomentirati poslije TESTA
		and par.ident_stevilka is not null and par.ident_stevilka != '' -- only for FINA
	end
end

set statistics time off



--ponovno testiranje s Actual executing plan na kraju bude sve isto na COmpability level 120 SQL Server 2014 !!

--odlučio sam se za inner join jer kod cross apply mi se javilo da je NULL eleminates by set or other 

-- 28.02.2024 g_tomislav MID 50397 - created automatic rendering OBV_IND_SSOFT_RLC for not printed after FAK_LOBR_SSOFT_RLC and ZBR_FAKT_SSOFT_RLC for LOBR and FINA partners

declare @rendered_report_name varchar(100), @id_rendered varchar(100), @max_id_rep_ind int
set @rendered_report_name = 'FAK_LOBR_SSOFT_RLC'
set @id_rendered =  20240011699

if @id_rendered != '-1' --When we run Stimulsoft Designer, event iz triggered with id_object = -1 
begin 
	if @rendered_report_name in ('FAK_LOBR_SSOFT_RLC')
	begin
set statistics time on
		set @max_id_rep_ind = (select rep_ind.max_id_rep_ind 
			from (
				select nf.id_cont, nf.id_kupca 
				from dbo.najem_fa nf
				inner join dbo.vrst_ter vt on nf.id_terj = vt.id_terj
				and vt.sif_terj = 'LOBR'
				and nf.ddv_id = @id_rendered
			) nf
			inner join dbo.partner par on nf.id_kupca = par.id_kupca	
			cross apply (select max(id_rep_ind) as max_id_rep_ind 
									from dbo.rep_ind 
									where izpisan = 0
									and ddv_date > '20230630' 
									and id_cont = nf.id_cont
						) as rep_ind
			where par.ident_stevilka is not null and par.ident_stevilka != ''
			)
		select * from dbo.rep_ind where ID_REP_IND = @max_id_rep_ind
		
		set @max_id_rep_ind = (select rep_ind.max_id_rep_ind 
			from (
				select nf.id_cont, nf.id_kupca--, nf.ddv_id 
				from dbo.najem_fa nf
				inner join dbo.vrst_ter vt on nf.id_terj = vt.id_terj
				and vt.sif_terj = 'LOBR'
				and nf.ddv_id = @id_rendered
			) nf
			inner join dbo.partner par on nf.id_kupca = par.id_kupca	
			inner join (
						select max(id_rep_ind) as max_id_rep_ind, id_cont from dbo.rep_ind where izpisan = 0 and ddv_date > '20230630' group by id_cont
						) as rep_ind on nf.id_cont = rep_ind.id_cont
			where par.ident_stevilka is not null and par.ident_stevilka != ''
			)

		
		select * from dbo.rep_ind where ID_REP_IND = @max_id_rep_ind

		--update dbo.rep_ind set izpisan = 1 where izpisan = 0 and id_rep_ind = @max_id_rep_ind
		--update dbo.rep_ind set opombe = rtrim(nf.ddv_id) +iif(rep_ind.opombe != '', char(13) + opombe, '') where charindex(@id, opombe) and id_rep_ind = @max_id_rep_ind
set statistics time off		
	end
end