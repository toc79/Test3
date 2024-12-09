
/*username, event_name,
parameter_name, parameter_value (id_opom)

Da li se može desiti, da prije samog ispisa koji čeka u queue, id_opom završi u ARH_ZA_OPOM, jer netko pusti ponovno pripremu opomena?
Ako se to desi, u queue će ostati zapisi u grešci ??!! pa ćemo onda vidjeti da se doradi ispis UNION na ARH_ZA_OPOM
=> neće doći do greške, već će se ispisati prazna stranica


Podesio sam jednostavniji 

if @sql_code_after is null
begin
    select 
        @rep_name as report, 
        ltrim(rtrim(@id)) as id,
        @delay as delay
    --where @rep_name <> 'IGNORE'
end
else
begin
    select 
        @rep_name as report, 
        rtrim(ltrim(@id)) as id,
        @sql_code_after as sql_code_after,
        @delay as delay
    --where @rep_name <> 'IGNORE'
end


Podesiti za 
EdocTypeId EdocTypeName Title
0041 Invoice Račun za opomenu
0042 Reminder Opomena bez troška
0043 guarremind Obavijest jamcu o opomeni
0044 guarremind Obavijest dodatnim jamcima o opomeni
0045 general Obavijest o neplaćenim potraživanjima => ovaj ispis je vezan na točku 5.
te ispis "TEKST OPOMENE TP" koji će se podesiti u stimulsoftu te napraviti edoc podešavanja. => ako ne ide u eventu, onda XDOC


05.09.2024 14:42:47:397	127	DBHelper	Db	[g_tomislav,192.168.23.206                ]	[6dbee70d-0415-40a2-94d2-72a2a2919a46,LE]	Getting dataset with adapter: --Parameters {X}:  -- 0 - 'g_tomislav'  -- 1 - 'reminderwithnocostafterissue'  -- 2 - 'IDs'  -- 3 - '62844'  -- 4 - NULL    -- 5 - NULL  -- 6 - NULL    -- 05.09.2024 g_tomislav MID 49592  declare @id_opom int  set @id_opom = NULL    declare @rep_name varchar(100), @id varchar(100), @sql_code_after varchar(1000), @delay int  set @rep_name = 'OPOMIN_SSOFT_ESL'   set @id = @id_opom  set @sql_code_after = 'update dbo.za_opom set izpisan = 1 where id_opom = ' +rtrim(@id)   set @delay = 30    select @rep_name as report,           rtrim(ltrim(@id)) as id,          @sql_code_after as sql_code_after,          @delay as delay

*/

-- 05.09.2024 g_tomislav MID 49592
declare @id_opom int
set @id_opom = {3} 

declare @rep_name varchar(100), @id varchar(100), @sql_code_after varchar(1000), @delay int
set @rep_name = 'OPOMIN' 
set @id = @id_opom
set @sql_code_after = 'update dbo.za_opom set izpisan = 1 where id_opom = ' +rtrim(@id) 
set @delay = 30 --seconds

select @rep_name as report, 
        rtrim(ltrim(@id)) as id,
        @sql_code_after as sql_code_after,
        @delay as delay
