package com.github.hwc2243.servicebuilder.service;

import java.io.File;
import java.io.IOException;

import com.github.hwc2243.servicebuilder.model.Service;

public interface BuilderService {
	
	public void build (BuilderArgs args) throws ServiceException, IOException;

	public void build (File file, BuilderArgs args) throws ServiceException, IOException;
	
	public void build (Service service, BuilderArgs args) throws ServiceException, IOException;
}
