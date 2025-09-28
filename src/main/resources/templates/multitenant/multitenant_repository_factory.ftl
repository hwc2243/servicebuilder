package ${multitenantPackage};

import org.springframework.data.jpa.repository.support.JpaEntityInformation;
import org.springframework.data.jpa.repository.support.JpaRepositoryFactory;

import org.springframework.data.repository.core.RepositoryMetadata;

import org.springframework.data.repository.core.support.RepositoryComposition.RepositoryFragments;
import org.springframework.data.repository.core.support.RepositoryFragment;

import jakarta.persistence.EntityManager;

public class MultitenantRepositoryFactory extends JpaRepositoryFactory {

    private final EntityManager entityManager;
    
    private final TenantDiscriminator tenantDiscriminator;

    public MultitenantRepositoryFactory(EntityManager entityManager, TenantDiscriminator tenantDiscriminator) {
        super(entityManager);
        this.entityManager = entityManager;
        this.tenantDiscriminator = tenantDiscriminator;
    }
    
    /**
     * This is the recommended way to add a custom implementation.
     * It appends our custom methods as a "fragment" to the repository.
     */
    @Override
    protected RepositoryFragments getRepositoryFragments(RepositoryMetadata metadata) {
        RepositoryFragments fragments = super.getRepositoryFragments(metadata);

        if (MultitenantCrudRepository.class.isAssignableFrom(metadata.getRepositoryInterface())) {
            // Get the JpaEntityInformation for the specific entity (e.g., Customer).
            JpaEntityInformation<?, ?> entityInformation = this.getEntityInformation(metadata.getDomainType());
            
            // Append our custom implementation as a fragment.
            fragments = fragments.append(RepositoryFragment.implemented(MultitenantCrudRepository.class, new MultitenantCrudRepositoryImpl(entityInformation, entityManager, tenantDiscriminator)));
        }

        return fragments;
    }
}