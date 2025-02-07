package com.github.hwc2243.servicebuilder.service;

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
	public void whenFinder_hasBadColumn () throws Exception
	{
		assertThrows(ServiceException.class, () -> {
			File serviceFile = this.loadFile("bad-finder-attribute.xml");
			builderService.build(serviceFile, args);
		});
	}
}
