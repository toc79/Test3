using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlTypes;
using System.Data.SqlClient;
using System.Threading;
using System.Xml;
using System.Linq;
using GMI.Core;
using GMI.Core.Data;
using GMI.BusinessLogic;
using System;
using System.IO;

namespace GMI.Hr_IntegrationModule {


    /// <summary> Lego class for request index_import_prepare.
    /// Created via tool.</summary>
    /// <remarks><history><list type="bullet">
    /// <item>xx.xx.xxxx yyyy; created</item>
    ///	</list></history></remarks>
    ////////////////////////////////////////////////////////////////////////////////////
    [GMI_ScriptableLego("urn:gmi:nova:hr_integration_module", "index_import_prepare")]
    public class GMI_LegoPluginList: GMI_LegoObject {

        /// <remarks/>
        [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "2.0.50727.1432")]
        [System.SerializableAttribute()]
        [System.Diagnostics.DebuggerStepThroughAttribute()]
        [System.ComponentModel.DesignerCategoryAttribute("code")]
        [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "urn:gmi:nova:hr_integration_module")]
        [System.Xml.Serialization.XmlRootAttribute(Namespace = "urn:gmi:nova:hr_integration_module", IsNullable = false)]
        public partial class index_import_prepare {
        }

        /// <remarks/>
        [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "2.0.50727.1432")]
        [System.SerializableAttribute()]
        [System.Diagnostics.DebuggerStepThroughAttribute()]
        [System.ComponentModel.DesignerCategoryAttribute("code")]
        [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "urn:gmi:nova:hr_integration_module")]
        [System.Xml.Serialization.XmlRootAttribute(Namespace = "urn:gmi:nova:hr_integration_module", IsNullable = false)]
        public partial class index_import_prepare_response {

            private string responseField;

            /// <remarks/>
            public string response {
                get {
                    return this.responseField;
                }
                set {
                    this.responseField = value;
                }
            }
        }

        //public class GBL_AutomaticIndexImportPrepare: GMI_LegoObject {

        /// <summary> Input parameters in binary form. </summary>
        ///
        index_import_prepare ip;

        const string const_string_id_register = "HR_INDEX_IMPORT_MAPPING";
        const string const_string_response = "Pronađeno datoteka: {0}, indeksa za uvoz: {1}, uvezeno indeksa: {2}";
        const string const_string_response_no_files = "Nije bilo datoteka za obradu";
        const string defDecimalPoint = ".";
        GMI_IoChannel mainChannel;
        ImportType importT;
        string[] listOfFiles;
        index_import_response response;
        Hashtable mapping;
        int fIndex;
        int iIndex;
        string delimiter = ";";
        bool hasHeader = false;
        bool useDQoute = false;
        bool indexidComplex = false;
        int indexidField = 0;
        int[] indexidAddField;
        int indexdescField = 1;
        int indexdateField = 2;
        int indexvalueField = 3;
        string indexdateFormat = "yyyyMMdd";
        string indexdatechar = "";
        string decimalPoint = ",";
        string thousandSeparator = ".";

        /// <summary> constructor that accepts binary parameters </summary>
        //public GBL_AutomaticIndexImportPrepare(GMI_Session session, index_import_prepare input_parameters)
        //    : base(session, input_parameters) {

        public GMI_LegoPluginList(GMI_Session session, System.Xml.XmlDocument _parameters)
            : base(session, _parameters) {
            this.ip = _parameters.DeserializeXml2<index_import_prepare>();
            //this.ip = input_parameters;
            Init();
        }

        /// <summary> main business logic </summary>
        protected override void RunBl() {
            string finalResponse;
            try {
                if (listOfFiles.Length > 0) {
                    fIndex = 0;
                    iIndex = 0;
                    switch (importT) {
                        case ImportType.index_import:
                            ImportFromStandardXml();
                            break;
                        case ImportType.csv:
                            ImportFromCSV();
                            break;
                    }
                    finalResponse = string.Format(const_string_response, listOfFiles.Length, fIndex, iIndex);
                } else {
                    finalResponse = const_string_response_no_files;
                }

                this.results = new index_import_prepare_response() { response = finalResponse };
            } catch (GMI_Exception ex) {
                throw GMI_Exception.CreateMessage(ex.Message);
            }
        }

        #region "CommonMethods"
        private void Init() {
            mainChannel = GMI_IoChannel.GetChannel(session, "IndexImport");
            importT = (ImportType)Enum.Parse(typeof(ImportType), mainChannel.channel_extra_params.Trim());
            listOfFiles = GetFiles(importT == ImportType.index_import ? "xml" : "csv");
            mapping = GetMapping();
            if (importT == ImportType.csv)
                setCsvImportProperties();
        }

        private void RunImport(index_import par) {
            GMI_LegoObject obj = new GBL_AutomaticIndexInsert(session, par);
            obj.Run();
            response = (index_import_response)obj.results;
            fIndex += response.indexes_count;
            iIndex += response.indexes_imported;
        }

        private void RunImport(index_for_import[] array) {
            var e = (from l in array
                     where mapping.ContainsKey(l.index_id)
                     select new index_for_import() {
                         index_date = l.index_date,
                         index_desc = l.index_desc, index_value = l.index_value, index_id = mapping[l.index_id].ToString()
                     });

            index_import par = new index_import();
            par.indexes_for_import = e.ToArray();
            RunImport(par);
        }

        private string[] GetFiles(string fileExtension) {
            return Directory.GetFiles(mainChannel.channel_path.Trim(), string.Format("*.{0}", fileExtension));
        }

        private Hashtable GetMapping() {
            var list = Tab_GeneralRegister.CreateQuery()
                .SelectField(Tab_GeneralRegister.Columns.id_key, Tab_GeneralRegister.Columns.val_char)
                .IsEqual(Tab_GeneralRegister.Columns.id_register, const_string_id_register)
                .GetList(session);
            Hashtable t = new Hashtable(list.Count);
            foreach (var l in list) {
                t.Add(l.id_key.Trim(), l.val_char.Trim());

            }
            return t;
        }

        private void ArchiveFile(string file) {

            GMI_UtilsBl.MoveFileToArchive(session.Translations[Translations.EFileNotExists], file, true, new FileInfo(file).DirectoryName + "\\archive", "dat");
        }

        /// <summary>
        /// Type of import
        /// </summary>
        public enum ImportType {

            /// <summary>Standard xml</summary>
            index_import,
            /// <summary>Csv</summary>
            csv
        }

        private void setCsvImportProperties() {
            //delimiter
            string delim = session.DBHelper.GetCustomSetting("Hr_Integration.IndexImport.Delimiter");
            if (!delim.IsNullOrEmpty())
                delimiter = delim.Trim();

            //uses headers
            string headers = session.DBHelper.GetCustomSetting("Hr_Integration.IndexImport.HasHeader");
            if (!delim.IsNullOrEmpty() && headers.Trim() != "0")
                hasHeader = true;

            //string double quotes
            string quotes = session.DBHelper.GetCustomSetting("Hr_Integration.IndexImport.DoubleQuote");
            if (!quotes.IsNullOrEmpty() && quotes.Trim() != "0")
                useDQoute = true;

            //complex index_id from file
            string complex = session.DBHelper.GetCustomSetting("Hr_Integration.IndexImport.ComplexId");
            if (!complex.IsNullOrEmpty() && complex.Trim() != "0")
                indexidComplex = true;

            //complex index_id additional_field
            if (indexidComplex) {
                complex = session.DBHelper.GetCustomSetting("HR_Integration.IndexImport.ComplexId2");
                string[] fields = complex.Split(';');
                int x = 0;
				indexidAddField = new int[fields.Length];
                foreach (string i in fields) { 
                        indexidAddField.SetValue(int.Parse(i.Trim()), x);
                        x++;
                }                                
            }
            //position of fields in csv
            string field = session.DBHelper.GetCustomSetting("HR_Integration.IndexImport.IdField");
            if (!field.IsNullOrEmpty())
                indexidField = int.Parse(field.Trim());

            field = session.DBHelper.GetCustomSetting("HR_Integration.IndexImport.DescField");
            if (!field.IsNullOrEmpty())
                indexdescField = int.Parse(field.Trim());

            field = session.DBHelper.GetCustomSetting("HR_Integration.IndexImport.DateField");
            if (!field.IsNullOrEmpty())
                indexdateField = int.Parse(field.Trim());

            field = session.DBHelper.GetCustomSetting("HR_Integration.IndexImport.ValueField");
            if (!field.IsNullOrEmpty())
                indexvalueField = int.Parse(field.Trim());

            //date format in field
            string format = session.DBHelper.GetCustomSetting("HR_Integration.IndexImport.DateFormat");
            if (!format.IsNullOrEmpty())
                indexdateFormat = format.Trim();

            //date has add format
            format = session.DBHelper.GetCustomSetting("HR_Integration.IndexImport.DateChar");
            if (!format.IsNullOrEmpty())
                indexdatechar = format.Trim();

            //decimal point
            format = session.DBHelper.GetCustomSetting("HR_Integration.IndexImport.DecimalPoint");
            if (!format.IsNullOrEmpty())
                decimalPoint = format.Trim();

            //thounsand separator
            format = session.DBHelper.GetCustomSetting("HR_Integration.IndexImport.ThousandSeparator");
            if (!format.IsNullOrEmpty())
                thousandSeparator = format.Trim();
        }
        #endregion

        #region ImportFromXML
        private void ImportFromStandardXml() {
            foreach (string file in listOfFiles) {
                string xml = File.ReadAllText(file);
                indexes indexi = (indexes)GMI_Memento.DeserializeXml(xml, typeof(indexes));
                RunImport(indexi.index_for_import);
                ArchiveFile(file);
            }
        }
        #endregion

        #region ImportFromCsv
        private void ImportFromCSV() {
            string line;

            foreach (string file in listOfFiles) {
                ArrayList arr = new ArrayList();
                StreamReader a = new StreamReader(file);
                if (hasHeader)
                    a.ReadLine();

                while ((line = a.ReadLine()) != null) {
                    arr.Add(ProcessLine(line));
                }
                a.Close();
                index_for_import[] e = (index_for_import[])arr.ToArray(typeof(index_for_import));
                RunImport(e);
                ArchiveFile(file);
            }

        }

        private index_for_import ProcessLine(string line) {
            string[] lineParts = line.Split(delimiter.ToCharArray());
            index_for_import i = new index_for_import();
            i.index_id = CreateId(lineParts);
            i.index_desc = ClearStringField(lineParts[indexdescField], true, false);
            i.index_date = CreateIndexDate(lineParts[indexdateField]);
            i.index_value = CreateIndexValue(lineParts[indexvalueField]);

            return i;
        }

        private string ClearStringField(string s, bool clearDQoute, bool clearDateChar) {
            if (useDQoute && clearDQoute)
                s = s.Replace("\"", "");

            if (clearDateChar)
                s = s.Replace(indexdatechar, "");

            return s;
        }

        private string CreateId(string[] s1) {
            string Id = ClearStringField(s1[indexidField], true, false);

            if (indexidComplex) {

                for (int i = 0; i <= indexidAddField.Length - 1; i++) {
                    Id += ClearStringField(s1[indexidAddField[i]], true, false);
                }
            }

            return Id;
        }

        private DateTime CreateIndexDate(string s) {
            string dateString;
            dateString = ClearStringField(s, false, true);

            return DateTime.ParseExact(dateString, indexdateFormat, System.Globalization.CultureInfo.InvariantCulture, System.Globalization.DateTimeStyles.None);
        }

        private Decimal CreateIndexValue(string s) {
            string decimalString = ClearStringField(s, true, false);
            decimalString = decimalString.Replace(thousandSeparator, "");
            if (decimalPoint != defDecimalPoint)
                decimalString = decimalString.Replace(decimalPoint, defDecimalPoint);
            if (decimalString.StartsWith("."))
                decimalString = "0" + decimalString;
            return Decimal.Parse(decimalString, System.Globalization.CultureInfo.CreateSpecificCulture("en-US"));
        }
        #endregion


    }
    

    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "2.0.50727.1432")]
    [System.SerializableAttribute()]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(Namespace="urn:gmi:nova:hr_integration_module")]
    public partial class index_for_import {
        
        private string index_idField;
        
        private string index_descField;
        
        private System.DateTime index_dateField;
        
        private decimal index_valueField;
        
        /// <remarks/>
        public string index_id {
            get {
                return this.index_idField;
            }
            set {
                this.index_idField = value;
            }
        }
        
        /// <remarks/>
        public string index_desc {
            get {
                return this.index_descField;
            }
            set {
                this.index_descField = value;
            }
        }
        
        /// <remarks/>
        public System.DateTime index_date {
            get {
                return this.index_dateField;
            }
            set {
                this.index_dateField = value;
            }
        }
        
        /// <remarks/>
        public decimal index_value {
            get {
                return this.index_valueField;
            }
            set {
                this.index_valueField = value;
            }
        }
    }


    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "2.0.50727.1432")]
    [System.SerializableAttribute()]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "urn:gmi:nova:hr_integration_module")]
    [System.Xml.Serialization.XmlRootAttribute(Namespace = "urn:gmi:nova:hr_integration_module", IsNullable = false)]
    public partial class index_import {

        private index_for_import[] indexes_for_importField;

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute("indexes_for_import")]
        public index_for_import[] indexes_for_import {
            get {
                return this.indexes_for_importField;
            }
            set {
                this.indexes_for_importField = value;
            }
        }
    }

    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "2.0.50727.1432")]
    [System.SerializableAttribute()]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "urn:gmi:nova:hr_integration_module")]
    [System.Xml.Serialization.XmlRootAttribute(Namespace = "urn:gmi:nova:hr_integration_module", IsNullable = false)]
    public partial class index_import_response {

        private int indexes_countField;

        private int indexes_importedField;

        /// <remarks/>
        public int indexes_count {
            get {
                return this.indexes_countField;
            }
            set {
                this.indexes_countField = value;
            }
        }

        /// <remarks/>
        public int indexes_imported {
            get {
                return this.indexes_importedField;
            }
            set {
                this.indexes_importedField = value;
            }
        }
    }

    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "2.0.50727.1432")]
    [System.SerializableAttribute()]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true, Namespace = "urn:gmi:nova:hr_integration_module")]
    [System.Xml.Serialization.XmlRootAttribute(Namespace = "urn:gmi:nova:hr_integration_module", IsNullable = false)]
    public partial class indexes {

        private index_for_import[] index_for_importField;

        /// <remarks/>
        [System.Xml.Serialization.XmlElementAttribute("index_for_import")]
        public index_for_import[] index_for_import {
            get {
                return this.index_for_importField;
            }
            set {
                this.index_for_importField = value;
            }
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////
    /// <summary> Lego class for request index_import.
    /// Created via tool.</summary>
    /// <remarks><history><list type="bullet">
    /// <item>xx.xx.xxxx yyyy; created</item>
    ///	</list></history></remarks>
    ////////////////////////////////////////////////////////////////////////////////////
    
    public class GBL_AutomaticIndexInsert: GMI_LegoObject {

        /// <summary> Input parameters in binary form. </summary>
        ///
        index_import ip;
        int recieved_indexes;
        int imported_indexes;


        /// <summary> constructor that accepts binary parameters </summary>
        public GBL_AutomaticIndexInsert(GMI_Session session, index_import input_parameters)
            : base(session, input_parameters) {
            this.ip = input_parameters;
        }

        /// <summary> main business logic </summary>
        protected override void RunBl() {
            // perform all that is needed
            recieved_indexes = ip.indexes_for_import.Length;
            imported_indexes = 0;

            foreach (index_for_import a in ip.indexes_for_import) {
                if (!IndexExistForDate(a.index_id, a.index_date)) {
                    Tab_Rvred r = new Tab_Rvred();
                    r.id_rtip = a.index_id;
                    r.datum = a.index_date;
                    r.indeks = a.index_value;
                    r.vnesel = session.UserName;
                    r.dat_vnosa = DateTime.Now;
                    r.Insert(session);
                    imported_indexes++;
                }
            }

            // store binary results into member results
            this.results = new index_import_response() { indexes_count=recieved_indexes, indexes_imported=imported_indexes };
        }

        private bool IndexExistForDate(string id_rtip, DateTime date) {
            int check = Tab_Rvred.CreateQuery()
                    .IsEqual(Tab_Rvred.Columns.id_rtip, id_rtip)
                    .IsEqual(Tab_Rvred.Columns.datum, date)
                    .ExecuteCount(session);
            return check != 0;
        } 
    }
}