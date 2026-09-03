<#macro enum_attribute entity attribute visibility="protected">
<#if attribute.enumClass?has_content>
  ${visibility} ${attribute.enumClass} ${attribute.name} = null;
<#else>
  ${visibility} ${entity.name?cap_first}${attribute.name?cap_first} ${attribute.name} = null;
</#if>
</#macro>