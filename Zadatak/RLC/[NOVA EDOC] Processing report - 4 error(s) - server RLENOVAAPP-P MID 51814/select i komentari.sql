Poštovani, 

greška se desilo kod sljedeća 4 dokumenta 
'Contract_83784_2023_12_07_11_17_10_336.pdf'
'Contract_83784_2023_12_07_11_19_05_247.pdf'
'Contract_83787_2023_12_07_11_38_01_531.pdf'
'Contract_83787_2023_12_07_11_39_46_456.pdf' 

koje se odnose na ispise 
NALOG ZA PLAĆANJE
PLAN OTPLATE - Stimulsoft 

za ugovore 
74811/23 (id 83784)
74814/23 (id 83787)
koji su obrisani. 





select top 10 * from dbo.reports_log where edoc_file_name = 'Contract_83784_2023_12_07_11_17_10_336.pdf'
select top 10 * from dbo.reports_log where edoc_file_name = 'Contract_83784_2023_12_07_11_19_05_247.pdf'
select top 10 * from dbo.reports_log where edoc_file_name = 'Contract_83787_2023_12_07_11_38_01_531.pdf'
select top 10 * from dbo.reports_log where edoc_file_name = 'Contract_83787_2023_12_07_11_39_46_456.pdf' 

declare @id_reports_log int
set @id_reports_log = (SELECT id_reports_log FROM dbo.reports_log WHERE edoc_file_name = 'Contract_83787_2023_12_07_11_39_46_456.pdf' and doc_type = 'Contract' and id_object_edoc = 83787)

SELECT * FROM dbo.reports_log WHERE edoc_file_name = 'Contract_83787_2023_12_07_11_39_46_456.pdf' and doc_type = 'Contract' and id_object_edoc = 83787

select * from pogodba where id_cont in (83784, 83787)

select * from pogodba_deleted where id_cont in (83784, 83787)

select * from dbo.print_selection where REP_KEY in ( 'NAL_PL_SSOFT_RLC','PLANP_SSOFT_RLC')