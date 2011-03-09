/*
	BATTLE TACTICS - SERVER CORE V0.0.1a
	Author: Code Slacker
	Description: Adds/Removes people from teams, tells the join scripts when people can join, tells debit script the price to join, starts a game, handles global server messages, communicates to HUDs
	
	<LICENSE>
	    Copyright (C) 2011  Code Slacker
	
	    This program is free software: you can redistribute it and/or modify
	    it under the terms of the GNU General Public License as published by
	    the Free Software Foundation, either version 3 of the License, or
	    (at your option) any later version.
	
	    This program is distributed in the hope that it will be useful,
	    but WITHOUT ANY WARRANTY; without even the implied warranty of
	    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	    GNU General Public License for more details.
	
	    You should have received a copy of the GNU General Public License
	    along with this program.  If not, see <http://www.gnu.org/licenses/>.	
	</LICENSE>
	
*/

/*
	=======================================
	CHANGE LOG
	
	=======================================
*/


// CONSTANTS
// link message numbers (LMNUM)
integer g_LMNUM_GLOBAL = 0;					// global server messages
integer g_LMNUM_CONFIG = 1;					// configuration message
integer g_LMNUM_JOIN = 2;					// join messages
integer g_LMNUM_DEBIT = 3;					// debit messages
integer g_LMNUM_BOARD = 4;					// board messages
integer g_LMNUM_MENU = 5;					// menu button messages
integer g_LMNUM_IM = 6;						// instant message messages
integer g_LMNUM_ITEMS = 7;					// item giver messages

// channel numbers
integer g_CHANNEL_GLOBAL = -9454200;		// global server messages (such as "kill" or "start" messages)

// team numbers
integer g_TEAM_RED = 0;
integer g_TEAM_BLUE = 1;



// VARIABLES

// <configuration section>
// payout options
integer g_configPayout 		= FALSE;				// pay out to winners
integer g_configPayoutAll 	= TRUE;					// pay out to ALL winners (if the pot can't be divided evenly)
integer g_configInitialPot 	= 0;					// initial pot to start each game with

// refinery options
integer g_configRefNum 		= 2;					// number of refineries per team
integer g_configRefAmount	= 4;					// amount of money to give each person per refinery on an interval
float g_configRefInterval	= 1.0;					// interval to give money

// time options (represented in minutes)
float g_configTimeOutJoin	= 4.0;					// join time out
// </configuration section>



// pot variables
integer g_pot = 0;				// amount of money in the pot
integer g_potDivided = 0;		// amount of money to pay each individual


// these two lists are parallel
list g_redPlayers = [];			// list of red player keys
list g_redReady = [];			// list of red players that are ready (easier to just use llListStatistics to check if everyone is ready)

list g_bluePlayers = [];		// list of blue player keys
list g_blueReady = [];			// list of blue players that are ready

// lists used for displaying the players on each team and relaying it to the join scripts (this reduces llKey2Name calls)
list g_redNames = [];
list g_blueNames = [];




// FUNCTIONS
// Setup()	- Sets up the server
Setup()
{
	llMessageLinked(LINK_THIS, g_LMNUM_DEBIT, "price", "hide");		// hide the price
	llMessageLinked(LINK_THIS, g_LMNUM_JOIN, "join", "no");			// tell the join scripts that joining is not allowed
	llMessageLinked(LINK_THIS, g_LMNUM_CONFIG, "request", "");		// request configuration data
}


// AddPlayer()	- Adds a player to a team (if they aren't already on another)
AddPlayer(key id, integer team)
{
	// check if they're on a team
	if (llListFindList(g_redPlayers, [id]) > -1)
	{
		llMessageLinked(LINK_THIS, g_LMNUM_IM, "You are already on red!", id);
		return;
	}
	
	if (llListFindList(g_bluePlayers, [id]) > -1)
	{
		llMessageLinked(LINK_THIS, g_LMNUM_IM, "You are already on blue!", id);
		return;
	}
	
	// they're not on a team
	if (team == g_TEAM_RED)
	{
		g_redPlayers += [id];
		g_redReady += [FALSE];
		g_redNames += [llKey2Name(id)];
	}
	
	else if (team == g_TEAM_BLUE)
	{
		g_bluePlayers += [id];
		g_blueReady += [FALSE];
		g_blueNames += [llKey2Name(id)];
	}
	
}



// PlayerReady()	- Makes a player ready
PlayerReady(key id)
{
	integer index = llListFindList(g_redPlayers, [id]);
	if (index > -1)
	{
		g_redReady = llListReplaceList(g_redReady, [TRUE], index, index);
		CheckReady();
		return;
	}
	
	index = llListFindList(g_redPlayers, [id]);
	if (index > -1)
	{
		g_redReady = llListReplaceList(g_redReady, [TRUE], index, index);
		CheckReady();
		return;
	}
	
}


// CheckReady()		- Checks if all players are ready, if so start the game
CheckReady()
{
	integer num_of_players = llGetListLength(g_redPlayers) + llGetListLength(g_bluePlayers);
	integer sum = llRound(llListStatistics(LIST_STAT_SUM, g_redReady) + llListStatistics(LIST_STAT_SUM, g_blueReady));
	
	// all players are ready
	if (sum == num_of_players)
	{
		StartGame();
	}
}


// StartGame()		- Starts a new game
StartGame()
{
	llMessageLinked(LINK_ALL_OTHERS, g_LMNUM_JOIN, "join", "no");
	llMessageLinked(LINK_THIS, g_LMNUM_DEBIT, "price", "hide");
}



default
{
	on_rez(integer param)
	{
		llResetScript();
	}
	
	state_entry()
	{
		Setup();
	}
	
	
	listen(integer channel, string name, key id, string msg)
	{
		
	}
	
	
	link_message(integer link_num, integer num, string msg, key id)
	{
		// config message
		if (num == g_LMNUM_CONFIG && msg == "core")
		{
			
				
		}	// end of config message
		
		
		// join message
		else if (num == g_LMNUM_JOIN)
		{
			// add to red team
			if (msg == "add_red")
			{
				
			}
			
			// add to blue team
			else if (msg == "add_blue")
			{
				
			}
			
		}	// end of join message
		
		
	}
	
}