-------------------------------------------------------
-- This view gets data from p_eval where eval_type = 'E'
-- 
-- History:
-- 23.02.2010 Natasa; created;
-- 01.04.2010 Vilko; added field id_p_eval
-- 13.09.2010 Ziga; MID 26836 - added fields kategorija1, kategorija2, kategorija3
-- 05.07.2011 Franci; MID 30687 - added field opombe
-- 10.04.2014 Jelena; Task ID 7796 - because it is supported of more evaluation of type E for partner per day - added inner join
-- 09.12.2014 Jelena; Task ID 48660 - refactoring by Gemicro; into main select added WHERE p.eval_type = 'E'
-- 17.03.2015 Domen; MID 50175 - Added kategorija4, kategorija5, kategorija6
-------------------------------------------------------
CREATE VIEW [dbo].[gv_p_eval]
AS
SELECT 
		   p.id_kupca,
		   p.dat_eval,
		   p.datum_bil,
		   p.limita,
		   p.tec_limite,
		   p.eval_model,
		   p.cust_ratin,
		   p.coll_ratin,
		   p.oall_ratin,
		   p.asset_clas,
		   p.vnesel,
		   p.dat_vnosa,
		   p.id,
		   p.dat_nasl_vred,
		   p.ext_id,
		   p.ext_id_type,
		   p.eval_type,
		   p.id_p_eval,
		   p.kategorija1,
		   p.kategorija2,
		   p.kategorija3,
		   p.kategorija4,
		   p.kategorija5,
		   p.kategorija6,
		   p.opombe
	   FROM dbo.p_eval p
	   INNER JOIN (SELECT id_kupca, dat_eval, max(id_p_eval) as id_p_eval
				   FROM dbo.p_eval
				   WHERE eval_type = 'E'
				   GROUP BY id_kupca, dat_eval) E ON E.id_p_eval = P.id_p_eval
		WHERE p.eval_type = 'E'