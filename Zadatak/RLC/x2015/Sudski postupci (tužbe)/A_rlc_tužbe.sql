begin tran
--BACK UP  SS_TPOGODBA, SS_TPLANP I SS_TDOGODKI
SELECT *
into #_ss_tpogodba_tmp
FROM nova_prod.dbo.SS_TPOGODBA

SELECT *
into #_ss_tplanp_tmp
from nova_prod.dbo.ss_tplanp

CREATE TABLE dbo._ss_tdogodki_tmp (
	--[ID_SS_TDOGODKI] int NOT NULL,
      [ID_CONT] int NOT NULL
      ,[OPRAVIL_ST] char(20) NOT NULL
      ,[DATUM] datetime NOT NULL
      ,[VNESEL] char(10) NOT NULL
      ,[DEBIT] decimal(18,2) NOT NULL
      ,[ID_OPIS] char(3) NOT NULL
      ,[OPIS] varchar (1000) NOT NULL
      ,[ST_DOK] char(21) NOT NULL
      ,[ID_PLAC] int NOT NULL
      ,[OBDELAL] bit NOT NULL
      ,[KREDIT] decimal(18,2) NOT NULL
      ,[TIP_DOGOD] char(4) NOT NULL
      ,[VRS_PLAC] char(3) NOT NULL
      ,[DAT_PLAC] datetime NULL
      ,[AVTOM] bit NOT NULL
      ,[rok] datetime NULL
      ,[status] char(10) NOT NULL
      ,[id_ss_postopek] int NOT NULL
) ON [PRIMARY]
INSERT INTO _ss_tdogodki_tmp (ID_CONT,OPRAVIL_ST,DATUM,VNESEL,DEBIT,ID_OPIS,OPIS,ST_DOK,ID_PLAC,OBDELAL,KREDIT,TIP_DOGOD,VRS_PLAC,DAT_PLAC,AVTOM,rok,status,id_ss_postopek)
SELECT ID_CONT,OPRAVIL_ST,DATUM,VNESEL,DEBIT,ID_OPIS,OPIS,ST_DOK,ID_PLAC,OBDELAL,KREDIT,TIP_DOGOD,VRS_PLAC,DAT_PLAC,AVTOM,rok,status,id_ss_postopek FROM nova_prod.dbo.ss_tdogodki

DELETE FROM ss_tdogodki
DELETE FROM ss_tplanp
DELETE FROM ss_tpogodba

--rollback
--SLJEDEÆI KORAK JE UPDATE SS_POSTOPEK (2_RLC_update_postupka.sql)