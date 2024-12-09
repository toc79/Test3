*obična zadužnica

iif(RF_TIP_POG(pogodba.nacin_leas)=="F1" or RF_TIP_POG(pogodba.nacin_leas)=="ZP",allt(trans(round(_c1.debit*pogodba.st_obrok,2)+pogodba.opcija,gccif)),+allt(iif(pogodba.nacin_leas="O",transform(round(pogodba.st_obrok*pogodba.ost_obr,2),gccif),""))+allt(iif(pogodba.nacin_leas="FF",transform(round(pogodba.st_obrok*pogodba.ost_obr,2)+pogodba.opcija,gccif),"")))

"(slovima: "+iif(RF_TIP_POG(pogodba.nacin_leas)=="F1" or RF_TIP_POG(pogodba.nacin_leas)=="ZP",crocif(round(_c1.debit*pogodba.st_obrok,2)+pogodba.opcija,"Z"),"")+iif(pogodba.nacin_leas="O",crocif(round(pogodba.st_obrok*pogodba.ost_obr,2),"Z"),"")+iif(pogodba.nacin_leas="FF",crocif(round(pogodba.st_obrok*pogodba.ost_obr,2)+pogodba.opcija,"Z"),"")+" "+alltr(GF_LOOKUP("valute.naziv",pogodba.id_val,"valute.id_val"))+")"

*za okvire

¤idval¤ ___________________________ (slovima: __________________________________ ) 

* novo

IIF( GF_NULLOREMPTY(frame_list.sif_odobrit), "___________________________ (slovima: __________________________________ )",    IIF(RF_TIP_POG(_cb_ponudba.nacin_leas)=="F1" or RF_TIP_POG(_cb_ponudba.nacin_leas)=="ZP",allt(trans(round(_cb_AmortisationPlanLobr.debit*_cb_ponudba.st_obrok,2)+_cb_ponudba.opcija,gccif)),+allt(iif(_cb_ponudba.nacin_leas="O",transform(round(_cb_ponudba.st_obrok*_cb_ponudba.ost_obr,2),gccif),""))+allt(iif(_cb_ponudba.nacin_leas="FF",transform(round(_cb_ponudba.st_obrok*_cb_ponudba.ost_obr,2)+_cb_ponudba.opcija,gccif),"")))    )


IIF( GF_NULLOREMPTY(frame_list.sif_odobrit), "",   " (slovima: "+iif(RF_TIP_POG(_cb_ponudba.nacin_leas)=="F1" or RF_TIP_POG(_cb_ponudba.nacin_leas)=="ZP",crocif(round(_cb_AmortisationPlanLobr.debit*_cb_ponudba.st_obrok,2)+_cb_ponudba.opcija,"Z"),"")+iif(_cb_ponudba.nacin_leas="O",crocif(round(_cb_ponudba.st_obrok*_cb_ponudba.ost_obr,2),"Z"),"")+iif(_cb_ponudba.nacin_leas="FF",crocif(round(_cb_ponudba.st_obrok*_cb_ponudba.ost_obr,2)+_cb_ponudba.opcija,"Z"),"")+" "+alltr(GF_LOOKUP("valute.naziv",_cb_ponudba.id_val,"valute.id_val"))+")" )


IIF( GF_NULLOREMPTY(frame_list.sif_odobrit), "___________________________ (slovima: __________________________________ )",    IIF(RF_TIP_POG(_cb_ponudba.nacin_leas)=="F1" or RF_TIP_POG(_cb_ponudba.nacin_leas)=="ZP",allt(trans(round(_cb_AmortisationPlanLobr.debit*_cb_ponudba.st_obrok,2)+_cb_ponudba.opcija,gccif)),+allt(iif(_cb_ponudba.nacin_leas="O",transform(round(_cb_ponudba.st_obrok*_cb_ponudba.ost_obr,2),gccif),""))+allt(iif(_cb_ponudba.nacin_leas="FF",transform(round(_cb_ponudba.st_obrok*_cb_ponudba.ost_obr,2)+_cb_ponudba.opcija,gccif),"")))    +" (slovima: "+iif(RF_TIP_POG(_cb_ponudba.nacin_leas)=="F1" or RF_TIP_POG(_cb_ponudba.nacin_leas)=="ZP",crocif(round(_cb_AmortisationPlanLobr.debit*_cb_ponudba.st_obrok,2)+_cb_ponudba.opcija,"Z"),"")+iif(_cb_ponudba.nacin_leas="O",crocif(round(_cb_ponudba.st_obrok*_cb_ponudba.ost_obr,2),"Z"),"")+iif(_cb_ponudba.nacin_leas="FF",crocif(round(_cb_ponudba.st_obrok*_cb_ponudba.ost_obr,2)+_cb_ponudba.opcija,"Z"),"")+" "+alltr(GF_LOOKUP("valute.naziv",_cb_ponudba.id_val,"valute.id_val"))+")"       )

*code_before

&&local lnId_frame 
&&lnId_frame = okviri.id_frame
&&select * from okviri where id_frame = lnId_frame into cursor frame_list 

local lcId_kupca
lcId_kupca = frame_list.id_kupca
GF_SQLEXEC("select * from partner where id_kupca="+GF_QuotedStr(lcId_kupca),"_partner")

local lcId_strm
lcId_strm = frame_list.id_strm
GF_SQLEXEC("select * from strm1 where id_strm="+GF_QuotedStr(lcId_strm),"_strm1")

GF_SQLEXEC("select a.id_obr, a.datum, a.vrednost from obr_zgod a inner join (select max(datum) as datum, id_obr from obr_zgod group by id_obr) b on a.id_obr = b.id_obr and a.datum = b.datum where a.id_obr = '01'","_OBR")

lcId_pon = GF_LOOKUP("ponudba.id_pon", frame_list.sif_odobrit, "odobrit.id_odobrit")
GF_SQLEXEC("SELECT * FROM dbo.ponudba WHERE id_pon = "+GF_QuotedStr(lcId_pon),"_cb_ponudba")

GF_SQLEXEC("SELECT * FROM dbo.gfn_GenerateAmortisationPlan4Offer("+GF_QuotedStr(_cb_ponudba.id_pon)+") WHERE sif_terj ='LOBR'", "_cb_AmortisationPlanLobr")




* OSTALO

Select debit from planplacil where sif_terj="LOBR" into cursor _c1