--USE [Nova_hls]
--GO
--/****** Object:  Trigger [dbo].[POROCILA_IUD]    Script Date: 10.03.2020. 14:43:16 ******/
--SET ANSI_NULLS OFF
--GO
--SET QUOTED_IDENTIFIER ON
--GO

CREATE TRIGGER [dbo].[POROCILA_IUD] ON [dbo].[POROCILA] 
	FOR INSERT, UPDATE, DELETE 
	AS
	
	 IF (SELECT count(*) FROM inserted)>0 
	BEGIN	
		IF (SELECT count(*) FROM deleted)>0	 /* UPDATE*/		
		BEGIN
			INSERT INTO dbo.ARH_POROCILA 
			SELECT @@spid,getdate(),'U', * 
			FROM inserted
		END
		ELSE /* INSERT*/
		BEGIN
			INSERT INTO dbo.ARH_POROCILA 
			SELECT @@spid,getdate(),'I', * 
			FROM inserted
		END
	END
	ELSE /*  DELETE */
	BEGIN
		INSERT INTO dbo.ARH_POROCILA 
		SELECT @@spid,getdate(),'D', * 
		FROM deleted
	END
GO

ALTER TABLE [dbo].[POROCILA] ENABLE TRIGGER [POROCILA_IUD]
GO


