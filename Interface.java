import java.util.*;
import java.sql.*;

public class Interface
{
    static Connection conn;
    static Scanner input = new Scanner(System.in);
    
    public static void main(String args[]) throws Exception
    {
        setUpConnection();
        chooseInterface();
        System.exit(0);
    }
    
    /*|===========================================================|*/
    /*|                          Setup                            |*/
    /*|===========================================================|*/
    
    public static void setUpConnection() throws Exception
    {
        Class.forName("org.postgresql.Driver");
        String url = "jdbc:postgresql://localhost/FinalProject";
        Properties props = new Properties();
        props.setProperty("user", "postgres");
        props.setProperty("password", "postgres");
        conn = DriverManager.getConnection(url, props);
    }
    
    /*|===========================================================|*/
    /*|                        Main Loop                          |*/
    /*|===========================================================|*/
    
    public static void chooseInterface()
    {
        int choice = -1;
        loop:
        while(true)
        {
            System.out.print
            (
                "Enter the number of the option you would like to select:\n" +
                "1. Administrator interface\n" +
                "2. Customer Interface\n" +
                "3. Exit program\n"
            );
            choice = Integer.parseInt(input.nextLine());
            switch(choice)
            {
                case 1:
                    administratorInterface();
                    break;
                case 2:
                    customerInterface();
                    break;
                case 3:
                    break loop;
            }
        }
    }
    
    /*|===========================================================|*/
    /*|                  Administrator Functions                  |*/
    /*|===========================================================|*/
    
    public static void administratorInterface()
    {
        System.out.print("You are now in the administrator interface\n\n");
        int choice = -1;
        loop:
        while(true)
        {
            System.out.print
            (
                "Enter the number of the option you would like to select:\n" +
                "1. Erase the database\n" +
                "2. Load airline information\n" +
                "3. Load schedule information\n" +
                "4. Load pricing information\n" +
                "5. Load plane information\n" +
                "6. Generate passenger manifest for specific flight on given day\n" +
                "7. Update the current timestamp\n" +
                "8. Return to main menu\n"
            );
            choice = Integer.parseInt(input.nextLine());
            switch(choice)
            {
                case 1:
                    eraseDatabase();
                    break;
                case 2:
                    loadAirlineInformation();
                    break;
                case 3:
                    loadScheduleInformation();
                    break;
                case 4:
                    loadPricingInformation();
                    break;
                case 5:
                    loadPlaneInformation();
                    break;
                case 6:
                    generatePassengerManifest();
                    break;
                case 7:
                    updateCurrentTimestamp();
                    break;
                case 8:
                    break loop;
            }
        }
    }
    
    public static void eraseDatabase()
    {
        System.out.print
        (
            "In the eraseDatabse function\n" +
            "Function summary: Erase the database\n\n"
        );
    }
    
    public static void loadAirlineInformation()
    {
        System.out.print
        (
            "In the loadAirlineInformation function\n" +
            "Function summary: Load airline information\n\n"
        );
    }
    
    public static void loadScheduleInformation()
    {
        System.out.print
        (
            "In the loadScheduleInformation function\n" +
            "Function summary: Load schedule information\n\n"
        );
    }
    
    public static void loadPricingInformation()
    {
        System.out.print
        (
            "In the loadPricingInformation function\n" +
            "Function summary: Load pricing information\n\n"
        );
    }
    
    public static void loadPlaneInformation()
    {
        System.out.print
        (
            "In the loadPlaneInformation function\n" +
            "Function summary: Load plane information\n\n"
        );
    }
    
    public static void generatePassengerManifest()
    {
        System.out.print
        (
            "In the generatePassengerManifest function\n" +
            "Function summary: Generate passenger manifest for specific flight on given day\n\n"
        );
    }
    
    public static void updateCurrentTimestamp()
    {
        System.out.print
        (
            "In the updateCurrentTimestamp function\n" +
            "Function summary: Update the current timestamp\n\n"
        );
    }
    
    /*|===========================================================|*/
    /*|                End Of Administrator Fuctions              |*/
    /*|===========================================================|*/
    
    /*|===========================================================|*/
    /*|                     Customer Functions                    |*/
    /*|===========================================================|*/
    
    public static void customerInterface()
    {
        System.out.print("You are now in the customer interface\n\n");
        int choice = -1;
        loop:
        while(true)
        {
            System.out.print
            (
                "Enter the number of the option you would like to select:\n" +
                "1. Add customer\n" +
                "2. Show customer info, given customer name\n" +
                "3. Find price for flights between two cities\n" +
                "4. Find all routes between two cities\n" +
                "5. Find all routes between two cities of a given airline\n" +
                "6. Find all routes with available seats between two cities on a given date\n" +
                "7. Add reservation\n" +
                "8. Delete reservation\n" +
                "9. Show reservation info, given reservation number\n" +
                "10. Buy ticket from existing reservation\n" +
                "11. Find the top-k customers for each airline\n" +
                "12. Find the top-k traveled customers for each airline\n" +
                "13. Rank the airlines based on customer satisfaction\n" +
                "14. Return to main menu\n"
            );
            choice = Integer.parseInt(input.nextLine());
            switch(choice)
            {
                case 1:
                    addCustomer();
                    break;
                case 2:
                    showCustomerInfo();
                    break;
                case 3:
                    findPrice();
                    break;
                case 4:
                    findAllRoutes();
                    break;
                case 5:
                    findAllRoutesForGivenAirline();
                    break;
                case 6:
                    findAllUnfilledFlightsOnGivenDate();
                    break;
                case 7:
                    addReservation();
                    break;
                case 8:
                    deleteReservation();
                    break;
                case 9:
                    showReservationInfo();
                    break;
                case 10:
                    buyTicketFromReservation();
                    break;
                case 11:
                    findTopPayingCustomers();
                    break;
                case 12:
                    findTopTravelledCustomers();
                    break; 
                case 13:
                    rankAirlines();
                    break;
                case 14:
                    break loop;
            }
        }
    }
    
    public static void addCustomer()
    {
        System.out.print
        (
            "In the addCustomer function\n" +
            "Function summary: Add customer\n\n"
        );
    }
    
    public static void showCustomerInfo()
    {
        System.out.print
        (
            "In the showCustomerInfo function\n" +
            "Function summary: Show customer info, given customer name\n\n"
        );
    }
    
    public static void findPrice()
    {
        System.out.print
        (
            "In the findPrice function\n" +
            "Function summary: Find price for flights between two cities\n\n"
        );
    }
    
    public static void findAllRoutes()
    {
        System.out.print
        (
            "In the findAllRoutes function\n" +
            "Function summary: Find all routes between two cities\n\n"
        );
    }
    
    public static void findAllRoutesForGivenAirline()
    {
        System.out.print
        (
            "In the findAllRoutesForGivenAirline function\n" +
            "Function summary: Find all routes between two cities of a given airline\n\n"
        );
    }
    
    public static void findAllUnfilledFlightsOnGivenDate()
    {
        System.out.print
        (
            "In the findAllUnfilledFlightsOnGivenDate function\n" +
            "Function summary: Find all routes with available seats between two cities on a given date\n\n"
        );
    }
    
    public static void addReservation()
    {
        System.out.print
        (
            "In the addReservation function\n" +
            "Function summary: Add reservation\n\n"
        );
    }
    
    public static void deleteReservation()
    {
        System.out.print
        (
            "In the deleteReservation function\n" +
            "Function summary: Delete reservation\n\n"
        );
    }
    
    public static void showReservationInfo()
    {
        System.out.print
        (
            "In the showReservationInfo function\n" +
            "Function summary: Show reservation info, given reservation number\n\n"
        );
    }
    
    public static void buyTicketFromReservation()
    {
        System.out.print
        (
            "In the buyTicketFromReservation function\n" +
            "Function summary: Buy ticket from existing reservation\n\n"
        );
    }
    
    public static void findTopPayingCustomers()
    {
        System.out.print
        (
            "In the findTopPayingCustomers function\n" +
            "Function summary: Find the top-k customers for each airline\n\n"
        );
    }
    
    public static void findTopTravelledCustomers()
    {
        System.out.print
        (
            "In the findTopTravelledCustomers function\n" +
            "Function summary: Find the top-k traveled customers for each airline\n\n"
        );
    }
    
    public static void rankAirlines()
    {
        System.out.print
        (
            "In the rankAirlines function\n" +
            "Function summary: Rank the airlines based on customer satisfaction\n\n"
        );
    }

    /*|===========================================================|*/
    /*|                  End Of Customer Fuctions                 |*/
    /*|===========================================================|*/
    
}