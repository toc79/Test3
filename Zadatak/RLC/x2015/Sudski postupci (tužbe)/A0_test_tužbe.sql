begin tran
SET IDENTITY_INSERT dbo.ss_postopek ON

INSERT INTO dbo.ss_postopek(id_ss_postopek, id_kupca,dat_post,id_tip_post,id_status_post,sodisce,sodnik,odvetnik,opravilna_st,znesek_post,dat_vnosa,vnesel,obdeluje,int_id_ss_postopek,opombe) VALUES('89','000448','Jul 26 2004 12:00AM','000',NULL,'','','O.D. ETEROVIÆ','',0.00,'Jul 26 2004 12:00AM','ivam','nadaf','','')
INSERT INTO dbo.ss_postopek(id_ss_postopek, id_kupca,dat_post,id_tip_post,id_status_post,sodisce,sodnik,odvetnik,opravilna_st,znesek_post,dat_vnosa,vnesel,obdeluje,int_id_ss_postopek,opombe) VALUES('287','000448','Jul 26 2004 12:00AM','000',NULL,'','','O.D. ETEROVIÆ','',0.00,'Jul 26 2004 12:00AM','ivam','nadaf','','')
INSERT INTO dbo.ss_postopek(id_ss_postopek, id_kupca,dat_post,id_tip_post,id_status_post,sodisce,sodnik,odvetnik,opravilna_st,znesek_post,dat_vnosa,vnesel,obdeluje,int_id_ss_postopek,opombe) VALUES('290','000448','Jul 26 2004 12:00AM','000',NULL,'','','O.D. ETEROVIÆ','',0.00,'Jul 26 2004 12:00AM','ivam','nadaf','','')

SET IDENTITY_INSERT dbo.ss_postopek OFF

select * from ss_postopek
--rollback
