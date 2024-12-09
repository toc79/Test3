select EF_OBRM, EF_OBRM_TREN, dni_financ, STR_FINANC, * from dbo.arh_pogodba where id_cont = 78746 order by time



testirao dodavanje kroz opće račune, kroz DNI_FINANC i STR_FINANC, ručni reprogram i svugdje je izračun EKSa bio OK, samo kod izdavanje iz modula interkalarnih NIJE OK.
Pripremio odgovor
Oko zadnjeg odlomka, moglo bi se napraviti da mi pokrenemo izračun u kontroli u npr. POGODBA_MASKA AFTER_SAVE ako GMI tako potvrdi da možemo to podesiti.
Slično možda bi se moglo i za interkalarnu (event ili nešto tako ako nema ext_func dok ne dođe dorada)
http://gmcv03/support/Maintenance.aspx?ID=50444


Poštovana/i, 

oko 
"Ukoliko kliknemo na trenutni izračun EKS-a, program izračuna još veću (6,4146%), a pretpostavljamo da bi trebala biti manja, obzirom da se trošak interk.kamate smanjio. "
izračunati EKS je veći zato jer imate fiktivno potraživanje IK i dalje u Plaćanjima na početku u iznosu 109,67 (bez obzira što ste obračunali interkalarnu s potraživanjem 1G "OBRAČUN za korištena sredstva" to fiktivno potraživanje ulazi u EKS).

Testirao sam izdavanje interkalarne iz modula/opcije interkalarnih kamata (opcija Održavanje | Posebne obrade | Interkalarne kamate) te kada se izda potraživanje, ne dolazi do osvježavanja EKSa. Pogledao sam u našu uputu koju smo vam slali i ta opcija nje navedena pa ćemo poslati upit kolegama u Sloveniju oko navedenog da bi se EKS i u toj opciji trebao EKS osvježiti.
Ako se npr. potraživanje 1G "OBRAČUN za korištena sredstva " doda kroz opciju općeg računa, EKS se osvježi kako je navedeno u uputi.

Testiro sam i promjenu fiktivnog troška IK "Interkalarna kamata" (promjena iznosa ili brisanje) na neaktivnom ugovoru te sam primjerio da ako NIJE označena opcija "Ponovno generiraj plan otplate", da se onda osvježi samo početni EKS, a trenutni se ne osvježi. Pa molimo da na to obratite pažnju. Znači ako radite promjenu troškova bez kvačice, da onda obavezno kliknete na izračun EKSa.
Oko navedenog ćemo isto poslati upit kolegama u Sloveniju da bi se trenutni EKS isto trebao osvježiti.

