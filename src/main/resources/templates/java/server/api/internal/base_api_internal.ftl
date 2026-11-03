<#include "/functions.ftl">
package ${baseInternalApiPackage};

import java.util.Collection;
import java.util.List;

import org.springframework.http.ResponseEntity;

import org.springframework.web.bind.annotation.RequestParam;

import ${dtoPackage}.${entity.name?cap_first}DTO;
<#list entity.relateds as related>
<#if related.relationshipType.name() == "ONE_TO_MANY" || related.relationshipType.name() == "MANY_TO_MANY">
import ${dtoPackage}.${related.entityName?cap_first}DTO;
</#if>
</#list>

import ${baseInternalApiPackage}.BaseInternal${entity.name?cap_first}Rest;

public interface BaseInternal${entity.name?cap_first}Rest
{
<#if entity.api?? && entity.api.internal?? && entity.api.internal.operations?seq_contains("CREATE")>
	public ResponseEntity<${entity.name?cap_first}DTO> create${entity.name?cap_first} (${entity.name?cap_first}DTO ${entity.name});
</#if>
	
<#if entity.api?? && entity.api.internal?? && entity.api.internal.operations?seq_contains("DELETE")>
    public ResponseEntity<Void> delete${entity.name?cap_first}(${entity.key.type.javaType} id);
</#if>

<#if entity.api?? && entity.api.internal?? && entity.api.internal.operations?seq_contains("READ")>
	public ResponseEntity<${entity.name?cap_first}DTO> get${entity.name?cap_first} (${entity.key.type.javaType} id);
	
	public ResponseEntity<List<${entity.name?cap_first}DTO>> list${entity.name?cap_first}s ();
	
	public ResponseEntity<List<${entity.name?cap_first}DTO>> search${entity.name?cap_first}s (
<#assign searchableAttributes = entity.attributes?filter(a -> a.name != "id" && a.type == "string")>
<#list searchableAttributes as attribute>
      @RequestParam(required = false) String ${attribute.name}<#sep>,</#sep>
</#list>
	);

<#list entity.relateds as related>
<#if related.relationshipType.name() == "ONE_TO_MANY" || related.relationshipType.name() == "MANY_TO_MANY">
	public ResponseEntity<Collection<${related.entityName?cap_first}DTO>> list${entity.name?cap_first}${related.name?cap_first} (
		${entity.key.type.javaType} ${entity.name}Id);
</#if>
</#list>
</#if>
	
<#if entity.api?? && entity.api.internal?? && entity.api.internal.operations?seq_contains("UPDATE")>
	    public ResponseEntity<${entity.name?cap_first}DTO> update${entity.name?cap_first} (${entity.key.type.javaType} id, ${entity.name?cap_first}DTO ${entity.name});
</#if>
}
