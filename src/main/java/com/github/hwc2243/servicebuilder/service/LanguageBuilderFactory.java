package com.github.hwc2243.servicebuilder.service;

import freemarker.template.Configuration;

public final class LanguageBuilderFactory {

	private final Configuration freemarker;
	private final DefinitionReaderService definitionReaderService;

	public LanguageBuilderFactory(Configuration freemarker, DefinitionReaderService definitionReaderService) {
		this.freemarker = freemarker;
		this.definitionReaderService = definitionReaderService;
	}

	public LanguageBuilder get(BuilderArgs.BuildLang language) {
		return switch (language) {
		case JAVA -> new JavaLanguageBuilder(freemarker, definitionReaderService);
		case FLUTTER -> new FlutterLanguageBuilder(freemarker, definitionReaderService);
		};
	}
}
