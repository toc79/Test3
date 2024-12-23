begin tran
CREATE TABLE dbo._ss_postopek_tmp (
	[id_ss_postopek] int  NOT NULL
      ,[id_kupca] char(6) NOT NULL
      ,[dat_post] datetime NULL
      ,[id_tip_post] char (3) NOT NULL
      ,[id_status_post] char (3) NULL
      ,[sodisce] varchar (100) NOT NULL
      ,[sodnik] varchar (100) NOT NULL
      ,[odvetnik] varchar (100) NOT NULL
      ,[opravilna_st] char (20) NOT NULL
      ,[znesek_post] decimal (18,2) NOT NULL
      ,[opombe] text NOT NULL
      ,[dat_vnosa] datetime NOT NULL
      ,[vnesel] char(10) NOT NULL
      ,[obdeluje] char(10) NOT NULL
      ,[int_id_ss_postopek] char(10) NOT NULL
) ON [PRIMARY]

INSERT INTO _ss_postopek_tmp
select * from ss_postopek

UPDATE ss_postopek SET id_kupca=b.id_kupca, dat_post=b.dat_post, id_tip_post=b.id_tip_post, id_status_post=b.id_status_post, sodisce=b.sodisce, sodnik=b.sodnik, odvetnik=b.odvetnik, opravilna_st=b.opravilna_st, znesek_post=b.znesek_post, opombe=b.opombe, dat_vnosa=b.dat_vnosa, vnesel=b.vnesel, obdeluje=b.obdeluje, int_id_ss_postopek=b.int_id_ss_postopek FROM ss_postopek a
inner join _ss_postopek_tmp b on a.id_ss_postopek='1' --koji postupak će se UPDATE-ati
where b.id_ss_postopek='2' --prema kojemu postupku(starome)

select * from ss_postopek
select * from _ss_postopek_tmp
--rollback
Begin tran
UPDATE ss_postopek SET ss_postopek.znesek_post='38735.99' where id_ss_postopek='1'
