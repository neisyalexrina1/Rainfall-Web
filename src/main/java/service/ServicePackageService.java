package service;

import model.ServicePackage;
import java.util.List;

public interface ServicePackageService {
    List<ServicePackage> getAllPackages();

    ServicePackage getPackageById(int id);
}
