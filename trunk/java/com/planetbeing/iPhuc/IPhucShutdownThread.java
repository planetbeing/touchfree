package com.planetbeing.iPhuc;

public class IPhucShutdownThread extends Thread {
	IPhuc toShutdown;
	
	public IPhucShutdownThread(IPhuc toShutdown) {
		this.toShutdown = toShutdown;
	}
	
	public void run() {
		toShutdown.kill();
    }
}
