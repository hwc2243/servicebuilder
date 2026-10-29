package com.github.hwc2243.servicebuilder.service;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
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
	public void whenKeyOnlyRelationship_isGeneratedAsKey() throws Exception {
		testService("key-only-service.xml");

		Path generatedRoot = Paths.get(TMPDIR, "test", "key_only");
		String entity = Files.readString(generatedRoot.resolve("entity/base/BaseRallyEntity.java"));
		String model = Files.readString(generatedRoot.resolve("model/base/BaseRally.java"));
		String dto = Files.readString(generatedRoot.resolve("dto/base/BaseRallyDTO.java"));

		assertTrue(entity.contains("protected Long userId"));
		assertTrue(entity.contains("Long getUserId ()"));
		assertTrue(entity.contains("void setUserId (Long userId)"));
		assertFalse(entity.contains("UserEntity user"));
		assertTrue(model.contains("Long getUserId ();"));
		assertTrue(dto.contains("protected Long userId"));
		assertTrue(dto.contains("Long getUserId ()"));
	}

	@Test
	public void whenKeyOnlyCollection_isRejected() throws Exception {
		assertThrows(BuildException.class, () -> {
			File serviceFile = loadFile("key-only-collection-service.xml");
			builderService.build(serviceFile, args);
		});
	}

	@Test
	public void whenKeyOnlyMatchesTenantDiscriminator_isGeneratedOnce() throws Exception {
		args.setOutputDir("/tmp/servicebuilder-key-only-discriminator-build");
		Service serviceDefinition = definitionReaderService.read(
				loadFile("multitenant/key-only-discriminator-service.xml"));
		builderService.build(serviceDefinition, args);
		runCompile("/tmp/servicebuilder-key-only-discriminator-build/com/rallyapp/rallymaster");

		Path generatedRoot = Paths.get("/tmp/servicebuilder-key-only-discriminator-build",
				"com", "rallyapp", "rallymaster");
		String entity = Files.readString(
				generatedRoot.resolve("entity/base/BaseOrganizationMembershipEntity.java"));
		String persistence = Files.readString(generatedRoot.resolve(
				"persistence/base/BaseOrganizationMembershipPersistence.java"));
		String service = Files.readString(generatedRoot.resolve(
				"service/base/BaseOrganizationMembershipService.java"));

		assertTrue(entity.contains("protected Long organizationId = null;"));
		assertFalse(entity.contains("protected Long organizationIdId"));
		assertFalse(entity.contains("OrganizationEntity organization"));
		assertEquals(1, entity.lines()
				.filter(line -> line.contains("protected Long organizationId = null;"))
				.count());
		assertTrue(persistence.contains("findByUserId(Long userId)"));
		assertFalse(persistence.contains("findByOrganizationIdAndUserId"));
		assertTrue(service.contains("findByUserId (Long userId)"));
		assertFalse(service.contains("findByOrganizationIdAndUserId"));
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
	public void whenEvents_areGenerated() throws Exception {
		testService("simple-service.xml");

		Path generatedRoot = Paths.get(TMPDIR, "test", "simple");
		String event = Files.readString(generatedRoot.resolve("service/event/EntityCrudEvent.java"));
		String serviceImpl = Files.readString(generatedRoot.resolve("service/base/BaseSimpleServiceImpl.java"));

		assertTrue(event.contains("public final class EntityCrudEvent<T> implements ServiceEvent"));
		assertTrue(serviceImpl.contains("@Autowired(required = false)"));
		assertTrue(serviceImpl.contains("import org.springframework.transaction.annotation.Transactional;"));
		assertEquals(3, serviceImpl.lines().filter(line -> line.trim().equals("@Transactional")).count());
		assertTrue(serviceImpl.contains("publishCrudEvent(CrudOperation.CREATED, savedDto)"));
		assertTrue(serviceImpl.contains("publishCrudEvent(CrudOperation.UPDATED, savedDto)"));
		assertTrue(serviceImpl.contains("publishCrudEvent(CrudOperation.DELETED, deletedDto)"));
		String eventBus = Files.readString(generatedRoot.resolve("service/event/SpringServiceEventBus.java"));
		assertTrue(eventBus.contains("publisher.publishEvent(event);"));
		assertFalse(eventBus.contains("@TransactionalEventListener"));
	}

	@Test
	public void whenClientBuildType_isSelected_onlyClientCodeIsGenerated() throws Exception {
		args.setBuildType(BuilderArgs.BuildType.CLIENT);
		args.setOutputDir("/tmp/servicebuilder-client-build");
		builderService.build(loadFile("simple-service.xml"), args);

		Path generatedRoot = Paths.get("/tmp/servicebuilder-client-build", "test", "simple");
		assertTrue(Files.exists(generatedRoot.resolve("client/model/Simple.java")));
		assertFalse(Files.exists(generatedRoot.resolve("entity/base/BaseSimpleEntity.java")));
	}

	@Test
	public void whenServerBuildType_isSelected_onlyServerCodeIsGenerated() throws Exception {
		args.setBuildType(BuilderArgs.BuildType.SERVER);
		args.setOutputDir("/tmp/servicebuilder-server-build");
		builderService.build(loadFile("simple-service.xml"), args);

		Path generatedRoot = Paths.get("/tmp/servicebuilder-server-build", "test", "simple");
		assertTrue(Files.exists(generatedRoot.resolve("entity/base/BaseSimpleEntity.java")));
		assertFalse(Files.exists(generatedRoot.resolve("client/model/Simple.java")));
	}

	@Test
	public void whenBuilderArgs_areCreated_javaIsTheDefaultBuildLanguage() {
		BuilderArgs builderArgs = new BuilderArgs();

		assertEquals(BuilderArgs.BuildLang.JAVA, builderArgs.getBuildLang());
		assertEquals(BuilderArgs.BuildLang.JAVA,
				builderArgs.new BuildLangConverter().convert("java"));
	}

	@Test
	public void whenFlutterClientBuild_isSelected_modelsAreGenerated() throws Exception {
		args.setBuildLang(BuilderArgs.BuildLang.FLUTTER);
		args.setBuildType(BuilderArgs.BuildType.CLIENT);
		args.setOutputDir("/tmp/servicebuilder-flutter-build");
		builderService.build(loadFile("simple-service.xml"), args);

		Path model = Paths.get("/tmp/servicebuilder-flutter-build", "lib/models/simple_dto.dart");
		String source = Files.readString(model);
		assertTrue(source.contains("class SimpleDto"));
		assertTrue(source.contains("final int? id;"));
		assertTrue(source.contains("final int? serverId;"));
		assertTrue(source.contains("json['id'] as int?"));
		assertFalse(Files.exists(Paths.get("/tmp/servicebuilder-flutter-build",
				"lib/providers/simple_provider.dart")));
	}

	@Test
	public void whenFlutterTenantBuild_isSelected_runtimeTenantProvidersAreGenerated() throws Exception {
		args.setBuildLang(BuilderArgs.BuildLang.FLUTTER);
		args.setBuildType(BuilderArgs.BuildType.CLIENT);
		args.setOutputDir("/tmp/servicebuilder-flutter-tenant-provider-build");
		builderService.build(loadFile("multitenant/key-only-discriminator-service.xml"), args);

		Path providerRoot = Paths.get("/tmp/servicebuilder-flutter-tenant-provider-build", "lib/providers");
		String tenantProvider = Files.readString(providerRoot.resolve("tenant_discriminator_provider.dart"));
		assertTrue(tenantProvider.contains("class TenantDiscriminatorProvider extends ChangeNotifier"));
		assertTrue(tenantProvider.contains("int? get organizationId"));
		assertTrue(tenantProvider.contains("setOrganizationId"));

		assertFalse(Files.exists(providerRoot.resolve("organization_membership_provider.dart")));
	}

	@Test
	public void whenFlutterExternalApi_isConfigured_providerMethodsAndHttpClientAreGenerated() throws Exception {
		args.setBuildLang(BuilderArgs.BuildLang.FLUTTER);
		args.setBuildType(BuilderArgs.BuildType.CLIENT);
		args.setOutputDir("/tmp/servicebuilder-flutter-api-build");
		builderService.build(loadFile("api-service.xml"), args);

		Path providerRoot = Paths.get("/tmp/servicebuilder-flutter-api-build", "lib/providers");
		String provider = Files.readString(providerRoot.resolve("widget_provider.dart"));
		assertTrue(provider.contains("Future<WidgetDto?> get(int serverId)"));
		assertTrue(provider.contains("Future<List<WidgetDto>> list()"));
		assertTrue(provider.contains("Future<List<WidgetDto>> search("));
		assertTrue(provider.contains("Future<List<WidgetDto>> search()"));
		assertFalse(provider.contains("Future<WidgetDto> update("));
		assertFalse(provider.contains("Future<void> delete("));
		assertTrue(provider.contains("'/api/external/widget'"));
		assertTrue(Files.exists(Paths.get("/tmp/servicebuilder-flutter-api-build",
				"lib/network/service_builder_http_client.dart")));
		assertTrue(Files.exists(Paths.get("/tmp/servicebuilder-flutter-api-build",
				"lib/network/service_builder_http_exception.dart")));
	}

	@Test
	public void whenFlutterTenantModel_hasKeyOnlyTenantRelation_organizationIdIsGeneratedOnce() throws Exception {
		args.setBuildLang(BuilderArgs.BuildLang.FLUTTER);
		args.setBuildType(BuilderArgs.BuildType.CLIENT);
		args.setOutputDir("/tmp/servicebuilder-flutter-tenant-build");
		builderService.build(loadFile("multitenant/key-only-discriminator-service.xml"), args);

		Path model = Paths.get("/tmp/servicebuilder-flutter-tenant-build",
				"lib/models/organization_membership_dto.dart");
		String source = Files.readString(model);
		assertEquals(1, source.lines()
				.filter(line -> line.trim().equals("this.organizationId,"))
				.count());
		String tenantCopy = source.substring(source.indexOf("forOrganizationId"), source.indexOf("Map<String, dynamic> toJson"));
		assertEquals(1, tenantCopy.lines()
				.filter(line -> line.contains("organizationId:"))
				.count());
		assertFalse(Files.exists(Paths.get("/tmp/servicebuilder-flutter-tenant-build",
				"lib/models/OrganizationMembershipDto.dart")));
	}

	@Test
	public void whenFlutterServerBuild_isSelected_isRejected() throws Exception {
		args.setBuildLang(BuilderArgs.BuildLang.FLUTTER);
		args.setBuildType(BuilderArgs.BuildType.SERVER);

		assertThrows(BuildException.class, () -> builderService.build(loadFile("simple-service.xml"), args));
	}

	@Test
	public void whenInternalAndExternalApis_areGenerated() throws Exception {
		File serviceFile = loadFile("api-service.xml");
		builderService.build(serviceFile, args);

		Path generatedRoot = Paths.get(TMPDIR, "test", "api");
		assertTrue(Files.exists(generatedRoot.resolve("api/internal/base/BaseInternalWidgetRest.java")));
		assertTrue(Files.exists(generatedRoot.resolve("api/internal/base/BaseInternalWidgetRestImpl.java")));
		assertTrue(Files.exists(generatedRoot.resolve("api/internal/InternalWidgetRest.java")));
		assertTrue(Files.exists(generatedRoot.resolve("api/internal/InternalWidgetRestImpl.java")));
		assertTrue(Files.exists(generatedRoot.resolve("api/external/base/BaseExternalWidgetRest.java")));
		assertTrue(Files.exists(generatedRoot.resolve("api/external/base/BaseExternalWidgetRestImpl.java")));
		assertTrue(Files.exists(generatedRoot.resolve("api/external/ExternalWidgetRest.java")));
		assertTrue(Files.exists(generatedRoot.resolve("api/external/ExternalWidgetRestImpl.java")));
	}

	@Test
	public void whenUniqueFinder_hasRelationships_usesJoinColumns() throws Exception {
		testService("unique-related-finder-service.xml");

		Path generatedRoot = Paths.get(TMPDIR, "test", "unique_related_finder");
		String entity = Files.readString(generatedRoot.resolve("entity/AttendanceEntity.java"));

		assertTrue(entity.contains("\"member_id\""));
		assertTrue(entity.contains("\"meeting_id\""));
		assertFalse(entity.contains("\"member\""));
		assertFalse(entity.contains("\"meeting\""));
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
