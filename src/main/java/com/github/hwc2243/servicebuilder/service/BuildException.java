package com.github.hwc2243.servicebuilder.service;

public class BuildException extends RuntimeException {

	public BuildException() {
		super();
	}

	public BuildException(String message) {
		super(message);
	}

	public BuildException(Throwable cause) {
		super("Build failed", cause);
	}

	public BuildException(String message, Throwable cause) {
		super(message, cause);
	}

	public BuildException(String message, Throwable cause, boolean enableSuppression, boolean writableStackTrace) {
		super(message, cause, enableSuppression, writableStackTrace);
	}
}
