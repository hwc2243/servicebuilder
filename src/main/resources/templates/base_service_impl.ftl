package ${baseServicePackage};

import java.util.List;
import java.util.Optional;

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
  
  @Override
  public void delete (ID id) throws ServiceException
  {
    ${entity.name}Persistence.deleteById(id);
  }
  
  @Override
  public List<T> findAll () throws ServiceException
  {
    return ${entity.name}Persistence.findAll();
  }
  
  @Override
  public T get (ID id) throws ServiceException
  {
    Optional<T> optional = ${entity.name}Persistence.findById(id);

    return optional.isEmpty() ? null : optional.get();
  }
  
  @Override
  public T update (T entity) throws ServiceException
  {
    return ${entity.name}Persistence.save(entity);
  }
}