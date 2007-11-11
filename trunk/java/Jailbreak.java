import java.io.*;
import java.awt.*;
import java.beans.*;
import javax.swing.*;

import com.planetbeing.iPhuc.*;
import com.planetbeing.touchFree.*;

public class Jailbreak extends JPanel {
	static JFrame f;
	static String iphucLocation;
	
	private JTextArea description;
	private JCheckBox installSSHField;
	private JTextField passwordField;
	private JButton jailbreakButton;
	
	private ProgressMonitor monitor;
	private TFProgressMonitor tfMonitor;
	private Thread jbThread;
	private TouchFreeEngine engine;
	
	private boolean installSSH;
	private String password;
	
	public Jailbreak() {
		super(new BorderLayout());
		
	    setLayout(new BorderLayout());
	    description = new JTextArea(10, 40);
	    description.setText("Welcome to TouchFree!\n\nThis jailbreak for firmware version 1.1.2 is brought to you by the iPhone/touch dev team: planetbeing, drudge, pumpkin, roxfan, dinopio, as well as many others whose shoulders we stand upon.\n\nBefore clicking the magic button, please make sure that you have already used OktoPrep in 1.1.1 and have now updated to 1.1.2");
	    description.setEditable(false);
	    description.setMargin(new Insets(5,5,5,5));
	    description.setLineWrap(true);
	    description.setWrapStyleWord(true);
	    description.setFont(Font.getFont("Arial"));
	    add(description, BorderLayout.CENTER);
	    
	    JPanel options = new JPanel(new GridBagLayout());
	    GridBagConstraints c = new GridBagConstraints();
	    c.fill = GridBagConstraints.HORIZONTAL;
	    c.gridx = 0;
	    c.gridy = 0;
	    options.add(new JLabel("Install SSH"), c);
	    c.fill = GridBagConstraints.HORIZONTAL;
	    c.gridx = 1;
	    c.gridy = 0;
	    options.add(installSSHField = new JCheckBox(), c);
	    c.fill = GridBagConstraints.HORIZONTAL;
	    c.gridx = 2;
	    c.gridy = 0;
	    options.add(new JLabel("Root Password: "), c);
	    c.fill = GridBagConstraints.HORIZONTAL;
	    c.gridx = 3;
	    c.gridy = 0;
	    options.add(passwordField = new JTextField("alpine", 8), c);
	    c.fill = GridBagConstraints.HORIZONTAL;
	    c.gridx = 0;
	    c.gridy = 1;   
	    c.gridwidth = 4;
	    c.weightx = 1;
	    options.add(jailbreakButton = new JButton("Jailbreak!"), c);
	    jailbreakButton.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
            	jailbreakButtonActionPerformed(evt);
            }
        });
	    add(options, BorderLayout.SOUTH);
	}
	
	class Task implements Runnable {
        public void run() {
        	tfMonitor = new TFProgressMonitor(monitor);
        	engine = new TouchFreeEngine(iphucLocation, ".", tfMonitor, tfMonitor, tfMonitor);
        	
        	javax.swing.SwingUtilities.invokeLater(new Runnable() {
                public void run() {
                	monitor.setMaximum((int)engine.jailbreakSize(true, installSSH));
                }
            });
    	    
    	    
    	    try {
    	    	if(engine.jailbreak(true, installSSH, tfMonitor)) {
    	    		engine.setPasswordJailbreak(password);
    	    		javax.swing.SwingUtilities.invokeLater(new Runnable() {
    	                public void run() {
    	                	monitor.setProgress(monitor.getMaximum());
    	                }
    	            });
    	    	} else {
    	    		javax.swing.SwingUtilities.invokeLater(new Runnable() {
    	                public void run() {
    	                	JOptionPane.showMessageDialog(null, "An unrecoverable error was encountered during the jailbreak. See console for details.", "Jailbreak failed", JOptionPane.ERROR_MESSAGE);
    	                	engine.done();
    	                	System.exit(0);
    	                }
    	            });
    	    	}
    	    } catch (Exception e) {
    	    	
    	    }
    	    
    	    engine.done();
    	    
    	    javax.swing.SwingUtilities.invokeLater(new Runnable() {
                public void run() {
                	JOptionPane.showMessageDialog(null, "Done! Reboot your device (it will automatically reboot once after you do so)", "Jailbreak complete!", JOptionPane.INFORMATION_MESSAGE);
                	System.exit(0);
                }
            });
        }
    }
	
	private void jailbreakButtonActionPerformed(java.awt.event.ActionEvent evt) {
		
		monitor = new ProgressMonitor(null, "Jailbreaking...", "", 0, 100);
		monitor.setMillisToDecideToPopup(0);
		monitor.setMillisToPopup(0);
		monitor.setProgress(0);
		jailbreakButton.setEnabled(false);
	    f.setVisible(false);
	    
	    installSSH = installSSHField.isSelected();
	    password = passwordField.getText();
	    
	    jbThread = new Thread(new Task());
	    jbThread.start();
    }
	
	private static void createAndShowGUI()  {
		try {
			UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
		} catch (Exception e) {
			
		}
		
	    f = new JFrame("1.1.2 Jailbreak");
	    f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	    f.setSize(400, 200);
	    
	    JComponent newContentPane = new Jailbreak();
        newContentPane.setOpaque(true); //content panes must be opaque
        f.setContentPane(newContentPane);
	    
	    f.pack();
	    f.setLocationRelativeTo(null);
	    f.setVisible(true);

	}
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {
		try {
			if(System.getProperty("os.name").contains("Mac")) {
				iphucLocation = (new File("iphuc")).getCanonicalPath();
			} else {
				iphucLocation = (new File("iphuc.exe")).getCanonicalPath();
			}
		} catch (IOException e) {
			System.out.println("Cannot find iPHUC!");
			return;
		}
		
		javax.swing.SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                createAndShowGUI();
            }
        });
		
	    /*Container content = f.getContentPane();
	    content.setBackground(Color.white);
	    content.setLayout(new BoxLayout(content, BoxLayout.PAGE_AXIS));
	    content.add(status = new JLabel("Welcome to TouchFree!"));
	    JPanel cards = new JPanel(new CardLayout());
	    JPanel card1 = new JPanel();
	    JPanel card2 = new JPanel();
	    card1.add(jailbreakButton = new JButton("Jailbreak!"), "BUTTON");
	    card2.add(progressBar = new JProgressBar(), "PROGRESS");
	    ((CardLayout)(cards.getLayout())).show(cards, "PROGRESS");
	    content.add(cards);
	    f.setVisible(true);*/
	    /*
		BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
		
		String iphucLocation;
		
		try {
			if(System.getProperty("os.name").contains("Mac")) {
				iphucLocation = (new File("iphuc")).getCanonicalPath();
			} else {
				iphucLocation = (new File("iphuc.exe")).getCanonicalPath();
			}
		} catch (IOException e) {
			System.out.println("Cannot find iPHUC!");
			return;
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
			
		}*/
	}

}
