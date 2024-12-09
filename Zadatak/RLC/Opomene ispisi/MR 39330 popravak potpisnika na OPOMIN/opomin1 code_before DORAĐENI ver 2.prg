GF_SQLEXEC("select id_kupca,stev_reg from partner ","cur_partner")
gf_sqlexec("select  top 10 * from tecaj  order by datum desc","__tecaj")
select "000" as id_tec, dtot(date()) as datum,1 as tecaj from __tecaj order by datum into cursor __tecaj0


gf_sqlexec("select * from dbo.nacini_l","_nacinil")

select rf_tip_pog(za_opom.nacin_leas) as tip_leas, za_opom.nacin_leas from za_opom group by za_opom.nacin_leas into cursor _nacinil2

select * from __tecaj where datum=date() ;
union all select * from __tecaj0 where datum=date() ;
into cursor _tecaj

PUBLIC rlplbrez_stroskov
rlplbrez_stroskov=.f.

LOCAL lnOdg, lcText, llIzpisan

lnOdg=rf_msgbox("Pitanje","Želite li ispis svih označenih ili trenutnog zapisa?","Svih","Trenutnog","Poništi")
DO case
	CASE lnOdg = 2	&& 7 Trenutnega

		SELECT za_opom	
		IF oznacen = .f. or (EMPTY(ddv_id) OR ISNULL(ddv_id))
			OBVESTI("Niste odabrali izdanu opomenu!")
			return .f.
		ENDIF
		GF_SQLEXEC("select a.id_pog, isnull(b.id_tec_new,b.id_tec) as id_tec,isnull(c.id_val,a.id_val) as id_val from pogodba a left join tecajnic b on a.id_tec=b.id_tec left join tecajnic c on b.id_tec_new=c.id_tec where id_cont="+allt(transf(za_opom.id_cont)),"_pogodba")	
		obj_ReportSelector.obj_reportPrinter.rep_scope = "FOR id_opom="+transform(za_opom.id_opom)
		* "next 1"
	CASE lnOdg = 1	&& 6 Vse
		obj_ReportSelector.obj_reportPrinter.rep_scope = "FOR oznacen = .T."
		SELECT za_opom
		LOCATE FOR oznacen = .T. AND !(EMPTY(ddv_id) OR ISNULL(ddv_id))
		IF !FOUND()
			OBVESTI("Niste odabrali nijednu izdanu opomenu!")
			return .f.
		ENDIF
		GF_SQLEXEC("select a.id_pog, isnull(b.id_tec_new,b.id_tec) as id_tec,isnull(c.id_val,a.id_val) as id_val from pogodba a left join tecajnic b on a.id_tec=b.id_tec left join tecajnic c on b.id_tec_new=c.id_tec","_pogodba")		
	OTHERWISE
		RETURN .F.
ENDCASE

select a.id_pog, b.id_tec, b.id_val, c.tecaj from za_opom a ;
left join _pogodba b on a.id_pog=b.id_pog ;
left join _tecaj c on b.id_tec=c.id_tec into cursor _dug

SELECT za_opom
lcFilter=filter()

SELECT id_opom, RF_POTPIS('OPOMIN') as gr, RF_POTPIS('OPOMINV') as grV, RF_POTPIS(NVL(Ro_izdal, '')) as grPrim FROM za_opom ;
WHERE !ISNULL(Ro_izdal) AND oznacen = .T. AND !GF_NULLOREMPTY(ddv_id) AND IIF(EMPTY(lcFilter), .t., lcFilter) ORDER BY 1 INTO CURSOR _cb_Potpis

SELECT za_opom	
if !empty(lcFilter)
   lcfilter="(oznacen = .T. AND !(EMPTY(ddv_id) OR ISNULL(ddv_id))) and ("+lcfilter+")"
   set filter to &lcFilter
else	
   SET FILTER TO oznacen = .T. AND !(EMPTY(ddv_id) OR ISNULL(ddv_id))
endif
SET SKIP TO opom_tmp