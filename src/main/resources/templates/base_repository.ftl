package ${baseRepositoryPackage};

import ${baseModelPackage}.Base${entity.name?cap_first};

import org.springframework.data.jpa.repository.JpaRepository;

public interface Base${entity.name?cap_first}Persistence<T extends Base${entity.name?cap_first}, ID> extends JpaRepository<T, ID>
{
} 