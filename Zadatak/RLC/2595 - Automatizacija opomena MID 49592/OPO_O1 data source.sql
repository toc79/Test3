declare @id_kupca as varchar(10), @id_tec varchar(3), @dat_tec datetime, @delimiter char(1), @cnt int
set @cnt = 1
set @delimiter = '$'
--set @id = '000001$000$20190703$21'

	while (charindex(@delimiter, @id)>0)
    begin
     
		if @cnt = 1 
		begin
        
			set @id_kupca = ltrim(rtrim(substring(@id, 1, charindex(@delimiter, @id)-1)))
		end

		if @cnt = 2
		begin
        
			set @id_tec = ltrim(rtrim(substring(@id, 1, charindex(@delimiter, @id)-1)))
		end
		if @cnt = 3 
		begin
        
			set @dat_tec = ltrim(rtrim(substring(@id, 1, charindex(@delimiter, @id)-1)))
		end

			set @id = substring(@id, charindex(@delimiter, @id)+1, len(@id))
			set @cnt = @cnt + 1
    end


Select p.id_kupca, p.naz_kr_kup, p.ulica, p.id_poste, p.mesto, p.stev_reg,
	tec.naziv as tec_naziv,
	tec.id_val,
	@id_tec as id_tec_s,
	@dat_tec as dat_tec_s
	From dbo.PARTNER p
INNER JOIN dbo.tecajnic tec ON tec.id_tec = @id_tec
where p.id_kupca = @id_kupca


/*set @xml_data = (Select cast(xml1 as xml)  as xml_data
From dbo.ssoft_reports
Where id = CAST(@id as INT)
)

select
	par.id_kupca, par.naz_kr_kup, par.ulica, par.id_poste, par.mesto, par.stev_reg,
	tec.naziv as tec_naziv,
	tec.id_val,
	a.id_tec_s,
	a.dat_tec_s
	FROM
(Select 
	rtrim(t.c.value('id_kupca[1]','varchar(10)')) as id_kupca,
	rtrim(t.c.value('id_tec_s[1]','varchar(3)')) as id_tec_s,
	rtrim(t.c.value('dat_tec_s[1]','datetime')) as dat_tec_s
	From @xml_data.nodes('VFPData/rezultat') t(c))a
INNER JOIN dbo.PARTNER par ON a.id_kupca = par.id_kupca
INNER JOIN dbo.tecajnic tec ON a.id_tec_s = tec.id_tec
*/

