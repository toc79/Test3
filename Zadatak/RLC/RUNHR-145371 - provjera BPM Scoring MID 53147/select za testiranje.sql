select * from dbo.osr_izvjestaji where id_kupca = '043687'
select * from dbo.osr_izvjestaji_ki where osoba like '%86675987743%' and id_izvjestaja = 676 order by id

declare @result varchar(10), @id_izvjestaja int, @max_dni int, @is_osr_done_ok bit, @id_izvjestaja_osr int, @id_kupca varchar(10), @oib varchar(20), @limit_low decimal(18,2), @limit_high decimal(18,2)
set @result = '0'
set @is_osr_done_ok = cast(case when ISNULL('true', '') = 'true' then 1 else 0 end as bit)--cast(case when ISNULL(${is_osr_done_ok}, '') = 'true' then 1 else 0 end as bit)
set @id_izvjestaja_osr = 676--CAST(ISNULL(${id_izvjestaja_osr}, '-1') as int)--CAST(ISNULL(${id_izvjestaja_osr}, '-1') as int)
set @id_kupca = '043687'--${id_kupca}
set @oib = '86675987743'--${oib}
set @limit_low = (Select cast(val_num as decimal(18,2)) as val From dbo.general_register where id_register = 'BPM_SCORING_OSR_LIMIT' and id_key = 'LIMIT_NIZI')
set @limit_high = (Select cast(val_num as decimal(18,2)) as val From dbo.general_register where id_register = 'BPM_SCORING_OSR_LIMIT' and id_key = 'LIMIT_VISI')

if @is_osr_done_ok = 1 and @id_izvjestaja_osr > 0
begin
  
    if exists(Select * From dbo.osr_izvjestaji Where id_kupca = @id_kupca and oib = @oib and id = @id_izvjestaja_osr and ucitano > 0 and obavijesti = 0 and broj_gresaka = 0)
    begin 
        set @id_izvjestaja = (Select max(id) as id From dbo.osr_izvjestaji Where id_kupca = @id_kupca and oib = @oib and id = @id_izvjestaja_osr)

        Select a.id, cast(b.dana_kasnjenja as int) as dana_kasnjenja, b.valuta_odr, cast(b.iznos_odr as decimal(18,2)) as iznos_odr_o, cast(b.datum_stanja as datetime) as datum_stanja,
        dbo.gfn_xchange(dbo.gfn_GetNewTec('000'), cast(b.iznos_odr as decimal(18,2)), rtrim(g.val_char), cast(b.datum_stanja as datetime)) as iznos_odr,
        DATEDIFF(m, cast(b.datum_stanja as datetime), GETDATE()) as month_diff
        into #analitika
        From dbo.osr_izvjestaji_ki a
        cross apply (
    
                Select rtrim(t.c.value('@KD','varchar(100)')) as dana_kasnjenja,
                rtrim(t.c.value('@VDD','varchar(100)')) as valuta_odr,
                rtrim(t.c.value('@IDD','varchar(100)')) as iznos_odr,
                rtrim(t.c.value('@DS','varchar(100)')) as datum_stanja
                From (
                Select CAST(REPLACE(REPLACE(REPLACE(a.povijest_obveze, 'xmlns:xsd="http://www.w3.org/2001/XMLSchema"',''),'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"',''), '<?xml version="1.0" encoding="utf-16"?>', '') as xml) as xml_data
                )x
                cross apply x.xml_data.nodes('ObvezaPovijest/P') t(c)
        ) b
    left join dbo.general_register g on g.id_register = 'BPM_SCORING_DEFAULT_EXCHANGE' and rtrim(b.valuta_odr) = rtrim(g.id_key)
        Where a.id_izvjestaja = @id_izvjestaja and DATEDIFF(m, cast(b.datum_stanja as datetime), GETDATE()) <= 12
select * from #analitika        
Select * From #analitika Where dana_kasnjenja > 0 and iznos_odr > 0
        if exists(Select * From #analitika Where dana_kasnjenja > 0 and iznos_odr > 0)
        begin
                set @max_dni = (Select max(dana_kasnjenja) From #analitika Where iznos_odr > 0)

                if @max_dni >= 120
                begin
                set @result = 'N'
                end
                else
                begin
                    if @max_dni <= 30
                    begin
                        set @result = 'Y'
                    end
                    else if @max_dni between 31 and 59
                    begin
                      set @result = (Select case when (iznos_odr > @limit_high and broj = 1) or iznos_odr <= @limit_high then 'Y' 
                                                 when iznos_odr > @limit_high and broj > 1 then 'N'
                                                 else 'Y' end
                                        From (
                                            Select sum(iznos_odr) as iznos_odr, count(*) as broj 
                                            From #analitika 
                                            where dana_kasnjenja between 31 and 59 and iznos_odr > 0
                                        ) a
                            )
                    end
                    else
                    begin
                        set @result = (Select case when iznos_odr <= @limit_low then 'Y' 
                                        when iznos_odr > @limit_low then 'N'
                                        else 'Y' end
                                        From (
                                            Select sum(iznos_odr) as iznos_odr, count(*) as broj 
                                            From #analitika 
                                            where dana_kasnjenja between 60 and 119 and iznos_odr > 0
                                        ) a
                            )
                    end
                end
        end

        --Select * From #analitika
        drop table #analitika
    end

    if exists(Select * From dbo.osr_izvjestaji where id_kupca = @id_kupca and oib = @oib and id = @id_izvjestaja_osr and broj_gresaka > 0)
    begin
        Select '-1' as id_izvjestaja_osr, 'false' as is_osr_done_ok
    end
end
else
begin
    Select '-1' as id_izvjestaja_osr, 'false' as is_osr_done_ok
end
      
Select @result as hrok_flag       