package ${multitenantBaseServicePackage};

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;

import ${multitenantServicePackage}.TenantDiscriminator;

public abstract class MultitenantRestClient extends AbstractRestClient {

	@Autowired
	protected TenantDiscriminator tenantDiscriminator;
	
	public MultitenantRestClient() {
		super();
	}

	@Override
	protected Map<String, String> getHeaders() {
		Map<String,String> headers = new HashMap<>(super.getHeaders());
		headers.put("${tenantDiscriminator.name}", "" + tenantDiscriminator.get${tenantDiscriminator.name?cap_first}());
		return headers;
	}

}