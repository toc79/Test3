declare @id_rtip char(5), @datum datetime, @vnesel char(10)

declare tmp cursor fast_forward
for
Select id_rtip, datum, vnesel
From dbo.rvred
where datum >= '20160301'
and id_rtip not in ('EUR3I','EUR6I','EUR1I')

open tmp

fetch next from tmp into @id_rtip, @datum,  @vnesel
while @@fetch_status = 0
begin 
	exec dbo.gsp_RtipDerivedIndex  @id_rtip, @datum, 'I', @vnesel
	fetch next from tmp into @id_rtip, @datum, @vnesel
end

close tmp
deallocate tmp



