package ${eventPackage};

public interface ServiceEventBus {
  void publish(ServiceEvent event);
}
