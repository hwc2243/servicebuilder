<#include "/finder/finder.ftl">
package ${baseRepositoryPackage};

<#if entity.finders??>
import java.util.List;

</#if>
import org.springframework.data.jpa.repository.JpaRepository;

import ${baseModelPackage}.Base${entity.name?cap_first};
import ${localModelPackage}.${entity.name?cap_first};
<#list entity.attributes as attribute>
<#if attribute.type.value == "enum">
<#if attribute.enumClass?has_content>
import ${attribute.enumClass};
<#else>
import ${localModelPackage}.${attribute.name?cap_first}Type;
</#if>
</#if>
</#list>

public interface Base${entity.name?cap_first}Persistence<T extends ${entity.name?cap_first}, ID> extends JpaRepository<T, ID>
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