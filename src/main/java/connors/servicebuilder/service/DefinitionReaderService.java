package connors.servicebuilder.service;

import java.io.File;
import java.io.IOException;

import connors.servicebuilder.model.Service;

public interface DefinitionReaderService {
	public Service read (File file) throws IOException;
}
