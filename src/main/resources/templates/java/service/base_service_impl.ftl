<#include "/functions.ftl">
<#include "/finder/finder.ftl">
package ${serviceBasePackage};
<#assign imports += {
  "java.util.List": true,
  "java.util.Optional": true,
  "org.springframework.beans.factory.annotation.Autowired" : true,
  dtoBasePackage + ".Base" + entity.name?cap_first + "DTO" : true,
  dtoPackage + "." + entity.name?cap_first + "DTO" : true,
  entityBasePackage + ".Base" + entity.name?cap_first + "Entity" : true,
  entityPackage + "." + entity.name?cap_first + "Entity" : true,
  persistencePackage + "." + entity.name?cap_first + "Persistence" : true,
  persistenceBasePackage + ".Base" + entity.name?cap_first + "Persistence" : true,
  servicePackage + ".ServiceException" : true
}>
<#list entity.attributes as attribute>
<#if attribute.type == "ENUM">
<#if attribute.enumClass?has_content>
<#assign imports += { attribute.enumClass : true }>
<#else>
<#assign imports += { modelPackage + "." + entity.name?cap_first + attribute.name?cap_first : true }>
</#if>
<#elseif attribute.type.javaType?last_index_of(".") gt 0>
<#assign imports += { attribute.type.javaType : true }>
</#if>
</#list>
<#if entity.multitenant>
<#assign imports += {
 modelBasePackage + ".Multitenant" : true,
 serviceBasePackage + ".MultitenantServiceImpl" : true
}>
</#if>

<@import imports/>

public abstract class Base${entity.name?cap_first}ServiceImpl<D extends ${entity.name?cap_first}DTO<#if entity.multitenant> & Multitenant</#if>, E extends ${entity.name?cap_first}Entity<#if entity.multitenant> & Multitenant</#if>, ID>
<#if entity.multitenant>
  extends MultitenantServiceImpl
</#if>
  implements Base${entity.name?cap_first}Service<D, ID> {

  @Autowired
  private Base${entity.name?cap_first}Persistence<E, ID> base${entity.name?cap_first}Persistence;

  @Autowired
  protected ${entity.name?cap_first}Persistence ${entity.name}Persistence;

    @Override
  public D create (D dto) throws ServiceException
  {
  <#if entity.multitenant>
    if (!hasAccess(dto)) {
      throw new ServiceException("Access denied for creating ${entity.name}");
    }
    
  </#if>
    E entity = toEntity(dto);
    E saved = base${entity.name?cap_first}Persistence.save(entity);
    return toDto(saved);
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
  public List<D> findAll () throws ServiceException
  {
<#if entity.multitenant>
    List<E> entities = base${entity.name?cap_first}Persistence.findBy${tenantDiscriminator.name?cap_first}(tenantDiscriminator.get${tenantDiscriminator.name?cap_first}());
<#else>
    List<E> entities = base${entity.name?cap_first}Persistence.findAll();
</#if>
    return toDtos(entities);
  }
<#list inheritedAndOwnFinders(entity) as finder>
<@finder_preprocessor finder=finder/>

<#if finder.unique>
  @Override
  public D fetchBy${finderAttributes} (${finderParameters})
  {
	return toDto(base${entity.name?cap_first}Persistence.findFirstBy${finderAttributes}(${finderArguments}));
  }
<#else>
  @Override
  public List<D> ${finderName}${finderAttributes} (${finderParameters})
  {
	return toDtos(base${entity.name?cap_first}Persistence.${finderName}<#if entity.multitenant>${tenantDiscriminator.name?cap_first}And</#if>${finderAttributes}(<#if entity.multitenant>tenantDiscriminator.get${tenantDiscriminator.name?cap_first}(),</#if>${finderArguments}));
  }
</#if>
</#list>


  @Override
  public D get (ID id) throws ServiceException
  {
    Optional<E> optional = base${entity.name?cap_first}Persistence.findById(id);

<#if entity.multitenant>
    if (optional.isPresent()) {
      if (!hasAccess(optional.get())) {
		throw new ServiceException("Access denied for ${entity.name} with ${entity.key.name} = " + id);
	  }
	}
</#if>
    return optional.isEmpty() ? null : toDto(optional.get());
  }
  
  @Override
  public D update (D dto) throws ServiceException
  {
  <#if entity.multitenant>
    if (!hasAccess(dto)) {
      throw new ServiceException("Access denied for updating ${entity.name} with ${entity.key.name} = " + dto.get${entity.key.name?cap_first}());
    }
  </#if>
    E entity = toEntity(dto);
    E saved = base${entity.name?cap_first}Persistence.save(entity);
    return toDto(saved);
  }
  
  protected abstract E toEntity (D dto);
  protected abstract List<E> toEntities (List<D> dtos);

  protected abstract D toDto (E entity);
  protected abstract List<D> toDtos (List<E> entities);
}
