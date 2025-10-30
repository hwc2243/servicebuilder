<#include "/entity/util.ftl">
<#assign className = className(entity.name)>
<#assign variableName = entity.name>
package ${clientBaseRestPackage};

import java.io.IOException;
import java.util.List;
import java.util.concurrent.CompletableFuture;

import ${clientModelPackage}.${className};

import com.google.gson.reflect.TypeToken;

public abstract class Base${className}RestClient
<#if entity.multitenant>
  extends MultitenantRestClient  
<#else>
  extends AbstractRestClient
</#if>
{

	public Base${className}RestClient() {
		super();
	}
	
	public CompletableFuture<${className}> get (long id) {
		try {
			${className} ${variableName} = doGet("http://localhost:8080", "/api/external/menu/" + id, new TypeToken<${className}>() {}.getType());
			return CompletableFuture.completedFuture(${variableName});
		} catch (IOException | InterruptedException e) {
			return CompletableFuture.failedFuture(e);
		}
	}
	
	public CompletableFuture<List<${className}>> findAll () {
		try {
			List<${className}> ${variableName}s = doGet("http://localhost:8080", "/api/external/menu",
					new TypeToken<List<${className}>>() {}.getType());
			
			return CompletableFuture.completedFuture(${variableName}s);
			
		} catch (IOException | InterruptedException e) {
			return CompletableFuture.failedFuture(e);
		}
	}
}