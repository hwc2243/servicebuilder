<#macro equals_hashcode entity key>
    @Override
	public int hashCode() {
		return Objects.hash(${key.name});
	}
	
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
			
		Base${entity.name?cap_first} other = (Base${entity.name?cap_first}) obj;
<#if entity.key.type.value == "uuid" || entity.key.type.value == "string">
		return this.get${key.name?cap_first}().equals(other.get${key.name?cap_first}());
<#else>		
		return ${key.name} == other.${key.name};
</#if>
	}
</#macro>