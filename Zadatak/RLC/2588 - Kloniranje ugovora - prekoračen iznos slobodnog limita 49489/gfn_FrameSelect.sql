-------------------------------------------------------------------------------------------------------------------------------------------  
-- Function: returns a record from frames for given id_kupca and for guarantor if it is marked and for connected partners if it is marked  
  
-- History:  
-- 20.03.2018 Jelena; MID 68161 - created  
-- 30.03.2018 Jelena; MID 68161 - added param @list_id_poroka  
-- 07.10.2019 Jelena; BID 37720 - correct date condition for field velja_do - called function dbo.gfn_GetDatePart for GETDATE()  
-------------------------------------------------------------------------------------------------------------------------------------------  
  
CREATE FUNCTION [dbo].[gfn_FrameSelect]   
(  
 @id_kupca char(6),   
 @tip_vnosne_maske int,  
 @id_frame_original int = null,  
 @id_cont int = null,  
 @list_id_poroka varchar(100)   
)    
  
RETURNS table   
AS    
RETURN (  
 SELECT l.id_frame, l.opis, l.id_kupca, l.dat_odobritve, l.status_akt, t.sif_frame_type, l.velja_do, l.dat_izteka  
 FROM dbo.frame_list l  
 INNER JOIN frame_type t ON l.frame_type = t.id_frame_type   
 WHERE   
   t.sif_frame_type IN ('POG', 'REV', 'NET', 'RFO', 'RNE', 'MPC')  
   AND l.status_akt != 'Z'  
   AND (l.velja_do IS NULL OR l.velja_do >= dbo.gfn_GetDatePart(GETDATE()))   
   AND (l.id_kupca = @id_kupca OR (l.ali_pov_part = 1 AND l.id_kupca in (select id_kupca from dbo.gfn_PovPartGetConnectedPartnersMultilevel(@id_kupca)))  
     OR (l.ali_porok = 1 and l.id_kupca in (select id from dbo.gfn_split_ids(@list_id_poroka, ',')))  
    OR (@tip_vnosne_maske = 2 and l.ali_porok = 1 and l.id_kupca in (select id_poroka from dbo.POG_PORO WHERE ID_CONT = @id_cont)))  
   OR (@tip_vnosne_maske != 1 AND id_frame = @id_frame_original)  
)  