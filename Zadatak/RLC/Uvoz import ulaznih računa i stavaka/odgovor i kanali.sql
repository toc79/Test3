Poštovani, 

1. na testu smo podesili import stavaka ulaznih računa iz XML datoteke (koja se uređuje u excelu) iz opcije 
GL | Knjiženje | Ulazni i izlazni računi | Ulazni računi (porez)
na masci za unos/popravak ulaznog računa. Upute su u privitku "Upute oko uvoza stavaka iz xml datoteke.xlsx".
U privitku vam šaljemo i template datoteke "Template_UlazniRacuniStavke_HR.xltx" koju je potrebno popuniti i spremiti kao XML SpreeadSheet 2003. Lokacija za uvoz datoteke je 
\\Rlenova\nova_test\IO\GL_INCOMING_INVOICES_RK_IMPORT 
Podaci u datoteci/predlošku odgovaraju poljima za unos stavke kod unosa/popravaka ulaznog računa. 
U privitku vam šaljemo i xml datoteku "Uvoz_stavaka.xml" korištenu za pripremu "Upute oko uvoza stavaka iz xml datoteke.xlsx". Ista datoteka je korištena za testi uvoz te je za nju kreirana datoteka u ARCHIVE folderu.

2. Uz navedenu funkcionalnost na testu sam podesio i funkcionalnost importa ulaznih računa iz excel/xml datoteke. 
Više o navedenoj funkcionalnosti se može pročitati u helpu za IS Nova na stranici 
http://rlenova/Gmi.Help.Hr/Z/Page/GL_PrejetiRacuniDavekNovo#uvoz-ulaznih-računa 
Lokacija za uvoz datoteke je 
\\Rlenova\nova_test\IO\GL_INCOMING_INVOICES_IMPORT 
U privitku "Šifranti RLC.xlsx" vam šaljemo šifrante te template "gl_incoming_invoices_import_template_HR.xltx" i "gl_incoming_invoices_import_template_HR.xlt".
U privitku vam šaljemo i xml datoteku "gl_incoming_invoices_import_templateHR_Primjer.xml" koju sam koristio za testi uvoz te je za nju kreirana datoteka u ARCHIVE folderu

Za testiranje predlažem da prvo uspješno unesete jedan ulazni račun na testu kroz masku. Onda na temelju tih podataka, popunite predložak, spremite kao xml te ga onda uvezete.

Molim provjeru funkcionalnosti na testu. 

$SIGN 




\\RLENOVA\nova_test_io\GL_INCOMING_INVOICES_RK_IMPORT

UPDATE dbo.io_channels SET channel_path = '\\RLENOVA\nova_test_io\GL_INCOMING_INVOICES_RK_IMPORT'  WHERE channel_code = 'GL_INCOMING_INVOICES_RK_IMPORT'
UPDATE dbo.io_channels SET channel_path = '\\RLENOVA\nova_test_io\GL_INCOMING_INVOICES_IMPORT'  WHERE channel_code = 'GL_INCOMING_INVOICES_IMPORT'


800 eur licenca, povećava se iznos održavanja za 1.8% od 800,00 EUR + dodaš stavku Podešavanje i implementacija (ja mislim da nam je 2 ili 3 sata po 58,00 EUR  

[10:02] Daniel Vrpoljac
    ajd ti njima prvo pošalji mail da mi možemo zatražiti licencu i podesiti na TEST, te se u tom slučaju podešavanje naplaćuje bez obzira na kupnju modula
​[10:02] Daniel Vrpoljac
    pa kad na to odgovore, onda im pošalješ ovaj  mail
​[10:03] Daniel Vrpoljac
    da ne bi ispalo sad da su nas oni pitali da li se može testirati, a mi im kažemo "evo na testu je i naplatili smo vam podešavanje)



Poštovana/i, 

da bi vam mogli podesiti funkcionalnost na testu, moramo zatražiti testnu licencu od kolega iz Slovenije. 
U privitku vam šaljemo ponudu za podešavanje funkcionalnosti na testu koja će se naplatiti bez obzira da li ćemo funkcionalnost podešavati na produkciji (upute bi vam onda također poslali).  
U ponudu smo dodali i stavku cijene same licence u slučaju podešavanja na produkciji.