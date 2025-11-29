package ${clientServicePackage};

import org.springframework.stereotype.Service;

import ${clientBaseServicePackage}.Base${entity.name?cap_first}ServiceImpl;

import ${clientModelPackage}.${entity.name?cap_first};

@Service
public class ${entity.name?cap_first}ServiceImpl
  extends Base${entity.name?cap_first}ServiceImpl<${entity.name?cap_first},Long>
  implements ${entity.name?cap_first}Service
{
}