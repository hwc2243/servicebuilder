<#include "/finder/finder.ftl">
package ${baseServicePackage};

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;

import ${baseModelPackage}.Base${entity.name?cap_first};
import ${localModelPackage}.${entity.name?cap_first};

import ${localServicePackage}.ServiceException;

import ${localRepositoryPackage}.${entity.name?cap_first}Persistence;
import ${baseRepositoryPackage}.Base${entity.name?cap_first}Persistence;

public abstract class Base${entity.name?cap_first}ServiceImpl<T extends ${entity.name?cap_first}, ID> implements Base${entity.name?cap_first}Service<T, ID> {

  @Autowired
  private Base${entity.name?cap_first}Persistence<T,ID> base${entity.name?cap_first}Persistence;
  
  @Autowired
  protected ${entity.name?cap_first}Persistence ${entity.name}Persistence;
  
  @Override
  public T create (T entity) throws ServiceException
  {
    return base${entity.name?cap_first}Persistence.save(entity);
  }
  
  @Override
  public void delete (ID id) throws ServiceException
  {
    base${entity.name?cap_first}Persistence.deleteById(id);
  }
  
  @Override
  public List<T> findAll () throws ServiceException
  {
    return base${entity.name?cap_first}Persistence.findAll();
  }
<#if entity.finders??>
<#list entity.finders as finder>
<@finder_processor finder=finder/>

<#if finder.unique>
  @Override
  public T ${finderName} (${finderParameters})
  {
	return base${entity.name?cap_first}Persistence.findFirstBy${finderAttributes}(${finderArguments});
  }
<#else>
  @Override
  public List<T> ${finderName} (${finderParameters})
  {
	return base${entity.name?cap_first}Persistence.${finderName}(${finderArguments});
  }
</#if>
</#list>
</#if>  

  @Override
  public T get (ID id) throws ServiceException
  {
    Optional<T> optional = base${entity.name?cap_first}Persistence.findById(id);

    return optional.isEmpty() ? null : optional.get();
  }
  
  @Override
  public T update (T entity) throws ServiceException
  {
    return base${entity.name?cap_first}Persistence.save(entity);
  }
}