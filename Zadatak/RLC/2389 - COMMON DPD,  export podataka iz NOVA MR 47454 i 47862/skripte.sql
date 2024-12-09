select * from dbo.io_channels

--Ako se podesi TRUE onda se pripremio i za PK (primary key)
exec dbo.tsp_generate_inserts 'io_channels', 'dbo', 'FALSE', '##inserts', 'where channel_code=''XDOC_REGIST'''
select * from ##inserts
--drop table ##inserts

INSERT INTO dbo.io_channels(channel_code,channel_desc,channel_path,channel_file_name,channel_is_output,channel_encoding,channel_group,channel_extra_params) 
VALUES('XDOC_COMMON_DPD','Export COMMON DPD to CSV','\\rlenovaapp-t\NOVA_TEST_IO\COMMON DPD\Za RBA','',1,'utf-8','XDOC',NULL)

--produkcija
INSERT INTO dbo.io_channels(channel_code,channel_desc,channel_path,channel_file_name,channel_is_output,channel_encoding,channel_group,channel_extra_params) 
VALUES('XDOC_COMMON_DPD','Export COMMON DPD to CSV','\\rlefs-p\Shares\TRANSFER\COMMON DPD','',1,'utf-8','XDOC',NULL)

