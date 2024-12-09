Public gcPotpis
gcPotpis = IIF(GF_NULLOREMPTY(RF_POTPIS('OPOMIN')),GOBJ_Comm.GetUserDesc(),RF_POTPIS(gcRep))
GF_SQLEXEC("select id_kupca,stev_reg from partner ","cur_partner")
gf_sqlexec("select * from dbo.nacini_l","_nacinil")

select rf_tip_pog(za_opom.nacin_leas) as tip_leas, za_opom.nacin_leas from za_opom group by za_opom.nacin_leas into cursor _nacinil2

PUBLIC rlplbrez_stroskov
rlplbrez_stroskov=.T.
	
LOCAL lnOdg, lcText, llIzpisan

lnOdg=rf_msgbox("Pitanje","Želite li ispis svih označenih ili trenutnog zapisa?","Svih","Trenutnog","Poništi")
DO case
	CASE lnOdg = 2	&& 7 Trenutnega

		SELECT za_opom	
		IF oznacen = .f. or GF_NULLOREMPTY(dok_opom) or !GF_NULLOREMPTY(ddv_id) or id_za_opom_type != 8
			OBVESTI("Niste odabrali nijednu izdanu opomenu za TP ugovore!")
			return .f.
		ENDIF
		GF_SQLEXEC("select a.id_pog, isnull(b.id_tec_new,b.id_tec) as id_tec,isnull(c.id_val,a.id_val) as id_val from pogodba a left join tecajnic b on a.id_tec=b.id_tec left join tecajnic c on b.id_tec_new=c.id_tec where id_cont="+allt(transf(za_opom.id_cont)),"_pogodba")	
		obj_ReportSelector.obj_reportPrinter.rep_scope = "FOR id_opom="+transform(za_opom.id_opom)
		* "next 1"
	CASE lnOdg = 1	&& 6 Vse
		obj_ReportSelector.obj_reportPrinter.rep_scope = "FOR oznacen = .T. and !GF_NULLOREMPTY(dok_opom) AND GF_NULLOREMPTY(ddv_id) and id_za_opom_type = 8"

		**GF_SQLEXEC("SELECT id_kupca from p_kontakt where id_vloga='O1' and neaktiven=0","cur_za_opom")
		**list = GF_CreateDelimitedList("cur_za_opom","id_kupca", "", ",",.t.)
			
		SELECT za_opom
		LOCATE FOR oznacen = .T. AND !GF_NULLOREMPTY(dok_opom) AND GF_NULLOREMPTY(ddv_id) AND id_za_opom_type = 8
		** AND !(INLIST(allt(id_kupca),&list))
		
		IF !FOUND()
			OBVESTI("Niste odabrali nijednu izdanu opomenu za TP ugovore!")
			return .f.
		ENDIF
	
		GF_SQLEXEC("select a.id_pog, isnull(b.id_tec_new,b.id_tec) as id_tec,isnull(c.id_val,a.id_val) as id_val from pogodba a left join tecajnic b on a.id_tec=b.id_tec left join tecajnic c on b.id_tec_new=c.id_tec","_pogodba")		
	OTHERWISE
		RETURN .F.
ENDCASE

*public gcDatum_upisa,gdDatum_upisa
*gdDatum_upisa=date()-1
*gdDatum_upisa=GF_GET_DATE("Datum upisa",gdDatum_upisa)

public loUserData
loUserData=gobj_comm.getUserData()

SELECT za_opom
SET FILTER TO oznacen = .T. AND !EMPTY(dok_opom)
** AND !(INLIST(allt(id_kupca),&list))
SET SKIP TO opom_tmp

GF_SQLEXEC("select a.*, b.ddv_id from opom_tmp a left join planp b on a.id_cont=b.id_cont AND a.st_dok=b.st_dok","_temp")