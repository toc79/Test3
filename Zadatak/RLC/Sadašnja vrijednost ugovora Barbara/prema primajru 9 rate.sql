-- ALTER   FUNCTION [dbo].[gfn_PresentValueInterest] 
-- (
DECLARE @var_Znesek decimal(18,2) = 6624.45 ,
@var_Procent decimal(18,4) = 2.77,
@var_Od datetime = '2020-05-31',
@var_Do datetime = '2021-02-01'
-- )  

-- RETURNS decimal(18,2) AS  

-- BEGIN 

	DECLARE @var_Dni int
	DECLARE @var_Leto int
	DECLARE @var_LetoDni int
	DECLARE @var_DniObracun int
	DECLARE @var_ZacetekLeta datetime
	DECLARE @var_KonecLeta datetime
	DECLARE @var_Suma decimal(18,6)
	DECLARE @var_ObdobjeDni int
	DECLARE @result decimal(18,2)
	
	DECLARE @var_ZacetekObdobja datetime
	DECLARE @var_KonecObdobja datetime
	
	SET @var_Dni=DATEDIFF(dd,@var_Od,@var_Do)
	SET @var_Leto=DATEPART(yyyy,@var_Od)
	
	SET @var_ZacetekLeta = CAST(cast(@var_Leto as varchar(4))+ '0101' as datetime)
	SET @var_KonecLeta = CAST(cast((@var_Leto)+1 as varchar(4)) + '0101' as datetime)
	SET @var_LetoDni=DATEDIFF(dd,@var_ZacetekLeta, @var_KonecLeta)
	
	SET @var_Suma=@var_Znesek
	
	
	SET @var_ZacetekObdobja = @var_Od
	
	IF @var_Dni < (DATEDIFF(dd,@var_Od,@var_KonecLeta)-1)
		BEGIN
		SET @var_KonecObdobja = @var_Do
		END
	ELSE
		BEGIN
		SET @var_KonecObdobja = @var_KonecLeta
		END
	
	WHILE @var_Dni>0
	BEGIN
	
		SET @var_ObdobjeDni = DATEDIFF(dd,@var_ZacetekObdobja,@var_KonecObdobja)
		SET @var_Suma = ((CAST(@var_Suma as decimal(18,6))) / (POWER((1 + CAST(@var_Procent as decimal(18,6))/100),(CAST(@var_ObdobjeDni as decimal(18,6))/CAST(@var_LetoDni as decimal(18,6))))))
		
--		PRINT CAST(@var_ZacetekObdobja as varchar) + ' --> ' + CAST(@var_KonecObdobja as varchar)
--		PRINT 'Dni: ' + CAST(@var_Dni as varchar) + ' - Dni v obdobju: ' + CAST(@var_ObdobjeDni as varchar) + ' - Dni v letu: ' + CAST(@var_LetoDni as varchar) +  ' - Suma: ' + CAST(@var_Suma as varchar)

		SET @var_Dni = @var_Dni - DATEDIFF(dd,@var_ZacetekObdobja,@var_KonecObdobja)
		SET @var_Leto = DATEPART(yyyy,@var_KonecObdobja+1) --naslednje leto
		
		SET @var_ZacetekLeta = CAST(cast(@var_Leto as varchar(4))+ '0101' as datetime)
		SET @var_KonecLeta = CAST(cast((@var_Leto + 1) as varchar(4)) + '0101' as datetime)
		SET @var_LetoDni = DATEDIFF(dd,@var_ZacetekLeta, @var_KonecLeta)


		
		SET @var_ZacetekObdobja = @var_ZacetekLeta
		
		IF @var_Dni < @var_LetoDni
			BEGIN
			SET @var_KonecObdobja = @var_Do
			END
		ELSE
			BEGIN
			SET @var_KonecObdobja = @var_KonecLeta
			END
	END
	
	SET @result = round(@var_Suma, 2)
	RETURN @result