package ${multitenantPackage};

import org.springframework.context.annotation.Configuration;

import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@Configuration
@EnableJpaRepositories(
	    basePackages = "${localRepositoryPackage}",
	    repositoryFactoryBeanClass = MultitenantRepositoryFactoryBean.class
	)
public class MultitenantConfig {

}
