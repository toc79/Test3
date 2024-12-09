LOCAL loForm 

loForm = GF_GetFormObject("PON_PRED_ODKUP")

loForm.pgfPonudba.page1.lblVracKaska.Caption = 'PPMV (HRK)'
loForm.pgfPonudba.page1.lblPopust.Caption = 'Naknada prij.'
loForm.pgfPonudba.page1.lblInkaso.Caption = 'CMV'
loForm.pgfPonudba.page1.lblOdobLj.Caption = 'Ostali troškovi'

* 05.01.2017 g_tomislav MR 37063
loForm.pgfPonudba.page1.lblIzplacZavar.Caption = 'Naknada'
