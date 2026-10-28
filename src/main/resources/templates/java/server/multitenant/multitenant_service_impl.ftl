<#include "/functions.ftl">
package ${multitenantBaseServicePackage};
<#assign imports += { 
  multitenantBaseModelPackage + ".Multitenant" : true,
  multitenantServicePackage + ".TenantDiscriminator" : true,
  "java.util.List" : true,
  "java.util.Collection" : true,
  "java.util.stream.Collectors" : true,
  "org.springframework.beans.factory.annotation.Autowired" : true
}>

<@import imports/>

public abstract class MultitenantServiceImpl {

	@Autowired
	protected TenantDiscriminator tenantDiscriminator;
	
	public MultitenantServiceImpl() {
		// TODO Auto-generated constructor stub
	}

	protected boolean hasAccess (Multitenant bean) {
		if (bean == null) {
			return false;
		} else {
			return tenantDiscriminator.get${tenantDiscriminator.name?cap_first}().equals(bean.get${tenantDiscriminator.name?cap_first}());
		}
	}
	
	public <X extends Multitenant> List<X> filterByAccess(Collection<X> beans) {
		if (beans == null || beans.isEmpty()) {
			return List.of(); // Return an empty, immutable list
		}

		// Use Java Streams to filter the collection based on the hasAccess method
		return beans.stream()
			.filter(this::hasAccess)
			.collect(Collectors.toList());
	}
}
