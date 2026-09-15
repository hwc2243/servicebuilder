package com.github.hwc2243.servicebuilder.service;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
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

import org.junit.jupiter.api.Test;
import org.mapstruct.factory.Mappers;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.SAXException;

import com.github.hwc2243.servicebuilder.model.Service;

public class BuilderServiceTest extends AbstractServiceTest {


	protected static Logger logger = LoggerFactory.getLogger(BuilderServiceTest.class);

	public BuilderServiceTest() throws SAXException {
		super();
	}

	@Test
	public void whenSimple_isGood() throws Exception {
		testService("simple-service.xml");
	}
	
	@Test
	public void whenSimpleEnum_isGood() throws Exception {
		testService("simple-enum-service.xml");
	}

	@Test
	public void whenSimpleMultitenant_isGood() throws Exception {
		testService("multitenant/simple-multitenant-service.xml");
	}
	
	@Test
	public void whenFinder_hasBadColumn() throws Exception {
		assertThrows(BuildException.class, () -> {
			File serviceFile = this.loadFile("bad-finder-attribute.xml");
			builderService.build(serviceFile, args);
		});
	}

	@Test
	public void whenFinder_hasToOneRelationship_isGood() throws Exception {
		File serviceFile = loadFile("related/one-to-many-finder-good.xml");
		builderService.build(serviceFile, args);

		Path generatedRoot = Paths.get(TMPDIR, "test", "related_finder");
		String filePersistence = Files.readString(generatedRoot.resolve("persistence/base/BaseDocumentFilePersistence.java"));
		String folderPersistence = Files.readString(generatedRoot.resolve("persistence/base/BaseDocumentFolderPersistence.java"));
		String entity = Files.readString(generatedRoot.resolve("entity/base/BaseDocumentLibraryEntity.java"));

		assertTrue(filePersistence.contains("findFirstByNameAndLibraryIdAndParentFolderId(String name, Long libraryId, Long parentFolderId)"));
		assertTrue(folderPersistence.contains("findFirstByNameAndLibraryIdAndParentFolderId(String name, Long libraryId, Long parentFolderId)"));
		assertTrue(entity.contains("@OneToMany(mappedBy = \"library\""));
		assertFalse(entity.contains("@JoinColumn(name = \"documentLibraryId\")"));
	}

	@Test
	public void whenNamedCollectionFinder_isGood() throws Exception {
		testService("named-collection-finder-service.xml");

		Path generatedRoot = Paths.get(TMPDIR, "test", "named_finder");
		String persistence = Files.readString(generatedRoot.resolve("persistence/base/BaseMemberPersistence.java"));
		String service = Files.readString(generatedRoot.resolve("service/base/BaseMemberService.java"));
		String serviceImpl = Files.readString(generatedRoot.resolve("service/base/BaseMemberServiceImpl.java"));

		assertTrue(persistence.contains("@Query(\"select entity from MemberEntity entity join entity.sessions session where session = :session\")"));
		assertTrue(persistence.contains("List<E> findBySession(@Param(\"session\") SessionEntity session);"));
		assertTrue(service.contains("List<D> findBySession (SessionDTO session);"));
		assertTrue(serviceImpl.contains("baseMemberPersistence.findBySession(sessionMapper.toEntity(session))"));
	}

	@Test
	public void whenBidirectionalRelationship_isGood() throws Exception {
		File serviceFile = this.loadFile("related/many-to-many-bi-good.xml");
		builderService.build(serviceFile, args);
	}

	@Test
	public void whenBidirectionalRelationship_hasBadRelated() throws Exception {
		assertThrows(BuildException.class, () -> {
			File serviceFile = this.loadFile("related/many-to-many-bi-bad-related.xml");
			builderService.build(serviceFile, args);
		});
	}

	@Test
	public void whenBidirectionalRelationship_hasBadMappedBy() throws Exception {
		assertThrows(BuildException.class, () -> {
			File serviceFile = this.loadFile("related/many-to-many-bi-no-mapped-by.xml");
			builderService.build(serviceFile, args);
		});

		assertThrows(BuildException.class, () -> {
			File serviceFile = this.loadFile("related/many-to-many-bi-both-mapped-by.xml");
			builderService.build(serviceFile, args);
		});

		assertThrows(BuildException.class, () -> {
			File serviceFile = this.loadFile("related/many-to-many-bi-wrong-mapped-by.xml");
			builderService.build(serviceFile, args);
		});

	}

	@Test
	public void whenUnidirectionalRelationship_isGood() throws Exception {
		File serviceFile = this.loadFile("related/many-to-many-uni-good.xml");
		builderService.build(serviceFile, args);
	}

	@Test
	public void whenMultitenant_NoDiscriminator() throws Exception {
		assertThrows(BuildException.class, () -> {
			File serviceFile = this.loadFile("multitenant/multi-no-discriminator.xml");
			builderService.build(serviceFile, args);
		});
	}

	@Test
	public void whenNoMultitenant_HasDiscriminator() throws Exception {
		assertThrows(BuildException.class, () -> {
			File serviceFile = this.loadFile("multitenant/no-multi-discriminator.xml");
			builderService.build(serviceFile, args);
		});
	}

	@Test
	public void whenMultitenant_HasDiscriminator() throws Exception {
		assertDoesNotThrow(() -> {
			File serviceFile = this.loadFile("multitenant/multi-discriminator-good.xml");
			builderService.build(serviceFile, args);
		});
	}
	

}
