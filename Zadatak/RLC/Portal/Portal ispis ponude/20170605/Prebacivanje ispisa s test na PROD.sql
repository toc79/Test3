begin tran
INSERT INTO dbo.arh_rep_Report(archive_time,id,id_entity,name,description,inactive,sort_order,report_condition, report_file, report_type,last_change) 
select getdate(), id,id_entity,name,description,inactive,sort_order, report_condition, report_file, report_type, last_change FROM dbo.rep_Report WHERE id_entity = 'CalcOffer'
UPDATE dbo.rep_Report SET report_file = (SELECT report_file FROM dwc_test.[dbo].[rep_Report] WHERE id_entity = 'CalcOffer'), last_change = getdate() where id_entity = 'CalcOffer'
--commit