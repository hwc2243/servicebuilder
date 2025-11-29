package ${clientRepositoryPackage};

import ${clientModelPackage}.${entity.name?cap_first};

import ${clientBaseRepositoryPackage}.Base${entity.name?cap_first}Persistence;

public interface ${entity.name?cap_first}Persistence extends Base${entity.name?cap_first}Persistence<${entity.name?cap_first},Long>
{
} 