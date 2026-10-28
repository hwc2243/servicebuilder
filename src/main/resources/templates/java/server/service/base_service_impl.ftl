<#include "/functions.ftl">
<#include "/java/server/finder/finder.ftl">
package ${serviceBasePackage};
<#assign imports += {
  "java.util.List": true,
  "java.util.Optional": true,
  "org.springframework.beans.factory.annotation.Autowired" : true,
  "org.springframework.transaction.annotation.Transactional" : true,
  dtoBasePackage + ".Base" + entity.name?cap_first + "DTO" : true,
  dtoPackage + "." + entity.name?cap_first + "DTO" : true,
  entityBasePackage + ".Base" + entity.name?cap_first + "Entity" : true,
  entityPackage + "." + entity.name?cap_first + "Entity" : true,
  persistencePackage + "." + entity.name?cap_first + "Persistence" : true,
  persistenceBasePackage + ".Base" + entity.name?cap_first + "Persistence" : true,
  servicePackage + ".ServiceException" : true,
  eventPackage + ".CrudOperation" : true,
  eventPackage + ".EntityCrudEvent" : true,
  eventPackage + ".ServiceEvent" : true,
  eventPackage + ".ServiceEventBus" : true
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
<#assign namedFinderRelateds = []>
<#assign namedFinderNames = []>
<#list inheritedAndOwnFinders(entity) as finder>
<#if finder.name?has_content>
<#assign finderRelated = inheritedRelated(entity, finder.finderAttributes?first.name)>
<#if !namedFinderNames?seq_contains(finder.name)>
<#assign namedFinderNames += [finder.name]>
<#assign namedFinderRelateds += [finderRelated]>
<#assign finderCollectionEntity = entityMap[finderRelated.entityName]>
<#assign imports += {
  dtoPackage + "." + finderCollectionEntity.name?cap_first + "DTO" : true,
  entityPackage + "." + finderCollectionEntity.name?cap_first + "Entity" : true,
  servicePackage + "." + finderCollectionEntity.name?cap_first + "Mapper" : true
}>
</#if>
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

  @Autowired(required = false)
  protected ServiceEventBus serviceEventBus;

<#list namedFinderRelateds as related>
  @Autowired
  protected ${related.entityName?cap_first}Mapper ${namedFinderNames[related_index]}Mapper;
</#list>

    @Override
  @Transactional
  public D create (D dto) throws ServiceException
  {
  <#if entity.multitenant>
    if (!hasAccess(dto)) {
      throw new ServiceException("Access denied for creating ${entity.name}");
    }
    
  </#if>
    E entity = toEntity(dto);
    E saved = base${entity.name?cap_first}Persistence.save(entity);
    D savedDto = toDto(saved);
    publishCrudEvent(CrudOperation.CREATED, savedDto);
    return savedDto;
  }
  
  @Override
  @Transactional
  public void delete (ID id) throws ServiceException
  {
    D deletedDto = serviceEventBus == null ? null : get(id);
  <#if entity.multitenant>
    try {
      get(id);
    } catch (ServiceException ex) {
      throw new ServiceException("Access denied for deleting ${entity.name} with ${entity.key.name} = " + id);
    }
    
  </#if>
    base${entity.name?cap_first}Persistence.deleteById(id);
    if (deletedDto != null) {
      publishCrudEvent(CrudOperation.DELETED, deletedDto);
    }
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

<#if finderCollectionRelated?has_content>
  @Override
  public List<D> ${finderName}${finderAttributes} (${finderServiceParameters})
  {
	return toDtos(base${entity.name?cap_first}Persistence.${finderName}${finderAttributes}(${finder.name}Mapper.toEntity(${finder.name})));
  }
<#elseif finder.unique>
  @Override
  public D fetchBy<#if entity.multitenant && finder.tenantScoped>${tenantDiscriminator.name?cap_first}And</#if>${finderAttributes} (${finderParameters})
  {
	return toDto(base${entity.name?cap_first}Persistence.findFirstBy<#if entity.multitenant && finder.tenantScoped>${tenantDiscriminator.name?cap_first}And</#if>${finderAttributes}(<#if entity.multitenant && finder.tenantScoped>tenantDiscriminator.get${tenantDiscriminator.name?cap_first}(),</#if>${finderArguments}));
  }
<#else>
  @Override
  public List<D> ${finderName}<#if entity.multitenant && finder.tenantScoped>${tenantDiscriminator.name?cap_first}And</#if>${finderAttributes} (${finderParameters})
  {
	return toDtos(base${entity.name?cap_first}Persistence.${finderName}<#if entity.multitenant && finder.tenantScoped>${tenantDiscriminator.name?cap_first}And</#if>${finderAttributes}(<#if entity.multitenant && finder.tenantScoped>tenantDiscriminator.get${tenantDiscriminator.name?cap_first}(),</#if>${finderArguments}));
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
  @Transactional
  public D update (D dto) throws ServiceException
  {
  <#if entity.multitenant>
    if (!hasAccess(dto)) {
      throw new ServiceException("Access denied for updating ${entity.name} with ${entity.key.name} = " + dto.get${entity.key.name?cap_first}());
    }
  </#if>
    E entity = toEntity(dto);
    E saved = base${entity.name?cap_first}Persistence.save(entity);
    D savedDto = toDto(saved);
    publishCrudEvent(CrudOperation.UPDATED, savedDto);
    return savedDto;
  }

  protected void publishEvent (ServiceEvent event)
  {
    if (serviceEventBus != null) {
      serviceEventBus.publish(event);
    }
  }

  protected void publishCrudEvent (CrudOperation operation, D dto)
  {
    if (dto != null) {
      publishEvent(new EntityCrudEvent<D>(operation, "${entity.name}", dto.get${entity.key.name?cap_first}(), dto));
    }
  }

  protected abstract E toEntity (D dto);
  protected abstract List<E> toEntities (List<D> dtos);

  protected abstract D toDto (E entity);
  protected abstract List<D> toDtos (List<E> entities);
}
