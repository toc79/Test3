select * from dbo.EXT_FUNC where ID_EXT_FUNC like '%sys%'
--Sys.EventHandler.ProcessXml.[event_name]
--AfterContractUpdate
-- INSERT INTO dbo.EXT_FUNC (id_ext_func, code, id_ext_func_type, inactive, onform) VALUES ('Sys.EventHandler.ProcessXml.Contract.Activated', '', 'SQL_CS', '0', NULL)

   --select     '<plugin_list xmlns="urn:gmi:nova:core"></plugin_list>' as xml,     
   --cast(1 as bit) as via_queue,    
   --300 as delay,    
   --cast(0 as bit) as via_esb,    
   --'nova.bpm' as esb_target  

declare @id_cont int 
set @id_cont = 38667--{0}

select '<delete_dokument xmlns="urn:gmi:nova:leasing">
<id_dokum>'+CAST(b.id_dokum as varchar(10))+'</id_dokum>
<delete_linked_docs>true</delete_linked_docs>
</delete_dokument>' AS xml,
   cast(0 as bit) as via_queue,    
   300 as delay,    
   cast(0 as bit) as via_esb,    
   'nova.bpm' as esb_target  
FROM dbo.pogodba a
JOIN dbo.dokument b ON a.id_cont = b.id_cont AND b.id_obl_zav = '1R'
WHERE a.id_cont = @id_cont


declare @id_cont int 
set @id_cont = 38667
--{0} to je user g_tomislav
--{1} 
--{2}
--{3}
--{4}
--{5}
--{6}
--{7}
--{8}
--{9}
--{10}

select '<delete_dokument xmlns="urn:gmi:nova:leasing">
<id_dokum>'+CAST(b.id_dokum as varchar(10))+'</id_dokum>
<delete_linked_docs>true</delete_linked_docs>
</delete_dokument>' AS xml,
   cast(0 as bit) as via_queue,    
   300 as delay,    
   cast(0 as bit) as via_esb,    
   'nova.bpm' as esb_target  
FROM dbo.pogodba a
JOIN dbo.dokument b ON a.id_cont = b.id_cont AND b.id_obl_zav = '1R'
WHERE a.id_cont = @id_cont

--u logu

declare @id_cont int   set @id_cont = 38667  
--'g_tomislav' to je user g_tomislav  0
--'contract.activated'   1
--'id_cont'  2
--'38667'  3
--NULL  
--NULL  --NULL  --NULL  --NULL  --NULL  --NULL    
select '<delete_dokument xmlns="urn:gmi:nova:leasing">  
<id_dokum>'+CAST(b.id_dokum as varchar(10))+'</id_dokum>  
<delete_linked_docs>true</delete_linked_docs>  
</delete_dokument>' AS xml,     
cast(0 as bit) as via_queue,         
300 as delay,         
cast(0 as bit) as via_esb,         
'nova.bpm' as esb_target    
FROM dbo.pogodba a  
JOIN dbo.dokument b ON a.id_cont = b.id_cont AND b.id_obl_zav = '1R'  
WHERE a.id_cont = @id_cont