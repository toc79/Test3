DECLARE @id varchar(100) = 1827

DECLARE @lista varchar(max)
SET @lista = (Select value from dbo.GENERAL_REGISTER Where ID_REGISTER = 'RLC Reporting list' and id_key = 'RLC_KROV_INST_OSIG' and neaktiven = 0) 

SELECT 
	part.naz_kr_kup, part.ulica_sed, part.id_poste_sed, part.mesto_sed, drzave.ime AS drzava_ime
	, a.id_frame, dat_odobritve
	, dok.opis AS dok_opis, dok.kolicina AS dok_kolicina
FROM dbo.frame_list a
INNER JOIN dbo.partner part ON a.id_kupca = part.id_kupca
LEFT JOIN dbo.poste ON poste.id_poste = part.id_poste_sed
LEFT JOIN dbo.drzave ON drzave.drzava = poste.drzava 
LEFT JOIN (SELECT id_frame, opis, kolicina FROM dbo.dokument WHERE id_obl_zav IN (SELECT id FROM dbo.gfn_GetTableFromList(@lista)) ) dok ON a.id_frame = dok.id_frame 
WHERE a.id_frame = @id



INSERT INTO dbo.REPORT_ID_OBJECT_TYPES (id_object_type, description, GDPR_customers_select) 
VALUES('frame_list', 'Logiranje ispisa partnera okvira', 'DECLARE @id_frame int
SET @id_frame = ''{0}''

SELECT r.id_kupca as ID_KUPCA, 
	   p.vr_osebe as VRSTA_OSEBE, 
	   ''Ispis okvira'' as ADDITIONAL_DESC
FROM dbo.frame_list r 
INNER JOIN dbo.partner p on r.id_kupca = p.id_kupca 
WHERE r.id_frame = @id_frame')


DECLARE @id_frame int
SET @id_frame = '{0}'

SELECT r.id_kupca as ID_KUPCA, 
	   p.vr_osebe as VRSTA_OSEBE, 
	   'Ispis okvira' as ADDITIONAL_DESC
FROM dbo.frame_list r 
INNER JOIN dbo.partner p on r.id_kupca = p.id_kupca 
WHERE r.id_frame = @id_frame




select * from REPORT_ID_OBJECT_TYPES


DECLARE @ddv_id char(14)
SET @ddv_id = '{0}'

SELECT r.id_kupca as ID_KUPCA, 
	   p.vr_osebe as VRSTA_OSEBE, 
	   r.OPISDOK as ADDITIONAL_DESC
FROM
	  dbo.rac_out r 
	  INNER JOIN dbo.partner p on r.id_kupca = p.id_kupca 
	  WHERE r.ddv_id = @ddv_id

	  
	  
DECLARE @id_najem_ob int
SET @id_najem_ob = '{0}'

SELECT r.id_kupca as ID_KUPCA, 
	   p.vr_osebe as VRSTA_OSEBE, 
	   'Ispis obavijesti za rate' as ADDITIONAL_DESC
FROM
	  dbo.pft_Print_NoticeForInstallments(getdate()) r 
	  INNER JOIN dbo.partner p on r.id_kupca = p.id_kupca 
	  WHERE r.id_najem_ob = @id_najem_ob
	  
	  DECLARE @id_kupca char(6)
SET @id_kupca = '{0}'
SELECT p.id_kupca as id_kupca,
 p.vr_osebe as vrsta_osebe,
 'Ispis prema partneru' as additional_desc
FROM 
 dbo.partner p
 WHERE p.id_kupca = @id_kupca