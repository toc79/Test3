<?xml version='1.0' encoding='utf-8' ?>
<field_list>
<field grid_searchtype="471524" sort_order="1" field_name="id" header_name="Id" control_type="TextBox" field_width="100" field_format="" field_alignment="3" back_color="255,255,255" fore_color="0,0,0" font_bold="0" field_function="" exists_sql="0" sort_sql="0" />

<field grid_searchtype="471524" sort_order="2" field_name="brojac" header_name="Brojač upita" control_type="TextBox" field_width="100" field_format="" field_alignment="3" back_color="255,255,255" fore_color="0,0,0" font_bold="0" field_function="" exists_sql="0" sort_sql="0" />

<field grid_searchtype="471524" sort_order="3" field_name="id_kupca" header_name="Šifra partnera" control_type="TextBox" field_width="100" field_format="" field_alignment="3" back_color="255,255,255" fore_color="0,0,0" font_bold="0" field_function="" exists_sql="0" sort_sql="0" />

<field grid_searchtype="471524" sort_order="4" field_name="naz_kr_kup" header_name="Naziv partnera" control_type="TextBox" field_width="100" field_format="" field_alignment="3" back_color="255,255,255" fore_color="0,0,0" font_bold="0" field_function="" exists_sql="0" sort_sql="0" />

<field grid_searchtype="471524" sort_order="5" field_name="oib" header_name="Oib" control_type="TextBox" field_width="100" field_format="" field_alignment="3" back_color="255,255,255" fore_color="0,0,0" font_bold="0" field_function="" exists_sql="0" sort_sql="0" />

<field grid_searchtype="471524" sort_order="6" field_name="datum_pripreme" header_name="Datum pripreme" control_type="TextBox" field_width="100" field_format="" field_alignment="3" back_color="255,255,255" fore_color="0,0,0" font_bold="0" field_function="ttod(@Field)" exists_sql="0" sort_sql="0" />

<field grid_searchtype="471524" sort_order="7" field_name="referentni_broj_z" header_name="Referentni broj zahtjev" control_type="TextBox" field_width="100" field_format="" field_alignment="3" back_color="255,255,255" fore_color="0,0,0" font_bold="0" field_function="" exists_sql="0" sort_sql="0" />

<field grid_searchtype="471524" sort_order="8" field_name="referentni_broj_o" header_name="Referentni broj oodgovora" control_type="TextBox" field_width="100" field_format="" field_alignment="3" back_color="255,255,255" fore_color="0,0,0" font_bold="0" field_function="" exists_sql="0" sort_sql="0" />

<field grid_searchtype="471524" sort_order="9" field_name="status_obrade" header_name="Status obrade" control_type="TextBox" field_width="100" field_format="" field_alignment="3" back_color="255,255,255" fore_color="0,0,0" font_bold="0" field_function="" exists_sql="0" sort_sql="0" />

<field grid_searchtype="471524" sort_order="10" field_name="ucitano" header_name="Broj učitanih" control_type="TextBox" field_width="100" field_format="" field_alignment="3" back_color="255,255,255" fore_color="0,0,0" font_bold="0" field_function="" exists_sql="0" sort_sql="0" />

<field grid_searchtype="471524" sort_order="11" field_name="obavijesti" header_name="Broj nepronađenih" control_type="TextBox" field_width="100" field_format="" field_alignment="3" back_color="255,255,255" fore_color="0,0,0" font_bold="0" field_function="" exists_sql="0" sort_sql="0" />

<field grid_searchtype="471524" sort_order="12" field_name="odbijeno_zbog_kz" header_name="Broj odbačenih" control_type="TextBox" field_width="100" field_format="" field_alignment="3" back_color="255,255,255" fore_color="0,0,0" font_bold="0" field_function="" exists_sql="0" sort_sql="0" />

<field grid_searchtype="471524" sort_order="13" field_name="broj_gresaka" header_name="Broj gresaka" control_type="TextBox" field_width="100" field_format="" field_alignment="3" back_color="255,255,255" fore_color="0,0,0" font_bold="0" field_function="" exists_sql="0" sort_sql="0" />
</field_list>

declare @oib bit, @zadnji bit

set @zadnji = {2}
set @oib = {3}

declare @main table (
	[id] [int] NOT NULL PRIMARY KEY,
	[brojac] [int] NOT NULL,
	[id_kupca] [varchar](10) NULL,
	[oib] [varchar](17) NULL,
	[datum_pripreme] [datetime] NULL,
	[referentni_broj_z] [varchar](128) NULL,
	[referentni_broj_o] [varchar](36) NULL,
	[status_obrade] [varchar](36) NULL,
	[ucitano] [int] NULL,
	[obavijesti] [int] NULL,
	[odbijeno_zbog_kz] [int] NULL,
	[broj_gresaka] [int] NULL
)

insert into @main
Select *
From dbo.osr_izvjestaji
where id_kupca = {1}

insert into @main
Select *
From dbo.osr_izvjestaji
Where @oib = 1 and oib in (Select oib From @main group by oib) and id not in (Select id From @main)

if @zadnji = 1
begin
	Select a.*
	into #group_po_partneru
	From @main a
	inner join (
	Select id_kupca, max(datum_pripreme) as datum_pripreme
	From @main
	group by id_kupca
	) b on a.id_kupca = b.id_kupca and a.datum_pripreme = b.datum_pripreme
	
	delete from @main
	
	insert into @main
	Select *
	From #group_po_partneru
	
	drop table #group_po_partneru
end

Select a.*, b.naz_kr_kup
From @main a
inner join {5}.dbo.partner b on a.id_kupca = b.id_kupca

Select [id]
      ,[id_izvjestaja]
      ,[osoba]
      ,[datum_stanja]
      ,[institucija]
      ,[ogranicenje_obrade]
      ,[oznaka_obveze]
      ,[oznaka_okvira]
      ,[oznaka_garancije]
      ,[subvencija]
      ,[sindikat]
      ,[tudja_sredstva]
      ,[zalog_nekretnina]
      ,[instrument_naplate]
      ,[datum_obveze]
      ,[datum_obnove_iznosa]
      ,[datum_isteka_obveze]
      ,[iznos_obveze]
      ,[ugovorna_valuta]
      ,[uloga]
      ,[vrsta_obveze]
      ,[vrsta_otplate]
      ,[iznos_rate]
      ,[iznos_glavnice]
      ,[iznos_kamate]
      ,[iznos_ostatka]
      ,[ucestalost_placanja_g]
      ,[ucestalost_placanja_k]
      ,[status_obveze]
      ,[bud_glavnica]
      ,[bud_kamata]
      ,[neiskoristeni_iznos]
      ,[iskoristeni_iznos]
      ,[prekoraceni_iznos]
      ,[p_zadnja_3m]
      ,[p_zadnja_6m]
      ,[p_zadnja_12m]
      ,[datum_zatvaranja]
      ,[dana_kasnjenja]
      ,[iznos_odr]
      ,[valuta_odr]
      ,[datum_poceka]
      ,[datum_isteka_poceka]
      ,[datum_moratorij]
      ,[datum_isteka_moratorij]
      ,[ukupno_moratorij]
      ,cast([povijest_obveze] as text) as [povijest_obveze]
From dbo.osr_izvjestaji_ki
where id_izvjestaja in (Select id From @main)

Select id, id_izvjestaja, tip_greske, left(opis, 254) as opis, left(referenca, 254) as referenca
From dbo.osr_izvjestaji_greske
where id_izvjestaja in (Select id From @main)