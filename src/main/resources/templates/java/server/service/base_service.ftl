<#include "/functions.ftl">
<#include "/java/server/finder/finder.ftl">
package ${serviceBasePackage};

<#if entity.finders?? || entity.relateds?size gt 0>
<#assign imports += { "java.util.List" : true }>
</#if>
<#assign hasCollectionRelations = entity.relateds?filter(r -> r.relationshipType.name() == "ONE_TO_MANY" || r.relationshipType.name() == "MANY_TO_MANY")?size gt 0>
<#if hasCollectionRelations>
<#assign imports += { "java.util.Collection" : true }>
</#if>
<#assign imports += { dtoBasePackage + ".Base" + entity.name?cap_first + "DTO" : true }>
<#assign imports += { servicePackage + ".ServiceException" : true }>
<#list entity.relateds as related>
<#if related.relationshipType.name() == "ONE_TO_MANY" || related.relationshipType.name() == "MANY_TO_MANY">
<#assign imports += { dtoPackage + "." + related.entityName?cap_first + "DTO" : true }>
</#if>
</#list>
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
	public D fetchBy<#if entity.multitenant && finder.tenantScoped>${tenantDiscriminator.name?cap_first}And</#if>${finderAttributes} (${finderParameters});
<#else>
	public List<D> ${finderName}${finderAttributes} (${finderParameters});
</#if>
</#list>
<#list entity.relateds as related>
<#if related.relationshipType.name() == "MANY_TO_ONE" && !hasRelationshipFinder(entity, related) && !isTenantDiscriminatorRelation(entity, related)>
	public List<D> findBy${related.name?cap_first}Id (${entityMap[related.entityName].key.type.javaType} ${related.name}Id);
</#if>
<#if related.relationshipType.name() == "ONE_TO_MANY" || related.relationshipType.name() == "MANY_TO_MANY">
	public Collection<${related.entityName?cap_first}DTO> get${related.name?cap_first} (ID id) throws ServiceException;
</#if>
</#list>
}
