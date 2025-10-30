package ${clientBaseRestPackage};

import ${clientBaseRestPackage}.HeaderProvider;

import com.google.gson.Gson;

import java.io.IOException;

import java.lang.reflect.Type;

import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;

public abstract class AbstractRestClient {

	protected Gson gson = new Gson();

    @Autowired
    protected HeaderProvider headerProvider;
    
	public AbstractRestClient() {
	}

	protected Map<String, String> getHeaders ()
	{
	    return headerProvider.get();
	};
	
	protected <T> T doGet (String hostPath, String apiPath, Class<T> targetClass) throws IOException, InterruptedException {
		/*
		HttpClient client = HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).build();
		HttpRequest.Builder requestBuilder = HttpRequest.newBuilder()
				.uri(java.net.URI.create("http://localhost:8080" + apiPath))
				.GET();
		
		Map<String, String> headers = getHeaders();
		if (headers != null && !headers.isEmpty()) {
		    headers.forEach(requestBuilder::header); 
		}
		
		if (applicationModel.getOrganizationId() > -1) {
            String orgId = String.valueOf(applicationModel.getOrganizationId());
            requestBuilder.header("organization_id", orgId);
			requestBuilder.header("Authorization", "Bearer " + applicationModel.getTokenResponse().access_token());
            System.out.println("API Call with organization-id: " + orgId);
        }
        */
        
		HttpRequest request	= createGet(hostPath, apiPath);

		HttpClient client = HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).build();
		HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

		if (response.statusCode() == 200) {
			T result = gson.fromJson(response.body(), targetClass);
			return result;
		} else {
			throw new IOException("API Call Failed. Status: " + response.statusCode() + "\nResponse Body:\n" + response.body());
			// Return error status and body
		}
	}
	
	public <T> T doGet (String hostPath, String apiPath, Type targetType) throws IOException, InterruptedException {
        
        /*
        HttpRequest.Builder requestBuilder = HttpRequest.newBuilder()
            .uri(java.net.URI.create("http://localhost:8080" + apiPath))
            .header("Authorization", "Bearer " + applicationModel.getTokenResponse().access_token())
            .GET();

        if (applicationModel.getOrganizationId() > -1) {
            String orgId = String.valueOf(applicationModel.getOrganizationId());
            requestBuilder.header("organization_id", orgId);
            System.out.println("API Call with organization-id: " + orgId);
        }
        */

		HttpRequest request	= createGet(hostPath, apiPath);

		HttpClient client = HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).build();
        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

        if (response.statusCode() == 200) {
            // Use Type (captured by TypeToken) for correct generic deserialization
            T result = gson.fromJson(response.body(), targetType);
            return result;
        } else {
            throw new IOException(String.format(
                "API Call Failed. Status: %d. Response Body: %s", 
                response.statusCode(), 
                response.body()
            ));
        }
	}
	
	protected HttpRequest createGet (String hostPath, String apiPath)
	{
	    HttpClient client = HttpClient.newBuilder().version(HttpClient.Version.HTTP_1_1).build();
		HttpRequest.Builder requestBuilder = HttpRequest.newBuilder()
				.uri(java.net.URI.create(hostPath + apiPath))
				.GET();
		
		Map<String, String> headers = getHeaders();
		if (headers != null && !headers.isEmpty()) {
		    headers.forEach(requestBuilder::header); 
		}
		
		return requestBuilder.build();
	}
}
