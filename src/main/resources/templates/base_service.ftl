package ${baseServicePackage};

import ${baseModelPackage}.Base${entity.name?cap_first};

public interface Base${entity.name?cap_first}Service<T extends Base${entity.name?cap_first}, ID> extends EntityService<T, ID> {
}