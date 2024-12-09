using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Data;
using System.Data.SqlTypes;
using System.Data.SqlClient;
using System.Threading;
using System.Xml.Serialization;
using System.Collections.Generic;
using System.Linq;
using GMI.Core;
using GMI.Core.Data;
using GMI.BusinessLogic;
using GMI.Leasing.BusinessLogic;

namespace Gmi.ExtFunc.RLHR {
    /// <summary>
    /// 
    /// </summary>
    [GMI_ScriptableLego("urn:gmi:ext_func:hr_RL", "CRS_IMPORT")]
    public class CRS_IMPORT : GMI_LegoObject {

        /// <summary>
        /// 
        /// </summary>
        [XmlRootAttribute("CRS_IMPORT", Namespace = "urn:gmi:ext_func:hr_RL")]
        public class InputParameters {
        }

        /// <summary>
        /// 
        /// </summary>
        [XmlRootAttribute("CRS_IMPORT_RESPONSE", Namespace = "urn:gmi:ext_func:hr_RL")]
        public class CRS_IMPORT_RESPONSE {
            /// <summary>
            /// 
            /// </summary>
            [XmlElement]
            public string result;
        }

        int filesFound = 0;
        int filesProcessed = 0;
        int errorFiles = 0;
        int errorCustomers = 0;
        int customerProcessed = 0;
        int importCustomersError = 0;
        const string evalType = "C";
        InputParameters ip;
        GMI_IoChannel channel;
        string logFile;
        GMI_IFormattingStrategy fs = GMI_FormattingStrategyCsv.Singleton;

        /// <summary> constructor that accepts binary parameters </summary>
        public CRS_IMPORT(GMI_Session session, System.Xml.XmlDocument _parameters)
            : base(session, _parameters) {
            // check permisson
            //session.Permissions.CheckPrivileges(Functionalities.SpecialServicesRecoveryReportEventInsert, GMI_UserPermissionEnum.Full);
            ip = _parameters.DeserializeXml2<InputParameters>();
        }

        /// <summary> main business logic </summary>
        protected override void RunBl() {
            channel = GMI_IoChannel.GetChannel(session, "CRS_IMPORT");
            if (channel == null)
                throw GMI_Exception.CreateMessage("No channel for import defined!");

            if (!channel.channel_path.EndsWith(Path.DirectorySeparatorChar.ToString()))
                channel.channel_path += Path.DirectorySeparatorChar;

            string[] importFiles = GetFiles();

            session.Log("Files found: " + importFiles.Length.ToString(), "CRS_IMPORT");

            if (importFiles.Length > 0) {
                this.filesFound = importFiles.Length;
                foreach (string singleFile in importFiles) {
                    try {
                        ProcessSingleFile(singleFile);
                        GMI_Utils.MoveFileToArchive(session.Translations["EFileNotExists"], singleFile, true, channel.channel_path.Trim() + "archive", null);
                    } catch (GMI_Exception ex) {
                        session.Log(ex.Message, "CRS_IMPORT");
                    }
                }

                string res = "Files Found: " + this.filesFound.ToString() + "\r\n";
                res += "Files processed: " + this.filesProcessed.ToString() + "\r\n";
                res += "Errors processing files: " + this.errorFiles.ToString() + "\r\n";
                res += "Error founding customers: " + this.errorCustomers.ToString() + "\r\n";
                res += "Customers imported: " + this.customerProcessed.ToString() + "\r\n";
                res += "Customers not imported " + this.importCustomersError.ToString() + "\r\n";

                this.results = new CRS_IMPORT_RESPONSE() { result = res };
            } else {
                this.results = new CRS_IMPORT_RESPONSE() { result = "No CRS files found!" };
            }
        }

        /// <summary>
        /// Single file processing
        /// </summary>
        /// <param name="singleFile"></param>
        private void ProcessSingleFile(string singleFile) {
            session.Log("Processing single file:" + singleFile, "CRS_IMPORT");
            //DateTime date = CreateDateFromFileName(singleFile.Substring(singleFile.LastIndexOf(Path.DirectorySeparatorChar.ToString())+1));

            if (!CheckFile(singleFile)) {
                this.errorFiles++;
            } else {
                string[] allLines = File.ReadAllLines(singleFile);
                var linesList = allLines.ToList();
                var dataLines = (from l in linesList
                                 where l != String.Empty && l != linesList[0]
                                 select l).ToArray();

                session.Log("No of rows in file" + dataLines.Length.ToString(), "CRS_IMPORT");
                DataTable dt = new DataTable("singleFile");
                dt.Columns.Add("coconut", Type.GetType("System.String"));
                dt.Columns.Add("crs", Type.GetType("System.String"));
                dt.Columns.Add("crs_datum", typeof(System.DateTime));
                dt.Columns.Add("skrbnik2", Type.GetType("System.String"));
                dt.Columns.Add("crs_zadnji", Type.GetType("System.String"));
                dt.Columns.Add("datum_zadnji", typeof(System.DateTime));
                dt.Columns.Add("sifra_klijenta", Type.GetType("System.String"));
                dt.Columns.Add("naziv_klijenta", Type.GetType("System.String"));
                dt.Columns.Add("izlozenost", Type.GetType("System.Decimal"));
                dt.Columns.Add("uvezeno", Type.GetType("System.String"));
                dt.Columns.Add("crs_slovo", Type.GetType("System.String"));

                foreach (string dataLine in dataLines) {
                    string[] columns = dataLine.Split(';');
                    string coconut = columns[0].ToString().Trim().Replace("\"", "");
                    string crs = string.Format("0{0}", columns[1].ToString().Trim());
                    session.Log("Process cocunut: " + coconut, "CRS_IMPORT");
                    string customer = (string)session.DBHelper.LookupQOrNull(Tab_Partner.Columns.id_kupca, Tab_Partner.TableName, Tab_Partner.Columns.ext_id, coconut);
                    bool import = false;
                    bool gotoimport = false;
                    decimal izlozenost = 0;
                    string crs_lasttime = "";
                    DateTime? crs_datelast = null;
                    DateTime? date = null;
                    string skrbnik2 = "";
                    string naz_kr_kup = "";
                    string crs_slovo = columns[5].ToString().Trim();

                    string crs_datum = columns[2].ToString().Trim().Replace("\"", "");
                    if (crs_datum != string.Empty)
                        date = CreateDateFromStringColumn(crs_datum);

                    if (customer != null && crs != "04") {
                        customer = customer.Trim();
                        session.Log("NOVA customer: " + customer, "CRS_IMPORT");
                        naz_kr_kup = (string)session.DBHelper.LookupQOrNull(Tab_Partner.Columns.naz_kr_kup, Tab_Partner.TableName, Tab_Partner.Columns.id_kupca, customer);
                        skrbnik2 = (string)session.DBHelper.LookupQOrNull(Tab_Partner.Columns.skrbnik_2, Tab_Partner.TableName, Tab_Partner.Columns.id_kupca, customer);
                        naz_kr_kup = naz_kr_kup == null ? "" : naz_kr_kup.Trim();
                        skrbnik2 = skrbnik2 == null ? "" : skrbnik2.Trim();

                        if (customer != null && customer != string.Empty && crs_datum != string.Empty) {
                            Tab_PEval pe;
                            var pes = Tab_PEval.CreateQuery()
                                .IsEqual("id_kupca", customer)
                                .IsEqual("eval_type", evalType)
                                .SetTop(1)
                                .OrderByDesc("dat_eval")
                                .Execute(session);
                            if (pes.Length > 0) {
                                pe = (Tab_PEval)pes.GetValue(0);
                                crs_lasttime = pe.oall_ratin.ToString().Trim();
                                crs_datelast = pe.dat_eval;
                            }

                            izlozenost = GetIzlozenost(customer);

                            if (singleFile.Contains("banke")) {
                                if (skrbnik2 != "000015" || skrbnik2 == string.Empty) {
                                    gotoimport = false;
                                } else {
                                    if ((crs_lasttime == "04" && crs_lasttime == crs) || (crs_lasttime != "04" || crs_lasttime == string.Empty)) {
                                        gotoimport = true;
                                    }
                                }
                            } else {
                                gotoimport = true;
                            }

                            if (gotoimport)
                                import = CreateEvalTypeC(customer, crs, date.Value, crs_slovo);
                        }
                    } else {
                        if (crs == "04") { this.importCustomersError++; } else { this.errorCustomers++; }
                    }
                    dt.Rows.Add(new Object[] { coconut, crs, date == null ? DateTime.Parse("01/01/1900") : date.Value, skrbnik2, crs_lasttime, crs_datelast == null ? DateTime.Parse("01/01/1900") : crs_datelast.Value, customer, naz_kr_kup, izlozenost, import ? "DA" : "NE", crs_slovo });
                }
                WriteToLogFile(dt, singleFile);
                this.filesProcessed++;
            }
        }

        /// <summary>
        /// Creates new evaluation type C on date
        /// </summary>
        /// <param name="customer"></param>
        /// <param name="custRatin"></param>
        /// <param name="date"></param>
        private bool CreateEvalTypeC(string customer, string custRatin, DateTime date, string crs_slovo) {
            bool result = false;
            try {
                var evalCount = Tab_PEval.CreateQuery().IsEqual("dat_eval", date).IsEqual("id_kupca", customer).IsEqual("eval_type", evalType).ExecuteCount(session);
                if (evalCount == 0) {
                    p_eval_iu_register newEvalTypeC = new p_eval_iu_register();
                    newEvalTypeC.is_update = false;
                    newEvalTypeC.asset_clas = string.Empty;
                    newEvalTypeC.coll_ratin = string.Empty;
                    newEvalTypeC.cust_ratin = crs_slovo;
                    newEvalTypeC.dat_eval = date;
                    newEvalTypeC.dat_vnosa = DateTime.Today;
                    newEvalTypeC.eval_model = string.Empty;
                    newEvalTypeC.id_kupca = customer;
                    newEvalTypeC.limita = 0;
                    newEvalTypeC.oall_ratin = custRatin;
                    newEvalTypeC.tec_limite = "000";
                    newEvalTypeC.vnesel = session.UserName;
                    newEvalTypeC.id = string.Empty;
                    newEvalTypeC.eval_type = evalType;
                    newEvalTypeC.opombe = string.Empty;


                    GBL_PEvalIURegister newEval = new GBL_PEvalIURegister(session, newEvalTypeC);
                    newEval.Run();

                    this.customerProcessed++;
                    result = true;
                } else {
                    this.importCustomersError++;
                }
            } catch (GMI_Exception ex) {
                throw GMI_Exception.Create(ex);
            }
            return result;
        }

        /// <summary>
        /// Checks if file is in right format
        /// </summary>
        /// <param name="singleFile"></param>
        /// <returns></returns>
        private bool CheckFile(string singleFile) {
            bool test = false;
            Encoding fileEncoding = this.channel.channel_encoding == null || this.channel.channel_encoding == "" ? Encoding.Default : Encoding.GetEncoding(this.channel.channel_encoding);
            TextReader tr = new StreamReader(singleFile, fileEncoding);

            string firstLine = tr.ReadLine();
            string[] columns = firstLine.Split(';');

            if (columns.Length >= 3) {
                if ((columns[0].ToLower() == "customer" || columns[0].ToLower() == "cocunut") && columns[1].ToLower() == "crs" && columns[2].ToLower() == "crs_datum" && columns[5].ToLower() == "crs_slovo")
                    test = true;
            }
            tr.Close();
            return test;
        }

        /// <summary>
        /// Creates list of found files
        /// </summary>
        /// <returns></returns>
        private string[] GetFiles() {
            return Directory.GetFiles(channel.channel_path, "EWS*RiskStatus*.csv", SearchOption.TopDirectoryOnly);
        }

        /// <summary>
        /// Creates date from file name
        /// </summary>
        /// <param name="fileName"></param>
        /// <returns></returns>
        private DateTime CreateDateFromFileName(string fileName) {
            fileName = fileName.Substring(fileName.IndexOf('_') + 1, 8);
            fileName = fileName.Substring(2, 2) + "/" + fileName.Left(2) + "/" + fileName.Right(4);
            return DateTime.Parse(fileName);
        }

        /// <summary>
        /// Creates date from string column
        /// </summary>
        /// <param name="stringDate"></param>
        /// <returns></returns>
        private DateTime CreateDateFromStringColumn(string stringDate) {
            if (stringDate.Contains(".")) {
                int i = stringDate.IndexOf(".");
                int j = stringDate.LastIndexOf(".");
                int x = stringDate.Length;
                stringDate = string.Format("{0:d2}{1:d2}{2}", Int32.Parse(stringDate.Substring(0, i)), Int32.Parse(stringDate.Substring(i + 1, j - (i + 1))), stringDate.Substring(j + 1, 4));
            }

            stringDate = stringDate.Left(2) + "/" + stringDate.Substring(2, 2) + "/" + stringDate.Right(4);
            return DateTime.Parse(stringDate);
        }

        private void WriteToLogFile(DataTable dt, string fileName) {
            if (this.logFile != null)
                logFile = null;

            logFile = fileName.Replace(".csv", ".log.xml");
            logFile = logFile.Replace(channel.channel_path.Trim(), channel.channel_path.Trim() + "reports" + Path.DirectorySeparatorChar);

            dt.WriteXml(logFile);
            ReportXML rp = new ReportXML();
            ReportXMLRow[] rpr = new ReportXMLRow[dt.Rows.Count];
            int i = 0;
            foreach (DataRow r in dt.Rows) {
                ReportXMLRow row = new ReportXMLRow();
                row.CRS = r["crs"].ToString();
                row.CRS_DATUM = DateTime.Parse(r["crs_datum"].ToString());
                row.CRS_ZADNJI = r["crs_zadnji"].ToString();
                if (DateTime.Parse(r["datum_zadnji"].ToString()).ToShortDateString().Contains(".1900")) {
                    row.CRS_ZADNJI_DATUM = null;
                } else {
                    row.CRS_ZADNJI_DATUM = DateTime.Parse(r["datum_zadnji"].ToString());
                }
                row.Customer = r["coconut"].ToString();
                row.NAZIV_KLIJENTA = r["naziv_klijenta"].ToString();
                row.SIFRA_KLIJENTA = r["sifra_klijenta"].ToString();
                row.SKRBNIK2 = r["skrbnik2"].ToString();
                row.Uvezeno = r["uvezeno"].ToString();
                row.Izlozenost = Decimal.Parse(r["izlozenost"].ToString());
                row.CRS_SLOVO = r["crs_slovo"].ToString();
                rpr.SetValue(row, i);
                i++;
            }
            rp.ReportRows = rpr;
            System.Xml.XmlDocument doc = rp.SerializeXmlDoc();
            doc.Save(logFile);
        }

        /// <summary>
        /// Converting date to string in specified format by RLHR
        /// </summary>
        /// <param name="date"></param>
        /// <returns></returns>
        private string DateToString(DateTime date) {
            var stringDate = string.Format("{0:d2}{1:d2}{2}", date.Day, date.Month, date.Year.ToString());
            return stringDate;
        }

        /// <summary>
        /// Get total obligo defined by RLHR
        /// </summary>
        /// <param name="customer">id_kupca</param>
        /// <returns></returns>
        private decimal GetIzlozenost(string customer) {
            string sql = @"Select isnull(i.izlozenost,0)+isnull(k.razlika_val,0) as izlozenost_EUR 
                          From dbo.partner a 
                            LEFT JOIN (Select a.id_kupca, sum(dbo.gfn_xchange('006',znp_saldo_brut_all+bod_neto_lpod,a.id_tec,getdate())) as izlozenost
			                        From dbo.planp_ds a
			                        LEFT JOIN dbo.pogodba b on a.id_cont = b.id_cont
			                        Where b.status_akt NOT IN ('N','Z')
			                        Group by a.id_kupca
                            ) i ON a.id_kupca = i.id_kupca
                            left join (SELECT id_kupca, sum(dbo.gfn_xchange('006',razlika_val,id_tec,getdate())) as razlika_val
                                    FROM dbo.gfn_FrameView(0,0,1,'{0}',1,'19000101',getdate(),0,0,'',0,'',0,0,0,0) 
                                    where status_akt='A' 
                                    and sif_frame_type = 'REV'
                                    Group by id_kupca
                            )  k on a.id_kupca = k.id_kupca 
                            Where a.id_kupca = '{0}'";

            return (decimal)session.DBHelper.ExecuteScalar(string.Format(sql, customer));
        }
    }
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "2.0.50727.1432")]
    [System.SerializableAttribute()]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    [System.Xml.Serialization.XmlRootAttribute(Namespace = "", IsNullable = false)]
    public partial class ReportXML {
        private ReportXMLRow[] row;

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute("ReportXMLRow")]
        public ReportXMLRow[] ReportRows {
            get { return this.row; }

            set { this.row = value; }
        }

    }

    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "2.0.50727.1432")]
    [System.SerializableAttribute()]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    [System.Xml.Serialization.XmlRootAttribute(Namespace = "", IsNullable = false)]
    public partial class ReportXMLRow {
        private string customerField;

        private string crsField;

        private DateTime? crs_datumField;

        private string skrbnik2Field;

        private string crs_zadnjiField;

        private DateTime? crs_datum_zadnjiField;

        private string sifra_klijentaField;

        private string naziv_klijentaField;

        private decimal izlozenostField;

        private string uvezenoField;

        private string crs_slovoField;

        /// <remarks/>
        public string Customer {
            get { return this.customerField; }
            set { this.customerField = value; }
        }

        /// <remarks/>
        public string CRS {
            get { return this.crsField; }
            set { this.crsField = value; }
        }

        /// <remarks/>
        public DateTime? CRS_DATUM {
            get { return this.crs_datumField; }
            set { this.crs_datumField = value; }
        }

        /// <remarks/>
        public string SKRBNIK2 {
            get { return this.skrbnik2Field; }
            set { this.skrbnik2Field = value; }
        }

        /// <remarks/>
        public string CRS_ZADNJI {
            get { return this.crs_zadnjiField; }
            set { this.crs_zadnjiField = value; }
        }

        /// <remarks/>
        public DateTime? CRS_ZADNJI_DATUM {
            get { return this.crs_datum_zadnjiField; }
            set { this.crs_datum_zadnjiField = value; }
        }

        /// <remarks/>
        public string SIFRA_KLIJENTA {
            get { return this.sifra_klijentaField; }
            set { this.sifra_klijentaField = value; }
        }

        /// <remarks/>
        public string NAZIV_KLIJENTA {
            get { return this.naziv_klijentaField; }
            set { this.naziv_klijentaField = value; }
        }

        /// <remarks/>
        public decimal Izlozenost {
            get { return this.izlozenostField; }
            set { this.izlozenostField = value; }
        }

        /// <remarks/>
        public string Uvezeno {
            get { return this.uvezenoField; }
            set { this.uvezenoField = value; }
        }

        /// <remarks/>
        public string CRS_SLOVO {
            get { return this.crs_slovoField; }
            set { this.crs_slovoField = value; }
        }
    }
}
