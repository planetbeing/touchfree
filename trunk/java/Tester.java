import java.io.*;

import com.planetbeing.iPhuc.DefaultProgressListener;
import com.planetbeing.touchFree.*;

public class Tester {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
		
		String iphucLocation;
		
		if(new File("iphuc.exe").exists()) {
			try {
				iphucLocation = (new File("iphuc.exe")).getCanonicalPath();
			} catch (IOException e) {
				System.out.println("Cannot launch iPHUC!");
				return;
			}
		} else {
			try {
				iphucLocation = (new File("iphuc")).getCanonicalPath();
			} catch (IOException e) {
				System.out.println("Cannot launch iPHUC!");
				return;
			}
		}
		
		TouchFreeEngine engine = new TouchFreeEngine(iphucLocation, ".", new DefaultErrorListener(), new DefaultStatusListener(), new DefaultProgressListener());
		
		try {
			
			if(args.length >= 1 && args[0].compareToIgnoreCase("iphone") == 0) {
				engine.installIPhoneApps();
			} else {
				if(engine.jailbreak(true, true)) {
					System.out.println("For security reasons, please set the root password for your iPod touch. Due to the limitation of Linux, the password will be truncated at 8 characters.");
					System.out.print("New password: ");
					engine.setPasswordJailbreak(br.readLine());				
					System.out.println("Done. Reboot your iPod.");
				}
			}
			
			engine.done();
		} catch (IOException e) {
			System.out.println("Some sort of unexpected error occured!");
			e.printStackTrace();
		}
		
		
		System.out.println("This program will close in ten seconds.");
		try {
			Thread.sleep(10000);
		} catch (InterruptedException e) {
			
		}
	}

}
