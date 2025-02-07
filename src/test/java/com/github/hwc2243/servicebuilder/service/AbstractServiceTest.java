package com.github.hwc2243.servicebuilder.service;

import java.io.File;

public abstract class AbstractServiceTest {

	public AbstractServiceTest() {
	}

	protected File loadFile (String filename)
	{
		return new File(getClass().getClassLoader().getResource(filename).getFile());
	}
}
