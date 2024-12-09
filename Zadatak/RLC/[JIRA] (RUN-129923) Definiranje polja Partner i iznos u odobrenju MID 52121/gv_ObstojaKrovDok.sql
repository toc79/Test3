/*--------------------------------------------------------------------------------------------------------
 View: used for searching documentation select for documentation collection preview
 History:
26.03.2018 MatjazB; Task 13002 - created
06.05.2024 MitjaM; MID 130876 - added vrednost
--------------------------------------------------------------------------------------------------------*/

CREATE VIEW [dbo].[gv_ObstojaKrovDok]
AS
select
    d.id_dokum, 
    case 
        when d.id_krov_dok is not null then rtrim(ltrim(d.opis)) + ' (' + cast(d.id_krov_dok as varchar(20)) + ')'
        else d.opis
    end as opis,
    d.id_kupca as id_kupca_dok, 
    case 
        when fl.id_kupca is not null then fl.id_kupca
        when kp.id_kupca is not null then kp.id_kupca
        when pog.id_kupca is not null then pog.id_kupca
        else null
    end as id_kupca_entity,
    case 
        when fl.id_kupca is not null then p1.naz_kr_kup
        when kp.id_kupca is not null then p2.naz_kr_kup
        when pog.id_kupca is not null then p3.naz_kr_kup
        else null
    end as naz_kr_kup_entity,
    fl.id_frame, fl.opis as opis_frame, 
    p.naz_kr_kup as naz_kr_kup_dok, 
    kp.id_krov_pog, kp.st_krov_pog, kp.opis_pog as opis_kp,
    d.VREDNOST
from
    dbo.dokument d
    left join dbo.frame_list fl on fl.id_frame = d.id_frame
    left join dbo.krov_pog kp on kp.id_krov_pog = d.id_krov_pog
    left join dbo.pogodba pog on pog.id_cont = d.id_cont
    left join dbo.partner p on p.id_kupca = d.id_kupca
    left join dbo.partner p1 on p1.id_kupca = fl.id_kupca
    left join dbo.partner p2 on p2.id_kupca = kp.id_kupca
    left join dbo.partner p3 on p3.id_kupca = pog.id_kupca

