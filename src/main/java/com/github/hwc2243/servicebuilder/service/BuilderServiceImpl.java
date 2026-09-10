package com.github.hwc2243.servicebuilder.service;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

import com.github.hwc2243.servicebuilder.ServiceBuilderApplication;
import com.github.hwc2243.servicebuilder.model.Attribute;
import com.github.hwc2243.servicebuilder.model.DataType;
import com.github.hwc2243.servicebuilder.model.Entity;
import com.github.hwc2243.servicebuilder.model.Finder;
import com.github.hwc2243.servicebuilder.model.FinderAttribute;
import com.github.hwc2243.servicebuilder.model.Key;
import com.github.hwc2243.servicebuilder.model.KeyType;
import com.github.hwc2243.servicebuilder.model.Related;
import com.github.hwc2243.servicebuilder.model.RelationshipType;
import com.github.hwc2243.servicebuilder.model.Service;
import com.github.hwc2243.servicebuilder.model.TenantDiscriminator;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import freemarker.template.TemplateExceptionHandler;
import freemarker.template.Version;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import javax.xml.XMLConstants;
import javax.xml.validation.SchemaFactory;

public class BuilderServiceImpl implements BuilderService {

	protected static Logger logger = LoggerFactory.getLogger(BuilderServiceImpl.class);

	protected Configuration freemarker;

	protected DefinitionReaderService definitionReaderService;

	public BuilderServiceImpl() throws SAXException {
		this(new DefinitionReaderServiceImpl());
	}
	
	public BuilderServiceImpl (DefinitionReaderService definitionReaderService) {
		this(initFreemarker(), definitionReaderService);
	}

	public BuilderServiceImpl(Configuration freemarker, DefinitionReaderService definitionReaderService) {
		this.freemarker = freemarker;
		this.definitionReaderService = definitionReaderService;
	}

	protected static Configuration initFreemarker () {
		Configuration freemarker = new Configuration(new Version(2, 3, 20));
		freemarker.setClassForTemplateLoading(ServiceBuilderApplication.class, "/templates");
		freemarker.setDefaultEncoding("UTF-8");
		freemarker.setLocale(Locale.US);
		freemarker.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
		
		return freemarker;
	}
	
	@Override
	public void build(BuilderArgs args) throws BuildException {
		File file = new File(args.getServiceFile());

		build(file, args);
	}

	@Override
	public void build(File file, BuilderArgs args) throws BuildException {
		if (!file.exists()) {
			throw new BuildException(new FileNotFoundException(args.getServiceFile() + " not found"));
		}

		try {
			Service service = definitionReaderService.read(file);
			build(service, args);
		} catch (SAXException ex) {
			throw new BuildException(new IOException("Failed to parse service file", ex));
		} catch (IOException ex) {
			throw new BuildException(ex);
		}

	}

	@Override
	public void build (Service service, BuilderArgs args) throws BuildException {
		boolean needPersistence = false;
		boolean needInternalApi = false;
		boolean needExternalApi = false;
		for (Entity entity : service.getEntities()) {
			if (entity.isPersistence()) {
				needPersistence = true;
			}
			if (entity.getApi() != null) {
				if (entity.getApi().getInternal() != null) {
					needInternalApi = true;
				}
				if (entity.getApi().getExternal() != null) {
					needExternalApi = true;
				}
			}
		}

		Map<String, Object> model = new HashMap<>();
		model.put("jpaPackage", args.getJpaPackage());

		Map<String, Entity> entityMap = buildEntityMap(service);
		validateService(service, entityMap);
		postProcess(entityMap);

		model.put("entityMap", entityMap);
		Map<String, List<Entity>> referencedEntitiesMap = buildReferencedEntitiesMap(entityMap);
		model.put("referencedEntitiesMap", referencedEntitiesMap);

		File outputDir = new File(args.getOutputDir());
		logger.debug("Outdir = {}", outputDir.getAbsolutePath());
		if (outputDir.exists() && args.isClean()) {
			try {
				Files.walk(outputDir.toPath()).sorted(Comparator.reverseOrder()).map(Path::toFile)
						.forEach(File::delete);
			} catch (IOException ex) {
				throw new BuildException(ex);
			}
		}
		if (!outputDir.exists()) {
			outputDir.mkdirs();
		}

		String projectPackageName = service.getPackageName();
		File projectPackageDir = createPackageDir(outputDir, projectPackageName.replace(".", File.separator));
		logger.debug("Base package dir = {}", projectPackageDir.getAbsolutePath());

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

		// multitenant setup
		if (service.isMultitenant()) {
			model.put("tenantDiscriminator", service.getTenantDiscriminator());
			model.put("multitenantBaseModelPackage", modelBasePackageName);
			model.put("multitenantModelPackage", modelPackageName);
			model.put("multitenantBaseServicePackage", serviceBasePackageName);
			model.put("multitenantServicePackage", servicePackageName);
			
			File tenantDiscriminatorFile = new File(servicePackageDir, "TenantDiscriminator.java");
			if (!tenantDiscriminatorFile.exists() || args.isReplace()) {
				writeFile(args, model, "java/multitenant/tenant_discriminator.ftl", tenantDiscriminatorFile);
			}
			
			File multitenantFile = new File(modelBasePackageDir, "Multitenant.java");
			writeFile(args, model, "java/model/multitenant.ftl", multitenantFile);
			
			File multitenantServiceFile = new File(serviceBasePackageDir, "MultitenantServiceImpl.java");
			writeFile(args, model, "java/multitenant/multitenant_service_impl.ftl", multitenantServiceFile);
		}

		writeFile(args, model, "java/entity/abstract_base_entity.ftl", new File(entityBasePackageDir, "AbstractBaseEntity.java"));
		writeFile(args, model, "java/service/service_exception.ftl", new File(servicePackageDir, "ServiceException.java"));
		writeFile(args, model, "java/service/base_entity_service.ftl", new File(serviceBasePackageDir, "EntityService.java"));

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
			
		});	
		
		/*

		// if we are building client code
		File clientPackageDir = null;
		String clientPackageName = projectPackageName + ".client";
		if (args.getBuildType().contains(BuilderArgs.BuildType.ALL)
				|| args.getBuildType().contains(BuilderArgs.BuildType.CLIENT)) {
			model.put("clientPackage", clientPackageName);
			clientPackageDir = createPackageDir(projectPackageDir, "client");
		}

		// write the repositories
		if (needPersistence && (args.getBuildType().contains(BuilderArgs.BuildType.ALL)
				|| args.getBuildType().contains(BuilderArgs.BuildType.SERVICE))) {
			

			// write the services

			try {
				if (service.isMultitenant()) {
					

				}
			} catch (Exception ex) {
				ex.printStackTrace();
			}

			service.getEntities().stream().forEach(entity -> {
				if (entity.isPersistence()) {
					writeBaseService(args, model, entity, baseServiceDir);
					writeLocalService(args, model, entity, localServiceDir);
				}
			});

			if (needInternalApi || needExternalApi) {
				// write the rest packages
				String apiPackageName = projectPackageName + ".api";
				File apiPackageDir = createPackageDir(projectPackageDir, "api");

				if (needInternalApi) {
					String internalApiPackageName = apiPackageName + ".internal";
					model.put("internalApiPackage", internalApiPackageName);
					File internalApiPackageDir = createPackageDir(apiPackageDir, "internal");

					String baseInternalApiPackageName = internalApiPackageName + ".base";
					model.put("baseInternalApiPackage", baseInternalApiPackageName);
					File baseInternalApiPackageDir = createPackageDir(internalApiPackageDir, "base");

					service.getEntities().stream().forEach(entity -> {
						if (entity.getApi() != null) {
							if (entity.getApi().getInternal() != null) {
								writeApiBaseInternal(args, model, entity, baseInternalApiPackageDir);
								writeApiInternal(args, model, entity, internalApiPackageDir);
							}
						}
					});
				}

				if (needExternalApi) {
					String externalApiPackageName = apiPackageName + ".external";
					model.put("externalApiPackage", externalApiPackageName);
					File externalApiPackageDir = createPackageDir(apiPackageDir, "external");

					String baseExternalApiPackage = externalApiPackageName + ".base";
					model.put("baseExternalApiPackage", baseExternalApiPackage);
					File baseExternalApiPackageDir = createPackageDir(externalApiPackageDir, "base");

					service.getEntities().stream().forEach(entity -> {
						if (entity.getApi() != null) {
							if (entity.getApi().getInternal() != null) {
								writeApiBaseExternal(args, model, entity, baseExternalApiPackageDir);
								writeApiExternal(args, model, entity, externalApiPackageDir);
							}
						}
					});
				}
			}
		}

		// if we are building client code, write the models and rest services
		if (args.getBuildType().contains(BuilderArgs.BuildType.ALL)
				|| args.getBuildType().contains(BuilderArgs.BuildType.CLIENT)) {
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
			writeFile(args, model, "/client/abstract_client_base_entity.ftl",
					new File(clientBaseModelDir, "AbstractBaseEntity.java"));
			writeFile(args, model, "/client/abstract_client_base_rest.ftl",
					new File(clientBaseRestDir, "AbstractRestClient.java"));
			writeFile(args, model, "client/client_service_exception.ftl",
					new File(clientServiceDir, "ServiceException.java"));
			writeFile(args, model, "client/client_entity_service.ftl",
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
				writeFile(args, model, "multitenant/multitenant.ftl", multitenantFile);

				File tenantDiscriminatorFile = new File(clientRestDir, "TenantDiscriminator.java");
				if (!tenantDiscriminatorFile.exists() || args.isReplace()) {
					writeFile(args, model, "multitenant/tenant_discriminator.ftl", tenantDiscriminatorFile);
				}

				File multitenantClientFile = new File(clientBaseRestDir, "MultitenantRestClient.java");
				writeFile(args, model, "multitenant/multitenant_client_impl.ftl", multitenantClientFile);

				File headerProviderFile = new File(clientBaseRestDir, "HeaderProvider.java");
				if (!headerProviderFile.exists() || args.isReplace()) {
					writeFile(args, model, "client/header_provider.ftl", headerProviderFile);
				}

				model.put("multitenantBaseServicePackage", clientBaseServicePackageName);
				File multitenantServiceFile = new File(clientBaseServiceDir, "MultitenantServiceImpl.java");
				writeFile(args, model, "multitenant/multitenant_service_impl.ftl", multitenantServiceFile);
			}
		}
		*/
	}

	protected Map<String, Entity> buildEntityMap(Service service) {
		return service.getEntities().stream().collect(Collectors.toMap(Entity::getName, Function.identity()));
	}

	protected Map<String, List<Entity>> buildReferencedEntitiesMap(Map<String, Entity> entityMap) {
		Map<String, List<Entity>> referencedEntitiesMap = new HashMap<>();

		entityMap.values().stream().forEach(entity -> {
			logger.info("entity {} - attribute = {}", entity.getName(), entity.getAttributes());

			try {
				List<Entity> referencedEntities = entity.getRelateds().stream().map(related -> {
					String relatedEntityName = related.getEntityName();
					if (StringUtils.isBlank(relatedEntityName)) {
						throw new IllegalStateException(
								"Related entity name cannot be blank for entity: " + entity.getName());
					}

					Entity relatedEntity = entityMap.get(relatedEntityName);
					if (relatedEntity == null) {
						throw new IllegalArgumentException(
								"Related entity '" + relatedEntityName + "' not found for entity: " + entity.getName());
					}
					return relatedEntity;
				}).collect(Collectors.toList());

				logger.info("{} referencedEntities = {}", entity.getName(), referencedEntities);
				referencedEntitiesMap.put(entity.getName(), referencedEntities);

			} catch (Exception ex) {
				logger.error("Error building referenced entities for {}: {}", entity.getName(), ex.getMessage());
				throw ex; // Re-throw the exception to propagate the error
			}
		});

		/*
		 * entityMap.values().stream().forEach(entity -> {
		 * logger.info("entity {} - attribute = {}", entity.getName(),
		 * entity.getAttributes()); List<Entity> referencedEntities =
		 * entity.getRelateds().stream() .filter(related ->
		 * StringUtils.isNotBlank(related.getEntityName())).map(related -> { return
		 * entityMap.get(related.getEntityName()); }).collect(Collectors.toList());
		 * 
		 * logger.info("{} referencedEntities = {}", entity.getName(),
		 * referencedEntities);
		 * 
		 * referencedEntitiesMap.put(entity.getName(), referencedEntities); });
		 */

		return referencedEntitiesMap;
	}

	protected File createPackageDir(File baseDir, String packageName) {
		File packageDir = new File(baseDir, packageName);
		if (!packageDir.exists()) {
			packageDir.mkdirs();
		}
		return packageDir;
	}

	protected void dumpEntityMap(Map<String, Entity> entityMap) {
		entityMap.values().stream().forEach(entity -> {
			logger.info("{}", entity.getName());
		});
	}

	protected void postProcess(Map<String, Entity> entityMap) {
		for (Entity entity : entityMap.values()) {
			logger.info("processing {}", entity.getName());
			for (Related related : entity.getRelateds()) {
				logger.info("  name: {}, type: {}, entity: {}", related.getName(), related.getRelationshipType(),
						related.getEntityName());
				Entity targetEntity = null;

				switch (related.getRelationshipType()) {

				case ONE_TO_ONE:
					if (related.isBidirectional()) {
						targetEntity = entityMap.get(related.getEntityName());
						boolean found = false;
						for (Related targetRelationship : targetEntity.getRelateds()) {
							if (targetRelationship.getEntityName().equals(entity.getName())) {
								found = true;
							}
						}
						if (!found) {
							logger.info("  setting {} as owner", related.getName());
							related.setOwner(true);

							Related targetRelationship = new Related();
							targetRelationship.setName(entity.getName());
							targetRelationship.setEntityName(entity.getName());
							targetRelationship.setRelationshipType(RelationshipType.ONE_TO_ONE);
							targetRelationship.setBidirectional(true);
							targetEntity.addRelated(targetRelationship);
							logger.info("  adding {} to {}", targetRelationship.getName(), targetEntity.getName());
						}
					}
					break;

				case ONE_TO_MANY:
					if (related.isBidirectional()) {
						targetEntity = entityMap.get(related.getEntityName());

						Related targetRelationship = new Related();
						targetRelationship.setName(entity.getName());
						targetRelationship.setEntityName(entity.getName());
						targetRelationship.setRelationshipType(RelationshipType.MANY_TO_ONE);
						targetEntity.addRelated(targetRelationship);
						logger.info("  adding {} to {}", targetRelationship.getName(), targetEntity.getName());
					}
					break;

				case MANY_TO_MANY:
					logger.info("  MANY_TO_MANY");
					logger.info("    relationship {} target {}", related.getName(), related.getEntityName());
					if (StringUtils.isNotBlank(related.getMappedBy())) {
						targetEntity = entityMap.get(related.getEntityName());
						Related targetRelationship = targetEntity.getRelated(related.getMappedBy());
						targetRelationship.setOwner(true);
					} else {
						related.setOwner(true);
					}
					break;
				}
			}
		}
	}

	protected void validateEntityMap(Map<String, Entity> entityMap) throws BuildException {
	}

	protected void validateAttributes(Entity entity, TenantDiscriminator tenantDiscriminator) throws BuildException {
		for (Attribute attribute : entity.getAttributes()) {
			// ensure enum attributes are properly defined
			if (DataType.ENUM == attribute.getType()) {
				if (attribute.getEnumClass() != null && attribute.getEnumValues() != null) {
					throw new BuildException(
							String.format("Attribute %s on %s cannot have both enumClass and enumValues defined.",
									attribute.getName(), entity.getName()));
				}
				if (attribute.getEnumClass() == null && attribute.getEnumValues() == null) {
					throw new BuildException(
							String.format("Attribute %s on %s must have either enumClass or enumValues defined.",
									attribute.getName(), entity.getName()));
				}
				if (attribute.getEnumValues() != null && attribute.getEnumValues().isEmpty()) {
					throw new BuildException(String.format("Attribute %s on %s has an empty enumValues list.",
							attribute.getName(), entity.getName()));
				}
			}
		}

		// if the entity is multitenant ensure the tenant-discriminator attribute exists
		if (entity.isMultitenant() && tenantDiscriminator != null) {
			Attribute attribute = entity.getAttribute(tenantDiscriminator.getName());
			if (attribute == null) {
				attribute = new Attribute();
				attribute.setName(tenantDiscriminator.getName());
				attribute.setType(tenantDiscriminator.getType());
				attribute.setIndexed(true);
				entity.addAttribute(attribute);
			} else {
				if (attribute.getType() != tenantDiscriminator.getType()) {
					throw new BuildException(String.format(
							"Entity %s is multitenant but tenant-discriminator attribute %s has type %s instead of %s.",
							entity.getName(), attribute.getName(), attribute.getType(), tenantDiscriminator.getType()));
				}
				attribute.setIndexed(true);
			}
		}
	}

	protected void validateEntity(Entity entity) throws BuildException {
		if (entity.getKey() == null) {
			if (entity.getAttribute("id") != null) {
				throw new BuildException(String.format(
						"Entity %s can not auto generate a key because an attribute with the name 'id' already exists.",
						entity.getName()));
			}
			Key key = Key.builder().name("id").type(KeyType.LONG).build();
			entity.setKey(key);
		}

	}

	protected void validateFinders(Entity entity, Map<String, Entity> entityMap) throws BuildException {
		for (Finder finder : entity.getFinders()) {
			for (FinderAttribute attribute : finder.getFinderAttributes()) {
				Related related = findRelated(entity, attribute.getName(), entityMap);
				if (findAttribute(entity, attribute.getName(), entityMap) == null && related == null) {
					throw new BuildException(String.format("Finder %s on %s is invalid, %s is not an attribute.",
							"findBy" + finder.buildFinderColumnNames(), entity.getName(), attribute.getName()));
				} else if (related != null && related.getRelationshipType() != RelationshipType.MANY_TO_ONE
						&& related.getRelationshipType() != RelationshipType.ONE_TO_ONE) {
					throw new BuildException(String.format(
							"Finder %s on %s is invalid, %s must be a scalar, many-to-one, or one-to-one attribute.",
							"findBy" + finder.buildFinderColumnNames(), entity.getName(), attribute.getName()));
				}
			}
		}
	}

	protected Attribute findAttribute(Entity entity, String name, Map<String, Entity> entityMap) {
		Entity current = entity;
		while (current != null) {
			Attribute attribute = current.getAttribute(name);
			if (attribute != null) {
				return attribute;
			}
			current = StringUtils.isBlank(current.getParent()) ? null : entityMap.get(current.getParent());
		}
		return null;
	}

	protected Related findRelated(Entity entity, String name, Map<String, Entity> entityMap) {
		Entity current = entity;
		while (current != null) {
			Related related = current.getRelated(name);
			if (related != null) {
				return related;
			}
			current = StringUtils.isBlank(current.getParent()) ? null : entityMap.get(current.getParent());
		}
		return null;
	}

	protected void validateRelated(Entity entity, Map<String, Entity> entityMap) throws BuildException {
		if (entity.getRelateds() != null) {
			logger.info("Validating related for entity: " + entity.getName());
		}
		for (Related related : entity.getRelateds()) {
			if (StringUtils.isBlank(related.getEntityName())) {
				throw new BuildException("Related entity name cannot be blank for entity: " + entity.getName());
			}

			Entity relatedEntity = entityMap.get(related.getEntityName());
			if (relatedEntity == null) {
				throw new BuildException(
						"Related entity '" + related.getEntityName() + "' not found for entity: " + entity.getName());
			}

			if (related.getRelationshipType() == null) {
				throw new BuildException("Related entity '" + related.getEntityName()
						+ "' must have a relationship type defined for entity: " + entity.getName());
			} else if (related.getRelationshipType() == RelationshipType.MANY_TO_MANY) {
				Related relatedEntityRelated = relatedEntity.getRelated(entity.getName() + "s");
				if (relatedEntityRelated == null) {
					// if there is no relatedEntity related definition assume this unidirectional
					related.setBidirectional(false);
				} else if (relatedEntityRelated.getRelationshipType() != RelationshipType.MANY_TO_MANY) {
					throw new BuildException("Related entity '" + related.getEntityName()
							+ "' has an invalid relationship type for entity: " + entity.getName());
				} else if (!(StringUtils.isEmpty(related.getMappedBy())
						^ StringUtils.isEmpty(relatedEntityRelated.getMappedBy()))) {
					throw new BuildException("Related entities '" + entity.getName() + "'.'" + related.getName()
							+ "' and '" + relatedEntity.getName() + "'.'" + relatedEntityRelated.getName()
							+ "' must have one and only one side as the mapped-by for MANY_TO_MANY relationship");
				} else if (!StringUtils.isEmpty(related.getMappedBy())
						&& !related.getMappedBy().equals(relatedEntityRelated.getName())) {
					throw new BuildException("Related entity '" + related.getEntityName()
							+ "' does not have the mapped-by name: " + related.getMappedBy() + " specified by '"
							+ entity.getName() + "'.'" + related.getName() + "'");
				}
				related.setBidirectional(true);
			} else if (related.getRelationshipType() == RelationshipType.ONE_TO_MANY) {
			} else if (related.getRelationshipType() == RelationshipType.MANY_TO_ONE) {
			} else if (related.getRelationshipType() == RelationshipType.ONE_TO_ONE) {
			} else {
				throw new BuildException("Related entity '" + related.getEntityName()
						+ "' has an invalid relationship type for entity: " + entity.getName());
			}
		}
	}

	protected void validateService(Service service, Map<String, Entity> entityMap) throws BuildException {
		if (StringUtils.isBlank(service.getPackageName())) {
			throw new BuildException("Service package name cannot be blank");
		}
		if (service.getEntities() == null || service.getEntities().isEmpty()) {
			throw new BuildException("Service must have at least one entity defined");
		}
		if (service.isMultitenant() && service.getTenantDiscriminator() == null) {
			throw new BuildException("Service is multitenant but no tenant-discriminator defined");
		} else if (!service.isMultitenant() && service.getTenantDiscriminator() != null) {
			throw new BuildException("Service is not multitenant but tenant-discriminator defined");
		}

		for (Entity entity : entityMap.values()) {
			logger.info("Validating entity: " + entity.getName());
			validateAttributes(entity, service.getTenantDiscriminator());
			validateFinders(entity, entityMap);
			validateRelated(entity, entityMap);
			validateEntity(entity);
		}

		validateEntityMap(entityMap);
	}

	protected void writeEnum (BuilderArgs args, Map<String, Object> baseModel, Entity entity, Attribute attribute,
			File outputDir) throws BuildException {
		if (StringUtils.isBlank(attribute.getEnumClass())) {
			String enumName = StringUtils.capitalize(entity.getName()) + StringUtils.capitalize(attribute.getName()) + ".java";
			File enumFile = new File(outputDir, enumName);

			if (!enumFile.exists() || args.isReplace()) {
				Map<String, Object> enumModel = new HashMap<>(baseModel);
				enumModel.put("entity", entity);
				enumModel.put("attribute", attribute);
			
				writeFile(args, enumModel, "java/model/enum.ftl", enumFile);
			}
		}
	}


	protected void writeBaseModel (BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) throws BuildException {
		String className = "Base" + StringUtils.capitalize(entity.getName()) + ".java";
		File classFile = new File(outputDir, className);
			
		Map<String, Object> entityModel = new HashMap<>(baseModel);
		entityModel.put("entity", entity);

		writeFile(args, entityModel, "java/model/base_model.ftl", classFile);
	}
	
	protected void writeExtensionModel (BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) throws BuildException {
		String className = StringUtils.capitalize(entity.getName()) + ".java";
		File classFile = new File(outputDir, className);
			
		if (!classFile.exists() || args.isReplace()) {
			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);
			
			writeFile(args, entityModel, "java/model/model.ftl", classFile);
		} 
	}
	
	protected void writeBaseEntity(BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) throws BuildException {
		String className = "Base" + StringUtils.capitalize(entity.getName()) + "Entity.java";
		File classFile = new File(outputDir, className);
		
		Map<String, Object> entityModel = new HashMap<>(baseModel);
		entityModel.put("entity", entity);

		writeFile(args, entityModel, "java/entity/base_entity.ftl", classFile);
	}
	
	protected void writeExtensionEntity(BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) {
		try {
			String className = StringUtils.capitalize(entity.getName()) + "Entity.java";
			File classFile = new File(outputDir, className);

			if (!classFile.exists() || args.isReplace()) {
				Map<String, Object> entityModel = new HashMap<>(baseModel);
				entityModel.put("entity", entity);

				writeFile(args, entityModel, "java/entity/entity.ftl", classFile);
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}

	}

	protected void writeBasePersistence (BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) {
		try {
			String className = "Base" + StringUtils.capitalize(entity.getName()) + "Persistence.java";
			File classFile = new File(outputDir, className);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			writeFile(args, entityModel, "java/persistence/base_persistence.ftl", classFile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
	
	protected void writeExtensionPersistence (BuilderArgs args, Map<String, Object> baseModel, Entity entity,
			File outputDir) {
		try {
			String className = StringUtils.capitalize(entity.getName()) + "Persistence.java";
			File classFile = new File(outputDir, className);

			if (!classFile.exists() || args.isReplace()) {
				Map<String, Object> entityModel = new HashMap<>(baseModel);
				entityModel.put("entity", entity);

				writeFile(args, entityModel, "java/persistence/persistence.ftl", classFile);
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	protected void writeBaseDTO (BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir)
			throws BuildException {
		String className = "Base" + StringUtils.capitalize(entity.getName()) + "DTO.java";
		File classFile = new File(outputDir, className);

		Map<String, Object> entityModel = new HashMap<>(baseModel);
		entityModel.put("entity", entity);

		writeFile(args, entityModel, "java/dto/base_dto.ftl", classFile);
	}

	protected void writeExtensionDTO (BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir)
			throws BuildException {
		String className = StringUtils.capitalize(entity.getName()) + "DTO.java";
		File classFile = new File(outputDir, className);

		if (!classFile.exists() || args.isReplace()) {
			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			writeFile(args, entityModel, "java/dto/dto.ftl", classFile);
		}
	}

	protected void writeBaseService(BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) {
		try {
			String serviceName = "Base" + StringUtils.capitalize(entity.getName()) + "Service.java";
			File serviceFile = new File(outputDir, serviceName);
			String implName = "Base" + StringUtils.capitalize(entity.getName()) + "ServiceImpl.java";
			File implFile = new File(outputDir, implName);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			writeFile(args, entityModel, "java/service/base_service.ftl", serviceFile);
			writeFile(args, entityModel, "java/service/base_service_impl.ftl", implFile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	protected void writeExtensionService(BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) {
		try {
			String serviceName = StringUtils.capitalize(entity.getName()) + "Service.java";
			File serviceFile = new File(outputDir, serviceName);
			String implName = StringUtils.capitalize(entity.getName()) + "ServiceImpl.java";
			File implFile = new File(outputDir, implName);
			String mapperName = StringUtils.capitalize(entity.getName() + "Mapper.java");
			File mapperFile = new File(outputDir, mapperName);
			
			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			if (!serviceFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "java/service/service.ftl", serviceFile);
			}
			if (!implFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "java/service/service_impl.ftl", implFile);
			}
			if (!mapperFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "java/service/mapper.ftl", mapperFile);
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}


	
	protected void writeApiBaseExternal(BuilderArgs args, Map<String, Object> baseModel, Entity entity,
			File outputDir) {
		try {
			String className = "BaseExternal" + StringUtils.capitalize(entity.getName()) + "Rest.java";
			File classFile = new File(outputDir, className);

			String implName = "BaseExternal" + StringUtils.capitalize(entity.getName()) + "RestImpl.java";
			File implFile = new File(outputDir, implName);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			writeFile(args, entityModel, "api/external/base_api_external.ftl", classFile);
			writeFile(args, entityModel, "api/external/base_api_external_impl.ftl", implFile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	protected void writeApiExternal(BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) {
		try {
			String className = "External" + StringUtils.capitalize(entity.getName()) + "Rest.java";
			File classFile = new File(outputDir, className);

			String implName = "External" + StringUtils.capitalize(entity.getName()) + "RestImpl.java";
			File implFile = new File(outputDir, implName);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			if (!classFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "api/external/api_external.ftl", classFile);
			}
			if (!implFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "api/external/api_external_impl.ftl", implFile);
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	protected void writeApiBaseInternal(BuilderArgs args, Map<String, Object> baseModel, Entity entity,
			File outputDir) {
		try {
			String className = "BaseInternal" + StringUtils.capitalize(entity.getName()) + "Rest.java";
			File classFile = new File(outputDir, className);

			String implName = "BaseInternal" + StringUtils.capitalize(entity.getName()) + "RestImpl.java";
			File implFile = new File(outputDir, implName);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			writeFile(args, entityModel, "api/internal/base_api_internal.ftl", classFile);
			writeFile(args, entityModel, "api/internal/base_api_internal_impl.ftl", implFile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	protected void writeApiInternal(BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) {
		try {
			String className = "Internal" + StringUtils.capitalize(entity.getName()) + "Rest.java";
			File classFile = new File(outputDir, className);

			String implName = "Internal" + StringUtils.capitalize(entity.getName()) + "RestImpl.java";
			File implFile = new File(outputDir, implName);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			if (!classFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "api/internal/api_internal.ftl", classFile);
			}
			if (!implFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "api/internal/api_internal_impl.ftl", implFile);
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}



	protected void writeClientEntity(BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) {
		try {
			String className = StringUtils.capitalize(entity.getName()) + ".java";
			File classFile = new File(outputDir, className);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			if (!classFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "client/client_entity.ftl", classFile);
			}

		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	protected void writeClientBaseEntity(BuilderArgs args, Map<String, Object> baseModel, Entity entity,
			File outputDir) {
		try {
			String className = "Base" + StringUtils.capitalize(entity.getName()) + ".java";
			File classFile = new File(outputDir, className);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			writeFile(args, entityModel, "client/client_base_entity.ftl", classFile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	protected void writeClientRest(BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) {
		try {
			String className = StringUtils.capitalize(entity.getName()) + "RestClient.java";
			File classFile = new File(outputDir, className);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			if (!classFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "client/client_rest.ftl", classFile);
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	protected void writeClientBaseRest(BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) {
		try {
			String className = "Base" + StringUtils.capitalize(entity.getName()) + "RestClient.java";
			File classFile = new File(outputDir, className);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			writeFile(args, entityModel, "client/client_base_rest.ftl", classFile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	protected void writeClientRepository(BuilderArgs args, Map<String, Object> baseModel, Entity entity,
			File outputDir) {
		try {
			String className = StringUtils.capitalize(entity.getName()) + "Persistence.java";
			File classFile = new File(outputDir, className);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			if (!classFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "client/client_repository.ftl", classFile);
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	protected void writeClientBaseRepository(BuilderArgs args, Map<String, Object> baseModel, Entity entity,
			File outputDir) {
		try {
			String className = "Base" + StringUtils.capitalize(entity.getName()) + "Persistence.java";
			File classFile = new File(outputDir, className);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			writeFile(args, entityModel, "client/client_base_repository.ftl", classFile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	protected void writeClientService(BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) {
		try {
			String serviceName = StringUtils.capitalize(entity.getName()) + "Service.java";
			File serviceFile = new File(outputDir, serviceName);
			String implName = StringUtils.capitalize(entity.getName()) + "ServiceImpl.java";
			File implFile = new File(outputDir, implName);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			if (!serviceFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "client/client_service.ftl", serviceFile);
			}

			if (!implFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "client/client_service_impl.ftl", implFile);
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	protected void writeClientBaseService(BuilderArgs args, Map<String, Object> baseModel, Entity entity,
			File outputDir) {
		try {
			String serviceName = "Base" + StringUtils.capitalize(entity.getName()) + "Service.java";
			File serviceFile = new File(outputDir, serviceName);
			String implName = "Base" + StringUtils.capitalize(entity.getName()) + "ServiceImpl.java";
			File implFile = new File(outputDir, implName);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			writeFile(args, entityModel, "client/client_base_service.ftl", serviceFile);
			writeFile(args, entityModel, "client/client_base_service_impl.ftl", implFile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}


	/*
	protected void writeLocalEnum(BuilderArgs args, Map<String, Object> baseModel, Attribute attribute,
			File outputDir) {
		try {
			String enumName = StringUtils.capitalize(attribute.getName()) + "Type.java";
			File enumFile = new File(outputDir, enumName);

			if (!enumFile.exists() || args.isReplace()) {
				Map<String, Object> enumModel = new HashMap<>(baseModel);
				enumModel.put("attribute", attribute);

				writeFile(args, enumModel, "local_enum.ftl", enumFile);
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
	*/

	protected void writeMultitenant(BuilderArgs args, Map<String, Object> baseModel, Service service, File outputDir) {
		try {

		} catch (Exception ex) {
			ex.printStackTrace();
		}

	}

	protected void writeFile(BuilderArgs args, Map<String, Object> model, String templateName, File outputFile)
			throws BuildException {
		logger.info("Creating {}", outputFile);
		Template template;
		try {
			template = freemarker.getTemplate(templateName);
			FileWriter fileWriter = new FileWriter(outputFile);

			template.process(model, fileWriter);
		} catch (Exception ex) {
			throw new BuildException(ex);
		}
	}
}
