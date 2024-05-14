package ${baseModelPackage};

import java.util.Objects;

import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.MappedSuperclass;

@MappedSuperclass
public abstract class AbstractBaseEntity
{
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    protected long id;

    public long getId() {
        return id;
    }

    public void setId(long id) {
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