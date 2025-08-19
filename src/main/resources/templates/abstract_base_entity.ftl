package ${baseModelPackage};

import java.io.Serializable;

import java.util.Objects;

import ${jpaPackage}.GeneratedValue;
import ${jpaPackage}.GenerationType;
import ${jpaPackage}.Id;
import ${jpaPackage}.MappedSuperclass;

@MappedSuperclass
public abstract class AbstractBaseEntity
  implements Serializable
{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    protected long id;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }
    
    @Override
	public int hashCode() {
		return Objects.hash(id);
	}
	
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
			
		AbstractBaseEntity other = (AbstractBaseEntity) obj;
		return id == other.id;
	}
}