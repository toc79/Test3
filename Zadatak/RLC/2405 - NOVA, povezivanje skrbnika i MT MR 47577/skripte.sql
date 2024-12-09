--insert into dbo.EXT_FUNC values ('Sys.EventHandler.ProcessXml.GeneralRegister.Update', '', 'SQL_CS', 0, null)
--insert into dbo.EXT_FUNC values ('Sys.EventHandler.ProcessXml.GeneralRegister.Insert', '', 'SQL_CS', 0, null)
--insert into dbo.ext_func values ('Sys.EventHandler.ProcessXml.Contract.InsertOrUpdate', '', 'SQL_CS', 0, null) -- NE RADI NA AKTIVNIM UGOVORMA 
--insert into dbo.ext_func values ('Sys.EventHandler.ProcessXml.Contract.InsertingOrUpdating', '', 'SQL_CS', 0, null) -- NE RADI NA AKTIVNIM UGOVORIMA
--Kod promjene aktivnog ugovora na NOVA_HAC_NEW ima Event, koji pak nije naveden u ext_func ili custom_event_handlers, Event DwcDiffSyncCandidate.Insert raised with event data: [Key: [id_cont], Value: [2262]; Key: [id_kupca], Value: []; Key: [type], Value: [UPD]; ]  /// <summary> Called when something happened on contract, partner, claim etc. that is relevant for dwc diff sync candidate</summary>

select * from dbo.custom_event_handlers -- nije bilo potrebno registrirati event, možda zato što nije custom

declare @id_register varchar(100) = 'RLC_SKRBNIK_1_MT'
declare @skrbnik_1 varchar(100) = '001493' --id_key
declare @MT varchar(100) = (select val_char from dbo.general_register where id_register = @id_register and id_key= @skrbnik_1)
select * from dbo.general_register where id_register = @id_register and id_key= @skrbnik_1
select @id_register, @skrbnik_1, @MT

--Podesiti da ako @MT postoji u dbo.STRM! da tek onda ide

select par.skrbnik_1, pog.STATUS_AKT, pog.id_strm
	,* 
from dbo.POGODBA pog
inner join dbo.partner par on pog.id_kupca = par.id_kupca
where par.skrbnik_1 = @skrbnik_1
and pog.status_akt != 'Z'
and pog.id_strm != @MT

-- Fixed assets (OS)
select par.skrbnik_1, pog.STATUS_AKT, pog.id_strm, fa.id_strm fa_id_strm
	, fa.status
	, fa.* 
from dbo.POGODBA pog
inner join dbo.partner par on pog.id_kupca = par.id_kupca
inner join dbo.fa fa on pog.id_cont = fa.id_cont
where par.skrbnik_1 = @skrbnik_1
and pog.status_akt != 'Z'
--and pog.id_strm != @MT
and fa.id_strm != @MT
--and fa.status in ('A', 'P')

-- Fixed assets (OS) fa_dnev
select par.skrbnik_1, pog.STATUS_AKT, pog.id_strm, fa.id_strm fa_id_strm
	--, fa.status
	, fa.* 
from dbo.POGODBA pog
inner join dbo.partner par on pog.id_kupca = par.id_kupca
inner join dbo.fa_dnev fa on pog.id_cont = fa.id_cont
where par.skrbnik_1 = @skrbnik_1
and pog.status_akt != 'Z'
--and pog.id_strm != @MT
and fa.id_strm != @MT 