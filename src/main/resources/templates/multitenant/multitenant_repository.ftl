package ${multitenantPackage};

import java.io.Serializable;
import java.util.Optional;

import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.NoRepositoryBean;

@NoRepositoryBean
public interface MultitenantCrudRepository<T, ID extends Serializable> extends CrudRepository<T, ID> {
	// Overriding standard CrudRepository methods to ensure they are handled by our custom implementation.
    @Override
    <S extends T> S save(S entity);

    @Override
    Optional<T> findById(ID id);

    @Override
    Iterable<T> findAll();

    @Override
    void delete(T entity);
}
