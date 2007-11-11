import javax.swing.*;

import com.planetbeing.iPhuc.*;
import com.planetbeing.touchFree.ErrorListener;
import com.planetbeing.touchFree.StatusListener;

public class TFProgressMonitor implements JBProgressMonitor, ErrorListener, StatusListener, ProgressListener {
	ProgressMonitor monitor;
	int current = 0;
	int before = 0;
	String currentMsg;
	
	public TFProgressMonitor(ProgressMonitor monitor) {
		this.monitor = monitor;
	}
	
	public void progress(int p) {
		current += p;
		
		javax.swing.SwingUtilities.invokeLater(new Runnable() {
            public void run() {
            	monitor.setProgress(current);
            	
            	if (monitor.isCanceled()) {
            		System.exit(0);
            	}
            }
        });
	}

	public void error(String msg) {
		System.err.println(msg);
		currentMsg = msg;
		javax.swing.SwingUtilities.invokeLater(new Runnable() {
            public void run() {
            	monitor.setNote(currentMsg);
            	
            	if (monitor.isCanceled()) {
            		System.exit(0);
            	}
            	
            	JOptionPane.showMessageDialog(null, currentMsg, "Error", JOptionPane.ERROR_MESSAGE);
            }
        });
	}
	
	public void message(String msg) {
		System.out.println(msg);
		currentMsg = msg;
		javax.swing.SwingUtilities.invokeLater(new Runnable() {
            public void run() {
            	monitor.setNote(currentMsg);
            	
            	if (monitor.isCanceled()) {
            		System.exit(0);
            	}
            }
        });
	}

	public void progress(long progress, long total) {
		System.out.println(progress + "/" + total);
		
		current = before + ((int)progress);
		
		javax.swing.SwingUtilities.invokeLater(new Runnable() {
            public void run() {
            	monitor.setProgress(current);
            	
            	if (monitor.isCanceled()) {
            		System.exit(0);
            	}
            }
        });
		
	}
	
	public void start() {
		before = current;
	}
}
