<#include "/entity/util.ftl">
<#assign className = className(entity.name)>
<#assign variableName = entity.name>
package ${clientBaseRestPackage};

import java.io.IOException;
import java.util.List;
import java.util.concurrent.CompletableFuture;

import ${clientModelPackage}.${className};

import com.google.gson.reflect.TypeToken;

public abstract class Base${className}RestClient<T extends ${className}>
<#if entity.multitenant>
  extends MultitenantRestClient  
<#else>
  extends AbstractRestClient
</#if>
{
	protected String hostPath = "http://localhost:8080";
	protected String apiPath = "/api/external/${entity.name}";

	public Base${className}RestClient() {
		super();
	}
	
	public CompletableFuture<T> create (T entity) {
		try {
			T ${variableName} = doPost(hostPath, apiPath, entity, new TypeToken<${className}>() {}.getType());
			return CompletableFuture.completedFuture(${variableName});
		} catch (IOException | InterruptedException e) {
			return CompletableFuture.failedFuture(e);
		}
	}
	
	public CompletableFuture<T> get (long id) {
		try {
			T ${variableName} = doGet(hostPath, apiPath + "/" + id, new TypeToken<${className}>() {}.getType());
			return CompletableFuture.completedFuture(${variableName});
		} catch (IOException | InterruptedException e) {
			return CompletableFuture.failedFuture(e);
		}
	}
	
	public CompletableFuture<List<T>> findAll () {
		try {
			List<T> ${variableName}s = doGet(hostPath, apiPath,
					new TypeToken<List<${className}>>() {}.getType());
			
			return CompletableFuture.completedFuture(${variableName}s);
			
		} catch (IOException | InterruptedException e) {
			return CompletableFuture.failedFuture(e);
		}
	}
}