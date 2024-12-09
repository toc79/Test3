customer_peergroup_mark_calc = "0";
			
			if (customer_peergroup_mark == "0"){
				customer_risk_mark = customer_sif_dej_mark;
			}else if (customer_peergroup_mark == "1" && customer_sif_dej_mark == "1L"){
				customer_risk_mark = "1L";
			}else if ((customer_peergroup_mark == "3" && customer_sif_dej_mark == "3H") || (customer_peergroup_mark == "3H" && customer_sif_dej_mark == "3") || (customer_peergroup_mark == "3H" && customer_sif_dej_mark == "3H")){
				customer_risk_mark = "3H";
			}else{
				if (customer_peergroup_mark == "3H")
					customer_peergroup_mark_calc = "3";
					
				if (customer_sif_dej_mark == "1L")
					customer_sif_dej_mark_calc = "1";
				
				if (customer_sif_dej_mark == "3H")
					customer_sif_dej_mark_calc = "3";
					
				customer_risk_mark = Math.round((customer_sif_dej_mark_calc + customer_peergroup_mark_calc) / 2);
				
				
				
				<evaluation evaluator="sql">
		<statement><![CDATA[
			select "1" as customer_risk_mark
			]]></statement>
	  </evaluation>
--staro

			Select ${customer_sif_dej_mark} as customer_risk_mark

--SQL
declare @customer_peergroup_mark varchar(2) = ${customer_peergroup_mark}
declare @customer_sif_dej_mark varchar(2) = ${customer_sif_dej_mark}
declare @customer_risk_mark varchar(2)

if @customer_peergroup_mark = '3H' or @customer_sif_dej_mark = '3H'
	set @customer_risk_mark = '3H'
else 
begin 
	if @customer_peergroup_mark = '1L' or @customer_sif_dej_mark = '1L'
		set @customer_risk_mark = '1L'
	else 
		set @customer_risk_mark = cast(round((cast(@customer_peergroup_mark as decimal(18,2)) + cast(@customer_sif_dej_mark as decimal(18,2))) / 2, 0) as int)
end

select @customer_risk_mark as customer_risk_mark 

--OCJENA DRŽAVE ??
 <evaluate evaluator="Sql">
      <statement><![CDATA[
          Select case when ${global_mark_xc} = 'Da' and ${global_pep} = 1 Then '3H'
                when ${global_mark_xc} = 'Da' and ${global_customer_is_fi} = 0 Then '3'
                when ${global_mark_xc} = 'Da' and ${global_customer_is_fi} = 1 Then '3H'
                when charindex(${customer_category}, ${global_xa_customers}) != 0 and ${global_customer_is_fi} = 0 Then '1'
                when charindex(${customer_category}, ${global_xa_customers}) != 0 and ${global_customer_is_fi} = 1 Then '1L'
                Else '1' 
                End as calculated_mark
        ]]></statement>
    </evaluate>