package com.github.hwc2243.servicebuilder.service;

import java.io.File;

import com.github.hwc2243.servicebuilder.model.Service;
import com.github.hwc2243.servicebuilder.model.Entity;
import com.github.hwc2243.servicebuilder.model.DataType;

import freemarker.template.Configuration;

public final class JavaLanguageBuilder extends BuilderServiceImpl implements LanguageBuilder {

	public JavaLanguageBuilder(Configuration freemarker, DefinitionReaderService definitionReaderService) {
		super(freemarker, definitionReaderService);
	}

	@Override
	public void build(GenerationContext context) throws BuildException {
		BuilderArgs args = context.getArgs();
		Service service = context.getService();
		java.util.Map<String, Object> model = context.getModel();
		File outputDir = context.getOutputDir();
		boolean buildClient = args.getBuildType() == BuilderArgs.BuildType.CLIENT;
		boolean buildServer = args.getBuildType() == BuilderArgs.BuildType.SERVER;
		boolean needPersistence = service.getEntities().stream().anyMatch(entity -> entity.isPersistence());
		boolean needInternalApi = service.getEntities().stream().anyMatch(entity -> entity.getApi() != null && entity.getApi().getInternal() != null);
		boolean needExternalApi = service.getEntities().stream().anyMatch(entity -> entity.getApi() != null && entity.getApi().getExternal() != null);
		
		String projectPackageName = service.getPackageName();
		File projectPackageDir = createPackageDir(outputDir, projectPackageName.replace(".", File.separator));
		logger.debug("Base package dir = {}", projectPackageDir.getAbsolutePath());

		if (buildServer) {
		// model package setup
		String modelPackageName = projectPackageName + ".model";
		model.put("modelPackage", modelPackageName);
		File modelPackageDir = createPackageDir(projectPackageDir, "model");
		String modelBasePackageName = modelPackageName + ".base";
		model.put("modelBasePackage", modelBasePackageName);
		File modelBasePackageDir = createPackageDir(modelPackageDir, "base");
		
		// entity package setup
		String entityPackageName = projectPackageName + ".entity";
		model.put("entityPackage", entityPackageName);
		File entityPackageDir = createPackageDir(projectPackageDir, "entity");
		String entityBasePackageName = entityPackageName + ".base";
		model.put("entityBasePackage", entityBasePackageName);
		File entityBasePackageDir = createPackageDir(entityPackageDir, "base");
		
		// persistence setup
		String persistencePackageName = projectPackageName + ".persistence";
		model.put("persistencePackage", persistencePackageName);
		File persistencePackageDir = createPackageDir(projectPackageDir, "persistence");
		String pesistenceBasePackageName = persistencePackageName + ".base";
		model.put("persistenceBasePackage", pesistenceBasePackageName);
		File persistenceBasePackageDir = createPackageDir(persistencePackageDir, "base");
		
		// dto setup
		String dtoPackageName = projectPackageName + ".dto";
		model.put("dtoPackage", dtoPackageName);
		File dtoPackageDir = createPackageDir(projectPackageDir, "dto");
		String dtoBasePackageName = dtoPackageName + ".base";
		model.put("dtoBasePackage", dtoBasePackageName);
		File dtoBasePackageDir = createPackageDir(dtoPackageDir, "base");

		// service setup
		String servicePackageName = projectPackageName + ".service";
		model.put("servicePackage", servicePackageName);
		File servicePackageDir = createPackageDir(projectPackageDir, "service");
		String serviceBasePackageName = servicePackageName + ".base";
		model.put("serviceBasePackage", serviceBasePackageName);
		File serviceBasePackageDir = createPackageDir(servicePackageDir, "base");
		String eventPackageName = servicePackageName + ".event";
		model.put("eventPackage", eventPackageName);
		File eventPackageDir = createPackageDir(servicePackageDir, "event");

		writeFile(args, model, "java/server/event/service_event.ftl", new File(eventPackageDir, "ServiceEvent.java"));
		writeFile(args, model, "java/server/event/crud_operation.ftl", new File(eventPackageDir, "CrudOperation.java"));
		writeFile(args, model, "java/server/event/entity_crud_event.ftl", new File(eventPackageDir, "EntityCrudEvent.java"));
		writeFile(args, model, "java/server/event/service_event_bus.ftl", new File(eventPackageDir, "ServiceEventBus.java"));
		writeFile(args, model, "java/server/event/spring_service_event_bus.ftl",
				new File(eventPackageDir, "SpringServiceEventBus.java"));

		// multitenant setup
		if (service.isMultitenant()) {
			model.put("tenantDiscriminator", service.getTenantDiscriminator());
			model.put("multitenantBaseModelPackage", modelBasePackageName);
			model.put("multitenantModelPackage", modelPackageName);
			model.put("multitenantBaseServicePackage", serviceBasePackageName);
			model.put("multitenantServicePackage", servicePackageName);
			
			File tenantDiscriminatorFile = new File(servicePackageDir, "TenantDiscriminator.java");
			if (!tenantDiscriminatorFile.exists() || args.isReplace()) {
				writeFile(args, model, "java/server/multitenant/tenant_discriminator.ftl", tenantDiscriminatorFile);
			}
			
			File multitenantFile = new File(modelBasePackageDir, "Multitenant.java");
			writeFile(args, model, "java/server/model/multitenant.ftl", multitenantFile);
			
			File multitenantServiceFile = new File(serviceBasePackageDir, "MultitenantServiceImpl.java");
			writeFile(args, model, "java/server/multitenant/multitenant_service_impl.ftl", multitenantServiceFile);
		}

		writeFile(args, model, "java/server/entity/abstract_base_entity.ftl", new File(entityBasePackageDir, "AbstractBaseEntity.java"));
		writeFile(args, model, "java/server/service/service_exception.ftl", new File(servicePackageDir, "ServiceException.java"));
		writeFile(args, model, "java/server/service/base_entity_service.ftl", new File(serviceBasePackageDir, "EntityService.java"));

		// api setup
		String apiPackageName = projectPackageName + ".api";
		final File apiPackageDir = (needInternalApi || needExternalApi)
				? createPackageDir(projectPackageDir, "api")
				: null;

		final File internalApiPackageDir = needInternalApi
				? createPackageDir(apiPackageDir, "internal")
				: null;
		final File baseInternalApiPackageDir = needInternalApi
				? createPackageDir(internalApiPackageDir, "base")
				: null;
		if (needInternalApi) {
			String internalApiPackageName = apiPackageName + ".internal";
			model.put("internalApiPackage", internalApiPackageName);
			model.put("baseInternalApiPackage", internalApiPackageName + ".base");
		}

		final File externalApiPackageDir = needExternalApi
				? createPackageDir(apiPackageDir, "external")
				: null;
		final File baseExternalApiPackageDir = needExternalApi
				? createPackageDir(externalApiPackageDir, "base")
				: null;
		if (needExternalApi) {
			String externalApiPackageName = apiPackageName + ".external";
			model.put("externalApiPackage", externalApiPackageName);
			model.put("baseExternalApiPackage", externalApiPackageName + ".base");
		}

		service.getEntities().stream().forEach(entity -> {
			// write the models
			writeBaseModel(args, model, entity, modelBasePackageDir);
			writeExtensionModel(args, model, entity, modelPackageDir);
			entity.getAttributes().stream()
			    .filter(attribute -> DataType.ENUM == attribute.getType())
			    .forEach(attribute -> {
				  writeEnum(args, model, entity, attribute, modelPackageDir);
			    });
			
			// write the entities
			writeBaseEntity(args, model, entity, entityBasePackageDir);
			writeExtensionEntity(args, model, entity, entityPackageDir);
			
			// write the dtos
			writeBaseDTO(args, model, entity, dtoBasePackageDir);
			writeExtensionDTO(args, model, entity, dtoPackageDir);
			
			if (!entity.isAbstractEntity()) {
				// write the persistence
				writeBasePersistence(args, model, entity, persistenceBasePackageDir);
				writeExtensionPersistence(args, model, entity, persistencePackageDir);

				// write the services
				writeBaseService(args, model, entity, serviceBasePackageDir);
				writeExtensionService(args, model, entity, servicePackageDir);
			}
			
			if (needInternalApi) {
				if (entity.getApi() != null) {
					if (entity.getApi().getInternal() != null) {
						writeApiBaseInternal(args, model, entity, baseInternalApiPackageDir);
						writeApiInternal(args, model, entity, internalApiPackageDir);
					}
				}
			}

			if (needExternalApi) {
				if (entity.getApi() != null) {
					if (entity.getApi().getExternal() != null) {
						writeApiBaseExternal(args, model, entity, baseExternalApiPackageDir);
						writeApiExternal(args, model, entity, externalApiPackageDir);
					}
				}
			}
		});
		}

		if (buildClient) {
		// client package setup
		File clientPackageDir = null;
		String clientPackageName = projectPackageName + ".client";
		model.put("clientPackage", clientPackageName);
		clientPackageDir = createPackageDir(projectPackageDir, "client");

		// if we are building client code, write the models and rest services
		{
			String clientModelPackageName = clientPackageName + ".model";
			model.put("clientModelPackage", clientModelPackageName);
			File clientModelDir = createPackageDir(clientPackageDir, "model");

			String clientBaseModelPackageName = clientModelPackageName + ".base";
			model.put("clientBaseModelPackage", clientBaseModelPackageName);
			File clientBaseModelDir = createPackageDir(clientModelDir, "base");

			String clientRestPackageName = clientPackageName + ".rest";
			model.put("clientRestPackage", clientRestPackageName);
			File clientRestDir = createPackageDir(clientPackageDir, "rest");

			String clientBaseRestPackageName = clientRestPackageName + ".base";
			model.put("clientBaseRestPackage", clientBaseRestPackageName);
			File clientBaseRestDir = createPackageDir(clientRestDir, "base");

			String clientRepositoryPackageName = clientPackageName + ".repository";
			model.put("clientRepositoryPackage", clientRepositoryPackageName);
			File clientRepositoryDir = createPackageDir(clientPackageDir, "repository");

			String clientBaseRepositoryPackageName = clientRepositoryPackageName + ".base";
			model.put("clientBaseRepositoryPackage", clientBaseRepositoryPackageName);
			File clientBaseRepositoryDir = createPackageDir(clientRepositoryDir, "base");

			String clientServicePackageName = clientPackageName + ".service";
			model.put("clientServicePackage", clientServicePackageName);
			File clientServiceDir = createPackageDir(clientPackageDir, "service");

			String clientBaseServicePackageName = clientServicePackageName + ".base";
			model.put("clientBaseServicePackage", clientBaseServicePackageName);
			File clientBaseServiceDir = createPackageDir(clientServiceDir, "base");
			writeFile(args, model, "/java/client/abstract_client_base_entity.ftl",
					new File(clientBaseModelDir, "AbstractBaseEntity.java"));
			writeFile(args, model, "/java/client/abstract_client_base_rest.ftl",
					new File(clientBaseRestDir, "AbstractRestClient.java"));
				writeFile(args, model, "java/client/client_service_exception.ftl",
					new File(clientServiceDir, "ServiceException.java"));
				writeFile(args, model, "java/client/client_entity_service.ftl",
					new File(clientBaseServiceDir, "EntityService.java"));

			service.getEntities().stream().forEach(entity -> {
				writeClientBaseEntity(args, model, entity, clientBaseModelDir);
				writeClientEntity(args, model, entity, clientModelDir);
				writeClientBaseRest(args, model, entity, clientBaseRestDir);
				writeClientRest(args, model, entity, clientRestDir);
				if (entity.isPersistence()) {
					writeClientBaseRepository(args, model, entity, clientBaseRepositoryDir);
					writeClientRepository(args, model, entity, clientRepositoryDir);
				}
				writeClientBaseService(args, model, entity, clientBaseServiceDir);
				writeClientService(args, model, entity, clientServiceDir);
			});

			if (service.isMultitenant()) {

				File multitenantFile = new File(clientBaseModelDir, "Multitenant.java");
					writeFile(args, model, "java/server/multitenant/multitenant.ftl", multitenantFile);

				File tenantDiscriminatorFile = new File(clientRestDir, "TenantDiscriminator.java");
				if (!tenantDiscriminatorFile.exists() || args.isReplace()) {
					writeFile(args, model, "java/server/multitenant/tenant_discriminator.ftl", tenantDiscriminatorFile);
				}

				File multitenantClientFile = new File(clientBaseRestDir, "MultitenantRestClient.java");
					writeFile(args, model, "java/server/multitenant/multitenant_client_impl.ftl", multitenantClientFile);

				File headerProviderFile = new File(clientBaseRestDir, "HeaderProvider.java");
				if (!headerProviderFile.exists() || args.isReplace()) {
					writeFile(args, model, "java/client/header_provider.ftl", headerProviderFile);
				}

				model.put("multitenantBaseServicePackage", clientBaseServicePackageName);
				File multitenantServiceFile = new File(clientBaseServiceDir, "MultitenantServiceImpl.java");
					writeFile(args, model, "java/server/multitenant/multitenant_service_impl.ftl", multitenantServiceFile);
			}
		}
		}
	}
}

