package ${baseServicePackage};

import ${baseModelPackage}.Multitenant;

import ${localServicePackage}.TenantDiscriminator;

import java.util.List;
import java.util.Collection;

import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;

public abstract class MultitenantServiceImpl<T extends Multitenant, ID> {

	@Autowired
	protected TenantDiscriminator tenantDiscriminator;
	
	public MultitenantServiceImpl() {
		// TODO Auto-generated constructor stub
	}

	protected boolean hasAccess (T entity) {
		if (entity == null) {
			return false;
		} else {
			return tenantDiscriminator.get${tenantDiscriminator.name?cap_first}().equals(entity.get${tenantDiscriminator.name?cap_first}());
		}
	}
	
	public List<T> filterByAccess(Collection<T> entities) {
		if (entities == null || entities.isEmpty()) {
			return List.of(); // Return an empty, immutable list
		}

		// Use Java Streams to filter the collection based on the hasAccess method
		return entities.stream()
			.filter(this::hasAccess)
			.collect(Collectors.toList());
	}
}
