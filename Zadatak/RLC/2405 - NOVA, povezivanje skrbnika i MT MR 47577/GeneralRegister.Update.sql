--Parameters {X}:
--{0} 0 -'g_tomislav'   
--{1} 1 -'generalregister.update'   
--{2} 2 -'id_register'  
--{3} 3 -'RLC_SKRBNIK_1_MT'  
--{4} 4 -'id_key'  
--{5} 5 -'001493'  
--{6} 6 - NULL  

declare @id_register varchar(100) = {3}

if @id_register = 'RLC_SKRBNIK_1_MT'
begin
declare @hash_value varchar(40) = dbo.gfn_GetContractDataHash(2005)

select '<?xml version=''1.0'' encoding=''utf-8'' ?><rpg_contract_update xmlns="urn:gmi:nova:leasing"> <common_parameters> <id_cont>2005</id_cont> <comment>test objašnjenje promjena</comment> <hash_value>' +@hash_value +'</hash_value> <id_rep_category>999</id_rep_category> <use_4eyes>false</use_4eyes> </common_parameters> <updated_values>   <table_name>POGODBA</table_name>   <name>ID_STRM</name>   <updated_value>1000</updated_value> </updated_values>  </rpg_contract_update>' AS xml,
	cast(0 as bit) as via_queue,    
	0 as delay,    
	cast(0 as bit) as via_esb,    
	'nova.le' as esb_target  

--union all 

select '<update_fa xmlns=''urn:gmi:nova:fa''><id_strm>1000</id_strm><id_sobe>00001</id_sobe><neam_vred>0</neam_vred><id_amor_sk>001</id_amor_sk><id_nomen>100</id_nomen><id_kupca>000001</id_kupca><id_gl_sifkljuc>1</id_gl_sifkljuc><id_knjizbe>0001</id_knjizbe> <id_fa>784</id_fa><zac_reval>2014/06</zac_reval><id_grupe>0000</id_grupe><id_cont>2005</id_cont><naziv1>test unosa OS</naziv1> <naziv2></naziv2> <stopnja_am>4</stopnja_am><sys_ts>' +cast(cast(fa.sys_ts as bigint) as varchar(40)) +'</sys_ts><zac_amort>2014/06</zac_amort><st_amint>0</st_amint><st_amek>0</st_amek><ne_knjizim>false</ne_knjizim><opombe></opombe><zac_amort_datum>2014-06-01T00:00:00.000</zac_amort_datum></update_fa>' as xml,
	cast(0 as bit) as via_queue,    
	300 as delay,    
	cast(0 as bit) as via_esb,    
	'nova.le' as esb_target
from dbo.fa fa
where id_fa = 784

end
/* OBRISAO
<updated_values>   <table_name>POGODBA</table_name>   <name>SF_FREE_PERIOD</name>   <is_null>true</is_null> </updated_values> <updated_values>   <table_name>POGODBA</table_name>   <name>SF_OFFSET</name>   <is_null>true</is_null> </updated_values>
*/

-- custom_event_handler je bio deaktiviran, event se i dalje pokretao => za standardne se ne treba onda definirati