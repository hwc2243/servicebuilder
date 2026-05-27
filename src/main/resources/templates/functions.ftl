<#function className fullyQualifiedName>
  <#if fullyQualifiedName?last_index_of(".") gt 0>
    <#return fullyQualifiedName?substring(fullyQualifiedName?last_index_of(".") + 1)>
  <#else>
    <#return fullyQualifiedName>
  </#if>
</#function>
<#function attributeTypeClass attribute>
  <#if attribute.type == "ENUM">
    <#if attribute.enumClass?has_content>
      <#return attribute.enumClass>
    <#else>
      <#return "${attribute.name?cap_first}Type"> 
    </#if>
  <#else>
    <#return className(attribute.type.javaType)> 
  </#if>
</#function>
<#assign imports = {}>
<#macro import imports>
<#list imports?keys?sort as importClass>
import ${importClass};
</#list>
</#macro>