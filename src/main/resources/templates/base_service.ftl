<#include "/finder/finder.ftl">
package ${baseServicePackage};

<#if entity.finders??>
import java.util.List;

</#if>
import ${baseModelPackage}.Base${entity.name?cap_first};

public interface Base${entity.name?cap_first}Service<T extends Base${entity.name?cap_first}, ID> extends EntityService<T, ID> {
<#if entity.finders??>
<#list entity.finders as finder>
<@finder_preprocessor finder=finder/>

<#if finder.unique>
	public T fetchBy${finderAttributes} (${finderParameters});
<#else>
	public List<T> ${finderName}${finderAttributes} (${finderParameters});
</#if>
</#list>
</#if>
}