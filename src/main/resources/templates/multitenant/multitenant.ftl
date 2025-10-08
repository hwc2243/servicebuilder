package ${baseModelPackage};

public interface Multitenant {
	public ${tenantDiscriminator.type.javaType} get${tenantDiscriminator.name?cap_first} ();
}
