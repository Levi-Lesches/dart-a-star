/*
Copyright (C) 2009 by Benjamin Hardin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

// from http://46dogs.blogspot.com/2009/10/star-pathroute-finding-javascript-code.html

function a_star(startXY, destinationXY, board, columns, rows)
{
	//Create start and destination as true nodes
	var start = new node(startXY[0], startXY[1], -1, -1, -1, -1);
	var destination = new node(destinationXY[0], destinationXY[1], -1, -1, -1, -1);
	
	var open = []; //List of open nodes (nodes to be inspected)
	var closed = []; //List of closed nodes (nodes we've already inspected)

	var g = 0; //Cost from start to current node
	var h = heuristic(start, destination); //Cost from current node to destination
	var f = g+h; //Cost from start to destination going through the current node

	//Push the start node onto the list of open nodes
	open.push(start); 

	//Keep going while there's nodes in our open list
	while (open.length > 0)
	{
		//Find the best open node (lowest f value)

		//Alternately, you could simply keep the open list sorted by f value lowest to highest,
		//in which case you always use the first node
		var best_cost = open[0].f;
		var best_node = 0;
		
		for (var i = 1; i < open.length; i++)
		{
			if (open[i].f < best_cost)
			{
				best_cost = open[i].f;
				best_node = i;
			}
		}

		//Set it as our current node
		var current_node = open[best_node];
		
		//Check if we've reached our destination
		if (current_node.x == destination.x && current_node.y == destination.y)
		{
			var path = [destination]; //Initialize the path with the destination node

			//Go up the chain to recreate the path 
			while (current_node.parent_index != -1)
			{
				current_node = closed[current_node.parent_index];
				path.unshift(current_node);
			}
			
			return path;
		}

		//Remove the current node from our open list
		open.splice(best_node, 1);

		//Push it onto the closed list
		closed.push(current_node);

		//Expand our current node (look in all 8 directions)
		for (var new_node_x = Math.max(0, current_node.x-1); new_node_x <= Math.min(columns-1, current_node.x+1); new_node_x++)
			for (var new_node_y = Math.max(0, current_node.y-1); new_node_y <= Math.min(rows-1, current_node.y+1); new_node_y++)
			{
				if (board[new_node_x][new_node_y] == 0 //If the new node is open
					|| (destination.x == new_node_x && destination.y == new_node_y)) //or the new node is our destination
				{
					//See if the node is already in our closed list. If so, skip it.
					var found_in_closed = false;
					for (var i in closed)
						if (closed[i].x == new_node_x && closed[i].y == new_node_y)
						{
							found_in_closed = true;
							break;
						}

					if (found_in_closed)
						continue;

					//See if the node is in our open list. If not, use it.
					var found_in_open = false;
					for (var i in open)
						if (open[i].x == new_node_x && open[i].y == new_node_y)
						{
							found_in_open = true;
							break;
						}

					if (!found_in_open)
					{
						var new_node = new node(new_node_x, new_node_y, closed.length-1, -1, -1, -1);

						new_node.g = current_node.g + Math.floor(Math.sqrt(Math.pow(new_node.x-current_node.x, 2)+Math.pow(new_node.y-current_node.y, 2)));
						new_node.h = heuristic(new_node, destination);
						new_node.f = new_node.g+new_node.h;

						open.push(new_node);
					}
				}
			}
	}
	
	return [];
}

//An A* heurisitic must be admissible, meaning it must never overestimate the distance to the goal.
//In other words, it must either underestimate or return exactly the distance to the goal.
function heuristic(current_node, destination)
{
	//Find the straight-line distance between the current node and the destination. (Thanks to id for the improvement)
	//return Math.floor(Math.sqrt(Math.pow(current_node.x-destination.x, 2)+Math.pow(current_node.y-destination.y, 2)));
	var x = current_node.x-destination.x;
	var y = current_node.y-destination.y;
	return x*x+y*y;
}


/* Each node will have six values: 
 X position
 Y position
 Index of the node's parent in the closed array
 Cost from start to current node
 Heuristic cost from current node to destination
 Cost from start to destination going through the current node
*/	

function node(x, y, parent_index, g, h, f)
{
	this.x = x;
	this.y = y;
	this.parent_index = parent_index;
	this.g = g;
	this.h = h;
	this.f = f;
}



// added by Seth

function main() {

  //Create the board, setting random squares to be obstacles
  var rows = 10;
    var columns = 10;

    //Create the board, setting random squares to be obstacles
    var board = [];
    for (var x = 0; x < columns; x++)
    {
        board[x] = [];

        for (var y = 0; y < rows; y++)
        {
            //Give each square a 25% chance of being an obstacle
            //var square = Math.floor(Math.random()*4);
            var square = 1;

            //0 = open, 1 = obstacle
            if (square == 0)
                board[x][y] = 1;
            else
                board[x][y] = 0;
        }
    }
 
    //Set the start and destination squares
    var start = [1, 1];
    board[1][1] = 0;

    var destination = [8, 8];
    board[8][8] = 0;
        
    var path;
    
    var startTime = new Date().getTime();
    
    for (var i = 0; i < 100000; i++) {
      path = a_star(start, destination, board, rows, columns);
    }
    
    var stopTime = new Date().getTime();

    print("Done: " + (stopTime - startTime));
    print('Path is ' + path.length + ' long and last is ' + path[path.length-1].x + ',' + path[path.length-1].y);
}

main();