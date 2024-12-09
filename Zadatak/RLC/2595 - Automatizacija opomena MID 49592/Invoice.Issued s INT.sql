declare @ddv_id varchar(15)
set @ddv_id = {3}

declare @tab varchar(100)
declare @rep_name varchar(100)
declare @id varchar(100)
declare @sql_code_after varchar(1000)
declare @delay int
declare @is_for_fina bit

set @is_for_fina = (Select cast(count(*) as bit) From dbo.partner where id_kupca in (Select id_kupca From dbo.rac_out Where ddv_id = @ddv_id) and ident_stevilka is not null and ident_stevilka <> '') 

set @id = @ddv_id
set @tab = (select dbo.gfn_GetInvoiceSource(@ddv_id))
set @rep_name = 'ERROR'
set @delay = 240

if @tab = 'NAJEM_FA'
begin
	--if @is_for_fina = 0
	--begin
		set @rep_name = 'IGNORE' 
	--end
	--else
	--begin
	--	set @rep_name = 'FAK_LOBR_SSOFT_RLC' 
	--	set @sql_code_after = 'update dbo.najem_fa set izpisan = 1 where ddv_id = ''' + RTRIM(@ddv_id) + ''''
	--	set @delay = 10800
	--end
end
else
if @tab = 'POGODBA'
begin
	if @is_for_fina = 0
	begin
		set @rep_name = 'IGNORE' 
	end
	else
	begin
		set @rep_name = 'KK_FAKT' --popraviti custom_settings ime, pustiti sve EDOC obrade i code before
	end
end
else
if @tab = 'ZOBR_FA' 
begin
	if @is_for_fina = 0
	begin
		set @rep_name = 'IGNORE' 
	end
	else
	begin
		set @rep_name = 'ZOBR_FA_SSOFT_RLC' 
		set @sql_code_after = 'update dbo.zobr_fa set izpisan = 1 where ddv_id = ''' + RTRIM(@ddv_id) + ''''
	end
end
else
if @tab = 'REP_IND' 
begin
	if @is_for_fina = 0
	begin
		set @rep_name = 'IGNORE' 
	end
	else
	begin
		set @rep_name = 'OBV_IND_SSOFT_RLC' 
		set @id = (select cast(id_rep_ind as varchar(100)) from dbo.rep_ind where ddv_id = @ddv_id)
		set @sql_code_after = 'update dbo.rep_ind set izpisan = 1 where id_rep_ind = ''' + rtrim(@id) + ''''
	end
end
else
if @tab = 'SPR_DDV'
begin
	if @is_for_fina = 0
	begin
		set @rep_name = 'IGNORE' 
	end
	else
	begin
		set @rep_name = 'DDV_DBRP_ZVEC_SSOFT_RLC' 
		set @id = (Select cast(id_spr_ddv as varchar(100)) From dbo.SPR_DDV where DDV_ID = @ddv_id)
		set @sql_code_after = 'update dbo.spr_ddv set izpisan = 1 where id_spr_ddv = ''' + rtrim(@id) + ''''
	end
end
else
if @tab = 'ZA_OPOM' 
begin
	if @is_for_fina = 0
	begin
		set @rep_name = 'IGNORE' 
	end
	else
	begin
		set @rep_name = 'OPOMIN' --popraviti custom_settings ime, pustiti sve EDOC obrade i code before
		set @id =(select cast(id_opom as varchar(100)) from dbo.za_opom where ddv_id = @ddv_id)
		if @id is null
			set @id =(select cast(id_opom as varchar(100)) from dbo.arh_za_opom where ddv_id = @ddv_id)
		set @sql_code_after = 'update dbo.za_opom set izpisan = 1 where id_opom = ''' + rtrim(@id) + ''''
	end
end
else
if @tab = 'DOK_OPOM' 
begin
	if @is_for_fina = 0
	begin
		set @rep_name = 'IGNORE' 
	end
	else
	begin
		set @rep_name = 'DOK_OP_SSOFT_RLC' 
		set @id =(select cast(min(id_opom) as varchar(100)) from dbo.dok_opom where ddv_id = @ddv_id)
		if @id is null
			set @id =(select cast(min(id_opom) as varchar(100)) from dbo.arh_dok_opom where ddv_id = @ddv_id)
		set @sql_code_after = 'update dbo.dok_opom set izpisan = 1 where id_opom = ''' + rtrim(@id) + ''''
	end
end
else
if @tab = 'OPC_FAKT' --za sada će ručno
begin
	if @is_for_fina = 0
	begin
		set @rep_name = 'IGNORE' 
	end
	else
	begin
		set @rep_name = 'OPC_FAK_SSOFT_RLC' 
		set @sql_code_after = 'update dbo.opc_fakt set izpisan = 1 where ddv_id = ''' + RTRIM(@ddv_id) + ''''
	end
end
else
if @tab = 'FAKTURE' 
begin
	if @is_for_fina = 0
	begin
		set @rep_name = 'IGNORE' 
	end
	else
	begin
		set @rep_name = 'SPL_FAK' --popraviti custom_settings ime, pustiti sve EDOC obrade i code before
		set @sql_code_after = 'update dbo.fakture set izpisan = 1 where ddv_id = ''' + RTRIM(@ddv_id) + ''''
	end
end
else
if @tab = 'AVANSI' 
begin
	if @is_for_fina = 0
	begin
		set @rep_name = 'IGNORE' 
	end
	else
	begin
		set @rep_name = 'FAK_AVAN_SSOFT_RLC'
		set @sql_code_after = 'update dbo.avansi set izpisan = 1 where ddv_id = ''' + RTRIM(@ddv_id) + ''''
	end
end
else
if @tab = 'GL_OUTPUT_R' 
begin
	if @is_for_fina = 0
	begin
		set @rep_name = 'IGNORE' 
	end
	else
	begin
		set @rep_name = 'OUTPU_R2_SSOFT_RLC' 
	end
end
--else
--if @tab = 'PLANP' set @rep_name = 'FAKT_PP_SSOFT_UCL' --MI OVO NEMAMO ide u najem_fa
else
if @tab = 'ZA_REGIS' 
begin
	--if @is_for_fina = 0
	--begin
		set @rep_name = 'IGNORE' 
	--end
	--else
	--begin
	--	set @rep_name = 'FAK_REG_SSOFT_RLC' 
	--	set @sql_code_after = 'update dbo.za_regis set izpisan = 1 where ddv_id = ''' + RTRIM(@ddv_id) + ''''
	--end
end
else
if @tab = 'TEC_RAZL' 
begin
	if @is_for_fina = 0
	begin
		set @rep_name = 'IGNORE' 
	end
	else
	begin
		set @rep_name = 'FAKT_TR_SSOFT_RLC' 
		set @sql_code_after = 'update dbo.tec_razl set izpisan = 1 where ddv_id = ''' + RTRIM(@ddv_id) + ''''
	end
end
else 
if @tab = 'ZBIRNA_FAKTURA' 
begin
	set @rep_name = 'IGNORE' 
	--set @rep_name = 'ZBR_FAKT_SSOFT_RLC' 
	--set @sql_code_after = 'update dbo.zbirniki set izpisan = 1 where ddv_id = ''' + RTRIM(@ddv_id) + ''''
end
else
set @rep_name = 'ERROR'

if  @delay is null
begin 
	set @delay = 240
end 

if @sql_code_after is null
begin
    select 
        @rep_name as report, 
        ltrim(rtrim(@id)) as id,
        @delay as delay
    where @rep_name <> 'IGNORE'
end
else
begin
    select 
        @rep_name as report, 
        rtrim(ltrim(@id)) as id,
        @sql_code_after as sql_code_after,
        @delay as delay
    where @rep_name <> 'IGNORE'
end
