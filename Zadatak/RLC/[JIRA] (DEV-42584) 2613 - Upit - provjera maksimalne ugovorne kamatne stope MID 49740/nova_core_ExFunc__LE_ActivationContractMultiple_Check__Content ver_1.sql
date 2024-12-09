-- 12.04.2024 g_tomislav MID 49740 - created

declare @id_conts varchar(max) = {0}		-- id_conts delimited by comma (,)

declare @contracts_where_activation_is_not_allowed table (id_cont int, id_pog varchar(11));

insert into @contracts_where_activation_is_not_allowed (id_cont, id_pog)
select pog.id_cont, pog.id_pog
from dbo.pogodba pog
inner join dbo.gfn_split_ids(@id_conts, ',') i on i.id = pog.ID_CONT
inner join dbo.PARTNER par on pog.id_kupca = par.id_kupca
inner join dbo.vrst_ose vo on par.vr_osebe = vo.vr_osebe
cross join dbo.NASTAVIT n
cross apply dbo.gfn_CalculateMaxAllowedIR(pog.dej_obr
			, pog.vr_val_zac
			, case when vo.sifra = 'FO' then 1 else 0 end
			, pog.nacin_leas, 
			cast(cast(getdate() as date) as datetime)
		) x
where n.check_max_ir = 1
and x.max_ir_used = 1


----- Tab[0]: is activation allowed (true/false) 
select 
	case when COUNT(*) = 0 
		then CAST(1 as bit) 
		else CAST(0 as bit) 
	end as contract_activation_is_allowed,
	case when COUNT(*) = 0 
		then ''
		else 'Aktivacija ugovora nije moguæa jer je prekoraèena maksimalna zakonski dozvoljena kamatna stopa. Ugovor: '
	end as error_msg
from @contracts_where_activation_is_not_allowed 

----- Tab[1]: list of id_pogs for which activation is not allowed 
select ID_CONT, id_pog
from @contracts_where_activation_is_not_allowed