package com.github.hwc2243.servicebuilder.service;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import com.github.hwc2243.servicebuilder.model.Entity;
import com.github.hwc2243.servicebuilder.model.Service;

import freemarker.template.Configuration;

public final class FlutterLanguageBuilder extends BuilderServiceImpl implements LanguageBuilder {

	public FlutterLanguageBuilder(Configuration freemarker, DefinitionReaderService definitionReaderService) {
		super(freemarker, definitionReaderService);
	}

	@Override
	public void build(GenerationContext context) throws BuildException {
		BuilderArgs args = context.getArgs();
		if (args.getBuildType() != BuilderArgs.BuildType.CLIENT) {
			throw new BuildException("Flutter builds only support CLIENT build type");
		}

		Service service = context.getService();
		Map<String, Object> baseModel = context.getModel();
		File modelDir = new File(context.getOutputDir(), "lib/models");
		if (!modelDir.exists()) {
			modelDir.mkdirs();
		}

		for (Entity entity : service.getEntities()) {
			String className = entity.getName().substring(0, 1).toUpperCase()
					+ entity.getName().substring(1) + "Dto";
			File modelFile = new File(modelDir, className + ".dart");
			if (!modelFile.exists() || args.isReplace()) {
				Map<String, Object> entityModel = new HashMap<>(baseModel);
				entityModel.put("entity", entity);
				writeFile(args, entityModel, "flutter/client/model.ftl", modelFile);
			}
		}
	}
}
