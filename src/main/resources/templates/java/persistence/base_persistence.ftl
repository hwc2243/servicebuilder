<#include "/functions.ftl">
<#include "/finder/finder.ftl">
package ${persistenceBasePackage};

<#if entity.finders??>
<#assign imports += { "java.util.List" : true }>
</#if>
<#assign imports += { 
  "org.springframework.data.jpa.repository.JpaRepository" : true,
  entityBasePackage + ".Base" + entity.name?cap_first + "Entity" : true,
  entityPackage + "." + entity.name?cap_first + "Entity" : true 
}>
<#list entity.attributes as attribute>
<#if attribute.type.value == "enum">
<#if attribute.enumClass?has_content>
<#assign imports += { attribute.enumClass : true }>
<#else>
<#assign imports += { modelPackage +"." + entity.name?cap_first + attribute.name?cap_first + "Type" : true }>
</#if>
</#if>
</#list>

<@import imports/>

public interface Base${entity.name?cap_first}Persistence<T extends Base${entity.name?cap_first}Entity, ID> extends JpaRepository<T, ID>
{
<#if entity.multitenant>
	public List<T> findBy${tenantDiscriminator.name?cap_first} (${tenantDiscriminator.type.javaType} ${tenantDiscriminator.name});
	
</#if>
<#if entity.finders??>
<#list entity.finders as finder>
<@finder_preprocessor finder=finder/>

    public ${finderReturn} ${finderName}<#if entity.multitenant>${tenantDiscriminator.name?cap_first}And</#if>${finderAttributes} (<#if entity.multitenant>${tenantDiscriminator.type.javaType} ${tenantDiscriminator.name}, </#if>${finderParameters});
</#list>
</#if>
} 