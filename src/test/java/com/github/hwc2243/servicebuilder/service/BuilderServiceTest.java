package com.github.hwc2243.servicebuilder.service;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.io.File;

import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.SAXException;

public class BuilderServiceTest extends AbstractServiceTest {

	protected static Logger logger = LoggerFactory.getLogger(BuilderServiceTest.class);

	protected BuilderService builderService;
	
	protected BuilderArgs args;
	
	public BuilderServiceTest() throws SAXException {
		builderService = new BuilderServiceImpl();
		
		args = new BuilderArgs();
		args.setClean(true);
		args.setReplace(true);
		args.setOutputDir("/tmp");
	}

	@Test
	public void whenSimple_isGood () throws Exception
	{
		File serviceFile = this.loadFile("simple-service.xml");
		builderService.build(serviceFile, args);
	}
	
	@Test
	public void whenFinder_hasBadColumn () throws Exception
	{
		assertThrows(ServiceException.class, () -> {
			File serviceFile = this.loadFile("bad-finder-attribute.xml");
			builderService.build(serviceFile, args);
		});
	}
	
	@Test
	public void whenBidirectionalRelationship_isGood () throws Exception
	{
		File serviceFile = this.loadFile("related/many-to-many-bi-good.xml");
		builderService.build(serviceFile, args);
	}
	
	@Test
	public void whenBidirectionalRelationship_hasBadRelated () throws Exception
	{
		assertThrows(ServiceException.class, () -> {
			File serviceFile = this.loadFile("related/many-to-many-bi-bad-related.xml");
			builderService.build(serviceFile, args);
		});
	}
	
	@Test
	public void whenBidirectionalRelationship_hasBadMappedBy () throws Exception
	{
		assertThrows(ServiceException.class, () -> {
			File serviceFile = this.loadFile("related/many-to-many-bi-no-mapped-by.xml");
			builderService.build(serviceFile, args);
		});
		
		assertThrows(ServiceException.class, () -> {
			File serviceFile = this.loadFile("related/many-to-many-bi-both-mapped-by.xml");
			builderService.build(serviceFile, args);
		});

		assertThrows(ServiceException.class, () -> {
			File serviceFile = this.loadFile("related/many-to-many-bi-wrong-mapped-by.xml");
			builderService.build(serviceFile, args);
		});

	}
	
	@Test
	public void whenUnidirectionalRelationship_isGood () throws Exception
	{
		File serviceFile = this.loadFile("related/many-to-many-uni-good.xml");
		builderService.build(serviceFile, args);
	}
	
	@Test
	public void whenMultitenant_NoDiscriminator () throws Exception
	{
		assertThrows(ServiceException.class, () -> {
			File serviceFile = this.loadFile("multitenant/multi-no-discriminator.xml");
			builderService.build(serviceFile, args);
		});
	}
	
	@Test
	public void whenNoMultitenant_HasDiscriminator () throws Exception
	{
		assertThrows(ServiceException.class, () -> {
			File serviceFile = this.loadFile("multitenant/no-multi-discriminator.xml");
			builderService.build(serviceFile, args);
		});
	}
	
	@Test
	public void whenMultitenant_HasDiscriminator () throws Exception
	{
		assertDoesNotThrow(() -> {
			File serviceFile = this.loadFile("multitenant/multi-discriminator-good.xml");
			builderService.build(serviceFile, args);
		});
	}
}
