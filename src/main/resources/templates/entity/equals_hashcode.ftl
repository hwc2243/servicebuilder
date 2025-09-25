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
		return ${key.name} == other.${key.name};
	}
</#macro>