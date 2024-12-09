begin tran
UPDATE kred_pog set tip_pog = 2, status_akt = 'A', id_krov_pog = '0180 16', dat_aktiv = '2016-12-21', krov_pog_val_znes = val_znes, dat_poprave = getdate() 
--output inserted.*, deleted.*
where id_kredpog = '0236 20'
--select tip_pog, status_akt , id_krov_pog , dat_aktiv, krov_pog_val_znes, dat_poprave , val_znes, * from kred_pog where id_kredpog = '0236 20'
--rollback
--commit

--dat_aktiv je s krovnog ugovora 0180 16