package ${multitenantPackage};

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaDelete;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;
import jakarta.transaction.Transactional;

import org.springframework.data.jpa.repository.support.JpaEntityInformation;
import org.springframework.data.jpa.repository.support.SimpleJpaRepository;
import org.springframework.data.repository.query.QueryCreationException;
import org.springframework.util.Assert;

import java.io.Serializable;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

@Transactional
public class MultitenantCrudRepositoryImpl<T, ID extends Serializable> extends SimpleJpaRepository<T, ID> implements MultitenantCrudRepository<T, ID> {

    @PersistenceContext
    private EntityManager entityManager;
    
    private TenantDiscriminator tenantDiscriminator;

    public MultitenantCrudRepositoryImpl(JpaEntityInformation<T, ?> entityInformation, EntityManager entityManager, TenantDiscriminator tenantDiscriminator) {
        super(entityInformation, entityManager);
        this.entityManager = entityManager;
        this.tenantDiscriminator = tenantDiscriminator;
    }

    private ${tenantDiscriminator.type.javaType} get${tenantDiscriminator.name?cap_first}() {
    	return tenantDiscriminator.get${tenantDiscriminator.name?cap_first}();
    }
    
    private void check${tenantDiscriminator.name?cap_first} (T entity) {
    	${tenantDiscriminator.type.javaType} ${tenantDiscriminator.name} = null;
        try {
            ${tenantDiscriminator.name} = (${tenantDiscriminator.type.javaType}) entity.getClass().getMethod("get${tenantDiscriminator.name?cap_first}").invoke(entity);
        } catch (Exception e) {
            throw new IllegalStateException("Entity must have a '${tenantDiscriminator.name}' field with a getter.", e);
        }
        if (${tenantDiscriminator.name} == null || !(${tenantDiscriminator.name} == get${tenantDiscriminator.name?cap_first}())) {
            throw new IllegalStateException("Cannot save or update an entity with a different ${tenantDiscriminator.name}.");
        }
    }

    @Override
    public <S extends T> S save(S entity) {
    	System.out.println("Saving entity: " + entity);
        check${tenantDiscriminator.name?cap_first}(entity);
        return entityManager.merge(entity);
    }

    @Override
    public Optional<T> findById(ID id) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<T> query = cb.createQuery(getDomainClass());
        Root<T> root = query.from(getDomainClass());

        query.select(root)
             .where(cb.and(
                 cb.equal(root.get("id"), id),
                 cb.equal(root.get("organizationId"), get${tenantDiscriminator.name?cap_first}())
             ));

        try {
            return Optional.of(entityManager.createQuery(query).getSingleResult());
        } catch (jakarta.persistence.NoResultException e) {
            return Optional.empty();
        }
    }

    @Override
    public List<T> findAll() {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<T> query = cb.createQuery(getDomainClass());
        Root<T> root = query.from(getDomainClass());

        query.select(root)
             .where(cb.equal(root.get("organizationId"), get${tenantDiscriminator.name?cap_first}()));

        return entityManager.createQuery(query).getResultList();
    }

    @Override
    public long count() {
    	class Local {};
        throw QueryCreationException.create("This method is not implemented. Use countByTenant() instead.",null, MultitenantCrudRepository.class, Local.class.getEnclosingMethod());
    }

    /*
    @Override
    public long countByTenant() {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Long> query = cb.createQuery(Long.class);
        Root<T> root = query.from(domainClass);

        query.select(cb.count(root))
             .where(cb.equal(root.get("${tenantDiscriminator.name}"), get${tenantDiscriminator.name?cap_first}()));

        return entityManager.createQuery(query).getSingleResult();
    }
    */

    @Override
    public void delete(T entity) {
        check${tenantDiscriminator.name?cap_first}(entity);
        entityManager.remove(entityManager.contains(entity) ? entity : entityManager.merge(entity));
    }

    @Override
    public boolean existsById(ID id) {
        return findById(id).isPresent();
    }

    @Override
    public <S extends T> List<S> saveAll(Iterable<S> entities) {
    	class Local {};
        throw QueryCreationException.create("This method is not implemented.", null, MultitenantCrudRepository.class, Local.class.getEnclosingMethod());
    }

    @Override
    public List<T> findAllById(Iterable<ID> ids) {
    	class Local {};
        throw QueryCreationException.create("This method is not implemented.", null, MultitenantCrudRepository.class, Local.class.getEnclosingMethod());
    }

    @Override
    public void deleteById(ID id) {
        findById(id).ifPresent(this::delete);
    }

    @Override
    public void deleteAll(Iterable<? extends T> entities) {
        entities.forEach(this::delete);
    }

    @Override
    public void deleteAll() {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaDelete<T> delete = cb.createCriteriaDelete(getDomainClass());
        Root<T> root = delete.from(getDomainClass());
        delete.where(cb.equal(root.get("${tenantDiscriminator.name}"), get${tenantDiscriminator.name?cap_first}()));
        entityManager.createQuery(delete).executeUpdate();
    }
    
    @Override
    public void deleteAllById(Iterable<? extends ID> ids) {
        if (ids == null) {
            return;
        }

        List<ID> idList = StreamSupport.stream(ids.spliterator(), false)
                                     .collect(Collectors.toList());

        if (idList.isEmpty()) {
            return;
        }

        // Find entities by their IDs AND the tenant ID to prevent cross-tenant deletion
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<T> query = cb.createQuery(getDomainClass());
        Root<T> root = query.from(getDomainClass());
        
        query.select(root)
             .where(cb.and(
                 root.get("id").in(idList),
                 cb.equal(root.get("${tenantDiscriminator.name}"), get${tenantDiscriminator.name?cap_first}())
             ));

        List<T> entitiesToDelete = entityManager.createQuery(query).getResultList();

        // Now, delete the entities that were found
        entitiesToDelete.forEach(this::delete);
    }
}
