using System;
using System.Drawing;
using System.Windows.Forms;
using System.Data;
using Stimulsoft.Controls;
using Stimulsoft.Base.Drawing;
using Stimulsoft.Report;
using Stimulsoft.Report.Dialogs;
using Stimulsoft.Report.Components;
using System.Globalization;
using System.Collections;
using System.Collections.Generic;
//using System.Linq;



namespace Reports
{
	using Gmi.Core;
	public class Report : Stimulsoft.Report.StiReport
	{
        
		public Report()
		{
			this.InitializeComponent();
		}
		#region StiReport Designer generated code - do not modify
		#endregion StiReport Designer generated code - do not modify
	}
}


namespace Gmi.Core {
	
	public static class Gmi_Utils {
		public enum WordLang {
			HR,
			RS,
			SLO
		}		
		
		public static string NumberToWords(decimal number, WordLang type, bool show_decimal){
			string firstPart;
			string secondPart;
			
			int i = int.Parse(number.ToString(CultureInfo.InvariantCulture).Split('.')[0]);
			firstPart = NumberToWords(i, type);
			
			i = int.Parse(number.ToString(CultureInfo.InvariantCulture).Split('.')[1]);
			secondPart = NumberToWords(i, type);
			
			if (show_decimal)
				return string.Format("{0} zarez {1}", firstPart, secondPart);
			else
				return firstPart;
		}
		
		private static string NumberToWords(int number, WordLang type){
			if(type == WordLang.RS)
				return NumberToWordsRS(number);
			else if(type == WordLang.HR)
				return NumberToWordsHR(number);
			return "";
		}
				
		
		private static string NumberToWordsRS(int number){
			
			if(number == 0)
				return "nula";	
				
			if(number < 0)
				return "minus" + NumberToWordsRS(Math.Abs(number));
				
			string words = "";
				
				
				
			if ((number / 1000000) > 0){     
				if ((number / 1000000) == 1) {
					words += "milion ";         
				}else{
					words += NumberToWordsRS(number / 1000000) + " miliona ";         
				}
				
				number %= 1000000;     
			}
				
			if ((number / 1000) > 0){
					
				if((number / 1000) == 1){
					words += "hiljadu ";
				}else if ((number / 1000) >= 2 && (number / 1000) <=4 ){
					words += (NumberToWordsRS(number / 1000) + " hiljade ").Replace("jedan","jedna").Replace("dva hiljade","dve hiljade").Replace("tri hiljada", "tri hiljade");
				}else{
					words += (NumberToWordsRS(number / 1000) + " hiljada ").Replace("jedan","jedna").Replace("dva hiljade","dve hiljade").Replace("tri hiljada", "tri hiljade"); 
				}
					
				number %= 1000;     
			}      
				
			if ((number / 100) > 0){     
				if((number/100) == 1){
					words += " sto ";
				}else if ((number/100)== 2){
					words += " dvjesta ";
				}else if ((number/100)== 3){
					words += " trista ";
				}else{
					words += NumberToWordsRS(number / 100) + "sto ";         					     
				}
				number %= 100;
			}      
				
			if (number > 0) {
				if (words != "")             
					words += " ";          
					
				string[] unitsMap = new string[] { "nula", "jedan", "dva", "tri", "četiri", "pet", "šest", "sedam", "osam", "devet", "deset", "jedanaest", "dvanaest", "trinaest", "četrnaest", "petnaest", "šestnaest", "sedamnaest", "osamnaest", "devetnaest" };         
				string[] tensMap = new string[] { "nula", "deset", "dvadeset", "trideset", "četrdeset", "pedeset", "šezdeset", "sedamdeset", "osamdeset", "devedest" };          
					
				if (number < 20){           
					words += unitsMap[number];         
				} else {             
					words += tensMap[number / 10];             
					
					if ((number % 10) > 0)                 
						words += " " + unitsMap[number % 10];         
				}     
					
			} 
				
			return words;
		}
		
		
		private static string NumberToWordsHR(int number){
			
			if(number == 0)
				return "nula";	
				
			if(number < 0)
				return "minus" + NumberToWordsHR(Math.Abs(number));
				
			string words = "";
				
				
				
			if ((number / 1000000) > 0){     
				if ((number / 1000000) == 1) {
					words += "milijun ";         
				}else{
					words += NumberToWordsHR(number / 1000000) + " milijuna ";         
				}
				
				number %= 1000000;     
			}
				
			if ((number / 1000) > 0){
					
				if((number / 1000) == 1){
					words += "tisuću ";
				}else if ((number / 1000) >= 2 && (number / 1000) <=4 ){
					words += (NumberToWordsHR(number / 1000) + " tisuće ").Replace("jedan","jedna").Replace("dva tisuće","dvije tisuće").Replace("tri tisuće", "tri tisuće");
				}else{
					words += (NumberToWordsHR(number / 1000) + " tisuća ").Replace("jedan","jedna").Replace("dva tisuće","dvije tisuće").Replace("tri tisuća", "tri tisuće"); 
				}
					
				number %= 1000;     
			}      
				
			if ((number / 100) > 0){     
				if((number/100) == 1){
					words += " sto ";
				}else if ((number/100)== 2){
					words += " dvjesto ";
				}else if ((number/100)== 3){
					words += " tristo ";
				}else{
					words += NumberToWordsHR(number / 100) + "sto ";         					     
				}
				number %= 100;
			}      
				
			if (number > 0) {
				if (words != "")             
					words += " ";          
					
				string[] unitsMap = new string[] { "nula", "jedan", "dva", "tri", "četiri", "pet", "šest", "sedam", "osam", "devet", "deset", "jedanaest", "dvanaest", "trinaest", "četrnaest", "petnaest", "šestnaest", "sedamnaest", "osamnaest", "devetnaest" };         
				string[] tensMap = new string[] { "nula", "deset", "dvadeset", "trideset", "četrdeset", "pedeset", "šezdeset", "sedamdeset", "osamdeset", "devedest" };          
					
				if (number < 20){           
					words += unitsMap[number];         
				} else {             
					words += tensMap[number / 10];             
					
					if ((number % 10) > 0)                 
						words += " " + unitsMap[number % 10];         
				}     
					
			} 
				
			return words;
		}
		
	}
}
