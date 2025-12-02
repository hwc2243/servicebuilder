<#include "/core.ftl">
<#include "/functions.ftl">
package ${baseInternalApiPackage};

import java.util.List;

import org.springframework.http.ResponseEntity;

import org.springframework.web.bind.annotation.RequestParam;

import ${localModelPackage}.${baseEntityName};

import ${baseInternalApiPackage}.BaseInternal${baseEntityName}Rest;

public interface BaseInternal${baseEntityName}Rest
{
<#if entity.api?? && entity.api.internal?? && entity.api.internal.operations?seq_contains("CREATE")>
	public ResponseEntity<${baseEntityName}> create${baseEntityName} (${baseEntityName} ${entity.name});
</#if>
	
<#if entity.api?? && entity.api.internal?? && entity.api.internal.operations?seq_contains("DELETE")>
    public ResponseEntity<${baseEntityName}> delete${baseEntityName}(${entity.key.type.javaType} id); 
</#if>

<#if entity.api?? && entity.api.internal?? && entity.api.internal.operations?seq_contains("READ")>
	public ResponseEntity<${baseEntityName}> get${baseEntityName} (${entity.key.type.javaType} id);
	
	public ResponseEntity<List<${baseEntityName}>> list${baseEntityName}s ();
	
	public ResponseEntity<List<${baseEntityName}>> search${baseEntityName}s (
<#assign searchableAttributes = entity.attributes?filter(a -> a.name != "id" && a.type == "String")>
<#list searchableAttributes as attribute>
      @RequestParam(required = false) String ${attribute.name}<#sep>,</#sep>
</#list>
	);
</#if>
	
<#if entity.api?? && entity.api.internal?? && entity.api.internal.operations?seq_contains("UPDATE")>
    public ResponseEntity<${baseEntityName}> update${baseEntityName} (${entity.key.type.javaType} id, ${baseEntityName} ${entity.name});
</#if>
}