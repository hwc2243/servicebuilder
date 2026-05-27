<#macro key_attribute entity key visibility="protected">
  ${visibility} ${className(key.type.javaType)} ${key.name} = null;
</#macro>