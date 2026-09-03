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
      <#return attribute.name?cap_first>
    </#if>
  <#else>
    <#return className(attribute.type.javaType)>
  </#if>
</#function>

<#function relatedGenericNames targetEntity suffix="">
  <#assign names = []>
  <#list targetEntity.relateds as related>
    <#assign names += [related.entityName?cap_first + suffix]>
  </#list>
  <#return names>
</#function>

<#function relatedGenericPlaceholders targetEntity>
  <#assign names = []>
  <#list targetEntity.relateds as related>
    <#assign names += [related.entityName?upper_case]>
  </#list>
  <#return names>
</#function>

<#function asGenericDeclaration names>
  <#if names?size gt 0>
    <#return "<" + names?join(", ") + ">">
  </#if>
  <#return "">
</#function>

<#function parentEntityOf targetEntity>
  <#if targetEntity.parent?? && targetEntity.parent?has_content>
    <#return entityMap[targetEntity.parent]>
  </#if>
  <#return "">
</#function>

<#function parentGenericPlaceholders targetEntity>
  <#if targetEntity.parent?? && targetEntity.parent?has_content>
    <#assign parentEntity = entityMap[targetEntity.parent]>
    <#return relatedGenericPlaceholders(parentEntity)>
  </#if>
  <#return []>
</#function>

<#function ownGenericPlaceholders targetEntity>
  <#return relatedGenericPlaceholders(targetEntity)>
</#function>

<#function inheritedAndOwnGenericPlaceholders targetEntity>
  <#return parentGenericPlaceholders(targetEntity) + ownGenericPlaceholders(targetEntity)>
</#function>

<#function parentModelGenericTypes targetEntity>
  <#if targetEntity.parent?? && targetEntity.parent?has_content>
    <#assign parentEntity = entityMap[targetEntity.parent]>
    <#return relatedGenericNames(parentEntity)>
  </#if>
  <#return []>
</#function>

<#function ownModelGenericTypes targetEntity>
  <#return relatedGenericNames(targetEntity)>
</#function>

<#function inheritedAndOwnModelGenericTypes targetEntity>
  <#return parentModelGenericTypes(targetEntity) + ownModelGenericTypes(targetEntity)>
</#function>

<#function parentEntityGenericTypes targetEntity>
  <#if targetEntity.parent?? && targetEntity.parent?has_content>
    <#assign parentEntity = entityMap[targetEntity.parent]>
    <#return relatedGenericNames(parentEntity, "Entity")>
  </#if>
  <#return []>
</#function>

<#function ownEntityGenericTypes targetEntity>
  <#return relatedGenericNames(targetEntity, "Entity")>
</#function>

<#function inheritedAndOwnEntityGenericTypes targetEntity>
  <#return parentEntityGenericTypes(targetEntity) + ownEntityGenericTypes(targetEntity)>
</#function>

<#function parentDtoGenericTypes targetEntity>
  <#if targetEntity.parent?? && targetEntity.parent?has_content>
    <#assign parentEntity = entityMap[targetEntity.parent]>
    <#return relatedGenericNames(parentEntity, "DTO")>
  </#if>
  <#return []>
</#function>

<#function ownDtoGenericTypes targetEntity>
  <#return relatedGenericNames(targetEntity, "DTO")>
</#function>

<#function inheritedAndOwnDtoGenericTypes targetEntity>
  <#return parentDtoGenericTypes(targetEntity) + ownDtoGenericTypes(targetEntity)>
</#function>

<#function inheritedAndOwnRelateds targetEntity>
  <#assign relateds = []>
  <#if targetEntity.parent?? && targetEntity.parent?has_content>
    <#assign parentEntity = entityMap[targetEntity.parent]>
    <#assign relateds += parentEntity.relateds>
  </#if>
  <#assign relateds += targetEntity.relateds>
  <#return relateds>
</#function>

<#assign imports = {}>
<#macro import imports>
<#list imports?keys?sort as importClass>
import ${importClass};
</#list>
</#macro>