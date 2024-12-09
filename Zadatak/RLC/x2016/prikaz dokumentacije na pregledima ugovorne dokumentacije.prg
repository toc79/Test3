Poštovani, 
za vrstu dokumenta OI je podešen Custom functionalities 
1385	904	CollectionDocumentationView	Dok_Nitko nema prava	OI	Odluka o izuzeću  nedostajuće dokumentacije	DocTypes
(na slici u prilogu) 
te se zato ne vidi na pregledu. 
Provjerili smo prikazivanje pdataak na pregledu u prethodnoj verziji 2.19 te je tamo ista logika, tj. da se provjerava pravo ContractDocumentationView i CollectionDocumentationView	 prilikom prikaza dokumentacije na pregledu.

Na pregledu Dokumentacije za ugovor se provjerava samo pravo  
ContractDocumentationView
iz custom 
pa se zato tamo prikazuje.




Dok z augovor
(3,_dokument)SELECT *, cast(0 as bit) AS nova_vrednost_ima FROM dbo.gv_Dokument WHERE id_cont = 52266 AND dbo.gfn_UserCanDo_CustomFuncsEx('g_tomislav', 'ContractDocumentationView', 'DocTypes', id_obl_zav ) > 0  ORDER BY vrst_red_d


--(3,rezultat)EXEC  dbo.grp_DocumentsAllContracts 0,0,'',1

Dok Sva ugovorna dokumentacija
--(3,rezultat)EXEC  dbo.grp_DocumentsAllContracts 0,0,'',1,'20160110','20160310',0,'',0,'',0,'',0,0,'',0,'',0,'19000101','19000101',0,0,0,0,'',0,'',0,'',0,'',0,'',0,0,'','',1,'g_tomislav' 
gfn_DocumentsAllContracts2


--(1,rezultat)EXEC  dbo.grp_DocumentsAllContracts 1,0,'',0,'','',1,'49383/16',0,'',0,'',0,0,'',0,'',0,'19000101','19000101',0,0,0,0,'',0,'',0,'',0,'',0,'',0,0,'','',1,'g_tomislav' 

--sp_helptext gfn_UserCanDo_CustomFuncsEx
-- g_tomislav
SELECT id_obl_zav
FROM dbo.Dok
WHERE 
--dbo.gfn_UserCanDo_CustomFuncsEx( 'anat', 'CollectionDocumentationView', 'DocTypes', id_obl_zav  ) > 0 
--  AND 
  dbo.gfn_UserCanDo_CustomFuncsEx( 'anat', 'ContractDocumentationView', 'DocTypes', id_obl_zav  ) > 0
  AND id_obl_zav='OI'
  order by 1

  select * from users where username in  ('anat' ,'dianab')

  SELECT * 
  FROM dbo.users_custom_funcs a 
  join functionalities b ON a.func_id= b.id
  where a.type='DocTypes' and a.keyid='OI'
order by username




