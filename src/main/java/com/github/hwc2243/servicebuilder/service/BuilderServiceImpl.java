package com.github.hwc2243.servicebuilder.service;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import com.github.hwc2243.servicebuilder.model.Entity;
import com.github.hwc2243.servicebuilder.model.Service;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import freemarker.template.utility.StringUtil;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;

@org.springframework.stereotype.Service
public class BuilderServiceImpl implements BuilderService {

	protected static Logger logger = LoggerFactory.getLogger(BuilderServiceImpl.class);
	
	@Autowired
	protected Configuration freemarker;
	
	@Override
	public void build (Service service, BuilderArgs args) throws IOException {

		File outputDir = new File(args.getOutputDir());
		logger.debug("Outdir = {}", outputDir.getAbsolutePath());
		if (outputDir.exists() && args.isClean())
		{
			Files.walk(outputDir.toPath())
		      .sorted(Comparator.reverseOrder())
		      .map(Path::toFile)
		      .forEach(File::delete);
		}
		if (!outputDir.exists()) {
			outputDir.mkdirs();
		}

		String projectPackageName = service.getPackageName();
		File projectPackageDir = createPackageDir(outputDir, projectPackageName.replace(".", File.separator));
		logger.debug("Base package dir = {}", projectPackageDir.getAbsolutePath());
		
		String basePackageName = projectPackageName + ".base";
		Map<String, Object> model = new HashMap<>();
		model.put("basePackage", basePackageName);
		File basePackageDir = createPackageDir(projectPackageDir, "base");

		
		// write the base models
		String baseModelPackageName = basePackageName + ".model";
		model.put("baseModelPackage", baseModelPackageName);
		File baseModelDir = createPackageDir(basePackageDir, "model");
		try
		{
			writeFile(args, model, "abstract_base_entity.ftl", new File(baseModelDir, "AbstractBaseEntity.java"));
		}
		catch (Exception ex)
		{
			ex.printStackTrace();
		}
		service.getEntities().stream().forEach(entity -> {writeBaseEntity(args, model, entity, baseModelDir);});
		
		// write the local model
		String localModelPackageName = projectPackageName + ".model";
		model.put("localModelPackage", localModelPackageName);
		File localModelDir = createPackageDir(projectPackageDir, "model");
		service.getEntities().stream().forEach(entity -> {writeLocalEntity(args, model, entity, localModelDir);});

		// write the repositories
		String baseRepositoryPackageName = basePackageName + ".persistence";
		model.put("baseRepositoryPackage", baseRepositoryPackageName);
		File baseRepositoryDir = createPackageDir(basePackageDir, "persistence");
		String localRepositoryPackageName = projectPackageName + ".persistence";
		model.put("localRepositoryPackage", localRepositoryPackageName);
		File localRepositoryDir = createPackageDir(projectPackageDir, "persistence");
		service.getEntities().stream().forEach(entity -> {
			writeBaseRepository(args, model, entity, baseRepositoryDir);
			writeLocalRepository(args, model, entity, localRepositoryDir);
		});
		
		// write the services
		String baseServicePackageName = basePackageName + ".service";
		model.put("baseServicePackage", baseServicePackageName);
		File baseServiceDir = createPackageDir(basePackageDir, "service");
		try
		{
			writeFile(args, model, "service_exception.ftl", new File(baseServiceDir, "ServiceException.java"));
			writeFile(args, model, "base_entity_service.ftl", new File(baseServiceDir, "EntityService.java"));
		}
		catch (Exception ex)
		{
			ex.printStackTrace();
		}
		String localServicePackageName = projectPackageName + ".service";
		model.put("localServicePackage", localServicePackageName);
		File localServiceDir = createPackageDir(projectPackageDir, "service");
		
		service.getEntities().stream().forEach(entity -> {
			writeBaseService(args, model, entity, baseServiceDir);
			writeLocalService(args, model, entity, localServiceDir);
		});
		
	}
	
	protected File createPackageDir (File baseDir, String packageName)
	{
		File packageDir = new File(baseDir, packageName);
		if (!packageDir.exists()) {
			packageDir.mkdirs();
		}
		return packageDir;
	}
	
	protected void writeBaseEntity (BuilderArgs args, Map<String,Object> baseModel, Entity entity, File outputDir) {
		try {
			String className = "Base" + StringUtils.capitalize(entity.getName()) + ".java";
			File classFile = new File(outputDir, className);
			
			Map<String,Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);
			
			writeFile(args, entityModel, "base_entity.ftl", classFile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
	
	protected void writeBaseRepository (BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir)
	{
		try {
			String className = "Base" + StringUtil.capitalize(entity.getName()) + "Persistence.java";
			File classFile = new File(outputDir, className);
			
			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);
			
			writeFile(args, entityModel, "base_repository.ftl", classFile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
	
	protected void writeBaseService (BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir)
	{
		try {
			String serviceName = "Base" + StringUtil.capitalize(entity.getName()) + "Service.java";
			File serviceFile = new File(outputDir, serviceName);
			String implName = "Base" + StringUtil.capitalize(entity.getName()) + "ServiceImpl.java";
			File implFile = new File(outputDir, implName);
			
			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);
			
			writeFile(args, entityModel, "base_service.ftl", serviceFile);
			writeFile(args, entityModel, "base_service_impl.ftl", implFile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
	
	protected void writeLocalEntity (BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir)
	{
		try {
			String className = StringUtils.capitalize(entity.getName()) + ".java";
			File classFile = new File(outputDir, className);
			
			Map<String,Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);
			
			writeFile(args, entityModel, "local_entity.ftl", classFile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}

	}
	
	protected void writeLocalRepository (BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir)
	{
		try {
			String className = StringUtil.capitalize(entity.getName()) + "Persistence.java";
			File classFile = new File(outputDir, className);
			
			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);
			
			writeFile(args, entityModel, "local_repository.ftl", classFile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	protected void writeLocalService (BuilderArgs args, Map<String, Object> baseModel, Entity entity, File outputDir)
	{
		try {
			String serviceName = StringUtil.capitalize(entity.getName()) + "Service.java";
			File serviceFile = new File(outputDir, serviceName);
			String implName = StringUtil.capitalize(entity.getName()) + "ServiceImpl.java";
			File implFile = new File(outputDir, implName);
			
			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);
			
			writeFile(args, entityModel, "local_service.ftl", serviceFile);
			writeFile(args, entityModel, "local_service_impl.ftl", implFile);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
	
	protected void writeFile (BuilderArgs args, Map<String,Object> model, String templateName, File outputFile) throws IOException, TemplateException {
		logger.info("Creating {}", outputFile);
		Template template = freemarker.getTemplate(templateName);
		FileWriter fileWriter = new FileWriter(outputFile);
		
		template.process(model, fileWriter);
	}

}
