<#include "/functions.ftl">
<#include "/accessor/enum.ftl">
<#include "/accessor/key.ftl">
<#include "/accessor/standard.ftl">
<#include "/attribute/key.ftl">
<#include "/java/dto/builder.ftl">
<#include "/java/dto/equals_hashcode.ftl">
<#include "/java/dto/enum.ftl">
<#include "/java/dto/key.ftl">
<#include "/java/dto/standard.ftl">
<#include "/java/dto/related.ftl">
package ${dtoBasePackage};

<#list entity.attributes as attribute>
<#if attribute.type == "ENUM">
<#if attribute.enumClass?has_content>
<#assign imports += { attribute.enumClass : true }>
<#else>
<#assign imports += { modelPackage + "." + entity.name?cap_first + attribute.name?cap_first : true }>
</#if>
<#elseif attribute.type.javaType?last_index_of(".") gt 0>
<#assign imports += { attribute.type.javaType : true }>
</#if>
</#list>
<#if entity.key.type.value == "uuid">
<#assign imports += { "java.util.UUID" : true }>
</#if>
<#list referencedEntitiesMap[entity.name] as referencedEntity>
<#assign imports += { dtoPackage + "." + referencedEntity.name?cap_first + "DTO": true }>
</#list>
<#if entity.parent?has_content>
<#assign imports += { dtoBasePackage + ".Base" + entity.parent?cap_first + "DTO" : true }>
</#if>
<#assign imports +=  {
  "java.io.Serializable": true,
  "java.util.List": true,
  "java.util.Set": true,
  "java.util.Objects" : true,
  "com.fasterxml.jackson.annotation.JsonFormat": true,
  dtoPackage + "." + entity.name?cap_first + "DTO": true,
  modelBasePackage + ".Base" + entity.name?cap_first: true
 }>
 <#if entity.multitenant>
 <#assign imports += { modelBasePackage + ".Multitenant" : true }>
 </#if>
<#list inheritedAndOwnDtoGenericTypes(entity) as genericType>
  <#assign imports += { dtoPackage + "." + genericType : true }>
</#list>

<@import imports/>

<#assign modelGenericDeclaration = asGenericDeclaration(inheritedAndOwnDtoGenericTypes(entity))>
<#assign modelGenericDeclaration = asGenericDeclaration(inheritedAndOwnDtoGenericTypes(entity))>
public abstract class Base${entity.name?cap_first}DTO
<#if entity.parent?? && entity.parent?has_content>
extends Base${entity.parent?cap_first}DTO
</#if>
implements Base${entity.name?cap_first}${modelGenericDeclaration}, <#if entity.multitenant>Multitenant, </#if> Serializable
{
<@key_attribute entity entity.key/>

<#list entity.attributes as attribute>
<#if attribute.type == "ENUM">
<@enum_attribute entity=entity attribute=attribute/>
  
<#else>
<#assign attributeType = attributeTypeClass(attribute)>
<#if attribute.type.value == "datetime">
@JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss.SSS")
</#if>
<@standard_attribute entity=entity attribute=attribute/>
  
</#if>
</#list>
<#list entity.relateds as related>
<@related_attribute related=related/>
</#list>

  protected Base${entity.name?cap_first}DTO () {
  }
  
<@builder_constructor entity=entity/>

<@key_accessors_impl entity=entity key=entity.key write_get_key=false />

<#list entity.attributes as attribute>
<#if attribute.type == "ENUM">
<@enum_accessors_impl entity=entity attribute=attribute/>

<#else>
<@standard_accessors_impl entity=entity attribute=attribute/>

</#if>
</#list>
<#list entity.relateds as related>
<@related_accessor related=related/>
</#list>

<@equals_hashcode entity=entity key=entity.key/>

<@builder_class entity=entity/>
}