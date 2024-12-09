declare @id_conts varchar(max) = {0}		-- id_conts delimited by comma (,)

declare @contracts_where_activation_is_not_allowed table (id_cont int, id_pog varchar(11));

insert into @contracts_where_activation_is_not_allowed (id_cont, id_pog)
select pog.ID_CONT, pog.id_pog
from dbo.POGODBA pog
inner join dbo.gfn_split_ids(@id_conts, ',') i on i.id = pog.ID_CONT
where pog.ID_STRM like '05%' and pog.DAT_PODPISA is null


----- Tab[0]: is activation allowed (true/false) 
select 
	case when COUNT(*) = 0 
		then CAST(1 as bit) 
		else CAST(0 as bit) 
	end as contract_activation_is_allowed,
	case when COUNT(*) = 0 
		then ''
		else 'Aktivacija pogodb ni mogoèa, ker le ta nima datuma podpisa. Id_pog:'
	end as error_msg
from @contracts_where_activation_is_not_allowed 

----- Tab[1]: list of id_pogs for which activation is not allowed 
select ID_CONT, id_pog
from @contracts_where_activation_is_not_allowed


