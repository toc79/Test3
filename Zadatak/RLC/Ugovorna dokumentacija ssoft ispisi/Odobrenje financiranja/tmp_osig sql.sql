DECLARE @id int = 2486--344

DECLARE @opis varchar(100), @naz_kr_kup varchar(100), @ex_opis varchar(max)

SET @ex_opis = ''

DECLARE tmp_zavar CURSOR FOR
SELECT --Z.id_obl_zav, isnull(Z.id_kupca,'') as id_kupca,
	 isnull(D.opis,'') as opis
	, isnull(P.naz_kr_kup,'') as naz_kr_kup
FROM dbo.odobrit_zavar Z
LEFT JOIN dbo.partner P ON Z.id_kupca = P.id_kupca
LEFT JOIN dbo.dok D ON Z.id_obl_zav = D.id_obl_zav
WHERE Z.id_odobrit = @id

OPEN tmp_zavar 
FETCH NEXT FROM tmp_zavar INTO @opis, @naz_kr_kup
WHILE @@FETCH_STATUS = 0 
BEGIN
	 SET @ex_opis =  @ex_opis + ltrim(rtrim(@opis)) + ' - ' + ltrim(rtrim(@naz_kr_kup)) + CHAR(10) + CHAR(13)
FETCH NEXT FROM tmp_zavar INTO @opis, @naz_kr_kup
END
CLOSE tmp_zavar
DEALLOCATE tmp_zavar

SELECT @ex_opis AS opis
