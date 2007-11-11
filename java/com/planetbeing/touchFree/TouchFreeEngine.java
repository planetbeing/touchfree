package com.planetbeing.touchFree;

import java.io.*;
import java.security.*;
import java.security.interfaces.RSAPrivateCrtKey;

import com.planetbeing.iPhuc.*;

public class TouchFreeEngine {
	IPhuc iphuc;

	String iphucLocation;
	String resourcesLocation;

	ErrorListener errorListener;
	StatusListener statusListener;
	ProgressListener progressListener;

	public TouchFreeEngine(String iphucLocation, String resourcesLocation,
			ErrorListener errorListener, StatusListener statusListener,
			ProgressListener progressListener) {
		this.iphucLocation = iphucLocation;
		this.resourcesLocation = resourcesLocation;
		this.errorListener = errorListener;
		this.statusListener = statusListener;
		this.progressListener = progressListener;

		connect();
	}
	
	public boolean isConnected() {
		if(iphuc != null) {
			return true;
		} else {
			return false;
		}
	}

	public void connect() {
		statusListener.message("Connecting to iPod/iPhone...");
		
		try {
			iphuc = new IPhuc(iphucLocation);
		} catch(IOException e) {
			errorListener.error("Cannot launch iPHUC!");
			iphuc = null;
			return;
		}

		if (!iphuc.isConnected()) {
			errorListener
					.error("Cannot connect to your device: Please plug your iPod/iPhone into your computer. If you're still having trouble, restart the computer, reconnect the device and try again.");
			iphuc.kill();
			
			try {
				iphuc = new IPhuc(iphucLocation);				
			} catch(IOException e) {
				errorListener.error("Cannot launch iPHUC!");
				iphuc = null;
				return;
			}
			iphuc.waitForPrompt();
		}
	}

	public boolean atRoot() {
		return iphuc.fileExists("/Applications");
	}
	
	public boolean hasDisk() {
		return iphuc.fileExists("/disk");
	}

	public boolean jailbreak(boolean doInstaller, boolean doSSH, JBProgressMonitor monitor)
			throws IOException {

		if (doInstaller) {
			statusListener.message("Uploading Installer.app files...");
			iphuc.recursiveUpload(resourcesLocation + File.separatorChar
					+ "installer" + File.separatorChar + "root",
					"/touchFree", monitor);
		}

		if (doSSH) {
			statusListener.message("Uploading SSH files...");
			iphuc.recursiveUpload(resourcesLocation + File.separatorChar
					+ "ssh" + File.separatorChar + "root",
					"/touchFree", monitor);
			
			
			statusListener.message("Generating RSA host key...");
			try {
				generateKey("/touchFree/root/etc/ssh_host_rsa_key");
			} catch (NoSuchAlgorithmException e) {
				errorListener.error("Could not find RSA crypto engine!");
				return false;
			}
		}

		return jailbreak(monitor);
	}
	
	public long jailbreakSize(boolean doInstaller, boolean doSSH) {
		long total = 0;
		
		if (doInstaller) {
			total += calculateFolderSize(resourcesLocation + File.separatorChar
					+ "installer" + File.separatorChar + "root");
		}
		
		if (doSSH) {
			total += calculateFolderSize(resourcesLocation + File.separatorChar
					+ "ssh" + File.separatorChar + "root");
		}
		
		total += jailbreakSize();
		
		return total;
	}
	
	public long jailbreakSize() {
		long total = 0;
		String jbRes = resourcesLocation + File.separatorChar + "required"
			+ File.separatorChar;
		
		total += calculateFolderSize(jbRes + "touchFree");
		total += 314572800;
		total += 314572800;
		total += 314572800;
		
		return total;
	}

	public boolean jailbreak(JBProgressMonitor monitor) throws IOException {
		String jbRes = resourcesLocation + File.separatorChar + "required"
				+ File.separatorChar;

		statusListener.message("Uploading core files...");
		iphuc.recursiveUpload(jbRes + "touchFree", "/", monitor);

		statusListener.message("Reading flash image...");
		File imageFile = File.createTempFile("rdisk0s1", ".dmg");
		imageFile.deleteOnExit();
		iphuc.readImage(imageFile.getAbsolutePath(), progressListener);

		statusListener.message("Patching flash image...");
		iphuc.patch(imageFile.getAbsolutePath(), new String[][] {
				new String[] { jbRes + "com.apple.syslogd.plist",
						jbRes + "com.apple.syslogd.new.plist" },
				new String[] { jbRes + "fstab", jbRes + "fstab.new" } },
				progressListener);

		statusListener.message("Writing flash image...");
		iphuc.writeImage(imageFile.getAbsolutePath(), progressListener);
		imageFile.delete();
		
		return true;
	}

	/*public void installIPhoneApps() throws IOException {
		String res = resourcesLocation + File.separatorChar + "iphone"
				+ File.separatorChar;

		statusListener.message("Attempting to access filesystem root...");

		iphuc.setAfc("com.apple.afc2");

		if (!atRoot()) {
			errorListener
					.message("Cannot access root: You did not appear to have jailbroken with a supported method (Services.plist must be altered to add com.apple.afc2).");
			return;
		}

		if (!(new File(res + "GMM.framework")).exists()) {
			errorListener
					.message("Missing the 'iphone/GMM.framework' folder. Please download this folder and put it into the iphone directory.");
			return;
		}

		if (!(new File(res + "MobileMailSettings.bundle")).exists()) {
			errorListener
					.message("Missing the 'iphone/MobileMailSettings.bundle' folder. Please download this folder and put it into the iphone directory.");
			return;
		}

		statusListener.message("Uploading settings...");
		iphuc.recursiveUpload(res + "GMM.framework",
				"/System/Library/Framework");
		iphuc.recursiveUpload(res + "MobileMailSettings.bundle",
				"/System/Library/PreferenceBundles");

		statusListener.message("Uploading Maps...");
		if (!(new File(res + "Maps.app")).exists())
			errorListener
					.message("Maps.app is not found and will not be installed.");
		else
			iphuc.recursiveUpload(res + "Maps.app", "/Applications");

		statusListener.message("Uploading Mail...");
		if (!(new File(res + "MobileMail.app")).exists())
			errorListener
					.message("MobileMail.app is not found and will not be installed.");
		else
			iphuc.recursiveUpload(res + "MobileMail.app", "/Applications");

		statusListener.message("Uploading Notes...");
		if (!(new File(res + "MobileNotes.app")).exists())
			errorListener
					.message("MobileNotes.app is not found and will not be installed.");
		else
			iphuc.recursiveUpload(res + "MobileNotes.app", "/Applications");

		statusListener.message("Uploading Stocks...");
		if (!(new File(res + "Stocks.app")).exists())
			errorListener
					.message("Stocks.app is not found and will not be installed.");
		else
			iphuc.recursiveUpload(res + "Stocks.app", "/Applications");

		statusListener.message("Uploading Weather...");
		if (!(new File(res + "Weather.app")).exists())
			errorListener
					.message("Weather.app is not found and will not be installed.");
		else
			iphuc.recursiveUpload(res + "Weather.app", "/Applications");

		statusListener.message("Uploading MobileSMS data for Colloquy fix...");
		if (!(new File(res + "MobileSMS.app")).exists())
			errorListener
					.message("MobileSMS.app is not found and the Colloquy fix will not be installed.");
		else
			iphuc.recursiveUpload(res + "MobileSMS.app", "/Applications");

		statusListener.message("Uploading setup script...");
		iphuc.uploadFile(res + "run.sh", "/private/var/root/Media/touchFree/run.sh");

		statusListener.message("Executing setup script...");
		iphuc.afcExecute("com.planetbeing.runscript");
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
		}

		statusListener.message("Restarting SpringBoard...");
		iphuc.afcExecute("com.planetbeing.killsb");
	}

	public void installInstaller() throws IOException {
		genericInstall("installer");
	}

	public void installSSH() throws IOException {
		genericInstall("ssh");
	}

	public void genericInstall(String resName) throws IOException {
		String res = resourcesLocation + File.separatorChar + resName
				+ File.separatorChar;

		statusListener.message("Attempting to access filesystem root...");

		iphuc.setAfc("com.apple.afc2");

		if (!atRoot()) {
			errorListener
					.message("Cannot access root: You did not appear to have jailbroken with a supported method (Services.plist must be altered to add com.apple.afc2).");
			return;
		}

		statusListener.message("Uploading necessary files...");
		iphuc.merge(res + "root", "/");

		statusListener.message("Uploading setup script...");
		iphuc.uploadFile(res + "run.sh", "/private/var/root/Media/touchFree/run.sh");

		statusListener.message("Executing setup script...");
		iphuc.afcExecute("com.planetbeing.runscript");
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
		}

		statusListener.message("Restarting SpringBoard...");
		iphuc.afcExecute("com.planetbeing.killsb");
	}*/

	public void setPasswordJailbreak(String password) throws IOException {
		setPassword(password, password, "/touchFree/root/etc/master.passwd");
	}
	
	public void setPassword(String rootPassword, String mobilePassword, String remoteLocation) throws IOException {
		File passwdFile = File.createTempFile("master", ".passwd");
		passwdFile.deleteOnExit();
		Writer writer = new FileWriter(passwdFile);
		writer.write(genPasswd(rootPassword, mobilePassword));
		writer.close();
		iphuc.uploadFile(passwdFile.getAbsolutePath(), remoteLocation, new DefaultJBProgressMonitor());
		passwdFile.delete();
	}
	
	public void done() {
		iphuc.done();
	}
	
	private String genPasswd(String rootPassword, String mobilePassword) {
		StringBuilder sb = new StringBuilder();
		sb.append("##\n");
		sb.append("##\n");
		sb.append("# User Database\n");
		sb.append("# \n");
		sb.append("# Note that this file is consulted when the system is running in single-user\n");
		sb.append("# mode.  At other times this information is handled by lookupd.  By default,\n");
		sb.append("# lookupd gets information from NetInfo, so this file will not be consulted\n");
		sb.append("# unless you have changed lookupd's configuration.\n");
		sb.append("##\n");
		sb.append("nobody:*:-2:-2::0:0:Unprivileged User:/var/empty:/usr/bin/false\n");
		sb.append("root:" + Crypt.crypt("/sm", rootPassword) + ":0:0::0:0:System Administrator:/var/root:/bin/sh\n");
		sb.append("mobile:" + Crypt.crypt("/sm", rootPassword) + ":501:0::0:0:Mobile User:/var/mobile:/bin/sh\n");
		sb.append("daemon:*:1:1::0:0:System Services:/var/root:/usr/bin/false\n");
		sb.append("unknown:*:99:99::0:0:Unknown User:/var/empty:/usr/bin/false\n");
		
		return sb.toString();
	}
	
	private void generateKey(String remoteLocation) throws IOException, NoSuchAlgorithmException {
		KeyPairGenerator generator = KeyPairGenerator.getInstance("RSA");
		generator.initialize(2048);
		KeyPair keys = generator.generateKeyPair();
		RSAPrivateCrtKey theKey = (RSAPrivateCrtKey)keys.getPrivate();
		
		SimpleASNWriter asn = new SimpleASNWriter();
		SimpleASNWriter asn2 = new SimpleASNWriter();
        asn2.writeByte(0x02); // INTEGER (version)

        byte[] version = new byte[1];
        asn2.writeData(version);
        asn2.writeByte(0x02); // INTEGER ()
        asn2.writeData(theKey.getModulus().toByteArray());
        asn2.writeByte(0x02); // INTEGER ()
        asn2.writeData(theKey.getPublicExponent().toByteArray());
        asn2.writeByte(0x02); // INTEGER ()
        asn2.writeData(theKey.getPrivateExponent().toByteArray());
        asn2.writeByte(0x02); // INTEGER ()
        asn2.writeData(theKey.getPrimeP().toByteArray());
        asn2.writeByte(0x02); // INTEGER ()
        asn2.writeData(theKey.getPrimeQ().toByteArray());
        asn2.writeByte(0x02); // INTEGER ()
        asn2.writeData(theKey.getPrimeExponentP().toByteArray());
        asn2.writeByte(0x02); // INTEGER ()
        asn2.writeData(theKey.getPrimeExponentQ().toByteArray());
        asn2.writeByte(0x02); // INTEGER ()
        asn2.writeData(theKey.getCrtCoefficient().toByteArray());

        byte[] rsaKeyEncoded = asn2.toByteArray();
        asn.writeByte(0x30); // SEQUENCE
        asn.writeData(rsaKeyEncoded);
		
		File keyFile = File.createTempFile("ssh_host_rsa_key", ".tmp");
		keyFile.deleteOnExit();
		Writer writer = new FileWriter(keyFile);
		writer.write("-----BEGIN RSA PRIVATE KEY-----\n" + Base64.encodeBytes(asn.toByteArray()) + "\n-----END RSA PRIVATE KEY-----\n");
		writer.close();
		iphuc.uploadFile(keyFile.getAbsolutePath(), remoteLocation, new DefaultJBProgressMonitor());
		keyFile.delete();
	}
	
	public static long calculateFolderSize(String folder) {
		File file = new File(folder);
		long total = 0;
		if(file.isDirectory()) {
			File[] files = file.listFiles();
			for(int i = 0; i < files.length; i++) {
				try {
					total += calculateFolderSize(files[i].getCanonicalPath());
				} catch (IOException e) {
					
				}
			}
		} else {
			total = file.length();
		}
		
		return total;
	}
}
