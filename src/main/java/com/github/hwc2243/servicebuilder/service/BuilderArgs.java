package com.github.hwc2243.servicebuilder.service;

import com.beust.jcommander.IStringConverter;
import com.beust.jcommander.Parameter;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BuilderArgs {

	@Parameter(
			names = {"-b", "--build-type"},
			description = "The build type: client or server (default server)",
			converter = BuildTypeConverter.class)
	@Builder.Default
	private BuildType buildType = BuildType.SERVER;

	@Parameter(
		names = {"-l", "--build-lang"},
		description = "The build language: java or flutter (default java)",
		converter = BuildLangConverter.class)
	@Builder.Default
	private BuildLang buildLang = BuildLang.JAVA;
	
	@Parameter(
		names = {"-c", "--clean"},
		description = "Clean the output directory")
	@Builder.Default
	private boolean clean = false;
	
	@Parameter(
		names = {"-r", "--replace"},
		description = "Replace existing local entities/services")
	@Builder.Default
	private boolean replace = false;
	
	@Parameter(
		names = {"-o", "--output-dir"},
		description = "The output directory",
		required = true)
	private String outputDir;
	
	@Parameter(
		names = {"-s", "--service-file"},
		description = "The service definition file",
		required = true)
	private String serviceFile;
	
	@Parameter(
		names = {"-j", "--jpa-package"},
		description = "The package to get JPA annotations from (default jakarta.persistence)")
	@Builder.Default
	private String jpaPackage = "jakarta.persistence";
	
	
	public enum BuildType {
		CLIENT, SERVER
	}

	public enum BuildLang {
		JAVA, FLUTTER
	}

	
	public class BuildTypeConverter implements IStringConverter<BuildType> {
        @Override
        public BuildType convert (String value) {
            return BuildType.valueOf(value.toUpperCase());
        }
    }

	public class BuildLangConverter implements IStringConverter<BuildLang> {
        @Override
        public BuildLang convert (String value) {
            return BuildLang.valueOf(value.toUpperCase());
        }
    }
}
