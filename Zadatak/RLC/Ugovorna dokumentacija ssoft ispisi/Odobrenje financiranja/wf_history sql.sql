DECLARE @id int = 2486--344

SELECT a.id_history, a.id_document, a.date_entered, a.date_started
	, a.date_planned, a.date_ended, a.user_entered, a.user_old
	, a.user_new, a.id_status_old, a.id_status_new, a.comment
	, a.sys_data, a.sys_flag, a.status_date
	, status_old.title AS status_old_title
	, status_new.title AS status_new_title
	, user_entered.user_desc AS user_entered_user_desc
FROM dbo.WF_History a
LEFT JOIN dbo.WF_Status status_old ON a.id_status_old = status_old.id_status
LEFT JOIN dbo.WF_Status status_new ON a.id_status_new = status_new.id_status
LEFT JOIN dbo.users user_entered ON a.user_entered = user_entered.username
WHERE id_document = (
	SELECT top 1 d.id_document 
	FROM dbo.odobrit o 
	LEFT JOIN dbo.WF_Document D ON O.id_odobrit = D.foreign_document
	WHERE o.id_odobrit = @id)
ORDER BY a.id_history DESC