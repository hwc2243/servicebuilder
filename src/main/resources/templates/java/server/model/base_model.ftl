<#include "/functions.ftl">
<#include "/entity_core.ftl">
<#include "/java/server/accessor/enum.ftl">
<#include "/java/server/accessor/key.ftl">
<#include "/java/server/accessor/standard.ftl">
<#include "/java/server/accessor/one_to_one.ftl">
<#include "/java/server/accessor/one_to_many.ftl">
<#include "/java/server/accessor/many_to_one.ftl">
<#include "/java/server/accessor/many_to_many.ftl">
package ${modelBasePackage};

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
  "java.io.Serializable" : true,
  "java.util.List": true,
  "java.util.Objects" : true,
  "java.util.Set" : true 
}>
<#if entity.key.type.value == "uuid">
  <#assign imports += { "java.util.UUID" : true }>
</#if>
<#list entity.relateds as related>
  <#if related.keyOnly && entityMap[related.entityName].key.type.value == "uuid">
    <#assign imports += { "java.util.UUID" : true }>
  </#if>
</#list>
<#list referencedEntitiesMap[entity.name] as referencedEntity>
  <#assign imports += { modelPackage + "." + referencedEntity.name?cap_first : true }>
</#list>
<#list inheritedAndOwnModelGenericTypes(entity) as genericType>
  <#assign imports += { modelPackage + "." + genericType : true }>
</#list>
<@import imports/>

<#assign genericDeclaration = asGenericDeclaration(inheritedAndOwnGenericPlaceholders(entity))>
<#assign parentGenericDeclaration = asGenericDeclaration(parentGenericPlaceholders(entity))>
public interface Base${entity.name?cap_first}${genericDeclaration}
<#if entity.parent?? && entity.parent?has_content>
 extends Base${entity.parent?cap_first}${parentGenericDeclaration}, <#if entity.multitenant>Multitenant, </#if>Serializable
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
<#if isTenantKeyOnly(entity, related)>
<#-- The tenant discriminator accessors already represent this relationship. -->
<#elseif related.keyOnly>
<#assign relatedEntity = entityMap[related.entityName]>
  public ${className(relatedEntity.key.type.javaType)} get${related.name?cap_first}Id ();
  public void set${related.name?cap_first}Id (${className(relatedEntity.key.type.javaType)} ${related.name}Id);

<#elseif related.relationshipType.name() == "ONE_TO_ONE">
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
