package ${baseServicePackage};

import org.springframework.beans.factory.annotation.Autowired;

import ${baseModelPackage}.Base${entity.name?cap_first};

import ${baseRepositoryPackage}.Base${entity.name?cap_first}Persistence;

public abstract class Base${entity.name?cap_first}ServiceImpl<T extends Base${entity.name?cap_first}, ID> implements Base${entity.name?cap_first}Service<T, ID> {

  @Autowired
  protected Base${entity.name?cap_first}Persistence<T,ID> ${entity.name}Persistence;
  
  @Override
  public T create (T entity) throws ServiceException
  {
    return ${entity.name}Persistence.save(entity);
  }
}