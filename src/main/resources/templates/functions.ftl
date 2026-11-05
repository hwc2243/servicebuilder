<#function className fullyQualifiedName>
  <#if fullyQualifiedName?last_index_of(".") gt 0>
    <#return fullyQualifiedName?substring(fullyQualifiedName?last_index_of(".") + 1)>
  <#else>
    <#return fullyQualifiedName>
  </#if>
</#function>

<#function isTenantKeyOnly entity related>
  <#return related.apiIdReference && entity.multitenant && tenantDiscriminator??
      && related.name + "Id" == tenantDiscriminator.name>
</#function>

<#function isTenantApiReference entity related>
  <#return related.apiIdReference && entity.multitenant && tenantDiscriminator??
      && related.name + "Id" == tenantDiscriminator.name>
</#function>

<#function isLegacyTenantKeyOnly entity related>
  <#return related.keyOnly && (!related.apiReference?? || related.apiReference?lower_case != "id")
      && entity.multitenant && tenantDiscriminator??
      && related.name + "Id" == tenantDiscriminator.name>
</#function>

<#function isExplicitApiIdReference related>
  <#return related.apiReference?? && related.apiReference?lower_case == "id">
</#function>

<#function isGeneratedApiIdReference related>
  <#return related.apiIdReference && (!related.keyOnly || isExplicitApiIdReference(related))>
</#function>

<#function isApiObjectReference related>
  <#return related.apiObjectReference>
</#function>

<#function isApiNoneReference related>
  <#return related.apiNoneReference>
</#function>

<#function isCollectionRelated related>
  <#return related.relationshipType.name() == "ONE_TO_MANY"
      || related.relationshipType.name() == "MANY_TO_MANY">
</#function>

<#function isEffectivelyMultitenant entity>
  <#if entity.multitenant>
    <#return true>
  </#if>
  <#if entity.parent?? && entity.parent?has_content>
    <#return isEffectivelyMultitenant(entityMap[entity.parent])>
  </#if>
  <#return false>
</#function>

<#function hasRelationshipFinder entity related>
  <#list inheritedAndOwnFinders(entity) as finder>
    <#list finder.finderAttributes as finderAttribute>
      <#if finderAttribute.name == related.name>
        <#return true>
      </#if>
    </#list>
  </#list>
  <#return false>
</#function>

<#function isTenantDiscriminatorAttribute entity attribute>
  <#if entity.multitenant && tenantDiscriminator?? && attribute.name == tenantDiscriminator.name>
    <#list entity.relateds as related>
      <#if isTenantDiscriminatorRelation(entity, related)>
        <#return true>
      </#if>
    </#list>
  </#if>
  <#return false>
</#function>

<#function isTenantDiscriminatorRelation entity related>
  <#return entity.multitenant && tenantDiscriminator??
      && related.name + "Id" == tenantDiscriminator.name>
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
    <#if !related.keyOnly>
      <#assign names += [related.entityName?cap_first + suffix]>
    </#if>
  </#list>
  <#return names>
</#function>

<#function relatedDtoGenericNames targetEntity>
  <#assign names = []>
  <#list targetEntity.relateds as related>
    <#if related.apiObjectReference>
      <#assign names += [related.entityName?cap_first + "DTO"]>
    </#if>
  </#list>
  <#return names>
</#function>

<#function relatedGenericPlaceholders targetEntity>
  <#assign names = []>
  <#list targetEntity.relateds as related>
    <#if !related.keyOnly>
      <#assign names += [related.entityName?upper_case]>
    </#if>
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
    <#return relatedDtoGenericNames(parentEntity)>
  </#if>
  <#return []>
</#function>

<#function ownDtoGenericTypes targetEntity>
  <#return relatedDtoGenericNames(targetEntity)>
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

<#function inheritedAndOwnAttributes targetEntity>
  <#assign attributes = []>
  <#if targetEntity.parent?? && targetEntity.parent?has_content>
    <#assign parentEntity = entityMap[targetEntity.parent]>
    <#assign attributes += inheritedAndOwnAttributes(parentEntity)>
  </#if>
  <#assign attributes += targetEntity.attributes>
  <#return attributes>
</#function>

<#function inheritedAndOwnFinders targetEntity>
  <#assign finders = []>
  <#if targetEntity.parent?? && targetEntity.parent?has_content>
    <#assign parentEntity = entityMap[targetEntity.parent]>
    <#assign finders += inheritedAndOwnFinders(parentEntity)>
  </#if>
  <#assign finders += targetEntity.finders>
  <#return finders>
</#function>

<#function inheritedAttribute targetEntity name>
  <#list inheritedAndOwnAttributes(targetEntity) as attribute>
    <#if attribute.name == name>
      <#return attribute>
    </#if>
  </#list>
  <#return "">
</#function>

<#function inheritedRelated targetEntity name>
  <#list inheritedAndOwnRelateds(targetEntity) as related>
    <#if related.name == name>
      <#return related>
    </#if>
  </#list>
  <#return "">
</#function>

<#assign imports = {}>
<#macro import imports>
<#list imports?keys?sort as importClass>
import ${importClass};
</#list>
</#macro>
