[12:33] Daniel Vrpoljac
ne možemo mi stornirati

[12:34] Tomislav Krnjak
još bolje, meni lakše

[12:34] Daniel Vrpoljac
to se mora provesti ručno ili im napisati možemo vidjeti da li možemo preko skripte, ali to do kraja tjedna da im možemo eventualno provjeriti
pa neka čekaju ako žele 4 dana

[12:35] Daniel Vrpoljac
napisati da do sada nismo to radili

Pozdrav, 

kod klijenta se desio slučaj da su se za jedan ugovor kreirale dvije opomene i to u slučaju kada na ugovoru imaju jednog neaktivnog glavnog jamca te aktivnog glavnog jamca, ponovio sam taj bug te vam šaljem slike (s lokalne baze/aplikacije).
Molimo popravak (trebalo bi popraviti funkciju gfn_IsMainGuarantor i/ili proceduru grp_GetReminderData).


11.08.2023 15:07:47:621	67	ProcessXmlAsync	Bl	[sanjam,10.239.106.90]	[240c514e-f08d-49d5-b628-0ee041fbab48,LE]	<issue_reminders xmlns='urn:gmi:nova:leasing'>  <with_costs>true</with_costs>  <list>18543038</list><list>18543038</list><list>18543039</list><list>18543039</list><list>18543040</list><list>18543040</list><list>18543041</list><list>18543041</list><list>18543042</list><list>18543042</list><list>18543043</list><list>18543043</list><list>18543053</list><list>18543053</list><list>18543054</list><list>18543054</list><list>18543055</list><list>18543055</list><list>18543056</list><list>18543056</list><list>18543057</list><list>18543057</list><list>18543058</list><list>18543058</list><list>18543047</list><list>18543047</list><list>18543048</list><list>18543048</list><list>18543049</list><list>18543049</list><list>18543050</list><list>18543050</list><list>18543051</list><list>18543051</list><list>18543052</list><list>18543052</list><list>18543044</list><list>18543044</list><list>18543045</list><list>18543045</list><list>18537877</list><list>18544009</list><list>18543046</list><list>18543046</list><list>18543267</list><list>18537954</list><list>18544057</list><list>18537982</list><list>18539803</list><list>18539804</list><list>18539933</list><list>18544093</list><list>18538182</list><list>18540385</list><list>18540383</list>  </issue_reminders>

select * from dbo.reports_log rl where rendered_when> '20230810' 
--and id_report = 'ERROR'
--and id_object = '18543038'
and exists (select * 
from dbo.planp pp 
where id_terj = '01'
and datum_dok = '20230811'
and not exists (select ddv_id from dbo.ZA_OPOM
			where  pp.ddv_id = DDV_ID
			union all
			select ddv_id from dbo.ARH_ZA_OPOM
			where  pp.ddv_id = DDV_ID) 
and rl.id_object_edoc = pp.ddv_id
	) 

select pp.id_kupca, dbo.gfn_Id_pog4Id_cont(id_cont) as Ugovor, pp.ddv_id as Broj_racuna, ST_DOK as Broj_dokumenta, * 
from dbo.planp pp 
where id_terj = '01'
and datum_dok = '20230811'
and not exists (select ddv_id from dbo.ZA_OPOM
			where  pp.ddv_id = DDV_ID
			union all
			select ddv_id from dbo.ARH_ZA_OPOM
			where  pp.ddv_id = DDV_ID) 

select * from dbo.reports_log where rendered_when> '20230810' 


SELECT                       
b.dav_obv, b.dav_stev, b.naz_kr_kup, a.nacin_leas, a.id_dav_st, c.id_kupca,                      
a.id_obrs, c.st_opomina, c.dok_opom, c.id_opom, a.id_pog, c.id_cont, c.ddv_id, d.sif_status,                      
a.status, c.saldo_val, c.zobr_val, c.poobl_odvzem, f.se_regis, c.id_tec, a.id_ref, c.cas_prip,       
c.zap_op, c.stros_op_val, c.po_opodpov, c.tec_opom,                      
(select top 1 id_zapo from dbo.zap_reg g where g.id_cont = a.id_cont order by g.id_zapo) as id_zapo,                      
f.tip_opr, a.izvoz, a.id_obrv, OL.status as status_op, c.oznacen_poro,                      
c.STROS_PORO, c.stros_lj 
, ol.*
, pr.*
--INTO   #tmp_reminder_data               
FROM   dbo.pogodba a 
INNER JOIN                    dbo.za_opom c ON a.id_cont = c.id_cont 
INNER JOIN                       dbo.partner b ON c.id_kupca = b.id_kupca 
INNER JOIN                       dbo.statusi d ON a.status = d.status 
INNER JOIN                      dbo.vrst_opr f on a.id_vrste = f.id_vrste 
INNER JOIN                       dbo.za_opom_log OL ON c.id_za_opom_log = OL.id_za_opom_log            
LEFT JOIN (SELECT COUNT(id_cont) as st, id_cont FROM dbo.pog_poro P WHERE neaktiven = 0 
	GROUP BY id_cont, ne_opominjaj HAVING ne_opominjaj = 0) PR ON PR.id_cont = c.id_cont          
INNER JOIN dbo.ZA_OPOM_TYPE ZT ON ZT.id_za_opom_type = c.id_za_opom_type                     
WHERE  c.id_opom in (18543038,18543038,18543039,18543039,18543040,18543040,18543041,18543041,18543042,18543042,18543043,18543043,18543053,18543053,18543054,18543054,18543055,18543055,18543056,18543056,18543057,18543057,18543058,18543058,18543047,18543047,18543048,18543048,18543049,18543049,18543050,18543050,18543051,18543051,18543052,18543052,18543044,18543044,18543045,18543045,18537877,18544009,18543046,18543046,18543267,18537954,18544057,18537982,18539803,18539804,18539933,18544093,18538182,18540385,18540383)               
ORDER BY c.id_cont; 


declare @ddv_id varchar(100) = 'N2023007372'
select * from dbo.rac_out where ddv_id = @ddv_id
select dbo.gfn_GetInvoiceSource(@ddv_id)
--select * from dbo.KLAVZULE_SIFR
select * from dbo.za_opom where ddv_id= @ddv_id 
select * from dbo.arh_za_opom where ddv_id= @ddv_id 
select * from dbo.planp where ddv_id= @ddv_id 

--select * from dbo.queue_pending

select * from dbo.rac_out where ddv_id = 'N2023007371'
select dbo.gfn_GetInvoiceSource('N2023007371')
--select * from dbo.KLAVZULE_SIFR
select * from dbo.za_opom where ddv_id= 'N2023007371' 
select * from dbo.arh_za_opom where ddv_id= 'N2023007371' 
select * from dbo.planp where ddv_id= 'N2023007371'
select * from dbo.za_opom where id_opom= 18543038
select * from dbo.arh_za_opom where ID_OPOM= 18543038
select * from dbo.ZA_OPOM_PORO where ID_OPOM= 18543038
select * from dbo.arh_ZA_OPOM_PORO --0 zapisa
select * from dbo.planp where id_cont = 59123
--select * from dbo.vrst_ter