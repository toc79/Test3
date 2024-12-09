DECLARE @id int = 2486--344

DECLARE @comment varchar(max), @komentar varchar(max)

SET @komentar = ''

DECLARE tmp_history CURSOR FOR
SELECT comment
FROM dbo.WF_History
WHERE id_document = (SELECT top 1 d.id_document 
	FROM dbo.odobrit o 
	LEFT JOIN dbo.WF_Document D ON O.id_odobrit = D.foreign_document
	WHERE o.id_odobrit = @id)
AND comment IS NOT NULL 
AND ltrim(rtrim(REPLACE(REPLACE(REPLACE(comment, CHAR(10), ''), CHAR(13), ''), CHAR(9), ''))) != ''
ORDER BY id_history DESC
OPEN tmp_history 
FETCH NEXT FROM tmp_history INTO @comment
WHILE @@FETCH_STATUS = 0 
BEGIN
	 SET @komentar =  @komentar + ltrim(rtrim(@comment)) + CHAR(10) + CHAR(13)
FETCH NEXT FROM tmp_history INTO @comment
END
CLOSE tmp_history
DEALLOCATE tmp_history

SELECT @komentar AS komentar
