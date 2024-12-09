loForm = GF_GetFormObject("frmActiveContractUpdate") 

*********************************************
** S promjenom kontrole na ovom mjestu, potrebno je promijeniti POGODBA_MASKA_PREVERI_PODATKE, POGODBA_MASKA_RIND_STRATEGIJE_LOSTFOCUS, POGODBA_UPDATE_RIND_STRATEGIJE_LOSTFOCUS te provjeriti i POGODBA_MASKA_AFTER_INIT
** 29.10.2020 g_tomislav MID 45655 - onemogućavanje polja kao i u POGODBA_MASKA_AFTER_INIT zbog sistemske kontrole koja ne dozvoljava strategiju zadnji radni dan u mjesecu 

loForm.pgfPogodba.pagSplosni.txtrindDatNext.Enabled = .F.
*Kraj Rind_strategije ***********************