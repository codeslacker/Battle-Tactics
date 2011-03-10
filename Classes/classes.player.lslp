/*
	BATTLE TACTICS - PLAYER CLASS v0.0.1a
	Author: Code Slacker
	Description: Handles player health, money and building
	
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
// channels
integer g_CHANNEL_GLOBAL = -9454200;		// global messages (such as "kill")
integer g_CHANNEL_PLAYERS = -9454201;		// channel for Player messages
integer g_CHANNEL_HUD = -9454202;			// channel for HUD messages

// stats
integer g_MAX_HEALTH = 100;					// maximum health the class has
integer g_DEF_POINTS = 5;					// defense points the class has

// sounds

key g_OWNER;								// the owner's key
key g_UUID;									// the UUID of this object


// VARIABLES
integer g_health;							// amount of health the class has
integer g_money;							// amount of money the player has
integer g_team;								// team the player is on


// config settings
integer g_configRefNum;						// number of refineries
integer g_configRefAmount;					// the amount of money each refinery generates
float g_configRefInterval;					// the interval for generating money
integer g_configInitialMoney;				// initial amount of money to start off with

// listen handles
integer g_lhGlobal;							// global messages handle
integer g_lhPlayers;						// the player handle
integer g_lhHUD;							// the HUD handle

float g_playerHeight;						// height of the player

key g_player;								// the player's key


// FUNCTIONS
// Initialization
Init()
{
	g_OWNER = llGetOwner();
	g_UUID = llGetKey();
	
	llSetStatus(STATUS_PHANTOM, TRUE);
	
	llParticleSystem([]);		// clear any particles
	
	g_health = g_MAX_HEALTH;
	// UpdateHealthBar();
	
	g_lhGlobal = llListen(g_CHANNEL_GLOBAL, "Battle Tactics Game v1", NULL_KEY, "");
	g_lhPlayers = llListen(g_CHANNEL_PLAYERS, "Battle Tactics Game v1", NULL_KEY, "");
}


// Impair damage
Damage(integer attack)
{
	integer dmg = llRound((attack / g_DEF_POINTS) * 2);
	
	g_health -= dmg;
	
	// dead
	if (g_health <= 0)
	{
		Destroy();
		return;
	}
	
	UpdateHealthBar();
}


// Updates the health bar above the class
UpdateHealthBar()
{
	string text = "(" + (string)g_health + "%) ";
	
	float red = (100 - g_health) / (float)g_MAX_HEALTH;
	float green = g_health / (float)g_MAX_HEALTH;
	vector color = <red, green, 0.0>;
	
	integer num_of_bars = llFloor(g_health / 10);
	
	integer i;
	for (i=0; i<num_of_bars; i++)
	{
		text += "█";
	}
	
	llSetText(text, color, 1.0);
	
	float alpha = (g_health / 100.0) + 0.2;		// set the alpha but don't let it get too low
	llSetAlpha(alpha, ALL_SIDES);
		
}


// Destroys the object
Destroy()
{
	llSetText("**** DEAD ****", <1.0, 0.0, 0.0>, 1.0);

	llSleep(5.0);
	
	llListenRemove(g_lhGlobal);
	
	llDie();		// kill the object
}


// Activates the Player object; means the game started
Activate()
{
	vector agent_size = llGetAgentSize(g_player);
	g_playerHeight = agent_size.z;
	
	Follow();
}


// Follows the player
Follow()
{
	list obj_details = llGetObjectDetails(g_player, [OBJECT_POS]);
	vector pos = llList2Vector(obj_details, 0);
	
	// not in sim
	if (pos == ZERO_VECTOR)
	{
		llSay(0, "Player " + llKey2Name(g_player) + " has left the game.");
		Destroy();
		return;
	}
	
	// they are in the sim
	pos.z = pos.z + (g_playerHeight / 2);
	
	llSetLinkPrimitiveParamsFast(LINK_SET, [PRIM_POSITION, pos]);
}


default
{
	on_rez(integer param)
	{
		llResetScript();
	}
	
	state_entry()
	{
		Init();
	}
	
	listen(integer channel, string name, key id, string msg)
	{
		// if the owner's server is talking
		if (llGetOwnerKey(id) == g_OWNER)
		{
			// global channel
			if (channel == g_CHANNEL_GLOBAL)
			{
				if (msg == "kill")
				{
					Destroy();
				}
				
				// start message
				else if (llGetSubString(msg, 0, 8) == "countdown")
				{
					float sleep = (float)llGetSubString(msg, 9, -1);
					llSleep(sleep);
					Activate();
				}
			}
			
			// players channel
			else if (channel == g_CHANNEL_PLAYERS)
			{					
				llListenRemove(g_lhPlayers);		// remove old listener
				
				// parse data
				list parsed = llParseString2List(msg, [";"], []);
				key uuid = (key)llList2String(parsed, 0);
				
				// if not talking to this object
				if (uuid != g_UUID)
				{
					return;		// exit event
				}
				
				g_player 			= (key)llList2String(parsed, 1);
				g_team 				= (integer)llList2String(parsed, 2);
				g_configRefNum 		= (integer)llList2String(parsed, 3);
				g_configRefAmount 	= (integer)llList2String(parsed, 4);
				g_configRefInterval = (float)llList2String(parsed, 5);
				
				
			}
		}
		
		// player HUD is talking
		else if (channel == g_CHANNEL_PLAYERS && llGetOwnerKey(id) == g_player)
		{
			
		}
		
	}
	
}