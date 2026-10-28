package com.github.hwc2243.servicebuilder.service;

import java.io.File;
import java.util.List;
import java.util.Map;

import com.github.hwc2243.servicebuilder.model.Entity;
import com.github.hwc2243.servicebuilder.model.Service;

import freemarker.template.Configuration;

public final class GenerationContext {

	private final Service service;
	private final BuilderArgs args;
	private final Map<String, Object> model;
	private final Map<String, Entity> entityMap;
	private final Map<String, List<Entity>> referencedEntitiesMap;
	private final File outputDir;
	private final Configuration freemarker;

	public GenerationContext(Service service, BuilderArgs args, Map<String, Object> model,
			Map<String, Entity> entityMap, Map<String, List<Entity>> referencedEntitiesMap,
			File outputDir, Configuration freemarker) {
		this.service = service;
		this.args = args;
		this.model = model;
		this.entityMap = entityMap;
		this.referencedEntitiesMap = referencedEntitiesMap;
		this.outputDir = outputDir;
		this.freemarker = freemarker;
	}

	public Service getService() {
		return service;
	}

	public BuilderArgs getArgs() {
		return args;
	}

	public Map<String, Object> getModel() {
		return model;
	}

	public Map<String, Entity> getEntityMap() {
		return entityMap;
	}

	public Map<String, List<Entity>> getReferencedEntitiesMap() {
		return referencedEntitiesMap;
	}

	public File getOutputDir() {
		return outputDir;
	}

	public Configuration getFreemarker() {
		return freemarker;
	}
}
