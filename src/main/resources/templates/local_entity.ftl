package ${localModelPackage};

import jakarta.persistence.Entity;

import ${baseModelPackage}.Base${entity.name?cap_first};

@Entity
public class ${entity.name?cap_first} extends Base${entity.name?cap_first}
{
}