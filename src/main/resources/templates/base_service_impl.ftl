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
<#if entity.multitenant>

import ${multitenantPackage}.Multitenant;
import ${multitenantPackage}.MultitenantServiceImpl;
</#if>

public abstract class Base${entity.name?cap_first}ServiceImpl<T extends ${entity.name?cap_first}<#if entity.multitenant> & Multitenant</#if>, ID>
<#if entity.multitenant>
  extends MultitenantServiceImpl<T, ID>
</#if>
  implements Base${entity.name?cap_first}Service<T, ID> {

  @Autowired
  private Base${entity.name?cap_first}Persistence<T,ID> base${entity.name?cap_first}Persistence;
  
  @Autowired
  protected ${entity.name?cap_first}Persistence ${entity.name}Persistence;
  
  @Override
  public T create (T entity) throws ServiceException
  {
  <#if entity.multitenant>
    if (!hasAccess(entity)) {
      throw new ServiceException("Access denied for creating ${entity.name}");
    }
    
  </#if>
    return base${entity.name?cap_first}Persistence.save(entity);
  }
  
  @Override
  public void delete (ID id) throws ServiceException
  {
  <#if entity.multitenant>
    try {
      get(id);
    } catch (ServiceException ex) {
      throw new ServiceException("Access denied for deleting ${entity.name} with ${entity.key.name} = " + id);
    }
    
  </#if>
    base${entity.name?cap_first}Persistence.deleteById(id);
  }
  
  @Override
  public List<T> findAll () throws ServiceException
  {
<#if entity.multitenant>
    return base${entity.name?cap_first}Persistence.findBy${tenantDiscriminator.name?cap_first}(tenantDiscriminator.get${tenantDiscriminator.name?cap_first}());
<#else>
    return base${entity.name?cap_first}Persistence.findAll();
</#if>
  }
<#if entity.finders??>
<#list entity.finders as finder>
<@finder_preprocessor finder=finder/>

<#if finder.unique>
  @Override
  public T fetchBy${finderAttributes} (${finderParameters})
  {
	return base${entity.name?cap_first}Persistence.findFirstBy${finderAttributes}(${finderArguments});
  }
<#else>
  @Override
  public List<T> ${finderName}${finderAttributes} (${finderParameters})
  {
	return base${entity.name?cap_first}Persistence.${finderName}<#if entity.multitenant>${tenantDiscriminator.name?cap_first}And</#if>${finderAttributes}(<#if entity.multitenant>tenantDiscriminator.get${tenantDiscriminator.name?cap_first}(),</#if>${finderArguments});
  }
</#if>
</#list>
</#if>  

  @Override
  public T get (ID id) throws ServiceException
  {
    Optional<T> optional = base${entity.name?cap_first}Persistence.findById(id);

<#if entity.multitenant>
    if (optional.isPresent()) {
      if (!hasAccess(optional.get())) {
		throw new ServiceException("Access denied for ${entity.name} with ${entity.key.name} = " + id);
	  }
	}
</#if>
    return optional.isEmpty() ? null : optional.get();
  }
  
  @Override
  public T update (T entity) throws ServiceException
  {
  <#if entity.multitenant>
    if (!hasAccess(entity)) {
      throw new ServiceException("Access denied for updating ${entity.name} with ${entity.key.name} = " + entity.get${entity.key.name?cap_first}());
    }
  </#if>
    return base${entity.name?cap_first}Persistence.save(entity);
  }
}