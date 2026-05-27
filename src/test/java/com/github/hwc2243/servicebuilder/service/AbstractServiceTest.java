package com.github.hwc2243.servicebuilder.service;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.junit.jupiter.api.Assertions.fail;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Method;
import java.net.URL;
import java.net.URLClassLoader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

import javax.tools.DiagnosticCollector;
import javax.tools.JavaCompiler;
import javax.tools.JavaFileObject;
import javax.tools.StandardJavaFileManager;
import javax.tools.ToolProvider;

import org.mapstruct.factory.Mappers;
import org.xml.sax.SAXException;

import com.github.hwc2243.servicebuilder.model.Service;

public abstract class AbstractServiceTest {

	public static final String TMPDIR = "/tmp"; // System.getProperty("java.io.tmpdir");

	protected BuilderService builderService;

	protected DefinitionReaderService definitionReaderService = null;

	protected BuilderArgs args;

	public AbstractServiceTest() throws SAXException {
		this.definitionReaderService = new DefinitionReaderServiceImpl();
		this.builderService = new BuilderServiceImpl(definitionReaderService);

		args = new BuilderArgs();
		args.setClean(true);
		args.setReplace(true);
		args.setOutputDir(TMPDIR);
	}

	protected File loadFile (String filename)
	{
		return new File(getClass().getClassLoader().getResource(filename).getFile());
	}
	
	protected void testService (String serviceFile) throws Exception {
		Service service = definitionReaderService.read(this.loadFile(serviceFile));
		builderService.build(service, args);
		Path compileDir = runCompile(TMPDIR + "/" + service.getPackageName().replace(".", "/"));
		testMapper(service, compileDir);
	}
	
	protected void testMapper(Service service, Path compileDir) throws Exception {

	    URLClassLoader classLoader = new URLClassLoader(
	            new URL[] { compileDir.toUri().toURL() },
	            this.getClass().getClassLoader()
	    );

	    for (var entity : service.getEntities()) {

	        String basePackage = service.getPackageName();

	        String entityName = entity.getName();

	        String mapperClassName =
	                basePackage + ".service." +
	                capitalize(entityName) + "Mapper";

	        String entityClassName =
	                basePackage + ".entity." +
	                capitalize(entityName) + "Entity";

	        String dtoClassName =
	                basePackage + ".dto." +
	                capitalize(entityName) + "DTO";

	        Class<?> mapperClass = classLoader.loadClass(mapperClassName);
	        Class<?> entityClass = classLoader.loadClass(entityClassName);
	        Class<?> dtoClass = classLoader.loadClass(dtoClassName);

	        Object mapper =
	                Mappers.getMapper((Class) mapperClass);

	        Object entityObject =
	                entityClass.getDeclaredConstructor().newInstance();

	        Method toDto =
	                mapperClass.getMethod("toDto", entityClass);

	        Object dtoObject =
	                toDto.invoke(mapper, entityObject);

	        assertNotNull(dtoObject);

	        assertTrue(dtoClass.isAssignableFrom(dtoObject.getClass()));

	        Method toEntity =
	                mapperClass.getMethod("toEntity", dtoClass);

	        Object mappedEntity =
	                toEntity.invoke(mapper, dtoObject);

	        assertNotNull(mappedEntity);

	        assertTrue(entityClass.isAssignableFrom(mappedEntity.getClass()));
	    }
	}
	
	protected Path runCompile (String sourcePath) throws IOException {
		Path generatedRoot = Paths.get(sourcePath);

		List<File> javaFiles;
		try (var stream = Files.walk(generatedRoot)) {
			javaFiles = stream.filter(path -> path.toString().endsWith(".java")).map(Path::toFile).toList();
		}
		assertFalse(javaFiles.isEmpty(), "No generated Java files found");
		
		JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
	    assertNotNull(compiler, "No Java compiler available. Make sure tests run with a JDK, not a JRE.");

	    DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();

	    try (StandardJavaFileManager fileManager =
	                 compiler.getStandardFileManager(diagnostics, null, null)) {

	        Iterable<? extends JavaFileObject> compilationUnits =
	                fileManager.getJavaFileObjectsFromFiles(javaFiles);

	        Path compileOutputDir = Files.createTempDirectory("generated-code-classes");

	        List<String> options = List.of(
	                "-d", compileOutputDir.toString(),
	                "-classpath", System.getProperty("java.class.path"),
	                "-processorpath", System.getProperty("java.class.path"),
	                "-processor", "org.mapstruct.ap.MappingProcessor"
	        );

	        Boolean success = compiler.getTask(
	                null,
	                fileManager,
	                diagnostics,
	                options,
	                null,
	                compilationUnits
	        ).call();

	        if (!Boolean.TRUE.equals(success)) {
	            String errors = diagnostics.getDiagnostics().stream()
	                    .map(d -> String.format(
	                            "%s:%d:%d: %s",
	                            d.getSource() == null ? "unknown" : d.getSource().getName(),
	                            d.getLineNumber(),
	                            d.getColumnNumber(),
	                            d.getMessage(Locale.US)
	                    ))
	                    .collect(Collectors.joining(System.lineSeparator()));

	            fail("Generated code did not compile:\n" + errors);
	        }
		    return compileOutputDir;
	    }
	}
	
	protected String capitalize(String value) {
	    return Character.toUpperCase(value.charAt(0))
	            + value.substring(1);
	}
}
