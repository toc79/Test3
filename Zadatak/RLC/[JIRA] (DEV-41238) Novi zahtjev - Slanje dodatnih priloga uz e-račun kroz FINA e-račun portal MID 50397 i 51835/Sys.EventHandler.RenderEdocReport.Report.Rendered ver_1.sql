-- 26.10.2023 g_tomislav MID 50397 - created automatic rendering OBV_IND_SSOFT_RLC after FAK_LOBR_SSOFT_RLC and ZBR_FAKT_SSOFT_RLC

declare @rendered_report_name varchar(100), @rep_name varchar(100), @sql_code_after varchar(1000), @delay int, @retry_count int, @id_rendered varchar(100)

set @rendered_report_name = {3}
set @rep_name = 'ERROR'
set @id_rendered = {5} 
set @delay = 300
set @retry_count = 2

if @id_rendered != '-1' -- Kod pokretanja designera se okine event s id_object = -1 pa treba i to hendlat
begin 
	if @rendered_report_name in ('FAK_LOBR_SSOFT_RLC', 'ZBR_FAKT_SSOFT_RLC')
	begin
		set @rep_name = 'OBV_IND_SSOFT_RLC' 
		set @delay = 60 -- za zakomnetirati poslije testa 

		select 
			@rep_name as report, 
			convert(varchar(30), rep_ind.max_id_rep_ind) as id,
			@delay as delay,
			'update dbo.rep_ind set izpisan = 1 where id_rep_ind  = ' +convert(varchar(30), rep_ind.max_id_rep_ind) +' and izpisan = 0;' 
			 +' update dbo.rep_ind set opombe = ''' +rtrim(nf.ddv_id) +'''' +iif(rep_ind.opombe != '', ' + char(13) + opombe', '')  +' where id_rep_ind  = ' +convert(varchar(30), rep_ind.max_id_rep_ind) +' and opombe not like ''%' +rtrim(ddv_id) +'%''' 
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
					cross apply (select max(id_rep_ind) as max_id_rep_ind from dbo.rep_ind where izpisan = 0 and ddv_date > '20230630' and id_cont = nf.id_cont ) ri2
					where 1=1 
					and ri1.id_rep_ind = ri2.max_id_rep_ind
					) as rep_ind
		where par.ident_stevilka is not null and par.ident_stevilka != '' -- only for FINA
	end
end

/* -- cross apply radi brže od inner join kada nema rezultata (0) što će biti u većini pokretanja evenata (inner join je brži kada ima pogodaka)



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