<#include "/functions.ftl">
<#assign baseEntityName = entity.name?cap_first>
<#assign dtoName = baseEntityName + "DTO">
package ${baseExternalApiPackage};

import java.util.List;
import java.util.ArrayList;

import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import ${dtoPackage}.${dtoName};

import ${servicePackage}.${baseEntityName}Service;
import ${servicePackage}.ServiceException;

import ${baseExternalApiPackage}.BaseExternal${baseEntityName}Rest;

public abstract class BaseExternal${baseEntityName}RestImpl implements BaseExternal${baseEntityName}Rest
{
	@Autowired
	protected ${baseEntityName}Service ${entity.name}Service;

<#if entity.api?? && entity.api.external?? && entity.api.external.operations?seq_contains("CREATE")>
	@PostMapping
	@Override
	public ResponseEntity<${dtoName}> create${baseEntityName} (@RequestBody ${dtoName} ${entity.name})
	{
	  ${dtoName} new${baseEntityName} = null;
	  
	  try
	  {
	    new${baseEntityName} = ${entity.name}Service.create(${entity.name});
	  }
	  catch (ServiceException ex)
	  {
	    ex.printStackTrace();
        return ResponseEntity.internalServerError().build();
	  }	
	  
	  return ResponseEntity.status(HttpStatus.CREATED).body(new${baseEntityName});
	}
</#if>
	
<#if entity.api?? && entity.api.external?? && entity.api.external.operations?seq_contains("DELETE")>
	@DeleteMapping("/{id}")
	@Override
    public ResponseEntity<Void> delete${baseEntityName}(@PathVariable ${entity.key.type.javaType} id)
    {
      try
      {
        ${entity.name}Service.delete(id);
      }
      catch (ServiceException ex)
      {
        ex.printStackTrace();
        return ResponseEntity.internalServerError().build();
      }
      return ResponseEntity.noContent().build();
    }
</#if>

<#if entity.api?? && entity.api.external?? && entity.api.external.operations?seq_contains("READ")>
	@GetMapping("/{id}")
	@Override
	public ResponseEntity<${dtoName}> get${baseEntityName} (@PathVariable ${entity.key.type.javaType} id)
	{
		${dtoName} ${entity.name} = null;
		
		try	{
			${entity.name} = ${entity.name}Service.get(id);
		}
		catch (ServiceException ex) {
			ex.printStackTrace();
          return ResponseEntity.internalServerError().build();
		}
		
        if (${entity.name} != null) {
            return ResponseEntity.ok(${entity.name});
        } else {
            return ResponseEntity.notFound().build();
        }
    }
    
    @GetMapping
    @Override
    public ResponseEntity<List<${dtoName}>> list${baseEntityName}s ()
    {
        try
        {
        List<${dtoName}> ${entity.name}s = ${entity.name}Service.findAll();
        	return ResponseEntity.ok(${entity.name}s);
        }
        catch (ServiceException ex)
        {
          ex.printStackTrace();
          return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/search")
    @Override  
	public ResponseEntity<List<${dtoName}>> search${baseEntityName}s (
<#assign searchableAttributes = entity.attributes?filter(a -> a.name != "id" && a.type == "string")>
<#list searchableAttributes as attribute>
      @RequestParam(required = false) String ${attribute.name}<#sep>,</#sep>
</#list>
	)
	{
	  try
	  {
	    List<${dtoName}> all${baseEntityName}s = ${entity.name}Service.findAll();
	    List<${dtoName}> filtered${baseEntityName}s = all${baseEntityName}s.stream()
<#list entity.attributes as attribute>
<#if attribute.name != "id" && attribute.type == "string">
          .filter(item -> ${attribute.name} == null || item.get${attribute.name?cap_first}().equalsIgnoreCase(${attribute.name}))
</#if>
</#list>
          .collect(Collectors.toList());
          
        return ResponseEntity.ok(filtered${baseEntityName}s);
	  }
	  catch (ServiceException ex)
	  {
	    ex.printStackTrace();
        return ResponseEntity.internalServerError().build();
	  }
	}
</#if>
	
<#if entity.api?? && entity.api.external?? && entity.api.external.operations?seq_contains("UPDATE")>
    @PutMapping("/{id}")
    @Override
	    public ResponseEntity<${dtoName}> update${baseEntityName}(@PathVariable ${entity.key.type.javaType} id, @RequestBody ${dtoName} ${entity.name})
    {
	      ${dtoName} updated${baseEntityName} = null;

<#if entity.key.type.value == "string" || entity.key.type.value == "uuid" >
      if (${entity.name}.getId() == null || "".equals(${entity.name}.getId()))
      {
      	${entity.name}.setId(id);
      }
      else if (!${entity.name}.getId().equals(id))
      {
        return ResponseEntity.badRequest().build();
      }
<#else>
      if (${entity.name}.getId() == 0) 
      {
      	${entity.name}.setId(id);
      }
      else if (id != ${entity.name}.getId())
      {
        return ResponseEntity.badRequest().build();
      }
</#if>
      try
      {
        ${dtoName} existing${baseEntityName} = ${entity.name}Service.get(id);
        if (existing${baseEntityName} == null)
        {
          return ResponseEntity.notFound().build();
        }
        updated${baseEntityName} = ${entity.name}Service.update(${entity.name});
      }
      catch (ServiceException ex)
      {
        ex.printStackTrace();
        return ResponseEntity.internalServerError().build();
      }
      return ResponseEntity.ok(updated${baseEntityName});
    }
</#if>
}
