<#include "/functions.ftl">
<#include "/accessor/enum.ftl">
<#include "/accessor/key.ftl">
<#include "/accessor/standard.ftl">
<#include "/accessor/one_to_one.ftl">
<#include "/accessor/one_to_many.ftl">
<#include "/accessor/many_to_one.ftl">
<#include "/accessor/many_to_many.ftl">
package ${modelPackage};

<#list entity.attributes as attribute>
<#if attribute.type == "ENUM">
<#if attribute.enumClass?has_content>
<#assign imports += { attribute.enumClass : true }>
<#else>
<#assign imports += { modelPackage +"." + entity.name?cap_first + attribute.name?cap_first + "Type" : true }>
</#if>
<#elseif attribute.type.javaType?last_index_of(".") gt 0>
<#assign imports += { attribute.type.javaType : true }>
</#if>
</#list>
<#assign imports +=  { 
  "java.util.List": true,
  "java.util.Objects" : true,
  "java.util.Set" : true 
}>
<#if entity.key.type.value == "uuid">
<#assign imports += { "java.util.UUID" : true }>
</#if>
<#list referencedEntitiesMap[entity.name] as referencedEntity>
<#assign imports += { modelPackage + "." + referencedEntity.name?cap_first : true }>
</#list>
<#if entity.parent??>
<#assign imports += { modelPackage + "." + entity.parent?cap_first : true }>
</#if>
<#assign imports += { modelBasePackage + ".Base" + entity.name?cap_first : true }>
<@import imports/>

<#assign genericParams = []>
<#list entity.relateds as related>
  <#assign genericParams += [related.entityName?upper_case]>
</#list>
<#assign genericDeclaration = "">
<#if genericParams?size gt 0>
  <#assign genericDeclaration = "<" + genericParams?join(", ") + ">">
</#if>
<#if entity.parent??>
public interface ${entity.name?cap_first}${genericDeclaration} extends Base${entity.parent.name?cap_first}${genericDeclaration}, Base${entity.name?cap_first}${genericDeclaration} 
<#else>
public interface ${entity.name?cap_first}${genericDeclaration} extends Base${entity.name?cap_first}${genericDeclaration}
</#if>
{ 
}
