LOCAL loForm, lcXml
loForm = GF_GetFormObject("frmPartner_eval_pregled2")
IF potrjeno("Da li želite uvoziti SMB ratinge?") THEN
	lcXml = "<partner_rating_smb_import xmlns='urn:gmi:nova:common_raiffeisen' />"
	IF GF_ProcessXml(lcXml) THEN
		obvesti("Podaci su uspješno uvezeni.")
		loForm.runsql()
	ELSE
		pozor("Kod uvoza podataka došlo je do greške!")
			RETURN .F.
	ENDIF
ENDIF


using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Data;
using System.Xml.Serialization;
using GMI.Core;
using GMI.Core.Data;
using GMI.Leasing.BusinessLogic;
using GMI.Leasing.BusinessObjects;

namespace GMI.ExtFunc.Common_Raiffeisen {

    public class PEval_Last : View_GvPevalLastevaluation {
        public string coconut_id;
        public string bonity_on_partner;
        public string asset_class_on_partner;
    }

    public class SMBRating {
        public string rating_id;

        public string coconut_id;

        public string eval_model;

        public string gams_flag;

        public string gics_code;

        public string nace_code;

        public string rating;

        public bool is_valid;

        public DateTime? dat_eval;
    }



    ////////////////////////////////////////////////////////////////////////////////////
    /// <summary> Import of SMB evaluations from csv file for RL REGION 1.</summary>
    /// <remarks><history><list type="bullet">
    /// <item>17.07.2012 Ziga; MID 35783 - created</item>
	 /// <item>21.08.2012 Ziga; MID 35783 - changed delimiter in log file to ";"</item>
    ///	</list></history></remarks>
    ////////////////////////////////////////////////////////////////////////////////////
	
	[GMI_ScriptableLego("urn:gmi:ext_func:common_raiffeisen", "partner_rating_smb_import")]
    public class GBL_PartnerRatingSMBImport : GMI_LegoObject {

       [XmlRootAttribute("partner_rating_smb_import", Namespace = "urn:gmi:ext_func:common_raiffeisen")]
        public class InputParameters : GMI_LegoParams {
        }

        InputParameters ip;

        /// <summary> Entity name (RLRS/RRRS/RLHR/RLBH/RLSI). </summary>
        string entity_name;

        /// <summary> IO channel. </summary>
        GMI_IoChannel channel;

        /// <summary> SMBRAT file. </summary>
        FileInfo smbrat_file;

        /// <summary> Log filename </summary>
        string log_filename;

        /// <summary> List of all ratings from csv file. </summary>
        List<SMBRating> smb_ratings_list_all = new List<SMBRating>();

        /// <summary> List of all last smb ratings. </summary>
        List<SMBRating> smb_ratings_list_smb = new List<SMBRating>();

        /// <summary> List of all last relevant smb ratings. </summary>
        List<SMBRating> smb_ratings_list_smb_relevant = new List<SMBRating>();

        /// <summary> List of relevant ratings. </summary>
        List<PEval_Last> evaluations_nova;

        /// <summary> Enumeration for SMB partner ratings </summary>
        List<string> ratings_enum = new List<string>(new string[] { "1A", "1B", "1C", "2A", "2B", "2C", "3A", "3B", "3C", "4A", "4B", "4C", "5A", "5B", "5C",
                                                                    "6A", "6B", "6C", "7A", "7B", "7C", "8A", "8B", "8C", "9A", "9B", "9C", "10A", "10B", "10C" });

        /// <summary> Enumeration for SMB evaluation models. </summary>
        List<string> eval_models_enum = new List<string>(new string[] { "41", "29", "06", "63" });

        /// <summary> Text writer for writing to log file. </summary>
        TextWriter tw_log;

        /// <summary> Template for log row. </summary>
        //COCONUT_ID;PARTNER_NOVA;EVAL_MODEL;RATING;NACE;GICS;EVAL_DATE;COMMENT
        string template_for_log_row = "{0};{1};{2};{3};{4};{5};{6};{7}";


        /// <summary> constructor that accepts binary parameters </summary>
        public GBL_PartnerRatingSMBImport(GMI_Session session, System.Xml.XmlDocument _parameters)
            : base(session, _parameters) {
            // desirialize input paramrameters to object
            ip = (InputParameters)GMI_Memento.DeserializeXml(_parameters.OuterXml, typeof(InputParameters));
            channel = GMI_IoChannel.GetChannel(session, "RATING_SMB");
            entity_name = GMI_LocNast.Singleton.entity_name.Trim();
        }

        /// <summary> main business logic </summary>
        protected override void RunBl() {
            try {
                InitializeLogFile();

                ImportCSVFile();

                PrepareData();

                ProcessData();

                LogWarnings();

                ArchiveFiles();
            } finally {
                ClearLogFile();
            }

            // store binary results into member xmldoc_results
            this.xmldoc_results = new System.Xml.XmlDocument();
            this.xmldoc_results.LoadXml("<okd />");
        }

        private void PrepareData() {
            session.Log("PrepareData started.", "GBL_PartnerRatingSMBImport", GMI_LogMsgGroupEnum.Bl, GMI_LogMsgLevelEnum.None);

            // 1.) PREPARE DATA FOR NEW EVALUATIONS IMPORTED FROM SCV FILE
            // perform order because it is possible that more records with same coconut id and dat_eval exists => relevant are those with max rating_id
            var smb_ratings_sorted = (from x in this.smb_ratings_list_all
                                      orderby x.coconut_id, x.dat_eval descending, x.rating_id descending
                                      select x).ToList();

            // filter last evaluations -> relevant are only records with max dat_eval for current coconut_id
            var smb_ratings_filtered = (from t in smb_ratings_sorted
                                        group t by t.coconut_id into g
                                        select new SMBRating {
                                             coconut_id = g.Key,
                                             dat_eval = g.Max(gt => gt.dat_eval),
                                             eval_model = g.First(gt2 => gt2.dat_eval == g.Max(gt => gt.dat_eval)).eval_model,
                                             gams_flag = g.First(gt2 => gt2.dat_eval == g.Max(gt => gt.dat_eval)).gams_flag,
                                             gics_code = g.First(gt2 => gt2.dat_eval == g.Max(gt => gt.dat_eval)).gics_code,
                                             is_valid = g.First(gt2 => gt2.dat_eval == g.Max(gt => gt.dat_eval)).is_valid,
                                             nace_code = g.First(gt2 => gt2.dat_eval == g.Max(gt => gt.dat_eval)).nace_code,
                                             rating = g.First(gt2 => gt2.dat_eval == g.Max(gt => gt.dat_eval)).rating,
                                             rating_id = g.First(gt2 => gt2.dat_eval == g.Max(gt => gt.dat_eval)).rating_id
                                         }).ToList();

            // filter evaluations for SMB eval models
            this.smb_ratings_list_smb = (from x in smb_ratings_filtered
                                         where x.is_valid == true && eval_models_enum.Contains(x.eval_model)
                                         select x).ToList();

            // filter evaluations for SMB eval models and correct ratings
            this.smb_ratings_list_smb_relevant = (from x in smb_ratings_filtered
                                                  where x.is_valid == true && eval_models_enum.Contains(x.eval_model) && ratings_enum.Contains(x.rating)
                                                  select x).ToList();
           

            // 2.) PREPARE DATA FOR ALL CURRENT EVALUATIONS IN NOVA
            string sql_cmd = @"select a.*, rtrim(ltrim(b.ext_id)) as coconut_id, rtrim(ltrim(b.boniteta)) as boniteta, rtrim(ltrim(b.asset_clas)) as asset_clas
                                from dbo.gv_PEval_LastEvaluation a
                                inner join dbo.partner b on b.id_kupca = a.id_kupca
                                where a.eval_type = 'E'";

            DataTable pe_dt = session.DBHelper.GetDataTable(sql_cmd);

            this.evaluations_nova = new List<PEval_Last>(pe_dt.Rows.Count);

            foreach (DataRow dr in pe_dt.Rows) {
                PEval_Last e = new PEval_Last();
                e.Load(dr);
                e.coconut_id = dr["coconut_id"] != DBNull.Value ? (string)dr["coconut_id"] : null;
                e.bonity_on_partner = dr["boniteta"] != DBNull.Value ? ((string)dr["boniteta"]).Trim() : "";
                e.asset_clas = dr["asset_clas"] != DBNull.Value ? ((string)dr["asset_clas"]).Trim() : "";
                this.evaluations_nova.Add(e);
            }

            session.Log("PrepareData finished.", "GBL_PartnerRatingSMBImport", GMI_LogMsgGroupEnum.Bl, GMI_LogMsgLevelEnum.None);
        }

        private void ProcessData() {
            session.Log("ProcessData started.", "GBL_PartnerRatingSMBImport", GMI_LogMsgGroupEnum.Bl, GMI_LogMsgLevelEnum.None);

            foreach (SMBRating r in this.smb_ratings_list_smb_relevant) {
                var a = evaluations_nova.Where(x => x.coconut_id.Trim() == r.coconut_id).ToList();
                if (a.Count == 1) {
                    // evaluation exists -> insert new evaluation
                    ProcessExistingEvaluation(r, a[0]);
                } else if (a.Count == 0) {
                    // evaluation does not exists
                    DataTable dtp = Tab_Partner.CreateQuery().IsEqual(Tab_Partner.Columns.ext_id, r.coconut_id)
                                                             .SelectField(Tab_Partner.Columns.id_kupca)
                                                             .GetDataTable(session);
                    if (dtp.Rows.Count == 0) {
                        // partner does not exists
                        string s = PrepareRowForErrorLog(r.coconut_id, "Patner does not exist in Nova.");
                        WriteToLog(s);
                    } else if (dtp.Rows.Count > 1) {
                        // duplicate for coconut
                        string s = PrepareRowForErrorLog(r.coconut_id, "More than one partner with this coconut id exist in Nova.");
                        WriteToLog(s);
                    } else { // if (a.Count == 1)
                        // previous evaluation does not exists -> insert new evaluation
                        string id_kupca = (string)dtp.Rows[0]["id_kupca"];
                        ProcessFirstEvaluation(r, id_kupca);
                    }

                } else {
                    // duplicate for coconut_id
                    string s = PrepareRowForErrorLog(r.coconut_id, "More than one partner with this coconut id exist in Nova.");
                    WriteToLog(s);
                }
            }

            session.Log("ProcessData finished.", "GBL_PartnerRatingSMBImport", GMI_LogMsgGroupEnum.Bl, GMI_LogMsgLevelEnum.None);
        }

        private void ProcessFirstEvaluation(SMBRating rat_csv, string id_kupca) {
            // prepare data for evaluation
            p_eval_iu_register peval_input = new p_eval_iu_register();
            peval_input.is_update = false;
            peval_input.asset_clas = "SMBUS";
            peval_input.coll_ratin = "";
            peval_input.dat_vnosaSpecified = true;
            peval_input.dat_vnosa = DateTime.Today;
            peval_input.id_kupca = id_kupca;
            peval_input.limita = 0;
            peval_input.oall_ratin = "";
            peval_input.tec_limite = "000";
            peval_input.datum_bilSpecified = false;
            peval_input.dat_nasl_vredSpecified = false;
            peval_input.vnesel = "g_system";
            peval_input.id = "";
            peval_input.eval_type = "E";
            peval_input.opombe = "";
            peval_input.cust_ratin = rat_csv.rating;
            peval_input.eval_model = rat_csv.eval_model + rat_csv.gams_flag;
            peval_input.dat_eval = rat_csv.dat_eval ?? DateTime.Today;
            peval_input.kategorija1 = null;
            peval_input.kategorija2 = null;
            peval_input.kategorija3 = null;

            if (entity_name == "RLRS" || entity_name == "RRRS") {
                peval_input.kategorija2 = rat_csv.nace_code.NullIfEmpty();
                peval_input.kategorija3 = rat_csv.gics_code.NullIfEmpty();
            }

            if (entity_name == "RLHR") {
                peval_input.kategorija1 = rat_csv.gics_code.NullIfEmpty();
                peval_input.kategorija2 = rat_csv.nace_code.NullIfEmpty();
            }

            peval_input.dat_eval = rat_csv.dat_eval ?? DateTime.Today;


            GBL_PEvalIURegister peval = new GBL_PEvalIURegister(session, peval_input);
            peval.Run();

            UpdateBonityOnPartner(peval_input.id_kupca, peval_input.cust_ratin + "/" + peval_input.coll_ratin + "/" + peval_input.oall_ratin, peval_input.asset_clas);

            // Write differences to log file
             //COCONUT_ID;PARTNER_NOVA;EVAL_MODEL;RATING;NACE;GICS;EVAL_DATE;COMMENT
            string diff_for_log = string.Format(template_for_log_row,
                                                    rat_csv.coconut_id, id_kupca,
                                                    rat_csv.eval_model + rat_csv.gams_flag,
                                                    rat_csv.rating,
                                                    (entity_name == "RLRS" || entity_name == "RRRS" || entity_name == "RLHR" ? rat_csv.nace_code : ""),
                                                    (entity_name == "RLRS" || entity_name == "RRRS" || entity_name == "RLHR" ? rat_csv.gics_code : ""),
                                                    peval_input.dat_eval.ToShortDateString(),
                                                    "New evaluation.");

            WriteToLog(diff_for_log);
            
        }

        private void ProcessExistingEvaluation(SMBRating rat_csv, PEval_Last rat_nova) {

            // prepare data for new evaluation based on previous evaluation
            p_eval_iu_register peval_input = new p_eval_iu_register();
            peval_input.is_update = false;
            peval_input.asset_clas = "SMBUS";
            peval_input.coll_ratin = rat_nova.coll_ratin;
            peval_input.dat_vnosaSpecified = true;
            peval_input.dat_vnosa = DateTime.Today;
            peval_input.id_kupca = rat_nova.id_kupca;
            peval_input.limita = rat_nova.limita;
            peval_input.oall_ratin = rat_nova.oall_ratin;
            peval_input.tec_limite = rat_nova.tec_limite;
            peval_input.datum_bilSpecified = rat_nova.datum_bil.HasValue;
            if (rat_nova.datum_bil.HasValue)
                peval_input.datum_bil = rat_nova.datum_bil.Value;
            peval_input.dat_nasl_vredSpecified = rat_nova.dat_nasl_vred.HasValue;
            if (rat_nova.dat_nasl_vred.HasValue)
                peval_input.dat_nasl_vred = rat_nova.dat_nasl_vred.Value;
            peval_input.vnesel = "g_system";
            peval_input.id = rat_nova.id;
            peval_input.eval_type = "E";
            peval_input.opombe = rat_nova.opombe;
            peval_input.ext_id = rat_nova.ext_id;
            peval_input.ext_id_type = rat_nova.ext_id_type;
            peval_input.cust_ratin = rat_nova.cust_ratin;
            peval_input.eval_model = rat_nova.eval_model;
            peval_input.kategorija1 = rat_nova.kategorija1;
            peval_input.kategorija2 = rat_nova.kategorija2;
            peval_input.kategorija3 = rat_nova.kategorija3;

            // apply changes 
            bool rating_changed = false; bool eval_model_changed = false; bool gics_changed = false; bool nace_changed = false;

            // set evaluation date
            DateTime new_eval_date;
            if (rat_csv.dat_eval.HasValue && rat_csv.dat_eval.Value > rat_nova.dat_eval)
                new_eval_date = rat_csv.dat_eval.Value;
            else
                new_eval_date = DateTime.Today;

            peval_input.dat_eval = new_eval_date;

            // check and log exception if new eval. date is same as eval date for evaluation in Nova
            // It is not allowed to insert two or more evaluations with same eval. date
            if (DateTime.Compare(new_eval_date, rat_nova.dat_eval) == 0) {
                string msg = "Evaluation can not be inserted because of evaluation date.";
                string msg_for_log = string.Format(this.template_for_log_row, rat_csv.coconut_id, rat_nova.id_kupca, "", "", "", "", "", msg);
                WriteToLog(msg_for_log);
                return;
            }

            // check for partner rating
            if (rat_csv.rating != rat_nova.cust_ratin) {
                rating_changed = true;
                peval_input.cust_ratin = rat_csv.rating;
            }

            // check for eval model
            if (rat_csv.eval_model + rat_csv.gams_flag != rat_nova.eval_model) {
                eval_model_changed = true;
                peval_input.eval_model = rat_csv.eval_model + rat_csv.gams_flag;
            }

            // check for nace code
            if (entity_name == "RLRS" || entity_name == "RRRS") {
                if (!String.IsNullOrEmpty(rat_csv.nace_code) && rat_csv.nace_code != rat_nova.kategorija2.EmptyIfNull()) {
                    nace_changed = true;
                    peval_input.kategorija2 = rat_csv.nace_code;
                }

                if (!String.IsNullOrEmpty(rat_csv.gics_code) && rat_csv.gics_code != rat_nova.kategorija3.EmptyIfNull()) {
                    gics_changed = true;
                    peval_input.kategorija3 = rat_csv.gics_code;
                }
            }

            // check for gics code
            if (entity_name == "RLHR") {
                if (!String.IsNullOrEmpty(rat_csv.gics_code) && rat_csv.gics_code != rat_nova.kategorija1.EmptyIfNull()) {
                    gics_changed = true;
                    peval_input.kategorija1 = rat_csv.gics_code;
                }

                if (!String.IsNullOrEmpty(rat_csv.nace_code) && rat_csv.nace_code != rat_nova.kategorija2.EmptyIfNull()) {
                    nace_changed = true;
                    peval_input.kategorija2 = rat_csv.nace_code;
                }
            }

            // if nothing changed, we do not insert new evaluation
            if (!(rating_changed || gics_changed || nace_changed || eval_model_changed))
                return;

            GBL_PEvalIURegister peval = new GBL_PEvalIURegister(session, peval_input);
            peval.Run();

            string new_bonity = peval_input.cust_ratin + "/" + peval_input.coll_ratin + "/" + peval_input.oall_ratin;
            string new_asset_clas = peval_input.asset_clas;
            bool update_bonity = (new_bonity != rat_nova.bonity_on_partner);
            bool update_asset_clas = (new_asset_clas != rat_nova.asset_clas);
            if (update_bonity || update_asset_clas)
                UpdateBonityOnPartner(peval_input.id_kupca, (update_bonity ? new_bonity : null), (update_asset_clas ? new_asset_clas : null));

            // Write differences to log file
            //COCONUT_ID;PARTNER_NOVA;EVAL_MODEL;RATING;NACE;GICS;EVAL_DATE;COMMENT
            string diff_for_log = string.Format(this.template_for_log_row,
                                                    rat_csv.coconut_id, rat_nova.id_kupca,
                                                    eval_model_changed == true ? rat_nova.eval_model.Trim() + " -> " + rat_csv.eval_model.Trim() + rat_csv.gams_flag.Trim() : "",
                                                    rating_changed == true ? rat_nova.cust_ratin.Trim() + " -> " + rat_csv.rating.Trim() : "",
                                                    nace_changed == true ? (entity_name == "RLRS" || entity_name == "RRRS" || entity_name == "RLHR" ? rat_nova.kategorija2.EmptyIfNull() + " -> " + rat_csv.nace_code : "") : "",
                                                    gics_changed == true ? (entity_name == "RLRS" || entity_name == "RRRS" ? rat_nova.kategorija3.EmptyIfNull() + " -> " + rat_csv.gics_code : (entity_name == "RLHR" ? rat_nova.kategorija1.EmptyIfNull() + " -> " + rat_csv.gics_code : "")) : "",
                                                    rat_nova.dat_eval.ToShortDateString() + " -> " + new_eval_date.ToShortDateString(),
                                                    "New evaluation based on existing evaluation in Nova.");
            WriteToLog(diff_for_log);
        }

        private void UpdateBonityOnPartner(string id_kupca, string bonity, string asset_class) {
            string sql_stmt = "SELECT CAST(sys_ts as bigint) AS sys_ts FROM dbo.partner WHERE id_kupca = {0}";
            sql_stmt = String.Format(sql_stmt, session.DBHelper.fs.FormatValue(id_kupca));
            int sys_ts = Convert.ToInt32(session.DBHelper.ExecuteScalar(sql_stmt));

            List<updated_field> fu = new List<updated_field>();
            
            if (bonity != null) {
                updated_field f = new updated_field();
                f.name = Tab_Partner.Columns.boniteta;
                f.updated_value = bonity;
                f.table_name = Tab_Partner.TableName;
                fu.Add(f);
            }

            if (asset_class != null) {
                updated_field f = new updated_field();
                f.name = Tab_Partner.Columns.asset_clas;
                f.updated_value = asset_class;
                f.table_name = Tab_Partner.TableName;
                fu.Add(f);
            }

            // update filed Boniteta and Kategorija B2 trough reprogram
            rpg_partner_update rpg = new rpg_partner_update();
            rpg.common_parameters = new rpg_common_parameters();
            rpg.common_parameters.comment = "Update partner rating field.";
            rpg.common_parameters.id_kupca = id_kupca;
            rpg.common_parameters.sys_tsSpecified = true;
            rpg.common_parameters.sys_ts = sys_ts;
            rpg.common_parameters.id_rep_category = GBO_DbUtils.GetReprogramCategory(session, "UPP");
            rpg.updated_values = fu.ToArray();

            GBL_ReprogramPartnerUpdate rep = new GBL_ReprogramPartnerUpdate(session, rpg);
            rep.Run();
        }

        private void LogWarnings() {
            session.Log("LogNonRelevantRatings started.", "GBL_PartnerRatingSMBImport", GMI_LogMsgGroupEnum.Bl, GMI_LogMsgLevelEnum.None);

            // Write to log non relevant ratings
            var smb_ratings_non_relevant = (from x in this.smb_ratings_list_smb
                                            where !this.ratings_enum.Contains(x.rating)
                                            select x).ToList();

            foreach (SMBRating r in smb_ratings_non_relevant) {
                string msg = "Not appropriate SMB rating in CSV file.";
                string s = string.Format(this.template_for_log_row, r.coconut_id, "", r.eval_model + r.gams_flag, r.rating, r.nace_code, r.gics_code, r.dat_eval.HasValue ? r.dat_eval.Value.ToShortDateString() : "", msg);
                WriteToLog(s);
            }

            // Write to log all SMB ratings present in Nova and not present in csv file
            var smb_in_nova_not_in_csv = (from x in this.evaluations_nova
                                          where this.eval_models_enum.Contains(x.eval_model.Left(2))
                                          && !(from y in this.smb_ratings_list_smb_relevant
                                               select y.coconut_id).Contains(x.coconut_id)
                                          select x).ToList();

            foreach (PEval_Last e in smb_in_nova_not_in_csv) {
                string msg = "SMB rating is present in Nova but does not exist in csv file or rating in csv file is not appropirate.";
                string s = string.Format(this.template_for_log_row, e.coconut_id.Trim(), e.id_kupca.Trim(),
                                                                    e.eval_model, e.cust_ratin.Trim(),
                                                                    (entity_name == "RLRS" || entity_name == "RRRS" || entity_name == "RLHR" ? e.kategorija2.EmptyIfNull().Trim() : ""),
                                                                    (entity_name == "RLRS" || entity_name == "RRRS" ? e.kategorija3.EmptyIfNull().Trim() : (entity_name == "RLHR" ? e.kategorija1.EmptyIfNull().Trim() : "")),
                                                                    e.dat_eval.ToShortDateString(), msg);
                WriteToLog(s);
            }

            // Write to log all SMB evaluations with invalid rating
            var invalid_smb_ratings = View_GvPevalLastevaluation.CreateQuery()
                                                                .IsEqual(View_GvPevalLastevaluation.Columns.eval_type, "E")
                                                                .IsInArray("LEFT(" + View_GvPevalLastevaluation.Columns.eval_model + ",2)", eval_models_enum)
                                                                .IsNotInArray(View_GvPevalLastevaluation.Columns.cust_ratin, ratings_enum)
                                                                .GetList(session);

            foreach (View_GvPevalLastevaluation ir in invalid_smb_ratings) {
                string msg = "Invalid SMB rating in Nova.";
                string s = string.Format(this.template_for_log_row, "", ir.id_kupca, "", ir.cust_ratin, "", "", "", msg);
                WriteToLog(s);
            }

            session.Log("LogNonRelevantRatings finished.", "GBL_PartnerRatingSMBImport", GMI_LogMsgGroupEnum.Bl, GMI_LogMsgLevelEnum.None);

        }

        private string PrepareRowForErrorLog(string coconut_id, string msg) {
            return string.Format(this.template_for_log_row, coconut_id, "", "", "", "", "", "", msg);

        }

        private void ImportCSVFile() {
            session.Log("ImportCSVFile started.", "GBL_PartnerRatingSMBImport", GMI_LogMsgGroupEnum.Bl, GMI_LogMsgLevelEnum.None);

            // Check that both files exists (<UNIT>.CUSTRAT.YYYYDDMM.csv and <UNIT>.SMBRAT.YYYYDDMM.csv)
            DirectoryInfo di = new DirectoryInfo(channel.channel_path);
            FileInfo[] fi = di.GetFiles("*.csv");

            var file_smb = fi.Where(x => x.Name.Contains(".SMBRAT.")).ToList();


            if (file_smb.Count != 1)
                throw GMI_Exception.CreateMessage("File SMBRAT is missing or there is more than one file!");

            // set filename memebers
            this.smbrat_file = file_smb[0];

            // Import CUSTRAT
            string full_filename = Path.Combine(channel.channel_path, this.smbrat_file.Name);
            Encoding encoding = null;
            if (!String.IsNullOrEmpty(channel.channel_encoding))
                encoding = Encoding.GetEncoding(channel.channel_encoding);

            TextReader tr = (encoding == null ? new StreamReader(full_filename) : new StreamReader(full_filename, encoding));

            int row_no = 1;
            try {
                string s = tr.ReadLine();
                while (s != null && s != ((char)26).ToString()) {
                    if (row_no == 1)
                        ProcessHeaderLine(s);
                    else
                        ProcessSingleLine(s);
                    s = tr.ReadLine();
                    row_no++;
                }
            } catch (Exception ex) {
                throw GMI_Exception.CreateMessage(string.Format("Error parsing CSV file, line {0}. ", row_no.ToString()) + ex.Message);
            } finally {
                tr.Close();  
            }

            session.Log("ImportCSVFile finished.", "GBL_PartnerRatingSMBImport", GMI_LogMsgGroupEnum.Bl, GMI_LogMsgLevelEnum.None);
        }

        private void ProcessHeaderLine(string s) {
            string[] header_row = s.Split('|');

            // checks for fields in header row
            // CUST_ID (coconut id) -> position 2; NACE_CODE_MAIN (nace code) -> position 25; BCORATVAL_APPR (rating) -> position 60;
            // CUSTRAT_DAT_APPR (dat. eval) -> position 74; CUSTRAT_STAT_VALID (is rating valid) -> position 85; GAMS (gams flag) -> position 125;
            // ctyp_code (eval. model) -> position 126; BCOGICS_CODE_NO (GICS code) -> position 132

            bool valid = (header_row.Length > 132
                         && header_row[1].Replace("\"", "").ToUpper() == "CUST_ID" && header_row[24].Replace("\"", "").ToUpper() == "NACE_CODE_MAIN"
                         && header_row[71].Replace("\"", "").ToUpper() == "BCORATVAL_APPR" && header_row[73].Replace("\"", "").ToUpper() == "CUSTRAT_DAT_APPR"
                         && header_row[84].Replace("\"", "").ToUpper() == "CUSTRAT_STAT_VALID" && header_row[124].Replace("\"", "").ToUpper() == "GAMS"
                         && header_row[125].Replace("\"", "").ToUpper() == "CTYP_CODE" && header_row[131].Replace("\"", "").ToUpper() == "BCOGICS_CODE_NO");
            if (!valid)
                throw GMI_Exception.CreateMessage("Invalid header row!");
        }

        private void ProcessSingleLine(string s) {
            string[] rat_s = s.Split('|');
            SMBRating rat = new SMBRating();
            rat.rating_id = rat_s[0].Replace("\"", "").EmptyIfNull().Trim();
            rat.coconut_id = rat_s[1].Replace("\"", "").EmptyIfNull().Trim();
            rat.nace_code = rat_s[24].Replace("\"", "").EmptyIfNull().Trim();
            rat.rating = rat_s[71].Replace("\"", "").EmptyIfNull().Trim();
            rat.dat_eval = ParseDateTime(rat_s[73].Replace("\"", ""));
            rat.is_valid = rat_s[84].Replace("\"", "") == "Y" ? true : false;
            rat.gams_flag = rat_s[124].Replace("\"", "").EmptyIfNull().Trim();
            rat.eval_model = rat_s[125].Replace("\"", "").EmptyIfNull().Trim();
            rat.gics_code = rat_s[131].Replace("\"", "").EmptyIfNull().Trim();

            smb_ratings_list_all.Add(rat);

        }

        private DateTime? ParseDateTime(string s) {
            DateTime? date;

            try {
                date = new DateTime(Int32.Parse(s.Left(4)), Int32.Parse(s.Substring(5, 2)), Int32.Parse(s.Substring(8, 2)));
            } catch {
                date = new Nullable<DateTime>();
            }

            return date;
        }

        private void InitializeLogFile() {
            session.Log("InitializeLogFile started.", "GBL_PartnerRatingSMBImport", GMI_LogMsgGroupEnum.Bl, GMI_LogMsgLevelEnum.None);

            // Initialize log file
            DateTime now = DateTime.Now;
            this.log_filename = string.Format("log_{0}.log", now.ToYYYYMMDDHHMMSSMMM());
            string full_filename = Path.Combine(channel.channel_path, this.log_filename);

            Encoding encoding = null;
            if (!String.IsNullOrEmpty(channel.channel_encoding))
                encoding = Encoding.GetEncoding(channel.channel_encoding);

            tw_log = (encoding == null ? new StreamWriter(full_filename) : new StreamWriter(full_filename, true, encoding));

            // Write header row to log
            string header_row = "COCONUT_ID;PARTNER_NOVA;EVAL_MODEL;RATING;NACE;GICS;EVAL_DATE;COMMENT";
            tw_log.WriteLine(header_row);

            session.Log("InitializeLogFile finished.", "GBL_PartnerRatingSMBImport", GMI_LogMsgGroupEnum.Bl, GMI_LogMsgLevelEnum.None);
        }

        private void WriteToLog(string s) {
            tw_log.WriteLine(s);
        }

        private void ArchiveFiles() {
            session.Log("ArchiveFiles started.", "GBL_PartnerRatingSMBImport", GMI_LogMsgGroupEnum.Bl, GMI_LogMsgLevelEnum.None);

            string archive_path = Path.Combine(channel.channel_path, "archive");
            string log_path = Path.Combine(channel.channel_path, "logs");

            if (!Directory.Exists(archive_path))
                Directory.CreateDirectory(archive_path);

            if (!Directory.Exists(log_path))
                Directory.CreateDirectory(log_path);

            this.smbrat_file.MoveTo(Path.Combine(archive_path, this.smbrat_file.Name + ".arh"));

            if (File.Exists(Path.Combine(channel.channel_path, this.log_filename))) {
                tw_log.Close();
                FileInfo log_fi = new FileInfo((Path.Combine(channel.channel_path, this.log_filename)));
                log_fi.MoveTo(Path.Combine(log_path, log_fi.Name));
            }

            session.Log("ArchiveFiles finished.", "GBL_PartnerRatingSMBImport", GMI_LogMsgGroupEnum.Bl, GMI_LogMsgLevelEnum.None);
        }

        private void ClearLogFile() {
            tw_log.Close();
            string[] log_files = Directory.GetFiles(channel.channel_path, "*.log");
            foreach (string log_file in log_files)
                File.Delete(log_file);
        }
    }
}
