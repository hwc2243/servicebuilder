<#function className fullyQualifiedName>
  <#if fullyQualifiedName?last_index_of(".") gt 0>
    <#return fullyQualifiedName?substring(fullyQualifiedName?last_index_of(".") + 1)>
  <#else>
    <#return fullyQualifiedName>
  </#if>
</#function>