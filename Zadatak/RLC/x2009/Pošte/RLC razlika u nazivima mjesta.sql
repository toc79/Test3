select a.[id_kupca]
      ,a.[naz_kr_kup]

      ,a.[id_poste],a.[mesto], b.[id_poste],b.naziv
      
	,a.[id_poste_k],a.[ulica_k]
      
      ,a.[id_poste_sed],a.mesto_sed
      
      ,a.[id_poste_d],a.[mesto_d]
      
      
      FROM [dbo].[PARTNER] a 
	inner join poste b
	on a.id_poste=b.id_poste where a.[mesto]!=b.naziv
       AND LEFT(id_poste,2)!='HR'