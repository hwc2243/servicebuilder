package com.github.hwc2243.servicebuilder.service;

import java.io.File;
import java.util.HashMap;
import java.util.Locale;
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
			File modelFile = new File(modelDir, toSnakeCase(entity.getName()) + "_dto.dart");
			if (!modelFile.exists() || args.isReplace()) {
				Map<String, Object> entityModel = new HashMap<>(baseModel);
				entityModel.put("entity", entity);
				writeFile(args, entityModel, "flutter/client/model.ftl", modelFile);
			}
		}

		File providerDir = new File(context.getOutputDir(), "lib/providers");
		if (!providerDir.exists()) {
			providerDir.mkdirs();
		}

		if (service.isMultitenant() && service.getTenantDiscriminator() != null) {
			File tenantProviderFile = new File(providerDir, "tenant_discriminator_provider.dart");
			if (!tenantProviderFile.exists() || args.isReplace()) {
				writeFile(args, baseModel, "flutter/client/tenant_discriminator_provider.ftl", tenantProviderFile);
			}
		}

		if (hasExternalApi(service)) {
			File networkDir = new File(context.getOutputDir(), "lib/network");
			if (!networkDir.exists()) {
				networkDir.mkdirs();
			}
			File httpClientFile = new File(networkDir, "service_builder_http_client.dart");
			if (!httpClientFile.exists() || args.isReplace()) {
				writeFile(args, baseModel, "flutter/client/http_client.ftl", httpClientFile);
			}
			File httpExceptionFile = new File(networkDir, "service_builder_http_exception.dart");
			if (!httpExceptionFile.exists() || args.isReplace()) {
				writeFile(args, baseModel, "flutter/client/http_exception.ftl", httpExceptionFile);
			}
		}

		for (Entity entity : service.getEntities()) {
			if (entity.getApi() == null || entity.getApi().getExternal() == null) {
				continue;
			}
			Map<String, Object> entityModel = new HashMap<>(baseModel);
			entityModel.put("entity", entity);
			File providerFile = new File(providerDir, toSnakeCase(entity.getName()) + "_provider.dart");
			if (!providerFile.exists() || args.isReplace()) {
				writeFile(args, entityModel, "flutter/client/entity_provider.ftl", providerFile);
			}
		}
	}

	private boolean hasExternalApi(Service service) {
		return service.getEntities().stream()
				.anyMatch(entity -> entity.getApi() != null && entity.getApi().getExternal() != null);
	}

	private String toSnakeCase(String value) {
		return value.replaceAll("([a-z0-9])([A-Z])", "$1_$2")
				.toLowerCase(Locale.ROOT);
	}
}
