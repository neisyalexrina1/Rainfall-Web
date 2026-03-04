package model;

import jakarta.persistence.*;

@Entity
@Table(name = "ServicePackages")
public class ServicePackage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "PackageID")
    private int packageID;

    @Column(name = "PackageName", length = 50)
    private String packageName;

    @Column(name = "DurationMonths")
    private int durationMonths;

    @Column(name = "Price")
    private double price;

    public ServicePackage() {
    }

    public ServicePackage(int packageID, String packageName, int durationMonths, double price) {
        this.packageID = packageID;
        this.packageName = packageName;
        this.durationMonths = durationMonths;
        this.price = price;
    }

    public int getPackageID() {
        return packageID;
    }

    public void setPackageID(int packageID) {
        this.packageID = packageID;
    }

    public String getPackageName() {
        return packageName;
    }

    public void setPackageName(String packageName) {
        this.packageName = packageName;
    }

    public int getDurationMonths() {
        return durationMonths;
    }

    public void setDurationMonths(int durationMonths) {
        this.durationMonths = durationMonths;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }
}
