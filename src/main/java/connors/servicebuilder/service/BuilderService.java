package connors.servicebuilder.service;

import java.io.IOException;

import connors.servicebuilder.model.Service;

public interface BuilderService {
	public void build (Service service, BuilderArgs args) throws IOException;
}
