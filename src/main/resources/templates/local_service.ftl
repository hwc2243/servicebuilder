package ${localServicePackage};

import ${baseServicePackage}.Base${entity.name?cap_first}Service;

import ${localModelPackage}.${entity.name?cap_first};

public interface ${entity.name?cap_first}Service extends Base${entity.name?cap_first}Service<${entity.name?cap_first},Long>
{
}