--podešavanja na produkciji 

drop index if exists IX_DOKUMENT_ID_CONT_ID_OBL_ZAV on dbo.dokument

--kraj podešavanja na produkciji


outer apply (select top 1 opis1 from dbo.dokument where id_cont = a.id_cont and id_obl_zav = 'DU' order by id_dokum desc) dok --on a.id_cont = dok.id_cont RADI SPORIJE OD LEFT JOINA, EXECUTIN PLAN JA 49% 
originalni
   CPU time = 125 ms,  elapsed time = 276 ms.
   
outer apply 
   CPU time = 125 ms,  elapsed time = 345 ms.

select *
from dbo.reports_log
where id_report = 'FAK_LOBR_SSOFT_RLC' and rendered_when >= '20240703'


--create nonclustered index IX_ID_CONT_ID_OBL_ZAV on dbo.dokument (id_cont, id_obl_zav)
-- create nonclustered index IX_ID_CONT_ID_OBL_ZAV on dbo.dokument (id_cont) include (id_obl_zav)
--drop index if exists IX_ID_CONT_ID_OBL_ZAV on dbo.dokument

create nonclustered index IX_DOKUMENT_ID_CONT_ID_OBL_ZAV on dbo.dokument (id_cont) include (id_obl_zav)


ALTER INDEX IX_DOKUMENT_IOZ ON dokument REBUILD
ALTER INDEX IX_DOKUMENT_ic ON dokument REBUILD


exec sp_updatestats


UPDATE STATISTICS dbo.dokument
--update statistics ne pokvari vrijeme SQL upita 


na prod
prije indeksa
 SQL Server Execution Times:
   CPU time = 3312 ms,  elapsed time = 3469 ms.


poslije indexa
 SQL Server Execution Times:
   CPU time = 93 ms,  elapsed time = 114 ms.


Pozdrav, 
klijent je prijavio da nakon podešavanja verzije 7.15 u 3. mjesecu 2024.g. se znatno usporilo priprema ispisa računa za rate koje pokreću početkom mjeseca.
Našim testiranjem smo zaključili da je za ubrzanje renderiranj potrebno dodati indeks na tabelu dokument (šaljem sliku u privitku) 
create nonclustered index IX_ID_CONT_ID_OBL_ZAV on dbo.dokument (id_cont) include (id_obl_zav)
Nakon dodavanja indeksa je trajanje renderiranja (reports_log.duration) je bilo oko 200 ms , dok je prij indeksa trajalo oko 2000 ms.

Kod klijenta ćemo indeks dodati i na produkciju pa molim još provjeru s vaše strane da li bi dodavali indeks za sve klijente ili neka indeks za sada bude samo na RLC.

LP 
Tomislav



Prosječno vrijeme trajanja pojedinog ispisa je bilo do tada oko 


select top 10 rtrim(ddv_id) as ddv_id2, * from dbo.najem_fa order by datum_dok desc 


select * from dbo.rep_ind where opombe like '%20240022676%'

select ri.opombe, pog.NACIN_LEAS, * 
from dbo.rep_ind ri
join dbo.pogodba pog on ri.id_cont = pog.id_cont
where ri.opombe != ''


Vrijeme Duration ovisi kada se pokrene, nema dosljednosti...
da se doradi najem_fa i makne dvojni prikaz i PFN_?

druga stranica je prazna kada se podesi @print_rep_ind i @id_rep_ind parametri!?

--select * from dbo.najem_fa
select top 20 * from dbo.reports_log where id_report in ('FAK_LOBR_SSOFT_RLC', 'FAK_LOBR_SSOFT_RLC2') order by id_reports_log desc

id_reports_log	id_report	id_object	doc_type	rendered_by	rendered_when	edoc_file_name	id_object_edoc	barcode	page_number	duration
2841402	FAK_LOBR_SSOFT_RLC            	20240022676	Invoice   	g_tomislav	2024-04-19 13:46:10.000	Invoice_20240022676_2024_04_19_13_46_09_974.pdf	20240022676	NULL	2	1009
2841401	FAK_LOBR_SSOFT_RLC2           	20240022676	NULL	g_tomislav	2024-04-19 13:45:47.000	NULL	NULL	NULL	2	7176
2841396	FAK_LOBR_SSOFT_RLC2           	20240022676	NULL	g_tomislav	2024-04-19 13:27:56.000	NULL	NULL	NULL	2	2297
2841395	FAK_LOBR_SSOFT_RLC            	20240022676	Invoice   	g_tomislav	2024-04-19 13:23:17.000	Invoice_20240022676_2024_04_19_13_23_17_155.pdf	20240022676	NULL	2	15714
2841394	FAK_LOBR_SSOFT_RLC2           	20240022676	NULL	g_tomislav	2024-04-19 13:22:32.000	NULL	NULL	NULL	2	9040
2841384	FAK_LOBR_SSOFT_RLC            	20240027982	Invoice   	g_tomislav	2024-04-19 11:49:17.000	Invoice_20240027982_2024_04_19_11_49_17_703.pdf	20240027982	NULL	1	951
2841383	FAK_LOBR_SSOFT_RLC2           	20230068054	NULL	g_tomislav	2024-04-19 11:48:05.000	NULL	NULL	NULL	1	2310
2841382	FAK_LOBR_SSOFT_RLC            	20230068054	Invoice   	g_tomislav	2024-04-19 11:47:49.000	Invoice_20230068054_2024_04_19_11_47_49_431.pdf	20230068054	NULL	1	904
2841381	FAK_LOBR_SSOFT_RLC            	20230068054	Invoice   	g_tomislav	2024-04-19 11:47:23.000	Invoice_20230068054_2024_04_19_11_47_23_477.pdf	20230068054	NULL	1	1610
2841377	FAK_LOBR_SSOFT_RLC2           	20230068054	NULL	g_tomislav	2024-04-19 11:18:51.000	NULL	NULL	NULL	1	1342
2841376	FAK_LOBR_SSOFT_RLC            	20230068054	Invoice   	g_tomislav	2024-04-19 11:17:49.000	Invoice_20230068054_2024_04_19_11_17_49_746.pdf	20230068054	NULL	1	5924

najem_fa

	, case when rep_ind.id_rep_ind is not null and f.ident_stevilka is not null and f.ident_stevilka <> '' and v.sif_terj = 'LOBR' then 1 else 0 end as print_rep_ind
	, rep_ind.id_rep_ind
	


Select opombe, IZPISAN, * 
From dbo.rep_ind 
where /*izpisan = 1 and */ ddv_date > '20230630' and opombe != ''

update dbo.REP_IND set IZPISAN = 0 where ID_REP_IND = 177564



declare @id varchar(100) = '20240027980'


declare @ddv_date datetime, @id_cont int
select @ddv_date = ddv_date
	, @id_cont = id_cont
from rac_out where ddv_id = @id
--from dbo.rep_ind where id_rep_ind in (Select max(ri.id_rep_ind) as id_rep_ind From dbo.rep_ind ri inner join dbo.najem_fa nf on ri.id_cont = nf.id_cont where ri.izpisan = 0 and ri.ddv_date > '20230630' and nf.ddv_id = @id)

declare @OpcSt_dok char(21) = (select ISNULL(dbo.gfn_GetOpcSt_dok(id_cont, nacin_leas), '0') as OpcSt_dok from dbo.pogodba where id_cont = @id_cont)
	
Select a.datum_dok,
	a.zap_obr,
	a.neto,
	a.marza, 
	a.obresti,
	a.robresti,
	a.debit,
	@OpcSt_dok as OpcSt_dok,
	CASE WHEN a.ST_DOK = @OpcSt_dok THEN 'OTKUPNA VRIJEDNOST OBJEKTA LEASINGA' ELSE 'RATA' END AS txtOpis,
	CASE WHEN a.id_val = 'HRK' THEN 'KN' ELSE a.id_val END AS id_val
	, min(a.datum_dok) over () as min_datum_dok
From dbo.planp a
Left Join dbo.vrst_ter v on a.id_terj = v.id_terj
Where a.id_cont = @id_cont
and v.sif_terj = 'LOBR' 
and a.datum_dok > @ddv_date



select name , database_id from sys.databases where name = 'nova_test'
select * from sys.objects where name = 'dokument'

select TableName=object_name(dm.object_id)
       ,IndexName=i.name
       ,IndexType=dm.index_type_desc
       ,[%Fragmented]=avg_fragmentation_in_percent   ,dm.fragment_count      ,dm.page_count      ,dm.avg_fragment_size_in_pages     
,dm.record_count     ,dm.avg_page_space_used_in_percent  from 
sys.dm_db_index_physical_stats(10,1974298093,null,null,'SAMPLED') dm 
--Here 14 is the Database ID 
--And 420770742 is the Object ID of the table
join sys.indexes i on dm.object_id=i.object_id and
dm.index_id=i.index_id   order by avg_fragmentation_in_percent desc


NOVA_TEST 3.7.2024

<?xml version='1.0' encoding='utf-8'?>
<render_report2  xmlns='urn:gmi:nova:core'>
<wait_to_finish>false</wait_to_finish>
<return_rendered_data>true</return_rendered_data>
<return_data_to_memory>false</return_data_to_memory>
<document>
<report_name>FAK_LOBR_SSOFT_RLC</report_name>
<object_id>20230055443</object_id>
<rendering_format>Pdf</rendering_format>
</document>
<document>
<report_name>FAK_LOBR_SSOFT_RLC</report_name>
<object_id>20230061850</object_id>
<rendering_format>Pdf</rendering_format>
</document>
<document>
<report_name>FAK_LOBR_SSOFT_RLC</report_name>
<object_id>20230000070</object_id>
<rendering_format>Pdf</rendering_format>
</document>
<document>
<report_name>FAK_LOBR_SSOFT_RLC</report_name>
<object_id>20230000071</object_id>
<rendering_format>Pdf</rendering_format>
</document>
<document>
<report_name>FAK_LOBR_SSOFT_RLC</report_name>
<object_id>20230028407</object_id>
<rendering_format>Pdf</rendering_format>
</document>
<document>
<report_name>FAK_LOBR_SSOFT_RLC</report_name>
<object_id>20230035387</object_id>
<rendering_format>Pdf</rendering_format>
</document>
<document>
<report_name>FAK_LOBR_SSOFT_RLC</report_name>
<object_id>20230000075</object_id>
<rendering_format>Pdf</rendering_format>
</document>
<document>
<report_name>FAK_LOBR_SSOFT_RLC</report_name>
<object_id>20230006979</object_id>
<rendering_format>Pdf</rendering_format>
</document>
<document>
<report_name>FAK_LOBR_SSOFT_RLC</report_name>
<object_id>20230000077</object_id>
<rendering_format>Pdf</rendering_format>
</document>
<document>
<report_name>FAK_LOBR_SSOFT_RLC</report_name>
<object_id>20230006985</object_id>
<rendering_format>Pdf</rendering_format>
</document>
<print_settings><skip_preview>false</skip_preview>
</print_settings></render_report2>