package com.github.hwc2243.servicebuilder.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.io.File;

import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

import com.github.hwc2243.servicebuilder.model.Service;

public class DefinitionReaderServiceTest {
	
	protected static Logger logger = LoggerFactory.getLogger(DefinitionReaderServiceTest.class);

	protected DefinitionReaderService definitionReaderService = null;
	
	public DefinitionReaderServiceTest () throws SAXException
	{
		this.definitionReaderService = new DefinitionReaderServiceImpl();
	}
	
	@Test
	public void whenSimpleService_isValid () {
		File file = loadFile("simple-service.xml");
		assertThat(file).isNotNull();
		assertDoesNotThrow(() -> {
			Service service = definitionReaderService.read(file);
			assertThat(service).isNotNull();
		});
	}
	
	@Test
	public void whenSimpleService_noServiceName () {
		File file = loadFile("noservicename-service.xml");
		assertThat(file).isNotNull();
		assertThrows(
		           SAXParseException.class,
		           () -> { 
		        	   definitionReaderService.read(file);
		           });
	}
	
	@Test
	public void whenSimpleService_noPackage () {
		File file = loadFile("nopackage-service.xml");
		assertThat(file).isNotNull();
		assertThrows(
		           SAXParseException.class,
		           () -> { 
		        	   definitionReaderService.read(file);
		           });
	}

	@Test
	public void whenFinderService_isValid () {
		File file = loadFile("finder-service.xml");
		assertThat(file).isNotNull();
		assertDoesNotThrow(() -> {
			Service service = definitionReaderService.read(file);
			assertThat(service).isNotNull();
		});
	}
	
	@Test
	public void multiEntityService_isValid () {
		File file = loadFile("multientity-service.xml");
		assertThat(file).isNotNull();
		assertDoesNotThrow(() -> {
			Service service = definitionReaderService.read(file);
			assertThat(service).isNotNull();
		});
	}
	
	@Test
	public void whenFullService_isValid () {
		File file = loadFile("full-service.xml");
		assertThat(file).isNotNull();
		assertDoesNotThrow(() -> {
			Service service = definitionReaderService.read(file);
			assertThat(service).isNotNull();
		});
	}

	protected File loadFile (String filename)
	{
		return new File(getClass().getClassLoader().getResource(filename).getFile());
	}
}
