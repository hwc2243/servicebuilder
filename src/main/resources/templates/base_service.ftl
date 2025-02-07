package ${baseServicePackage};

<#if entity.finders??>
import java.util.List;

</#if>
import ${baseModelPackage}.Base${entity.name?cap_first};

public interface Base${entity.name?cap_first}Service<T extends Base${entity.name?cap_first}, ID> extends EntityService<T, ID> {
<#if entity.finders??>
<#list entity.finders as finder>
<#assign finderName = "">
<#assign finderParameters = "">
<#list finder.finderAttributes as finderAttribute>
<#if finderName?length != 0><#assign finderName += "And"></#if>
<#assign finderName += finderAttribute.name?cap_first>
<#if finderParameters?length != 0><#assign finderParameters += ", "></#if>
<#assign finderParameter = entity.getAttribute(finderAttribute.name)>
<#assign finderParameters += finderParameter.type>
<#assign finderParameters += " ">
<#assign finderParameters += finderParameter.name>
</#list>

	public List<T> findBy${finderName} (${finderParameters});
</#list>
</#if>
}