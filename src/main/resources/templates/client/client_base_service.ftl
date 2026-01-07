<#include "/finder/finder.ftl">
package ${clientBaseServicePackage};

<#if entity.finders??>
import java.util.List;

</#if>
import ${clientBaseModelPackage}.Base${entity.name?cap_first};
<#list entity.attributes as attribute>
<#if attribute.type.value == "enum">
<#if attribute.enumClass?has_content>
import ${attribute.enumClass};
<#else>
import ${dtoPackage}.${attribute.name?cap_first}Type;
</#if>
</#if>
</#list>

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