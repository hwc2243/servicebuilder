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
<#list finder.finderColumns as finderColumn>
<#if finderName?length != 0><#assign finderName += "And"></#if>
<#assign finderName += finderColumn.name?cap_first>
<#if finderParameters?length != 0><#assign finderParameters += ", "></#if>
<#assign finderParameter = entity.getAttribute(finderColumn.name)>
<#assign finderParameters += finderParameter.type>
<#assign finderParameters += " ">
<#assign finderParameters += finderParameter.name>
</#list>

	public List<T> findBy${finderName} (${finderParameters});
</#list>
</#if>
} 