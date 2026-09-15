<#include "/functions.ftl">
<#include "/finder/finder.ftl">
package ${serviceBasePackage};

<#if entity.finders??>
<#assign imports += { "java.util.List" : true }>
</#if>
<#assign imports += { dtoBasePackage + ".Base" + entity.name?cap_first + "DTO" : true }>
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
<#list inheritedAndOwnFinders(entity) as finder>
<#if finder.name?has_content>
<#assign finderRelated = inheritedRelated(entity, finder.finderAttributes?first.name)>
<#assign finderCollectionEntity = entityMap[finderRelated.entityName]>
<#assign imports += { dtoPackage + "." + finderCollectionEntity.name?cap_first + "DTO" : true }>
</#if>
</#list>

<@import imports/>

public interface Base${entity.name?cap_first}Service<D extends Base${entity.name?cap_first}DTO, ID> extends EntityService<D, ID> {
<#list inheritedAndOwnFinders(entity) as finder>
<@finder_preprocessor finder=finder/>

<#if finderCollectionRelated?has_content>
	public List<D> ${finderName}${finderAttributes} (${finderServiceParameters});
<#elseif finder.unique>
	public D fetchBy${finderAttributes} (${finderParameters});
<#else>
	public List<D> ${finderName}${finderAttributes} (${finderParameters});
</#if>
</#list>
}
