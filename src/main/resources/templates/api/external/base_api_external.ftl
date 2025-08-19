<#include "/core.ftl">
<#include "/functions.ftl">
package ${baseExternalApiPackage};

import java.util.List;

import org.springframework.http.ResponseEntity;

import org.springframework.web.bind.annotation.RequestParam;

import ${localModelPackage}.${baseEntityName};

import ${baseExternalApiPackage}.BaseExternal${baseEntityName}Rest;

public interface BaseExternal${baseEntityName}Rest
{
<#if entity.api?? && entity.api.external?? && entity.api.external.operations?seq_contains("CREATE")>
	public ResponseEntity<${baseEntityName}> create${baseEntityName} (${baseEntityName} ${entity.name});
</#if>
	
<#if entity.api?? && entity.api.external?? && entity.api.external.operations?seq_contains("DELETE")>
    public ResponseEntity<${baseEntityName}> delete${baseEntityName}(Long id); 
</#if>

<#if entity.api?? && entity.api.external?? && entity.api.external.operations?seq_contains("READ")>
	public ResponseEntity<${baseEntityName}> get${baseEntityName} (Long id);
	
	public ResponseEntity<List<${baseEntityName}>> list${baseEntityName}s ();
	
	public ResponseEntity<List<${baseEntityName}>> search${baseEntityName}s (
<#assign searchableAttributes = entity.attributes?filter(a -> a.name != "id" && a.type == "String")>
<#list searchableAttributes as attribute>
      @RequestParam(required = false) String ${attribute.name}<#sep>,</#sep>
</#list>
	);
</#if>
	
<#if entity.api?? && entity.api.external?? && entity.api.external.operations?seq_contains("UPDATE")>
    public ResponseEntity<${baseEntityName}> update${baseEntityName} (Long id, ${baseEntityName} ${entity.name});
</#if>
}