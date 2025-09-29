package ${multitenantPackage};


public class TenantDiscriminator implements Multitenant {

	public TenantDiscriminator() {
		// TODO Auto-generated constructor stub
	}

	public ${tenantDiscriminator.type.javaType} get${tenantDiscriminator.name?cap_first} () {
		throw new IllegalStateException("TenantDiscriminator.get${tenantDiscriminator.name?cap_first}() needs to be implemented.");
	}
}