declare @OM_specification bit = (Select case when b.id_dav_st = 'OM' then 1 else 0 end as OM_specification --and sum(cast(a.je_davek as int)) > 0
							from dbo.gl_output_r b 
							where b.ddv_id = @id)
						--From dbo.gl_out_rk a
						--Inner join dbo.gl_output_r b on a.id_gl_output_r = b.id_gl_output_r and b.ddv_id = @id
						--group by b.ddv_id, b.id_dav_st)

if @OM_specification = 0
	Select a.opis, a.kosov, a.cena, a.davek, a.znesek --, a.je_davek , a.osnova, a.id_cont
	From dbo.gl_out_rk a
	Inner join dbo.gl_output_r b on a.id_gl_output_r = b.id_gl_output_r and b.ddv_id = @id

else
begin
	declare @protikonto_neto char(8) = (Select top 1 a.protikonto
										From dbo.gl_out_rk a
										Inner join dbo.gl_output_r b on a.id_gl_output_r = b.id_gl_output_r and b.ddv_id = @id
										where a.je_davek = 1)
	declare @opis_neto varchar(500) = (Select top 1 a.opis
									From dbo.gl_out_rk a
									Inner join dbo.gl_output_r b on a.id_gl_output_r = b.id_gl_output_r and b.ddv_id = @id
									where a.protikonto = @protikonto_neto 
									and a.je_davek = 0)
	--NETO i MARŽA
	select @opis_neto as opis
		, min(a.kosov) as kosov
		, sum(a.cena + a.davek) as cena
		, convert(decimal(18,2), 0) as davek
		, sum(a.znesek) as znesek 
	from dbo.gl_out_rk a
	inner join dbo.gl_output_r b on a.id_gl_output_r = b.id_gl_output_r and b.ddv_id = @id
	where a.protikonto = @protikonto_neto
	
	union all 
	--PPMV
	select a.opis, a.kosov, a.cena, a.davek, a.znesek --, a.je_davek , a.osnova, a.id_cont
	from dbo.gl_out_rk a
	inner join dbo.gl_output_r b on a.id_gl_output_r = b.id_gl_output_r and b.ddv_id = @id 
	where a.protikonto != @protikonto_neto
end