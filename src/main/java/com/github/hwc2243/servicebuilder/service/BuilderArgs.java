
package com.github.hwc2243.servicebuilder.service;

import com.beust.jcommander.Parameter;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BuilderArgs {

	@Parameter(
		names = {"-c", "--clean"},
		description = "Clean the output directory")
	private boolean clean = false;
	
	@Parameter(
		names = {"-r", "--replace"},
		description = "Replace existing local entities/services")
	private boolean replace;
	
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
	private String jpaPackage = "jakarta.persistence";
}
