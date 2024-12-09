select * from gdpr_access_log order by Id_access_log desc
--select * from gdpr_access_log_details
select * from gdpr_access_log_details where id_access_log=742

Select [val] FROM dbo.CUSTOM_SETTINGS WHERE code='Nova.GDPR.ListOfCustomerTypesForAccessLog'
update dbo.CUSTOM_SETTINGS set val = 'F1,FO,SP,FR,R1,SR' WHERE code='Nova.GDPR.ListOfCustomerTypesForAccessLog'

