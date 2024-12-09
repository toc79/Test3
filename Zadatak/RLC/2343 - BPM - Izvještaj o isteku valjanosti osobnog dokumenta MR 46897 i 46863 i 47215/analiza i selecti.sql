select top 100 * from dbo.gv_bpm_data_field_instance 

select id_kupca, count(*) as br_zapisa from dbo.P_EVAL 
where ext_id is not null 
and exists (select * from dbo.partner where vr_osebe in ('FO', 'F1') and p_eval.ID_KUPCA = id_kupca)
group by id_kupca 
having count(*)>1

select ext_id, * from dbo.p_eval where id_kupca='025733' and ext_id is not null 

select * from bpm_prod.dbo.bpm_data_field_instance dfi
join bpm_prod.dbo.bpm_def_data_field ddf on ddf.id = dfi.id_data_field_definition
where 1=1
and dfi.id_process_instance = 16362	 
--and ddf.id_process_version = 55 
and ddf.name in( 'assignee_personal_doc_date', 'assignee_personal_doc_date2', 'customer_id')
and val_str is not null

gfn_GetElementValueFromXMLDesc


Poštovani, 

u privitku vam šaljemo ponudu za izradama kontrole u Nova i BPMu te izradu posebnog izvještaja.



pitanje za RLC i izvještaja iz BPMa, nisam do sada bio radio
oni žele kritrerij pretrage Status procesa: Samo završeni procesi ili Amo ne završeni procesi
Ako idu i nezavršeni procesi, to znači da podatke nemam u ODS tabeli, već da ću morati uzimati podatke iz dbo.bpm_data_field_instance
http://gmcv03/support/Maintenance.aspx?ID=46897&Tab=Progress



select id_kupca, count(*) as br_zapisa from dbo.P_EVAL 
where ext_id is not null 
and exists (select * from dbo.partner where vr_osebe in ('FO', 'F1') and p_eval.ID_KUPCA = id_kupca)
group by id_kupca 
having count(*)>1

select ext_id, * from dbo.p_eval where id_kupca='025733' and ext_id is not null 

select * from bpm_prod.dbo.bpm_data_field_instance dfi
join bpm_prod.dbo.bpm_def_data_field ddf on ddf.id = dfi.id_data_field_definition
where 1=1
and dfi.id_process_instance = 16362	 
--and ddf.id_process_version = 55 
and ddf.name in( 'assignee_personal_doc_date', 'assignee_personal_doc_date2', 'customer_id')
and val_str is not null

gfn_GetElementValueFromXMLDesc


Poštovani, 

u privitku vam šaljemo ponudu za izradama kontrole u Nova i BPMu te izradu posebnog izvještaja.



pitanje za RLC i izvještaja iz BPMa nisam do sada bio radio iz nule te općenito. 
1. Oko izvještaja oni žele kritrerij pretrage Status procesa: Samo završeni procesi ili Samo ne završeni procesi
Ako idu i nezavršeni procesi, to znači da podatke nemam u ODS tabeli, već da ću morati uzimati podatke iz dbo.bpm_data_field_instance onda za cijeli izvještaj, i općenito ? 
2. I oko ponude za validaciju 6 polja u BPMu (is_warning=true) na koliko po tebi bi išla ponuda?
http://gmcv03/support/Maintenance.aspx?ID=46897&Tab=Progress 




Poštovana/i, 

1. oko kontrola u NOVA znači kod unosa i popravka parntera ide samo upozoravajuća poruka s mogućnošću nastavka spremanja.
Oko kontrole u procesu "Proces ZSPNFT s provjerom fizičkih osoba u vlasničkoj strukturi RLHR", imate više polja za:
- 4. Zakonski zastupnik/punomoćenik imamo dva podatka: 1. Osobni dokument važi do i 2. Osobni dokument važi do
- 2.2 Vlasnička struktura - fizičke osobe imamo četiri podatka: 1. Važi do - identifikacijska isprava, 2. Važi do - identifikacijska isprava, 3. Važi do - identifikacijska isprava i 4. Važi do - identifikacijska isprava.
Da li se provjera radi za sva navedena polja ili samo za ?

2. Pregled svih unesenih osoba u BPM sa određenim podacima možemo napraviti u IS NOVA u opciji izvještaja iz snimka stanja (to su u biti svi izvještaji koji nisu iz produkcijske baze IS NOVA). Nakon što definirate u točki 1. koje polja želite kontrolirati, ista polja bi onda prikazli na izvještaju.
Izvještaj bi se radio samo za proces "Proces ZSPNFT s provjerom fizičkih osoba u vlasničkoj strukturi RLHR" pa smatram da taj kriterij nije potreban jer će izvještaj biti u IS NOVA već bi kreirali samo kriterij za "Status procesa".

$SIGN





Izvještaj ib se radio samo za proces "Proces ZSPNFT s provjerom fizičkih osoba u vlasničkoj strukturi RLHR"
   
   
te također želite da poruka bude informativna tj. da se može nastaviti dalje s procesom? U NOVA postoji popravak partnera dok u BPMu ne postoji popravak instance, da li želite da se ipak ne može spremiti neodgovarajući podatak?

   
   <data_field name="assignee_personal_doc_date" type="date" title="1. Osobni dokument važi do" description="1. Osobni dokument važi do" display_to_user="true" display_group="4. Zakonski zastupnik/punomoćenik" />
   
   <data_field name="assignee_personal_doc_date2" type="date" title="2. Osobni dokument važi do" description="2. Osobni dokument važi do" display_to_user="true" display_group="4. Zakonski zastupnik/punomoćenik" />
   
   <data_field name="related_fo_manage_id_doc_date1" type="date" description="1. Važi do - identifikacijska isprava" title="1. Važi do - identifikacijska isprava" display_to_user="true" display_group="2.2 Vlasnička struktura - fizičke osobe" />
   
   <data_field name="related_fo_manage_id_doc_date2" type="date" description="2. Važi do - identifikacijska isprava" title="2. Važi do - identifikacijska isprava" display_to_user="true" display_group="2.2 Vlasnička struktura - fizičke osobe" />
   
   <data_field name="related_fo_manage_id_doc_date3" type="date" description="3. Važi do - identifikacijska isprava" title="3. Važi do - identifikacijska isprava" display_to_user="true" display_group="2.2 Vlasnička struktura - fizičke osobe" />
   
   <data_field name="related_fo_manage_id_doc_date4" type="date" description="4. Važi do - identifikacijska isprava" title="4. Važi do - identifikacijska isprava" display_to_user="true" display_group="2.2 Vlasnička struktura - fizičke osobe" />