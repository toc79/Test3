select * 
from dbo.gl_razmej r
inner join dbo.gl_raz_plan rp on r.id_gl_razmej = rp.id_gl_razmej
where r.id_gl_razmej = 94

/*
<gl_raz_plan>
<datum>2021-12-01T00:00:00.000</datum>
<evident>*</evident>
<id_gl_raz_plan>62795</id_gl_raz_plan>
<id_gl_razmej>3069</id_gl_razmej>
<id_strm>0905</id_strm>
<zap_obr>1</zap_obr>
<znesek>10</znesek>
</gl_raz_plan><gl_raz_plan>
*/
-- ltrim(rtrim(rp.evident)) bude <evident />
select cast((select rp.datum, rp.evident as evident, rp.id_gl_raz_plan, rp.id_gl_razmej, rp.id_strm, rp.zap_obr, rp.znesek
    from dbo.gl_raz_plan rp
    where rp.id_gl_razmej = r.id_gl_razmej
    for xml path ('gl_raz_plan')) as xml) as xml_gl_raz_plan
    , r.* 
from dbo.gl_razmej r
where r.id_gl_razmej = 94

select '<?xml version=''1.0'' encoding=''utf-8'' ?>'
    +'<delimitations_crud_request xmlns=''urn:gmi:nova:gl:sync''>'
    +'<id_gl_razmej>'+cast(r.id_gl_razmej as varchar(10))+'</id_gl_razmej>'
    +'<konto>'+ltrim(rtrim(r.konto))+'</konto>'
    +'<raz_pkonto>'+ltrim(rtrim(r.raz_pkonto))+'</raz_pkonto>'
    --IF !GF_NULLOREMPTY(gl_razmej.id_cont)
    +case when r.id_cont is not null then '<id_cont>'+CAST(r.id_cont as varchar(10))+'</id_cont>' else '' end
    +'<ddv_id>'+ltrim(rtrim(r.ddv_id))+'</ddv_id>'
    +'<id_strm>'+ltrim(rtrim(r.id_strm))+'</id_strm>'
    +'<znesek>'+cast(r.znesek as varchar(30))+'</znesek>'
    +'<znesek_se>'+cast(r.znesek_se as varchar(30))+'</znesek_se>'
    +'<opis_dok>'+rtrim(replace(replace(replace(r.opis_dok, '&', '&amp;'), '<', '&lt;'), '>', '&gt;'))+'</opis_dok>'
    +'<raz_datum>'+convert(varchar(30), r.raz_datum, 126)+'.000</raz_datum>'
    +'<raz_st_obr>'+cast(r.raz_st_obr as varchar(10))+'</raz_st_obr>'
    +'<raz_obdobj>'+ltrim(rtrim(r.raz_obdobj))+'</raz_obdobj>'
    +'<raz_tip>'+cast(r.raz_tip as varchar(10))+'</raz_tip>'
    +'<pas_akt>'+cast(r.pas_akt as varchar(10))+'</pas_akt>'
    +'<kljuc>'+ltrim(rtrim(r.kljuc))+'</kljuc>'
    --IF !GF_NULLOREMPTY(gl_razmej.dat_aktiv)
    +case when r.dat_aktiv is not null then '<dat_aktiv>'+convert(varchar(30), r.dat_aktiv, 126)+'.000</dat_aktiv>' else '' end
    --IF !GF_NULLOREMPTY(gl_razmej.id_kupca)
    +case when r.id_kupca is not null then '<id_kupca>'+r.id_kupca+'</id_kupca>' else '' end
    +'<st_dok>'+ltrim(rtrim(st_dok))+'</st_dok>'
    +'<veza_l4>'+case when r.veza_l4 = 1 then 'true' else 'false' end +'</veza_l4>'
    +'<veza_ni_ok>'+case when r.veza_ni_ok = 1 then 'true' else 'false' end +'</veza_ni_ok>'
    +'<obrokov_se>'+cast(r.obrokov_se as varchar(10))+'</obrokov_se>'
    --IF !GF_NULLOREMPTY(gl_razmej.id_source)
    +case when r.id_source is not null then '<id_source>'+cast(r.id_source as varchar(10))+'</id_source>' else '' end
    +'<sys_ts></sys_ts>'
    +'<vrsta_dok>'+ltrim(rtrim(r.vrsta_dok))+'</vrsta_dok>'
    +'<interna_veza>'+ltrim(rtrim(r.interna_veza))+'</interna_veza>'
    --IF !GF_NULLOREMPTY(gl_razmej.id_gl_sifkljuc)
    +case when r.id_gl_sifkljuc is not null then '<id_gl_sifkljuc>'+cast(r.id_gl_sifkljuc as varchar(10))+'</id_gl_sifkljuc>' else '' end
    --IF !GF_NULLOREMPTY(gl_razmej.id_project)
    +case when r.id_project is not null then '<id_project>'+cast(r.id_project as varchar(10))+'</id_project>' else '' end
    --'<gl_raz_plan>'
    +replace(cast(
    cast((select rp.datum, rp.evident as evident, rp.id_gl_raz_plan, rp.id_gl_razmej, rp.id_strm, rp.zap_obr, rp.znesek
            from dbo.gl_raz_plan rp
            where rp.id_gl_razmej = r.id_gl_razmej
            for xml path ('gl_raz_plan')) as xml) as varchar(max)), 
        '<evident>&#x20;</evident>', '<evident></evident>') --as xml_gl_raz_plan
    
    --lcXML = lcXML + GF_CreateNode("crud_mode", "update", "C", 1) + gcE
    +'<crud_mode>update</crud_mode>'
    +'</delimitations_crud_request>'
    as xml
    
    , r.* 
    , cast(0 as bit) as via_queue
	, 0 as delay --300
	, cast(0 as bit) as via_esb
	, 'nova.fa' as esb_target
from dbo.gl_razmej r
where r.id_gl_razmej = 94
and id_gl_sifkljuc is null --or id_gl_sifkljuc = '' polje je int -- razgranièenje bez kljuèa za raspodijelu po mjestu troška
