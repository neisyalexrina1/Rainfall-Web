package service;

import dao.ServicePackageDAO;
import model.ServicePackage;
import java.util.List;

public class ServicePackageServiceImpl implements ServicePackageService {

    private final ServicePackageDAO servicePackageDAO;

    public ServicePackageServiceImpl() {
        this.servicePackageDAO = new ServicePackageDAO();
    }

    @Override
    public List<ServicePackage> getAllPackages() {
        return servicePackageDAO.getAllPackages();
    }

    @Override
    public ServicePackage getPackageById(int id) {
        return servicePackageDAO.getPackageById(id);
    }
}
