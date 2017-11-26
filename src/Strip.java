
import java.io.*;

public class Strip
{

public static void main(String [] args) throws Exception
{

Reader r = new FileReader(args[0]);
BufferedReader br = new BufferedReader(r);

while(true) {
String g = br.readLine();
if(g==null) break;
g = g.trim();
if(g.startsWith(">")) g=g.substring(1);

g=g.trim();
System.out.println(g);
}

}

}