/*

Modified from sample code posted by Denis Popov at http://www.sql.ru/forum/actualthread.aspx?tid=180792

*/

import java.sql.*;

public class JTDSTest
{
	public static void main(String[] args) throws SQLException
	{
		DriverManager.registerDriver(new net.sourceforge.jtds.jdbc.Driver());
		Connection conn = null;

		if (3 == args.length)
			conn = DriverManager.getConnection(args[0], args[1], args[2]);
		else
			conn = DriverManager.getConnection("jdbc:jtds:sqlserver://" + args[0] + ":" + args[1] + "/" + args[2], args[3], args[4]);

		Statement st = conn.createStatement();
		ResultSet rs = st.executeQuery("SELECT 'Hello " + JTDSTest.class.getName() + "'");

		while (rs.next())
			System.out.println(rs.getString(1));
	}
}
