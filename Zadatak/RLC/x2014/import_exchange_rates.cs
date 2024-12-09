using System;
using System.Collections;
using System.Data;
using System.Data.SqlTypes;
using System.Data.SqlClient;
using System.Threading;
using System.Xml.Serialization;
using System.Collections.Generic;
using GMI.Core;
using GMI.Core.Data;
using GMI.BusinessLogic;
using GMI.Leasing.BusinessObjects;
using GMI.Leasing.BusinessLogic;


namespace GMI.ExtFunc.ImportExchangeRates
{
    [GMI_ScriptableLego("urn:gmi:ext_func:import_rates", "import_exchange_rates")]
    public class GMI_LegoPluginList : GMI_LegoObject
    {
        [XmlRootAttribute("import_exchange_rates", Namespace = "urn:gmi:ext_func:import_rates")]
        public class InputParameters : GMI_LegoParams
        {

            /// <summary>Should imported file be archived</summary>
            [XmlElement]
            public bool archive_file;
        }

        [XmlRootAttribute("import_exchange_rates_response", Namespace = "urn:gmi:ext_func:import_rates")]
        public class import_exchange_rates_response : GMI_LegoParams
        {
            private Tecaji[] itemsField;

            /// <remarks/>
            [System.Xml.Serialization.XmlElementAttribute("Tecaji")]
            public Tecaji[] Items
            {
                get
                {
                    return this.itemsField;
                }
                set
                {
                    this.itemsField = value;
                }
            }

        }

        InputParameters ip;
        GMI_IoChannel channel;

        /// <summary> constructor that accepts binary parameters </summary>
        public GMI_LegoPluginList(GMI_Session session, System.Xml.XmlDocument _parameters)
            : base(session, _parameters)
        {
            // check permisson
           // session.Permissions.CheckPrivileges(Functionalities.ParamsForIntercalaryInterestsInsert, GMI_UserPermissionEnum.Full);
            ip = (InputParameters)GMI_Memento.DeserializeXml(_parameters.OuterXml, typeof(InputParameters));

        }

        /// <summary> main business logic </summary>
        protected override void RunBl()
        {

            channel = GMI_IoChannel.GetChannel(session, "IMP_RATES");

            if (channel == null)
            {
                throw GMI_Exception.Create("Invalid io_channel data - null value.");
            }

            try
            {
                ExchangeRatesReader.ExchRatesReader_input_parametrs inp = new ExchangeRatesReader.ExchRatesReader_input_parametrs();
                inp.channel_code = channel.channel_encoding;
                inp.channel_file_name= channel.channel_file_name.Trim();
                inp.channel_path = channel.channel_path.Trim();
                inp.channel_extra_params = channel.channel_extra_params.Trim();
                
                ExchangeRatesReader er = new ExchangeRatesReader(session, inp);
                er.Run();
                
               import_exchange_rates_response res = new import_exchange_rates_response();
                res.Items  = er.Rates;

                if (ip.archive_file == true)
                {

                    //GMI_UtilsBl.MoveFileToArchive(session.Translations["EFileNotExists"],
                    //channel.GetAbsoluteFileName(), delete_original, archive_subdir, extension);
                    GMI_Utils.MoveFileToArchive(session.Translations["EFileNotExists"]
                    ,channel.channel_path.Trim()+channel.channel_file_name.Trim(),true,channel.channel_path.Trim()+"archive", null);
                }

                this.results = res;
              // this.xmldoc_results = new System.Xml.XmlDocument();
              // this.xmldoc_results.LoadXml(GMI_Memento.SerializeXml(res));

            }catch(Exception ex)
            {
                throw GMI_Exception.Create(ex);
            }
                        
        }
    }

    #region ExchangeRatesReader

    public class ExchangeRatesReader:GMI_LegoObject 
    {

        public class ExchRatesReader_input_parametrs: GMI_LegoParams 
        {
            public string channel_path;
            public string channel_file_name;
            public string channel_code;
            public string channel_extra_params;
        }
                
        private Tecaji[] rt;

        private ExchRatesReader_input_parametrs input_pars;
        
        public ExchangeRatesReader(GMI_Session session, ExchRatesReader_input_parametrs ip)
        :base(session,ip)
        {
            input_pars = ip;
        }

        protected override  void RunBl()
        {

            

            if (System.IO.File.Exists(input_pars.channel_path + input_pars.channel_file_name) == false)
            {
                throw GMI_Exception.Create("Invalid file path - file doesn't exist");
            }
            if (CheckMapping() == false)
            {
                throw GMI_Exception.Create("Invalid exchange rates mapping!");
            }
            
            switch (input_pars.channel_code)
            {
                case "RLHR":
                    if (ProcessRaiff() == false)
                    {
                        throw GMI_Exception.Create("Invalid file format (RLHR)!");
                    }
                    break;
                case "OTP":
                    if (ProcessOTP() == false)
                    {
                        throw GMI_Exception.Create("Invalid file format (OTP)!");
                    }
                    break;
                default:
                    throw GMI_Exception.Create("Invalid channel_code");
                    break;
            }
        }

        private bool CheckMapping()
        {
            int i = session.DBHelper.ExecuteNonQuery("Select count(*) as broj From dbo.custom_settings Where code like 'TEC_MAP%'");
            int x = session.DBHelper.ExecuteNonQuery("Select count(*) as broj From dbo.Tecajnic where id_tec_new is null and id_tec<>'000'");

            if (i != x) {return false;}

            return true;
        }

        private DataTable GetExchMappingByIdVal(string idval)
        {
            
            return GetExchMapping(String.Format("Select * From dbo.custom_settings Where code like 'TEC_MAP_{0}%'",idval));
        }

        private DataTable GetExchMapping(string sql)
        {
            return session.DBHelper.GetDataTable(sql);
        }

        private Hashtable GetExchRatesDictionary()
        {
            DataTable tbl = session.DBHelper.GetDataTable("SELECT  id_tec, id_val as [currency] FROM dbo.TECAJNIC where id_tec_new is null and id_tec<>'000'");
            Hashtable hash = new Hashtable();
            foreach (DataRow r in tbl.Rows)
            { hash.Add(r["id_tec"], r["currency"]); }

            return hash;
        }

        #region ProcessRaiff

        private  bool ProcessRaiff()
        {
           try
            {
                int i = 0;
                Hashtable hash = GetExchRatesDictionary();
                Session.Log(input_pars.channel_extra_params, "ProcessRaiff");

                if (input_pars.channel_extra_params.Contains("XLS"))
                {
                    Session.Log("Begining XLS import", "ProcessRaiff");
                    String sConnectionString = "Provider=Microsoft.Jet.OLEDB.4.0;" + "Data Source=" + input_pars.channel_path + input_pars.channel_file_name + ";" + "Extended Properties=Excel 8.0;"; 
                                        
                    System.Data.OleDb.OleDbConnection oConn = new System.Data.OleDb.OleDbConnection(sConnectionString);
                    oConn.Open();
                    System.Data.OleDb.OleDbCommand objCmdSelect = new System.Data.OleDb.OleDbCommand("SELECT * FROM [Tecaj$A10:I43]", oConn);
                    System.Data.OleDb.OleDbDataAdapter objAdapter1 = new System.Data.OleDb.OleDbDataAdapter();
                    objAdapter1.SelectCommand = objCmdSelect;
                    DataSet objDataset1 = new DataSet();
                    objAdapter1.Fill(objDataset1);
                    DataTable dt = objDataset1.Tables[0];
                    rt = new Tecaji[dt.Rows.Count];

                    foreach (DataRow row in dt.Rows)
                    {
                        if (hash.ContainsValue(row[2].ToString()))
                        {
                            DataTable tbl = GetExchMappingByIdVal(row[2].ToString());
                            foreach (DataRow r in tbl.Rows)
                            {
                                Tecaji tecaci = new Tecaji();
                                switch (r["description"].ToString())
                                {
                                    case "Srednji":
                                        tecaci.TecajValue = Decimal.Parse(row[5].ToString());
                                        break;
                                    case "Kupovni":
                                        tecaci.TecajValue = Decimal.Parse(row[4].ToString());
                                        break;
                                    case "Prodajni":
                                        tecaci.TecajValue = Decimal.Parse(row[6].ToString());
                                        break;
                                }

                                tecaci.IdTec = r["val"].ToString();
                                tecaci.Valuta = row[2].ToString();
                                tecaci.SifraValute = row[1].ToString();
                                tecaci.Jedinica = Int32.Parse(row[3].ToString());
                                rt.SetValue(tecaci, i);
                                i += 1;
                            }
                        }
                    }

                    oConn.Close();
                    Session.Log("XLS import finished", "ProcessRaiff");
                }
                else
                {
                    Session.Log("Begining XML import", "ProcessRaiff");
                    System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                    doc.Load(input_pars.channel_path + input_pars.channel_file_name);
                    XmlSerializer ser = new XmlSerializer(typeof(RLHRFormat.TecajnaLista));
                    System.IO.StringReader rs = new System.IO.StringReader(doc.OuterXml);
                    RLHRFormat.TecajnaLista tec = (RLHRFormat.TecajnaLista)ser.Deserialize(rs);//.DeserializeXml(doc.OuterXml ,typeof(TecajnaLista));
                    rt = new Tecaji[tec.Tecajevi.Length];
                    
                    foreach (RLHRFormat.TecajnaListaTecaj exch in tec.Tecajevi)
                    {
                        if (hash.ContainsValue(exch.Valuta))
                        {
                            DataTable tbl = GetExchMappingByIdVal(exch.Valuta);
                            foreach (DataRow r in tbl.Rows)
                            {
                                Tecaji tecaci = new Tecaji();
                                switch (r["description"].ToString())
                                {
                                    case "Srednji":
                                        tecaci.TecajValue = exch.Srednji;
                                        break;
                                    case "Kupovni":
                                        tecaci.TecajValue = exch.KupovniZaDevize;
                                        break;
                                    case "Prodajni":
                                        tecaci.TecajValue = exch.ProdajniZaDevize;
                                        break;
                                }

                                tecaci.IdTec = r["val"].ToString();
                                tecaci.Valuta = exch.Valuta;
                                tecaci.SifraValute = exch.SifraValute.ToString();
                                tecaci.Jedinica = (int)exch.Jedinica;
                                rt.SetValue(tecaci, i);
                                i += 1;
                            }
                        }
                    }
                    Session.Log("XML import finished", "ProcessRaiff");
                }
                return true;
            }catch(Exception ex){
                throw GMI_Exception.Create(ex);
            }

        }

        #endregion

        #region ProcessOTP

        private bool ProcessOTP()
        {
            try
            {
                Session.Log("Begining XML import", "ProcessOTP");
                System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                doc.Load(input_pars.channel_path + input_pars.channel_file_name);
                XmlSerializer ser = new XmlSerializer(typeof(OTPFormat.TecajnaLista));
                System.IO.StringReader rs = new System.IO.StringReader(doc.OuterXml);
                OTPFormat.TecajnaLista tec = (OTPFormat.TecajnaLista)ser.Deserialize(rs);//.DeserializeXml(doc.OuterXml ,typeof(TecajnaLista));
                rt = new Tecaji[tec.Valute.Length];
                int i = 0;
                Hashtable hash = GetExchRatesDictionary();

                foreach (OTPFormat.TecajnaListaValuta exch in tec.Valute)
                {
                    if (hash.ContainsValue(exch.Oznaka))
                    {
                        DataTable tbl = GetExchMappingByIdVal(exch.Oznaka);
                        foreach (DataRow r in tbl.Rows)
                        {
                            Tecaji tecaci = new Tecaji();
                            switch (r["description"].ToString())
                            {
                                case "Srednji":
                                    tecaci.TecajValue = Decimal.Parse(exch.Srednji.Replace(",","."));
                                    break;
                                case "Kupovni":
                                    tecaci.TecajValue = Decimal.Parse(exch.KupovniDevize.Replace(",", "."));
                                    break;
                                case "Prodajni":
                                    tecaci.TecajValue = Decimal.Parse(exch.ProdajniDevize.Replace(",", "."));
                                    break;
                            }

                            tecaci.IdTec = r["val"].ToString();
                            tecaci.Valuta = exch.Oznaka;
                            tecaci.SifraValute = exch.Sifra.ToString();
                            tecaci.Jedinica = (int)exch.Jedinica;
                            rt.SetValue(tecaci, i);
                            i += 1;
                        }
                    }
                }
                Session.Log("XML import finnished", "ProcessOTP");
                return true;
            }
            catch (Exception ex)
            {
                throw GMI_Exception.Create(ex);
            }
        }

        #endregion

        public Tecaji[] Rates
        { get { return this.rt; } }

    }

    #endregion


    #region ResultFileFormat
    //format of XML for result it must be same for everyone
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "2.0.50727.1432")]
    [System.SerializableAttribute()]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(Namespace = "urn:gmi:ext_func:import_rates")]
    public partial class Tecaji
    {
        private string idtec;

        private string valuta;

        private string sifraValute;

        private int jedinica;

        private decimal tecaj;

        ///<remarks/>
        public string IdTec
        {
            get
            {
                return this.idtec; 
            }
            set
            {
                this.idtec=value;
            }
        }

        /// <remarks/>
        public string Valuta
        {
            get
            {
                return this.valuta;
            }
            set
            {
                this.valuta = value;
            }
        }

        /// <remarks/>
        public string SifraValute
        {
            get
            {
                return this.sifraValute;
            }
            set
            {
                this.sifraValute = value;
            }
        }

        /// <remarks/>
        public int Jedinica
        {
            get
            {
                return this.jedinica;
            }
            set
            {
                this.jedinica = value;
            }
        }

        /// <remarks/>
        public decimal TecajValue
        {
            get
            {
                return this.tecaj;
            }
            set
            {
                this.tecaj = value;
            }
        }

    }

    #endregion


    #region FileFormats
    //From here we write formats of file for import
    #region RLHR Formater

    public class RLHRFormat
    {
    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "2.0.50727.1432")]
    [System.SerializableAttribute()]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    [System.Xml.Serialization.XmlRootAttribute(Namespace = "", IsNullable = false)]
    public partial class TecajnaLista
    {

        private TecajnaListaZaglavlje zaglavljeField;

        private TecajnaListaTecaj[] tecajeviField;

        /// <remarks/>
        public TecajnaListaZaglavlje Zaglavlje
        {
            get
            {
                return this.zaglavljeField;
            }
            set
            {
                this.zaglavljeField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlArrayItemAttribute("Tecaj", IsNullable = false)]
        public TecajnaListaTecaj[] Tecajevi
        {
            get
            {
                return this.tecajeviField;
            }
            set
            {
                this.tecajeviField = value;
            }
        }
    }

    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "2.0.50727.1432")]
    [System.SerializableAttribute()]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class TecajnaListaZaglavlje
    {

        private byte brojTLField;

        private string datumUtvrdjenaField;

        private string datumVrijediOdField;

        /// <remarks/>
        public byte BrojTL
        {
            get
            {
                return this.brojTLField;
            }
            set
            {
                this.brojTLField = value;
            }
        }

        /// <remarks/>
        public string DatumUtvrdjena
        {
            get
            {
                return this.datumUtvrdjenaField;
            }
            set
            {
                this.datumUtvrdjenaField = value;
            }
        }

        /// <remarks/>
        public string DatumVrijediOd
        {
            get
            {
                return this.datumVrijediOdField;
            }
            set
            {
                this.datumVrijediOdField = value;
            }
        }
    }

    /// <remarks/>
    [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "2.0.50727.1432")]
    [System.SerializableAttribute()]
    [System.Diagnostics.DebuggerStepThroughAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public partial class TecajnaListaTecaj
    {

        private ushort sifraValuteField;

        private string valutaField;

        private byte jedinicaField;

        private decimal kupovniZaDevizeField;

        private decimal srednjiField;

        private decimal prodajniZaDevizeField;

        private decimal kupovniZaEfektivuField;

        private decimal prodajniZaEfektivuField;

        /// <remarks/>
        public ushort SifraValute
        {
            get
            {
                return this.sifraValuteField;
            }
            set
            {
                this.sifraValuteField = value;
            }
        }

        /// <remarks/>
        public string Valuta
        {
            get
            {
                return this.valutaField;
            }
            set
            {
                this.valutaField = value;
            }
        }

        /// <remarks/>
        public byte Jedinica
        {
            get
            {
                return this.jedinicaField;
            }
            set
            {
                this.jedinicaField = value;
            }
        }

        /// <remarks/>
        public decimal KupovniZaDevize
        {
            get
            {
                return this.kupovniZaDevizeField;
            }
            set
            {
                this.kupovniZaDevizeField = value;
            }
        }

        /// <remarks/>
        public decimal Srednji
        {
            get
            {
                return this.srednjiField;
            }
            set
            {
                this.srednjiField = value;
            }
        }

        /// <remarks/>
        public decimal ProdajniZaDevize
        {
            get
            {
                return this.prodajniZaDevizeField;
            }
            set
            {
                this.prodajniZaDevizeField = value;
            }
        }

        /// <remarks/>
        public decimal KupovniZaEfektivu
        {
            get
            {
                return this.kupovniZaEfektivuField;
            }
            set
            {
                this.kupovniZaEfektivuField = value;
            }
        }

        /// <remarks/>
        public decimal ProdajniZaEfektivu
        {
            get
            {
                return this.prodajniZaEfektivuField;
            }
            set
            {
                this.prodajniZaEfektivuField = value;
            }
        }
    }
}

#endregion 

    #region OTP Formater

    public class OTPFormat
    {
        //------------------------------------------------------------------------------
        // <auto-generated>
        //     This code was generated by a tool.
        //     Runtime Version:2.0.50727.3074
        //
        //     Changes to this file may cause incorrect behavior and will be lost if
        //     the code is regenerated.
        // </auto-generated>
        //------------------------------------------------------------------------------


        // 
        // This source code was auto-generated by xsd, Version=2.0.50727.1432.
        // 


        /// <remarks/>
        [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "2.0.50727.1432")]
        [System.SerializableAttribute()]
        [System.Diagnostics.DebuggerStepThroughAttribute()]
        [System.ComponentModel.DesignerCategoryAttribute("code")]
        [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
        [System.Xml.Serialization.XmlRootAttribute(Namespace = "", IsNullable = false)]
        public partial class TecajnaLista
        {

            private string bankaField;

            private byte brojField;

            private string utvrdjenaField;

            private string primjenaField;

            private TecajnaListaValuta[] valuteField;

            /// <remarks/>
            public string Banka
            {
                get
                {
                    return this.bankaField;
                }
                set
                {
                    this.bankaField = value;
                }
            }

            /// <remarks/>
            public byte Broj
            {
                get
                {
                    return this.brojField;
                }
                set
                {
                    this.brojField = value;
                }
            }

            /// <remarks/>
            public string Utvrdjena
            {
                get
                {
                    return this.utvrdjenaField;
                }
                set
                {
                    this.utvrdjenaField = value;
                }
            }

            /// <remarks/>
            public string Primjena
            {
                get
                {
                    return this.primjenaField;
                }
                set
                {
                    this.primjenaField = value;
                }
            }

            /// <remarks/>
            [System.Xml.Serialization.XmlArrayItemAttribute("Valuta", IsNullable = false)]
            public TecajnaListaValuta[] Valute
            {
                get
                {
                    return this.valuteField;
                }
                set
                {
                    this.valuteField = value;
                }
            }
        }

        /// <remarks/>
        [System.CodeDom.Compiler.GeneratedCodeAttribute("xsd", "2.0.50727.1432")]
        [System.SerializableAttribute()]
        [System.Diagnostics.DebuggerStepThroughAttribute()]
        [System.ComponentModel.DesignerCategoryAttribute("code")]
        [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
        public partial class TecajnaListaValuta
        {

            private ushort sifraField;

            private string oznakaField;

            private byte jedinicaField;

            private string kupovniEfektivaField;

            private string kupovniDevizeField;

            private string srednjiField;

            private string prodajniDevizeField;

            private string prodajniEfektivaField;

            /// <remarks/>
            public ushort Sifra
            {
                get
                {
                    return this.sifraField;
                }
                set
                {
                    this.sifraField = value;
                }
            }

            /// <remarks/>
            public string Oznaka
            {
                get
                {
                    return this.oznakaField;
                }
                set
                {
                    this.oznakaField = value;
                }
            }

            /// <remarks/>
            public byte Jedinica
            {
                get
                {
                    return this.jedinicaField;
                }
                set
                {
                    this.jedinicaField = value;
                }
            }

            /// <remarks/>
            public string KupovniEfektiva
            {
                get
                {
                    return this.kupovniEfektivaField;
                }
                set
                {
                    this.kupovniEfektivaField = value;
                }
            }

            /// <remarks/>
            public string KupovniDevize
            {
                get
                {
                    return this.kupovniDevizeField;
                }
                set
                {
                    this.kupovniDevizeField = value;
                }
            }

            /// <remarks/>
            public string Srednji
            {
                get
                {
                    return this.srednjiField;
                }
                set
                {
                    this.srednjiField = value;
                }
            }

            /// <remarks/>
            public string ProdajniDevize
            {
                get
                {
                    return this.prodajniDevizeField;
                }
                set
                {
                    this.prodajniDevizeField = value;
                }
            }

            /// <remarks/>
            public string ProdajniEfektiva
            {
                get
                {
                    return this.prodajniEfektivaField;
                }
                set
                {
                    this.prodajniEfektivaField = value;
                }
            }
        }
    }

    #endregion

    #endregion
}