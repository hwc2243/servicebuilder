<#include "/functions.ftl">
<#include "/finder/finder.ftl">
package ${persistenceBasePackage};

<#if entity.finders?? || entity.multitenant>
<#assign imports += { "java.util.List" : true }>
</#if>

<#assign imports += { 
  "org.springframework.data.jpa.repository.JpaRepository" : true,
  "org.springframework.data.repository.NoRepositoryBean" : true,
  entityPackage + "." + entity.name?cap_first + "Entity" : true 
}>

<#list entity.attributes as attribute>
<#if attribute.type.value == "enum">
<#if attribute.enumClass?has_content>
<#assign imports += { attribute.enumClass : true }>
<#else>
<#assign imports += { modelPackage +"." + entity.name?cap_first + attribute.name?cap_first : true }>
</#if>
</#if>
</#list>
<#list inheritedAndOwnFinders(entity) as finder>
<#if finder.name?has_content>
<#assign finderRelated = inheritedRelated(entity, finder.finderAttributes?first.name)>
<#assign finderCollectionEntity = entityMap[finderRelated.entityName]>
<#assign imports += {
  "org.springframework.data.jpa.repository.Query" : true,
  "org.springframework.data.repository.query.Param" : true,
  entityPackage + "." + finderCollectionEntity.name?cap_first + "Entity" : true
}>
</#if>
</#list>

<@import imports/>

@NoRepositoryBean
public interface Base${entity.name?cap_first}Persistence<E extends ${entity.name?cap_first}Entity, ID> extends JpaRepository<E, ID>
{
<#if entity.multitenant>
    public List<E> findBy${tenantDiscriminator.name?cap_first}(${tenantDiscriminator.type.javaType} ${tenantDiscriminator.name});
</#if>

<#list inheritedAndOwnFinders(entity) as finder>
<@finder_preprocessor finder=finder/>

<#if finderCollectionRelated?has_content>
    @Query("select entity from ${entity.name?cap_first}Entity entity join entity.${finderCollectionRelated.name} ${finder.name} where ${finder.name} = :${finder.name}")
    public List<E> ${finderName}${finderAttributes}(@Param("${finder.name}") ${finderPersistenceParameters});
<#else>
    public <#if finder.unique>E<#else>List<E></#if> ${finderName}<#if entity.multitenant>${tenantDiscriminator.name?cap_first}And</#if>${finderAttributes}(<#if entity.multitenant>${tenantDiscriminator.type.javaType} ${tenantDiscriminator.name}, </#if>${finderParameters});
</#if>

</#list>
}
