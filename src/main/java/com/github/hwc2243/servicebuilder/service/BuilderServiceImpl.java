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
		if (args.getBuildLang() == BuilderArgs.BuildLang.FLUTTER
				&& args.getBuildType() != BuilderArgs.BuildType.CLIENT) {
			throw new BuildException("Flutter builds only support CLIENT build type");
		}

		Map<String, Object> model = new HashMap<>();
		model.put("jpaPackage", args.getJpaPackage());

		Map<String, Entity> entityMap = buildEntityMap(service);
		validateService(service, entityMap);
		postProcess(entityMap);
		validateKeyOnlyRelationships(entityMap);

		model.put("entityMap", entityMap);
		Map<String, List<Entity>> referencedEntitiesMap = buildReferencedEntitiesMap(entityMap);
		model.put("referencedEntitiesMap", referencedEntitiesMap);

		File outputDir = new File(args.getOutputDir());
		logger.debug("Outdir = {}", outputDir.getAbsolutePath());
		if (outputDir.exists() && args.isClean()) {
			try {
				if (args.getBuildLang() == BuilderArgs.BuildLang.FLUTTER) {
					cleanFlutterOutput(outputDir);
				} else {
					Files.walk(outputDir.toPath()).sorted(Comparator.reverseOrder()).map(Path::toFile)
						.forEach(File::delete);
				}
			} catch (IOException ex) {
				throw new BuildException(ex);
			}
		}
		if (!outputDir.exists()) {
			outputDir.mkdirs();
		}

		if (service.isMultitenant()) {
			model.put("tenantDiscriminator", service.getTenantDiscriminator());
		}

		GenerationContext context = new GenerationContext(service, args, model, entityMap,
				referencedEntitiesMap, outputDir, freemarker);
		new LanguageBuilderFactory(freemarker, definitionReaderService)
				.get(args.getBuildLang())
				.build(context);
	}

	protected void cleanFlutterOutput(File outputDir) throws IOException {
		deletePath(new File(outputDir, "lib/models").toPath());
		deletePath(new File(outputDir, "lib/network").toPath());
		deletePath(new File(outputDir, "lib/providers/base").toPath());
		deletePath(new File(outputDir, "lib/providers/generated").toPath());
		File tenantProvider = new File(outputDir, "lib/providers/tenant_discriminator_provider.dart");
		if (tenantProvider.exists()) {
			Files.delete(tenantProvider.toPath());
		}
	}

	private void deletePath(Path path) throws IOException {
		if (Files.exists(path)) {
			Files.walk(path).sorted(Comparator.reverseOrder()).map(Path::toFile).forEach(File::delete);
		}
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

	protected void validateKeyOnlyRelationships(Map<String, Entity> entityMap) throws BuildException {
		for (Entity entity : entityMap.values()) {
			for (Related related : entity.getRelateds()) {
				if (related.isKeyOnly() && related.getRelationshipType() == RelationshipType.ONE_TO_ONE
						&& related.isOwner()) {
					throw new BuildException("Inverse one-to-one relationship '" + related.getName()
							+ "' on " + entity.getName()
							+ " cannot use key-only; the owning side must hold the key.");
				}
			}
		}
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
			if (StringUtils.isNotBlank(finder.getName())) {
				if (finder.getFinderAttributes().size() != 1) {
					throw new BuildException(String.format("Named finder %s on %s must have exactly one finder attribute.",
							finder.getName(), entity.getName()));
				}

				FinderAttribute finderAttribute = finder.getFinderAttributes().iterator().next();
				Related related = findRelated(entity, finderAttribute.getName(), entityMap);
				if (related == null || (related.getRelationshipType() != RelationshipType.ONE_TO_MANY
						&& related.getRelationshipType() != RelationshipType.MANY_TO_MANY)) {
					throw new BuildException(String.format(
							"Named finder %s on %s must reference a one-to-many or many-to-many relationship.",
							finder.getName(), entity.getName()));
				}
				if (finder.isUnique()) {
					throw new BuildException(String.format("Named collection finder %s on %s cannot be unique.",
							finder.getName(), entity.getName()));
				}
				Entity relatedEntity = entityMap.get(related.getEntityName());
				if (relatedEntity.isAbstractEntity()) {
					throw new BuildException(String.format(
							"Named collection finder %s on %s cannot reference abstract entity %s.", finder.getName(),
							entity.getName(), related.getEntityName()));
				}
				continue;
			}

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
				if (related.isKeyOnly()) {
					throw new BuildException("Related entity '" + related.getName()
							+ "' on " + entity.getName()
							+ " cannot use key-only with a many-to-many relationship.");
				}
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
				if (related.isKeyOnly()) {
					throw new BuildException("Related entity '" + related.getName()
							+ "' on " + entity.getName()
							+ " cannot use key-only with a one-to-many relationship.");
				}
			} else if (related.getRelationshipType() == RelationshipType.MANY_TO_ONE) {
			} else if (related.getRelationshipType() == RelationshipType.ONE_TO_ONE) {
				if (related.isKeyOnly() && related.isOwner()) {
					throw new BuildException("Inverse one-to-one relationship '" + related.getName()
							+ "' on " + entity.getName()
							+ " cannot use key-only; the owning side must hold the key.");
				}
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
			
				writeFile(args, enumModel, "java/server/model/enum.ftl", enumFile);
			}
		}
	}

	protected void writeBaseModel (BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) throws BuildException {
		String className = "Base" + StringUtils.capitalize(entity.getName()) + ".java";
		File classFile = new File(outputDir, className);
			
		Map<String, Object> entityModel = new HashMap<>(baseModel);
		entityModel.put("entity", entity);

		writeFile(args, entityModel, "java/server/model/base_model.ftl", classFile);
	}
	
	protected void writeExtensionModel (BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) throws BuildException {
		String className = StringUtils.capitalize(entity.getName()) + ".java";
		File classFile = new File(outputDir, className);
			
		if (!classFile.exists() || args.isReplace()) {
			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);
			
			writeFile(args, entityModel, "java/server/model/model.ftl", classFile);
		} 
	}
	
	protected void writeBaseEntity(BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) throws BuildException {
		String className = "Base" + StringUtils.capitalize(entity.getName()) + "Entity.java";
		File classFile = new File(outputDir, className);
		
		Map<String, Object> entityModel = new HashMap<>(baseModel);
		entityModel.put("entity", entity);

		writeFile(args, entityModel, "java/server/entity/base_entity.ftl", classFile);
	}
	
	protected void writeExtensionEntity(BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) {
		try {
			String className = StringUtils.capitalize(entity.getName()) + "Entity.java";
			File classFile = new File(outputDir, className);

			if (!classFile.exists() || args.isReplace()) {
				Map<String, Object> entityModel = new HashMap<>(baseModel);
				entityModel.put("entity", entity);

				writeFile(args, entityModel, "java/server/entity/entity.ftl", classFile);
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

			writeFile(args, entityModel, "java/server/persistence/base_persistence.ftl", classFile);
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

				writeFile(args, entityModel, "java/server/persistence/persistence.ftl", classFile);
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

		writeFile(args, entityModel, "java/server/dto/base_dto.ftl", classFile);
	}

	protected void writeExtensionDTO (BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir)
			throws BuildException {
		String className = StringUtils.capitalize(entity.getName()) + "DTO.java";
		File classFile = new File(outputDir, className);

		if (!classFile.exists() || args.isReplace()) {
			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			writeFile(args, entityModel, "java/server/dto/dto.ftl", classFile);
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

			writeFile(args, entityModel, "java/server/service/base_service.ftl", serviceFile);
			writeFile(args, entityModel, "java/server/service/base_service_impl.ftl", implFile);
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
				writeFile(args, entityModel, "java/server/service/service.ftl", serviceFile);
			}
			if (!implFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "java/server/service/service_impl.ftl", implFile);
			}
			if (!mapperFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "java/server/service/mapper.ftl", mapperFile);
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

			writeFile(args, entityModel, "java/server/api/external/base_api_external.ftl", classFile);
			writeFile(args, entityModel, "java/server/api/external/base_api_external_impl.ftl", implFile);
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
				writeFile(args, entityModel, "java/server/api/external/api_external.ftl", classFile);
			}
			if (!implFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "java/server/api/external/api_external_impl.ftl", implFile);
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

			writeFile(args, entityModel, "java/server/api/internal/base_api_internal.ftl", classFile);
			writeFile(args, entityModel, "java/server/api/internal/base_api_internal_impl.ftl", implFile);
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
				writeFile(args, entityModel, "java/server/api/internal/api_internal.ftl", classFile);
			}
			if (!implFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "java/server/api/internal/api_internal_impl.ftl", implFile);
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
				writeFile(args, entityModel, "java/client/client_entity.ftl", classFile);
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

			writeFile(args, entityModel, "java/client/client_base_entity.ftl", classFile);
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
				writeFile(args, entityModel, "java/client/client_rest.ftl", classFile);
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

				writeFile(args, entityModel, "java/client/client_base_rest.ftl", classFile);
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
				writeFile(args, entityModel, "java/client/client_repository.ftl", classFile);
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

			writeFile(args, entityModel, "java/client/client_base_repository.ftl", classFile);
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
				writeFile(args, entityModel, "java/client/client_service.ftl", serviceFile);
			}

			if (!implFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "java/client/client_service_impl.ftl", implFile);
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

			writeFile(args, entityModel, "java/client/client_base_service.ftl", serviceFile);
			writeFile(args, entityModel, "java/client/client_base_service_impl.ftl", implFile);
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
