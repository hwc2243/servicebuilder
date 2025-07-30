package com.github.hwc2243.servicebuilder.service;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

import com.github.hwc2243.servicebuilder.ServiceBuilderApplication;
import com.github.hwc2243.servicebuilder.model.Attribute;
import com.github.hwc2243.servicebuilder.model.Entity;
import com.github.hwc2243.servicebuilder.model.Finder;
import com.github.hwc2243.servicebuilder.model.FinderAttribute;
import com.github.hwc2243.servicebuilder.model.Related;
import com.github.hwc2243.servicebuilder.model.RelationshipType;
import com.github.hwc2243.servicebuilder.model.Service;

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

	public BuilderServiceImpl() throws SAXException 
	{
		this.freemarker = new Configuration(new Version(2, 3, 20));
		freemarker.setClassForTemplateLoading(ServiceBuilderApplication.class, "/templates");
		freemarker.setDefaultEncoding("UTF-8");
		freemarker.setLocale(Locale.US);
		freemarker.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);

		this.definitionReaderService = new DefinitionReaderServiceImpl();
	}

	public BuilderServiceImpl(Configuration freemarker, DefinitionReaderService definitionReaderService) {
		this.freemarker = freemarker;
		this.definitionReaderService = definitionReaderService;
	}

	@Override
	public void build(BuilderArgs args) throws ServiceException, IOException {
		File file = new File(args.getServiceFile());
		
		build(file, args);
	}

	@Override
	public void build (File file, BuilderArgs args) throws ServiceException, IOException {
		if (!file.exists()) {
			throw new FileNotFoundException(args.getServiceFile() + " not found");
		}

		try
		{
			Service service = definitionReaderService.read(file);
			build(service, args);
		}
		catch (SAXException ex)
		{
			throw new IOException("Failed to parse service file", ex);
		}
	}
	
	@Override
	public void build(Service service, BuilderArgs args) throws ServiceException, IOException {
		Map<String, Object> model = new HashMap<>();
		model.put("jpaPackage", args.getJpaPackage());

		Map<String, Entity> entityMap = buildEntityMap(service);
		postProcess(entityMap);
		validateEntityMap(entityMap);
		
		model.put("entityMap", entityMap);
		Map<String, List<Entity>> referencedEntitiesMap = buildReferencedEntitiesMap(entityMap);
		model.put("referencedEntitiesMap", referencedEntitiesMap);

		File outputDir = new File(args.getOutputDir());
		logger.debug("Outdir = {}", outputDir.getAbsolutePath());
		if (outputDir.exists() && args.isClean()) {
			Files.walk(outputDir.toPath()).sorted(Comparator.reverseOrder()).map(Path::toFile).forEach(File::delete);
		}
		if (!outputDir.exists()) {
			outputDir.mkdirs();
		}

		String projectPackageName = service.getPackageName();
		File projectPackageDir = createPackageDir(outputDir, projectPackageName.replace(".", File.separator));
		logger.debug("Base package dir = {}", projectPackageDir.getAbsolutePath());

		// write the models
		String localModelPackageName = projectPackageName + ".model";
		model.put("localModelPackage", localModelPackageName);
		String baseModelPackageName = localModelPackageName + ".base";
		model.put("baseModelPackage", baseModelPackageName);

		File localModelDir = createPackageDir(projectPackageDir, "model");
		File baseModelDir = createPackageDir(localModelDir, "base");
		try {
			writeFile(args, model, "abstract_base_entity.ftl", new File(baseModelDir, "AbstractBaseEntity.java"));
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		service.getEntities().stream().forEach(entity -> {
			writeBaseEntity(args, model, entity, baseModelDir);
			writeLocalEntity(args, model, entity, localModelDir);
		});

		// write the repositories
		String localRepositoryPackageName = projectPackageName + ".persistence";
		model.put("localRepositoryPackage", localRepositoryPackageName);
		String baseRepositoryPackageName = localRepositoryPackageName + ".base";
		model.put("baseRepositoryPackage", baseRepositoryPackageName);
		
		File localRepositoryDir = createPackageDir(projectPackageDir, "persistence");
		File baseRepositoryDir = createPackageDir(localRepositoryDir, "base");
		service.getEntities().stream().forEach(entity -> {
			if (entity.isPersistence()) {
				writeBaseRepository(args, model, entity, baseRepositoryDir);
				writeLocalRepository(args, model, entity, localRepositoryDir);
			}
		});

		// write the services
		String localServicePackageName = projectPackageName + ".service";
		model.put("localServicePackage", localServicePackageName);
		File localServiceDir = createPackageDir(projectPackageDir, "service");
		
		String baseServicePackageName = localServicePackageName + ".base";
		model.put("baseServicePackage", baseServicePackageName);
		File baseServiceDir = createPackageDir(localServiceDir, "base");
		
		try {
			writeFile(args, model, "service_exception.ftl", new File(localServiceDir, "ServiceException.java"));
			writeFile(args, model, "base_entity_service.ftl", new File(baseServiceDir, "EntityService.java"));
		} catch (Exception ex) {
			ex.printStackTrace();
		}

		service.getEntities().stream().forEach(entity -> {
			if (entity.isPersistence()) {
				writeBaseService(args, model, entity, baseServiceDir);
				writeLocalService(args, model, entity, localServiceDir);
			}
		});
		
		// write the rest endpoints

		String apiPackageName = projectPackageName + ".api";
		File apiPackageDir = createPackageDir(projectPackageDir, "api");
		
		String baseApiPackageName = apiPackageName + ".base";
		File baseApiPackageDir = createPackageDir(apiPackageDir, "base");
		
		String baseInternalApiPackageName = baseApiPackageName + ".internal";
		model.put("baseInternalApiPackage", baseInternalApiPackageName);
		File baseInternalApiPackageDir = createPackageDir(baseApiPackageDir, "internal");
		service.getEntities().stream().forEach(entity -> {
			if (entity.isPersistence()) {
				writeApiBaseInternal(args, model, entity, baseInternalApiPackageDir);
			}
		});
		
		String baseExternalApiPackage = baseApiPackageName + ".external";
		model.put("baseExternalApiPackage", baseExternalApiPackage);
		File baseExternalApiPackageDir = createPackageDir(baseApiPackageDir, "external");
		
		String internalApiPackageName = apiPackageName + ".internal";
		model.put("internalApiPackage", internalApiPackageName);
		File internalApiPackageDir = createPackageDir(apiPackageDir, "internal");
		service.getEntities().stream().forEach(entity -> {
			if (entity.isPersistence()) {
				writeApiInternal(args, model, entity, internalApiPackageDir);
			}
		});
		
		String externalApiPackageName = apiPackageName + ".external";
		model.put("externalApiPackage", externalApiPackageName);
		File externalApiPackageDir = createPackageDir(apiPackageDir, "external");
	}

	protected Map<String, Entity> buildEntityMap(Service service) {
		return service.getEntities().stream().collect(Collectors.toMap(Entity::getName, Function.identity()));
	}

	protected Map<String, List<Entity>> buildReferencedEntitiesMap(Map<String, Entity> entityMap) {
		Map<String, List<Entity>> referencedEntitiesMap = new HashMap<>();

		entityMap.values().stream().forEach(entity -> {
			logger.info("entity {} - attribute = {}", entity.getName(), entity.getAttributes());
			List<Entity> referencedEntities = entity.getRelateds().stream()
					.filter(related -> StringUtils.isNotBlank(related.getEntityName())).map(related -> {
						return entityMap.get(related.getEntityName());
					}).collect(Collectors.toList());

			logger.info("{} referencedEntities = {}", entity.getName(), referencedEntities);

			referencedEntitiesMap.put(entity.getName(), referencedEntities);
		});

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
						targetEntity = entityMap.get(related.getEntityName());

						Related targetRelationship = new Related();
						targetRelationship.setName(entity.getName());
						targetRelationship.setEntityName(entity.getName());
						targetRelationship.setRelationshipType(RelationshipType.MANY_TO_ONE);
						targetEntity.addRelated(targetRelationship);
						logger.info("  adding {} to {}", targetRelationship.getName(), targetEntity.getName());

						break;

					case MANY_TO_MANY:
						logger.info("  MANY_TO_MANY");
						logger.info("    relationship {} target {}", related.getName(), related.getEntityName());
						if (StringUtils.isNotBlank(related.getMappedBy())) {
							targetEntity = entityMap.get(related.getEntityName());
							targetRelationship = targetEntity.getRelated(related.getMappedBy());
							targetRelationship.setOwner(true);
						}
						else
						{
							related.setOwner(true);
						}
						break;
					}
			}
		}
	}

	protected void validateEntityMap (Map<String, Entity> entityMap) throws ServiceException
	{
		for (Entity entity : entityMap.values())
		{
			validateFinders(entity);
		}
	}
	
	protected void validateFinders (Entity entity) throws ServiceException
	{
		for (Finder finder : entity.getFinders())
		{
			for (FinderAttribute attribute : finder.getFinderAttributes()) {
				if (entity.getAttribute(attribute.getName()) == null) {
					throw new ServiceException(String.format("Finder %s on %s is invalid, %s is not an attribute.", finder.buildFinderName(), entity.getName(), attribute.getName()));
				}
			}
		}
	}
	
	protected void writeApiBaseInternal (BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) {
		try
		{
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

	protected void writeApiInternal (BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) {
		try
		{
			String className = "Internal" + StringUtils.capitalize(entity.getName()) + "Rest.java";
			File classFile = new File(outputDir, className);
	
			String implName = "Internal" + StringUtils.capitalize(entity.getName()) + "RestImpl.java";
			File implFile = new File(outputDir, implName);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			writeFile(args, entityModel, "api/internal/api_internal.ftl", classFile);
			writeFile(args, entityModel, "api/internal/api_internal_impl.ftl", implFile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
	
	protected void writeBaseEntity(BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) {
		try {
			String className = "Base" + StringUtils.capitalize(entity.getName()) + ".java";
			File classFile = new File(outputDir, className);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			writeFile(args, entityModel, "base_entity.ftl", classFile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	protected void writeBaseRepository(BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) {
		try {
			String className = "Base" + StringUtils.capitalize(entity.getName()) + "Persistence.java";
			File classFile = new File(outputDir, className);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			writeFile(args, entityModel, "base_repository.ftl", classFile);
		} catch (Exception ex) {
			ex.printStackTrace();
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

			writeFile(args, entityModel, "base_service.ftl", serviceFile);
			writeFile(args, entityModel, "base_service_impl.ftl", implFile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	protected void writeLocalEntity(BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) {
		try {
			String className = StringUtils.capitalize(entity.getName()) + ".java";
			File classFile = new File(outputDir, className);

			if (!classFile.exists() || args.isReplace()) {
				Map<String, Object> entityModel = new HashMap<>(baseModel);
				entityModel.put("entity", entity);

				writeFile(args, entityModel, "local_entity.ftl", classFile);
			}
			entity.getAttributes().stream()
			  .filter(attribute -> "enum".equals(attribute.getType()))
			  .forEach(attribute -> { writeLocalEnum(args, baseModel, attribute, outputDir);});
		} catch (Exception ex) {
			ex.printStackTrace();
		}

	}

	protected void writeLocalEnum (BuilderArgs args, Map<String, Object> baseModel, Attribute attribute, File outputDir) {
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
	
	protected void writeLocalRepository(BuilderArgs args, Map<String, Object> baseModel, Entity entity,
			File outputDir) {
		try {
			String className = StringUtils.capitalize(entity.getName()) + "Persistence.java";
			File classFile = new File(outputDir, className);

			if (!classFile.exists() || args.isReplace()) {
				Map<String, Object> entityModel = new HashMap<>(baseModel);
				entityModel.put("entity", entity);

				writeFile(args, entityModel, "local_repository.ftl", classFile);
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	protected void writeLocalService(BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir) {
		try {
			String serviceName = StringUtils.capitalize(entity.getName()) + "Service.java";
			File serviceFile = new File(outputDir, serviceName);
			String implName = StringUtils.capitalize(entity.getName()) + "ServiceImpl.java";
			File implFile = new File(outputDir, implName);

			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);

			if (!serviceFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "local_service.ftl", serviceFile);
			}

			if (!implFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "local_service_impl.ftl", implFile);
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	protected void writeFile(BuilderArgs args, Map<String, Object> model, String templateName, File outputFile)
			throws IOException, TemplateException {
		logger.info("Creating {}", outputFile);
		Template template = freemarker.getTemplate(templateName);
		FileWriter fileWriter = new FileWriter(outputFile);

		template.process(model, fileWriter);
	}

}
