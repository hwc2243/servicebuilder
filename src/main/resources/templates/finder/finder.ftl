<#include "/functions.ftl">
<#macro finder_preprocessor finder>
<#assign finderName = "">
<#assign finderAttributes = "">
<#assign finderArguments = "">
<#assign finderParameters = "">
<#assign finderPersistenceParameters = "">
<#assign finderServiceParameters = "">
<#assign finderCollectionRelated = "">
<#if finder.name?has_content>
<#assign finderCollectionRelated = inheritedRelated(entity, finder.finderAttributes?first.name)>
<#assign finderCollectionEntity = entityMap[finderCollectionRelated.entityName]>
<#assign finderName = "findBy">
<#assign finderAttributes = finder.name?cap_first>
<#assign finderArguments = finder.name>
<#assign finderPersistenceParameters = finderCollectionEntity.name?cap_first + "Entity " + finder.name>
<#assign finderServiceParameters = finderCollectionEntity.name?cap_first + "DTO " + finder.name>
<#else>
<#list finder.finderAttributes as finderAttribute>
<#assign finderArgumentName = finderAttribute.name>
<#assign parameterJavaType = "">
<#if finderAttributes?length != 0><#assign finderAttributes += "And"></#if>
<#assign finderRelated = inheritedRelated(entity, finderAttribute.name)>
<#if finderRelated?has_content>
<#assign finderAttributes += finderRelated.name?cap_first + "Id">
<#assign finderArgumentName = finderRelated.name + "Id">
<#assign relatedEntity = entityMap[finderRelated.entityName]>
<#assign parameterJavaType = relatedEntity.key.type.javaType>
<#else>
<#assign finderParameter = inheritedAttribute(entity, finderAttribute.name)>
<#assign finderAttributes += finderParameter.name?cap_first>
<#if finderParameter.type.value == "enum">
<#if finderParameter.enumClass?has_content>
<#assign parameterJavaType = finderParameter.enumClass>
<#else>
<#assign parameterJavaType = finderParameter.name?cap_first>
</#if>
<#else>
<#assign parameterJavaType = finderParameter.type.javaType>
</#if>
</#if>
<#if finderArguments?length != 0><#assign finderArguments += ", "><#assign finderParameters += ", "></#if>
<#assign finderArguments += finderArgumentName>
<#assign finderParameters += parameterJavaType>
<#assign finderParameters += " ">
<#assign finderParameters += finderArgumentName>
<#if finder.unique>
<#assign finderName = "findFirstBy">
<#assign finderReturn = "T">
<#else>
<#assign finderName = "findBy">
<#assign finderReturn = "List<T>">
</#if>
</#list>
</#if>
</#macro>
