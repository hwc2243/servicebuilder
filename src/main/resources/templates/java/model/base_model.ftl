<#include "/functions.ftl">
<#include "/accessor/enum.ftl">
<#include "/accessor/key.ftl">
<#include "/accessor/standard.ftl">
<#include "/accessor/one_to_one.ftl">
<#include "/accessor/one_to_many.ftl">
<#include "/accessor/many_to_one.ftl">
<#include "/accessor/many_to_many.ftl">
package ${modelBasePackage};

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
  "java.io.Serializable" : true,
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
<@import imports/>

<#assign genericParams = []>
<#list entity.relateds as related>
  <#assign genericParams += [related.entityName?upper_case]>
</#list>

<#assign genericDeclaration = "">
<#if genericParams?size gt 0>
  <#assign genericDeclaration = "<" + genericParams?join(", ") + ">">
</#if>

public interface Base${entity.name?cap_first}${genericDeclaration}
<#if entity.parent??>
 extends Base${entity.parent.name?cap_first}, <#if entity.multitenant>Multitenant, </#if>Serializable
<#else>
 extends <#if entity.multitenant>Multitenant, </#if>Serializable
</#if>
{ 
<@key_accessors_api entity=entity key=entity.key write_get_key=false/>

<#list entity.attributes as attribute>
<#if attribute.type == "ENUM">
<@enum_accessors_api entity=entity attribute=attribute/>

<#else>
<@standard_accessors_api entity=entity attribute=attribute/>

</#if>
</#list>
<#list entity.relateds as related>
<#if related.relationshipType.name() == "ONE_TO_ONE">
<@one_to_one_accessors_api entity=entity related=related type=related.entityName?upper_case/>

<#elseif related.relationshipType.name() == "ONE_TO_MANY">
<@one_to_many_accessors_api entity=entity related=related type=related.entityName?upper_case/>

<#elseif related.relationshipType.name() == "MANY_TO_ONE">
<@many_to_one_accessors_api entity=entity related=related type=related.entityName?upper_case/>

<#elseif related.relationshipType.name() == "MANY_TO_MANY">
<@many_to_many_accessors_api entity=entity related=related type=related.entityName?upper_case/>

<#else>
</#if>
</#list>
}
