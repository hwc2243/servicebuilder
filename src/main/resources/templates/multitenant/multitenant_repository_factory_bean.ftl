package ${multitenantPackage};

import java.io.Serializable;

import org.springframework.beans.BeansException;

import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;

import org.springframework.data.jpa.repository.JpaRepository;

import org.springframework.data.jpa.repository.support.JpaRepositoryFactoryBean;
import org.springframework.data.repository.core.support.RepositoryFactorySupport;

import jakarta.persistence.EntityManager;

public class MultitenantRepositoryFactoryBean<R extends JpaRepository<T, ID>, T, ID extends Serializable>
		extends JpaRepositoryFactoryBean<R, T, ID> implements ApplicationContextAware{

	private ApplicationContext applicationContext;
	
	public MultitenantRepositoryFactoryBean(Class<? extends R> repositoryInterface) {
		super(repositoryInterface);
	}

	@Override
	protected RepositoryFactorySupport createRepositoryFactory(EntityManager entityManager) {
		TenantDiscriminator tenantDiscriminator = (TenantDiscriminator)applicationContext.getBean("tenantDiscriminator");
		if (tenantDiscriminator == null) {
		    throw new IllegalStateException("No bean named tenantDiscriminator defined.");
		}
		
		return new MultitenantRepositoryFactory(entityManager, tenantDiscriminator);
	}

	@Override
	public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
		this.applicationContext = applicationContext;
	}
}