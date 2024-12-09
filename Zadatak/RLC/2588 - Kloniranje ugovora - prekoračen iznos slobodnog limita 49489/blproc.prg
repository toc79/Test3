**************************************************************************
* History:
* ???????? Matjaz; created
* 23.03.2004 Matjaz; id_cont 2 PK action
* 23.03.2004 Vik; added function GF_ShowContractPriority
* 28.05.2004 Matjaz; added function GF_GetContractStatusDesc
* 01.06.2004 Matjaz; removed status 'P' from GF_GetContractStatusDesc
* 07.06.2004 Matjaz; changed SQL statement in GF_ChangePPDates that was still using id_pog instead of id_cont
* 20.08.2004 Matjaz; added function GF_CreateZav_memo
* 24.09.2004 Matjaz; added naz_kr_kup into zam_memo generation
* 28.09.2004 Vik; added GF_OpenSnapshot()
* 04.11.2004 Dare; added GF_odkl_pog()
* 18.11.2004 Vilko; transfered method GF_CreateZav_memo into XPROC.PRG
* 23.11.2004 Matjaz; added GF_DeleteContractBL
* 08.12.2004 Matjaz; added GF_ChangeContractStatus
* 19.01.2005 Vik; GF_odkl_pog now uses GF_ProcesXml
* 27.01.2005 Vik; added GF_HypoSI_PartnerSync()
* 04.04.2005 Vik; BugID: 1173 - we now allow movement of dates for VAT claim
* 05.04.2005 Matjaz; BugID: 1181 - added customer and object information in GF_DeleteContractBL 
* 11.05.2005 Natasa; Added function GF_PLAC_IZH_AVTOR - create authorization form for out. payments
* 16.05.2005 Vik; fixed GF_OpenSnapshot to use entity_code
* 18.05.2005 Vik; added GF_AutoRpgPrecalc
* 20.05.2005 Natasa, changed GF_PLAC_IZH_AVTOR, added parameters tcTec in tdDatum
* 03.06.2005 Matjaz; removed && caption and split a line into 2 to fix translation problems
* 14.06.2005 Natasa; added function GF_PRIOR_REDEMPTION_XML - prepare XML for prior redemption calculation, reading or insertion
* 04.07.2005 Natasa; modified GF_PLAC_IZH_AVTOR - added parameter tnVrednostPogodbe = value of contract to check if authorization is allowed
* 09.07.2005 Vik; replaced usage of ReprogramEntryPoint with ProcessXml
* 11.07.2005 Vilko; changed GF_ContractInsertProcess - removed unnecessary messagebox
* 11.07.2005 Natasa; changed GF_PLAC_IZH_AVTOR, added params tcPrejemnik, tcZnesek to show on authorization form 
* 11.07.2005 Natasa; created GF_DELETE_OUT_PAY - function prepare and execute XML (ProcessXml) to delete out. payments
* 13.07.2005 Natasa; added FUNCTION GF_CHECK_MODEL_AND_REF_NO
* 19.07.2005 Natasa; modified GF_PRIOR_REDEMPTION_CURSORS, added parameter for XMLResult, functiopn returns T or F dependeng on ProcessXml success 
* 22.07.2005 Natasa; created GF_COMMISSIONS_MANIPULATE - set commissions status and calculate value in native currency 
* 26.07.2005 Natasa; changed GF_ContractInsertProcess - added out. payment in contract insert process between "zapisnik" and "dokumentacija"
* 02.08.2005 Vik; added function GF_TransferSnapshot()
* 04.08.2005 Vik; changed GF_ChangeContractStatus - no call is made to server is new status is the same as old one
* 18.08.2005 Natasa; changed GF_odkl_pog separate text for warning because of translation  
* 26.08.2005 Natasa; changed GF_ContractInsertProcess, added call pogodba_dashboard 
* 06.09.2005 Vik; added code for transformation of string into XML format
* 26.09.2005 Vilko; changed GF_ContractInsertProcess - added commissions in contract insert process
* 28.09.2005 Vilko; changed GF_UpdateDbfield - enlarged functionality - now is possible to update more than one field
* 13.10.2005 Matjaz; added permission check for contract delete
* 24.10.2005 Vilko; changed GF_UpdateDbfield - added check on restoring last record position in active alias
* 20.12.2005 Natasa bug id 25777 : modified GF_PLAC_IZH_AVTOR, added parameter contract/frame and show it on form for autorization of payment 
* 19.01.2006 Darko; modified GF_PLAC_IZH_AVTOR: added new parameter tcpartner (maintenance 689)
* 13.07.2006 Vik; Bug ID 26050 - added snapshot description to snapshot lists (in functions GF_OpenSnapshot and GF_TransferSnapshot)
* 14.07.2006 Vilko; Bug ID 26057 - modified GF_OpenSnapshot and GF_TransferSnapshot - added snapshot id and snapshot creation date to snapshot list
* 04.09.2006 Darko; moved GF_UpdateDbfield from blproc to sqltools due to use in other modules than leasing
* 16.10.2006 Muri; function GF_COMMISSIONS_MANIPULATE upgraded to new XSD schema
* 17.10.2006 Jasna;Bug ID 26301 changes in GF_CHECK_MODEL_AND_REF_NO;checking for RefNo in case that HR is the country and model no. is 99 is deleted.  
* 20.10.2006 Ziga; Bug id 26327 - Added function GF_DeleteSnapshot() for deleting old snapshots from production database
* 20.10.2006 Ziga; Changed listbox_select form call in functions GF_TransferSnapshot() and GF_OpenSnapshot(); calls are executed with width and height parameters
* 27.10.2006 Vik; Bug id 26327 - Changed permission level for bowsing data from snapshot
* 05.01.2007 Vilko; Maintenance ID 3722 - added function GF_CheckFrameAvailabilityForContract - merged Valid method for id_frame from pogodba_maska and pogodba_update
* 26.02.2007 Vik; Maintenance ID 3447 - added check of new document date in method GF_ChangePPDates
* 02.04.2007 Jelena; Task ID 5035 - changed GF_ContractInsertProcess - added direct debit on beginning of contract insert process 
* 02.04.2007 Jasna; small changes in call GF_TestModel and GF_TestReferenceNumber, remove obsolate parameter 
* 31.05.2007 Vilko; modified GF_ContractInsertProcess - added check if module DIRECT_DEBIT is enabled
* 04.06.2007 Jelena; added check - if contract is in domectic exchange for inserting direct debit
* 10.12.2007 Jasna; Maintenance ID 12415 - modified GF_CHECK_MODEL_AND_REF_NO, model can be empty also in BiH
* 19.12.2007 Natasa; Maintenance ID 7288, added parameter id_cont to method GF_ChangePPDates
* 08.01.2007 Vilko; MID 12833 - modified GF_ChangeContractStatus - added missing parameter in function call GF_CreateContractUpdateXML
* 11.02.2008 MatjazB; Bug ID 27138 - added ORDER BY created_on DESC in GF_TransferSnapshot, GF_DeleteSnapshot and GF_OpenSnapshot
* 14.02.2008 Jasna; MID 13571 - fixed bug (toContract instead of toContact) in GF_CheckFrameAvailabilityForContract
* 13.03.2008 MatjazB; Bug ID 27097 - remove GF_OpenSnapshot()
* 19.03.2008 Jasna; MID 14016 - modified GF_DeleteContractBL
* 09.04.2008 Jasna; MID 14016 - modified GF_DeleteContractBL
* 16.05.2008 Jasna; Bug 27285 - modified GF_DeleteContractBL (on Exit doesn't need to check valid date)
* 11.06.2008 Vilko; MID 15803 - modified GF_PRIOR_REDEMPTION_CURSORS - refactoring due changes in XSD schema
* 10.07.2008 Ziga; Bug ID 27380 - modified GF_DeleteContractBL, removed return .T. when checking dni_zak_ddv
* 18.09.2008 PetraR; Bug ID 27459 - modified GF_TransferSnapshot - if snapshot exists in snapshot database, program asks if you want to transfer snapshot again
* 24.09.2008 Ziga; Bug ID 27319 - modified GF_DeleteContractBL - added second parameter to call of the function GF_ValidDDVDate
* 25.09.2008 Ziga; Maintenance ID 16321 - added procedure GF_PartnerInsertProcess
* 25.09.2008 Ziga; Maintenance ID 16321 - added check for type of field lcId_Kupca in procedure GF_PartnerInsertProcess
* 13.11.2008 Jasna; MID 17828 - modified GF_DeleteContractBL function
* 28.11.2008 Vilko; MID 18159 - moved function GF_PartnerInsertProcess to xproc.prg
* 18.02.2009 Ziga; Bug ID 27680 - added check for empty date in function GF_DeleteContractBL
* 27.05.2009 Ziga; Task ID 5531 - added function GF_ProcessPaymentIndisciplineIndex
* 27.05.2009 Ziga; Task ID 5581 - added function GF_ReprogramIntRateChange
* 08.10.2009 Ziga; MID 21953 - added function GF_ClearContractSpecialities
* 23.11.2009 Ziga; Task ID 5599 - replaced dbo.oc_reports with dbo.gv_OcReports in procedures GF_TransferSnapshot and GF_DeleteSnapshot
* 17.12.2009 MatjazB; MID 23046 - modified GF_ChangePPDates - changes due to new form for changing dates
* 17.02.2010 Ziga; MID 23659 - modified function GF_CheckFrameAvailabilityForContract, net_nal_zac and vr_val_zac amount is considered instead of net_nal and vr_val for frame types 'POG' and 'NET'
* 09.03.2010 Natasa; MID 23238 - added function GF_CDTransfer 
* 07.04.2010 Natasa; MID 23238 - change GF_CDTransfer, added check if xml result type is character
* 15.04.2010 Ziga; MID 24299 - modified function GF_ReprogramIntRateChange, added possibility to change interest rate to current value (till now only change for current % was possible)
* 19.04.2010 Ziga; MID 24705 - modified function GF_CheckFrameAvailabilityForContract, added support for frame type RFO (revolving frame Ford stock for Summit)
* 21.04.2010 Vilko; MID 24705 - modified function GF_CheckFrameAvailabilityForContract - split one line into three lines due translation problems
* 04.05.2010 Ziga; MID 25145 - modified function GF_CheckFrameAvailabilityForContract - repaired obligo for frame type REV and RFO for active contracts that do not exists in planp_ds (all claims are closed), obligo for such contracts is 0.
* 21.06.2010 Ziga; MID 24498 - added function GF_ZobrMassStornoCancelletion.
* 21.06.2010 JozeM; TID 5938 - changed GF_DELETE_OUT_PAY schema
* 24.06.2010 JozeM; TID 5938 - changed some processXml calls
* 12.10.2010 TASK 6095 - handling new parameter official in method GF_TransferSnapshot
* 19.10.2010 TASK 6095 - rehandled of paramter official in GF_TransferSnapshot
* 03.12.2010 TASK 6095 - small text changed after Petra test in GF_TransferSnapshot
* 07.02.2011 TASK 6187 - in GF_ContractInsertProcess, added information if notifications or commissions are exported from DSA 
* 03.03.2011 MID 29185 - Added translation flag into method GF_TransferSnapshot
* 16.05.2011 Jelena; Task ID 6271 - added method GF_CloneSnapshot
* 17.05.2011 Jelena; Task ID 6271 - modified method GF_CloneSnapshot
* 19.05.2011 Jelena; Task ID 6271 - modified method GF_CloneSnapshot
* 07.06.2011 Nataša; Task ID 6183 - modified method GF_CloneSnapshot, GF_TransferSnapshot and GF_DeleteSnapshot - enable for all snapshot types
* 14.06.2011 Nataša; Task ID 6183 - mofified GF_TransferSnapshot, set Official = .T. only for snapshots of type MAIN, for rest set it to .F. 
* 07.10.2011 JozeM; MID 30844 - changed message in GF_ChangePPDates
* 24.10.2011 Vilko; Task ID 6475 - modified GF_CloneSnapshot - added check the number of allowed intermediate snapshots
* 27.12.2011 Jasna; MID 30918 - modified GF_CheckFrameAvailabilityForContract() added new frame type RNE
* 28.03.2012 Ziga; MID 34209 - modified calculation of obligo for frame type RFO, future interests tax is excluded in function GF_CheckFrameAvailabilityForContract()
* 03.04.2012 Ziga; MID 34209 - modified calculation of obligo for frame type RFO, future interests tax is excluded in function GF_CheckFrameAvailabilityForContract()
* 25.04.2012 Uros; TASK 6754 - added CustomRevalorization method
* 29.05.2012 Ziga; Task ID 6354 - modified GF_ContractInsertProcess, modified parameters to call of form direct_debit_maska
* 28.08.2012 Ziga; Task ID 6938 - modified GF_ContractInsertProcess, added allocation from credit contracts in contract insert process
* 25.09.2012 Natasa; Task ID 6338- modified GF_CloneSnapshot, GF_DeleteSnapshot and GF?TransferSnapshot - added optional parameter id_oc_report 
* 18.12.2012 Ales; Bug id 29777 - modified GF_TransferSnapshot - added daily to sql query, added desc D if snapsot is daily or M if montly to snapshot name
* 31.01.2013 MatjazB; MID 38607 - added CalculateEquipmentAcceptanceProtocol
* 22.02.2013 Uros; TID 7247 - added ext func POGODBA_AFTER_INSERT_PROCESS
* 18.03.2013 Jelena; TID 7267 - into method GF_ChangePPDates added check if contract is prohibited from changing payment plan dates
* 12.08.2013 Ales; MID 41114 - modified GF_ContractInsertProcess - added check for custom setting 'Nova.LE.InsertZapReg'
* 18.12.2013 Jasna; MID 41892 - modified GF_ChangePPDates() - data_dok_create_type register included
* 09.04.2014 Natasa; TID 7793 - modified GF_CloneSnapshot - warns if number of snapshots approach to max (custom settings)
* 11.04.2014 Natasa; TID 7793 - modified GF_TransferSnapshot - add deleting of previouse transfer in DWH depanding on custom settings
* 26.05.2014 IgorS; Task ID 8090 - modified GF_CheckFrameAvailabilityForContract, added support for PPMV in finbruto
* 27.05.2014 IgorS; Task ID 8090 - removed added logic from GF_CheckFrameAvailabilityForContract
* 30.05.2014 IgorS; Task ID 8109 - added logic from GF_CheckFrameAvailabilityForContract
* 21.07.2014 Natasa; Bug ID 31012- cosmetic changes
* 29.07.2014 Uros; Bug 30903 - added prepare_partners to GF_CloneSnapshot
* 21.11.2014 Andrej; Task 8170 - added method GF_GenerateNewStocksFromContracts
* 26.11.2014 Andrej; Task 8170 - modified method GF_GenerateNewStocksFromContracts
* 27.11.2014 Andrej; BUG 31215 - Modified method GF_DeleteSnapshot. 
* 13.01.2014 Jelena; MID 48881 - modified method GF_ChangePPDates
* 19.01.2015 IgorS, Zigap; MID XXXXX  - removed bug (toContarct instead of toContract) in function GF_CheckFrameAvailabilityForContract
* 20.01.2015 Andrej; BUG 31490 - modified messagebox string in method 'GF_GenerateNewStocksFromContracts'
* 11.03.2014 Jelena; Bug ID 31550 - modified method GF_ChangePPDates
* 15.05.2015 Jelena; Task ID 8630 - modified method  GF_ReprogramIntRateChange - added is_installment_credit
* 18.12.2015 Jasna; MID 54392 - modified GF_ChangePPDates() - > call of GF_APChangeDate changed, added new parameter lbFourEyes
* 13.01.2016 Ales; Bug id 32163 - modified GF_ContractInsertProcess - Commissions - diffrent msg if commission is inserted in dsa or directly in Nova
* 28.01.2016 MatjazB; MID 54121 - modified GF_ChangePPDates - refactoring (use form pogodba_dashboard_changedates)
* 28.01.2016 Jost; Bug ID 32191 - GF_ContractInsertProcess() - added Lego call for inserting commissions (new way)
* 29.01.2016 Jost; Bug ID 32191 - minor change in sequence: 1. insert commissions, 2. make check if commisions were inserted
* 02.02.2016 Andrej; Task ID 9195 - GF_TransferSnapshot(), GF_CloneSnapshot() - modified to not select snapshots that are marked to delete.
* 03.02.2016 Ziga; MID 50905 - added new function GF_AutoRpgInitialIntRateSuggestion and minor modifications in function GF_AutoRpgPrecalc.
* 29.02.2016 MatjazB; Bug 32261 - modified GF_ChangePPDates - change after test (MID 54121)
* 23.03.2016 Domen; BugID 30912 - modified GF_ContractInsertProcess, calling SQL with parameters
* 28.04.2016 Ales; Bug id 32416- modified GF_ContractInsertProcess - Commissions - fixed msg if commission is inserted directly in Nova
* 20.05.2016 Jelena; Bug id 32322 - remove empty string from message in GF_CheckFrameAvailabilityForContract
* 13.06.2016 Ales; Task id 9396 - selecting id_provision_definition moved to after contract save
* 15.06.2016 Ales; Task id 9397 - modified GF_ContractInsertProcess - recalculate DWC provisions
* 16.06.2016 Ales; Task id 9397 - modified GF_ContractInsertProcess - recalculate DWC provisions - minor fixes
* 16.06.2016 Ales; Task id 9396 - modified GF_ContractInsertProcess - auto select provision def. id if only one candidate, do not calculate provision if there is no provision def. id candidates
* 20.06.2016 Ales; Task id 9397 - modified GF_ContractInsertProcess - do not show diff view if there is no diff
* 21.06.2016 Ales; Task id 9396 - modified GF_ContractInsertProcess - show error msg if provision calculation failed
* 18.07.2016 MatjazB; Task 9514 - added GF_SelectRpgCategoryComment
* 08.09.2016 Blaz; TID 9622 - added GF_StockFundingSetContractsAsSold 
* 12.09.2016 Blaz; TID 9622 - added extra messages to GF_StockFundingSetContractsAsSold
* 07.10.2016 Blaz; TID 9622 - transfered the GF_StockFundingSetContractsAsSold gsp execution to C#
* 04.11.2016 Blaz; TID 9730 - added a check if there are any commission calculations for selected agent
* 28.11.2016 Blaz; BID 32737 - split GF_ContractInsertProcess to multiple procedures and added a recursive call to ContractInsertCommissions
* 28.11.2016 MatjazB; Bug 32778 - modified GF_ChangePPDates - fix reprogram category
* 30.11.2016 Blaz; BID 32737 - added a break if we dont select any commissions
* 05.12.2016 MatjazB; Task 9640 - added GF_CheckDokActStatus4Entities
* 17.01.2017 MatjazB; Task 9812 - modified GF_StockFundingSetContractsAsSold - change message
* 13.02.2017 Blaz; BID 32909 - modified GF_CheckDokActStatus4Entities - removed the check for non-active documents it checks all documents
* 23.02.2017 Blaz; BID 32948 - renamed a custom setting
* 23.02.2017 Blaz; BID 32948 - an extra rename
* 27.02.2017 MatjazB; MID 61716 - modified GF_AutoRpgInitialIntRateSuggestion - support rabat
* 15.11.2017 MatjazB; Bug 33441 - modified GF_AutoRpgInitialIntRateSuggestion - handle error
* 24.01.2018 MatjazB; Bug 33162 - modified GF_AutoRpgInitialIntRateSuggestion - set rebate to 0
* 26.01.2018 MatjazB; Task 11638 - modified GF_ContractInsertProcess - optimization
* 15.02.2018 Jelena; MID 69420 - into GF_CheckFrameAvailabilityForContract added case for new frame type 'MPC'
* 20.09.2018 KlemenV; TID 14634 - modified GF_TransferSnapshot, GF_DeleteSnapshot and GF_CloneSnapshot - changed permissions
* 18.01.2019 Blaz; TID 15150 - modifed ContractInsertCommissions - can now return a message when calculating
* 21.01.2019 Blaz; TID 15150 - modifed ContractInsertCommissions - added return
* 13.02.2019 KlemenV; TID 15260 - modifed GF_ContractInsertProcess - changed lnId_cont to input param
* 04.04.2019 KlemenV; MID 79369 - modified GF_ChangePPDates
* 05.04.2019 Ernest; TID 15488 - added possibiliti to add 'poljubna kategorija' and open contract dashboard after creation to GF_ContractInsertProcess
* 23.09.2019 MatjazB; MID 84952 - modified GF_ContractInsertProcess (poljubne kategorije)
* 06.03.2020 MatjazB; TID 18883 - ODBC - modified GF_ChangePPDates, GF_ContractInsertProcess
* 26.05.2020 Thor; MID 91069 - if "vrsta osebe" is registerd in "Nova.App.DirectDebitSEPAPartnerTypeStrongPaymentNotMandatory" its the same as strong_payment = true
* 27.07.2020 Blaz; BID 38280 - added GF_ContractCommissionReEntry
* 19.08.2020 Blaz; BID 38280 - modified GF_ContractCommissionReEntry - changed the date checked
* 21.08.2020 Blaz; BID 38280 - modified GF_ContractCommissionReEntry - added another condition to allow deletion
* 28.08.2020 Blaz; BID 38280 - modified GF_ContractCommissionReEntry - added a check if the contract has any commissions
* 07.09.2020 Blaz; BID 38280 - modified GF_ContractCommissionReEntry - added extra check when counting inserted commissions
* 06.04.2021 Kristjan; BID 38831 - modified ContractInsertCommissions - added CS Nova.LE.NewCommissionsModule.PosrednikJeKoncesija check
* 11.10.2021 MatjazB; TID 22804 - modified GF_DeleteContractBL
**************************************************************************

#INCLUDE ..\..\common\includes\locs.h

**************************************************************************
PROCEDURE GF_ContractInsertProcess
	LPARAMETERS lnId_cont
	LOCAL lResult, lcSql, llstrong_payment, llCustomSettingInsertZapReg, llInsertZapReg, laPar[1], lcCursor, llOpenKateg

	IF PCOUNT() = 0 THEN
		DO FORM pogodba_maska TO lnId_cont
	ELSE
		laPar[1] = lnId_cont
		lcCursor = SYS(2015)
		TEXT TO lcSql NOSHOW 
			select STATUS_AKT from dbo.pogodba WHERE id_cont = ?p1
		ENDTEXT 
		GF_SQLEXEC_P(lcSql, @laPar, lcCursor)
		SELECT (lcCursor)
		IF &lcCursor..STATUS_AKT != "N" THEN
	        obvesti("Pogodba ni neaktivna, procesa ni mogoèe nadaljevati.") && caption
			RETURN .F.
		ENDIF	
	ENDIF

	laPar[1] = lnId_cont
	IF GOBJ_LicenceManager.IsModuleEnabled("DIRECT_DEBIT") THEN
		IF !EMPTY(lnId_cont) THEN 
			lcCursor = SYS(2015)
			
			TEXT TO lcSql NOSHOW 	
				select a.id_tec, a.strong_payment, par.vr_osebe from dbo.pogodba a 
				inner join dbo.PARTNER par on a.ID_KUPCA = par.id_kupca 
				WHERE id_cont = ?p1
			ENDTEXT 
			
			GF_SQLEXEC_P(lcSql, @laPar, lcCursor)
			SELECT (lcCursor)
			
			IF &lcCursor..id_tec = "000" THEN 
			
				LOCAL laVr_osebe[1], llExists,lcVrstaOsebe 
				
				lcVrstaOsebe = &lcCursor..vr_osebe
				lcPartnerTypeSetting = GF_CustomSettings("Nova.App.DirectDebitSEPAPartnerTypeStrongPaymentNotMandatory")
				GF_Split(lcPartnerTypeSetting, ",", @laVr_osebe)
				llExists = ASCAN(laVr_osebe, lcVrstaOsebe ) > 0
				
				* Direct debit
				lResult = &lcCursor..strong_payment OR llExists = .T.
				IF ISNULL(lResult) OR (lResult) == .F. THEN 
					* TODO error
				ELSE		
					IF potrjeno("Želite vnesti še direktne bremenitve?", .T.) THEN && caption
						DO FORM dir_debit_maska WITH .F., 1, lnId_cont
					ENDIF   
				ENDIF 
			ENDIF
			IF USED(lcCursor) THEN 
				USE IN (lcCursor)
			ENDIF 
		ENDIF 
	ENDIF
	
	IF !EMPTY(lnId_cont) THEN 
		* Notifications
		laPar[1] = lnId_cont
		TEXT TO lcSql NOSHOW 
			SELECT count(*) FROM dbo.zap_reg WHERE id_cont = ?p1
		ENDTEXT 
		IF GF_SQLEXECScalar_P(lcSql, @laPar) > 0 THEN
			obvesti("Zapisnik za opremo, ki se registrira, je uvožen iz modula DSA.")
		ELSE 
			TEXT TO lcSql NOSHOW 
				SELECT count(*) FROM dbo.zap_ner WHERE id_cont = ?p1
			ENDTEXT 
			IF GF_SQLEXECScalar_P(lcSql, @laPar) > 0 THEN
				obvesti("Zapisnik za opremo, ki se ne registrira, je uvožen iz modula DSA.")
			ELSE 	
				TEXT TO lcSql NOSHOW 
					SELECT V.se_regis
			 	 	FROM dbo.pogodba P 
			 		INNER JOIN dbo.vrst_opr V ON P.id_vrste = V.id_vrste
			 		WHERE P.id_cont = ?p1
				ENDTEXT 
				lResult = GF_SQLExecScalar_P(lcSql, @laPar, .T.)
				IF ISNULL(lResult) OR TYPE('lResult') != "C" THEN 
					* TODO error
				ELSE
					llCustomSettingInsertZapReg = GF_CustomSettings("Nova.LE.InsertZapReg")
					IF !GF_NULLOREMPTY(llCustomSettingInsertZapReg) THEN
						llInsertZapReg = (LOWER(llCustomSettingInsertZapReg) = "true")
					ELSE
						llInsertZapReg = .F.
					ENDIF
					IF llInsertZapReg OR potrjeno("Želite vnesti še zapisnik?", .T.) THEN && caption
						IF ALLTRIM(lResult) == '*' THEN 
							DO FORM zap_reg_maska WITH lnId_cont,1 TO llSuccess
						ELSE 
							DO FORM zap_ner_maska WITH lnId_cont,1 TO llSuccess
						ENDIF 
					ENDIF
				ENDIF
			ENDIF	
		ENDIF
		
		* dodajanje poljubne kategorije na pogodbo
		IF !EMPTY(lnId_cont) THEN
			IF GF_CategoryEntityExists('POGODBA') THEN
				IF VAL(GF_CustomSettings("Nova.LE.NewContractKateg_tipEntry")) > 0 THEN
					llOpenKateg = .T.
					IF VAL(GF_CustomSettings("Nova.LE.NewContractKateg_tipEntry")) = 1 THEN
						IF !potrjeno("Želite za dodano pogodbo vnesti tudi poljubne kategorije?") THEN
							llOpenKateg = .F.
						ENDIF
					ENDIF
					IF llOpenKateg THEN
						DO FORM kategorije_entiteta_maska WITH "POGODBA", ALLTRIM(TRANSFORM(lnId_cont)), 1, "", .T.
					ENDIF
				ENDIF
			ENDIF
		ENDIF

		* Documentation
		DO ContractInsertDocs WITH lnId_cont

		* Payments
		DO ContractInsertPayments WITH lnId_cont
		
		* Provisions
		DO ContractInsertCommissions WITH lnId_cont, .F., .T.
		
		* Allocation of assets from credit contracts
		DO ContractInsertAllocateCredit WITH lnId_cont

		* Contract dashboard
		DO FORM pogodba_dashboard WITH lnId_cont 
		
		GF_EXT_FUNC('POGODBA_AFTER_INSERT_PROCESS')

	ENDIF 
ENDPROC

* Insert documantation for GF_ContractInsertProcess
PROCEDURE ContractInsertDocs(lnId_cont)
	IF potrjeno("Želite vnesti še dokumentacijo?",.T.) THEN && caption
		DO FORM dokument_pregled WITH lnId_cont, .T.
	ENDIF 
ENDPROC
 
* Insert payments for GF_ContractInsertProcess
PROCEDURE ContractInsertPayments(lnId_cont)
	IF GOBJ_Permissions.GetPermission('SpecialServicesRecapitulation') >= 2 AND Gobj_settings.Getval("ask_placdob_pog") = .T. THEN
		IF potrjeno("Želite vnesti predvidena plaèila dobavitelju?") THEN &&caption
			DO FORM plac_izh_dob WITH lnId_cont
		ENDIF
	ENDIF
ENDPROC

* Insert commissions for GF_ContractInsertProcess
PROCEDURE ContractInsertCommissions(lnId_cont, llRecursiveCall, llIzPog)
	LOCAL laSqlParams[1], lnProvPogCount, lnDsaProvPogCount
	
	laSqlParams[1] = NVL(lnId_cont, -1)
	lnProvPogCount = GF_SQLEXECScalar_P("SELECT count(*) as cnt FROM dbo.prov_pog WHERE id_cont = ?p1", @laSqlParams)
	lnDsaProvPogCount = GF_SQLEXECScalar_P("SELECT count(*) as cnt FROM dbo.INTG_DSA_PROV_POG WHERE id_cont = ?p1", @laSqlParams)

	* èe uporabljamo novi modul
	IF(GOBJ_LicenceManager.IsModuleEnabled("COMMISSIONS_AND_SELLERS") = .T.) THEN
		* preveri èe obstajajo NNP provizije za pogodbo prenešene iz DWC
		LOCAL lcSql, lnProvPogNotNpCount
		TEXT TO lcSql NOSHOW
			SELECT count(*) as cnt
			FROM 
			    dbo.INTG_DSA_PROV_POG dsa
			    INNER JOIN dbo.PROVIZIJE_IZRACUN p on dsa.id_provizije_izracun = p.id_provizije_izracun
			WHERE p.uporaba != 'NP' and dsa.ID_CONT = ?p1
		ENDTEXT
		lnProvPogNotNpCount = GF_SQLEXECScalar_P(lcSql , @laSqlParams)
		
		LOCAL llProvDiffSetting, llProdajalecJeKoncesija
		llProvDiffSetting = GF_CustomSettingsAsBool('Nova.LE.NewCommissionsModule.DiffBetweenNNPCommissions')
		llProdajalecJeKoncesija = GF_CustomSettingsAsBool('Nova.LE.NewCommissionsModule.PosrednikJeKoncesija')
		
		* èe so provizije že uvožene prek DSA
		IF lnProvPogCount > 0 AND lnDsaProvPogCount > 0 AND (lnProvPogNotNpCount = 0 OR (lnProvPogNotNpCount > 0 AND llProvDiffSetting = .F.)) THEN
			obvesti("Podatki o provizijah so uvoženi iz modula DSA.")
		ELSE
			* obstajajo NNP provizije uvožene iz dwc in setting za preraèun je true
			IF lnProvPogNotNpCount > 0 AND llProvDiffSetting = .T. THEN
			
				LOCAL lcSqlProvDefId, llShowDiffForm
				TEXT TO lcSqlProvDefId NOSHOW
					SELECT top 1 p.id_provizije as provision_def_id
					FROM dbo.INTG_DSA_PROV_POG dsa
					INNER JOIN dbo.PROVIZIJE_IZRACUN p on dsa.id_provizije_izracun = p.id_provizije_izracun
					WHERE dsa.ID_CONT = ?p1
				ENDTEXT
				GF_SQLEXEC_P(lcSqlProvDefId, @laSqlParams, "_prov_def_id")
			
				lcXML = ""
				lcXML = lcXML + '<get_calculated_commission xmlns="urn:gmi:nova:leasing">' + gcE
				lcXML = lcXML + GF_CreateNode("id_cont", lnId_cont, "N", 1) + gcE
				lcXML = lcXML + GF_CreateNode("id_provision_definition", _prov_def_id.provision_def_id, "N", 1) + gcE
				lcXML = lcXML + GF_CreateNode("recalculate", .T., "L", 1) + gcE
				lcXML = lcXML + '</get_calculated_commission>'
				
				USE IN _prov_def_id
				
				lcResult = GF_ProcessXml(lcXML,.T.,.T.)
				
				llShowDiffForm = GF_GetSingleNodeXml(lcResult, "provision_diff_exists")
				
				IF llShowDiffForm = 'true' THEN
					DO provisionsdiff IN frmparams_posebne_obdelave WITH lcResult 
				ELSE
					obvesti("Podatki o provizijah so uvoženi iz modula DSA.")
				ENDIF				
			ELSE
				* ali je potrebno vnesti provizije
				TEXT TO lcSql NOSHOW
					SELECT ze_proviz
					FROM dbo.pogodba
					WHERE id_cont = ?p1
				ENDTEXT
				lResult = GF_SQLExecScalar_P(lcSql, @laSqlParams, .T.)
				
				IF ISNULL(lResult) OR TYPE('lResult') != "L" THEN 
					* TODO error
				ELSE
					IF lResult = .T. THEN
						* napolni dropdown za izbor provizije
						lcXML = ""
						lcXML = lcXML + '<get_provision_definitions xmlns="urn:gmi:nova:leasing">' + gcE
						lcXML = lcXML + GF_CreateNode("id_cont", lnId_cont, "N", 1) + gcE
						lcXML = lcXML + '</get_provision_definitions>'
						lcResult = GF_ProcessXml(lcXML,.T.,.T.)
						
						* pripravi curzor				
						DIMENSION CursorDescription1(2,7)
						i = 1
						CursorDescription1(i,1) = "id"
						CursorDescription1(i,2) = "N"
						CursorDescription1(i,3) = 6
						CursorDescription1(i,4) = 0
						CursorDescription1(i,5) = .F.
						CursorDescription1(i,6) = .F.
						CursorDescription1(i,7) = "id"
						i = i + 1
						CursorDescription1(i,1) = "title"
						CursorDescription1(i,2) = "C"
						CursorDescription1(i,3) = 70
						CursorDescription1(i,4) = 0
						CursorDescription1(i,5) = .F.
						CursorDescription1(i,6) = .F.
						CursorDescription1(i,7) = "title"
						
						lcRootNode = "//get_provision_definitions_response/prov_def_id_title"
						
						* napolni kurzor
						GF_xml2cursor_2(@CursorDescription1, "_tmp_definicije_provizij", lcResult , lcRootNode, "elem")
						
						* preveri èe obstaja kakšna definicija, ki ustreza pogojem
						IF RECCOUNT("_tmp_definicije_provizij") > 0 THEN
							LOCAL lcIdProvDef, llError, lcPosrednik
							
							IF RECCOUNT("_tmp_definicije_provizij") > 1 THEN
								* pripravi dropdown	
								SELECT title, id FROM _tmp_definicije_provizij INTO ARRAY laDefinicijeProvizij
								lcTitle = "Izberi definicijo provizije" &&caption
								lcIdProvDef = GF_Get_Combobox(lcTitle, @laDefinicijeProvizij, 1, 2, 2, "325,0", .T., .T.)
								IF GF_NULLOREMPTY(lcIdProvDef) THEN
									RETURN
								ENDIF
							ELSE
								* èe obstaja samo ena definicija, ki ustreza pogojem jo izberi
								lcIdProvDef = _tmp_definicije_provizij.id
							ENDIF
							
							* preveri èe obstaja kalkulacija za provizije za izbranega posrednika in opozori èe ne obstaja
							TEXT TO lcSql NOSHOW
								select gr.VAL_CHAR as posrednik
								from 
								    dbo.POGODBA pog
								    left join dbo.gfn_g_register('p_posrednik') gr on pog.ID_POSREDNIK = gr.ID_KEY 
								where pog.ID_CONT = ?p1
							ENDTEXT
							lcPosrednik = GF_SQLEXECScalar_P(lcSql, @laSqlParams, .T.)
							
							IF !GF_NULLOREMPTY(lcPosrednik) AND llProdajalecJeKoncesija = .T. THEN 
								LOCAL laPar2[2], lnCount
								TEXT TO lcSql NOSHOW
									SELECT COUNT(*) as cnt 
									FROM dbo.PROVIZIJE_IZRACUN 
									WHERE 
									    id_provizije = ?p1
									    AND posrednik_id_kupca = ?p2
								ENDTEXT
								laPar2[1] = lcIdProvDef
								laPar2[2] = lcPosrednik
								lnCount = GF_SQLEXECScalar_P(lcSql, @laPar2)
								IF lnCount == 0 THEN
									IF potrjeno("Izbrana definicija za provizijo nima izraèuna za posrednika na pogodbi. Želite izbrati drugo definicijo?")&& caption
										DO ContractInsertCommissions WITH lnId_cont, .T., llIzPog
									ENDIF
								ENDIF
							ENDIF
							
							* èe so še enkrat izbrali definicijo se originalna procedura ne sme veè izvajati
							IF llRecursiveCall THEN
								RETURN
							ENDIF
							
							USE IN _tmp_definicije_provizij
							 
							* izraèun provizij v novi
							lcXML = ""
							lcXML = lcXML + '<get_calculated_commission xmlns="urn:gmi:nova:leasing">' + gcE
							lcXML = lcXML + GF_CreateNode("id_cont", lnId_cont, "N", 1) + gcE
							
							IF !GF_NULLOREMPTY(lcIdProvDef) THEN
								lcXML = lcXML + GF_CreateNode("id_provision_definition", lcIdProvDef, "N", 1) + gcE
							ENDIF
							
							lcXML = lcXML + '</get_calculated_commission>'
							lcResult = GF_ProcessXml(lcXML,.T.,.T.)
							
							llError = GF_GetSingleNodeXml(lcResult, "is_error")
							lcReturnMsg = GF_GetSingleNodeXml(lcResult, "return_msg")
							
							IF llError = 'true' AND !Gf_NullOrEmpty(lcReturnMsg) THEN
								obvesti(lcReturnMsg)
								RETURN
							ENDIF
							
							IF llError = 'true' THEN
								obvesti('Pri izraèunu provizij je prišlo do napake.')
							ENDIF
						ENDIF
						
						lnProvPogCount = GF_SQLEXECScalar_P("SELECT count(*) as cnt FROM dbo.prov_pog WHERE id_cont = ?p1 AND id_provizije_izracun IS NOT NULL", @laSqlParams)
						
						IF llIzPog THEN
							IF lnProvPogCount > 0 AND !GF_NULLOREMPTY(lcIdProvDef) THEN
								obvesti("Provizije so bile vnesene.")
							ELSE
								IF GOBJ_Permissions.GetPermission('SpecialServicesCommissions') >= 2 THEN
									IF potrjeno("Želite vnesti še podatke o provizijah?") THEN
										DO FORM prov_pog_pogodba WITH lnId_cont
									ENDIF
								ENDIF
							ENDIF		
						ELSE
							IF lnProvPogCount = 0 THEN
								obvesti("Avtomatski vnos provizij ni bil uspešen. Podatke o provizijah lahko vnesete roèno.")
							ENDIF
						ENDIF
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	ELSE 
		* brez novega modula
		* èe so provizije že uvožene prek DSA
		IF lnProvPogCount > 0 AND lnDsaProvPogCount > 0 THEN
			obvesti("Podatki o provizijah so uvoženi iz modula DSA.")
		ELSE
			TEXT TO lcSql NOSHOW
				SELECT ze_proviz
				FROM dbo.pogodba
				WHERE id_cont = ?p1
			ENDTEXT
			
			lResult = GF_SQLExecScalar_P(lcSql, @laSqlParams, .T.)
			IF ISNULL(lResult) OR TYPE('lResult') != "L" THEN 
				* TODO error
			ELSE
				IF lResult = .T. AND GOBJ_Permissions.GetPermission('SpecialServicesCommissions') >= 2 THEN
					IF potrjeno("Želite vnesti še podatke o provizijah?") THEN
						DO FORM prov_pog_pogodba WITH lnId_cont
					ENDIF
				ENDIF
			ENDIF
		ENDIF
	ENDIF
	
ENDPROC

* Allocation of assets from credit contracts
PROCEDURE ContractInsertAllocateCredit(lnId_cont)
	IF GOBJ_Permissions.GetPermission("ContractAllocationCreditContractsInsert") >= 2 AND ALLTRIM(GF_CustomSettings("Nova.LE.ContractInsertAskKredPogAlloc")) = "1" THEN
		IF potrjeno("Želite alocirati sredstva iz kreditnih pogodb?") THEN &&caption 
			DO FORM ccontracts_alloc WITH 1, lnId_cont, .F.
		ENDIF
	ENDIF
ENDPROC
**************************************************************************
* Function: Changes dates in amortisation plan 
* Parameters:
* tnId_cont - contract id 
* tcSt_dok - document number of the starting claim
* tcSt_dok_list - list of documents number for the rest of claims
* Returns: true/false

FUNCTION GF_ChangePPDates()
	LPARAMETERS tnId_cont, tcSt_dok, tcSt_dok_list
	IF PCOUNT() # 3 THEN 
		GF_NAPAKA(0, Program(), "", LOWPARAMETERS_LOC, 1)
		RETURN .F.
	ENDIF 
	
	LOCAL lcSql, llOnlyActive, lcPogStatAkt, lcAppMessage, lcSqlHash, laPar[1], laPar2[2]
	LOCAL ldNew_date, llDdsc, llCdd, llCac, lnHash, lcRpgCat, lcComment, llFourEyes, llSame_day, lnDni_zap_zacet_terj

	* Check if contract is prohibited from changing dates on payment plan (contract specialities)
	lcSql = "select dbo.gfn_ContractCanChangePaymentPlanDate(?p1, ?p2)" 
	laPar2[1] = tnId_cont
	laPar2[2] = DTOS(DATE())
	IF GF_SQLExecScalar_P(lcSql, @laPar2, .T.) = .F. THEN 
		lcAppMessage = GF_GetAppMessageForUser("EContractProhibitedChangePaymentPlanDate")
		POZOR(lcAppMessage)
		RETURN .F. 
	ENDIF 
	
	* insert "'" into the list, so that the list can be used in SQL IN statement
	IF !EMPTY(tcSt_dok_list)  THEN 
		tcSt_dok_list = "'" + STRTRAN(tcSt_dok_list, ",", "','") + "'"
	ENDIF 
	
	* Get starting claim
	lcSql = "SELECT * FROM dbo.planp WHERE st_dok = ?p1" 
	laPar[1] = ALLTRIM(tcSt_dok)
	GF_SQLEXEC_P(lcSql, @laPar, "_cppd_planp")
	
	* novododan custom setting
	llOnlyActive = GF_CustomSettingsAsBool("Nova.LE.4EyePrincip.OnlyActive")
	
	*Get contract data
	lcSql = "SELECT id_cont, status_akt, id_obd, id_datum_dok_create_type, id_rtip FROM dbo.pogodba WHERE id_cont = ?p1" 
	laPar[1] = _cppd_planp.id_cont
	GF_SQLEXEC_P(lcSql, @laPar, "_pog")
	SELECT _pog
	LOCATE 	
	
	** Four eyes
	IF GF_IsFourEyes_Active("Le.Reprogram.ChangePlanPDates") AND (_pog.status_akt = "A" OR (_pog.status_akt != "A" AND !llOnlyActive)) THEN 
		llFourEyes = .T.
	ELSE
		llFourEyes = .F.
	ENDIF 
	
	SELECT _cppd_planp
	* Check if the claim exists
	IF EOF("_cppd_planp") THEN 
		GF_NAPAKA(0, Program(), "", "Terjatev " + tcSt_dok + " ne obstaja!", 0) && caption
		RETURN .F.
	ENDIF 
	
	* Check if kredit > 0
	IF _cppd_planp.kredit > 0 THEN 
		lcAppMessage = "Terjatev je že dospela. Datum dokumenta ostane nespremenjen!" &&caption
		pozor(lcAppMessage)
		RETURN .F.
	ENDIF 

	* open form
	LOCAL loObject
	DO FORM pogodba_dashboard_changedates WITH llFourEyes TO loObject
	IF TYPE("loObject") # "O"
		RETURN .F.
	ENDIF
	
	ldNew_date = loObject.datum
	lcRpgCat = loObject.rpg_cat
	lcComment = loObject.opis
	llDdsc = loObject.ddsc
	llCdd = loObject.cdd
	llCaC = loObject.cac
	llSame_day = loObject.same_day
	lnDni_zap_zacet_terj = loObject.dni_zap_zacet_terj
	
	IF USED("_cppd_planp") THEN 
		USE IN _cppd_planp
	ENDIF 
	IF USED("_pog") THEN 
		USE IN _pog
	ENDIF 
	IF !llCaC THEN 
		tcSt_dok_list = "'" + tcSt_dok + "'"
	ENDIF 
	IF llSame_day THEN 
		tcSt_dok = loObject.st_dok
		tcSt_dok_list = loObject.st_dok_list
	ENDIF 
	
	lcSqlHash = "SELECT CHECKSUM_AGG(CHECKSUM(*)) FROM dbo.planp WHERE st_dok IN ({list_st_dok})"
	lcSqlHash = STRTRAN(lcSqlHash , "{list_st_dok}", ALLTRIM(tcSt_dok_list))
	lnHash = GF_SQLExecScalar(lcSqlHash)
	RETURN GF_APDateChange(tnId_cont, tcSt_dok, tcSt_dok_list, DTOT(ldNew_date), llDdsc, llCdd, llCac, lnHash, lcRpgCat, lcComment, llFourEyes, llSame_day, lnDni_zap_zacet_terj)
ENDFUNC 



***************************************************************
* this function check if given contract is the first
* contract on user's priority list.
* If such list exists and if contract isn't the first one,
* we display priority list ot user.
* The result value denotes if this contract was NOT the 
* first on priority list.
*
* tcIdKupca - customer id
* tnIdCont - contract id

FUNCTION GF_ShowContractPriority(tcIdKupca, tnIdCont)
    LOCAL tcSql, tbRes
    tcSql= "select id_cont, PRIORITETA, dbo.gfn_Id_pog4Id_cont(id_cont) as id_pog from dbo.prior_za where ID_KUPCA='" + tcIdKupca + "' order by prioriteta asc"
    GF_SQLExec(tcSql, 'cur_prior')

    tbRes = .f.
    
    * if priority list for this contract exists and if contract is not the first one.
    If (Reccount()>0) And (cur_prior.id_cont != tnIdCont) then

        * show list of contracts (listed by priority) to user
        Private lcMsg
        lcMsg = ""
        Scan
            lcMsg = lcMsg + STR(cur_prior.prioriteta) + ".->" + cur_prior.id_pog + Chr(13)+ Chr(10)
        Endscan
        obvesti("Prioriteta zapiranja pogodb tega partnerja je sledeèa:" + Chr(13) + Chr(10) + lcMsg) && caption

        tbRes = .t.
    Endif
    USE IN cur_prior
    RETURN tbRes
ENDFUNC 


***************************************************************
* this function returns description of given contract status id
*
* tcStatus - given status id

FUNCTION GF_GetContractStatusDesc(tcStatus)
    IF PCOUNT() # 1 THEN 
        GF_NAPAKA(0,GF_GetContractStatusDesc(),'',LOWPARAMETERS_LOC,1)
        RETURN .F.
    ENDIF 
    LOCAL lcDesc
    DO CASE
        CASE tcStatus = 'A' 
            lcDesc = POGODBA_AKTIVNA
        CASE tcStatus = 'N' 
            lcDesc = POGODBA_NEAKTIVNA
        CASE tcStatus = 'D' 
            lcDesc = POGODBA_DELNO_AKTIVNA
        CASE tcStatus = 'Z' 
            lcDesc = POGODBA_ZAKLJUCENA     
    ENDCASE
    RETURN lcDesc
ENDFUNC 

***************************************************************
* this function initiates snapshot transfer

FUNCTION GF_TransferSnapshot(loid_oc_report)


	IF TYPE("loid_oc_report") != "N" THEN
		loid_oc_report = -1 
	ENDIF

	*checks for permission
	IF GOBJ_Permissions.GetPermission('OC_SNAPSHOT_TRANSFER') < 2 THEN 
		pozor(STRTRAN(PERMISSION_DENIED, "{0}", "OC_SNAPSHOT_TRANSFER"))
		RETURN .F.
	ENDIF 
	
	* get settings 	
	* '0 - Ask, 1 - Do not ask, delete all snapshots in rea for the same intermediate by default, 2- Do not ask, do not delete ')
	lnActionAfterTransfer = VAL(GF_CustomSettings("Nova.LE.OcSnapshotsDeleteInReaAfterTransfer"))
	
	
	IF loid_oc_report = -1 THEN 
	    * fetch list of snapshot reports
	    GF_SqlExec("select ISNULL(description, '') as description, unit_name, id_oc_report, report_name, date_to, created_on, daily from dbo.Oc_Reports where filter_on_id_kupca = 0 and brisati = 0 order by created_on desc", "cur_snapshots")

	    IF RECCOUNT("cur_snapshots") = 0 THEN
	        USE IN cur_snapshots
	        obvesti("V podatkovni bazi ni pripravljenih posnetkov") && caption
	        RETURN
	    ENDIF
	    
	    LOCAL laA[1], lnSelect, lnI, lcPreparedOn, lnSnapshotExs, llOdg, lcMsg, lcSql, llOfficial, lnDateTo, lnLastDay, lcIdOcReport, lcSnapshotCode 
	    lcPreparedOn = "narejen" && caption
	    SELECT cur_snapshots
	    lnRecNo = RECCOUNT()
	    DIMENSION laA[lnRecNo, 2]
	    lnI = 1
	    SCAN
	        laA[lnI, 1] = "[" + ALLTRIM(unit_name) + " " + ALLTRIM(report_name)+ "] (" + DTOC(date_to) + ") (" + lcPreparedOn + ": " + TTOC(created_on) + ", "+ IIF(daily = .T., "D", "M") + ", Id: " + ALLTRIM(STR(id_oc_report)) + ") " + ALLTRIM(description)
	        laA[lnI, 2] = id_oc_report
	        lnI = lnI + 1
	    ENDSCAN
	    USE IN cur_snapshots
	    
	    DO FORM listbox_select WITH laA, '', 800, 600 TO lnSelect
	ENDIF     
    
    IF loid_oc_report >0 OR lnSelect > 0 THEN
    
    	IF loid_oc_report >0 THEN 
    		lnSnapshotExs = GF_SQLExecScalarNull("SELECT TOP 1 * FROM dbo.Oc_Reports WHERE id_oc_report_orig = " + TRANSFORM(loid_oc_report ), "snapshots")
		ELSE 
	    	lnSnapshotExs = GF_SQLExecScalarNull("SELECT TOP 1 * FROM dbo.Oc_Reports WHERE id_oc_report_orig = " + TRANSFORM(laA[lnSelect,2]), "snapshots")
	    ENDIF 
	    	
    	llOdg = .T.
    	IF !ISNULL(lnSnapShotExs) THEN
    		llOdg = POTRJENO("Posnetek, ki ga želite prenesti, že obstaja v skladišèu podatkov. Ali ga želite ponovno prenesti?")
    	ENDIF
    	
    	IF loid_oc_report >0 THEN 
    		lcIdOcReport = TRANSFORM(loid_oc_report)
    	ELSE 	
    		lcIdOcReport = TRANSFORM(laA[lnSelect,2])
    	ENDIF 	
    	
    	IF llOdg THEN 
    		lcSql = "SELECT date_to FROM dbo.Oc_Reports WHERE id_oc_report = {0}"
    		lcSql = STRTRAN(lcSql, "{0}", lcIdOcReport)
    		lnDateTo = TTOD(GF_SQLExecScalarNull(lcSql))
    		
    		lcSql = "SELECT code FROM dbo.Oc_Reports WHERE id_oc_report = {0}"
    		lcSql = STRTRAN(lcSql, "{0}", lcIdOcReport)
    		lcSnapshotCode = GF_SQLExecScalarNull(lcSql)
    		
    		lcSql = "SELECT dbo.gfn_GetLastDayOfMonth('{0}')"
    		lcSql = STRTRAN(lcSql, "{0}", DTOC(lnDateTo))
    		lnLastDay = TTOD(GF_SQLExecScalarNull(lcSql))
    		
    		llOfficial = .F.
    		
    		IF (lnDateTo == lnLastDay) THEN
    			lcSql = "SELECT TOP 1 id_oc_report, date_to FROM dbo.Oc_Reports WHERE date_to = '{0}' AND official = 1"
    			lcSql = STRTRAN(lcSql, "{0}", DTOS(lnDateTo))
    			GF_SQLExec(lcSql , "my_report", "snapshots")
    		
    			IF lcSnapshotCode = 'MAIN'
    				llOfficial = .T.
    			ELSE 
    				llOfficial = .F.
    			ENDIF 	
    				
	    		IF RECCOUNT("my_report") != 0 THEN
		    		lcMsg = "Uradni posnetek za TD {0} že obstaja (ID = {1}). Ali prenešeni posnetek nadomesti uradnega?" && caption
		    		lcMsg = STRTRAN(lcMsg, "{0}", DTOC(lnDateTo))
		    		lcMsg = STRTRAN(lcMsg, "{1}", ALLTRIM(STR(my_report.id_oc_report)))
		    		IF !POTRJENO(lcMsg)
	    				llOfficial = .F.
	    			ENDIF 
	    		ENDIF
    		ENDIF
    		
    		LOCAL lcVpr, llSucc 
    		llSucc = .T.
    		lcVpr = "Prenešeni posnetek je že obstajal v skladišèu podatkov. Ali želite izbrisati vse prejšnje prenose tega posnetka?" &&caption
    		IF GF_TransferOpenClaimsReport(lcIdOcReport, llOfficial) = .T. 
    			 IF !ISNULL(lnSnapShotExs) AND (lnActionAfterTransfer = 1 OR (lnActionAfterTransfer = 0 AND potrjeno(lcVpr)))
    			 	 IF (lnActionAfterTransfer = 1)
    			 	 	obvesti("Prenešeni posnetek je že obstajal v skladišèu podatkov. Izbrisani bodo vsi prejšnji prenosi tega posnetka ID = " + TRANSFORM(lcIdOcReport)) 
    			 	 ENDIF 	
	    		     lnCurrentSnapshot = GF_SQLExecScalarNull("SELECT TOP 1 id_oc_report FROM dbo.Oc_Reports WHERE id_oc_report_orig = " + TRANSFORM(lcIdOcReport) + " ORDER BY id_oc_report desc ", "snapshots") 
					 GF_SqlExec("SELECT id_oc_report FROM dbo.Oc_Reports WHERE id_oc_report_orig = " + TRANSFORM(lcIdOcReport) + " AND id_oc_report <> " + TRANSFORM(lnCurrentSnapshot) , "old_snapshots", "snapshots")
				  	 SELECT old_snapshots
				     SCAN
				     	WAIT WINDOW "Brišem posnetek ID = " + TRANSFORM(id_oc_report) TIMEOUT 5 
			    		llRes = GF_DeleteOpenClaimsReportInDWH(id_oc_report)	        
			    		llSucc = llSucc AND llRes &&zapomni rezultat obdelave
		    		 ENDSCAN
		    		 IF llSucc THEN 
		    		 	obvesti("Izbrisani so vsi prejšnji prenosi posnetka ID = " + TRANSFORM(lcIdOcReport)) 
		    		 ENDIF 
				     USE IN OLD_snapshots
			     ENDIF 
    		ENDIF 
    	ENDIF
    ENDIF
ENDFUNC

***************************************************************
* this function deletes selected snapshot
FUNCTION GF_DeleteSnapshot(loid_oc_report)

	IF TYPE("loid_oc_report") != "N" THEN
		loid_oc_report = -1 
	ENDIF

	*checks for permission
	IF GOBJ_Permissions.GetPermission('OC_SNAPSHOT_DELETE') < 2 THEN 
		pozor(STRTRAN(PERMISSION_DENIED, "{0}", "OC_SNAPSHOT_DELETE"))
		RETURN .F.
	ENDIF 
	
	IF(loid_oc_report = -1) then 
		* fetch list of snapshot reports
	    GF_SqlExec("select ISNULL(description, '') as description, unit_name, id_oc_report, report_name, date_to, created_on, daily from dbo.Oc_Reports where filter_on_id_kupca = 0 order by created_on desc", "cur_snapshots")

	    IF RECCOUNT("cur_snapshots") = 0 THEN
	        USE IN cur_snapshots
	        obvesti("V podatkovni bazi ni pripravljenih posnetkov") && caption
	        RETURN
	    ENDIF
	    
	    LOCAL laA[1], lnSelect, lnI, lcPreparedOn
	    lcPreparedOn = "narejen" && caption
	    SELECT cur_snapshots
	    lnRecNo = RECCOUNT()
	    DIMENSION laA[lnRecNo, 2]
	    lnI = 1
	    SCAN
	        laA[lnI, 1] = "[" + ALLTRIM(unit_name) + " " + ALLTRIM(report_name)+ "] (" + DTOC(date_to) + ") (" + lcPreparedOn + ": " + TTOC(created_on) + ", "+ IIF(daily = .T., "D", "M") + ", Id: " + ALLTRIM(STR(id_oc_report)) + ") " + ALLTRIM(description)
	        laA[lnI, 2] = id_oc_report
	        lnI = lnI + 1
	    ENDSCAN
	    USE IN cur_snapshots
	    
	    DO FORM listbox_select WITH laA, '', 800, 600 TO lnSelect
	    
	 ENDIF    
    
    IF loid_oc_report > 0 OR lnSelect > 0 THEN
        IF potrjeno("Ali želite izbrisati pripravljeni posnetek v glavni bazi?") THEN
        	IF loid_oc_report > 0 THEN 
	        	RETURN GF_DeleteOpenClaimsReport(TRANSFORM(loid_oc_report))
	        ELSE 	
            	RETURN GF_DeleteOpenClaimsReport(laA[lnSelect, 2])
            ENDIF 	
        ELSE
            RETURN .t.
        ENDIF
    ENDIF
ENDFUNC

*******************************
* Function for performing precalculation of automatic reprogram 
* tnIdCont - id_cont for contract 
* tdTargetDate - target date for automatic reprogram
*******************************

FUNCTION GF_AutoRpgPrecalc(tnIdCont, tdTargetDate)

    LOCAL lcXml
    lcXml = "<auto_rpg_precalc xmlns='urn:gmi:nova:leasing'><id_cont>" + XMLDataType(tnIdCont, "N", 1) + "</id_cont>"
    lcXml = lcXml + GF_CreateNode("target_date", tdTargetDate, "D", 1) + "</auto_rpg_precalc>"

    IF GF_ProcessXml(lcXml) THEN 
        lcXml = GObj_Comm.GetResult()
        
        LOCAL lcRes
        lcRes = GF_GetSingleNodeXml(lcXml, "recalculated_lower_ir")
        
        IF GF_NULLOREMPTY(lcRes) THEN
        	RETURN -1
        ENDIF 
        
        RETURN EVALUATE(lcRes)
    ELSE 
        RETURN -1
    ENDIF 
ENDFUNC

*******************************
* Function for performing initial interest rate and rabat precalculation of automatic reprogram 
* tnIdCont - id_cont for contract 
* tdTargetDate - target date for automatic reprogram
* tlSkipRebate - skip rebate calculation 
*******************************
FUNCTION GF_AutoRpgInitialIntRateSuggestion(tnIdCont, tdTargetDate, tlSkipRebate)
	LOCAL lcXml, loObj
	
	lcXml = "<auto_rpg_initial_int_rate_suggestion xmlns='urn:gmi:nova:leasing'>"
	lcXml = lcXml + GF_CreateNode("id_cont", tnIdCont, "N", 1)
	lcXml = lcXml + GF_CreateNode("target_date", tdTargetDate, "D", 1)
	lcXml = lcXml + GF_CreateNode("skip_rebate", tlSkipRebate, "L", 1)
	lcXml = lcXml + "</auto_rpg_initial_int_rate_suggestion>"
	
	loObj = CREATEOBJECT("custom")
	loObj.AddProperty("interest_rate", -1)
	loObj.AddProperty("rabate", 0)
	loObj.AddProperty("err_rabate", .F.)
	loObj.AddProperty("IsError", .T.)

	IF GF_ProcessXml(lcXml) THEN
		lcXml = GObj_Comm.GetResult()

		LOCAL lcRes
		lcRes = GF_GetSingleNodeXml(lcXml, "interest_rate")
		IF !GF_NULLOREMPTY(lcRes) THEN
			loObj.interest_rate = EVALUATE(lcRes)
		ENDIF 
		lcRes = GF_GetSingleNodeXml(lcXml, "rabate")
		IF !GF_NULLOREMPTY(lcRes) THEN
			loObj.rabate = EVALUATE(lcRes)
			loObj.err_rabate = IIF(loObj.rabate = -1, .T., .F.)
		ENDIF 
		loObj.IsError = .F.
	ENDIF 
	RETURN loObj
ENDFUNC

*******************************
*** Function for unlocking terminated contracts
*** (Odklepanje raèunovodsko zakljuèenih pogodb)
* tnid_cont - id_cont from contract to unlock
* tcid_pog - id_pog from contract to unlock
* tnsys_ts - sys_ts from contract record in table contract
* tcComment - comment about reason for unlocking
*******************************

FUNCTION GF_odkl_pog(tnid_cont, tcid_pog, tnsys_ts, tcComment)

    LOCAL lcXml
    lcXml = "<unlock_contract xmlns='urn:gmi:nova:leasing'><id_cont>" + XMLDataType(tnid_cont, "N", 1) + "</id_cont>"
    lcXml = lcXml + "<comment>" + XMLDataType(tcComment, "C", 1) + "</comment>"
    lcXml = lcXml + "<sys_ts>" + XMLDataType(tnsys_ts, "N", 1) + "</sys_ts></unlock_contract>"
    
    IF GF_ProcessXml(lcXml) THEN 
        LOCAL lcStr1, lcStr2
        lcStr1 = "Pogodba" &&caption
        lcStr2 = "je uspešno odklenjena." &&caption
        OBVESTI( lcStr1 + SPACE(1)+ ALLTRIM(tcid_pog) + SPACE(1)+ lcStr2) 
    ENDIF 
ENDFUNC


**************************************************
*** Function deletes selected contract
* tcNacin_leas - leas type of contract to be deleted
* tcStatus_akt - status of contract to be deleted
* tcOpombe - note that will be written in pogodba_deleted.opombe
* tcId_cont - of contract to be deleted
**************************************************
FUNCTION GF_DeleteContractBL(tcNacin_leas, tcStatus_akt, tcOpombe, tnId_cont)
LOCAL lcFakt_Zac, lnId_cont, ldDate, lcText
lcFakt_zac = GF_LookUp("nacini_l.fakt_zac", tcNacin_leas, "nacini_l.nacin_leas")
IF tcStatus_akt = 'A' AND (!ISNULL(lcFakt_zac) AND !EMPTY(lcFakt_zac)) THEN 
	* Get date od change
	IF GOBJ_Settings.GetVal("dni_zak_ddv") > 0
		ldDate = GF_GET_DATE('Vnesite datum spremembe')	&& Caption
		IF EMPTY(ldDate) OR ISNULL(ldDate)
			lcText = "Datum ne sme biti prazen." &&caption
			pozor(lcText)
			RETURN .F.
		ENDIF
		IF !GF_ValidDDVDate(ldDate, .F.) AND ldDate <> { . . } 
			POZOR("Datum je izven dovoljenega obdobja!")
			RETURN .F.
		ENDIF
	ELSE
		ldDate = DATE()
	ENDIF
	IF !GF_ValidBookingPeriod(ldDate, .F., .T.) THEN 
		IF !POTRJENO("Izbrani datum je v zakljuèenem obdobju knjiženja. Ali želite nadaljevati?")
			RETURN .F.
		ENDIF
	ENDIF
ELSE 
	ldDate = DATE()
ENDIF
IF GF_DeleteContract(tnId_cont, ldDate, tcOpombe) THEN 
	obvesti("Pogodba uspešno izbrisana.")
 	RETURN .T.
ELSE 
	RETURN .F.
ENDIF 
ENDFUNC 


**************************************************
*** Function changes contract status
* tnId_cont - contract id
* tcNewStatus - new status
**************************************************
FUNCTION GF_ChangeContractStatus(tnId_cont, tcNewStatus)
    && get contract hash
    LOCAL lnContract_hash
    lnContract_hash = GF_SQLEXECSCALAR("SELECT dbo.gfn_GetContractDataHash("+TRANSFORM(tnId_cont)+")")

    && get old status, create copy and change it with new one
    GF_SQLEXEC("SELECT status FROM dbo.pogodba WHERE id_cont = "+TRANSFORM(tnId_cont), 'pogodba_new')
    SELECT * FROM pogodba_new INTO CURSOR pogodba_old
    REPLACE status WITH tcNewStatus IN pogodba_new
    
    && create XML with instructions and call reprogram
    LOCAL lcXML, lcComment
    lcComment = "Menjava statusa pogodbe" && caption
    lcXML = GF_CreateContractUpdateXML(tnId_cont, lcComment, lnContract_hash, "", "pogodba_new", "pogodba_old")
    
    && if nothing is to be changed, do not call the server
    IF LEN(ALLTRIM(lcXml)) = 0 THEN 
    	RETURN .t.
    ENDIF 
    RETURN GF_ProcessXml(lcXML)
ENDPROC 


**************************************************
*** Function changes contract status
* tnId_cont - contract id
* tcNewStatus - new status
**************************************************
PROCEDURE GF_HypoSI_PartnerSync()

    WAIT WINDOW PRIPRAVLJAM_PODATKE nowait 
    IF GF_ProcessXml("<hypoce_transfer_partners/>") THEN 
        WAIT CLEAR
        LOCAL lcXml
        lcXml = GObj_Comm.GetResult()
        XMLTOCURSOR(lcXml, "cur_msgs")
        BROWSE 
        USE IN cur_msgs
    ELSE 
        WAIT CLEAR
    ENDIF 
ENDPROC 

*****************************************************************
*!* authorization form for outgoing payments 
*!* return id_avtorizant if auhorization was successful

FUNCTION GF_PLAC_IZH_AVTOR(tnVrsta, tnZnesek, tnVrednostPogodbe, tcTec, tdDatum, tcOpomba, tcPrejemnik, tcZnesek, tcPogodba, tcPartner)
LOCAL loResult
DO FORM plac_izh_avt WITH tnVrsta, tnZnesek, tnVrednostPogodbe, tcTec, tdDatum, tcPrejemnik, tcZnesek, tcPogodba, tcPartner TO loResult
tcOpomba = loResult.opomba
RETURN loResult.Avtorizant
ENDFUNC
*****************************************************************


*****************************************************************
*!* GF_PRIOR_REDEMPTION_CURSORS
*!* create cursors for prior redemption 

FUNCTION GF_PRIOR_REDEMPTION_CURSORS(tcCursorMaster, tcCursorDetail, tcXML, tlExecute)
LOCAL lcXMLResult, lcCursorMaster, lcCursorCalcData, lcCursorOtherData, lcRootNode
LOCAL laCursorDescription[1], laCursorCalcDataDescription[1], laCursorOtherDataDescriptio[1], laCursorDetailDescription[1]

	* 1. execute XML	
	IF tlExecute = .T. THEN
		lcXMLResult = GF_ProcessXml(tcXML, .T., .T.)
	ELSE
		lcXMLResult = ""
	ENDIF
	
    * 2. prepare master cursor
    DIMENSION laCursorDescription[1,1]
    DO PriorRedemptionCursor IN frmparams_contractpv WITH laCursorDescription
    lcRootNode = "//offer_prior_redemption/input_data"
	lcCursorMaster = SYS(2015)
    GF_XML2Cursor(@laCursorDescription, lcCursorMaster, lcXMLResult, lcRootNode)
    
    DIMENSION laCursorCalcDataDescription[1,1]
    DO PriorRedemptionCalcDataCursor IN frmparams_contractpv WITH laCursorCalcDataDescription
    lcRootNode = "//offer_prior_redemption/output_data/calculated_data"
 	lcCursorCalcData = SYS(2015)
    GF_XML2Cursor(@laCursorCalcDataDescription, lcCursorCalcData, lcXMLResult, lcRootNode)

    DIMENSION laCursorOtherDataDescription[1,1]
    DO PriorRedemptionOtherDataCursor IN frmparams_contractpv WITH laCursorOtherDataDescription
    lcRootNode = "//offer_prior_redemption/output_data/other_data"
 	lcCursorOtherData = SYS(2015)
    GF_XML2Cursor(@laCursorOtherDataDescription, lcCursorOtherData, lcXMLResult, lcRootNode)

	SELECT M.*, C.*, O.* FROM (lcCursorMaster) M, (lcCursorCalcData) C, (lcCursorOtherData) O INTO CURSOR (tcCursorMaster)
	USE IN (lcCursorMaster)
	USE IN (lcCursorCalcData)
	USE IN (lcCursorOtherData)

    * 3. prepare cursor detail 
    DIMENSION laCursorDetailDescription[1,1]
    DO PriorRedemptionDetailCursor IN frmparams_contractpv WITH laCursorDetailDescription
    lcRootNode = "//offer_prior_redemption/xml_detail_object_data/GBO_OfferPriorredemptionDetails"
    GF_XML2Cursor(@laCursorDetailDescription, tcCursorDetail, lcXMLResult, lcRootNode)

    RETURN lcXMLResult
ENDFUNC

***********  END OF GF_PRIOR_REDEMPTION_CURSORSGF_PRIOR_REDEMPTION_XML  ***********

*****************************************************************
* prepare and execute XML (ProcessXml) to delete out. payments

FUNCTION GF_DELETE_OUT_PAY(tnIdPlacIzh)

LOCAL lcE, lcXMLDoc 

* Prepare XML with input parameters and data

lcE = CHR(10) + CHR(13) 
lcXMLDoc = "<plac_izh_delete xmlns='urn:gmi:nova:core_bl'>" + m.lcE
lcXMLDoc = m.lcXMLDoc + "<id_plac_izh>" +  XMLDataType(tnIdPlacIzh, "I",1) + "</id_plac_izh>" + m.lcE
lcXMLDoc = m.lcXMLDoc + "</plac_izh_delete>"
IF GF_ProcessXml(m.lcXMLDoc) 
    RETURN .T.
ELSE
    RETURN .F.
ENDIF

ENDFUNC
***********  END OF GF_DELETE_OUT_PAY   ***********

FUNCTION GF_CHECK_MODEL_AND_REF_NO(tcModel, tcRefNo, tlShowMsg)


    tcModel= ALLTRIM(tcModel)
    tcRefNo= ALLTRIM(tcRefNo)

    * Only Croatian banks allow empty model
    IF EMPTY(tcModel) AND !(GObj_Settings.GetVal("DRZAVA") == "HR" OR GObj_Settings.GetVal("DRZAVA") == "BA")
        IF tlShowMsg THEN
            Obvesti("Model ne sme biti prazen!") && caption
        ENDIF   
        RETURN .F.  
    ENDIF 

    * Check if model is valid!
    * Returns False if method GF_TestModel fails otherwise True.
    IF !GF_TestModel(tcModel) 
        RETURN .F.
    ENDIF 

    * Allow empty Reference number so that user can exit the field in case he is 
    * not able to produce a valid ref. no.
    IF EMPTY(tcRefNo)
        RETURN .t.
    ENDIF 

    * Check if reference number is valid!
    * Returns False if method GF_TestReferenceNumber fails otherwise True.
    IF !GF_TestReferenceNumber(tcModel, tcRefNo) 
        RETURN .F.
    ENDIF

    RETURN .T.

ENDFUNC
***********  END OF GF_CHECK_MODEL_AND_REF_NO   ***********

FUNCTION GF_COMMISSIONS_MANIPULATE(tcStatus, tArrayOfIds, tcid_kupca) 

LOCAL lcXMLDoc,lcE, lnStev  
EXTERNAL ARRAY tArrayOfIds 

	LOCAL lcXmlRequest
	LOCAL lcXmlResult
	LOCAL lcXml 

	LOCAL lxXml
	LOCAL lcE
	LOCAL i

	lcE = CHR(13) + CHR(10)
	i=0

	SELECT prov_pog

	lxXml = "<process_commissions xmlns:xsd="+CHR(34)+"http://www.w3.org/2001/XMLSchema"+CHR(34)+" xmlns:xsi="+CHR(34)+"http://www.w3.org/2001/XMLSchema-instance"+CHR(34)+" xmlns="+CHR(34)+"urn:gmi:nova:leasing"+CHR(34)+">" + lcE 
	lxXml = lxXml + GF_CreateNode("action", "MarkPrintedCommissions", "C", 1) + lcE 
	*oznaèi v shemi kot neobvezne
	lxXml = lxXml + GF_CreateNode("customer_id", "", "C", 1) + lcE  
	lxXml = lxXml + GF_CreateNode("package_id", "0", "C", 1) + lcE 
	lxXml = lxXml + GF_CreateNode("old_package_checksum", "", "C", 1) + lcE 

	    IF !EMPTY(tArrayOfIds(1)) THEN      
	        FOR lnStev = 1 TO ALEN(tArrayOfIds,1)
			lxXml = lxXml + "<records>" + lcE 
			lxXml = lxXml + GF_CreateNode("commision_record_id", XMLDataType(tArrayOfIds(lnStev,1), "I",1), "I", 1) + lcE 
			lxXml = lxXml + GF_CreateNode("commision_record_timestamp", XMLDataType(tArrayOfIds(lnStev,2), "I",1) , "C", 1) + lcE 
			lxXml = lxXml + "</records>" + lcE 
	        ENDFOR
	    ENDIF   

	lxXml = lxXml + "</process_commissions>" 
	lcXmlRequest = lxXml

	IF GF_ProcessXml(lcXmlRequest, .F., lcXmlResult) THEN
        RETURN .T.
	ELSE
        RETURN .F.
	ENDIF

ENDFUNC
***********  END OF GF_COMMISSIONS_MANIPULATE   ***********


*******************************
*** Function for checking frame availability for contract
* Parameters:
* toContract - contract object - contains all fields of selected contract
* toFrameList - frame object - contains all fiels of selected frame
* Returns: true/false
*******************************

FUNCTION GF_CheckFrameAvailabilityForContract
LPARAMETERS toContract, toFrameList
	LOCAL lcSql, lcFrameType, lnObligo, lnFrameRes, lcObv, llReturn, lnDavek, lcFinbruto, lcDav_n, lcStatus_akt, ldDat_aktiv, llImaRobresti, lcDav_b, lnMpc

	llReturn = .T.
	lcFrameType = toFrameList.sif_frame_type

	* Get current obligo for contract
	IF lcFrameType = "REV" OR lcFrameType = "RFO" OR lcFrameType = "RNE" THEN
		TEXT TO lcSql NOSHOW
			SELECT dbo.gfn_XChange('{0}', {OBLIGO}, pp.id_tec, '{1}') AS obligo
			  FROM dbo.planp_ds pp
			  INNER JOIN dbo.pogodba po ON po.id_cont = pp.id_cont
			  INNER JOIN dbo.nacini_l nl ON nl.nacin_leas = po.nacin_leas
			  INNER JOIN dbo.dav_stop ds ON ds.id_dav_st = po.id_dav_st
			 WHERE pp.id_cont = {2}
			   AND pp.id_kupca = '{3}'
			 GROUP BY pp.id_tec
		ENDTEXT
		lcSql = STRTRAN(lcSql, "{0}", toContract.id_tec)
		lcSql = STRTRAN(lcSql, "{1}", DTOS(toContract.dat_sklen))
		lcSql = STRTRAN(lcSql, "{2}", IIF(TYPE("toContract.id_cont") = "U", "NULL", TRANSFORM(toContract.id_cont)))
		lcSql = STRTRAN(lcSql, "{3}", toContract.id_kupca)
		
		DO CASE
			CASE lcFrameType = "REV" 
				lcSql = STRTRAN(lcSql, "{OBLIGO}", "SUM(pp.znp_saldo_brut_all + pp.bod_neto_lpod)")
			CASE lcFrameType = "RFO"
				lcSql = STRTRAN(lcSql, "{OBLIGO}", "SUM(pp.znp_saldo_brut_all + pp.bod_debit_brut_ALL - pp.bod_obresti_LPOD - case when nl.dav_o = 'D' then pp.bod_obresti_LPOD * (ds.davek / 100) else 0 end)")
			CASE lcFrameType = "RNE"
				lcSql = STRTRAN(lcSql, "{OBLIGO}", "SUM(pp.znp_saldo_ddv + pp.bod_davek_lpod)")
		ENDCASE
		
		lnObligo = GF_SQLExecScalarNull(lcSql)
	ENDIF 
	
	* Get residual value of approved value and used frame
	TEXT TO lcSql NOSHOW
		SELECT dbo.gfn_GetFrameResidual({0}, {1}, '{2}','{3}')
	ENDTEXT
	lcSql = STRTRAN(lcSql, "{0}", TRANSFORM(toFrameList.id_frame))
	lcSql = STRTRAN(lcSql, "{1}", IIF(TYPE("toContract.id_cont") = "U", "NULL", TRANSFORM(toContract.id_cont)))
	lcSql = STRTRAN(lcSql, "{2}", toContract.id_tec)
	lcSql = STRTRAN(lcSql, "{3}", DTOS(toContract.dat_sklen))
	lnFrameRes = GF_SQLExecScalarNull(lcSql)
	DO CASE
		CASE lcFrameType = "REV"
			lcStatus_akt = IIF(TYPE("toContract.id_cont") = "U", "N", GF_LOOKUP("pogodba.status_akt", toContract.id_cont, "pogodba.id_cont"))
			ldDat_aktiv = IIF(TYPE("toContract.id_cont") = "U", null, GF_LOOKUP("pogodba.dat_aktiv", toContract.id_cont, "pogodba.id_cont"))
			lnFrameRes = lnFrameRes - IIF(ISNULL(lnObligo) AND (lcStatus_akt = "Z" OR (lcStatus_akt = "A" AND DATE() - TTOD(ldDat_aktiv) > 5)), 0, ;
											IIF(ISNULL(lnObligo), toContract.vr_val, lnObligo))
		
		CASE lcFrameType = "RFO"
			lcStatus_akt = IIF(TYPE("toContract.id_cont") = "U", "N", GF_LOOKUP("pogodba.status_akt", toContract.id_cont, "pogodba.id_cont"))
			ldDat_aktiv = IIF(TYPE("toContract.id_cont") = "U", null, GF_LOOKUP("pogodba.dat_aktiv", toContract.id_cont, "pogodba.id_cont"))
			lcFinbruto = GF_LOOKUP("nacini_l.finbruto", toContract.nacin_leas, "nacini_l.nacin_leas")
			lcDav_n = GF_LOOKUP("nacini_l.dav_n", toContract.nacin_leas, "nacini_l.nacin_leas")
			lnDavek = GF_LOOKUP("dav_stop.davek", toContract.id_dav_st, "dav_stop.id_dav_st")
			llImaRobresti = GF_LOOKUP("nacini_l.ima_robresti", toContract.nacin_leas, "nacini_l.nacin_leas")
			lcDav_b = GF_LOOKUP("nacini_l.dav_b", toContract.nacin_leas, "nacini_l.nacin_leas")
			
			lnFrameRes = lnFrameRes - IIF(ISNULL(lnObligo) AND (lcStatus_akt = "Z" OR (lcStatus_akt = "A" AND DATE() - TTOD(ldDat_aktiv) > 5)), 0, ;
											IIF(ISNULL(lnObligo), GF_VrValToBruto(toContract.vr_val, toContract.robresti_val, lnDavek, llImaRobresti, lcDav_b, lcFinbruto, lcDav_n) + toContract.man_str + toContract.stroski_x + ;
											  toContract.stroski_pz + toContract.stroski_zt + toContract.zav_fin + toContract.str_financ, lnObligo))
		CASE lcFrameType = "NET"
			lnFrameRes = lnFrameRes - toContract.net_nal_zac
		
		CASE lcFrameType = "POG"
			lnFrameRes = lnFrameRes - toContract.vr_val_zac
			
		CASE lcFrameType = "RNE"
			lcStatus_akt = IIF(TYPE("toContract.id_cont") = "U", "N", GF_LOOKUP("pogodba.status_akt", toContract.id_cont, "pogodba.id_cont"))
			ldDat_aktiv = IIF(TYPE("toContract.id_cont") = "U", null, GF_LOOKUP("pogodba.dat_aktiv", toContract.id_cont, "pogodba.id_cont"))
			lnFrameRes = lnFrameRes - IIF(ISNULL(lnObligo) AND (lcStatus_akt = "Z" OR (lcStatus_akt = "A" AND DATE() - TTOD(ldDat_aktiv) > 5)), 0, ;
											IIF(ISNULL(lnObligo), toContract.ddv, lnObligo)) - toContract.net_nal_zac
											
		CASE lcFrameType = "MPC"
		lnMpc =  GF_XCHANGE(toContract.id_tec, toContract.mpc, '000' , toContract.dat_sklen)
		lnFrameRes = lnFrameRes - lnMpc 
									
			
	ENDCASE

	IF lnFrameRes < 0 THEN
		lcObv = "Odobreni znesek okvira je presežen za" + SPACE(1) + LTRIM(TRANSFORM(ABS(m.lnFrameRes), m.gcCif)) + SPACE(1) + toContract.id_val + "!" + CHR(13) + CHR(10)  && Caption
		lcObv = lcObv + "Želite nadaljevati?"  && Caption
		llReturn = potrjeno(lcObv)
	ENDIF
RETURN llReturn
ENDFUNC
***********  END OF GF_CheckFrameAvailabilityForContract  ***********

FUNCTION GF_ProcessPaymentIndisciplineIndex

	LOCAL ldTargetDateNew, ldTargetDatePrevious, lcText, lcCaption, llOK, lcErrorMsg
	
	* check permissions
	IF GOBJ_Permissions.GetPermission("PaymentIndisciplineIndex") < 2 THEN 
		pozor(STRTRAN(PERMISSION_DENIED, "{0}", "PaymentIndisciplineIndex"))
		RETURN .F.
	ENDIF

	ldTargetDatePrevious = GF_SQLExecScalar("SELECT date_to FROM dbo.wavg_zam_settings")
	ldTargetDatePrevious = TTOD(ldTargetDatePrevious)
	
	lcCaption = "Izraèun indeksa plaèilne nediscipline" && Caption
	lcText = "Vnesite datum, na katerega naj se izraèuna indeks plaèilne nediscipline (datum zadnjega izraèuna je {0})" && Caption
	lcText = STRTRAN(lcText, "{0}", DTOC(ldTargetDatePrevious))

	ldTargetDateNew = GF_GET_DATE(lcText, DATE(), "D", .T., lcCaption)

	IF EMPTY(ldTargetDateNew) THEN
		RETURN
	ENDIF

	llOK = GF_PreparePaymentIndisciplineIndex(ldTargetDateNew)
	
	IF llOK THEN
		obvesti("Rutina uspešno konèana.")
	ENDIF
	
	RETURN

ENDFUNC
***********  END OF GF_ProcessPaymentIndisciplineIndex  ***********

FUNCTION GF_ReprogramIntRateChange(loReproParams)
	IF TYPE("loReproParams") != "O" THEN
		GF_NAPAKA(0,GF_ReprogramIntRateChange(), '', PARAM_TYPE_LOC, 1)
	ENDIF
	
	LOCAL lcXml, lcXmlResult, i
	
	lcXml = "<rpg_interest_rate_change xmlns='urn:gmi:nova:leasing'>"
	lcXml = lcXml + GF_CreateNode("interest_rate_type", loReproParams.interest_rate_type, "C", 1)
	IF PEMSTATUS(loReproParams, "interest_rate_change_percent", 5) = .T. THEN
		lcXml = lcXml + GF_CreateNode("interest_rate_change_percent", loReproParams.interest_rate_change_percent, "N", 1)
	ELSE
		lcXml = lcXml + GF_CreateNode("interest_rate_change_value", loReproParams.interest_rate_change_value, "N", 1)
	ENDIF
	lcXml = lcXml + GF_CreateNode("id_rep_category", loReproParams.id_rep_category, "C", 1)
	lcXml = lcXml + GF_CreateNode("reprogram_date_from", loReproParams.reprogram_date_from, "D", 1)
	lcXml = lcXml + GF_CreateNode("comment", loReproParams.comment, "C", 1)
	
	FOR i = 1 TO ALEN(loReproParams.contract_list)
		lcXml = lcXml + GF_CreateNode("contract_list", loReproParams.contract_list[i], "N", 1)
	ENDFOR
	
	lcXml = lcXml + GF_CreateNode("simulation", loReproParams.simulation, "L", 1)
	lcXml = lcXml + GF_CreateNode("is_installment_credit", loReproParams.is_installment_credit, "L", 1)
	lcXml = lcXml + "</rpg_interest_rate_change>"

	lcXmlResult = GF_ProcessXml(lcXml, .T., .T.)
	
	IF TYPE("lcXmlResult") = "C" THEN
		IF loReproParams.simulation = .F. THEN
			obvesti("Reprogram je zakljuèen.")
		ELSE
			obvesti("Simulacija reprograma je zakljuèena.")
		ENDIF
	ELSE
		RETURN .F.
	ENDIF
	
	RETURN GF_GetSingleNodeXml(lcXmlResult, "session_id")
	
ENDFUNC
***********  END OF GF_ReprogramIntRateChange***********

***********  END OF GF_ClearContractSpecialities  ***********

FUNCTION GF_ClearContractSpecialities
	LOCAL lcXml
	
	lcXml = "<clear_contract_specialities xmlns='urn:gmi:nova:leasing'>"
	lcXml = lcXml + "</clear_contract_specialities>"
	RETURN GF_ProcessXml(lcXml)
	
ENDFUNC
***********  END OF GF_ClearContractSpecialities  ***********

FUNCTION GF_CDTransfer(llFor_single_user)

	LOCAL lcXml, lcXmlResult	
	
	lcXml = "<cd_transfer xmlns='urn:gmi:nova:leasing'>"
	lcXml = lcXml + GF_CreateNode("for_single_user", llFor_single_user, "L", 1)
	lcXml = lcXml + "</cd_transfer>"

	lcXmlResult = GF_ProcessXml(lcXml, .T., .T.)
	
	IF TYPE('lcXmlResult ') = "C" then	
		RETURN GF_GetSingleNodeXml(lcXmlResult, "id_diary")
	ELSE 	
		RETURN '-1'
	ENDIF 	

ENDFUNC 
***********  END OF GF_CDTransfer***********

***********  END OF GF_ZobrMassStornoCancelletion***********

FUNCTION GF_ZobrMassStornoCancelletion(loCancellationParams)
	IF TYPE("loCancellationParams") != "O" THEN
		GF_NAPAKA(0,GF_ZobrMassStornoCancelletion(), '', PARAM_TYPE_LOC, 1)
	ENDIF
	
	LOCAL lcXml, lcXmlResult, i
	
	lcXml = "<zobr_mass_cancellation xmlns='urn:gmi:nova:leasing'>"
	lcXml = lcXml + GF_CreateNode("cancellation_type", loCancellationParams.cancellation_type, "C", 1)
	lcXml = lcXml + GF_CreateNode("cancellation_date", loCancellationParams.cancellation_date, "D", 1)
	IF PEMSTATUS(loCancellationParams, "percent", 5) = .T. THEN
		lcXml = lcXml + GF_CreateNode("percent", loCancellationParams.percent, "N", 1)
	ENDIF
	IF PEMSTATUS(loCancellationParams, "obr_mera", 5) = .T. THEN
		lcXml = lcXml + GF_CreateNode("obr_mera", loCancellationParams.obr_mera, "N", 1)
	ENDIF
	lcXml = lcXml + GF_CreateNode("comment", loCancellationParams.comment, "C", 1)
	
	FOR i = 1 TO ALEN(loCancellationParams.st_dok_list)
		lcXml = lcXml + GF_CreateNode("st_dok_list", loCancellationParams.st_dok_list[i], "C", 1)
	ENDFOR
	
	lcXml = lcXml + GF_CreateNode("simulation", loCancellationParams.simulation, "L", 1)
	lcXml = lcXml + GF_CreateNode("id_rep_category", loCancellationParams.id_rep_category, "C", 1)
	lcXml = lcXml + "</zobr_mass_cancellation>"

	lcXmlResult = GF_ProcessXml(lcXml, .T., .T.)
	
	IF TYPE("lcXmlResult") = "C" THEN
		IF loCancellationParams.simulation = .F. THEN
			obvesti("Stornacija je zakljuèena.")
		ELSE
			obvesti("Izraèun za storno je zakljuèen.")
		ENDIF
	ELSE
		RETURN .F.
	ENDIF
	
	RETURN GF_GetSingleNodeXml(lcXmlResult, "session_id")
	
ENDFUNC
***********  END OF GF_ZobrMassStornoCancelletion***********

***************************************************************
* this function clone selected snapshot
FUNCTION GF_CloneSnapshot(loid_oc_report)

	IF TYPE("loid_oc_report") != "N" THEN
		loid_oc_report = -1 
	ENDIF

	*checks for permission
	IF GOBJ_Permissions.GetPermission('OC_SNAPSHOT_CLONE') < 2 THEN 
		pozor(STRTRAN(PERMISSION_DENIED, "{0}", "OC_SNAPSHOT_CLONE"))
		RETURN .F.
	ENDIF

	LOCAL lcSql, lnOcSnapshotsCnt, lnOcSnapshotsMaxNum, lnOcSnapshotsApproachingMaxNum
	* check the number of prepared intermediate snapshots
	TEXT TO lcSql NOSHOW
		SELECT COUNT(*) FROM dbo.oc_reports
	ENDTEXT	
	lnOcSnapshotsCnt = GF_SQLExecScalarNull(lcSql)
	lnOcSnapshotsMaxNum = VAL(GF_CustomSettings("Nova.LE.OcSnapshotsMaxNum"))
	lnOcSnapshotsApproachingMaxNum = VAL(GF_CustomSettings("Nova.LE.OcSnapshotsApproachingMaxNum"))
	
	IF !EMPTY(lnOcSnapshotsMaxNum) THEN
		IF lnOcSnapshotsCnt >= lnOcSnapshotsMaxNum THEN
			lcObv = GF_GetAppMessageForUser("ESnapshot_ExceedMaxNumOfSnapshots")
			lcObv = STRTRAN(lcObv, "{0}", ALLTRIM(TRANSFORM(lnOcSnapshotsCnt)))
			lcObv = STRTRAN(lcObv, "{1}", ALLTRIM(TRANSFORM(lnOcSnapshotsMaxNum)))
			pozor(lcObv)
			RETURN .F.
		ELSE IF (lnOcSnapshotsCnt >=  lnOcSnapshotsMaxNum - lnOcSnapshotsApproachingMaxNum)	THEN 
			lcObv = GF_GetAppMessageForUser("ESnapshot_ApproachingMaxNumOfSnapshots")
			lcObv = STRTRAN(lcObv, "{0}", ALLTRIM(TRANSFORM(lnOcSnapshotsCnt)))
			lcObv = STRTRAN(lcObv, "{1}", ALLTRIM(TRANSFORM(lnOcSnapshotsMaxNum)))
			pozor(lcObv)		
		ENDIF
		
	ENDIF
	
	IF (loid_oc_report = -1) THEN 

		* fetch list of snapshot reports
		TEXT TO lcSql NOSHOW
			SELECT ISNULL(description, '') as description, unit_name, id_oc_report, report_name, date_to, created_on, id_oc_settings, daily
			  FROM dbo.oc_reports 
			 WHERE filter_on_id_kupca = 0
			   AND brisati = 0
			 ORDER BY created_on DESC
		ENDTEXT
	    GF_SqlExec(lcSql, "cur_snapshots")

	    IF RECCOUNT("cur_snapshots") = 0 THEN
	        USE IN cur_snapshots
	        obvesti("V podatkovni bazi ni pripravljenih posnetkov")
	        RETURN .F.
	    ENDIF
	    
	    LOCAL laA[1], lnSelect, lnI, lcPreparedOn
	    lcPreparedOn = "narejen" && caption
	    SELECT cur_snapshots
	    lnRecNo = RECCOUNT()
	    DIMENSION laA[lnRecNo, 2]
	    lnI = 1
	    SCAN
	        laA[lnI, 1] = "[" + ALLTRIM(unit_name) + " " + ALLTRIM(report_name)+ "] (" + DTOC(date_to) + ") (" + lcPreparedOn + ": " + TTOC(created_on) + ", "+ IIF(daily = .T., "D", "M") + ", Id: " + ALLTRIM(STR(id_oc_report)) + ") " + ALLTRIM(description)
	        laA[lnI, 2] = id_oc_report
	        lnI = lnI + 1
	    ENDSCAN
	    USE IN cur_snapshots
	    
	    DO FORM listbox_select WITH laA, '', 800, 600 TO lnSelect    
	    
	    
	ENDIF     
	    
    LOCAL lnIdOcReportOld, lnIdSnapshotSettings, llprepare_oc_dokument, llprepare_oc_lsk_and_oc_gl, llprepare_oc_fa, llprepare_oc_frames, llprepare_oc_kred_pog, llprepare_oc_pop_cashflow, lnCloneDays, lcCloneMsg, llprepare_oc_default_events
        
	IF loid_oc_report > 0 OR lnSelect > 0 THEN
	
	    IF loid_oc_report > 0 THEN 
		    lnIdOcReportOld = TRANSFORM(loid_oc_report)
		ELSE 	
    		lnIdOcReportOld = TRANSFORM(laA[lnSelect,2])
    	ENDIF 
    	
    	GF_SQLEXEC("SELECT id_oc_settings, DATEDIFF(dd, date_to, getdate()) cnt_day_from_sh FROM dbo.Oc_Reports WHERE id_oc_report = " + lnIdOcReportOld, "posnetek")
    	
    	lnIdSnapshotSettings = posnetek.id_oc_settings
    	
    	*èe je id_oc_settings=0 
    	IF GF_NULLOREMPTY(lnIdSnapshotSettings) THEN
    		pozor("Kloniranje posnetka ni možno (id_oc_settings=0).")
    		RETURN .F.
    	ENDIF
    		
    	
		TEXT TO lcSql NOSHOW
			SELECT prepare_oc_dokument, prepare_oc_lsk_and_oc_gl, prepare_oc_lsk_promet, prepare_oc_fa, prepare_oc_frames,
			       prepare_oc_kred_pog, prepare_oc_pop_cashflow, prepare_oc_default_events
			  FROM dbo.gfn_Get_OcSettings ({0})
		ENDTEXT

		lcSql = STRTRAN(lcSql, "{0}", TRANSFORM(lnIdSnapshotSettings))
		GF_SQLEXEC(lcSql, 'oc_settings')	
	
		llprepare_oc_dokument = oc_settings.prepare_oc_dokument
		llprepare_oc_lsk_and_oc_gl = oc_settings.prepare_oc_lsk_and_oc_gl   	
		llprepare_oc_fa = oc_settings.prepare_oc_fa
		llprepare_oc_frames = oc_settings.prepare_oc_frames 
		llprepare_oc_kred_pog =  oc_settings.prepare_oc_kred_pog   
		llprepare_oc_pop_cashflow = oc_settings.prepare_oc_pop_cashflow
		llprepare_oc_default_events = oc_settings.prepare_oc_default_events
		
		IF llprepare_oc_dokument = .F. AND llprepare_oc_lsk_and_oc_gl = .F. AND llprepare_oc_fa = .F.  AND llprepare_oc_frames = .F. AND llprepare_oc_kred_pog = .F. AND llprepare_oc_pop_cashflow = .F. THEN 
			pozor("Kloniranje posnetka ni možno. Preverite nastavitve (prepare_oc_...) v tabeli oc_settings.")
    		RETURN .F.
		ENDIF
		
		*preveri èe od target date-a posnetka ni preteklo veè kot 30 dni 	
		lncnt_day_from_sh  = GF_SQLExecScalar("SELECT DATEDIFF(dd, date_to, getdate()) as cnt_day_from_sh FROM dbo.oc_reports WHERE id_oc_report = " + lnIdOcReportOld)
		
		lnCloneDays = VAL(GF_CustomSettings("Snapshot.Clone.ValidDays"))
		
		IF lncnt_day_from_sh > lnCloneDays
			lcCloneMsg = "Preteklo je veè kot {0} dni od priprave posnetka. Kloniranje posnetka ni možno." && caption
			lcCloneMsg = STRTRAN(lcCloneMsg, "{0}", TRANSFORM(lnCloneDays))
			pozor(lcCloneMsg)
    		RETURN .F.
		ENDIF
		
   
    	LOCAL plRunQuery, plHideContainer, plRunFullScreen, paDefaultValues, SearchNo, i

		SearchNo = 1

		DIMENSION SearchType(6,11)
		SearchType(1,1) = SearchNo
		SearchType(1,2) = "Kloniranje posnetka"  && Caption
		SearchType(1,3) = "dbo.gsp_oc_clone_snapshot " 
		SearchType(1,4) = ""
		SearchType(1,5) = .F. && contract
		SearchType(1,6) = .F. && client
		SearchType(1,7) = .F.
		SearchType(1,8) = .F.
		SearchType(1,9) = .F.
		SearchType(1,10) = 2
		SearchType(1,11) = ""

		DIMENSION CriteriaContainers(9,11)
		i = 0
	
		i = i + 1
		CriteriaContainers(i,1) = SearchNo
		CriteriaContainers(i,2) = "criteria_text" 
		CriteriaContainers(i,3) = i
		CriteriaContainers(i,4) = "ID posnetka ki ga bomo klonirali"  && Caption
		CriteriaContainers(i,5) = .T.
		CriteriaContainers(i,6) = 0
		CriteriaContainers(i,7) = .F.
		CriteriaContainers(i,8) = lnIdOcReportOld
		CriteriaContainers(i,9) = "DOK"
		CriteriaContainers(i,10) = ""
		CriteriaContainers(i,11) = .F.
	
		i = i + 1
		CriteriaContainers(i,1) = SearchNo
		CriteriaContainers(i,2) = "criteria_bit" 
		CriteriaContainers(i,3) = i
		CriteriaContainers(i,4) = "DOKUMENTACIJO"  && Caption
		CriteriaContainers(i,5) = .T.
		CriteriaContainers(i,6) = 0
		CriteriaContainers(i,7) = llprepare_oc_dokument
		CriteriaContainers(i,8) = ""
		CriteriaContainers(i,9) = "DOK"
		CriteriaContainers(i,10) = ""
		CriteriaContainers(i,11) = .F.

		i = i + 1
		CriteriaContainers(i,1) = SearchNo
		CriteriaContainers(i,2) = "criteria_bit" 
		CriteriaContainers(i,3) = i
		CriteriaContainers(i,4) = "LSK in GL"  && Caption
		CriteriaContainers(i,5) = .T.
		CriteriaContainers(i,6) = 0
		CriteriaContainers(i,7) = llprepare_oc_lsk_and_oc_gl 
		CriteriaContainers(i,8) = ""
		CriteriaContainers(i,9) = "LSK"
		CriteriaContainers(i,10) = ""
		CriteriaContainers(i,11) = .F.
	
		i = i + 1
		CriteriaContainers(i,1) = SearchNo
		CriteriaContainers(i,2) = "criteria_bit" && izdana
		CriteriaContainers(i,3) = i
		CriteriaContainers(i,4) = "FA"  && Caption
		CriteriaContainers(i,5) = .T.
		CriteriaContainers(i,6) = 0
		CriteriaContainers(i,7) = llprepare_oc_fa 
		CriteriaContainers(i,8) = ''
		CriteriaContainers(i,9) = "FAB"
		CriteriaContainers(i,10) = ""
		CriteriaContainers(i,11) = .F.
	
		i = i + 1
		CriteriaContainers(i,1) = SearchNo
		CriteriaContainers(i,2) = "criteria_bit" && izdana
		CriteriaContainers(i,3) = i
		CriteriaContainers(i,4) = "OKVIRE"  && Caption
		CriteriaContainers(i,5) = .T.
		CriteriaContainers(i,6) = 0
		CriteriaContainers(i,7) = llprepare_oc_frames 
		CriteriaContainers(i,8) = ''
		CriteriaContainers(i,9) = "OKV"
		CriteriaContainers(i,10) = ""
		CriteriaContainers(i,11) = .F.
	
		i = i + 1
		CriteriaContainers(i,1) = SearchNo
		CriteriaContainers(i,2) = "criteria_bit" && izdana
		CriteriaContainers(i,3) = i
		CriteriaContainers(i,4) = "KREDITNE POGODBE"  && Caption
		CriteriaContainers(i,5) = .T.
		CriteriaContainers(i,6) = 0
		CriteriaContainers(i,7) = llprepare_oc_kred_pog 
		CriteriaContainers(i,8) = ''
		CriteriaContainers(i,9) = "KRP"
		CriteriaContainers(i,10) = ""
		CriteriaContainers(i,11) = .F.
		
		i = i + 1
		CriteriaContainers(i,1) = SearchNo
		CriteriaContainers(i,2) = "criteria_bit" && izdana
		CriteriaContainers(i,3) = i
		CriteriaContainers(i,4) = "PREDVID. DEN. TOKOVE"  && Caption
		CriteriaContainers(i,5) = .T.
		CriteriaContainers(i,6) = 0
		CriteriaContainers(i,7) = llprepare_oc_pop_cashflow 
		CriteriaContainers(i,8) = ''
		CriteriaContainers(i,9) = "POP"
		CriteriaContainers(i,10) = ""
		CriteriaContainers(i,11) = .F.
		
		i = i + 1
		CriteriaContainers(i,1) = SearchNo
		CriteriaContainers(i,2) = "criteria_bit" && izdana
		CriteriaContainers(i,3) = i
		CriteriaContainers(i,4) = "IZREDNE DOGODKE"  && Caption
		CriteriaContainers(i,5) = .T.
		CriteriaContainers(i,6) = 0
		CriteriaContainers(i,7) = llprepare_oc_default_events
		CriteriaContainers(i,8) = ''
		CriteriaContainers(i,9) = "POP"
		CriteriaContainers(i,10) = ""
		CriteriaContainers(i,11) = .F.
		
		i = i + 1
		CriteriaContainers(i,1) = SearchNo
		CriteriaContainers(i,2) = "criteria_bit" && izdana
		CriteriaContainers(i,3) = i
		CriteriaContainers(i,4) = "PARTNERJE"  && Caption
		CriteriaContainers(i,5) = .T.
		CriteriaContainers(i,6) = 0
		CriteriaContainers(i,7) = .T.
		CriteriaContainers(i,8) = ''
		CriteriaContainers(i,9) = "PAR"
		CriteriaContainers(i,10) = ""
		CriteriaContainers(i,11) = .F.

	    * Ponastavi v "CriteriaContainers" default values iz vhodnega arraya
	    DO GF_SetDefaultValueForCriteriaContainers WITH CriteriaContainers, paDefaultValues
	    
		plHideContainer = .F.
	    plRunFullScreen =.F.
	    
	    IF loid_oc_report > 0 OR lnSelect > 0 THEN
	    	IF potrjeno("Ali želite klonirati pripravljeni posnetek v glavni bazi?") THEN
	            DO FORM "oc_clone" WITH  SearchNo, SearchType, CriteriaContainers, plHideContainer, plRunFullScreen
	        ELSE
	            RETURN .t.
	        ENDIF
	    ENDIF
    
    ENDIF 

ENDFUNC

FUNCTION CustomRevalorization	
	LOCAL lcSqlText, lcTitle, loResult, lcXml, lcRes
		TEXT TO lcsqltext NOSHOW 
		SELECT ID_cont 
		INTO ##custom_reval 
		FROM dbo.pogodba 
		WHERE status_akt ='A'
		ENDTEXT
	lctitle = "Custom revalorization" && Caption
	DO FORM message_memo WITH lcsqltext, lcTitle, .T., 8000 TO loResult
	IF TYPE("loResult") = "O" THEN
		IF loResult.Result=.T. THEN 
			lcSqlText = loResult.text
			
			lcXml = "<revalorization_custom xmlns='urn:gmi:nova:leasing'>"
			lcXml = lcXml + GF_CreateNode("sqlText", lcSqlText, "C", 1)
			lcXml = lcXml + "</revalorization_custom>"
			&&lcRes = GF_ProcessXml( lcXml )
			lcRes = GF_ProcessXml(lcXml, .t., .t.)
			if TYPE('lcRes') != "L" then
				lcSessionId = GF_GetSingleNodeXmlConvert(lcRes, "SessionId")
				DO RevalorPregled IN frmparams_reprogram WITH .T., .T., .T., .F., lcSessionId
			ENDIF 
		ENDIF 
	ENDIF
ENDFUNC 

** calculate amounts for equipment at acceptance protocol (use form zap_ner_maska.scx and zap_reg_maska.scx)
FUNCTION CalculateEquipmentAcceptanceProtocol
	LPARAMETERS pcField

	LOCAL lcId_dav_st, lnProcent
	lnPercent = 0

	SELECT oprema

	IF oprema.nv_brez_popusta <> 0
		lnPercent = 100 * oprema.nv_popust_znesek / oprema.nv_brez_popusta 
		IF lnPercent > 99.9999 && nv_popust_procent can't be bigger then 99,9999
			lnPercent = 0
		ENDIF
	ENDIF

	DO CASE
		
		CASE pcField=='nv_brez_popusta' && changed vrednost brez popusta value
			IF oprema.nv_brez_popusta < 0
				REPLACE oprema.nv_brez_popusta WITH 0
			ENDIF

			REPLACE ;
				oprema.nv_popust_procent WITH ROUND(lnPercent, 4),;
				oprema.nabav_vred WITH oprema.nv_brez_popusta - oprema.nv_popust_znesek 

		CASE pcField=='nv_popust_procent' && changed % value
			IF oprema.nv_popust_procent< 0 OR oprema.nv_popust_procent > 99.9999
				REPLACE oprema.nv_popust_procent WITH 0
			ENDIF
			
				REPLACE ;
					oprema.nv_popust_znesek WITH ROUND(oprema.nv_brez_popusta * oprema.nv_popust_procent /100,2),;
					oprema.nabav_vred WITH oprema.nv_brez_popusta - oprema.nv_popust_znesek 

		CASE pcField=='nv_popust_znesek' && changed znesek s popustom nabavne vrednosti
				IF oprema.nv_popust_znesek < 0 OR oprema.nv_popust_znesek >= oprema.nv_brez_popusta
				REPLACE oprema.nv_popust_znesek WITH 0
			ENDIF

			REPLACE ;
				oprema.nv_popust_procent WITH ROUND(lnPercent, 4),;
				oprema.nabav_vred WITH oprema.nv_brez_popusta - oprema.nv_popust_znesek 

		CASE pcField=='nabav_vred' && changed summary value 
			IF oprema.nabav_vred < 0
				REPLACE oprema.nabav_vred WITH 0
			ENDIF
			
			LOCAL lnNV, lnPZ, lnZBP, lnD, lnP_DDV

			lnNV = oprema.nabav_vred
			lnPZ = oprema.nv_popust_znesek && nabavna vrednost s popustom
			
			lnZBP = ROUND((lnNV + lnPZ), 2) && nabavna vrednost brez popusta

			REPLACE	;
				oprema.nv_brez_popusta WITH lnZBP, ;
				oprema.nv_popust_znesek WITH lnPZ,;
				oprema.nv_popust_procent WITH ROUND(lnPercent, 4);

		OTHERWISE 

			REPLACE ;
				oprema.nv_popust_znesek WITH ROUND(oprema.nv_brez_popusta *oprema.nv_popust_procent /100,2),;
				oprema.nabav_vred WITH oprema.nv_brez_popusta - oprema.nv_popust_znesek 

	ENDCASE
ENDFUNC

**Creates new stocks of vehicles from contracts
FUNCTION GF_GenerateNewStocksFromContracts

	LOCAL llSuccess
	
	IF Potrjeno('Želite osvežiti seznam zalog?',.T.) THEN  &&caption
		llSuccess = GF_ProcessXml("<stock_refresh xmlns='urn:gmi:nova:stock_inspection'/>", .T.)
		IF llSuccess 
			obvesti("Rutina osveževanja seznama zalog uspešno konèana.")  &&caption
		ENDIF
	ENDIF
	
	RETURN
ENDFUNC

*** GF_SelectRpgCategoryComment *****************************************************
* Select reprogram category and comment
* RETURNS object with property rpg_cat and opis
* If user cancels the procedure empty value in object is returned
* PARAMETRS
* tcFormCap => form captions
* tcRpgType => reprogram type
* tcComment => default comment (Opis)
* tlCommentMandatory => if comment is mandatory (default .T.)
FUNCTION GF_SelectRpgCategoryComment
LPARAMETERS tcFormCap, tcRpgType, tcComment, tlCommentMandatory
	LOCAL loObj
	IF PCOUNT() < 2 THEN && Obvezna sta dva parametra
		GF_NAPAKA(0, "GF_SelectRpgCategoryComment", "", LOWPARAMETERS_LOC, 0)
		RETURN .F.
	ENDIF
	
	IF PCOUNT() < 4 THEN
		tlCommentMandatory = .T.
	ENDIF 

	DO FORM repro_category_comment WITH tcFormCap, tcRpgType, tcComment, tlCommentMandatory TO loObj
		
	RETURN loObj
ENDFUNC  

*** GF_StockFundingSetContractsAsSold  ************************************************
* Update all stock funding contracts that have payed their capital as sold
FUNCTION GF_StockFundingSetContractsAsSold 
	LOCAL lcMsgConfirm, lcMsgSuccess, lcMsgFailed, llSuccess
	
	lcMsgConfirm = "Želite oznaèiti predmete pogodb za financiranje zalog s plaèano glavnico kot prodane?" && caption
	lcMsgSuccess = "Rutina oznaèevanja pogodb za financiranje zalog uspešno konèana." && caption
	lcMsgFailed = "Napaka. Rutina za oznaèevanja pogodb za financiranje zalog se ni uspešno izvedla." && caption
	
	IF GOBJ_Permissions.GetPermission('StockFundingSetContractsAsSoldPermission') >= 2 THEN
		IF potrjeno(lcMsgConfirm) THEN
			llSuccess = GF_ProcessXml("<stock_funding_mark_as_sold xmlns='urn:gmi:nova:leasing'/>")
			IF llSuccess THEN
				obvesti(lcMsgSuccess)
			ELSE
				obvesti(lcMsgFailed)
			ENDIF
		ENDIF
	ELSE
		pozor(STRTRAN(PERMISSION_DENIED, "{0}", "StockFundingSetContractsAsSoldPermission"))
	ENDIF  
ENDFUNC
***************************************************************************************

*** GF_CheckDokActStatus4Entities ************************************************
* Check documents activation status for entities
FUNCTION GF_CheckDokActStatus4Entities
	LPARAMETERS tcType, toId
	IF PCOUNT() < 2 THEN && Obvezna sta dva parametra
		GF_NAPAKA(0, "GF_CheckDokActStatus4Entities", "", LOWPARAMETERS_LOC, 0)
		RETURN .F.
	ENDIF
	
	LOCAL lcSql, lcField, lcCursor, laPar[1], lnI, lcCursorNum, llFound, lnCount
	lcCursor = SYS(2015)
	laPar[1] = toId
	llFound = .F.
	
	DO CASE 
		CASE UPPER(tcType) = "FRAMES"
			lcField = "id_frame"
		CASE UPPER(tcType) = "KROV_POG"
			lcField = "id_krov_pog"
	ENDCASE 
	TEXT TO lcSql NOSHOW 
		declare @id_dokum int
		
		select id_dokum, status_akt from dbo.dokument where {field} = ?p1

		declare _cur cursor fast_forward for 
		select id_dokum from dbo.dokument where {field} = ?p1

		open _cur
		fetch next from _cur into @id_dokum
		while @@fetch_status = 0

		begin
		    exec dbo.grp_DocumentationLinkedForOneDocument @id_dokum

		    fetch next from _cur into @id_dokum
		end
		close _cur
		deallocate _cur
	ENDTEXT 
	lcSql = STRTRAN(lcSql, "{field}", lcField)
	GF_SqlExec_P(lcSql, @laPar, lcCursor)
	
	lnI = 0
	DO WHILE lnI <= 50
		IF lnI = 0 THEN 
			lcCursorNum = lcCursor
		ELSE
			lcCursorNum = lcCursor + ALLTRIM(STR(lnI))
		ENDIF 
		lnI = lnI + 1
		
		IF USED(lcCursorNum) THEN && ali cursor obstaja
			IF RECCOUNT(lcCursorNum) > 0 AND !llFound THEN 
				&& nismo se nasli dokumentov, ki niso neaktivni
				SELECT &lcCursorNum
				COUNT FOR !GF_NULLOREMPTY(&lcCursorNum..status_akt) TO lnCount
				IF lnCount <> 0 THEN 
					llFound = .T.
				ENDIF 
				
			ENDIF 
			USE IN &lcCursorNum
			
		ELSE && ni vec cursorjev
			EXIT 
			
		ENDIF 
	ENDDO 

	RETURN llFound
ENDFUNC
***************************************************************************************

*** GF_ContractCommissionReEntry ************************************************
* Check if we the user can delete and re-enter the commissions
* If the the user can re-enter the commissions we delete the existing commissions and make him choose a new calculation
FUNCTION GF_ContractCommissionReEntry
	LPARAMETERS lnId_cont
	LOCAL lcReEntrySettings, lcSqlAny, lcSql, lcExtraCondition, lcXml, lcMsg1, lcMsg2, lcSqlAnyAuto
	
	* check if there are any commissions inserted
	TEXT TO lcSqlAny NOSHOW
		SELECT COUNT(*) FROM dbo.prov_pog WHERE id_cont = {0}
	ENDTEXT
	lcSqlAny = STRTRAN(lcSqlAny , "{0}", TRANSFORM(lnId_cont))
	
	* check if there are any commission that ware automaticlly inserted
	TEXT TO lcSqlAnyAuto NOSHOW
		SELECT COUNT(*) FROM dbo.prov_pog WHERE id_cont = {0} AND id_provizije_izracun IS NOT NULL
	ENDTEXT
	lcSqlAnyAuto = STRTRAN(lcSqlAnyAuto, "{0}", TRANSFORM(lnId_cont))	
	
	IF GF_SQLExecScalar(lcSqlAny) = 0 OR GF_SQLExecScalar(lcSqlAnyAuto) = 0 THEN
		* no commission - trigger automatic insert
		DO ContractInsertCommissions WITH lnId_cont, .F., .T.
	ELSE
	 	* there are commissions inserted, we check if the user can delete and re-insert them
		lcReEntrySettings = GF_CustomSettings("Nova.LE.NewCommissionsModule.CommissionReEnterSetting")
		
		IF GF_NULLOREMPTY(lcReEntrySettings) THEN
			RETURN .F.
		ENDIF
		
		DO CASE
		CASE lcReEntrySettings = "1"
			lcExtraCondition = " DKONTROLE is not null"
		CASE lcReEntrySettings = "2"
			lcExtraCondition = " IZPIS_OBV is not null"
		OTHERWISE
			RETURN .F.
		ENDCASE
		
		TEXT TO lcSql NOSHOW 
			SELECT COUNT(*) FROM dbo.prov_pog WHERE id_cont = {0} AND id_provizije_izracun IS NOT NULL AND {1}
		ENDTEXT 
		lcSql = STRTRAN(lcSql, "{0}", TRANSFORM(lnId_cont))
		lcSql = STRTRAN(lcSql, "{1}", lcExtraCondition)
		
		lcMsg1 = "Ali želite izbrisati in ponovno vnesti avtomatsko vnesene provizije?" && caption
		lcMsg2 = "Roèno vnesene provizije ne bodo spremenjene." && caption
		
		*ask to delete and re-enter
		IF GF_SQLExecScalar(lcSql) = 0 AND potrjeno(lcMsg1 + CHR(13) + CHR(10) + lcMsg2) THEN
			lcXml = '<delete_commissions_for_contract xmlns="urn:gmi:nova:leasing">' + gcE
			lcXml = lcXml + GF_CreateNode("id_cont", lnId_cont, "N", 1) + gcE
			lcXml = lcXml + '</delete_commissions_for_contract>'
			GF_ProcessXml(lcXml)
				
			DO ContractInsertCommissions WITH lnId_cont, .F., .T.
			
			RETURN .T.
		ELSE
			*commissions are confirmed/authorized so we cant delete and re-enter them
			RETURN .F.
		ENDIF
	ENDIF
ENDFUNC
***************************************************************************************
