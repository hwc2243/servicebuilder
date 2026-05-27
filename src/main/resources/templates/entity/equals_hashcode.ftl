<#macro equals_hashcode entity key>
    @Override
	public int hashCode() {
		return Objects.hash(this.get${key.name?cap_first}());
	}
	
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
			
		Base${entity.name?cap_first}Entity other = (Base${entity.name?cap_first}Entity) obj;
		return Objects.equals(get${key.name?cap_first}(), other.get${key.name?cap_first}());
	}
</#macro>