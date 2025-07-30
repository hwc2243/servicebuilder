<#include "/core.ftl">
<#include "/functions.ftl">
package ${baseInternalApiPackage};

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.http.ResponseEntity;

import org.springframework.web.bind.annotation.PathVariable;

import ${localModelPackage}.${baseEntityName};

import ${localServicePackage}.${baseEntityName}Service;
import ${localServicePackage}.ServiceException;

import ${baseInternalApiPackage}.BaseInternal${baseEntityName}Rest;

public abstract class BaseInternal${baseEntityName}RestImpl implements BaseInternal${baseEntityName}Rest
{
	@Autowired
	protected ${baseEntityName}Service ${entity.name}Service;
	
	public ResponseEntity<${baseEntityName}> get${baseEntityName}ById (@PathVariable Long id)
	{
		${baseEntityName} entity = null;
		
		try	{
			entity = ${entity.name}Service.get(id);
		}
		catch (ServiceException ex) {
			ex.printStackTrace();
		}
		
        if (entity != null) {
            return ResponseEntity.ok(entity);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}