<#include "/functions.ftl">
package ${serviceBasePackage};
<#assign imports +=  {
  servicePackage + ".ServiceException": true,
  "java.util.List": true
}>

<@import imports/>

public interface EntityService<D, ID> {
	
    public D create(D entity) throws ServiceException;

    public void delete(ID id) throws ServiceException;

    public List<D> findAll () throws ServiceException;
     
    public D get(ID id) throws ServiceException;

    public D update(D entity) throws ServiceException;
}