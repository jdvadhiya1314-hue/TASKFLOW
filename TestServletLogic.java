import java.sql.Timestamp;

public class TestServletLogic {
    public static void main(String[] args) {
        String action = "REJECT";
        if ("approve".equals(action)) {
            System.out.println("approve");
        } else if ("reject".equals(action)) {
            System.out.println("reject");
        } else {
            System.out.println("Invalid action. SC_BAD_REQUEST");
        }
    }
}
