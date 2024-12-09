select  a.id_dog Br_dogadaja, a.id_kupca Šif_partnera, b.naz_kr_kup Naziv_partnera
, c.id_pog Br_ugovora, c.pred_naj Predmet_najma
, dbo.gfn_GetUserDesc(a.OBDELUJE) Obraduje
, a.id_tip_dog, T.opis AS Tip_događaja
, a.dat_vnosa Datum_unosa_događaja, a.dat_poprave Datum_popravka_događaja, a.DOLG_DAT_D Dug_na_datum
, a.plac_dogov Dogovoreni_iznos, dbo.gfn_xchange ('006', a.plac_dogov, '000', a.dat_poprave ) AS Okvirni_iznos_u_HRK_dat_popravka
, dbo.gfn_xchange ('006', a.plac_dogov, '000', a.dat_vnosa) AS Okvirni_iznos_u_HRK_datum_unosa
--,* 
from SS_DOGODEK a
left join PARTNER b ON a.id_kupca = b.id_kupca
left join pogodba c on a.id_cont = c.id_cont
INNER JOIN dbo.ss_tipi_dog AS T ON a.id_tip_dog = T.id_tip_dog 
where  a.plac_dogov > 0 --a.id_tip_dog = '05' 
AND (a.DAT_VNOSA > = '20161215' or a.dat_poprave >= '20161215')
order by a.id_dog

