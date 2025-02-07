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

<#assign finder = finder>
	public List<T> ${finder.buildFinderName()} (${finderParameters});
</#list>
</#if>
} 