package com.planetbeing.iPhuc;
/*
 *  Written by planetbeing, 2007
 *  
 *  This file is part of touchFree.
 *
 *  touchFree is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  touchFree is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with touchFree.  If not, see <http://www.gnu.org/licenses/>.
 *  
 */


import java.io.*;


public class IPhuc implements Runnable {
	private String path;
	private Process p;
	private InputStream stdout;
	private Writer stdin;
	
	LineParser lineParser = new DefaultLineParser();
	private boolean atPrompt = false;
	
	public IPhuc(String path) {
		this.path = path;
		Runtime.getRuntime().addShutdownHook(new IPhucShutdownThread(this));
		start();
	}
	
	public void merge(String localPath, String remoteAbsolutePath) {
		File localFile = new File(localPath);
		String path = remoteAbsolutePath.replaceAll(" ", "\\ ");
		
		mkdir(path);
		File[] files = localFile.listFiles();
		for(int i = 0; i < files.length; i++) {
			if(files[i].isFile()) {
				uploadFile(files[i].getAbsolutePath(), path + "/" + files[i].getName());
			} else {
				recursiveUpload(files[i].getAbsolutePath(), path);
			}
		}		
	}
	
	public void recursiveUpload(String localPath, String remoteAbsolutePath) {
		File localFile = new File(localPath);
		String path = (remoteAbsolutePath + "/" + localFile.getName()).replaceAll(" ", "\\ ");
		
		mkdir(path);
		File[] files = localFile.listFiles();
		for(int i = 0; i < files.length; i++) {
			if(files[i].isFile()) {
				uploadFile(files[i].getAbsolutePath(), path + "/" + files[i].getName());
			} else {
				recursiveUpload(files[i].getAbsolutePath(), path);
			}
		}
	}
	
	public void uploadFile(String localPath, String remoteAbsolutePath) {
		File localFile = new File(localPath);
		String remoteDir = (new File(remoteAbsolutePath)).getParent().replace(File.separatorChar, '/').replaceAll(" ", "\\ ");
		mkdir(remoteDir);
		
		//System.out.println(localPath);
		while(getFileSize(remoteAbsolutePath) != localFile.length()) {
			execute("putfile " + getAbsolutePath(localPath) + " " + remoteAbsolutePath);
		}
	}
	
	public String getAbsolutePath(String path) {
		String absolutePath = (new File(path)).getAbsolutePath();
		
		if(File.separatorChar == '/') {
			return absolutePath.replaceAll(" ", "\\ ");
		} else {
			return (new File(absolutePath)).toURI().toASCIIString().replaceAll("file:/", "file:///");
		}
	}
	
	public void mkdir(String remoteDir) {
		while(!fileExists(remoteDir)) {
			execute("mkdir " + remoteDir);
		}
	}
	
	public long getFileSize(String remotePath) {
		long size = 0;
		String[] results = execute("getfilesize " + remotePath);
		for(int i = 0; i < results.length; i++) {
			String[] parts = results[i].split(" ");
			for(int j = 0; j < parts.length; j++) {
				try {
					size = Long.parseLong(parts[j]);
				} catch (NumberFormatException e) {
					
				}
			}
		}
		return size;
	}
	
	public boolean fileExists(String remotePath) {
		File remoteFile = new File(remotePath);
		String remoteDir = remoteFile.getParent().replace(File.separatorChar, '/');
		String remoteFilename = remoteFile.getName();		
		String[] results = execute("ls " + remoteDir);
	
		for(int i = 0; i < results.length; i++) {
			if(results[i].compareTo(remoteFilename) == 0) {
				return true;
			}
		}
		
		return false;
	}
	
	public void setAfc(String afc)
	{
		done();
		start();
		execute("setafc " + afc);
	}
	
	public void readImage(String localFile, ProgressListener listener) {
		do {
			execute("getfile /dev/rdisk0s1 " + getAbsolutePath(localFile) + " 314572800", new ProgressLineParser(listener));
		} while ((new File(localFile)).length() != 314572800);
	}
	
	public void writeImage(String localFile, ProgressListener listener) {
		execute("putfile " + getAbsolutePath(localFile) + " /dev/rdisk0s1", new ProgressLineParser(listener));
	}
	
	public void start() {
		try {
			atPrompt = false;
			p = Runtime.getRuntime().exec(path);
			stdout = p.getInputStream();
			stdin = new BufferedWriter(new OutputStreamWriter(p.getOutputStream()));
		} catch(IOException e) {
		}
	}
	
	public boolean isConnected() {
		Thread myThread = new Thread(this);
		myThread.start();
		try {
			myThread.join(2000);
		} catch (InterruptedException e) {
			
		}
		return atPrompt;
	}
	
	public void kill() {
		if(p != null) {
			p.destroy();
			p = null;
		}
		
		if(stdin != null) {
			try {
				Writer myStdin = stdin;
				stdin = null;
				myStdin.close();
			} catch(IOException e) {
				
			}
		}
		
		if(stdout != null) {
			stdout = null; 
		}
	}
	
	public void run() {
		waitForPrompt();
	}
	
	public void waitForPrompt() {
		String currentLine = "";
		char[] match = new char[] {'\n', '(', 'i', 'P', 'H', 'U', 'C', ')'};
		int matchPosition = 0;
			
		if(atPrompt)
			return;
		
		try {
			do {
				int readResult = stdout.read();
				if(stdout == null) {
					return;
				}
				
				if(readResult == -1) {
					start();
					continue;
				}
				
				if(readResult == '\n') {
					lineParser.parseLine(currentLine.trim());
					currentLine = "";
				} else {
					currentLine += (char)readResult;
				}
				
				if(readResult == match[matchPosition]) {
					matchPosition++;
					
					if(matchPosition == match.length) {
						while (stdout.read() != ':');
						stdout.read(); // this ought to be ' '
						break;
					}
				}
			
			} while(true);
			
			atPrompt = true;
		} catch(IOException e) {
			
		} catch(NullPointerException e) {
			
		}
	}
	
	public String[] execute(String command) {
		StoreLineParser parser = new StoreLineParser();
		execute(command, parser);
		return parser.getLines();
	}
	
	public void execute(String command, LineParser parser)
	{
		try {
			
			waitForPrompt();
			
			lineParser = parser;
			
			stdin.write(command + "\n");
			stdin.flush();
			
			atPrompt = false;
			waitForPrompt();
			
			lineParser = new DefaultLineParser();
			
		} catch(IOException e) {
		}
	}
	
	public void done() {
		try {
			stdin.write("exit\n");
			stdin.flush();
		} catch(IOException e) {
			
		}
	}
	
	public int patch(String fileName, String[][] toReplace, ProgressListener listener)
    {
        int bufferSize = 4 * 1024 * 1024;
        int bufferPosition = 0;
        long searched = 0;
        byte[] buffer = new byte[bufferSize];
        int numSearches = toReplace.length;
        int[] matchState = new int[numSearches];
        long[] matchLength = new long[numSearches];
        byte[][][] searchBuffers = new byte[numSearches][][];
        long fileLength;

        //gui.SetProgressBar(0);

        try {
	        for (int i = 0; i < numSearches; i++)
	        {
	        	File in = new File(toReplace[i][0]);
	        	File out = new File(toReplace[i][1]);;
	        	
	            searchBuffers[i] = new byte[2][];
	            searchBuffers[i][0] = new byte[(int)in.length()];
	            searchBuffers[i][1] = new byte[(int)out.length()];
	            (new FileInputStream(in)).read(searchBuffers[i][0], 0, (int)in.length());
	            (new FileInputStream(out)).read(searchBuffers[i][1], 0, (int)out.length());
	            
	            matchState[i] = 0;
	            matchLength[i] = searchBuffers[i][0].length;
	            //System.out.println(new String(searchBuffers[i][0]));
	            //System.out.println(new String(searchBuffers[i][1]));
	            //System.out.println(matchLength[i]);
	        }
	
	        RandomAccessFile stream = new RandomAccessFile(fileName, "rw");
	        fileLength = stream.length();
	        while (searched < fileLength)
	        {
	            if (bufferPosition == 0)
	            {
	                stream.read(buffer, 0, bufferSize);
	                listener.progress(searched, fileLength);
	            }
	
	            for (int i = 0; i < numSearches; i++)
	            {
                    if (searchBuffers[i][0][matchState[i]] == buffer[bufferPosition])
                    {
                        matchState[i]++;
                        if (matchState[i] == matchLength[i])
                        {
                        	//System.out.println("matched: " + i);
                        	long currentPos = stream.getFilePointer();
                        	stream.seek(searched + 1 - matchLength[i]);
            	            stream.write(searchBuffers[i][1], 0, searchBuffers[i][1].length);
            	            stream.seek(currentPos);
            	            matchState[i] = 0;
                        }
                    }
                    else
                    {
                        matchState[i] = 0;
                    }
	            }
	
	            searched++;
	            bufferPosition = (bufferPosition + 1) % bufferSize;	
	        }
	        stream.close();
        } catch (Exception e) 
        {
        	return -1;
        }

        //gui.SetProgressBar(100);

        return 0;
        
    }
	
	public void afcExecute(String afc) throws IOException {
		Runtime.getRuntime().exec(new String[] { path, "-o", "setafc " + afc });
	}
	
}
