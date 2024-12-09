select ne_knj_obresti,* from dbo.kred_pog where status_akt= 'A'
select ne_knj_obresti,* from dbo.kred_pog where status_akt= 'A' and ne_knj_obresti != 1
select ne_knj_obresti,* from dbo.kred_pog where status_akt= 'A' and ne_knj_obresti = 1

update dbo.kred_pog set ne_knj_obresti = 0 where status_akt= 'A' and ne_knj_obresti = 1


loForm = GF_GetFormObject("frmCContracts_maska") 
IF ISNULL(loForm) THEN 
	RETURN
ENDIF


**----------------------------
** 26.05.2021 g_tomislav MID 46585

IF loForm.tip_vnosne_maske == 1
	loForm.chkNe_knj_obresti.Value = .f.
ENDIF
** Kraj MID 46585-------------

Promjena podatka ne_knj_obresti je bila na sljdećim ugovorima 
0140 13        
0163 16        
0164 16        
0175 16        
0176 16        
0180 16        
0183 17        
0184 17        
0186 17        
0187 17        
0191 17        
0192 17        
0198 18        
0200 18        
0201 18        
0202 18        
0203 18        
0204 18        
0205 18        
0206 18        
0207 18        
0208 18        
0209 19        
0210 19        
0211 19        
0212 19        
0214 19        
0215 19        
0216 19        
0217 19        
0219 19        
0220 19        
0221 19        
0222 19        
0223 19        
0224 19        
0226 19        
0227 19        
0228 19        
0231 19        
0232 19        
0233 19        
0234 20        
0236 20        
0237 20        
0238 20        
0239 20        
0240 20        
0241 20        
0242 20        
0243 20        
0244 20        
0245 20        
0246 20        