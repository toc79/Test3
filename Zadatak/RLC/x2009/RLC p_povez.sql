begin tran

INSERT INTO p_povez VALUES ('U2','Upravljačka: B je podružnica od A','0','','')
--UPDATE p_povez SET je_obratna=1 where tip_pov='U2'
SELECT * FROM P_POVEZ
--commit
--rollback

