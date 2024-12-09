-- 15.09.2021 g_tomislav MID 47528 - removing hardcode id_xdoc_template = 22 with variable 

DECLARE @id_xdoc_template int = {@id_template}

select cast(id_history as char(30)) as doc_id
from dbo.wf_history 
WHERE date_entered >= (select ISNULL(max(date_inserted),getdate()-1) as max_date_inserted from dbo.xdoc_run_history Where status='C' and id_xdoc_template = @id_xdoc_template)