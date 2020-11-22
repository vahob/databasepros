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
    
    public static void setUpConnection() throws Exception {
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
    
    public static void chooseInterface() throws SQLException
    {
        int choice = -1;
        loop:
        while(true)
        {
            System.out.print
            (
                "\nMain Menu:\n" +
                "1. Administrator interface\n" +
                "2. Customer Interface\n" +
                "3. Exit program\n\n" +
                "Enter option: "
            );
            try
            {
                choice = Integer.parseInt(input.nextLine());
            }
            catch(Exception e)
            {
                System.out.print("\nPlease enter a valid option\n");
                continue;
            }
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
                default:
                    System.out.print("\nPlease enter a valid option\n");
                    break;
            }
        }
    }
    
    /*|===========================================================|*/
    /*|                  Administrator Functions                  |*/
    /*|===========================================================|*/
    
    public static void administratorInterface()
    {
        System.out.print("\nYou are now in the administrator interface\n");
        int choice = -1;
        loop:
        while(true)
        {
            System.out.print
            (
                "\nAdministrator Menu:\n" +
                "Enter the number of the option you would like to select:\n" +
                "1. Erase the database\n" +
                "2. Load airline information\n" +
                "3. Load schedule information\n" +
                "4. Load pricing information\n" +
                "5. Load plane information\n" +
                "6. Generate passenger manifest for specific flight on given day\n" +
                "7. Update the current timestamp\n" +
                "8. Return to main menu\n\n" +
                "Enter option: "
            );
            try
            {
                choice = Integer.parseInt(input.nextLine());
            }
            catch(Exception e)
            {
                System.out.print("\nPlease enter a valid option\n");
                continue;
            }
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
                default:
                    System.out.print("\nPlease enter a valid option\n");
                    break;
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
        
        String sql;
        try
        {
            Statement stmt = conn.createStatement();
            sql =
                (
                    "DELETE FROM ourtimestamp;" +
                    "DELETE FROM reservation_detail;" +
                    "DELETE FROM reservation;" +
                    "DELETE FROM customer;" +
                    "DELETE FROM price;" +
                    "DELETE FROM flight;" +
                    "DELETE FROM plane;" +
                    "DELETE FROM airline;"
                );
            stmt.executeUpdate(sql);
            System.out.print("Successfully dropped all tuples from all tables in the database.\n");
            stmt.close();
            return;
        }
        catch (SQLException e)
        {
            e.printStackTrace();
        }
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
    
    public static void customerInterface() throws SQLException
    {
        System.out.print("\nYou are now in the customer interface\n");
        int choice = -1;
        loop:
        while(true)
        {
            System.out.print
            (
                "\nCustomer Menu:\n" +
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
                "14. Return to main menu\n\n" +
                "Enter option: "
            );
            try
            {
                choice = Integer.parseInt(input.nextLine());
            }
            catch(Exception e)
            {
                System.out.print("\nPlease enter a valid option\n");
                continue;
            }
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
                default:
                    System.out.print("\nPlease enter a valid option\n");
                    break;
            }
        }
    }
    
    public static void addCustomer() throws SQLException
    {
        String sql;
        int newCID=0;
        System.out.print
        (
            "In the addCustomer function\n" +
            "Function summary: Add customer\n\n"
        );

       
        System.out.println("All fields are required:");

        System.out.print("salutation (Mr/Mrs/Ms): ");
        String salutation = input.nextLine();

        System.out.print("First name: ");
        String firstName = input.nextLine();

        System.out.print("Last name: ");
        String lastName = input.nextLine();
        
        System.out.print("House num and street name: ");
        String street = input.nextLine();

        System.out.print("City: ");
        String city = input.nextLine();

        System.out.print("State: ");
        String state = input.nextLine();

        System.out.print("Phone number: ");
        String phone = input.nextLine();

        System.out.print("Email address: ");
        String email = input.nextLine();

        System.out.print("Credit card number: ");
        String creditCardNumber = input.nextLine();

        System.out.print("Expiration date: ");
        String expiration = input.nextLine();

        System.out.print("Frequent miles: ");
        String frequentMiles = input.next();
        input.nextLine(); // clears the buffer.
        Statement stmt = conn.createStatement();
        try {

            sql = "SELECT * FROM Customer WHERE first_name = \'" + firstName + "\' AND last_name= \'" + lastName + "\'";
            ResultSet res = stmt.executeQuery(sql);

            if (res.next()) {
                System.out.println("User with name " + firstName + " " + lastName + " already exists.");

                stmt.close();
                return;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        try {
            sql = "SELECT COUNT(*) FROM Customer";
            ResultSet res = stmt.executeQuery(sql);
            if (res.next()) {
                newCID = res.getInt(1);
            }
            newCID++; // next CID;
            sql = "INSERT INTO Customer VALUES(" + newCID + ", \'" + salutation + "\', \'" + firstName + "\', \'"
                    + lastName + "\', \'" + creditCardNumber + "\', TO_DATE(\'" + expiration
                    + "\', 'MM-DD-YYYY'), \'" + street + "\', \'" + city + "\', \'" + state + "\', \'" + phone + "\', \'" + email + "\', \'"
                    + frequentMiles + "\')";

            stmt.executeUpdate(sql);
            stmt.close();
            System.out.println("ID " + newCID + " was added successfully.");

        } catch (SQLException e) {
            System.out.println("");
            e.printStackTrace();
        }
    }
    
    public static void showCustomerInfo() throws SQLException {
        String sql;
        System.out.println(
                "In the showCustomerInfo function\n" + "Function summary: Show customer info, given customer name\n\n");

        System.out.println("Enter customer's first and last name.");
        System.out.print("First name: ");
        String firstName = input.next();

        System.out.print("Last name: ");
        String lastName = input.next();
        input.nextLine(); // clear the buffer.
        Statement stmt = conn.createStatement();
        try {

            sql = "SELECT * FROM Customer WHERE first_name = \'" + firstName + "\' AND last_name= \'" + lastName + "\'";
            ResultSet res = stmt.executeQuery(sql);

            if (res.next()) {
                System.out.println("\nINFO:\n" + res.getString(2) + ". " + res.getString(3) + " " + res.getString(4)
                        + "\n" + "Credit card number: " + res.getString(5) + "\n" + "Expiration: " + res.getString(6)
                        + "\n" + "Address: " + res.getString(7) + ", " + res.getString(8) + ", " + res.getString(9)
                        + "\n" + "Phone: " + res.getString(10) + "\n" + "Email: " + res.getString(11) + "\n"
                        + "Frequent Miles: " + res.getString(12));

                stmt.close();
                return;
            }
            else
            {
                System.out.println("Customer with this name does not exist in the database.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    public static void findPrice() throws SQLException {
        String sql, cityA, cityB;
        int high_price1=0;
        int high_price2=0;
        int low_price1=0;
        int low_price2 = 0;
        System.out.print(
                "In the findPrice function\n" + "Function summary: Find price for flights between two cities\n\n");
        do {
            System.out.println("Enter the names of two cities -- 3 letters.");
            System.out.print("First city: ");
            cityA = input.next();

            System.out.print("Second city: ");
            cityB = input.next();
        } while (cityA.length() != 3 && cityB.length() != 3);
        input.nextLine(); // clears the buffer.
        Statement stmt = conn.createStatement();
        try {
            sql = "SELECT high_price, low_price FROM Price " +
                    "WHERE departure_city = \'" + cityA + "\' AND arrival_city = \'" + cityB + "\';";
            ResultSet res = stmt.executeQuery(sql);
            if(res.next())
            {
                System.out.println("\nOne-way " + cityA + " --> " + cityB);
                System.out.println("High price: " + res.getInt(1));
                System.out.println("Low price: " + res.getInt(2));
                high_price1 = res.getInt(1);
                low_price1 = res.getInt(2);
            }
            else
            {
                System.out.println("\nPrice for " + cityA + " --> " + cityB + " doesn't exist");
            }

            sql = "SELECT high_price, low_price FROM Price " +
                    "WHERE departure_city = \'" + cityB + "\' AND arrival_city = \'" + cityA + "\';";
            res = stmt.executeQuery(sql);
            if(res.next())
            {
                System.out.println("\nOne-way " + cityB + " --> " + cityA);
                System.out.println("High price: " + res.getInt(1));
                System.out.println("Low price: " + res.getInt(2));
                high_price2 = res.getInt(1);
                low_price2 = res.getInt(2);
            }
            else
            {
                System.out.println("\nPrice for " + cityB + " --> " + cityA + " doesn't exist");
            }

            System.out.println("\nRound Trip " + cityA + " --> " + cityB);
                System.out.println("High price: " + (high_price1+high_price2));
                System.out.println("Low price: " + (low_price1+low_price2));            
            
        } catch(SQLException e)
        {
            e.printStackTrace();
        }
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