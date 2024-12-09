select * from dbo.queue_pending where id in (
545977, 545979, 545981, 545982, 545985, 545987, 545989, 545991, 545993, 545995, 545997, 545999, 546001, 546002, 546004, 546006, 546007, 546009, 546010, 546012, 546020
) 

begin tran
delete from dbo.queue_pending where id in (
545977, 545979, 545981, 545982, 545985, 545987, 545989, 545991, 545993, 545995, 545997, 545999, 546001, 546002, 546004, 546006, 546007, 546009, 546010, 546012, 546020
) 
--rollback
--commit


(21 rows affected)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(545977,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007371</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:07PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:11PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:11PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(545979,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007373</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:07PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:11PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(545981,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007375</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:07PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:11PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(545982,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007377</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:07PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:11PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(545985,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007379</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:07PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:11PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(545987,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007381</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:07PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:11PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(545989,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007383</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:07PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:11PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(545991,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007385</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:08PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:12PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(545993,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007387</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:08PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:12PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(545995,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007389</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:08PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:12PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(545997,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007391</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:08PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:12PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(545999,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007393</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:08PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:12PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(546001,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007395</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:08PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:12PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(546002,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007397</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:08PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:12PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(546004,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007399</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:08PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:12PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(546006,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007401</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:08PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:12PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(546007,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007403</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:08PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:12PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(546009,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007405</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:08PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:12PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(546010,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007407</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:08PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:12PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(546012,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007409</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:08PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:12PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)
INSERT INTO dbo.queue_pending(id,xml_cmd,inserted_at,priority,resolved,resolved_when,resolved_who,resolved_msg,status,processing_started,processing_ended,processing_result,error_msg,session_info,ignore_after,error_after,not_before,inserted_by,server_name,retry_count,retry_interval,retry_count_current,retry_time) VALUES(546020,'<?xml version="1.0" encoding="utf-16"?>
<render_report xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:gmi:nova:core">
  <report_name>ERROR</report_name>
  <object_id>N2023007412</object_id>
  <rendering_format>Mdc</rendering_format>
  <return_rendered_data>false</return_rendered_data>
</render_report>','Aug 11 2023  3:08PM',0,0,NULL,NULL,NULL,'E','Aug 11 2023  3:12PM','Aug 11 2023  3:12PM',NULL,'GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> GMI.Core.GMI_Exception: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports ---> System.ArgumentException: No data found with specified id: error, class = GMI.Core.Data.Tab_Reports
   at GMI.Core.Data.BaseTableWrapper.Load(IDataProvider provider, String column_name, Object id)
   at GMI.Core.ReportCache.LoadReportIfNeeded(String report_name)
   at GMI.Core.ReportCache.FindReport(String report_name)
   at GMI.Core.GMI_ReportRenderer2.TryTextRenderers()
   at GMI.Core.GMI_ReportRenderer2.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_LegoObject.Run()
   at GMI.Core.GMI_ReportRenderer.RunBl()
   at GMI.Core.GMI_LegoObject.Run()
   --- End of inner exception stack trace ---
   at GMI.Core.GMI_','240c514e-f08d-49d5-b628-0ee041fbab48',NULL,NULL,'Aug 11 2023  3:12PM','sanjam','RLENOVAAPP-P',NULL,1800000,NULL,NULL)

Completion time: 2023-08-14T12:55:30.6811621+02:00
