package ${multitenantServicePackage};

public interface TenantDiscriminator {

	public ${tenantDiscriminator.type.javaType} get${tenantDiscriminator.name?cap_first} ();
}