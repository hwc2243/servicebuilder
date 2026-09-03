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
<#assign imports += { modelPackage +"." + entity.name?cap_first + attribute.name?cap_first : true }>
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
<#if entity.parent?has_content>
<#assign imports += { modelPackage + "." + entity.parent?cap_first : true }>
</#if>
<#assign imports += { modelBasePackage + ".Base" + entity.name?cap_first : true }>
<#list inheritedAndOwnModelGenericTypes(entity) as genericType>
  <#assign imports += { modelPackage + "." + genericType : true }>
</#list>
<@import imports/>

<#assign genericDeclaration = asGenericDeclaration(inheritedAndOwnGenericPlaceholders(entity))>
<#assign parentGenericDeclaration = asGenericDeclaration(parentGenericPlaceholders(entity))>
<#if entity.parent?has_content>
public interface ${entity.name?cap_first}${genericDeclaration} extends ${entity.parent?cap_first}${parentGenericDeclaration}, Base${entity.name?cap_first}${genericDeclaration}
<#else>
public interface ${entity.name?cap_first}${genericDeclaration} extends Base${entity.name?cap_first}${genericDeclaration}
</#if>
{ 
}
