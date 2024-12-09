select * 
from wf_history a
join (select id_document, max(id_history) as id_history_max from wf_history
group by id_document) b on a.id_document=b.id_document and a.id_history=b.id_history_max