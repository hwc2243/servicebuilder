<#macro standard_attribute entity attribute visibility="protected">
  ${visibility} ${className(attribute.type.javaType)} ${attribute.name} = null;
</#macro>