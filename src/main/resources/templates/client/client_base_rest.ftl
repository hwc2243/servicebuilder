<#include "/entity/util.ftl">
<#assign className = className(entity.name)>
<#assign variableName = entity.name>
package ${clientBaseRestPackage};

import java.io.IOException;
import java.util.List;
import java.util.concurrent.CompletableFuture;

import ${clientModelPackage}.${className};

import com.google.gson.reflect.TypeToken;

import org.springframework.beans.factory.annotation.Value;

public abstract class Base${className}RestClient<T extends ${className}>
<#if entity.multitenant>
  extends MultitenantRestClient  
<#else>
  extends AbstractRestClient
</#if>
{
<#noparse>
	@Value("${apiHostName:http://localhost:8080}")
</#noparse>
	protected String hostPath;
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

/*
    public CompletableFuture<T> get (long id) {
    // 1. supplyAsync moves the execution to a worker thread (usually ForkJoinPool.commonPool())
    return CompletableFuture.supplyAsync(() -> {
        try {
            // 2. This synchronous call (doGet) now executes on a background thread.
            // Note: We use the target type here, which is Organization in your case
            return doGet(hostPath, apiPath + "/" + id, new TypeToken<Organization>() {}.getType());
        } catch (IOException | InterruptedException e) {
            // 3. If an exception occurs, it must be thrown inside the supplier
            // This causes the CompletableFuture to complete exceptionally.
            throw new RuntimeException(e);
        }
    });
    // The .exceptionally() or .handle() method is often used after this 
    // to process the exception on the main thread if needed.
    }
*/	
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