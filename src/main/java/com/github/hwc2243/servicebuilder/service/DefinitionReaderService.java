package com.github.hwc2243.servicebuilder.service;

import java.io.File;
import java.io.IOException;

import org.xml.sax.SAXException;

import com.github.hwc2243.servicebuilder.model.Service;

public interface DefinitionReaderService {
	public Service read (File file) throws IOException, SAXException;
}
