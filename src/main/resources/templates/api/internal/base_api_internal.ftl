<#include "/core.ftl">
<#include "/functions.ftl">
package ${baseInternalApiPackage};

import org.springframework.http.ResponseEntity;

import ${localModelPackage}.${baseEntityName};

import ${baseInternalApiPackage}.BaseInternal${baseEntityName}Rest;

public interface BaseInternal${baseEntityName}Rest
{
	public ResponseEntity<${baseEntityName}> get${baseEntityName}ById (Long id);

}