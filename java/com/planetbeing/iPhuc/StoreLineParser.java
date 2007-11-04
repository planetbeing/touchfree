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

import java.util.*;

public class StoreLineParser implements LineParser {
	LinkedList lines = new LinkedList();
	
	public void parseLine(String line) {
		//System.out.println("line: " + line);
		lines.add(line);
		// TODO Auto-generated method stub

	}
	
	public String[] getLines() {
		int i = 0;
		String[] myLines = new String[lines.size()];
		ListIterator iter = lines.listIterator();
		
		while(iter.hasNext()) {
			myLines[i] = (String)iter.next();
			i++;
		}
		
		return myLines;
	}

}
