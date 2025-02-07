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
<#assign finderName = "">
<#assign finderArguments = "">
<#assign finderParameters = "">
<#list finder.finderAttributes as finderAttribute>
<#if finderName?length != 0><#assign finderName += "And"></#if>
<#assign finderName += finderAttribute.name?cap_first>
<#if finderArguments?length != 0><#assign finderArguments += ", "><#assign finderParameters += ", "></#if>
<#assign finderParameter = entity.getAttribute(finderAttribute.name)>
<#assign finderArguments += finderParameter.name>
<#assign finderParameters += finderParameter.type>
<#assign finderParameters += " ">
<#assign finderParameters += finderParameter.name>
</#list>

  @Override
  public List<T> findBy${finderName} (${finderParameters})
  {
	return base${entity.name?cap_first}Persistence.findBy${finderName}(${finderArguments});
  }
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