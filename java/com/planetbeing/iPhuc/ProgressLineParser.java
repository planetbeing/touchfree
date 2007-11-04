package com.planetbeing.iPhuc;

public class ProgressLineParser implements LineParser {
	long total = -1;
	long progress = 0;
	long lastRead = 0;
	ProgressListener listener;
	
	public ProgressLineParser(ProgressListener listener) {
		this.listener = listener; 
	}
	
	
	public void parseLine(String line) {
		long reading;
		long remaining;
		
		String[] parts = line.split(" ");
		
		if(parts.length != 6)
			return;
	
		try {
			reading = Long.parseLong(parts[1]);
			remaining = Long.parseLong(parts[3]);
		} catch(NumberFormatException e) {
			return;
		}
		
		if(total == -1) {
			total = reading + remaining;
			progress = 0;
		} else {
			progress += lastRead;
		}
		
		lastRead = reading;
	
		listener.progress(progress, total);
	}

}
