<#include "/finder/finder.ftl">
package ${baseRepositoryPackage};

<#if entity.finders??>
import java.util.List;

</#if>
import org.springframework.data.jpa.repository.JpaRepository;

import ${baseModelPackage}.Base${entity.name?cap_first};
import ${localModelPackage}.${entity.name?cap_first};

public interface Base${entity.name?cap_first}Persistence<T extends ${entity.name?cap_first}, ID> extends JpaRepository<T, ID>
{
<#if entity.finders??>
<#list entity.finders as finder>
<@finder_processor finder=finder/>

<#if finder.unique>
    public T findFirstBy${finderAttributes} (${finderParameters});
<#else>
	public List<T> ${finderName} (${finderParameters});
</#if>
</#list>
</#if>
} 