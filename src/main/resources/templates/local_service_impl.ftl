package ${localServicePackage};

import org.springframework.stereotype.Service;

import ${baseServicePackage}.Base${entity.name?cap_first}ServiceImpl;

import ${localModelPackage}.${entity.name?cap_first};

@Service
public class ${entity.name?cap_first}ServiceImpl
  extends Base${entity.name?cap_first}ServiceImpl<${entity.name?cap_first},${entity.key.type.javaType}>
  implements ${entity.name?cap_first}Service
{
}