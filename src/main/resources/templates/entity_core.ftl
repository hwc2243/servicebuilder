<#assign baseEntityName = entity.name?cap_first>
<#assign parentGenericDeclaration = "">
<#if entity.parent?has_content>
  <#assign parentEntity = entityMap[entity.parent]>
  <#assign parentGenericParams = []>
  <#list parentEntity.relateds as related>
    <#assign parentGenericParams += [related.entityName?cap_first]>
  </#list>
  <#if parentGenericParams?size gt 0>
    <#assign parentGenericDeclaration = "<" + parentGenericParams?join(", ") + ">">
  </#if>
</#if>