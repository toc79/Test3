select * from dbo.io_channels where channel_code = 'FINANCIAL_STATEMENT'
--exec dbo.Tsp_generate_inserts @t_name = 'io_channels', @where_stmt = 'where channel_code = ''FINANCIAL_STATEMENT'''
select * from ##inserts
--INSERT INTO dbo.io_channels(channel_code,channel_desc,channel_path,channel_file_name,channel_is_output,channel_encoding,channel_group,channel_extra_params) VALUES('FINANCIAL_STATEMENT','Export and import of financial statements','c:\temp\','bilance.xlt',1,'<NULL>','<NULL>','<NULL>')
select * from dbo.CUSTOM_SETTINGS where code = 'Nova.Fox.UseGmiTmpDirectory'
select BILAN_RESULT_ONLY, * from dbo.gl_nastavit
--update dbo.GL_NASTAVIT set BILAN_RESULT_ONLY = 1



lcXLT_NAME = "C:\temp\BILANCE.XLT"
oExcel = CREATEOBJECT("Excel.Application")
oExcel.Workbooks.Add(lcXLT_NAME)

lcVersion = oExcel.Version
? lcVersion

oExcel.ActiveWorkbook.Close(.F.)