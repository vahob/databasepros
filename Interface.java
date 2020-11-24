import java.util.*;
import java.io.*;
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
        catch(SQLException e)
        {
            e.printStackTrace();
        }
    }
    
    public static void loadAirlineInformation()
    {
        System.out.print
        (
            "In the loadAirlineInformation function\n" +
            "Function summary: Load airline information\n\n" +
            "Please enter the name of the file to be loaded:"
        );
        Scanner inputFile;
        while(true)
        {
            try
            {
                inputFile = new Scanner(new File(input.nextLine()));
                break;
            }
            catch(Exception e)
            {
                System.out.print("\nCould not find file. Please enter the name of a valid file to be loaded:");
                continue;
            }
        }
        while(inputFile.hasNext())
        {
            String[] tokens = inputFile.nextLine().split("\t");
            try
            {
                Statement stmt = conn.createStatement();
                String sql =
                    (
                        "INSERT INTO AIRLINE VALUES (" +
                        Integer.parseInt(tokens[0]) + ", " +
                        "\'" + tokens[1] + "\', " +
                        "\'" + tokens[2] + "\', " +
                        Integer.parseInt(tokens[3]) +
                        ");"
                    );
                stmt.executeUpdate(sql);
                stmt.close();
            }
            catch(SQLException e)
            {
                e.printStackTrace();
            }
        }
        inputFile.close();
        System.out.print("Load complete.\n");
    }
    
    public static void loadScheduleInformation()
    {
        System.out.print
        (
            "In the loadScheduleInformation function\n" +
            "Function summary: Load schedule information\n\n" +
            "Please enter the name of the file to be loaded:"
        );
		Scanner inputFile;
        while(true)
        {
            try
            {
                inputFile = new Scanner(new File(input.nextLine()));
                break;
            }
            catch(Exception e)
            {
                System.out.print("\nCould not find file. Please enter the name of a valid file to be loaded:");
                continue;
            }
        }
        while(inputFile.hasNext())
        {
            String[] tokens = inputFile.nextLine().split("\t");
            try
            {
                Statement stmt = conn.createStatement();
                String sql =
                    (
                        "INSERT INTO FLIGHT VALUES (" +
                        Integer.parseInt(tokens[0]) + ", " +
						Integer.parseInt(tokens[1]) + ", " +
                        "\'" + tokens[2] + "\', " +
                        "\'" + tokens[3] + "\', " +
                        "\'" + tokens[4] + "\', " +
                        "\'" + tokens[5] + "\', " +
                        "\'" + tokens[6] + "\', " +
                        "\'" + tokens[7] + "\'" +
                        ");"
                    );
                stmt.executeUpdate(sql);
                stmt.close();
            }
            catch(SQLException e)
            {
                e.printStackTrace();
            }
        }
        inputFile.close();
        System.out.print("Load complete.\n");
    }
    
    public static void loadPricingInformation()
    {
        System.out.print
        (
            "In the loadPricingInformation function\n" +
            "Function summary: Load pricing information\n\n"
        );
        char choice = '0';
        loop:
        while(true)
        {
            System.out.print
            (
                "Enter the character of the option you would like to select:\n" +
                "L: Load pricing information\n" +
                "C: Change the price of an existing flight\n" +
                "E: Exit menu\n\n" +
                "Enter option: "
            );
            try
            {
                choice = input.nextLine().charAt(0);
                choice = Character.toUpperCase(choice);
            }
            catch(Exception e)
            {
                System.out.print("\nPlease enter a valid option\n");
                continue;
            }
            switch(choice)
            {
                case 'L':
                {
                    System.out.print("\nPlease enter the name of the file to be loaded:");
                    Scanner inputFile;
                    while(true)
                    {
                        try
                        {
                            inputFile = new Scanner(new File(input.nextLine()));
                            break;
                        }
                        catch(Exception e)
                        {
                            System.out.print("\nCould not find file. Please enter the name of a valid file to be loaded:");
                            continue;
                        }
                    }
                    while(inputFile.hasNext())
                    {
                        String[] tokens = inputFile.nextLine().split("\t");
                        try
                        {
                            Statement stmt = conn.createStatement();
                            String sql =
                                (
                                    "INSERT INTO PRICE VALUES (" +
                                    "\'" + tokens[0] + "\', " +
                                    "\'" + tokens[1] + "\', " +
                                    Integer.parseInt(tokens[2]) + ", " +
                                    Integer.parseInt(tokens[3]) + ", " +
                                    Integer.parseInt(tokens[4]) +
                                    ");"
                                );
                            stmt.executeUpdate(sql);
                            stmt.close();
                        }
                        catch(SQLException e)
                        {
                            e.printStackTrace();
                        }
                    }
                    inputFile.close();
                    System.out.print("Load complete.\n");
                    break;
                }
                case 'C':
                {
                    
                    System.out.print("\nThis functionality is not yet implemented\n");
                    break;
                }
                case 'E':
                    break loop;
                default:
                    System.out.print("\nPlease enter a valid option\n");
                    break;
            }
        }
    }
    
    public static void loadPlaneInformation()
    {
        System.out.print
        (
            "In the loadPlaneInformation function\n" +
            "Function summary: Load plane information\n\n" +
            "Please enter the name of the file to be loaded:"
        );
		Scanner inputFile;
        while(true)
        {
            try
            {
                inputFile = new Scanner(new File(input.nextLine()));
                break;
            }
            catch(Exception e)
            {
                System.out.print("\nCould not find file. Please enter the name of a valid file to be loaded: ");
                continue;
            }
        }
        while(inputFile.hasNext())
        {
            String[] tokens = inputFile.nextLine().split("\t");
            try
            {
                Statement stmt = conn.createStatement();
                String sql =
                    (
                        "INSERT INTO PLANE VALUES (" +
                        "\'" + tokens[0] + "\', " +
                        "\'" + tokens[1] + "\', " +
                        Integer.parseInt(tokens[2]) + ", " +
                        "TO_DATE(\'" + tokens[3] + "\', 'MM-DD-YYYY'), " +
                        Integer.parseInt(tokens[4]) + ", " +
						Integer.parseInt(tokens[5]) +
                        ");"
                    );
                stmt.executeUpdate(sql);
                stmt.close();
            }
            catch(SQLException e)
            {
                e.printStackTrace();
            }
        }
        inputFile.close();
        System.out.print("Load complete.\n");
    }
    
    public static void generatePassengerManifest()
    {
        System.out.print
        (
            "In the generatePassengerManifest function\n" +
            "Function summary: Generate passenger manifest for specific flight on given day\n\n"
        );
        
        System.out.print("Please enter the flight number and date in the format MM-DD-YYYY of the manifest you would like to see.\n\n");
        System.out.print("Flight number: ");
        String flight_number = input.nextLine();
        System.out.print("Date: ");
        String date = input.nextLine();
        
        try
        {
            Statement stmt = conn.createStatement();
            String sql =
                (
                    "SELECT salutation, first_name, last_name " +
                    "FROM CUSTOMER " +
                    "JOIN RESERVATION ON CUSTOMER.cid = RESERVATION.cid " +
                    "JOIN RESERVATION_DETAIL on RESERVATION.reservation_number = RESERVATION_DETAIL.reservation_number " +
                    "WHERE flight_number = \'" + flight_number + "\' AND TO_CHAR(flight_date, 'MM-DD-YYYY') = " + "\'" + date +"\';"
                );
            ResultSet res = stmt.executeQuery(sql);
            int i = 0;
            while(res.next() == true)
            {
                i++;
                System.out.print
                (
                    "\nPassenger " + i + ":\n" +
                    "Salutation: " + res.getString(1) + "\n" +
                    "First Name: " + res.getString(2) + "\n" +
                    "Last Name: " + res.getString(3) + "\n"
                );
            }
            stmt.close();
            if(i == 0)
            {
                System.out.print("\nEither such a flight does not exist, or it exists but there are no passengers on it\n");
            }
        }
        catch(SQLException e)
        {
            e.printStackTrace();
        }
    }
    
    public static void updateCurrentTimestamp()
    {
        System.out.print
        (
            "In the updateCurrentTimestamp function\n" +
            "Function summary: Update the current timestamp\n\n" +
            "Please enter a new timestamp in the format [MM-DD-YYYY HH24:MI]: "
        );
		String timestamp;
        while(true)
        {
            timestamp = input.nextLine();
            if(timestamp.length() != 16)
            {
                System.out.print("\nPlease enter a valid timestamp in the format [MM-DD-YYYY HH24:MI]: ");
                continue;
            }
            break;
        }
        String sql;
        try
        {
            Statement stmt = conn.createStatement();
            sql =
                (
                    "DELETE FROM OURTIMESTAMP;"
                );
            stmt.executeUpdate(sql);
            sql =
                (
                    "INSERT INTO OURTIMESTAMP VALUES (" +
                    "\'" + timestamp + "\'" +
                    ");"
                );
            stmt.executeUpdate(sql);
            stmt.close();
        }
        catch(SQLException e)
        {
            e.printStackTrace();
        }
        System.out.print("\nTimestamp update complete.\n");
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

    public static void findAllRoutes() throws SQLException
    {
        String sql, cityA, cityB;
        System.out.print
        (
            "In the findAllRoutes function\n" +
            "Function summary: Find all routes between two cities\n\n"
        );

        do {
            System.out.println("Enter the names of two cities -- 3 letters.");
            System.out.print("Departure city: ");
            cityA = input.next();

            System.out.print("Arrival city: ");
            cityB = input.next();
        } while (cityA.length() != 3 && cityB.length() != 3);
        input.nextLine(); // clears the buffer.
        Statement stmt = conn.createStatement();
        try {

            sql = "SELECT flight_number, departure_city, departure_time, arrival_time FROM Flight " +
                    "WHERE departure_city = \'" + cityA + "\' AND arrival_city = \'" + cityB + "\';";
            ResultSet res = stmt.executeQuery(sql);
            System.out.println("Direct routes between " + cityA + " and " + cityB);
            if(!res.next())
            {
                System.out.println("No direct routes were found.");
            } else {
                do {
                    System.out.println("Flight Number: " + res.getInt(1) + "\n" + 
                                       "Departure city: " + res.getString(2) + "\n" +
                                       "Departure time: " + res.getString(3) + "\n" +
                                       "Arrival time: " + res.getString(4));
                } while(res.next());
            }   
                       

            sql = "SELECT F1.flight_number, F1.departure_city, F1.departure_time, F1.arrival_time, " + 
            " F2.flight_number, F2.departure_city, F2.departure_time, F2.arrival_time " +            
            " FROM Flight F1 JOIN Flight F2 ON F1.arrival_city = F2.departure_city " +
            "WHERE F1.departure_city = \'" + cityA + "\' and F2.arrival_city = \'" + cityB + "\' " +
            "AND  is_connecting(F1.weekly_schedule, F2.weekly_schedule, F2.departure_time, F1.arrival_time);";
            res = stmt.executeQuery(sql);
            System.out.println("Routes with one connection between " + cityA + " and " + cityB);
            if(!res.next())
            {
                System.out.println("No direct routes were found.");
            } else {
                do {
                    System.out.println("++++ Route " + res.getRow()+ "++++++++++");
                    System.out.println("Flight Number: " + res.getInt(1) + "\n" + 
                                   "Departure city: " + res.getString(2) + "\n" +
                                   "Departure time: " + res.getString(3) + "\n" +
                                   "Arrival time: " + res.getString(4));
                    System.out.println("Connection");
                    System.out.println("Flight Number: " + res.getInt(5) + "\n" + 
                                   "Departure city: " + res.getString(6) + "\n" +
                                   "Departure time: " + res.getString(7) + "\n" +
                                   "Arrival time: " + res.getString(8));
                    System.out.println("++++++++++++++++++++");
                } while(res.next());
            } 
        } catch (SQLException e)
        {
            e.printStackTrace();
        }




    }
    
    public static void findAllRoutesForGivenAirline() throws SQLException
    {
        String sql, cityA, cityB, airline;
        System.out.print
        (
            "In the findAllRoutes function\n" +
            "Function summary: Find all routes between two cities given airline\n\n"
        );

        do {
            
            System.out.println("Enter the names of two cities -- 3 letters.");
            System.out.print("Departure city: ");
            cityA = input.next();
            System.out.print("Arrival city: ");
            cityB = input.next();
            System.out.print("Airline name: ");
            input.nextLine(); // clear the buffer
            airline = input.nextLine();
        } while (cityA.length() != 3 && cityB.length() != 3);
        //input.nextLine(); // clears the buffer.
        Statement stmt = conn.createStatement();
        try {

            sql = "SELECT flight_number, departure_city, departure_time, arrival_time FROM Flight " +
                    "WHERE departure_city = \'" + cityA + "\' AND arrival_city = \'" + cityB + 
                    "\' AND airline_id = (SELECT airline_id FROM airline " +
                    "WHERE airline_name = \'" + airline + "\' );";
            ResultSet res = stmt.executeQuery(sql);
            System.out.println("Direct routes between " + cityA + " and " + cityB);
            
            if(!res.next())
            {
                System.out.println("No direct routes were found.");
            } else {
                do {
                    System.out.println("Flight Number: " + res.getInt(1) + "\n" + 
                                       "Departure city: " + res.getString(2) + "\n" +
                                       "Departure time: " + res.getString(3) + "\n" +
                                       "Arrival time: " + res.getString(4));
                } while(res.next());
            }   
                       

            sql = "SELECT F1.flight_number, F1.departure_city, F1.departure_time, F1.arrival_time, " + 
            " F2.flight_number, F2.departure_city, F2.departure_time, F2.arrival_time " +            
            " FROM Flight F1 JOIN Flight F2 ON F1.arrival_city = F2.departure_city " +
            "WHERE F1.departure_city = \'" + cityA + "\' and F2.arrival_city = \'" + cityB + "\' " +
            "AND  is_connecting(F1.weekly_schedule, F2.weekly_schedule, F2.departure_time, F1.arrival_time) "
            + "AND F1.airline_id = (SELECT airline_id FROM airline " +
            "WHERE airline_name = \'" + airline + "\' ) AND F1.airline_id = F2.airline_id;";
            res = stmt.executeQuery(sql);
            System.out.println("Routes with one connection between " + cityA + " and " + cityB);
            if(!res.next())
            {
                System.out.println("No direct routes were found.");
            } else {
                do {
                    System.out.println("++++ Route " + res.getRow()+ "++++++++++");                    
                    System.out.println("Flight Number: " + res.getInt(1) + "\n" + 
                                   "Departure city: " + res.getString(2) + "\n" +
                                   "Departure time: " + res.getString(3) + "\n" +
                                   "Arrival time: " + res.getString(4));
                    System.out.println("Connection");
                    System.out.println("Flight Number: " + res.getInt(5) + "\n" + 
                                   "Departure city: " + res.getString(6) + "\n" +
                                   "Departure time: " + res.getString(7) + "\n" +
                                   "Arrival time: " + res.getString(8));
                    System.out.println("++++++++++++++++++++");
                } while(res.next());
            } 
        } catch (SQLException e)
        {
            e.printStackTrace();
        }
    }
    
    
    public static void findAllUnfilledFlightsOnGivenDate() throws SQLException
    {
        String sql, cityA, cityB, date;
        System.out.print
        (
            "In the findAllUnfilledFlightsOnGivenDate function\n" +
            "Function summary: Find all routes with available seats between two cities on a given date\n\n"
        );

        do {
            
            System.out.println("Enter the names of two cities -- 3 letters.");
            System.out.print("Departure city: ");
            cityA = input.next();
            System.out.print("Arrival city: ");
            cityB = input.next();
            System.out.print("Date MM-DD-YYYY: ");
            input.nextLine(); // clear the buffer
            date = input.nextLine();
        } while (cityA.length() != 3 && cityB.length() != 3);
        //input.nextLine(); // clears the buffer.
        Statement stmt = conn.createStatement();

        try {

            sql = "SELECT flight_number, departure_city, departure_time, arrival_time FROM Flight " +
                    "WHERE departure_city = \'" + cityA + "\' AND arrival_city = \'" + cityB + 
                    "\' AND isplanefull(flight_number, getflighttime(flight_number, TO_DATE(\'" + date + "\', 'MM-DD-YYYY'))) = FALSE;";
            ResultSet res = stmt.executeQuery(sql);
            System.out.println("Direct routes between " + cityA + " and " + cityB);
            
            if(!res.next())
            {
                System.out.println("No direct routes were found.");
            } else {
                do {
                    System.out.println("Flight Number: " + res.getInt(1) + "\n" + 
                                       "Departure city: " + res.getString(2) + "\n" +
                                       "Departure time: " + res.getString(3) + "\n" +
                                       "Arrival time: " + res.getString(4));
                } while(res.next());
            }   
                       

            sql = "SELECT F1.flight_number, F1.departure_city, F1.departure_time, F1.arrival_time, " + 
            " F2.flight_number, F2.departure_city, F2.departure_time, F2.arrival_time " +            
            " FROM Flight F1 JOIN Flight F2 ON F1.arrival_city = F2.departure_city " +
            "WHERE F1.departure_city = \'" + cityA + "\' and F2.arrival_city = \'" + cityB + "\' " +
            "AND  is_connecting(F1.weekly_schedule, F2.weekly_schedule, F2.departure_time, F1.arrival_time) "
            + "AND isplanefull(F1.flight_number, getflighttime(F1.flight_number, TO_DATE(\'" + date + "\', 'MM-DD-YYYY'))) = FALSE "
            + "AND isplanefull(F2.flight_number, getflighttime(F2.flight_number, TO_DATE(\'" + date + "\', 'MM-DD-YYYY'))) = FALSE";
            res = stmt.executeQuery(sql);
            System.out.println("Routes with one connection between " + cityA + " and " + cityB);
            if(!res.next())
            {
                System.out.println("No direct routes were found.");
            } else {
                do {
                    System.out.println("++++ Route " + res.getRow()+ "++++++++++");                    
                    System.out.println("Flight Number: " + res.getInt(1) + "\n" + 
                                   "Departure city: " + res.getString(2) + "\n" +
                                   "Departure time: " + res.getString(3) + "\n" +
                                   "Arrival time: " + res.getString(4));
                    System.out.println("Connection");
                    System.out.println("Flight Number: " + res.getInt(5) + "\n" + 
                                   "Departure city: " + res.getString(6) + "\n" +
                                   "Departure time: " + res.getString(7) + "\n" +
                                   "Arrival time: " + res.getString(8));
                    System.out.println("++++++++++++++++++++");
                } while(res.next());
            } 
        } catch (SQLException e)
        {
            e.printStackTrace();
        }
    }
    
    public static void addReservation()
    {
        System.out.print("In the addReservation function\n" + "Function summary: Add reservation\n\n");

        ArrayList<Integer> flight_num = new ArrayList<>();
        ArrayList<String> dates = new ArrayList<>();
        Integer flight_n=0;
        String date="";
        String credit_card="";
        String freq_miles="";
        String sql="";
        String timestamp="";
        int reservation_num=0;
        int CID=0;
        int cost=0;
        int high_price=0;
        int low_price=0;
        int airline_id1=0;
        int airline_id2=0;
        cost = 0;
        System.out.print("First name: ");
        String firstName = input.next();

        System.out.print("Last name: ");
        String lastName = input.next();

        Statement stmt = conn.createStatement();
        try {
            sql = "SELECT CID, credit_card_num, frequent_miles FROM Customer WHERE first_name = \'" + firstName + "\' AND last_name= \'" + lastName + "\'";
            ResultSet res = stmt.executeQuery(sql);

            if (res.next()) {
                CID = res.getInt(1);
                credit_card = res.getString(2);
                freq_miles = res.getString(3);
            }
            else
            {
                System.out.println("User: " + firstName + " " + lastName + " does not exit in Customers");
                return;
            }
        

            for (int i = 0; i < 4; i++) {

                System.out.print("Enter flight number: ");
                String f = input.next();
                flight_n = Integer.parseInt(f);
                if(i==0 && flight_n == 0)
                {
                    System.out.println("First flight number cannot be zero.");
                    i=0;
                    continue;
                }
                else if (flight_n==0)
                {
                    break;
                }          

                System.out.print("Enter date: ");
                date = input.next();
                flight_num.add(flight_n);
                dates.add(date);

                sql = "SELECT P.high_price, P.low_price, F.airline_id " +
                "FROM (FLIGHT F JOIN PRICE P ON F.departure_city=P.departure_city " + 
                "AND F.arrival_city=P.arrival_city) WHERE F.flight_number = " + flight_n + ";";

                res = stmt.executeQuery(sql);
                if(res.next())
                {
                    high_price = res.getInt(1);
                    low_price = res.getInt(2);
                    airline_id1 = res.getInt(3);                    
                }

                sql = "SELECT airline_id " +
                "FROM airline WHERE airline_abbreviation = (SELECT frequent_miles " +
                "FROM customer C  WHERE C.cid = " + CID + ");";

                res = stmt.executeQuery(sql);
                if(res.next()) {
                    airline_id2 = res.getInt(1);
                }

                if(i > 0)
                {
                    
                    if(dates.get(i-1) == date) {
                        if(airline_id1 == airline_id2)
                            high_price *= 0.9;
                        cost += high_price;
                    }
                    else
                    {
                        if(airline_id1 == airline_id2)
                            low_price *= 0.9;
                        cost += low_price;  
                    }
                }
                else {
                    if(airline_id1 == airline_id2)
                            high_price *= 0.9;
                        cost += high_price;
                }               
                
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        stmt = conn.createStatement();
        try {

                sql = "SELECT COUNT(reservation_number) FROM reservation;";
                ResultSet res =  stmt.executeQuery(sql);
                if(res.next()) {
                    reservation_num = res.getInt(1);
                    reservation_num++; // increment to generate new reservation number
                }
                else {
                    System.out.println("Query is not successful");
                    return;
                }

                sql = "SELECT c_timestamp from ourtimestamp LIMIT 1;";
                res = stmt.executeQuery(sql);
                if(res.next()) timestamp = res.getString(1);

                sql = "INSERT INTO Reservation VALUES("
                + reservation_num + ", " + CID + ", " + cost + ", \'" 
                + credit_card + "\', \'" + timestamp + "\', FALSE);";
                stmt.executeUpdate(sql);
                for(int i=0; i < flight_num.size(); i++)
                {
                    sql = "CALL makereservation(" 
                    + reservation_num + ", " + flight_num.get(i) + ", \'" + 
                    dates.get(i) + "\', " + (i+1) + ")";
                    stmt.execute(sql);
                }

                System.out.println("Reservation is confirmed.\n" +
                                   "Reservation number is " + reservation_num);

        } catch (SQLException e)
        {
            System.out.println("Error: Reservation cannot be created.");
            e.printStackTrace();
        }
    }
    
    public static void deleteReservation() throws SQLException {
        System.out.print("In the deleteReservation function\n" + "Function summary: Delete reservation\n\n");
        String sql;
        System.out.print("Enter reservation number: ");
        String reservation_number = input.next();
        input.nextLine();
        int res_number = Integer.parseInt(reservation_number);

        Statement stmt = conn.createStatement();
        try {
            sql = "DELETE FROM reservation WHERE reservation_number = "+ res_number + ";";
            int res = stmt.executeUpdate(sql);
            if(res==0) {System.out.println("Reservation number does not exist.");}
            else {System.out.println("Reservation succesfully deleted.");}
        } catch (SQLException e)
        {
            e.printStackTrace();
        }
    }
    
    public static void showReservationInfo() throws SQLException {
        System.out.print("In the showReservationInfo function\n"
                + "Function summary: Show reservation info, given reservation number\n\n");

        String sql;
        System.out.print("Enter reservation number: ");
        String reservation_number = input.next();
        input.nextLine();
        int res_number = Integer.parseInt(reservation_number);

        Statement stmt = conn.createStatement();
        try {
            sql = "SELECT flight_number FROM reservation_detail WHERE reservation_number = "+ res_number + ";";
            ResultSet res = stmt.executeQuery(sql);

            if (!res.next()) {
                System.out.println("Reservation number does not exist.");
            } else {
                System.out.println("All flights for the given reservation:");
                do {
                    System.out.println("  Flight Number: " + res.getInt(1));
                } while (res.next());
            }
            
        } catch (SQLException e)
        {
            e.printStackTrace();
        }        
    }
    
    public static void buyTicketFromReservation() throws SQLException {
        System.out.print("In the buyTicketFromReservation function\n"
                + "Function summary: Buy ticket from existing reservation\n\n");

        String sql;
        System.out.print("Enter reservation number: ");
        String reservation_number = input.next();
        input.nextLine();
        int res_number = Integer.parseInt(reservation_number);

        Statement stmt = conn.createStatement();
        try {
            sql = "UPDATE reservation SET ticketed=TRUE WHERE reservation_number = "+ res_number + ";";
            int res = stmt.executeUpdate(sql);
            if(res==0) {System.out.println("Reservation number does not exist.");}
            else {System.out.println("Reservation is succesfully purchased.");}
        } catch (SQLException e)
        {
            e.printStackTrace();
        }
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
