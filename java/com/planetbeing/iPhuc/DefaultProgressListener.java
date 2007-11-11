package com.planetbeing.iPhuc;

public class DefaultProgressListener implements ProgressListener {

	public void progress(long progress, long total) {
		System.out.println(progress + "/" + total);
	}
	
	public void start() {
		
	}

}
