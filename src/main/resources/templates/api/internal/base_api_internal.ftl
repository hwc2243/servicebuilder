<#include "/core.ftl">
<#include "/functions.ftl">
package ${baseInternalApiPackage};

import java.util.List;

import org.springframework.http.ResponseEntity;

import ${localModelPackage}.${baseEntityName};

import ${baseInternalApiPackage}.BaseInternal${baseEntityName}Rest;

public interface BaseInternal${baseEntityName}Rest
{
	public ResponseEntity<${baseEntityName}> create${baseEntityName} (${baseEntityName} ${entity.name});
	
    public ResponseEntity<${baseEntityName}> delete${baseEntityName}(Long id); 

	public ResponseEntity<${baseEntityName}> get${baseEntityName} (Long id);
	
	public ResponseEntity<List<${baseEntityName}>> list${baseEntityName}s();
	
    public ResponseEntity<${baseEntityName}> update${baseEntityName}(Long id, ${baseEntityName} ${entity.name});
}