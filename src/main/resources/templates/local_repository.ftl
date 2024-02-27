package ${localRepositoryPackage};

import ${localModelPackage}.${entity.name?cap_first};

import ${baseRepositoryPackage}.Base${entity.name?cap_first}Persistence;

public interface ${entity.name?cap_first}Persistence extends Base${entity.name?cap_first}Persistence<${entity.name?cap_first},Long>
{
} 