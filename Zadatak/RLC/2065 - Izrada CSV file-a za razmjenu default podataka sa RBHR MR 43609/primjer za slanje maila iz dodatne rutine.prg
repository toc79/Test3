tsp_check_string_occurrences_in_nova 'mail'

select * from porocila where code_after like '%mail%' order by FORM_NAME 

select * from dbo.jm_job where id_job = 34
select * from dbo.jm_job_history where id_job = 34
select * from dbo.jm_job_step_history where id_job_history = 216308
select * from dbo.MAIL where mail_id = 71972


local lnCount, lnError, lcE, lcXML

Select * From rezultat where sent = .F. and error is null into cursor _za_slati

sele _za_slati

go top

IF reccount() >0 then	
	lnCount = reccount()
	lnError = 0	
	lcE = CHR(13) + CHR(10)	
	
	scan
		lcXML= "<send_mail xmlns="+chr(34)+"urn:gmi:nova:core"+chr(34)+">" + gcE		
		lcXML= lcXML + GF_CreateNode("mail_id", _za_slati.mail_id, "I", 1) + gcE		
		lcXML= lcXML + GF_CreateNode("do_not_throw_exception_on_error", .T., "L", 1) + gcE		
		lcXML= lcXML + "</send_mail>"			
		
		IF !GF_ProcessXml(lcXml, .t., .f.) then			
			**=obvesti("Mail sa brojem: "+allt(trans(_za_slati.mail_id))+ " nije poslan!")				
			lnError = lnError + 1		
		endif	
	endscan	
	=obvesti("Za slanje: "+allt(trans(lnCount))+lcE+"Poslano: "+allt(trans(lnCount-lnError))+lcE+"Grešaka: "+allt(trans(lnError))+".")
ELSE	
	=obvesti("U pregledu ne postoje mailovi koji nisu poslani!")	
endif
use in _za_slati

local loForm

FOR i = 1 TO _Screen.FormCount	
	IF LOWER(_Screen.Forms(i).Name) == LOWER("frmmail_view") THEN		
		loForm = _Screen.Forms(i)		
		EXIT	
	ENDIF
NEXT

loForm.runsql()