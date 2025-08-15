<#include "/core.ftl">
<#include "/functions.ftl">
package ${baseInternalApiPackage};

import java.util.List;
import java.util.ArrayList;

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;


import ${localModelPackage}.${baseEntityName};

import ${localServicePackage}.${baseEntityName}Service;
import ${localServicePackage}.ServiceException;

import ${baseInternalApiPackage}.BaseInternal${baseEntityName}Rest;

public abstract class BaseInternal${baseEntityName}RestImpl implements BaseInternal${baseEntityName}Rest
{
	@Autowired
	protected ${baseEntityName}Service ${entity.name}Service;
	
	@PostMapping
	@Override
	public ResponseEntity<${baseEntityName}> create${baseEntityName} (@RequestBody ${baseEntityName} ${entity.name})
	{
	  ${baseEntityName} new${baseEntityName} = null;
	  
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
	
	@DeleteMapping("/{id}")
	@Override
    public ResponseEntity<${baseEntityName}> delete${baseEntityName}(@PathVariable Long id) 
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

	@GetMapping("/{id}")
	@Override
	public ResponseEntity<${baseEntityName}> get${baseEntityName} (@PathVariable Long id)
	{
		${baseEntityName} ${entity.name} = null;
		
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
    public ResponseEntity<List<${baseEntityName}>> list${baseEntityName}s ()
    {
        try
        {
        	List<${baseEntityName}> ${entity.name}s = ${entity.name}Service.findAll();
        	return ResponseEntity.ok(${entity.name}s);
        }
        catch (ServiceException ex)
        {
          ex.printStackTrace();
          return ResponseEntity.internalServerError().build();
        }
    }
    
    @PutMapping("/{id}")
    @Override
    public ResponseEntity<${baseEntityName}> update${baseEntityName}(@PathVariable Long id, @RequestBody ${baseEntityName} ${entity.name})
    {
      ${baseEntityName} updated${baseEntityName} = null;
      
      if (${entity.name}.getId() == 0) 
      {
      	${entity.name}.setId(id);
      }
      else if (id != ${entity.name}.getId())
      {
         return ResponseEntity.badRequest().build();
      }
      try
      {
        ${baseEntityName} existing${baseEntityName} = ${entity.name}Service.get(id);
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
}