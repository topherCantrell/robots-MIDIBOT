import java.io.*;


public class Cleaner
{

public static void main(String [] args) throws Exception
{

Reader r = new FileReader("Yeah.txt");
BufferedReader br = new BufferedReader(r);
while(true) {
  String g = br.readLine();
  if(g==null) break;

int i = g.indexOf("b");
if(i>0) {
  String ns = g.substring(0,i)+g.charAt(i+1)+"b"+g.substring(i+2);
  g = ns;
}
i = g.indexOf("#");
if(i>0) {
  String ns = g.substring(0,i)+g.charAt(i+1)+"#"+g.substring(i+2);
  g = ns;
}

System.out.print(g+" ");

}

}


}