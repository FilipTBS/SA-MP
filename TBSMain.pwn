/*
							 ____________     _______         ______
							|____    ____|   |   __  \      / ______\
								 |  |        |  |  |  |    | /
								 |  |        |  |__|  /    | \ _____
		 						 |  |        |   __  |     \______  \
								 |  |        |  |  |  \           \ |
								 |  |        |  |__|  |     ______/ |
								 |__|		 |_______/     \________/
								 
							-----------------------------------------------
								Topic: TheBestStunts (v2 / y_ini + dini)
								File: TBSMain.pwn
								Authors: George and Filip
								Editor: FreAkeD
								Build: 17
							-----------------------------------------------
*/
//----------------
// Includes
//----------------
#include <a_samp>
//#include <crashdetect>
#include <sscanf2>
#include <zcmd>
#include <foreach>
#include <YSI\y_ini>
#include <TimeStampToDate>
#include <streamer>
#include <dini>
#include <a_angles> //Special Angle Functions
#include <Dutils>
#include <Dudb>
#include <floodcontrol>
// ------------------
// Defines
//------------------
#pragma dynamic 150000
#pragma tabsize 0
#define aselect 111111
#define VERSION Build 17
#define SERVER_WEBSITE "TBS-OFFICIAL.EU"
#define Path "Users/%s.ini"
#define ServerStats "tbsServer/ServerStats.ini"
#define REGISTER 2000
#define LOGIN 2001
#define WEAPONS 101
#define DIALOG_COLOR 102
#define DIALOG_ADMINS 103
#define DIALOG_VIPS 104
#define DIALOG_CUSTOMSPAWN 105
#define DIALOG_GM 106
#define DIALOG_RULES 107
#define DIALOG_HELP 200
#define DIALOG_SPAWN 201
#define DIALOG_CMDS 202
#define DIALOG_KEYS 199
#define DIALOG_CREDITS 99
#define DIALOG_TELES 203
#define DIALOG_CHANGENAME 204
#define DIALOG_SETTINGS 205
#define DIALOG_STATS 206
#define DIALOG_MUSIC 207
#define DIALOG_ADMINAPP 208
#define DIALOG_VIPAPP 209
#define DIALOG_DM 210
#define DIALOG_DONATE 211
#define DIALOG_STUNT 212
#define DIALOG_NEWS 213
#define DIALOG_DJAPP 214
#define DIALOG_MUSIC2 215
#define DIALOG_MUSIC3 216
#define DIALOG_BANK 	(898)
#define DIALOG_BALANCE  (899)
#define DIALOG_DEPOSIT  (901)
#define DIALOG_WITHDRAW (903)
#define DIALOG_BANK2 	(8989)
#define DIALOG_BANK3    (8990)
#define MAX_RACE_CHECKPOINTS_EACH_RACE \
 	120
#define MAX_RACES \
 	100
#define COLGREY \
	0xAFAFAFAA

#define COLGREEN \
	0x9FFF00FF

#define COLRED \
	0xE60000FF

#define COLYELLOW \
	0xFFFF00AA

#define COLWHITE \
	0xFFFFFFAA

#define ForEach(%0,%1) \
	for(new %0 = 0; %0 != %1; %0++) if(IsPlayerConnected(%0) && !IsPlayerNPC(%0))

#define Loop2(%0,%1) \
	for(new %0 = 0; %0 != %1; %0++)

#define IsOdd(%1) \
	((%1) & 1)

#define ConvertTime(%0,%1,%2,%3,%4) \
	new \
	    Float: %0 = floatdiv(%1, 60000) \
	;\
	%2 = floatround(%0, floatround_tozero); \
	%3 = floatround(floatmul(%0 - %2, 60), floatround_tozero); \
	%4 = floatround(floatmul(floatmul(%0 - %2, 60) - %3, 1000), floatround_tozero)

#define function1%0(%1) \
	forward%0(%1); public%0(%1)

#define MAX_RACE_CHECKPOINTS_EACH_RACE \
 	120
#define COUNT_DOWN_TILL_RACE_START \
	30 // seconds

#define MAX_RACE_TIME \
	300 // seconds

#define RACE_CHECKPOINT_SIZE \
	12.0

#define DEBUG_RACE \
	1

#define FLOAT_INFINITY 			(Float:0x7F800000)
#define MAXADMINLEVEL

#pragma unused ret_memcpy
#define 	TEAM_COPS       ( 1 )
#define 	TEAM_ROBBERS    ( 2 )
#define 	TEAM_PROROBBERS       ( 3 )
#define 	TEAM_SWAT    ( 4 )
#define 	TEAM_EROBBERS    ( 5 )
#define 	TEAM_ARMY    ( 6 )
#define DBLUE_ "{87CEFA}"
#define savefolder "/CNR/%s.ini"

#if !defined False
    stock bool:False = false;
#endif
//Actor
#define DIALOG_AM   2423
#define DIALOG_A1   2424
#define DIALOG_A2   2425
#define DIALOG_A3   2426
#define DIALOG_A4   2427
#define DIALOG_A5   2428
#define DIALOG_A6   2429
#define DIALOG_A7   2430
#define DIALOG_A8   2431
#define DIALOG_A9   2432
new actor,actormodelid,actorworld,Float:act_X,Float:act_Y,Float:act_Z,Float:act_A;

new bool:pInvincible[MAX_PLAYERS];
//Secutrity Van Heist
new C4[MAX_PLAYERS];
new FBTimer;
new CountTime;
new Counting;
new BagTime;
new BagCounting;
new VanMoved;
new SMoney;
new DetonateC4[MAX_PLAYERS];
new SecurityVanID[MAX_PLAYERS];
new SVBeingRobbed[MAX_VEHICLES];
new FullBag[MAX_PLAYERS];
new MoneyLeft[MAX_VEHICLES];
new Float:VanX,Float:VanY,Float:VanZ;
//Forwards
forward VanMovedTimer(playerid,Float:X,Float:Y,Float:Z);
forward FillingBags(playerid);
forward SecureMoney(playerid);
// Gates
enum _@en@agate
{
	Float:ag_openPos[3],
	Float:ag_closePos[6],
	bool:ag_status,
	ag_timer,
	ag_id
}
new gates[][_@en@agate] = {
	{{-1571.89014, 660.84381, 3.00}, {-1571.89014, 660.84381, 8.70, 0.0, 0.0, 90.00}, false, 0},
	{{900.84155, 2213.91162, 12.68217}, {900.8416, 2213.9116, 6.9698,   0.00000, 0.00000, 269.71289}, false, 0}, // FreAkeD's House Gate
	{{-1628.26184, 327.47751, 3.00}, {-1628.26184, 327.47751, 8.60, 0.0, 0.0,  0.00}, false, 0},
	{{-2433.40454, 496.81241, 25.0}, {-2433.40454, 496.81241, 31.4, 0.0, 0.0, 23.12}, false, 0},
	{{ -2571.56470, 580.02917, 10.0}, { -2571.56470, 580.02917, 14.8, 0.0, 0.0, 0.0}, false, 0}
};

//=== HostName ===
#define HOSTNAME_1  "The Best™ Stunts© - Official (0.3.7) [New Update]"
#define HOSTNAME_2  "The Best™ Stunts© - Official [ /donate for Platinum VIP]"
#define HOSTNAME_3  "The Best™ Stunts© - Official (0.3.7) [Party Place]"
#define BUILD      	"17"

new changeHostname;

//Defines
#define MAX_PLAYERVEHICLES 1
#define VehicleSpawnerLimit 1
//Vehicle Dialogs
//Dialogs                           I'm using bigger dialog ids to don't make conflict with your server dialogs.
#define Dialog_Unique_Vehicle 501
#define Dialog_Trailers_Vehicle 502
#define Dialog_Boats_Vehicle 503
#define Dialog_Station_Vehicle 504
#define Dialog_Sport_Vehicle 505
#define Dialog_Saloon_Vehicle 506
#define Dialog_Public_Service_Vehicle 507
#define Dialog_Off-Road_Vehicle 508
#define Dialog_Low-Rider_Vehicle 509
#define Dialog_Industry_Vehicle 510
#define Dialog_Convertable_Vehicle 511
#define Dialog_Bike_Vehicle 512
#define Dialog_Helicopters 513
#define Dialog_Airplanes 514
#define Dialog_Rc_Vehicle 515
#define Dialog_Vehicle 516

//vehicles
new Airplanes[] = { 592, 577, 511, 512, 593, 553, 476, 519, 460, 513 };
new Helicopters[] = { 548, 417, 487, 488, 497, 563, 469 };
new Bikes[] = { 581, 509, 481, 462, 521, 463, 510, 522, 461, 448, 471, 468, 586 };
new Convertibles[] = { 480, 533, 439, 555 };
new Industrials[] = { 499, 422, 482, 498, 609, 524, 578, 455, 403, 414, 582, 443, 514, 413, 515, 440, 543, 605, 459, 531, 408, 552, 478, 456, 554 };
new Lowriders[] = { 536, 575, 534, 567, 535, 566, 576, 412 };
new Offroad[] = { 568, 424, 573, 579, 400, 500, 444, 556, 557, 470, 489, 505, 495 };
new Public[] = { 416, 433, 431, 438, 437, 523, 427, 490, 528, 407, 544, 596, 598, 597, 599, 601, 420 };
new Saloons[] = { 445, 504, 401, 518, 527, 542, 507, 562, 585, 419, 526, 604, 466, 492, 474, 546, 517, 410, 551, 516, 467, 600, 426, 436, 547, 405, 580, 560, 550, 549, 540, 491, 529, 421 };
new Sport[] = { 602, 429, 496, 402, 541, 415, 589, 587, 565, 494, 502, 503, 411, 559, 603, 475, 506, 451, 558, 477 };
new Station[] = { 418, 404, 479, 458, 561 };
new Boats[] = { 472, 473, 493, 595, 484, 430, 453, 452, 446, 454 };
new Trailers[] = { 435, 450, 591, 606, 607, 610, 569, 590, 584, 570, 608, 611 };
new Unique[] = { 485, 537, 457, 483, 508, 532, 486, 406, 530, 538, 434, 545, 588, 571, 572, 423, 442, 428, 409, 574, 449, 525, 583, 539 };
new RC_Vehicles[] = { 441, 464, 465, 501, 564, 594 };

//=====[Internal Settings]=====
#define MINMONEY 				500      				//Minimum duel bet money - Useful for A/D servers. Set to 0 for A/D
#define MAX_DUELS 				40                  //Max duel maps.
#define MAX_DUEL_WEPS           3
#define MAX_INVITES             14
#define INVITERESET             60000               //Total time until an invite is considered denied



#define DUELFILES 				"/Duels/%d.ini"     //Set your own directory for the duel system.. Change DUEL_IDFILE too.
#define DUEL_IDFILE 			"/Duels/idset.ini"

#define SPEC_UPDATE     		1000
#define DUELDIAG 				6550
#define COLOR_DUEL 		0x00C224

#define neondialog 221


#define PUTIH 0xFFFFFFFF
// ******************************************************************************************************************************
// Settings that can be changed
// ******************************************************************************************************************************

// Default max number of players is set to 500, re-define it to 50
#undef MAX_PLAYERS
#define MAX_PLAYERS 1000

// Define housing parameters
#define MAX_BUSINESS				3000 // Defines the maximum number of businesses that can be created
#define MAX_BUSINESSPERPLAYER		3 // Defines the maximum number of businesses that any player can own (useable values: 1 to 20)

// Define path to business-files
#define BusinessFile "Business/Business%i.ini"
#define BusinessTimeFile "Business/BusinessTime.ini"

// Set the exit-time for exiting a business (required if you use custom-made islands, otherwise you'll fall into the water)
// Default: 1 second (1000 milliseconds)
new ExitBusinessTimer = 1000;

#define GANGS "Gangs/%d.ini"
#define MAX_GANG 30

#define FIRE "Gangs/Fire/%d.ini"
#define MAX_FIRE 30

// Define Dialogs
#define DialogCreateBusSelType      2501
#define DialogBusinessNameChange    2502
#define DialogSellBusiness          2503
#define DialogBusinessMenu          2504
#define DialogGoBusiness            2505


// House Defines
#define INFORMATION_HEADER "{F6F6F6}House {00BC00}v3 {F6F6F6}by {00BC00}Developers"
#define LABELTEXT1 "House Name: {F6F6F6}%s\n{00BC00}House Owner: {F6F6F6}No Owner\n{00BC00}House Value: {F6F6F6}$%d\n{00BC00}For Sale: {F6F6F6}No\n{00BC00}House Privacy: {F6F6F6}Opened\n{00BC00}House ID: {F6F6F6}%d"
#define LABELTEXT2 "House Name: {F6F6F6}%s\n{00BC00}House Owner: {F6F6F6}%s\n{00BC00}House Value: {F6F6F6}$%d\n{00BC00}For Sale: {F6F6F6}%s\n{00BC00}House Privacy: {F6F6F6}%s\n{00BC00}House ID: {F6F6F6}%d"
//House Colours
#define COLOUR_INFO			   			0x00CC33FF
#define COLOUR_SYSTEM 		   			0xFF0000FF
#define COLOUR_YELLOW 					0xFFFF2AFF
#define COLOUR_GREEN 					0x00BC00FF
#define COLOUR_DIALOG                   0xF6F6F6AA
#define SRED            0xFF6347AA
#define SEABLUE 	    0x33CCFFAA
#define AYELLOW 		0xFFFF00FF
#define ZBLUE 			0x1275EDFF
#define ZPURPLE 		0xC2A2DAFF
//==============================================================================
#define DC_SAMP         				"{F6F6F6}"
#define DC_DIALOG 						"{F6F6F6}"
#define DC_ERROR 						"{FF0000}"
#define DC_ADMIN 						"{CC00CC}"
#define DC_INFO 						"{00BC00}"
//House Macros
new CMDSString[1000], IsInHouse[MAX_PLAYERS char];
#define YesNo(%0) ((%0) == (1)) ? ("Yes") : ("No")
#define Answer(%0,%1,%2) (%0) == (1) ? (%1) : (%2)
#define IsPlayerInHouse(%0,%1) ((GetPVarInt(%0, "LastHouseCP") == (%1)) && (IsInHouse{%0} == (1))) ? (1) : (0)
#define ShowInfoBox(%0,%1,%2) do{CMDSString = ""; format(CMDSString, 1000, %1, %2); ShowPlayerDialog(%0, HOUSEMENU-1, DIALOG_STYLE_MSGBOX, INFORMATION_HEADER, CMDSString, "Close", "");}while(FALSE)
#define GameTextEx(%0,%1,%2,%3,%4) do{CMDSString = ""; format(CMDSString, 1000, %3, %4); GameTextForPlayer(%0, CMDSString, %1, %2);}while(FALSE)
#define Loop(%0,%1,%2) for(new %0 = %2; %0 < %1; %0++)
#define function%0(%1) forward %0(%1); public %0(%1)
#define TYPE_OUT (0)
#define TYPE_INT (1)
//==============================================================================
//House Configuration
#define TMPODJID
#define MAX_HOUSES 					3000
#define MAX_HOUSE_INTERIORS         15
#define MAX_HOUSES_OWNED    		3
#define HOUSEMENU 					21700 //DialogID
#define FILEPATH 					"/House/Houses/%d.ini"
#define HINT_FILEPATH 				"/House/Interiors/%d.ini"
#define USERPATH 					"/House/Users/%s.ini"
//------------------------------------------------------------------------------
#define GH_USE_MAPICONS 			true
#define GH_USE_CPS 					true
#define GH_HINTERIOR_UPGRADE 		true
#define GH_USE_HOUSESTORAGE 		true
#define GH_HOUSECARS				true
#define SPAWN_IN_HOUSE 				true
#define CASE_SENSETIVE              true  // true = ignore case sensetive in strcmp | false = not.
#define GH_ALLOW_BREAKIN            true
#define GH_GIVE_WANTEDLEVEL         true
#define GH_ALLOW_HOUSEROBBERY       false
#define GH_SAVE_ADMINWEPS 			false
#define GH_USE_WEAPONSTORAGE 		false
#define GH_ALLOW_HOUSETELEPORT      true
//------------------------------------------------------------------------------
#define HOUSEFILE_LENGTH      		30
#define INTERIORFILE_LENGTH   		30
#define MIN_HOUSE_VALUE             50000000
#define MAX_HOUSE_VALUE             900000000
#define MIN_HINT_VALUE      		10000
#define MAX_HINT_VALUE      		50000000
#define HOUSE_ROBBERY_PERCENT       25 // How many percent of the cash in the house storage will be robbed?
#define MAX_MONEY_ROBBED            500000
#define HSPAWN_TIMER_RATE   		1000 // After how long will the timer call the spawn in house function? (in ms)
#define MICON_VD 					50.0 // Map icon visible range (drawdistance).
#define TEXTLABEL_DISTANCE 			25.0 // 3D text visible range (drawdistance)
#define TEXTLABEL_TESTLOS 			1 // 1 makes the 3D text label visible trough walls.
#define CP_DRAWDISTANCE 			25.0 // checkpoint visible range (drawdistance)
#define DEFAULT_H_INTERIOR  		0 // Default house interior when creating a house
#define HCAR_COLOUR1 				-1 // The first colour of the housecar
#define HCAR_COLOUR2 				-1 // The second colour of the housecar
#define HCAR_RESPAWN				60 // The respawn delay of the house car (in seconds)
#define HCAR_RANGE  				10.0 // The range to check for nearby vehicles when saving the house car.
#define PICKUP_MODEL_OUT 			1273 // Pickup model ID which shows up OUTSIDE the house.
#define PICKUP_MODEL_INT 			1272 // Pickup model ID which shows up INSIDE the house.
#define PICKUP_TYPE                 1 // The pickup type if you decide to not use checkpoints
#define MAX_VISIT_TIME              1 // The max time the player can be visiting in (In Minutes).
#define TIME_BETWEEN_VISITS         2 // The time the player have to wait before previewing a new house interior (In minutes).
#define TIME_BETWEEN_BREAKINS       5 // The time the player have to wait before attempting to breakin to a house again (In minutes).
#define TIME_BETWEEN_ROBBERIES      10 // The time the player have to wait before attempting to rob a house again (In minutes).
#define HOUSE_SELLING_PROCENT   	75 // The amount of the house value the player will get when the house is sold.
#define HOUSE_SELLING_PROCENT2 		6.5 // The total percentage the nearby houses will go up/down by when a house is sold/bought nearby.
#define RANGE_BETWEEN_HOUSES        200 // The range used when increasing/decreasing the value of nearby houses when a house is bought/sold (set to 0 to disable)
#define MAX_HOUSE_NAME              35
#define MIN_HOUSE_NAME              4
#define MAX_HINT_NAME              	35
#define MIN_HINT_NAME              	4
#define MAX_HOUSE_PASSWORD          35
#define MIN_HOUSE_PASSWORD          4
#define MAX_ZONE_NAME 				60
#define MIN_ROB_TIME                30
#define MAX_ROB_TIME                60
#define HUPGRADE_ALARM  			10000000
#define HUPGRADE_CAMERA 	 		25000000
#define HUPGRADE_DOG  				50000000
#define HUPGRADE_UPGRADED_HLOCK  	100000000
#define HBREAKIN_WL                 1 // How much should the players wanted level increase by when they fail/succeed at breaking into a house (if the house has a house alarm/security camera).
#define HROBBERY_WL                 3 // How much should the players wanted level increase by when they fail/succeed at robbing a house (if the house has a house alarm/security camera).
#define GH_MAX_WANTED_LEVEL         6
#define SECURITYDOG_HEALTHLOSS 		25.00 // How much health should the player lose after each bit?
#define SECURITYDOG_BITS    		3 // How many times will the dog bite the player during a breakin/robbery?
#define INVALID_HOWNER_NAME         "INVALID_PLAYER_ID"
#define DEFAULT_HOUSE_NAME          "House For Sale!"
//------------------------------------------------------------------------------
#define E_NO_HOUSES_OWNED "{F6F6F6}You do not own any houses."
#define I_HMENU "{F6F6F6}Type /housemenu to access the house menu."
#define E_H_ALREADY_OWNED "{F6F6F6}This house is already owned by someone else."
#define E_INVALID_HPASS_LENGTH "{F6F6F6}Invalid house password length"
#define E_INVALID_HPASS "{F6F6F6}Invalid house password. You may not use this house password."
#define E_INVALID_HPASS_CHARS "{F6F6F6}Your house password contains illegal characters ({00BC00}percentage sign {F6F6F6}or {00BC00}~{F6F6F6})."
#define E_INVALID_HNAME_LENGTH "{F6F6F6}Invalid house name length."
#define E_INVALID_HNAME_CHARS "{F6F6F6}Your house name contains illegal characters ({00BC00}percentage sign {F6F6F6}or {00BC00}~{F6F6F6})."
#define I_HPASS_NO_CHANGE "{F6F6F6}Your house password remains the same."
#define I_HPASS_REMOVED "{F6F6F6}The house password for this house has been removed."
#define E_NOT_ENOUGH_PMONEY "{F6F6F6}You do not have that much money."
#define E_INVALID_AMOUNT "{F6F6F6}Invalid amount."
#define E_HSTORAGE_L_REACHED "{F6F6F6}You can not deposit this much money into your house storage. It can only hold up to {00BC00}$25,000,000{F6F6F6}."
#define E_NOT_ENOUGH_HSMONEY "{F6F6F6}You do not have that much money in your house storage."
#define E_NO_WEAPONS "{F6F6F6}You do not have any weapons to store."
#define E_NO_HS_WEAPONS "{F6F6F6}You do not have any weapons in your house storage."
#define E_INVALID_HPASS_CHARS2 "{F6F6F6}The entered house password contains illegal characters ({00BC00}percentage sign {F6F6F6}or {00BC00}~{F6F6F6})."
#define E_C_ACCESS_SE_HM "{F6F6F6}You can not access someone elses house menu."
#define E_NOT_IN_HOUSE "{F6F6F6}You need to be in a house to use this command."
#define E_NOT_HOWNER "{F6F6F6}You need to be the owner of a house to use this command."
#define E_HCAR_NOT_IN_VEH "{F6F6F6}You need to be in a vehicle to add a house car."
#define E_INVALID_HID "{F6F6F6}Invalid house ID. This house ID does not exist."
#define E_NO_HCAR "{F6F6F6}This house ID does not have a house car. Unable to delete."
#define E_H_A_F_SALE "{F6F6F6}This house is already for sale. You can not sell it."
#define E_ALREADY_HAVE_HINTERIOR "{F6F6F6}You already have this house interior."
#define E_HINT_WAIT_BEFORE_VISITING "{F6F6F6}Please wait before visiting a house interior again."
#define I_WRONG_HPASS1 "{F6F6F6}You have failed to enter {00BC00}%s's {F6F6F6}house using the password {00BC00}%s{F6F6F6}."
#define I_WRONG_HPASS2 "{00BC00}%s (%d) {F6F6F6}has attempted to enter your house using the password {00BC00}%s{F6F6F6}."
#define I_CORRECT_HPASS1 "{F6F6F6}You have successfully entered {00BC00}%s's {F6F6F6}house using the password {00BC00}%s{F6F6F6}."
#define I_CORRECT_HPASS2 "{00BC00}%s (%d) {F6F6F6}has successfully entered your house using the password {00BC00}%s{F6F6F6}!"
#define E_TOO_MANY_HOUSES "{F6F6F6}Sorry, but there are already {00BC00}%d {F6F6F6}houses created.\nDelete one of the current ones or increase the limit in the script."
#define I_H_CREATED "{F6F6F6}House ID {00BC00}%d {F6F6F6}created..."
#define I_HCAR_EXIST_ALREADY "{F6F6F6}House ID %d {F6F6F6}already have a house car. Overwriting current one."
#define I_HCAR_CREATED "{F6F6F6}House car for house ID {00BC00}%d {F6F6F6}created..."
#define I_H_DESTROYED "{F6F6F6}House ID {00BC00}%d {F6F6F6}destroyed..."
#define I_HCAR_REMOVED "{F6F6F6}House car for house ID {00BC00}%d {F6F6F6}removed..."
#define I_ALLH_DESTROYED "{F6F6F6}All houses removed. ({00BC00}%d {F6F6F6}in total)"
#define I_ALLHCAR_REMOVED "{F6F6F6}All house cars removed. ({00BC00}%d {F6F6F6}in total)"
#define I_HSPAWN_CHANGED "{F6F6F6}You have changed the spawnposition and angle for house ID {00BC00}%d{F6F6F6}."
#define I_TELEPORT_MSG "{F6F6F6}You have teleported to house ID {00BC00}%d{F6F6F6}."
#define I_H_SOLD "{F6F6F6}You have sold house ID {00BC00}%d{F6F6F6}..."
#define I_ALLH_SOLD "{F6F6F6}All houses on the server has been sold. ({00BC00}%d {F6F6F6}in total)"
#define I_H_PRICE_CHANGED "{F6F6F6}The value for house ID {00BC00}%d has been changed to {00BC00}$%d{F6F6F6}."
#define I_ALLH_PRICE_CHANGED "{F6F6F6}You have changed the value of all houses on the server to {00BC00}$%d. ({00BC00}%d {F6F6F6}in total)"
#define I_HINT_VISIT_OVER "{F6F6F6}Your visiting time is over.\nDo you want to buy the house interior {00BC00}%s {F6F6F6}for {00BC00}$%d{F6F6F6}?"
#define E_INVALID_HCAR_MODEL "{F6F6F6}Invalid car model. Accepted car models are between {00BC00}400 {F6F6F6}and {00BC00}612."
#define I_HCAR_CHANGED "{F6F6F6}Car model for house ID {00BC00}%d {F6F6F6}changed to {00BC00}%d."
#define HMENU_SELL_HOUSE2 "{F6F6F6}Type in how much you want to sell your house for below:"
#define HMENU_CANCEL_HOUSE_SALE "{F6F6F6}Your house is no longer for sale."
#define HMENU_HSALE_CANCEL "{F6F6F6}Click {00BC00}\"Remove\" {F6F6F6}to cancel the house sale for this house."
#define E_H_NOT_FOR_SALE "{F6F6F6}This house is not for sale."
#define E_INVALID_HSELL_AMOUNT "{F6F6F6}Invalid amount. The price you want to sell your house for can not be higher than {00BC00}$"#MAX_HOUSE_VALUE" {F6F6F6}or lower than {00BC00}$"#MIN_HOUSE_VALUE"{F6F6F6}."
#define I_H_SET_FOR_SALE "{F6F6F6}You have successfully set your house {00BC00}%s {F6F6F6}for sale for {00BC00}$%d{F6F6F6}."
#define HSELL_BUY_DIALOG "{00BC00}Current House Owner: {F6F6F6}%s\n{00BC00}Current House Name: {F6F6F6}%s\n\nAre You Sure You Want To Buy This House For {00BC00}$%d{F6F6F6}?"
#define HSELLER_CONNECTED_MSG1 "{F6F6F6}Your house {00BC00}%s {F6F6F6}has been sold to {00BC00}%s (%d){F6F6F6}.\n"
#define HSELLER_CONNECTED_MSG2 "{00BC00}You receive: {F6F6F6}$%d\n{00BC00}House Storage: {F6F6F6}$%d\n{00BC00}House Price: {F6F6F6}$%d"
#define HSELLER_OFFLINE_MSG1 "{F6F6F6}Your house {00BC00}%s {F6F6F6}has been sold to {00BC00}%s {F6F6F6}while you were offline.\n"
#define HSELLER_OFFLINE_MSG2 "{00BC00}You receive: {F6F6F6}$%d\n{00BC00}House Storage: {F6F6F6}$%d\n{00BC00}House Price: {F6F6F6}$%d"
#define E_NOT_HOUSECAR_OWNER "{F6F6F6}You can not drive this vehicle as it belongs to the owner of house ID {F6F6F6}%d which is {F6F6F6}%s."
#define I_HOUSECAR_OWNER "{F6F6F6}Welcome to your vehicle, {00BC00}%s{F6F6F6}! This vehicle belongs to your house (ID {00BC00}%d{F6F6F6}) so therefore only you can drive it."
#define I_TO_PLAYERS_HSOLD "{F6F6F6}This house has been sold.\nYou have been automaticly kicked out from the house."
#define E_INVALID_HINT "{F6F6F6}Invalid house interior. Accepted house interiors are between {00BC00}0 {F6F6F6}and {00BC00}"#MAX_HOUSE_INTERIORS"{F6F6F6}."
#define E_CMD_USAGE_CHANGEHINTSPAWN "Usage:{F6F6F6} /changehintspawn (house interior)"
#define E_CMD_USAGE_CREATEHINT "Usage:{F6F6F6} /createhint (value) (name)"
#define E_CMD_USAGE_REMOVEHINT "Usage:{F6F6F6} /removehint (house interior)"
#define E_CMD_USAGE_CREATEHOUSE "Usage:{F6F6F6} /createhouse (house value) (optional: house interior)"
#define E_CMD_USAGE_ADDHCAR "Usage:{F6F6F6} /addhcar (house id)"
#define E_CMD_USAGE_REMOVEHOUSE "Usage:{F6F6F6} /removehouse (houseid)"
#define E_CMD_USAGE_REMOVEHCAR "Usage:{F6F6F6} /removehcar (house id)"
#define E_CMD_USAGE_CHANGEHCAR "Usage:{F6F6F6} /changehcar (house id) (modelid: 400-612)"
#define E_CMD_USAGE_CHANGESPAWN "Usage:{F6F6F6} /changespawn (houseid)"
#define E_CMD_USAGE_GOTOHOUSE "Usage:{F6F6F6} /gotohouse (houseid)"
#define E_CMD_USAGE_SELLHOUSE "Usage:{F6F6F6} /sellhouse (houseid)"
#define E_CMD_USAGE_CHANGEPRICE "Usage:{F6F6F6} /changeprice (houseid) (price)"
#define E_CMD_USAGE_CHANGEALLPRICE "Usage:{F6F6F6} /changeallprices (price)"
#define E_INVALID_HINT_ID "{F6F6F6}Invalid house interior ID."
#define I_HINT_SPAWN_CHANGED "{F6F6F6}You have changed the spawn position and angel for house interior ID %d."
#define I_HINT_CREATED "{F6F6F6}House interior ID {00BC00}%d {F6F6F6}created...\n{00BC00}House Interior Value: {F6F6F6}$%d\n{00BC00}House Interior Name: {F6F6F6}%s"
#define E_TOO_MANY_HINTS "{F6F6F6}Sorry, but there are already {00BC00}%d {F6F6F6}house interiors created.\nDelete one of the current ones or increase the limit in the script."
#define E_INVALID_HINT_VALUE "{F6F6F6}Invalid house interior value. The value must be between {00BC00}$"#MIN_HINT_VALUE" {F6F6F6}and {00BC00}$"#MAX_HINT_VALUE"{F6F6F6}."
#define E_INVALID_HINT_LENGTH "{F6F6F6}Invalid house interior name length. The length must be between {00BC00}"#MIN_HINT_NAME" {F6F6F6}and {00BC00}"#MAX_HINT_NAME"{F6F6F6}."
#define I_HINT_DESTROYED "{F6F6F6}House interior ID {00BC00}%d {F6F6F6}has been deleted..."
#define E_NO_HOUSESTORAGE "{F6F6F6}The house storage feature has been disabled in this server. You can not use it."
#define I_HOWNER_HINFO_1 "{00BC00}House Name: {F6F6F6}%s\n{00BC00}House Location: {F6F6F6}%s\n{00BC00}Distance to house from you: {F6F6F6}%0.2f feet\n"
#define I_HOWNER_HINFO_2 "{00BC00}House Value: {F6F6F6}$%d\n{00BC00}House Storage: {F6F6F6}$%d\n{00BC00}House Privacy: {F6F6F6}%s\n{00BC00}House ID: {F6F6F6}%d"
#define HMENU_ENTER_PASS "{00BC00}House Name: {F6F6F6}%s\n{00BC00}House Owner: {F6F6F6}%s\n{00BC00}House Value: {F6F6F6}$%d\n{00BC00}House ID: {F6F6F6}%d\n\nEnter The Password For The House Below If You Wish To Enter:"
#define I_HINT_DEPOSIT1 "{F6F6F6}You have {00BC00}$%d {F6F6F6}in your house storage.\n\nType in the amount you want to deposit below:"
#define I_HINT_WITHDRAW1 "{F6F6F6}You have {00BC00}$%d {F6F6F6}in your house storage.\n\nType in the amount you want to withdraw below:"
#define I_HINT_DEPOSIT2 "{F6F6F6}You have successfully deposited {00BC00}$%d {F6F6F6}Into your house storage.\n{00BC00}Current Balance: {F6F6F6}$%d"
#define I_HINT_WITHDRAW2 "{F6F6F6}You have successfully withdrawn {00BC00}$%d {F6F6F6}From your house storage.\n{00BC00}Current Balance: {F6F6F6}$%d"
#define I_HINT_CHECKBALANCE "{F6F6F6}You have {00BC00}$%d {F6F6F6}in your house storage."
#define E_HINT_DOESNT_EXIST "{F6F6F6}Invalid house interior. This house interior does not exist."
#define HMENU_BUY_HOUSE "{F6F6F6}Do you want to buy this house for {00BC00}$%d{F6F6F6}?"
#define HMENU_BUY_HINTERIOR "{F6F6F6}Do you want to buy the house interior {00BC00}%s {F6F6F6}for {00BC00}$%d{F6F6F6}?"
#define HMENU_SELL_HOUSE "{F6F6F6}Are you sure you want to sell your house {00BC00}%s {F6F6F6}for {00BC00}$%d{F6F6F6}?"
#define I_SELL_HOUSE1_1 "{F6F6F6}You have successfully sold your house for {00BC00}$%d\n"
#define I_SELL_HOUSE1_2 "{00BC00}Selling Fee: {F6F6F6}$%d\nThe {00BC00}$%d {F6F6F6}in your house storage has been transfered to your pocket."
#define I_SELL_HOUSE2 "{F6F6F6}You have successfully sold your house {00BC00}%s {F6F6F6}for {00BC00}$%d.\n{00BC00}Selling Fee: {F6F6F6}$%d"
#define I_BUY_HOUSE "{F6F6F6}You have successfully bought this house for {00BC00}$%d{F6F6F6}!"
#define I_HPASSWORD_CHANGED "{F6F6F6}You have successfully set the house password to {00BC00}%s{F6F6F6}!"
#define I_HNAME_CHANGED "{F6F6F6}You have successfully set the house name to {00BC00}%s{F6F6F6}!"
#define I_VISITING_HOUSEINT "{F6F6F6}You're now visiting the house interior {00BC00}%s{F6F6F6}.\nThis house interior costs {00BC00}$%d{F6F6F6}.\nYour visit time will end in {00BC00}%d {F6F6F6}minute%s."
#define E_CANT_AFFORD_HINT1 "{F6F6F6}You can not afford to buy the house interior {00BC00}%s{F6F6F6}.\n{00BC00}House Interior Price: {F6F6F6}$%d\n"
#define E_CANT_AFFORD_HINT2 "{00BC00}You have: {F6F6F6}$%d\n{00BC00}You Need: {F6F6F6}$%d"
#define I_HINT_BOUGHT "{F6F6F6}You have bought the house interior {00BC00}%s {F6F6F6}for {00BC00}$%d."
#define I_HS_WEAPONS1 "{F6F6F6}You have successfully stored {00BC00}%d {F6F6F6}weapon%s in your house storage."
#define I_HS_WEAPONS2 "{F6F6F6}You have successfully received {00BC00}%d {F6F6F6}weapon%s from your house storage."
#define E_INVALID_HVALUE "{F6F6F6}Invalid house value. The house value must be between {00BC00}$"#MIN_HOUSE_VALUE" {F6F6F6}and {00BC00}$"#MAX_HOUSE_VALUE"{F6F6F6}."
#define I_HOPEN_FOR_VISITORS "{F6F6F6}You have successfully opened your house for visitors."
#define I_CLOSED_FOR_VISITORS1 "{F6F6F6}You have successfully closed your house for visitors.\n{00BC00}Total visitors kicked out: {F6F6F6}%d"
#define I_CLOSED_FOR_VISITORS2 "{00BC00}%s (%d) {F6F6F6}has closed their house for visitors. Automaticly exiting house..."
#define E_MAX_HOUSES_OWNED "{F6F6F6}You already own {00BC00}%d {F6F6F6}house%s. Sell one of your others before buying a new."
#define E_CANT_AFFORD_HOUSE "{F6F6F6}You can not afford to buy this house.\n{00BC00}House Value: {F6F6F6}$%d\n{00BC00}You Have: {F6F6F6}$%d\n{00BC00}You Need: {F6F6F6}$%d"
#define I_SUCCESSFULL_BREAKIN1_1 "{00BC00}%s (%d) {F6F6F6}has successfully broken into your house {00BC00}%s {F6F6F6}in {00BC00}%s{F6F6F6}."
#define I_SUCCESSFULL_BREAKIN1_2 "{F6F6F6}Someone has successfully broken into your house {00BC00}%s {F6F6F6}in {00BC00}%s{F6F6F6}."
#define I_SUCCESSFULL_BREAKIN2 "{F6F6F6}You have successfully broken into this house.\n{00BC00}House Name: {F6F6F6}%s\n{00BC00}House Owner: {F6F6F6}%s"
#define E_FAILED_BREAKIN1_1 "{00BC00}%s (%d) {F6F6F6}has failed to breakin to your house {00BC00}%s {F6F6F6}in {00BC00}%s{F6F6F6}."
#define E_FAILED_BREAKIN1_2 "{F6F6F6}Someone has failed to breakin to your house {00BC00}%s {F6F6F6}in {00BC00}%s{F6F6F6}."
#define E_FAILED_BREAKIN2 "{F6F6F6}You have failed to breakin to this house.\n{00BC00}House Name: {F6F6F6}%s\n{00BC00}House Owner: {F6F6F6}%s"
#define E_NO_HOUSE_BREAKIN "{F6F6F6}The breakin feature has been disabled in this server. You can not use it."
#define E_KICKED_NOT_IN_HOUSE "{F6F6F6}This player is not in your house."
#define I_KICKED_FROM_HOUSE1 "{F6F6F6}You have kicked out {00BC00}%s (%d) {F6F6F6}from your house."
#define I_KICKED_FROM_HOUSE2 "{F6F6F6}You have been kicked out from the house by {00BC00}%s (%d){F6F6F6}."
#define E_ALREADY_HAVE_HOUSEKEYS "{F6F6F6}You have already given the house keys for this house to this player."
#define I_HOUSEKEYS_RECIEVED_1 "{F6F6F6}You have given {00BC00}%s (%d) {F6F6F6}house keys to this house."
#define I_HOUSEKEYS_RECIEVED_2 "{F6F6F6}You have been given house keys to {00BC00}%s {F6F6F6}in {00BC00}%s {F6F6F6}by {00BC00}%s (%d){F6F6F6}."
#define E_DOESNT_HAVE_HOUSEKEYS "{F6F6F6}This player does not have the house keys for this house."
#define I_HOUSEKEYS_TAKEN_1 "{F6F6F6}You have taken away {00BC00}%s's (%d) {F6F6F6}house keys to this house."
#define I_HOUSEKEYS_TAKEN_2 "{00BC00}%s (%d) {F6F6F6}has taken away the house keys to his house {00BC00}%s {F6F6F6}in {00BC00}%s{F6F6F6}."
#define E_NONE_IN_HOUSE "{F6F6F6}There isn't anyone in your house."
#define E_CANT_ROB_OWN_HOUSE "{F6F6F6}You can not rob your own house."
#define E_ALREADY_HAVE_ALARM "{F6F6F6}You have already bought a house alarm for this house."
#define E_ALREADY_HAVE_CAMERA "{F6F6F6}You have already bought a security camera for this house."
#define E_ALREADY_HAVE_DOG "{F6F6F6}You have already bought a security dog for this house."
#define E_ALREADY_HAVE_UPGRADED_HLOCK "{F6F6F6}You have already bought a better doorlock for this house."
#define E_NOT_ENOUGH_MONEY_ALARM "{F6F6F6}You do not have enough money to buy a house alarm for your house."
#define E_NOT_ENOUGH_MONEY_CAMERA "{F6F6F6}You do not have enough money to buy a security camera for your house."
#define E_NOT_ENOUGH_MONEY_DOG "{F6F6F6}You do not have enough money to buy a security dog for your house."
#define E_NOT_ENOUGH_MONEY_UPGRADED_HLOCK "{F6F6F6}You do not have enough money to buy a better doorlock for your house."
#define I_HUPGRADE_ALARM "{F6F6F6}You have bought a alarm for your house.\nThis alarm will warn you when someone tries to or succeed in either robbing or breaking into your house.\n{00BC00}Note: {F6F6F6}It does not notify you of who it is."
#define I_HUPGRADE_CAMERA "{F6F6F6}You have bought a security camera for your house.\nThis security camera will warn you when someone tries to or succeed in either robbing or breaking into your house.\n{00BC00}Note: {F6F6F6}It does notify you of who it is."
#define I_HUPGRADE_DOG "{F6F6F6}You have bought a security dog for your house.\nThis security dog will try to kill anyone who tries to either rob or breakin to your house."
#define I_HUPGRADE_UPGRADED_HLOCK "{F6F6F6}You have bought upgraded the doorlock for your house.\nIt will now be harder to breakin to your house."
#define E_FAILED_HROB1_1 "{00BC00}%s (%d) {F6F6F6}has failed to rob your house {00BC00}%s {F6F6F6}in {00BC00}%s{F6F6F6}."
#define E_FAILED_HROB1_2 "{F6F6F6}Someone has failed to rob your house {00BC00}%s {F6F6F6}in {00BC00}%s{F6F6F6}."
#define I_HROB_STARTED1_1 "{F6F6F6}Someone is currently robbing your house %s {F6F6F6}in %s{F6F6F6}."
#define I_HROB_STARTED1_2 "{00BC00}%s (%d) {F6F6F6}is currently robbing your house %s {F6F6F6}in %s{F6F6F6}."
#define I_HROB_STARTED2 "{F6F6F6}You have started the robbery of {00BC00}%s's {F6F6F6}house {00BC00}%s {F6F6F6}in {00BC00}%s{F6F6F6}.\n\n{00BC00}Stay alive and do not leave the house until the robbery finishes!"
#define E_HROB_OWNER_NOT_CONNECTED "{F6F6F6}You can not rob this house since the owner of it is not connected."
#define I_HROB_FAILED_DEATH "{F6F6F6}You have died.\nThe attempt to rob the house {00BC00}%s {F6F6F6}has failed."
#define I_HROB_FAILED_HEXIT "{F6F6F6}You have left the house.\nThe attempt to rob the house {00BC00}%s {F6F6F6}has failed."
#define I_HROB_FAILED_NOT_IN_HOUSE "{F6F6F6}You are not in the house you were attempting to rob.\nThe attempt to rob the house {00BC00}%s {F6F6F6}has failed."
#define E_FAILED_HROB2 "{F6F6F6}House robbery failed."
#define I_HROB_COMPLETED1_1 "{F6F6F6}Your house {00BC00}%s {F6F6F6}in {00BC00}%s {F6F6F6}has been robbed for {00BC00}$%d{F6F6F6}."
#define I_HROB_COMPLETED1_2 "{00BC00}%s (%d) {F6F6F6}has robbed your house {00BC00}%s {F6F6F6}in {00BC00}%s {F6F6F6}for {00BC00}$%d{F6F6F6}."
#define I_HROB_COMPLETED2 "{F6F6F6}House robbery completed.\nYou got away with {00BC00}$%d {F6F6F6}from {00BC00}%s's {F6F6F6}house {00BC00}%s {F6F6F6}in {00BC00}%s{F6F6F6}."
#define HROB_FAILED1 "{F6F6F6}You have been bit to death by the security dog for this house.\nRobbery failed."
#define HBREAKIN_FAILED1 "{F6F6F6}You have been bit to death by the security dog for this house.\nHouse breakin failed."
#define E_WAIT_BEFORE_BREAKIN "{F6F6F6}Please wait before attempting to breakin to a house again."
#define E_WAIT_BEFORE_ROBBING "{F6F6F6}Please wait before attempting to rob a house again."
#define E_ALREADY_ROBBING_HOUSE "{F6F6F6}You are already robbing a house."
#define HROB_FAILED2 "{F6F6F6}House robbery failed.\nYou have been bit by the security dog for this house."
#define HBREAKIN_FAILED2 "{F6F6F6}House breakin failed.\nYou have been bit by the security dog for this house."
//-----------------
// Colors
//-----------------
#define TELEPORTBLUE "{5CBBED}"
#define PREMIUM "{0FF2F2}"
#define PINK "{F7B0D0}"
#define GREEN "{11ED65}"
#define STEELBLUE "{B0C4DE}"
#define GREY "{C0C4C4}"
#define WHITE "{FFFFFF}"
#define RED "{FF0000}"
#define ORANGE "{F07F1D}"
#define REDORANGE "{F75A05}"
#define PURPLE "{ED2BD0}"
#define LIGHTBLUE "{9FF0FC}"
#define COLOR_FIREBRICK 	0xB22222FF
#define USAGE 0x6FFF00FF
#define YELLOW "{F5D922}"
#define BLUE "{0000E1}"
#define YELLOW2 "{FFFF00}"

#define COLOR_YELLOW2           0xFFFF00FF
#define COLOR_PURPLE            0xD526D9FF
#define COLOR_LIGHTGREEN        0x00FF00FF
#define COLOR_PINK				0xFFB6C1FF
#define COLOR_LIGHTBLUE         0x33CCFFAA
#define COLOR_GREY              0xAFAFAFAA
#define COLOR_WHITE             0xFFFFFFFF
#define COLOR_ORANGE            0xFF8000FF
#define COLOR_YELLOW            0xFFFF00FF
#define COLOR_BLUE              0x0000E1FF
#define COLOR_RED               0xFF0000FF
#define COLOR_LIME              0x00FF00FF
#define COLOR_GREEN 			0x33AA33AA
#define COLOR_VIOLET 			0xEE82EEFF
#define LIGHTGREEN 	    0x00FFFFFF

#define COLOR_ORANGE2 						0xFF8000FF
#define COLOR_DBLUE2 						0x2641FEAA
#define COLOR_LIGHTRED 						0xFF634700
#define COLOR_DARKRED 						0x9A000000
#define COLOR_DARKBLUE 						0x00009A00
#define COLOR_DARKGREEN 					0x40008000
#define COLOR_BROWN 						0x99330000
#define COLOR_MAGENTA 						0xFF00FF00
#define COLOR_DBLUE 						0x8D8DFF00
#define COLOR_LAWENFORCE 					0x8D8DFF00
#define COLOR_LAWENFORCERADAR 				0x8D8DFFAA
#define COLOR_DARKPURPLE 					0xD900D300
#define COLOR_BLACK 						0x02020200
#define COLOR_CYAN 							0x99FFFF00
#define COLOR_TAN 							0xFFFFCC00
#define COLOR_KHAKI 						0x99990000
#define COLOR_TURQ 							0x00A3C000
#define COLOR_SYSTEM 						0xEFEFF700
#define COLOR_GRAD1 						0xB4B5B700
#define COLOR_GRAD2 						0xBFC0C200
#define COLOR_GRAD3 						0xCBCCCE00
#define COLOR_GRAD4 						0xD8D8D800
#define COLOR_GRAD5 						0xE3E3E300
#define COLOR_GRAD6 						0xF0F0F0FF
#define COLOR_FADE1 						0xE6E6E600
#define COLOR_FADE2 						0xC8C8C800
#define COLOR_FADE3 						0xAAAAAA00
#define COLOR_FADE4 						0x8C8C8C00
#define COLOR_FADE5 						0x6E6E6E00
#define GELB 								0xFF828200

#define DIALOG_GANGHELP      6969
#define DIALOG_GANG          6970
#define DIALOG_EDITING       6971
#define DIALOG_RANK          6972
#define DIALOG_SKIN          6973
#define DIALOG_COORDINATES   6974
#define DIALOG_RANK2         6975
#define DIALOG_SKIN2         6976
#define DIALOG_NAME          6977
#define DIALOG_LICENSE       6978
#define DIALOG_LAPTOP        6979
#define DIALOG_LOCATIONISP   6980
#define DIALOG_WEAPON        6981
#define DIALOG_TARGETS       6982
#define DIALOG_TICKET      	 6983
#define DIALOG_PDWEAPONS     6984
#define DIALOG_FIRE          6985
#define DIALOG_VATRA         6986
//#define ROT 								0xFF0000FF
// *****************************************************************************
enum TBusinessData
{
	PickupID,
	Text3D:DoorText,
	MapIconID,
	BusinessName[100],
	Float:BusinessX,
	Float:BusinessY,
	Float:BusinessZ,
	BusinessType,
	BusinessLevel,
	LastTransaction,
	bool:Owned,
	Owner[24]
}

new ABusinessData[MAX_BUSINESS][TBusinessData];
new BusinessTransactionTime;

enum TBusinessType
{
	InteriorName[50],
	InteriorID,
	Float:IntX,
	Float:IntY,
	Float:IntZ,
	BusPrice,
	BusEarnings,
	IconID
}

new ABusinessInteriors[][TBusinessType] =
{
	{"Dummy", 				0, 		0.0, 		0.0, 		0.0,		0,			0,		0}, //Never Used
	{"24/7 (Small)", 		6, 		-26.75, 	-55.75, 	1003.6,		500000,		5,		52}, //Earnings: $7200
	{"24/7 (Medium)", 		18, 	-31.0, 		-89.5, 		1003.6,		700000,		7,		52}, //Earnings: $10080
	{"Bar", 				11, 	502.25, 	-69.75, 	998.8,		400000,		4,		49}, //Earnings: $5760
	{"Barber (Small)", 		2, 		411.5, 		-21.25, 	1001.8,		300000,		3,		7}, //Eearnings: $4320
	{"Barber (Medium)",		3, 		418.75, 	-82.5, 		1001.8,		400000,		4,		7}, //Earnings: $5760
	{"Betting shop", 		3, 		833.25, 	7.0, 		1004.2,		1500000,	15,		52}, //Earnings: $21600
	{"Burger Shot", 		10, 	363.5, 		-74.5, 		1001.5,		700000,		7,		10}, //Earnings: $10080
	{"Casino (4 Dragons)", 	10, 	2017.25, 	1017.75, 	996.9,		2500000,	25,		44}, //Earnings: $36000
	{"Casino (Caligula's)", 1, 		2234.0, 	1710.75, 	1011.3,		2500000,	25,		25}, //Earnings: $36000
	{"Casino (Small)", 		12, 	1133.0, 	-9.5,	 	1000.7,		2000000,	20,		43}, //Earnings: $28800
	{"Clothing (Binco)", 	15, 	207.75, 	-109.0, 	1005.2,		800000,		8,		45}, //Earnings: $11520
	{"Clothing (Pro)", 		3, 		207.0, 		-138.75, 	1003.5,		800000,		8,		45}, //Earnings: $11520
	{"Clothing (Urban)", 	1, 		203.75, 	-48.5, 		1001.8,		800000,		8,		45}, //Earnings: $11520
	{"Clothing (Victim)", 	5, 		226.25, 	-7.5, 		1002.3,		800000,		8,		45}, //Earnings: $11520
	{"Clothing (ZIP)",		18, 	161.5, 		-92.25, 	1001.8,		800000,		8,		45}, //Earnings: $11520
	{"Cluckin' Bell",		9,		365.75, 	-10.75,  	1001.9,		700000,		7,		14}, //Earnings: $10080
	{"Disco (Small)", 		17, 	492.75,		-22.0, 		1000.7,		1000000,	10,		48}, //Earnings: $14400
	{"Disco (Large)", 		3, 		-2642.0, 	1406.5, 	906.5,		1200000,	12,		48}, //Earnings: $17280
	{"Gym (LS)", 			5, 		772.0, 		-3.0, 		1000.8,		500000,		5,		54}, //Earnings: $7200
	{"Gym (SF)", 			6, 		774.25, 	-49.0, 		1000.6,		500000,		5,		54}, //Earnings: $7200
	{"Gym (LV)", 			7, 		774.25, 	-74.0, 		1000.7,		500000,		5,		54}, //Earnings: $7200
	{"Motel", 				15, 	2216.25, 	-1150.5, 	1025.8,		1000000,	10,		37}, //Earnings: $14400
	{"RC shop", 			6, 		-2238.75, 	131.0, 		1035.5,		600000,		6,		46}, //Earnings: $8640
	{"Sex-shop", 			3, 		-100.25, 	-22.75, 	1000.8,		800000,		8,		38}, //Earnings: $11520
	{"Slaughterhouse", 		1, 		933.75, 	2151.0, 	1011.1,		500000,		5,		50}, //Earnings: $7200
	{"Stadium (Bloodbowl)", 15, 	-1394.25, 	987.5, 		1024.0,		1700000,	17,		33}, //Earnings: $24480
	{"Stadium (Kickstart)", 14, 	-1410.75, 	1591.25, 	1052.6,		1700000,	17,		33}, //Earnings: $24480
	{"Stadium (8-Track)", 	7, 		-1396.0, 	-208.25, 	1051.2,		1700000,	17,		33}, //Earnings: $24480
	{"Stadium (Dirt Bike)", 4, 		-1425.0, 	-664.5, 	1059.9,		1700000,	17,		33}, //Earnings: $24480
	{"Stripclub (Small)", 	3, 		1212.75, 	-30.0, 		1001.0,		700000,		7,		48}, //Earnings: $10080
	{"Stripclub (Large)", 	2, 		1204.75, 	-12.5, 		1001.0,		900000,		9,		48}, //Earnings: $12960
	{"Tattoo LS", 			16, 	-203.0, 	-24.25, 	1002.3,		500000,		5,		39}, //Earnings: $7200
	{"Well Stacked Pizza", 	5,	 	372.25, 	-131.50, 	1001.5,		600000,		6,		29} //Earnings: $8640
};

enum TPlayerData
{
	Business[20],
    CurrentBusiness
}
new APlayerData[MAX_PLAYERS][TPlayerData];

new TotalBusiness;

enum tk
{
	StunTK,AskTick,Fight
};
new TickCount[MAX_PLAYERS][tk];
new
	Iterator:PlayerInCNR<MAX_PLAYERS>,
	Iterator:PlayerInCOPS<MAX_PLAYERS>,
	Iterator:PlayerInROBBERS<MAX_PLAYERS>
;
new Float:gRandomPlayerSpawnscnrrobber[2][3] =
{

	{2787.2317,1270.4355,10.7500},
	{1297.7286,2678.6980,10.8203}
};
new Float:gRandomPlayerSpawnscnrcop[3][3] =
{

	{2309.6406,2470.1592,3.2734},
	{2290.3398,2424.8931,10.8203},
	{2239.0569,2449.2832,11.0372}
};

//Kill Streak
new killStreak[MAX_PLAYERS];
new Text3D:MWLabel[MAX_PLAYERS];
#define DIALOG_KILLSTREAK 600

//Anti-Death Spam
new Deaths[MAX_PLAYERS];
new AntiDeathSpamTime;
new Death_Limit = 3;
new Clock = 30;
//Vehicle Forwards
forward VehicleSpawner(playerid,model);
forward CarReseter(vehicleid);
forward VehicleSpawnerLimiter(playerid);

new Turn[MAX_PLAYERS];
new VehicleSpawn[MAX_PLAYERS];

forward SpawnCNR(playerid);
new pWeapons[MAX_PLAYERS][13],pAmmo[MAX_PLAYERS][13];
new SavedSKIN[MAX_PLAYERS];
new
	Text:KillerTD1,						Text:KillerTD2,
	Text:KillerTD3,						Text:KillerTD4,
	Text:KillerTD5,						Text:KillerTD6,
	Text:KillerTD7,      				CarsCnr[ 187 ],
	CnRgate[ 5 ],                       CnRCp[ 7 ],
    CNR_ZONE[ 5 ],
	Text:KillerTD9,                     RobberP2,
    RobberP,                       		RobberOP,
    Text:RobTD,
    PlayerBombs[MAX_PLAYERS],
    Jailbreak[MAX_PLAYERS],
    IsSpecating[MAX_PLAYERS],
    gTime[ MAX_PLAYERS ][ 2 ],
    Text:KillerTD0,
    Text:KillerTD8,
    bool:Cuffed[ MAX_PLAYERS ],
    KillerTimer[MAX_PLAYERS],
    jailtimer2,                         jailtimer,
    spawntiming,                        robberytime,
    cnrjail,                            cnrjailtiming,
    spawntime,
    robberytiming,
    Robstart[ MAX_PLAYERS ],
    RobOn[ MAX_PLAYERS ],
	PoliceP,                       		PoliceOP;
#define DIALOG_CnR 300
#define DIALOG_EMPTY 301
#define JOBINFO 0xC8F1FAFF
#define GRAY 0xBEBEBEFF
//=======================Zone System===================================================
forward Zones_Update();

enum SAZONE_MAIN { //Betamaster
		SAZONE_NAME[28],
		Float:SAZONE_AREA[6]
};

static const gSAZones[][SAZONE_MAIN] = {
	//	NAME                            AREA (Xmin,Ymin,Zmin,Xmax,Ymax,Zmax)
	{"The Big Ear",	                {-410.00,1403.30,-3.00,-137.90,1681.20,200.00}},
	{"Aldea Malvada",               {-1372.10,2498.50,0.00,-1277.50,2615.30,200.00}},
	{"Angel Pine",                  {-2324.90,-2584.20,-6.10,-1964.20,-2212.10,200.00}},
	{"Arco del Oeste",              {-901.10,2221.80,0.00,-592.00,2571.90,200.00}},
	{"Avispa Country Club",         {-2646.40,-355.40,0.00,-2270.00,-222.50,200.00}},
	{"Avispa Country Club",         {-2831.80,-430.20,-6.10,-2646.40,-222.50,200.00}},
	{"Avispa Country Club",         {-2361.50,-417.10,0.00,-2270.00,-355.40,200.00}},
	{"Avispa Country Club",         {-2667.80,-302.10,-28.80,-2646.40,-262.30,71.10}},
	{"Avispa Country Club",         {-2470.00,-355.40,0.00,-2270.00,-318.40,46.10}},
	{"Avispa Country Club",         {-2550.00,-355.40,0.00,-2470.00,-318.40,39.70}},
	{"Back o Beyond",               {-1166.90,-2641.10,0.00,-321.70,-1856.00,200.00}},
	{"Battery Point",               {-2741.00,1268.40,-4.50,-2533.00,1490.40,200.00}},
	{"Bayside",                     {-2741.00,2175.10,0.00,-2353.10,2722.70,200.00}},
	{"Bayside Marina",              {-2353.10,2275.70,0.00,-2153.10,2475.70,200.00}},
	{"Beacon Hill",                 {-399.60,-1075.50,-1.40,-319.00,-977.50,198.50}},
	{"Blackfield",                  {964.30,1203.20,-89.00,1197.30,1403.20,110.90}},
	{"Blackfield",                  {964.30,1403.20,-89.00,1197.30,1726.20,110.90}},
	{"Blackfield Chapel",           {1375.60,596.30,-89.00,1558.00,823.20,110.90}},
	{"Blackfield Chapel",           {1325.60,596.30,-89.00,1375.60,795.00,110.90}},
	{"Blackfield Intersection",     {1197.30,1044.60,-89.00,1277.00,1163.30,110.90}},
	{"Blackfield Intersection",     {1166.50,795.00,-89.00,1375.60,1044.60,110.90}},
	{"Blackfield Intersection",     {1277.00,1044.60,-89.00,1315.30,1087.60,110.90}},
	{"Blackfield Intersection",     {1375.60,823.20,-89.00,1457.30,919.40,110.90}},
	{"Blueberry",                   {104.50,-220.10,2.30,349.60,152.20,200.00}},
	{"Blueberry",                   {19.60,-404.10,3.80,349.60,-220.10,200.00}},
	{"Blueberry Acres",             {-319.60,-220.10,0.00,104.50,293.30,200.00}},
	{"Caligula's Palace",           {2087.30,1543.20,-89.00,2437.30,1703.20,110.90}},
	{"Caligula's Palace",           {2137.40,1703.20,-89.00,2437.30,1783.20,110.90}},
	{"Calton Heights",              {-2274.10,744.10,-6.10,-1982.30,1358.90,200.00}},
	{"Chinatown",                   {-2274.10,578.30,-7.60,-2078.60,744.10,200.00}},
	{"City Hall",                   {-2867.80,277.40,-9.10,-2593.40,458.40,200.00}},
	{"Come-A-Lot",                  {2087.30,943.20,-89.00,2623.10,1203.20,110.90}},
	{"Commerce",                    {1323.90,-1842.20,-89.00,1701.90,-1722.20,110.90}},
	{"Commerce",                    {1323.90,-1722.20,-89.00,1440.90,-1577.50,110.90}},
	{"Commerce",                    {1370.80,-1577.50,-89.00,1463.90,-1384.90,110.90}},
	{"Commerce",                    {1463.90,-1577.50,-89.00,1667.90,-1430.80,110.90}},
	{"Commerce",                    {1583.50,-1722.20,-89.00,1758.90,-1577.50,110.90}},
	{"Commerce",                    {1667.90,-1577.50,-89.00,1812.60,-1430.80,110.90}},
	{"Conference Center",           {1046.10,-1804.20,-89.00,1323.90,-1722.20,110.90}},
	{"Conference Center",           {1073.20,-1842.20,-89.00,1323.90,-1804.20,110.90}},
	{"Cranberry Station",           {-2007.80,56.30,0.00,-1922.00,224.70,100.00}},
	{"Creek",                       {2749.90,1937.20,-89.00,2921.60,2669.70,110.90}},
	{"Dillimore",                   {580.70,-674.80,-9.50,861.00,-404.70,200.00}},
	{"Doherty",                     {-2270.00,-324.10,-0.00,-1794.90,-222.50,200.00}},
	{"Doherty",                     {-2173.00,-222.50,-0.00,-1794.90,265.20,200.00}},
	{"Downtown",                    {-1982.30,744.10,-6.10,-1871.70,1274.20,200.00}},
	{"Downtown",                    {-1871.70,1176.40,-4.50,-1620.30,1274.20,200.00}},
	{"Downtown",                    {-1700.00,744.20,-6.10,-1580.00,1176.50,200.00}},
	{"Downtown",                    {-1580.00,744.20,-6.10,-1499.80,1025.90,200.00}},
	{"Downtown",                    {-2078.60,578.30,-7.60,-1499.80,744.20,200.00}},
	{"Downtown",                    {-1993.20,265.20,-9.10,-1794.90,578.30,200.00}},
	{"Downtown Los Santos",         {1463.90,-1430.80,-89.00,1724.70,-1290.80,110.90}},
	{"Downtown Los Santos",         {1724.70,-1430.80,-89.00,1812.60,-1250.90,110.90}},
	{"Downtown Los Santos",         {1463.90,-1290.80,-89.00,1724.70,-1150.80,110.90}},
	{"Downtown Los Santos",         {1370.80,-1384.90,-89.00,1463.90,-1170.80,110.90}},
	{"Downtown Los Santos",         {1724.70,-1250.90,-89.00,1812.60,-1150.80,110.90}},
	{"Downtown Los Santos",         {1370.80,-1170.80,-89.00,1463.90,-1130.80,110.90}},
	{"Downtown Los Santos",         {1378.30,-1130.80,-89.00,1463.90,-1026.30,110.90}},
	{"Downtown Los Santos",         {1391.00,-1026.30,-89.00,1463.90,-926.90,110.90}},
	{"Downtown Los Santos",         {1507.50,-1385.20,110.90,1582.50,-1325.30,335.90}},
	{"East Beach",                  {2632.80,-1852.80,-89.00,2959.30,-1668.10,110.90}},
	{"East Beach",                  {2632.80,-1668.10,-89.00,2747.70,-1393.40,110.90}},
	{"East Beach",                  {2747.70,-1668.10,-89.00,2959.30,-1498.60,110.90}},
	{"East Beach",                  {2747.70,-1498.60,-89.00,2959.30,-1120.00,110.90}},
	{"East Los Santos",             {2421.00,-1628.50,-89.00,2632.80,-1454.30,110.90}},
	{"East Los Santos",             {2222.50,-1628.50,-89.00,2421.00,-1494.00,110.90}},
	{"East Los Santos",             {2266.20,-1494.00,-89.00,2381.60,-1372.00,110.90}},
	{"East Los Santos",             {2381.60,-1494.00,-89.00,2421.00,-1454.30,110.90}},
	{"East Los Santos",             {2281.40,-1372.00,-89.00,2381.60,-1135.00,110.90}},
	{"East Los Santos",             {2381.60,-1454.30,-89.00,2462.10,-1135.00,110.90}},
	{"East Los Santos",             {2462.10,-1454.30,-89.00,2581.70,-1135.00,110.90}},
	{"Easter Basin",                {-1794.90,249.90,-9.10,-1242.90,578.30,200.00}},
	{"Easter Basin",                {-1794.90,-50.00,-0.00,-1499.80,249.90,200.00}},
	{"Easter Bay Airport",          {-1499.80,-50.00,-0.00,-1242.90,249.90,200.00}},
	{"Easter Bay Airport",          {-1794.90,-730.10,-3.00,-1213.90,-50.00,200.00}},
	{"Easter Bay Airport",          {-1213.90,-730.10,0.00,-1132.80,-50.00,200.00}},
	{"Easter Bay Airport",          {-1242.90,-50.00,0.00,-1213.90,578.30,200.00}},
	{"Easter Bay Airport",          {-1213.90,-50.00,-4.50,-947.90,578.30,200.00}},
	{"Easter Bay Airport",          {-1315.40,-405.30,15.40,-1264.40,-209.50,25.40}},
	{"Easter Bay Airport",          {-1354.30,-287.30,15.40,-1315.40,-209.50,25.40}},
	{"Easter Bay Airport",          {-1490.30,-209.50,15.40,-1264.40,-148.30,25.40}},
	{"Easter Bay Chemicals",        {-1132.80,-768.00,0.00,-956.40,-578.10,200.00}},
	{"Easter Bay Chemicals",        {-1132.80,-787.30,0.00,-956.40,-768.00,200.00}},
	{"El Castillo del Diablo",      {-464.50,2217.60,0.00,-208.50,2580.30,200.00}},
	{"El Castillo del Diablo",      {-208.50,2123.00,-7.60,114.00,2337.10,200.00}},
	{"El Castillo del Diablo",      {-208.50,2337.10,0.00,8.40,2487.10,200.00}},
	{"El Corona",                   {1812.60,-2179.20,-89.00,1970.60,-1852.80,110.90}},
	{"El Corona",                   {1692.60,-2179.20,-89.00,1812.60,-1842.20,110.90}},
	{"El Quebrados",                {-1645.20,2498.50,0.00,-1372.10,2777.80,200.00}},
	{"Esplanade East",              {-1620.30,1176.50,-4.50,-1580.00,1274.20,200.00}},
	{"Esplanade East",              {-1580.00,1025.90,-6.10,-1499.80,1274.20,200.00}},
	{"Esplanade East",              {-1499.80,578.30,-79.60,-1339.80,1274.20,20.30}},
	{"Esplanade North",             {-2533.00,1358.90,-4.50,-1996.60,1501.20,200.00}},
	{"Esplanade North",             {-1996.60,1358.90,-4.50,-1524.20,1592.50,200.00}},
	{"Esplanade North",             {-1982.30,1274.20,-4.50,-1524.20,1358.90,200.00}},
	{"Fallen Tree",                 {-792.20,-698.50,-5.30,-452.40,-380.00,200.00}},
	{"Fallow Bridge",               {434.30,366.50,0.00,603.00,555.60,200.00}},
	{"Fern Ridge",                  {508.10,-139.20,0.00,1306.60,119.50,200.00}},
	{"Financial",                   {-1871.70,744.10,-6.10,-1701.30,1176.40,300.00}},
	{"Fisher's Lagoon",             {1916.90,-233.30,-100.00,2131.70,13.80,200.00}},
	{"Flint Intersection",          {-187.70,-1596.70,-89.00,17.00,-1276.60,110.90}},
	{"Flint Range",                 {-594.10,-1648.50,0.00,-187.70,-1276.60,200.00}},
	{"Fort Carson",                 {-376.20,826.30,-3.00,123.70,1220.40,200.00}},
	{"Foster Valley",               {-2270.00,-430.20,-0.00,-2178.60,-324.10,200.00}},
	{"Foster Valley",               {-2178.60,-599.80,-0.00,-1794.90,-324.10,200.00}},
	{"Foster Valley",               {-2178.60,-1115.50,0.00,-1794.90,-599.80,200.00}},
	{"Foster Valley",               {-2178.60,-1250.90,0.00,-1794.90,-1115.50,200.00}},
	{"Frederick Bridge",            {2759.20,296.50,0.00,2774.20,594.70,200.00}},
	{"Gant Bridge",                 {-2741.40,1659.60,-6.10,-2616.40,2175.10,200.00}},
	{"Gant Bridge",                 {-2741.00,1490.40,-6.10,-2616.40,1659.60,200.00}},
	{"Ganton",                      {2222.50,-1852.80,-89.00,2632.80,-1722.30,110.90}},
	{"Ganton",                      {2222.50,-1722.30,-89.00,2632.80,-1628.50,110.90}},
	{"Garcia",                      {-2411.20,-222.50,-0.00,-2173.00,265.20,200.00}},
	{"Garcia",                      {-2395.10,-222.50,-5.30,-2354.00,-204.70,200.00}},
	{"Garver Bridge",               {-1339.80,828.10,-89.00,-1213.90,1057.00,110.90}},
	{"Garver Bridge",               {-1213.90,950.00,-89.00,-1087.90,1178.90,110.90}},
	{"Garver Bridge",               {-1499.80,696.40,-179.60,-1339.80,925.30,20.30}},
	{"Glen Park",                   {1812.60,-1449.60,-89.00,1996.90,-1350.70,110.90}},
	{"Glen Park",                   {1812.60,-1100.80,-89.00,1994.30,-973.30,110.90}},
	{"Glen Park",                   {1812.60,-1350.70,-89.00,2056.80,-1100.80,110.90}},
	{"Green Palms",                 {176.50,1305.40,-3.00,338.60,1520.70,200.00}},
	{"Greenglass College",          {964.30,1044.60,-89.00,1197.30,1203.20,110.90}},
	{"Greenglass College",          {964.30,930.80,-89.00,1166.50,1044.60,110.90}},
	{"Hampton Barns",               {603.00,264.30,0.00,761.90,366.50,200.00}},
	{"Hankypanky Point",            {2576.90,62.10,0.00,2759.20,385.50,200.00}},
	{"Harry Gold Parkway",          {1777.30,863.20,-89.00,1817.30,2342.80,110.90}},
	{"Hashbury",                    {-2593.40,-222.50,-0.00,-2411.20,54.70,200.00}},
	{"Hilltop Farm",                {967.30,-450.30,-3.00,1176.70,-217.90,200.00}},
	{"Hunter Quarry",               {337.20,710.80,-115.20,860.50,1031.70,203.70}},
	{"Idlewood",                    {1812.60,-1852.80,-89.00,1971.60,-1742.30,110.90}},
	{"Idlewood",                    {1812.60,-1742.30,-89.00,1951.60,-1602.30,110.90}},
	{"Idlewood",                    {1951.60,-1742.30,-89.00,2124.60,-1602.30,110.90}},
	{"Idlewood",                    {1812.60,-1602.30,-89.00,2124.60,-1449.60,110.90}},
	{"Idlewood",                    {2124.60,-1742.30,-89.00,2222.50,-1494.00,110.90}},
	{"Idlewood",                    {1971.60,-1852.80,-89.00,2222.50,-1742.30,110.90}},
	{"Jefferson",                   {1996.90,-1449.60,-89.00,2056.80,-1350.70,110.90}},
	{"Jefferson",                   {2124.60,-1494.00,-89.00,2266.20,-1449.60,110.90}},
	{"Jefferson",                   {2056.80,-1372.00,-89.00,2281.40,-1210.70,110.90}},
	{"Jefferson",                   {2056.80,-1210.70,-89.00,2185.30,-1126.30,110.90}},
	{"Jefferson",                   {2185.30,-1210.70,-89.00,2281.40,-1154.50,110.90}},
	{"Jefferson",                   {2056.80,-1449.60,-89.00,2266.20,-1372.00,110.90}},
	{"Julius Thruway East",         {2623.10,943.20,-89.00,2749.90,1055.90,110.90}},
	{"Julius Thruway East",         {2685.10,1055.90,-89.00,2749.90,2626.50,110.90}},
	{"Julius Thruway East",         {2536.40,2442.50,-89.00,2685.10,2542.50,110.90}},
	{"Julius Thruway East",         {2625.10,2202.70,-89.00,2685.10,2442.50,110.90}},
	{"Julius Thruway North",        {2498.20,2542.50,-89.00,2685.10,2626.50,110.90}},
	{"Julius Thruway North",        {2237.40,2542.50,-89.00,2498.20,2663.10,110.90}},
	{"Julius Thruway North",        {2121.40,2508.20,-89.00,2237.40,2663.10,110.90}},
	{"Julius Thruway North",        {1938.80,2508.20,-89.00,2121.40,2624.20,110.90}},
	{"Julius Thruway North",        {1534.50,2433.20,-89.00,1848.40,2583.20,110.90}},
	{"Julius Thruway North",        {1848.40,2478.40,-89.00,1938.80,2553.40,110.90}},
	{"Julius Thruway North",        {1704.50,2342.80,-89.00,1848.40,2433.20,110.90}},
	{"Julius Thruway North",        {1377.30,2433.20,-89.00,1534.50,2507.20,110.90}},
	{"Julius Thruway South",        {1457.30,823.20,-89.00,2377.30,863.20,110.90}},
	{"Julius Thruway South",        {2377.30,788.80,-89.00,2537.30,897.90,110.90}},
	{"Julius Thruway West",         {1197.30,1163.30,-89.00,1236.60,2243.20,110.90}},
	{"Julius Thruway West",         {1236.60,2142.80,-89.00,1297.40,2243.20,110.90}},
	{"Juniper Hill",                {-2533.00,578.30,-7.60,-2274.10,968.30,200.00}},
	{"Juniper Hollow",              {-2533.00,968.30,-6.10,-2274.10,1358.90,200.00}},
	{"K.A.C.C. Military Fuels",     {2498.20,2626.50,-89.00,2749.90,2861.50,110.90}},
	{"Kincaid Bridge",              {-1339.80,599.20,-89.00,-1213.90,828.10,110.90}},
	{"Kincaid Bridge",              {-1213.90,721.10,-89.00,-1087.90,950.00,110.90}},
	{"Kincaid Bridge",              {-1087.90,855.30,-89.00,-961.90,986.20,110.90}},
	{"King's",                      {-2329.30,458.40,-7.60,-1993.20,578.30,200.00}},
	{"King's",                      {-2411.20,265.20,-9.10,-1993.20,373.50,200.00}},
	{"King's",                      {-2253.50,373.50,-9.10,-1993.20,458.40,200.00}},
	{"LVA Freight Depot",           {1457.30,863.20,-89.00,1777.40,1143.20,110.90}},
	{"LVA Freight Depot",           {1375.60,919.40,-89.00,1457.30,1203.20,110.90}},
	{"LVA Freight Depot",           {1277.00,1087.60,-89.00,1375.60,1203.20,110.90}},
	{"LVA Freight Depot",           {1315.30,1044.60,-89.00,1375.60,1087.60,110.90}},
	{"LVA Freight Depot",           {1236.60,1163.40,-89.00,1277.00,1203.20,110.90}},
	{"Las Barrancas",               {-926.10,1398.70,-3.00,-719.20,1634.60,200.00}},
	{"Las Brujas",                  {-365.10,2123.00,-3.00,-208.50,2217.60,200.00}},
	{"Las Colinas",                 {1994.30,-1100.80,-89.00,2056.80,-920.80,110.90}},
	{"Las Colinas",                 {2056.80,-1126.30,-89.00,2126.80,-920.80,110.90}},
	{"Las Colinas",                 {2185.30,-1154.50,-89.00,2281.40,-934.40,110.90}},
	{"Las Colinas",                 {2126.80,-1126.30,-89.00,2185.30,-934.40,110.90}},
	{"Las Colinas",                 {2747.70,-1120.00,-89.00,2959.30,-945.00,110.90}},
	{"Las Colinas",                 {2632.70,-1135.00,-89.00,2747.70,-945.00,110.90}},
	{"Las Colinas",                 {2281.40,-1135.00,-89.00,2632.70,-945.00,110.90}},
	{"Las Payasadas",               {-354.30,2580.30,2.00,-133.60,2816.80,200.00}},
	{"Las Venturas Airport",        {1236.60,1203.20,-89.00,1457.30,1883.10,110.90}},
	{"Las Venturas Airport",        {1457.30,1203.20,-89.00,1777.30,1883.10,110.90}},
	{"Las Venturas Airport",        {1457.30,1143.20,-89.00,1777.40,1203.20,110.90}},
	{"Las Venturas Airport",        {1515.80,1586.40,-12.50,1729.90,1714.50,87.50}},
	{"Last Dime Motel",             {1823.00,596.30,-89.00,1997.20,823.20,110.90}},
	{"Leafy Hollow",                {-1166.90,-1856.00,0.00,-815.60,-1602.00,200.00}},
	{"Liberty City",                {-1000.00,400.00,1300.00,-700.00,600.00,1400.00}},
	{"Lil' Probe Inn",              {-90.20,1286.80,-3.00,153.80,1554.10,200.00}},
	{"Linden Side",                 {2749.90,943.20,-89.00,2923.30,1198.90,110.90}},
	{"Linden Station",              {2749.90,1198.90,-89.00,2923.30,1548.90,110.90}},
	{"Linden Station",              {2811.20,1229.50,-39.50,2861.20,1407.50,60.40}},
	{"Little Mexico",               {1701.90,-1842.20,-89.00,1812.60,-1722.20,110.90}},
	{"Little Mexico",               {1758.90,-1722.20,-89.00,1812.60,-1577.50,110.90}},
	{"Los Flores",                  {2581.70,-1454.30,-89.00,2632.80,-1393.40,110.90}},
	{"Los Flores",                  {2581.70,-1393.40,-89.00,2747.70,-1135.00,110.90}},
	{"Los Santos International",    {1249.60,-2394.30,-89.00,1852.00,-2179.20,110.90}},
	{"Los Santos International",    {1852.00,-2394.30,-89.00,2089.00,-2179.20,110.90}},
	{"Los Santos International",    {1382.70,-2730.80,-89.00,2201.80,-2394.30,110.90}},
	{"Los Santos International",    {1974.60,-2394.30,-39.00,2089.00,-2256.50,60.90}},
	{"Los Santos International",    {1400.90,-2669.20,-39.00,2189.80,-2597.20,60.90}},
	{"Los Santos International",    {2051.60,-2597.20,-39.00,2152.40,-2394.30,60.90}},
	{"Marina",                      {647.70,-1804.20,-89.00,851.40,-1577.50,110.90}},
	{"Marina",                      {647.70,-1577.50,-89.00,807.90,-1416.20,110.90}},
	{"Marina",                      {807.90,-1577.50,-89.00,926.90,-1416.20,110.90}},
	{"Market",                      {787.40,-1416.20,-89.00,1072.60,-1310.20,110.90}},
	{"Market",                      {952.60,-1310.20,-89.00,1072.60,-1130.80,110.90}},
	{"Market",                      {1072.60,-1416.20,-89.00,1370.80,-1130.80,110.90}},
	{"Market",                      {926.90,-1577.50,-89.00,1370.80,-1416.20,110.90}},
	{"Market Station",              {787.40,-1410.90,-34.10,866.00,-1310.20,65.80}},
	{"Martin Bridge",               {-222.10,293.30,0.00,-122.10,476.40,200.00}},
	{"Missionary Hill",             {-2994.40,-811.20,0.00,-2178.60,-430.20,200.00}},
	{"Montgomery",                  {1119.50,119.50,-3.00,1451.40,493.30,200.00}},
	{"Montgomery",                  {1451.40,347.40,-6.10,1582.40,420.80,200.00}},
	{"Montgomery Intersection",     {1546.60,208.10,0.00,1745.80,347.40,200.00}},
	{"Montgomery Intersection",     {1582.40,347.40,0.00,1664.60,401.70,200.00}},
	{"Mulholland",                  {1414.00,-768.00,-89.00,1667.60,-452.40,110.90}},
	{"Mulholland",                  {1281.10,-452.40,-89.00,1641.10,-290.90,110.90}},
	{"Mulholland",                  {1269.10,-768.00,-89.00,1414.00,-452.40,110.90}},
	{"Mulholland",                  {1357.00,-926.90,-89.00,1463.90,-768.00,110.90}},
	{"Mulholland",                  {1318.10,-910.10,-89.00,1357.00,-768.00,110.90}},
	{"Mulholland",                  {1169.10,-910.10,-89.00,1318.10,-768.00,110.90}},
	{"Mulholland",                  {768.60,-954.60,-89.00,952.60,-860.60,110.90}},
	{"Mulholland",                  {687.80,-860.60,-89.00,911.80,-768.00,110.90}},
	{"Mulholland",                  {737.50,-768.00,-89.00,1142.20,-674.80,110.90}},
	{"Mulholland",                  {1096.40,-910.10,-89.00,1169.10,-768.00,110.90}},
	{"Mulholland",                  {952.60,-937.10,-89.00,1096.40,-860.60,110.90}},
	{"Mulholland",                  {911.80,-860.60,-89.00,1096.40,-768.00,110.90}},
	{"Mulholland",                  {861.00,-674.80,-89.00,1156.50,-600.80,110.90}},
	{"Mulholland Intersection",     {1463.90,-1150.80,-89.00,1812.60,-768.00,110.90}},
	{"North Rock",                  {2285.30,-768.00,0.00,2770.50,-269.70,200.00}},
	{"Ocean Docks",                 {2373.70,-2697.00,-89.00,2809.20,-2330.40,110.90}},
	{"Ocean Docks",                 {2201.80,-2418.30,-89.00,2324.00,-2095.00,110.90}},
	{"Ocean Docks",                 {2324.00,-2302.30,-89.00,2703.50,-2145.10,110.90}},
	{"Ocean Docks",                 {2089.00,-2394.30,-89.00,2201.80,-2235.80,110.90}},
	{"Ocean Docks",                 {2201.80,-2730.80,-89.00,2324.00,-2418.30,110.90}},
	{"Ocean Docks",                 {2703.50,-2302.30,-89.00,2959.30,-2126.90,110.90}},
	{"Ocean Docks",                 {2324.00,-2145.10,-89.00,2703.50,-2059.20,110.90}},
	{"Ocean Flats",                 {-2994.40,277.40,-9.10,-2867.80,458.40,200.00}},
	{"Ocean Flats",                 {-2994.40,-222.50,-0.00,-2593.40,277.40,200.00}},
	{"Ocean Flats",                 {-2994.40,-430.20,-0.00,-2831.80,-222.50,200.00}},
	{"Octane Springs",              {338.60,1228.50,0.00,664.30,1655.00,200.00}},
	{"Old Venturas Strip",          {2162.30,2012.10,-89.00,2685.10,2202.70,110.90}},
	{"Palisades",                   {-2994.40,458.40,-6.10,-2741.00,1339.60,200.00}},
	{"Palomino Creek",              {2160.20,-149.00,0.00,2576.90,228.30,200.00}},
	{"Paradiso",                    {-2741.00,793.40,-6.10,-2533.00,1268.40,200.00}},
	{"Pershing Square",             {1440.90,-1722.20,-89.00,1583.50,-1577.50,110.90}},
	{"Pilgrim",                     {2437.30,1383.20,-89.00,2624.40,1783.20,110.90}},
	{"Pilgrim",                     {2624.40,1383.20,-89.00,2685.10,1783.20,110.90}},
	{"Pilson Intersection",         {1098.30,2243.20,-89.00,1377.30,2507.20,110.90}},
	{"Pirates in Men's Pants",      {1817.30,1469.20,-89.00,2027.40,1703.20,110.90}},
	{"Playa del Seville",           {2703.50,-2126.90,-89.00,2959.30,-1852.80,110.90}},
	{"Prickle Pine",                {1534.50,2583.20,-89.00,1848.40,2863.20,110.90}},
	{"Prickle Pine",                {1117.40,2507.20,-89.00,1534.50,2723.20,110.90}},
	{"Prickle Pine",                {1848.40,2553.40,-89.00,1938.80,2863.20,110.90}},
	{"Prickle Pine",                {1938.80,2624.20,-89.00,2121.40,2861.50,110.90}},
	{"Queens",                      {-2533.00,458.40,0.00,-2329.30,578.30,200.00}},
	{"Queens",                      {-2593.40,54.70,0.00,-2411.20,458.40,200.00}},
	{"Queens",                      {-2411.20,373.50,0.00,-2253.50,458.40,200.00}},
	{"Randolph Industrial Estate",  {1558.00,596.30,-89.00,1823.00,823.20,110.90}},
	{"Redsands East",               {1817.30,2011.80,-89.00,2106.70,2202.70,110.90}},
	{"Redsands East",               {1817.30,2202.70,-89.00,2011.90,2342.80,110.90}},
	{"Redsands East",               {1848.40,2342.80,-89.00,2011.90,2478.40,110.90}},
	{"Redsands West",               {1236.60,1883.10,-89.00,1777.30,2142.80,110.90}},
	{"Redsands West",               {1297.40,2142.80,-89.00,1777.30,2243.20,110.90}},
	{"Redsands West",               {1377.30,2243.20,-89.00,1704.50,2433.20,110.90}},
	{"Redsands West",               {1704.50,2243.20,-89.00,1777.30,2342.80,110.90}},
	{"Regular Tom",                 {-405.70,1712.80,-3.00,-276.70,1892.70,200.00}},
	{"Richman",                     {647.50,-1118.20,-89.00,787.40,-954.60,110.90}},
	{"Richman",                     {647.50,-954.60,-89.00,768.60,-860.60,110.90}},
	{"Richman",                     {225.10,-1369.60,-89.00,334.50,-1292.00,110.90}},
	{"Richman",                     {225.10,-1292.00,-89.00,466.20,-1235.00,110.90}},
	{"Richman",                     {72.60,-1404.90,-89.00,225.10,-1235.00,110.90}},
	{"Richman",                     {72.60,-1235.00,-89.00,321.30,-1008.10,110.90}},
	{"Richman",                     {321.30,-1235.00,-89.00,647.50,-1044.00,110.90}},
	{"Richman",                     {321.30,-1044.00,-89.00,647.50,-860.60,110.90}},
	{"Richman",                     {321.30,-860.60,-89.00,687.80,-768.00,110.90}},
	{"Richman",                     {321.30,-768.00,-89.00,700.70,-674.80,110.90}},
	{"Robada Intersection",         {-1119.00,1178.90,-89.00,-862.00,1351.40,110.90}},
	{"Roca Escalante",              {2237.40,2202.70,-89.00,2536.40,2542.50,110.90}},
	{"Roca Escalante",              {2536.40,2202.70,-89.00,2625.10,2442.50,110.90}},
	{"Rockshore East",              {2537.30,676.50,-89.00,2902.30,943.20,110.90}},
	{"Rockshore West",              {1997.20,596.30,-89.00,2377.30,823.20,110.90}},
	{"Rockshore West",              {2377.30,596.30,-89.00,2537.30,788.80,110.90}},
	{"Rodeo",                       {72.60,-1684.60,-89.00,225.10,-1544.10,110.90}},
	{"Rodeo",                       {72.60,-1544.10,-89.00,225.10,-1404.90,110.90}},
	{"Rodeo",                       {225.10,-1684.60,-89.00,312.80,-1501.90,110.90}},
	{"Rodeo",                       {225.10,-1501.90,-89.00,334.50,-1369.60,110.90}},
	{"Rodeo",                       {334.50,-1501.90,-89.00,422.60,-1406.00,110.90}},
	{"Rodeo",                       {312.80,-1684.60,-89.00,422.60,-1501.90,110.90}},
	{"Rodeo",                       {422.60,-1684.60,-89.00,558.00,-1570.20,110.90}},
	{"Rodeo",                       {558.00,-1684.60,-89.00,647.50,-1384.90,110.90}},
	{"Rodeo",                       {466.20,-1570.20,-89.00,558.00,-1385.00,110.90}},
	{"Rodeo",                       {422.60,-1570.20,-89.00,466.20,-1406.00,110.90}},
	{"Rodeo",                       {466.20,-1385.00,-89.00,647.50,-1235.00,110.90}},
	{"Rodeo",                       {334.50,-1406.00,-89.00,466.20,-1292.00,110.90}},
	{"Royal Casino",                {2087.30,1383.20,-89.00,2437.30,1543.20,110.90}},
	{"San Andreas Sound",           {2450.30,385.50,-100.00,2759.20,562.30,200.00}},
	{"Santa Flora",                 {-2741.00,458.40,-7.60,-2533.00,793.40,200.00}},
	{"Santa Maria Beach",           {342.60,-2173.20,-89.00,647.70,-1684.60,110.90}},
	{"Santa Maria Beach",           {72.60,-2173.20,-89.00,342.60,-1684.60,110.90}},
	{"Shady Cabin",                 {-1632.80,-2263.40,-3.00,-1601.30,-2231.70,200.00}},
	{"Shady Creeks",                {-1820.60,-2643.60,-8.00,-1226.70,-1771.60,200.00}},
	{"Shady Creeks",                {-2030.10,-2174.80,-6.10,-1820.60,-1771.60,200.00}},
	{"Sobell Rail Yards",           {2749.90,1548.90,-89.00,2923.30,1937.20,110.90}},
	{"Spinybed",                    {2121.40,2663.10,-89.00,2498.20,2861.50,110.90}},
	{"Starfish Casino",             {2437.30,1783.20,-89.00,2685.10,2012.10,110.90}},
	{"Starfish Casino",             {2437.30,1858.10,-39.00,2495.00,1970.80,60.90}},
	{"Starfish Casino",             {2162.30,1883.20,-89.00,2437.30,2012.10,110.90}},
	{"Temple",                      {1252.30,-1130.80,-89.00,1378.30,-1026.30,110.90}},
	{"Temple",                      {1252.30,-1026.30,-89.00,1391.00,-926.90,110.90}},
	{"Temple",                      {1252.30,-926.90,-89.00,1357.00,-910.10,110.90}},
	{"Temple",                      {952.60,-1130.80,-89.00,1096.40,-937.10,110.90}},
	{"Temple",                      {1096.40,-1130.80,-89.00,1252.30,-1026.30,110.90}},
	{"Temple",                      {1096.40,-1026.30,-89.00,1252.30,-910.10,110.90}},
	{"The Camel's Toe",             {2087.30,1203.20,-89.00,2640.40,1383.20,110.90}},
	{"The Clown's Pocket",          {2162.30,1783.20,-89.00,2437.30,1883.20,110.90}},
	{"The Emerald Isle",            {2011.90,2202.70,-89.00,2237.40,2508.20,110.90}},
	{"The Farm",                    {-1209.60,-1317.10,114.90,-908.10,-787.30,251.90}},
	{"The Four Dragons Casino",     {1817.30,863.20,-89.00,2027.30,1083.20,110.90}},
	{"The High Roller",             {1817.30,1283.20,-89.00,2027.30,1469.20,110.90}},
	{"The Mako Span",               {1664.60,401.70,0.00,1785.10,567.20,200.00}},
	{"The Panopticon",              {-947.90,-304.30,-1.10,-319.60,327.00,200.00}},
	{"The Pink Swan",               {1817.30,1083.20,-89.00,2027.30,1283.20,110.90}},
	{"The Sherman Dam",             {-968.70,1929.40,-3.00,-481.10,2155.20,200.00}},
	{"The Strip",                   {2027.40,863.20,-89.00,2087.30,1703.20,110.90}},
	{"The Strip",                   {2106.70,1863.20,-89.00,2162.30,2202.70,110.90}},
	{"The Strip",                   {2027.40,1783.20,-89.00,2162.30,1863.20,110.90}},
	{"The Strip",                   {2027.40,1703.20,-89.00,2137.40,1783.20,110.90}},
	{"The Visage",                  {1817.30,1863.20,-89.00,2106.70,2011.80,110.90}},
	{"The Visage",                  {1817.30,1703.20,-89.00,2027.40,1863.20,110.90}},
	{"Unity Station",               {1692.60,-1971.80,-20.40,1812.60,-1932.80,79.50}},
	{"Valle Ocultado",              {-936.60,2611.40,2.00,-715.90,2847.90,200.00}},
	{"Verdant Bluffs",              {930.20,-2488.40,-89.00,1249.60,-2006.70,110.90}},
	{"Verdant Bluffs",              {1073.20,-2006.70,-89.00,1249.60,-1842.20,110.90}},
	{"Verdant Bluffs",              {1249.60,-2179.20,-89.00,1692.60,-1842.20,110.90}},
	{"Verdant Meadows",             {37.00,2337.10,-3.00,435.90,2677.90,200.00}},
	{"Verona Beach",                {647.70,-2173.20,-89.00,930.20,-1804.20,110.90}},
	{"Verona Beach",                {930.20,-2006.70,-89.00,1073.20,-1804.20,110.90}},
	{"Verona Beach",                {851.40,-1804.20,-89.00,1046.10,-1577.50,110.90}},
	{"Verona Beach",                {1161.50,-1722.20,-89.00,1323.90,-1577.50,110.90}},
	{"Verona Beach",                {1046.10,-1722.20,-89.00,1161.50,-1577.50,110.90}},
	{"Vinewood",                    {787.40,-1310.20,-89.00,952.60,-1130.80,110.90}},
	{"Vinewood",                    {787.40,-1130.80,-89.00,952.60,-954.60,110.90}},
	{"Vinewood",                    {647.50,-1227.20,-89.00,787.40,-1118.20,110.90}},
	{"Vinewood",                    {647.70,-1416.20,-89.00,787.40,-1227.20,110.90}},
	{"Whitewood Estates",           {883.30,1726.20,-89.00,1098.30,2507.20,110.90}},
	{"Whitewood Estates",           {1098.30,1726.20,-89.00,1197.30,2243.20,110.90}},
	{"Willowfield",                 {1970.60,-2179.20,-89.00,2089.00,-1852.80,110.90}},
	{"Willowfield",                 {2089.00,-2235.80,-89.00,2201.80,-1989.90,110.90}},
	{"Willowfield",                 {2089.00,-1989.90,-89.00,2324.00,-1852.80,110.90}},
	{"Willowfield",                 {2201.80,-2095.00,-89.00,2324.00,-1989.90,110.90}},
	{"Willowfield",                 {2541.70,-1941.40,-89.00,2703.50,-1852.80,110.90}},
	{"Willowfield",                 {2324.00,-2059.20,-89.00,2541.70,-1852.80,110.90}},
	{"Willowfield",                 {2541.70,-2059.20,-89.00,2703.50,-1941.40,110.90}},
	{"Yellow Bell Station",         {1377.40,2600.40,-21.90,1492.40,2687.30,78.00}},
	// Main Zones
	{"Los Santos",                  {44.60,-2892.90,-242.90,2997.00,-768.00,900.00}},
	{"Las Venturas",                {869.40,596.30,-242.90,2997.00,2993.80,900.00}},
	{"Bone County",                 {-480.50,596.30,-242.90,869.40,2993.80,900.00}},
	{"Tierra Robada",               {-2997.40,1659.60,-242.90,-480.50,2993.80,900.00}},
	{"Tierra Robada",               {-1213.90,596.30,-242.90,-480.50,1659.60,900.00}},
	{"San Fierro",                  {-2997.40,-1115.50,-242.90,-1213.90,1659.60,900.00}},
	{"Red County",                  {-1213.90,-768.00,-242.90,2997.00,596.30,900.00}},
	{"Flint County",                {-1213.90,-2892.90,-242.90,44.60,-768.00,900.00}},
	{"Whetstone",                   {-2997.40,-2892.90,-242.90,-1213.90,-1115.50,900.00}},
	{"San Andreas",                	{4601.083, -2989.536, -242.90, 2989.536, -3666.853, 1500.00}},
	{"Mount Chilliad",              {-2997.40,-2892.90,-242.90,-1213.90,-1115.50,900.00}}
};

#define MAKE_COLOR_FROM_RGB(%0,%1,%2,%3) ((((%0) & 0xFF) << 24) | (((%1) & 0xFF) << 16) | (((%2) & 0xFF) << 8) | (((%3) & 0xFF) << 0))

#define red 0xFF0000AA
#define green 0x33FF33AA
#define blue  0x0000FFFF

new
	bankMoney[ MAX_PLAYERS ],
	bool: bAcc[ MAX_PLAYERS char ];

new Iterator:Houses<MAX_HOUSES>, Text3D:HouseLabel[MAX_HOUSES], Float:X, Float:Y, Float:Z, Float:Angle;
#if GH_USE_CPS == true
	new HouseCPOut[MAX_HOUSES], HouseCPInt[MAX_HOUSES];
#else
	new HousePickupOut[MAX_HOUSES], HousePickupInt[MAX_HOUSES];
#endif
#if GH_USE_MAPICONS == true
	new HouseMIcon[MAX_HOUSES];
#endif
#if GH_HOUSECARS == true
	new HCar[MAX_HOUSES];
#endif

new DuelTimer[MAX_PLAYERS];
new UpdateSpecTimer[MAX_PLAYERS];

forward DuelReset(player1, player2);
forward DuelCDUpdate(playerid);
forward UpdateSpectate(playerid);

new dFile[70];
new diagstr[900];
new Text:SpecTD[MAX_PLAYERS][2];

new diagitem[25];
new dinvitem[MAX_PLAYERS][MAX_INVITES];

new InDuel[MAX_PLAYERS];

enum duels
{
	Inviter,
	Invitee,
	BetMoney,
	Location,
	Started
}
new dInfo[MAX_DUELS][duels];
new dWeps[MAX_DUELS][MAX_DUEL_WEPS];
new TotalDuels;

enum ServerData
{
   ConnectMessages,
};

new ServerInfo[ServerData];

new vNames[212][] =
{
	{"Landstalker"},
	{"Bravura"},
	{"Buffalo"},
	{"Linerunner"},
	{"Perrenial"},
	{"Sentinel"},
	{"Dumper"},
	{"Firetruck"},
	{"Trashmaster"},
	{"Stretch"},
	{"Manana"},
	{"Infernus"},
	{"Voodoo"},
	{"Pony"},
	{"Mule"},
	{"Cheetah"},
	{"Ambulance"},
	{"Leviathan"},
	{"Moonbeam"},
	{"Esperanto"},
	{"Taxi"},
	{"Washington"},
	{"Bobcat"},
	{"MrWhoopee"},
	{"BFInjection"},
	{"Hunter"},
	{"Premier"},
	{"Enforcer"},
	{"Securicar"},
	{"Banshee"},
	{"Predator"},
	{"Bus"},
	{"Rhino"},
	{"Barracks"},
	{"Hotknife"},
	{"Trailer1"},
	{"Previon"},
	{"Coach"},
	{"Cabbie"},
	{"Stallion"},
	{"Rumpo"},
	{"RCBandit"},
	{"Romero"},
	{"Packer"},
	{"Monster"},
	{"Admiral"},
	{"Squalo"},
	{"Seasparrow"},
	{"Pizzaboy"},
	{"Tram"},
	{"Trailer2"},
	{"Turismo"},
	{"Speeder"},
	{"Reefer"},
	{"Tropic"},
	{"Flatbed"},
	{"Yankee"},
	{"Caddy"},
	{"Solair"},
	{"BerkleyRCVan"},
	{"Skimmer"},
	{"PCJ-600"},
	{"Faggio"},
	{"Freeway"},
	{"RCBaron"},
	{"RCRaider"},
	{"Glendale"},
	{"Oceanic"},
	{"Sanchez"},
	{"Sparrow"},
	{"Patriot"},
	{"Quad"},
	{"Coastguard"},
	{"Dinghy"},
	{"Hermes"},
	{"Sabre"},
	{"Rustler"},
	{"ZR-350"},
	{"Walton"},
	{"Regina"},
	{"Comet"},
	{"BMX"},
	{"Burrito"},
	{"Camper"},
	{"Marquis"},
	{"Baggage"},
	{"Dozer"},
	{"Maverick"},
	{"NewsChopper"},
	{"Rancher"},
	{"FBIRancher"},
	{"Virgo"},
	{"Greenwood"},
	{"Jetmax"},
	{"Hotring"},
	{"Sandking"},
	{"Blista Compact"},
	{"Police Maverick"},
	{"Boxville"},
	{"Benson"},
	{"Mesa"},
	{"RCGoblin"},
	{"HotringRacer A"},
	{"HotringRacer B"},
	{"BloodringBanger"},
	{"Rancher"},
	{"SuperGT"},
	{"Elegant"},
	{"Journey"},
	{"Bike"},
	{"MountainBike"},
	{"Beagle"},
	{"Cropdust"},
	{"Stunt"},
	{"Tanker"},
	{"Roadtrain"},
	{"Nebula"},
	{"Majestic"},
	{"Buccaneer"},
	{"Shamal"},
	{"Hydra"},
	{"FCR-900"},
	{"NRG-500"},
	{"HPV1000"},
	{"CementTruck"},
	{"TowTruck"},
	{"Fortune"},
	{"Cadrona"},
	{"FBITruck"},
	{"Willard"},
	{"Forklift"},
	{"Tractor"},
	{"Combine"},
	{"Feltzer"},
	{"Remington"},
	{"Slamvan"},
	{"Blade"},
	{"Freight"},
	{"Streak"},
	{"Vortex"},
	{"Vincent"},
	{"Bullet"},
	{"Clover"},
	{"Sadler"},
	{"FiretruckLA"},
	{"Hustler"},
	{"Intruder"},
	{"Primo"},
	{"Cargobob"},
	{"Tampa"},
	{"Sunrise"},
	{"Merit"},
	{"Utility"},
	{"Nevada"},
	{"Yosemite"},
	{"Windsor"},
	{"MonsterA"},
	{"MonsterB"},
	{"Uranus"},
	{"Jester"},
	{"Sultan"},
	{"Stratum"},
	{"Elegy"},
	{"Raindance"},
	{"RC Tiger"},
	{"Flash"},
	{"Tahoma"},
	{"Savanna"},
	{"Bandito"},
	{"FreightFlat"},
	{"StreakCarriage"},
	{"Kart"},
	{"Mower"},
	{"Duneride"},
	{"Sweeper"},
	{"Broadway"},
	{"Tornado"},
	{"AT-400"},
	{"DFT-30"},
	{"Huntley"},
	{"Stafford"},
	{"BF-400"},
	{"Newsvan"},
	{"Tug"},
	{"Trailer 3"},
	{"Emperor"},
	{"Wayfarer"},
	{"Euros"},
	{"Hotdog"},
	{"Club"},
	{"FreightCarriage"},
	{"Trailer3"},
	{"Andromada"},
	{"Dodo"},
	{"RCCam"},
	{"Launch"},
	{"PoliceCar(LSPD)"},
	{"PoliceCar(SFPD)"},
	{"PoliceCar(LVPD)"},
	{"PoliceRanger"},
	{"Picador"},
	{"S.W.A.T.Van"},
	{"Alpha"},
	{"Phoenix"},
	{"Glendale"},
	{"Sadler"},
	{"LuggageTrailerA"},
	{"LuggageTrailerB"},
	{"StairTrailer"},
	{"Boxville"},
	{"FarmPlow"},
	{"UtilityTrailer"}
	},
	BuildRace,
	BuildRaceType,
	BuildVehicle,
	BuildCreatedVehicle,
	BuildModeVID,
	BuildName[30],
	bool: BuildTakeVehPos,
	BuildVehPosCount,
	bool: BuildTakeCheckpoints,
	BuildCheckPointCount,
	RaceBusy = 0x00,
	RaceName[30],
	RaceVehicle,
	RaceType,
	TotalCP,
	Float: RaceVehCoords[2][4],
	Float: CPCoords[MAX_RACE_CHECKPOINTS_EACH_RACE][4],
	CreatedRaceVeh[MAX_PLAYERS],
	Index,
	PlayersCount[2],
	CountTimer,
	CountAmount,
	bool: Joined[MAX_PLAYERS],
	RaceTick,
	RaceStarted,
	CPProgess[MAX_PLAYERS],
	Position,
	FinishCount,
	JoinCount,
	rCounter,
	RaceTime,
	Text: RaceInfo[MAX_PLAYERS],
	InfoTimer[MAX_PLAYERS],
	RacePosition[MAX_PLAYERS],
	RaceNames[MAX_RACES][128],
 	TotalRaces,
 	bool: AutomaticRace,
 	TimeProgress
;
new RaceTimer;
new CountDown2 = -1;

new gPlayerUsingLoopingAnim[MAX_PLAYERS];
new gPlayerAnimLibsPreloaded[MAX_PLAYERS];

new ExitAnim[MAX_PLAYERS];
new Offer[MAX_PLAYERS];
new ChosenStyle[MAX_PLAYERS];

new VCannon;
//------------------------
// Vehicles
//------------------------
stock bankFile( playerid ) {
	new
		file[ 72 ],
		name[ 24 ];
	GetPlayerName( playerid, name, 24 );
	format( file, sizeof ( file ), "Bank/%s.ini", name );
	return file;
}

stock FormatNumber(inum, const sizechar[] = ",")
{
	new string[16];
	format(string, sizeof(string), "%d", inum);

	for(new ilen = strlen(string) - 3; ilen > 0; ilen -= 3)
	{
		strins(string, sizechar, ilen);
	}
	return string;
}

/*stock isNumeric( const str[ ] ) {
	new
	    i = 0,
		j = strlen( str );
	for ( ; i < j; ++ i ) {
	    if ( str[ i ] < '0' || str[ i ] > '9' ) {
	        return false;
		}
	}
	return true;
}*/

stock GetXYInFrontOfPlayer(playerid, &Float:x2, &Float:y2, Float:distance)
{
        new Float:a;

        GetPlayerPos(playerid, x2, y2, a);
        GetPlayerFacingAngle(playerid, a);

        if(GetPlayerVehicleID(playerid))
        {
                GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
        }

        x2 += (distance * floatsin(-a, degrees));
        y2 += (distance * floatcos(-a, degrees));
}
//-------------------------------------------------

OnePlayAnim(playerid,animlib[],animname[], Float:Speed, looping, lockx, locky, freeze, time)
{
	ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, freeze, time, 1);
    GameTextForPlayer(playerid, "~w~To stop the anim hit ~r~H!", 3000, 5);
	return;
}

//-------------------------------------------------
LoopingAnim(playerid,animlib[],animname[], Float:Speed, looping, lockx, locky, freeze, time)
{
    gPlayerUsingLoopingAnim[playerid] = 1;
    ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, freeze, time, 1);
    GameTextForPlayer(playerid, "~w~To stop the anim hit ~r~H!", 3000, 5);
	return;
}
//-------------------------------------------------

StopLoopingAnim(playerid)
{
    if(gPlayerUsingLoopingAnim[playerid] == 2)
    {
        SetPlayerSpecialAction(playerid, 0);
	}
	if(ExitAnim[playerid] == 1)
	{
	    OnePlayAnim(playerid, "ped", "SEAT_up", 4.0, 0, 0, 0, 0, 0);
	}
	else if(ExitAnim[playerid] == 2)
	{
	    OnePlayAnim(playerid, "ON_LOOKERS", "wave_loop", 4.0, 0, 0, 0, 0, 0);
	}
	else if(ExitAnim[playerid] == 3)
	{
	    OnePlayAnim(playerid, "PARK", "Tai_Chi_Out", 4.0, 0, 0, 0, 0, 0);
	}
	else if(ExitAnim[playerid] == 4)
	{
	    OnePlayAnim(playerid, "PAULNMAC", "wank_out", 4.0, 0, 0, 0, 0, 0);
	}
	else if(ExitAnim[playerid] == 5)
	{
	    OnePlayAnim(playerid, "PAULNMAC", "Piss_out", 4.0, 0, 0, 0, 0, 0);
	}
	else if(ExitAnim[playerid] == 6)
	{
	    OnePlayAnim(playerid, "BLOWJOBZ", "BJ_COUCH_END_W", 4.0, 0, 0, 0, 0, 0);
	}
	else if(ExitAnim[playerid] == 7)
	{
	    OnePlayAnim(playerid, "CAR", "Fixn_Car_Out", 4.0, 0, 0, 0, 0, 0);
	}
	else if(ExitAnim[playerid] == 8)
	{
	    OnePlayAnim(playerid, "Attractors", "Stepsit_out", 4.0, 0, 0, 0, 0, 0);
	}
	else if(ExitAnim[playerid] == 9)
	{
	    OnePlayAnim(playerid, "FOOD", "FF_Sit_Out_L_180", 4.0, 0, 0, 0, 0, 0);
	}
	else if(ExitAnim[playerid] == 10)
	{
	    OnePlayAnim(playerid, "FOOD", "FF_Sit_Out_R_180", 4.0, 0, 0, 0, 0, 0);
	}
	else if(ExitAnim[playerid] == 11)
	{
	    OnePlayAnim(playerid, "ON_LOOKERS", "Pointup_out", 4.0, 0, 0, 0, 0, 0);
	}
	else
	{
    	ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0, 1);
	}
	ExitAnim[playerid] = 0;
	gPlayerUsingLoopingAnim[playerid] = 0;
	return;
}

//-------------------------------------------------

PreloadAnimLib(playerid, animlib[])
{
	ApplyAnimation(playerid,animlib,"null",0.0,0,0,0,0,0,0);
	return;
}

//--------------
// New Stuff
//--------------
new InDeathMatch[MAX_PLAYERS];

new Text3D:jaja[MAX_PLAYERS] , daadetext3d[MAX_PLAYERS] , textjaja[MAX_PLAYERS][128];
new string1[54];

native WP_Hash(buffer[],len,const str[]);

new strg[256];

new cage[MAX_PLAYERS], cage2[MAX_PLAYERS], cage3[MAX_PLAYERS], cage4[MAX_PLAYERS], caged[MAX_PLAYERS];
new players_connected;
new seconds[MAX_PLAYERS];
new gTotalRegisters;
new vID;
new lastactive[50];
new
		Float:pos_x[MAX_PLAYERS],
		Float:pos_y[MAX_PLAYERS],
		Float:pos_z[MAX_PLAYERS]
	;
new gDMTD;
new Float:SpecX[MAX_PLAYERS], Float:SpecY[MAX_PLAYERS], Float:SpecZ[MAX_PLAYERS], vWorld[MAX_PLAYERS], Inter[MAX_PLAYERS];
new IsSpecing[MAX_PLAYERS], IsBeingSpeced[MAX_PLAYERS],spectatorid[MAX_PLAYERS];

forward FixAllCar();
forward Updater();
new FixTimer;
new ScoreTimer;
new timer;
new AntifallEnabled[MAX_PLAYERS];
new inVehicle[MAX_PLAYERS];
new carID[MAX_PLAYERS];
new AutoFix[MAX_PLAYERS];
new Nitro[MAX_PLAYERS];
new Bounce[MAX_PLAYERS];
new killstreak[MAX_PLAYERS];
new HealTimer[MAX_PLAYERS];
new HealPlayTimer[MAX_PLAYERS];
new randomMessages[][] =
    {
        "{F5511B}[HELP] {F5CD1B}Want a house or business? Ask from the Owner!",
        "{F5511B}[HELP]	{F5CD1B}Want to be free VIP? Apply on forum for Silver! VIP Cmds /vcmds!",
        "{F5511B}[HELP] {F5CD1B}Saw a rulebreaker? Use /report to notify the staff!",
		"{F5511B}[HELP] {F5CD1B}Wanna know who are the developers? See them in /credits!",
		"{F5511B}[HELP] {F5CD1B}Are you using the default weaponset? Try out the new weaponsets using /weapons(/w)!",
		"{F5511B}[HELP] {F5CD1B}Don't have a vehicle? Try up /v, /vehicle or if you want pimped up ride use /tc2 to /tc13!",
		"{F5511B}[HELP] {F5CD1B}Losing your health while stunting? Use /god to enable god protection!",
		"{F5511B}[HELP] {F5CD1B}Don't know all the commands? Check out all using /cmds!",
		"{F5511B}[HELP] {F5CD1B}Don't know the teleports? Visit /teles!",
		"{FF0000}[SERVER] {00FF00}Want to donate for Gold or Platinum VIP? Visit /donate for more info!",
		//"{FF0000}[SERVER] {00FF00}Join our TeamSpeak 3 Server! IP: 62.75.158.36!",
		"{FF0000}Pro-Tip: {00FF00}Use /commands or /cmds for seeing Server commands.",
		"{FF0000}Pro-Tip: {00FF00}Found a Bug, Report the Bug on forums!",
		"{FF0000}Pro-Tip: {00FF00}Register in our forums for the latest/upcoming Updates! "SERVER_WEBSITE"!",
		"{FF0000}Pro-Tip: {00FF00}Do Not Hack, Jennifer is Always watching you.!",
		"{FF0000}Pro-Tip: {00FF00}Found a Hacker? Report it now with /report or go to our forums to report.",
		"{FF0000}Pro-Tip: {00FF00}This Server has a strict policy, If you hack you will not get Un-Banned!",
		"{FF0000}Pro-Tip: {00FF00}Want to Become Admin? Be Helpful, Loyal & Play Fair. You will be selected in Admin Team.",
		"{FF0000}Pro-Tip: {00FF00}Cookies and Brownies will be given for Good Beahviour."
	};
new InfoTD_MSG[][] =
{
    "~y~Enjoying TBS? Visit our server website at ~r~"SERVER_WEBSITE"~y~!",
    "~y~Don't know the teleports? Visit ~p~/teles~y~!",
    "~y~Need a vehicle? Type ~g~/vehicle ~y~to get a list of all vehicles!",
    "~y~Saw a rulebreaker? Use ~r~/report ~y~to notify the staff!",
	"~y~Don't know the rules? See ~r~/rules ~y~!",
	"~y~Losing your health while stunting? Use ~p~/god~y~!",
	"~y~Don't know all the commands? Check out all using ~g~/cmds~y~!",
	"~y~Want cool weapons? Try out ~r~/weapons ~y~!",
	"~r~Willing to donate for VIP? Check ~r~/donate ~b~ for more info!"
	//"~g~Join our ~b~Team Speak 3 ~g~Server! IP: 62.75.158.36!"
};

new cd = -1;

//vehicle variables
new  Float:pX,
Float:pY, Float:pZ, Float:pAngle;
//--

new RandomHelmet[] =
{
    18645,
	18976,
	18977,
	18978,
	18979

};

new WeaponNames[55][] =
{
	"Fist", "Brass Knuckles", "Golf Club", "Nightstick", "Knife", "Baseball Bat",
	"Shovel", "Pool Cue", "Katana", "Chainsaw", "Double-ended Dilde", "Dildo",
	"Vibrator", "Silver Vibrator", "Flowers", "Cane", "Grenade", "Tear Gas",
	"Molotov Cocktail", "Unknow", "Unknown", "Unknown", "9mm", "Silenced 9mm",
	"Desert Eagle", "Shotgun", "Sawnoff Shotgun", "Combat Shotgun", "Micro SMG",
	"MP5", "AK-47", "M4", "Tec-9", "Country Rifle", "Sniper Rifle", "RPG", "HS Rocket",
	"Flamethrower", "Minigun", "Satchel Charge", "Detonator", "Spraycan", "Fire Extinguisher",
	"Camera", "Night Vis Goggles", "Thermal Goggles", "Parachute", "Fake Pistol", "Unknown",
	"Vehicle", "Helicopter Blades", "Explosion", "Unkown", "Drowned", "Spat"
};

new gOnlineTime;
new gTotalKills;
new gTotalBans;
new gLastRestartedTime[10];
new gLastRestartedDate[10];

new gFDMPlayers;
new gWARPlayers;
new gMINIPlayers;
new gEAGLEPlayers;
new gRDMPlayers;
new gODMPlayers;
new gSAWNDMPlayers;

new Float: SBvalue[MAX_PLAYERS];

new lastcommand[MAX_PLAYERS];

enum Data
{
   HousePassword,
   HouseOwner[MAX_PLAYER_NAME],
   HouseName[MAX_HOUSE_NAME],
   HouseLocation[MAX_ZONE_NAME],
   Float:SpawnOutAngle,
   SpawnInterior,
   SpawnWorld,
   Float:CPOutX,
   Float:CPOutY,
   Float:CPOutZ,
   Float:SpawnOutX,
   Float:SpawnOutY,
   Float:SpawnOutZ,
   HouseValue,
   HouseStorage,
   HouseInterior,
   HouseCar,
   HouseCarModel,
   HouseCarWorld,
   HouseCarInterior,
   Float:HouseCarPosX,
   Float:HouseCarPosY,
   Float:HouseCarPosZ,
   Float:HouseCarAngle,
   QuitInHouse,
   Weapon[14],
   Ammo[14],
   ForSale,
   ForSalePrice,
   HousePrivacy,
   HouseAlarm,
   HouseCamera,
   HouseDog,
   UpgradedLock
}
enum hIntData
{
   IntName[30],
   Float:IntSpawnX,
   Float:IntSpawnY,
   Float:IntSpawnZ,
   Float:IntSpawnAngle,
   Float:IntCPX,
   Float:IntCPY,
   Float:IntCPZ,
   IntInterior,
   IntValue
}
new hInfo[MAX_HOUSES][Data], hIntInfo[MAX_HOUSE_INTERIORS][hIntData];
new CurrentID;

//--------------------
//  Welcome TextDraws
//--------------------
new PlayerText:Textdraw0[MAX_PLAYERS];
new PlayerText:Textdraw1[MAX_PLAYERS];
new PlayerText:Textdraw2[MAX_PLAYERS];
new PlayerText:Textdraw3[MAX_PLAYERS];
new PlayerText:Textdraw4[MAX_PLAYERS];
new PlayerText:Textdraw5[MAX_PLAYERS];
new PlayerText:Textdraw6[MAX_PLAYERS];
new PlayerText:Textdraw7[MAX_PLAYERS];
new PlayerText:Textdraw8[MAX_PLAYERS];
new PlayerText:Textdraw9[MAX_PLAYERS];
new PlayerText:Textdraw10[MAX_PLAYERS];
new PlayerText:Textdraw11[MAX_PLAYERS];
new PlayerText:Textdraw12[MAX_PLAYERS];
new PlayerText:Textdraw13[MAX_PLAYERS];
new PlayerText:Textdraw14[MAX_PLAYERS];
new PlayerText:Textdraw15[MAX_PLAYERS];
new PlayerText:Textdraw16[MAX_PLAYERS];
new PlayerText:rInfoTDS[MAX_PLAYERS];

new Text:box;
new Text:fdm;
new Text:war;
new Text:mini;
new Text:eagle;
new Text:rdm;
new Text:odm;
new Text:sawndm;
new Text:fdmplayers;
new Text:warplayers;
new Text:miniplayers;
new Text:eagleplayers;
new Text:rdmplayers;
new Text:odmplayers;
new Text:sawndmplayers;
new Text:web;
new Text:InfoTD;
new Text:T;
new Text:BS;
new Text:gTextDraw[5];
//------------------------
// DM
//------------------------
new PlayerText:EXPforDM[MAX_PLAYERS];
new PlayerText:CashforDM[MAX_PLAYERS];

//---------------------------
// Vehicle Config
//---------------------------
#define MAXIMAL_PLAYERS 500
#define DIALOG_VEHICLES 0
#define DIALOG_VEHICLES_AIRPLANES 11
#define DIALOG_VEHICLES_HELICOPTERS 22
#define DIALOG_VEHICLES_BIKES 33
#define DIALOG_VEHICLES_CONVERTIBLES 44
#define DIALOG_VEHICLES_INDUSTRIAL 55
#define DIALOG_VEHICLES_LOWRIDERS 66
#define DIALOG_VEHICLES_OFF_ROAD 77
#define DIALOG_VEHICLES_PUBLIC_SERVICE_VEHICLES 88
#define DIALOG_VEHICLES_SALOONS 99
#define DIALOG_VEHICLES_SPORT_VEHICLES 100
#define DIALOG_VEHICLES_STATION_WAGONS 110
#define DIALOG_VEHICLES_BOATS 120
#define DIALOG_VEHICLES_TRAILERS 130
#define DIALOG_VEHICLES_UNIQUE_VEHICLES 140
#define DIALOG_VEHICLES_RC_VEHICLES 150
#define DIALOG_VEHICLES_MODERNIZATION 160
#define COLOR_WHITE 0xFFFFFFFF
#define C_WHITE "{FFFFFF}"
#define C_GREEN "{00FF00}"
#define C_RED "{FF0000}"
#define white            \"{FFFFFF}\"
#define orange           \"{F2C80C}\"

new protection[MAX_PLAYERS];
//---------------------------------------
// Forwards
//---------------------------------------
forward parsePlayerBank( playerid, name[ ], value[ ] );
public parsePlayerBank( playerid, name[ ], value[ ] ) {
	INI_Int( "bankMoney", bankMoney[ playerid ] );
	return true;
}
//---------------------------------------

main()
{
	print("\n-------------------------------");
	print("TBS - Official | By: George and Filip | Build: 16 | y_ini + dini");
	print("--------------------------------\n");
}

enum Cps {
	cp
}

enum VehID
{
        VehId
}
new Veh[MAX_PLAYERS][VehID];

new PlayerVehicle[MAX_PLAYERS][MAX_PLAYERVEHICLES];

enum pInfo
{
	AltName[26],
	RegOn[20],
	Spawned,
	LoginFail,
	LoggedIn,
	Goto,
	isAFK,
	inDM,
	inMini,
	inDMZone,
	inDerby,
	Float:POS_X,
	Float:POS_Y,
	Float:POS_Z,
	Skin,
	Color,
	pCar,
	GodEnabled,
	WeaponSet,
	Helmet,
	RecentlyRobbed,
	Jailed,
    Arrests,
   	Zone[ 100 ],
    EnterCP,
    Takedowns,
    Robberies,
    PlayerRobberies,
    CopsKilled,
    InCNR,
    BreakCuffs,
    Timearrested,
    INMG,
    ShopRobbed[ 100 ],
	ActionID,
	aMember,
	aLeader,
	Rank,
	pSkin,
	Races,
	Target,
	HaveTarget,
	TargetPrice,
	HaveVictim,
	NameVictim[24],
	NameTarget[24],
	WantedLevel,
}
new PlayerInfo[MAX_PLAYERS][pInfo];

enum poInfo
{
	Float:GX,
	Float:GY,
	Float:GZ,
	Float:GX1,
	Float:GY1,
	Float:GZ1,
	Float:GX2,
	Float:GY2,
	Float:GZ2,
	Float:GX3,
	Float:GY3,
	Float:GZ3,
	Float:GX4,
	Float:GY4,
	Float:GZ4,
}
new FireInfo[MAX_FIRE][poInfo];

enum orInfo
{
    Float:uX,
    Float:uY,
   	Float:uZ,
   	Float:iX,
    Float:iY,
   	Float:iZ,
   	Float:sX,
    Float:sY,
   	Float:sZ,
   	Float:LokX,
    Float:LokY,
   	Float:LokZ,
   	Float:orX,
    Float:orY,
   	Float:orZ,
   	Float:puX,
    Float:puY,
   	Float:puZ,
   	Float:arX,
    Float:arY,
   	Float:arZ,
   	Float:duX,
    Float:duY,
   	Float:duZ,
   	Name[128],
   	Rank1[128],
   	Rank2[128],
   	Rank3[128],
   	Rank4[128],
   	Rank5[128],
   	Rank6[128],
   	Int,
   	VW,
	rSkin1,
	rSkin2,
	rSkin3,
	rSkin4,
	rSkin5,
	rSkin6,
	AllowedF,
	AllowedR,
	AllowedD,
	AllowedH,
	AllowedPD,
    AllowedFD
}
//new FireT;
new Fire=0;
//new Fireid=-1;
new FireNumber=0;
new CP[MAX_PLAYERS];
new rank[MAX_PLAYERS];
new orga[MAX_PLAYERS]=-1;
new poz[MAX_PLAYERS]=-1;
new GangInfo[MAX_GANG][orInfo];
new GangPickup[sizeof(GangInfo)];
new GangPickup2[sizeof(GangInfo)];
new PDWeapons[sizeof(GangInfo)];
new Arrest[sizeof(GangInfo)];
new Text3D:GangLabel[sizeof(GangInfo)];
new Aparat[sizeof(GangInfo)];
new Text3D:AparatLabel[sizeof(GangInfo)];
new Member[12][15][MAX_PLAYER_NAME];
new Leader[2][15][MAX_PLAYER_NAME];
new VehiclesID[MAX_GANG][15];
new VehiclesColor[MAX_GANG][15];
new vCreated[MAX_GANG][15];
new GVehID[MAX_GANG][15];
new Float:Vehicle[MAX_GANG][4][15];
new Tazan[MAX_PLAYERS];
new EmptyTaser[MAX_PLAYERS];
new PlacedRadar[MAX_PLAYERS];
new PriceRadar[MAX_PLAYERS];
new SpeedRadar[MAX_PLAYERS];
new RadarObject[MAX_PLAYERS];
new Text3D:RadarLabel[MAX_PLAYERS];
new Pictured[MAX_PLAYERS];
new TicketWrote[MAX_PLAYERS];
new TicketPrice[MAX_PLAYERS];
new GJailTime[MAX_PLAYERS];
new GJailed[MAX_PLAYERS];
new Text3D:ArrestLabel[sizeof(GangInfo)];
new Pick[MAX_PLAYERS];
new Pic[MAX_PLAYERS];
//new FireO[5];

new
	gsString[ 2048 ],
	gsBigString[ 2096 ]
;

forward scoretimer();
public scoretimer()
{
	for (new i; i < MAX_PLAYERS; i++)
	{
	    if (!IsPlayerConnected(i)) continue;
	    seconds[i]++;
	    if (seconds[i] == 300)
	    {
	        SetPlayerScore(i, GetPlayerScore(i) + 2);
	        seconds[i] = 0;
		}
	}
	return 1;
}

#define FormatMSG(%0,%1,%2,%3)\
		do{\
		    gsBigString[0]=EOS;\
			format(gsBigString, sizeof(gsBigString), (%2), %3);\
			SendClientMessage((%0),(%1), gsBigString);\
		}\
		while(False)

#define WHITE_  "{FFFFFF}"
#define RED_  "{E62525}"
#define BROWN_  "{A52A2A}"
#define GREY_  "{808080}"
#define LIGHTRED_ "{FF975E}"
#define JOBINFO_ "{C8F1FA}"
#define BLUE_ "{004BFF}"
#define LBLUE_ "{00FFFF}"
#define DARK_ORANGE	"{C03A00}"
#define ORANGE_ "{FF9200}"
#define BLUE2_ "{001F6A}"
#define PURPLE_ "{B50D61}"
#define SKIN_ "{FFA863}"
#define SKIN2_ "{B77259}"
#define LIGHTYELLOW_ "{FFFF6D}"
#define PINK_ "{EB1CC1}"
#define WOOD_ "{8B5A2B}"
#define GREENBLUE_ "{1FC4A6}"
#define GREEN_ "{00FF00}"
#define GRAY_ "{BEBEBE}"
#define LIGHTBLUE_ "{00E5EE}"
#define DARKBLUE_ "{0040FF}"
#define BLACK_ "{7A7A7A}"
#define AdminInfo_ "{00D799}"
#define RACE_ "{46E01B}"
#define COLOR_ULTRARED 										(0xFF0000FF)
#define HOLDING(%0) \
((newkeys & (%0)) == (%0))

#define RELEASED(%0) \
(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

#define PRESSED(%0) \
(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define PRESSED(%0) \
    (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define IsPlayerNotInVehicle(%0) (!IsPlayerInAnyVehicle(%0))

#define HOLDING(%0) \
    ((newkeys & (%0)) == (%0))

#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

forward Float:GetPosInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance);

forward RandomMessages();
public RandomMessages()
{
    new randomMsg = random(sizeof(randomMessages));
    SendClientMessageToAll(-1, randomMessages[randomMsg]);
}

new
	Store1,								//Bank
	Store2,								Store2Exit,//Calgius
	Store3,								Store3Exit,//4 Dragon
	Store4,								Store4Exit,//Red Sands Casino
	Store5,								//Royal Casino
	Store6,								Store6Exit,//Binco
	Store7,                             //Binco
	Store8,                             //Bank
	Store9,                             Store9Exit,//Ammunation
	Store10,							//Ammunation
	Store11, 						    Store11Exit,//Cluckin Bell
	Store12,                            Store12Exit,//Pizza
	Store13,                            Store13Exit,//Burger Shop
	Store14,                            //Burger Shop
	Store15,                            //Burger Shop
	Store16,                            //Burger Shop
	Store17,                            Store17Exit,//24/7 Shop
	Store18,                            //24/7 Shop
	Store19,                            //24/7 Shop
	Store20,                            //24/7 Shop
	Store21,                            //Cluckin Bell Shop
	Store22                             //Pizza Shop
;

forward TDmsg();
public TDmsg()
{
    TextDrawSetString(InfoTD, InfoTD_MSG[random(sizeof(InfoTD_MSG))]);
}

new cTDcolor;
new cTDcolor2;
new cWEBcolor;
new cWEBcolor2;

forward ChangeTDcolor();
public ChangeTDcolor()
{
	TextDrawSetString(T, "~y~T");
	TextDrawSetString(BS, "~r~BS");
	cTDcolor2 = SetTimer("ChangeTDcolor2", 2000, false);
}

forward ShowGangs(playerid);
public ShowGangs(playerid)
{
	new showit3[800], org, oFile[50];
	format(oFile, sizeof(oFile), GANGS, org);
	format(showit3, sizeof(showit3), "%s (Leader: %s)\n", GangInfo[org][Name], GangInfo[org][Rank6]);
	ShowPlayerDialog(playerid, aselect, DIALOG_STYLE_LIST, "Select a Gang", showit3, "Select", "Cancel");
	return 1;
}

forward ChangeTDcolor2();
public ChangeTDcolor2()
{
	TextDrawSetString(T, "~r~T");
	TextDrawSetString(BS, "~g~BS");
	cTDcolor = SetTimer("ChangeTDcolor", 2000, false);
}

forward ChangeWEBcolor();
public ChangeWEBcolor()
{
	TextDrawSetString(web, "~b~TBS-OFFICIAL.~g~EU");
	cWEBcolor2 = SetTimer("ChangeWEBcolor2", 2000, false);
}

forward ChangeWEBcolor2();
public ChangeWEBcolor2()
{
	TextDrawSetString(web, "~r~TBS-OFFICIAL.~g~EU");
	cWEBcolor = SetTimer("ChangeWEBcolor", 2000, false);
}

forward HealReal(playerid);
public HealReal(playerid)
{
    HealTimer[playerid] = 0;
    SendClientMessage(playerid,0x42CC33C8, "Now you can use the command /heal again.");
    return 1;
}

public Updater()
{
	new hour,minute;
	gettime(hour,minute);
	SetWorldTime(hour);
	if(random(5) != 1) return 0;//The current chance to update weather is 1/5
	if(7 < hour < 17) return WeatherUpdateDay();//8 - 16 is Day time
	WeatherUpdateNight();
	return 1;
}

public OnGameModeInit()
{
	SetGameModeText("Stunt/DM/Drift/Freeroam/Race/Fun/CnR");
	SendRconCommand("hostname "HOSTNAME_1"");
    SendRconCommand("language English/Balkan/Bulgarian/Russian/Arabic/Spanish/All");
	SendRconCommand("loadfs ladmin");
	SendRconCommand("loadfs TBSMaps");
	SendRconCommand("loadfs OtherMap");

    SetTimer("VehicleSpawnLimiter", 1000, true);
    SetTimer("GateCheck", 800, true);
   	//Create gates
	for(new i=0, all=sizeof(gates); i<all; i++)
    {
        gates[i][ag_id] = CreateObject(980, gates[i][ag_closePos][0], gates[i][ag_closePos][1], gates[i][ag_closePos][2], gates[i][ag_closePos][3], gates[i][ag_closePos][4], gates[i][ag_closePos][5]);
    }
	for(new x=0; x<MAX_INVITES; x++) ResetDuelInvites(x);
    INI_Load("/House/House.ini");
    LoadHouses();
    foreach(Player, i)
    {
        SetPVarInt(i, "HousePrevTime", 0);
        SetPVarInt(i, "TimeSinceHouseRobbery", 0);
    	SetPVarInt(i, "TimeSinceHouseBreakin", 0);
        SetPVarInt(i, "HouseRobberyTimer", -1);
    }
	print("Dynamic Gang System - Loaded");

	//SetTimer("CreateFire",600000,1);
	//SetTimer("ExtinguisheFire",1800, 1);

	new AntiDeathSpamTimer = Clock *1000;
	AntiDeathSpamTime = SetTimer("AntiDeathSpam",AntiDeathSpamTimer,1);

    VCannon = CreatePickup(19605, 14, 2059.85, 1752.76, 124.49);

	for(new i = 0; i < sizeof(FireInfo); i++)
	{
		new oFile[50];
        format(oFile, sizeof(oFile), FIRE, i);
        if(fexist(oFile))
        {
            INI_ParseFile(oFile, "LoadFire", .bExtra = true, .extra = i);
	    }
	}
	for(new i = 0; i < sizeof(GangInfo); i++)
	{
		new oFile[50];
        format(oFile, sizeof(oFile), GANGS, i);
        if(fexist(oFile))
        {
            INI_ParseFile(oFile, "LoadGangs", .bExtra = true, .extra = i);
			if(vCreated[i][0] == 1)
			{
            	GVehID[i][0] = CreateVehicle(VehiclesID[i][0],Vehicle[i][0][0],Vehicle[i][1][0],Vehicle[i][2][0],Vehicle[i][3][0],VehiclesColor[i][0],VehiclesColor[i][0],30000);
            }
            if(vCreated[i][1] == 1)
			{
            	GVehID[i][1] = CreateVehicle(VehiclesID[i][1],Vehicle[i][0][1],Vehicle[i][1][1],Vehicle[i][2][1],Vehicle[i][3][1],VehiclesColor[i][1],VehiclesColor[i][1],30000);
            }
            if(vCreated[i][2] == 1)
			{
            	GVehID[i][2] = CreateVehicle(VehiclesID[i][2],Vehicle[i][0][2],Vehicle[i][1][2],Vehicle[i][2][2],Vehicle[i][3][2],VehiclesColor[i][2],VehiclesColor[i][2],30000);
            }
            if(vCreated[i][3] == 1)
			{
            	GVehID[i][3] = CreateVehicle(VehiclesID[i][3],Vehicle[i][0][3],Vehicle[i][1][3],Vehicle[i][2][3],Vehicle[i][3][3],VehiclesColor[i][3],VehiclesColor[i][3],30000);
            }
            if(vCreated[i][4] == 1)
			{
            	GVehID[i][4] = CreateVehicle(VehiclesID[i][4],Vehicle[i][0][4],Vehicle[i][1][4],Vehicle[i][2][4],Vehicle[i][3][4],VehiclesColor[i][4],VehiclesColor[i][4],30000);
            }
            if(vCreated[i][5] == 1)
			{
            	GVehID[i][5] = CreateVehicle(VehiclesID[i][5],Vehicle[i][0][5],Vehicle[i][1][5],Vehicle[i][2][5],Vehicle[i][3][5],VehiclesColor[i][5],VehiclesColor[i][5],30000);
            }
            if(vCreated[i][6] == 1)
			{
            	GVehID[i][6] = CreateVehicle(VehiclesID[i][6],Vehicle[i][0][6],Vehicle[i][1][6],Vehicle[i][2][6],Vehicle[i][3][6],VehiclesColor[i][6],VehiclesColor[i][6],30000);
            }
            if(vCreated[i][7] == 1)
			{
            	GVehID[i][7] = CreateVehicle(VehiclesID[i][7],Vehicle[i][0][7],Vehicle[i][1][7],Vehicle[i][2][7],Vehicle[i][3][7],VehiclesColor[i][7],VehiclesColor[i][7],30000);
            }
            if(vCreated[i][8] == 1)
			{
            	GVehID[i][8] = CreateVehicle(VehiclesID[i][8],Vehicle[i][0][8],Vehicle[i][1][8],Vehicle[i][2][8],Vehicle[i][3][8],VehiclesColor[i][8],VehiclesColor[i][8],30000);
            }
            if(vCreated[i][9] == 1)
			{
            	GVehID[i][9] = CreateVehicle(VehiclesID[i][9],Vehicle[i][0][9],Vehicle[i][1][9],Vehicle[i][2][9],Vehicle[i][3][9],VehiclesColor[i][9],VehiclesColor[i][9],30000);
            }
            if(vCreated[i][10] == 1)
			{
            	GVehID[i][10] = CreateVehicle(VehiclesID[i][10],Vehicle[i][0][10],Vehicle[i][1][10],Vehicle[i][2][10],Vehicle[i][3][10],VehiclesColor[i][10],VehiclesColor[i][10],30000);
            }
            if(vCreated[i][11] == 1)
			{
            	GVehID[i][11] = CreateVehicle(VehiclesID[i][11],Vehicle[i][0][11],Vehicle[i][1][11],Vehicle[i][2][11],Vehicle[i][3][11],VehiclesColor[i][11],VehiclesColor[i][11],30000);
            }
            if(vCreated[i][12] == 1)
			{
            	GVehID[i][12] = CreateVehicle(VehiclesID[i][12],Vehicle[i][0][12],Vehicle[i][1][12],Vehicle[i][2][12],Vehicle[i][3][12],VehiclesColor[i][12],VehiclesColor[i][12],30000);
            }
            if(vCreated[i][13] == 1)
			{
            	GVehID[i][13] = CreateVehicle(VehiclesID[i][13],Vehicle[i][0][13],Vehicle[i][1][13],Vehicle[i][2][13],Vehicle[i][3][13],VehiclesColor[i][13],VehiclesColor[i][13],30000);
            }
            if(vCreated[i][14] == 1)
			{
            	GVehID[i][14] = CreateVehicle(VehiclesID[i][14],Vehicle[i][0][14],Vehicle[i][1][14],Vehicle[i][2][14],Vehicle[i][3][14],VehiclesColor[i][14],VehiclesColor[i][14],30000);
            }
            new string[128];
            GangPickup[i] = CreateDynamicPickup(1272, 1, GangInfo[i][uX], GangInfo[i][uY], GangInfo[i][uZ]);
    		format(string,sizeof(string),"[ %s ]",GangInfo[i][Name]);
    		GangLabel[i] = CreateDynamic3DTextLabel(string,0x660066BB,GangInfo[i][uX],GangInfo[i][uY],GangInfo[i][uZ], 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
    		GangPickup2[i] = CreateDynamicPickup(1272, 1, GangInfo[i][iX], GangInfo[i][iY], GangInfo[i][iZ]);
    		PDWeapons[i] = CreatePickup(355, 1, GangInfo[i][orX],GangInfo[i][orY],GangInfo[i][orZ], 0);
    		Arrest[i] = CreateDynamicPickup(1314, 1, GangInfo[i][puX],GangInfo[i][puY],GangInfo[i][puZ], 0);
		    ArrestLabel[i] = CreateDynamic3DTextLabel("{FF9900}Place for arrest {FF3300}[{FFFFFF}/arrest{FF3300}]",-1,GangInfo[i][puX],GangInfo[i][puY],GangInfo[i][puZ], 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
		    Aparat[i] = CreateDynamicPickup(1239, 1, GangInfo[i][duX],GangInfo[i][duY],GangInfo[i][duZ], 0);
		    AparatLabel[i] = CreateDynamic3DTextLabel("{FF9900}Place for pickup fire extinguisher {FF3300}[{FFFFFF}/fireext{FF3300}]",-1,GangInfo[i][duX],GangInfo[i][duY],GangInfo[i][duZ], 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
		}
	}
	for(new i=0;i<MAX_PLAYERS;i++)
	{
		if(IsPlayerConnected(i))
		{
			PlayerInfo[i][aMember] = -1;
		    PlayerInfo[i][aLeader] = -1;
		    Tazan[i] = 0;
		    new str[128]; format(str,sizeof(str),"Gangs/Users/%s",GetName(i));
		    if(fexist(str))
		    {
		  	    INI_ParseFile(str, "LoadPlayer_%s", .bExtra = true, .extra = i);
		    }
	    }
    }
	BusinessTime_Load();
	for (new BusID = 1; BusID < MAX_BUSINESS; BusID++)
	BusinessFile_Load(BusID);
	SetTimer("Business_TransactionTimer", 1000 * 60, true);
	SetTimer("AntiCheat", 1000*1,true); //At least at 1sec
    printf("-------------------------------------");
    printf("Businesses loaded: %i", TotalBusiness);
    printf("-------------------------------------");

	CreateVehicle(580, 290.5502, -1150.6394, 80.5961, -138.0000, -1, -1, 100);
    CreateVehicle(411, 307.4842, -1162.2855, 80.6290, -178.0000, -1, -1, 100);
    CreateVehicle(405, 295.5508, -1151.8555, 80.7105, 185.0000, -1, -1, 100);

	Updater();
    timer = SetTimer("Updater",1000*60*60*60*3,1);

	ServerInfo[ConnectMessages] = 1;

	SetWorldTime(12);
	UsePlayerPedAnims();

	LoadVehicles();

	new time[10], date[10], h, m, s, y, mon, day;
	gettime(h, m, s);
	getdate(y, mon, day);
	format(time, sizeof(time), "%d:%d:%d", h, m, s);
	format(date, sizeof(date), "%d/%d/%d", day, mon, y);
 	new INI:FILE_SERVER_STATS = INI_Open(ServerStats);
  	INI_SetTag(FILE_SERVER_STATS, "Server_Statistics");
	INI_WriteString(FILE_SERVER_STATS, "Last_Restarted_Time", time);
	INI_WriteString(FILE_SERVER_STATS, "Last_Restarted_Date", date);
	INI_Close(FILE_SERVER_STATS);

	INI_ParseFile(ServerStats, "loadserverstats", .bExtra = false);
	ScoreTimer = SetTimer("scoretimer", 1000, true);
	FixTimer = SetTimer("FixAllCar",1000,true);
	SetTimer("RandomMessages", 100000, true);
	SetTimer("DMcountUpdate", 1000, true);
	SetTimer("TDmsg",8000,true);
	cTDcolor = SetTimer("ChangeTDcolor", 2000, false);
	cWEBcolor = SetTimer("ChangeWEBcolor", 2000, false);

    gTextDraw[1] = TextDrawCreate(231.917984, 415.333343, "~y~Stunt~w~/~b~DM~w~/~g~Drift~w~/~g~Freeroam~w~/~r~Race~w~/~p~Fun~w~/~y~CnR~w~");
	TextDrawLetterSize(gTextDraw[1], 0.272498, 1.662222);
	TextDrawAlignment(gTextDraw[1], 1);
	TextDrawColor(gTextDraw[1], -1);
	TextDrawSetShadow(gTextDraw[1], 0);
	TextDrawSetOutline(gTextDraw[1], 1);
	TextDrawBackgroundColor(gTextDraw[1], 51);
	TextDrawFont(gTextDraw[1], 1);
	TextDrawSetProportional(gTextDraw[1], 1);

	gTextDraw[2] = TextDrawCreate(476.612548, 401.083282, "usebox");
	TextDrawLetterSize(gTextDraw[2], 0.000000, 1.512964);
	TextDrawTextSize(gTextDraw[2], 146.052703, 0.000000);
	TextDrawAlignment(gTextDraw[2], 1);
	TextDrawColor(gTextDraw[2], 0);
	TextDrawUseBox(gTextDraw[2], true);
	TextDrawBoxColor(gTextDraw[2], 102);
	TextDrawSetShadow(gTextDraw[2], 0);
	TextDrawSetOutline(gTextDraw[2], 0);
	TextDrawFont(gTextDraw[2], 0);

    gTextDraw[3] = TextDrawCreate(140.395309, 433.416717, "~w~/FDM: ~r~0    ~w~/WAR: ~r~0   ~w~/MINI: ~r~0   ~w~/WAR: ~r~0   ~w~/RDM: ~r~0   ~w~/SAWNDM: ~r~0   ~w~/ODM: ~r~0");
	TextDrawLetterSize(gTextDraw[3], 0.229858, 1.347221);
	TextDrawAlignment(gTextDraw[3], 1);
	TextDrawColor(gTextDraw[3], -1);
	TextDrawSetShadow(gTextDraw[3], 0);
	TextDrawSetOutline(gTextDraw[3], 1);
	TextDrawBackgroundColor(gTextDraw[3], 51);
	TextDrawFont(gTextDraw[3], 1);
	TextDrawSetProportional(gTextDraw[3], 1);

	gTextDraw[4] = TextDrawCreate(475.674957, 434.916717, "usebox");
	TextDrawLetterSize(gTextDraw[4], 0.000000, 1.134259);
	TextDrawTextSize(gTextDraw[4], 146.521224, 0.000000);
	TextDrawAlignment(gTextDraw[4], 1);
	TextDrawColor(gTextDraw[4], 0);
	TextDrawUseBox(gTextDraw[4], true);
	TextDrawBoxColor(gTextDraw[4], 102);
	TextDrawSetShadow(gTextDraw[4], 0);
	TextDrawSetOutline(gTextDraw[4], 0);
	TextDrawFont(gTextDraw[4], 0);

	web = TextDrawCreate(530.000000, 1.866636, "~r~TBS-OFFICIAL.~g~EU");
	TextDrawBackgroundColor(web, 16777215);
	TextDrawFont(web, 1);
	TextDrawLetterSize(web, 0.330000, 1.299999);
	TextDrawColor(web, 255);
	TextDrawSetOutline(web, 1);
	TextDrawSetProportional(web, 1);

	InfoTD = TextDrawCreate(149.926818, 400.166625, "Don't forget to try our best maps at /lva!");
	TextDrawLetterSize(InfoTD, 0.272498, 1.662222);
	TextDrawAlignment(InfoTD, 1);
	TextDrawColor(InfoTD, -1);
	TextDrawSetShadow(InfoTD, 0);
	TextDrawSetOutline(InfoTD, 1);
	TextDrawBackgroundColor(InfoTD, 51);
	TextDrawFont(InfoTD, 1);
	TextDrawSetProportional(InfoTD, 1);

	T = TextDrawCreate(6.000000, 420.311218, "T");
	TextDrawLetterSize(T, 0.661500, 2.390223);
	TextDrawAlignment(T, 1);
    TextDrawBackgroundColor(T, 16777215);
	TextDrawColor(T, 255);
	TextDrawSetShadow(T, 0);
	TextDrawSetOutline(T, 1);
	TextDrawBackgroundColor(T, 51);
	TextDrawFont(T, 3);
	TextDrawSetProportional(T, 1);

	BS = TextDrawCreate(20.500000, 420.688934, "BS");
	TextDrawLetterSize(BS, 0.671500, 2.440000);
	TextDrawAlignment(BS, 1);
    TextDrawBackgroundColor(BS, 16777215);
	TextDrawColor(BS, 255);
	TextDrawSetShadow(BS, 0);
	TextDrawSetOutline(BS, 1);
	TextDrawBackgroundColor(BS, 51);
	TextDrawFont(BS, 3);
	TextDrawSetProportional(BS, 1);

	KillerTD0 = TextDrawCreate(660.000000, 1.000000, "                ");
	TextDrawBackgroundColor(KillerTD0, 255);
	TextDrawFont(KillerTD0, 1);
	TextDrawLetterSize(KillerTD0, 0.500000, 1.000000);
	TextDrawColor(KillerTD0, -1);
	TextDrawSetOutline(KillerTD0, 0);
	TextDrawSetProportional(KillerTD0, 1);
	TextDrawSetShadow(KillerTD0, 1);
	TextDrawUseBox(KillerTD0, 1);
	TextDrawBoxColor(KillerTD0, 255);
	TextDrawTextSize(KillerTD0, -5.000000, 64.000000);
	TextDrawSetSelectable(KillerTD0, 0);

	KillerTD1 = TextDrawCreate(250.000000, 77.000000, "~r~CnR");
	TextDrawBackgroundColor(KillerTD1, 255);
	TextDrawFont(KillerTD1, 0);
	TextDrawLetterSize(KillerTD1, 0.500000, 2.000000);
	TextDrawColor(KillerTD1, -1);
	TextDrawSetOutline(KillerTD1, 0);
	TextDrawSetProportional(KillerTD1, 1);
	TextDrawSetShadow(KillerTD1, 1);
	TextDrawSetSelectable(KillerTD1, 0);

	KillerTD2 = TextDrawCreate(280.000000, 90.000000, "Killcam");
	TextDrawBackgroundColor(KillerTD2, 255);
	TextDrawFont(KillerTD2, 1);
	TextDrawLetterSize(KillerTD2, 0.529999, 2.000000);
	TextDrawColor(KillerTD2, -1);
	TextDrawSetOutline(KillerTD2, 0);
	TextDrawSetProportional(KillerTD2, 1);
	TextDrawSetShadow(KillerTD2, 1);
	TextDrawSetSelectable(KillerTD2, 0);

	KillerTD3 = TextDrawCreate(661.000000, 340.000000, "                  ");
	TextDrawBackgroundColor(KillerTD3, 255);
	TextDrawFont(KillerTD3, 1);
	TextDrawLetterSize(KillerTD3, 0.500000, 1.000000);
	TextDrawColor(KillerTD3, -1);
	TextDrawSetOutline(KillerTD3, 0);
	TextDrawSetProportional(KillerTD3, 1);
	TextDrawSetShadow(KillerTD3, 1);
	TextDrawUseBox(KillerTD3, 1);
	TextDrawBoxColor(KillerTD3, 255);
	TextDrawTextSize(KillerTD3, -26.000000, 0.000000);
	TextDrawSetSelectable(KillerTD3, 0);

	KillerTD4 = TextDrawCreate(10.000000, 348.000000, "~g~PLAYER: ~w~: VK Khaber");
	TextDrawBackgroundColor(KillerTD4, 255);
	TextDrawFont(KillerTD4, 2);
	TextDrawLetterSize(KillerTD4, 0.400000, 1.000000);
	TextDrawColor(KillerTD4, -1);
	TextDrawSetOutline(KillerTD4, 0);
	TextDrawSetProportional(KillerTD4, 1);
	TextDrawSetShadow(KillerTD4, 1);
	TextDrawSetSelectable(KillerTD4, 0);

	KillerTD5 = TextDrawCreate(10.000000, 366.000000, "~r~HEALTH ~w~:100%");
	TextDrawBackgroundColor(KillerTD5, 255);
	TextDrawFont(KillerTD5, 2);
	TextDrawLetterSize(KillerTD5, 0.500000, 1.000000);
	TextDrawColor(KillerTD5, -1);
	TextDrawSetOutline(KillerTD5, 0);
	TextDrawSetProportional(KillerTD5, 1);
	TextDrawSetShadow(KillerTD5, 1);
	TextDrawSetSelectable(KillerTD5, 0);

	KillerTD6 = TextDrawCreate(490.000000, 366.000000, "~r~ARMOUR ~w~:0%");
	TextDrawBackgroundColor(KillerTD6, 255);
	TextDrawFont(KillerTD6, 2);
	TextDrawLetterSize(KillerTD6, 0.500000, 1.000000);
	TextDrawColor(KillerTD6, -1);
	TextDrawSetOutline(KillerTD6, 0);
	TextDrawSetProportional(KillerTD6, 1);
	TextDrawSetShadow(KillerTD6, 1);
	TextDrawSetSelectable(KillerTD6, 0);

	KillerTD7 = TextDrawCreate(506.000000, 347.000000, "~r~Killsteak ~w~: 0");
	TextDrawBackgroundColor(KillerTD7, 255);
	TextDrawFont(KillerTD7, 2);
	TextDrawLetterSize(KillerTD7, 0.460000, 1.199999);
	TextDrawColor(KillerTD7, -1);
	TextDrawSetOutline(KillerTD7, 0);
	TextDrawSetProportional(KillerTD7, 1);
	TextDrawSetShadow(KillerTD7, 1);
	TextDrawSetSelectable(KillerTD7, 0);

	KillerTD8 = TextDrawCreate(210.000000, 380.000000, "You will respawn in ~y~15 ~w~Seconds.");
	TextDrawBackgroundColor(KillerTD8, 255);
	TextDrawFont(KillerTD8, 1);
	TextDrawLetterSize(KillerTD8, 0.460000, 1.100000);
	TextDrawColor(KillerTD8, -1);
	TextDrawSetOutline(KillerTD8, 0);
	TextDrawSetProportional(KillerTD8, 1);
	TextDrawSetShadow(KillerTD8, 1);
	TextDrawSetSelectable(KillerTD8, 0);

	KillerTD9 = TextDrawCreate(210.000000, 400.000000, "Press the fire  key to respawn at anytime.");
	TextDrawBackgroundColor(KillerTD9, 255);
	TextDrawFont(KillerTD9, 1);
	TextDrawLetterSize(KillerTD9, 0.370000, 1.299999);
	TextDrawColor(KillerTD9, -1);
	TextDrawSetOutline(KillerTD9, 0);
	TextDrawSetProportional(KillerTD9, 1);
	TextDrawSetShadow(KillerTD9, 1);
	TextDrawSetSelectable(KillerTD9, 0);

    RobTD = TextDrawCreate(202.000000, 188.000000, "~b~ROBBERY IN PROGRESS ~nl~~w~STAY IN THE STORE ~nl~~r~25 ~w~SECONDS LEFT.");
    TextDrawFont(RobTD, 2);
    TextDrawLetterSize(RobTD, 0.529999, 2.599999);
    TextDrawColor(RobTD, -1);
    TextDrawSetOutline(RobTD, 1);
    TextDrawSetProportional(RobTD, 1);
    TextDrawSetSelectable(RobTD, 0);
    TextDrawBackgroundColor(RobTD, 255);

    CREATE3D();
	SetTimer("RobbersPro",1000,true);
 	SetTimer("Update", 1000, true);
	SetTimer("Zones_Update", 500, 1);
	//Stores
 	Store1= CreateDynamicCP( 2270.8896,2292.0337,10.8203,2.0,-1,-1); // Bank CP
	Store2= CreateDynamicCP( 2196.8003,1677.1257,12.3672,2.0,-1,-1); // Calguis
	Store2Exit= CreateDynamicCP( 2234.1506,1714.3947,1012.3828,2.0,-1,-1);//Calguis Exit
	Store3= CreateDynamicCP( 2019.5112,1007.6406,10.8203,2.0,-1,-1);//4 Dragon
	Store3Exit= CreateDynamicCP( 2018.6523,1017.6573,996.8750,2.0,-1,-1);//4 Dragon Exit
	Store4= CreateDynamicCP( 2167.4512,2115.5269,10.8203,2.0,-1,-1);//Redsand Casino
	Store4Exit= CreateDynamicCP(1133.2821,-14.4744,1000.6797,2.0,-1,-1);//Redsand Casino
	Store5= CreateDynamicCP( 2090.0652,1514.6912,10.8203,2.0,-1,-1);//Royal Casino
    Store6= CreateDynamicCP( 2103.1604,2257.4949,11.0234,2.0,-1,-1);//Binco Shop
    Store6Exit= CreateDynamicCP( 207.7650,-111.0889,1005.1328,2.0,-1,-1);//Binco Shop Exit
    Store7= CreateDynamicCP( 1655.3794,1733.4390,10.8281,2.0,-1,-1);//Binco Shop
    Store8= CreateDynamicCP( 2354.9150,1543.8160,10.8203,2.0,-1,-1); // Bank CP
    Store9= CreateDynamicCP( 2158.7559,943.2726,10.8203,2.0,-1,-1); // Ammunation CP
    Store9Exit= CreateDynamicCP( 286.1490,-40.6444,1001.5156,2.0,-1,-1);//Ammunation Shop Exit
    Store10= CreateDynamicCP( 2537.9285,2083.9502,10.8203,2.0,-1,-1); // Ammunation CP
    Store11= CreateDynamicCP( 2638.4160,1671.6783,11.0234,2.0,-1,-1);// Cluckin Bell CP
    Store11Exit= CreateDynamicCP( 365.1504,-11.4891,1001.8516,2.0,-1,-1);// Cluckin Bell CP Exit
    Store12= CreateDynamicCP( 2638.4282,1850.0570,11.0234,2.0,-1,-1);// Pizza CP
    Store12Exit= CreateDynamicCP( 372.3458,-133.5157,1001.4922,2.0,-1,-1);// Pizza CP Exit
    Store13= CreateDynamicCP( 2170.3120,2794.9949,10.8203,2.0,-1,-1);// Burger CP
    Store13Exit= CreateDynamicCP( 362.7684,-75.0646,1001.5078,2.0,-1,-1);// Burger CP Exit
    Store14= CreateDynamicCP( 2472.1184,2034.2938,11.0625,2.0,-1,-1);// Burger CP
    Store15= CreateDynamicCP( 2365.7756,2071.0264,10.8203,2.0,-1,-1);// Burger CP
    Store16= CreateDynamicCP( 1158.5654,2072.2627,11.0625,2.0,-1,-1);// Burger CP
    Store17= CreateDynamicCP( 2097.5088,2223.6741,11.0234,2.0,-1,-1);// 24/7 CP
	Store17Exit= CreateDynamicCP( -27.2616,-58.2641,1003.5469,2.0,-1,-1);// 24/7 CP Exit
	Store18= CreateDynamicCP( 1937.2565,2307.3269,10.8203,2.0,-1,-1);// 24/7 CP
    Store19= CreateDynamicCP( 2194.0891,1991.0579,12.2969,2.0,-1,-1);// 24/7 CP
    Store20= CreateDynamicCP( 2884.9958,2453.5703,11.0690,2.0,-1,-1);// 24/7 CP
    Store21= CreateDynamicCP( 2763.7302,2469.0498,11.0625,2.0,-1,-1);// Well Stacked Pizza CP
    Store22= CreateDynamicCP( 2846.1580,2415.1174,11.0690,2.0,-1,-1);// Cluckin Bell CP

	PoliceP= CreateDynamicCP( 2286.5427,2430.6497,10.8203,2.0,-1,-1);
	PoliceOP= CreateDynamicCP( 288.9210,167.1413,1007.1719,2.0,-1,-1);
	//============================= Create Map Icon ============================//
	CreateDynamicMapIcon( -1551.8900,1168.8789,7.1875, 52, -1,-1); // Server Bank
	CreateDynamicMapIcon( 2354.9150,1543.8160,10.8203, 52, -1,-1); // Bank Store 1
	CreateDynamicMapIcon( 2270.8896,2292.0337,10.8203, 52, -1,-1); // Bank Store 2
	CreateDynamicMapIcon( 2020.0339,1007.9818,10.8203, 25, -1,-1); //Casino
	CreateDynamicMapIcon( 2194.5830,1676.2454,12.3672, 25, -1,-1); //Casino
	CreateDynamicMapIcon( 2167.4512,2115.5269,10.8203, 25, -1,-1); //Casino
	CreateDynamicMapIcon( 2103.1604,2257.4949,11.0234, 45, -1,-1); //Binco
	CreateDynamicMapIcon( 1655.3794,1733.4390,10.8281, 45, -1,-1); //Binco
	CreateDynamicMapIcon( 2158.7559,943.2726,10.8203, 6, -1,-1); //Ammunation
	CreateDynamicMapIcon( 2537.9285,2083.9502,10.8203, 6, -1,-1); //Ammunation
	CreateDynamicMapIcon( 2636.3132,1670.7179,11.0234, 14, -1,-1);//Cluckin Bell
	CreateDynamicMapIcon( 2636.9695,1850.4019,11.0234, 29, -1,-1);//Well Stacked Pizza
	CreateDynamicMapIcon( 2170.3120,2794.9949,10.8203, 10, -1,-1); //Burger
	CreateDynamicMapIcon( 2472.1184,2034.2938,11.0625, 10, -1,-1); //Burger
	CreateDynamicMapIcon( 2365.7756,2071.0264,10.8203, 10, -1,-1); //Burger
	CreateDynamicMapIcon( 1158.5654,2072.2627,11.0625, 10, -1,-1); //Burger
	CreateDynamicMapIcon( 2097.5088,2223.6741,11.0234, 49, -1,-1); //24/7
	CreateDynamicMapIcon( 1937.2565,2307.3269,10.8203, 49, -1,-1); //24/7
	CreateDynamicMapIcon( 2194.0891,1991.0579,12.2969, 49, -1,-1); //24/7
	CreateDynamicMapIcon( 2884.9958,2453.5703,11.0690, 49, -1,-1); //24/7
	CreateDynamicMapIcon( 2763.7302,2469.0498,11.0625, 29, -1,-1);//Well Stacked Pizza
	CreateDynamicMapIcon( 2846.1580,2415.1174,11.0690, 14, -1,-1);//Cluckin Bell

	CreateDynamicMapIcon( 2225.6360,1838.6033,10.8203, 48, -1,-1);//Lv Club
	CreateDynamicMapIcon( 2295.2620,2460.0950,10.8203, 30, -1,-1);//Cops
	CreateDynamicMapIcon( 1634.2102,1554.5667,10.8083, 30, -1,-1);//Swat
	CreateDynamicMapIcon( 302.9118,2027.4635,17.6406, 30, -1,-1);//Army
	CreateDynamicMapIcon( 1322.9247,2672.7522,11.2392, 23, -1,-1);//Robber
	CreateDynamicMapIcon( 2817.1924,1282.4027,10.9609, 23, -1,-1); //Robber

    CarsCnr[ 0 ] = AddStaticVehicle(601, 2305.1479, 2424.9680, 10.5791, 150.9386, 1, 1);
	CarsCnr[ 1 ] = AddStaticVehicle(411,1622.6000000,1530.4000000,10.7000000,0.0000000,-1,-1); //Infernus
	CarsCnr[ 2 ] = AddStaticVehicle(411,1629.1000000,1529.9000000,10.7000000,0.0000000,-1,-1); //Infernus
	CarsCnr[ 3 ] = AddStaticVehicle(411,1635.6000000,1529.4000000,10.7000000,0.0000000,-1,-1); //Infernus
	CarsCnr[ 4 ] = AddStaticVehicle(411,1644.3000000,1528.8000000,10.7000000,0.0000000,-1,-1); //Infernus
	CarsCnr[ 5 ] = AddStaticVehicle(411,1652.3000000,1528.2000000,10.7000000,0.0000000,-1,-1); //Infernus
	CarsCnr[ 6 ] = AddStaticVehicle(522,1652.3000000,1538.4000000,10.4000000,0.0000000,-1,-1); //NRG-500
	CarsCnr[ 7 ] = AddStaticVehicle(522,1644.0000000,1538.0000000,10.4000000,0.0000000,-1,-1); //NRG-500
	CarsCnr[ 8 ] = AddStaticVehicle(522,1636.5000000,1537.6000000,10.4000000,0.0000000,-1,-1); //NRG-500
	CarsCnr[ 9 ] = AddStaticVehicle(522,1629.9000000,1537.4000000,10.4000000,0.0000000,-1,-1); //NRG-500
	CarsCnr[ 10 ] = AddStaticVehicle(522,1622.3000000,1537.3000000,10.4000000,0.0000000,-1,-1); //NRG-500
	CarsCnr[ 11 ] = AddStaticVehicle(497,1615.5000000,1531.3000000,11.1000000,0.0000000,-1,-1); //Police Maverick
	CarsCnr[ 12 ] = AddStaticVehicle(497,1656.7002000,1527.7002000,11.0000000,0.0000000,-1,-1); //Police Maverick
	CarsCnr[ 13 ] = AddStaticVehicle(541,1651.2000000,1545.9000000,10.5000000,0.0000000,-1,-1); //Bullet
	CarsCnr[ 14 ] = AddStaticVehicle(541,1644.3000000,1545.6000000,10.5000000,0.0000000,-1,-1); //Bullet
	CarsCnr[ 15 ] = AddStaticVehicle(541,1637.5000000,1545.4000000,10.5000000,0.0000000,-1,-1); //Bullet
	CarsCnr[ 16 ] = AddStaticVehicle(541,1629.8000000,1545.7000000,10.5000000,0.0000000,-1,-1); //Bullet
	CarsCnr[ 17 ] = AddStaticVehicle(541,1622.0000000,1545.2000000,10.5000000,0.0000000,-1,-1); //Bullet
	CarsCnr[ 18 ] = AddStaticVehicle(497,1615.6000000,1546.8000000,11.1000000,0.0000000,-1,-1); //Police Maverick
	CarsCnr[ 19 ] = AddStaticVehicle(497,1656.5000000,1548.5000000,11.0000000,0.0000000,-1,-1); //Police Maverick
	CarsCnr[ 20 ] = AddStaticVehicle(601,1615.6000000,1557.9000000,10.7000000,0.0000000,-1,-1); //S.W.A.T. Van
	CarsCnr[ 21 ] = AddStaticVehicle(601,1656.7000000,1558.9000000,10.7000000,0.0000000,-1,-1); //S.W.A.T. Van
	CarsCnr[ 22 ] = AddStaticVehicle(598,1621.3000000,1557.4000000,10.7000000,0.0000000,-1,-1); //Police Car (LVPD)
	CarsCnr[ 23 ] = AddStaticVehicle(598,1643.3000000,1556.9000000,10.7000000,0.0000000,-1,-1); //Police Car (LVPD)
	CarsCnr[ 24 ] = AddStaticVehicle(598,1629.4004000,1557.0000000,10.7000000,0.0000000,-1,-1); //Police Car (LVPD)
	CarsCnr[ 25 ] = AddStaticVehicle(598,1636.5000000,1556.7000000,10.7000000,0.0000000,-1,-1); //Police Car (LVPD)
	CarsCnr[ 26 ] = AddStaticVehicle(598,1650.8000000,1557.1000000,10.7000000,0.0000000,-1,-1); //Police Car (LVPD)
	CarsCnr[ 27 ] = AddStaticVehicle(523,1620.5000000,1563.9000000,10.5000000,0.0000000,-1,-1); //HPV1000
	CarsCnr[ 28 ] = AddStaticVehicle(523,1629.9004000,1564.4004000,10.5000000,0.0000000,-1,-1); //HPV1000
	CarsCnr[ 29 ] = AddStaticVehicle(523,1636.4000000,1564.7000000,10.5000000,0.0000000,-1,-1); //HPV1000
	CarsCnr[ 30 ] = AddStaticVehicle(523,1642.8000000,1565.0000000,10.5000000,0.0000000,-1,-1); //HPV1000
	CarsCnr[ 31 ] = AddStaticVehicle(523,1650.9000000,1565.4000000,10.5000000,0.0000000,-1,-1); //HPV1000
	CarsCnr[ 32 ] = AddStaticVehicle(599,1657.0000000,1567.7000000,11.2000000,0.0000000,-1,-1); //Police Ranger
	CarsCnr[ 33 ] = AddStaticVehicle(599,1616.0000000,1566.7000000,11.2000000,0.0000000,-1,-1); //Police Ranger
	CarsCnr[ 34 ] = AddStaticVehicle(522,1374.4000000,2693.0000000,10.5000000,0.0000000,-1,-1); //NRG-500
	CarsCnr[ 35 ] = AddStaticVehicle(522,1369.2000000,2692.8999000,10.5000000,0.0000000,-1,-1); //NRG-500
	CarsCnr[ 36 ] = AddStaticVehicle(522,1363.7000000,2692.8000000,10.5000000,0.0000000,-1,-1); //NRG-500
	CarsCnr[ 37 ] = AddStaticVehicle(522,1358.0000000,2692.5000000,10.5000000,0.0000000,-1,-1); //NRG-500
	CarsCnr[ 38 ] = AddStaticVehicle(522,1353.3000000,2692.3000000,10.5000000,0.0000000,-1,-1); //NRG-500
	CarsCnr[ 39 ] = AddStaticVehicle(522,1348.1000000,2692.0000000,10.5000000,0.0000000,-1,-1); //NRG-500
	CarsCnr[ 40 ] = AddStaticVehicle(522,1341.9000000,2691.7000000,10.5000000,0.0000000,-1,-1); //NRG-500
	CarsCnr[ 41 ] = AddStaticVehicle(522,1335.6000000,2691.8999000,10.5000000,0.0000000,-1,-1); //NRG-500
	CarsCnr[ 42 ] = AddStaticVehicle(522,1330.2000000,2691.6001000,10.5000000,0.0000000,-1,-1); //NRG-500
	CarsCnr[ 43 ] = AddStaticVehicle(522,1325.4000000,2692.0000000,10.5000000,0.0000000,-1,-1); //NRG-500
	CarsCnr[ 44 ] = AddStaticVehicle(522,1319.6000000,2691.3999000,10.5000000,0.0000000,-1,-1); //NRG-500
	CarsCnr[ 45 ] = AddStaticVehicle(522,1313.4004000,2691.7002000,10.5000000,0.0000000,-1,-1); //NRG-500
	CarsCnr[ 46 ] = AddStaticVehicle(487,1302.8000000,2694.1001000,11.1000000,184.0000000,-1,-1); //Maverick
	CarsCnr[ 47 ] = AddStaticVehicle(411,1374.3000000,2651.0000000,10.7000000,0.0000000,-1,-1); //Infernus
	CarsCnr[ 48 ] = AddStaticVehicle(411,1363.7000000,2651.0000000,10.7000000,0.0000000,-1,-1); //Infernus
	CarsCnr[ 49 ] = AddStaticVehicle(411,1330.7000000,2651.2000000,10.7000000,0.0000000,-1,-1); //Infernus
	CarsCnr[ 50 ] = AddStaticVehicle(411,1319.5000000,2651.8000000,10.7000000,0.0000000,-1,-1); //Infernus
	CarsCnr[ 51 ] = AddStaticVehicle(411,1308.1000000,2651.3999000,10.7000000,0.0000000,-1,-1); //Infernus
	CarsCnr[ 52 ] = AddStaticVehicle(411,1297.2000000,2651.6001000,10.7000000,0.0000000,-1,-1); //Infernus
	CarsCnr[ 53 ] = AddStaticVehicle(541,1369.5000000,2651.3000000,10.5000000,0.0000000,-1,-1); //Bullet
	CarsCnr[ 54 ] = AddStaticVehicle(541,1358.2000000,2650.8999000,10.5000000,0.0000000,-1,-1); //Bullet
	CarsCnr[ 55 ] = AddStaticVehicle(541,1336.0000000,2651.2000000,10.5000000,0.0000000,-1,-1); //Bullet
	CarsCnr[ 56 ] = AddStaticVehicle(541,1325.6000000,2651.3999000,10.5000000,0.0000000,-1,-1); //Bullet
	CarsCnr[ 57 ] = AddStaticVehicle(541,1314.0000000,2650.7000000,10.5000000,0.0000000,-1,-1); //Bullet
	CarsCnr[ 58 ] = AddStaticVehicle(541,1303.1000000,2651.3999000,10.5000000,0.0000000,-1,-1); //Bullet
	CarsCnr[ 59 ] = AddStaticVehicle(411,2764.7000000,1262.2000000,10.5000000,272.0000000,-1,-1); //Infernus
	CarsCnr[ 60 ] = AddStaticVehicle(411,2764.5000000,1265.7000000,10.5000000,272.0000000,-1,-1); //Infernus
	CarsCnr[ 61 ] = AddStaticVehicle(411,2764.3000000,1268.9000000,10.5000000,272.0000000,-1,-1); //Infernus
	CarsCnr[ 62 ] = AddStaticVehicle(541,2765.7000000,1272.2000000,10.4000000,272.0000000,-1,-1); //Bullet
	CarsCnr[ 63 ] = AddStaticVehicle(541,2765.6001000,1275.2000000,10.4000000,272.0000000,-1,-1); //Bullet
	CarsCnr[ 64 ] = AddStaticVehicle(559,2764.8999000,1278.5000000,10.5000000,266.0000000,-1,-1); //Jester
	CarsCnr[ 65 ] = AddStaticVehicle(559,2765.1006000,1281.7998000,10.5000000,265.9950000,-1,-1); //Jester
	CarsCnr[ 66 ] = AddStaticVehicle(559,2765.2002000,1284.7998000,10.5000000,266.9950000,-1,-1); //Jester
	CarsCnr[ 67 ] = AddStaticVehicle(541,2772.2998000,1294.5000000,10.4000000,180.0000000,-1,-1); //Bullet
	CarsCnr[ 68 ] = AddStaticVehicle(489,2779.1006000,1295.2998000,10.8000000,182.0000000,-1,-1); //Rancher
	CarsCnr[ 69 ] = AddStaticVehicle(489,2782.2002000,1295.5000000,10.8000000,182.0000000,-1,-1); //Rancher
	CarsCnr[ 70 ] = AddStaticVehicle(541,2775.3999000,1294.3000000,10.4000000,180.0000000,-1,-1); //Bullet
	CarsCnr[ 71 ] = AddStaticVehicle(559,2765.5000000,1287.9000000,10.5000000,266.9950000,-1,-1); //Jester
	CarsCnr[ 72 ] = AddStaticVehicle(559,2765.8999000,1291.1000000,10.5000000,266.9950000,-1,-1); //Jester
	CarsCnr[ 73 ] = AddStaticVehicle(521,2785.3000000,1294.2000000,10.4000000,180.0000000,-1,-1); //FCR-900
	CarsCnr[ 74 ] = AddStaticVehicle(522,2791.6001000,1294.2000000,10.4000000,184.0000000,-1,-1); //NRG-500
	CarsCnr[ 75 ] = AddStaticVehicle(461,2795.0000000,1294.2000000,10.4000000,180.0000000,-1,-1); //PCJ-600
	CarsCnr[ 76 ] = AddStaticVehicle(468,2787.5000000,1294.1000000,10.4000000,194.0000000,-1,-1); //Sanchez
	CarsCnr[ 77 ] = AddStaticVehicle(402,2805.7000000,1326.5000000,10.7000000,270.0000000,-1,-1); //Buffalo
	CarsCnr[ 78 ] = AddStaticVehicle(415,2805.5000000,1329.5000000,10.6000000,270.0000000,-1,-1); //Cheetah
	CarsCnr[ 79 ] = AddStaticVehicle(411,2805.4004000,1332.5996000,10.4000000,265.9950000,-1,-1); //Infernus
	CarsCnr[ 80 ] = AddStaticVehicle(437,2806.1001000,1340.9000000,10.9000000,178.0000000,-1,-1); //Coach
	CarsCnr[ 81 ] = AddStaticVehicle(437,2806.3000000,1354.9000000,10.9000000,177.9950000,-1,-1); //Coach
	CarsCnr[ 82 ] = AddStaticVehicle(487,2809.0000000,1370.9000000,11.0000000,180.0000000,-1,-1); //Maverick
	CarsCnr[ 83 ] = AddStaticVehicle(487,2823.5000000,1372.2000000,11.0000000,180.0000000,-1,-1); //Maverick
	CarsCnr[ 84 ] = AddStaticVehicle(487,2838.6001000,1373.1000000,11.0000000,180.0000000,-1,-1); //Maverick
	CarsCnr[ 85 ] = AddStaticVehicle(541, 2294.9751, 2395.1379, 10.5434, 0.0000, 0, 1 );
	CarsCnr[ 86 ] = AddStaticVehicle(541, 2294.9573, 2385.3606, 10.5434, 0.0000, 0, 1 );
	CarsCnr[ 87 ] = AddStaticVehicle(489,2816.6006000,1312.5996000,10.9000000,95.9990000,-1,-1); //Rancher
	CarsCnr[ 88 ] = AddStaticVehicle(470,2829.1001000,1269.9000000,10.9000000,90.0000000,-1,-1); //Patriot
	CarsCnr[ 89 ] = AddStaticVehicle(470,2829.2000000,1264.7000000,10.9000000,90.0000000,-1,-1); //Patriot
	CarsCnr[ 90 ] = AddStaticVehicle(489,2830.0000000,1245.1000000,11.1000000,90.0000000,-1,-1); //Rancher
	CarsCnr[ 91 ] = AddStaticVehicle(489,2830.0000000,1241.3000000,11.1000000,90.0000000,-1,-1); //Rancher
	CarsCnr[ 92 ] = AddStaticVehicle(470,284.1000100,2029.2000000,17.8000000,269.0000000,-1,-1); //Patriot
	CarsCnr[ 93 ] = AddStaticVehicle(446,2292.30004883,519.00000000,0.00000000,270.00000000,-1,-1); //Squalo
	CarsCnr[ 94 ] = AddStaticVehicle(470,284.6000100,2024.6000000,17.8000000,268.9950000,-1,-1); //Patriot
	CarsCnr[ 95 ] = AddStaticVehicle(470,285.1000100,2020.1000000,17.8000000,268.9950000,-1,-1); //Patriot
	CarsCnr[ 96 ] = AddStaticVehicle(411,283.5000000,1994.3000000,17.5000000,274.0000000,-1,-1); //Infernus
	CarsCnr[ 97 ] = AddStaticVehicle(411,282.7000100,1988.4000000,17.5000000,273.9990000,-1,-1); //Infernus
	CarsCnr[ 98 ] = AddStaticVehicle(411,281.7000100,1981.2000000,17.5000000,273.9990000,-1,-1); //Infernus
	CarsCnr[ 99 ] = AddStaticVehicle(541,279.7000100,1963.2000000,17.3000000,268.0000000,-1,-1); //Bullet
	CarsCnr[ 100 ] = AddStaticVehicle(541,280.2000100,1955.5000000,17.3000000,267.9950000,-1,-1); //Bullet
	CarsCnr[ 101 ] = AddStaticVehicle(541,279.5000000,1947.8000000,17.3000000,267.9950000,-1,-1); //Bullet
	CarsCnr[ 102 ] = AddStaticVehicle(497,319.7999900,2046.8000000,17.9000000,182.0000000,-1,-1); //Police Maverick
	CarsCnr[ 103 ] = AddStaticVehicle(497,296.3999900,2046.7000000,17.9000000,181.9970000,-1,-1); //Police Maverick
	CarsCnr[ 104 ] = AddStaticVehicle(522,302.5000000,2049.8000000,17.3000000,180.0000000,-1,-1); //NRG-500
	CarsCnr[ 105 ] = AddStaticVehicle(522,308.7000100,2049.5000000,17.3000000,180.0000000,-1,-1); //NRG-500
	CarsCnr[ 106 ] = AddStaticVehicle(522,313.7000100,2049.3000000,17.3000000,180.0000000,-1,-1); //NRG-500
	CarsCnr[ 107 ] = AddStaticVehicle(523,299.2000100,2050.0000000,17.3000000,178.0000000,-1,-1); //HPV1000
	CarsCnr[ 108 ] = AddStaticVehicle(523,306.1000100,2049.5000000,17.3000000,177.9950000,-1,-1); //HPV1000
	CarsCnr[ 109 ] = AddStaticVehicle(523,311.2000100,2049.3000000,17.3000000,177.9950000,-1,-1); //HPV1000
	CarsCnr[ 110 ] = AddStaticVehicle(415,318.2999900,2029.9000000,17.7000000,90.0000000,-1,-1); //Cheetah
	CarsCnr[ 111 ] = AddStaticVehicle(415,318.2000100,2025.5000000,17.7000000,90.0000000,-1,-1); //Cheetah
	CarsCnr[ 112 ] = AddStaticVehicle(415,317.2000100,2020.6000000,17.7000000,90.0000000,-1,-1); //Cheetah
	CarsCnr[ 113 ] = AddStaticVehicle(476,305.7000100,2004.1000000,18.8000000,186.0000000,-1,-1); //Rustler
	CarsCnr[ 114 ] = AddStaticVehicle(599,2307.6541000,2432.0132000,3.2828000,359.7990000,-1,-1); //Police Ranger
	CarsCnr[ 115 ] = AddStaticVehicle(599,2311.9124000,2431.7556000,3.2828000,359.7990000,-1,-1); //Police Ranger
    CarsCnr[ 116 ] = AddStaticVehicle(598,2299.2234000,2431.7944000,2.9070000,0.1000000,-1,-1); //Police Car (LVPD)
	CarsCnr[ 117 ] = AddStaticVehicle(598,2303.2290000,2431.9158000,3.0070000,0.0000000,-1,-1); //Police Car (LVPD)
	CarsCnr[ 118 ] = AddStaticVehicle(523,2314.4641000,2460.1409000,2.7722000,88.4264000,-1,-1); //HPV1000
	CarsCnr[ 119 ] = AddStaticVehicle(523,2314.3149000,2455.5918000,2.7722000,88.4264000,-1,-1); //HPV1000
	CarsCnr[ 120 ] = AddStaticVehicle(597,2285.6313000,2432.4355000,2.9726000,0.0000000,-1,-1); //Police Car (SFPD)
	CarsCnr[ 121 ] = AddStaticVehicle(597,2294.6094000,2432.2659000,2.9726000,0.0000000,-1,-1); //Police Car (SFPD)
	CarsCnr[ 122 ] = AddStaticVehicle(597,2290.2861000,2432.4155000,2.9726000,0.0000000,-1,-1); //Police Car (SFPD)
	CarsCnr[ 123 ] = AddStaticVehicle(528,2273.3298,2422.0361,10.8636,151.1364,0,0); // police car 1
    CarsCnr[ 124 ] = AddStaticVehicle(497, 2327.2590, 2392.7686, 11.1085, 49.9959,-1,-1);
	CarsCnr[ 125 ] = AddStaticVehicle(497, 2328.5825, 2375.7224, 11.1085, 51.3500, -1,-1);
	CarsCnr[ 126 ] = AddStaticVehicle(497, 2342.0979, 2396.5598, 11.1085, 54.1028, -1,-1);
	CarsCnr[ 127 ] = AddStaticVehicle(497, 2344.4739, 2377.9148, 11.1085, 48.1800, -1,-1);
	CarsCnr[ 128 ] = AddStaticVehicle(598, 2268.7070, 2405.8599, 10.8461, 53.9641, -1,-1);
	CarsCnr[ 129 ] = AddStaticVehicle(598, 2263.0259, 2405.8804, 10.8461, 53.9641, -1,-1);
	CarsCnr[ 130 ] = AddStaticVehicle(598, 2257.1843, 2405.8608, 10.8461, 53.9641, -1,-1);
	CarsCnr[ 131 ] = AddStaticVehicle(598, 2251.0037, 2405.8179, 10.8461, 53.9641, -1,-1);
	CarsCnr[ 132 ] = AddStaticVehicle(598, 2244.6067, 2405.8352, 10.8461, 53.9641, -1,-1);
	CarsCnr[ 133 ] = AddStaticVehicle(599, 2337.2676, 2406.1133, 10.8724, 63.3000, -1,-1);
	CarsCnr[ 134 ] = AddStaticVehicle(599, 2330.4619, 2406.0444, 10.8724, 63.3000, -1,-1);
	CarsCnr[ 135 ] = AddStaticVehicle(599, 2323.6560, 2406.0320, 10.8724, 63.3000, -1,-1);
	CarsCnr[ 136 ] = AddStaticVehicle(599, 2309.8044, 2406.0398, 10.8724, 63.3000, -1,-1);
	CarsCnr[ 137 ] = AddStaticVehicle(599, 2302.5701, 2405.9536, 10.8724, 63.3000, -1,-1);
	CarsCnr[ 138 ] = AddStaticVehicle(541, 2279.7263, 2385.8083, 10.5434, 0.0000, -1,-1);
	CarsCnr[ 139 ] = AddStaticVehicle(541, 2279.6941, 2395.6726, 10.5434, 0.0000, -1,-1);
	CarsCnr[ 140 ] = AddStaticVehicle(476, 2850.3999000,1365.8000000,12.0000000,95.9990000, -1,-1);
	CarsCnr[ 141 ] = AddStaticVehicle(476, 2849.3999000,1351.6000000,12.0000000,95.9990000, -1,-1);
	CarsCnr[ 142 ] = AddStaticVehicle(476, 1346.8000000,2652.8999000,12.0000000,0.0000000, -1,-1);
	CarsCnr[ 143 ] = AddStaticVehicle(598, 2274.3999 ,2446 ,10.7,0,-1,-1);
	CarsCnr[ 144 ] = AddStaticVehicle(598, 2278.3999 ,2445.7 ,10.7,181.247,-1,-1);
	CarsCnr[ 145 ] = AddStaticVehicle(598, 2282.5 ,2459 ,10.5,181.247,-1,-1);
	CarsCnr[ 146 ] = AddStaticVehicle(598, 2269.5 ,2459.2 ,10.5,181.247,-1,-1);
	CarsCnr[ 147 ] = AddStaticVehicle(415, 2281.7 ,2475.8 ,10.6,180,-1,-1);
	CarsCnr[ 148 ] = AddStaticVehicle(415, 2277.3 ,2475.8999 ,10.6,180,-1,-1);
	CarsCnr[ 149 ] = AddStaticVehicle(415, 2273.1001 ,2475.7 ,10.6,180,-1,-1);
	CarsCnr[ 150 ] = AddStaticVehicle(415, 2269.2 ,2476.7 ,10.6,180,-1,-1);
	CarsCnr[ 151 ] = AddStaticVehicle(489, 2260 ,2445.1001 ,10.9,0,-1,-1);
	CarsCnr[ 152 ] = AddStaticVehicle(489, 2252.2 ,2445.3999 ,10.9,0,-1,-1);
	CarsCnr[ 153 ] = AddStaticVehicle(415, 2256.5 ,2445 ,10.7,0,-1,-1);
	CarsCnr[ 154 ] = AddStaticVehicle(580, 2260.2 ,2475.2 ,10.7,177,-1,-1);
	CarsCnr[ 155 ] = AddStaticVehicle(523, 2255.8999 ,2474.3999 ,10.5,172,-1,-1);
	CarsCnr[ 156 ] = AddStaticVehicle(523, 2254.1001 ,2474.7 ,10.5,171.996,-1,-1);
	CarsCnr[ 157 ] = AddStaticVehicle(523, 2251.8999 ,2474.5 ,10.5,171.996,-1,-1);
	CarsCnr[ 158 ] = AddStaticVehicle(415, 2194.8999 ,2502.5 ,10.7,180,-1,-1);
	CarsCnr[ 159 ] = AddStaticVehicle(522, 2189.5 ,2501.3999 ,10.5,184,-1,-1);
	CarsCnr[ 160 ] = AddStaticVehicle(541, 2155.3999 ,2184.5 ,10.4,182,-1,-1);
	CarsCnr[ 161 ] = AddStaticVehicle(541, 2192.2 ,2502.1001 ,10.5,176,-1,-1);
	CarsCnr[ 162 ] = AddStaticVehicle(541, 2155.3 ,2200.6001 ,10.4,182,-1,-1);
	CarsCnr[ 163 ] = AddStaticVehicle(541, 2155.6001 ,2168.7 ,10.4,182,-1,-1);
	CarsCnr[ 164 ] = AddStaticVehicle(411, 2155.3 ,2121.3 ,10.6,0,-1,-1);
	CarsCnr[ 165 ] = AddStaticVehicle(411, 2154.6001 ,2103.5 ,10.6,0,-1,-1);
	CarsCnr[ 166 ] = AddStaticVehicle(411, 2154.7 ,2086.5 ,10.6,0,-1,-1);
	CarsCnr[ 167 ] = AddStaticVehicle(522, 2184.1001 ,1979.1 ,10.5,90,-1,-1);
	CarsCnr[ 168 ] = AddStaticVehicle(522, 2185.2 ,1995.8 ,10.5,90,-1,-1);
 	CarsCnr[ 169 ] = AddStaticVehicle(522, 2185.7 ,2004 ,10.5,90,-1,-1);
 	CarsCnr[ 170 ] = AddStaticVehicle(522, 2170 ,1973.9 ,10.5,274,-1,-1);
 	CarsCnr[ 171 ] = AddStaticVehicle(522, 2170.7 ,1985.1 ,10.5,273.999,-1,-1);
 	CarsCnr[ 172 ] = AddStaticVehicle(522, 2171.3999 ,1996.3 ,10.5,273.999,-1,-1);
 	CarsCnr[ 173 ] = AddStaticVehicle(522, 2171.7 ,2000.3 ,10.5,273.999,-1,-1);
 	CarsCnr[ 174 ] = AddStaticVehicle(522, 2171.2 ,1992.8 ,10.5,273.999,-1,-1);
 	CarsCnr[ 175 ] = AddStaticVehicle(522, 2170.9004 ,1988.7998 ,10.5,273.999,-1,-1);
 	CarsCnr[ 176 ] = AddStaticVehicle(522, 2170.3999 ,1981.6 ,10.5,273.999,-1,-1);
 	CarsCnr[ 177 ] = AddStaticVehicle(522, 2170.1006 ,1977.5996 ,10.5,273.999,-1,-1);
 	CarsCnr[ 178 ] = AddStaticVehicle(522, 2069.2 ,1761.8 ,10.4,336,-1,-1);
 	CarsCnr[ 179 ] = AddStaticVehicle(522, 2086.7 ,1797.1 ,10.4,335.995,-1,-1);
 	CarsCnr[ 180 ] = AddStaticVehicle(522, 2075 ,1634.6 ,10.4,0,-1,-1);
 	CarsCnr[ 181 ] = AddStaticVehicle(522, 2074.7 ,1569.6 ,10.4,0,-1,-1);
 	CarsCnr[ 182 ] = AddStaticVehicle(522, 2075.1001 ,1545.2 ,10.4,0,-1,-1);
 	CarsCnr[ 183 ] = AddStaticVehicle(522, 2075 ,1521.7 ,10.4,0,-1,-1);
	CarsCnr[ 184 ] = AddStaticVehicle(598, 2282.3999 ,2445.3999 ,10.7,0,-1,-1);
	CarsCnr[ 185 ] = AddStaticVehicle(598, 2278.3999 ,2445.7 ,10.7,181.247,-1,-1);
	CarsCnr[ 186 ] = AddStaticVehicle(598, 2269.3999 ,2446.3 ,10.7,0,-1,-1);

	// ( Set Cops Vehicles )
    for( new xc = 0; xc < 187; xc++ )
 	{
		SetVehicleVirtualWorld( CarsCnr[ xc ], 15 );
		SetVehicleNumberPlate( CarsCnr[ xc ], "{DB881A}CNR" );
	}
	// ( CNR Gates )
	CnRgate[ 0 ] = CreateObject( 976, 1397.23999, 2693.86011, 9.91000,   0.00000, 0.00000, 90.070001, 300.0 );
	CnRgate[ 1 ] = CreateObject( 976, 1397.23999, 2694.51001, 9.91000,   0.00000, 0.00000, 269.2300, 300.0 );
	CnRgate[ 2 ] = CreateObject( 971, 2756.9004000,1308.5000000,13.0000000, 0.00, 0.00,270.0000000, 300.0 );
	CnRgate[ 3 ] = CreateObject( 971, 2756.7998000,1317.9004000,13.0000000, 0.00, 0.00, 90.5000000, 300.0 );
	CnRgate[ 4 ] = CreateObject( 976, 2237.28003, 2448.85010, 9.88000,   0.00000, 0.00000, 90.29000, 300.0 );
	CnRCp[ 0 ] = CreateDynamicCP( 2298.0181,2466.5144,3.2734, 2, 15 );
	CnRCp[ 1 ] = CreateDynamicCP( 1301.2958,2674.1523,11.2392, 2, 15 );
	CnRCp[ 2 ] = CreateDynamicCP( 2817.1924,1282.4027,10.9609, 2, 15 );
    CnRCp[ 3 ] = CreateDynamicCP( 2200.6138,2475.1443,10.8203, 3, 15 );
    CnRCp[ 4 ] = CreateDynamicCP( 2146.9143,2750.7075,10.8203, 3, 15 );
    CnRCp[ 5 ] = CreateDynamicCP( 1640.8662,1573.5791,10.8203, 2, 15 );
    CnRCp[ 6 ] = CreateDynamicCP( 319.0746,2006.3840,17.6406, 2, 15 );

	RobberP= CreateDynamicCP( 1260.3131,2673.1099,10.8203,2, 15 );
	RobberP2= CreateDynamicCP( 2830.4456,1291.6594,10.7729,2, 15 );
	RobberOP= CreateDynamicCP( 2576.0725, -1304.3121, 1060.9844, 2, 15 );
	CNR_ZONE[ 0 ] = GangZoneCreate( 1257.429, 2587.360, 1530.238, 2700.725 );
	CNR_ZONE[ 1 ] = GangZoneCreate( 2234.375, 2417.96875, 2355.46875, 2507.8125 );
	CNR_ZONE[ 2 ] = GangZoneCreate( 1493.931, 1276.748, 1722.611, 1694.775 );
	CNR_ZONE[ 3 ] = GangZoneCreate( 107.536, 1792.202, 362.333, 2113.791 );
	CNR_ZONE[ 4 ] = GangZoneCreate( 2745.170, 1221.008, 2874.000, 1374.770 );

    //CNR
    CreateDynamicObject(6522, 1236.979614, 2673.399902, 17.906229, 0.000000, 0.000000, 0.000000,15,-1);
    CreateDynamicObject(8210, 2608.2448, 1345.0718, 80.4540, 0.0000, 0.0000, -93.3999,15,-1);
    CreateDynamicObject(8210,2769.8999000,1323.5000000,13.0000000,0.0000000,0.0000000,0.0000000,15,-1); //object(vgsselecfence12) (1)
    CreateDynamicObject(9951,2845.3000000,1291.6000000,21.8000000,0.0000000,0.0000000,0.0000000,15,-1); //object(pier3_sfe) (1)
    CreateDynamicObject(8210,2797.3999000,1350.8000000,13.0000000,0.0000000,0.0000000,90.0000000,15,-1); //object(vgsselecfence12) (2)
    CreateDynamicObject(8210,2829.3000000,1382.6000000,13.0000000,0.0000000,0.0000000,0.0000000,15,-1); //object(vgsselecfence12) (3)
    CreateDynamicObject(8209,2808.1006000,1223.7002000,13.0000000,0.0000000,0.0000000,179.9950000,15,-1); //object(vgsselecfence11) (2)
    CreateDynamicObject(8210,2856.5000000,1354.8000000,13.0000000,0.0000000,0.0000000,90.0000000,15,-1); //object(vgsselecfence12) (5)
    CreateDynamicObject(8210,2860.3999000,1251.6000000,13.0000000,0.0000000,0.0000000,90.0000000,15,-1); //object(vgsselecfence12) (6)
    CreateDynamicObject(8210,2758.0000000,1250.5996000,13.0000000,0.0000000,0.0000000,90.0000000,15,-1); //object(vgsselecfence12) (8)
    CreateDynamicObject(8210,2825.3999000,1382.8000000,13.0000000,0.0000000,0.0000000,0.0000000,15,-1); //object(vgsselecfence12) (9)
    CreateDynamicObject(8210,2797.6001000,1354.9000000,13.0000000,0.0000000,0.0000000,90.0000000,15,-1); //object(vgsselecfence12) (10)
    CreateDynamicObject(8209,2810.8999000,1223.8000000,13.0000000,0.0000000,0.0000000,179.9950000,15,-1); //object(vgsselecfence11) (1)
    CreateDynamicObject(8210,2757.8999000,1275.3000000,13.0000000,0.0000000,0.0000000,90.0000000,15,-1); //object(vgsselecfence12) (4)
	return 1;
}

forward DMcountUpdate(playerid);
public DMcountUpdate(playerid)
{
	switch(random(5))
	{
	    case 0: TextDrawSetString(gTextDraw[1], "~y~Stunt~w~/~b~DM~w~/~g~Drift~w~/~g~Freeroam~w~/~r~Race~w~/~p~Fun~w~/~y~CnR~w~");
		case 1: TextDrawSetString(gTextDraw[1], "~r~Stunt~w~/~y~DM~w~/~p~Drift~w~/~p~Freeroam~w~/~g~Race~w~/~b~Fun~w~/~g~CnR~w~");
		case 2: TextDrawSetString(gTextDraw[1], "~b~Stunt~w~/~g~DM~w~/~p~Drift~w~/~r~Freeroam~w~/~p~Race~w~/~y~Fun~w~/~r~CnR~w~");
		case 3: TextDrawSetString(gTextDraw[1], "~p~Stunt~w~/~r~DM~w~/~p~Drift~w~/~y~Freeroam~w~/~b~Race~w~/~g~Fun~w~/~p~CnR~w~");
		case 4: TextDrawSetString(gTextDraw[1], "~g~Stunt~w~/~p~DM~w~/~p~Drift~w~/~b~Freeroam~w~/~y~Race~w~/~r~Fun~w~/~b~CnR~w~");
	}
	new tempstr[140], Count[7];
	foreach(Player, i)
	{
		if(PlayerInfo[i][inDMZone] == 1) Count[0] ++;
		if(PlayerInfo[i][inDMZone] == 2) Count[1] ++;
		if(PlayerInfo[i][inDMZone] == 3) Count[2] ++;
		if(PlayerInfo[i][inDMZone] == 4) Count[3] ++;
		if(PlayerInfo[i][inDMZone] == 5) Count[4] ++;
		if(PlayerInfo[i][inDMZone] == 6) Count[5] ++;
		if(PlayerInfo[i][inDMZone] == 7) Count[6] ++;
	}
	format(tempstr, 140, "  ~w~/FDM: ~r~%i   ~w~/War: ~r~%i   ~w~/Mini: ~r~%i   ~w~/Eagle: ~r~%i   ~w~/RDM: ~r~%i   ~w~/ODM: ~r~%i   ~w~/SawnDM: ~r~%i",
	Count[0], Count[1], Count[2], Count[3], Count[4], Count[5], Count[6]);
	TextDrawSetString(gTextDraw[3], tempstr);
	return 1;
}


public OnGameModeExit()
{
	SendRconCommand("unloadfs ladmin");
	SendRconCommand("unloadfs TBSMaps");
	SendRconCommand("unloadfs OtherMap");

	KillTimer(timer);
	KillTimer(FixTimer);
	KillTimer(ScoreTimer);
	KillTimer(cTDcolor);
	KillTimer(cTDcolor2);
	KillTimer(cWEBcolor);
	KillTimer(cWEBcolor2);

	TextDrawDestroy(box);
	TextDrawDestroy(fdm);
	TextDrawDestroy(war);
	TextDrawDestroy(mini);
	TextDrawDestroy(eagle);
	TextDrawDestroy(rdm);
	TextDrawDestroy(odm);
	TextDrawDestroy(sawndm);
	TextDrawDestroy(T);
	TextDrawDestroy(BS);
	TextDrawDestroy(fdmplayers);
	TextDrawDestroy(warplayers);
	TextDrawDestroy(miniplayers);
	TextDrawDestroy(eagleplayers);
	TextDrawDestroy(rdmplayers);
	TextDrawDestroy(odmplayers);
	TextDrawDestroy(sawndmplayers);
	TextDrawDestroy(web);
	TextDrawDestroy(RobTD);
	TextDrawDestroy(gTextDraw[1]);

    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
		TextDrawHideForPlayer(i, RaceInfo[i]);
        TextDrawDestroy(RaceInfo[i]);
		CPProgess[i] = 0;
		KillTimer(InfoTimer[i]);
    }


	for(new i = 0; i < sizeof(gTextDraw); i ++) TextDrawDestroy(gTextDraw[i]);

	new INI:file, lasthcp;
	foreach(Player, i)
	{
	    EndHouseRobbery(i);
	    SetPVarInt(i, "IsRobbingHouse", 0);
	    lasthcp = GetPVarInt(i, "LastHouseCP");
	    if(!strcmp(hInfo[lasthcp][HouseOwner], pNick(i), CASE_SENSETIVE) && IsInHouse{i} == 1 && fexist(HouseFile(lasthcp)))
		{
  			file = INI_Open(HouseFile(lasthcp));
	    	INI_WriteInt(file, "QuitInHouse", 1);
		    INI_Close(file);
		    #if GH_HOUSECARS == true
	    		SaveHouseCar(lasthcp);
        	#endif
		}
		ExitHouse(i, lasthcp);
		DeletePVars(i);
	}
    UnloadHouses(); // Unload houses (also unloads the house cars)
   	BuildCreatedVehicle = (BuildCreatedVehicle == 0x01) ? (DestroyVehicle(BuildVehicle), BuildCreatedVehicle = 0x00) : (DestroyVehicle(BuildVehicle), BuildCreatedVehicle = 0x00);
	KillTimer(rCounter);
	KillTimer(CountTimer);
	KillTimer(AntiDeathSpamTime);
	Loop2(i, MAX_PLAYERS)
	{
		DisablePlayerRaceCheckpoint(i);
        TextDrawHideForPlayer(i, RaceInfo[i]);
        TextDrawDestroy(RaceInfo[i]);
		DestroyVehicle(CreatedRaceVeh[i]);
		Joined[i] = false;
		KillTimer(InfoTimer[i]);
	}
	JoinCount = 0;
	FinishCount = 0;
	TimeProgress = 0;
	AutomaticRace = false;
    for(new a = 0; a < sizeof(GangInfo); a++)
	{
		DestroyDynamicPickup(GangPickup[a]);
		DestroyDynamicPickup(GangPickup2[a]);
		DestroyDynamic3DTextLabel(GangLabel[a]);
		DestroyDynamicPickup(Aparat[a]);
		DestroyDynamic3DTextLabel(AparatLabel[a]);
		DestroyDynamicPickup(Arrest[a]);
		DestroyDynamic3DTextLabel(ArrestLabel[a]);
		DestroyPickup(PDWeapons[a]);
	    for(new i=0;i<15;i++)
	    {
			DestroyVehicle(GVehID[a][i]);
	    }
    }
    for(new i=0;i<MAX_PLAYERS;i++)
    DestroyDynamic3DTextLabel(RadarLabel[i]);
    for(new all = 0; all < MAX_PLAYERS; all++)
	{
	    SavePlayer(all);
	    SaveStats(all);
	}
	return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    if(!success)
	{
	   new string[128];
	   format(string, sizeof(string), "{FF0000}CMD: '%s'{F5D922} is incorrect, look {11ED65}/cmds {F5D922}and {11ED65}/teles {F5D922}again", cmdtext);
	   SendClientMessage(playerid, COLOR_YELLOW, string);
	}
    else
	{
		lastcommand[playerid]=gettime();
        //sets the variable to the current UNIX timestamp- see below for details
    }
	return 1;
}

public OnPlayerCommandReceived(playerid, cmdtext[]){
    if( lastcommand[playerid]!=0 && gettime()-lastcommand[playerid]<2 ){
        //This will make sure last command is not 0 (will be 0 if the player hasn't typed a command yet)
        //And make sure 3 seconds have NOT passed since the player last typed a command using a UNIX timestamp- see below for details
        SendClientMessage(playerid,0xFF0000FF,"You can only type ONE command every TWO seconds!");
        return 0;
    }
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	APlayerData[playerid][CurrentBusiness] = 0;
	SetPlayerPos(playerid,1295.8086,-783.0390,146.3881);
	SetPlayerCameraPos(playerid, 1300.8086,-786.0390,147.3881);
    ApplyAnimation(playerid, "RIOT", "RIOT_shout", 4.0, 1, 0, 0, 0, 0);
	return 1;
}

public OnPlayerFloodControl(playerid, iCount, iTimeSpan)
{
    if(iCount > 4 && iTimeSpan < 8000)
	{
        Ban(playerid);
    }
}


/*forward ExtinguisheFire();
public ExtinguisheFire()
{
    foreach (Player, i)
	{
	    new org=-1;
	    if(PlayerInfo[i][aLeader] > -1)
		{
			org = PlayerInfo[i][aLeader];
		}
		if(PlayerInfo[i][aMember] > -1)
		{
			org = PlayerInfo[i][aMember];
		}
		if(GangInfo[org][AllowedFD] == 1)
		{
		    if(Fire == 1)
		    {
		        if(IsPlayerInRangeOfPoint(i,35.0,FireInfo[Fireid][GX],FireInfo[Fireid][GY],FireInfo[Fireid][GZ]))
		        {
					if(GetPlayerWeapon(i) == 42 || IsPlayerInAnyVehicle(i))
					{
							    new Keys,ud,lr;
			    				GetPlayerKeys(i,Keys,ud,lr);
			    				if(Keys == KEY_FIRE)
								{
					        	new rand = random(5);
					        	if(rand < 5)
					        	{
					        		DestroyDynamicObject(FireO[rand]);
			                    	FireT++;
					        	}
								if(FireT == 10)
								{
								    FireT = 0;
								    for(new a = 0; a < 5; a++)
			        				{
			        					DestroyDynamicObject(FireO[a]);
			        				}
			        				new String[160];
									for(new d = 0; d < MAX_PLAYERS; d++)
			        				{
			        				    new band=-1;
			        				    if(PlayerInfo[d][aLeader] > -1)
			        				    {
			        				        band=PlayerInfo[d][aLeader];
			        				    }
			        				    if(PlayerInfo[d][aMember] > -1)
			        				    {
			        				        band=PlayerInfo[d][aMember];
			        				    }
										if(GangInfo[band][AllowedFD] == 1 || GangInfo[band][AllowedPD] == 1)
										{
										    if(IsPlayerInRangeOfPoint(d,20.0,FireInfo[Fireid][GX],FireInfo[Fireid][GY],FireInfo[Fireid][GZ]))
										    {
												format(String,sizeof(String),"{FF9900}You've participated in extinguishing the fire so you've got money on your bank account. {FFFFFF}600$!");
												SendClientMessage(d,SEABLUE,String);
												GivePlayerMoneyEx(d,600);
											}
										}
									}
			        				format(String,sizeof(String),"{0099CC}[Headquaters] {FF9900} All units, fire is extinguished!");
									FDChat(String);
		             				Fire = 0;
			      					}
								}
       				}
			}
		}
	}
 }
	return 1;
}*/
/*
forward CreateFire();
public CreateFire()
{
	if(Fire == 0)
	{
	    new rand=random(FireNumber);
	    new oFile[50];
        format(oFile, sizeof(oFile), FIRE, rand);
        if(fexist(oFile))
        {
	     	Fire = 1;
			FireO[0] = CreateDynamicObject(18690, FireInfo[rand][GX],FireInfo[rand][GY],FireInfo[rand][GZ]-2.3, 0, 0, 0.0);
			FireO[1] = CreateDynamicObject(18690, FireInfo[rand][GX1],FireInfo[rand][GY1],FireInfo[rand][GZ1]-2.3, 0, 0, 0.0);
			FireO[2] = CreateDynamicObject(18690, FireInfo[rand][GX2],FireInfo[rand][GY2],FireInfo[rand][GZ2]-2.3, 0, 0, 0.0);
			FireO[3] = CreateDynamicObject(18690, FireInfo[rand][GX3],FireInfo[rand][GY3],FireInfo[rand][GZ3]-2.3, 0, 0, 0.0);
			FireO[4] = CreateDynamicObject(18690, FireInfo[rand][GX4],FireInfo[rand][GY4],FireInfo[rand][GZ4]-2.3, 0, 0, 0.0);
			new String[280];
			format(String,sizeof(String),"{0099CC}[Headquaters] {FF9900}There's a new fire, to locate it use {FFFFFF}/flocate! {FF9900}Your job is to close the road!!");
			PDChat(String);
			format(String,sizeof(String),"{0099CC}[Headquaters] {FF9900}There's a new fire, to locate it use {FFFFFF}/flocate! {FF9900}Your job is to extinguish the fire!!");
			FDChat(String);
			Fireid=rand;
		}
		else
		{
			CreateFire();
		}
	}
	return 1;
}*/


forward ReturnPick(playerid);
public ReturnPick(playerid)
{
	if(Pick[playerid] > 0)
	{
		Pick[playerid]--;
	}
	else
	{
		Pick[playerid]=0;
		KillTimer(Pic[playerid]);
	}
}

#if GH_USE_CPS == true
public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	{
	    new string[256], tmpstring[50];
	    foreach(Houses, h)
		{
		    if(checkpointid == HouseCPOut[h])
		    {
		        SetPVarInt(playerid, "LastHouseCP", h);
		        if(!strcmp(hInfo[h][HouseOwner], pNick(playerid), CASE_SENSETIVE))
		        {
		            SetPlayerHouseInterior(playerid, h);
		            ShowInfoBoxEx(playerid, COLOUR_INFO, I_HMENU);
		            break;
		        }
                format(tmpstring, sizeof(tmpstring), "HouseKeys_%d", h);
			    if(GetPVarInt(playerid, tmpstring) == 1)
			    {
			        SetPlayerHouseInterior(playerid, h);
			        break;
			    }
		        if(strcmp(hInfo[h][HouseOwner], pNick(playerid), CASE_SENSETIVE) && strcmp(hInfo[h][HouseOwner], INVALID_HOWNER_NAME, CASE_SENSETIVE))
		        {
		            if(hInfo[h][HousePassword] == udb_hash("INVALID_HOUSE_PASSWORD"))
					{
					    switch(hInfo[h][ForSale])
					    {
					        case 0: ShowInfoBox(playerid, LABELTEXT2, hInfo[h][HouseName], hInfo[h][HouseOwner], hInfo[h][HouseValue], h);
							case 1:
							{
							    switch(hInfo[h][HousePrivacy])
							    {
							        case 0: ShowPlayerDialog(playerid, HOUSEMENU+23, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Buy House (Step 1)\nBreak In", "Select", "Cancel");
									case 1: ShowPlayerDialog(playerid, HOUSEMENU+23, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Buy House (Step 1)\nBreak In\nEnter House", "Select", "Cancel");
								}
							}
						}
						break;
					}
					if(hInfo[h][HousePassword] != udb_hash("INVALID_HOUSE_PASSWORD"))
					{
					    switch(hInfo[h][ForSale])
					    {
					        case 0:
					        {
							    switch(hInfo[h][HousePrivacy])
							    {
							        case 0: ShowPlayerDialog(playerid, HOUSEMENU+28, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Enter House Using Password\nBreak In", "Select", "Cancel");
									case 1: ShowPlayerDialog(playerid, HOUSEMENU+28, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Enter House Using Password\nBreak In\nEnter House", "Select", "Cancel");
								}
							}
       						case 1: ShowPlayerDialog(playerid, HOUSEMENU+23, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Buy House (Step 1)\nBreak In\nEnter House", "Select", "Cancel");
				   		}
				   		break;
					}
		        }
		        if(!strcmp(hInfo[h][HouseOwner], INVALID_HOWNER_NAME, CASE_SENSETIVE) && hInfo[h][HouseValue] > 0 && GetPVarInt(playerid, "JustCreatedHouse") == 0)
				{
					format(string, sizeof(string), HMENU_BUY_HOUSE, hInfo[h][HouseValue]);
					ShowPlayerDialog(playerid, HOUSEMENU+4, DIALOG_STYLE_MSGBOX, INFORMATION_HEADER, string, "Buy", "Cancel");
					break;
				}
		    }
		    if(checkpointid == HouseCPInt[h])
		    {
		        switch(GetPVarInt(playerid, "HousePreview"))
		        {
		            case 0: ExitHouse(playerid, h);
		            #if GH_HINTERIOR_UPGRADE == true
		            case 1:
			        {
						GetPVarString(playerid, "HousePrevName", tmpstring, 50);
						format(string, sizeof(string), HMENU_BUY_HINTERIOR, tmpstring, GetPVarInt(playerid, "HousePrevValue"));
						ShowPlayerDialog(playerid, HOUSEMENU+17, DIALOG_STYLE_MSGBOX, INFORMATION_HEADER, string, "Buy", "Cancel");
			        }
		            #endif
		        }
				break;
		    }
	    }
	}
	static Float:posx2[MAX_PLAYERS][2];
	static Float:posy2[MAX_PLAYERS][2];
	static Float:posz2[MAX_PLAYERS][2];
	static Float:zangle2[MAX_PLAYERS][2];
	if(checkpointid == Store1)
	{
	    if(!IsPlayerInAnyVehicle(playerid))
	    {
	  		if(GetPlayerTeam(playerid) == TEAM_ROBBERS || GetPlayerTeam(playerid) == TEAM_PROROBBERS || GetPlayerTeam(playerid) == TEAM_EROBBERS)
			{
				PlayerInfo[playerid][EnterCP] = 1;
			    format(PlayerInfo[playerid][ShopRobbed], 25, "Bank");
				Robstart[playerid] = 1;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",2500,5);
				SetPlayerInterior(playerid, 0);
				SetPlayerPos(playerid,2309.5686,-15.8837,26.7496);
			}
			else
			{
			    PlayerInfo[playerid][EnterCP] = 1;
				SetPlayerInterior(playerid, 0);
				SetPlayerPos(playerid,2309.5686,-15.8837,26.7496);
			}
		}
	}
	if(checkpointid == Store2)
	{
	    if(!IsPlayerInAnyVehicle(playerid))
	    {
			if(GetPlayerTeam(playerid) == TEAM_ROBBERS || GetPlayerTeam(playerid) == TEAM_PROROBBERS || GetPlayerTeam(playerid) == TEAM_EROBBERS)
			{
			    format(PlayerInfo[playerid][ShopRobbed], 25, "Calgious Casino");
				Robstart[playerid] = 1;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
				SetPlayerPos(playerid,2233.8032 ,1712.2303,1011.7632);
				SetPlayerInterior(playerid, 1);
	 		}
			else
			{
				SetPlayerPos(playerid,2233.8032 ,1712.2303,1011.7632);
				SetPlayerInterior(playerid, 1);
	 		}
 		}
	}
	if(checkpointid == Store2Exit)
	{
	    if(!IsPlayerInAnyVehicle(playerid))
	    {
		    format(PlayerInfo[playerid][ShopRobbed], 25, "None");
			Robstart[playerid] = 0;
	        SetPlayerPos(playerid, 2193.9080,1675.5385,12.3672);
			SetPlayerInterior(playerid, 0);
			KillTimer(robberytiming);
			robberytiming = 0;
			TextDrawHideForPlayer(playerid, RobTD);
		}

	}
	if(checkpointid == Store3)
	{
	    if(!IsPlayerInAnyVehicle(playerid))
	    {
			if(GetPlayerTeam(playerid) == TEAM_ROBBERS || GetPlayerTeam(playerid) == TEAM_PROROBBERS || GetPlayerTeam(playerid) == TEAM_EROBBERS)
			{
			    format(PlayerInfo[playerid][ShopRobbed], 25, "4 Dragon Casino");
		 		Robstart[playerid] = 1;
		 		PlayerInfo[playerid][EnterCP] = 1;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
		        GetPlayerPos(playerid, posx2[playerid][0], posy2[playerid][0], posz2[playerid][0]);
		        GetPlayerFacingAngle(playerid, zangle2[playerid][0]);
				SetPlayerPos(playerid,2008.8306,1016.1687,994.4688);
				SetPlayerInterior(playerid, 10);
			}
			else
			{
		        GetPlayerPos(playerid, posx2[playerid][0], posy2[playerid][0], posz2[playerid][0]);
		        GetPlayerFacingAngle(playerid, zangle2[playerid][0]);
				SetPlayerPos(playerid,2008.8306,1016.1687,994.4688);
				SetPlayerInterior(playerid, 10);
			}
		}
	}
	if(checkpointid == Store3Exit)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
		    format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "None" );
	 		Robstart[ playerid ] 			= 0;
	        SetPlayerPos( playerid, posx2[ playerid ][ 0 ] + 5, posy2[ playerid ][ 0 ], posz2[ playerid ][ 0 ] );
	        SetPlayerFacingAngle( playerid, zangle2[ playerid ][ 0 ] );
			SetPlayerInterior( playerid, 0 );
		}

	}
	if(checkpointid == Store4)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
			if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
			    format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "Casino" );
		 		Robstart[ playerid ] = 1;
                PlayerInfo[ playerid ][ EnterCP ] = 1;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
				SetPlayerPos(playerid,1133.0935,-9.4303,1000.6797);
				SetPlayerInterior( playerid, 12 );
			}
			else
			{
			    PlayerInfo[ playerid ][ EnterCP ] = 1;
				SetPlayerPos(playerid,1133.0935,-9.4303,1000.6797);
				SetPlayerInterior( playerid, 12 );
			}
		}
	}
	if(checkpointid == Store4Exit)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
	        if ( PlayerInfo[ playerid ][ EnterCP ] == 1)
	        {
		        SetPlayerPos( playerid, 2167.1433,2119.6877,10.8203);
		        SetPlayerFacingAngle( playerid, 0.4730 );
			}
			else if ( PlayerInfo[ playerid ][ EnterCP ] == 2)
			{
		        SetPlayerPos( playerid, 2089.1265,1519.1575,10.8203 );
		        SetPlayerFacingAngle( playerid, 7.1586 );
			}
		    format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "None" );
	 		Robstart[ playerid ] 			= 0;
	 		PlayerInfo[ playerid ][ EnterCP ] = 0;
			SetPlayerInterior( playerid, 0 );
		}

	}
	if(checkpointid == Store5)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
			if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
			    format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "Royal Casino" );
		 		Robstart[ playerid ] = 1;
		 		PlayerInfo[ playerid ][ EnterCP ] = 2;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
				SetPlayerPos(playerid,1133.0935,-9.4303,1000.6797);
				SetPlayerInterior( playerid, 12 );
			}
			else
			{
                PlayerInfo[ playerid ][ EnterCP ] = 2;
				SetPlayerPos(playerid,1133.0935,-9.4303,1000.6797);
				SetPlayerInterior( playerid, 12 );
			}
		}
	}
	if(checkpointid == Store6)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
			if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
			    format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "Binco" );
				Robstart[ playerid ] = 1;
				PlayerInfo[ playerid ][ EnterCP ] = 1;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
				SetPlayerPos(playerid,207.4441,-107.7490,1005.1328);
				SetPlayerFacingAngle( playerid, 0.7508 );
				SetPlayerInterior( playerid, 15 );
	 		}
			else
			{
			    PlayerInfo[ playerid ][ EnterCP ] = 1;
				SetPlayerPos(playerid,207.4441,-107.7490,1005.1328);
				SetPlayerFacingAngle( playerid, 0.7508 );
				SetPlayerInterior( playerid, 15 );
	 		}
 		}
	}
	if(checkpointid == Store6Exit)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
			Robstart[ playerid ] = 0;
	        if ( PlayerInfo[ playerid ][ EnterCP ] == 1)
	        {
		        SetPlayerPos( playerid, 2105.7771,2256.8118,11.0234);
		        SetPlayerFacingAngle( playerid, 272.2740 );
			}
			else if ( PlayerInfo[ playerid ][ EnterCP ] == 2)
			{
		        SetPlayerPos( playerid, 1653.1239,1733.1302,10.8203 );
		        SetPlayerFacingAngle( playerid, 89.0192 );
			}
			SetPlayerInterior( playerid, 0 );
			KillTimer(robberytiming);
			robberytiming = 0;
			PlayerInfo[ playerid ][ EnterCP ] = 0;
			TextDrawHideForPlayer(playerid, RobTD);
		}
	}
	if(checkpointid == Store7)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
			if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
			    format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "Binco" );
				Robstart[ playerid ] = 1;
				PlayerInfo[ playerid ][ EnterCP ] = 2;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
				SetPlayerPos(playerid,207.4441,-107.7490,1005.1328);
				SetPlayerFacingAngle( playerid, 0.7508 );
				SetPlayerInterior( playerid, 15 );
	 		}
			else
			{
				SetPlayerPos(playerid,207.4441,-107.7490,1005.1328);
				SetPlayerFacingAngle( playerid, 0.7508 );
				SetPlayerInterior( playerid, 15 );
				PlayerInfo[ playerid ][ EnterCP ] = 2;
	 		}
 		}
	}
	if(checkpointid == Store8)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
	  		if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
				PlayerInfo[ playerid ][ EnterCP ] = 3;
			    format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "Bank" );
				Robstart[ playerid ] = 1;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",2500,5);
				SetPlayerInterior( playerid, 0 );
				SetPlayerPos(playerid,2309.5686,-15.8837,26.7496);
			}
			else
			{
			    PlayerInfo[ playerid ][ EnterCP ] = 3;
				SetPlayerInterior( playerid, 0 );
				SetPlayerPos(playerid,2309.5686,-15.8837,26.7496);
			}
		}
	}
	if(checkpointid == Store9)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
	  		if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
				PlayerInfo[ playerid ][ EnterCP ] = 1;
			    format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "Ammunation" );
				Robstart[ playerid ] = 1;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",2500,5);
				SetPlayerInterior( playerid, 1 );
				SetPlayerPos(playerid,285.3693,-38.0492,1001.5156);
				SetPlayerFacingAngle( playerid, 21.5801 );
			}
			else
			{
			    PlayerInfo[ playerid ][ EnterCP ] = 1;
				SetPlayerInterior( playerid, 1 );
				SetPlayerPos(playerid,285.3693,-38.0492,1001.5156);
				SetPlayerFacingAngle( playerid, 21.5801 );
			}
		}
	}
	if(checkpointid == Store9Exit)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
			Robstart[ playerid ] 			= 0;
	        if ( PlayerInfo[ playerid ][ EnterCP ] == 1)
	        {
		        SetPlayerPos( playerid, 2155.2732,942.9988,10.8203 );
		        SetPlayerFacingAngle( playerid, 90.4685 );
			}
			else if ( PlayerInfo[ playerid ][ EnterCP ] == 2)
			{
		        SetPlayerPos( playerid, 2534.5569,2082.9429,10.8203);
		        SetPlayerFacingAngle( playerid, 89.8886 );
			}
			SetPlayerInterior( playerid, 0 );
			KillTimer(robberytiming);
			robberytiming = 0;
			PlayerInfo[ playerid ][ EnterCP ] = 0;
			TextDrawHideForPlayer(playerid, RobTD);
		}
	}
	if(checkpointid == Store10)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
	  		if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
				PlayerInfo[ playerid ][ EnterCP ] = 2;
			    format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "Ammunation" );
				Robstart[ playerid ] = 1;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",2500,5);
				SetPlayerInterior( playerid, 1 );
				SetPlayerPos(playerid,285.3693,-38.0492,1001.5156);
				SetPlayerFacingAngle( playerid, 21.5801 );
			}
			else
			{
			    PlayerInfo[ playerid ][ EnterCP ] = 2;
				SetPlayerInterior( playerid, 1 );
				SetPlayerPos(playerid,285.3693,-38.0492,1001.5156);
				SetPlayerFacingAngle( playerid, 21.5801 );
			}
		}
	}
	if(checkpointid == Store11)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
			if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
                PlayerInfo[ playerid ][ EnterCP ] = 1;
				format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "Cluckin Bell" );
		 		Robstart[ playerid ] = 1;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
				SetPlayerPos(playerid,365.3098,-9.0513,1001.8516);
				SetPlayerInterior( playerid, 9 );
	 		}
			else
			{
			    PlayerInfo[ playerid ][ EnterCP ] = 1;
				SetPlayerPos(playerid,365.3098 ,-9.0513,1001.8516);
				SetPlayerInterior( playerid, 9 );
	 		}
 		}
	}
	if(checkpointid == Store11Exit)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
	        if ( PlayerInfo[ playerid ][ EnterCP ] == 1)
			{
		        SetPlayerPos( playerid, 2633.1025,1671.5349,10.8203 );
		        SetPlayerFacingAngle( playerid, 90.8305);
			}
	        else if ( PlayerInfo[ playerid ][ EnterCP ] == 2)
			{
		        SetPlayerPos( playerid, 2848.1365,2413.0388,11.0690 );
		        SetPlayerFacingAngle( playerid, 224.9740);
			}
		    format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "None" );
			Robstart[ playerid ] 			= 0;
			PlayerInfo[ playerid ][ EnterCP ] = 0;
			SetPlayerInterior( playerid, 0 );
			KillTimer(robberytiming);
			robberytiming = 0;
			TextDrawHideForPlayer(playerid, RobTD);
		}
	}
	if(checkpointid == Store12)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
			if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
				format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "Well Stacked Pizza" );
		 		Robstart[ playerid ] = 1;
		 		PlayerInfo[ playerid ][ EnterCP ] = 1;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
				SetPlayerPos(playerid,371.5939,-129.0607,1001.4922);
				SetPlayerFacingAngle( playerid, 2.4788);
				SetPlayerInterior( playerid, 5 );
	 		}
			else
			{
				SetPlayerPos(playerid,371.5939,-129.0607,1001.4922);
				SetPlayerFacingAngle( playerid, 2.4788);
				SetPlayerInterior( playerid, 5 );
				PlayerInfo[ playerid ][ EnterCP ] = 1;
	 		}
 		}
	}
	if(checkpointid == Store12Exit)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
	        if ( PlayerInfo[ playerid ][ EnterCP ] == 1)
			{
		        SetPlayerPos( playerid, 2636.0862,1849.8922,11.0234 );
		        SetPlayerFacingAngle( playerid, 91.4210);
			}
	        else if ( PlayerInfo[ playerid ][ EnterCP ] == 2)
			{
		        SetPlayerPos( playerid, 2762.0913,2466.7473,11.0625 );
		        SetPlayerFacingAngle( playerid, 126.5631);
			}
		    format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "None" );
			Robstart[ playerid ] 			= 0;
			PlayerInfo[ playerid ][ EnterCP ] = 0;
			SetPlayerInterior( playerid, 0 );
			KillTimer(robberytiming);
			robberytiming = 0;
			TextDrawHideForPlayer(playerid, RobTD);
		}
	}
	if(checkpointid == Store13)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
			if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
				format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "Burger Shot" );
		 		Robstart[ playerid ] = 1;
		 		PlayerInfo[ playerid ][ EnterCP ] = 1;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
				SetPlayerPos(playerid,365.4099 ,-73.6167,1001.5078);
				SetPlayerInterior( playerid, 10 );
	 		}
			else
			{
				SetPlayerPos(playerid,365.4099 ,-73.6167,1001.5078);
				SetPlayerInterior( playerid, 10 );
				PlayerInfo[ playerid ][ EnterCP ] = 1;
	 		}
 		}
	}
	if(checkpointid == Store13Exit)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
	        if ( PlayerInfo[ playerid ][ EnterCP ] == 1)
			{
		        SetPlayerPos( playerid, 2173.9604,2795.7378,10.8203 );
		        SetPlayerFacingAngle( playerid, 269.2012);
			}
	        else if ( PlayerInfo[ playerid ][ EnterCP ] == 2)
			{
		        SetPlayerPos( playerid, 2467.4170,2034.1187,11.0625 );
		        SetPlayerFacingAngle( playerid, 89.3927);
			}
	        else if ( PlayerInfo[ playerid ][ EnterCP ] == 3)
			{
		        SetPlayerPos( playerid, 2363.2280,2071.1501,10.8203 );
		        SetPlayerFacingAngle( playerid, 93.4661);
			}
	        else if ( PlayerInfo[ playerid ][ EnterCP ] == 4)
			{
		        SetPlayerPos( playerid, 1162.3760,2072.4702,11.0625 );
		        SetPlayerFacingAngle( playerid, 272.1936);
			}
		    format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "None" );
			Robstart[ playerid ] = 0;
			PlayerInfo[ playerid ][ EnterCP ] = 0;
			SetPlayerInterior( playerid, 0 );
			KillTimer(robberytiming);
			robberytiming = 0;
			TextDrawHideForPlayer(playerid, RobTD);
		}
	}
	if(checkpointid == Store14)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
			if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
				format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "Burger Shot" );
		 		Robstart[ playerid ] = 1;
		 		PlayerInfo[ playerid ][ EnterCP ] = 2;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
				SetPlayerPos(playerid,365.4099 ,-73.6167,1001.5078);
				SetPlayerInterior( playerid, 10 );
	 		}
			else
			{
				SetPlayerPos(playerid,365.4099 ,-73.6167,1001.5078);
				SetPlayerInterior( playerid, 10 );
				PlayerInfo[ playerid ][ EnterCP ] = 2;
	 		}
 		}
	}
	if(checkpointid == Store15)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
			if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
				format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "Burger Shot" );
		 		Robstart[ playerid ] = 1;
		 		PlayerInfo[ playerid ][ EnterCP ] = 3;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
				SetPlayerPos(playerid,365.4099 ,-73.6167,1001.5078);
				SetPlayerInterior( playerid, 10 );
	 		}
			else
			{
				SetPlayerPos(playerid,365.4099 ,-73.6167,1001.5078);
				SetPlayerInterior( playerid, 10 );
				PlayerInfo[ playerid ][ EnterCP ] = 3;
	 		}
 		}
	}
	if(checkpointid == Store16)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
			if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
				format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "Burger Shot" );
		 		Robstart[ playerid ] = 1;
		 		PlayerInfo[ playerid ][ EnterCP ] = 4;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
				SetPlayerPos(playerid,365.4099 ,-73.6167,1001.5078);
				SetPlayerInterior( playerid, 10 );
	 		}
			else
			{
				SetPlayerPos(playerid,365.4099 ,-73.6167,1001.5078);
				SetPlayerInterior( playerid, 10 );
				PlayerInfo[ playerid ][ EnterCP ] = 4;
	 		}
 		}
	}
	if(checkpointid == Store17)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
	  		if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
				PlayerInfo[ playerid ][ EnterCP ] = 1;
			    format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "24/7" );
				Robstart[ playerid ] = 1;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
				SetPlayerPos(playerid,-26.6916 ,-55.7149,1003.5469);
				SetPlayerInterior( playerid, 6 );
			}
			else
			{
			    PlayerInfo[ playerid ][ EnterCP ] = 1;
				SetPlayerPos(playerid,-26.6916 ,-55.7149,1003.5469);
				SetPlayerInterior( playerid, 6 );
			}
		}
	}
	if(checkpointid ==  Store17Exit)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
	        if ( PlayerInfo[ playerid ][ EnterCP ] == 1)
	        {
		        SetPlayerPos( playerid, 2098.0432,2220.3806,10.8203 );
		        SetPlayerFacingAngle( playerid, 179.8655 );
			}
			else if ( PlayerInfo[ playerid ][ EnterCP ] == 2)
			{
		        SetPlayerPos( playerid, 1933.6343,2307.1343,10.8203 );
		        SetPlayerFacingAngle( playerid, 91.6785 );
			}
			else if ( PlayerInfo[ playerid ][ EnterCP ] == 3)
			{
		        SetPlayerPos( playerid, 2189.2288,1990.6420,10.8203 );
		        SetPlayerFacingAngle( playerid, 92.3521 );
			}
			else if ( PlayerInfo[ playerid ][ EnterCP ] == 4)
			{
		        SetPlayerPos( playerid, 2886.2598,2451.2739,11.0690 );
		        SetPlayerFacingAngle( playerid, 229.0240 );
			}
			format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "None" );
			SetPlayerInterior( playerid, 0 );
			PlayerInfo[ playerid ][ EnterCP ] = 0;
			Robstart[ playerid ] = 0;
	 		KillTimer(robberytiming);
			robberytiming = 0;
			TextDrawHideForPlayer(playerid, RobTD);
		}
	}
	if(checkpointid == Store18)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
	  		if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
				PlayerInfo[ playerid ][ EnterCP ] = 2;
			    format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "24/7" );
				Robstart[ playerid ] = 1;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
				SetPlayerPos(playerid,-26.6916 ,-55.7149,1003.5469);
				SetPlayerInterior( playerid, 6 );
			}
			else
			{
			    PlayerInfo[ playerid ][ EnterCP ] = 2;
				SetPlayerPos(playerid,-26.6916 ,-55.7149,1003.5469);
				SetPlayerInterior( playerid, 6 );
			}
		}
	}
	if(checkpointid == Store19)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
	  		if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
				PlayerInfo[ playerid ][ EnterCP ] = 3;
			    format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "24/7" );
				Robstart[ playerid ] = 1;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
				SetPlayerPos(playerid,-26.6916 ,-55.7149,1003.5469);
				SetPlayerInterior( playerid, 6 );
			}
			else
			{
			    PlayerInfo[ playerid ][ EnterCP ] = 3;
				SetPlayerPos(playerid,-26.6916 ,-55.7149,1003.5469);
				SetPlayerInterior( playerid, 6 );
			}
		}
	}
	if(checkpointid == Store20)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
	  		if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
				PlayerInfo[ playerid ][ EnterCP ] = 4;
			    format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "24/7" );
				Robstart[ playerid ] = 1;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
				SetPlayerPos(playerid,-26.6916 ,-55.7149,1003.5469);
				SetPlayerInterior( playerid, 6 );
			}
			else
			{
			    PlayerInfo[ playerid ][ EnterCP ] = 4;
				SetPlayerPos(playerid,-26.6916 ,-55.7149,1003.5469);
				SetPlayerInterior( playerid, 6 );
			}
		}
	}
	if(checkpointid == Store21)
	{
	    if ( !IsPlayerInAnyVehicle( playerid ) )
	    {
			if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
				format( PlayerInfo[ playerid ][ ShopRobbed ], 25, "Well Stacked Pizza" );
		 		Robstart[ playerid ] = 1;
		 		PlayerInfo[ playerid ][ EnterCP ] = 2;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
				SetPlayerPos(playerid,371.5939,-129.0607,1001.4922);
				SetPlayerFacingAngle( playerid, 2.4788);
				SetPlayerInterior( playerid, 5 );
	 		}
			else
			{
				SetPlayerPos(playerid,371.5939,-129.0607,1001.4922);
				SetPlayerFacingAngle( playerid, 2.4788);
				SetPlayerInterior( playerid, 5 );
				PlayerInfo[ playerid ][ EnterCP ] = 2;
	 		}
 		}
	}
	if(checkpointid == Store22)
	{
	    if(!IsPlayerInAnyVehicle(playerid))
	    {
			if(GetPlayerTeam(playerid) == TEAM_ROBBERS || GetPlayerTeam(playerid) == TEAM_PROROBBERS || GetPlayerTeam(playerid) == TEAM_EROBBERS)
			{
                PlayerInfo[playerid][EnterCP] = 2;
				format(PlayerInfo[playerid][ShopRobbed], 25, "Cluckin Bell");
		 		Robstart[playerid] 			= 1;
				GameTextForPlayer(playerid,"~b~/ROB ~w~TO ~nl~ATTEMPT A ROBBERY",5000,5);
				SetPlayerPos(playerid,365.3098,-9.0513,1001.8516);
				SetPlayerInterior(playerid, 9);
	 		}
			else
			{
			    PlayerInfo[playerid][EnterCP] = 2;
				SetPlayerPos(playerid,365.3098 ,-9.0513,1001.8516);
				SetPlayerInterior(playerid, 9);
	 		}
 		}
	}
	if(checkpointid == PoliceP)
	{
	    if ( !IsPlayerInAnyVehicle(playerid))
	    {
			SetPlayerPos(playerid,288.2816,173.2520,1007.1794);
			SetPlayerInterior(playerid, 3);
		}
	}
	if(checkpointid == PoliceOP)
	{
	    if ( !IsPlayerInAnyVehicle(playerid))
	    {
			SetPlayerPos(playerid,2287.2363,2425.5176,10.8203);
			SetPlayerInterior(playerid, 0);
		}
	}
	if(checkpointid == RobberP)
	{
	    if (!IsPlayerInAnyVehicle(playerid))
	    {
	        if(GetPlayerTeam(playerid) == TEAM_ROBBERS || GetPlayerTeam(playerid) == TEAM_PROROBBERS || GetPlayerTeam(playerid) == TEAM_EROBBERS)
	        {
	            SendClientMessage(playerid, COLOR_ULTRARED,"{FF0000}Welcome to Robbers HQ");
	         	SetPlayerPos(playerid , 2567.0352,-1294.6320,1063.2520);
	        	SetPlayerInterior(playerid , 2);
	        	PlayerInfo[playerid][EnterCP] = 1;
	        }
	        else SendClientMessage(playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a robber while in a /CnR minigame to enter robbers HQ!");
		}
	}
	if(checkpointid == RobberOP)
	{
	    if (!IsPlayerInAnyVehicle(playerid))
	    {
	        if(GetPlayerTeam(playerid) == TEAM_ROBBERS || GetPlayerTeam(playerid) == TEAM_PROROBBERS || GetPlayerTeam(playerid) == TEAM_EROBBERS)
	        {
		        if(PlayerInfo[playerid][EnterCP] == 1)
		        {
			        SetPlayerPos(playerid, 1268.7513,2673.2830,10.8203);
			        SetPlayerFacingAngle(playerid, 273.1829);
				}
				else if(PlayerInfo[playerid][EnterCP] == 2)
				{
					SetPlayerPos(playerid,2828.1384,1291.5239,10.7696);
					SetPlayerFacingAngle(playerid, 92.0744);
				}
				PlayerInfo[playerid][EnterCP] = 0;
	        	SendClientMessage(playerid, COLOR_ULTRARED,"{FF0000}You have left Robbers HQ");
	        	SetPlayerInterior(playerid , 0);
	        	SetPlayerVirtualWorld(playerid , 15);
	        }
	        else SendClientMessage(playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a robber while in a /CnR minigame to leave robbers HQ!");
		}
	}
	if(checkpointid == RobberP2)
	{
	    if(!IsPlayerInAnyVehicle(playerid))
	    {
	        if(GetPlayerTeam(playerid) == TEAM_ROBBERS || GetPlayerTeam(playerid) == TEAM_PROROBBERS || GetPlayerTeam(playerid) == TEAM_EROBBERS)
	        {
	            PlayerInfo[playerid][EnterCP] = 2;
	         	SetPlayerPos(playerid, 2567.0352,-1294.6320,1063.2520 );
	        	SetPlayerInterior(playerid, 2);
	        }
	        else SendClientMessage(playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a robber while in a /CnR minigame to enter robbers HQ!");
		}
	}
	//(CnR)
	if(checkpointid == CnRCp[0])
	{
	    if(GetPlayerTeam(playerid) != TEAM_COPS && GetPlayerTeam(playerid) != TEAM_ARMY && GetPlayerTeam(playerid) != TEAM_SWAT)
		return SendClientMessage(playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a cop while in a /CnR minigame to enter robbers HQ!");
		ShowPlayerDialog(playerid, DIALOG_CnR + 2, DIALOG_STYLE_LIST, "{004BFF}LVPD Refill", CNRRefill(), "Select", "");
	}
	if(checkpointid == CnRCp[1])
	{
	    if(GetPlayerTeam(playerid) != TEAM_ROBBERS && GetPlayerTeam(playerid) != TEAM_PROROBBERS && GetPlayerTeam(playerid) != TEAM_EROBBERS)
		return SendClientMessage(playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a robber while in a /CnR minigame to enter robbers HQ!");
		ShowPlayerDialog(playerid, DIALOG_CnR + 3, DIALOG_STYLE_LIST, "{FF8000}Robbery Refill", CNRRefill(), "Select", "");
	}
	if(checkpointid == CnRCp[2])
	{
	    if( GetPlayerTeam(playerid) != TEAM_ROBBERS && GetPlayerTeam(playerid) != TEAM_PROROBBERS && GetPlayerTeam(playerid) != TEAM_EROBBERS)
		return SendClientMessage(playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a robber while in a /CnR minigame to enter robbers HQ!");
		ShowPlayerDialog(playerid, DIALOG_CnR + 3, DIALOG_STYLE_LIST, "{FF8000}Robbery Refill", CNRRefill() , "Select", "");
	}
	if(checkpointid == CnRCp[3])
	{
	    if (IsPlayerInAnyVehicle(playerid))
 		{
			ShowPlayerDialog(playerid, DIALOG_CnR + 4, DIALOG_STYLE_LIST, "{FF8000}Refill Station", RefillStation(), "Select", "");
		}
	}
	if(checkpointid == CnRCp[4])
	{
	    if (IsPlayerInAnyVehicle(playerid))
	    {
			ShowPlayerDialog(playerid, DIALOG_CnR + 4, DIALOG_STYLE_LIST, "{FF8000}Refill Station", RefillStation(), "Select", "");
		}
	}
	if(checkpointid == CnRCp[5])
	{
	    if(GetPlayerTeam(playerid) != TEAM_COPS && GetPlayerTeam(playerid) != TEAM_ARMY && GetPlayerTeam(playerid) != TEAM_SWAT)
		return SendClientMessage(playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a cop while in a /CnR minigame to enter robbers HQ!");
		ShowPlayerDialog(playerid, DIALOG_CnR + 2, DIALOG_STYLE_LIST, "{0000FF}LVPD Refill", CNRRefill(), "Select", "");
	}
	if(checkpointid == CnRCp[6])
	{
	    if(GetPlayerTeam(playerid) != TEAM_COPS && GetPlayerTeam(playerid) != TEAM_ARMY && GetPlayerTeam(playerid) != TEAM_SWAT)
		return SendClientMessage(playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a robber while in a /CnR minigame to enter robbers HQ!");
		ShowPlayerDialog(playerid, DIALOG_CnR + 2, DIALOG_STYLE_LIST , "{8000FF}LVPD Refill", CNRRefill(), "Select" , "");
	}
	return 1;
}
public OnPlayerLeaveDynamicCP(playerid, checkpointid)
{
    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && GetPVarInt(playerid, "JustCreatedHouse") == 1)
	{
	    foreach(Houses, h)
		{
		    if(checkpointid == HouseCPOut[h])
		    {
		        DeletePVar(playerid, "JustCreatedHouse");
		        break;
		    }
	    }
	}
	return 1;
}
#else
public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	{
	    new string[256], tmpstring[50];
	    foreach(Houses, h)
		{
		    if(pickupid == HousePickupOut[h])
		    {
		        SetPVarInt(playerid, "LastHouseCP", h);
		        if(!strcmp(hInfo[h][HouseOwner], pNick(playerid), CASE_SENSETIVE))
		        {
		            SetPlayerHouseInterior(playerid, h);
		            ShowInfoBoxEx(playerid, COLOUR_INFO, I_HMENU);
		            break;
		        }
                format(tmpstring, sizeof(tmpstring), "HouseKeys_%d", h);
			    if(GetPVarInt(playerid, tmpstring) == 1)
			    {
			        SetPlayerHouseInterior(playerid, h);
			        break;
			    }
		        if(strcmp(hInfo[h][HouseOwner], pNick(playerid), CASE_SENSETIVE) && strcmp(hInfo[h][HouseOwner], INVALID_HOWNER_NAME, CASE_SENSETIVE))
		        {
		            if(hInfo[h][HousePassword] == udb_hash("INVALID_HOUSE_PASSWORD"))
					{
					    switch(hInfo[h][ForSale])
					    {
					        case 0: ShowInfoBox(playerid, LABELTEXT2, hInfo[h][HouseName], hInfo[h][HouseOwner], hInfo[h][HouseValue], h);
							case 1:
							{
							    switch(hInfo[h][HousePrivacy])
							    {
							        case 0: ShowPlayerDialog(playerid, HOUSEMENU+23, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Buy House (Step 1)\nBreak In", "Select", "Cancel");
									case 1: ShowPlayerDialog(playerid, HOUSEMENU+23, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Buy House (Step 1)\nBreak In\nEnter House", "Select", "Cancel");
								}
							}
						}
						break;
					}
					if(hInfo[h][HousePassword] != udb_hash("INVALID_HOUSE_PASSWORD"))
					{
					    switch(hInfo[h][ForSale])
					    {
					        case 0:
					        {
							    switch(hInfo[h][HousePrivacy])
							    {
							        case 0: ShowPlayerDialog(playerid, HOUSEMENU+28, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Enter House Using Password\nBreak In", "Select", "Cancel");
									case 1: ShowPlayerDialog(playerid, HOUSEMENU+28, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Enter House Using Password\nBreak In\nEnter House", "Select", "Cancel");
								}
							}
       						case 1: ShowPlayerDialog(playerid, HOUSEMENU+23, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Buy House (Step 1)\nBreak In\nEnter House", "Select", "Cancel");
				   		}
				   		break;
					}
		        }
		        if(!strcmp(hInfo[h][HouseOwner], INVALID_HOWNER_NAME, CASE_SENSETIVE) && hInfo[h][HouseValue] > 0 && GetPVarInt(playerid, "JustCreatedHouse") == 0)
				{
					format(string, sizeof(string), HMENU_BUY_HOUSE, hInfo[h][HouseValue]);
					ShowPlayerDialog(playerid, HOUSEMENU+4, DIALOG_STYLE_MSGBOX, INFORMATION_HEADER, string, "Buy", "Cancel");
					break;
				}
		    }
		    if(pickupid == HousePickupInt[h])
		    {
		        switch(GetPVarInt(playerid, "HousePreview"))
		        {
		            case 0: ExitHouse(playerid, h);
		            #if GH_HINTERIOR_UPGRADE == true
		            case 1:
			        {
						GetPVarString(playerid, "HousePrevName", tmpstring, 50);
						format(string, sizeof(string), HMENU_BUY_HINTERIOR, tmpstring, GetPVarInt(playerid, "HousePrevValue"));
						ShowPlayerDialog(playerid, HOUSEMENU+17, DIALOG_STYLE_MSGBOX, INFORMATION_HEADER, string, "Buy", "Cancel");
			        }
		            #endif
		        }
				break;
		    }
	    }
	}
	return 1;
}
#endif
stock Float:DistanceToPoint(Float:X1, Float:Y1, Float:Z1, Float:X2, Float:Y2, Float:Z2) return Float:floatsqroot(((X2 - X1) * (X2 - X1)) + ((Y2 - Y1) * (Y2 - Y1)) + ((Z2 - Z1) * (Z2 - Z1)));

public OnPlayerConnect(playerid)
{
	SetPlayerPos(playerid,1295.8086,-783.0390,146.3881);
    //CallRemoteFunction("CallConnect","i",playerid);
	killStreak[playerid] = 0;
	// Welcome TextDraws...
    rInfoTDS[playerid] = CreatePlayerTextDraw(playerid, 165.000000, 351.000000, " ");
	PlayerTextDrawAlignment(playerid, rInfoTDS[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, rInfoTDS[playerid], 0x000000ff);
	PlayerTextDrawFont(playerid, rInfoTDS[playerid], 1);
	PlayerTextDrawLetterSize(playerid, rInfoTDS[playerid], 0.299999, 1.200000);
	PlayerTextDrawColor(playerid, rInfoTDS[playerid], 0xffffffff);
	PlayerTextDrawSetOutline(playerid, rInfoTDS[playerid], 1);
	PlayerTextDrawSetProportional(playerid, rInfoTDS[playerid], 1);
	PlayerTextDrawSetShadow(playerid, rInfoTDS[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, rInfoTDS[2], 0);

	Textdraw0[playerid] = CreatePlayerTextDraw(playerid, 495.000000, 76.444412, "Welcome to");
	PlayerTextDrawLetterSize(playerid, Textdraw0[playerid], 0.395000, 1.288887);
	PlayerTextDrawAlignment(playerid, Textdraw0[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw0[playerid], -65281);
	PlayerTextDrawSetShadow(playerid, Textdraw0[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw0[playerid], 2);
	PlayerTextDrawBackgroundColor(playerid, Textdraw0[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw0[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw0[playerid], 1);

	Textdraw1[playerid] = CreatePlayerTextDraw(playerid, 447.000000, 91.999954, "The");
	PlayerTextDrawLetterSize(playerid, Textdraw1[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Textdraw1[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw1[playerid], 65535);
	PlayerTextDrawSetShadow(playerid, Textdraw1[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw1[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw1[playerid], -5963521);
	PlayerTextDrawFont(playerid, Textdraw1[playerid], 2);
	PlayerTextDrawSetProportional(playerid, Textdraw1[playerid], 1);

	Textdraw2[playerid] = CreatePlayerTextDraw(playerid, 524.000000, 111.288864, "Best");
	PlayerTextDrawLetterSize(playerid, Textdraw2[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Textdraw2[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw2[playerid], -16776961);
	PlayerTextDrawSetShadow(playerid, Textdraw2[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw2[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw2[playerid], -5963521);
	PlayerTextDrawFont(playerid, Textdraw2[playerid], 2);
	PlayerTextDrawSetProportional(playerid, Textdraw2[playerid], 1);

	Textdraw3[playerid] = CreatePlayerTextDraw(playerid, 525.000000, 128.088851, "Stunts");
	PlayerTextDrawLetterSize(playerid, Textdraw3[playerid], 0.451500, 2.016888);
	PlayerTextDrawAlignment(playerid, Textdraw3[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw3[playerid], 16777215);
	PlayerTextDrawSetShadow(playerid, Textdraw3[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw3[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw3[playerid], -16776961);
	PlayerTextDrawFont(playerid, Textdraw3[playerid], 2);
	PlayerTextDrawSetProportional(playerid, Textdraw3[playerid], 1);

	Textdraw4[playerid] = CreatePlayerTextDraw(playerid, 565.000000, 405.066650, "Build 17");
	PlayerTextDrawLetterSize(playerid, Textdraw4[playerid], 0.447499, 1.936000);
	PlayerTextDrawAlignment(playerid, Textdraw4[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw4[playerid], 16711935);
	PlayerTextDrawSetShadow(playerid, Textdraw4[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw4[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw4[playerid], -1523963137);
	PlayerTextDrawFont(playerid, Textdraw4[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Textdraw4[playerid], 1);

	Textdraw5[playerid] = CreatePlayerTextDraw(playerid, 644.000000, 149.500000, "usebox");
	PlayerTextDrawLetterSize(playerid, Textdraw5[playerid], 0.000000, -0.159259);
	PlayerTextDrawTextSize(playerid, Textdraw5[playerid], 442.500000, 0.000000);
	PlayerTextDrawAlignment(playerid, Textdraw5[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw5[playerid], 0);
	PlayerTextDrawUseBox(playerid, Textdraw5[playerid], true);
	PlayerTextDrawBoxColor(playerid, Textdraw5[playerid], 65535);
	PlayerTextDrawSetShadow(playerid, Textdraw5[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw5[playerid], 0);
	PlayerTextDrawFont(playerid, Textdraw5[playerid], 0);

	Textdraw6[playerid] = CreatePlayerTextDraw(playerid, 661.500000, 69.233337, "usebox");
	PlayerTextDrawLetterSize(playerid, Textdraw6[playerid], 0.000000, -0.040124);
	PlayerTextDrawTextSize(playerid, Textdraw6[playerid], 441.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, Textdraw6[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw6[playerid], 0);
	PlayerTextDrawUseBox(playerid, Textdraw6[playerid], true);
	PlayerTextDrawBoxColor(playerid, Textdraw6[playerid], 65535);
	PlayerTextDrawSetShadow(playerid, Textdraw6[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw6[playerid], 0);
	PlayerTextDrawFont(playerid, Textdraw6[playerid], 0);

	Textdraw7[playerid] = CreatePlayerTextDraw(playerid, 202.500000, 189.411102, "usebox");
	PlayerTextDrawLetterSize(playerid, Textdraw7[playerid], 0.000000, 11.392593);
	PlayerTextDrawTextSize(playerid, Textdraw7[playerid], 36.500000, 0.000000);
	PlayerTextDrawAlignment(playerid, Textdraw7[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw7[playerid], 0);
	PlayerTextDrawUseBox(playerid, Textdraw7[playerid], true);
	PlayerTextDrawBoxColor(playerid, Textdraw7[playerid], 102);
	PlayerTextDrawSetShadow(playerid, Textdraw7[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw7[playerid], 0);
	PlayerTextDrawFont(playerid, Textdraw7[playerid], 0);

	Textdraw8[playerid] = CreatePlayerTextDraw(playerid, 46.500000, 191.022186, "Server Statistics");
	PlayerTextDrawLetterSize(playerid, Textdraw8[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Textdraw8[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw8[playerid], -1523963137);
	PlayerTextDrawSetShadow(playerid, Textdraw8[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw8[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw8[playerid], -5963521);
	PlayerTextDrawFont(playerid, Textdraw8[playerid], 3);
	PlayerTextDrawSetProportional(playerid, Textdraw8[playerid], 1);

	Textdraw9[playerid] = CreatePlayerTextDraw(playerid, 201.500000, 211.188888, "usebox");
	PlayerTextDrawLetterSize(playerid, Textdraw9[playerid], 0.000000, -0.040124);
	PlayerTextDrawTextSize(playerid, Textdraw9[playerid], 36.500000, 0.000000);
	PlayerTextDrawAlignment(playerid, Textdraw9[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw9[playerid], 0);
	PlayerTextDrawUseBox(playerid, Textdraw9[playerid], true);
	PlayerTextDrawBoxColor(playerid, Textdraw9[playerid], -65281);
	PlayerTextDrawSetShadow(playerid, Textdraw9[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw9[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, Textdraw9[playerid], -65281);
	PlayerTextDrawFont(playerid, Textdraw9[playerid], 0);

	Textdraw10[playerid] = CreatePlayerTextDraw(playerid, 40.500000, 225.244445, "> Total Registered Users:");
	PlayerTextDrawLetterSize(playerid, Textdraw10[playerid], 0.228500, 1.375999);
	PlayerTextDrawAlignment(playerid, Textdraw10[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw10[playerid], -1378294017);
	PlayerTextDrawSetShadow(playerid, Textdraw10[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw10[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw10[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw10[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw10[playerid], 1);

	new TR[14];
	format(TR, sizeof(TR), "%d", gTotalRegisters);
	Textdraw11[playerid] = CreatePlayerTextDraw(playerid, 149.000000, 223.999969, TR);
	PlayerTextDrawLetterSize(playerid, Textdraw11[playerid], 0.342500, 1.544000);
	PlayerTextDrawAlignment(playerid, Textdraw11[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw11[playerid], -16776961);
	PlayerTextDrawSetShadow(playerid, Textdraw11[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw11[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw11[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw11[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw11[playerid], 1);

	Textdraw12[playerid] = CreatePlayerTextDraw(playerid, 39.500000, 238.311096, "> Total Server Kills:");
	PlayerTextDrawLetterSize(playerid, Textdraw12[playerid], 0.237500, 1.382222);
	PlayerTextDrawAlignment(playerid, Textdraw12[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw12[playerid], -1378294017);
	PlayerTextDrawSetShadow(playerid, Textdraw12[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw12[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw12[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw12[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw12[playerid], 1);

	new TK[14];
	format(TK, sizeof(TK), "%d", gTotalKills);
	Textdraw13[playerid] = CreatePlayerTextDraw(playerid, 130.000000, 235.822235, TK);
	PlayerTextDrawLetterSize(playerid, Textdraw13[playerid], 0.387499, 1.600000);
	PlayerTextDrawLetterSize(playerid, Textdraw13[playerid], 0.342500, 1.544000);
	PlayerTextDrawAlignment(playerid, Textdraw13[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw13[playerid], -16776961);
	PlayerTextDrawSetShadow(playerid, Textdraw13[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw13[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw13[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw13[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw13[playerid], 1);

	Textdraw14[playerid] = CreatePlayerTextDraw(playerid, 40.500000, 250.133270, "> Total Bans Issued:");
	PlayerTextDrawLetterSize(playerid, Textdraw14[playerid], 0.232500, 1.444444);
	PlayerTextDrawAlignment(playerid, Textdraw14[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw14[playerid], -1378294017);
	PlayerTextDrawSetShadow(playerid, Textdraw14[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw14[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw14[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw14[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw14[playerid], 1);

	new TB[14];
	format(TB, sizeof(TB), "%d", gTotalBans);
	Textdraw15[playerid] = CreatePlayerTextDraw(playerid, 130.500000, 248.888854, TB);
	PlayerTextDrawLetterSize(playerid, Textdraw15[playerid], 0.402499, 1.413333);
	PlayerTextDrawLetterSize(playerid, Textdraw15[playerid], 0.342500, 1.544000);
	PlayerTextDrawAlignment(playerid, Textdraw15[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw15[playerid], -16776961);
	PlayerTextDrawSetShadow(playerid, Textdraw15[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw15[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw15[playerid], 51);
	PlayerTextDrawFont(playerid, Textdraw15[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Textdraw15[playerid], 1);

	Textdraw16[playerid] = CreatePlayerTextDraw(playerid, 67.500000, 275.644378, "Enjoy!");
	PlayerTextDrawLetterSize(playerid, Textdraw16[playerid], 0.449999, 1.600000);
	PlayerTextDrawAlignment(playerid, Textdraw16[playerid], 1);
	PlayerTextDrawColor(playerid, Textdraw16[playerid], 16711935);
	PlayerTextDrawSetShadow(playerid, Textdraw16[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Textdraw16[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Textdraw16[playerid], -16711681);
	PlayerTextDrawFont(playerid, Textdraw16[playerid], 2);
	PlayerTextDrawSetProportional(playerid, Textdraw16[playerid], 1);

    gTextDraw[1] = TextDrawCreate(231.917984, 415.333343, "~y~Stunt~w~/~b~DM~w~/~g~Drift~w~/~g~Freeroam~w~/~r~Race~w~/~p~Fun~w~/~y~CnR~w~");
	TextDrawLetterSize(gTextDraw[1], 0.272498, 1.662222);
	TextDrawAlignment(gTextDraw[1], 1);
	TextDrawColor(gTextDraw[1], -1);
	TextDrawSetShadow(gTextDraw[1], 0);
	TextDrawSetOutline(gTextDraw[1], 1);
	TextDrawBackgroundColor(gTextDraw[1], 51);
	TextDrawFont(gTextDraw[1], 1);
	TextDrawSetProportional(gTextDraw[1], 1);
	//--------------------------------------------
    RemoveBuildingForPlayer(playerid, 9942, -1621.5469, 976.5938, 27.2656, 0.25);
    RemoveBuildingForPlayer(playerid, 9949, -1535.4219, 1054.5234, 18.2031, 0.25);
    RemoveBuildingForPlayer(playerid, 9964, -1535.4219, 1054.5234, 18.2031, 0.25);
    RemoveBuildingForPlayer(playerid, 9965, -1535.4219, 1168.6641, 18.2031, 0.25);
    RemoveBuildingForPlayer(playerid, 10012, -1767.9531, 1052.8984, 48.3047, 0.25);
    RemoveBuildingForPlayer(playerid, 10040, -1765.7422, 799.9453, 53.2266, 0.25);
    RemoveBuildingForPlayer(playerid, 10042, -1606.5625, 731.4375, 39.3359, 0.25);
    RemoveBuildingForPlayer(playerid, 731, -1585.7891, 782.3594, 5.1250, 0.25);
    RemoveBuildingForPlayer(playerid, 733, -1604.7422, 1253.6250, 5.5859, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1526.1641, 726.8125, 8.8047, 0.25);
    RemoveBuildingForPlayer(playerid, 3875, -1570.8750, 743.3047, 13.5313, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1526.1641, 748.0547, 8.8047, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1576.9688, 749.4375, 8.4297, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1589.9688, 769.2734, 8.4297, 0.25);
    RemoveBuildingForPlayer(playerid, 715, -1586.3984, 772.6094, 13.6719, 0.25);
    RemoveBuildingForPlayer(playerid, 715, -1581.1641, 757.6250, 13.6719, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1576.9688, 765.9453, 8.4297, 0.25);
    RemoveBuildingForPlayer(playerid, 1290, -1551.0547, 767.9063, 12.2891, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1524.9844, 769.3047, 8.8047, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1600.4297, 782.6563, 8.4297, 0.25);
    RemoveBuildingForPlayer(playerid, 649, -1596.6875, 782.5781, 5.5391, 0.25);
    RemoveBuildingForPlayer(playerid, 673, -1594.1484, 787.0625, 5.4141, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1576.9688, 782.4531, 8.4297, 0.25);
    RemoveBuildingForPlayer(playerid, 649, -1550.1953, 786.0547, 6.3359, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1522.8438, 790.5469, 8.8047, 0.25);
    RemoveBuildingForPlayer(playerid, 715, -1584.4609, 792.3906, 13.6719, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1576.9688, 798.9688, 8.4297, 0.25);
    RemoveBuildingForPlayer(playerid, 673, -1549.3984, 797.1172, 6.0859, 0.25);
    RemoveBuildingForPlayer(playerid, 673, -1581.5781, 802.9766, 5.4141, 0.25);
    RemoveBuildingForPlayer(playerid, 673, -1549.3984, 813.8047, 6.0859, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1576.9688, 815.4766, 8.4297, 0.25);
    RemoveBuildingForPlayer(playerid, 649, -1547.9766, 817.5781, 6.3359, 0.25);
    RemoveBuildingForPlayer(playerid, 1290, -1548.0078, 820.7734, 12.2891, 0.25);
    RemoveBuildingForPlayer(playerid, 3875, -1548.0469, 824.5938, 13.6641, 0.25);
    RemoveBuildingForPlayer(playerid, 737, -1585.0156, 829.0313, 6.7969, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, -1574.2344, 832.2031, 10.0781, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1517.8359, 833.0391, 8.8047, 0.25);
    RemoveBuildingForPlayer(playerid, 1284, -1572.4453, 852.6016, 9.3672, 0.25);
    RemoveBuildingForPlayer(playerid, 737, -1569.4453, 863.9453, 6.4766, 0.25);
    RemoveBuildingForPlayer(playerid, 1290, -1545.2734, 866.7734, 12.2891, 0.25);
    RemoveBuildingForPlayer(playerid, 3875, -1548.0469, 866.6250, 13.4766, 0.25);
    RemoveBuildingForPlayer(playerid, 3875, -1573.6641, 869.2266, 13.6172, 0.25);
    RemoveBuildingForPlayer(playerid, 649, -1541.3672, 869.6563, 6.3359, 0.25);
    RemoveBuildingForPlayer(playerid, 673, -1548.2266, 874.1016, 6.0859, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1513.8281, 875.5313, 8.8047, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, -1607.3828, 938.0859, 10.5391, 0.25);
    RemoveBuildingForPlayer(playerid, 673, -1540.6719, 898.0625, 6.0859, 0.25);
    RemoveBuildingForPlayer(playerid, 649, -1548.6250, 901.6953, 6.3359, 0.25);
    RemoveBuildingForPlayer(playerid, 3875, -1548.0469, 902.3672, 13.6641, 0.25);
    RemoveBuildingForPlayer(playerid, 737, -1569.4453, 908.9531, 6.4766, 0.25);
    RemoveBuildingForPlayer(playerid, 1290, -1544.6875, 904.6563, 12.2891, 0.25);
    RemoveBuildingForPlayer(playerid, 1284, -1572.3047, 918.0078, 9.3047, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1510.6641, 918.0234, 8.8047, 0.25);
    RemoveBuildingForPlayer(playerid, 3875, -1569.3125, 943.0313, 13.3594, 0.25);
    RemoveBuildingForPlayer(playerid, 1290, -1545.7266, 947.1563, 12.2891, 0.25);
    RemoveBuildingForPlayer(playerid, 649, -1548.0156, 956.5703, 6.3359, 0.25);
    RemoveBuildingForPlayer(playerid, 673, -1544.8828, 954.0938, 6.0859, 0.25);
    RemoveBuildingForPlayer(playerid, 3875, -1520.3672, 942.1719, 13.5625, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1516.1719, 960.5156, 8.8047, 0.25);
    RemoveBuildingForPlayer(playerid, 1290, -1667.2344, 1265.9063, 12.2891, 0.25);
    RemoveBuildingForPlayer(playerid, 1375, -1529.2266, 967.6484, 7.8359, 0.25);
    RemoveBuildingForPlayer(playerid, 9921, -1621.5469, 976.5938, 27.2656, 0.25);
    RemoveBuildingForPlayer(playerid, 1375, -1588.1797, 975.8750, 7.8359, 0.25);
    RemoveBuildingForPlayer(playerid, 3875, -1601.1563, 986.2344, 13.6094, 0.25);
    RemoveBuildingForPlayer(playerid, 1290, -1571.7578, 988.0000, 12.2891, 0.25);
    RemoveBuildingForPlayer(playerid, 649, -1574.0469, 992.9844, 6.3359, 0.25);
    RemoveBuildingForPlayer(playerid, 673, -1565.5547, 980.5938, 6.0859, 0.25);
    RemoveBuildingForPlayer(playerid, 1290, -1594.4063, 1034.0000, 12.2891, 0.25);
    RemoveBuildingForPlayer(playerid, 649, -1589.8984, 1016.5703, 6.3359, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1540.9063, 1000.9219, 8.8047, 0.25);
    RemoveBuildingForPlayer(playerid, 1290, -1594.4063, 1074.4219, 12.2891, 0.25);
    RemoveBuildingForPlayer(playerid, 1306, -1620.3828, 1090.4609, 13.6797, 0.25);
    RemoveBuildingForPlayer(playerid, 1290, -1594.4063, 1114.8438, 12.2891, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1567.0547, 1041.3203, 8.8047, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1567.0547, 1069.4063, 8.8047, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1567.0547, 1097.4922, 8.8047, 0.25);
    RemoveBuildingForPlayer(playerid, 3875, -1562.9063, 1080.0938, 13.5313, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1509.8672, 1086.4766, 8.8047, 0.25);
    RemoveBuildingForPlayer(playerid, 1283, -1631.5703, 1191.6563, 9.2891, 0.25);
    RemoveBuildingForPlayer(playerid, 1290, -1603.5859, 1193.1484, 12.2891, 0.25);
    RemoveBuildingForPlayer(playerid, 1290, -1618.9297, 1216.7656, 12.2891, 0.25);
    RemoveBuildingForPlayer(playerid, 759, -1609.3516, 1246.9688, 5.9219, 0.25);
    RemoveBuildingForPlayer(playerid, 759, -1601.4844, 1239.7344, 5.9219, 0.25);
    RemoveBuildingForPlayer(playerid, 759, -1603.6875, 1244.7188, 5.9219, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1509.8672, 1119.6719, 8.8047, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1567.0547, 1125.5781, 8.8047, 0.25);
    RemoveBuildingForPlayer(playerid, 1290, -1594.4063, 1155.2656, 12.2891, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1567.0547, 1153.6641, 8.8047, 0.25);
    RemoveBuildingForPlayer(playerid, 3875, -1588.9531, 1205.9141, 13.6250, 0.25);
    RemoveBuildingForPlayer(playerid, 9951, -1535.4219, 1168.6641, 18.2031, 0.25);
    RemoveBuildingForPlayer(playerid, 1232, -1507.7656, 1179.3047, 8.8047, 0.25);
    RemoveBuildingForPlayer(playerid, 1375, -1633.5078, 1257.9766, 7.9375, 0.25);
    RemoveBuildingForPlayer(playerid, 715, -1624.8125, 1273.2500, 14.4453, 0.25);
    RemoveBuildingForPlayer(playerid, 759, -1622.3984, 1273.3281, 5.9219, 0.25);
    RemoveBuildingForPlayer(playerid, 759, -1614.3047, 1257.8281, 5.9219, 0.25);
    RemoveBuildingForPlayer(playerid, 715, -1618.6172, 1261.0781, 14.4453, 0.25);
    RemoveBuildingForPlayer(playerid, 759, -1618.2188, 1273.3672, 5.9375, 0.25);
    RemoveBuildingForPlayer(playerid, 715, -1613.8047, 1277.3203, 14.4453, 0.25);
    RemoveBuildingForPlayer(playerid, 759, -1620.3828, 1279.4844, 5.9219, 0.25);
    RemoveBuildingForPlayer(playerid, 7202, 2797.3906, 2563.1094, 12.8906, 0.25);
    RemoveBuildingForPlayer(playerid, 7292, 2797.3906, 2562.6641, 10.5703, 0.25);
    RemoveBuildingForPlayer(playerid, 1268, 2919.1016, 2380.7422, 25.1563, 0.25);
    RemoveBuildingForPlayer(playerid, 1268, 2919.1016, 2415.8125, 25.1563, 0.25);
    RemoveBuildingForPlayer(playerid, 7304, 2918.7891, 2361.5313, 31.6016, 0.25);
    RemoveBuildingForPlayer(playerid, 620, 2895.6641, 2393.6406, 3.4609, 0.25);
    RemoveBuildingForPlayer(playerid, 1259, 2919.1016, 2380.7422, 25.1563, 0.25);
    RemoveBuildingForPlayer(playerid, 3460, 2903.1328, 2395.1172, 13.7656, 0.25);
    RemoveBuildingForPlayer(playerid, 1259, 2919.1016, 2415.8125, 25.1563, 0.25);
    RemoveBuildingForPlayer(playerid, 1319, -1923.5313, -2717.4922, 53.3594, 0.25);
    RemoveBuildingForPlayer(playerid, 1297, -1922.1484, -2703.8672, 56.3750, 0.25);
	//TamZer
	RemoveBuildingForPlayer(playerid, 708, 1966.7109, -1360.0938, 17.5859, 0.25);
    RemoveBuildingForPlayer(playerid, 5400, 1913.1328, -1370.5000, 17.7734, 0.25);
    RemoveBuildingForPlayer(playerid, 673, 1933.2422, -1376.1719, 13.3281, 0.25);
    //Sam's City
    RemoveBuildingForPlayer(playerid, 5156, 2838.0391, -2423.8828, 10.9609, 0.25);
    RemoveBuildingForPlayer(playerid, 5159, 2838.0313, -2371.9531, 7.2969, 0.25);
    RemoveBuildingForPlayer(playerid, 5160, 2829.9531, -2479.5703, 5.2656, 0.25);
    RemoveBuildingForPlayer(playerid, 5161, 2838.0234, -2358.4766, 21.3125, 0.25);
    RemoveBuildingForPlayer(playerid, 5162, 2838.0391, -2423.8828, 10.9609, 0.25);
    RemoveBuildingForPlayer(playerid, 5163, 2838.0391, -2532.7734, 17.0234, 0.25);
    RemoveBuildingForPlayer(playerid, 5164, 2838.1406, -2447.8438, 15.7266, 0.25);
    RemoveBuildingForPlayer(playerid, 5165, 2838.0313, -2520.1875, 18.4141, 0.25);
    RemoveBuildingForPlayer(playerid, 5166, 2829.9531, -2479.5703, 5.2656, 0.25);
    RemoveBuildingForPlayer(playerid, 5167, 2838.0313, -2371.9531, 7.2969, 0.25);
    RemoveBuildingForPlayer(playerid, 3689, 2685.3828, -2366.0547, 19.9531, 0.25);
    RemoveBuildingForPlayer(playerid, 3689, 2430.5859, -2583.9453, 20.5234, 0.25);
    RemoveBuildingForPlayer(playerid, 3707, 2716.2344, -2452.5938, 20.2031, 0.25);
    RemoveBuildingForPlayer(playerid, 3707, 2720.3203, -2530.9141, 19.9766, 0.25);
    RemoveBuildingForPlayer(playerid, 3707, 2480.8594, -2460.0547, 20.4922, 0.25);
    RemoveBuildingForPlayer(playerid, 3707, 2539.1797, -2424.3594, 20.4922, 0.25);
    RemoveBuildingForPlayer(playerid, 3690, 2685.3828, -2366.0547, 19.9531, 0.25);
    RemoveBuildingForPlayer(playerid, 3690, 2430.5859, -2583.9453, 20.5234, 0.25);
    RemoveBuildingForPlayer(playerid, 3688, 2387.8047, -2580.8672, 17.7891, 0.25);
    RemoveBuildingForPlayer(playerid, 3688, 2450.8750, -2680.4531, 17.7891, 0.25);
    RemoveBuildingForPlayer(playerid, 3687, 2503.5391, -2366.5078, 16.0469, 0.25);
    RemoveBuildingForPlayer(playerid, 3687, 2475.2578, -2394.7891, 16.0469, 0.25);
    RemoveBuildingForPlayer(playerid, 3687, 2450.5078, -2419.5391, 16.0469, 0.25);
    RemoveBuildingForPlayer(playerid, 3686, 2464.3047, -2617.0156, 16.0469, 0.25);
    RemoveBuildingForPlayer(playerid, 3710, 2788.1563, -2417.7891, 16.7266, 0.25);
    RemoveBuildingForPlayer(playerid, 3710, 2788.1563, -2455.8828, 16.7266, 0.25);
    RemoveBuildingForPlayer(playerid, 3710, 2788.1563, -2493.9844, 16.7266, 0.25);
    RemoveBuildingForPlayer(playerid, 3709, 2511.9609, -2608.0156, 17.0703, 0.25);
    RemoveBuildingForPlayer(playerid, 3709, 2511.9609, -2571.2422, 17.0703, 0.25);
    RemoveBuildingForPlayer(playerid, 3709, 2511.9609, -2535.4531, 17.0703, 0.25);
    RemoveBuildingForPlayer(playerid, 3709, 2660.4766, -2429.2969, 17.0703, 0.25);
    RemoveBuildingForPlayer(playerid, 3709, 2639.5469, -2429.2969, 17.0703, 0.25);
    RemoveBuildingForPlayer(playerid, 3709, 2618.8594, -2429.2969, 17.0703, 0.25);
    RemoveBuildingForPlayer(playerid, 3708, 2720.3203, -2530.9141, 19.9766, 0.25);
    RemoveBuildingForPlayer(playerid, 3708, 2716.2344, -2452.5938, 20.2031, 0.25);
    RemoveBuildingForPlayer(playerid, 3708, 2480.8594, -2460.0547, 20.4922, 0.25);
    RemoveBuildingForPlayer(playerid, 3708, 2539.1797, -2424.3594, 20.4922, 0.25);
    RemoveBuildingForPlayer(playerid, 3710, 2415.4609, -2468.5781, 16.7266, 0.25);
    RemoveBuildingForPlayer(playerid, 3744, 2771.0703, -2372.4453, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 3744, 2789.2109, -2377.6250, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 3744, 2774.7969, -2386.8516, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 3744, 2771.0703, -2520.5469, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 3744, 2774.7969, -2534.9531, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 3744, 2437.2109, -2490.0938, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 3744, 2399.4219, -2490.6797, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 3744, 2391.8750, -2503.5078, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 3744, 2551.5313, -2472.6953, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 3709, 2544.2500, -2524.0938, 16.4453, 0.25);
    RemoveBuildingForPlayer(playerid, 3709, 2544.2500, -2548.8125, 16.7031, 0.25);
    RemoveBuildingForPlayer(playerid, 3746, 2814.2656, -2356.5703, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 3746, 2814.2656, -2521.4922, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 3746, 2568.4453, -2483.3906, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 3746, 2563.1563, -2563.5781, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 3746, 2531.7031, -2629.2266, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 3746, 2519.8047, -2701.8750, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 3746, 2381.1016, -2701.8750, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 5325, 2488.9922, -2509.2578, 18.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 3746, 2422.7031, -2411.9219, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 3746, 2472.4453, -2362.9375, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 5335, 2829.9531, -2479.5703, 5.2656, 0.25);
    RemoveBuildingForPlayer(playerid, 5336, 2829.9531, -2479.5703, 5.2656, 0.25);
    RemoveBuildingForPlayer(playerid, 3770, 2795.8281, -2394.2422, 14.1719, 0.25);
    RemoveBuildingForPlayer(playerid, 3770, 2746.4063, -2453.4844, 14.0781, 0.25);
    RemoveBuildingForPlayer(playerid, 3770, 2507.3672, -2640.0703, 14.0781, 0.25);
    RemoveBuildingForPlayer(playerid, 3769, 2464.1250, -2571.6328, 15.1641, 0.25);
    RemoveBuildingForPlayer(playerid, 3769, 2400.9063, -2577.3359, 15.1641, 0.25);
    RemoveBuildingForPlayer(playerid, 5352, 2838.1953, -2488.6641, 29.3125, 0.25);
    RemoveBuildingForPlayer(playerid, 3620, 2381.1016, -2701.8750, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 1278, 2406.5469, -2695.0156, 26.6719, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2387.0547, -2667.7422, 16.4688, 0.25);
    RemoveBuildingForPlayer(playerid, 1413, 2392.1172, -2653.5625, 13.9375, 0.25);
    RemoveBuildingForPlayer(playerid, 1413, 2386.8438, -2653.5078, 13.9375, 0.25);
    RemoveBuildingForPlayer(playerid, 1413, 2397.3984, -2653.6250, 13.9375, 0.25);
    RemoveBuildingForPlayer(playerid, 1412, 2402.6719, -2653.6406, 13.9375, 0.25);
    RemoveBuildingForPlayer(playerid, 1413, 2407.9453, -2653.6484, 13.9375, 0.25);
    RemoveBuildingForPlayer(playerid, 1278, 2376.3281, -2630.0000, 26.6719, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2410.9766, -2632.8750, 16.4688, 0.25);
    RemoveBuildingForPlayer(playerid, 1278, 2376.3281, -2575.8750, 26.6719, 0.25);
    RemoveBuildingForPlayer(playerid, 3621, 2387.8047, -2580.8672, 17.7891, 0.25);
    RemoveBuildingForPlayer(playerid, 3574, 2391.8750, -2503.5078, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 3625, 2400.9063, -2577.3359, 15.1641, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2410.9766, -2562.8516, 16.4688, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2410.9766, -2535.2422, 16.4688, 0.25);
    RemoveBuildingForPlayer(playerid, 3574, 2399.4219, -2490.6797, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 3624, 2415.4609, -2468.5781, 16.7266, 0.25);
    RemoveBuildingForPlayer(playerid, 3620, 2519.8047, -2701.8750, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 1278, 2492.2031, -2695.0156, 26.6719, 0.25);
    RemoveBuildingForPlayer(playerid, 3621, 2450.8750, -2680.4531, 17.7891, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2478.6016, -2662.3828, 16.2969, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2424.2969, -2658.9844, 16.2969, 0.25);
    RemoveBuildingForPlayer(playerid, 1635, 2430.5781, -2653.9453, 23.7188, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2450.0156, -2632.7734, 16.3594, 0.25);
    RemoveBuildingForPlayer(playerid, 1306, 2469.6016, -2645.3203, 19.8438, 0.25);
    RemoveBuildingForPlayer(playerid, 3578, 2470.1406, -2628.2656, 13.1719, 0.25);
    RemoveBuildingForPlayer(playerid, 3626, 2507.3672, -2640.0703, 14.0781, 0.25);
    RemoveBuildingForPlayer(playerid, 3620, 2531.7031, -2629.2266, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 3627, 2464.3047, -2617.0156, 16.0469, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2450.0156, -2604.9297, 16.3594, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2480.3281, -2588.3281, 16.3594, 0.25);
    RemoveBuildingForPlayer(playerid, 1306, 2469.6016, -2579.9844, 19.8438, 0.25);
    RemoveBuildingForPlayer(playerid, 3625, 2464.1250, -2571.6328, 15.1641, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2489.3516, -2625.7109, 16.2969, 0.25);
    RemoveBuildingForPlayer(playerid, 1306, 2498.3438, -2612.6563, 19.8438, 0.25);
    RemoveBuildingForPlayer(playerid, 1413, 2496.5547, -2585.1797, 13.9063, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2489.3516, -2566.2734, 16.2969, 0.25);
    RemoveBuildingForPlayer(playerid, 1413, 2501.8359, -2585.2422, 13.9063, 0.25);
    RemoveBuildingForPlayer(playerid, 1635, 2511.8359, -2622.6172, 17.3906, 0.25);
    RemoveBuildingForPlayer(playerid, 3623, 2511.9609, -2608.0156, 17.0703, 0.25);
    RemoveBuildingForPlayer(playerid, 3623, 2511.9609, -2571.2422, 17.0703, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2450.0156, -2563.2188, 16.3594, 0.25);
    RemoveBuildingForPlayer(playerid, 1413, 2496.5547, -2557.3359, 13.9063, 0.25);
    RemoveBuildingForPlayer(playerid, 1413, 2501.8359, -2557.3984, 13.9063, 0.25);
    RemoveBuildingForPlayer(playerid, 1306, 2498.3438, -2547.3203, 19.8438, 0.25);
    RemoveBuildingForPlayer(playerid, 1278, 2470.2734, -2539.0234, 26.6719, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2450.0156, -2535.5703, 16.3594, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2480.3281, -2536.4375, 16.3594, 0.25);
    RemoveBuildingForPlayer(playerid, 3578, 2470.1406, -2530.5547, 13.1719, 0.25);
    RemoveBuildingForPlayer(playerid, 1306, 2469.6016, -2514.6484, 19.8438, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2435.8203, -2512.4844, 16.4688, 0.25);
    RemoveBuildingForPlayer(playerid, 3574, 2437.2109, -2490.0938, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 1306, 2498.3438, -2481.9766, 19.8438, 0.25);
    RemoveBuildingForPlayer(playerid, 1635, 2471.5859, -2494.0703, 15.0781, 0.25);
    RemoveBuildingForPlayer(playerid, 1306, 2444.3281, -2435.0625, 19.8438, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2461.9141, -2444.3438, 16.3672, 0.25);
    RemoveBuildingForPlayer(playerid, 3578, 2526.4297, -2561.3047, 13.1719, 0.25);
    RemoveBuildingForPlayer(playerid, 3623, 2544.2500, -2548.8125, 16.7031, 0.25);
    RemoveBuildingForPlayer(playerid, 3623, 2511.9609, -2535.4531, 17.0703, 0.25);
    RemoveBuildingForPlayer(playerid, 3623, 2544.2500, -2524.0938, 16.4453, 0.25);
    RemoveBuildingForPlayer(playerid, 1306, 2533.3906, -2514.1094, 19.8438, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2528.4844, -2508.3047, 16.3594, 0.25);
    RemoveBuildingForPlayer(playerid, 1278, 2533.6172, -2461.6875, 26.6719, 0.25);
    RemoveBuildingForPlayer(playerid, 3574, 2551.5313, -2472.6953, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 3620, 2563.1563, -2563.5781, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2558.0859, -2499.5938, 16.3594, 0.25);
    RemoveBuildingForPlayer(playerid, 3620, 2568.4453, -2483.3906, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2624.3281, -2452.1484, 16.4141, 0.25);
    RemoveBuildingForPlayer(playerid, 1635, 2459.3359, -2427.8281, 16.7422, 0.25);
    RemoveBuildingForPlayer(playerid, 3622, 2450.5078, -2419.5391, 16.0469, 0.25);
    RemoveBuildingForPlayer(playerid, 3578, 2468.8594, -2413.5234, 13.1719, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2482.2031, -2412.1094, 16.3203, 0.25);
    RemoveBuildingForPlayer(playerid, 3620, 2422.7031, -2411.9219, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2502.3281, -2404.0781, 16.3672, 0.25);
    RemoveBuildingForPlayer(playerid, 1635, 2483.7188, -2403.3438, 16.7422, 0.25);
    RemoveBuildingForPlayer(playerid, 1306, 2455.0703, -2399.0156, 19.8438, 0.25);
    RemoveBuildingForPlayer(playerid, 3622, 2475.2578, -2394.7891, 16.0469, 0.25);
    RemoveBuildingForPlayer(playerid, 1306, 2491.7031, -2383.3281, 19.8438, 0.25);
    RemoveBuildingForPlayer(playerid, 3578, 2495.8438, -2386.9375, 13.1719, 0.25);
    RemoveBuildingForPlayer(playerid, 3620, 2472.4453, -2362.9375, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 3622, 2503.5391, -2366.5078, 16.0469, 0.25);
    RemoveBuildingForPlayer(playerid, 3578, 2546.0469, -2396.5938, 13.1719, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2535.6875, -2377.6563, 16.3672, 0.25);
    RemoveBuildingForPlayer(playerid, 1635, 2512.0078, -2375.0859, 16.7422, 0.25);
    RemoveBuildingForPlayer(playerid, 1306, 2513.0000, -2339.3281, 19.8438, 0.25);
    RemoveBuildingForPlayer(playerid, 3578, 2571.1641, -2421.1328, 13.1719, 0.25);
    RemoveBuildingForPlayer(playerid, 1278, 2592.4922, -2359.4219, 26.7031, 0.25);
    RemoveBuildingForPlayer(playerid, 3623, 2618.8594, -2429.2969, 17.0703, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2624.3281, -2409.5625, 16.4141, 0.25);
    RemoveBuildingForPlayer(playerid, 1278, 2626.2344, -2391.5234, 26.7031, 0.25);
    RemoveBuildingForPlayer(playerid, 1278, 2674.5234, -2557.4922, 26.7031, 0.25);
    RemoveBuildingForPlayer(playerid, 1306, 2669.9063, -2518.6641, 19.8438, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2674.2656, -2508.3047, 16.3594, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2713.0625, -2508.3047, 16.3594, 0.25);
    RemoveBuildingForPlayer(playerid, 1315, 2672.5938, -2506.8594, 15.8125, 0.25);
    RemoveBuildingForPlayer(playerid, 1315, 2680.8594, -2493.0781, 15.8125, 0.25);
    RemoveBuildingForPlayer(playerid, 1635, 2704.3672, -2487.8672, 20.5625, 0.25);
    RemoveBuildingForPlayer(playerid, 1306, 2742.2656, -2481.5156, 19.8438, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2696.0234, -2474.8594, 16.4141, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2675.5703, -2466.8516, 16.4141, 0.25);
    RemoveBuildingForPlayer(playerid, 5326, 2661.5156, -2465.1406, 20.1094, 0.25);
    RemoveBuildingForPlayer(playerid, 1306, 2669.9063, -2447.2891, 19.8438, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2696.0234, -2446.6250, 16.4141, 0.25);
    RemoveBuildingForPlayer(playerid, 3623, 2639.5469, -2429.2969, 17.0703, 0.25);
    RemoveBuildingForPlayer(playerid, 3623, 2660.4766, -2429.2969, 17.0703, 0.25);
    RemoveBuildingForPlayer(playerid, 1307, 2629.2109, -2419.6875, 12.2891, 0.25);
    RemoveBuildingForPlayer(playerid, 1307, 2649.8984, -2419.6875, 12.2891, 0.25);
    RemoveBuildingForPlayer(playerid, 1315, 2686.7578, -2416.6250, 15.8125, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2663.5078, -2409.5625, 16.4141, 0.25);
    RemoveBuildingForPlayer(playerid, 1315, 2672.5938, -2408.2500, 15.8125, 0.25);
    RemoveBuildingForPlayer(playerid, 1306, 2742.2656, -2416.5234, 19.8438, 0.25);
    RemoveBuildingForPlayer(playerid, 3578, 2639.1953, -2392.8203, 13.1719, 0.25);
    RemoveBuildingForPlayer(playerid, 3578, 2663.8359, -2392.8203, 13.1719, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2637.1719, -2385.8672, 16.4141, 0.25);
    RemoveBuildingForPlayer(playerid, 1306, 2669.9063, -2394.5078, 19.8438, 0.25);
    RemoveBuildingForPlayer(playerid, 1226, 2692.6797, -2387.4766, 16.4141, 0.25);
    RemoveBuildingForPlayer(playerid, 1278, 2708.4063, -2391.5234, 26.7031, 0.25);
    RemoveBuildingForPlayer(playerid, 3574, 2774.7969, -2534.9531, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 3574, 2771.0703, -2520.5469, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 3761, 2783.7813, -2501.8359, 14.6953, 0.25);
    RemoveBuildingForPlayer(playerid, 3624, 2788.1563, -2493.9844, 16.7266, 0.25);
    RemoveBuildingForPlayer(playerid, 3761, 2783.7813, -2486.9609, 14.6563, 0.25);
    RemoveBuildingForPlayer(playerid, 3578, 2747.0078, -2480.2422, 13.1719, 0.25);
    RemoveBuildingForPlayer(playerid, 3761, 2783.7813, -2463.8203, 14.6328, 0.25);
    RemoveBuildingForPlayer(playerid, 1278, 2773.3438, -2479.9688, 26.7031, 0.25);
    RemoveBuildingForPlayer(playerid, 3624, 2788.1563, -2455.8828, 16.7266, 0.25);
    RemoveBuildingForPlayer(playerid, 3626, 2746.4063, -2453.4844, 14.0781, 0.25);
    RemoveBuildingForPlayer(playerid, 3761, 2783.7813, -2448.4766, 14.6328, 0.25);
    RemoveBuildingForPlayer(playerid, 1278, 2773.3438, -2443.1719, 26.7031, 0.25);
    RemoveBuildingForPlayer(playerid, 3577, 2744.5703, -2436.1875, 13.3438, 0.25);
    RemoveBuildingForPlayer(playerid, 3577, 2744.5703, -2427.3203, 13.3516, 0.25);
    RemoveBuildingForPlayer(playerid, 3761, 2783.7813, -2425.3516, 14.6328, 0.25);
    RemoveBuildingForPlayer(playerid, 3574, 2774.7969, -2386.8516, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 3574, 2771.0703, -2372.4453, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 3761, 2783.7813, -2410.2109, 14.6719, 0.25);
    RemoveBuildingForPlayer(playerid, 3624, 2788.1563, -2417.7891, 16.7266, 0.25);
    RemoveBuildingForPlayer(playerid, 3574, 2789.2109, -2377.6250, 15.2188, 0.25);
    RemoveBuildingForPlayer(playerid, 1278, 2802.4297, -2556.5234, 26.7031, 0.25);
    RemoveBuildingForPlayer(playerid, 3761, 2791.9531, -2501.8359, 14.6328, 0.25);
    RemoveBuildingForPlayer(playerid, 3761, 2797.5156, -2486.8281, 14.6328, 0.25);
    RemoveBuildingForPlayer(playerid, 3761, 2791.9531, -2486.9609, 14.6328, 0.25);
    RemoveBuildingForPlayer(playerid, 3761, 2791.9531, -2463.8203, 14.6328, 0.25);
    RemoveBuildingForPlayer(playerid, 3761, 2797.5156, -2448.3438, 14.6328, 0.25);
    RemoveBuildingForPlayer(playerid, 3761, 2791.9531, -2448.4766, 14.6328, 0.25);
    RemoveBuildingForPlayer(playerid, 3761, 2791.9531, -2425.3516, 14.6719, 0.25);
    RemoveBuildingForPlayer(playerid, 3761, 2791.9531, -2410.2109, 14.6563, 0.25);
    RemoveBuildingForPlayer(playerid, 3761, 2797.5156, -2410.0781, 14.6328, 0.25);
    RemoveBuildingForPlayer(playerid, 3626, 2795.8281, -2394.2422, 14.1719, 0.25);
    RemoveBuildingForPlayer(playerid, 3620, 2814.2656, -2521.4922, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 5157, 2838.0391, -2532.7734, 17.0234, 0.25);
    RemoveBuildingForPlayer(playerid, 5154, 2838.1406, -2447.8438, 15.7500, 0.25);
    RemoveBuildingForPlayer(playerid, 3724, 2838.1953, -2488.6641, 29.3125, 0.25);
    RemoveBuildingForPlayer(playerid, 3620, 2814.2656, -2356.5703, 25.5156, 0.25);
    RemoveBuildingForPlayer(playerid, 5155, 2838.0234, -2358.4766, 21.3125, 0.25);
    RemoveBuildingForPlayer(playerid, 3724, 2838.1953, -2407.1406, 29.3125, 0.25);
    RemoveBuildingForPlayer(playerid, 1278, 2762.7578, -2333.3828, 26.7031, 0.25);
    RemoveBuildingForPlayer(playerid, 1278, 2804.2422, -2333.3828, 26.7031, 0.25);
    RemoveBuildingForPlayer(playerid, 5158, 2837.7734, -2334.4766, 11.9922, 0.25);
    RemoveBuildingForPlayer(playerid, 3337, 426.8750, 621.2344, 16.8828, 0.25);
    RemoveBuildingForPlayer(playerid, 4246, 272.4844, -2210.7031, -29.2578, 0.25);
    RemoveBuildingForPlayer(playerid, 4381, 272.4844, -2210.7031, -29.2578, 0.25);
    RemoveBuildingForPlayer(playerid, 3880, -1738.0313, -442.8750, 0.0625, 0.25);
    RemoveBuildingForPlayer(playerid, 3879, -1738.0313, -442.8750, 0.0625, 0.25);
    RemoveBuildingForPlayer(playerid, 1278, -1244.9219, 5.1250, 25.3359, 0.25);
    RemoveBuildingForPlayer(playerid, 3489, 1609.3359, 1671.6953, 16.4375, 0.25);
    RemoveBuildingForPlayer(playerid, 3490, 1609.3359, 1671.6953, 16.4375, 0.25);
    RemoveBuildingForPlayer(playerid, 3489, 1677.2969, 1671.6953, 16.4375, 0.25);
    RemoveBuildingForPlayer(playerid, 3490, 1677.2969, 1671.6953, 16.4375, 0.25);
    RemoveBuildingForPlayer(playerid, 8338, 1641.1328, 1629.4063, 13.8203, 0.25);
    RemoveBuildingForPlayer(playerid, 8345, 1583.9844, 1516.7188, 13.3281, 0.25);
    RemoveBuildingForPlayer(playerid, 8339, 1641.1328, 1629.4063, 13.8203, 0.25);
    RemoveBuildingForPlayer(playerid, 4286, 801.6563, -2711.4531, -24.0547, 0.25);
    RemoveBuildingForPlayer(playerid, 4294, -1966.2969, -2928.6250, -33.5000, 0.25);
    RemoveBuildingForPlayer(playerid, 4420, 801.6563, -2711.4531, -24.0547, 0.25);
    RemoveBuildingForPlayer(playerid, 4428, -1966.2969, -2928.6250, -33.5000, 0.25);
    RemoveBuildingForPlayer(playerid, 13052, -69.0469, 86.8359, 2.1094, 0.25);
    RemoveBuildingForPlayer(playerid, 13053, -59.9531, 110.4609, 13.4766, 0.25);
    RemoveBuildingForPlayer(playerid, 3376, -96.0859, 3.1953, 6.6953, 0.25);
    RemoveBuildingForPlayer(playerid, 3376, -15.5234, 68.4531, 6.6641, 0.25);
    RemoveBuildingForPlayer(playerid, 13477, -21.9453, 101.3906, 4.5313, 0.25);
    RemoveBuildingForPlayer(playerid, 3375, -96.0859, 3.1953, 6.6953, 0.25);
    RemoveBuildingForPlayer(playerid, 3276, -94.5234, 31.6172, 2.8828, 0.25);
    RemoveBuildingForPlayer(playerid, 3276, -90.5313, 42.1484, 2.8828, 0.25);
    RemoveBuildingForPlayer(playerid, 3276, -81.8984, 56.8516, 2.8828, 0.25);
    RemoveBuildingForPlayer(playerid, 3276, -71.8359, 58.8750, 2.8828, 0.25);
    RemoveBuildingForPlayer(playerid, 3374, -92.8672, 58.3438, 3.5703, 0.25);
    RemoveBuildingForPlayer(playerid, 3374, -91.9453, 47.8125, 3.5703, 0.25);
    RemoveBuildingForPlayer(playerid, 3375, -15.5234, 68.4531, 6.6641, 0.25);
    RemoveBuildingForPlayer(playerid, 12915, -69.0469, 86.8359, 2.1094, 0.25);
    RemoveBuildingForPlayer(playerid, 672, -15.2109, 94.8438, 3.4766, 0.25);
    RemoveBuildingForPlayer(playerid, 3374, -41.2500, 98.4141, 3.4609, 0.25);
    RemoveBuildingForPlayer(playerid, 3374, -36.0156, 96.1875, 3.5703, 0.25);
    RemoveBuildingForPlayer(playerid, 12912, -59.9531, 110.4609, 13.4766, 0.25);
    RemoveBuildingForPlayer(playerid, 12913, -21.9453, 101.3906, 4.5313, 0.25);
    RemoveBuildingForPlayer(playerid, 3276, -88.4688, 122.1953, 2.9531, 0.25);
    RemoveBuildingForPlayer(playerid, 3276, -32.6484, 121.0938, 2.9531, 0.25);
    RemoveBuildingForPlayer(playerid, 3276, -23.6563, 114.0000, 2.9531, 0.25);
    RemoveBuildingForPlayer(playerid, 672, -71.7109, 135.3438, 1.8281, 0.25);
    RemoveBuildingForPlayer(playerid, 3276, -84.3984, 133.5859, 2.9531, 0.25);
    RemoveBuildingForPlayer(playerid, 3276, -34.9297, 131.5469, 2.9531, 0.25);
    RemoveBuildingForPlayer(playerid, 3276, -51.7188, 145.9609, 2.9531, 0.25);
    RemoveBuildingForPlayer(playerid, 3276, -72.5234, 152.5000, 2.9531, 0.25);
    RemoveBuildingForPlayer(playerid, 3276, -62.5313, 151.3906, 2.9531, 0.25);
    RemoveBuildingForPlayer(playerid, 3276, -24.5625, 154.5234, 2.2969, 0.25);
    RemoveBuildingForPlayer(playerid, 3276, -34.2969, 160.0156, 2.3203, 0.25);
    RemoveBuildingForPlayer(playerid, 705, -71.2422, 174.6641, 1.1172, 0.25);

	new CNRName[128];
	new CNRFile[128];
	GetPlayerName(playerid, CNRName, sizeof(CNRName));
    format(CNRFile, sizeof(CNRFile), savefolder,CNRName);
    if(!dini_Exists(CNRFile)) {
        dini_Create(CNRFile);
        dini_IntSet(CNRFile, "Arrests", PlayerInfo[playerid][Arrests]);
        dini_IntSet(CNRFile, "Takedowns", PlayerInfo[playerid][Takedowns]);
        dini_IntSet(CNRFile, "Robberies", PlayerInfo[playerid][Robberies]);
        dini_IntSet(CNRFile, "PlayerRobberies", PlayerInfo[playerid][PlayerRobberies]);
        dini_IntSet(CNRFile, "CopsKilled", PlayerInfo[playerid][CopsKilled]);
        dini_IntSet(CNRFile, "Timearrested", PlayerInfo[playerid][Timearrested]);
    }
    else {
        PlayerInfo[playerid][Arrests] = dini_Int(CNRFile, "Arrests");
        PlayerInfo[playerid][Takedowns] = dini_Int(CNRFile, "Takedowns");
        PlayerInfo[playerid][Robberies] = dini_Int(CNRFile, "Robberies");
        PlayerInfo[playerid][PlayerRobberies] = dini_Int(CNRFile, "PlayerRobberies");
        PlayerInfo[playerid][CopsKilled] = dini_Int(CNRFile, "CopsKilled");
        PlayerInfo[playerid][Timearrested] = dini_Int(CNRFile, "Timearrested");
    }
    players_connected++;
	PlayerInfo[playerid][pCar] = 0;
	pos_x[playerid] = 0;
	pos_y[playerid] = 0;
	pos_z[playerid] = 0;
	seconds[playerid] = 0;
	AutoFix[playerid] = 1;
	Nitro[playerid] = 1;
	Bounce[playerid] = 1;
	SBvalue[playerid] = 1.5;
	killstreak[playerid] = 0;
    SetPVarInt(playerid, "InDM", 0);
    SetPVarInt(playerid, "InDCnR", 0);
    SetPVarInt(playerid, "InRace", 0);
	//vehicle
	PlayerInfo[playerid][pCar] = INVALID_VEHICLE_ID;
	Veh[playerid][VehId] = INVALID_VEHICLE_ID;
	DestroyNeonObjects(playerid);
	LoadDuelSpecTextdraw(playerid);
    ResetDuelInvites(playerid);
    SetPVarInt(playerid, "DuelDID", -1);
	InDuel[playerid] = 0;
    ExitAnim[playerid] = 0;
    ChosenStyle[playerid] = 0;
    Offer[playerid] = -1;
    gPlayerUsingLoopingAnim[playerid] = 0;
	gPlayerAnimLibsPreloaded[playerid] = 0;
	AntifallEnabled[playerid] = 1;
	InDeathMatch[playerid] = 0;
	PlayerInfo[playerid][Goto] = 0;
	PlayerInfo[playerid][isAFK] = 0;
	PlayerInfo[playerid][inDerby] = 0;
	PlayerInfo[playerid][Spawned] = 0;
	PlayerInfo[playerid][LoginFail] = 0;
	PlayerInfo[playerid][LoggedIn] = 0;
	PlayerInfo[playerid][inDM] = 0;
	PlayerInfo[playerid][inMini] = 0;
	PlayerInfo[playerid][inDMZone] = 0;
	PlayerInfo[playerid][WeaponSet] = 0;
	PlayerInfo[playerid][Skin] = 0;
	PlayerInfo[playerid][POS_X] = 0;
	PlayerInfo[playerid][POS_Y] = 0;
	PlayerInfo[playerid][POS_Z] = 0;
	PlayerInfo[playerid][RegOn] = 0;
	PlayerInfo[playerid][AltName] = 0;
	PlayerInfo[playerid][Helmet] = 0;
	PlayerInfo[playerid][GodEnabled] = 0;
	pInvincible[playerid] = false;
	// Setup local variables
	new BusID, BusSlot, PName[24];
	// Get the player's name
	GetPlayerName(playerid, PName, sizeof(PName));
	// Loop through all businesses to find the ones which belong to this player
	for (BusID = 1; BusID < MAX_BUSINESS; BusID++)
	{
		// Check if the business exists
		if (IsValidDynamicPickup(ABusinessData[BusID][PickupID]))
		{
		    // Check if the business is owned
		    if (ABusinessData[BusID][Owned] == true)
		    {
		        // Check if the player is the owner of the business
				if (strcmp(ABusinessData[BusID][Owner], PName, false) == 0)
				{
					// Add the BusID to the player's account for faster reference later on
					APlayerData[playerid][Business][BusSlot] = BusID;
					// Select the next BusSlot
					BusSlot++;
				}
		    }
		}
	}
	PlayerTextDrawShow(playerid, Textdraw0[playerid]);
	PlayerTextDrawShow(playerid, Textdraw1[playerid]);
	PlayerTextDrawShow(playerid, Textdraw2[playerid]);
	PlayerTextDrawShow(playerid, Textdraw3[playerid]);
	PlayerTextDrawShow(playerid, Textdraw4[playerid]);
	PlayerTextDrawShow(playerid, Textdraw5[playerid]);
	PlayerTextDrawShow(playerid, Textdraw6[playerid]);
	PlayerTextDrawShow(playerid, Textdraw7[playerid]);
 	PlayerTextDrawShow(playerid, Textdraw8[playerid]);
 	PlayerTextDrawShow(playerid, Textdraw9[playerid]);
 	PlayerTextDrawShow(playerid, Textdraw10[playerid]);
 	PlayerTextDrawShow(playerid, Textdraw11[playerid]);
 	PlayerTextDrawShow(playerid, Textdraw12[playerid]);
 	PlayerTextDrawShow(playerid, Textdraw13[playerid]);
 	PlayerTextDrawShow(playerid, Textdraw14[playerid]);
 	PlayerTextDrawShow(playerid, Textdraw15[playerid]);
 	PlayerTextDrawShow(playerid, Textdraw16[playerid]);
	if ( fexist( bankFile( playerid ) ) ) {
 		INI_ParseFile( bankFile( playerid ), "parsePlayerBank", .bExtra = true, .extra = playerid );
		bAcc{ playerid } = true;
	}
	else {
	    bAcc{ playerid } = false;
	}
    new lastrestart[128];
	SendClientMessage(playerid, COLOR_FIREBRICK, "*** {FFB10A}Welcome to {FFB10A}The Best Stunts - Official{F7BD3E}! Currently running on "#VERSION"!");
	SendClientMessage(playerid, COLOR_FIREBRICK, "*** {F7BD3E}Commands: /cmds {B22222}|| {F7BD3E}Teleports: /teles {B22222} || {F7BD3E}Latest Update: /changelog {B22222}");
	format(lastrestart, sizeof(lastrestart), "*** {33AA33}The server was last restarted at %s on %s.", gLastRestartedTime, gLastRestartedDate);
	SendClientMessage(playerid, COLOR_FIREBRICK, lastrestart);
	if (fexist(UserPath(playerid)))
	{
		//PlayAudioStreamForPlayer(playerid, "http://62.75.158.36:8000/stream");
	    SetPlayerColor(playerid, PlayerInfo[playerid][Color]);
		INI_ParseFile(UserPath(playerid), "loadaccount_%s", .bExtra = true, .extra = playerid);
		//SetPlayerCameraLookAt(playerid, -2306.2190,-1622.4716,502.7734, CAMERA_CUT);
		new stri[250]; //, str2[128]
  		SetPlayerColor(playerid, PlayerInfo[playerid][Color]);
		format(stri, sizeof(stri), "** Welcome back, %s! You were last online on {CB6CE6}%s{FFB6C1}!", GetName(playerid), lastactive);
		SendClientMessage(playerid, COLOR_PINK, stri);
		//format(str2, sizeof(str2), "** You have been online for %i hours and %i minutes in total.", PlayerInfo[playerid][Hours], PlayerInfo[playerid][Minutes]);
		//SendClientMessage(playerid, 0xFFD70075, str2);
		SpawnPlayer(playerid);
		gOnlineTime = SetTimerEx("TimeOnServer", 60000, true, "i", playerid);
		PlayerInfo[playerid][Spawned] = 1;
		PlayerInfo[playerid][LoggedIn] = 1;
	}
	else
	{
 		//PlayAudioStreamForPlayer(playerid, "http://62.75.158.36:8000/stream");
	    new str[200];
		new random_color = ( 16777216 * random( 256 ) ) + ( 65536 * random( 256 ) ) + ( 256 * random( 256 ) ) + 255;
		format(str, sizeof(str), ""RED"[TBS] {%06x}%s(%d) {2BD9F8}has joined the server for the first time!", random_color >>> 8, GetName(playerid), playerid, players_connected);
  		SendClientMessageToAll(0x2BD9F8FF, str);
		SetPlayerColor(playerid, random_color);
		new  date[20], year, month, day;
		getdate(year, month, day);
		format(date, sizeof(date), "%d/%d/%d", day, month, year);
		new INI:File = INI_Open(UserPath(playerid));
		INI_Close(File);
		gTotalRegisters++;
        GivePlayerMoneyEx(playerid, 5000);
        PlayerInfo[playerid][POS_X] = -2355.9038;
        PlayerInfo[playerid][POS_Y] = -1635.4912;
        PlayerInfo[playerid][POS_Z] = 483.7031;
        PlayerInfo[playerid][Helmet] = 1;
        PlayerInfo[playerid][RegOn] = date;
	    PlayerInfo[playerid][Races] = 0;
		SpawnPlayer(playerid);
   		new INI:FILE_SERVER_STATS = INI_Open(ServerStats);
    	INI_SetTag(FILE_SERVER_STATS, "Server_Statistics");
		INI_WriteInt(FILE_SERVER_STATS, "Total_Registered_Users", gTotalRegisters);
		INI_Close(FILE_SERVER_STATS);
  		PlayerInfo[playerid][Spawned] = 1;
  		PlayerInfo[playerid][LoggedIn] = 1;
  	}
    EnableStuntBonusForAll(false);
    SendDeathMessage(INVALID_PLAYER_ID, playerid, 200);
	new filename[HOUSEFILE_LENGTH], string3[MAX_PLAYER_NAME], string2[MAX_HOUSE_NAME], _tmpstring[256];
	format(filename, sizeof(filename), USERPATH, pNick(playerid));
	if(fexist(filename))
	{
	    new hs = GetPVarInt(playerid, "GA_TMP_HOUSESTORAGE"), price = GetPVarInt(playerid, "GA_TMP_HOUSEFORSALEPRICE");
	    INI_ParseFile(filename, "LoadUserData", false, true, playerid, true, false);
	    fremove(filename);
		GetPVarString(playerid, "GA_TMP_NEWHOUSEOWNER", string2, MAX_PLAYER_NAME);
		GetPVarString(playerid, "GA_TMP_HOUSENAME", string1, MAX_HOUSE_NAME);
		CMDSString = "";
		format(_tmpstring, sizeof(_tmpstring), HSELLER_OFFLINE_MSG1, string3, string2);
		strcat(CMDSString, _tmpstring);
		format(_tmpstring, sizeof(_tmpstring), HSELLER_OFFLINE_MSG2, (hs + price), hs, price);
		strcat(CMDSString, _tmpstring);
		ShowInfoBoxEx(playerid, COLOUR_INFO, CMDSString);
		DeletePVar(playerid, "GA_TMP_HOUSESTORAGE"), DeletePVar(playerid, "GA_TMP_HOUSEFORSALEPRICE"), DeletePVar(playerid, "GA_TMP_NEWHOUSEOWNER"), DeletePVar(playerid, "GA_TMP_HOUSENAME");
 	}
 	SetPVarInt(playerid, "HouseRobberyTimer", -1);
 	IsInHouse{playerid} = 0;
	PlayerInfo[playerid][aMember] = -1;
    PlayerInfo[playerid][aLeader] = -1;
    new str[128]; format(str,sizeof(str),"Gangs/Users/%s",GetName(playerid));
    if(fexist(str))
    {
  	    INI_ParseFile(str, "LoadPlayer_%s", .bExtra = true, .extra = playerid);
    }
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	DestroyDynamic3DTextLabel(MWLabel[playerid]);
    lastcommand[playerid] = 0;
    CallRemoteFunction("CallDisconnect","ii",playerid,reason);
    SendDeathMessage(INVALID_PLAYER_ID, playerid, 201);
	if (PlayerInfo[playerid][Spawned] == 1)
	{
		SaveStats(playerid);
	}
	switch (PlayerInfo[playerid][inDMZone])
	{
	    case 0:
	    {
	        gFDMPlayers--;
		}
		case 1:
		{
		    gWARPlayers--;
		}
		case 2:
		{
		    gMINIPlayers--;
		}
    	case 3:
		{
		    gEAGLEPlayers--;
		}
    	case 4:
		{
		    gRDMPlayers--;
		}
    	case 5:
		{
		    gODMPlayers--;
		}
    	case 6:
		{
		    gSAWNDMPlayers--;
		}
	}
	new CNRName[128], CNRFile[128];
	GetPlayerName(playerid, CNRName, sizeof(CNRName));
    format(CNRFile, sizeof(CNRFile), savefolder,CNRName);
    if(!dini_Exists(CNRFile)) {
    }
    else { // if not
        dini_IntSet(CNRFile, "Arrests", PlayerInfo[playerid][Arrests]);
        dini_IntSet(CNRFile, "Takedowns", PlayerInfo[playerid][Takedowns]);
        dini_IntSet(CNRFile, "Robberies", PlayerInfo[playerid][Robberies]);
        dini_IntSet(CNRFile, "PlayerRobberies", PlayerInfo[playerid][PlayerRobberies]);
        dini_IntSet(CNRFile, "CopsKilled", PlayerInfo[playerid][CopsKilled]);
        dini_IntSet(CNRFile, "Timearrested", PlayerInfo[playerid][Timearrested]);
    }
	DestroyDynamic3DTextLabel(jaja[playerid]);
	KillTimer(gOnlineTime);
	//Build Race
	if(BuildRace == playerid +1) BuildRace = 0;
	//vehicle
	if(PlayerInfo[playerid][pCar] != 0) CarDeleter(playerid, PlayerInfo[playerid][pCar]);
	DestroyVehicle(PlayerInfo[playerid][pCar]);
	DestroyVehicle(Veh[playerid][VehId]);
	DestroyNeonObjects(playerid);
	InDeathMatch[playerid] = 0;
	if(Joined[playerid] == true)
    {
		JoinCount--;
		Joined[playerid] = false;
	    Nitro[playerid] = true;
	    Bounce[playerid] = true;
	    AutoFix[playerid] = true;
		DestroyVehicle(CreatedRaceVeh[playerid]);
	    DisablePlayerRaceCheckpoint(playerid);
		TextDrawHideForPlayer(playerid, RaceInfo[playerid]);
        TextDrawDestroy(RaceInfo[playerid]);
		CPProgess[playerid] = 0;
		KillTimer(InfoTimer[playerid]);
		TogglePlayerControllable(playerid, true);
		SetCameraBehindPlayer(playerid);
		#if defined RACE_IN_OTHER_WORLD
		SetPlayerVirtualWorld(playerid, 0);
		#endif
	}
	new INI:hfile, hlasthcp;
    EndHouseRobbery(playerid);
    SetPVarInt(playerid, "IsRobbingHouse", 0);
    hlasthcp = GetPVarInt(playerid, "LastHouseCP");
    if(!strcmp(hInfo[hlasthcp][HouseOwner], pNick(playerid), CASE_SENSETIVE) && IsInHouse{playerid} == 1 && fexist(HouseFile(hlasthcp)))
	{
  			hfile = INI_Open(HouseFile(hlasthcp));
	    	INI_WriteInt(hfile, "QuitInHouse", 1);
		    INI_Close(hfile);
		    #if GH_HOUSECARS == true
	    		SaveHouseCar(hlasthcp);
        	#endif
	}
	ExitHouse(playerid, hlasthcp);
	DeletePVars(playerid);
	// Setup local variables
	new BusSlot;
	// Loop through all businesses the player owns
	for (BusSlot = 0; BusSlot < MAX_BUSINESSPERPLAYER; BusSlot++)
	{
		// Check if the player has a business in this busslot
		if (APlayerData[playerid][Business][BusSlot] != 0)
		{
		    // Save the Busfile
			BusinessFile_Save(APlayerData[playerid][Business][BusSlot]);

		    // Clear the BusID stored in this busslot
			APlayerData[playerid][Business][BusSlot] = 0;
		}
	}
	// Clear all data for this player
	APlayerData[playerid][CurrentBusiness] = 0;
	new duelid = GetPVarInt(playerid, "DuelDID");
	new dueler2;
	dueler2 = dInfo[duelid][Invitee];
	if(InDuel[playerid] == 1 && InDuel[dueler2] == 1)
	{
		new gBet = dInfo[duelid][BetMoney];
		//new gDuelSpot = dInfo[duelid][Location];

		new Slot[MAX_DUEL_WEPS];
		for(new i=0; i < MAX_DUEL_WEPS; i++) Slot[i] = dWeps[duelid][i];

		new winner, loser;
		if(playerid == playerid)
		{
		    winner = dueler2;
		    loser = playerid;
		}
		else if(dueler2 == playerid)
		{
		    winner = playerid;
		    loser = dueler2;
 		}
		GivePlayerMoneyEx(winner, gBet);

		new wepstr[256];
		for(new x=0; x < MAX_DUEL_WEPS; x++)
		{
		    if(IsValidWeapon(Slot[x])) format(wepstr, sizeof(wepstr), "%s%s ", wepstr, weaponNames(Slot[x]));
		}
		format(wepstr, sizeof(wepstr), "Duel | %s has left the server while during a duel (Reason: %s), %s wins %d", pDName(loser), reason, pDName(winner), gBet);
		SendClientMessageToAll(COLOR_DUEL, wepstr);

		SetPlayerArmour(winner, 0);
		RemoveFromDuel(loser);
		RemoveFromDuel(winner);
		ResetDuelInformation(duelid);
		RemoveDuelInvite(dueler2, playerid);
		SpawnPlayer(winner);
		SetPlayerVirtualWorld(winner, 0);
		TotalDuels--;
	}
	if ( PlayerInfo[ playerid ][ ActionID ] == 2 )
	{
	KillTimer(spawntiming);
	spawntiming=-1;
	KillTimer(robberytiming);
	robberytiming = 0;
	RemovePlayerFromVehicle( playerid );
	SetPlayerInterior( playerid , 0 );
	SetPlayerTeam( playerid, NO_TEAM );
	PlayerInfo[ playerid ][ ActionID ] = ( 0 );
	ResetPlayerWeapons( playerid );
	LoadPlayerCoords(playerid);
	Iter_Remove( PlayerInCNR, playerid );
	Iter_Remove( PlayerInROBBERS, playerid );
	Iter_Remove( PlayerInCOPS, playerid );
    Nitro[playerid] = true;
    Bounce[playerid] = true;
    AutoFix[playerid] = true;
    SetPVarInt(playerid, "InDM", 0);
    SetPVarInt(playerid, "InDCnR", 0);
    SetPVarInt(playerid, "InRace", 0);
	// ( GangZone CNR )
	GangZoneHideForPlayer( playerid, CNR_ZONE[ 0 ] ); // Rob
	GangZoneHideForPlayer( playerid, CNR_ZONE[ 1 ] ); // Cop
	GangZoneHideForPlayer( playerid, CNR_ZONE[ 2 ] ); // Swat
	GangZoneHideForPlayer( playerid, CNR_ZONE[ 3 ] ); // Army
	GangZoneHideForPlayer( playerid, CNR_ZONE[ 4 ] );  // Rob2
	// ( Leave Message )
	TextDrawHideForPlayer(playerid, RobTD);
	Cuffed[ playerid ] = false;
	Robstart[ playerid ] = 0;
	ClearAnimations(playerid);
	PlayerInfo[ playerid ][ InCNR] = 0;
	SetPlayerVirtualWorld(playerid,0);
	}
	TextDrawDestroy(SpecTD[playerid][0]);
	TextDrawDestroy(SpecTD[playerid][1]);
	InDuel[playerid] = 0;
	KillTimer(DuelTimer[playerid]);
	//----------
	if ( bAcc{ playerid } ) {
		new
		    INI: file = INI_Open( bankFile( playerid ) );
		INI_WriteInt( file, "bankMoney", bankMoney[ playerid ] );
		INI_Close( file );
	}
	if (IsBeingSpeced[playerid] == 1)
	{
	    for (new i = 0; i < MAX_PLAYERS; i++)
	    {
	        if (spectatorid[i] == playerid)
	        {
	            TogglePlayerSpectating(i, false);
			}
		}
	}
	new year, month, day, lastvisited[20], lasthcp = GetPVarInt(playerid, "LastHouseCP");
	EndHouseRobbery(playerid);
    if(!strcmp(hInfo[lasthcp][HouseOwner], pNick(playerid), CASE_SENSETIVE) && IsInHouse{playerid} == 1 && fexist(HouseFile(lasthcp)))
	{
	    getdate(year, month, day);
	    format(lastvisited, sizeof(lastvisited), "%02d/%02d/%d", day, month, year);
	    new INI:file = INI_Open(HouseFile(lasthcp));
	    INI_WriteInt(file, "QuitInHouse", 1);
	    INI_WriteString(file, "LastVisited", lastvisited);
	    INI_Close(file);
	    #if GH_HOUSECARS == true
	    	SaveHouseCar(lasthcp);
	    	UnloadHouseCar(lasthcp);
        #endif
	}
	IsInHouse{playerid} = 0;
    if(PlayerInfo[playerid][HaveTarget] == 1)
    {
		    new id = GetPlayerID(PlayerInfo[playerid][NameTarget]);
		    if(id == INVALID_PLAYER_ID) return 1;
		    SendClientMessage(id,AYELLOW,"* Your target has quit the server!");
		    format(PlayerInfo[id][NameVictim],24,"Nobody");
		    PlayerInfo[id][HaveVictim] = 0;
    }
	if(PlayerInfo[playerid][HaveVictim] == 1)
 	{
		    new id = GetPlayerID(PlayerInfo[playerid][NameVictim]);
		    if(id == INVALID_PLAYER_ID) return 1;
		    format(PlayerInfo[id][NameTarget],24,"Nobody");
		    PlayerInfo[id][HaveTarget] = 0;
      		new String[128];
		    format(String,sizeof(String),"Free target: %s | Price: %d$ | ID Target: %d |",GetName(id),PlayerInfo[id][TargetPrice],id);
      		HChat(String);
 	}
	if(PlayerInfo[playerid][ActionID] == 2)
	{
	KillTimer(spawntiming);
	spawntiming=-1;
	KillTimer(robberytiming);
	robberytiming = 0;
	RemovePlayerFromVehicle(playerid);
	SetPlayerInterior(playerid , 0);
	SetPlayerTeam(playerid, NO_TEAM);
	PlayerInfo[playerid][ActionID] = (0);
	ResetPlayerWeapons(playerid);
	LoadPlayerCoords(playerid);
	Iter_Remove(PlayerInCNR, playerid);
	Iter_Remove(PlayerInROBBERS, playerid);
	Iter_Remove(PlayerInCOPS, playerid);
	//(GangZone CNR)
	GangZoneHideForPlayer(playerid, CNR_ZONE[0]); // Rob
	GangZoneHideForPlayer(playerid, CNR_ZONE[1]); // Cop
	GangZoneHideForPlayer(playerid, CNR_ZONE[2]); // Swat
	GangZoneHideForPlayer(playerid, CNR_ZONE[3]); // Army
	GangZoneHideForPlayer(playerid, CNR_ZONE[4]);  // Rob2
	Cuffed[ playerid] = false;
	Robstart[playerid] = 0;
	ClearAnimations(playerid);
	PlayerInfo[playerid][InCNR] = 0;
	SetPlayerVirtualWorld(playerid,0);
	}
	players_connected--;
	return 1;
}

stock WeatherUpdateDay()
{
	SetWeather(RandomSet(2,4,7,8,9,12,15,22,25,30,48));//Change the weather ID to whatever you want
	return 1;
}

stock WeatherUpdateNight()
{
	SetWeather(RandomSet(16,32,38,42,43,48));//Change the weather ID to whatever you want
	return 1;
}

stock RandomSet(...) return getarg(random(numargs()));
stock TimeAndDate ()
{
    new year, month, day, hour, minute, sec, last[50];
   	getdate(year, month, day);
	gettime(hour, minute, sec);
    format(last, sizeof(last), "%d:%d:%d | %d/%d/%d", hour, minute, sec, day, month, year);
    return last;
}


public OnPlayerSpawn(playerid)
{
	if(PlayerInfo[playerid][GodEnabled] == 1)
	{
	   EnableGod(playerid);
	}
    CallRemoteFunction("CallSpawn","i",playerid);
	SetPVarInt(playerid, "AllowingCashChange", 0); //to ensure vars in the anti money cheat systems are set correctly
	if(GetPVarInt(playerid, "IsAnimsPreloaded") == 0)
	{
	    ApplyAnimation(playerid, "CRACK", "null", 0.0, 0, 0, 0, 0, 0);
    	SetPVarInt(playerid, "IsAnimsPreloaded", 1);
    }
    #if SPAWN_IN_HOUSE == true
    if(GetPVarInt(playerid, "FirstSpawn") == 0)
    {
		SetTimerEx("HouseSpawning", HSPAWN_TIMER_RATE, false, "i", playerid); // Increase timer rate if your gamemodes OnPlayerSpawn gets called after the timer has ended
    }
    #endif
	new Float:RandomSpawns[][] =
	{
	    {374.7578,2536.7205,16.5790,135.2049},
		{-2663.3826,1329.6676,16.9922,322.3937},
		{1610.1835,1244.6378,10.8711,71.1635},
		{-1282.0042,27.8623,14.1484,132.6035}
	};
	new Random = random(sizeof(RandomSpawns));
    SetPlayerPosition(playerid, RandomSpawns[Random][0], RandomSpawns[Random][1], RandomSpawns[Random][2], RandomSpawns[Random][3]);
	PlayerPlaySound(playerid, 1186, 0.0, 0.0, 0.0); // (blank sound) to shut the music up
	for(new i = 0; i < sizeof(gTextDraw); i ++) TextDrawShowForPlayer(playerid, gTextDraw[i]);
	if(!gPlayerAnimLibsPreloaded[playerid])
	{
		PreloadAnimLib(playerid,"MISC");
		PreloadAnimLib(playerid,"ped");
		PreloadAnimLib(playerid,"BEACH");
		PreloadAnimLib(playerid,"SMOKING");
		PreloadAnimLib(playerid,"BOMBER");
		PreloadAnimLib(playerid,"RAPPING");
		PreloadAnimLib(playerid,"SHOP");
		PreloadAnimLib(playerid,"COP_AMBIENT");
		PreloadAnimLib(playerid,"FOOD");
		PreloadAnimLib(playerid,"ON_LOOKERS");
		PreloadAnimLib(playerid,"SWEET");
		PreloadAnimLib(playerid,"DEALER");
		PreloadAnimLib(playerid,"CRACK");
		PreloadAnimLib(playerid,"BLOWJOBZ");
		PreloadAnimLib(playerid,"PARK");
		PreloadAnimLib(playerid,"GYMNASIUM");
		PreloadAnimLib(playerid,"PAULNMAC");
		PreloadAnimLib(playerid,"CAR");
		PreloadAnimLib(playerid,"GANGS");
		PreloadAnimLib(playerid,"GHANDS");
		PreloadAnimLib(playerid,"MEDIC");
		PreloadAnimLib(playerid,"Attractors");
		PreloadAnimLib(playerid,"HEIST9");
		PreloadAnimLib(playerid,"RIOT");
		PreloadAnimLib(playerid,"CARRY");
		gPlayerAnimLibsPreloaded[playerid] = 1;
	}
	Offer[playerid] = -1;
	PlayerTextDrawDestroy(playerid, Textdraw0[playerid]);
	PlayerTextDrawDestroy(playerid, Textdraw1[playerid]);
	PlayerTextDrawDestroy(playerid, Textdraw2[playerid]);
	PlayerTextDrawDestroy(playerid, Textdraw3[playerid]);
	PlayerTextDrawDestroy(playerid, Textdraw4[playerid]);
	PlayerTextDrawDestroy(playerid, Textdraw5[playerid]);
	PlayerTextDrawDestroy(playerid, Textdraw6[playerid]);
	PlayerTextDrawDestroy(playerid, Textdraw7[playerid]);
	PlayerTextDrawDestroy(playerid, Textdraw8[playerid]);
	PlayerTextDrawDestroy(playerid, Textdraw9[playerid]);
	PlayerTextDrawDestroy(playerid, Textdraw10[playerid]);
	PlayerTextDrawDestroy(playerid, Textdraw11[playerid]);
	PlayerTextDrawDestroy(playerid, Textdraw12[playerid]);
	PlayerTextDrawDestroy(playerid, Textdraw13[playerid]);
	PlayerTextDrawDestroy(playerid, Textdraw14[playerid]);
	PlayerTextDrawDestroy(playerid, Textdraw15[playerid]);
	PlayerTextDrawDestroy(playerid, Textdraw16[playerid]);
	TextDrawShowForPlayer(playerid, box);
	TextDrawShowForPlayer(playerid, fdm);
	TextDrawShowForPlayer(playerid, war);
	TextDrawShowForPlayer(playerid, mini);
	TextDrawShowForPlayer(playerid, eagle);
	TextDrawShowForPlayer(playerid, rdm);
	TextDrawShowForPlayer(playerid, odm);
	TextDrawShowForPlayer(playerid, sawndm);
	TextDrawShowForPlayer(playerid, fdmplayers);
	TextDrawShowForPlayer(playerid, warplayers);
	TextDrawShowForPlayer(playerid, miniplayers);
	TextDrawShowForPlayer(playerid, eagleplayers);
	TextDrawShowForPlayer(playerid, rdmplayers);
	TextDrawShowForPlayer(playerid, odmplayers);
	TextDrawShowForPlayer(playerid, sawndmplayers);
	TextDrawShowForPlayer(playerid, T);
	TextDrawShowForPlayer(playerid, BS);
	TextDrawShowForPlayer(playerid, web);
	TextDrawShowForPlayer(playerid, InfoTD);

	if (PlayerInfo[playerid][Helmet] == 1)
	{
		SetPlayerAttachedObject(playerid, 3, RandomHelmet[random(sizeof(RandomHelmet))], 2, 0.101, -0.0, 0.0, 5.50, 84.60, 83.7, 1, 1, 1);
	}
	// Reset the BusID where the player is located
	APlayerData[playerid][CurrentBusiness] = 0;
    if(IsSpecing[playerid] == 1)
    {
        SetPlayerPos(playerid,SpecX[playerid],SpecY[playerid],SpecZ[playerid]);
        SetPlayerInterior(playerid,Inter[playerid]);
        SetPlayerVirtualWorld(playerid,vWorld[playerid]);
        IsSpecing[playerid] = 0;
        IsBeingSpeced[spectatorid[playerid]] = 0;
    }
	RespawninDM(playerid);
	if (PlayerInfo[playerid][inDM] == 0 && PlayerInfo[playerid][inDMZone] == 0)
    {
		if ( PlayerInfo[playerid][POS_X] >= 1 && PlayerInfo[playerid][POS_Y] >= 1 && PlayerInfo[playerid][POS_Z] >= 1 )
		  {
			SetPlayerPos(playerid, PlayerInfo[playerid][POS_X], PlayerInfo[playerid][POS_Y], PlayerInfo[playerid][POS_Z]);
			SetCameraBehindPlayer(playerid);
		  }
	}
    SetPlayerColor(playerid, PlayerInfo[playerid][Color]);
	if( PlayerInfo[ playerid ][ ActionID ] == 2 ) // ( CnR )
	{
					TextDrawHideForPlayer(playerid, KillerTD0);
					TextDrawHideForPlayer(playerid, KillerTD1);
					TextDrawHideForPlayer(playerid, KillerTD2);
					TextDrawHideForPlayer(playerid, KillerTD3);
					TextDrawHideForPlayer(playerid, KillerTD4);
					TextDrawHideForPlayer(playerid, KillerTD5);
					TextDrawHideForPlayer(playerid, KillerTD6);
					TextDrawHideForPlayer(playerid, KillerTD7);
					TextDrawHideForPlayer(playerid, KillerTD8);
					TextDrawHideForPlayer(playerid, KillerTD9);
					TogglePlayerSpectating(playerid, false);
			        IsSpecating[playerid] =0;
			        KillTimer( KillerTimer[ playerid] );
	                if ( GetPlayerTeam( playerid ) == TEAM_COPS)
	                {
	                    RespawnplayerCop( playerid );
					}
	                if ( GetPlayerTeam( playerid ) == TEAM_ARMY)
	                {
	                    RespawnplayerArmy( playerid );
					}
	                if ( GetPlayerTeam( playerid ) == TEAM_SWAT)
	                {
	                    RespawnplayerSwat( playerid );
					}
	                if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS)
	                {
	                    RespawnplayerRobber( playerid );
					}
	                if ( GetPlayerTeam( playerid ) == TEAM_PROROBBERS)
	                {
	                    RespawnplayerProRobber( playerid );
					}
	                if ( GetPlayerTeam( playerid ) == TEAM_EROBBERS)
	                {
	                    RespawnplayerERobber( playerid );
					}
    }
    PlayerBombs[playerid]=3;
	/*if(PlayerInfo[playerid][aLeader] == 1 && PlayerInfo[playerid][aMember] == 1)
	{
        SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
	}*/
	if(PlayerInfo[playerid][aLeader] > -1)
	{
		new org=PlayerInfo[playerid][aLeader];
		new c=0;
		for(new i=0;i<2;i++)
		{
			if(udb_hash(Leader[i][org]) != udb_hash(GetName(playerid)))
		   	{
		   		c++;
			   	if(c==2)
			   	{
				   	SendClientMessage(playerid,-1,"You're no longer a leader!");
				   	PlayerInfo[playerid][aLeader] = -1;
				   	SavePlayer(playerid);
				}
		   	}
		}
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		new org=PlayerInfo[playerid][aMember];
		new c=0;
		for(new i=0;i<12;i++)
		{
			if(udb_hash(Member[i][org]) != udb_hash(GetName(playerid)))
		   	{
			   	c++;
			   	if(c==12)
			   	{
				   	SendClientMessage(playerid,-1,"You have been kicked out of his gang!");
				   	PlayerInfo[playerid][aMember] = -1;
				   	SavePlayer(playerid);
			   	}
		   	}
		}
	}
	for(new i=0; i<MAX_GANG;i++)
	{
		if(PlayerInfo[playerid][aMember] == i || PlayerInfo[playerid][aLeader] == i)
		{
			SetPlayerPos(playerid,GangInfo[i][sX],GangInfo[i][sY],GangInfo[i][sZ]);
		}
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(!strcmp(PlayerInfo[killerid][NameVictim], GetName(playerid), true))
	{
	    new String[200];
		format(String,sizeof(String),"|Hitman| %s has killed %s and won the price of %d$",GetName(killerid),GetName(playerid),PlayerInfo[playerid][TargetPrice]);
		HChat(String);
		PlayerInfo[killerid][HaveVictim] = 0;
		format(PlayerInfo[killerid][NameVictim],24,"Nobody");
		GivePlayerMoneyEx(killerid,PlayerInfo[playerid][TargetPrice]);
		PlayerInfo[playerid][HaveTarget] = 0;
		PlayerInfo[playerid][Target] = 0;
		format(PlayerInfo[playerid][NameTarget],24,"Nobody");
		PlayerInfo[playerid][TargetPrice] = 0;
	}
	if(killStreak[playerid] >= 5)
	{
	    new str [ 200 ];
		format(str, sizeof(str), ""BLUE"* {%06x}%s(%d) "GREY"has ended {%06x}%s(%d) "GREY"killstreak of "RED"%d.",(GetPlayerColor(killerid) >>> 8), GetName(killerid), killerid, (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid, killStreak[playerid]);
		SendClientMessageToAll(-1, str);
		SendClientMessage(killerid, -1, "> You have earned 3000$ and 2 score for ending a players killstreak.");
    	GivePlayerMoneyEx(killerid, 2000);
    	SetPlayerScore(killerid, GetPlayerScore(killerid) + 2);
		TD_MSG(killerid, 4500, "+~g~~h~$~y~h~10,00");
		}
 	if(killStreak[playerid] >= 10)
	{
	    new str [ 200 ];
	    format(str, sizeof(str), ""RED"* {%06x}%s(%i) "GREY"has killed the most wanted {%06x}%s(%i)",(GetPlayerColor(killerid) >>> 8), GetName(killerid), killerid, (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
	    SendClientMessageToAll(-1, str);
	    SendClientMessage(killerid, -1, ""GREEN"> "PINK"You earned 5000$ and 5 score for killing the most wanted player");
     	TD_MSG(killerid, 4500, "+~g~$~w~10,000~w~~r~~h~+2 Score ~g~~h~and ~y~~h~+5 Cookies");
    	GivePlayerMoneyEx(killerid, 5000);
    	SetPlayerScore(killerid, GetPlayerScore(killerid) + 5);
	}
	DestroyDynamic3DTextLabel(MWLabel[playerid]);
	killStreak[killerid] ++;
	KillStreak(killerid);
	killStreak[playerid] = 0;
    if(FullBag[playerid] == 1)
	{
	GivePlayerMoney(playerid, -100000);
	KillTimer(SMoney);
	FullBag[playerid] = 0;
	SendClientMessage(playerid, -1,"You failed the Rob Security Van, RIP.");
	}
	if(PlayerInfo[playerid][inDM] == 0 && PlayerInfo[playerid][InCNR] == 0)
	{
	    CallRemoteFunction("CallDeath","iii",playerid,killerid,reason);
	}
	if(Joined[playerid] == true)
    {
		JoinCount--;
		Joined[playerid] = false;
		DestroyVehicle(CreatedRaceVeh[playerid]);
		DisablePlayerRaceCheckpoint(playerid);
        TextDrawHideForPlayer(playerid, RaceInfo[playerid]);
        TextDrawDestroy(RaceInfo[playerid]);
		CPProgess[playerid] = 0;
		KillTimer(InfoTimer[playerid]);
		#if defined RACE_IN_OTHER_WORLD
		SetPlayerVirtualWorld(playerid, 0);
		#endif
	}
	if(gPlayerUsingLoopingAnim[playerid])
	{
	    ExitAnim[playerid] = 0;  // if they die whilst performing a looping anim, we should reset the state
        gPlayerUsingLoopingAnim[playerid] = 0;
	}
	if(GetPVarInt(playerid, "IsRobbingHouse") == 1)
	{
	    ShowInfoBox(playerid, I_HROB_FAILED_DEATH, hInfo[GetPVarInt(playerid, "LastHouseCP")][HouseName]);
		EndHouseRobbery(playerid);
		SetPVarInt(playerid, "IsRobbingHouse", 0);
		SetPVarInt(playerid, "TimeSinceHouseRobbery", GetTickCount());
	}
    SendDeathMessage(killerid, playerid, reason);
	if(IsBeingSpeced[playerid] == 1)
    {
        for (new i = 0; i < MAX_PLAYERS; i++)
        {
            if(spectatorid[i] == playerid)
            {
				format(strg, sizeof(strg), ""STEELBLUE"- AS - {%06x}%s(%d) "STEELBLUE"died while you were spectating, you may resume spectating by using /spec again.", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
				SendClientMessage(i, -1, strg);
                TogglePlayerSpectating(i,false);
            }
        }
    }
	new duelid = GetPVarInt(killerid, "DuelDID");
	new dueler, dueler2;
	dueler = dInfo[duelid][Inviter];
	dueler2 = dInfo[duelid][Invitee];
   	if(InDuel[dueler] == 1 && InDuel[dueler2] == 1)
	{
		new gBet = dInfo[duelid][BetMoney];
		new gDuelSpot = dInfo[duelid][Location];

		new Slot[MAX_DUEL_WEPS];
		for(new i=0; i < MAX_DUEL_WEPS; i++) Slot[i] = dWeps[duelid][i];

		new winner, loser;
		if(dueler == playerid)
		{
		    winner = dueler2;
		    loser = dueler;
		}
		else if(dueler2 == playerid)
		{
		    winner = dueler;
		    loser = dueler2;
 		}
		GivePlayerMoneyEx(winner, gBet);
		GivePlayerMoneyEx(loser, -gBet);
		new wepstr[200];
		for(new x=0; x < MAX_DUEL_WEPS; x++)
		{
		    if(IsValidWeapon(Slot[x])) format(wepstr, sizeof(wepstr), "%s%s ", wepstr, weaponNames(Slot[x]));
		}
		new str[230], duelloc[40];
		new HPT = GetRoundedTotalHP(playerid);
		format(duelloc, sizeof(duelloc), "%s", ReturnDuelNameFromID(gDuelSpot));
		format(str, sizeof(str), "Duel | %s won the duel against %s {0004B6}(HP %d) (Weapons %s) {009900}(Bet: $%d) {F8FF3D}(%s [ID %d])", pDName(killerid), pDName(playerid), HPT, wepstr, gBet, duelloc, gDuelSpot);
		SendClientMessageToAll(COLOR_RED, str);
		SetPlayerArmour(playerid, 0);
		SetPlayerArmour(killerid, 0);
		RemoveFromDuel(playerid);
		RemoveFromDuel(killerid);
		ResetDuelInformation(duelid);
		SpawnPlayer(killerid);
		TotalDuels--;
		RemoveDuelInvite(dueler2, dueler);
	}
	else if(killerid == INVALID_PLAYER_ID && InDuel[playerid] == 1)
	{
		new gBet = dInfo[duelid][BetMoney];
		new gDuelSpot = dInfo[duelid][Location];
		new Slot[MAX_DUEL_WEPS];
		for(new i=0; i < MAX_DUEL_WEPS; i++) Slot[i] = dWeps[duelid][i];
		GivePlayerMoneyEx(playerid, -gBet);
		GivePlayerMoneyEx(killerid, gBet);
		new winner, loser;
		if(dueler == playerid)
		{
		    winner = dueler2;
		    loser = dueler;
		}
		else if(dueler2 == playerid)
		{
		    winner = dueler;
		    loser = dueler2;
 		}
		new wepstr[200];
		for(new x=0; x < MAX_DUEL_WEPS; x++)
		{
		    if(IsValidWeapon(Slot[x])) format(wepstr, sizeof(wepstr), "%s%s ", wepstr, weaponNames(Slot[x]));
		}
		new str[220];
		format(str, sizeof(str), "Duel | %s commited suicide during a duel with %s {0004B6}(Weapons %s) {009900}(Bet: $%d) {F8FF3D}(%s [ID %d])", pDName(loser), pDName(winner), wepstr, gBet, ReturnDuelNameFromID(gDuelSpot), gDuelSpot);
		SendClientMessageToAll(COLOR_DUEL, str);
		SetPlayerArmour(winner, 0);
		SetPlayerArmour(loser, 0);
		RemoveDuelInvite(dueler2, dueler);
		RemoveFromDuel(winner);
		RemoveFromDuel(loser);
		ResetDuelInformation(duelid);
		SpawnPlayer(winner);
		SetPlayerVirtualWorld(winner, 0);
		TotalDuels--;
	}
	// Reset the BusID where the player is located
	APlayerData[playerid][CurrentBusiness] = 0;
	GameTextForPlayer(playerid, "~r~DEAD!", 3000, 3);
    if(killerid != INVALID_PLAYER_ID)
    {
        gTotalKills++;
		switch (gTotalKills)
		{
		    case 1000: SendClientMessageToAll(-1, "{FFD700}[TBS] {008FFB}10k{2BD9F8} players have been killed since the server launch!");
		    case 20000: SendClientMessageToAll(-1, "{FFD700}[TBS] {008FFB}20k{2BD9F8} players have been killed since the server launch!");
			case 50000: SendClientMessageToAll(-1, "{FFD700}[TBS] {008FFB}50k{2BD9F8} players have been killed since the server launch!");
		}
        new INI:FILE_SERVER_STATS = INI_Open(ServerStats);
       	INI_SetTag(FILE_SERVER_STATS, "Server_Statistics");
		INI_WriteInt(FILE_SERVER_STATS, "Total_Kills", gTotalKills);
		INI_Close(FILE_SERVER_STATS);
        new str[128];
         //DM
		EXPforDM[killerid] = CreatePlayerTextDraw(killerid, 2.500000, 175.466751, "+1 EXP");
  		PlayerTextDrawLetterSize(killerid, EXPforDM[killerid], 0.449999, 1.600000);
  		PlayerTextDrawAlignment(killerid, EXPforDM[killerid], 1);
  		PlayerTextDrawColor(killerid, EXPforDM[killerid], -5963521);
  		PlayerTextDrawSetShadow(killerid, EXPforDM[killerid], 0);
  		PlayerTextDrawSetOutline(killerid, EXPforDM[killerid], -256);
  		PlayerTextDrawBackgroundColor(killerid, EXPforDM[killerid], 51);
  		PlayerTextDrawFont(killerid, EXPforDM[killerid], 2);
		PlayerTextDrawSetProportional(killerid, EXPforDM[killerid], 1);
  		CashforDM[killerid] = CreatePlayerTextDraw(killerid, 2.500000, 191.644439, "+3000$");
  		PlayerTextDrawLetterSize(killerid, CashforDM[killerid], 0.449999, 1.600000);
  		PlayerTextDrawAlignment(killerid, CashforDM[killerid], 1);
  		PlayerTextDrawColor(killerid, CashforDM[killerid], 16711935);
  		PlayerTextDrawSetShadow(killerid, CashforDM[killerid], 0);
  		PlayerTextDrawSetOutline(killerid, CashforDM[killerid], 0);
		PlayerTextDrawBackgroundColor(killerid, CashforDM[killerid], 51);
  		PlayerTextDrawFont(killerid, CashforDM[killerid], 2);
  		PlayerTextDrawSetProportional(killerid, CashforDM[killerid], 1);
  		PlayerTextDrawShow(killerid, EXPforDM[killerid]);
	    PlayerTextDrawShow(killerid, CashforDM[killerid]);
        PlayerTextDrawShow(killerid, EXPforDM[killerid]);
  		PlayerTextDrawShow(killerid, CashforDM[killerid]);
        SetPlayerScore(killerid, GetPlayerScore(killerid) + 1);
        GivePlayerMoneyEx(killerid, 3000);
        for (new i = 0; i < MAX_PLAYERS; i++)
        {
            if (IsPlayerConnected(i))
            {
                if (PlayerInfo[i][inDM] == 1)
                {
                    format(str, sizeof(str), "%s(%d) killed %s(%d) (%s)", GetName(killerid), killerid, GetName(playerid), playerid, WeaponNames[reason]);
                    SendClientMessage(i, COLOR_VIOLET, str);
    			}
   			}
  		}
  		//SendClientMessageToAll( COLOR_VIOLET, str);
        gDMTD = SetTimerEx("HideDMTextDraw", 2000, false, "i", killerid);
 	}
	if(BuildRace == playerid+1) BuildRace = 0;
	if(PlayerInfo[playerid][InCNR] == 1) //(CnR)
	{
	    PlayerInfo[playerid][ActionID] = 2;
	}
	if(IsPlayerInAnyVehicle(playerid))
	{
	   DestroyNeonObjects(playerid);
	}
    if(PlayerInfo[playerid][ActionID] == 2) //(CnR)
    {
		if(IsPlayerConnected(killerid))
	    {
			gsString[0] = EOS;
	 	    Iter_Remove(PlayerInCOPS, playerid);
	 	    Iter_Remove(PlayerInCNR, playerid);
	 	    Iter_Remove(PlayerInROBBERS, playerid);
			Killercam(playerid,killerid);
			if(GetPlayerTeam(killerid) == TEAM_PROROBBERS)
			{
			    PlayerInfo[killerid][CopsKilled]++;
				foreach(Player, i)
				{
					if(PlayerInfo[i][InCNR] == 1)
					{
						FormatMSG(i, -1, "{FF0000}[CnR] {7A7A7A}%s(%d) killed %s(%d) ({BABABA}%s{7A7A7A})", PlayerName(playerid), playerid, PlayerName(killerid), killerid,GetWeapon(reason));
					}
				}
	   			gsString[0] = EOS;
				SendClientMessage(killerid, COLOR_RED,"{FF0000}- CnR -  {3BBD44}You have received 1 score and $5000 for killing an officer!");
    			GivePlayerMoneyEx(killerid, 5000);
			}
			if(GetPlayerTeam(killerid) == TEAM_ROBBERS)
			{
			    PlayerInfo[killerid][CopsKilled]++;
				foreach(Player, i)
				{
					if(PlayerInfo[i][InCNR] == 1)
					{
						FormatMSG(i, -1, "{FF0000}[CnR] {7A7A7A}%s(%d) killed %s(%d) ({BABABA}%s{7A7A7A})", PlayerName(playerid), playerid, PlayerName(killerid), killerid,GetWeapon(reason));
					}
				}
	   			gsString[0] = EOS;
				SendClientMessage(killerid, COLOR_RED,"{FF0000}- CnR -  {3BBD44}You have received 1 score and $5000 for killing an officer!");
    			GivePlayerMoneyEx(killerid, 5000);
			}
			if(GetPlayerTeam(killerid) == TEAM_EROBBERS)
			{
			    PlayerInfo[killerid][CopsKilled]++;
				foreach(Player, i)
				{
					if(PlayerInfo[i][InCNR] == 1)
					{
						FormatMSG(i, -1, "{FF0000}[CnR] {7A7A7A}%s(%d) killed %s(%d) ({BABABA}%s{7A7A7A})", PlayerName(playerid), playerid, PlayerName(killerid), killerid,GetWeapon(reason));
					}
				}
				SendClientMessage(killerid, COLOR_RED,"{FF0000}- CnR -  {3BBD44}You have received 1 score and $5000 for killing an officer!");
    			GivePlayerMoneyEx(killerid, 5000);
			}
			if(GetPlayerTeam(killerid) == TEAM_SWAT)
			{
				foreach(Player, i)
				{
					if(PlayerInfo[i][InCNR] == 1)
					{
					    FormatMSG(i, -1, "{FF0000}[CnR] {7A7A7A}%s(%d) killed %s(%d) ({BABABA}%s{7A7A7A})", PlayerName(playerid), playerid, PlayerName(killerid), killerid,GetWeapon(reason));
						FormatMSG(i, -1, "{7A7A7A}[CnR] {D2D2AB}Suspect %s(%d) has been taken down by Officer %s(%d).", PlayerName(playerid), playerid, PlayerName(killerid), killerid);
					}
				}
				FormatMSG(playerid, -1, "{FF0000}- CnR -  {BABABA}You have been taken down by Officer %s(%d)", PlayerName( killerid ), killerid );
                PlayerInfo[killerid][Takedowns]++;
			}
			if(GetPlayerTeam(killerid) == TEAM_ARMY)
			{
				foreach(Player, i)
				{
					if(PlayerInfo[i][InCNR] == 1)
					{
					    FormatMSG(i, -1, "{FF0000}[CnR] {7A7A7A}%s(%d) killed %s(%d) ({BABABA}%s{7A7A7A})", PlayerName(playerid), playerid, PlayerName(killerid), killerid,GetWeapon(reason));
						FormatMSG(i, -1, "{7A7A7A}[CnR] {D2D2AB}Suspect %s(%d) has been taken down by Officer %s(%d).", PlayerName(playerid), playerid, PlayerName(killerid), killerid);
					}
				}
				FormatMSG(playerid, -1, "{FF0000}- CnR -  {BABABA}You have been taken down by Officer %s(%d)", PlayerName(killerid), killerid);
                PlayerInfo[killerid][Takedowns]++;
			}
			if(GetPlayerTeam(killerid) == TEAM_COPS)
			{
				foreach(Player, i)
				{
					if( PlayerInfo[i][InCNR] == 1)
					{
					    FormatMSG(i, -1, "{FF0000}[CnR] {7A7A7A}%s(%d) killed %s(%d) ({BABABA}%s{7A7A7A})", PlayerName(playerid), playerid, PlayerName(killerid), killerid,GetWeapon(reason));
						FormatMSG(i, -1, "{7A7A7A}[CnR] {D2D2AB}Suspect %s(%d) has been taken down by Officer %s(%d).", PlayerName(playerid), playerid, PlayerName(killerid), killerid);
					}
				}
                FormatMSG(playerid, -1, "{FF0000}- CnR -  {BABABA}You have been taken down by Officer %s(%d)", PlayerName(killerid), killerid);
				PlayerInfo[killerid][Takedowns]++;
			}
		}
	}
	return 1;
}

stock GetDistanceBetweenPlayers(playerid, giveplayerid)// for distance in event texts + average killing distance.
{
    new Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2;
    GetPlayerPos(playerid, x1, y1, z1);
    GetPlayerPos(giveplayerid, x2, y2, z2);
    return floatround(floatsqroot(floatpower(floatabs(floatsub(x2,x1)), 2) + floatpower(floatabs(floatsub(y2,y1)),2) + floatpower(floatabs(floatsub(z2,z1)) ,2)));
}

GetWeapon(weaponid)
{
    new gunname[32 ];
    GetWeaponName(weaponid, gunname, sizeof(gunname));
    return gunname;
}

forward HideDMTextDraw(killerid);
public HideDMTextDraw(killerid)
{
	PlayerTextDrawHide(killerid, EXPforDM[killerid]);
	PlayerTextDrawHide(killerid, CashforDM[killerid]);
	KillTimer(gDMTD);
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	for(new i=0;i<MAX_PLAYERS;i++)
	{
        if(vehicleid==PlayerInfo[i][pCar])
		{
		    CarDeleter(i,vehicleid);
	        PlayerInfo[i][pCar]=-1;
        }
	}
	for(new i=0;i<MAX_PLAYERS;i++)
	{
	    for(new u=0;u<MAX_PLAYERVEHICLES;u++)
	    {
	        if(vehicleid==PlayerVehicle[i][u])
			{
			    CarDeleter(i,vehicleid);
		        PlayerVehicle[i][u]=0;
				Turn[i]--;
	        }
	    }
	}
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
if (PlayerInfo[playerid][ActionID] == 2)
{
if(Cuffed[playerid] == true)
{
if (PlayerInfo[playerid][BreakCuffs] == 1)
{
foreach(Player, i)
{
if(PlayerInfo[i][InCNR] == 1)
{
FormatMSG(i, ~1, "{7A7A7A}[CnR] {E65555}%s(%d) has evaded his arrest (Vehicle Evasion)", PlayerName(playerid), playerid);
}
}
Cuffed[playerid] = false;
KillTimer(jailtimer);
KillTimer(jailtimer2);
PlayerInfo[playerid][BreakCuffs] = 0;
}
}
}
if(!ispassenger)
{
new Float:Poz[3]; GetPlayerPos(playerid, Poz[0], Poz[1], Poz[2]);
for(new i = 0; i < 15; i++)
{
for(new a = 0; a < sizeof(GangInfo); a++)
{
if(vehicleid == GVehID[a][i])
{
if(PlayerInfo[playerid][aMember] != a && PlayerInfo[playerid][aLeader] !=a)
{
SetPlayerPos(playerid, Poz[0], Poz[1], Poz[2]);
new str[128];
format(str,sizeof(str),"~b~%s",GangInfo[a][Name]);
GameTextForPlayer(playerid, str, 2500, 5);
}
if(IsPlayerAdmin(playerid))
{
new str[128];
format(str,sizeof(str),"{FF9900}Gang ID: {FFFFFF}%d {FF0000}| {FF9900}Car slot: {FFFFFF}%d",a,i);
SendClientMessage(playerid,-1,str);
}
}
}
}
}
return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
    inVehicle[playerid] = 0;
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float: amount, weaponid, bodypart)
{

		new org=-1;
		if(PlayerInfo[playerid][aLeader] > -1)
		{
			org = PlayerInfo[playerid][aLeader];
		}
		if(PlayerInfo[playerid][aMember] > -1)
		{
			org = PlayerInfo[playerid][aMember];
		}
		if(GangInfo[org][AllowedPD] == 1)
		{
			new org2=-1;
			if(PlayerInfo[damagedid][aLeader] > -1)
			{
				org2 = PlayerInfo[damagedid][aLeader];
			}
			if(PlayerInfo[damagedid][aMember] > -1)
			{
				org2 = PlayerInfo[damagedid][aMember];
			}
			if(org2>-1)
			{
				if(GangInfo[org2][AllowedPD] != 1)
				{
					if(damagedid != playerid)
					{
						if(weaponid == 23)
						{
							new Float:px,Float:py,Float:pz;
							GetPlayerPos(damagedid,px,py,pz);
							if(IsPlayerInRangeOfPoint(playerid,25.0,px,py,pz))
							{
							if(Tazan[damagedid] == 1)return 1;
							if(EmptyTaser[playerid] == 1){return SendClientMessage(playerid,-1,"You need to wait for reload of taser!");}
							new string[128];
							format(string,sizeof(string),"**%s takes out a taser and strikes %s for 8 seconds.",GetName(playerid),GetName(damagedid));
							ProxDetector(18.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
							format(string,sizeof(string),"%s {FFFFFF}you are shocked for 8 seconds.",GetName(playerid));
							SendClientMessage(damagedid,COLOR_PURPLE,string);
							format(string,sizeof(string),"You shocked %s for 8 seconds",GetName(damagedid));
							SendClientMessage(playerid,COLOR_PURPLE,string);
							TogglePlayerControllable(damagedid,0);
							Tazan[damagedid] = 1;
							EmptyTaser[playerid] = 1;
							SetTimerEx("Tazz",8000,0,"d",damagedid);
							SetTimerEx("Taz1",3000,0,"d",playerid);
							}
						}
					}
				}else SendClientMessage(playerid,-1,"The player is a member of the police!");
			}
			else
			{
					if(damagedid != playerid)
					{
						if(weaponid == 23)
						{
							new Float:px,Float:py,Float:pz;
							GetPlayerPos(damagedid,px,py,pz);
							if(IsPlayerInRangeOfPoint(playerid,25.0,px,py,pz))
							{
							if(Tazan[damagedid] == 1)return 1;
							if(EmptyTaser[playerid] == 1){return SendClientMessage(playerid,-1,"You need to wait for reload of taser!");}
							new string[128];
							format(string,sizeof(string),"**%s takes out a taser and strikes %s for 8 seconds.",GetName(playerid),GetName(damagedid));
							ProxDetector(18.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
							format(string,sizeof(string),"%s {FFFFFF}you are shocked for 8 seconds.",GetName(playerid));
							SendClientMessage(damagedid,COLOR_PURPLE,string);
							format(string,sizeof(string),"You shocked %s for 8 seconds",GetName(damagedid));
							SendClientMessage(playerid,COLOR_PURPLE,string);
							TogglePlayerControllable(damagedid,0);
							Tazan[damagedid] = 1;
							EmptyTaser[playerid] = 1;
							SetTimerEx("Tazz",8000,0,"d",damagedid);
							SetTimerEx("Taz1",3000,0,"d",playerid);
							}
						}
					}
			}
		}else SendClientMessage(playerid,-1,"You are not member of the police!");
    	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    #if GH_HOUSECARS == true
	if(newstate == PLAYER_STATE_DRIVER)
	{
		foreach(Houses, h)
		{
	    	if(GetPlayerVehicleID(playerid) == HCar[h])
	    	{
	    	    switch(strcmp(hInfo[h][HouseOwner], pNick(playerid), CASE_SENSETIVE))
	    	    {
	    	        case 0: ShowInfoBox(playerid, I_HOUSECAR_OWNER, pNick(playerid), h);
	    	        case 1:
	    	        {
	    	            GetPlayerPos(playerid, X, Y, Z);
	    	            SetPlayerPos(playerid, (X + 3), Y, Z);
                  		ShowInfoBox(playerid, E_NOT_HOUSECAR_OWNER, h, hInfo[h][HouseOwner]);
                        #endif
					}
	    	    }
	    	    break;
	    	}
	    }
	}
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)// If the player's state changes to a vehicle state we'll have to spec the vehicle.
    {
        if(IsBeingSpeced[playerid] == 1)//If the player being spectated, enters a vehicle, then let the spectator spectate the vehicle.
        {
            for (new i = 0; i < MAX_PLAYERS; i++)
            {
                if(spectatorid[i] == playerid)
                {
                    PlayerSpectateVehicle(i, GetPlayerVehicleID(playerid));// Letting the spectator, spectate the vehicle of the player being spectated (I hope you understand this xD)
                }
            }
        }
    }
    if(newstate == PLAYER_STATE_ONFOOT)
    {
        if(IsBeingSpeced[playerid] == 1)//If the player being spectated, exists a vehicle, then let the spectator spectate the player.
        {
            for (new i = 0; i < MAX_PLAYERS; i++)
            {
                if(spectatorid[i] == playerid)
                {
                    PlayerSpectatePlayer(i, playerid);// Letting the spectator, spectate the player who exited the vehicle.
                }
            }
        }
    }
	if (AntifallEnabled[playerid] == 1)
	{
	    if (oldstate == PLAYER_STATE_ONFOOT)
	    {
	        if (newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	        {
	            inVehicle[playerid] = 1;
	            carID[playerid] = GetPlayerVehicleID(playerid);
			}
		}
		if (oldstate == PLAYER_STATE_DRIVER)
		{
		    if (newstate == PLAYER_STATE_ONFOOT)
		    {
		        if (inVehicle[playerid] == 1)
		        {
		        	PutPlayerInVehicle(playerid, carID[playerid], 0);
				}
			}
		}
		if (oldstate == PLAYER_STATE_PASSENGER)
		{
		    if (newstate == PLAYER_STATE_ONFOOT)
		    {
		        if (inVehicle[playerid] == 1)
		        {
		        	PutPlayerInVehicle(playerid, carID[playerid], 1);
				}
			}
		}
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    //Weapons for Hitmans======
	if(CP[playerid] == 1)
	{
	DisablePlayerCheckpoint(playerid);
    ShowPlayerDialog(playerid,DIALOG_WEAPON,DIALOG_STYLE_LIST,"Weapon"," Boxer\n Knife\n Deagle\n MP5\n M4\n Sniper\n Shotgun","Select","Cancel");
	}
	if(CP[playerid] == 2)
	{
	DisablePlayerCheckpoint(playerid);
    ShowPlayerDialog(playerid,DIALOG_WEAPON,DIALOG_STYLE_LIST,"Weapon"," Boxer\n Knife\n Deagle\n MP5\n M4\n Sniper\n Shotgun","Select","Cancel");
	}
	if(CP[playerid] == 3)
	{
	DisablePlayerCheckpoint(playerid);
    ShowPlayerDialog(playerid,DIALOG_WEAPON,DIALOG_STYLE_LIST,"Weapon"," Boxer\n Knife\n Deagle\n MP5\n M4\n Sniper\n Shotgun","Select","Cancel");
	}
	if(CP[playerid] == 4)
	{
	DisablePlayerCheckpoint(playerid);
    ShowPlayerDialog(playerid,DIALOG_WEAPON,DIALOG_STYLE_LIST,"Weapon"," Boxer\n Knife\n Deagle\n MP5\n M4\n Sniper\n Shotgun","Select","Cancel");
	}
	if(CP[playerid] == 5)
	{
	DisablePlayerCheckpoint(playerid);
    ShowPlayerDialog(playerid,DIALOG_WEAPON,DIALOG_STYLE_LIST,"Weapon"," Boxer\n Knife\n Deagle\n MP5\n M4\n Sniper\n Shotgun","Select","Cancel");
	}
	if(CP[playerid] == 6)
	{
	DisablePlayerCheckpoint(playerid);
    ShowPlayerDialog(playerid,DIALOG_WEAPON,DIALOG_STYLE_LIST,"Weapon"," Boxer\n Knife\n Deagle\n MP5\n M4\n Sniper\n Shotgun","Select","Cancel");
	}
	if(CP[playerid] == 7)
	{
	DisablePlayerCheckpoint(playerid);
    ShowPlayerDialog(playerid,DIALOG_WEAPON,DIALOG_STYLE_LIST,"Weapon"," Boxer\n Knife\n Deagle\n MP5\n M4\n Sniper\n Shotgun","Select","Cancel");
	}
	CP[playerid] = 0;
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	if(CPProgess[playerid] == TotalCP -1)
	{
		new
		    TimeStamp,
		    TotalRaceTime,
		    string[256],
		    rFile[256],
		    pName2[MAX_PLAYER_NAME],
			rTime[3],
			Prize[2],
			TempTotalTime,
			TempTime[3]
		;
		Position++;
		GetPlayerName(playerid, pName2, sizeof(pName2));
		TimeStamp = GetTickCount();
		TotalRaceTime = TimeStamp - RaceTick;
		ConvertTime(var, TotalRaceTime, rTime[0], rTime[1], rTime[2]);
		switch(Position)
		{
		    case 1: Prize[0] = (random(random(5000)) + 30000), Prize[1] = 20;
		    case 2: Prize[0] = (random(random(4500)) + 25000), Prize[1] = 15;
		    case 3: Prize[0] = (random(random(4000)) + 20000), Prize[1] = 10;
		    case 4: Prize[0] = (random(random(3500)) + 15000), Prize[1] = 8;
		    case 5: Prize[0] = (random(random(3000)) + 10000), Prize[1] = 5;
		    case 6: Prize[0] = (random(random(2500)) + 8000), Prize[1] = 4;
		    case 7: Prize[0] = (random(random(2000)) + 7000), Prize[1] = 3;
		    case 8: Prize[0] = (random(random(1500)) + 6000), Prize[1] = 2;
		    case 9: Prize[0] = (random(random(1000)) + 5000), Prize[1] = 1;
		    default: Prize[0] = random(random(1000)), Prize[1] = 1;
		}
		format(string, sizeof(string), ">> %s has finished the race in position %d - Wins: \"$%d and +%d Score\", with Time: \"%d:%d.%d\"!", pName2, Position, Prize[0], Prize[1], rTime[0], rTime[1], rTime[2]);
		SendClientMessageToAll(COLWHITE, string);
		Joined[playerid] = false;
        Nitro[playerid] = true;
        Bounce[playerid] = true;
        AutoFix[playerid] = true;
		TextDrawHideForPlayer(playerid, RaceInfo[playerid]);
        TextDrawDestroy(RaceInfo[playerid]);
		//PlayerInfo[playerid][Races]++;
		//SetPVarInt(playerid, "Races", PlayerInfo[playerid][Races]);
		CPProgess[playerid] = 0;
		KillTimer(InfoTimer[playerid]);
        new RaceVeh = GetPlayerVehicleID(playerid);
        RemovePlayerFromVehicle(playerid);
		DestroyVehicle(RaceVeh);
		SetPlayerPosition(playerid, 1617.1729,1272.0662,10.7556,75.9016);
		if(FinishCount <= 5)
		{
			format(rFile, sizeof(rFile), "/Race/%s.RRACE", RaceName);
		    format(string, sizeof(string), "BestRacerTime_%d", TimeProgress);
		    TempTotalTime = dini_Int(rFile, string);
		    ConvertTime(var1, TempTotalTime, TempTime[0], TempTime[1], TempTime[2]);
		    if(TotalRaceTime <= dini_Int(rFile, string) || TempTotalTime == 0)
		    {
		        dini_IntSet(rFile, string, TotalRaceTime);
				format(string, sizeof(string), "BestRacer_%d", TimeProgress);
		        if(TempTotalTime != 0) format(string, sizeof(string), ">> \"%s\" has broken the record of \"%s\" with \"%d\" seconds faster on the \"%d\"'st/th place!", pName2, dini_Get(rFile, string), -(rTime[1] - TempTime[1]), TimeProgress+1);
				else format(string, sizeof(string), ">> \"%s\" has broken a new record of on the \"%d\"'st/th place!", pName2, TimeProgress+1);
				SendClientMessageToAll(COLGREEN, string);
				format(string, sizeof(string), "BestRacer_%d", TimeProgress);
				dini_Set(rFile, string, pName2);
				TimeProgress++;
		    }
		}
		FinishCount++;
		GivePlayerMoneyEx(playerid, Prize[0]);
		SetPlayerScore(playerid, GetPlayerScore(playerid) + Prize[1]);
		DisablePlayerRaceCheckpoint(playerid);
		CPProgess[playerid]++;
		if(FinishCount >= JoinCount) return StopRace();
    }
	else
	{
		CPProgess[playerid]++;
		CPCoords[CPProgess[playerid]][3]++;
		RacePosition[playerid] = floatround(CPCoords[CPProgess[playerid]][3], floatround_floor);
	    SetCP(playerid, CPProgess[playerid], CPProgess[playerid]+1, TotalCP, RaceType);
	    PlayerPlaySound(playerid, 1137, 0.0, 0.0, 0.0);
	}
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	//StopAudioStreamForPlayer(playerid);
	APlayerData[playerid][CurrentBusiness] = 0;
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	for(new i=0;i<sizeof(GangInfo);i++)
	{
	    if(pickupid == PDWeapons[i])
	    {
	        new org=-1;
		    if(PlayerInfo[playerid][aLeader] > -1)
			{
				org = PlayerInfo[playerid][aLeader];
			}
			if(PlayerInfo[playerid][aMember] > -1)
			{
				org = PlayerInfo[playerid][aMember];
			}
			if(GangInfo[org][AllowedPD] == 1)
			{
				if(Pick[playerid] == 0)
				{
					ShowPlayerDialog(playerid,DIALOG_PDWEAPONS,DIALOG_STYLE_LIST,"PD weapons"," Patrol\n Pursuit\n Special\n Professional\n Undercover\n Sniper\n Heal and Armour\n Taser","Select","Cancel");
					Pick[playerid]=5;
					Pic[playerid]=SetTimerEx("ReturnPick",1000,true,"i",playerid);
				}
			}
			else
			{
				return GameTextForPlayer(playerid, "~r~locked!", 3000, 1);
			}
	    }
    }
	if(pickupid == VCannon)
	{
    new Float:vx, Float:vy, Float:vz;
    new car = GetPlayerVehicleID(playerid);
    GetVehicleVelocity(car, vx, vy, vz);
    SetVehicleVelocity(car, vx*6, vy*6, vz*6);
    }
	return 1;
}


public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	if(IsBeingSpeced[playerid] == 1)//If the player being spectated, changes an interior, then update the interior and virtualword for the spectator.
    {
        for (new i = 0; i < MAX_PLAYERS; i++)
        {
            if(spectatorid[i] == playerid)
            {
                SetPlayerInterior(i,GetPlayerInterior(playerid));
                SetPlayerVirtualWorld(i,GetPlayerVirtualWorld(playerid));
            }
        }
    }
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
    if (IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && GetPVarInt(playerid,"InCNR") == 0)
    {
        if(newkeys & KEY_CROUCH)
        {
            TD_MSG(playerid, 3000, "~b~Handbrake + flip!");
            new Float: P[ 4 ];
		    GetPlayerPos( playerid, P[ 0 ], P[ 1 ], P[ 2 ] );
		    GetVehicleZAngle( GetPlayerVehicleID( playerid ) , P[ 3 ]);
		    SetVehiclePos( GetPlayerVehicleID( playerid ), P[ 0 ], P[ 1 ], P[ 2 ] );
		    SetVehicleZAngle( GetPlayerVehicleID( playerid ), P[ 3 ] );
		    PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		}
	}
	if(IsPlayerInAnyVehicle(playerid))
	{
	    if((newkeys & 128) && !(oldkeys & 128))
	    {
		    StopLoopingAnim(playerid);
		}
	}
    else if((newkeys & KEY_CTRL_BACK) && !(oldkeys & KEY_CTRL_BACK))
	{
		StopLoopingAnim(playerid);
	}
	if(newkeys == KEY_FIRE)
	{
		new specid = GetPVarInt(playerid, "DuelSpecID");
		if(GetPVarInt(playerid, "DuelSpec") && IsPlayerInDuel(specid))
		{
		    SetPlayerSpectatingDuel(playerid, GetDuelerID(specid));
		}
		if( PlayerInfo[ playerid ][ ActionID ] == 2 ) // ( CnR )
		{
	        if(IsSpecating[playerid] == 1)
	        {
					TextDrawHideForPlayer(playerid, KillerTD0);
					TextDrawHideForPlayer(playerid, KillerTD1);
					TextDrawHideForPlayer(playerid, KillerTD2);
					TextDrawHideForPlayer(playerid, KillerTD3);
					TextDrawHideForPlayer(playerid, KillerTD4);
					TextDrawHideForPlayer(playerid, KillerTD5);
					TextDrawHideForPlayer(playerid, KillerTD6);
					TextDrawHideForPlayer(playerid, KillerTD7);
					TextDrawHideForPlayer(playerid, KillerTD8);
					TextDrawHideForPlayer(playerid, KillerTD9);
			        TogglePlayerSpectating(playerid, false);
			        IsSpecating[playerid] =0;
			        KillTimer( KillerTimer[ playerid] );
	                if ( GetPlayerTeam( playerid ) == TEAM_COPS)
	                {
	                    RespawnplayerCop( playerid );
					}
	                if ( GetPlayerTeam( playerid ) == TEAM_ARMY)
	                {
	                    RespawnplayerArmy( playerid );
					}
	                if ( GetPlayerTeam( playerid ) == TEAM_SWAT)
	                {
	                    RespawnplayerSwat( playerid );
					}
	                if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS)
	                {
	                    RespawnplayerRobber( playerid );
					}
	                if ( GetPlayerTeam( playerid ) == TEAM_PROROBBERS)
	                {
	                    RespawnplayerProRobber( playerid );
					}
	                if ( GetPlayerTeam( playerid ) == TEAM_EROBBERS)
	                {
	                    RespawnplayerERobber( playerid );
					}

	        }
        }
	}
    if( newkeys == KEY_SECONDARY_ATTACK )
	{
	    for(new i=0;i<MAX_GANG;i++)
	    {
		    if(IsPlayerInRangeOfPoint(playerid, 3.0, GangInfo[i][uX], GangInfo[i][uY], GangInfo[i][uZ]) && !IsPlayerInAnyVehicle(playerid) && (PlayerInfo[playerid][aMember] == i || PlayerInfo[playerid][aLeader] == i))
			{
				SetPlayerVirtualWorld(playerid, GangInfo[i][VW]);
				SetPlayerInterior(playerid, GangInfo[i][Int]);
				SetPlayerPos(playerid, GangInfo[i][iX], GangInfo[i][iY], GangInfo[i][iZ]);
			}
			if(IsPlayerInRangeOfPoint(playerid, 3.0, GangInfo[i][iX], GangInfo[i][iY], GangInfo[i][iZ]) && !IsPlayerInAnyVehicle(playerid))
			{
				SetPlayerVirtualWorld(playerid, GangInfo[i][VW]);
				SetPlayerInterior(playerid, GangInfo[i][Int]);
				SetPlayerPos(playerid, GangInfo[i][uX], GangInfo[i][uY], GangInfo[i][uZ]);
			}
	    }
	}
	if(PRESSED(KEY_LOOK_BEHIND))
	{
		if ( PlayerInfo[ playerid ][ ActionID ] == 2 )
		{
			if ( GetPlayerTeam( playerid ) != TEAM_COPS && GetPlayerTeam( playerid ) != TEAM_ARMY && GetPlayerTeam( playerid ) != TEAM_SWAT ) 		return  SendClientMessage(playerid, COLOR_RED,"{FF0000}ERROR: {C8C8C8}You must be a cop while in a /CnR minigame to use this command!");
			new targetid = GetClosestPlayer( playerid, .checkvw = true, .range = 2.0 );
		  	if( targetid == INVALID_PLAYER_ID ) 				return SendClientMessage(playerid, COLOR_RED,"{FF0000}CnR: {778899}No criminals near your range.");
			if( Cuffed[ targetid ] == true ) 					return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}The robber is already arrested!");
			if(GetPlayerWantedLevel(targetid) < 1) return SendClientMessage(playerid, COLOR_RED,"{FF0000}ERROR: Player has Warning Level of 0 or lower!");
			if(GetPlayerTeam( targetid ) != TEAM_ROBBERS && GetPlayerTeam( targetid ) != TEAM_PROROBBERS && GetPlayerTeam( targetid ) != TEAM_EROBBERS   ) 	return 1;
		    PlayerInfo[ targetid ][ Timearrested]++;
		    PlayerInfo[ targetid ][ Jailed ] = 1;
		    PlayerInfo[ targetid ][ BreakCuffs ] = 1;
		    foreach( Player, i )
			{
				if ( GetPlayerTeam( playerid ) == TEAM_COPS )
				{
		   			FormatMSG( i, ~1, "{7A7A7A}[CnR] {D2D2AB}Suspect %s(%d) has been arrested by Officer %s(%d).", PlayerName( targetid ), targetid, PlayerName( playerid ), playerid );
				}
				if ( GetPlayerTeam( playerid ) == TEAM_ARMY )
				{
					FormatMSG( i, ~1, "{7A7A7A}[CnR] {D2D2AB}Suspect %s(%d) has been arrested by {5A00FF}Army Officer {D2D2AB}%s(%d).", PlayerName( targetid ), targetid, PlayerName( playerid ), playerid );
				}
				if ( GetPlayerTeam( playerid ) == TEAM_SWAT )
				{
					FormatMSG( i, ~1, "{7A7A7A}[CnR] {D2D2AB}Suspect %s(%d) has been arrested by {15D4ED}Swat Captain {D2D2AB}%s(%d).", PlayerName( targetid ), targetid, PlayerName( playerid ), playerid );

				}
			}
		    GivePlayerMoneyEx(playerid, 6500);
		    SetPlayerScore(playerid, GetPlayerScore(playerid) + 2);
			jailtimer = SetTimerEx( "Jailtimer", 4000, 0, "i", targetid );
			jailtimer2 = SetTimerEx( "CnrJailRefresh", 4000, 0, "i", targetid );
			Announce( playerid, "~r~~h~SUSPECT ARRESTED!", 4000, 4 );
			Announce( targetid, "~r~ARRESTED~w~!~nl~~w~TYPE /BREAKCUFFS [/BC]~nl~~w~TO ESCAPE!", 4000, 4 );
		    SendClientMessage(playerid, COLOR_RED,"{FF0000}- CnR -  {3BBD44}You have received 2 score and $6500 for catching a criminal!");
			SendClientMessage(targetid, COLOR_RED,"{FF0000}CNR {7A7A7A}»{DBED15} {FF0000}You have been cuffed and arrested!");
			SendClientMessage(targetid, COLOR_RED,"{FF0000}CNR {7A7A7A}»{DBED15} {FF0000}You will serve 30 seconds in jail.");
			PlayerInfo[ playerid ][ Arrests]++;
		}
	}
	if (IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && GetPVarInt(playerid,"InCNR") == 0)
 	{
		if(newkeys & KEY_FIRE)
        {
			if(Nitro[playerid] == 1)
 			{
        		new Float:vx,Float:vy,Float:vz, vehID;
				vehID = GetPlayerVehicleID(playerid);
				AddVehicleComponent(vehID, 1008);
        		GetVehicleVelocity(GetPlayerVehicleID(playerid),vx,vy,vz);
        		SetVehicleVelocity(GetPlayerVehicleID(playerid), vx * SBvalue[playerid], vy * SBvalue[playerid], vz * SBvalue[playerid]);
			}
        }
   	}
	if (IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && GetPVarInt(playerid,"InCNR") == 0)
 	{
  		if (newkeys & KEY_LOOK_BEHIND)
        {
			if(Bounce[playerid] == 1)
        	{
        		new Float:x, Float:y, Float:z;
        		GetVehicleVelocity(GetPlayerVehicleID(playerid),x,y,z);
        		SetVehicleVelocity(GetPlayerVehicleID(playerid),x,y,z+0.3);
        	}
        }
	}
		new
 		string[256],
 		rNameFile[256],
   		rFile[256],
     	Float: vPos[4]
	;
	if(newkeys & KEY_FIRE)
	{
	    if(BuildRace == playerid+1)
	    {
		    if(BuildTakeVehPos == true)
		    {
		    	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLRED, ">> You need to be in a vehicle");
				format(rFile, sizeof(rFile), "/Race/%s.RRACE", BuildName);
				GetVehiclePos(GetPlayerVehicleID(playerid), vPos[0], vPos[1], vPos[2]);
				GetVehicleZAngle(GetPlayerVehicleID(playerid), vPos[3]);
		        dini_Create(rFile);
				dini_IntSet(rFile, "vModel", BuildModeVID);
				dini_IntSet(rFile, "rType", BuildRaceType);
		        format(string, sizeof(string), "vPosX_%d", BuildVehPosCount), dini_FloatSet(rFile, string, vPos[0]);
		        format(string, sizeof(string), "vPosY_%d", BuildVehPosCount), dini_FloatSet(rFile, string, vPos[1]);
		        format(string, sizeof(string), "vPosZ_%d", BuildVehPosCount), dini_FloatSet(rFile, string, vPos[2]);
		        format(string, sizeof(string), "vAngle_%d", BuildVehPosCount), dini_FloatSet(rFile, string, vPos[3]);
		        format(string, sizeof(string), ">> Vehicle Pos '%d' has been taken.", BuildVehPosCount+1);
		        SendClientMessage(playerid, COLYELLOW, string);
				BuildVehPosCount++;
			}
   			if(BuildVehPosCount >= 2)
		    {
		        BuildVehPosCount = 0;
		        BuildTakeVehPos = false;
		        ShowDialog(playerid, 605);
		    }
			if(BuildTakeCheckpoints == true)
			{
			    if(BuildCheckPointCount > MAX_RACE_CHECKPOINTS_EACH_RACE) return SendClientMessage(playerid, COLRED, ">> You reached the maximum amount of checkpoints!");
			    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLRED, ">> You need to be in a vehicle");
				format(rFile, sizeof(rFile), "/Race/%s.RRACE", BuildName);
				GetVehiclePos(GetPlayerVehicleID(playerid), vPos[0], vPos[1], vPos[2]);
				format(string, sizeof(string), "CP_%d_PosX", BuildCheckPointCount), dini_FloatSet(rFile, string, vPos[0]);
				format(string, sizeof(string), "CP_%d_PosY", BuildCheckPointCount), dini_FloatSet(rFile, string, vPos[1]);
				format(string, sizeof(string), "CP_%d_PosZ", BuildCheckPointCount), dini_FloatSet(rFile, string, vPos[2]);
    			format(string, sizeof(string), ">> Checkpoint '%d' has been setted!", BuildCheckPointCount+1);
		        SendClientMessage(playerid, COLYELLOW, string);
				BuildCheckPointCount++;
			}
		}
	}
	if(newkeys & KEY_SECONDARY_ATTACK)
	{
	    if(BuildTakeCheckpoints == true)
	    {
	        ShowDialog(playerid, 606);
			format(rNameFile, sizeof(rNameFile), "/Race/RaceNames/RaceNames.txt");
			TotalRaces = dini_Int(rNameFile, "TotalRaces");
			TotalRaces++;
			dini_IntSet(rNameFile, "TotalRaces", TotalRaces);
			format(string, sizeof(string), "Race_%d", TotalRaces-1);
			format(rFile, sizeof(rFile), "/Race/%s.RRACE", BuildName);
			dini_Set(rNameFile, string, BuildName);
			dini_IntSet(rFile, "TotalCP", BuildCheckPointCount);
			Loop2(x, 5)
			{
				format(string, sizeof(string), "BestRacerTime_%d", x);
				dini_Set(rFile, string, "0");
				format(string, sizeof(string), "BestRacer_%d", x);
				dini_Set(rFile, string, "noone");
			}
	    }
	}
	return 1;
}

stock getEmptyID(const len, const lokacija[])
{
    new id = (-1);
    for(new loop = (0), provjera = (-1), Data_[64] = "\0"; loop != len; loop++)
    {
       provjera = (loop);
       format(Data_, (sizeof Data_), lokacija ,provjera);
       if(!fexist(Data_))
       {
          id = (provjera);
          break;
       }
    }
	return (id);
}

stock GetVehicleSpeed(vehicleid)
{
    new Float:V[3];
    GetVehicleVelocity(vehicleid, V[0], V[1], V[2]);
    return floatround(floatsqroot(V[0] * V[0] + V[1] * V[1] + V[2] * V[2]) * 180.00);
}
stock GetPlayerID(const name[])
{
    for(new i; i<MAX_PLAYERS; i++)
    {
      if(IsPlayerConnected(i))
      {
        new GpName[MAX_PLAYER_NAME];
        GetPlayerName(i, GpName, sizeof(GpName));
        if(strcmp(name, GpName, true)==0)
        {
          return i;
        }
      }
    }
    return -1;
}

forward GJailTimer(playerid,org);
public GJailTimer(playerid,org)
{
	if(GJailed[playerid] == 1)
	{
		if(GJailTime[playerid] == 0)
		{
			GJailed[playerid] = 0;
			SendClientMessage(playerid,-1,"You are released from prison");
			SetPlayerPos(playerid,GangInfo[org][puX], GangInfo[org][puY], GangInfo[org][puZ]);
		}
		else
		{
			GJailTime[playerid]  -= 1000;
			SetTimerEx("GJailTimer", 1000,false,"id",playerid,org);
		}
	}
	return 1;
}
forward RadarPicture(playerid);
public RadarPicture(playerid)
{
	Pictured[playerid] = 0;
	return 1;
}
forward Taz1(playerid);
public Taz1(playerid)
{
	EmptyTaser[playerid] = 0;
	return 1;
}
forward Tazz(playerid);
public Tazz(playerid)
{
	TogglePlayerControllable(playerid,1);
	Tazan[playerid] = 0;
	return 1;
}

forward ProxDetector(Float:radi, playerid, string[],col1,col2,col3,col4,col5);
public ProxDetector(Float:radi, playerid, string[],col1,col2,col3,col4,col5)
{
    if(IsPlayerConnected(playerid))
    {
        new Float:posx, Float:posy, Float:posz;
        new Float:oldposx, Float:oldposy, Float:oldposz;
        new Float:tempposx, Float:tempposy, Float:tempposz;
        GetPlayerPos(playerid, oldposx, oldposy, oldposz);
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(IsPlayerConnected(i))
            {
                GetPlayerPos(i, posx, posy, posz);
                tempposx = (oldposx -posx);
                tempposy = (oldposy -posy);
                tempposz = (oldposz -posz);
                if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i))
                {
                    if (((tempposx < radi/16) && (tempposx > -radi/16)) && ((tempposy < radi/16) && (tempposy > -radi/16)) && ((tempposz < radi/16) && (tempposz > -radi/16)))
                    {
                        SendClientMessage(i, col1, string);
                    }
                    else if (((tempposx < radi/8) && (tempposx > -radi/8)) && ((tempposy < radi/8) && (tempposy > -radi/8)) && ((tempposz < radi/8) && (tempposz > -radi/8)))
                    {
                        SendClientMessage(i, col2, string);
                    }
                    else if (((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4)))
                    {
                        SendClientMessage(i, col3, string);
                    }
                    else if (((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2)))
                    {
                        SendClientMessage(i, col4, string);
                    }
                    else if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
                    {
                        SendClientMessage(i, col5, string);
                    }
                }
            }
        }
    }
    return 1;
}

public OnPlayerUpdate(playerid)
{
	if(InDuel[playerid] == 1) SetPlayerTeam(playerid, NO_TEAM);
    new playerState = GetPlayerState(playerid);
    if(IsPlayerInAnyVehicle(playerid) && playerState == PLAYER_STATE_DRIVER)
	{
	    RadarCheck(playerid);
	}
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

//============================[ EOF ]===========================================
public VehicleSpawner(playerid,model){
	if(IsPlayerInAnyVehicle(playerid)){
		SendClientMessage(playerid, COLOR_RED, "Error: You're already in vehicle!");
 	}
 	else{
	if(VehicleSpawn[playerid]==0){
	new Float:x,Float:y,Float:z,Float:a, vehicleid;
    GetPlayerPos(playerid,x,y,z);
    GetPlayerFacingAngle(playerid,a);
    vehicleid = CreateVehicle(model,x+1,y+1,z,a,-1,-1,-1);
	PutPlayerInVehicle(playerid, vehicleid, 0);
    SetVehicleHealth(vehicleid,  1000.0);
    LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid));
	for(new i=0;i<MAX_PLAYERVEHICLES;i++){
    if(Turn[playerid]==MAX_PLAYERVEHICLES){
    CarDeleter(playerid, PlayerVehicle[playerid][0]);
    new b=MAX_PLAYERVEHICLES-1;
    for(new c=0;c<b;c++){
    new A=c+1;
    PlayerVehicle[playerid][c]=PlayerVehicle[playerid][A];
    }
    PlayerVehicle[playerid][b]=0;
    Turn[playerid]--;
	}
	if(!PlayerVehicle[playerid][i]){
	PlayerVehicle[playerid][i]=vehicleid;
	Turn[playerid]++;
	break;
    }
  }
}
		else{
		 	new string[256];
			format(string, sizeof(string), "Please wait %d sec. to spawn again a vehicle!", VehicleSpawn[playerid]);
			SendClientMessage(playerid,COLOR_RED, string);
		}
	}
}

forward CarDeleter(playerid, vehicleid);
public CarDeleter(playerid, vehicleid)
{
      new Float:X5,Float:Y5,Float:Z5;
      if(PlayerInfo[playerid][pCar] != 0)
      {
    	    RemovePlayerFromVehicle(playerid);
    	    GetPlayerPos(playerid,X5,Y5,Z5);
        	SetPlayerPos(playerid,X5,Y5+3,Z5);
       }
       SetVehicleParamsForPlayer(vehicleid,playerid,0,1);
       SetTimerEx("CarReseter",1000,0,"i",vehicleid);
}

public CarReseter(vehicleid)
{
    DestroyVehicle(vehicleid);
}

public VehicleSpawnerLimiter(){
	new i;
	for(i=0;i<=MAX_PLAYERS;i++){
	    if(VehicleSpawn[i]>0){
   	 		VehicleSpawn[i]--;
	    }
	}
}

forward RadarCheck(playerid);
public RadarCheck(playerid)
{
	new org;
	if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
	if(GangInfo[org][AllowedPD] == 1) {return 1;}
    for(new i=0; i<MAX_PLAYERS; i++)
    {
        if(PlacedRadar[i] == 1)
        {
            new Float:rX,Float:rY,Float:rZ;
            GetDynamicObjectPos(RadarObject[i],rX,rY,rZ);
            if(Pictured[playerid] == 0)
            {
	            if(IsPlayerInRangeOfPoint(playerid,30.0,rX,rY,rZ))
	            {
	                new GVehId = GetPlayerVehicleID(playerid);
					if(GetVehicleSpeed(GVehId) > SpeedRadar[i])
					{
					   Pictured[playerid] = 1;
					   new String[200];
					   format(String,sizeof(String),"{FF0000}Radar | {FF9900}Ticket: {FFFFFF}%d$ {FF0000}| {FF9900}You drive {FFFFFF}%d km/h {FF0000}| {FF9900}Allowed {FFFFFF}%d km/h {FF0000}| {FF9900}Pictured: {FFFFFF}%s",PriceRadar[i],GetVehicleSpeed(GVehId),SpeedRadar[i],GetName(i));
					   SendClientMessage(playerid,-1,String);
					   GivePlayerMoneyEx(playerid,-PriceRadar[i]);
                       format(String,sizeof(String),"{FF0000}Radar | {FF9900}Ticket: {FFFFFF}%d$ {FF0000}| {FF9900}He drive {FFFFFF}%d km/h {FF0000}| {FF9900}Allowed {FFFFFF}%d km/h {FF0000}| {FF9900}Name: {FFFFFF}%s",PriceRadar[i],GetVehicleSpeed(GVehId),SpeedRadar[i],GetName(playerid));
					   SendClientMessage(i,-1,String);
                       SetTimerEx("RadarPicture", 6500,false,"i",playerid);
					}
	            }
			}
        }
    }
	return 1;
}
forward ChatGang(idorg, const string[]);
public ChatGang(idorg, const string[])
{
	foreach(Player, i)
	{
		if(PlayerInfo[i][aLeader] == idorg || PlayerInfo[i][aMember] == idorg) SendClientMessage(i, -1, string);
	}
	return 1;
}
forward DChat(const string[]);
public DChat(const string[])
{
	for(new a=0;a<sizeof(GangInfo);a++)
	{
	    if(GangInfo[a][AllowedD] == 1)
		{
		    foreach(Player, i)
			{
			    if(PlayerInfo[i][aLeader] == a || PlayerInfo[i][aMember] == a)
			    {
					SendClientMessage(i, -1, string);
				}
			}
		}
	}
	return 1;
}
forward FDChat(const string[]);
public FDChat(const string[])
{
	for(new a=0;a<sizeof(GangInfo);a++)
	{
	    if(GangInfo[a][AllowedFD] == 1)
		{
		    foreach(Player, i)
			{
			    if(PlayerInfo[i][aLeader] == a || PlayerInfo[i][aMember] == a)
			    {
					SendClientMessage(i, -1, string);
				}
			}
		}
	}
	return 1;
}
forward PDChat(const string[]);
public PDChat(const string[])
{
	for(new a=0;a<sizeof(GangInfo);a++)
	{
	    if(GangInfo[a][AllowedPD] == 1)
		{
		    foreach(Player, i)
			{
			    if(PlayerInfo[i][aLeader] == a || PlayerInfo[i][aMember] == a)
			    {
					SendClientMessage(i, -1, string);
				}
			}
		}
	}
	return 1;
}
forward HChat(const string[]);
public HChat(const string[])
{
	for(new a=0;a<sizeof(GangInfo);a++)
	{
	    if(GangInfo[a][AllowedH] == 1)
		{
		    foreach(Player, i)
			{
			    if(PlayerInfo[i][aLeader] == a || PlayerInfo[i][aMember] == a)
			    {
					SendClientMessage(i, -1, string);
				}
			}
		}
	}
	return 1;
}

forward LoadFire(pozid,name[],value[]);
public LoadFire(pozid,name[],value[])
{
    INI_Float("GX",FireInfo[pozid][GX]);
    INI_Float("GY",FireInfo[pozid][GY]);
    INI_Float("GZ",FireInfo[pozid][GZ]);
    INI_Float("GX1",FireInfo[pozid][GX1]);
    INI_Float("GY1",FireInfo[pozid][GY1]);
    INI_Float("GZ1",FireInfo[pozid][GZ1]);
    INI_Float("GX2",FireInfo[pozid][GX2]);
    INI_Float("GY2",FireInfo[pozid][GY2]);
    INI_Float("GZ2",FireInfo[pozid][GZ2]);
    INI_Float("GX3",FireInfo[pozid][GX3]);
    INI_Float("GY3",FireInfo[pozid][GY3]);
    INI_Float("GZ3",FireInfo[pozid][GZ3]);
    INI_Float("GX4",FireInfo[pozid][GX4]);
    INI_Float("GY4",FireInfo[pozid][GY4]);
    INI_Float("GZ4",FireInfo[pozid][GZ4]);
    INI_Int("FireNumber",FireNumber);
	return 1;
}
////////////////////////////////////////////////
stock SaveFire(pozid)
{
    new str[64]; format(str,64,"Gangs/Fire/%d.ini",pozid);
	new INI:File = INI_Open(str);
 	INI_SetTag(File,"Fire");
 	INI_WriteFloat(File,"GX", FireInfo[pozid][GX]);
 	INI_WriteFloat(File,"GY", FireInfo[pozid][GY]);
 	INI_WriteFloat(File,"GZ", FireInfo[pozid][GZ]);
 	INI_WriteFloat(File,"GX1", FireInfo[pozid][GX1]);
 	INI_WriteFloat(File,"GY1", FireInfo[pozid][GY1]);
 	INI_WriteFloat(File,"GZ1", FireInfo[pozid][GZ1]);
 	INI_WriteFloat(File,"GX2", FireInfo[pozid][GX2]);
 	INI_WriteFloat(File,"GY2", FireInfo[pozid][GY2]);
 	INI_WriteFloat(File,"GZ2", FireInfo[pozid][GZ2]);
 	INI_WriteFloat(File,"GX3", FireInfo[pozid][GX3]);
 	INI_WriteFloat(File,"GY3", FireInfo[pozid][GY3]);
 	INI_WriteFloat(File,"GZ3", FireInfo[pozid][GZ3]);
 	INI_WriteFloat(File,"GX4", FireInfo[pozid][GX4]);
 	INI_WriteFloat(File,"GY4", FireInfo[pozid][GY4]);
 	INI_WriteFloat(File,"GZ4", FireInfo[pozid][GZ4]);
 	INI_WriteInt(File,"FireNumber", FireNumber);
	INI_Close(File);
	return 1;
}
forward LoadPlayer_data(playerid,name[],value[]);
public LoadPlayer_data(playerid,name[],value[])
{
    INI_Int("pLeader",PlayerInfo[playerid][aLeader]);
    INI_Int("pMember",PlayerInfo[playerid][aMember]);
    INI_Int("pRank",PlayerInfo[playerid][Rank]);
    INI_Int("Skin",PlayerInfo[playerid][pSkin]);
	return 1;
}
////////////////////////////////////////////////
stock SavePlayer(playerid)
{
    new str[64]; format(str,64,"Gangs/Users/%s",GetName(playerid));
	new INI:File = INI_Open(str);
 	INI_SetTag(File,"data");
 	INI_WriteInt(File,"pLeader", PlayerInfo[playerid][aLeader]);
 	INI_WriteInt(File,"pMember", PlayerInfo[playerid][aMember]);
 	INI_WriteInt(File,"pRank", PlayerInfo[playerid][Rank]);
 	INI_WriteInt(File,"Skin", PlayerInfo[playerid][pSkin]);
	INI_Close(File);
	return 1;
}

stock SaveStats (playerid)
{
		new INI:File = INI_Open(UserPath(playerid));
	    INI_SetTag(File, "Player's Data");
	    INI_WriteString(File, "LastActive", TimeAndDate());
	    INI_WriteString(File, "AltName", PlayerInfo[playerid][AltName]);
	    INI_WriteInt(File, "WeaponSet", PlayerInfo[playerid][WeaponSet]);
	    INI_WriteHex(File, "Color", GetPlayerColor(playerid));
   		INI_WriteFloat(File, "SpawnPosX", PlayerInfo[playerid][POS_X], 6);
		INI_WriteFloat(File, "SpawnPosY", PlayerInfo[playerid][POS_Y], 6);
		INI_WriteFloat(File, "SpawnPosZ", PlayerInfo[playerid][POS_Z], 6);
		INI_WriteInt(File, "Helmet", PlayerInfo[playerid][Helmet]);
		INI_Close(File);
		return 1;
}

forward loadaccount_user(playerid, name[], value[]);
public loadaccount_user(playerid, name[], value[])
{
	INI_String("LastActive", lastactive, 50);
	INI_String("AltName", PlayerInfo[playerid][AltName], 30);
	INI_Int("WeaponSet", PlayerInfo[playerid][WeaponSet]);
	INI_Hex("Color", PlayerInfo[playerid][Color]);
	INI_Float("SpawnPosX", PlayerInfo[playerid][POS_X]);
	INI_Float("SpawnPosY", PlayerInfo[playerid][POS_Y]);
	INI_Float("SpawnPosZ", PlayerInfo[playerid][POS_Z]);
	INI_Int("Helmet", PlayerInfo[playerid][Helmet]);
	return 1;
}

forward loadserverstats(name[], value[]);
public loadserverstats(name[], value[])
{
	INI_Int("Total_Registered_Users", gTotalRegisters);
	INI_Int("Total_Kills", gTotalKills);
	INI_Int("Total_Bans", gTotalBans);
	INI_String("Last_Restarted_Time", gLastRestartedTime, 10);
	INI_String("Last_Restarted_Date", gLastRestartedDate, 10);
	return 1;
}

forward LoadGangs(idorg,name[],value[]);
public LoadGangs(idorg,name[],value[])
{
    for(new i=0;i<15;i++)
	{
		new string[128];
		format(string,sizeof(string),"Created%d",i);
		INI_Int(string,vCreated[idorg][i]);
	}
	for(new i=0;i<15;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehicle%d",i);
		INI_Int(string,VehiclesID[idorg][i]);
	}
	for(new i=0;i<15;i++)
	{
		new string[128];
		format(string,sizeof(string),"VehicleB%d",i);
		INI_Int(string,VehiclesColor[idorg][i]);
	}
	INI_Float("uX",GangInfo[idorg][uX]);
	INI_Float("uY",GangInfo[idorg][uY]);
	INI_Float("uZ",GangInfo[idorg][uZ]);
	INI_Float("iX",GangInfo[idorg][iX]);
	INI_Float("iY",GangInfo[idorg][iY]);
	INI_Float("iZ",GangInfo[idorg][iZ]);
	INI_Float("sX",GangInfo[idorg][sX]);
	INI_Float("sY",GangInfo[idorg][sY]);
	INI_Float("sZ",GangInfo[idorg][sZ]);
	INI_Float("LokX",GangInfo[idorg][LokX]);
	INI_Float("LokY",GangInfo[idorg][LokY]);
	INI_Float("LokZ",GangInfo[idorg][LokZ]);
	INI_Float("orX",GangInfo[idorg][orX]);
	INI_Float("orY",GangInfo[idorg][orY]);
	INI_Float("orZ",GangInfo[idorg][orZ]);
	INI_Float("puX",GangInfo[idorg][puX]);
	INI_Float("puY",GangInfo[idorg][puY]);
	INI_Float("puZ",GangInfo[idorg][puZ]);
	INI_Float("arX",GangInfo[idorg][arX]);
	INI_Float("arY",GangInfo[idorg][arY]);
	INI_Float("arZ",GangInfo[idorg][arZ]);
	INI_Float("duX",GangInfo[idorg][duX]);
	INI_Float("duY",GangInfo[idorg][duY]);
	INI_Float("duZ",GangInfo[idorg][duZ]);
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek1%d",i);
		INI_Float(string,Vehicle[idorg][i][0]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek2%d",i);
		INI_Float(string,Vehicle[idorg][i][1]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek3%d",i);
		INI_Float(string,Vehicle[idorg][i][2]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek4%d",i);
		INI_Float(string,Vehicle[idorg][i][3]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek5%d",i);
		INI_Float(string,Vehicle[idorg][i][4]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek6%d",i);
		INI_Float(string,Vehicle[idorg][i][5]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek7%d",i);
		INI_Float(string,Vehicle[idorg][i][6]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek8%d",i);
		INI_Float(string,Vehicle[idorg][i][7]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek9%d",i);
		INI_Float(string,Vehicle[idorg][i][8]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek10%d",i);
		INI_Float(string,Vehicle[idorg][i][9]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek11%d",i);
		INI_Float(string,Vehicle[idorg][i][10]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek12%d",i);
		INI_Float(string,Vehicle[idorg][i][11]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek13%d",i);
		INI_Float(string,Vehicle[idorg][i][12]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek14%d",i);
		INI_Float(string,Vehicle[idorg][i][13]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek15%d",i);
		INI_Float(string,Vehicle[idorg][i][14]);
	}
	INI_String("Leader1",Leader[0][idorg],MAX_PLAYER_NAME);
	INI_String("Leader2",Leader[1][idorg],MAX_PLAYER_NAME);
	INI_String("Member1",Member[0][idorg],MAX_PLAYER_NAME);
	INI_String("Member2",Member[1][idorg],MAX_PLAYER_NAME);
	INI_String("Member3",Member[2][idorg],MAX_PLAYER_NAME);
	INI_String("Member4",Member[3][idorg],MAX_PLAYER_NAME);
	INI_String("Member5",Member[4][idorg],MAX_PLAYER_NAME);
	INI_String("Member6",Member[5][idorg],MAX_PLAYER_NAME);
	INI_String("Member7",Member[6][idorg],MAX_PLAYER_NAME);
	INI_String("Member8",Member[7][idorg],MAX_PLAYER_NAME);
	INI_String("Member9",Member[8][idorg],MAX_PLAYER_NAME);
	INI_String("Member10",Member[9][idorg],MAX_PLAYER_NAME);
	INI_String("Member11",Member[10][idorg],MAX_PLAYER_NAME);
	INI_String("Member12",Member[11][idorg],MAX_PLAYER_NAME);
	INI_String("Name",GangInfo[idorg][Name],128);
	INI_String("Rank1",GangInfo[idorg][Rank1],128);
	INI_String("Rank2",GangInfo[idorg][Rank2],128);
	INI_String("Rank3",GangInfo[idorg][Rank3],128);
	INI_String("Rank4",GangInfo[idorg][Rank4],128);
	INI_String("Rank5",GangInfo[idorg][Rank5],128);
	INI_String("Rank6",GangInfo[idorg][Rank6],128);
	INI_Int("Int",GangInfo[idorg][Int]);
	INI_Int("VW",GangInfo[idorg][VW]);
	INI_Int("rSkin1",GangInfo[idorg][rSkin1]);
	INI_Int("rSkin2",GangInfo[idorg][rSkin2]);
	INI_Int("rSkin3",GangInfo[idorg][rSkin3]);
	INI_Int("rSkin4",GangInfo[idorg][rSkin4]);
	INI_Int("rSkin5",GangInfo[idorg][rSkin5]);
	INI_Int("rSkin6",GangInfo[idorg][rSkin6]);
	INI_Int("AllowedF",GangInfo[idorg][AllowedF]);
	INI_Int("AllowedR",GangInfo[idorg][AllowedR]);
	INI_Int("AllowedD",GangInfo[idorg][AllowedD]);
	INI_Int("AllowedH",GangInfo[idorg][AllowedH]);
	INI_Int("AllowedPD",GangInfo[idorg][AllowedPD]);
	INI_Int("AllowedFD",GangInfo[idorg][AllowedFD]);
    return 1;
}
///////////////////////////////////////////////////
stock SaveGangs(idorg)
{
	new orgFile[80];
	format(orgFile,sizeof(orgFile),GANGS,idorg);
    new INI:File = INI_Open(orgFile);
    INI_SetTag(File,"Gang");
    for(new i=0;i<15;i++)
	{
		new string[128];
		format(string,sizeof(string),"Created%d",i);
		INI_WriteInt(File,string,vCreated[idorg][i]);
	}
   	for(new i=0;i<15;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehicle%d",i);
		INI_WriteInt(File,string,VehiclesID[idorg][i]);
	}
	for(new i=0;i<15;i++)
	{
		new string[128];
		format(string,sizeof(string),"VehicleB%d",i);
		INI_WriteInt(File,string,VehiclesColor[idorg][i]);
	}
	INI_WriteFloat(File,"uX",GangInfo[idorg][uX]);
	INI_WriteFloat(File,"uY",GangInfo[idorg][uY]);
	INI_WriteFloat(File,"uZ",GangInfo[idorg][uZ]);
	INI_WriteFloat(File,"iX",GangInfo[idorg][iX]);
	INI_WriteFloat(File,"iY",GangInfo[idorg][iY]);
	INI_WriteFloat(File,"iZ",GangInfo[idorg][iZ]);
	INI_WriteFloat(File,"sX",GangInfo[idorg][sX]);
	INI_WriteFloat(File,"sY",GangInfo[idorg][sY]);
	INI_WriteFloat(File,"sZ",GangInfo[idorg][sZ]);
	INI_WriteFloat(File,"LokX",GangInfo[idorg][LokX]);
	INI_WriteFloat(File,"LokY",GangInfo[idorg][LokY]);
	INI_WriteFloat(File,"LokZ",GangInfo[idorg][LokZ]);
	INI_WriteFloat(File,"orX",GangInfo[idorg][orX]);
	INI_WriteFloat(File,"orY",GangInfo[idorg][orY]);
	INI_WriteFloat(File,"orZ",GangInfo[idorg][orZ]);
	INI_WriteFloat(File,"puX",GangInfo[idorg][puX]);
	INI_WriteFloat(File,"puY",GangInfo[idorg][puY]);
	INI_WriteFloat(File,"puZ",GangInfo[idorg][puZ]);
	INI_WriteFloat(File,"arX",GangInfo[idorg][arX]);
	INI_WriteFloat(File,"arY",GangInfo[idorg][arY]);
	INI_WriteFloat(File,"arZ",GangInfo[idorg][arZ]);
	INI_WriteFloat(File,"duX",GangInfo[idorg][duX]);
	INI_WriteFloat(File,"duY",GangInfo[idorg][duY]);
	INI_WriteFloat(File,"duZ",GangInfo[idorg][duZ]);
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek1%d",i);
		INI_WriteFloat(File,string,Vehicle[idorg][i][0]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek2%d",i);
		INI_WriteFloat(File,string,Vehicle[idorg][i][1]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek3%d",i);
		INI_WriteFloat(File,string,Vehicle[idorg][i][2]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek4%d",i);
		INI_WriteFloat(File,string,Vehicle[idorg][i][3]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek5%d",i);
		INI_WriteFloat(File,string,Vehicle[idorg][i][4]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek6%d",i);
		INI_WriteFloat(File,string,Vehicle[idorg][i][5]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek7%d",i);
		INI_WriteFloat(File,string,Vehicle[idorg][i][6]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek8%d",i);
		INI_WriteFloat(File,string,Vehicle[idorg][i][7]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek9%d",i);
		INI_WriteFloat(File,string,Vehicle[idorg][i][8]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek10%d",i);
		INI_WriteFloat(File,string,Vehicle[idorg][i][9]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek11%d",i);
		INI_WriteFloat(File,string,Vehicle[idorg][i][10]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek12%d",i);
		INI_WriteFloat(File,string,Vehicle[idorg][i][11]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek13%d",i);
		INI_WriteFloat(File,string,Vehicle[idorg][i][12]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek14%d",i);
		INI_WriteFloat(File,string,Vehicle[idorg][i][13]);
	}
	for(new i=0;i<4;i++)
	{
		new string[128];
		format(string,sizeof(string),"Vehiclek15%d",i);
		INI_WriteFloat(File,string,Vehicle[idorg][i][14]);
	}
	INI_WriteString(File,"Leader1",Leader[0][idorg]);
	INI_WriteString(File,"Leader2",Leader[1][idorg]);
	INI_WriteString(File,"Member1",Member[0][idorg]);
	INI_WriteString(File,"Member2",Member[1][idorg]);
	INI_WriteString(File,"Member3",Member[2][idorg]);
	INI_WriteString(File,"Member4",Member[3][idorg]);
	INI_WriteString(File,"Member5",Member[4][idorg]);
	INI_WriteString(File,"Member6",Member[5][idorg]);
	INI_WriteString(File,"Member7",Member[6][idorg]);
	INI_WriteString(File,"Member8",Member[7][idorg]);
	INI_WriteString(File,"Member9",Member[8][idorg]);
	INI_WriteString(File,"Member10",Member[9][idorg]);
	INI_WriteString(File,"Member11",Member[10][idorg]);
	INI_WriteString(File,"Member12",Member[11][idorg]);
	INI_WriteString(File,"Name",GangInfo[idorg][Name]);
	INI_WriteString(File,"Rank1",GangInfo[idorg][Rank1]);
	INI_WriteString(File,"Rank2",GangInfo[idorg][Rank2]);
	INI_WriteString(File,"Rank3",GangInfo[idorg][Rank3]);
	INI_WriteString(File,"Rank4",GangInfo[idorg][Rank4]);
	INI_WriteString(File,"Rank5",GangInfo[idorg][Rank5]);
	INI_WriteString(File,"Rank6",GangInfo[idorg][Rank6]);
	INI_WriteInt(File,"Int",GangInfo[idorg][Int]);
	INI_WriteInt(File,"VW",GangInfo[idorg][VW]);
	INI_WriteInt(File,"rSkin1",GangInfo[idorg][rSkin1]);
	INI_WriteInt(File,"rSkin2",GangInfo[idorg][rSkin2]);
	INI_WriteInt(File,"rSkin3",GangInfo[idorg][rSkin3]);
	INI_WriteInt(File,"rSkin4",GangInfo[idorg][rSkin4]);
	INI_WriteInt(File,"rSkin5",GangInfo[idorg][rSkin5]);
	INI_WriteInt(File,"rSkin6",GangInfo[idorg][rSkin6]);
	INI_WriteInt(File,"AllowedF",GangInfo[idorg][AllowedF]);
	INI_WriteInt(File,"AllowedR",GangInfo[idorg][AllowedR]);
	INI_WriteInt(File,"AllowedD",GangInfo[idorg][AllowedD]);
	INI_WriteInt(File,"AllowedH",GangInfo[idorg][AllowedH]);
	INI_WriteInt(File,"AllowedPD",GangInfo[idorg][AllowedPD]);
	INI_WriteInt(File,"AllowedFD",GangInfo[idorg][AllowedFD]);
	INI_Close(File);
	return 1;
}

stock ShowVehicleDialog(playerid)
{
ShowPlayerDialog(playerid, Dialog_Vehicle, 2, "{ffffff}Vehicle categories:", "Airplanes\nHelicopters\nBikes\nConvertibles\nIndustrial\nLowriders\nOff Road\nPublic Service Vehicles\nSaloons\nSport Vehicles\nStation Wagons\nBoats\nTrailers\nUnique Vehicles\nRC Vehicles", "Select", "Back" );
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
	{
	    case DIALOG_A1:
	    {
	        switch(response)
	        {
	            case 0: { /**/ }
	            case 1: { ShowPlayerDialog(playerid,DIALOG_AM,DIALOG_STYLE_LIST,"{00BD2C}C_ACTOR MENU","Actor Model ID \nCustom Spawn Coordinate \nSpawn-On-Me \nVirtual World \nActor Information \nSpawn","Select","Cancel"); }
	        }
	    }
	    case DIALOG_AM:
	    {
			switch(response)
			{
			    case 0: { SendClientMessage(playerid,COLOR_GREY,"Selection cancelled."); }
			    case 1:
				{
				    switch(listitem)
				    {
				        case 0: { ShowPlayerDialog(playerid,DIALOG_A3,DIALOG_STYLE_INPUT,"{00BD2C}C_ACTOR MENU","Type in a Model ID to use for this actor \nhttps://wiki.sa-mp.com/wiki/Skins:All","Submit","Back"); }
				        case 1: { ShowPlayerDialog(playerid,DIALOG_A4,DIALOG_STYLE_INPUT,"{00BD2C}C_ACTOR MENU","Specify the X COORD of the actor spawn below.","Submit","Back"); }
				        case 2:
						{
						    new Float:actX,Float:actY,Float:actZ,Float:actA;
							GetPlayerPos(playerid,X,Y,Z);
							act_X = actX;
							act_Y = actY;
							act_Z = actZ;
							act_A = actA;
							ShowPlayerDialog(playerid,DIALOG_AM,DIALOG_STYLE_LIST,"{00BD2C}C_ACTOR MENU","Actor Model ID \nCustom Spawn Coordinate \nSpawn-On-Me \nVirtual World \nActor Information \nSpawn","Select","Cancel");
							SendClientMessage(playerid,COLOR_GREEN,"[C_ACTOR] {FFFFFF}Actor spawn position successfully set.");
						}
						case 3: { ShowPlayerDialog(playerid,DIALOG_A9,DIALOG_STYLE_INPUT,"{00BD2C}C_ACTOR MENU","Type in the Virtual World ID for this actor below.","Submit","Back"); }
						case 4:
						{
						    new string[400];
							format(string,sizeof(string),"{00BD2C}ALL ACTOR INFORMATION \n{FFFFFF}Model ID:%d \nSpawn Coordinates: %f,%f,%f \nVirtual World:%d",actormodelid,act_X,act_Y,act_Z,actorworld);
						    ShowPlayerDialog(playerid,DIALOG_A8,DIALOG_STYLE_MSGBOX,"{00BD2C}C_ACTOR MENU",string,"Back","");
						}
						case 5:
						{
						    actor++; CreateActor(actormodelid,act_X,act_Y,act_Z+2,act_A);
						    SetActorVirtualWorld(actor,actorworld);
	        				SendClientMessage(playerid,COLOR_GREEN,"[C_ACTOR] {FFFFFF}Actor created.");
						}
				    }
				}
			}
	    }
	    case DIALOG_A3:
	    {
	        switch(response)
	        {
	            case 0: { ShowPlayerDialog(playerid,DIALOG_AM,DIALOG_STYLE_LIST,"{00BD2C}C_ACTOR MENU","Actor Model ID \nCustom Spawn Coordinate \nSpawn-On-Me \nVirtual World \nActor Information \nSpawn","Select","Cancel"); }
				case 1:
				{
				    new id = strval(inputtext);
				    actormodelid = id;
				    ShowPlayerDialog(playerid,DIALOG_AM,DIALOG_STYLE_LIST,"{00BD2C}C_ACTOR MENU","Actor Model ID \nCustom Spawn Coordinate \nSpawn-On-Me \nVirtual World \nActor Information \nSpawn","Select","Cancel");
					SendClientMessage(playerid,COLOR_GREEN,"[C_ACTOR] {FFFFFF}Actor Model ID set.");
				}
			}
	    }
	    case DIALOG_A4:
	    {
	        switch(response)
			{
			    case 0: { ShowPlayerDialog(playerid,DIALOG_AM,DIALOG_STYLE_LIST,"{00BD2C}C_ACTOR MENU","Actor Model ID \nCustom Spawn Coordinate \nSpawn-On-Me \nVirtual World \nActor Information \nSpawn","Select","Cancel"); }
				case 1:
				{
				    new x = strval(inputtext);
				    act_X = x;
				    ShowPlayerDialog(playerid,DIALOG_A5,DIALOG_STYLE_INPUT,"{00BD2C}C_ACTOR MENU","Specify the Y COORD of the actor spawn below.","Submit","Back");
				}
			}
	    }
	    case DIALOG_A5:
	    {
	        switch(response)
			{
			    case 0: { ShowPlayerDialog(playerid,DIALOG_A4,DIALOG_STYLE_INPUT,"{00BD2C}C_ACTOR MENU","Specify the X COORD of the actor spawn below.","Submit","Back"); }
				case 1:
				{
				    new y = strval(inputtext);
				    act_Y = y;
				    ShowPlayerDialog(playerid,DIALOG_A6,DIALOG_STYLE_INPUT,"{00BD2C}C_ACTOR MENU","Specify the Z COORD of the actor spawn below.","Submit","Back");
				}
			}
	    }
	    case DIALOG_A6:
	    {
	        switch(response)
			{
			    case 0: { ShowPlayerDialog(playerid,DIALOG_A5,DIALOG_STYLE_INPUT,"{00BD2C}C_ACTOR MENU","Specify the Y COORD of the actor spawn below.","Submit","Back"); }
				case 1:
				{
				    new z = strval(inputtext);
				    act_Z = z;
				    SendClientMessage(playerid,COLOR_GREEN,"[C_ACTOR] {FFFFFF}Actor Coordinate specified.");
				    ShowPlayerDialog(playerid,DIALOG_AM,DIALOG_STYLE_LIST,"{00BD2C}C_ACTOR MENU","Actor Model ID \nCustom Spawn Coordinate \nSpawn-On-Me \nVirtual World \nActor Information \nSpawn","Select","Cancel");
				}
			}
	    }
		case DIALOG_A9:
	    {
	        switch(response)
	        {
	            case 0: { ShowPlayerDialog(playerid,DIALOG_AM,DIALOG_STYLE_LIST,"{00BD2C}C_ACTOR MENU","Actor Model ID \nCustom Spawn Coordinate \nSpawn-On-Me \nVirtual World \nActor Information \nSpawn","Select","Cancel"); }
	            case 1:
				{
				    new world = strval(inputtext);
				    actorworld = world;
				    SendClientMessage(playerid,COLOR_GREEN,"[C_ACTOR] {FFFFFF}Actor Virtual World ID set.");
				    ShowPlayerDialog(playerid,DIALOG_AM,DIALOG_STYLE_LIST,"{00BD2C}C_ACTOR MENU","Actor Model ID \nCustom Spawn Coordinate \nSpawn-On-Me \nVirtual World \nActor Information \nSpawn","Select","Cancel");
				}
	        }
		}
		case DIALOG_A8:
		{
		    ShowPlayerDialog(playerid,DIALOG_AM,DIALOG_STYLE_LIST,"{00BD2C}C_ACTOR MENU","Actor Model ID \nCustom Spawn Coordinate \nSpawn-On-Me \nVirtual World \nActor Information \nSpawn","Select","Cancel");
		}
	}
	if(dialogid == aselect) //Gangs List
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0: //Gang 1
	            {
	                SendClientMessage(playerid,0x42CC33C8, "Under Constuction.");
					return 1;
	            }
	            case 1: //Gang 2.
	            {
	            	SendClientMessage(playerid,0x42CC33C8, "Under Constuction.");
					return 1;
	            }
	            case 2: //Gang 3.
	            {
	                SendClientMessage(playerid,0x42CC33C8, "Under Constuction.");
					return 1;
	            }
	            case 3: //Gang 4.
	            {
	                SendClientMessage(playerid,0x42CC33C8, "Under Constuction.");
					return 1;
	            }
	            case 4: //Gang 5.
	            {
	                SendClientMessage(playerid,0x42CC33C8, "Under Constuction.");
					return 1;
	            }
	        }
	    }
	    else
	    {
	        return 1;
	    }
	}
	if (dialogid == DIALOG_COLOR)
	{
	    if (response)
	    {
	        new str[128];
	        switch (listitem)
	        {
	      		case 0:
	      		{
			  		SetPlayerColor(playerid, COLOR_PURPLE);
			  		PlayerInfo[playerid][Color] = COLOR_PURPLE;
				}
				case 1:
				{
					SetPlayerColor(playerid, COLOR_PINK);
					PlayerInfo[playerid][Color] = COLOR_PINK;
				}
				case 2:
				{
					SetPlayerColor(playerid, COLOR_LIGHTBLUE);
					PlayerInfo[playerid][Color] = COLOR_LIGHTBLUE;
				}
				case 3:
				{
					SetPlayerColor(playerid, COLOR_LIGHTGREEN);
					PlayerInfo[playerid][Color] = COLOR_LIGHTGREEN;
				}
				case 4:
				{
					SetPlayerColor(playerid, COLOR_GREY);
					PlayerInfo[playerid][Color] = COLOR_GREY;
				}
				case 5:
				{
					SetPlayerColor(playerid, COLOR_WHITE);
					PlayerInfo[playerid][Color] = COLOR_WHITE;
				}
				case 6:
				{
					SetPlayerColor(playerid, COLOR_ORANGE);
					PlayerInfo[playerid][Color] = COLOR_ORANGE;
				}
				case 7:
				{
					SetPlayerColor(playerid, COLOR_YELLOW);
					PlayerInfo[playerid][Color] = COLOR_YELLOW;
				}
				case 8:
				{
					SetPlayerColor(playerid, COLOR_RED);
                    PlayerInfo[playerid][Color] = COLOR_RED;
				}
				case 9:
				{
					SetPlayerColor(playerid, COLOR_GREEN);
					PlayerInfo[playerid][Color] = COLOR_GREEN;
				}
			}
			format(str, sizeof(str), "{%06x}You have successfully changed your nick color!", (GetPlayerColor(playerid) >>> 8));
	        SendClientMessage(playerid, -1, str);
		}
	}
    if(dialogid == DIALOG_SKIN2)
	{
	    new skin;
		if(!response) return 1;
		if(sscanf(inputtext,"d",skin)) return ShowPlayerDialog(playerid, DIALOG_SKIN2, 1, ""WHITE"Change the skin", ""WHITE"Enter the ID of the skin", "OK", "Cancel");
		if(skin < 0 || skin > 299) return ShowPlayerDialog(playerid, DIALOG_SKIN2, 1, ""WHITE"Wrong ID of the skin", ""WHITE"Enter the ID of the skin", "OK", "Cancel");
  		if(rank[playerid] == 1)
	    {
	    	GangInfo[orga[playerid]][rSkin1]=skin;
	    	for(new i=0;i<MAX_PLAYERS;i++)
	    	{
	    	    if(PlayerInfo[i][aMember] == orga[playerid] && PlayerInfo[i][Rank] == 1)
	    	    {
	    	        PlayerInfo[i][pSkin]=skin;
	    	        SetPlayerSkin(i,skin);
	    	        SavePlayer(i);
	    	    }
	    	}
	    }
	    else if(rank[playerid] == 2)
	    {
	    	GangInfo[orga[playerid]][rSkin2]=skin;
	    	for(new i=0;i<MAX_PLAYERS;i++)
	    	{
	    	    if(PlayerInfo[i][aMember] == orga[playerid] && PlayerInfo[i][Rank] == 2)
	    	    {
	    	        PlayerInfo[i][pSkin]=skin;
	    	        SetPlayerSkin(i,skin);
	    	        SavePlayer(i);
	    	    }
	    	}
	    }
	    else if(rank[playerid] == 3)
	    {
	    	GangInfo[orga[playerid]][rSkin3]=skin;
	    	for(new i=0;i<MAX_PLAYERS;i++)
	    	{
	    	    if(PlayerInfo[i][aMember] == orga[playerid] && PlayerInfo[i][Rank] == 3)
	    	    {
	    	        PlayerInfo[i][pSkin]=skin;
	    	        SetPlayerSkin(i,skin);
	    	        SavePlayer(i);
	    	    }
	    	}
	    }
	    else if(rank[playerid] == 4)
	    {
	    	GangInfo[orga[playerid]][rSkin4]=skin;
	    	for(new i=0;i<MAX_PLAYERS;i++)
	    	{
	    	    if(PlayerInfo[i][aMember] == orga[playerid] && PlayerInfo[i][Rank] == 4)
	    	    {
	    	        PlayerInfo[i][pSkin]=skin;
	    	        SetPlayerSkin(i,skin);
	    	        SavePlayer(i);
	    	    }
	    	}
	    }
	    else if(rank[playerid] == 5)
	    {
	    	GangInfo[orga[playerid]][rSkin5]=skin;
	    	for(new i=0;i<MAX_PLAYERS;i++)
	    	{
	    	    if(PlayerInfo[i][aMember] == orga[playerid] && PlayerInfo[i][Rank] == 5)
	    	    {
	    	        PlayerInfo[i][pSkin]=skin;
	    	        SetPlayerSkin(i,skin);
	    	        SavePlayer(i);
	    	    }
	    	}
	    }
	    else if(rank[playerid] == 6)
	    {
	    	GangInfo[orga[playerid]][rSkin6]=skin;
	    	for(new i=0;i<MAX_PLAYERS;i++)
	    	{
	    	    if(PlayerInfo[i][aMember] == orga[playerid] && PlayerInfo[i][Rank] == 6)
	    	    {
	    	        PlayerInfo[i][pSkin]=skin;
	    	        SetPlayerSkin(i,skin);
	    	        SavePlayer(i);
	    	    }
	    	}
	    }
	    SendClientMessage(playerid,-1,"{00C0FF}ID of the skin successfully saved!");
	    ShowPlayerDialog(playerid, DIALOG_SKIN, DIALOG_STYLE_LIST, "Skins", "Rank 1\nRank 2\nRank 3\nRank 4\nRank 5\nRank 6", "OK", "Cancel");
	    SaveGangs(orga[playerid]);
	}
    if(dialogid == DIALOG_RANK2)
	{
	    new ime[128];
		if(!response) return 1;
		if(sscanf(inputtext,"s",ime)) return ShowPlayerDialog(playerid, DIALOG_RANK2, 1, ""WHITE"Change name of the rank", ""WHITE"Enter the new name of the rank", "OK", "Cancel");
  		if(rank[playerid] == 1)
	    {
	    	strmid(GangInfo[orga[playerid]][Rank1],ime,0,strlen(ime),255);
	    }
	    else if(rank[playerid] == 2)
	    {
	    	strmid(GangInfo[orga[playerid]][Rank2],ime,0,strlen(ime),255);
	    }
	    else if(rank[playerid] == 3)
	    {
	    	strmid(GangInfo[orga[playerid]][Rank3],ime,0,strlen(ime),255);
	    }
	    else if(rank[playerid] == 4)
	    {
	    	strmid(GangInfo[orga[playerid]][Rank4],ime,0,strlen(ime),255);
	    }
	    else if(rank[playerid] == 5)
	    {
	    	strmid(GangInfo[orga[playerid]][Rank5],ime,0,strlen(ime),255);
	    }
	    else if(rank[playerid] == 6)
	    {
	    	strmid(GangInfo[orga[playerid]][Rank6],ime,0,strlen(ime),255);
	    }
	    SendClientMessage(playerid,-1,"{00C0FF}Name of rank successfully saved!");
	    ShowPlayerDialog(playerid, DIALOG_RANK, DIALOG_STYLE_LIST, "Ranks", "Rank 1\nRank 2\nRank 3\nRank 4\nRank 5\nRank 6", "OK", "Cancel");
	    SaveGangs(orga[playerid]);
	}
	if(dialogid == DIALOG_SKIN)
	{
		if(!response) return 1;
	    switch(listitem)
	    {
	        case 0:
	        {
	            ShowPlayerDialog(playerid, DIALOG_SKIN2, 1, ""WHITE"Change the skin", ""WHITE"Enter the ID of the skin", "OK", "Cancel");
	            rank[playerid] = 1;
			}
			case 1:
			{
	            ShowPlayerDialog(playerid, DIALOG_SKIN2, 1, ""WHITE"Change the skin", ""WHITE"Enter the ID of the skin", "OK", "Cancel");
	            rank[playerid] = 2;
			}
			case 2:
			{
	            ShowPlayerDialog(playerid, DIALOG_SKIN2, 1, ""WHITE"Change the skin", ""WHITE"Enter the ID of the skin", "OK", "Cancel");
	            rank[playerid] = 3;
			}
			case 3:
			{
				ShowPlayerDialog(playerid, DIALOG_SKIN2, 1, ""WHITE"Change the skin", ""WHITE"Enter the ID of the skin", "OK", "Cancel");
				rank[playerid] = 4;
			}
			case 4:
			{
				ShowPlayerDialog(playerid, DIALOG_SKIN2, 1, ""WHITE"Change the skin", ""WHITE"Enter the ID of the skin", "OK", "Cancel");
				rank[playerid] = 5;
			}
			case 5:
			{
				ShowPlayerDialog(playerid, DIALOG_SKIN2, 1, ""WHITE"Change the skin", ""WHITE"Enter the ID of the skin", "OK", "Cancel");
				rank[playerid] = 6;
			}
		}
	}
	if(dialogid == DIALOG_RANK)
	{
		if(!response) return 1;
	    switch(listitem)
	    {
	        case 0:
	        {
	            ShowPlayerDialog(playerid, DIALOG_RANK2, 1, ""WHITE"Change name of the rank", ""WHITE"Enter the new name of the rank 1", "OK", "Cancel");
	            rank[playerid] = 1;
			}
			case 1:
			{
	            ShowPlayerDialog(playerid, DIALOG_RANK2, 1, ""WHITE"Change name of the rank", ""WHITE"Enter the new name of the rank 2", "OK", "Cancel");
	            rank[playerid] = 2;
			}
			case 2:
			{
	            ShowPlayerDialog(playerid, DIALOG_RANK2, 1, ""WHITE"Change name of the rank", ""WHITE"Enter the new name of the rank 3", "OK", "Cancel");
	            rank[playerid] = 3;
			}
			case 3:
			{
				ShowPlayerDialog(playerid, DIALOG_RANK2, 1, ""WHITE"Change name of the rank", ""WHITE"Enter the new name of the rank 4", "OK", "Cancel");
				rank[playerid] = 4;
			}
			case 4:
			{
				ShowPlayerDialog(playerid, DIALOG_RANK2, 1, ""WHITE"Change name of the rank", ""WHITE"Enter the new name of the rank 5", "OK", "Cancel");
				rank[playerid] = 5;
			}
			case 5:
			{
				ShowPlayerDialog(playerid, DIALOG_RANK2, 1, ""WHITE"Change name of the rank", ""WHITE"Enter the new name of the rank 6", "OK", "Cancel");
				rank[playerid] = 6;
			}
		}
	}
	if(dialogid == DIALOG_COORDINATES)
	{
		if(!response) return 1;
		if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,SRED,"You can't be in vehicle!");
	    switch(listitem)
	    {
	        case 0:
	        {
	            new Float:gx,Float:gy,Float:gz;
			    GetPlayerPos(playerid,gx,gy,gz);
			    GangInfo[orga[playerid]][sX]=gx;
			    GangInfo[orga[playerid]][sY]=gy;
			    GangInfo[orga[playerid]][sZ]=gz;
			    SendClientMessage(playerid,-1,"{00C0FF}Coordinates of spawn saved!");
			    SaveGangs(orga[playerid]);
			    ShowPlayerDialog(playerid, DIALOG_COORDINATES, DIALOG_STYLE_LIST, "Coordinates", "Spawn for players\nEntering the interior\nExiting the interior\nCollecting weapons for Hitman\nCollecting weapoms for PD\nPlace for arrest\nPlace for spawn arrested player\nLocation of fire extinguisher", "OK", "Cancel");
			    SendClientMessage(playerid,-1,"{00C0FF}Coordinates are saved as soon as you click on one of the offered!");
			}
			case 1:
			{
	            new Float:gx,Float:gy,Float:gz;
			    new string[128];
			    GetPlayerPos(playerid,gx,gy,gz);
			    GangInfo[orga[playerid]][uX]=gx;
			    GangInfo[orga[playerid]][uY]=gy;
			    GangInfo[orga[playerid]][uZ]=gz;
			    DestroyDynamicPickup(GangPickup[orga[playerid]]);
			    GangPickup[orga[playerid]] = CreateDynamicPickup(1272, 1, gx, gy, gz);
			    DestroyDynamic3DTextLabel(GangLabel[orga[playerid]]);
			    format(string,sizeof(string),"[ %s ]",GangInfo[orga[playerid]][Name]);
			    GangLabel[orga[playerid]] = CreateDynamic3DTextLabel(string,0x660066BB,GangInfo[orga[playerid]][uX],GangInfo[orga[playerid]][uY],GangInfo[orga[playerid]][uZ], 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
			    SendClientMessage(playerid,-1,"{00C0FF}Coordinates the entrance to the interior saved!");
			    SaveGangs(orga[playerid]);
			    ShowPlayerDialog(playerid, DIALOG_COORDINATES, DIALOG_STYLE_LIST, "Coordinates", "Spawn for players\nEntering the interior\nExiting the interior\nCollecting weapons for Hitman\nCollecting weapoms for PD\nPlace for arrest\nPlace for spawn arrested player\nLocation of fire extinguisher", "OK", "Cancel");
			    SendClientMessage(playerid,-1,"{00C0FF}Coordinates are saved as soon as you click on one of the offered!");
			}
			case 2:
			{
	            new Float:gx,Float:gy,Float:gz;
			    GetPlayerPos(playerid,gx,gy,gz);
			    GangInfo[orga[playerid]][iX]=gx;
			    GangInfo[orga[playerid]][iY]=gy;
			    GangInfo[orga[playerid]][iZ]=gz;
			    GangInfo[orga[playerid]][Int]=GetPlayerInterior(playerid);
			    GangInfo[orga[playerid]][VW]=GetPlayerVirtualWorld(playerid);
			    DestroyDynamicPickup(GangPickup2[orga[playerid]]);
			    GangPickup2[orga[playerid]] = CreateDynamicPickup(1272, 1, gx, gy, gz);
			    SendClientMessage(playerid,-1,"{00C0FF}Coordinates exit from the interior saved!");
			    SaveGangs(orga[playerid]);
			    ShowPlayerDialog(playerid, DIALOG_COORDINATES, DIALOG_STYLE_LIST, "Coordinates", "Spawn for players\nEntering the interior\nExiting the interior\nCollecting weapons for Hitman\nCollecting weapoms for PD\nPlace for arrest\nPlace for spawn arrested player\nLocation of fire extinguisher", "OK", "Cancel");
			    SendClientMessage(playerid,-1,"{00C0FF}Coordinates are saved as soon as you click on one of the offered!");
			}
			case 3:
			{
	            new Float:gx,Float:gy,Float:gz;
			    GetPlayerPos(playerid,gx,gy,gz);
			    GangInfo[orga[playerid]][LokX]=gx;
			    GangInfo[orga[playerid]][LokY]=gy;
			    GangInfo[orga[playerid]][LokZ]=gz;
			    SendClientMessage(playerid,-1,"{00C0FF}Coordinates the collection of weapons of Hitman saved!");
			    SaveGangs(orga[playerid]);
			    ShowPlayerDialog(playerid, DIALOG_COORDINATES, DIALOG_STYLE_LIST, "Coordinates", "Spawn for players\nEntering the interior\nExiting the interior\nCollecting weapons for Hitman\nCollecting weapoms for PD\nPlace for arrest\nPlace for spawn arrested player\nLocation of fire extinguisher", "OK", "Cancel");
				SendClientMessage(playerid,-1,"{00C0FF}Coordinates are saved as soon as you click on one of the offered!");
			}
			case 4:
			{
	            new Float:gx,Float:gy,Float:gz;
			    GetPlayerPos(playerid,gx,gy,gz);
			    GangInfo[orga[playerid]][orX]=gx;
			    GangInfo[orga[playerid]][orY]=gy;
			    GangInfo[orga[playerid]][orZ]=gz;
			    DestroyPickup(PDWeapons[orga[playerid]]);
			    PDWeapons[orga[playerid]] = CreatePickup(355, 1, GangInfo[orga[playerid]][orX],GangInfo[orga[playerid]][orY],GangInfo[orga[playerid]][orZ], 0);
			    SendClientMessage(playerid,-1,"{00C0FF}Coordinates the collection of weapons of PD saved!");
			    SaveGangs(orga[playerid]);
			    ShowPlayerDialog(playerid, DIALOG_COORDINATES, DIALOG_STYLE_LIST, "Coordinates", "Spawn for players\nEntering the interior\nExiting the interior\nCollecting weapons for Hitman\nCollecting weapoms for PD\nPlace for arrest\nPlace for spawn arrested player\nLocation of fire extinguisher", "OK", "Cancel");
				SendClientMessage(playerid,-1,"{00C0FF}Coordinates are saved as soon as you click on one of the offered!!");
			}
			case 5:
			{
	            new Float:gx,Float:gy,Float:gz;
			    GetPlayerPos(playerid,gx,gy,gz);
			    GangInfo[orga[playerid]][puX]=gx;
			    GangInfo[orga[playerid]][puY]=gy;
			    GangInfo[orga[playerid]][puZ]=gz;
			    DestroyDynamicPickup(Arrest[orga[playerid]]);
			    DestroyDynamic3DTextLabel(ArrestLabel[orga[playerid]]);
			    Arrest[orga[playerid]] = CreateDynamicPickup(1314, 1, GangInfo[orga[playerid]][puX],GangInfo[orga[playerid]][puY],GangInfo[orga[playerid]][puZ], 0);
			    ArrestLabel[orga[playerid]] = CreateDynamic3DTextLabel("{FF9900}Place for arrest {FF3300}[{FFFFFF}/arrest{FF3300}]",-1,GangInfo[orga[playerid]][puX],GangInfo[orga[playerid]][puY],GangInfo[orga[playerid]][puZ], 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
			    SendClientMessage(playerid,-1,"{00C0FF}Place for arrest saved!");
			    SaveGangs(orga[playerid]);
			    ShowPlayerDialog(playerid, DIALOG_COORDINATES, DIALOG_STYLE_LIST, "Coordinates", "Spawn for players\nEntering the interior\nExiting the interior\nCollecting weapons for Hitman\nCollecting weapoms for PD\nPlace for arrest\nPlace for spawn arrested player\nLocation of fire extinguisher", "OK", "Cancel");
				SendClientMessage(playerid,-1,"{00C0FF}Coordinates are saved as soon as you click on one of the offered!!");
			}
			case 6:
			{
	            new Float:gx,Float:gy,Float:gz;
			    GetPlayerPos(playerid,gx,gy,gz);
			    GangInfo[orga[playerid]][arX]=gx;
			    GangInfo[orga[playerid]][arY]=gy;
			    GangInfo[orga[playerid]][arZ]=gz;
			    SendClientMessage(playerid,-1,"{00C0FF}Place for spawn arrested player saved!");
			    SaveGangs(orga[playerid]);
			    ShowPlayerDialog(playerid, DIALOG_COORDINATES, DIALOG_STYLE_LIST, "Coordinates", "Spawn for players\nEntering the interior\nExiting the interior\nCollecting weapons for Hitman\nCollecting weapons for PD\nPlace for arrest\nPlace for spawn arrested player\nLocation of fire extinguisher", "OK", "Cancel");
				SendClientMessage(playerid,-1,"{00C0FF}Coordinates are saved as soon as you click on one of the offered!!");
			}
			case 7:
			{
	            new Float:gx,Float:gy,Float:gz;
			    GetPlayerPos(playerid,gx,gy,gz);
			    GangInfo[orga[playerid]][duX]=gx;
			    GangInfo[orga[playerid]][duY]=gy;
			    GangInfo[orga[playerid]][duZ]=gz;
			    SendClientMessage(playerid,-1,"{00C0FF}Place for pickup fire extinguisher saved!");
			    SaveGangs(orga[playerid]);
			    DestroyDynamicPickup(Aparat[orga[playerid]]);
			    DestroyDynamic3DTextLabel(AparatLabel[orga[playerid]]);
			    Aparat[orga[playerid]] = CreateDynamicPickup(1239, 1, GangInfo[orga[playerid]][duX],GangInfo[orga[playerid]][duY],GangInfo[orga[playerid]][duZ], 0);
	  			AparatLabel[orga[playerid]] = CreateDynamic3DTextLabel("{FF9900}Place for pickup fire extinguisher {FF3300}[{FFFFFF}/fireext{FF3300}]",-1,GangInfo[orga[playerid]][duX],GangInfo[orga[playerid]][duY],GangInfo[orga[playerid]][duZ], 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
			    ShowPlayerDialog(playerid, DIALOG_COORDINATES, DIALOG_STYLE_LIST, "Coordinates", "Spawn for players\nEntering the interior\nExiting the interior\nCollecting weapons for Hitman\nCollecting weapons for PD\nPlace for arrest\nPlace for spawn arrested player\nLocation of fire extinguisher", "OK", "Cancel");
				SendClientMessage(playerid,-1,"{00C0FF}Coordinates are saved as soon as you click on one of the offered!!");
			}
		}
	}
	if(dialogid == DIALOG_VATRA)
	{
		new org;
	    if(!response) return 1;
	    if(sscanf(inputtext,"i",org)) return ShowPlayerDialog(playerid, DIALOG_VATRA, 1, ""WHITE"Fire", ""WHITE"Enter ID of fire", "OK", "Cancel");
	    new oFile[50];
		format(oFile, sizeof(oFile), FIRE, org);
    	if(!fexist(oFile))return ShowPlayerDialog(playerid, DIALOG_VATRA, 1, ""WHITE"Fire doesnt exist", ""WHITE"Enter ID of fire", "OK", "Cancel");
		poz[playerid]=org;
		SendClientMessage(playerid,-1,"{00C0FF}Coordinates are saved as soon as you click on one of the offered!!");
		ShowPlayerDialog(playerid, DIALOG_FIRE, DIALOG_STYLE_LIST, "Editing", "Fire object 1\nFire object 2\nFire object 3\nFire object 4\nFire object 5", "OK", "Cancel");
	}
	if(dialogid == DIALOG_FIRE)
	{
		if(!response) return 1;
		if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,SRED,"You cant be in vehicle!");
	    switch(listitem)
	    {
	        case 0:
	        {
            new Float:gx,Float:gy,Float:gz;
		    GetPlayerPos(playerid,gx,gy,gz);
		    FireInfo[poz[playerid]][GX]=gx;
		    FireInfo[poz[playerid]][GY]=gy;
		    FireInfo[poz[playerid]][GZ]=gz;
		    SendClientMessage(playerid,-1,"{00C0FF}Coordinates of fire object 1 saved!");
		    SaveFire(poz[playerid]);
		    ShowPlayerDialog(playerid, DIALOG_FIRE, DIALOG_STYLE_LIST, "Editing", "Fire object 1\nFire object 2\nFire object 3\nFire object 4\nFire object 5", "OK", "Cancel");
		    SendClientMessage(playerid,-1,"{00C0FF}Coordinates are saved as soon as you click on one of the offered!!");
			}
			case 1:
			{
            new Float:gx,Float:gy,Float:gz;
		    GetPlayerPos(playerid,gx,gy,gz);
		    FireInfo[poz[playerid]][GX1]=gx;
		    FireInfo[poz[playerid]][GY1]=gy;
		    FireInfo[poz[playerid]][GZ1]=gz;
		    SendClientMessage(playerid,-1,"{00C0FF}Coordinates of fire object 2 saved!");
		    SaveFire(poz[playerid]);
		    ShowPlayerDialog(playerid, DIALOG_FIRE, DIALOG_STYLE_LIST, "Editing", "Fire object 1\nFire object 2\nFire object 3\nFire object 4\nFire object 5", "OK", "Cancel");
		    SendClientMessage(playerid,-1,"{00C0FF}Coordinates are saved as soon as you click on one of the offered!!");
			}
			case 2:
			{
            new Float:gx,Float:gy,Float:gz;
		    GetPlayerPos(playerid,gx,gy,gz);
		    FireInfo[poz[playerid]][GX2]=gx;
		    FireInfo[poz[playerid]][GY2]=gy;
		    FireInfo[poz[playerid]][GZ2]=gz;
		    SendClientMessage(playerid,-1,"{00C0FF}Coordinates of fire object 3 saved!");
		    SaveFire(poz[playerid]);
		    ShowPlayerDialog(playerid, DIALOG_FIRE, DIALOG_STYLE_LIST, "Editing", "Fire object 1\nFire object 2\nFire object 3\nFire object 4\nFire object 5", "OK", "Cancel");
			SendClientMessage(playerid,-1,"{00C0FF}Coordinates are saved as soon as you click on one of the offered!!");
			}
			case 3:
			{
            new Float:gx,Float:gy,Float:gz;
		    GetPlayerPos(playerid,gx,gy,gz);
		    FireInfo[poz[playerid]][GX3]=gx;
		    FireInfo[poz[playerid]][GY3]=gy;
		    FireInfo[poz[playerid]][GZ3]=gz;
		    SendClientMessage(playerid,-1,"{00C0FF}Coordinates of fire object 4 saved!");
		    SaveFire(poz[playerid]);
		    ShowPlayerDialog(playerid, DIALOG_FIRE, DIALOG_STYLE_LIST, "Editing", "Fire object 1\nFire object 2\nFire object 3\nFire object 4\nFire object 5", "OK", "Cancel");
			SendClientMessage(playerid,-1,"{00C0FF}Coordinates are saved as soon as you click on one of the offered!!");
			}
			case 4:
			{
            new Float:gx,Float:gy,Float:gz;
		    GetPlayerPos(playerid,gx,gy,gz);
		    FireInfo[poz[playerid]][GX4]=gx;
		    FireInfo[poz[playerid]][GY4]=gy;
		    FireInfo[poz[playerid]][GZ4]=gz;
            SendClientMessage(playerid,-1,"{00C0FF}Coordinates of fire object 5 saved!");
		    SaveFire(poz[playerid]);
		    ShowPlayerDialog(playerid, DIALOG_FIRE, DIALOG_STYLE_LIST, "Editing", "Fire object 1\nFire object 2\nFire object 3\nFire object 4\nFire object 5", "OK", "Cancel");
			SendClientMessage(playerid,-1,"{00C0FF}Coordinates are saved as soon as you click on one of the offered!!");
			}
		}
	}
    if(dialogid == DIALOG_NAME)
	{
	    new ime[128];
		if(!response) return 1;
	    if(sscanf(inputtext,"s",ime)) return ShowPlayerDialog(playerid, DIALOG_NAME, 1, ""WHITE"Changing name", ""WHITE"Enter the new name of the gang", "OK", "Cancel");
	    if(strlen(ime) < 1)return SendClientMessage(playerid,SRED,"The name must contain at least one letter!");
		SendClientMessage(playerid,-1,"{00C0FF}Name has changed!");
		new string[128];
    	strmid(GangInfo[orga[playerid]][Name],ime,0,strlen(ime),255);
    	SaveGangs(orga[playerid]);
    	DestroyDynamic3DTextLabel(GangLabel[orga[playerid]]);
    	format(string,sizeof(string),"[ %s ]",GangInfo[orga[playerid]][Name]);
    	GangLabel[orga[playerid]] = CreateDynamic3DTextLabel(string,0x660066BB,GangInfo[orga[playerid]][uX],GangInfo[orga[playerid]][uY],GangInfo[orga[playerid]][uZ], 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
	}
    if(dialogid == DIALOG_EDITING)
	{
		if(!response) return 1;
	    switch(listitem)
	    {
	        case 0:
	        {
            	ShowPlayerDialog(playerid, DIALOG_NAME, 1, ""WHITE"Changing name", ""WHITE"Enter the new name of the gang", "OK", "Cancel");
			}
			case 1:
			{
            	ShowPlayerDialog(playerid, DIALOG_RANK, DIALOG_STYLE_LIST, "Ranks", "Rank 1\nRank 2\nRank 3\nRank 4\nRank 5\nRank 6", "OK", "Cancel");
			}
			case 2:
			{
            	ShowPlayerDialog(playerid, DIALOG_SKIN, DIALOG_STYLE_LIST, "Skins", "Rank 1\nRank 2\nRank 3\nRank 4\nRank 5\nRank 6", "OK", "Cancel");
			}
			case 3:
			{
				SendClientMessage(playerid,-1,"{00C0FF}Coordinates are saved as soon as you click on one of the offered!");
	            ShowPlayerDialog(playerid, DIALOG_COORDINATES, DIALOG_STYLE_LIST, "Coordinates", "Spawn for players\nEntering the interior\nExiting the interior\nCollecting weapons for Hitman\nCollecting weapons for PD\nPlace for arrest\nPlace for spawn arrested player\nLocation of fire extinguisher", "OK", "Cancel");
			}
			case 4:
			{
            	ShowPlayerDialog(playerid, DIALOG_LICENSE, DIALOG_STYLE_LIST, "Allow/Disallow", "Allow /f chat\nAllow /r chat\nAllow /d chat\nAllow Hitman commands\nAllow PD commands\nAllow FD commands", "OK", "Cancel");
			}
		}
	}
    if(dialogid == DIALOG_GANG)
	{
		new org;
	    if(!response) return 1;
	    if(sscanf(inputtext,"i",org)) return ShowPlayerDialog(playerid, DIALOG_GANG, 1, ""WHITE"Editing", ""WHITE"Enter the ID of the gang you want to edit", "Next", "Cancel");
	    new oFile[50];
		format(oFile, sizeof(oFile), GANGS, org);
    	if(!fexist(oFile))return ShowPlayerDialog(playerid, DIALOG_GANG, 1, ""WHITE"Gang does not exist", ""WHITE"Enter the ID of the gang you want to edit", "Next", "Cancel");
		orga[playerid]=org;
		ShowPlayerDialog(playerid, DIALOG_EDITING, DIALOG_STYLE_LIST, "Editing", "Change the name of the gang\nChange the name of the ranks\nChange skins\nEdit coordinates\nAllow commands", "OK", "Cancel");
	}
	if(dialogid == DIALOG_LAPTOP)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
	                new info[2048];
	                strcat(info, ""YELLOW"Targets\n\n", sizeof(info));
				    if(PlayerInfo[playerid][Rank] > 3)
				 	{
				  		for(new i = 0; i != MAX_PLAYERS; i++)
						{
				  			if(PlayerInfo[i][Target] != 0)
					    	{
				      			if(PlayerInfo[i][HaveTarget] == 0)
					        	{
						        	new String[250];
							        format(String,sizeof(String),"{FF0000}|Target| {FF9900}Player: {FFFFFF}%s {FF0000}| {FF9900}Price: {FFFFFF}%d$ {FF0000}| {FF9900}ID Target: {FFFFFF}%d {FF0000}|\n",GetName(i),PlayerInfo[i][TargetPrice],i);
							        strcat(info, String, sizeof(info));
								}
							}
						}
				   	}
					ShowPlayerDialog(playerid, DIALOG_TARGETS, DIALOG_STYLE_MSGBOX, ""WHITE"Targets", info, "OK", "");
	            }
	            case 1:
	            {
		            new String[250];
		            if(PlayerInfo[playerid][TargetPrice] != 0)
		            {
			            format(String,sizeof(String),"{FF0000}|Your target| {FF9900}Player: {FFFFFF}%s {FF0000}| {FF9900}Price: {FFFFFF}%d$ {FF0000}|",PlayerInfo[playerid][NameVictim],PlayerInfo[playerid][TargetPrice]);
		    			SendClientMessage(playerid,-1,String);
	    			}
	    			else return SendClientMessage(playerid,-1,"You dont have target!");
	            }
	            case 2:
	            {
             		ShowPlayerDialog(playerid,DIALOG_LOCATIONISP,DIALOG_STYLE_LIST,"Location of packet","Base\n Wilowfield\n LS Aero\n Near MD\n Santa Maria Beach\n Near Skate Park\n Near MD","OK","Cancel");
	            }
      		}
		}
		return 1;
	}
	if(dialogid == DIALOG_LOCATIONISP)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
	            SetPlayerCheckpoint(playerid,GangInfo[orga[playerid]][LokX],GangInfo[orga[playerid]][LokY],GangInfo[orga[playerid]][LokZ],2.0);
				CP[playerid] = 1;
	            }
	            case 1:
	            {
	            SetPlayerCheckpoint(playerid,2741.5186,-1945.7740,13.2050,2.0);
				CP[playerid] = 2;
	            }
	            case 2:
	            {
	            SetPlayerCheckpoint(playerid,1733.5438,-2689.5618,13.5766,2.0);
				CP[playerid] = 3;
	            }
             	case 3:
	            {
				SetPlayerCheckpoint(playerid,1360.8369,-1523.3380,13.2865,2.0);
				CP[playerid] = 4;
	            }
             	case 4:
	            {
	            SetPlayerCheckpoint(playerid,1000.7914,-2150.4417,12.8338,2.0);
				CP[playerid] = 5;
	            }
	            case 5:
	            {
	            SetPlayerCheckpoint(playerid,2017.3931,-1306.2031,20.6147,2.0);
				CP[playerid] = 6;
	            }
	            case 6:
	            {
				SetPlayerCheckpoint(playerid,879.3303,-1363.1744,13.3739,2.0);
				CP[playerid] = 7;
	            }
      		}
		}
		return 1;
	}
	if(dialogid == DIALOG_WEAPON)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
	            GivePlayerWeapon(playerid,1,999999999);
	            }
	            case 1:
	            {
	            GivePlayerWeapon(playerid,4,999999999);
	            }
	            case 2:
	            {
	            GivePlayerWeapon(playerid,24,999999999);
	            }
             	case 3:
	            {
	            GivePlayerWeapon(playerid,29,999999999);
	            }
             	case 4:
	            {
	            GivePlayerWeapon(playerid,31,999999999);
	            }
             	case 5:
	            {
	            GivePlayerWeapon(playerid,34,999999999);
	            }
	            case 6:
	            {
	            GivePlayerWeapon(playerid,25,999999999);
	            }
      		}
		}
		return 1;
	}
	if(dialogid == DIALOG_LICENSE)
	{
	    if(!response) return 1;
        switch(listitem)
	    {
	        case 0:
	        {
		        if(GangInfo[orga[playerid]][AllowedF]==0)
		        {
		        GangInfo[orga[playerid]][AllowedF]=1;
				SendClientMessage(playerid,-1,"{00C0FF}You allowed this gang /f chat!");
				SaveGangs(orga[playerid]);
		        }
		        else
		        {
		        GangInfo[orga[playerid]][AllowedF]=0;
				SendClientMessage(playerid,-1,"{00C0FF}You disallowed this gang /f chat!");
				SaveGangs(orga[playerid]);
		        }
			}
			case 1:
			{
			    if(GangInfo[orga[playerid]][AllowedR]==0)
		        {
		        GangInfo[orga[playerid]][AllowedR]=1;
				SendClientMessage(playerid,-1,"{00C0FF}You allowed this gang /r chat!");
				SaveGangs(orga[playerid]);
		        }
		        else
		        {
		        GangInfo[orga[playerid]][AllowedR]=0;
				SendClientMessage(playerid,-1,"{00C0FF}You disallowed this gang /r chat!");
				SaveGangs(orga[playerid]);
		        }
			}
			case 2:
			{
			    if(GangInfo[orga[playerid]][AllowedD]==0)
		        {
		        GangInfo[orga[playerid]][AllowedD]=1;
				SendClientMessage(playerid,-1,"{00C0FF}You allowed this gang /d chat!");
				SaveGangs(orga[playerid]);
		        }
		        else
		        {
		        GangInfo[orga[playerid]][AllowedD]=0;
				SendClientMessage(playerid,-1,"{00C0FF}You disallowed this gang /d chat!");
				SaveGangs(orga[playerid]);
		        }
			}
			case 3:
			{
			    if(GangInfo[orga[playerid]][AllowedH]==0)
		        {
		        GangInfo[orga[playerid]][AllowedH]=1;
				SendClientMessage(playerid,-1,"{00C0FF}You allowed Hitman commands to this gang(/laptop,/givetarget,/targets)!");
				SaveGangs(orga[playerid]);
		        }
		        else
		        {
		        GangInfo[orga[playerid]][AllowedH]=0;
				SendClientMessage(playerid,-1,"{00C0FF}You disallowed Hitman commands to this gang(/laptop,/givetarget,/targets)!");
				SaveGangs(orga[playerid]);
		        }
			}
			case 4:
			{
			    if(GangInfo[orga[playerid]][AllowedPD]==0)
		        {
		        GangInfo[orga[playerid]][AllowedPD]=1;
				SendClientMessage(playerid,-1,"{00C0FF}You allowed PD commands to this gang(/arrest,/cuff,/uncuff,/su,/wanted,/m,/ticket,/pu,/radar)!");
				SaveGangs(orga[playerid]);
		        }
		        else
		        {
		        GangInfo[orga[playerid]][AllowedPD]=0;
				SendClientMessage(playerid,-1,"{00C0FF}You disallowed PD commands to this gang(/arrest,/cuff,/uncuff,/su,/wanted,/m,/ticket,/pu,/radar)!");
				SaveGangs(orga[playerid]);
		        }
			}
			case 5:
			{
			    if(GangInfo[orga[playerid]][AllowedFD]==0)
		        {
		        GangInfo[orga[playerid]][AllowedFD]=1;
				SendClientMessage(playerid,-1,"{00C0FF}You allowed FD commands to this gang(/flocate,/fireext,Fire will start automatically every 10 minutes)!");
				SaveGangs(orga[playerid]);
		        }
		        else
		        {
		        GangInfo[orga[playerid]][AllowedFD]=0;
				SendClientMessage(playerid,-1,"{00C0FF}You disallowed FD commands to this gang(/flocate,/fireext,Fire will start automatically every 10 minutes)!");
				SaveGangs(orga[playerid]);
		        }
			}
		}
	}
	if(dialogid == DIALOG_TICKET)
	{
	    if(response)
		{
		SendClientMessage(playerid,-1,"You paid the ticket!");
		SendClientMessage(TicketWrote[playerid],-1,"The player has paid the ticket!");
		GivePlayerMoneyEx(playerid,-TicketPrice[playerid]);
		TicketWrote[playerid]=-1;
		TicketPrice[playerid]=0;
		}
		if(!response)
		{
		SendClientMessage(playerid,-1,"You refused to pay the ticket!");
		SendClientMessage(TicketWrote[playerid],-1,"The player has refused to pay the ticket!");
		TicketWrote[playerid]=-1;
		TicketPrice[playerid]=0;
		}
	}
	if(dialogid == DIALOG_PDWEAPONS)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0: // Patrol
	            {
	            GivePlayerWeapon(playerid,24,200);
	            GivePlayerWeapon(playerid,41,250);
                GivePlayerWeapon(playerid,3,1);
                GivePlayerWeapon(playerid,25,50);
	            }
				case 1: // Pursuit
				{
				GivePlayerWeapon(playerid,24,200);
	            GivePlayerWeapon(playerid,41,250);
                GivePlayerWeapon(playerid,3,1);
                GivePlayerWeapon(playerid,29,300);
				}
				case 2: // Special
				{
				GivePlayerWeapon(playerid,24,200);
	            GivePlayerWeapon(playerid,41,250);
                GivePlayerWeapon(playerid,3,1);
                GivePlayerWeapon(playerid,29,300);
                GivePlayerWeapon(playerid,30,400);

				}
				case 3: // Professional
				{
				GivePlayerWeapon(playerid,24,200);
	            GivePlayerWeapon(playerid,41,250);
                GivePlayerWeapon(playerid,3,1);
                GivePlayerWeapon(playerid,29,300);
                GivePlayerWeapon(playerid,31,400);

				}
				case 4: // undercover
				{
                GivePlayerWeapon(playerid,23,200);
                GivePlayerWeapon(playerid,4,1);
                SetPlayerArmour(playerid,0.0);
				}
				case 5: // Sniper
				{
				GivePlayerWeapon(playerid,24,200);
                GivePlayerWeapon(playerid,3,1);
                GivePlayerWeapon(playerid,46,1);
                GivePlayerWeapon(playerid,34,60);
				}
				case 6: // health i armour
				{
				SetPlayerHealth(playerid,100.0);
				SetPlayerArmour(playerid,100.0);
				}
				case 7: // Taser
				{
				GivePlayerWeapon(playerid,23,150);
				}
	        }
	    }
	}
	if(dialogid == neondialog)
	{
		if(response)
		{
			if(listitem ==  0)
			{

				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon",CreateObject(18648,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon1",CreateObject(18648,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon1"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,0xFFFFFFAA,"Neon Installed");
			}
			if(listitem == 1)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon2",CreateObject(18647,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon3",CreateObject(18647,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon2"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon3"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,0xFFFFFFAA,"Neon Installed");
			}
			if(listitem == 2)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon4",CreateObject(18649,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon5",CreateObject(18649,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon4"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon5"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,0xFFFFFFAA,"Neon Installed");
			}
			if(listitem == 3)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon6",CreateObject(18652,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon7",CreateObject(18652,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon6"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon7"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,0xFFFFFFAA,"Neon Installed");
			}
			if(listitem == 4)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon8",CreateObject(18651,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon9",CreateObject(18651,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon8"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon9"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,0xFFFFFFAA,"Neon Installed");
			}
			if(listitem == 5)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon10",CreateObject(18650,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon11",CreateObject(18650,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon10"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon11"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,0xFFFFFFAA,"Neon Installed");
			}
			if(listitem == 6)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon12",CreateObject(18646,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon13",CreateObject(18646,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon12"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon13"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,-1,"Neon Installed");
			}
			if(listitem == 7)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"interior",CreateObject(18646,0,0,0,0,0,0));
				SetPVarInt(playerid,"interior1",CreateObject(18646,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"interior"),GetPlayerVehicleID(playerid),0,-0.0,0,2.0,2.0,3.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"interior1"),GetPlayerVehicleID(playerid),0,-0.0,0,2.0,2.0,3.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,-1,"Neon Installed");
			}
			if(listitem == 8)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"back",CreateObject(18646,0,0,0,0,0,0));
				SetPVarInt(playerid,"back1",CreateObject(18646,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"back"),GetPlayerVehicleID(playerid),-0.0,-1.5,-1,2.0,2.0,3.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"back1"),GetPlayerVehicleID(playerid),-0.0,-1.5,-1,2.0,2.0,3.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,-1,"Neon Installed");
			}
			if(listitem == 9)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"front",CreateObject(18646,0,0,0,0,0,0));
				SetPVarInt(playerid,"front1",CreateObject(18646,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"front"),GetPlayerVehicleID(playerid),-0.0,1.5,-0.6,2.0,2.0,3.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"front1"),GetPlayerVehicleID(playerid),-0.0,1.5,-0.6,2.0,2.0,3.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,-1,"Neon Installed");
			}
			if(listitem == 10)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"undercover",CreateObject(18646,0,0,0,0,0,0));
				SetPVarInt(playerid,"undercover1",CreateObject(18646,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"undercover"),GetPlayerVehicleID(playerid),-0.5,-0.2,0.8,2.0,2.0,3.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"undercover1"),GetPlayerVehicleID(playerid),-0.5,-0.2,0.8,2.0,2.0,3.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,-1,"Neon Installed");
			}
			if(listitem == 11)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon",CreateObject(18648,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon1",CreateObject(18648,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon1"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,-1,"Neon Installed");
			}
			if(listitem == 12)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon8",CreateObject(18651,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon9",CreateObject(18651,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon8"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon9"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,-1,"Neon Installed");
			}
			if(listitem == 13)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon10",CreateObject(18650,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon11",CreateObject(18650,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon10"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon11"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,-1,"Neon Installed");
			}
			if(listitem == 14)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon12",CreateObject(18648,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon13",CreateObject(18648,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon14",CreateObject(18649,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon15",CreateObject(18649,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon12"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon13"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon14"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon15"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,-1,"Neon Installed");
			}
			if(listitem == 15)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon16",CreateObject(18648,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon17",CreateObject(18648,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon18",CreateObject(18652,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon19",CreateObject(18652,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon16"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon17"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon18"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon19"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,-1,"Neon Installed");
			}
			if(listitem == 16)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon20",CreateObject(18647,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon21",CreateObject(18647,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon22",CreateObject(18652,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon23",CreateObject(18652,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon20"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon21"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon22"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon23"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,-1,"Neon Installed");
			}
			if(listitem == 17)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon24",CreateObject(18647,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon25",CreateObject(18647,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon26",CreateObject(18650,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon27",CreateObject(18650,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon24"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon25"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon26"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon27"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,-1,"Neon Installed");

			}
			if(listitem == 18)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon28",CreateObject(18649,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon29",CreateObject(18649,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon30",CreateObject(18652,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon31",CreateObject(18652,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon28"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon29"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon30"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon31"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,-1,"Neon Installed");
			}
			if(listitem == 19)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon32",CreateObject(18652,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon33",CreateObject(18652,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon34",CreateObject(18650,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon35",CreateObject(18650,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon32"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon33"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon34"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon35"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,-1,"Neon Installed");
			}
			if(listitem == 20)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon12",CreateObject(18653,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon13",CreateObject(18653,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon12"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon13"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,0xFFFFFFAA,"Neon Installed");
			}
			if(listitem == 21)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon14",CreateObject(18654,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon15",CreateObject(18654,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon14"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon15"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,0xFFFFFFAA,"Neon Installed");

			}
			if(listitem == 22)
			{
                DestroyNeonObjects(playerid);
				SetPVarInt(playerid,"Status",1);
				SetPVarInt(playerid,"neon16",CreateObject(18655,0,0,0,0,0,0));
				SetPVarInt(playerid,"neon17",CreateObject(18655,0,0,0,0,0,0));
				AttachObjectToVehicle(GetPVarInt(playerid,"neon16"),GetPlayerVehicleID(playerid),-0.8,0.0,-0.70,0.0,0.0,0.0);
				AttachObjectToVehicle(GetPVarInt(playerid,"neon17"),GetPlayerVehicleID(playerid),0.8,0.0,-0.70,0.0,0.0,0.0);
                SetPlayerTime(playerid, 0, 0);
				SendClientMessage(playerid,0xFFFFFFAA,"Neon Installed");
			}
			if(listitem == 23)
			{
                DestroyNeonObjects(playerid);
			}
		}
	}
	if(dialogid == DIALOG_MUSIC)
	{
	    if(response)
	    {
	            if(listitem==0)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Ice_Cube_-_Gangsta_Rap_Made_Me_Do_It.mp3");
                TD_MSG(playerid, 3000, "~g~Playing ~y~Ice Cube - Gangsta Rap Made Me Do It");
	            }
	            if(listitem==1)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Justin_Timberlake_-_What_Goes_Around...Comes_Around_(Interlude).mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Justin Timberlake - What Goes Around Comes Around");
	            }
	            if(listitem==2)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Icon_For_Hire_-_Get_Well.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Icon For Hire - Get Well");
	            }
	            if(listitem==3)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Inna_-_Yalla.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Inna - Yalla");
	            }
	            if(listitem==4)
	            {
	            PlayAudioStreamForPlayer(playerid, "http://tbs-official.eu/music/Chief_Keef_-_Love_Sosa_RL_Grime_Remix.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Chief Keef - Love Sosa (RL Grime Remix)");
	            }
	            if(listitem==5)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Ty_Dolla_$ign_-_Or_Nah_(Remix).mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Ty Dolla $ign - Or Nah (Remix)");
	            }
	            if(listitem==6)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Sevyn_Streeter_-_How_Bad_Do_You_Want_It.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Sevyn Streeter - How Bad Do You Want It");
	            }
	            if(listitem==7)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Dr.Dre_The_Next_Episode.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Dr.Dre - The Next Episode (San Holo Remix)");
	            }
	            if(listitem==8)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/UMF_2015_Martin_Garrix.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~UMF 2015 Martin Garrix");
	            }
	            if(listitem==9)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/MO_-_Final_Song.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~MO - Final Song");
	            }
	            if(listitem==10)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Desiigner_-_Panda.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Desiigner - Panda");
	            }
	            if(listitem==11)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Lil_Wayne_-_A_Milli.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Lil Wayne - A Milli");
	            }
	            if(listitem==12)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Martin_Garrix_-_Animals.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Martin Garrix - Animals");
	            }
	            if(listitem==13)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Heathens_-_Twenty_One_Pilots.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Twenty One Pilots - Heathens");
	            }
	            if(listitem==14)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Eminem_-_Without_Me.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Eminem - Without Me");
	            }
	            if(listitem==15)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/DMX_-_Party_Up_(Up_In_Here).mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~DMX - Party Up");
	            }
	            if(listitem==16)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/G-Eazy_-_I_Mean_It_ft.Remo.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~G-Eazy - I Mean It (feat. Remo)");
	            }
	            if(listitem==17)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Wiz_Khalifa_Medicated_ft.Chevy_Woods_&_Juicy_J.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Wiz Khalifa - Medicated (feat. Juicy J and Chevy Woods)");
	            }
	            if(listitem==18)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Consoul_Trainin_-_Take_Me_To_Infinity.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Consoul Trainin - Take Me To Infinity");
	            }
	            if(listitem==19)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Mr.Probs_Waves.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Mr.Probz - Waves");
	            }
	            if(listitem==20)
	            {
	            ShowPlayerDialog(playerid, DIALOG_MUSIC2, DIALOG_STYLE_LIST, ""YELLOW"Pick a Song!", ""GREEN"> Fetty Wap - Trap Queen\n"GREEN"> Kid Ink - Show Me (feat. Chris Brown)\n"GREEN"> Linkin Park - Numb\n"GREEN"> Rae Sremmurd - No Type\n"GREEN"> Chris Brown & Tyga - Ayo\n"GREEN"> Linkin Park - In The End\n"GREEN"> Don Omar - Danza Kuduro\n"GREEN"> Brantley Gilbert - Bottoms Up\n"GREEN"> Eva & N.A.S.O - I Me Nqma\n"GREEN"> NADIA - Samo Teb\n"GREEN"> THCF feat. COBY - IDES ZA KANADU\n"GREEN"> Slavin Slavchev - Tamnosinyo\n"GREEN"> Pavell & Venci Venc' - Momicheto ot kvartala\n"GREEN"> Jonas Blue - Perfect Strangers (feat. JP Cooper)\n"GREEN"> Skrillex & Rick Ross - Purple Lamborghini\n"GREEN"> Deep Zone Project - Magnit\n"GREEN"> Deep Zone Project - Maski Dolu\n"GREEN"> Pavell & Venci Venc' - SeTaaBrat\n"GREEN"> DARA - K'vo ne chu\n"GREEN"> Metallica - Nothing Else Matters\n"GREEN"> Rihanna - Work (feat. Drake)\n"YELLOW">> "BLUE"Next Page\n"YELLOW"Go Back", "Choose", "Cancel");
			    }
				if(listitem==21)
	            {
	            StopAudioStreamForPlayer(playerid);
  	            TD_MSG(playerid, 3000, "~r~Stopped music");
   				}
				if(listitem==01)
				{
				StopAudioStreamForPlayer(playerid);
				}
	    }
	}
	if ( dialogid == DIALOG_MUSIC2 )
	{
	    if(response)
	    {
	            if(listitem==0)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Fetty_Wap_-_Trap_Queen.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Fetty Wap - Trap Queen");
				}
	            if(listitem==1)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Kid_Ink_-_Show_Me_(feat.Chris_Brown).mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Kid Ink - Show Me (feat. Chris Brown)");
             	}
	            if(listitem==2)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Linkin_Park_-_Numb.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Linkin Park - Numb");
	            }
	            if(listitem==3)
	            {
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Rae_Sremmurd_-_No_Type.mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~Rae Sremmurd - No Type");
				}
	            if(listitem==4)
	            {
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Chris_Brown,_Tyga_-_Ayo.mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~Chris Brown & Tyga - Ayo");
				}
	            if(listitem==5)
	            {
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Linkin_Park_-_In_The_End.mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~Linkin Park - In The End");
				}
	            if(listitem==6)
	            {
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Don_Omar_-_Danza_Kuduro.mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~Don Omar - Danza Kuduro");
				}
	            if(listitem==7)
	            {
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Brantley_Gilbert_-_Bottoms_Up.mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~Brantley Gilbert - Bottoms Up");
				}
	            if(listitem==8)
	            {
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Eva_&_N.A.S.O_-_I_Me_Nqma.mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~Eva & N.A.S.O - I Me Nqma");
				}
	            if(listitem==9)
	            {
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/NADIA_-_Samo_Teb.mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~NADIA - Samo Teb");
				}
	            if(listitem==10)
	            {
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/THCF_Ft._Coby_-_Ides_Za_Kanadu.mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~THCF feat. COBY - IDES ZA KANADU");
				}
			    if(listitem==11)
	            {
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Slavin_Slavchev_-_Tamnosinyo.mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~Slavin Slavchev - Tamnosinyo");
				}
	            if(listitem==12)
	            {
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Pavell_&_Venci_Venc_-_Momicheto_Ot_Kvartala.mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~Pavell & Venci Venc' - Momicheto ot kvartala");
				}
				if(listitem==13)
				{
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Jonas_Blue_-_Perfect_Strangers_(feat.JP_Cooper).mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~Jonas Blue - Perfect Strangers (feat. JP Cooper)");
				}
				if(listitem==14)
				{
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Skrillex_&_Rick_Ross_-_Purple_Lamborghini.mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~Skrillex & Rick Ross - Purple Lamborghini");
				}
				if(listitem==15)
				{
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Deep_Zone_Project_-_Magnit.mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~Deep Zone Project - Magnit");
				}
				if(listitem==16)
				{
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Deep_Zone_Project_-_Maski_Dolu.mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~Deep Zone Project - Maski Dolu");
				}
				if(listitem==17)
				{
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Pavell_&_Venci_Venc'_-_SeTaaBrat.mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~Pavell & Venci Venc' - SeTaaBrat");
				}
				if(listitem==18)
				{
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/DARA_-_K'vo_ne_chu.mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~DARA - K'vo ne chu");
				}
				if(listitem==19)
				{
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Metallica_-_Nothing_Else_Matters.mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~Metallica - Nothing Else Matters");
				}
				if(listitem==20)
				{
				PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Rihanna_-_Work_(feat.Drake).mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~Rihanna - Work (feat. Drake)");
				}
				if(listitem==21)
	            {
				ShowPlayerDialog(playerid, DIALOG_MUSIC3, DIALOG_STYLE_LIST, ""YELLOW"Pick a Song!", ""GREEN"> Metallica - The Unforgiven\n"GREEN"> Eminem - Till I Collapse (feat. Nate Dogg)\n"GREEN"> 50 Cent - Candy Shop (feat. Olivia)\n"YELLOW">> "YELLOW"Go Back", "Choose", "Cancel");
				}
				if(listitem==22)
				{
                ShowPlayerDialog(playerid, DIALOG_MUSIC, DIALOG_STYLE_LIST, ""YELLOW"Pick a Song!", ""GREEN"> Ice Cube - Gangsta Rap Made Me Do It\n"GREEN"> Justin Timberlake - What Goes Around Comes Back Around\n"GREEN"> Icon For Hire - Get Well\n"GREEN"> Inna - Yalla\n"GREEN"> Chief Keef - Love Sosa (Remix)\n"GREEN"> Ty Dolla $ign - Or Nah (feat. Wiz Khalifa & The Weeknd)\n"GREEN"> Sevyn Streeter - How Bad Do You Want It\n"GREEN"> Dr.Dre feat. Snoop Dogg - The Next Episode (San Holo Remix)\n"GREEN"> Martin Garrix - UMF 2015\n"GREEN"> MO - Final Song\n"GREEN"> Desiigner - Panda\n"GREEN"> Lil Wayne - A Milli\n"GREEN"> Martin Garrix - Animals\n"GREEN"> Twenty One Pilots - Heathens\n"GREEN"> Eminem - Without Me\n"GREEN"> DMX - Party Up\n"GREEN"> G-Eazy - I Mean It (feat. Remo)\n"GREEN"> Wiz Khalifa - Medicated (feat. Juicy J & Chevy Woods)\n"GREEN"> Consoul Trainin - Take Me To Infinity\n"GREEN"> Mr.Probz - Waves\n"BLUE"> Next Page\n"RED">> "RED"Stop Music", "Choose", "Cancel");
				}
		}
	}
	if ( dialogid == DIALOG_MUSIC3 )
	{
	    if(response)
	    {
	            if(listitem==0)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Metallica_-_The_Unforgiven.mp3");
	            TD_MSG(playerid, 3000, "~g~Playing ~y~Metallica - The Unforgiven");
			    }
                if(listitem==1)
	            {
	            PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/Eminem_-_Till_I_Collapse_(feat.Nate_Dogg).mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~Eminem - Till I Collapse (feat. Nate Dogg)");
			    }
			    if(listitem==2)
			    {
			    PlayAudioStreamForPlayer(playerid, "https://tbs-official.eu/music/50_Cent_-_Candy_Shop_(feat.Olivia).mp3");
				TD_MSG(playerid, 3000, "~g~Playing ~y~50 Cent - Candy Shop (feat. Olivia)");
				}
                if(listitem==3)
	            {
                ShowPlayerDialog(playerid, DIALOG_MUSIC2, DIALOG_STYLE_LIST, ""YELLOW"Pick a Song!", ""GREEN"> Fetty Wap - Trap Queen\n"GREEN"> Kid Ink - Show Me (feat. Chris Brown)\n"GREEN"> Linkin Park - Numb\n"GREEN"> Rae Sremmurd - No Type\n"GREEN"> Chris Brown & Tyga - Ayo\n"GREEN"> Linkin Park - In The End\n"GREEN"> Don Omar - Danza Kuduro\n"GREEN"> Brantley Gilbert - Bottoms Up\n"GREEN"> Eva & N.A.S.O - I Me Nqma\n"GREEN"> NADIA - Samo Teb\n"GREEN"> THCF feat. COBY - IDES ZA KANADU\n"GREEN"> Slavin Slavchev - Tamnosinyo\n"GREEN"> Pavell & Venci Venc' - Momicheto ot kvartala\n"GREEN"> Jonas Blue - Perfect Strangers (feat. JP Cooper)\n"GREEN"> Skrillex & Rick Ross - Purple Lamborghini\n"GREEN"> Deep Zone Project - Magnit\n"GREEN"> Deep Zone Project - Maski Dolu\n"GREEN"> Pavell & Venci Venc' - SeTaaBrat\n"GREEN"> DARA - K'vo ne chu\n"GREEN"> Metallica - Nothing Else Matters\n"GREEN"> Rihanna - Work (feat. Drake)\n"YELLOW">> "YELLOW"Go Back", "Choose", "Cancel");
			    }
		 }
	}
	if(dialogid == DUELDIAG)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0: //Choose player
	            {
                    ShowPlayerDialog(playerid, DUELDIAG+1, DIALOG_STYLE_INPUT, "Duel - Select a player", "{C0C0C0}Type in the playername or ID of the player you want\nto invite to a duel.\n\n{00FFFF}NOTE: You can enter partial names.", "Invite", "Back");
	            }
	            case 1: //Choose Duel location
				{
					format(diagstr, sizeof(diagstr), "ID\tDuel Name\n");
					for(new x=0; x<MAX_DUELS; x++)
					{
						format(dFile, sizeof(dFile), DUELFILES, x);
				 		if(strlen(dini_Get(dFile, "duelName")) > 0) format(diagstr, sizeof(diagstr), "%s%d\t%s\n", diagstr, x, dini_Get(dFile, "duelName"));
				 		else format(diagstr, sizeof(diagstr), "%s%d\tEmpty Slot\n", diagstr, x);
					}
					ShowPlayerDialog(playerid, DUELDIAG+2, DIALOG_STYLE_LIST, "Duel List", diagstr, "Select", "Exit");
					return 1;
	            }
	            case 2: //Choose weapons
	            {
	                ShowPlayerDialog(playerid, DUELDIAG+5, DIALOG_STYLE_LIST, "Select Weapon Slot", "Slot 1\nSlot 2\nSlot 3", "Select", "Back");
	            }
	            case 3: //Choose Duel Money
	            {
	                ShowPlayerDialog(playerid, DUELDIAG+4, DIALOG_STYLE_INPUT, "Set Bet Amount", "{00FFFF}NOTE: {FFFFFF}Set the bet amount for the duel.\n\n{00FF00}The winner takes the money and the loser\nloses this amount of money.", "Set", "Back");
	            }
	            case 4: //Send invitation
				{
				    new str[80];
				    new dPID = GetPVarInt(playerid, "dPID");
				    new dBet = GetPVarInt(playerid, "dBet");
				    new dLoc = GetPVarInt(playerid, "dLoc");
				    new dWep[3], key[7];
					for(new x=0; x<=2; x++)
					{
						format(key, sizeof(key), "dWep%d", x);
						dWep[x] = GetPVarInt(playerid, key);
					}
					format(str, sizeof(str), "invite %d %d %d %d %d %d", dPID, dBet, dLoc, dWep[0], dWep[1], dWep[2]);
					return cmd_duel(playerid, str);
				}
	            case 5: //Cancel invitation
	            {
	            	return SendClientMessage(playerid, COLOR_DUEL, "Duel invite was canceled, duel settings were saved.");
	            }
	        }
		}
	}
	if(dialogid == DUELDIAG+1)
	{
	    if(response)
	    {
	        new invitee;
	        if(sscanf(inputtext, "u", invitee)) return ShowPlayerDialog(playerid, DUELDIAG+1, DIALOG_STYLE_INPUT, "Duel - Select a player", "{C0C0C0}Type in the playername or ID of the player you want\nto invite to a duel.\n\n{C0C0C0}NOTE: You can enter partial names.", "Invite", "Back");
			if(invitee == playerid) return ShowPlayerDialog(playerid, DUELDIAG+1, DIALOG_STYLE_INPUT, "Duel - Select a player", "{FF0000}ERROR: You cannot invite yourself to a duel!\n\n{C0C0C0}Type in the playername or ID of the player you want\nto invite to a duel.\n\n{C0C0C0}NOTE: You can enter partial names.", "Invite", "Back");
			if(invitee == INVALID_PLAYER_ID || !IsPlayerConnected(invitee)) return ShowPlayerDialog(playerid, DUELDIAG+1, DIALOG_STYLE_INPUT, "Duel - Select a player", "{FF0000}ERROR: The player specified is not connected, try again!\n\n{C0C0C0}Type in the playername or ID of the player you want\nto invite to a duel.\n\n{00FFFF}NOTE: You can enter partial names.", "Invite", "Back");
			SetPVarInt(playerid, "dPID", invitee);
   			ShowDuelSettingsDialog(playerid);
		}
		else ShowDuelSettingsDialog(playerid);
	}
	if(dialogid == DUELDIAG+2)
	{
		if(response)
		{
			format(dFile, sizeof(dFile), DUELFILES, listitem-1);
			if(!dini_Exists(dFile)) return OnDialogResponse(playerid, DUELDIAG, 1, 1, "blank");
			SetPVarInt(playerid, "dLoc", listitem-1);
			ShowDuelSettingsDialog(playerid);
		}
		else ShowDuelSettingsDialog(playerid);
	}
	if(dialogid == DUELDIAG+4) //Duel money
	{
		if(response)
		{
	        new amount;
	       	if(sscanf(inputtext, "d", amount)) return ShowPlayerDialog(playerid, DUELDIAG+4, DIALOG_STYLE_INPUT, "Set Bet Amount", "Enter the bet amount for the duel.\nThe winner takes the money and the loser\nloses this amount of money.", "Set", "Back");
			if(MINMONEY != 0 && amount < 500) return ShowPlayerDialog(playerid, DUELDIAG+4, DIALOG_STYLE_INPUT, "Set Bet Amount", "ERROR: Bet amount must be higher then $500!\nSet the bet amount for the duel.\nThe winner takes the money and the loser\nloses this amount of money.", "Set", "Back");
            SetPVarInt(playerid, "dBet", amount);
   			ShowDuelSettingsDialog(playerid);
		}
		else ShowDuelSettingsDialog(playerid);
	}
	if(dialogid == DUELDIAG+5) //Weapon slots
	{
	    if(response)
		{
			SetPVarInt(playerid, "dWSlot", listitem);
			ShowPlayerDialog(playerid, DUELDIAG+6, DIALOG_STYLE_LIST, "Choose a weapon", "Brass Knuckles\nGolf Club\nNite Stick\nKnife\nBaseball Bat\nShovel\nPool Cue\nKatana\nChainsaw\nDildo\nVibrator\nFlowers\nCane\nGrenade\nTeargas\nMolotov\nColt 45\nSilenced Pistol\nDeagle\nShotgun\nSawns\nSpas\nUzi\nMP5\nAK47\nM4\nTec9\nRifle\nSniper", "Select", "Back");
		}
		else ShowDuelSettingsDialog(playerid);
	}
	if(dialogid == DUELDIAG+6)
	{
	    if(response)
	    {
			new key[7];
			format(key, sizeof(key), "dWep%d", GetPVarInt(playerid, "dWSlot"));
			switch(listitem)
			{
			    case 13..15:
				{
			    	ShowPlayerDialog(playerid, DUELDIAG+6, DIALOG_STYLE_LIST, "Choose a weapon", "Brass Knuckles\nGolf Club\nNite Stick\nKnife\nBaseball Bat\nShovel\nPool Cue\nKatana\nChainsaw\nDildo\nVibrator\nFlowers\nCane\nGrenade\nTeargas\nMolotov\nColt 45\nSilenced Pistol\nDeagle\nShotgun\nSawns\nSpas\nUzi\nMP5\nAK47\nM4\nTec9\nRifle\nSniper", "Select", "Back");
					return SendClientMessage(playerid, COLOR_RED, "ERROR: This weapon is disabled!");
				}
			}
	        switch(listitem)
	        {
	            case 0: SetPVarInt(playerid, key, 1);
	            case 1: SetPVarInt(playerid, key, 2);
	            case 2: SetPVarInt(playerid, key, 3);
	            case 3: SetPVarInt(playerid, key, 4);
	            case 4: SetPVarInt(playerid, key, 5);
	            case 5: SetPVarInt(playerid, key, 6);
	            case 6: SetPVarInt(playerid, key, 7);
	            case 7: SetPVarInt(playerid, key, 8);
	            case 8: SetPVarInt(playerid, key, 9);
	            case 9: SetPVarInt(playerid, key, 10);
	            case 10: SetPVarInt(playerid, key, 11);
	            case 11: SetPVarInt(playerid, key, 14);
	            case 12: SetPVarInt(playerid, key, 15);
	            case 13: SetPVarInt(playerid, key, 16);
	            case 14: SetPVarInt(playerid, key, 17);
	            case 15: SetPVarInt(playerid, key, 18);
	            case 16: SetPVarInt(playerid, key, 22);
	            case 17: SetPVarInt(playerid, key, 23);
	            case 18: SetPVarInt(playerid, key, 24);
	            case 19: SetPVarInt(playerid, key, 25);
	            case 20: SetPVarInt(playerid, key, 26);
	            case 21: SetPVarInt(playerid, key, 27);
	            case 22: SetPVarInt(playerid, key, 28);
	            case 23: SetPVarInt(playerid, key, 29);
	            case 24: SetPVarInt(playerid, key, 30);
	            case 25: SetPVarInt(playerid, key, 31);
	            case 26: SetPVarInt(playerid, key, 32);
	            case 27: SetPVarInt(playerid, key, 33);
	            case 28: SetPVarInt(playerid, key, 34);
	        }
	        ShowDuelSettingsDialog(playerid);
	    }
	    else ShowDuelSettingsDialog(playerid);
	}
	if(dialogid == DUELDIAG+7)
	{
	    if(response)
		{
		    if(!IsPlayerInDuel(diagitem[listitem])) return 1;
			SetPlayerSpectatingDuel(playerid, diagitem[listitem]);
		}
	    else return 1;
	}
	if(dialogid == DUELDIAG+8)
	{
	    if(response)
		{
			new vehicle;
			if(listitem > MAX_INVITES) return 1;
		    new dueler = dinvitem[playerid][listitem];
		    if(dueler == INVALID_PLAYER_ID) return ShowPlayerDialog(playerid, DUELDIAG-1, DIALOG_STYLE_MSGBOX, "Duel Invites", "ERROR: This player is no longer connected!", "Ok", "");
            //if(GetPlayerMoneyEx(dueler) < GetPVarInt(playerid, "dBet")) return SendClientMessage(playerid, COLOR_RED, "Duel | This player does not have that amount of money!");
            if(GetPlayerMoneyEx(playerid) < GetPVarInt(playerid, "dBet")) return SendClientMessage(playerid, COLOR_RED, "Duel | You don't have that amount of money to bet");
            if(dueler == playerid) return SendClientMessage(playerid, COLOR_RED, "Duel | You can't duel yourself!");
			vehicle = GetPlayerVehicleID(playerid);
		    RemovePlayerFromVehicle(playerid);
		    DestroyVehicle(vehicle);
			SetPVarInt(playerid, "DuelDID", listitem);
			AcceptDuel(playerid);
 			return 1;
		}
	}
	if (dialogid == WEAPONS)
	{
		if (response)
		switch (listitem)
		{
			case 0:
			{
			    if (PlayerInfo[playerid][inMini] == 1) return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"You cannot spawn weaponsets in Minigun DM.");
                if (GetPlayerMoneyEx(playerid) < 100000) return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"You do not have enough cash to buy this weaponset.");
				PlayerInfo[playerid][WeaponSet] = 0;
				GiveWeaponSet(playerid, 0);
				GivePlayerMoneyEx(playerid, -250000);
				ShowPlayerDialog( playerid, 5, DIALOG_STYLE_MSGBOX, "{FF122A}Standard Weapon Set", "{32E3A2}You are now using Standard Weapon Set!", "OK", "");
			}
			case 1:
			{
			    if (PlayerInfo[playerid][inMini] == 1) return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"You cannot spawn weaponsets in Minigun DM.");
			    if (GetPlayerMoneyEx(playerid) < 250000) return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"You do not have enough cash to buy this weaponset.");
				PlayerInfo[playerid][WeaponSet] = 1;
				GiveWeaponSet(playerid, 1);
				GivePlayerMoneyEx(playerid, -250000);
				ShowPlayerDialog( playerid, 5, DIALOG_STYLE_MSGBOX, "{FF122A}Advanced Weapon Set", "{32E3A2}You are now using Advanced Weapon Set!", "OK", "");
			}
			case 2:
			{
			    if (PlayerInfo[playerid][inMini] == 1) return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"You cannot spawn weaponsets in Minigun DM.");
		     	if (GetPlayerMoneyEx(playerid) < 500000) return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"You do not have enough cash to buy this weaponset.");
				PlayerInfo[playerid][WeaponSet] = 2;
				GiveWeaponSet(playerid, 2);
				GivePlayerMoneyEx(playerid, -500000);
				ShowPlayerDialog( playerid, 5, DIALOG_STYLE_MSGBOX, "{FF122A}Expert Weapon Set", "{32E3A2}You are now using Expert Weapon Set!", "OK", "");
			}
		}
	}
	if (dialogid == DIALOG_CUSTOMSPAWN)
	{
	    if(!response) return 1;
		if (response)
		{
		    GetPlayerPos(playerid, pos_x[playerid], pos_y[playerid], pos_z[playerid]);
		    PlayerInfo[playerid][POS_X] = pos_x[playerid];
		    PlayerInfo[playerid][POS_Y] = pos_y[playerid];
		    PlayerInfo[playerid][POS_Z] = pos_z[playerid];
		    SendClientMessage(playerid, -1, ""PINK"[SPAWN] You have successfully set your current position as your custom spawn place!");
		    return 1;
		}
	}
 	if (dialogid == DIALOG_SPAWN)
	{
	    if (!response) return 1;
	    if (response)
	    {
	        switch (listitem)
	        {
	            case 0:
	            {
					PlayerInfo[playerid][POS_X] = 2180.3672;
					PlayerInfo[playerid][POS_Y] = 1681.6908;
					PlayerInfo[playerid][POS_Z] = 11.0565;
					SendClientMessage(playerid, -1, ""PINK"[SPAWN] You have changed your spawn place to Las Venturas (/lv).");
				}
				case 1:
				{
				    PlayerInfo[playerid][POS_X] = 2094.1396;
				    PlayerInfo[playerid][POS_Y] = -2631.1240;
					PlayerInfo[playerid][POS_Z] = 13.6307;
					SendClientMessage(playerid, -1, ""PINK"[SPAWN] You have changed your spawn place to Las Santos Airport (/lsair).");
				}
				case 2:
				{
				    PlayerInfo[playerid][POS_X] = 374.7578;
				    PlayerInfo[playerid][POS_Y] = 2536.7205;
				    PlayerInfo[playerid][POS_Z] = 16.5790;
					SendClientMessage(playerid, -1, ""PINK"[SPAWN] You have changed your spawn place to Abandoned Airfield (/aa).");
				}
				case 3:
				{
				    PlayerInfo[playerid][POS_X] = -2355.9038;
					PlayerInfo[playerid][POS_Y] = -1635.4912;
					PlayerInfo[playerid][POS_Z] = 483.7031;
					SendClientMessage(playerid, -1, ""PINK"[SPAWN] You have changed your spawn place to Mount Chilliad (/chilliad).");
				}
				case 4:
				{
				    PlayerInfo[playerid][POS_X] = -2663.3826;
					PlayerInfo[playerid][POS_Y] = 1329.6676;
					PlayerInfo[playerid][POS_Z] = 16.9922;
					SendClientMessage(playerid, -1, ""PINK"[SPAWN] You have changed your spawn place to San Fierro (/sf).");
				}
				case 5:
				{
					GetPlayerPos(playerid, pos_x[playerid], pos_y[playerid], pos_z[playerid]);
		    		PlayerInfo[playerid][POS_X] = pos_x[playerid];
		    		PlayerInfo[playerid][POS_Y] = pos_y[playerid];
		    		PlayerInfo[playerid][POS_Z] = pos_z[playerid];
		    		SendClientMessage(playerid, -1, ""PINK"[SPAWN] You have changed your spawn place to your current position.");
				}
			}
		}
	}
	if (dialogid == DIALOG_GM)
	{
	    if (!response) return 1;
		if (response)
		{
			SetPlayerPos(playerid, pos_x[playerid], pos_y[playerid], pos_z[playerid]);
			ResetPlayerWeapons(playerid);
			SetPlayerHealth(playerid, 10.0);
			SetPlayerArmour(playerid, 0.0);
			GivePlayerWeapon(playerid, 16, 20);
			return 1;
		}
	}
	if (dialogid == DIALOG_CHANGENAME)
	{
	    if (!response) return 1;
	    if (response)
	    {
	        new path[40], str[150];
			if (isnull(inputtext)) return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"You have not specified any new name.");
			if (strlen(inputtext) < 3 || strlen(inputtext) > 24) return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"Your new nick cannot be smaller than 3 or longer than 24 characters!");
			format(path, sizeof(path), "Users/%s.ini", inputtext);
			if (fexist(path)) return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"The name you have entered is already registered. Please enter a different name to proceed.");
			else
			frename(UserPath(playerid), path);
			SetPlayerName(playerid, inputtext);
			format(str, sizeof(str), "{F5CD1B}You have successfully changed your name to %s. Make sure you change your name on your SA-MP client.", inputtext);
			SendClientMessage(playerid, -1, str);
			return 1;
		}
	}
	switch ( dialogid ) {
	    case DIALOG_BANK2 : {
			if ( response ) {
			    new
			        INI:file = INI_Open( bankFile( playerid ) );
				INI_WriteInt( file, "bankMoney", 0 );
				INI_Close( file );
				bAcc{ playerid } = true;
				ShowPlayerDialog( playerid, DIALOG_BANK3, DIALOG_STYLE_MSGBOX, "{FFFFFF}Bank Account",
				"{FFFFFF}Your bank account has been created. Would you like to deposit some of your money now?", "Yes", "No" );
			}
		}
		case DIALOG_BANK3 : {
		    if ( response ) {
		        ShowPlayerDialog( playerid, DIALOG_BANK, DIALOG_STYLE_LIST, "{FFFFFF}Bank Account",
				"{FFFFFF}Balance\nDeposit\nWithdraw", "Select", "Cancel" );
			}
		}
		case DIALOG_BANK : {
		    if ( response ) {
		        new
		            str[ 250 ];
		        switch ( listitem ) {
		            case 0 : { // Balance
						format( str, sizeof ( str ), "{FFFFFF}Bank Balance : {33FF33}$%i", bankMoney[ playerid ] );
						ShowPlayerDialog( playerid, DIALOG_BANK3, DIALOG_STYLE_MSGBOX, "{FFFFFF}Balance", str, "Return", "Exit" );
					}
					case 1 : { // Deposit
					    format( str, sizeof ( str ),
						"{FFFFFF}Write the amount of money that you want to deposit at the blank field below! \n\n\
						{FFFFFF}Current Balance : {33FF33}$%d", bankMoney[ playerid ] );
					    ShowPlayerDialog( playerid, DIALOG_DEPOSIT, DIALOG_STYLE_INPUT, "{FFFFFF}Deposit",
					    str, "Deposit", "Cancel" );
					}
					case 2 : { // Withdraw
						format( str, sizeof ( str ),
						"{FFFFFF}Write the amount of money that you want to withdraw at the blank field below! \n\n\
						{FFFFFF}Current Balance : {33FF33}$%d", bankMoney[ playerid ] );
					    ShowPlayerDialog( playerid, DIALOG_WITHDRAW, DIALOG_STYLE_INPUT, "{FFFFFF}Withdraw",
					    str, "Withdraw", "Cancel" );
					}
				}
			}
		}
		case DIALOG_DEPOSIT : {
		    if ( response ) {
		        new
		            str[ 300 ];
				if ( !isNumeric( inputtext ) ) {
				    format( str, sizeof ( str ),
				    "{FF3333}ERROR: {FFFFFF}The input must be a number! \n\
					{FFFFFF}Write the amount of money that you want to deposit at the blank field below! \n\n\
					{FFFFFF}Current Balance : {33FF33}$%d", bankMoney[ playerid ] );
				    ShowPlayerDialog( playerid, DIALOG_DEPOSIT, DIALOG_STYLE_INPUT, "{FFFFFF}Deposit",
				    str, "Deposit", "Cancel" );
					return true;
				}
				if ( strval( inputtext ) < 0 || strval( inputtext ) > 900000000 ) {
					format( str, sizeof ( str ),
				    "{FF3333}ERROR: {FFFFFF}Valid amount : 0$ - 900.000.000$ < 900 millions >! \n\
					{FFFFFF}Write the amount of money that you want to deposit at the blank field below! \n\n\
					{FFFFFF}Current Balance : {33FF33}$%d", bankMoney[ playerid ] );
				    ShowPlayerDialog( playerid, DIALOG_DEPOSIT, DIALOG_STYLE_INPUT, "{FFFFFF}Deposit",
				    str, "Deposit", "Cancel" );
					return true;
				}
				if ( strval( inputtext ) > GetPlayerMoneyEx( playerid ) ) {
				    format( str, sizeof ( str ),
				    "{FF3333}ERROR: {FFFFFF}You don't have that much money! \n\
					{FFFFFF}Write the amount of money that you want to deposit at the blank field below! \n\n\
					{FFFFFF}Current Balance : {33FF33}$%d", bankMoney[ playerid ] );
				    ShowPlayerDialog( playerid, DIALOG_DEPOSIT, DIALOG_STYLE_INPUT, "{FFFFFF}Deposit",
				    str, "Deposit", "Cancel" );
					return true;
				}
				bankMoney[ playerid ] = ( bankMoney[ playerid ] + strval( inputtext ) );
				new
		    		INI: file = INI_Open( bankFile( playerid ) );
				INI_WriteInt( file, "bankMoney", bankMoney[ playerid ] );
				INI_Close( file );
				format( str, sizeof ( str ), "{FFFFFF}You have deposited {33FF33}$%i {FFFFFF}to your bank account! \n\n\
				{FFFFFF}Bank Balance : {33FF33}$%i", strval( inputtext ), bankMoney[ playerid ] );
				GivePlayerMoneyEx( playerid, - strval( inputtext ) );
				ShowPlayerDialog( playerid, DIALOG_BANK3, DIALOG_STYLE_MSGBOX, "{FFFFFF}Deposit", str, "Return", "Exit" );
			}
		}
		case DIALOG_WITHDRAW : {
			if ( response ) {
			    new
			        str[ 300 ];
				if ( !isNumeric( inputtext ) ) {
					format( str, sizeof ( str ),
				    "{FF3333}ERROR: {FFFFFF}The input must be a number! \n\
					{FFFFFF}Write the amount of money that you want to withdraw at the blank field below! \n\n\
					{FFFFFF}Current Balance : {33FF33}$%d", bankMoney[ playerid ] );
				    ShowPlayerDialog( playerid, DIALOG_WITHDRAW, DIALOG_STYLE_INPUT, "{FFFFFF}Withdraw",
				    str, "Withdraw", "Cancel" );
				    return true;
				}
				if ( strval( inputtext ) < 0 || strval( inputtext ) > 900000000 ) {
					format( str, sizeof ( str ),
				    "{FF3333}ERROR: {FFFFFF}Valid amount : 0$ - 900.000.000$ < 900 millions >! \n\
					{FFFFFF}Write the amount of money that you want to withdraw at the blank field below! \n\n\
					{FFFFFF}Current Balance : {33FF33}$%d", bankMoney[ playerid ] );
				    ShowPlayerDialog( playerid, DIALOG_WITHDRAW, DIALOG_STYLE_INPUT, "{FFFFFF}Withdraw",
				    str, "Deposit", "Cancel" );
					return true;
				}
				if ( strval( inputtext ) > bankMoney[ playerid ] ) {
					format( str, sizeof ( str ),
				    "{FF3333}ERROR: {FFFFFF}You don't have that much money in your bank account! \n\
					{FFFFFF}Write the amount of money that you want to withdraw at the blank field below! \n\n\
					{FFFFFF}Current Balance : {33FF33}$%d", bankMoney[ playerid ] );
                    ShowPlayerDialog( playerid, DIALOG_WITHDRAW, DIALOG_STYLE_INPUT, "{FFFFFF}Withdraw",
				    str, "Withdraw", "Cancel" );
				    return true;
				}
				bankMoney[ playerid ] = ( bankMoney[ playerid ] - strval( inputtext ) );
				new
		    		INI: file = INI_Open( bankFile( playerid ) );
				INI_WriteInt( file, "bankMoney", bankMoney[ playerid ] );
				INI_Close( file );
				format( str, sizeof ( str ), "{FFFFFF}You have withdrawn {33FF33}$%i {FFFFFF}from your bank account! \n\n\
				{FFFFFF}Bank Balance : {33FF33}$%i", strval( inputtext ), bankMoney[ playerid ] );
				GivePlayerMoneyEx( playerid, strval( inputtext ) );
				ShowPlayerDialog( playerid, DIALOG_BANK3, DIALOG_STYLE_MSGBOX, "{FFFFFF}Withdraw", str, "Return", "Exit" );
			}
		}
	}
	if (dialogid == DIALOG_SETTINGS)
	{
	    if (!response) return 1;
	    if (response)
	    {
	        switch (listitem)
			{
				case 0:
				{
				    if (Nitro[playerid] == 1)
				    {
				        Nitro[playerid] = 0;
					}
					else if (Nitro[playerid] == 0)
					{
					    Nitro[playerid] = 1;
					}
					new string[300];
					new SBstring[30];
					if (Nitro[playerid] == 1) format(SBstring, 30, ""C_RED"Disable"C_WHITE"");
					if (Nitro[playerid] == 0) format(SBstring, 30, ""C_GREEN"Enable"C_WHITE"");
					new AutoFixString[30];
					if (AutoFix[playerid] == 1) format(AutoFixString, 30, ""C_RED"Disable"C_WHITE"");
					if (AutoFix[playerid] == 0) format(AutoFixString, 30, ""C_GREEN"Enable"C_WHITE"");
					new BounceString[30];
					if (Bounce[playerid] == 1) format(BounceString, 30, ""C_RED"Disable"C_WHITE"");
					if (Bounce[playerid] == 0) format(BounceString, 30, ""C_GREEN"Enable"C_WHITE"");
					new AFstring[30];
					if (AntifallEnabled[playerid] == 1) format(AFstring, 30, ""C_RED"Disable"C_WHITE"");
					if (AntifallEnabled[playerid] == 0) format(AFstring, 30, ""C_GREEN"Enable"C_WHITE"");
					new WeaponSetString[30];
					if (PlayerInfo[playerid][WeaponSet] == 0) format(WeaponSetString, 30, ""ORANGE"Standard"C_WHITE"");
					if (PlayerInfo[playerid][WeaponSet] == 1) format(WeaponSetString, 30, ""ORANGE"Advanced"C_WHITE"");
					if (PlayerInfo[playerid][WeaponSet] == 2) format(WeaponSetString, 30, ""ORANGE"Expert"C_WHITE"");
					format(string, 300, "Speedboost (%s)\nAuto Repair (%s)\nBounce (%s)\nAntifall (%s)\nWeapon Set (%s)", SBstring, AutoFixString, BounceString, AFstring, WeaponSetString);
					ShowPlayerDialog(playerid, DIALOG_SETTINGS, DIALOG_STYLE_LIST, ""REDORANGE">> "C_WHITE"Account Settings", string, "OK", "Cancel");
				}
				case 1:
				{
					if (AutoFix[playerid] == 1)
					{
					    AutoFix[playerid] = 0;
					}
					else if (AutoFix[playerid] == 0)
					{
					    AutoFix[playerid] = 1;
					}
					new string[300];
					new SBstring[30];
					if (Nitro[playerid] == 1) format(SBstring, 30, ""C_RED"Disable"C_WHITE"");
					if (Nitro[playerid] == 0) format(SBstring, 30, ""C_GREEN"Enable"C_WHITE"");
					new AutoFixString[30];
					if (AutoFix[playerid] == 1) format(AutoFixString, 30, ""C_RED"Disable"C_WHITE"");
					if (AutoFix[playerid] == 0) format(AutoFixString, 30, ""C_GREEN"Enable"C_WHITE"");
					new BounceString[30];
					if (Bounce[playerid] == 1) format(BounceString, 30, ""C_RED"Disable"C_WHITE"");
					if (Bounce[playerid] == 0) format(BounceString, 30, ""C_GREEN"Enable"C_WHITE"");
					new AFstring[30];
					if (AntifallEnabled[playerid] == 1) format(AFstring, 30, ""C_RED"Disable"C_WHITE"");
					if (AntifallEnabled[playerid] == 0) format(AFstring, 30, ""C_GREEN"Enable"C_WHITE"");
					new WeaponSetString[30];
					if (PlayerInfo[playerid][WeaponSet] == 0) format(WeaponSetString, 30, ""ORANGE"Standard"C_WHITE"");
					if (PlayerInfo[playerid][WeaponSet] == 1) format(WeaponSetString, 30, ""ORANGE"Advanced"C_WHITE"");
					if (PlayerInfo[playerid][WeaponSet] == 2) format(WeaponSetString, 30, ""ORANGE"Expert"C_WHITE"");
					format(string, 300, "Speedboost (%s)\nAuto Repair (%s)\nBounce (%s)\nAntifall (%s)\nWeapon Set (%s)", SBstring, AutoFixString, BounceString, AFstring, WeaponSetString);
					ShowPlayerDialog(playerid, DIALOG_SETTINGS, DIALOG_STYLE_LIST, ""REDORANGE">> "C_WHITE"Account Settings", string, "OK", "Cancel");
				}
				case 2:
				{
				    if (Bounce[playerid] == 1)
				    {
				        Bounce[playerid] = 0;
					}
					else if (Bounce[playerid] == 0)
					{
					    Bounce[playerid] = 1;
					}
					new string[300];
					new SBstring[30];
					if (Nitro[playerid] == 1) format(SBstring, 30, ""C_RED"Disable"C_WHITE"");
					if (Nitro[playerid] == 0) format(SBstring, 30, ""C_GREEN"Enable"C_WHITE"");
					new AutoFixString[30];
					if (AutoFix[playerid] == 1) format(AutoFixString, 30, ""C_RED"Disable"C_WHITE"");
					if (AutoFix[playerid] == 0) format(AutoFixString, 30, ""C_GREEN"Enable"C_WHITE"");
					new BounceString[30];
					if (Bounce[playerid] == 1) format(BounceString, 30, ""C_RED"Disable"C_WHITE"");
					if (Bounce[playerid] == 0) format(BounceString, 30, ""C_GREEN"Enable"C_WHITE"");
					new AFstring[30];
					if (AntifallEnabled[playerid] == 1) format(AFstring, 30, ""C_RED"Disable"C_WHITE"");
					if (AntifallEnabled[playerid] == 0) format(AFstring, 30, ""C_GREEN"Enable"C_WHITE"");
					new WeaponSetString[30];
					if (PlayerInfo[playerid][WeaponSet] == 0) format(WeaponSetString, 30, ""ORANGE"Standard"C_WHITE"");
					if (PlayerInfo[playerid][WeaponSet] == 1) format(WeaponSetString, 30, ""ORANGE"Advanced"C_WHITE"");
					if (PlayerInfo[playerid][WeaponSet] == 2) format(WeaponSetString, 30, ""ORANGE"Expert"C_WHITE"");
					format(string, 300, "Speedboost (%s)\nAuto Repair (%s)\nBounce (%s)\nAntifall (%s)\nWeapon Set (%s)", SBstring, AutoFixString, BounceString, AFstring, WeaponSetString);
					ShowPlayerDialog(playerid, DIALOG_SETTINGS, DIALOG_STYLE_LIST, ""REDORANGE">> "C_WHITE"Account Settings", string, "OK", "Cancel");
				}
				case 3:
				{
				    if (AntifallEnabled[playerid] == 1)
				    {
				        AntifallEnabled[playerid] = 0;
					}
					else if (AntifallEnabled[playerid] == 0)
					{
					    AntifallEnabled[playerid] = 1;
					}
					new string[300];
					new SBstring[30];
					if (Nitro[playerid] == 1) format(SBstring, 30, ""C_RED"Disable"C_WHITE"");
					if (Nitro[playerid] == 0) format(SBstring, 30, ""C_GREEN"Enable"C_WHITE"");
					new AutoFixString[30];
					if (AutoFix[playerid] == 1) format(AutoFixString, 30, ""C_RED"Disable"C_WHITE"");
					if (AutoFix[playerid] == 0) format(AutoFixString, 30, ""C_GREEN"Enable"C_WHITE"");
					new BounceString[30];
					if (Bounce[playerid] == 1) format(BounceString, 30, ""C_RED"Disable"C_WHITE"");
					if (Bounce[playerid] == 0) format(BounceString, 30, ""C_GREEN"Enable"C_WHITE"");
					new AFstring[30];
					if (AntifallEnabled[playerid] == 1) format(AFstring, 30, ""C_RED"Disable"C_WHITE"");
					if (AntifallEnabled[playerid] == 0) format(AFstring, 30, ""C_GREEN"Enable"C_WHITE"");
					new WeaponSetString[30];
					if (PlayerInfo[playerid][WeaponSet] == 0) format(WeaponSetString, 30, ""ORANGE"Standard"C_WHITE"");
					if (PlayerInfo[playerid][WeaponSet] == 1) format(WeaponSetString, 30, ""ORANGE"Advanced"C_WHITE"");
					if (PlayerInfo[playerid][WeaponSet] == 2) format(WeaponSetString, 30, ""ORANGE"Expert"C_WHITE"");
					format(string, 300, "Speedboost (%s)\nAuto Repair (%s)\nBounce (%s)\nAntifall (%s)\nWeapon Set (%s)", SBstring, AutoFixString, BounceString, AFstring, WeaponSetString);
					ShowPlayerDialog(playerid, DIALOG_SETTINGS, DIALOG_STYLE_LIST, ""REDORANGE">> "C_WHITE"Account Settings", string, "OK", "Cancel");
				}
				case 4:
				{
					ShowPlayerDialog( playerid, WEAPONS, DIALOG_STYLE_LIST, "{58C8ED}Weapon Set", ""ORANGE"Standard Weapon Set {33AA33}($100k)\n"ORANGE"Advanced Weapon Set {33AA33}($250k)\n"ORANGE"Expert Weapon Set {33AA33}($500k)", "Select", "Cancel" );
				}
			}
		}
	}
	new string[400], _tmpstring[256], INI:file, filename[HOUSEFILE_LENGTH], h = GetPVarInt(playerid, "LastHouseCP"), amount = floatround(strval(inputtext));
    format(filename, sizeof(filename), FILEPATH, h);
	if(dialogid == HOUSEMENU && response)
	{
	    switch(listitem)
		{
		    case 0: ShowPlayerDialog(playerid, HOUSEMENU+19, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Set House For Sale\nCancel Active House Sale\nSell House", "Select", "Cancel");
		    case 1:
			{
				#if GH_USE_HOUSESTORAGE == false
					ShowInfoBoxEx(playerid, COLOUR_INFO, E_NO_HOUSESTORAGE);
				#else
					#if GH_USE_WEAPONSTORAGE == true
						ShowPlayerDialog(playerid, HOUSEMENU+18, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Money Storage\nWeapon Storage", "Select", "Cancel");
					#else
						ShowPlayerDialog(playerid, HOUSEMENU+10, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Deposit Money\nWithdraw Money\nCheck Balance", "Select", "Cancel");
					#endif
				#endif
			}
			case 2: ShowPlayerDialog(playerid, HOUSEMENU+14, DIALOG_STYLE_INPUT, INFORMATION_HEADER, "Type In The New House Name Below:\n\nPress 'Cancel' To Cancel", "Done", "Cancel");
		    case 3: ShowPlayerDialog(playerid, HOUSEMENU+13, DIALOG_STYLE_INPUT, INFORMATION_HEADER, "Type In The New House Password Below:\nLeave The Box Empty If You Want To Keep Your Current House Password.\nPress 'Remove' To Remove The House Password.", "Done", "Remove");
			case 4:
		 	{
				#if GH_HINTERIOR_UPGRADE == true
		 			ShowPlayerDialog(playerid, HOUSEMENU+16, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Preview House Interior\nBuy House Interior", "Select", "Cancel");
				#else
                	ShowPlayerDialog(playerid, HOUSEMENU+24, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Open House For Visitors\nClose House For Visitors", "Select", "Cancel");
				#endif
			}
			case 5:
			{
			    #if GH_HINTERIOR_UPGRADE == true
					ShowPlayerDialog(playerid, HOUSEMENU+24, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Open House For Visitors\nClose House For Visitors", "Select", "Cancel");
				#else
				new tmpcount = 1, total = (CountPlayersInHouse(h) - 1);
				if(CountPlayersInHouse(h) == 0) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_NONE_IN_HOUSE);
				CMDSString = "";
				foreach(Player, i)
				{
				    if(!IsPlayerInHouse(i, h)) continue;
				    if(playerid == i) continue;
					if(tmpcount == total)
					{
					    format(_tmpstring, sizeof(_tmpstring), "{00BC00}%d.\t{FFFF2A}%s in %s", tmpcount, pNick(i), i);
					}
					else format(_tmpstring, sizeof(_tmpstring), "{00BC00}%d.\t{FFFF2A}%s (%d)\n", tmpcount, pNick(i), i);
					strcat(CMDSString, _tmpstring);
					tmpcount++;
				}
				ShowPlayerDialog(playerid, HOUSEMENU+25, DIALOG_STYLE_LIST, INFORMATION_HEADER, CMDSString, "Select", "Cancel");
				#endif
			}
			case 6:
			{
			    #if GH_HINTERIOR_UPGRADE == true
				new tmpcount = 1, total = (CountPlayersInHouse(h) - 1);
				if(CountPlayersInHouse(h) == 0) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_NONE_IN_HOUSE);
				CMDSString = "";
				foreach(Player, i)
				{
				    if(!IsPlayerInHouse(i, h)) continue;
				    if(playerid == i) continue;
					if(tmpcount == total)
					{
					    format(_tmpstring, sizeof(_tmpstring), "{00BC00}%d.\t{FFFF2A}%s in %s", tmpcount, pNick(i), i);
					}
					else format(_tmpstring, sizeof(_tmpstring), "{00BC00}%d.\t{FFFF2A}%s (%d)\n", tmpcount, pNick(i), i);
					strcat(CMDSString, _tmpstring);
					tmpcount++;
				}
				ShowPlayerDialog(playerid, HOUSEMENU+25, DIALOG_STYLE_LIST, INFORMATION_HEADER, CMDSString, "Select", "Cancel");
				#else
                	ShowPlayerDialog(playerid, HOUSEMENU+27, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Buy House Alarm\t\t$"#HUPGRADE_ALARM"\nBuy Security Camera\t\t$"#HUPGRADE_CAMERA"\nBuy House Security Dog\t$"#HUPGRADE_DOG"\nBuy Better Houselock\t\t$"#HUPGRADE_UPGRADED_HLOCK"", "Select", "Cancel");
				#endif
			}
			case 7: ShowPlayerDialog(playerid, HOUSEMENU+27, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Buy House Alarm\t\t$"#HUPGRADE_ALARM"\nBuy Security Camera\t\t$"#HUPGRADE_CAMERA"\nBuy House Security Dog\t$"#HUPGRADE_DOG"\nBuy Better Houselock\t\t$"#HUPGRADE_UPGRADED_HLOCK"", "Select", "Cancel");
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                               House Sale
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+3 && response)
	{
		if(GetOwnedHouses(playerid) == 0) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_NO_HOUSES_OWNED);
		else
		{
		    new procent = ReturnProcent(hInfo[h][HouseValue], HOUSE_SELLING_PROCENT);
			GivePlayerMoneyEx(playerid, procent);
			if(hInfo[h][HouseStorage] >= 1)
			{
			    CMDSString = "";
				format(_tmpstring, sizeof(_tmpstring), I_SELL_HOUSE1_1, procent);
				strcat(CMDSString, _tmpstring);
				format(_tmpstring, sizeof(_tmpstring), I_SELL_HOUSE1_2, (hInfo[h][HouseValue] - procent), hInfo[h][HouseStorage]);
				strcat(CMDSString, _tmpstring);
   				ShowInfoBoxEx(playerid, COLOUR_INFO, CMDSString);
				GivePlayerMoneyEx(playerid, hInfo[h][HouseStorage]);
			}
			if(hInfo[h][HouseStorage] == 0)
			{
			    ShowInfoBox(playerid, I_SELL_HOUSE2, hInfo[h][HouseName], procent, (hInfo[h][HouseValue] - procent));
			}
			format(hInfo[h][HouseName], MAX_HOUSE_NAME, "%s", DEFAULT_HOUSE_NAME);
   			format(hInfo[h][HouseOwner], MAX_PLAYER_NAME, "%s", INVALID_HOWNER_NAME);
		    hInfo[h][HousePassword] = udb_hash("INVALID_HOUSE_PASSWORD");
		    hInfo[h][HouseStorage] = hInfo[h][HouseAlarm] = hInfo[h][HouseDog] = hInfo[h][HouseCamera] = hInfo[h][UpgradedLock] = 0;
		    hInfo[h][HouseValue] = ReturnProcent(hInfo[h][HouseValue], HOUSE_SELLING_PROCENT);
			file = INI_Open(filename);
			INI_WriteInt(file, "HouseValue", hInfo[h][HouseValue]);
			INI_WriteString(file, "HouseOwner", INVALID_HOWNER_NAME);
			INI_WriteInt(file, "HousePassword", hInfo[h][HousePassword]);
			INI_WriteString(file, "HouseName", DEFAULT_HOUSE_NAME);
			INI_WriteInt(file, "HouseStorage", 0);
			INI_Close(file);
			foreach(Houses, h2)
			{
				if(IsHouseInRangeOfHouse(h, h2, RANGE_BETWEEN_HOUSES) && h2 != h)
				{
			   		hInfo[h2][HouseValue] = (hInfo[h2][HouseValue] - ReturnProcent(hInfo[h2][HouseValue], HOUSE_SELLING_PROCENT2));
			   		file = INI_Open(HouseFile(h2));
					INI_WriteInt(file, "HouseValue", hInfo[h2][HouseValue]);
					INI_Close(file);
                    UpdateHouseText(h2);
				}
			}
			foreach(Player, i)
			{
			    if(IsPlayerInHouse(i, h))
			    {
			        ExitHouse(i, h);
					ShowInfoBoxEx(i, COLOUR_INFO, I_TO_PLAYERS_HSOLD);
			    }
			}
			#if GH_USE_MAPICONS == true
				DestroyDynamicMapIcon(HouseMIcon[h]);
				HouseMIcon[h] = CreateDynamicMapIcon(hInfo[h][CPOutX], hInfo[h][CPOutY], hInfo[h][CPOutZ], 31, -1, hInfo[h][SpawnWorld], hInfo[h][SpawnInterior], -1, MICON_VD);
			#endif
			UpdateHouseText(h);
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                               House Buying
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+4)
	{
		if(response)
		{
		    new hname[MAX_PLAYER_NAME+9];
			if(GetOwnedHouses(playerid) >= MAX_HOUSES_OWNED) { ShowInfoBox(playerid, E_MAX_HOUSES_OWNED, MAX_HOUSES_OWNED, AddS(MAX_HOUSES_OWNED)); return 1; }
			if(strcmp(hInfo[h][HouseOwner], pNick(playerid), CASE_SENSETIVE) && strcmp(hInfo[h][HouseOwner], INVALID_HOWNER_NAME, CASE_SENSETIVE)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_H_ALREADY_OWNED);
			if(hInfo[h][HouseValue] > GetPlayerMoneyEx(playerid)) { ShowInfoBox(playerid, E_CANT_AFFORD_HOUSE, hInfo[h][HouseValue], GetPlayerMoneyEx(playerid), (hInfo[h][HouseValue] - GetPlayerMoneyEx(playerid))); return 1; }
			else
			{
			    format(hname, sizeof(hname), "%s's House", pNick(playerid));
			    format(hInfo[h][HouseName], sizeof(hname), "%s", hname);
			    format(hInfo[h][HouseOwner], MAX_PLAYER_NAME, "%s", pNick(playerid));
			    hInfo[h][HousePassword] = udb_hash("INVALID_HOUSE_PASSWORD");
			    hInfo[h][HouseStorage] = 0;
				GivePlayerMoneyEx(playerid, -hInfo[h][HouseValue]);
				file = INI_Open(filename);
				INI_WriteString(file, "HouseOwner", pNick(playerid));
				INI_WriteInt(file, "HousePassword", hInfo[h][HousePassword]);
				INI_WriteString(file, "HouseName", hname);
				INI_WriteInt(file, "HouseStorage", 0);
				INI_Close(file);
				ShowInfoBox(playerid, I_BUY_HOUSE, hInfo[h][HouseValue]);
				foreach(Houses, h2)
				{
					if(IsHouseInRangeOfHouse(h, h2, RANGE_BETWEEN_HOUSES) && h2 != h)
					{
					    file = INI_Open(HouseFile(h2));
						INI_WriteInt(file, "HouseValue", (hInfo[h2][HouseValue] + ReturnProcent(hInfo[h2][HouseValue], HOUSE_SELLING_PROCENT2)));
                        UpdateHouseText(h2);
                        INI_Close(file);
					}
				}
				#if GH_USE_MAPICONS == true
					DestroyDynamicMapIcon(HouseMIcon[h]);
					HouseMIcon[h] = CreateDynamicMapIcon(hInfo[h][CPOutX], hInfo[h][CPOutY], hInfo[h][CPOutZ], 32, -1, hInfo[h][SpawnWorld], hInfo[h][SpawnInterior], -1, MICON_VD);
				#endif
				UpdateHouseText(h);
			}
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                               House Password
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+13)
	{
		if(response)
		{
			if(strlen(inputtext) > MAX_HOUSE_PASSWORD || (strlen(inputtext) < MIN_HOUSE_PASSWORD && strlen(inputtext) >= 1)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HPASS_LENGTH);
			if(!strcmp(inputtext, "INVALID_HOUSE_PASSWORD", CASE_SENSETIVE)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HPASS);
			if(strfind(inputtext, "%", CASE_SENSETIVE) != -1 || strfind(inputtext, "~", CASE_SENSETIVE) != -1) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HPASS_CHARS);
			else
			{
			    if(strlen(inputtext) >= 1)
			    {
			        hInfo[h][HousePassword] = udb_hash(inputtext);
			        file = INI_Open(filename);
					INI_WriteInt(file, "HousePassword", hInfo[h][HousePassword]);
					INI_Close(file);
					ShowInfoBox(playerid, I_HPASSWORD_CHANGED, inputtext);
				}
				else ShowInfoBoxEx(playerid, COLOUR_INFO, I_HPASS_NO_CHANGE);
			}
		}
		if(!response)
		{
		    file = INI_Open(filename);
		    INI_WriteInt(file, "HousePassword", udb_hash("INVALID_HOUSE_PASSWORD"));
		    INI_Close(file);
			ShowInfoBoxEx(playerid, COLOUR_INFO, I_HPASS_REMOVED);
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                               House Name
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+14)
	{
		if(response)
		{
		    if(strfind(inputtext, "%", CASE_SENSETIVE) != -1 || strfind(inputtext, "~", CASE_SENSETIVE) != -1) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HNAME_CHARS);
			if(strlen(inputtext) < MIN_HOUSE_NAME || strlen(inputtext) > MAX_HOUSE_NAME) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HNAME_LENGTH);
			else
			{
			    format(hInfo[h][HouseName], MAX_HOUSE_NAME, "%s", inputtext);
			    file = INI_Open(filename);
				INI_WriteString(file, "HouseName", inputtext);
				INI_Close(file);
				ShowInfoBox(playerid, I_HNAME_CHANGED, inputtext);
                UpdateHouseText(h);
			}
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                       House Interior Upgrade
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+15 && response)
	{
	    new _int = hInfo[h][HouseInterior];
	    SetPVarInt(playerid, "OldHouseInt", _int);
	    Loop(hint, MAX_HOUSE_INTERIORS, 0)
		{
		    if(hint == listitem)
		    {
		        SetPVarInt(playerid, "HousePrevInt", hint), SetPVarInt(playerid, "HousePrevValue", hIntInfo[hint][IntValue]), SetPVarString(playerid, "HousePrevName", hIntInfo[hint][IntName]);
		    }
		}
		if(_int == GetPVarInt(playerid, "HousePrevInt")) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_ALREADY_HAVE_HINTERIOR);
		else
		{
		    new hprevvalue = GetPVarInt(playerid, "HousePrevValue");
		    GetPVarString(playerid, "HousePrevName", string, 50);
//------------------------------------------------------------------------------
		    switch(GetPVarInt(playerid, "HouseIntUpgradeMod"))
		    {
				case 1:
				{
				    if(GetSecondsBetweenAction(GetPVarInt(playerid, "HousePrevTime")) < (TIME_BETWEEN_VISITS * 60000) && GetPVarInt(playerid, "HousePrevTime") != 0) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_HINT_WAIT_BEFORE_VISITING);
				    SetPVarInt(playerid, "IsHouseVisiting", 1);
					SetPVarInt(playerid, "HousePreview", 1);
					SetPVarInt(playerid, "ChangeHouseInt", 1);
					SetPVarInt(playerid, "HousePrevTime", GetTickCount());
					SetPVarInt(playerid, "HousePrevTimer", SetTimerEx("HouseVisiting", (MAX_VISIT_TIME * 60000), false, "i", playerid));
					ShowInfoBox(playerid, I_VISITING_HOUSEINT, string, hprevvalue, MAX_VISIT_TIME, AddS(MAX_VISIT_TIME));

				}
				case 2:
				{
					if(hprevvalue > GetPlayerMoneyEx(playerid))
					{
					    CMDSString = "";
						format(_tmpstring, sizeof(_tmpstring), E_CANT_AFFORD_HINT1, string, hprevvalue);
						strcat(CMDSString, _tmpstring);
						format(_tmpstring, sizeof(_tmpstring), E_CANT_AFFORD_HINT2, GetPlayerMoneyEx(playerid), (hprevvalue - GetPlayerMoneyEx(playerid)));
						strcat(CMDSString, _tmpstring);
						ShowInfoBoxEx(playerid, COLOUR_INFO, CMDSString);
					}
					if(hprevvalue <= GetPlayerMoneyEx(playerid))
					{
					    GivePlayerMoneyEx(playerid, -hprevvalue);
					    SetPVarInt(playerid, "ChangeHouseInt", 1);
    	    			file = INI_Open(filename);
					    INI_Close(file);
						ShowInfoBox(playerid, I_HINT_BOUGHT, string, hprevvalue);
					}
				}
			}
//------------------------------------------------------------------------------
			if(GetPVarInt(playerid, "ChangeHouseInt") == 1)
		    {
		        hInfo[h][HouseInterior] = GetPVarInt(playerid, "HousePrevInt");
 	    		file = INI_Open(filename);
			    INI_WriteInt(file, "HouseInterior", hInfo[h][HouseInterior]);
			    INI_Close(file);
			    DestroyHouseEntrance(h, TYPE_INT);
				CreateCorrectHouseExitCP(h);
				foreach(Player, i)
		  		{
		  		    if(GetPVarInt(i, "LastHouseCP") == h && IsInHouse{i} == 1)
		  		    {
		  				SetPlayerHouseInterior(i, h);
		  			}
		  		}
		  		DeletePVar(playerid, "ChangeHouseInt");
	  		}
//------------------------------------------------------------------------------
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                       House Interior Mode Selecting
//------------------------------------------------------------------------------
    #if GH_HINTERIOR_UPGRADE == true
	if(dialogid == HOUSEMENU+16 && response)
	{
	    switch(listitem)
	    {
	        case 0: SetPVarInt(playerid, "HouseIntUpgradeMod", 1);
	        case 1: SetPVarInt(playerid, "HouseIntUpgradeMod", 2);
	    }
	    CMDSString = "";
	    Loop(i, MAX_HOUSE_INTERIORS, 0)
	    {
	        format(filename, sizeof(filename), HINT_FILEPATH, i);
	        if(!fexist(filename)) continue;
			if(i == (MAX_HOUSE_INTERIORS-1))
			{
			    switch(strlen(hIntInfo[i][IntName]))
			    {
					case 0..13: format(_tmpstring, sizeof(_tmpstring), "{00BC00}%d.\t{FFFF2A}%s\t\t\t{00BC00}$%d", (i + 1), hIntInfo[i][IntName], hIntInfo[i][IntValue]);
					default: format(_tmpstring, sizeof(_tmpstring), "{00BC00}%d.\t{FFFF2A}%s\t\t{00BC00}$%d", (i + 1), hIntInfo[i][IntName], hIntInfo[i][IntValue]);
				}
			}
			else
			{
			    switch(strlen(hIntInfo[i][IntName]))
			    {
					case 0..13: format(_tmpstring, sizeof(_tmpstring), "{00BC00}%d.\t{FFFF2A}%s\t\t\t{00BC00}$%d\n", (i + 1), hIntInfo[i][IntName], hIntInfo[i][IntValue]);
					default: format(_tmpstring, sizeof(_tmpstring), "{00BC00}%d.\t{FFFF2A}%s\t\t{00BC00}$%d\n", (i + 1), hIntInfo[i][IntName], hIntInfo[i][IntValue]);
				}
			}
			strcat(CMDSString, _tmpstring);
	    }
		ShowPlayerDialog(playerid, HOUSEMENU+15, DIALOG_STYLE_LIST, INFORMATION_HEADER, CMDSString, "Buy", "Cancel");
		return 1;
	}
	#endif
//------------------------------------------------------------------------------
//                       House Interior Upgrade
//------------------------------------------------------------------------------
    #if GH_HINTERIOR_UPGRADE == true
	if(dialogid == HOUSEMENU+17)
	{
	    KillTimer(GetPVarInt(playerid, "HousePrevTimer"));
	    DeletePVar(playerid, "IsHouseVisiting"), DeletePVar(playerid, "HousePrevTimer");
	    file = INI_Open(filename);
	    switch(response)
	    {
	        case 0:
			{
			    hInfo[h][HouseInterior] = GetPVarInt(playerid, "OldHouseInt");
			    INI_WriteInt(file, "HouseInterior", hInfo[h][HouseInterior]);
			}
	        case 1:
	        {
	            new hprevvalue = GetPVarInt(playerid, "HousePrevValue");
	            GetPVarString(playerid, "HousePrevName", string, 50);
	            if(GetPlayerMoneyEx(playerid) < GetPVarInt(playerid, "HousePrevValue"))
	            {
	                hInfo[h][HouseInterior] = GetPVarInt(playerid, "OldHouseInt");
	                INI_WriteInt(file, "HouseInterior", hInfo[h][HouseInterior]);
	                CMDSString = "";
					format(_tmpstring, sizeof(_tmpstring), E_CANT_AFFORD_HINT1, string, hprevvalue);
					strcat(CMDSString, _tmpstring);
					format(_tmpstring, sizeof(_tmpstring), E_CANT_AFFORD_HINT2, GetPlayerMoneyEx(playerid), (hprevvalue - GetPlayerMoneyEx(playerid)));
					strcat(CMDSString, _tmpstring);
					ShowInfoBoxEx(playerid, COLOUR_INFO, CMDSString);
				}
				else
				{
	            	GivePlayerMoneyEx(playerid, -hprevvalue);
	            	hInfo[h][HouseInterior] = GetPVarInt(playerid, "HousePrevInt");
	            	INI_WriteString(file, "HouseInteriorName", string);
			    	INI_WriteInt(file, "HouseInterior", hInfo[h][HouseInterior]);
			    	INI_WriteInt(file, "HouseInteriorValue", hprevvalue);
	            	ShowInfoBox(playerid, I_HINT_BOUGHT, string, hprevvalue);
				}
			}
	    }
	    INI_Close(file);
//------------------------------------------------------------------------------
  		DestroyHouseEntrance(h, TYPE_INT);
		CreateCorrectHouseExitCP(h);
		foreach(Player, i)
		{
  			if(GetPVarInt(i, "LastHouseCP") == h && IsInHouse{i} == 1)
  			{
				SetPlayerHouseInterior(i, h);
			}
		}
		SetPVarInt(playerid, "HousePreview", 0);
//------------------------------------------------------------------------------
		return 1;
	}
	#endif
//------------------------------------------------------------------------------
//                               Money Storage
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+10 && response)
	{
    	if(listitem == 0) // Deposit
	   	{
     		format(string, sizeof(string), I_HINT_DEPOSIT1, hInfo[h][HouseStorage]);
  			ShowPlayerDialog(playerid, HOUSEMENU+11, DIALOG_STYLE_INPUT, INFORMATION_HEADER, string, "Deposit", "Cancel");
	    }
	    if(listitem == 1) // Withdraw
	    {
     		format(string, sizeof(string), I_HINT_WITHDRAW1, hInfo[h][HouseStorage]);
       		ShowPlayerDialog(playerid, HOUSEMENU+12, DIALOG_STYLE_INPUT, INFORMATION_HEADER, string, "Withdraw", "Cancel");
    	}
	    if(listitem == 2) // Check Balance
	    {
     		ShowInfoBox(playerid, I_HINT_CHECKBALANCE, hInfo[h][HouseStorage]);
		}
		return 1;
	}
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+11 && response)
	{
		if(amount > GetPlayerMoneyEx(playerid)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_NOT_ENOUGH_PMONEY);
		if(amount < 1) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_AMOUNT);
		if((hInfo[h][HouseStorage] + amount) >= 25000000) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_HSTORAGE_L_REACHED);
		else
		{
		    hInfo[h][HouseStorage] = (hInfo[h][HouseStorage] + amount);
		    file = INI_Open(filename);
			INI_WriteInt(file, "HouseStorage", hInfo[h][HouseStorage]);
			INI_Close(file);
			GivePlayerMoneyEx(playerid, -amount);
			ShowInfoBox(playerid, I_HINT_DEPOSIT2, amount, hInfo[h][HouseStorage]);
		}
		return 1;
	}
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+12 && response)
	{
		if(amount > hInfo[h][HouseStorage]) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_NOT_ENOUGH_HSMONEY);
		if(amount < 1) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_AMOUNT);
		else
		{
		    hInfo[h][HouseStorage] = (hInfo[h][HouseStorage] - amount);
		    file = INI_Open(filename);
			INI_WriteInt(file, "HouseStorage", hInfo[h][HouseStorage]);
			INI_Close(file);
			GivePlayerMoneyEx(playerid, amount);
			ShowInfoBox(playerid, I_HINT_WITHDRAW2, amount, hInfo[h][HouseStorage]);
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                          House Sale
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+18 && response)
	{
		switch(listitem)
		{
		    case 0: ShowPlayerDialog(playerid, HOUSEMENU+10, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Deposit Money\nWithdraw Money\nCheck Balance", "Select", "Cancel");
		    case 1: ShowPlayerDialog(playerid, HOUSEMENU+30, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Store Your Current Weapons\nReceive House Storage Weapons", "Select", "Cancel");
		}
	}
//------------------------------------------------------------------------------
//                          Selling House
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+19 && response)
	{
  		switch(listitem)
		{
		    case 0: ShowPlayerDialog(playerid, HOUSEMENU+20, DIALOG_STYLE_INPUT, INFORMATION_HEADER, HMENU_SELL_HOUSE2, "Select", "Cancel");
		    case 1: ShowPlayerDialog(playerid, HOUSEMENU+21, DIALOG_STYLE_MSGBOX, INFORMATION_HEADER, HMENU_HSALE_CANCEL, "Remove", "Cancel");
		    case 2:
		    {
		    	format(string, sizeof(string), HMENU_SELL_HOUSE, hInfo[h][HouseName], ReturnProcent(hInfo[h][HouseValue], HOUSE_SELLING_PROCENT));
				ShowPlayerDialog(playerid, HOUSEMENU+3, DIALOG_STYLE_MSGBOX, INFORMATION_HEADER, string, "Sell", "Cancel");
			}
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                          Selling House
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+20 && response)
	{
		if(amount < MIN_HOUSE_VALUE || amount > MAX_HOUSE_VALUE) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HSELL_AMOUNT);
		else
		{
		    hInfo[h][ForSalePrice] = amount;
		    hInfo[h][ForSale] = 1;
		    file = INI_Open(filename);
			INI_WriteInt(file, "ForSale", 1);
			INI_WriteInt(file, "ForSalePrice", amount);
			INI_Close(file);
			ShowInfoBox(playerid, I_H_SET_FOR_SALE, hInfo[h][HouseName], amount);
			UpdateHouseText(h);
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                          Cancelling House Sale
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+21 && response)
	{
		if(hInfo[h][ForSale] != 1) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_H_NOT_FOR_SALE);
		else
		{
		    hInfo[h][ForSalePrice] = 0;
		    hInfo[h][ForSale] = 0;
		    file = INI_Open(filename);
			INI_WriteInt(file, "ForSale", 0);
			INI_WriteInt(file, "ForSalePrice", 0);
			INI_Close(file);
			ShowInfoBoxEx(playerid, COLOUR_INFO, HMENU_CANCEL_HOUSE_SALE);
			UpdateHouseText(h);
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                          Selecting some stuff
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+22 && response)
	{
	    if(GetPlayerMoneyEx(playerid) < hInfo[h][ForSalePrice]) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_NOT_ENOUGH_PMONEY);
	    else
	    {
			new houseowner = GetHouseOwnerEx(h);
			switch(IsPlayerConnected(houseowner))
			{
				case 0:
	   			{
	    			new filename2[50];
	       			format(filename2, sizeof(filename2), USERPATH, hInfo[h][HouseOwner]);
			        if(!fexist(filename2))
			        {
	          			fcreate(filename2);
			        }
			        file = INI_Open(filename2);
					INI_WriteInt(file, "MoneyToGive", hInfo[h][ForSalePrice]);
					INI_WriteInt(file, "MoneyToGiveHS", hInfo[h][HouseStorage]);
					INI_WriteString(file, "HouseName", hInfo[h][HouseName]);
					INI_WriteString(file, "HouseBuyer", pNick(playerid));
					INI_Close(file);
	 			}
	 			case 1:
	 			{
	 			    CMDSString = "";
					format(_tmpstring, sizeof(_tmpstring), HSELLER_CONNECTED_MSG1, hInfo[h][HouseName], pNick(playerid), playerid);
					strcat(CMDSString, _tmpstring);
					format(_tmpstring, sizeof(_tmpstring), HSELLER_CONNECTED_MSG2, (hInfo[h][HouseStorage] + hInfo[h][ForSalePrice]), hInfo[h][HouseStorage], hInfo[h][ForSalePrice]);
					strcat(CMDSString, _tmpstring);
					ShowInfoBoxEx(houseowner, COLOUR_INFO, CMDSString);
					GivePlayerMoneyEx(houseowner, (hInfo[h][ForSalePrice] + hInfo[h][HouseStorage]));
	  			}
			}
			GivePlayerMoneyEx(playerid, -hInfo[h][ForSalePrice]);
			format(hInfo[h][HouseName], MAX_HOUSE_NAME, "%s's House", pNick(playerid));
			format(hInfo[h][HouseOwner], MAX_PLAYER_NAME, "%s", pNick(playerid));
			hInfo[h][HousePassword] = udb_hash("INVALID_HOUSE_PASSWORD");
			hInfo[h][ForSale] = 0;
			hInfo[h][ForSalePrice] = 0;
	   		hInfo[h][HouseStorage] = 0;
			file = INI_Open(filename);
			INI_WriteString(file, "HouseOwner", pNick(playerid));
			INI_WriteInt(file, "HousePassword", hInfo[h][HousePassword]);
			INI_WriteString(file, "HouseName", hInfo[h][HouseName]);
			INI_WriteInt(file, "HouseStorage", 0);
			INI_WriteInt(file, "ForSale", 0);
			INI_WriteInt(file, "ForSalePrice", 0);
			INI_Close(file);
			UpdateHouseText(h);
			#if GH_USE_MAPICONS == true
				DestroyDynamicMapIcon(HouseMIcon[h]);
				HouseMIcon[h] = CreateDynamicMapIcon(hInfo[h][CPOutX], hInfo[h][CPOutY], hInfo[h][CPOutZ], 31, -1, hInfo[h][SpawnWorld], hInfo[h][SpawnInterior], -1, MICON_VD);
			#endif
			UpdateHouseText(h);
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                          Selecting some stuff
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+23 && response)
	{
		switch(listitem)
		{
		    case 0:
			{
			    format(string,sizeof(string), HSELL_BUY_DIALOG, hInfo[h][HouseOwner], hInfo[h][HouseName], hInfo[h][ForSalePrice]);
				ShowPlayerDialog(playerid, HOUSEMENU+22, DIALOG_STYLE_MSGBOX, INFORMATION_HEADER, string, "Buy", "Cancel");
			}
			case 1:
			{
			    #if GH_ALLOW_BREAKIN == false
			    	ShowInfoBoxEx(playerid, COLOUR_INFO, E_NO_HOUSE_BREAKIN);
			    #else
			    new breakintime = GetPVarInt(playerid, "TimeSinceHouseBreakin"), houseowner = GetHouseOwnerEx(h), bi_chance = random(10000);
       			if(GetSecondsBetweenAction(breakintime) < (TIME_BETWEEN_BREAKINS * 60000) && breakintime != 0) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_WAIT_BEFORE_BREAKIN);
			    SetPVarInt(playerid, "TimeSinceHouseBreakin", GetTickCount());
			    if((hInfo[h][UpgradedLock] == 0 && bi_chance < 7000) ||  (hInfo[h][UpgradedLock] == 1 && bi_chance < 9000))
			    {
			    	if(IsPlayerConnected(houseowner))
        			{
           				switch(hInfo[h][HouseCamera])
               			{
                  			case 0:
	                    	{
                       			if(hInfo[h][HouseAlarm] == 1)
	                        	{
                          			ShowInfoBox(houseowner, E_FAILED_BREAKIN1_2, hInfo[h][HouseName], hInfo[h][HouseLocation]);
                       			}
           					}
	                		case 1: ShowInfoBox(houseowner, E_FAILED_BREAKIN1_1, pNick(playerid), playerid, hInfo[h][HouseName], hInfo[h][HouseLocation]);
           				}
           			}
		            ShowInfoBox(playerid, E_FAILED_BREAKIN2, hInfo[h][HouseName], hInfo[h][HouseOwner]);
		            SecurityDog_Bite(playerid, h, 0, 1);
			    }
			    if((hInfo[h][UpgradedLock] == 0 && bi_chance >= 7000) ||  (hInfo[h][UpgradedLock] == 1 && bi_chance >= 9000))
			    {
					if(IsPlayerConnected(houseowner))
     				{
         				switch(hInfo[h][HouseCamera])
             			{
                			case 0:
           					{
                				if(hInfo[h][HouseAlarm] == 1)
			                    {
									ShowInfoBox(houseowner, I_SUCCESSFULL_BREAKIN1_2, hInfo[h][HouseName], hInfo[h][HouseLocation]);
			                    }
			                }
		                	case 1: ShowInfoBox(houseowner, I_SUCCESSFULL_BREAKIN1_1, pNick(playerid), playerid, hInfo[h][HouseName], hInfo[h][HouseLocation]);
                		}
	            	}
		            ShowInfoBox(playerid, I_SUCCESSFULL_BREAKIN2, hInfo[h][HouseName], hInfo[h][HouseOwner]);
		           	SetPlayerHouseInterior(playerid, h);
			    }
			    #if GH_GIVE_WANTEDLEVEL == true
				if((GetPlayerWantedLevel(playerid) + HBREAKIN_WL) > GH_MAX_WANTED_LEVEL)
				{
					SetPlayerWantedLevel(playerid, GH_MAX_WANTED_LEVEL);
				}
				else SetPlayerWantedLevel(playerid, (GetPlayerWantedLevel(playerid) + HBREAKIN_WL));
				#endif
			    #endif
			}
			case 2:
		    {
		        if(hInfo[h][HousePassword] != udb_hash("INVALID_HOUSE_PASSWORD"))
		        {
		            format(string, sizeof(string), HMENU_ENTER_PASS, hInfo[h][HouseName], hInfo[h][HouseOwner], hInfo[h][HouseValue], h);
 					ShowPlayerDialog(playerid, HOUSEMENU+60, DIALOG_STYLE_INPUT, INFORMATION_HEADER, string, "Enter", "Close");
    			}
    			else SetPlayerHouseInterior(playerid, h);
		    }
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                          Selecting some stuff
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+28 && response)
	{
		switch(listitem)
		{
		    case 0:
			{
			    if(hInfo[h][HousePassword] != udb_hash("INVALID_HOUSE_PASSWORD"))
		        {
		            format(string,sizeof(string), HMENU_ENTER_PASS, hInfo[h][HouseName], hInfo[h][HouseOwner], hInfo[h][HouseValue], h);
 					ShowPlayerDialog(playerid, HOUSEMENU+60, DIALOG_STYLE_INPUT, INFORMATION_HEADER, string, "Enter", "Close");
    			}
			}
			case 1:
			{
			    #if GH_ALLOW_BREAKIN == false
			    	ShowInfoBoxEx(playerid, COLOUR_INFO, E_NO_HOUSE_BREAKIN);
			    #else
			    new breakintime = GetPVarInt(playerid, "TimeSinceHouseBreakin"), houseowner = GetHouseOwnerEx(h), bi_chance = random(10000);
       			if(GetSecondsBetweenAction(breakintime) < (TIME_BETWEEN_BREAKINS * 60000) && breakintime != 0) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_WAIT_BEFORE_BREAKIN);
			    SetPVarInt(playerid, "TimeSinceHouseBreakin", GetTickCount());
			    if((hInfo[h][UpgradedLock] == 0 && bi_chance < 7000) ||  (hInfo[h][UpgradedLock] == 1 && bi_chance < 9000))
			    {
			    	if(IsPlayerConnected(houseowner))
        			{
           				switch(hInfo[h][HouseCamera])
               			{
                  			case 0:
	                    	{
                       			if(hInfo[h][HouseAlarm] == 1)
	                        	{
                          			ShowInfoBox(houseowner, E_FAILED_BREAKIN1_2, hInfo[h][HouseName], hInfo[h][HouseLocation]);
                       			}
           					}
	                		case 1: ShowInfoBox(houseowner, E_FAILED_BREAKIN1_1, pNick(playerid), playerid, hInfo[h][HouseName], hInfo[h][HouseLocation]);
           				}
           			}
		            ShowInfoBox(playerid, E_FAILED_BREAKIN2, hInfo[h][HouseName], hInfo[h][HouseOwner]);
		            SecurityDog_Bite(playerid, h, 0, 1);
			    }
			    if((hInfo[h][UpgradedLock] == 0 && bi_chance >= 7000) ||  (hInfo[h][UpgradedLock] == 1 && bi_chance >= 9000))
			    {
					if(IsPlayerConnected(houseowner))
     				{
         				switch(hInfo[h][HouseCamera])
             			{
                			case 0:
           					{
                				if(hInfo[h][HouseAlarm] == 1)
			                    {
									ShowInfoBox(houseowner, I_SUCCESSFULL_BREAKIN1_2, hInfo[h][HouseName], hInfo[h][HouseLocation]);
			                    }
			                }
		                	case 1: ShowInfoBox(houseowner, I_SUCCESSFULL_BREAKIN1_1, pNick(playerid), playerid, hInfo[h][HouseName], hInfo[h][HouseLocation]);
                		}
	            	}
		            ShowInfoBox(playerid, I_SUCCESSFULL_BREAKIN2, hInfo[h][HouseName], hInfo[h][HouseOwner]);
		           	SetPlayerHouseInterior(playerid, h);
			    }
			    #if GH_GIVE_WANTEDLEVEL == true
				if((GetPlayerWantedLevel(playerid) + HBREAKIN_WL) > GH_MAX_WANTED_LEVEL)
				{
					SetPlayerWantedLevel(playerid, GH_MAX_WANTED_LEVEL);
				}
				else SetPlayerWantedLevel(playerid, (GetPlayerWantedLevel(playerid) + HBREAKIN_WL));
				#endif
			    #endif
			}
		    case 2: SetPlayerHouseInterior(playerid, h);
		}
		return 1;
	}
//------------------------------------------------------------------------------
//                          House Privacy
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+24 && response)
	{
		switch(listitem)
		{
		    case 0: // Open
			{
			    hInfo[h][HousePrivacy] = 1;
			    file = INI_Open(filename);
			    INI_WriteInt(file, "HousePrivacy", 1);
			    INI_Close(file);
			    ShowInfoBoxEx(playerid, COLOUR_INFO, I_HOPEN_FOR_VISITORS);
			}
			case 1: // Closed
		    {
		        new count;
		        hInfo[h][HousePrivacy] = 0;
			    file = INI_Open(filename);
			    INI_WriteInt(file, "HousePrivacy", 0);
			    INI_Close(file);
		      	foreach(Player, i)
				{
				    if(i == playerid) continue;
		  			if(GetPVarInt(i, "LastHouseCP") == h && IsInHouse{i} == 1)
		  			{
						ExitHouse(i, GetPVarInt(i, "LastHouseCP"));
						ShowInfoBox(playerid, I_CLOSED_FOR_VISITORS2 , pNick(playerid), playerid);
						count++;
					}
				}
                ShowInfoBox(playerid, I_CLOSED_FOR_VISITORS1, count);
		    }
		}
		UpdateHouseText(h);
		return 1;
	}
//------------------------------------------------------------------------------
//                          Player Selecting - Part 1
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+25 && response)
	{
	    new tmpcount;
		foreach(Player, i)
		{
  			if(!IsPlayerInHouse(i, h)) continue;
	    	if(playerid == i) continue;
	    	if(listitem == tmpcount)
	    	{
	    	    SetPVarInt(playerid, "ClickedPlayer", i);
	    	    break;
	    	}
	    	tmpcount++;
		}
		ShowPlayerDialog(playerid, HOUSEMENU+26, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Kick Out From House\nGive House Key\nTake House Key", "Select", "Cancel");
		return 1;
	}
//------------------------------------------------------------------------------
//                         Player Selecting - Part 2
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+26 && response)
	{
	    new clickedplayer = GetPVarInt(playerid, "ClickedPlayer"), _temp_[17];
	    switch(listitem)
	    {
	        case 0:
			{
			    if(!IsPlayerInHouse(clickedplayer, h)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_KICKED_NOT_IN_HOUSE);
			    ExitHouse(clickedplayer, h);
			    ShowInfoBox(playerid, I_KICKED_FROM_HOUSE1, pNick(clickedplayer), clickedplayer);
			    ShowInfoBox(clickedplayer, I_KICKED_FROM_HOUSE2, pNick(playerid), playerid);
			}
	        case 1:
			{
			    format(_temp_, sizeof(_temp_), "HouseKeys_%d", h);
			    if(GetPVarInt(clickedplayer, _temp_) == 1)  return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_ALREADY_HAVE_HOUSEKEYS);
			    SetPVarInt(clickedplayer, _temp_, 1);
			    ShowInfoBox(playerid, I_HOUSEKEYS_RECIEVED_1, pNick(clickedplayer), clickedplayer);
			    ShowInfoBox(clickedplayer, I_HOUSEKEYS_RECIEVED_2, hInfo[h][HouseName], hInfo[h][HouseLocation], pNick(playerid), playerid);
	        }
	        case 2:
	        {
			    format(_temp_, sizeof(_temp_), "HouseKeys_%d", h);
			    if(GetPVarInt(clickedplayer, _temp_) == 0)  return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_DOESNT_HAVE_HOUSEKEYS);
			    DeletePVar(clickedplayer, _temp_);
			    ShowInfoBox(playerid, I_HOUSEKEYS_TAKEN_1, pNick(clickedplayer), clickedplayer);
			    ShowInfoBox(clickedplayer, I_HOUSEKEYS_TAKEN_2, pNick(playerid), playerid, hInfo[h][HouseName], hInfo[h][HouseLocation]);
	        }
	    }
		return 1;
	}
//------------------------------------------------------------------------------
//                         House Security
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+27 && response)
	{
		file = INI_Open(filename);
	    switch(listitem)
	    {
	        case 0: // House Alarm
	        {
	            if(hInfo[h][HouseAlarm] == 1) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_ALREADY_HAVE_ALARM);
	            if(GetPlayerMoneyEx(playerid) < HUPGRADE_ALARM) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_NOT_ENOUGH_MONEY_ALARM);
	            GivePlayerMoneyEx(playerid, -HUPGRADE_ALARM);
	            hInfo[h][HouseAlarm] = 1;
	            INI_WriteInt(file, "HouseAlarm", 1);
	            ShowInfoBoxEx(playerid, COLOUR_INFO, I_HUPGRADE_ALARM);
	        }
			case 1: // Security Camera
			{
			    if(hInfo[h][HouseCamera] == 1) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_ALREADY_HAVE_CAMERA);
			    if(GetPlayerMoneyEx(playerid) < HUPGRADE_CAMERA) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_NOT_ENOUGH_MONEY_CAMERA);
			    GivePlayerMoneyEx(playerid, -HUPGRADE_CAMERA);
			    hInfo[h][HouseCamera] = 1;
			    INI_WriteInt(file, "HouseCamera", 1);
			    ShowInfoBoxEx(playerid, COLOUR_INFO, I_HUPGRADE_CAMERA);
	        }
			case 2: // House Security Dog
			{
			    if(hInfo[h][HouseDog] == 1) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_ALREADY_HAVE_DOG);
			    if(GetPlayerMoneyEx(playerid) < HUPGRADE_DOG) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_NOT_ENOUGH_MONEY_DOG);
			    GivePlayerMoneyEx(playerid, -HUPGRADE_DOG);
			    hInfo[h][HouseDog] = 1;
			    INI_WriteInt(file, "HouseDog", 1);
			    ShowInfoBoxEx(playerid, COLOUR_INFO, I_HUPGRADE_DOG);
	        }
			case 3: // Better Houselock
			{
			    if(hInfo[h][UpgradedLock] == 1) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_ALREADY_HAVE_UPGRADED_HLOCK);
			    if(GetPlayerMoneyEx(playerid) < HUPGRADE_UPGRADED_HLOCK) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_NOT_ENOUGH_MONEY_UPGRADED_HLOCK);
			    GivePlayerMoneyEx(playerid, -HUPGRADE_UPGRADED_HLOCK);
			    hInfo[h][UpgradedLock] = 1;
			    INI_WriteInt(file, "HouseUpgradedLock", 1);
			    ShowInfoBoxEx(playerid, COLOUR_INFO, I_HUPGRADE_UPGRADED_HLOCK);
	        }
	    }
	    INI_Close(file);
		return 1;
	}
//------------------------------------------------------------------------------
//                          Weapon Storage
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+30 && response)
	{
	    new tmp[9], tmp2[13], tmpcount;
		switch(listitem)
		{
		    case 0: // Store weapons
		    {
		        file = INI_Open(filename);
				Loop(weap, 14, 1)
				{
				    format(tmp, sizeof(tmp), "Weapon%d", weap);
  					format(tmp2, sizeof(tmp2), "Weapon%dAmmo", weap);
				    #if GH_SAVE_ADMINWEPS == false
				    if(weap == 7 || weap == 8 || weap == 9 || weap == 12) continue;
				    #endif
				    GetPlayerWeaponData(playerid, weap, hInfo[h][Weapon][weap], hInfo[h][Ammo][weap]);
				    if(hInfo[h][Ammo][weap] < 1 || (weap == 11 && hInfo[h][Weapon][weap] != 46)) continue;
					INI_WriteInt(file, tmp, hInfo[h][Weapon][weap]);
					INI_WriteInt(file, tmp2, hInfo[h][Ammo][weap]);
					GivePlayerWeapon(playerid, hInfo[h][Weapon][weap], -hInfo[h][Ammo][weap]);
					tmpcount++;
				}
				INI_Close(file);
				switch(tmpcount)
				{
				    case 0: ShowInfoBox(playerid, E_NO_WEAPONS, tmpcount);
				    default: ShowInfoBox(playerid, I_HS_WEAPONS1, tmpcount, AddS(tmpcount));
				}
			}
			case 1: // Receive Weapons
			{
			    file = INI_Open(filename);
				Loop(weap, 14, 1)
				{
				    format(tmp, sizeof(tmp), "Weapon%d", weap);
  					format(tmp2, sizeof(tmp2), "Weapon%dAmmo", weap);
  					if(hInfo[h][Ammo][weap] < 1) continue;
				    #if GH_SAVE_ADMINWEPS == false
				    if(weap == 7 || weap == 8 || weap == 9 || weap == 11 || weap == 12) continue;
				    #endif
					GivePlayerWeapon(playerid, hInfo[h][Weapon][weap], hInfo[h][Ammo][weap]);
					INI_WriteInt(file, tmp, 0);
					INI_WriteInt(file, tmp2, 0);
					tmpcount++;
				}
				INI_Close(file);
				switch(tmpcount)
				{
				    case 0: ShowInfoBoxEx(playerid, COLOUR_INFO, E_NO_HS_WEAPONS);
				    default: ShowInfoBox(playerid, I_HS_WEAPONS2, tmpcount, AddS(tmpcount));
				}
			}
		}
	}
//------------------------------------------------------------------------------
//                       /myhouse House Selecting - Part 1
//------------------------------------------------------------------------------
	if(dialogid == (HOUSEMENU+50) && response)
	{
	    SetPVarInt(playerid, "ClickedHouse", ReturnPlayerHouseID(playerid, (listitem + 1)));
	    #if GH_ALLOW_HOUSETELEPORT == true
        	ShowPlayerDialog(playerid, HOUSEMENU+51, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Show Information\nTeleport To This House", "Select", "Cancel");
        #else
        	ShowPlayerDialog(playerid, HOUSEMENU+51, DIALOG_STYLE_LIST, INFORMATION_HEADER, "Show Information", "Select", "Cancel");
        #endif
        return 1;
	}
//------------------------------------------------------------------------------
//                          /myhouse House Selecting - Part 2
//------------------------------------------------------------------------------
	if(dialogid == (HOUSEMENU+51) && response)
	{
	    new _h = GetPVarInt(playerid, "ClickedHouse");
	    switch(listitem)
	    {
			case 0:
			{
                GetPlayerPos(playerid, X, Y, Z);
			    CMDSString = "";
			    format(_tmpstring, sizeof(_tmpstring), I_HOWNER_HINFO_1, hInfo[_h][HouseName], hInfo[_h][HouseLocation], DistanceToPoint(X, Y, Z, hInfo[h][CPOutX], hInfo[h][CPOutY], hInfo[h][CPOutZ]));
			    strcat(CMDSString, _tmpstring);
				format(_tmpstring, sizeof(_tmpstring), I_HOWNER_HINFO_2, hInfo[_h][HouseValue], hInfo[_h][HouseStorage], Answer(hInfo[_h][HousePrivacy], "Open For Public", "Closed For Public"), _h);
                strcat(CMDSString, _tmpstring);
				ShowInfoBoxEx(playerid, COLOUR_INFO, CMDSString);
			}
			case 1: SetPlayerHouseInterior(playerid, _h);
	    }
	    return 1;
	}
//------------------------------------------------------------------------------
//                          Enter House Using Password
//------------------------------------------------------------------------------
	if(dialogid == HOUSEMENU+60)
	{
		if(response)
		{
		    new _tmp_ = GetHouseOwnerEx(h);
		    if(strfind(inputtext, "%", CASE_SENSETIVE) != -1 || strfind(inputtext, "~", CASE_SENSETIVE) != -1) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HPASS_CHARS2);
		    if(strlen(inputtext) < MIN_HOUSE_PASSWORD || strlen(inputtext) > MAX_HOUSE_PASSWORD) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HPASS_LENGTH);
			if(udb_hash(inputtext) != hInfo[h][HousePassword])
			{
				ShowInfoBox(playerid, I_WRONG_HPASS1, hInfo[h][HouseOwner], inputtext);
				if(IsPlayerConnected(_tmp_))
				{
					ShowInfoBox(_tmp_, INFORMATION_HEADER, I_WRONG_HPASS2, pNick(playerid), playerid, inputtext);
    			}
			}
			else
			{
				ShowInfoBox(playerid, I_CORRECT_HPASS1, hInfo[h][HouseOwner], inputtext);
				SetPlayerHouseInterior(playerid, h);
				if(IsPlayerConnected(_tmp_))
				{
					ShowInfoBox(_tmp_, INFORMATION_HEADER, I_CORRECT_HPASS2, pNick(playerid), playerid, inputtext);
				}
			}
		}
		return 1;
	}
	switch(dialogid)
	{
	    case 599:
 	   {
  	      if(!response) return BuildRace = 0;
  	      switch(listitem)
  	      {
 		       case 0: BuildRaceType = 0;
 		       case 1: BuildRaceType = 3;
			}
			ShowDialog(playerid, 600);
	    }
	    case 600..601:
	    {
	        if(!response) return ShowDialog(playerid, 599);
	        if(!strlen(inputtext)) return ShowDialog(playerid, 601);
	        if(strlen(inputtext) < 1 || strlen(inputtext) > 20) return ShowDialog(playerid, 601);
	        strmid(BuildName, inputtext, 0, strlen(inputtext), sizeof(BuildName));
	        ShowDialog(playerid, 602);
	    }
	    case 602..603:
	    {
	        if(!response) return ShowDialog(playerid, 600);
	        if(!strlen(inputtext)) return ShowDialog(playerid, 603);
	        if(isNumeric(inputtext))
	        {

	            if(!IsValidVehicle(strval(inputtext))) return ShowDialog(playerid, 603);
				new
	                Float: pPos[4]
				;
				GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
				GetPlayerFacingAngle(playerid, pPos[3]);
				BuildModeVID = strval(inputtext);
				BuildCreatedVehicle = (BuildCreatedVehicle == 0x01) ? (DestroyVehicle(BuildVehicle), BuildCreatedVehicle = 0x00) : (DestroyVehicle(BuildVehicle), BuildCreatedVehicle = 0x00);
	            BuildVehicle = CreateVehicle(strval(inputtext), pPos[0], pPos[1], pPos[2], pPos[3], random(126), random(126), (60 * 60));
	            PutPlayerInVehicle(playerid, BuildVehicle, 0);
				BuildCreatedVehicle = 0x01;
				ShowDialog(playerid, 604);
			}
	        else
	        {
	            if(!IsValidVehicle(ReturnVehicleID(inputtext))) return ShowDialog(playerid, 603);
				new
	                Float: pPos[4]
				;
				GetPlayerPos(playerid, pPos[0], pPos[1], pPos[2]);
				GetPlayerFacingAngle(playerid, pPos[3]);
				BuildModeVID = ReturnVehicleID(inputtext);
				BuildCreatedVehicle = (BuildCreatedVehicle == 0x01) ? (DestroyVehicle(BuildVehicle), BuildCreatedVehicle = 0x00) : (DestroyVehicle(BuildVehicle), BuildCreatedVehicle = 0x00);
	            BuildVehicle = CreateVehicle(ReturnVehicleID(inputtext), pPos[0], pPos[1], pPos[2], pPos[3], random(126), random(126), (60 * 60));
	            PutPlayerInVehicle(playerid, BuildVehicle, 0);
				BuildCreatedVehicle = 0x01;
				ShowDialog(playerid, 604);
	        }
	    }
	    case 604:
	    {
	        if(!response) return ShowDialog(playerid, 602);
			SendClientMessage(playerid, COLGREEN, ">> Go to the start line on the left road and press 'KEY_FIRE' and do the same with the right road block.");
			SendClientMessage(playerid, COLGREEN, "   - When this is done, you will see a dialog to continue.");
			BuildVehPosCount = 0;
	        BuildTakeVehPos = true;
	    }
	    case 605:
	    {
	        if(!response) return ShowDialog(playerid, 604);
	        SendClientMessage(playerid, COLGREEN, ">> Start taking checkpoints now by clicking 'KEY_FIRE'.");
	        SendClientMessage(playerid, COLGREEN, "   - IMPORTANT: Press 'ENTER' when you're done with the checkpoints! If it doesn't react press again and again.");
	        BuildCheckPointCount = 0;
	        BuildTakeCheckpoints = true;
	    }
	    case 606:
	    {
	        if(!response) return ShowDialog(playerid, 606);
	        BuildRace = 0;
	        BuildCheckPointCount = 0;
	        BuildVehPosCount = 0;
	        BuildTakeCheckpoints = false;
	        BuildTakeVehPos = false;
	        BuildCreatedVehicle = (BuildCreatedVehicle == 0x01) ? (DestroyVehicle(BuildVehicle), BuildCreatedVehicle = 0x00) : (DestroyVehicle(BuildVehicle), BuildCreatedVehicle = 0x00);
	    }
	}
	// Select the proper dialog to process
	switch (dialogid)
	{
		case DialogCreateBusSelType: Dialog_CreateBusSelType(playerid, response, listitem);
		case DialogBusinessMenu: Dialog_BusinessMenu(playerid, response, listitem);
		case DialogGoBusiness: Dialog_GoBusiness(playerid, response, listitem);
		case DialogBusinessNameChange: Dialog_ChangeBusinessName(playerid, response, inputtext); // Change the name of your business
		case DialogSellBusiness: Dialog_SellBusiness(playerid, response); // Sell the business
	}
    switch( dialogid )
    {
		case DIALOG_CnR:
	    {
   			if( !response ) return ( 1 );
			switch( listitem )
			{
			    case 0:
				{
				    SpawnPlayerCop( playerid );
				}
			    case 1:
				{
				    SpawnPlayerRobber( playerid );
				}
			    case 2:
				{
				    if(PlayerInfo[ playerid ][ CopsKilled ] <  100 && PlayerInfo[ playerid ][ Robberies ] < 100)

					return SendClientMessage( playerid, -1, "Server: {FF0000}You need at least 100 store robberies and 100 cop kills to choose this class!" );
				    SpawnPlayerProRobber( playerid );
				}
			    case 3:
				{
					if( PlayerInfo[ playerid ][ Takedowns ] < 200 && PlayerInfo[ playerid ][ Arrests ] < 200 )
					return SendClientMessage( playerid, -1, "Server: {5A00FF}You need at least 200 arrests and 200 takedowns to choose this class!" );
				    SpawnPlayerArmy( playerid );
				}
			    case 4:
				{
				    SpawnPlayerSwat( playerid );
				}
			    case 5:
				{
				    SpawnPlayerERobber( playerid );
				}

			}
	    }
	    case DIALOG_CnR + 2:
	    {
   			if( !response ) return ( 1 );
			switch( listitem )
			{
			    case 0:
			    {
			        SetPlayerHealth( playerid , 100.0 );
			        SendClientMessage(playerid, COLOR_RED,"{FF0000}Server: {87CEFA}You have refilled your health!");
			    }
			    case 1:
			    {
			        SetPlayerArmour( playerid, 100.0 );
			        SendClientMessage(playerid, COLOR_RED,"{FF0000}Server: {87CEFA}You have refilled your armour!");
			    }
			    case 2:
			    {
			        if( GetPlayerTeam( playerid ) == TEAM_ARMY )
			        {
                        ResetPlayerWeapons( playerid );
                        GivePlayerWeapon( playerid, 3, 1 );
				        GivePlayerWeapon( playerid, 26, 100 );
				        GivePlayerWeapon( playerid, 27, 100 );
				        GivePlayerWeapon( playerid, 30, 500 );
				        GivePlayerWeapon( playerid, 34, 500 );
                        SendClientMessage(playerid, COLOR_RED,"{FF0000}Server: {87CEFA}You have refilled your weapons!");
			        }
			        if( GetPlayerTeam( playerid ) == TEAM_COPS )
			        {
                        ResetPlayerWeapons( playerid );
                        GivePlayerWeapon( playerid, 3, 1 ); // Bulan
				        GivePlayerWeapon( playerid, 23, 100 ); // Silenced 9mm
				        GivePlayerWeapon( playerid, 24, 100 ); // Sawnoff Shotgun
				        GivePlayerWeapon( playerid, 32, 500 ); // Tec-9
				        GivePlayerWeapon( playerid, 31, 500 ); // M4
				        GivePlayerWeapon( playerid, 34, 100 ); // Sniper
                        SendClientMessage(playerid, COLOR_RED,"{FF0000}Server: {87CEFA}You have refilled your weapons!");
			        }
			        if( GetPlayerTeam( playerid ) == TEAM_SWAT )
			        {
                        ResetPlayerWeapons( playerid );
                        GivePlayerWeapon( playerid, 3, 1 ); // Bulan
				        GivePlayerWeapon( playerid, 23, 100 ); // Silenced 9mm
						GivePlayerWeapon( playerid, 26, 100 );
						GivePlayerWeapon( playerid, 28, 500 );
				        GivePlayerWeapon( playerid, 31, 500 ); // M4
				        GivePlayerWeapon( playerid, 34, 100 ); // Sniper
                        SendClientMessage(playerid, COLOR_RED,"{FF0000}Server: {87CEFA}You have refilled your weapons!");
			        }
			    }
			}
	    }
	    case DIALOG_CnR + 4:
	    {
   			if( !response ) return ( 1 );
			switch( listitem )
			{
			    case 0:
			    {
			        if(3000 > GetPlayerMoneyEx(playerid)) SendClientMessage(playerid, COLOR_RED,"» Error « {BABABA}You dont have that amount of money!");
			        SendClientMessage(playerid, COLOR_RED,"{FF0000}Server: {FFFFFF}You have repaired your vehicle!");
			        RepairVehicle( GetPlayerVehicleID( playerid ) );
			        GivePlayerMoneyEx( playerid, -2000 );
			    }
			    case 1:
			    {
			        if(5000 > GetPlayerMoneyEx(playerid)) SendClientMessage(playerid, COLOR_RED,"» Error « {BABABA}You dont have that amount of money!");
				    switch( GetVehicleModel( GetPlayerVehicleID( playerid ) ) )
				    {
				        case 448,461,462,463,468,471,509,510,521,522,523,581,586,449:
				        return SendClientMessage(playerid, COLOR_RED,"{FF0000}ERROR: {C8C8C8}This vehicle is not compatible with nitro!");
				    }
				    SendClientMessage(playerid, COLOR_RED,"{FF0000}Server: {FFFFFF}You have added nitro in your vehicle!");
				    GivePlayerMoneyEx(playerid, -5000);
				    AddVehicleComponent( GetPlayerVehicleID( playerid ), 1010 );
			    }
			    case 2:
			    {
			        if(10000 > GetPlayerMoneyEx(playerid)) SendClientMessage(playerid, COLOR_RED,"» Error « {BABABA}You dont have that amount of money!");
				    switch( GetVehicleModel( GetPlayerVehicleID( playerid ) ) )
				    {
				        case 448,461,462,463,468,471,509,510,521,522,523,581,586,449:
				        return SendClientMessage(playerid, COLOR_RED,"{FF0000}Server: {FFFFFF}You have repaired your vehicle! (Nitro not compatible)"),RepairVehicle( GetPlayerVehicleID( playerid ) ),GivePlayerMoneyEx( playerid, -2000 );
				    }
				    RepairVehicle( GetPlayerVehicleID( playerid ));
				    GivePlayerMoneyEx( playerid, -6500 );
				    AddVehicleComponent( GetPlayerVehicleID( playerid ), 1010 );
                    SendClientMessage(playerid, COLOR_RED,"{FF0000}Server: {FFFFFF}You have repaired and added nitro to your vehicle!");
			    }
			}
	    }
		case DIALOG_CnR + 3:
	    {
   			if( !response ) return ( 1 );
			switch( listitem )
			{
			    case 0:
			    {
			        SetPlayerHealth( playerid , 100.0 );
			        SendClientMessage(playerid, COLOR_RED,"{FF0000}Server: {DB881A}You have refilled your health!");
			    }
			    case 1:
			    {
				    SetPlayerArmour( playerid, 100.0 );
			        SendClientMessage(playerid, COLOR_RED,"{FF0000}Server: {DB881A}You have refilled your armour!");
			    }
			    case 2:
			    {
     				if( GetPlayerTeam( playerid ) == TEAM_PROROBBERS )
			        {
                        ResetPlayerWeapons( playerid );
						GivePlayerWeapon( playerid, 4, 1 );
						GivePlayerWeapon( playerid, 29, 1200 );
						GivePlayerWeapon( playerid, 31, 2000 );
						GivePlayerWeapon( playerid, 26, 600 );
						GivePlayerWeapon( playerid, 27, 500 );
						GivePlayerWeapon( playerid, 16, 5 );
						GivePlayerWeapon( playerid, 34, 200 );
						SendClientMessage(playerid, COLOR_RED,"{FF0000}Server: {DB881A}You have refilled your weapons!");
			        }
     				if( GetPlayerTeam( playerid ) == TEAM_ROBBERS )
			        {
                        ResetPlayerWeapons( playerid );
                        GivePlayerWeapon( playerid, 5, 1 ); // Bat
						GivePlayerWeapon( playerid, 24, 100 ); // Deagle
						GivePlayerWeapon( playerid, 25, 100 ); // Sawnoff Shotgun
						GivePlayerWeapon( playerid, 28, 500 ); // Micro SMG
				  		GivePlayerWeapon( playerid, 30, 500 ); // AK-47
						GivePlayerWeapon( playerid, 33, 100 ); // Sniper
                        SendClientMessage(playerid, COLOR_RED,"{FF0000}Server: {DB881A}You have refilled your weapons!");
			        }
     				if( GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			        {
                        ResetPlayerWeapons( playerid );
                        GivePlayerWeapon( playerid, 5, 1 ); // Bat
						GivePlayerWeapon( playerid, 24, 100 ); // Deagle
						GivePlayerWeapon( playerid, 25, 100 ); // Sawnoff Shotgun
				        GivePlayerWeapon( playerid, 32, 500 ); // Tec-9
				        GivePlayerWeapon( playerid, 31, 500 ); // M4
				        GivePlayerWeapon( playerid, 34, 100 ); // Sniper
				        GivePlayerWeapon(playerid, 35, 4);
                        SendClientMessage(playerid, COLOR_RED,"{FF0000}Server: {DB881A}You have refilled your weapons!");
			        }

			    }
			}
	    }
	}
if(dialogid== Dialog_Vehicle)
{
if ( response==1 )
{
if(listitem==0)ShowPlayerDialog( playerid, Dialog_Airplanes, 2, "{ffffff}Airplanes:", "Andromada\nAT-400\nBeagle\nCropduster\nDodo\nNevada\nRustler\nShamal\nSkimmer\nStuntplane", "Spawn", "Back" );
if(listitem==1)ShowPlayerDialog( playerid, Dialog_Helicopters, 2, "{ffffff}Helicopters:", "Cargobob\nLeviathan\nMaverick\nNews Maverick\nPolice Maverick\nRaindance\nSparrow", "Spawn", "Back" );
if(listitem==2)ShowPlayerDialog( playerid, Dialog_Bike_Vehicle, 2, "{ffffff}Bikes:", "BF-400\nBike\nBMX\nFaggio\nFCR-900\nFreeway\nMountain Bike\nNRG-500\nPCJ-600\nPizzaboy\nQuad\nSanchez\nWayfarer", "Spawn", "Back" );
if(listitem==3)ShowPlayerDialog( playerid, Dialog_Convertable_Vehicle, 2, "{ffffff}Convertibles:", "Comet\nFeltzer\nStallion\nWindsor", "Spawn", "Back" );
if(listitem==4)ShowPlayerDialog( playerid, Dialog_Industry_Vehicle, 2, "{ffffff}Industrial:", "Benson\nBobcat\nBurrito\nBoxville\nBoxburg\nCement Truck\nDFT-30\nFlatbed\nLinerunner\nMule\nNewsvan\nPacker\nPetrol Tanker\nPony\nRoadtrain\nRumpo\nSadler\nSadler Shit\nTopfun\nTractor\nTrashmaster\nUtility Van\nWalton\nYankee\nYosemite", "Spawn", "Back" );
if(listitem==5)ShowPlayerDialog( playerid, Dialog_Low-Rider_Vehicle, 2, "{ffffff}Lowriders:", "Blade\nBroadway\nRemington\nSavanna\nSlamvan\nTahoma\nTornado\nVoodoo", "Spawn", "Back" );
if(listitem==6)ShowPlayerDialog( playerid, Dialog_Off-Road_Vehicle, 2, "{ffffff}Off Road:", "Bandito\nBF Injection\nDune\nHuntley\nLandstalker\nMesa\nMonster\nMonster A\nMonster B\nPatriot\nRancher A\nRancher B\nSandking", "Spawn", "Back" );
if(listitem==7)ShowPlayerDialog( playerid, Dialog_Public_Service_Vehicle, 2, "{ffffff}Public Service Vehicles:", "Ambulance\nBarracks\nBus\nCabbie\nCoach\nCop Bike (HPV-1000)\nEnforcer\nFBI Rancher\nFBI Truck\nFiretruck\nFiretruck LA\nPolice Car (LSPD)\nPolice Car (LVPD)\nPolice Car (SFPD)\nRanger\nS.W.A.T\nTaxi", "Spawn", "Back" );
if(listitem==8)ShowPlayerDialog( playerid, Dialog_Saloon_Vehicle, 2, "{ffffff}Saloons:", "Admiral\nBloodring Banger\nBravura\nBuccaneer\nCadrona\nClover\nElegant\nElegy\nEmperor\nEsperanto\nFortune\nGlendale Shit\nGlendale\nGreenwood\nHermes\nIntruder\nMajestic\nManana\nMerit\nNebula\nOceanic\nPicador\nPremier\nPrevion\nPrimo\nSentinel\nStafford\nSultan\nSunrise\nTampa\nVincent\nVirgo\nWillard\nWashington", "Spawn", "Back" );
if(listitem==9)ShowPlayerDialog( playerid, Dialog_Sport_Vehicle, 2, "{ffffff}Sport Vehicles:", "Alpha\nBanshee\nBlista Compact\nBuffalo\nBullet\nCheetah\nClub\nEuros\nFlash\nHotring Racer\nHotring Racer A\nHotring Racer B\nInfernus\nJester\nPhoenix\nSabre\nSuper GT\nTurismo\nUranus\nZR-350", "Spawn", "Back" );
if(listitem==10)ShowPlayerDialog( playerid, Dialog_Station_Vehicle, 2, "{ffffff}Station Wagons:", "Moonbeam\nPerenniel\nRegina\nSolair\nStratum", "Spawn", "Back" );
if(listitem==11)ShowPlayerDialog( playerid, Dialog_Boats_Vehicle, 2, "{ffffff}Boats:", "Coastguard\nDinghy\nJetmax\nLaunch\nMarquis\nPredator\nReefer\nSpeeder\nSquallo\nTropic", "Spawn", "Back" );
if(listitem==12)ShowPlayerDialog( playerid, Dialog_Trailers_Vehicle, 2, "{ffffff}Trailers:", "Article Trailer\nArticle Trailer 2\nArticle Trailer 3\nBaggage Trailer A\nBaggage Trailer B\nFarm Trailer\nFreight Flat Trailer (Train)\nFreight Box Trailer (Train)\nPetrol Trailer\nStreak Trailer (Train)\nStairs Trailer\nUtility Trailer", "Spawn", "Back" );
if(listitem==13)ShowPlayerDialog( playerid, Dialog_Unique_Vehicle, 2, "{ffffff}Unique Vehicles:", "Baggage\nBrownstreak (Train)\nCaddy\nCamper\nCamper A\nCombine Harvester\nDozer\nDumper\nForklift\nFreight (Train)\nHotknife\nHustler\nHotdog\nKart\nMower\nMr Whoopee\nRomero\nSecuricar\nStretch\nSweeper\nTram\nTowtruck\nTug\nVortex", "Spawn", "Back" );
if(listitem==14)ShowPlayerDialog( playerid, Dialog_Rc_Vehicle, 2, "{ffffff}RC Vehicles:", "RC Bandit\nRC Baron\nRC Raider\nRC Goblin\nRC Tiger\nRC Cam", "Spawn", "Back" );
}
}
//Airplanes
if(response)
    {
    switch(dialogid)
        {
		case Dialog_Airplanes:
    	    {
           	switch(listitem)
        	{
        	    case 0:
        	    {
                VehicleSpawner(playerid,Airplanes[ listitem ]);
        	    }
        	    case 1:
        	    {
                VehicleSpawner(playerid,Airplanes[ listitem ]);
        	    }
        	    case 2:
        	    {
                VehicleSpawner(playerid,Airplanes[ listitem ]);
        	    }
        	    case 3:
        	    {
                VehicleSpawner(playerid,Airplanes[ listitem ]);
        	    }
				case 4:
        	    {
                VehicleSpawner(playerid,Airplanes[ listitem ]);
        	    }
				case 5:
        	    {
                VehicleSpawner(playerid,Airplanes[ listitem ]);
        	    }
				case 6:
        	    {
                VehicleSpawner(playerid,Airplanes[ listitem ]);
        	    }
				case 7:
        	    {
                VehicleSpawner(playerid,Airplanes[ listitem ]);
        	    }
				case 8:
        	    {
                VehicleSpawner(playerid,Airplanes[ listitem ]);
        	    }
				case 9:
        	    {
                VehicleSpawner(playerid,Airplanes[ listitem ]);
        	    }
            }
        }
    }
}
//Helicopters
if(response)
    {
    switch(dialogid)
        {
		case Dialog_Helicopters:
    	    {
           	switch(listitem)
        	{
        	    case 0:
        	    {
                VehicleSpawner(playerid,Helicopters[ listitem ]);
        	    }
        	    case 1:
        	    {
                VehicleSpawner(playerid,Helicopters[ listitem ]);
        	    }
        	    case 2:
        	    {
                VehicleSpawner(playerid,Helicopters[ listitem ]);
        	    }
        	    case 3:
        	    {
                VehicleSpawner(playerid,Helicopters[ listitem ]);
        	    }
        	    case 4:
        	    {
                VehicleSpawner(playerid,Helicopters[ listitem ]);
        	    }
        	    case 5:
        	    {
                VehicleSpawner(playerid,Helicopters[ listitem ]);
        	    }
        	    case 6:
        	    {
                VehicleSpawner(playerid,Helicopters[ listitem ]);
        	    }
            }
        }
    }
}
//Bikes
if(response)
    {
    switch(dialogid)
        {
		case Dialog_Bike_Vehicle:
    	    {
           	switch(listitem)
        	{
        	    case 0:
        	    {
                VehicleSpawner(playerid,Bikes[ listitem ]);
        	    }
        	    case 1:
        	    {
                VehicleSpawner(playerid,Bikes[ listitem ]);
        	    }
        	    case 2:
        	    {
                VehicleSpawner(playerid,Bikes[ listitem ]);
        	    }
        	    case 3:
        	    {
                VehicleSpawner(playerid,Bikes[ listitem ]);
        	    }
        	    case 4:
        	    {
                VehicleSpawner(playerid,Bikes[ listitem ]);
        	    }
        	    case 5:
        	    {
                VehicleSpawner(playerid,Bikes[ listitem ]);
        	    }
        	    case 6:
        	    {
                VehicleSpawner(playerid,Bikes[ listitem ]);
        	    }
        	    case 7:
        	    {
                VehicleSpawner(playerid,Bikes[ listitem ]);
        	    }
        	    case 8:
        	    {
                VehicleSpawner(playerid,Bikes[ listitem ]);
        	    }
        	    case 9:
        	    {
                VehicleSpawner(playerid,Bikes[ listitem ]);
        	    }
        	    case 10:
        	    {
                VehicleSpawner(playerid,Bikes[ listitem ]);
        	    }
        	    case 11:
        	    {
                VehicleSpawner(playerid,Bikes[ listitem ]);
        	    }
        	    case 12:
        	    {
                VehicleSpawner(playerid,Bikes[ listitem ]);
        	    }
            }
        }
    }
}
//Convertibles
if(response)
    {
    switch(dialogid)
        {
		case Dialog_Convertable_Vehicle:
    	    {
           	switch(listitem)
        	{
        	    case 0:
        	    {
                VehicleSpawner(playerid,Convertibles[ listitem ]);
        	    }
        	    case 1:
        	    {
                VehicleSpawner(playerid,Convertibles[ listitem ]);
        	    }
        	    case 2:
        	    {
                VehicleSpawner(playerid,Convertibles[ listitem ]);
        	    }
        	    case 3:
        	    {
                VehicleSpawner(playerid,Convertibles[ listitem ]);
        	    }
            }
        }
    }
}
//Industrial
if(response)
    {
    switch(dialogid)
        {
		case Dialog_Industry_Vehicle:
    	    {
           	switch(listitem)
        	{
        	    case 0:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 1:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 2:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 3:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 4:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 5:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 6:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 7:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 8:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 9:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 10:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 11:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 12:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 13:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 14:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 15:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 16:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 17:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 18:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 19:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 20:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 21:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 22:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 23:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
        	    case 24:
        	    {
                VehicleSpawner(playerid,Industrials[ listitem ]);
        	    }
            }
        }
    }
}
//Lowriders
if(response)
    {
    switch(dialogid)
        {
		case Dialog_Low-Rider_Vehicle:
    	    {
           	switch(listitem)
        	{
        	    case 0:
        	    {
                VehicleSpawner(playerid,Lowriders[ listitem ]);
        	    }
        	    case 1:
        	    {
                VehicleSpawner(playerid,Lowriders[ listitem ]);
        	    }
        	    case 2:
        	    {
                VehicleSpawner(playerid,Lowriders[ listitem ]);
        	    }
        	    case 3:
        	    {
                VehicleSpawner(playerid,Lowriders[ listitem ]);
        	    }
        	    case 4:
        	    {
                VehicleSpawner(playerid,Lowriders[ listitem ]);
        	    }
        	    case 5:
        	    {
                VehicleSpawner(playerid,Lowriders[ listitem ]);
        	    }
        	    case 6:
        	    {
                VehicleSpawner(playerid,Lowriders[ listitem ]);
        	    }
        	    case 7:
        	    {
                VehicleSpawner(playerid,Lowriders[ listitem ]);
        	    }
            }
        }
    }
}
//Off-road
if(response)
    {
    switch(dialogid)
        {
		case Dialog_Off-Road_Vehicle:
    	    {
           	switch(listitem)
        	{
        	    case 0:
        	    {
                VehicleSpawner(playerid,Offroad[ listitem ]);
        	    }
        	    case 1:
        	    {
                VehicleSpawner(playerid,Offroad[ listitem ]);
        	    }
        	    case 2:
        	    {
                VehicleSpawner(playerid,Offroad[ listitem ]);
        	    }
        	    case 3:
        	    {
                VehicleSpawner(playerid,Offroad[ listitem ]);
        	    }
        	    case 4:
        	    {
                VehicleSpawner(playerid,Offroad[ listitem ]);
        	    }
        	    case 5:
        	    {
                VehicleSpawner(playerid,Offroad[ listitem ]);
        	    }
        	    case 6:
        	    {
                VehicleSpawner(playerid,Offroad[ listitem ]);
        	    }
        	    case 7:
        	    {
                VehicleSpawner(playerid,Offroad[ listitem ]);
        	    }
        	    case 8:
        	    {
                VehicleSpawner(playerid,Offroad[ listitem ]);
        	    }
        	    case 9:
        	    {
                VehicleSpawner(playerid,Offroad[ listitem ]);
        	    }
        	    case 10:
        	    {
                VehicleSpawner(playerid,Offroad[ listitem ]);
        	    }
        	    case 11:
        	    {
                VehicleSpawner(playerid,Offroad[ listitem ]);
        	    }
        	    case 12:
        	    {
                VehicleSpawner(playerid,Offroad[ listitem ]);
        	    }
            }
        }
    }
}
//Public Service
if(response)
    {
    switch(dialogid)
        {
		case Dialog_Public_Service_Vehicle:
    	    {
           	switch(listitem)
        	{
        	    case 0:
        	    {
                VehicleSpawner(playerid,Public[ listitem ]);
        	    }
        	    case 1:
        	    {
                VehicleSpawner(playerid,Public[ listitem ]);
        	    }
        	    case 2:
        	    {
                VehicleSpawner(playerid,Public[ listitem ]);
        	    }
        	    case 3:
        	    {
                VehicleSpawner(playerid,Public[ listitem ]);
        	    }
        	    case 4:
        	    {
                VehicleSpawner(playerid,Public[ listitem ]);
        	    }
        	    case 5:
        	    {
                VehicleSpawner(playerid,Public[ listitem ]);
        	    }
        	    case 6:
        	    {
                VehicleSpawner(playerid,Public[ listitem ]);
        	    }
        	    case 7:
        	    {
                VehicleSpawner(playerid,Public[ listitem ]);
        	    }
        	    case 8:
        	    {
                VehicleSpawner(playerid,Public[ listitem ]);
        	    }
        	    case 9:
        	    {
                VehicleSpawner(playerid,Public[ listitem ]);
        	    }
        	    case 10:
        	    {
                VehicleSpawner(playerid,Public[ listitem ]);
        	    }
        	    case 11:
        	    {
                VehicleSpawner(playerid,Public[ listitem ]);
        	    }
        	    case 12:
        	    {
                VehicleSpawner(playerid,Public[ listitem ]);
        	    }
        	    case 13:
        	    {
                VehicleSpawner(playerid,Public[ listitem ]);
        	    }
        	    case 14:
        	    {
                VehicleSpawner(playerid,Public[ listitem ]);
        	    }
        	    case 15:
        	    {
                VehicleSpawner(playerid,Public[ listitem ]);
        	    }
        	    case 16:
        	    {
                VehicleSpawner(playerid,Public[ listitem ]);
        	    }
            }
        }
    }
}
//Saloons
if(response)
    {
    switch(dialogid)
        {
		case Dialog_Saloon_Vehicle:
    	    {
           	switch(listitem)
        	{
        	    case 0:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 1:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 2:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 3:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 4:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 5:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 6:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 7:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 8:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 9:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 10:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 11:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 12:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 13:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 14:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 15:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 16:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 17:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 18:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 19:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 20:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 21:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 22:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 23:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 24:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 25:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 26:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 27:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 28:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 29:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 30:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 31:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 32:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
        	    case 33:
        	    {
                VehicleSpawner(playerid,Saloons[ listitem ]);
        	    }
            }
        }
    }
}
//Sport
if(response)
    {
    switch(dialogid)
        {
		case Dialog_Sport_Vehicle:
    	    {
           	switch(listitem)
        	{
        	    case 0:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 1:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 2:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 3:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 4:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 5:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 6:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 7:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 8:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 9:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 10:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 11:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 12:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 13:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 14:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 15:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 16:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 17:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 18:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
        	    case 19:
        	    {
                VehicleSpawner(playerid,Sport[ listitem ]);
        	    }
            }
        }
    }
}
//Station
if(response)
    {
    switch(dialogid)
        {
		case Dialog_Station_Vehicle:
    	    {
           	switch(listitem)
        	{
        	    case 0:
        	    {
                VehicleSpawner(playerid,Station[ listitem ]);
        	    }
        	    case 1:
        	    {
                VehicleSpawner(playerid,Station[ listitem ]);
        	    }
        	    case 2:
        	    {
                VehicleSpawner(playerid,Station[ listitem ]);
        	    }
        	    case 3:
        	    {
                VehicleSpawner(playerid,Station[ listitem ]);
        	    }
        	    case 4:
        	    {
                VehicleSpawner(playerid,Station[ listitem ]);
        	    }
            }
        }
    }
}
//Boats
if(response)
    {
    switch(dialogid)
        {
		case Dialog_Boats_Vehicle:
    	    {
           	switch(listitem)
        	{
        	    case 0:
        	    {
                VehicleSpawner(playerid,Boats[ listitem ]);
        	    }
        	    case 1:
        	    {
                VehicleSpawner(playerid,Boats[ listitem ]);
        	    }
        	    case 2:
        	    {
                VehicleSpawner(playerid,Boats[ listitem ]);
        	    }
        	    case 3:
        	    {
                VehicleSpawner(playerid,Boats[ listitem ]);
        	    }
        	    case 4:
        	    {
                VehicleSpawner(playerid,Boats[ listitem ]);
        	    }
        	    case 5:
        	    {
                VehicleSpawner(playerid,Boats[ listitem ]);
        	    }
        	    case 6:
        	    {
                VehicleSpawner(playerid,Boats[ listitem ]);
        	    }
        	    case 7:
        	    {
                VehicleSpawner(playerid,Boats[ listitem ]);
        	    }
        	    case 8:
        	    {
                VehicleSpawner(playerid,Boats[ listitem ]);
        	    }
        	    case 9:
        	    {
                VehicleSpawner(playerid,Boats[ listitem ]);
        	    }
            }
        }
    }
}
//Trailers
if(response)
    {
    switch(dialogid)
        {
		case Dialog_Trailers_Vehicle:
    	    {
           	switch(listitem)
        	{
        	    case 0:
        	    {
                VehicleSpawner(playerid,Trailers[ listitem ]);
        	    }
        	    case 1:
        	    {
                VehicleSpawner(playerid,Trailers[ listitem ]);
        	    }
        	    case 2:
        	    {
                VehicleSpawner(playerid,Trailers[ listitem ]);
        	    }
        	    case 3:
        	    {
                VehicleSpawner(playerid,Trailers[ listitem ]);
        	    }
        	    case 4:
        	    {
                VehicleSpawner(playerid,Trailers[ listitem ]);
        	    }
        	    case 5:
        	    {
                VehicleSpawner(playerid,Trailers[ listitem ]);
        	    }
        	    case 6:
        	    {
                VehicleSpawner(playerid,Trailers[ listitem ]);
        	    }
        	    case 7:
        	    {
                VehicleSpawner(playerid,Trailers[ listitem ]);
        	    }
        	    case 8:
        	    {
                VehicleSpawner(playerid,Trailers[ listitem ]);
        	    }
        	    case 9:
        	    {
                VehicleSpawner(playerid,Trailers[ listitem ]);
        	    }
        	    case 10:
        	    {
                VehicleSpawner(playerid,Trailers[ listitem ]);
        	    }
        	    case 11:
        	    {
                VehicleSpawner(playerid,Trailers[ listitem ]);
        	    }
            }
        }
    }
}
//Unique
if(response)
    {
    switch(dialogid)
        {
		case Dialog_Unique_Vehicle:
    	    {
           	switch(listitem)
        	{
        	    case 0:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 1:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 2:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 3:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 4:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 5:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 6:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 7:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 8:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 9:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 10:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 11:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 13:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 14:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 15:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 16:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 17:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 18:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 19:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 20:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 21:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 22:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
        	    case 23:
        	    {
                VehicleSpawner(playerid,Unique[ listitem ]);
        	    }
            }
        }
    }
}
//RC vehicles
if(response)
    {
    switch(dialogid)
        {
		case Dialog_Rc_Vehicle:
    	    {
           	switch(listitem)
        	{
        	    case 0:
        	    {
                VehicleSpawner(playerid,RC_Vehicles[ listitem ]);
        	    }
        	    case 1:
        	    {
                VehicleSpawner(playerid,RC_Vehicles[ listitem ]);
        	    }
        	    case 2:
        	    {
                VehicleSpawner(playerid,RC_Vehicles[ listitem ]);
        	    }
        	    case 3:
        	    {
                VehicleSpawner(playerid,RC_Vehicles[ listitem ]);
        	    }
        	    case 4:
        	    {
                VehicleSpawner(playerid,RC_Vehicles[ listitem ]);
        	    }
        	    case 5:
        	    {
                VehicleSpawner(playerid,RC_Vehicles[ listitem ]);
        	    }
            }
        }
    }
}
if(dialogid== Dialog_Rc_Vehicle){
if ( response ){
VehicleSpawner(playerid,RC_Vehicles[ listitem ]);
}else ShowVehicleDialog(playerid);
}
return 0; // It is important to have return 0; here at the end of ALL your scripts which uses dialogs.
}

forward KickOnFail(playerid); //We have to do this so that the MSG is displayed before the player gets kicked!
public KickOnFail(playerid)
  	{
   		Kick(playerid);
	}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

//---------------
// Teleports
//---------------
CMD:bs(playerid) return cmd_bikeskills(playerid);
CMD:bikeskills(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
		SetPlayerVehiclePos(playerid, -1503.6721,312.5178,53.0322,277.6587);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~BIKE SKILLS!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -1505.5437,318.0351,53.4609,264.9079);
  		SetCameraBehindPlayer(playerid);
		GameTextForPlayer(playerid, "~r~BIKE SKILLS!", 2000, 3);
	}
	return 1;
}

CMD:bs2(playerid) return cmd_bikeskills2(playerid);
CMD:bikeskills2(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 836.0185,-2018.6010,12.6230,180.5763);
        SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~BikeSkills 2!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 836.1467,-2031.3687,12.8672,180.5775);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~BikeSkills 2!", 2000, 3);
	}
	return 1;
}

CMD:bs3(playerid) return cmd_bikeskills3(playerid);
CMD:bikeskills3(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
		SetPlayerVehiclePos(playerid, 2790.3271,-1068.3965,93.7464,182.9216);
 	    SetCameraBehindPlayer(playerid);
    	GameTextForPlayer(playerid, "~r~BIKE SKILLS 3!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
		SetPlayerPosition(playerid, 2806.6768,-1077.0695,94.1871,63.5400);
  		SetCameraBehindPlayer(playerid);
		GameTextForPlayer(playerid, "~r~BIKE SKILLS 3!", 2000, 3);
	}
	return 1;
}

CMD:bs4(playerid) return cmd_bikeskills4(playerid);
CMD:bikeskills4(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
		SetPlayerVehiclePos(playerid, 2467.7754,-1429.6439,34.1396,281.9245);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~BIKE SKILLS 4!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 2468.1228,-1412.6610,34.5681,186.3024);
  		SetCameraBehindPlayer(playerid);
		GameTextForPlayer(playerid, "~r~BIKE SKILLS 4!", 2000, 3);
	}
	return 1;
}

CMD:bs5(playerid) return cmd_bikeskills5(playerid);
CMD:bikeskills5(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
		SetPlayerVehiclePos(playerid, 2506.0959,-1663.7797,12.9587,178.5557);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~BIKE SKILLS 5!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 2503.2483,-1659.3923,13.3960,181.9929);
  		SetCameraBehindPlayer(playerid);
		GameTextForPlayer(playerid, "~r~BIKE SKILLS 5!", 2000, 3);
	}
	return 1;
}

CMD:bs6(playerid) return cmd_bikeskills6(playerid);
CMD:bikeskills6(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
		SetPlayerVehiclePos(playerid, 2046.4736,-1402.3339,67.8947,90.5766);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~BIKE SKILLS 6!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 2046.2976,-1398.8738,68.3218,144.5259);
  		SetCameraBehindPlayer(playerid);
		GameTextForPlayer(playerid, "~r~BIKE SKILLS 6!", 2000, 3);
	}
	return 1;
}

CMD:bs7(playerid) return cmd_bikeskills7(playerid);
CMD:bikeskills7(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
		SetPlayerVehiclePos(playerid, 471.1776,787.0906,7.9457,230.8269);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~BIKE SKILLS 7!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 449.8297,809.3416,6.4946,224.0582);
  		SetCameraBehindPlayer(playerid);
		GameTextForPlayer(playerid, "~r~BIKE SKILLS 7!", 2000, 3);
	}
	return 1;
}

CMD:bs8(playerid) return cmd_bikeskills8(playerid);
CMD:bikeskills8(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
		SetPlayerVehiclePos(playerid, -2756.8069,-2597.1165,7.3755,80.0866);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~BIKE SKILLS 8!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -2739.7805,-2609.4204,7.0587,88.1712);
  		SetCameraBehindPlayer(playerid);
		GameTextForPlayer(playerid, "~r~BIKE SKILLS 8!", 2000, 3);
	}
	return 1;
}


CMD:place1(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 2638.1768,552.6877,8.9067,27.0736);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 1!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 2713.8787,556.9504,8.8506,13.3103);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 1!", 2000, 3);
	}
	return 1;
}

CMD:place2(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 3000.1772,1033.9827,14.6638,282.1529);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 2!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 3009.6333,1028.9849,14.9339,248.3125);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 2!", 2000, 3);
	}
	return 1;
}

CMD:place3(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 2956.3218,2120.2986,15.8170,237.0324);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 3!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 2955.2876,2113.6133,16.1501,280.9230);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 3!", 2000, 3);
	}
	return 1;
}

CMD:place4(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 1960.3303,2983.0891,28.3921,343.5901);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 4!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 1969.8298,2973.1765,27.9243,35.6038);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 4!", 2000, 3);
	}
	return 1;
}

CMD:place5(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 1486.4993,2993.6516,19.2681,320.0667);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 5!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 1493.9371,3005.6934,19.4240,19.6005);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 5!", 2000, 3);
	}
	return 1;
}

CMD:place6(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, -129.7793,-2895.3464,39.6235,179.0882);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 6!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -137.9217,-2906.3428,40.1333,190.0550);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 6!", 2000, 3);
	}
	return 1;
}

CMD:place7(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 644.6796,-2036.3306,9.2063,287.0885);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 7!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 648.3317,-1947.5765,8.4963,344.7423);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 7!", 2000, 3);
	}
	return 1;
}

CMD:place8(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 2873.3120,-1983.5216,11.2418,7.7988);
     	SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 8!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 2872.6790,-1974.5374,11.2489,8.7170);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 8!", 2000, 3);
	}
	return 1;
}

CMD:place9(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 2847.1221,190.9436,15.7477,266.8690);
    	SetCameraBehindPlayer(playerid);
    	GameTextForPlayer(playerid, "~r~Cool Place 9!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 2833.8972,187.5651,15.6291,275.0158);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 9!", 2000, 3);
	}
	return 1;
}

CMD:place10(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 2699.0010,1112.7104,57.0331,72.0319);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 10!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 2678.4167,1154.6871,56.3406,33.8582);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Cool Place 10!", 2000, 3);
	}
	return 1;
}

CMD:place11(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 297.5857,1962.1069,17.8266,322.7157);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Place 11!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 318.5266,1930.5055,18.0756,187.6277);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Place 11!", 2000, 3);
	}
	return 1;
}

CMD:place12(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, -189.0816,-42.3998,5.2593,337.2982);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Place 12 :D!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -143.4556,-31.3365,6.6872,70.1536);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Place 12 :D!", 2000, 3);
	}
	return 1;
}

CMD:place13(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, -413.5700,-3036.1677,39.6493,165.7679);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Place 13 :D!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -433.9788,-3033.1765,40.7869,182.0620);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Place 13 :D!", 2000, 3);
	}
	return 1;
}

CMD:stuntland(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 1957.0490,-3224.5503,3.1307,244.4670);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Stunt Land!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 1971.2732,-3298.8628,4.4044,235.0670);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Stunt Land!", 2000, 3);
	}
	return 1;
}

CMD:sl(playerid)
{
  cmd_stuntland(playerid);
  return 1;
}

CMD:parkour1(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 292.3160,2033.4948,79.9762,93.0288);
        RemovePlayerFromVehicle(playerid);
        CarDeleter(playerid, PlayerInfo[playerid][pCar]);
        PlayerInfo[playerid][pCar] = 0;
        SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Parkour 1!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 291.6339,2046.1715,79.6301,104.9441);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Parkour 1!", 2000, 3);
	}
	return 1;
}

CMD:parkour2(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
		SetPlayerVehiclePos(playerid, 1537.6331,-1354.0913,329.4611,352.5282);
        RemovePlayerFromVehicle(playerid);
        CarDeleter(playerid, PlayerInfo[playerid][pCar]);
        PlayerInfo[playerid][pCar] = 0;
        SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Parkour 2!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 1544.6667,-1351.7169,329.4756,352.5281);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Parkour 2!", 2000, 3);
	}
	return 1;
}

CMD:parkour3(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
		SetPlayerVehiclePos(playerid, 999.0828,-2051.1074,38.8430,68.7398);
        RemovePlayerFromVehicle(playerid);
        CarDeleter(playerid, PlayerInfo[playerid][pCar]);
        PlayerInfo[playerid][pCar] = 0;
		SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Parkour 3!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 976.9490,-2054.8450,38.8478,337.5590);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Parkour 3!", 2000, 3);
	}
	return 1;
}

CMD:parkour(playerid)
{
   SendClientMessage(playerid, COLOR_GREEN, "Available Parkour Places:");
   SendClientMessage(playerid, COLOR_GREEN, "/parkour1, /parkour2, /parkour3");
   return 1;
}

CMD:park(playerid)
{
  cmd_parkour(playerid);
  return 1;
}

CMD:island(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 281.6832,-2621.5842,3.2486,164.4082);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Some island :D", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 294.0218,-2677.9504,2.7045,112.0810);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Some island :D", 2000, 3);
	}
	return 1;
}

CMD:air(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, -3003.1960,-203.3727,6.7227,92.7312);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Airport!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -2979.5645,-231.3856,6.8747,143.6815);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Airport!", 2000, 3);
	}
	return 1;
}

CMD:air2(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, -60.2282,-1749.0336,16.1928,174.0981);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Airport 2!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -28.0797,-1781.7213,16.0418,189.4750);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Airport 2!", 2000, 3);
	}
	return 1;
}

CMD:lv(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 2171.4873,1681.4995,10.3875,86.2513);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~LAS VENTURAS!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 2180.3672,1681.6908,11.0565,91.8018);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~LAS VENTURAS!", 2000, 3);
	}
	return 1;
}

CMD:drift(playerid)
{
	if ( caged[playerid] == 1 ) return SendClientMessage( playerid, -1, ""RED"ERROR: "GREY"You cannot use this command in jail!");
	if ( PlayerInfo[playerid][inDM] == 1 ) return SendClientMessage( playerid, -1, ""RED"ERROR: "GREY"You cannot use this command here! Type /exit to exit!" );
	SendClientMessage(playerid, COLOR_GREEN, "Available Drift Places:");
	SendClientMessage(playerid, COLOR_GREEN, "/drift1, /drift2, /drift3, /drift4, /drift5, /drift6, /drift7");
	return 1;
}

CMD:drift1(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 2848.3572,-346.8952,7.6758,278.7270);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Drift Place 1!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 2850.5237,-353.2813,8.0222,278.7706);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Drift Place 1!", 2000, 3);
	}
	return 1;
}

CMD:drift2(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 2688.2400,-2571.2229,13.5005,177.2635);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Drift Place 2!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 2674.2156,-2571.8896,13.5954,177.4601);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Drift Place 2!", 2000, 3);
	}
	return 1;
}

CMD:drift3(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 1246.6439,-2011.0614,59.7071,199.8380);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Drift Place 3!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
    	SetPlayerPosition(playerid, 1277.5486,-2012.0757,58.9122,156.8965);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Drift Place 3!", 2000, 3);
	}
	return 1;
}

CMD:drift4(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 1658.3414,-2860.8779,2.6339,5.1494);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Drift Place 4!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 1642.6150,-2854.9399,2.9700,270.4816);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Drift Place 4!", 2000, 3);
	}
	return 1;
}

CMD:drift5(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, -2812.0046,1522.3870,1.6330,357.6112);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Drift Place 5!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -2805.0510,1521.6556,1.9728,2.3230);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Drift Place 5!", 2000, 3);
	}
	return 1;
}

CMD:drift6(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, -304.5648,1512.8163,75.3594,177.5053);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Drift Place 6!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -294.1788,1519.1991,75.3782,104.4980);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Drift Place 6!", 2000, 3);
	}
	return 1;
}

CMD:drift7(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 4183.1299,480.4834,64.1961,180.7149);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Drift Place 7!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
    	SetPlayerPosition(playerid, 4203.7803,474.0792,61.6129,182.3090);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Drift Place 7!", 2000, 3);
	}
	return 1;
}

CMD:lvair(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 1617.1729,1272.0662,10.7556,75.9016);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Las Venturas Airport!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 1610.1835,1244.6378,10.8711,71.1635);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Las Venturas Airport!", 2000, 3);
	}
	return 1;
}

CMD:lva ( playerid )
{
	cmd_lvair(playerid);
	return 1;
}

CMD:actor(playerid)
{
    if (IsPlayerSeniorAdmin(playerid, 4) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You don't have enough privileges to use this command!");
	{
		ShowPlayerDialog(playerid,DIALOG_A1,DIALOG_STYLE_MSGBOX,"{00BD2C}C_ACTOR","Would you like to create an actor?","Yes","No");
	}
	return 1;
}


CMD:buyc4(playerid, params[])
{
	if(GetPlayerMoney(playerid) <= 10000) return SendClientMessage(playerid, -1,"You don't have Cash.");
	if(C4[playerid] == 1) return SendClientMessage(playerid, -1,"You already got a C4.");
	C4[playerid] = 1;
	SendClientMessage(playerid, -1,"You've successfully bought a C4.");
	SendClientMessage(playerid, -1,"Get to a Security Van and plant C4 on the rear doors.[/plantc4]");
	GivePlayerMoney(playerid, -10000);
	return 1;
}

CMD:plantc4(playerid, params[])
{
	new ClosestCar = GetClosestCar(playerid);
	GetVehiclePos(ClosestCar, VanX,VanY,VanZ);
	if(C4[playerid] == 0) return SendClientMessage(playerid, -1,"You don't have a C4.");
	if(IsPlayerInRangeOfPoint(playerid, 7.0, VanX,VanY,VanZ))
	{
 	if(SecurityVan(ClosestCar))
 	{
 	SecurityVanID[playerid] = ClosestCar;
	VanMoved = SetTimerEx("VanMovedTimer",1000,true,"i",playerid);
 	CountTime = 5;
 	Counting = 1;
 	SendClientMessage(playerid, -1,"You're planting the C4!");
 	//ApplyAnimation
 	}
 	else return SendClientMessage(playerid, -1,"This vehicle isn't a Security Van.");
 	}
	else return SendClientMessage(playerid, -1,"There aren't any Security Vans near.");
	return 1;
}

CMD:blastc4(playerid, params[])
{
	new Float:vanX,Float:vanY,Float:vanZ;
	if(DetonateC4[playerid] == 1)
	{
	new SVID = SecurityVanID[playerid];
	GetVehiclePos(SVID, vanX,vanY,vanZ);
	CreateExplosion(vanX, vanY, vanZ, 7, 10);
	SetVehicleHealth(SVID, 350);
	SVBeingRobbed[SVID] = 1;
	DetonateC4[playerid] = 0;
	MoneyLeft[SVID] = 5;
	SendClientMessage(playerid, -1,"The C4 blasted, Rob the van and get out of here![/robvan]");
	}
	else return SendClientMessage(playerid, -1,"You don't have a C4 planted anywhere.");
	return 1;
}

CMD:robvan(playerid, params[])
{
	new ClosestCar = GetClosestCar(playerid);
	if(BagCounting == 1) return SendClientMessage(playerid, -1,"You're robbing the Security Van!");
	if(MoneyLeft[ClosestCar] == 0) return SendClientMessage(playerid, -1,"This Van is empty!");
	if(FullBag[playerid] == 1) return SendClientMessage(playerid, -1,"You robbed the Security Van!");
	if(SVBeingRobbed[ClosestCar] == 1)
	{
	SendClientMessage(playerid, -1,"You're robbing Security Van.");
	FBTimer = SetTimerEx("FillingBags",1000,true,"i",playerid);
	BagTime = 5;
	BagCounting = 1;
	MoneyLeft[ClosestCar] -= 1;
	//ApplyAnimation
	}
	else return SendClientMessage(playerid, -1,"This Van isn't being robbed.");
	return 1;
}

CMD:sfair(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, -1256.4412,1.9492,13.8036,133.0014);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~San Fiero Airport!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -1282.0042,27.8623,14.1484,132.6035);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~San Fiero Airport!", 2000, 3);
	}
	return 1;
}

CMD:sfa(playerid)
{
	cmd_sfair(playerid);
	return 1;
}

CMD:aa(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 365.4525,2535.2830,16.2353,180.0284);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Abandoned Airfield!", 2000, 3);
	}
	else
	{

        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 374.7578,2536.7205,16.5790,135.2049);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Abandoned Airfield!", 2000, 3);
	}
	return 1;
}

CMD:tubeland(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 68.6065,3494.9485,9.7840,271.4272);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Welcome to Tube Land!", 2000, 3);
	}
	else
	{

        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 79.6600,3462.8838,6.8530,346.9503);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~AWelcome to Tube Land!", 2000, 3);
	}
	return 1;
}

CMD:sf(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, -2665.9607,1340.0472,16.5632,273.5440);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~San Fierro!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -2663.3826,1329.6676,16.9922,322.3937);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~San Fierro!", 2000, 3);
	}
	return 1;
}

CMD:tas1(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 1806.1698,-1910.7566,13.3905,90.9880);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~TamZer Map 1!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 1806.5476,-1939.0392,13.5469,13.0905);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~TamZer Map 1!", 2000, 3);
	}
	return 1;
}

CMD:tas2(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 1893.2000,-1355.6549,13.1582,168.9560);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~TamZer Map 2!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 1912.2405,-1406.7762,13.5703,27.5834);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~TamZer Map 2!", 2000, 3);
	}
	return 1;
}

CMD:richcity(playerid, params[])
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
       SetPlayerVehiclePos(playerid, 2512.5337,-2309.8379,24.0841,224.1499);
       SetCameraBehindPlayer(playerid);
       GameTextForPlayer(playerid, "~r~Rich City!", 2000, 3);
    }
	else
	{
       RemovePlayerFromVehicle(playerid);
	   SetPlayerPosition(playerid, 2472.7224,-2269.5220,25.0625,222.8965);
	   SetCameraBehindPlayer(playerid);
	   GameTextForPlayer(playerid, "~r~Rich City!", 2000, 3);
	}
	return 1;
}

CMD:bayside(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, -2238.4585,2389.3225,3.6281,314.8758);
 	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Bayside!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -2215.5095,2386.6956,4.9587,314.6105);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Bayside!", 2000, 3);
	}
	return 1;
}

CMD:chilliad(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, -2356.2617,-1637.7598,483.2783,277.7109);
        SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Chilliad!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -2355.9038,-1635.4912,483.7031,284.7480);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Chilliad!", 2000, 3);
	}
	return 1;
}

CMD:fdm(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
    
	PlayerInfo[playerid][inDM] = 1;
	PlayerInfo[playerid][inDMZone] = 1;
    SetPVarInt(playerid, "InDM", 1);
	gFDMPlayers++;
	GameTextForPlayer(playerid, "~r~FIELD DM!", 2000, 3);
	SendClientMessage(playerid, COLOR_FIREBRICK, "** Welcome to FIELD DM!" );
	new Float:RandomSpawns[][] =
	{
	    {1306.6731,2108.0920,11.0156,320.5279},
		{1383.2549,2185.4321,11.0234,142.6434}
	};
	if (IsPlayerInAnyVehicle(playerid))
	{
	    RemovePlayerFromVehicle(playerid);
	}
	new Random = random(sizeof(RandomSpawns));
	SetPlayerPosition(playerid, RandomSpawns[Random][0], RandomSpawns[Random][1], RandomSpawns[Random][2], RandomSpawns[Random][3]);
	SetPlayerVirtualWorld(playerid, 1);
	SetCameraBehindPlayer(playerid);
	SetPlayerTeam(playerid, playerid);
	ResetPlayerWeapons(playerid);
	SetPlayerHealth(playerid, 100.0);
	GiveWeaponSet(playerid, PlayerInfo[playerid][WeaponSet]);

	new str[128];
	format(str, sizeof(str), ""GREEN":: {%06x}%s(%d) "TELEPORTBLUE" is in [/fdm] Join and enjoy!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
	SendClientMessageToAll( -1, str );
	return 1;
}

CMD:war(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
    
	PlayerInfo[playerid][inDM] = 1;
	PlayerInfo[playerid][inDMZone] = 2;
    SetPVarInt(playerid, "InDM", 1);
	gWARPlayers++;
	GameTextForPlayer(playerid, "~r~WAR DM!", 2000, 3);
	SendClientMessage(playerid, COLOR_FIREBRICK, "** Welcome to WAR DM!" );
	new Float:RandomSpawns[][] =
	{
	    {336.9875,1822.0619,17.6406,88.7100},
		{123.5864,1819.3789,17.6406,346.1517},
		{135.2626,1935.9694,19.2690,174.2042}
	};
	if (IsPlayerInAnyVehicle(playerid))
	{
	    RemovePlayerFromVehicle(playerid);
	}
	new Random = random(sizeof(RandomSpawns));
	SetPlayerPosition(playerid, RandomSpawns[Random][0], RandomSpawns[Random][1], RandomSpawns[Random][2], RandomSpawns[Random][3]);
	SetPlayerVirtualWorld(playerid, 1);
	SetCameraBehindPlayer(playerid);
	SetPlayerTeam(playerid, playerid);
	ResetPlayerWeapons(playerid);
	SetPlayerHealth(playerid, 100.0);
	GiveWeaponSet(playerid, PlayerInfo[playerid][WeaponSet]);

	new str[128];
	format(str, sizeof(str), ""GREEN":: {%06x}%s(%d) "TELEPORTBLUE"is in [/war] Join and enjoy!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
	SendClientMessageToAll( -1, str );
	return 1;
}

CMD:mini(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
    
    SetPVarInt(playerid, "InDM", 1);
	PlayerInfo[playerid][inDM] = 1;
	PlayerInfo[playerid][inMini] = 1;
	PlayerInfo[playerid][inDMZone] = 3;
	gMINIPlayers++;
	GameTextForPlayer(playerid, "~r~MINIGUN DM!", 2000, 3);
	SendClientMessage(playerid, COLOR_FIREBRICK, "** Welcome to MINIGUN DM!" );
	new Float:RandomSpawns[][] =
	{
	    {2643.1538,2777.5657,23.8222,177.1462},
		{2604.4246,2726.2517,23.8222,356.0145},
		{2597.5359,2780.0967,23.8222,265.4370},
		{2608.2749,2731.7131,36.5386,1.3178}
	};
	if (IsPlayerInAnyVehicle(playerid))
	{
	    RemovePlayerFromVehicle(playerid);
	}
	new Random = random(sizeof(RandomSpawns));
	SetPlayerPosition(playerid, RandomSpawns[Random][0], RandomSpawns[Random][1], RandomSpawns[Random][2], RandomSpawns[Random][3]);
	SetPlayerVirtualWorld(playerid, 1);
	SetCameraBehindPlayer(playerid);
	SetPlayerTeam(playerid, playerid);
	ResetPlayerWeapons(playerid);
	SetPlayerHealth(playerid, 100.0);
	GivePlayerWeapon(playerid, 38, 99999);

	new str[128];
	format(str, sizeof(str), ""GREEN":: {%06x}%s(%d) "TELEPORTBLUE"is in [/mini] Join and enjoy!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
	SendClientMessageToAll( -1, str );
	return 1;
}
CMD:eagle(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
    
	PlayerInfo[playerid][inDM] = 1;
    SetPVarInt(playerid, "InDM", 1);
	PlayerInfo[playerid][inDMZone] = 4;
	gEAGLEPlayers++;
	GameTextForPlayer(playerid, "~r~EAGLE DM!", 2000, 3);
	SendClientMessage(playerid, COLOR_FIREBRICK, "** Welcome to EAGLE DM!" );
	new Float:RandomSpawns[][] =
	{
	    {-458.5346,2181.8350,47.1960,317.6914},
		{-338.3433,2209.2195,42.4844,76.4224},
		{-366.1375,2275.1846,41.6491,141.9097},
		{-517.3373,2235.7214,57.7979,272.5709}
	};
	if (IsPlayerInAnyVehicle(playerid))
	{
	    RemovePlayerFromVehicle(playerid);
	}
	new Random = random(sizeof(RandomSpawns));
	SetPlayerPosition(playerid, RandomSpawns[Random][0], RandomSpawns[Random][1], RandomSpawns[Random][2], RandomSpawns[Random][3]);
	SetPlayerVirtualWorld(playerid, 1);
	SetCameraBehindPlayer(playerid);
	SetPlayerTeam(playerid, playerid);
	ResetPlayerWeapons(playerid);
	SetPlayerHealth(playerid, 100.0);
	GivePlayerWeapon(playerid, 24, 99999);

	new str[128];
	format(str, sizeof(str), ""GREEN":: {%06x}%s(%d) "TELEPORTBLUE"is in [/eagle] Join and enjoy!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
	SendClientMessageToAll( -1, str );
	return 1;
}
CMD:rdm(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
    
	PlayerInfo[playerid][inDM] = 1;
    SetPVarInt(playerid, "InDM", 1);
	PlayerInfo[playerid][inDMZone] = 5;
	gRDMPlayers++;
	GameTextForPlayer(playerid, "~r~ROCKET MADNESS!", 2000, 3);
	SendClientMessage(playerid, COLOR_FIREBRICK, "** Welcome to ROCKET DM!" );
	new Float:RandomSpawns[][] =
	{
        {3383.5664,2202.0608,19.2243,237.1224},
        {3538.0852,2061.6968,26.2328,30.6570},
        {3541.4534,2208.6680,26.9936,79.1484},
        {3444.3206,2129.8296,22.4213,146.4239}
	};
	if (IsPlayerInAnyVehicle(playerid))
	{
	    RemovePlayerFromVehicle(playerid);
	}
	new Random = random(sizeof(RandomSpawns));
    SetPlayerPosition(playerid, RandomSpawns[Random][0], RandomSpawns[Random][1], RandomSpawns[Random][2], RandomSpawns[Random][3]);
	SetPlayerTeam(playerid, playerid);
	SetPlayerVirtualWorld(playerid, 1);
	ResetPlayerWeapons(playerid);
	SetPlayerHealth(playerid, 100.0);
	GivePlayerWeapon(playerid, 35, 99999);

	new str[128];
	format(str, sizeof(str), ""GREEN":: {%06x}%s(%d) "TELEPORTBLUE"is in [/rdm] Join and enjoy!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
	SendClientMessageToAll( -1, str );
	return 1;
}

CMD:odm(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
    
	PlayerInfo[playerid][inDM] = 1;
    SetPVarInt(playerid, "InDM", 1);
	PlayerInfo[playerid][inDMZone] = 6;
	gODMPlayers++;
	GameTextForPlayer(playerid, "~r~ONE SHOT DM", 2000, 3);
	SendClientMessage(playerid, COLOR_FIREBRICK, "** Welcome to One-Shot DM!");
	new Float:RandomSpawns[][] =
	{
	     {1066.0101,2617.8953,60.2512,53.9990},
	     {1011.5014,2617.3079,60.2469,308.7414},
	     {1066.6931,2634.0889,55.2469,139.5163},
	     {1010.6512,2617.0696,55.2469,320.9146}
	};
	if (IsPlayerInAnyVehicle(playerid))
	{
	    RemovePlayerFromVehicle(playerid);
	}
	new Random = random(sizeof(RandomSpawns));
	SetPlayerPosition(playerid, RandomSpawns[Random][0], RandomSpawns[Random][1], RandomSpawns[Random][2], RandomSpawns[Random][3]);
	SetPlayerTeam(playerid, playerid);
	SetPlayerVirtualWorld(playerid, 1);
	ResetPlayerWeapons(playerid);
	SetPlayerHealth(playerid, 2.0);
	GivePlayerWeapon(playerid, 23, 100);

	new str[128];
	format(str, sizeof(str), ""GREEN":: {%06x}%s(%d) "TELEPORTBLUE"is in [/odm] Join and enjoy!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
	SendClientMessageToAll( -1, str );
	return 1;
}

CMD:sawndm(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
    
	PlayerInfo[playerid][inDM] = 1;
    SetPVarInt(playerid, "InDM", 1);
	PlayerInfo[playerid][inDMZone] = 7;
	gSAWNDMPlayers++;
	GameTextForPlayer(playerid, "~r~SAWN DM", 2000, 3);
	SendClientMessage(playerid, COLOR_FIREBRICK, "** Welcome to Sawn-Off Shotgun DM!");
	new Float:RandomSpawns[][] =
	{
	     {3152.3618,-953.6491,6.7844,86.4379},
	     {3070.5437,-972.6807,6.7766,335.2036},
	     {3149.2522,-871.6746,6.7766,171.9554},
	     {3092.6870,-866.5349,6.7766,177.2820}
	};
	if (IsPlayerInAnyVehicle(playerid))
	{
	    RemovePlayerFromVehicle(playerid);
	}
	new Random = random(sizeof(RandomSpawns));
	SetPlayerPosition(playerid, RandomSpawns[Random][0], RandomSpawns[Random][1], RandomSpawns[Random][2], RandomSpawns[Random][3]);
	SetPlayerTeam(playerid, playerid);
	SetPlayerVirtualWorld(playerid, 1);
	ResetPlayerWeapons(playerid);
	SetPlayerHealth(playerid, 100.0);
	GivePlayerWeapon(playerid, 26, 99999);

	new str[128];
	format(str, sizeof(str), ""GREEN":: {%06x}%s(%d) "TELEPORTBLUE"is in [/sawndm] Join and enjoy!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
	SendClientMessageToAll( -1, str );
	return 1;
}
CMD:skyroad(playerid) return cmd_skr(playerid);
CMD:skr(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 582.4474,-465.5596,967.7355,270.1676);
        SetCameraBehindPlayer(playerid);
    	GameTextForPlayer(playerid, "~r~Sky Road!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
    	SetPlayerPosition(playerid, 582.4474,-465.5596,967.7355,270.1676);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Sky Road!", 2000, 3);
	}
	return 1;
}

CMD:waterpark (playerid) return cmd_wp (playerid);
CMD:wp(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, -2091.8765,-2815.7871,2.8540,176.3349);
        SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~WaterPark!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -2090.1899,-2805.4836,5.0560,175.4590);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~WaterPark!", 2000, 3);
	}
	return 1;
}

CMD:lsair(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 2108.7258,-2622.6819,13.4520,26.5755);
        SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~LOS SANTOS AIRPORT!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 2131.5845,-2586.6755,13.5469,49.1485);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~LOS SANTOS AIRPORT!", 2000, 3);
	}
	return 1;
}
CMD:speedway(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, -3839.6672,-781.1722,8.2272,81.4949);
        SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~TBS Speedway!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -3839.6672,-781.1722,8.2272,81.4949);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~TBS Speedway!", 2000, 3);
	}
	return 1;
}

/*CMD:np(playerid) return cmd_nrgparadise(playerid);
CMD:nrgparadise(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		SetPlayerPosition(playerid, -902.4949,-3340.4727,23.2917,180.7586);
		PutPlayerInVehicle(playerid, 522, false);
		GameTextForPlayer(playerid, "~r~NRG Paradise!", 2000, 3);
  		TogglePlayerControllable(playerid, false);
		SetTimerEx("unfreezePlayer", 2000, false, "i", playerid);
		SetPlayerWeather(playerid, 10);
		SetPlayerTime(playerid, 22, 0);
		SetPVarInt(playerid, "TimeChanged", 1);
	}
	return 1;
}*/

CMD:jungle(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 368.6567,-3300.6040,22.5328,262.0000);
        SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Mysterious Island!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 368.6567,-3300.6040,22.5328,262.0000);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Mysterious Island!", 2000, 3);
	}
	return 1;
}

CMD:lsa (playerid)
{
	cmd_lsair(playerid);
	return 1;
}

CMD:halfpipe (playerid) return cmd_hp (playerid);
CMD:hp (playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 2850.7961,-1979.7196,10.5106,270.2350);
        SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~HALF PIPE!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 2850.0728,-1980.0901,10.9375,270.2634);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~HALF PIPE!", 2000, 3);
	}
	return 1;
}

CMD:monsterhay (playerid) return cmd_mh (playerid);
CMD:mh (playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, -1011.7576,-1053.8992,128.7751,89.5055);
        SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~MONSTER HAY!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -1011.5343,-1054.7983,129.2188,89.5055);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~MONSTER HAY!", 2000, 3);
	}
	return 1;
}

CMD:nascar (playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 345.9669,-3625.6270,14.3085,2.8007);
        SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~NASCAR TRACK!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 337.3819,-3618.0120,14.7719,337.3324);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~NASCAR TRACK", 2000, 3);
	}
	return 1;
}

CMD:dreamyland (playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 428.4504,-2362.8330,6.4905,183.7385);
        SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~DREAMY LAND!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 451.7907,-2359.9563,6.7827,150.2115);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~DREAMY LAND!", 2000, 3);
	}
	return 1;
}

CMD:dreamyland2(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 4040.1411,-2201.8506,10.2472,272.1080);
        SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~DREAMY LAND 2!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 4100.1548,-2261.5132,9.6847,3.0713);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~DREAMY LAND 2!", 2000, 3);
	}
	return 1;
}

CMD:dl1(playerid)
{
	cmd_dreamyland(playerid);
	return 1;
}

CMD:dl2(playerid)
{
	cmd_dreamyland2(playerid);
	return 1;
}

CMD:jump(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, -2554.8955,1997.5952,4232.6133,184.7054);
        SetCameraBehindPlayer(playerid);
		GivePlayerWeapon(playerid, 46, 3);
	    GameTextForPlayer(playerid, "~r~JUMP!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -2502.0732,1958.7637,4234.6372,111.8179);
	    SetCameraBehindPlayer(playerid);
		GivePlayerWeapon(playerid, 46, 3);
	    GameTextForPlayer(playerid, "~r~JUMP!", 2000, 3);
	}
	return 1;
}

CMD:fall(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, 1395.4395,-2427.0610,527.0104,269.2303);
        SetCameraBehindPlayer(playerid);
		GivePlayerWeapon(playerid, 46, 3);
	    GameTextForPlayer(playerid, "~r~FALL!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, 1384.1195,-2409.0605,526.7211,206.3774);
	    SetCameraBehindPlayer(playerid);
		GivePlayerWeapon(playerid, 46, 3);
	    GameTextForPlayer(playerid, "~r~FALL!", 2000, 3);
	}
	return 1;
}

CMD:transfender (playerid) return cmd_trans (playerid);
CMD:trans (playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, -1935.2509,232.1588,33.7177,1.2509);
        SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~TRANSFENDER!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -1935.1283,228.3820,34.1563,358.7603);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~TRANSFENDER!", 2000, 3);
	}
	return 1;
}

CMD:arch (playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
	    SetPlayerVehiclePos(playerid, -2707.3994,219.1495,3.7516,94.9521);
        SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Wheel Arch Angels!", 2000, 3);
	}
	else
	{
        RemovePlayerFromVehicle(playerid);
	    SetPlayerPosition(playerid, -2702.9683,218.0549,4.1797,92.8087);
	    SetCameraBehindPlayer(playerid);
	    GameTextForPlayer(playerid, "~r~Wheel Arch Angels!", 2000, 3);
	}
	return 1;
}

//-----------------
// Player Commands
//-----------------
CMD:songall(playerid, params[])
{
    if (INT_CheckPlayerAdminLevel(playerid, 6) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {0000FF}Manager/CEO {FF0000}to do this command!");
	{
		if(isnull(params))
		{
		    SendClientMessage(playerid, COLOR_RED, "USAGE: /songall [URL Must be .mp3]");
		    SendClientMessage(playerid, COLOR_RED, "NOTE: /stopsongall to stop music!");
		}
		else
		{
			new string[128], name[24];
            GetPlayerName(playerid,name,24);
            format(string,sizeof(string),""GREEN"Admin %s started a new song for all players!",name);
			SendClientMessageToAll(-1,string);
			for(new i;i<MAX_PLAYERS;i++)
			{
				PlayAudioStreamForPlayer(i, params);
			}
		}
	}
	return 1;
}
CMD:stopsongall(playerid)
{
    if (INT_CheckPlayerAdminLevel(playerid, 6) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {0000FF}Manager/CEO {FF0000}to do this command!");
	{
	    for(new i;i<MAX_PLAYERS;i++)
	    {
	        StopAudioStreamForPlayer(i);
	    }
	}
	return 1;
}

CMD:song(playerid, params[])
{
   if(isnull(params))
   {
        SendClientMessage(playerid, COLOR_RED, "USAGE: /song [URL Must be .mp3]");
        SendClientMessage(playerid, COLOR_RED, "NOTE: /stop to stop music!");
   }
   else
   {
        {
			PlayAudioStreamForPlayer(playerid, params);
			SendClientMessage(playerid, COLOR_GREEN, "Now playing your song!"  ";)");
		}
    }
    return 1;
}

CMD:fireext(playerid, params[],help)
{
    new org=-1;
    if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
	if(GangInfo[org][AllowedFD] == 1)
	{
	    if(IsPlayerInRangeOfPoint(playerid,2,GangInfo[org][duX],GangInfo[org][duY],GangInfo[org][duZ]))
	    {
			if(Fire == 1)
			{
				GivePlayerWeapon(playerid,42,999);
				SendClientMessage(playerid,-1,"You pickup fire extinguisher!");
			}
			else return SendClientMessage(playerid,-1,"No fire right now!");
		}else return SendClientMessage(playerid,-1,""RED"You arent close to cabinets!");
	}
	else{SendClientMessage(playerid,SRED,"You arent member of FD!");}
	return 1;
}

CMD:editfire(playerid,params[],help)
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,-1,"{0000FF}[Gang] {C0C0C0}Only owner");
	ShowPlayerDialog(playerid, DIALOG_VATRA, 1, ""WHITE"Fire", ""WHITE"Enter ID of the fire you want to edit", "Further", "Cancel");
    return 1;
}

/*CMD:flocate(playerid, params[],help)
{
    new org=-1;
    if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
	if(GangInfo[org][AllowedPD] == 1 || GangInfo[org][AllowedFD] == 1)
	{
		if(Fire == 1)
		{
			SetPlayerCheckpoint(playerid,FireInfo[Fireid][GX],FireInfo[Fireid][GY],FireInfo[Fireid][GZ],5.0);
			SendClientMessage(playerid,SRED,"[Headquaters]: {33CCFF}Fire located on your GPS!");
		}
		else return SendClientMessage(playerid,-1,"No fire right now!");
	}
	else{SendClientMessage(playerid,SRED,"You arent member of FD!");}
	return 1;
}*/

/*CMD:fire(playerid, params[],help)
{
	if(IsPlayerAdmin(playerid))
	{
		CreateFire();
		SendClientMessage(playerid,-1,"You created fire for FD!");
	}
	return 1;
}*/

CMD:createfire(playerid,params[],help)
{
    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid,-1,"{0000FF}[Gang] {C0C0C0}Owner Only!");
    new id=getEmptyID(MAX_FIRE,"Gangs/Fire/%d.ini");
    FireInfo[id][GX]=0;
    FireInfo[id][GY]=0;
    FireInfo[id][GZ]=0;
    FireInfo[id][GX1]=0;
    FireInfo[id][GY1]=0;
    FireInfo[id][GZ1]=0;
    FireInfo[id][GX2]=0;
    FireInfo[id][GY2]=0;
    FireInfo[id][GZ2]=0;
    FireInfo[id][GX3]=0;
    FireInfo[id][GY3]=0;
    FireInfo[id][GZ3]=0;
    FireInfo[id][GX4]=0;
    FireInfo[id][GY4]=0;
    FireInfo[id][GZ4]=0;
    FireNumber++;
    SaveFire(id);
    SendClientMessage(playerid,-1,"{FF9900}successful created fire folder!");
    return 1;
}

CMD:arrest(playerid, params[],help)
{
    new Razlog;
	new IDKojegZatvaras;
	new Vrijeme;
	new org=-1;
    if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
	if(GangInfo[org][AllowedPD] == 0) return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}This gang does not have allowed PD commands!");
	if(sscanf(params, "udd",IDKojegZatvaras,Vrijeme,Razlog)) return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/arrest [ID] [Time] [Price]");
	else
	{
	if(PlayerInfo[IDKojegZatvaras][WantedLevel] == 0) return SendClientMessage(playerid,SEABLUE,"The player must be claimed by law!");
	if(IsPlayerInRangeOfPoint(playerid,15.0,GangInfo[org][puX], GangInfo[org][puY], GangInfo[org][puZ]) && IsPlayerInRangeOfPoint(IDKojegZatvaras,15.0,GangInfo[org][puX], GangInfo[org][puY], GangInfo[org][puZ]))
	{
	new Poruka[220];
	format(Poruka,sizeof(Poruka),"{FF9900}You're under arrest by a police officer {FF0000}%s {FF9900}for {FF0000}%d {FF9900}minutes and {FF0000}%d$",GetName(playerid),Vrijeme,Razlog);
	SendClientMessage(IDKojegZatvaras,-1,Poruka);
	format(Poruka,sizeof(Poruka),"{FF9900}You arrested {FF0000}%s {FF9900}in jail for {FF0000}%d {FF9900}ninutes and {FF0000}%d$",GetName(IDKojegZatvaras),Vrijeme,Razlog);
	SendClientMessage(playerid,-1,Poruka);
	new org2=-1;
    if(PlayerInfo[IDKojegZatvaras][aLeader] > -1)
	{
		org2 = PlayerInfo[IDKojegZatvaras][aLeader];
	}
	if(PlayerInfo[IDKojegZatvaras][aMember] > -1)
	{
		org2 = PlayerInfo[IDKojegZatvaras][aMember];
	}
	if(org2>-1)
	{
	if(GangInfo[org2][AllowedH] == 1) format(Poruka,sizeof(Poruka),"{FF0000}News: {FFFFFF}%s {FF9900}was arrested for multiple murders,arrested him {FFFFFF}%s",GetName(IDKojegZatvaras),GetName(playerid));
    else if(GangInfo[org2][AllowedF] == 1 && GangInfo[org2][AllowedH] == 0) format(Poruka,sizeof(Poruka),"{FF0000}News: {FFFFFF}%s {FF9900}was arrested for multiple robberies committed,arrested him {FFFFFF}%s",GetName(IDKojegZatvaras),GetName(playerid));
    else format(Poruka,sizeof(Poruka),"{FF0000}News: {FFFFFF}%s {FF9900}was arrested for unknown reasons, arrested him {FFFFFF}%s",GetName(IDKojegZatvaras),GetName(playerid));
    }
    else format(Poruka,sizeof(Poruka),"{FF0000}News: {FFFFFF}%s {FF9900}was arrested for unknown reasons, arrested him {FFFFFF}%s",GetName(IDKojegZatvaras),GetName(playerid));
	SendClientMessageToAll(-1,Poruka);
	GJailed[IDKojegZatvaras] = 1;
	GivePlayerMoneyEx(playerid,-Razlog);
	new VrijemeZatvora = Vrijeme*60000;
	GJailTime[IDKojegZatvaras] = VrijemeZatvora;
	SetTimerEx("GJailTimer", 1000,false,"id",IDKojegZatvaras,org);
	SetPlayerPos(IDKojegZatvaras,GangInfo[org][arX],GangInfo[org][arY],GangInfo[org][arZ]);
	RemovePlayerAttachedObject(IDKojegZatvaras, 0);
	SetPlayerSpecialAction(IDKojegZatvaras, SPECIAL_ACTION_NONE);
	TogglePlayerControllable(IDKojegZatvaras,1);
	}else{SendClientMessage(playerid,-1,"{FF0000}Not in the range of the prison can not arrest suspect!");}
	}
	return 1;
}

CMD:uncuff(playerid, params[],help)
{
	new org=-1;
    if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
	if(GangInfo[org][AllowedPD] == 0) return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}This gang does not have allowed PD commands!");
 	new user;
	if(sscanf(params, "u",user)) return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/uncuff [Player]");
	else
	{
 		new Float:Xa, Float:Za, Float:Ya;
   		GetPlayerPos(user,Xa,Ya,Za);
	    if(IsPlayerInRangeOfPoint(playerid,6.0,Xa,Ya,Za))
	    {
			GameTextForPlayer(user, "~r~Uncuffed!", 2500, 3);
			RemovePlayerAttachedObject(user, 0);
			SetPlayerSpecialAction(user, SPECIAL_ACTION_NONE);
			new str[50];
			format(str,sizeof(str),"{949294}* You are uncuff %s",GetName(user));
			SendClientMessage(playerid,-1,str);
			TogglePlayerControllable(user,1);
		}
	}
	return 1;
}
CMD:gcuff(playerid, params[],help)
{
	new org=-1;
    if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
	if(GangInfo[org][AllowedPD] == 0) return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}This gang does not have allowed PD commands!");
 	new user;
	if(sscanf(params, "u",user)) return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/gcuff [Player]");
	else
	{
 		new Float:Xa, Float:Za, Float:Ya;
   		GetPlayerPos(user,Xa,Ya,Za);
   		new org2=-1;
	    if(PlayerInfo[user][aLeader] > -1)
		{
			org2 = PlayerInfo[user][aLeader];
		}
		if(PlayerInfo[user][aMember] > -1)
		{
			org2 = PlayerInfo[user][aMember];
		}
		if(org2>-1)
		{
	    	if(GangInfo[org2][AllowedPD] == 1){return SendClientMessage(playerid,-1,"{FF0000}You can not cuff members of the police!");}
	    }
	    if(IsPlayerInRangeOfPoint(playerid,6.0,Xa,Ya,Za))
	    {
     		RemovePlayerAttachedObject(user, 0);
			GameTextForPlayer(user, "~r~Cuffed!", 2500, 3);
			SetPlayerAttachedObject(user, 0, 19418, 6, -0.011000, 0.028000, -0.022000, -15.600012, -33.699977, -81.700035, 0.891999, 1.000000, 1.168000);
   			new str[50];
			format(str,sizeof(str),"{949294}* You are cuff %s",GetName(user));
			SendClientMessage(playerid,-1,str);
			TogglePlayerControllable(user,0);
			SetPlayerSpecialAction(user, SPECIAL_ACTION_CUFFED);
		}
	}
	return 1;
}

CMD:radar(playerid, params[],help)
{
    new org=-1;
    if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
	if(GangInfo[org][AllowedPD] == 0) return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}This gang does not have allowed PD commands!");
	if(PlacedRadar[playerid] == 0)
	{
		new cijena,brzina;
  		if(sscanf(params, "dd",brzina,cijena)) return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {FF0000}/radar [Max.Speed] [Price]");
		else
		{
  			new Float:raX,Float:raY,Float:raZ;
	    	GetPlayerPos(playerid, raX, raY, raZ);
		    GetXYInFrontOfPlayer(playerid, raX, raY, 2);
			PlacedRadar[playerid] = 1;
   			SpeedRadar[playerid] = brzina;
		    PriceRadar[playerid] = cijena;
		    RadarObject[playerid] = CreateDynamicObject(18880, raX,raY,raZ-2.5,0.0,0.0,0.0);
		    new str[180];
		    format(str,sizeof(str),"\n%s\n{33CCFF}Max Speed: {FFFFFF}%d km/h\n{33CCFF}Ticket Price:{FFFFFF} %d$",GetName(playerid),brzina,cijena);
      		RadarLabel[playerid] = CreateDynamic3DTextLabel(str,0x008080FF,raX, raY, raZ+2, 30, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0);
		}
	}else{SendClientMessage(playerid,-1,"{FF0000}* You have already set up radar!");}
	return 1;
}

CMD:removeradar(playerid, params[],help)
{
    new org=-1;
    if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
	if(GangInfo[org][AllowedPD] == 0) return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}This gang does not have allowed PD commands!");
 	if(PlacedRadar[playerid] == 1)
	{
 		new Float:rX,Float:rY,Float:rZ;
   		GetDynamicObjectPos(RadarObject[playerid],rX,rY,rZ);
     	if(IsPlayerInRangeOfPoint(playerid,6.0,rX,rY,rZ))
      	{
       	DestroyDynamicObject(RadarObject[playerid]);
		PlacedRadar[playerid] = 0;
		SendClientMessage(playerid,SEABLUE,"Radar removed!");
		DestroyDynamic3DTextLabel(RadarLabel[playerid]);
  		}else{SendClientMessage(playerid,-1,"{FF0000}* You are not near your radar!");}

	}else{SendClientMessage(playerid,-1,"{FF0000}* You have not placed radar!");}
	return 1;
}

CMD:su(playerid, params[],help)
{
    new org=-1;
    if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
	if(GangInfo[org][AllowedPD] == 0) return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}This gang does not have allowed PD commands!");
	new razlog[60],id;
	if(sscanf(params, "us[60]",id,razlog)) return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/su [ID/Name] [Reason]");
	else
	if(id != INVALID_PLAYER_ID)
	{
	new org2=-1;
    if(PlayerInfo[id][aLeader] > -1)
	{
		org2 = PlayerInfo[id][aLeader];
	}
	if(PlayerInfo[id][aMember] > -1)
	{
		org2 = PlayerInfo[id][aMember];
	}
	if(org2>-1)
	{
	if(GangInfo[org2][AllowedPD]==1){return SendClientMessage(playerid,SEABLUE,"You can not accuse the police!");}
	}
	PlayerInfo[id][WantedLevel] +=1;
 	SetPlayerWantedLevel(id,PlayerInfo[id][WantedLevel]);
  	new String[200];
   	format(String,sizeof(String),"{FF0000}|{FF9900} Crime: {FFFFFF}%s {FF0000}| {FF9900}Reported: {FFFFFF}%s {FF0000}|",razlog,GetName(playerid));
    SendClientMessage(id,-1,String);
	format(String,sizeof(String),"{0099CC}|Police| {FF9900}Crime: {FFFFFF}%s | {FF9900}Person: {FFFFFF}%s | {FF9900}Reported: {FFFFFF}%s",razlog,GetName(id),GetName(playerid));
 	DChat(String);
	}else{SendClientMessage(playerid,SEABLUE,"Wrong ID!");}
	return 1;
}

CMD:pu(playerid, params[],help)
{
    new org=-1;
    if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
	if(GangInfo[org][AllowedPD] == 0) return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}This gang does not have allowed PD commands!");
 	new mjesto,id;
 	if(sscanf(params, "ud",id,mjesto)) return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/pu [ID/Name] [Place (1-3)]");
	else
	if(id != INVALID_PLAYER_ID)
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
  			new Float:aaX,Float:aaY,Float:aaZ;
	    	GetPlayerPos(id,aaX,aaY,aaZ);
		    if(IsPlayerInRangeOfPoint(playerid,6.0,aaX,aaY,aaZ))
		    {
      			if(!IsPlayerInAnyVehicle(id))
	        	{
	    			new vehicleid = GetPlayerVehicleID(playerid);
			    	PutPlayerInVehicle(id, vehicleid, mjesto);
				}else{SendClientMessage(playerid,SEABLUE,"* This person is already in the vehicle!");}
			}else{SendClientMessage(playerid,SEABLUE,"* This person is not close to you!");}
		}else{SendClientMessage(playerid,SEABLUE,"* You must be in the vehicle!");}
	}else{SendClientMessage(playerid,SEABLUE,"* Wrong ID!");}
	return 1;
}

CMD:wanted(playerid, params[],help)
{
    new org=-1;
    new info[2048],prov=0;
    if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
	if(GangInfo[org][AllowedPD] == 0) return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}This gang does not have allowed PD commands!");
	strcat(info, ""YELLOW"Wanted\n\n", sizeof(info));
	for(new i = 0; i != MAX_PLAYERS; i++)
	{
		if(PlayerInfo[i][WantedLevel] != 0)
 		{
		       	new String[200];
		        format(String,sizeof(String),"{FF0000}|{FF9900}Wanted{FF0000}| {FF9900}Player: {FFFFFF}%s {FF0000}| {FF9900}WL: {FFFFFF}%d {FF0000}| {FF9900}ID player: {FFFFFF}%d {FF0000}|\n",GetName(i),PlayerInfo[i][WantedLevel],i);
		        strcat(info, String, sizeof(info));
		        prov=1;
		}
   	}
   	if(prov==0)
   	{
   		strcat(info, "{FF9900}There are currently no wanted persons!", sizeof(info));
   	}
	ShowPlayerDialog(playerid, DIALOG_TARGETS, DIALOG_STYLE_MSGBOX, ""WHITE"Wanted", info, "OK", "");
	return 1;
}

CMD:ticket(playerid, params[],help)
{
    new org=-1;
    if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
	if(GangInfo[org][AllowedPD] == 0) return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}This gang does not have allowed PD commands!");
	new id, cjena, razlog[32], Float:Poz[3],String[150];
	if(sscanf(params, "uis[32]", id, cjena, razlog)) return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/ticket [Player ID] [Price (1-2000)] [Reason]");
	if(!IsPlayerConnected(id)) return SendClientMessage(playerid, -1, "{FF0000}This player is offline!");
	if(id == playerid) return SendClientMessage(playerid, -1, "{FF0000}You can not write ticket to you!");
	if(cjena < 1 || cjena > 2000) return SendClientMessage(playerid, -1, "{FF0000}Price may be the least $1, and most $2000!");
	if(strlen(razlog) > 32) return SendClientMessage(playerid, -1, "{FF0000}Too long a reason!");
	GetPlayerPos(id, Poz[0], Poz[1], Poz[2]);
	if(!IsPlayerInRangeOfPoint(playerid, 5.0, Poz[0], Poz[1], Poz[2])) return SendClientMessage(playerid, -1, "{FF0000}You are too far!");
	TicketWrote[id] = playerid;
	TicketPrice[id] = cjena;
	format(String,sizeof(String),"Police officer %s you wrote a ticket of $%d. Reason: {FFFFFF}%s",GetName(playerid), cjena, razlog);
	ShowPlayerDialog(id, DIALOG_TICKET, DIALOG_STYLE_MSGBOX, ""WHITE"Penalty", String, "Pay", "Cancel");
	format(String,sizeof(String),"You have written a ticket player %s of $%d. Reason: {FFFFFF}%s",GetName(id), cjena, razlog);
	SendClientMessage(playerid,SEABLUE,String);
	return 1;
}

CMD:m(playerid,params[],help)
{
    new org=-1,prov=0;
    new vehicleid=GetPlayerVehicleID(playerid);
	if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
	if(GangInfo[org][AllowedPD] == 0) return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}This gang does not have allowed PD commands!");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}You are not in the vehicle!");
	for(new i = 0; i < 15; i++)
	{
		if(vehicleid == GVehID[org][i])
		{
		 	new string[250];
		 	if(sscanf(params, "s[250]",string)) return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/m [text]");
		 	{
			 	new stringa[250];
			 	format(stringa,sizeof(stringa),"%s | %s megaphone: %s",GangInfo[org][Name],GetName(playerid),string);
			 	ProxDetector(20.0, playerid, stringa,AYELLOW,AYELLOW,AYELLOW,AYELLOW,AYELLOW);
			 	prov=1;
		 	}
	 	}
	}
	if(prov==0) return SendClientMessage(playerid,-1,"You are not in the vehicle of your organization!");
	return 1;
}

CMD:targets(playerid,params[],help)
{
    new info[2048],prov=0;
	if(PlayerInfo[playerid][aLeader] < 0 && PlayerInfo[playerid][aMember] < 0 )  return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}You are not a member of any gang!");
	new org;
	if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
	if(GangInfo[org][AllowedH] == 0) return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}This gang does not have allowed Hitman commands!");
    strcat(info, ""YELLOW"Targets\n\n", sizeof(info));
    if(PlayerInfo[playerid][Rank] > 3)
 	{
  		for(new i = 0; i != MAX_PLAYERS; i++)
		{
  			if(PlayerInfo[i][Target] != 0)
	    	{
      			if(PlayerInfo[i][HaveTarget] == 0)
	        	{
		        	new String[250];
			        format(String,sizeof(String),"{FF0000}|Target| {FF9900}Player: {FFFFFF}%s {FF0000}| {FF9900}Price: {FFFFFF}%d$ {FF0000}| {FF9900}ID Target: {FFFFFF}%d {FF0000}|\n",GetName(i),PlayerInfo[i][TargetPrice],i);
			        strcat(info, String, sizeof(info));
			        prov=1;
				}
			}
		}
   	}
   	if(prov==0)
   	{
   		strcat(info, "{FF9900}There are currently no targets!", sizeof(info));
   	}
	ShowPlayerDialog(playerid, DIALOG_TARGETS, DIALOG_STYLE_MSGBOX, ""WHITE"Targets", info, "OK", "");
    return 1;
}

CMD:givetarget(playerid, params[],help)
{
	new user,meta;
	if(sscanf(params, "uu",user, meta)) return SendClientMessage(playerid, SEABLUE, "Usage:{FFFFFF} /givetarget [ID player] [ID Target]");
	else
	{
	        if(PlayerInfo[playerid][aLeader] < 0 && PlayerInfo[playerid][aMember] < 0 )  return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}You are not a member of any gang!");
			new org;
			if(PlayerInfo[playerid][aLeader] > -1)
			{
				org = PlayerInfo[playerid][aLeader];
			}
			if(PlayerInfo[playerid][aMember] > -1)
			{
				org = PlayerInfo[playerid][aMember];
			}
			if(GangInfo[org][AllowedH] == 0) return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}This gang does not have allowed Hitman commands!");
	        if(PlayerInfo[playerid][Rank] > 3)
	        {
			    if(PlayerInfo[meta][HaveTarget] == 0)
			    {
			        if(PlayerInfo[meta][Target] != 0)
			    	{
				        if(PlayerInfo[user][HaveVictim] == 0)
				        {
				            if(PlayerInfo[user][aMember] == org || PlayerInfo[user][aLeader] == org)
				            {
							    PlayerInfo[meta][HaveTarget] = 1;
								PlayerInfo[user][HaveVictim] = 1;
						    	format(PlayerInfo[user][NameVictim],24,"%s",GetName(meta));
						    	format(PlayerInfo[user][NameTarget],24,"%s",GetName(user));
								new String[125];
								format(String,sizeof(String),"You give target %s to %s",GetName(meta),GetName(user));
								SendClientMessage(playerid,AYELLOW,String);
								format(String,sizeof(String),"Hitman %s has give you target %s",GetName(playerid),GetName(meta));
								SendClientMessage(user,AYELLOW,String);
							}
							else{SendClientMessage(playerid,AYELLOW,"That player isnt Hitman!");}
						}
						else{SendClientMessage(playerid,AYELLOW,"That Hitman have target!");}
					}
					else{SendClientMessage(playerid,AYELLOW,"That player isnt target!");}
			    }
			    else{SendClientMessage(playerid,AYELLOW,"That target doesnt exist!");}

		    }
		    else{SendClientMessage(playerid,AYELLOW,"Just RANK 4+");}
	}
	return 1;
}

CMD:contract(playerid, params[],help)
{
	new user,cijena;
	if(sscanf(params, "ud",user, cijena)) return SendClientMessage(playerid, -1, "Usage:{FFFFFF} /contract [ID] [Price]");
	else
	{
		if(user == INVALID_PLAYER_ID) return SendClientMessage(playerid,-1,"Wrong ID");
		if(user == playerid) return SendClientMessage(playerid, -1, "You can not contract yourself!");
		if(PlayerInfo[user][aLeader] == PlayerInfo[playerid][aLeader]) return SendClientMessage(playerid, -1, "You cant contract your boss!");
		if(cijena > 1000)
		{
	 		if(GetPlayerMoneyEx(playerid) > cijena)
	   		{
	     		PlayerInfo[user][Target] = 1;
	       		PlayerInfo[user][TargetPrice] = PlayerInfo[user][TargetPrice]+cijena;
		        GivePlayerMoneyEx(playerid,-cijena);
		        new String[230];
		        format(String,sizeof(String),"You contract %s for %d$",GetName(user),cijena);
		        SendClientMessage(playerid,-1,String);
		        format(String,sizeof(String),"|News| New target: %s | Price: %d$ | Contract: %s | ID Target: %d |",GetName(user),cijena,GetName(playerid),user);
		        HChat(String);
		    }
		    else{SendClientMessage(playerid,-1,"You do not have that much money!!");}

		}
		else{SendClientMessage(playerid,-1,"Price need to be more than 1000$!!");}
	}
	return 1;
}

CMD:laptop(playerid, params[],help)
{
if(PlayerInfo[playerid][aLeader] < 0 && PlayerInfo[playerid][aMember] < 0 )  return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}You are not a member of any gang!");
new org;
if(PlayerInfo[playerid][aLeader] > -1)
{
	org = PlayerInfo[playerid][aLeader];
}
if(PlayerInfo[playerid][aMember] > -1)
{
	org = PlayerInfo[playerid][aMember];
}
orga[playerid]=org;
if(GangInfo[org][AllowedH] == 0) return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}This gang does not have allowed Hitman commands!");
ShowPlayerDialog(playerid, DIALOG_LAPTOP, DIALOG_STYLE_LIST, "Laptop", " Targets\n Your target\n Pakets", "OK", "Cancel");
return 1;
}

CMD:editing(playerid,params[],help)
{
    if (INT_CheckPlayerAdminLevel(playerid, 6) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {0000FF}Manager/CEO {FF0000}to do this command!");
	ShowPlayerDialog(playerid, DIALOG_GANG, 1, ""WHITE"Editing", ""WHITE"Enter the ID of the gang you want to edit", "Next", "Cancel");
    return 1;
}

CMD:gangs(playerid,params[])
{
	ShowGangs(playerid);
 	return 1;
}

CMD:ganghelp(playerid,params[],help)
{
    new info[2048];
	if(INT_CheckPlayerAdminLevel(playerid, 6) == 0 && PlayerInfo[playerid][aLeader] < 0) return SendClientMessage(playerid,SRED,"You are not allowed!");
    if(INT_CheckPlayerAdminLevel(playerid, 6) == 0)
    {
	    strcat(info, "{FF0000}/Create/Delete gang\n", sizeof(info));
		strcat(info, "{C0C0C0}/creategang-Create file of the gang\n", sizeof(info));
		strcat(info, " /deletegang-Delete gang,all vehicles of gang,pickups and labels\n", sizeof(info));
		strcat(info, "{FF0000}Adding/Removing vehicles\n", sizeof(info));
		strcat(info, "{C0C0C0}/addvehicle-You create a vehicle for a particular gang that you selected\n", sizeof(info));
		strcat(info, "/deletevehicle-Deletes a specified vehicle from the gang that you selected\n", sizeof(info));
		strcat(info, "/agangpark-Park the car at the coordinates where you are now\n", sizeof(info));
		strcat(info, "{FF0000}Make/Remove Leader\n", sizeof(info));
		strcat(info, "{C0C0C0}/makeleader-You give leader certain player\n", sizeof(info));
		strcat(info, "/leaderslist-See the list of leaders in a particular gang\n", sizeof(info));
		strcat(info, "/removeleader-Removing the leader of a particular person in a particular gang\n", sizeof(info));
		strcat(info, "{FF0000}Editing\n", sizeof(info));
		strcat(info, "{C0C0C0}/editing-Editing skins,names of ranks,name of the gang,coordinates\n", sizeof(info));
		strcat(info, "/fire - Creating fire for firefighters\n", sizeof(info));
		strcat(info, "/makefire - Creating a file where fire will be saved\n", sizeof(info));
		strcat(info, "/editfire - Using this command you can save coordinates where fire object will be created at specific fire ID\n", sizeof(info));
	}
	if(PlayerInfo[playerid][aLeader] > -1)
	{
		strcat(info, "{FF0000}Leader commands\n", sizeof(info));
		strcat(info, "{C0C0C0}/invite-Invite player to your gang\n", sizeof(info));
		strcat(info, "/uninvite-Kick player from your gang\n", sizeof(info));
		strcat(info, "/members-See list of online members in your gang\n", sizeof(info));
		strcat(info, "/allmembers-See all members of your gang\n", sizeof(info));
		strcat(info, "/f-Chat of your gang\n", sizeof(info));
		strcat(info, "/giverank-Give a certain rank members of your gang\n", sizeof(info));
		strcat(info, "/laptop-Some options for Hitmans\n", sizeof(info));
		strcat(info, "/givetarget-Give target to memeber of your gang\n", sizeof(info));
		strcat(info, "/targets-View the available targets\n", sizeof(info));
	}
	ShowPlayerDialog(playerid, DIALOG_GANGHELP, DIALOG_STYLE_MSGBOX, ""WHITE"Gang Help", info, "Ok", "");
    return 1;
}

CMD:deletegang(playerid,params[],help)
{
    if (INT_CheckPlayerAdminLevel(playerid, 6) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {0000FF}Manager/CEO {FF0000}to do this command!");
    new org;
    if(sscanf(params,"i",org)) return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/deletegang [ID Gang]");
    new oFile[50];
	format(oFile, sizeof(oFile), GANGS, org);
    if(fexist(oFile))
    {
	    for(new i=0;i<15;i++)
	    {
		    DestroyVehicle(GVehID[org][i]);
		    vCreated[org][i]=0;
		    GVehID[org][i] = 0;
			DestroyDynamicPickup(GangPickup[org]);
			DestroyDynamicPickup(GangPickup2[org]);
			DestroyDynamic3DTextLabel(GangLabel[org]);
	    }
	    strmid(Leader[0][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Leader[1][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[0][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[1][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[2][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[3][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[4][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[5][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[6][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[7][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[8][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[9][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[10][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[11][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(GangInfo[org][Name],"No name",0,strlen("No name"),255);
	    strmid(GangInfo[org][Rank1],"Rank 1",0,strlen("Rank 1"),255);
	    strmid(GangInfo[org][Rank2],"Rank 2",0,strlen("Rank 2"),255);
	    strmid(GangInfo[org][Rank3],"Rank 3",0,strlen("Rank 3"),255);
	    strmid(GangInfo[org][Rank4],"Rank 4",0,strlen("Rank 4"),255);
	    strmid(GangInfo[org][Rank5],"Rank 5",0,strlen("Rank 5"),255);
	    strmid(GangInfo[org][Rank6],"Leader",0,strlen("Leader"),255);
	    GangInfo[org][uX] = 0;
	    GangInfo[org][uY] = 0;
	    GangInfo[org][uZ] = 0;
	    GangInfo[org][sX] = 0;
	    GangInfo[org][sY] = 0;
	    GangInfo[org][sZ] = 0;
	    fremove(oFile);
	    SendClientMessage(playerid,-1,"{00C0FF}Successfully deleted gang!");
    }else return SendClientMessage(playerid,SRED,"This gang does not exist!");
    return 1;
}
CMD:agangpark(playerid,params[],help)
{
    new org,slot;
    if (INT_CheckPlayerAdminLevel(playerid, 6) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {0000FF}Manager/CEO {FF0000}to do this command!");
    if(sscanf(params,"dd",org,slot)) return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/agangpark [ID gang][Vehicle slot]");
    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,SRED,"You must be in the vehicle!");
    new oFile[50];
	format(oFile, sizeof(oFile), GANGS, org);
    if(!fexist(oFile))return SendClientMessage(playerid,SRED,"This gang does not exist!");
	new Float:gx,Float:gy,Float:gz,Float:ga;
	GetVehiclePos(GetPlayerVehicleID(playerid),gx,gy,gz);
	GetVehicleZAngle(GetPlayerVehicleID(playerid),ga);
	Vehicle[org][0][slot] = gx;
	Vehicle[org][1][slot] = gy;
	Vehicle[org][2][slot] = gz;
	Vehicle[org][3][slot] = ga;
    SaveGangs(org);
    DestroyVehicle(GVehID[org][slot]);
    GVehID[org][slot] = CreateVehicle(VehiclesID[org][slot],Vehicle[org][0][slot],Vehicle[org][1][slot],Vehicle[org][2][slot],Vehicle[org][3][slot],VehiclesColor[org][slot],VehiclesColor[org][slot],30000);
    SendClientMessage(playerid,-1,"{00C0FF}Coordinates successfully saved!");
    return 1;
}
CMD:deletevehicle(playerid,params[],help)
{
    new org,auid;
    if (INT_CheckPlayerAdminLevel(playerid, 6) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {0000FF}Manager/CEO {FF0000}to do this command!");
    if(sscanf(params,"dd",org,auid)) return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/deletevehicle [ID gang][Vehicle slot]");
    if(vCreated[org][auid] == 0) return SendClientMessage(playerid,SRED,"This vehicle is not created!");
    new oFile[50];
	format(oFile, sizeof(oFile), GANGS, org);
    if(!fexist(oFile))return SendClientMessage(playerid,SRED,"This gang does not exist!");
    DestroyVehicle(GVehID[org][auid]);
    vCreated[org][auid] = 0;
    Vehicle[org][0][auid] = 0.000000;
	Vehicle[org][1][auid] = 0.000000;
	Vehicle[org][2][auid] = 0.000000;
	Vehicle[org][3][auid] = 0.000000;
	VehiclesID[org][auid] = 0;
    VehiclesColor[org][auid] = 0;
    GVehID[org][auid] = 0;
    SendClientMessage(playerid,-1,"{00C0FF}The vehicle successfully deleted!");
    SaveGangs(org);
    return 1;
}
CMD:leaderslist(playerid,params[],help)
{
    new org;
    if (INT_CheckPlayerAdminLevel(playerid, 6) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {0000FF}Manager/CEO {FF0000}to do this command!");
    if(sscanf(params,"d",org)) return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/leaderslist [ID gang]");
    new oFile[50];
 	format(oFile, sizeof(oFile), GANGS, org);
  	if(!fexist(oFile)) return SendClientMessage(playerid,SRED,"This gang does not exist!");
    new str[128];
    /*SendClientMessage(playerid, -1, " ");
	SendClientMessage(playerid, -1, " ");
	SendClientMessage(playerid, -1, " ");
	SendClientMessage(playerid, -1, " ");*/
	format(str,256,"{00C0FF}Leaders: %s",GangInfo[org][Name]);
	SendClientMessage(playerid,-1,str);
	format(str,256,"Leader 1: %s| Leader 2:%s",Leader[0][org],Leader[1][org]);
	SendClientMessage(playerid, 0xFFFDD1aa, str);
    return 1;
}
CMD:removeleader(playerid,params[],help)
{
    new ime[128],org;
    if (INT_CheckPlayerAdminLevel(playerid, 6) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {0000FF}Manager/CEO {FF0000}to do this command!");
    if(sscanf(params,"ds",org,ime)) return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/removeleader [ID gang][Name_Surname]");
    new cl=-1;
    for(new i=0;i<2;i++)
    {
	    if(udb_hash(Leader[i][org]) == udb_hash(ime))
	   	{
	    	cl=i;
	    }
    }
    if(cl==-1)return SendClientMessage(playerid,SRED,"This person is not a leader of this gang!");
    new m[24]; format(m,24,"Leader%d",cl+1);
    new dFile1[50];
	format(dFile1, sizeof(dFile1), GANGS, org);
 	new INI:File = INI_Open(dFile1);
 	INI_SetTag(File, "Gang");
 	INI_WriteString(File,m,"Nobody");
	INI_Close(File);
	strmid(Leader[cl][org],"Nobody",0,strlen("Nobody"),255);
	new ida = GetPlayerID(ime);
	if(IsPlayerConnected(ida))
	{
		SendClientMessage(ida,-1,"{00C0FF}You're off the position of leader!");
		PlayerInfo[ida][aLeader] = -1;
		PlayerInfo[ida][pSkin] = 0;
		SetPlayerSkin(ida, PlayerInfo[ida][pSkin]);
		SavePlayer(ida);
	}
    return 1;
}

CMD:f(playerid, params[],help)
{
    #pragma unused help
	new tekst[256];
	if(PlayerInfo[playerid][aLeader] < 0 && PlayerInfo[playerid][aMember] < 0 )  return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}You are not a member of any gang!");
	if (sscanf(params, "s[90]", tekst))  return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/f [Text]");
	new org;
	new rak[128];
    if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
	if(GangInfo[org][AllowedF] == 0) return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}This gang does not have allowed /f chat!");
	if(PlayerInfo[playerid][Rank] == 1)
	{
		strmid(rak,GangInfo[org][Rank1],0,strlen(GangInfo[org][Rank1]),255);
	}
	if(PlayerInfo[playerid][Rank] == 2)
	{
		strmid(rak,GangInfo[org][Rank2],0,strlen(GangInfo[org][Rank2]),255);
	}
	if(PlayerInfo[playerid][Rank] == 3)
	{
		strmid(rak,GangInfo[org][Rank3],0,strlen(GangInfo[org][Rank3]),255);
	}
	if(PlayerInfo[playerid][Rank] == 4)
	{
		strmid(rak,GangInfo[org][Rank4],0,strlen(GangInfo[org][Rank4]),255);
	}
	if(PlayerInfo[playerid][Rank] == 5)
	{
		strmid(rak,GangInfo[org][Rank5],0,strlen(GangInfo[org][Rank5]),255);
	}
	if(PlayerInfo[playerid][Rank] == 6)
	{
		strmid(rak,GangInfo[org][Rank6],0,strlen(GangInfo[org][Rank6]),255);
	}
	new string[256];
	format(string, sizeof(string), "{FF9933}Gang[F] Chat | {FFFFFF}%s: {FF9933}(%s): {C0C0C0}%s", GetName(playerid),rak, params[0] );
	return ChatGang(org,string);
}
CMD:r(playerid, params[],help)
{
    #pragma unused help
	new tekst[256];
	if(PlayerInfo[playerid][aLeader] < 0 && PlayerInfo[playerid][aMember] < 0 )  return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}You are not a member of any gang!");
	if (sscanf(params, "s[90]", tekst))  return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/r [Text]");
	new org;
	new rak[128];
    if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
	if(GangInfo[org][AllowedR] == 0) return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}This gang does not have allowed /r chat!");
	if(PlayerInfo[playerid][Rank] == 1)
	{
		strmid(rak,GangInfo[org][Rank1],0,strlen(GangInfo[org][Rank1]),255);
	}
	if(PlayerInfo[playerid][Rank] == 2)
	{
		strmid(rak,GangInfo[org][Rank2],0,strlen(GangInfo[org][Rank2]),255);
	}
	if(PlayerInfo[playerid][Rank] == 3)
	{
		strmid(rak,GangInfo[org][Rank3],0,strlen(GangInfo[org][Rank3]),255);
	}
	if(PlayerInfo[playerid][Rank] == 4)
	{
		strmid(rak,GangInfo[org][Rank4],0,strlen(GangInfo[org][Rank4]),255);
	}
	if(PlayerInfo[playerid][Rank] == 5)
	{
		strmid(rak,GangInfo[org][Rank5],0,strlen(GangInfo[org][Rank5]),255);
	}
	if(PlayerInfo[playerid][Rank] == 6)
	{
		strmid(rak,GangInfo[org][Rank6],0,strlen(GangInfo[org][Rank6]),255);
	}
	new string[256];
	format(string, sizeof(string), "{0066CC}Gang[R] Chat | {FFFFFF}%s: {0066CC}(%s): {C0C0C0}%s", GetName(playerid),rak, params[0]);
	return ChatGang(org,string);
}
CMD:d(playerid, params[],help)
{
    #pragma unused help
	new tekst[256];
	if(PlayerInfo[playerid][aLeader] < 0 && PlayerInfo[playerid][aMember] < 0 )  return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}You are not a member of any gang!");
	if (sscanf(params, "s[90]", tekst))  return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/d [Text]");
	new org;
	new rak[128];
    if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
	if(GangInfo[org][AllowedD] == 0) return SendClientMessage(playerid,-1,"{FF0000}[Gang] {C0C0C0}This gang does not have allowed /d chat!");
	if(PlayerInfo[playerid][Rank] == 1)
	{
		strmid(rak,GangInfo[org][Rank1],0,strlen(GangInfo[org][Rank1]),255);
	}
	if(PlayerInfo[playerid][Rank] == 2)
	{
		strmid(rak,GangInfo[org][Rank2],0,strlen(GangInfo[org][Rank2]),255);
	}
	if(PlayerInfo[playerid][Rank] == 3)
	{
		strmid(rak,GangInfo[org][Rank3],0,strlen(GangInfo[org][Rank3]),255);
	}
	if(PlayerInfo[playerid][Rank] == 4)
	{
		strmid(rak,GangInfo[org][Rank4],0,strlen(GangInfo[org][Rank4]),255);
	}
	if(PlayerInfo[playerid][Rank] == 5)
	{
		strmid(rak,GangInfo[org][Rank5],0,strlen(GangInfo[org][Rank5]),255);
	}
	if(PlayerInfo[playerid][Rank] == 6)
	{
		strmid(rak,GangInfo[org][Rank6],0,strlen(GangInfo[org][Rank6]),255);
	}
	new string[256];
	format(string, sizeof(string), "{339966}Gang[D] Chat | {FFFFFF}%s: {339966}(%s): {C0C0C0}%s", GetName(playerid),rak, params[0]);
	return DChat(string);
}

CMD:giverank(playerid,params[],help)
{
    new id,ranka;
	if(PlayerInfo[playerid][aLeader] < 0) return SendClientMessage(playerid,-1,"You are not authorized!");
	if(sscanf(params,"ud",id,ranka)) return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/giverank [ID of player][Rank(1-5)]");
	if(PlayerInfo[id][aMember] != PlayerInfo[playerid][aLeader]) return SendClientMessage(playerid,SRED,"The player is not a member of your gang!");
	if(ranka < 1 || ranka > 5) return SendClientMessage(playerid,SRED,"Ranks go from 1 to 5!");
	new string[128];
	format(string,sizeof(string),"{00C0FF}You've reached the rank %d!",ranka);
	SendClientMessage(id,-1,string);
	format(string,sizeof(string),"{00C0FF}Member %s you have given rank %d!",GetName(id),ranka);
	SendClientMessage(playerid,-1,string);
	new org=PlayerInfo[playerid][aLeader];
	PlayerInfo[id][Rank] = ranka;
	if(ranka == 1)
    {
    	PlayerInfo[id][pSkin]=GangInfo[org][rSkin1];
    }
    else if(ranka == 2)
    {
    	PlayerInfo[id][pSkin]=GangInfo[org][rSkin2];
    }
    else if(ranka == 3)
    {
    	PlayerInfo[id][pSkin]=GangInfo[org][rSkin3];
    }
    else if(ranka == 4)
    {
    	PlayerInfo[id][pSkin]=GangInfo[org][rSkin4];
    }
    else if(ranka == 5)
    {
    	PlayerInfo[id][pSkin]=GangInfo[org][rSkin5];
    }
	SetPlayerSkin(id, PlayerInfo[id][pSkin]);
	SavePlayer(id);
    return 1;
}
CMD:members(playerid,params[],help)
{
	if(PlayerInfo[playerid][aLeader] < 0 && PlayerInfo[playerid][aMember] < 0) return SendClientMessage(playerid,SRED,"You are not authorized!");
	new org;
	new string[128];
	if(PlayerInfo[playerid][aLeader] > -1)
	{
		org = PlayerInfo[playerid][aLeader];
	}
	if(PlayerInfo[playerid][aMember] > -1)
	{
		org = PlayerInfo[playerid][aMember];
	}
    format(string, sizeof(string), "{00C0FF}_____%s Members Online_____",GangInfo[org][Name]);
    SendClientMessage(playerid,-1,string);
	for(new i=0;i<MAX_PLAYERS;i++)
	{
		if((PlayerInfo[i][aMember] == org || PlayerInfo[i][aLeader] == org) && IsPlayerConnected(i))
		{
			format(string, sizeof(string), "  - {FFFFFF}%s - Rank:%d", GetName(i),PlayerInfo[i][Rank]);
			SendClientMessage(playerid, -1, string);
		}
	}
    return 1;
}
CMD:allmembers(playerid,params[],help)
{
	if(PlayerInfo[playerid][aLeader] < 0) return SendClientMessage(playerid,SRED,"You are not a leader!");
	new org = PlayerInfo[playerid][aLeader];
	new str[128];
    SendClientMessage(playerid, -1, " ");
	SendClientMessage(playerid, -1, " ");
	SendClientMessage(playerid, -1, " ");
	SendClientMessage(playerid, -1, " ");
	format(str,256," All Members: %s",GangInfo[org][Name]);
	SendClientMessage(playerid, 0xFFFB7Daa, str);
	format(str,256," %s|%s|%s|%s|%s",Member[0][org],Member[1][org],Member[2][org],Member[3][org],Member[4][org]);
	SendClientMessage(playerid, 0xFFFDD1aa, str);
	format(str,256," %s|%s|%s|%s|%s",Member[5][org],Member[6][org],Member[7][org],Member[8][org],Member[9][org]);
	SendClientMessage(playerid, 0xFFFDD1aa, str);
	format(str,256," %s|%s",Member[10][org],Member[11][org]);
	SendClientMessage(playerid, 0xFFFDD1aa, str);
    return 1;
}
CMD:uninvite(playerid,params[],help)
{
    new id[128];
    if(PlayerInfo[playerid][aLeader] < 0) return SendClientMessage(playerid,SRED,"You are not a leader!");
    if(sscanf(params,"s",id)) return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/uninvite [Name_Surname]");
	new org = PlayerInfo[playerid][aLeader];
    new cl=-1;
    for(new i=0;i<12;i++)
    {
	    if(udb_hash(Member[i][org]) == udb_hash(id))
	   	{
	    	cl=i;
	    }
    }
    if(cl==-1)return SendClientMessage(playerid,SRED,"The player is not a member of your gang!");
    new m[24]; format(m,24,"Member%d",cl+1);
    new dFile2[50];
	format(dFile2, sizeof(dFile2), GANGS, org);
 	new INI:File = INI_Open(dFile2);
 	INI_SetTag(File, "Gang");
 	INI_WriteString(File,m,"Nobody");
	INI_Close(File);
	strmid(Member[cl][org],"Nobody",0,strlen("Nobody"),255);
	new ida = GetPlayerID(id);
	if(IsPlayerConnected(ida))
	{
		SendClientMessage(ida,-1,"{00C0FF}You have been kicked out of your gang!");
		PlayerInfo[ida][aMember] = -1;
		PlayerInfo[ida][pSkin] = 0;
		SetPlayerSkin(ida, PlayerInfo[ida][pSkin]);
		SavePlayer(ida);
	}
    return 1;
}
CMD:invite(playerid,params[],help)
{
    new id;
    if(PlayerInfo[playerid][aLeader] < 0) return SendClientMessage(playerid,SRED,"You are not a leader!");
    if(sscanf(params,"u",id)) return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/invite [ID of player]");
    if(!IsPlayerConnected(id)) return SendClientMessage(playerid,SRED,"Player is offline!");
    if(id == playerid) return SendClientMessage(playerid,SRED,"You can not invite yourself!");
    if(PlayerInfo[id][aMember] > -1 || PlayerInfo[id][aLeader] > -1) return SendClientMessage(playerid,SRED,"The player is already a member of a gang!");
    new c = 0;
	new org = PlayerInfo[playerid][aLeader];
    for(new n = 0; n < 12; n++)
    {
	    if(udb_hash(Member[n][org]) == udb_hash("Nobody"))
	    	{
				new str[128];
				format(str,sizeof(str),"{00C0FF}You are invited in %s | Leader %s!",GangInfo[org][Name], GetName(playerid));
				SendClientMessage(id,-1,str);
				format(str,sizeof(str),"{00C0FF}You are invite a player %s!", GetName(id));
				SendClientMessage(playerid,-1,str);
				PlayerInfo[id][aMember] = org;
				PlayerInfo[id][Rank] = 1;
				PlayerInfo[id][pSkin] = GangInfo[org][rSkin1];
				SetPlayerSkin(id, PlayerInfo[id][pSkin]);
				SavePlayer(id);
				strmid(Member[n][org],GetName(id),0,strlen(GetName(id)),255);
				SaveGangs(org);
				return 1;
			}
    	else if(udb_hash(Member[n][org]) != udb_hash("Nobody"))
    		{
    			c++;
    			if(c == 12) return  SendClientMessage(playerid, -1, "{B3B3B3}({FF0000}Error!{B3B3B3}){FFFFFF} No place in gang!");
			}
	}
    return 1;
}
CMD:makeleader(playerid,params[],help)
{
    if (INT_CheckPlayerAdminLevel(playerid, 6) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {0000FF}Manager/CEO {FF0000}to do this command!");
    new org,id;
    if(sscanf(params,"ui",id,org))
    {
		SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/makeleader [ID of player] [ID of gang]");
		for(new i=0;i<MAX_GANG;i++)
		{
			new rFile[50];
			format(rFile, sizeof(rFile), GANGS, i);
		    if(fexist(rFile))
		    {
				new string[128];
				format(string,sizeof(string),"|{A3A3A3}Gang ID: {FFFFFF}%d | {A3A3A3}Name:{FFFFFF}%s|",i,GangInfo[i][Name]);
				SendClientMessage(playerid,-1,string);
			}
		}
	}
	else
	{
	    new oFile[50];
		format(oFile, sizeof(oFile), GANGS, org);
	    if(!fexist(oFile))return SendClientMessage(playerid,SRED,"This band does not exist!");
	    if(!IsPlayerConnected(id)) return SendClientMessage(playerid,SRED,"Player is offline!");
	    if(PlayerInfo[id][aMember] > -1 || PlayerInfo[id][aLeader] > -1) return SendClientMessage(playerid,SRED,"The player is already a member/Leader of a gang!");
	    new c = 0;
	    for(new n = 0; n < 2; n++)
	    {
		    if(udb_hash(Leader[n][org]) == udb_hash("Nobody"))
	    	{
				new str[256];
				format(str,sizeof(str),"{00C0FF}You are set for the leader of the gang %s | Admin %s!",GangInfo[org][Name], GetName(playerid));
				SendClientMessage(id,-1,str);
				format(str,sizeof(str),"{00C0FF}You have set for the leader of %s player %s!",GangInfo[org][Name], GetName(id));
				SendClientMessage(playerid,-1,str);
				strmid(Leader[n][org],GetName(id),0,strlen(GetName(id)),255);
				PlayerInfo[id][aLeader] = org;
				PlayerInfo[id][Rank] = 6;
				PlayerInfo[id][pSkin] = GangInfo[org][rSkin6];
				SetPlayerSkin(id, PlayerInfo[id][pSkin]);
				SavePlayer(id);
				SaveGangs(org);
				return 1;
			}
	    	else if(udb_hash(Leader[n][org]) != udb_hash("Nobody"))
	   		{
	  			c++;
	  			if(c == 2) return  SendClientMessage(playerid, -1, "{B3B3B3}({FF0000}Error!{B3B3B3}){FFFFFF} No place in gang!");
			}
		}
	}
    return 1;
}
CMD:creategang(playerid,params[],help)
{
    if (INT_CheckPlayerAdminLevel(playerid, 6) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {0000FF}Manager/CEO {FF0000}to do this command!");
    new org;
    if(sscanf(params,"i",org)) return SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/creategang [ID Gang]");
    new oFile[50];
	format(oFile, sizeof(oFile), GANGS, org);
    if(!fexist(oFile))
    {
	    strmid(Leader[0][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Leader[1][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[0][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[1][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[2][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[3][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[4][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[5][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[6][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[7][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[8][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[9][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[10][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(Member[11][org],"Nobody",0,strlen("Nobody"),255);
	    strmid(GangInfo[org][Name],"No name",0,strlen("No name"),255);
	    strmid(GangInfo[org][Rank1],"Rank 1",0,strlen("Rank 1"),255);
	    strmid(GangInfo[org][Rank2],"Rank 2",0,strlen("Rank 2"),255);
	    strmid(GangInfo[org][Rank3],"Rank 3",0,strlen("Rank 3"),255);
	    strmid(GangInfo[org][Rank4],"Rank 4",0,strlen("Rank 4"),255);
	    strmid(GangInfo[org][Rank5],"Rank 5",0,strlen("Rank 5"),255);
	    strmid(GangInfo[org][Rank6],"Leader",0,strlen("Leader"),255);
	    SaveGangs(org);
	    SendClientMessage(playerid,-1,"{00C0FF}Successfully make gang!");
    }else return SendClientMessage(playerid,SRED,"This gang already exists!");
    return 1;
}
CMD:addvehicle(playerid, params[],help)
{
	#pragma unused help
    if (INT_CheckPlayerAdminLevel(playerid, 6) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {0000FF}Manager/CEO {FF0000}to do this command!");
	new idbande,idvozila,mvozila,boja;
	if(sscanf(params, "dddd",idbande,idvozila,mvozila,boja))
	{
	    SendClientMessage(playerid,-1,"{FF0000}Gang Help | {C0C0C0}/addvehicle [ID gang] [Vehicle slot(0-14)] [Model of vehicle] [Color of vehicle]");
	    return 1;
	}
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,SRED,"You must be in the vehicle!");
	if(idvozila > 14 || idvozila < 0) return SendClientMessage(playerid,SRED,"Maximum slot of cars was 14 (0-14)!");
	if(vCreated[idbande][idvozila] == 1) return SendClientMessage(playerid,SRED,"This vehicle is already created!");
	new oFile[50];
 	format(oFile, sizeof(oFile), GANGS, idbande);
  	if(!fexist(oFile)) return SendClientMessage(playerid,SRED,"This gang already exists!");
	new Float:pax,Float:pay,Float:paz,Float:paa;
	GetVehiclePos(GetPlayerVehicleID(playerid),pax,pay,paz);
	GetVehicleZAngle(GetPlayerVehicleID(playerid),paa);
	Vehicle[idbande][0][idvozila] = pax;
	Vehicle[idbande][1][idvozila] = pay;
	Vehicle[idbande][2][idvozila] = paz;
	Vehicle[idbande][3][idvozila] = paa;
	VehiclesID[idbande][idvozila] = mvozila;
    VehiclesColor[idbande][idvozila] = boja;
    vCreated[idbande][idvozila] = 1;
   	GVehID[idbande][idvozila] = CreateVehicle(VehiclesID[idbande][idvozila],Vehicle[idbande][0][idvozila],Vehicle[idbande][1][idvozila],Vehicle[idbande][2][idvozila],Vehicle[idbande][3][idvozila],VehiclesColor[idbande][idvozila],VehiclesColor[idbande][idvozila],30000);
   	SaveGangs(idbande);
	return 1;
}

CMD:update (playerid) return cmd_news(playerid);
CMD:news(playerid)
{
	new bigstring[3000];
	strcat(bigstring, "Latest Update: Build {FFFF00}17\n\
                       {00FF00}In Game Updates:\n\
					   {FFFF00}*{FFFFFF}Removed YT stream cmds\n\
                       {FFFF00}*{FFFFFF}Prevented Car Spam with /tc2 to /tc12\n");
    strcat(bigstring, "{FFFF00}*{FFFFFF}Prevented using /skin and /skinid in DMs, Races and CnR\n\
                       {FFFF00}*{FFFFFF}Fixed SkinIDs on spawn\n\
                       {FFFF00}*{FFFFFF}Fixed some Map bugs\n");
    strcat(bigstring, "{FFFF00}*{FFFFFF}Updated score saving\n\
                       {FFFF00}*{FFFFFF}Updated auto time update for 3 hours\n\
                       {FFFF00}*{FFFFFF}Updated auto weather change\n\
                       {FFFF00}*{FFFFFF}Added /richcity\n");
    strcat(bigstring, "{FFFF00}*{FFFFFF}Added /tubeland\n\
                       {FFFF00}*{FFFFFF}Added /parkour3\n\
                       {FFFF00}*{FFFFFF}Added /dreamyland2\n");
    strcat(bigstring, "{FFFF00}*{FFFFFF}Added /jump\n\
                       {FFFF00}*{FFFFFF}Added /ghostmode (For Level3+ Administrators)\n\
                       {FFFF00}*{FFFFFF}Added /stuntland(/sl)\n\
                       {FFFF00}*{FFFFFF}IP changed to 62.75.158.36\n\n");
    strcat(bigstring, "{FF0000}Forum Updates:\n\
                       {FFFF00}*{FFFFFF}Forum upgraded to IPS 4.2.7\n\
                       {FFFF00}*{FFFFFF}Colors updated on TBS Official forum theme\n");
	strcat(bigstring, "{FFFF00}*{FFFFFF}Added Microsoft, Twitter and Google as Sign up/Sign in apps on Forum\n\
					   {FFFF00}*{FFFFFF}Added 'Donate' button on Forum\n");
    strcat(bigstring, "{FFFF00}*{FFFFFF}Added 'Music' page which contains TBS's Songs\n\
                       {FFFF00}*{FFFFFF}Executed some security measures on the VPS\n\
                       {FFFF00}*{FFFFFF}Domain changed to tbs-official.eu\n\n");
    strcat(bigstring, "{FFFF00}Developers of the Build: Filipbg, [TBS]SamYT");
	ShowPlayerDialog(playerid, DIALOG_NEWS, DIALOG_STYLE_MSGBOX, ""RED"TBS's ChangeLog", bigstring, "OK", "");
	return 1;
}

CMD:updatelist(playerid)
{
	cmd_news(playerid);
	return 1;
}

CMD:changelog(playerid)
{
	cmd_news(playerid);
	return 1;
}

CMD:animhelp(playerid) return cmd_animlist(playerid);
CMD:animlist(playerid)
{
	new main2[800];
	new string[200];
	format(main2, sizeof(main2), "{FFFFFF}You type all animations like this: {7CFC00}'/AN [Name]'.\n{FFFFFF}The only exception is for {7CFC00}'/Kiss [playerid/PartOfName]' {FFFFFF}and {7CFC00}'/Greet [playerid/PartOfName]'{FFFFFF}.\n\nHere is a list of all animations:\n");
	format(string, sizeof(string),"{9ACD32}Cellin - Cellout - Hitch - Scratch - Sit - Lay - Smoke - Bomb - Laugh - Robman - Lookout - Crossarms - Hide - Vomit - Wave\n");
	strcat(main2, string);
	format(string, sizeof(string),"Slapass - Blowjob - Deal - Idle - Pay - Crack - Chat - Fucku - Taichi - Dance - Injured - Shadowbox - Piss - Wank - Sleep\n");
	strcat(main2, string);
	format(string, sizeof(string),"Point - Shout - Look - Aim - CPR - Fixcar - Flag - Bat - Lean - Gang - Wallshoot - What - Insult\n");
    strcat(main2, string);
	format(string, sizeof(string),"handsup - strip - sexy - bitchslap - shadowbox - celebrate - win - cry - angry - yes - eat - thankyou - nod");
    strcat(main2, string);
	ShowPlayerDialog(playerid, 110, DIALOG_STYLE_MSGBOX, "{00BFFF}Available animations",main2, "Cool", "");
    return 1;
}

CMD:ctune(playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
    
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,red,"Error: You're not in a vehicle");
	new Float:X9,Float:Y9,Float:Z9,Float:Angle9;	GetPlayerPos(playerid,X9,Y9,Z9); GetPlayerFacingAngle(playerid,Angle9);
	AddVehicleComponent(GetPlayerVehicleID(playerid), 1028);	AddVehicleComponent(GetPlayerVehicleID(playerid), 1030);	AddVehicleComponent(GetPlayerVehicleID(playerid), 1031);	AddVehicleComponent(GetPlayerVehicleID(playerid), 1138);
	AddVehicleComponent(GetPlayerVehicleID(playerid), 1140);  AddVehicleComponent(GetPlayerVehicleID(playerid), 1170);
    AddVehicleComponent(GetPlayerVehicleID(playerid), 1028);	AddVehicleComponent(GetPlayerVehicleID(playerid), 1030);	AddVehicleComponent(GetPlayerVehicleID(playerid), 1031);	AddVehicleComponent(GetPlayerVehicleID(playerid), 1138);	AddVehicleComponent(GetPlayerVehicleID(playerid), 1140);  AddVehicleComponent(GetPlayerVehicleID(playerid), 1170);
    AddVehicleComponent(GetPlayerVehicleID(playerid), 1080);	AddVehicleComponent(GetPlayerVehicleID(playerid), 1086); AddVehicleComponent(GetPlayerVehicleID(playerid), 1087); AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);	PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	ChangeVehiclePaintjob(GetPlayerVehicleID(playerid),0);
	SendClientMessage(playerid, COLOR_GREEN, "You have added tuning parts to your vehicle!");
	return 1;
}

CMD:carcolor(playerid,params[])
{
    if(!IsPlayerBusy(playerid)) return 1;
    
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,red,"Error: You're not in a vehicle");
	new tmp2[256], tmp3[256], Index2; tmp2 = strtok(params,Index2); tmp3 = strtok(params,Index2);
    if(!strlen(tmp2) || !strlen(tmp3)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /carcolor [color1] [color2]");
	new colour1, colour2, string[128];
	if(!strlen(tmp2)) colour1 = random(126); else colour1 = strval(tmp2);
	if(!strlen(tmp3)) colour2 = random(126); else colour2 = strval(tmp3);
	format(string, sizeof(string), "You have changed your %s's color to '%d, %d'", vNames[GetVehicleModel(GetPlayerVehicleID(playerid))-400], colour1, colour2);
	SendClientMessage(playerid,COLOR_BLUE,string);
    return ChangeVehicleColor(GetPlayerVehicleID(playerid), colour1, colour2);
}

CMD:carcolour(playerid,params[])
{
    cmd_carcolor(playerid, params);
    return 1;
}

CMD:neon(playerid,params[]) {

    if(!IsPlayerBusy(playerid)) return 1;
    
	if(IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
	 ShowPlayerDialog(playerid, neondialog, DIALOG_STYLE_LIST, "Neon Color", "{00FFFF}Blue\n{FF0000}Red\n{00a33d}Green\n{ccecd8}White\n{ff2266}Pink\n{ffd700}Yellow\n{d1be94}Police Strobe\n{fdc8c7}Interior Lights\n{bad191}Back Neon\n{7e30cd}Front Neon\n{cd7f31}Undercover Roof Light\n{07a4d1}Dark Blue\n{663399}Violet\n{ffd700}Yellow\n{00ffff}Cyan\n{1395b1}Light Blue\n{fdc8c7}Pink\n{ffa500}Orange\n{80FF00}Light Green\n{FFFF80}Light Yellow\n{DD0000}S Red\n{00DF00}S Green\n{0000DF}S Blue\nRemove Neon", "Select", "Cancel");
	}
	else
	{
	SendClientMessage(playerid, -1, "You are not in a vehicle or you're not the driver of the vehicle!");
	}
	return 1;
}

CMD:rules(playerid, params[])
{
	new string[2000];
	strcat(string,"{FF0000}TBS Server Rules\n1.{FFFFFF}Do {FF0000}NOT {FFFFFF}Use Hacks (Captured Using Hacks Will Lead You To {FF0000}IP BAN{FFFFFF})\n{FF0000}2.{FFFFFF}CLEO Mods Are {FF0000}NOT {FFFFFF}Allowed (First time - Kicked, Second time - {FF0000}Banned{FFFFFF})\n{FF0000}3.{FFFFFF}Don't use s0beit. Using s0beit will get you {FF0000}Banned\n{FF0000}4.{FFFFFF}Don't Insult, Abuse, Spam, Flood etc... (Do This You Will Be Muted Or Even Kicked)\n");
	strcat(string,"{FF0000}5.Do {FF0000}NOT {FFFFFF}request a song multiple times using /request (You'll end up warned)\n{FF0000}6.{FFFFFF}Respect Server Owners, Admins, Moderators, VIP's, And Regular Players\n{FF0000}7.{FFFFFF}Be Nice (If You Are Being Rude You Will Be Muted)\n{FF0000}8.{FFFFFF}Don't Ram/Drive By (For Ramming You Will Be Jailed/Freezed)\n{FF0000}9.{FFFFFF}Don't Spawn Kill (Spawn Kill=Freeze)\n");
	strcat(string,"{FF0000}10.{FFFFFF}Don't Ask For Admin (Ask And You Will Be Muted)\n{FF0000}11.{FFFFFF}No Advertising (Muted, Kicked)\n{00FFFF}These are our server rules please read them and do NOT break them\nThanks for reading!");
	ShowPlayerDialog(playerid, 6000, DIALOG_STYLE_MSGBOX, "{FF0000}Rules", string, "Ok", "");
	return 1;
}

CMD:raceinfo(playerid)
{
    SendClientMessage(playerid, COLGREEN, "Available Races: Airport, Beach, Boats, Chilliad, Dakar, Drag, Forest, Freeway, Bandito, Grand,");
    SendClientMessage(playerid, COLGREEN, "Grov, Hard, LVDrift, Monster, Quad, Stunt, Sultan, Funny, Race, Race2, Cheetah, NRG, Bullet;");
    SendClientMessage(playerid, COLYELLOW, "Use: /startrace (Race Name) to start a race!");
    SendClientMessage(playerid, COLRED, "Important: You have to type the currect name of the race, otherwise it will NOT start!");
	return 1;
}

CMD:racecmds(playerid)
{
    SendClientMessage(playerid, COLGREEN, "Race Commands: /raceinfo - All Available Races!");
    SendClientMessage(playerid, COLGREEN, "/startrace - To start a race!");
    SendClientMessage(playerid, COLGREEN, "/join - To join in started race!");
    SendClientMessage(playerid, COLGREEN, "/exit - To exit from race!");
	return 1;
}

CMD:racecmd(playerid)
{

   return cmd_racecmds(playerid);
}

CMD:racehelp(playerid)
{
   return cmd_raceinfo(playerid);
}

CMD:race(playerid)
{
   return cmd_raceinfo(playerid);
}

CMD:buildrace(playerid, params[])
{
	if (INT_CheckPlayerAdminLevel(playerid, 6) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {0000FF}Manager/CEO {FF0000}to do this command!");
	if(BuildRace != 0) return SendClientMessage(playerid, COLRED, "<!> There's already someone building a race!");
	if(RaceBusy == 0x01) return SendClientMessage(playerid, COLRED, "<!> Wait first till race ends!");
	if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLRED, "<!> Please leave your vehicle first!");
	BuildRace = playerid+1;
	ShowDialog(playerid, 599);
	return 1;
}

CMD:cancelbuild(playerid, params[])
{
	if(INT_CheckPlayerAdminLevel(playerid, 6) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {0000FF}Manager/CEO {FF0000}to do this command!");
    new RacePath[64], rNameFile[128], string[128];
    format(RacePath, sizeof(RacePath), "/Race/%s.RRACE", BuildName);
    if(dini_Exists(BuildName))
	{
	format(rNameFile, sizeof(rNameFile), "/Race/RaceNames/RaceNames.txt");
	TotalRaces = dini_Int(rNameFile, "TotalRaces");
    printf(">> Deleted Race: %s", BuildName);
    fremove(rNameFile);
	format(string, sizeof(string), "Race: %s has been successfully deleted from the database!", BuildName);
	SendClientMessage(playerid, COLOR_GREEN, string);
	fremove(BuildName);
	BuildRace = 0;
    BuildTakeVehPos = false;
    BuildTakeCheckpoints = false;
    BuildCheckPointCount = 0;
    BuildVehPosCount = 0;
    BuildCreatedVehicle = 0x00;
    DestroyVehicle(BuildVehicle);
	}
	else return SendClientMessage(playerid, COLOR_RED, "ERROR: There aren't any races in build!");
	return 1;
}

CMD:startrace(playerid, params[])
{
    //if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLRED, "<!> You are not an administrator!");
    if(!IsPlayerBusy(playerid)) return 1;
	if(PlayerInfo[playerid][isAFK] == 1) return SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You're AFK, please type /back first!");
	if(AutomaticRace == true) return SendClientMessage(playerid, COLRED, "<!> Not possible. Automatic race is enabled!");
    if(BuildRace != 0) return SendClientMessage(playerid, COLRED, "<!> There's someone building a race!");
    if(RaceBusy == 0x01 || RaceStarted == 1) return SendClientMessage(playerid, COLRED, "<!> There's a race currently. Wait first till race ends!");
    if(isnull(params)) return SendClientMessage(playerid, COLRED, "<!> /startrace [racename]");
    LoadRace(playerid, params);
    return 1;
}
CMD:stoprace(playerid, params[])
{
    if (INT_CheckPlayerAdminLevel(playerid, 6) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {0000FF}Manager/CEO {FF0000}to do this command!");
    if(RaceBusy == 0x00 || RaceStarted == 0) return SendClientMessage(playerid, COLRED, "<!> There's no race to stop!");
	SendClientMessageToAll(COLRED, ">> An admin stopped the current race!");
	return StopRace();
}
CMD:join(playerid, params[])
{
    if(!IsPlayerBusy(playerid)) return 1;
	if(PlayerInfo[playerid][isAFK] == 1) return SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You're AFK, please type /back first!");
	if(RaceStarted == 1) return SendClientMessage(playerid, COLRED, "<!> Race already started! Wait first till race ends!");
	if(RaceBusy == 0x00) return SendClientMessage(playerid, COLRED, "<!> There's no race to join!");
	if(Joined[playerid] == true) return SendClientMessage(playerid, COLRED, "<!> You already joined a race!");
	if(IsPlayerInAnyVehicle(playerid)) return SetTimerEx("SetupRaceForPlayer", 2500, 0, "e", playerid), RemovePlayerFromVehicle(playerid), Joined[playerid] = true;
	SetupRaceForPlayer(playerid);
	Joined[playerid] = true;
	Nitro[playerid] = false;
	Bounce[playerid] = false;
	AutoFix[playerid] = false;
	DisableRemoteVehicleCollisions(playerid, 1);
	pInvincible[playerid] = true;
	SendClientMessage(playerid, COLOR_GREEN, "Racing Ghost Mode Enabled.");
	SendClientMessage(playerid, COLOR_WHITE, "You can now go through cars without them Ramming You!");
	return 1;
}
CMD:startautorace(playerid, params[])
{
    if (INT_CheckPlayerAdminLevel(playerid, 6) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {0000FF}Manager/CEO {FF0000}to do this command!");
	if(RaceBusy == 0x01 || RaceStarted == 1) return SendClientMessage(playerid, COLRED, "<!> There's a race currently. Wait first till race ends!");
	if(AutomaticRace == true) return SendClientMessage(playerid, COLRED, "<!> It's already enabled!");
    LoadRaceNames();
	LoadAutoRace(RaceNames[random(TotalRaces)]);
	AutomaticRace = true;
	SendClientMessage(playerid, COLGREEN, ">> You stared auto race. The filterscript will start a random race everytime the previous race is over!");
	return 1;
}
CMD:stopautorace(playerid, params[])
{
    if (INT_CheckPlayerAdminLevel(playerid, 6) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {0000FF}Manager/CEO {FF0000}to do this command!");
    if(AutomaticRace == false) return SendClientMessage(playerid, COLRED, "<!> It's already disabled!");
    AutomaticRace = false;
	KillTimer(RaceTimer);
	return 1;
}

CMD:anims(playerid, params[])
{
    return cmd_animlist(playerid);
}

CMD:animations(playerid, params[])
{
   return cmd_animlist(playerid);
}

CMD:an(playerid, params[]) return cmd_animation(playerid, params);
CMD:anim(playerid, params[]) return cmd_animation(playerid, params);
CMD:animation(playerid, params[])
{
    if(!IsPlayerBusy(playerid)) return 1;
    
    if(CallRemoteFunction("IsPlayerBlocked", "d", playerid) != 0 || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
    {
        SendClientMessage(playerid, COLOR_LIGHTRED, "   You can't do that right now!");
        return 1;
	}
	new name[30],id;
	if(!sscanf(params, "s[29]I(0)", name, id))
	{
		if(!strcmp(name, "cellin", true))
		{
		    SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USECELLPHONE);
		}
		else if(!strcmp(name, "cellout", true))
		{
		    SetPlayerSpecialAction(playerid,SPECIAL_ACTION_STOPUSECELLPHONE);
		}
		else if(!strcmp(name, "hitch", true))
		{
		    LoopingAnim(playerid,"MISC","Hiker_Pose", 4.0, 1, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "scratch", true))
		{
			LoopingAnim(playerid,"MISC","Scratchballs_01", 4.0, 1, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "sit", true))
		{
		    if(id == 1)
		    {
				ExitAnim[playerid] = 1;
		   		LoopingAnim(playerid,"ped","SEAT_idle", 4.0, 1, 0, 0, 0, 0);
			}
			else if(id == 2)
			{
			    LoopingAnim(playerid,"BEACH", "ParkSit_M_loop", 4.0, 1, 0, 0, 0, 0);
			}
			else if(id == 3)
			{
			    LoopingAnim(playerid,"BEACH", "ParkSit_W_loop", 4.0, 1, 0, 0, 0, 0);
			}
			else if(id == 4)
			{
			    LoopingAnim(playerid,"BEACH", "SitnWait_loop_W", 4.0, 1, 0, 0, 0, 0);
			}
			else if(id == 5)
			{
			    ExitAnim[playerid] = 8;
			    LoopingAnim(playerid,"Attractors", "Stepsit_loop", 4.0, 1, 0, 0, 0, 0);
			}
			else if(id == 6)
			{
			    ExitAnim[playerid] = 9;
			    LoopingAnim(playerid,"FOOD", "FF_Sit_In_L", 4.0, 0, 0, 0, 1, 0);
			}
			else if(id == 7)
			{
			    ExitAnim[playerid] = 10;
			    LoopingAnim(playerid,"FOOD", "FF_Sit_In_R", 4.0, 0, 0, 0, 1, 0);
			}
			else
			{
			    SendClientMessage(playerid, COLOR_WHITE, "USAGE: (/An)imation sit [ID]");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "1 - Chair sit");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "2 - Male groundsit");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "3 - Female groundsit");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "4 - Bored seat");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "5 - Step seat");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "6 - Right booth seat");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "7 - left booth seat");
			}
		}
		else if(!strcmp(name, "lay", true))
		{
		   	LoopingAnim(playerid,"BEACH", "bather", 4.0, 1, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "smoke", true))
		{
		    if(id == 1)
		    {
		   		LoopingAnim(playerid,"SMOKING", "M_smklean_loop", 4.0, 1, 0, 0, 0, 0);
			}
			else if(id == 2)
			{
			    LoopingAnim(playerid,"SMOKING", "F_smklean_loop", 4.0, 1, 0, 0, 0, 0);
			}
			else if(id == 3)
			{
			    LoopingAnim(playerid,"SMOKING", "M_smkstnd_loop", 4.0, 1, 0, 0, 0, 0);
			}
			else
			{
			    SendClientMessage(playerid, COLOR_WHITE, "USAGE: (/An)imation smoke [ID]");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "1 - Male lean");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "2 - Female lean");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "3 - Male standing");
			}
		}
		else if(!strcmp(name, "handsup", true))
		{
	         SetPlayerSpecialAction(playerid,SPECIAL_ACTION_HANDSUP);
             GameTextForPlayer(playerid, "~w~To stop the anim hit ~r~H!", 3000, 5);
		}
		else if(!strcmp(name, "strip", true))
		{
		    if(id == 1)
		    {
		   		OnePlayAnim(playerid,"STRIP","strip_A",4.0,1,1,1,1,0);
			}
			else if(id == 2)
			{
			    OnePlayAnim(playerid,"STRIP","strip_B",4.0,1,1,1,1,0);
			}
			else if(id == 3)
			{
			    OnePlayAnim(playerid,"STRIP","strip_C",4.0,1,1,1,1,0);
			}
			else if(id == 4)
			{
			    OnePlayAnim(playerid,"STRIP","strip_D",4.0,1,1,1,1,0);
			}
			else if(id == 5)
			{
			    OnePlayAnim(playerid,"STRIP","strip_E",4.0,1,1,1,1,0);
			}
			else if(id == 6)
			{
			    OnePlayAnim(playerid,"STRIP","strip_F",4.0,1,1,1,1,0);
			}
			else if(id == 7)
			{
			    OnePlayAnim(playerid,"STRIP","strip_G",4.0,1,1,1,1,0);
			}
			else
			{
			    SendClientMessage(playerid, COLOR_WHITE, "USAGE: (/An)imation strip [ID]");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "1 - Strip A, 2 - Strip - B, 3 - Strip C, 4 - Strip D,");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "5 - Strip E, 6 - Strip F, 7 - Strip G;");
			}
		}
		else if(!strcmp(name, "sexy", true))
		{
		    if(id == 1)
		    {
		   		OnePlayAnim(playerid,"SNM","SPANKING_IDLEW",4.1,0,1,1,1,1);
			}
			else if(id == 2)
			{
			    OnePlayAnim(playerid,"SNM","SPANKING_IDLEP",4.1,0,1,1,1,1);
			}
			else if(id == 3)
			{
			    OnePlayAnim(playerid,"SNM","SPANKINGW",4.1,0,1,1,1,1);
			}
			else if(id == 4)
			{
			    OnePlayAnim(playerid,"SNM","SPANKINGP",4.1,0,1,1,1,1);
			}
			else if(id == 5)
			{
			    OnePlayAnim(playerid,"SNM","SPANKEDW",4.1,0,1,1,1,1);
			}
			else if(id == 6)
			{
			    OnePlayAnim(playerid,"SNM","SPANKEDP",4.1,0,1,1,1,1);
			}
			else if(id == 7)
			{
			    OnePlayAnim(playerid,"SNM","SPANKING_ENDW",4.1,0,1,1,1,1);
			}
			else if(id == 8)
			{
			    OnePlayAnim(playerid,"SNM","SPANKING_ENDP",4.1,0,1,1,1,1);
			}
			else
			{
			    SendClientMessage(playerid, COLOR_WHITE, "USAGE: (/An)imation strip [ID]");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "Sexy Animations 1-8");
			}
		}
		else if(!strcmp(name, "bitchslap", true))
		{
		   	OnePlayAnim(playerid,"MISC","bitchslap",4.0,0,0,0,0,0);
		}
		else if(!strcmp(name, "bomb", true))
		{
		   	OnePlayAnim(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "laugh", true))
		{
		   	OnePlayAnim(playerid, "RAPPING", "Laugh_01", 4.0, 0, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "robman", true))
		{
		   	LoopingAnim(playerid, "SHOP", "ROB_Loop_Threat", 4.0, 1, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "lookout", true))
		{
		   	OnePlayAnim(playerid, "SHOP", "ROB_Shifty", 4.0, 0, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "crossarms", true))
		{
		   	LoopingAnim(playerid, "COP_AMBIENT", "Coplook_loop", 4.0, 1, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "hide", true))
		{
		   	LoopingAnim(playerid,"ped", "cower", 4.0, 1, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "vomit", true))
		{
		   	LoopingAnim(playerid,"FOOD", "EAT_Vomit_P", 4.0, 1, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "wave", true))
		{
		    ExitAnim[playerid] = 2;
		   	LoopingAnim(playerid, "ON_LOOKERS", "wave_loop", 4.0, 1, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "slapass", true))
		{
		   	OnePlayAnim(playerid, "SWEET", "sweet_ass_slap", 4.0, 0, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "blowjob", true))
		{
		    ExitAnim[playerid] = 6;
		   	LoopingAnim(playerid,"BLOWJOBZ","BJ_COUCH_LOOP_W",4.1,0,0,0,0,0);
		}
		//dealing
		else if(!strcmp(name, "deal", true))
		{
		   	OnePlayAnim(playerid, "DEALER", "DEALER_DEAL", 4.0, 0, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "idle", true))
		{
		   	LoopingAnim(playerid, "DEALER", "DEALER_IDLE", 4.0, 1, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "pay", true))
		{
		   	OnePlayAnim(playerid, "DEALER", "shop_pay", 4.0, 0, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "crack", true))
		{
		   	LoopingAnim(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "chat", true))
		{
		   	OnePlayAnim(playerid,"ped","IDLE_CHAT",4.0,0,0,0,0,0);
		}
		else if(!strcmp(name, "fucku", true))
		{
		   	OnePlayAnim(playerid,"ped","fucku",4.0,0,0,0,0,0);
		}
		else if(!strcmp(name, "taichi", true))
		{
		    ExitAnim[playerid] = 3;
		   	LoopingAnim(playerid,"PARK","Tai_Chi_Loop",4.0,1,0,0,0,0);
		}
		else if(!strcmp(name, "dance", true))
		{
		    if(id == 1)
		    {
		        SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE1);
		    }
		    else if(id == 2)
		    {
		        SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE2);
		    }
		    else if(id == 3)
		    {
		        SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE3);
		    }
		    else if(id == 4)
		    {
		        SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE4);
		    }
		    else
		    {
			    SendClientMessage(playerid, COLOR_WHITE, "USAGE: (/An)imation dance [ID]");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "1,2,3,4");
			}
		}
		else if(!strcmp(name, "injured", true))
		{
		    if(id == 1)
		    {
			    LoopingAnim(playerid,"SWEET", "Sweet_injuredloop", 4.0,1,0,0,0,0);
		    }
		    else if(id == 2)
		    {
		        OnePlayAnim(playerid,"SWAT","gnstwall_injurd", 4.0, 1, 0, 0, 0, 0);
		    }
		    else
		    {
			    SendClientMessage(playerid, COLOR_WHITE, "USAGE: (/An)imation injured [ID]");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "1,2");
			}
		}
		else if(!strcmp(name, "shadowbox", true))
		{
		   	LoopingAnim(playerid,"GYMNASIUM", "GYMshadowbox", 1.800001, 1, 0, 0, 1, 600);
		}
		else if(!strcmp(name, "celebrate", true))
		{
		    if(id == 1)
		    {
		        OnePlayAnim(playerid,"benchpress","gym_bp_celebrate", 4.0, 1, 0, 0, 0, 0);
		    }
		    else if(id == 2)
		    {
		        OnePlayAnim(playerid,"GYMNASIUM","gym_tread_celebrate", 4.0, 1, 0, 0, 0, 0);
		    }
		    else
		    {
			    SendClientMessage(playerid, COLOR_WHITE, "USAGE: (/An)imation celebrate [ID]");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "1,2");
			}
		}
		else if(!strcmp(name, "win", true))
		{
		    if(id == 1)
		    {
		        OnePlayAnim(playerid,"CASINO","cards_win", 4.0, 1, 0, 0, 0, 0);
		    }
		    else if(id == 2)
		    {
		        OnePlayAnim(playerid,"CASINO","Roulette_win", 4.0, 1, 0, 0, 0, 0);
		    }
		    else
		    {
			    SendClientMessage(playerid, COLOR_WHITE, "USAGE: (/An)imation win [ID]");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "1,2");
			}
		}
		else if(!strcmp(name, "cry", true))
		{
		    if(id == 1)
		    {
		        OnePlayAnim(playerid,"GRAVEYARD","mrnF_loop", 4.0, 1, 0, 0, 0, 0);
		    }
		    else if(id == 2)
		    {
		        OnePlayAnim(playerid,"GRAVEYARD","mrnM_loop", 4.0, 1, 0, 0, 0, 0);
		    }
		    else
		    {
			    SendClientMessage(playerid, COLOR_WHITE, "USAGE: (/An)imation cry [ID]");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "1,2");
			}
		}
		else if(!strcmp(name, "angry", true))
		{
		   	OnePlayAnim(playerid,"RIOT","RIOT_ANGRY",4.0,0,0,0,0,0);
		}
		else if(!strcmp(name, "yes", true))
		{
		   	OnePlayAnim(playerid,"CLOTHES","CLO_Buy", 4.0, 1, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "eat", true))
		{
		   	OnePlayAnim(playerid, "FOOD", "EAT_Burger", 3.0, 0, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "thankyou", true))
		{
		   	OnePlayAnim(playerid,"FOOD","SHP_Thank", 4.0, 1, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "nod", true))
		{
		   	OnePlayAnim(playerid,"CRACK","Bbalbat_Idle_02", 4.0, 1, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "wank", true))
		{
		    ExitAnim[playerid] = 4;
            LoopingAnim(playerid,"PAULNMAC", "wank_loop", 1.800001, 1, 0, 0, 1, 600);
		}
		else if(!strcmp(name, "piss", true))
		{
		    ExitAnim[playerid] = 5;
		   	LoopingAnim(playerid,"PAULNMAC","Piss_loop",4.1,1,0,0,0,0);
		   	SetPlayerSpecialAction(playerid, 68);//Piss particles
		   	gPlayerUsingLoopingAnim[playerid] = 2;
		}
		else if(!strcmp(name, "sleep", true))
		{
		   	LoopingAnim(playerid,"CRACK","crckdeth1",4.1,1,0,0,0,0);
		}
		else if(!strcmp(name, "point", true))
		{
		    ExitAnim[playerid] = 11;
		   	LoopingAnim(playerid,"ON_LOOKERS","Pointup_loop",4.1,1,0,0,0,0);
		}
		else if(!strcmp(name, "shout", true))
		{
		    if(id == 1)
		    {
		   		OnePlayAnim(playerid,"ON_LOOKERS", "shout_01", 4.0, 0, 0, 0, 0, 0);
			}
			else if(id == 2)
			{
			    OnePlayAnim(playerid,"ON_LOOKERS", "shout_02", 4.0, 0, 0, 0, 0, 0);
			}
			else
		    {
			    SendClientMessage(playerid, COLOR_WHITE, "USAGE: (/An)imation shout [ID]");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "1,2");
			}
		}
		else if(!strcmp(name, "look", true))
		{
		    OnePlayAnim(playerid,"ON_LOOKERS", "lkaround_loop", 4.0, 0, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "aim", true))
		{
		   	LoopingAnim(playerid,"ped", "ARRESTgun", 4.0, 1, 0, 0, 0, 0);
		}
		else if(!strcmp(name, "CPR", true))
		{
		   	OnePlayAnim(playerid,"MEDIC", "CPR", 4.0, 0, 0, 0, 0, 0);
		}
		//Car anims
		else if(!strcmp(name, "fixcar", true))
		{
		    ExitAnim[playerid] = 7;
		   	LoopingAnim(playerid,"CAR","Fixn_Car_Loop",4.1,1,0,0,0,0);
		}
		else if(!strcmp(name, "flag", true))
		{
		   	OnePlayAnim(playerid,"CAR","flag_drop",4.1,0,0,0,0,0);
		}
		//Gang anims
		else if(!strcmp(name, "bat", true))
		{
		    if(id == 1)
		    {
		   		OnePlayAnim(playerid,"CRACK","Bbalbat_Idle_01",4.1,0,0,0,0,0);
			}
			else if(id == 2)
			{
			    OnePlayAnim(playerid,"CRACK","Bbalbat_Idle_02",4.1,0,0,0,0,0);
			}
			else
			{
			    SendClientMessage(playerid, COLOR_WHITE, "USAGE: (/An)imation bat [ID]");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "1 - Bat on shoulder");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "2 - Neck crack");
			}
		}
		else if(!strcmp(name, "lean", true))
		{
		    if(id == 1)
		    {
		    	LoopingAnim(playerid,"GANGS","leanIDLE",4.1,1,0,0,0,0);
			}
			else if(id == 2)
			{
			    LoopingAnim(playerid,"MISC","Plyrlean_loop",4.1,1,0,0,0,0);
			}
			else
			{
			    SendClientMessage(playerid, COLOR_WHITE, "USAGE: (/An)imation lean [ID]");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "1 - Back lean");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "2 - Left lean");
			}
		}
		else if(!strcmp(name, "gang", true))
		{
		    if(id == 1)
			{
			    OnePlayAnim(playerid,"GHANDS","gsign1",4.1,0,0,0,0,0);
			}
			else if(id == 2)
			{
			    OnePlayAnim(playerid,"GHANDS","gsign2",4.1,0,0,0,0,0);
			}
			else if(id == 3)
			{
			    OnePlayAnim(playerid,"GHANDS","gsign3",4.1,0,0,0,0,0);
			}
			else if(id == 4)
			{
			    OnePlayAnim(playerid,"GHANDS","gsign4",4.1,0,0,0,0,0);
			}
			else if(id == 5)
			{
			    OnePlayAnim(playerid,"GHANDS","gsign5",4.1,0,0,0,0,0);
			}
			else if(id == 6)
			{
			    OnePlayAnim(playerid,"GHANDS","gsign1LH",4.1,0,0,0,0,0);
			}
			else if(id == 7)
			{
			    OnePlayAnim(playerid,"GHANDS","gsign2LH",4.1,0,0,0,0,0);
			}
			else if(id == 8)
			{
			    OnePlayAnim(playerid,"GHANDS","gsign3LH",4.1,0,0,0,0,0);
			}
			else if(id == 9)
			{
			    OnePlayAnim(playerid,"GHANDS","gsign4LH",4.1,0,0,0,0,0);
			}
			else if(id == 10)
			{
			    OnePlayAnim(playerid,"GHANDS","gsign5LH",4.1,0,0,0,0,0);
			}
			else
			{
			    SendClientMessage(playerid, COLOR_WHITE, "USAGE: (/An)imation gang [ID]");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "1 to 10");
			}
		}
		else if(!strcmp(name, "wallshoot", true))
		{
		    if(id == 1)
		    {
		        OnePlayAnim(playerid,"HEIST9","swt_wllshoot_out_L",4.1,0,0,0,0,0);
		    }
		    else if(id == 2)
		    {
		        OnePlayAnim(playerid,"HEIST9","swt_wllshoot_out_R",4.1,0,0,0,0,0);
		    }
		    else
		    {
			    SendClientMessage(playerid, COLOR_WHITE, "USAGE: (/An)imation wallshoot [ID]");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "1 - Shoot left");
			    SendClientMessage(playerid, COLOR_LIGHTBLUE, "2 - Shoot right");
			}
		}
		else if(!strcmp(name, "what", true))
		{
		    OnePlayAnim(playerid,"RIOT","RIOT_ANGRY",4.1,0,0,0,0,0);
		}
		else if(!strcmp(name, "insult", true))
		{
		    OnePlayAnim(playerid,"RIOT","RIOT_FUKU",4.1,0,0,0,0,0);
		}
		else if(!strcmp(name, "list", true))
		{
			cmd_animlist(playerid);
		}
		else
		{
		    SendClientMessage(playerid, COLOR_LIGHTRED, "   Invalid name!");
		}
		return 1;
	}
	else
	{
	    SendClientMessage(playerid, COLOR_WHITE, "USAGE: (/An)imation [Name]");
	    SendClientMessage(playerid, COLOR_LIGHTBLUE, "For a list of all animations type '/animlist'.");
	}
	return 1;
}

CMD:kiss(playerid, params[])
{
    if(!IsPlayerBusy(playerid)) return 1;
    
    if(CallRemoteFunction("IsPlayerBlocked", "d", playerid) != 0)
    {
        SendClientMessage(playerid, COLOR_LIGHTRED, "   You can't do that right now!");
        return 1;
	}
	new playa,style;
	if(!sscanf(params, "ui", playa, style))
	{
	    if(IsPlayerConnected(playa))
	    {
	        if(ProxDetectorS(1.5, playerid, playa))//Make sure they are close enough for the anim to work
	        {
	            if(style < 0 || style > 3)
	            {
	                SendClientMessage(playerid, COLOR_LIGHTRED, "   Invalid style! (1-3)");
	                return 1;
				}
	            ChosenStyle[playa] = style;
	            Offer[playa] = playerid;
	            new string[100];
	            format(string, sizeof(string), "* %s wants to greet you. Type '/Kiss' to accept.", PlayerNameEx(playerid));
	            SendClientMessage(playa, COLOR_LIGHTBLUE, string);
	            format(string, sizeof(string), "* You offered %s a greeting.", PlayerNameEx(playa));
	            SendClientMessage(playa, COLOR_LIGHTBLUE, string);
	            return 1;
	        }
	        else
	        {
	            SendClientMessage(playerid, COLOR_LIGHTRED, "   You are too far away!");
	            return 1;
			}
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED, "   Invalid player!");
	        return 1;
		}
	}
	else
	{
	    if(Offer[playerid] > -1)
	    {
			playa = Offer[playerid];
			style = ChosenStyle[playerid];
			if(IsPlayerConnected(playa))
		    {
		        if(ProxDetectorS(1.5, playerid, playa))//Make sure they are close enough for the anim to work
		        {
		            SetPlayerToFacePlayer(playerid, playa);//Make em face each other
		            if(style == 1)
		            {
		                OnePlayAnim(playerid,"KISSING","Grlfrd_Kiss_01",4.1,0,0,0,0,0);
		                OnePlayAnim(playa,"KISSING","Playa_Kiss_01",4.1,0,0,0,0,0);
		            }
		            else if(style == 2)
		            {
		                OnePlayAnim(playerid,"KISSING","Grlfrd_Kiss_02",4.1,0,0,0,0,0);
		                OnePlayAnim(playa,"KISSING","Playa_Kiss_02",4.1,0,0,0,0,0);
		            }
		            else if(style == 3)
		            {
		                OnePlayAnim(playerid,"KISSING","Grlfrd_Kiss_03",4.1,0,0,0,0,0);
		                OnePlayAnim(playa,"KISSING","Playa_Kiss_03",4.1,0,0,0,0,0);
		            }
		            else//Should anything happen just use the default
		            {
		                OnePlayAnim(playerid,"KISSING","Grlfrd_Kiss_03",4.1,0,0,0,0,0);
		                OnePlayAnim(playa,"KISSING","Playa_Kiss_03",4.1,0,0,0,0,0);
		            }
		            return 1;
				}
		        else
		        {
		            SendClientMessage(playerid, COLOR_LIGHTRED, "   You are too far away!");
				}
		    }
		    else
		    {
		        SendClientMessage(playerid, COLOR_LIGHTRED, "   Invalid player!");
			}
	        Offer[playerid] = -1;
	        ChosenStyle[playerid] = 0;
	    }
	    else
	    {
	    	SendClientMessage(playerid, COLOR_WHITE, "USAGE: /Kiss [playerid/PartOfName] [Style ID]");
	    	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Styles: 1 - 3");
		}
	}
	return 1;
}

CMD:greet(playerid, params[])
{
    if(!IsPlayerBusy(playerid)) return 1;
    
    if(CallRemoteFunction("IsPlayerBlocked", "d", playerid) != 0)
    {
        SendClientMessage(playerid, COLOR_LIGHTRED, "   You can't do that right now!");
        return 1;
	}
	new playa,style;
	if(!sscanf(params, "ui", playa, style))
	{
	    if(IsPlayerConnected(playa))
	    {
	        if(ProxDetectorS(1.5, playerid, playa))//Make sure they are close enough for the anim to work
	        {
	            if(style < 0 || style > 9)
	            {
	                SendClientMessage(playerid, COLOR_LIGHTRED, "   Invalid style! (1-9)");
	                return 1;
				}
	            ChosenStyle[playa] = style;
	            Offer[playa] = playerid;
	            new string[100];
	            format(string, sizeof(string), "* %s wants to greet you. Type '/Greet' to accept.", PlayerNameEx(playerid));
	            SendClientMessage(playa, COLOR_LIGHTBLUE, string);
	            format(string, sizeof(string), "* You offered %s a greeting.", PlayerNameEx(playa));
	            SendClientMessage(playa, COLOR_LIGHTBLUE, string);
	            return 1;
	        }
	        else
	        {
	            SendClientMessage(playerid, COLOR_LIGHTRED, "   You are too far away!");
	            return 1;
			}
	    }
	    else
	    {
	        SendClientMessage(playerid, COLOR_LIGHTRED, "   Invalid player!");
	        return 1;
		}
	}
	else
	{
	    if(Offer[playerid] > -1)
	    {
			playa = Offer[playerid];
			style = ChosenStyle[playerid];
			if(IsPlayerConnected(playa))
		    {
		        if(ProxDetectorS(1.5, playerid, playa))//Make sure they are close enough for the anim to work
		        {
		            SetPlayerToFacePlayer(playerid, playa);//Make em face each other
		            if(style == 1)
		            {
		                OnePlayAnim(playerid,"GANGS","hndshkaa",4.1,0,0,0,0,0);
		                OnePlayAnim(playa,"GANGS","hndshkaa",4.1,0,0,0,0,0);
		            }
		            else if(style == 2)
		            {
		                OnePlayAnim(playerid,"GANGS","hndshkaa",4.1,0,0,0,0,0);
		                OnePlayAnim(playa,"GANGS","hndshkaa",4.1,0,0,0,0,0);
		            }
		            else if(style == 3)
		            {
		                OnePlayAnim(playerid,"GANGS","hndshkba",4.1,0,0,0,0,0);
		                OnePlayAnim(playa,"GANGS","hndshkba",4.1,0,0,0,0,0);
		            }
		            else if(style == 4)
		            {
		                OnePlayAnim(playerid,"GANGS","hndshkca",4.1,0,0,0,0,0);
		                OnePlayAnim(playa,"GANGS","hndshkca",4.1,0,0,0,0,0);
		            }
		            else if(style == 5)
		            {
		                OnePlayAnim(playerid,"GANGS","hndshkda",4.1,0,0,0,0,0);
		                OnePlayAnim(playa,"GANGS","hndshkda",4.1,0,0,0,0,0);
		            }
		            else if(style == 6)
		            {
		                OnePlayAnim(playerid,"GANGS","hndshkea",4.1,0,0,0,0,0);
		                OnePlayAnim(playa,"GANGS","hndshkea",4.1,0,0,0,0,0);
		            }
		            else if(style == 7)
		            {
		                OnePlayAnim(playerid,"GANGS","hndshkfa",4.1,0,0,0,0,0);
		                OnePlayAnim(playa,"GANGS","hndshkfa",4.1,0,0,0,0,0);
		            }
		            else if(style == 8)
		            {
		                OnePlayAnim(playerid,"GANGS","prtial_hndshk_01",4.1,0,0,0,0,0);
		                OnePlayAnim(playa,"GANGS","prtial_hndshk_01",4.1,0,0,0,0,0);
		            }
		            else if(style == 9)
		            {
		                OnePlayAnim(playerid,"GANGS","prtial_hndshk_biz_01",4.1,0,0,0,0,0);
		                OnePlayAnim(playa,"GANGS","prtial_hndshk_biz_01",4.1,0,0,0,0,0);
		            }
		            else//Should anything happen just use the default
		            {
		                OnePlayAnim(playerid,"GANGS","prtial_hndshk_biz_01",4.1,0,0,0,0,0);
		                OnePlayAnim(playa,"GANGS","prtial_hndshk_biz_01",4.1,0,0,0,0,0);
		            }
		            return 1;
				}
		        else
		        {
		            SendClientMessage(playerid, COLOR_LIGHTRED, "   You are too far away!");
				}
		    }
		    else
		    {
		        SendClientMessage(playerid, COLOR_LIGHTRED, "   Invalid player!");
			}
	        Offer[playerid] = -1;
	        ChosenStyle[playerid] = 0;
	    }
	    else
	    {
	    	SendClientMessage(playerid, COLOR_WHITE, "USAGE: /Greet [playerid/PartOfName] [Style ID]");
	    	SendClientMessage(playerid, COLOR_LIGHTBLUE, "Styles: 1 - 9");
		}
	}
	return 1;
}

// ( CnR - Private Chat )
CMD:tpm( playerid , params [ ] )
{
	new
		CNRText[ 128 ]
	;
	if ( PlayerInfo[ playerid ][ ActionID ] != 2 ) return SendClientMessage( playerid, COLOR_ULTRARED, "{FF0000}ERROR: {C8C8C8}You must be in a CnR minigame to use this command!" );
	if ( sscanf( params, "s[128]", CNRText ) ) return SendClientMessage( playerid, COLOR_ULTRARED, "{FF0000}» {DB881A}USAGE: {FFE4C4}/tpm <text>" );
	if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
	{
		foreach( Player, i )
		{
      		if ( GetPlayerTeam( i ) == TEAM_ROBBERS || GetPlayerTeam( i ) == TEAM_PROROBBERS || GetPlayerTeam( i ) == TEAM_EROBBERS )
		    {
				FormatMSG( i, ~1, "{FF0000}[TPM] {FFFF00}%s(%i): %s", PlayerName( playerid ), playerid, CNRText );
	    	}
	    }
	}
	if ( GetPlayerTeam( playerid ) == TEAM_COPS || GetPlayerTeam( playerid ) == TEAM_ARMY || GetPlayerTeam( playerid ) == TEAM_SWAT )
	{
		foreach( Player, i )
		{
		    if ( GetPlayerTeam( i ) == TEAM_COPS || GetPlayerTeam( i ) == TEAM_ARMY || GetPlayerTeam( i ) == TEAM_SWAT )
		    {
				FormatMSG( i, ~1, "{FF0000}[TPM] {15D4ED}%s(%i): %s", PlayerName( playerid ), playerid, CNRText );
	    	}
	    }
	}
	return ( 1 );
}

CMD:leave(playerid, params[])
{
	return cmd_exit(playerid);
}

CMD:setarrest( playerid, params[ ] )
{
	if ( !IsPlayerAdmin( playerid ) )
		return SendClientMessage( playerid,-1, "{C8C8C8}You are not authorized to use this command!" );
    new
		Player,
  		value
	;
	if ( sscanf( params, "ui", Player, value ) )
		return SendClientMessage( playerid, COLOR_ULTRARED, "{FF0000}» {DB881A}USAGE: {FFE4C4}/setarrest [PlayerID] [arrests]" );

	if ( !IsPlayerConnected( Player ) )
		return SendClientMessage( playerid,-1, "{FF0000}Player is not connected" );

	PlayerInfo[ Player ][ Arrests] = value;
    if ( Player != playerid )
    {
        FormatMSG( Player, -1, "{00FFFF}Administrator \"%s\" has set your arrests to '%d'", PlayerName( playerid ), value );
        FormatMSG( playerid, -1, "{00FFFF}You have set \"%s's\" arrests to '%d'", PlayerName( Player ), value );
    }
    else
    	FormatMSG( playerid, -1, "{00FFFF}You set your arrests to '%d'", value );

    return ( 1 );
}
CMD:settakedown( playerid, params[ ] )
{
	if ( !IsPlayerAdmin( playerid ) )
		return SendClientMessage( playerid,-1, "{C8C8C8}You are not authorized to use this command!" );
    new
		Player,
  		value
	;
	if ( sscanf( params, "ui", Player, value ) )
		return SendClientMessage( playerid, COLOR_ULTRARED, "{FF0000}» {DB881A}USAGE: {FFE4C4}/settakedown [PlayerID] [takedown]" );

	if ( !IsPlayerConnected( Player ) )
		return SendClientMessage( playerid,-1, "{FF0000}Player is not connected" );

	PlayerInfo[ Player ][ Takedowns] = value;
    if ( Player != playerid )
    {
        FormatMSG( Player, -1, "{00FFFF}Administrator \"%s\" has set your takedown to '%d'", PlayerName( playerid ), value );
        FormatMSG( playerid, -1, "{00FFFF}You have set \"%s's\" takedown to '%d'", PlayerName( Player ), value );
    }
    else
    	FormatMSG( playerid, -1, "{00FFFF}You set your takedown to '%d'", value );

    return ( 1 );
}
CMD:setrobberies( playerid, params[ ] )
{
	if ( !IsPlayerAdmin( playerid ) )
		return SendClientMessage( playerid,-1, "{C8C8C8}You are not authorized to use this command!" );
    new
		Player,
  		value
	;
	if ( sscanf( params, "ui", Player, value ) )
		return SendClientMessage( playerid, COLOR_ULTRARED, "{FF0000}» {DB881A}USAGE: {FFE4C4}/setrobberies [PlayerID] [robberies]" );

	if ( !IsPlayerConnected( Player ) )
		return SendClientMessage( playerid,-1, "{FF0000}Player is not connected" );

	PlayerInfo[ Player ][ Robberies ] = value;
    if ( Player != playerid )
    {
        FormatMSG( Player, -1, ""DBLUE_"Administrator \"%s\" has set your robberies to '%d'", PlayerName( playerid ), value );
        FormatMSG( playerid, -1, ""DBLUE_"You have set \"%s's\" robberies to '%d'", PlayerName( Player ), value );
    }
    else
    	FormatMSG( playerid, -1, ""DBLUE_"You set your robberiess to '%d'", value );

    return ( 1 );
}
CMD:setcopskilled( playerid, params[ ] )
{
	if ( !IsPlayerAdmin( playerid ) )
		return SendClientMessage( playerid,-1, "{C8C8C8}You are not authorized to use this command!" );
    new
		Player,
  		value
	;
	if ( sscanf( params, "ui", Player, value ) )
		return SendClientMessage( playerid, COLOR_ULTRARED, "{FF0000}» {DB881A}USAGE: {FFE4C4}/setcopskilled [PlayerID] [copskilled]" );

	if ( !IsPlayerConnected( Player ) )
		return SendClientMessage( playerid,-1, "{FF0000}Player is not connected" );

	PlayerInfo[ Player ][ CopsKilled ] = value;
    if ( Player != playerid )
    {
        FormatMSG( Player, -1, ""DBLUE_"Administrator \"%s\" has set your cops killed to '%d'", PlayerName( playerid ), value );
        FormatMSG( playerid, -1, ""DBLUE_"You have set \"%s's\" cops killed to '%d'", PlayerName( Player ), value );
    }
    else
    	FormatMSG( playerid, -1, ""DBLUE_"You set your cops killed to '%d'", value );

    return ( 1 );
}

CMD:rob( playerid, params[ ] )
{
    if ( PlayerInfo[ playerid ][ ActionID ] != 2 ) 	return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a robber while in a /CnR minigame to use this command!");
    if ( GetPlayerTeam( playerid ) != TEAM_ROBBERS && GetPlayerTeam( playerid ) != TEAM_PROROBBERS && GetPlayerTeam( playerid ) != TEAM_EROBBERS ) 	return SendClientMessage(playerid,-1,"{FF0000}ERROR: {C8C8C8}You must be a robber in CnR to use this command!");
    if ( IsPlayerInAnyVehicle( playerid ) ) return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be on foot to commit robberies.");
	if ( Robstart[ playerid ] == 1  )
	{
	    if( RobOn[ playerid ] == 1 ) 					return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You have recently robbed a shop, you can only rob a store once every 2 minutes.");
		TogglePlayerControllable(playerid,1);
		robberytime=25;
		robberytiming = SetTimerEx("Robberytimer",1000,1,"i",playerid);
		TextDrawShowForPlayer(playerid, RobTD);
		SendClientMessage( playerid, COLOR_ULTRARED,"{0000FF}CnR: {DB881A}You have started a robbery, the cops have been notified!");
		foreach( Player, i )
		{
				if ( GetPlayerTeam( i ) == TEAM_COPS || GetPlayerTeam( i ) == TEAM_ARMY || GetPlayerTeam( i ) == TEAM_SWAT )
				{
					if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS )
					{
						format( gsString, sizeof( gsString ), "{004BFF}COP RADIO: {15D4ED}Suspect %s(%i) has started a robbery at the %s in %s. Units respond!", PlayerName( playerid ), playerid,PlayerInfo[ playerid ][ ShopRobbed ],PlayerInfo[ playerid ][ Zone ]);
						SendClientMessage( i, COLOR_ULTRARED,gsString);
					}
					if ( GetPlayerTeam( playerid ) == TEAM_PROROBBERS )
					{
						format( gsString, sizeof( gsString ), "{004BFF}COP RADIO: {15D4ED}Suspect %s(%i) has started a robbery at the %s in %s. Units respond!", PlayerName( playerid ), playerid,PlayerInfo[ playerid ][ ShopRobbed ],PlayerInfo[ playerid ][ Zone ]);
						SendClientMessage( i, COLOR_ULTRARED,gsString);
					}
					if ( GetPlayerTeam( playerid ) == TEAM_EROBBERS )
					{
						format( gsString, sizeof( gsString ), "{004BFF}COP RADIO: {15D4ED}Suspect %s(%i) has started a robbery at the %s in %s. Units respond!", PlayerName( playerid ), playerid,PlayerInfo[ playerid ][ ShopRobbed ],PlayerInfo[ playerid ][ Zone ]);
						SendClientMessage( i, COLOR_ULTRARED,gsString);

					}
				}
		}
		ApplyAnimation( playerid, "SHOP", "ROB_Loop_Threat", 4.0, 1, 0, 0, 0, 0 );
		RobOn[ playerid ] = ( 1 );
		SetTimerEx( "RobTimmer", 120000, 0, "i", playerid );
		SetPlayerAttachedObject( playerid, 0, 1550, 15, 0.016491, 0.205742, -0.208498, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000 ); // Money Bag
	}
	else
	{
		new id=-255, Float:x,Float:y,Float:z;
	    if ( PlayerInfo[ playerid ][ ActionID ] != 2 ) 	return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a robber while in a /CnR minigame to use this command!");
	    if ( GetPlayerTeam( playerid ) != TEAM_ROBBERS && GetPlayerTeam( playerid ) != TEAM_PROROBBERS && GetPlayerTeam( playerid ) != TEAM_EROBBERS ) 	return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a robber while in a /CnR minigame to use this command!");
		GetPlayerPos(playerid,x,y,z);
		if(!isnull(params))
		{
		  sscanf(params, "u", id);
	   	  if(!IsPlayerConnected(id))  return SendClientMessage(playerid, COLOR_RED, " "RED_"» Error Â« {BABABA}» Error Â« {BABABA}This player is not connected");
		  else if(id == playerid)  SendClientMessage(playerid, COLOR_RED," "RED_"» Error Â« {BABABA}You can't rob yourself!");
		  else
		  {
		     if(IsPlayerInRangeOfPoint(id,4.00,x,y,z)) robplayer(playerid,id);
		     else SendClientMessage(playerid, COLOR_RED," "RED_"» Error Â« {BABABA}This player is too far away from you!");
		  }
		}
		else
		{
		   foreach (new i : Player)
		   {
		      if(IsPlayerInRangeOfPoint(i,4.00,x,y,z) && i != playerid)
		      {
				  id=i;
				  break;
		      }
		   }
		   if(id == -255) SendClientMessage(playerid, COLOR_RED,"{FF0000}CnR: {778899}No players to rob near you."); else robplayer(playerid,id);
		}
	}
	return true;
}

CMD:bk(playerid, params[])
{
	if ( PlayerInfo[ playerid ][ ActionID ] != 2 ) 	return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must in the CnR minigame to use this command!");
	gsString[ 0 ] = EOS;
	if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
	{
		foreach( Player, i )
		{
      		if ( GetPlayerTeam( i ) == TEAM_ROBBERS || GetPlayerTeam( i ) == TEAM_PROROBBERS || GetPlayerTeam( i ) == TEAM_EROBBERS )
		    {
				FormatMSG( i, ~1, "{FF0000}ROBBER RADIO: {DB881A}%s(%d) is requesting backup! Location: %s", PlayerName( playerid ), playerid, PlayerInfo[ playerid ][ Zone ] );
	    	}
	    }
	}
	if ( GetPlayerTeam( playerid ) == TEAM_COPS || GetPlayerTeam( playerid ) == TEAM_ARMY || GetPlayerTeam( playerid ) == TEAM_SWAT )
	{
		foreach( Player, i )
		{
		    if ( GetPlayerTeam( i ) == TEAM_COPS || GetPlayerTeam( i ) == TEAM_ARMY || GetPlayerTeam( i ) == TEAM_SWAT )
		    {
				FormatMSG( i, ~1, "{004BFF}COP RADIO: {15D4ED}Officer %s(%d) is requesting backup! Location: %s", PlayerName( playerid ), playerid, PlayerInfo[ playerid ][ Zone ] );
	    	}
	    }
	}
	return true;
}

CMD:stun(playerid,params[])
{
	if ( PlayerInfo[ playerid ][ ActionID ] != 2 ) 	return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must in the CnR minigame to use this command!");
	if ( GetPlayerTeam( playerid ) != TEAM_ARMY && GetPlayerTeam( playerid ) != TEAM_SWAT ) 		return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a army/swats while in a /CnR minigame to use this command!");
    if ( ( GetTickCount() - TickCount[ playerid ][StunTK] ) < 10000 ) return SendClientMessage( playerid, COLOR_RED, " "RED_"» Error Â« {BABABA}You can't stun that often!" );

	new id=-255, Float:x,Float:y,Float:z;
	GetPlayerPos(playerid,x,y,z);
	if(!isnull(params))
	{
	  sscanf(params, "u", id);
   	  if(!IsPlayerConnected(id))  return SendClientMessage(playerid, COLOR_RED, " "RED_"» Error Â« {BABABA}This player is not connected");
	  else if(id == playerid)  SendClientMessage(playerid, COLOR_RED," "RED_"» Error Â« {BABABA}You cant stun yourself!");
	  else
	  {
	     if(IsPlayerInRangeOfPoint(id,3.00,x,y,z)) stunplayer(playerid,id);
	     else SendClientMessage(playerid, COLOR_RED," "RED_"» Error Â« {BABABA}This player is too far away from you!");
	  }
	}
	else
	{
	   foreach (new i : Player)
	   {
	      if(IsPlayerInRangeOfPoint(i,3.00,x,y,z) && i != playerid)
	      {
			  id=i;
			  break;
	      }
	   }
	   if(id == -255) SendClientMessage(playerid, COLOR_RED," "RED_"» Error Â« {BABABA}There are no robbers near you to stun!");
	   else stunplayer(playerid,id);
	}
	return 1;
}
CMD:cuff(playerid,params[])
{
	new id=-255, Float:x,Float:y,Float:z;
	if ( PlayerInfo[ playerid ][ ActionID ] != 2 ) 	return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must in the CnR minigame to use this command!");
	if ( GetPlayerTeam( playerid ) !=  TEAM_SWAT ) 		return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a Swat while in a /CnR minigame to use this command!");
	GetPlayerPos(playerid,x,y,z);
	if(GetPlayerWantedLevel(id) < 1) return SendClientMessage(playerid, COLOR_RED," "RED_"{FF0000}ERROR: {C8C8C8}ERROR: Player has Wanted Level of 0 or lower!");
	if(!isnull(params))
	{
	  sscanf(params, "u", id);
   	  if(!IsPlayerConnected(id))  return SendClientMessage(playerid, COLOR_RED, " "RED_"» Error Â« {BABABA}This player is not connected");
	  else if(id == playerid)  SendClientMessage(playerid, COLOR_RED," "RED_"» Error Â« {BABABA}You cant cuff yourself!");
	  else
	  {
	     if(IsPlayerInRangeOfPoint(id,3.00,x,y,z)) cuffplayer(playerid,id);
	     else SendClientMessage(playerid, COLOR_RED," "RED_"» Error Â« {BABABA}This player is too far away from you!");
	  }
	}
	else
	{
	   foreach (new i : Player)
	   {
	      if(IsPlayerInRangeOfPoint(i,3.00,x,y,z) && i != playerid)
	      {
			  id=i;
			  break;
	      }
	   }
	   if(id == -255) SendClientMessage(playerid, COLOR_RED," "RED_"» Error Â« {BABABA}There are no robbers near you to cuff!"); else cuffplayer(playerid,id);
	}
	return 1;
}

CMD:bomb(playerid,params[])
{
	new id=-255, Float:x,Float:y,Float:z;
	if ( PlayerInfo[ playerid ][ ActionID ] != 2 ) 	return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a elite robber while in a /CnR minigame to use this command!");
	if ( GetPlayerTeam( playerid ) !=  TEAM_EROBBERS ) 		return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a elite robber while in a /CnR minigame to use this command!");
  	if( id  == INVALID_PLAYER_ID ) 				return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be near to cop to attach bomb!");
	GetPlayerPos(playerid,x,y,z);
	if(!isnull(params))
	{
	  sscanf(params, "u", id);
	  if(!IsPlayerConnected(id))  return SendClientMessage(playerid, COLOR_RED, " "RED_"» Error Â« {BABABA}This player is not connected");
	  else
	  {
	     if(IsPlayerInRangeOfPoint(id,3.00,x,y,z)) bombplayer(playerid,id);
	     else SendClientMessage(playerid, COLOR_RED," "RED_"» Error Â« {BABABA}This player is too far away from you!");
	  }
	}
	else
	{
	   foreach (new i : Player)
	   {
	      if(IsPlayerInRangeOfPoint(i,3.00,x,y,z) && i != playerid)
	      {
			  id=i;
			  break;
	      }
	   }
	   if(id == -255) SendClientMessage(playerid, COLOR_RED," "RED_"» Error Â« {BABABA}There are no players near you to bomb!");
	   else bombplayer(playerid,id);
	}
	return 1;
}

CMD:ar(playerid, params[])
{
	if ( PlayerInfo[ playerid ][ ActionID ] != 2 ) 	return  SendClientMessage(playerid, COLOR_RED," "RED_"{FF0000}ERROR: {C8C8C8}You must be a cop while in a /CnR minigame to use this command!");
	if ( GetPlayerTeam( playerid ) != TEAM_COPS && GetPlayerTeam( playerid ) != TEAM_ARMY && GetPlayerTeam( playerid ) != TEAM_SWAT ) 		return  SendClientMessage(playerid, COLOR_RED," "RED_"{FF0000}ERROR: {C8C8C8}You must be a cop while in a /CnR minigame to use this command!");
	new targetid = GetClosestPlayer( playerid, .checkvw = true, .range = 2.0 );
  	if( targetid == INVALID_PLAYER_ID ) 				return SendClientMessage(playerid, COLOR_RED," "RED_"{FF0000}CnR: {778899}No criminals near your range.");
	if( Cuffed[ targetid ] == true ) 					return SendClientMessage(playerid, COLOR_RED," "RED_"{FF0000}ERROR: {C8C8C8}Player just escaped from his arrest, please wait before arresting them!");
	if(GetPlayerWantedLevel(targetid) < 1) return SendClientMessage(playerid, COLOR_RED," "RED_"{FF0000}ERROR: {C8C8C8}ERROR: Player has Wanted Level of 0 or lower!");
	if(GetPlayerTeam( targetid ) != TEAM_ROBBERS && GetPlayerTeam( targetid ) != TEAM_PROROBBERS && GetPlayerTeam( targetid ) != TEAM_EROBBERS   ) 	return 1;
    PlayerInfo[ targetid ][ Timearrested]++;
    PlayerInfo[ targetid ][ BreakCuffs ] = 1;
    foreach( Player, i )
	{
		if ( GetPlayerTeam( playerid ) == TEAM_COPS )
		{
   			FormatMSG( i, ~1, "{7A7A7A}[CnR] {D2D2AB}Suspect %s(%d) has been arrested by Officer %s(%d).", PlayerName( targetid ), targetid, PlayerName( playerid ), playerid );
		}
		if ( GetPlayerTeam( playerid ) == TEAM_ARMY )
		{
			FormatMSG( i, ~1, "{7A7A7A}[CnR] {D2D2AB}Suspect %s(%d) has been arrested by {5A00FF}Army Officer {D2D2AB}%s(%d).", PlayerName( targetid ), targetid, PlayerName( playerid ), playerid );
		}
		if ( GetPlayerTeam( playerid ) == TEAM_SWAT )
		{
			FormatMSG( i, ~1, "{7A7A7A}[CnR] {D2D2AB}Suspect %s(%d) has been arrested by {15D4ED}Swat Captain {D2D2AB}%s(%d).", PlayerName( targetid ), targetid, PlayerName( playerid ), playerid );

		}
	}
	if(GetPlayerWantedLevel(targetid) > 1 && GetPlayerWantedLevel(targetid) < 3)
	{
		SetPlayerColor(targetid, 0xFFFFFFFF);
	}
	if(GetPlayerWantedLevel(targetid) > 3 && GetPlayerWantedLevel(targetid) < 5)
	{
		SetPlayerColor(targetid, 0x0080FFFF);
	}
	if(GetPlayerWantedLevel(targetid) > 5 && GetPlayerWantedLevel(targetid) < 7)
	{
		SetPlayerColor(targetid, 0xFF0000FF);
	}
	GivePlayerMoneyEx(playerid, 6500);
    SetPlayerScore(playerid, GetPlayerScore(playerid) + 2);
	jailtimer = SetTimerEx("Jailtimer", 4000, 0, "i", targetid);
	jailtimer2 = SetTimerEx("CnrJailRefresh", 4000, 0, "i", targetid);
	Cuffed[targetid] = true;
	Announce(playerid, "~r~~h~SUSPECT ARRESTED!", 4000, 4);
	Announce(targetid, "~r~ARRESTED~w~!~nl~~w~TYPE /BREAKCUFFS /BC ~n~~w~TO ESCAPE!", 4000, 4);
    SendClientMessage(playerid, COLOR_RED,"{FF0000}- CnR -  {3BBD44}You have received 2 score and $6500 for catching a criminal!");
	SendClientMessage(targetid, COLOR_RED,"{FF0000}CNR {7A7A7A}»{DBED15} {FF0000}You have been cuffed and arrested!");
	SendClientMessage(targetid, COLOR_RED,"{FF0000}CNR {7A7A7A}»{DBED15} {FF0000}You will serve 30 seconds in jail.");
	PlayerInfo[playerid][Arrests]++;
	return true;
}

CMD:bc(playerid, params[])
{
	if ( PlayerInfo[ playerid ][ ActionID ] != 2 ) 	return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a robber in CnR to use this command!");
	if ( GetPlayerTeam( playerid ) != TEAM_ROBBERS && GetPlayerTeam( playerid ) != TEAM_PROROBBERS && GetPlayerTeam( playerid ) != TEAM_EROBBERS ) 		return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a robber in CnR to use this command!");
	if( Cuffed[ playerid ] != true ) 					return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be cuffed to use this command!" );
	if ( PlayerInfo[ playerid ][ BreakCuffs ] == 0)     return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be cuffed to use this command!" );
	switch( random( 2 ) )
	{
	case 0:
	{
	SendClientMessage(playerid, COLOR_RED,"*** {FF0000}Your attempt to break your cuffs has failed,you will now serve jail time!");
	Announce( playerid, "~r~ESCAPE FAILED!", 2000, 4 );
	PlayerInfo[ playerid ][ BreakCuffs ] = 0;
	}
	case 1:
	{
	foreach( Player, i )
	{
	if( PlayerInfo[ i ][ InCNR] == 1 )
	{
	FormatMSG( i, ~1, "{7A7A7A}[CnR] {E65555}%s(%d) has evaded his arrest (Broke Handcuffs)", PlayerName( playerid ), playerid);
	}
	}
	Cuffed[ playerid ] = false;
	Announce( playerid, "~g~~h~~h~BROKE CUFFS!", 2000, 4 );
	KillTimer(jailtimer2);
	KillTimer(jailtimer);
	PlayerInfo[ playerid ][ BreakCuffs ] = 0;
	}
	}

    return true;
}
CMD:escape(playerid, params[])
{
	if ( PlayerInfo[ playerid ][ ActionID ] != 2 ) 	return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a robber while in jail to use this command!");
	if ( GetPlayerTeam( playerid ) != TEAM_ROBBERS && GetPlayerTeam( playerid ) != TEAM_PROROBBERS && GetPlayerTeam( playerid ) != TEAM_EROBBERS ) 		return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a robber while in jail to use this command!");
	if( Jailbreak [ playerid ]  == 1 ) 	return SendClientMessage(playerid, COLOR_RED," "RED_"» Jail Â« {BABABA}You can't break jail.You already tried to break jail.");
	if ( PlayerInfo[ playerid ][ Jailed ] == 0 ) return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You are not in jail");
    PlayerInfo[ playerid ][ Jailed ] = 1;
    gTime[ playerid ][ 0 ] = 1;
	gTime[ playerid ][ 1 ] = 1;
	Jailbreak[playerid] = 1;
	switch( random( 2 ) )
	{
		case 0:
		{
			foreach( Player, i )
			{
					if ( GetPlayerTeam( i ) == TEAM_COPS || GetPlayerTeam( i ) == TEAM_ARMY || GetPlayerTeam( i ) == TEAM_SWAT )
					{
						if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS )
						{
							format( gsString, sizeof( gsString ), "{004BFF}COP RADIO: {87CEFA}Suspect %s(%d) has failed an attempt escape from jail.", PlayerName( playerid ), playerid);
							SendClientMessage( i, COLOR_ULTRARED,gsString);
						}
						if ( GetPlayerTeam( playerid ) == TEAM_PROROBBERS )
						{
							format( gsString, sizeof( gsString ), "{004BFF}COP RADIO: {87CEFA}Suspect %s(%d) has failed an attempt escape from jail.", PlayerName( playerid ), playerid);
							SendClientMessage( i, COLOR_ULTRARED,gsString);
						}
						if ( GetPlayerTeam( playerid ) == TEAM_EROBBERS )
						{
							format( gsString, sizeof( gsString ), "{004BFF}COP RADIO: {87CEFA}Suspect %s(%d) has failed an attempt escape from jail.", PlayerName( playerid ), playerid);
							SendClientMessage( i, COLOR_ULTRARED,gsString);

						}
					}
			}
			Announce( playerid, "~r~ESCAPE FAILED!", 2000, 4 );
		 	SendClientMessage(playerid, COLOR_RED,"{FF0000}*** {FF0000}Your escape has failed, 20 seconds added to your jail sentence!");
			SetTimerEx( "JailReleasecnr", 50000, 0, "i", playerid );
		    gTime[ playerid ][ 0 ] = 1;
			gTime[ playerid ][ 1 ] = 1;
		}
		case 1:
		{
		    SendClientMessage(playerid, COLOR_RED,"*** {FF0000}You have escaped from jail, the cops have been notified!");
			foreach( Player, i )
			{
				if( PlayerInfo[ i ][ InCNR] == 1 )
				{
					FormatMSG( i, ~1, "{FF0000}*** %s(%d) has escaped from prison!", PlayerName( playerid ), playerid);
				}
			}
			Announce( playerid, "~b~~h~~h~ESCAPED!", 2000, 4 );
			SetTimerEx( "JailReleasecnr", 100, 0, "i", playerid );
		    PlayerInfo[ playerid ][ Jailed ] = 0;
		    gTime[ playerid ][ 0 ] = 0;
			gTime[ playerid ][ 1 ] = 0;
		}
	}

    return true;
}
CMD:cnrstats( playerid, params[ ] )
{
    format( gsString, sizeof gsString, "{0000FF}%s(ID:%i) {00FFFF}stats:\n\n", PlayerName( playerid ),playerid);
	format( gsString, sizeof gsString, "%s{FF8000}Cops and Robbers Stats:\n\
										{00FFFF}> Arrests: {FFFFFF}%d\n\
										{00FFFF}> Takedowns: {FFFFFF}%d\n\
										{00FFFF}> Robberies: {FFFFFF}%d\n", gsString,PlayerInfo[ playerid ][ Arrests ],PlayerInfo[ playerid ][ Takedowns ],PlayerInfo[ playerid ][ Robberies ] );
	format( gsString, sizeof gsString, "%s{00FFFF}> Player Robberies: {FFFFFF}%d\n\
										{00FFFF}> Cops Killed: {FFFFFF}%d\n\
                                 		{00FFFF}> Times Arrested: {FFFFFF}%d\n\n", gsString,PlayerInfo[ playerid ][ PlayerRobberies ],PlayerInfo[ playerid ][ CopsKilled ], PlayerInfo[ playerid ][ Timearrested ] );

	ShowPlayerDialog(playerid,DIALOG_EMPTY,DIALOG_STYLE_MSGBOX,"{FF8000}CNR: {FFFFFF}CnR Statistics",gsString,"Exit","");
	return ( 1 );
}
CMD:cnrhelp( playerid, params[ ] )
{
    if ( PlayerInfo[ playerid ][ ActionID ] != 2 ) return SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You must be a robber while in a /CnR minigame to use this command!");
	if ( GetPlayerTeam( playerid ) == TEAM_COPS )
	{
		ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX ,  "{0000FF}Cop Help" , CopsHelp( ) , "Close" , "" );
	}
	if ( GetPlayerTeam( playerid ) == TEAM_ARMY )
	{
		ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX , "{8000FF}Army Help" , ArmyHelp( ) , "Close" , "" );
	}
	if ( GetPlayerTeam( playerid ) == TEAM_SWAT )
	{
		ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX , "{0000FF}Swat Help" , SwatHelp( ) , "Close" , "" );
	}
	if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS )
	{
		ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX , "{FF0000}Criminal Help" , RobsHelp( ) , "Close" , "" );
	}
	if ( GetPlayerTeam( playerid ) == TEAM_PROROBBERS )
	{
		ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX , "{FF0000}Pro Criminal Help" , ProRobsHelp( ) , "Close" , "" );
	}
	if ( GetPlayerTeam( playerid ) == TEAM_EROBBERS )
	{
		ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX , "{FF0000}Elite Criminal Help" , ERobsHelp( ) , "Close" , "" );
	}
	return ( 1 );
}
CMD:cnr( playerid , params [ ] )
{
    if(!IsPlayerBusy(playerid)) return 1;
    
	ShowPlayerDialog( playerid, DIALOG_CnR, DIALOG_STYLE_LIST, "{FF8000}Choose your Side", CNRMenu( ), "Select", "Exit" );
	return 1;
}

CMD:dreset(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return 1;
	for(new x=0; x<MAX_PLAYERS; x++)
	{
		if(!IsPlayerConnected(x)) continue;
		if(InDuel[x] == 1)
		{
		    InDuel[x] = 0;
		    SpawnPlayer(x);
		}
	}
 	SendClientMessageToAll(COLOR_DUEL, "The duel system has been reset!");
	return 1;
}

CMD:dinvites(playerid, params[])
{
    if(!IsPlayerBusy(playerid)) return 1;
    
	ShowDuelInvitesDialog(playerid);
	return 1;
}

CMD:daccept(playerid, params[])
{
	return cmd_dinvites(playerid, params);
    /*if(!IsPlayerBusy(playerid)) return 1;
    
	new listitem;
	if(sscanf(params, "d", listitem)) return SendClientMessage(playerid, COLOR_RED, "ERROR: This duel invite is not valid!");
 	if(listitem > MAX_INVITES) return 1;
 	new dueler = dinvitem[playerid][listitem];
 	if(dueler == INVALID_PLAYER_ID) return ShowPlayerDialog(playerid, DUELDIAG-1, DIALOG_STYLE_MSGBOX, "Duel Invites", "ERROR: This player is no longer connected!", "Ok", "");
  	SetPVarInt(playerid, "DuelDID", listitem);
	AcceptDuel(playerid);
	return 1;*/
}

CMD:duelmenu(playerid, params[])
{
    if(!IsPlayerBusy(playerid)) return 1;
    
	ShowDuelSettingsDialog(playerid);
	return 1;
}

CMD:duels(playerid, params[])
{
    if(!IsPlayerBusy(playerid)) return 1;
    
	format(diagstr, sizeof(diagstr), "");
	for(new x=0; x<MAX_PLAYERS; x++)
	{
 		for(new i=0; i<sizeof(diagitem); i++) if(x == diagitem[i]) continue; //Prevent duplicate duels
		if(InDuel[x] == 1)
		{
			new dueler = GetDuelerID(x);
			format(diagstr, sizeof(diagstr), "%s%s vs %s\n", diagstr, pDName(x), pDName(dueler));
			diagitem[TotalDuels] = x;
		}
	}
	if(TotalDuels < 1) format(diagstr, sizeof(diagstr), "There are currently no duels.");
	ShowPlayerDialog(playerid, DUELDIAG+7, DIALOG_STYLE_LIST, "Current Duels", diagstr, "Select", "Cancel");
	return 1;
}

CMD:dspecoff(playerid, params[])
{
	if(GetPVarInt(playerid, "DuelSpec") == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You are not spectating any duels!");
	EndDuelSpectate(playerid);
	return 1;
}

CMD:duel(playerid, params[])
{
    if(!IsPlayerBusy(playerid)) return 1;
    
	if(strfind(params, "create", true) != -1)
	{
		new third[60];
		sscanf(params[7], "s[60]", third);
	    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "You are not an admin!");
		if(GetPVarInt(playerid, "DuelEdit") == 1) return SendClientMessage(playerid, COLOR_RED, "You are already editing a duel!");

		new dName[90];
		if(unformat(third, "s[90]", dName)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /duel <create> <duelname>");
		else if(!strlen(dName)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /duel <create> <duelname>");
		else if(DuelNameExists(dName)) return SendClientMessage(playerid, COLOR_RED, "This duel name already exists");

		new getid = GetLowestDuelSlotID();
		format(dFile, sizeof(dFile), DUELFILES, getid);

		new Float:X6, Float:Y6, Float:Z6, Float:A6;
		GetPlayerPos(playerid, X6, Y6, Z6);
		GetPlayerFacingAngle(playerid, A6);

		dini_Create(dFile);
		dini_IntSet(dFile, "duelID", getid);
		dini_Set(dFile, "duelName", dName);
		dini_FloatSet(dFile, "duelX", X6);
		dini_FloatSet(dFile, "duelY", Y6);
		dini_FloatSet(dFile, "duelZ", Z6);
		dini_FloatSet(dFile, "duelA", A6);
		SetPVarInt(playerid, "DuelEdit", 1);
		SetPVarInt(playerid, "DuelID", getid);

		new str[200];
		format(str, sizeof(str), "Duel \"%s\" (ID: %d) created at: %f, %f, %f", dName, getid, X6, Y6, Z6);
		SendClientMessage(playerid, COLOR_DUEL, str);
		SendClientMessage(playerid, COLOR_DUEL, "Now go the second duelist position and type \"/duel <save>\" to set the position.");
		return 1;
	}
	if(strfind(params, "save", true) != -1)
	{
	    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "You are not an admin!");
		if(GetPVarInt(playerid, "DuelEdit") == 0) return SendClientMessage(playerid, COLOR_RED, "You are not editing a duel.");

		new duelID = GetPVarInt(playerid, "DuelID");
		format(dFile, sizeof(dFile), DUELFILES, duelID);

		new Float:X6, Float:Y6, Float:Z6, Float:A6;
		GetPlayerPos(playerid, X6, Y6, Z6);
		GetPlayerFacingAngle(playerid, A6);

		dini_FloatSet(dFile, "duel2X", X6);
		dini_FloatSet(dFile, "duel2Y", Y6);
		dini_FloatSet(dFile, "duel2Z", Z6);
		dini_FloatSet(dFile, "duel2A", A6);

		new str[180];
		format(str, sizeof(str), "Duel \"%s\" (ID: %d) second position set at: %f, %f, %f", ReturnDuelNameFromID(duelID), duelID, X6, Y6, Z6);
		SendClientMessage(playerid, COLOR_DUEL, str);

		SetPVarInt(playerid, "DuelEdit", 0);
		SetPVarInt(playerid, "DuelID", -1);
		return 1;
	}
	if(strfind(params, "invite", true) != -1)
	{
	    new third[60];
		sscanf(params[7], "s[60]", third);
		new target, gBet, gDuelSpot[85], gWeap[85], gWeap2[85], gWeap3[85];
		sscanf(third, "uis[85]s[85]s[85]s[85]", target, gBet, gDuelSpot, gWeap, gWeap2, gWeap3);
		if(target == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "Duel | Player not found");
		if(target == playerid) return SendClientMessage(playerid, COLOR_RED, "Duel | You can't invite yourself noob!");
		if(InDuel[playerid] == 1) return SendClientMessage(playerid, COLOR_DUEL, "Duel | You are already in a duel!");
		if(MINMONEY != 0 && gBet < 500) return SendClientMessage(playerid, COLOR_RED, "Duel | Minimum bet amount is 500");
		if(GetPlayerMoneyEx(playerid) < gBet) return SendClientMessage(playerid, COLOR_RED, "Duel | You don't have that amount of money to bet");
		if(GetPlayerMoneyEx(target) < gBet) return SendClientMessage(playerid, COLOR_RED, "Duel | This player does not have that amount of money!");
		if(ReturnDuelIDOrName(gDuelSpot) == 40) return SendClientMessage(playerid, COLOR_RED, "The duel id/name you entered does not exist!");
		//if(ReturnWeaponIDOrName(gWeap) == -1) return SendClientMessage(playerid, COLOR_RED, "Slot 1: Invalid Weapon ID or Name");
		if(GetPlayerState(target) == 9) return SendClientMessage(playerid, COLOR_RED, "Duel | This player is in spectate mode!");
		if(!strlen(gWeap2)) format(gWeap2, sizeof(gWeap2), "48");
		if(!strlen(gWeap3)) format(gWeap3, sizeof(gWeap3), "48");

		new duelloc = ReturnDuelIDOrName(gDuelSpot);
		new duelid = GetLowestUnusedDuelID();

		dInfo[duelid][Inviter] = playerid;
		dInfo[duelid][Invitee] = target;
		dInfo[duelid][BetMoney] = gBet;
		dInfo[duelid][Location] = duelloc;

		new Slot[3];
		Slot[0] = ReturnWeaponIDOrName(gWeap);
		Slot[1] = ReturnWeaponIDOrName(gWeap2);
		Slot[2] = ReturnWeaponIDOrName(gWeap3);

		dWeps[duelid][0] = Slot[0];
		dWeps[duelid][1] = Slot[1];
		dWeps[duelid][2] = Slot[2];

		new invid = GetLowestUnusedDuelSlot(target);
		dinvitem[target][invid] = playerid;

		SetTimerEx("DuelReset", INVITERESET, 0, "ii", playerid, target);

		new str[200];
		format(str, sizeof(str), "Duel invite from %s | (Bet: $%d) (Weapons: %s %s %s) (%s [ID %d])", pDName(playerid), gBet, weaponNames(Slot[0]), weaponNames(Slot[1]), weaponNames(Slot[2]), ReturnDuelNameFromID(duelloc), duelloc);
		SendClientMessage(target, COLOR_DUEL, str);
		SendClientMessage(target, COLOR_DUEL, "You can accept the invite from the duel invites menu. (Tip: Use /dinvites or /daccept <duelid>)");
		format(str, sizeof(str), "Duel | Waiting for %s's response to your duel invite", pDName(target));
		SendClientMessage(playerid, COLOR_DUEL, str);
		return 1;
	}
	if(strfind(params, "edit", true) != -1)
	{
		new third[60];
		sscanf(params[5], "s[60]", third);
	    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "You are not an admin!");
		if(GetPVarInt(playerid, "DuelEdit") == 1) return SendClientMessage(playerid, COLOR_RED, "You are already editing a duel!");

		new dName[90];
		if(unformat(third, "s[90]", dName)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /duel <edit> <duelid/name>");
		else if(!strlen(dName)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /duel <edit> <duelid/name>");
		else if(ReturnDuelIDOrName(dName) == -1) return SendClientMessage(playerid, COLOR_RED, "The duelid/name specified does not exist!");

		new getid = ReturnDuelIDOrName(dName);
		format(dFile, sizeof(dFile), DUELFILES, getid);

		new Float:X6, Float:Y6, Float:Z6, Float:A6;
		GetPlayerPos(playerid, X6, Y6, Z6);
		GetPlayerFacingAngle(playerid, A6);
		new dInterior = GetPlayerInterior(playerid);

		dini_FloatSet(dFile, "duelX", X6);
		dini_FloatSet(dFile, "duelY", Y6);
		dini_FloatSet(dFile, "duelZ", Z6);
		dini_FloatSet(dFile, "duelA", A6);
		SetPVarInt(playerid, "DuelEdit", 1);
		SetPVarInt(playerid, "DuelID", getid);

		new str[200];
		format(str, sizeof(str), "Duel \"%s\" (ID %d) edited at: %f, %f, %f (Interior %d)", dName, getid, X6, Y6, Z6, dInterior);
		SendClientMessage(playerid, COLOR_DUEL, str);
		SendClientMessage(playerid, COLOR_DUEL, "Now go the second duelist position and type \"/duel save\" to set the position.");
		return 1;
	}
	if(strfind(params, "setname", true) != -1)
	{
		new third[60];
		sscanf(params[8], "s[60]", third);
	    if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "You are not an admin!");

		new dName[90], dNewName[35];
		if(unformat(third, "s[90]s[35]", dName, dNewName)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /duel <setname> <duelid/name> <newduelname>");
		else if(!strlen(dName)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /duel <setname> <duelid/name> <newduelname>");
		else if(ReturnDuelIDOrName(dName) == -1) return SendClientMessage(playerid, COLOR_RED, "The duelid/name specified does not exist!");
		else if(strlen(dNewName) > 35) return SendClientMessage(playerid, COLOR_RED, "Max duel name length is 50 characters");

		new getid = ReturnDuelIDOrName(dName);
		format(dFile, sizeof(dFile), DUELFILES, getid);
		dini_Set(dFile, "duelName", dNewName);

		new str[200];
		format(str, sizeof(str), "Duel \"%s\" (ID: %d) is now named \"%s\"", dName, getid, dNewName);
		SendClientMessage(playerid, COLOR_DUEL, str);
		return 1;
	}
	if(strfind(params, "remove", true) != -1)
	{
		new third[60];
		sscanf(params[7], "s[60]", third);
    	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "ERROR: You are not an admin!");

		new dName[90];
		if(unformat(third, "s[90]", dName)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /duel <remove> <duelid/name>");
		else if(!strlen(dName)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /duel <remove> <duelid/name>");
		else if(!DuelNameExists(dName)) return SendClientMessage(playerid, COLOR_RED, "The duel id/name specified does not exist");
		else if(ReturnDuelIDOrName(dName) == -1) return SendClientMessage(playerid, COLOR_RED, "The duel id/name specified does not exist");

		new duelID = ReturnDuelIDOrName(dName);
		format(dFile, sizeof(dFile), DUELFILES, duelID);
		dini_Remove(dFile);

		new str[100];
		format(str, sizeof(str), "Duel \"%s\" (ID: %d) has been removed!", dName, duelID);
		SendClientMessage(playerid, COLOR_DUEL, str);
		return 1;
	}
	if(strfind(params, "help", true) != -1)
	{
		ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "{FFFF00}Duel Help", "{00FF00}Invite someone to a duel:\n{FFFFFF}/duel <invite> <playerid/name> <betamount> <duelspot> <wep1> <wep2> <wep3>\n\nExample: \"/duel invite Noob 500 SFBridge spas deagle\"\n{C0C0C0}You may enter partial weapon names.\nMinimum 1 weapon, max weps is 3.\n\n{00FFFF}Command '/duels' shows current duels to spectate or /duel <spec> <playerid/name>!\t\t\n\n{FF0000}Duel system by TBS Developers", "Ok", "");
		return 1;
	}
	if(strfind(params, "cmds", true) != -1)
	{
		if(!IsPlayerAdmin(playerid)) ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "{FFFF00}Duel Commands", "{00FFFF}User Commands\t\t\t{FFFFFF}Description\n\n{00FFFF}/duels\t\t\t\t\t{FFFFFF}Show the duel invite dialog!\n{00FFFF}/duel <cmds>\t\t\t\t{FFFFFF}Show a list of duel commands.\n{00FFFF}/duel <help>\t\t\t\t{FFFFFF}Help for dueling another player.\n{00FFFF}/duel <invite> <playerid/name>\t{FFFFFF}Invite a player to a duel!", "Ok", "");
		else
		{
			ShowPlayerDialog(playerid, 0, DIALOG_STYLE_MSGBOX, "{FFFF00}Duel Commands", "{00FFFF}User Commands\t\t\t{FFFFFF}Description\n\n{00FFFF}/duels\t\t\t\t\t{FFFFFF}Show the duel invite dialog!\n{00FFFF}/duel <cmds>\t\t\t\t{FFFFFF}Show a list of duel commands.\n{00FFFF}/duel <help>\t\t\t\t{FFFFFF}Help for dueling another player.\n{00FFFF}/duel <invite> <playerid/name>\t{FFFFFF}Invite a player to a duel!", "Ok", "");
			SendClientMessage(playerid, COLOR_DUEL, "DBuild: {00FF00}/duel <create> <name> {FFFFFF}Create map. Set 1st dueler position! | {00FF00}/duel <save> {FFFFFF}Save map, set 2nd dueler pos!");
			SendClientMessage(playerid, COLOR_DUEL, "{00FF00}/duel <edit> <mapid/name> {FFFFFF}Edit a map. Set 1st dueler position!");
			SendClientMessage(playerid, COLOR_DUEL, "{00FF00}duel <remove> <mapid/name> {FFFFFF}Delete a map. | {00FF00}/duel <setname> <mapid/name> <newname> {FFFFFF}Change a map name");
		}
		return 1;
	}
	if(strfind(params, "spec", true) != -1)
	{
	    new third[60];
		sscanf(params[5], "s[60]", third);

		new target;
		sscanf(third, "u", target);
		if(target == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "Duel | Player not found");
		if(InDuel[target] == 0) return SendClientMessage(playerid, COLOR_DUEL, "Duel | This player is not currently in a duel!");

		new str[90];
		format(str, sizeof(str), "Duel | You are now spectating %s duel.", pDName(target));
		SendClientMessage(target, COLOR_DUEL, "Duel | Type /dspecoff to exit at anytime!");
		SetPlayerSpectatingDuel(playerid, target);
		return 1;
	}
	else ShowDuelSettingsDialog(playerid);
	return 1;
}

CMD:godmode (playerid) return cmd_god(playerid);
CMD:god (playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
    
	switch (PlayerInfo[playerid][GodEnabled])
	{
	    case 0:
	    {
			new Float:h;
			GetPlayerHealth(playerid, h);
			if (h < 20) return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"Your health is very low! You cannot use /god.");
			EnableGod(playerid);
		}
		case 1:
		{
			DisableGod(playerid);
		}
	}
	return 1;
}


stock EnableGod(playerid)
{
    if(killStreak[playerid] != 0) killStreak[playerid] = 0, SendClientMessage(playerid, -1, ""RED"Your killstreak has been reset to 0.");
	SetPlayerHealth(playerid, FLOAT_INFINITY);
	TD_MSG(playerid, 3000, "~y~~h~God mode ~g~~h~activated");
	PlayerInfo[playerid][GodEnabled] = 1;
	ResetPlayerWeapons(playerid);
	return 1;
}

stock DisableGod(playerid)
{
	SetPlayerHealth(playerid, 100.0);
 	TD_MSG(playerid, 3000, "~y~~h~God mode ~r~~h~deactivated");
  	PlayerInfo[playerid][GodEnabled] = 0;
	GiveWeaponSet(playerid, PlayerInfo[playerid][WeaponSet]);
	return 1;
}

CMD:radios(playerid)
{
  SendClientMessage(playerid, COLOR_WHITE, " Radios: /tbs, /fresh, /njoy, /city, /party, /dubstep, /starfm, /trap, /usa, /defjay, /hot");
  SendClientMessage(playerid, COLOR_WHITE, "/bgradio, /zrock, /energy, /radio1, /thevoice, /cyberfolk, /fox, /dubstep2, /hits");
  SendClientMessage(playerid, COLOR_WHITE, "[Info] Some of the radios are Bulgarian. To stop a radio use: /stop");
  return 1;
}

CMD:radio(playerid)
{
  return cmd_radios(playerid);
}

CMD:tbs(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://62.75.158.36:8000/stream");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: The Best Stunts - Official!");
  return 1;
}

CMD:fresh(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://193.108.24.21:8000/fresh");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: Fresh!");
  return 1;
}

CMD:njoy(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://live.btvradio.bg/njoy.mp3.m3u");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: N-Joy!");
  return 1;
}

CMD:city(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://149.13.0.81/city.ogg");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: City!");
  return 1;
}

CMD:party(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://yp.shoutcast.com/sbin/tunein-station.pls?id=508962");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: Party!");
  return 1;
}

CMD:dubstep(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://www.dubstep.fm/listen.pls");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: Dupstep FM!");
  return 1;
}

CMD:starfm(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://pulsar.atlantis.bg:8000/starfm.m3u");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: Star FM!");
  return 1;
}

CMD:trap(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://radio.trap.fm/listen192.m3u");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: Trap!");
  return 1;
}

CMD:usa(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://listen.radionomy.com/americantop40");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: American Top 40 (USA)!");
  return 1;
}

CMD:bgradio(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://149.13..81/bgradio128");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: BG Radio!");
  return 1;
}

CMD:zrock(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://ng.btv.bg/m3u/zrock.m3u");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: ZRock!");
  return 1;
}

CMD:energy(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://149.13.0.80/nrj.ogg");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: Energy!");
  return 1;
}

CMD:radio1(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://149.13.0.81/radio1rock.ogg");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: Radio1 (Rock)!");
  return 1;
}

CMD:thevoice(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://31.13.223.148:8000/thevoice.mp3");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: The Voice!");
  return 1;
}

CMD:cyberfolk(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://play.radiocyberfolk.com");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: Cyber Folk!");
  return 1;
}

CMD:fox(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://www.foxbg.net:8000/listen.pls");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: Fox!");
  return 1;
}

CMD:dubstep2(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://yp.shoutcast.com/sbin/tunein-station.pls?id=39428");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: Dubstep 2!");
  return 1;
}

CMD:defjay(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://83.169.60.42:80");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: DEFJAY!");
  return 1;
}

CMD:hits(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://7609.live.streamtheworld.com:80/977_HITS_SC");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: Hits!");
  return 1;
}

CMD:hot(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://www.hot108.com/hot108.pls");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: Hot 108!");
  return 1;
}

CMD:ugh(playerid)
{
  PlayAudioStreamForPlayer(playerid, "http://43.225.188.110:8000/stream.m3u");
  SendClientMessage(playerid, COLOR_GREEN, "Playing Radio: UltraGameHost");
  return 1;
}

CMD:stop(playerid)
{
  StopAudioStreamForPlayer(playerid);
  SendClientMessage(playerid, COLOR_RED, "You have stopped your Radio/Song");
  return 1;
}


CMD:bank( playerid, params[ ] ) {
    if(!IsPlayerBusy(playerid)) return 1;
    
	if ( !bAcc{ playerid } ) {
	    ShowPlayerDialog( playerid, DIALOG_BANK2, DIALOG_STYLE_MSGBOX, "{FFFFFF}Bank Account",
	    "{FFFFFF}You don't have a bank account yet.\nWould you like to create a bank account?", "Yes", "No" );
	    return true;
	}
	else {
		ShowPlayerDialog( playerid, DIALOG_BANK, DIALOG_STYLE_LIST, "{FFFFFF}Bank Account",
		"{FFFFFF}Balance\nDeposit\nWithdraw", "Select", "Cancel" );
		return true;
	}
}

CMD:housemenu(playerid, params[])
{
	#pragma unused params
    if(!IsPlayerBusy(playerid)) return 1;
    
	new h = GetPVarInt(playerid, "LastHouseCP");
 	if(strcmp(hInfo[h][HouseOwner], pNick(playerid), CASE_SENSETIVE) && IsInHouse{playerid} == 1) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_C_ACCESS_SE_HM);
	if(IsInHouse{playerid} == 0) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_NOT_IN_HOUSE);
	if(GetOwnedHouses(playerid) == 0) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_NOT_HOWNER);
	if(IsInHouse{playerid} == 1 && !strcmp(hInfo[h][HouseOwner], pNick(playerid), CASE_SENSETIVE) && GetOwnedHouses(playerid) >= 1)
	{
	    #if GH_HINTERIOR_UPGRADE == true
			ShowPlayerDialog(playerid, HOUSEMENU, DIALOG_STYLE_LIST, INFORMATION_HEADER, "House Selling\nHouse Storage\nSet House Name\nSet House Password\nBuy/Preview House Interior\nToggle House Privacy\nManage Players In House\nHouse Security", "Select", "Cancel");
		#else
			ShowPlayerDialog(playerid, HOUSEMENU, DIALOG_STYLE_LIST, INFORMATION_HEADER, "House Selling\nHouse Storage\nSet House Name\nSet House Password\nToggle House Privacy\nManage Players In House\nHouse Security", "Select", "Cancel");
		#endif
	}
	return 1;
}

CMD:hmenu(playerid, params[])
{
	#pragma unused params
    if(!IsPlayerBusy(playerid)) return 1;
    
	new h = GetPVarInt(playerid, "LastHouseCP");
 	if(strcmp(hInfo[h][HouseOwner], pNick(playerid), CASE_SENSETIVE) && IsInHouse{playerid} == 1) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_C_ACCESS_SE_HM);
	if(IsInHouse{playerid} == 0) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_NOT_IN_HOUSE);
	if(GetOwnedHouses(playerid) == 0) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_NOT_HOWNER);
	if(IsInHouse{playerid} == 1 && !strcmp(hInfo[h][HouseOwner], pNick(playerid), CASE_SENSETIVE) && GetOwnedHouses(playerid) >= 1)
	{
	    #if GH_HINTERIOR_UPGRADE == true
			ShowPlayerDialog(playerid, HOUSEMENU, DIALOG_STYLE_LIST, INFORMATION_HEADER, "House Selling\nHouse Storage\nSet House Name\nSet House Password\nBuy/Preview House Interior\nToggle House Privacy\nManage Players In House\nHouse Security", "Select", "Cancel");
		#else
			ShowPlayerDialog(playerid, HOUSEMENU, DIALOG_STYLE_LIST, INFORMATION_HEADER, "House Selling\nHouse Storage\nSet House Name\nSet House Password\nToggle House Privacy\nManage Players In House\nHouse Security", "Select", "Cancel");
		#endif
	}
	return 1;
}

// ******************************************************************************************************************************
// Commands
// ******************************************************************************************************************************

// Lets the player add new businesses
CMD:createbusiness(playerid, params[])
{
	// If a player hasn't logged in properly, he cannot use this command
	if (INT_IsPlayerSpawned(playerid) == 0) return 0;
	// If the player has an insufficient admin-level (he needs level 5 or RCON admin), exit the command
	// returning "SERVER: Unknown command" to the player
    if (IsPlayerHeadAdmin(playerid, 5) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {00FFFF}Head Administrator {FF0000}to do this command!");

	// Setup local variables
	new BusinessList[2000];

	// Check if the player isn't inside a vehicle
	if (GetPlayerVehicleSeat(playerid) == -1)
	{
		// Construct the list of businesses
		for (new BusType = 1; BusType < sizeof(ABusinessInteriors); BusType++)
		{
		    format(BusinessList, sizeof(BusinessList), "%s%s\n", BusinessList, ABusinessInteriors[BusType][InteriorName]);
		}

		// Let the player choose a business-type via a dialog
		ShowPlayerDialog(playerid, DialogCreateBusSelType, DIALOG_STYLE_LIST, "Choose business-type:", BusinessList, "Select", "Cancel");
	}
	else
	    SendClientMessage(playerid, 0xFF0000FF, "You must be on foot to create a business");

	// Let the server know that this was a valid command
	return 1;
}

// This command lets the player delete a business
CMD:delbusiness(playerid, params[])
{
	// If a player hasn't logged in properly, he cannot use this command
	if (INT_IsPlayerSpawned(playerid) == 0) return 0;
	// If the player has an insufficient admin-level (he needs level 5 or RCON admin), exit the command
	// returning "SERVER: Unknown command" to the player
    if (IsPlayerHeadAdmin(playerid, 5) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {00FFFF}Head Administrator {FF0000}to do this command!");
	// Setup local variables
	new file[100], Msg[128];
	// Make sure the player isn't inside a vehicle
	if (GetPlayerVehicleSeat(playerid) == -1)
	{
		// Loop through all player-owned businesses
		for (new BusID = 1; BusID < MAX_BUSINESS; BusID++)
		{
			// Check if the business exists
			if (IsValidDynamicPickup(ABusinessData[BusID][PickupID]))
			{
				// Check if the business has no owner
				//if (ABusinessData[BusID][Owned] == true)
				//{
					// Check if the player is in range of the business-pickup
					if (IsPlayerInRangeOfPoint(playerid, 2.5, ABusinessData[BusID][BusinessX], ABusinessData[BusID][BusinessY], ABusinessData[BusID][BusinessZ]))
					{
						// Clear all data of the business
						ABusinessData[BusID][BusinessName] = 0;
						ABusinessData[BusID][BusinessX] = 0.0;
						ABusinessData[BusID][BusinessY] = 0.0;
						ABusinessData[BusID][BusinessZ] = 0.0;
						ABusinessData[BusID][BusinessType] = 0;
						ABusinessData[BusID][BusinessLevel] = 0;
						ABusinessData[BusID][LastTransaction] = 0;
						ABusinessData[BusID][Owned] = false;
						ABusinessData[BusID][Owner] = 0;
						// Destroy the mapicon, 3DText and pickup for the house
						DestroyDynamicPickup(ABusinessData[BusID][PickupID]);
						DestroyDynamicMapIcon(ABusinessData[BusID][MapIconID]);
						DestroyDynamic3DTextLabel(ABusinessData[BusID][DoorText]);
						ABusinessData[BusID][PickupID] = 0;
						ABusinessData[BusID][MapIconID] = 0;
						// Delete the business-file
						format(file, sizeof(file), BusinessFile, BusID); // Construct the complete filename for this business-file
						if (fexist(file)) // Make sure the file exists
							fremove(file); // Delete the file
						// Also let the player know he deleted the business
						format(Msg, 128, "{00FF00}You have deleted the business with ID: {FFFF00}%i", BusID);
						SendClientMessage(playerid, 0xFFFFFFFF, Msg);
						// Exit the function
						return 1;
					}
				//}
				//else return SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}You cannot delete an owned business");
			}
		}
		// There was no house in range, so let the player know about it
	    return SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}No business in range to delete");
	}
	else
	SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}You must be on foot to delete a business");
	// Let the server know that this was a valid command
	return 1;
}

CMD:sellbusiness(playerid, params[])
{
   cmd_delbusiness(playerid, params);
   return 1;
}

// This command lets the player buy a business when he's standing in range of a business that isn't owned yet
CMD:buybus(playerid, params[])
{
	// If a player's busy or punished, to not be able to perform this command
    if(!IsPlayerBusy(playerid)) return 1;

	// Setup local variables
	new Msg[128], BusType;

	// Make sure the player isn't inside a vehicle
	if (GetPlayerVehicleSeat(playerid) == -1)
	{
		// Check if the player is near a business-pickup
		for (new BusID = 1; BusID < sizeof(ABusinessData); BusID++)
		{
			// Check if this business is created (it would have a valid pickup in front of the door)
			if (IsValidDynamicPickup(ABusinessData[BusID][PickupID]))
			{
				// Check if the player is in range of the business-pickup
				if (IsPlayerInRangeOfPoint(playerid, 2.5, ABusinessData[BusID][BusinessX], ABusinessData[BusID][BusinessY], ABusinessData[BusID][BusinessZ]))
				{
				    // Check if the business isn't owned yet
				    if (ABusinessData[BusID][Owned] == false)
				    {
						// Get the type of business
						BusType = ABusinessData[BusID][BusinessType];
				        // Check if the player can afford this type of business business
				        if (GetPlayerMoneyEx(playerid) >= ABusinessInteriors[BusType][BusPrice])
				            Business_SetOwner(playerid, BusID); // Give ownership of the business to the player
				        else
				            SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}You cannot afford this business"); // The player cannot afford this business
				    }
				    else
				    {
				        // Let the player know that this business is already owned by a player
						format(Msg, 128, "{FF0000}This business is already owned by {FFFF00}%s", ABusinessData[BusID][Owner]);
						SendClientMessage(playerid, 0xFFFFFFFF, Msg);
				    }

					// The player was in range of a business-pickup, so stop searching for the other business pickups
				    return 1;
				}
			}
		}

		// All businesses have been processed, but the player wasn't in range of any business-pickup, let him know about it
		SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}To buy a business, you have to be near a business-pickup");
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}You can't buy a business when you're inside a vehicle");

	// Let the server know that this was a valid command
	return 1;
}

// This command lets the player enter the house/business if he's the owner
CMD:enter(playerid, params[])
{
	// If a player's busy or punished, to not be able to perform this command
    if(!IsPlayerBusy(playerid)) return 1;

	// Setup local variables
	new BusID, BusType;

	// Make sure the player isn't inside a vehicle
	if (GetPlayerVehicleSeat(playerid) == -1)
	{
		// Loop through all player-owned businesses
		for (new BusSlot; BusSlot < MAX_BUSINESSPERPLAYER; BusSlot++)
		{
		    // Get the business-id at the selected slot from the player
		    BusID = APlayerData[playerid][Business][BusSlot];

			// Check if the player has a business in this slot
			if (BusID != 0)
			{
				// Check if the player is in range of the business-pickup
				if (IsPlayerInRangeOfPoint(playerid, 2.5, ABusinessData[BusID][BusinessX], ABusinessData[BusID][BusinessY], ABusinessData[BusID][BusinessZ]))
				{
				    // Get the business-type
				    BusType = ABusinessData[BusID][BusinessType];

					// Set the player inside the interior of the business
					SetPlayerInterior(playerid, ABusinessInteriors[BusType][InteriorID]);
					// Set the position of the player at the spawn-location of the business's interior
					SetPlayerPos(playerid, ABusinessInteriors[BusType][IntX] - 2, ABusinessInteriors[BusType][IntY] - 2, ABusinessInteriors[BusType][IntZ]);

					// Also set a tracking-variable to enable /busmenu to track in which business the player is
					APlayerData[playerid][CurrentBusiness] = BusID;
					// Also let the player know he can use /busmenu to control his business
					SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}Use {FFFF00}/busmenu{00FF00} to change options for your business");

					// Exit the function
					return 1;
				}
			}
		}
	}

	// If no business was in range, allow other scripts to use the same command (like the housing-script)
	return SendClientMessage(playerid, COLOR_RED, "ERROR: You're not near a business or you're not the owner of it!");
}


// This command opens a menu when you're inside your business to allow to access the options of your business
CMD:busmenu(playerid, params[])
{
	// If a player's busy or punished, to not be able to perform this command
    if(!IsPlayerBusy(playerid)) return 1;

	// Setup local variables
	new OptionsList[200], DialogTitle[200];

	// Check if the player is inside a business
	if (APlayerData[playerid][CurrentBusiness] != 0)
	{
		// Create the dialog title
		format(DialogTitle, sizeof(DialogTitle), "Select option for %s", ABusinessData[APlayerData[playerid][CurrentBusiness]][BusinessName]);
		// Create the options in the dialog
		format(OptionsList, sizeof(OptionsList), "%sChange business-name\n", OptionsList);
		format(OptionsList, sizeof(OptionsList), "%sUpgrade business\n", OptionsList);
		format(OptionsList, sizeof(OptionsList), "%sRetrieve business earnings\n", OptionsList);
		format(OptionsList, sizeof(OptionsList), "%sSell business\n", OptionsList);
		format(OptionsList, sizeof(OptionsList), "%sExit business\n", OptionsList);
		// Show the businessmenu
		ShowPlayerDialog(playerid, DialogBusinessMenu, DIALOG_STYLE_LIST, DialogTitle, OptionsList, "Select", "Cancel");
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}You're not inside a business");

	// Let the server know that this was a valid command
	return 1;
}

// This command teleports you to your selected business
CMD:gobus(playerid, params[])
{
	// If a player's busy or punished, to not be able to perform this command
    if(!IsPlayerBusy(playerid)) return 1;

	// Setup local variables
	new BusinessList[1000], BusID, BusType, Earnings;

	// Check if the player is not jailed
	if (INT_IsPlayerJailed(playerid) == 0)
	{
		// Check if the player has a wanted level of less than 3
		if (GetPlayerWantedLevel(playerid) < 3)
		{
			// Check if the player is not inside a vehicle
			if (GetPlayerVehicleSeat(playerid) == -1)
			{
				// Ask to which business the player wants to port
				for (new BusSlot; BusSlot < MAX_BUSINESSPERPLAYER; BusSlot++)
				{
					// Get the business-id
				    BusID = APlayerData[playerid][Business][BusSlot];

					// Check if this businessindex is occupied
					if (BusID != 0)
					{
						// Get the business-type
						BusType = ABusinessData[BusID][BusinessType];
						Earnings = (BusinessTransactionTime - ABusinessData[BusID][LastTransaction]) * ABusinessInteriors[BusType][BusEarnings] * ABusinessData[BusID][BusinessLevel];
						format(BusinessList, 1000, "%s{00FF00}%s{FFFFFF} (earnings: $%i)\n", BusinessList, ABusinessData[BusID][BusinessName], Earnings);
					}
					else
						format(BusinessList, 1000, "%s{FFFFFF}%s{FFFFFF}\n", BusinessList, "Empty business-slot");
				}
				ShowPlayerDialog(playerid, DialogGoBusiness, DIALOG_STYLE_LIST, "Choose the business to go to:", BusinessList, "Select", "Cancel");
			}
			else
				SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}You need to be on-foot to port to your business");
		}
		else
		    SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}You cannot use /gobus when you're wanted");
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}You cannot use /gobus when you're in jail");

	// Let the server know that this was a valid command
	return 1;
}



//==============================================================================
// This command is used to trigger a house robbery
//==============================================================================
#if GH_ALLOW_HOUSEROBBERY == true
CMD:robhouse(playerid, params[])
{
	#pragma unused params
    if(!IsPlayerBusy(playerid)) return 1;
    
	new h = GetPVarInt(playerid, "LastHouseCP"), houseowner = GetHouseOwnerEx(GetPVarInt(playerid, "LastHouseCP")), robtime = GetPVarInt(playerid, "TimeSinceHouseBreakin");
	if(IsInHouse{playerid} == 0) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_NOT_IN_HOUSE);
	if(!strcmp(hInfo[h][HouseOwner], pNick(playerid), CASE_SENSETIVE)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_CANT_ROB_OWN_HOUSE);
	if(!IsPlayerConnected(houseowner)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_HROB_OWNER_NOT_CONNECTED);
	if(GetPVarInt(playerid, "IsRobbingHouse") == 1) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_ALREADY_ROBBING_HOUSE);
	if(GetSecondsBetweenAction(robtime) < (TIME_BETWEEN_ROBBERIES * 60000) && robtime != 0) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_WAIT_BEFORE_ROBBING);
	switch(random(10000))
	{
	    case 0..6999: // Failed robbery
		{
			switch(hInfo[h][HouseCamera])
 			{
 				case 0:
		   		{
			   		if(hInfo[h][HouseAlarm] == 1)
			   		{
      					ShowInfoBox(houseowner, E_FAILED_HROB1_2, hInfo[h][HouseName], hInfo[h][HouseLocation]);
			    	}
		     	}
		   		case 1: ShowInfoBox(houseowner, E_FAILED_HROB1_1, pNick(playerid), playerid, hInfo[h][HouseName], hInfo[h][HouseLocation]);
   			}
   			SecurityDog_Bite(playerid, h, 1, 1);
   			ShowInfoBox(playerid, E_FAILED_HROB2, hInfo[h][HouseName], hInfo[h][HouseOwner]);
		}
	    case 7000..9999: // Successfull robbery
	    {
			switch(hInfo[h][HouseCamera])
 			{
 				case 0:
				{
                	if(hInfo[h][HouseAlarm] == 1)
                  	{
                   		ShowInfoBox(houseowner, I_HROB_STARTED1_1, hInfo[h][HouseName], hInfo[h][HouseLocation]);
                   	}
    			}
               	case 1: ShowInfoBox(houseowner, I_HROB_STARTED1_2, pNick(playerid), playerid, hInfo[h][HouseName], hInfo[h][HouseLocation]);
    		}
   			ShowInfoBox(playerid, I_HROB_STARTED2, hInfo[h][HouseOwner], hInfo[h][HouseName], hInfo[h][HouseLocation]);
			SetPVarInt(playerid, "IsRobbingHouse", 1), SetPVarInt(playerid, "HouseRobberyTime", RandomEx(MIN_ROB_TIME, MAX_ROB_TIME));
			SetPVarInt(playerid, "HouseRobberyTimer", SetTimerEx("HouseRobbery", 999, true, "ii", playerid, h));
	    }
	}
	#if GH_GIVE_WANTEDLEVEL == true
	if((GetPlayerWantedLevel(playerid) + HROBBERY_WL) > GH_MAX_WANTED_LEVEL)
	{
		SetPlayerWantedLevel(playerid, GH_MAX_WANTED_LEVEL);
	}
	else SetPlayerWantedLevel(playerid, (GetPlayerWantedLevel(playerid) + HROBBERY_WL));
	#endif
	SetPVarInt(playerid, "TimeSinceHouseRobbery", GetTickCount());
	return 1;
}
#endif
#if GH_ALLOW_HOUSEROBBERY == true
function HouseRobbery(playerid, houseid)
{
	new Hrobberytime = GetPVarInt(playerid, "HouseRobberyTime");
	if(GetPVarInt(playerid, "IsRobbingHouse") == 1)
	{
		switch(Hrobberytime)
		{
		    case 1..MAX_ROB_TIME: GameTextEx(playerid, 999, 3, "~n~ ~g~Robbery in Progress... ~n~ ~r~%d ~w~Seconds Remaining...", Hrobberytime);
			case 0:
			{
			    switch(IsPlayerInHouse(playerid, houseid))
       			{
	    			case 0: ShowInfoBox(playerid, I_HROB_FAILED_NOT_IN_HOUSE, hInfo[houseid][HouseName]);
					case 1:
					{
	    				new RobAmount = ReturnProcent(hInfo[houseid][HouseStorage], HOUSE_ROBBERY_PERCENT), houseowner = GetHouseOwnerEx(houseid);
				    	if(RobAmount > MAX_MONEY_ROBBED)
					    {
							RobAmount = MAX_MONEY_ROBBED;
					    }
					    if(IsPlayerConnected(houseowner))
	     				{
	         				switch(hInfo[houseid][HouseCamera])
	             			{
	                			case 0:
	           					{
	                				if(hInfo[houseid][HouseAlarm] == 1)
				                    {
										ShowInfoBox(houseowner, I_HROB_COMPLETED1_2, hInfo[houseid][HouseName], hInfo[houseid][HouseLocation], RobAmount);
				                    }
				                }
			                	case 1: ShowInfoBox(houseowner, I_HROB_COMPLETED1_1, pNick(playerid), playerid, hInfo[houseid][HouseName], hInfo[houseid][HouseLocation], RobAmount);
	                		}
		            	}
					    hInfo[houseid][HouseStorage] -= RobAmount;
						new INI:file = INI_Open(HouseFile(houseid));
						INI_WriteInt(file, "HouseStorage", hInfo[houseid][HouseStorage]);
						INI_Close(file);
					    GivePlayerMoneyEx(playerid, RobAmount);
					    ShowInfoBox(playerid, I_HROB_COMPLETED2, RobAmount, hInfo[houseid][HouseOwner], hInfo[houseid][HouseName], hInfo[houseid][HouseLocation]);
					    GameTextEx(playerid, 4500, 3, "~n~ ~p~Robbery Completed~w~! ~n~ Robbed ~g~$%d~w~!", RobAmount);
			    	}
				}
				EndHouseRobbery(playerid);
				SetPVarInt(playerid, "IsRobbingHouse", 0);
				SetPVarInt(playerid, "TimeSinceHouseRobbery", GetTickCount());
			    DeletePVar(playerid, "HouseRobberyTimer");
			}
		}
	}
	return SetPVarInt(playerid, "HouseRobberyTime", (Hrobberytime - 1));
}
#endif
//==============================================================================
// This command is used to display the players houses.
//==============================================================================
CMD:myhouses(playerid, params[])
{
	#pragma unused params
    if(!IsPlayerBusy(playerid)) return 1;

	if(GetOwnedHouses(playerid) == 0) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_NO_HOUSES_OWNED);
	new h, _tmpstring[128], count = GetOwnedHouses(playerid);
	CMDSString = "";
	Loop(i, (count + 1), 1)
	{
	    h = ReturnPlayerHouseID(playerid, i);
		if(i == count)
		{
		    format(_tmpstring, sizeof(_tmpstring), "{00BC00}%d.\t{FFFF2A}%s in %s", i, hInfo[h][HouseName], hInfo[h][HouseLocation]);
		}
		else format(_tmpstring, sizeof(_tmpstring), "{00BC00}%d.\t{FFFF2A}%s in %s\n", i, hInfo[h][HouseName], hInfo[h][HouseLocation]);
		strcat(CMDSString, _tmpstring);
	}
	ShowPlayerDialog(playerid, HOUSEMENU+50, DIALOG_STYLE_LIST, INFORMATION_HEADER, CMDSString, "Select", "Cancel");
	return 1;
}
CMD:myhouse(playerid, params[])
{
	cmd_myhouses(playerid, params);
	return 1;
}

CMD:house(playerid, params[])
{
	cmd_myhouses(playerid, params);
	return 1;
}
//==============================================================================
// This command is used to create a house.
// The only thing you have to enter is the house value,
// the rest is done by the script.
//==============================================================================
CMD:createhouse(playerid, params[])
{
	new cost, h = GetFreeHouseID(), labeltext[250], hint;
    if (IsPlayerHeadAdmin(playerid, 5) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {00FFFF}Head Administrator {FF0000}to do this command!");
	if(sscanf(params, "dD(" #DEFAULT_H_INTERIOR ")", cost, hint)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_CMD_USAGE_CREATEHOUSE);
	if(h < 0)
	{
		ShowInfoBox(playerid, E_TOO_MANY_HOUSES, MAX_HOUSES);
		return 1;
	}
	if(hint < 0 || hint > MAX_HOUSE_INTERIORS) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HINT);
	if(IsHouseInteriorValid(hint) == 0) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_HINT_DOESNT_EXIST);
	if(cost < MIN_HOUSE_VALUE || cost > MAX_HOUSE_VALUE) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HVALUE);
	else
	{
        fcreate(HouseFile(h));
		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, Angle);
		new world = GetPlayerVirtualWorld(playerid), interior = GetPlayerInterior(playerid);
		hInfo[h][CPOutX] = X, hInfo[h][CPOutY] = Y, hInfo[h][CPOutZ] = Z;
		format(hInfo[h][HouseName], MAX_HOUSE_NAME, "%s", DEFAULT_HOUSE_NAME);
		format(hInfo[h][HouseOwner], MAX_PLAYER_NAME, "%s", INVALID_HOWNER_NAME);
		format(hInfo[h][HouseLocation], MAX_ZONE_NAME, "%s", GetHouseLocation(h));
		hInfo[h][HousePassword] = udb_hash("INVALID_HOUSE_PASSWORD");
		hInfo[h][HouseValue] = cost, hInfo[h][HouseStorage] = 0;
		new INI:file = INI_Open(HouseFile(h));
		INI_WriteFloat(file, "CPOutX", X);
		INI_WriteFloat(file, "CPOutY", Y);
		INI_WriteFloat(file, "CPOutZ", Z);
		INI_WriteString(file, "HouseName", DEFAULT_HOUSE_NAME);
		INI_WriteString(file, "HouseOwner", INVALID_HOWNER_NAME);
		INI_WriteString(file, "HouseLocation", hInfo[h][HouseLocation]);
		INI_WriteInt(file, "HousePassword", hInfo[h][HousePassword]);
		INI_WriteString(file, "HouseCreator", pNick(playerid));
		INI_WriteInt(file, "HouseValue", cost);
		INI_WriteInt(file, "HouseStorage", 0);
		format(labeltext, sizeof(labeltext), LABELTEXT1, DEFAULT_HOUSE_NAME, cost, h);
		#if GH_USE_CPS == true
			HouseCPOut[h] = CreateDynamicCP(X, Y, Z, 1.5, world, interior, -1, CP_DRAWDISTANCE);
			HouseCPInt[h] = CreateDynamicCP(hIntInfo[hint][IntCPX], hIntInfo[hint][IntCPY], hIntInfo[hint][IntCPZ], 1.5, (h + 1000), hIntInfo[hint][IntInterior], -1, 15.0);
		#else
			HousePickupOut[h] = CreateDynamicPickup(PICKUP_MODEL_OUT, PICKUP_TYPE, X, Y, Z, world, interior, -1, 15.0);
			HousePickupInt[h] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, hIntInfo[hint][IntCPX], hIntInfo[hint][IntCPY], hIntInfo[hint][IntCPZ], (h + 1000), hIntInfo[hint][IntInterior], -1, 15.0);
		#endif
		#if GH_USE_MAPICONS == true
	 		HouseMIcon[h] = CreateDynamicMapIcon(X, Y, Z, 31, -1, world, interior, -1, 50.0);
	 	#endif
		HouseLabel[h] = CreateDynamic3DTextLabel(labeltext, COLOUR_GREEN, X, Y, Z+0.7, TEXTLABEL_DISTANCE, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, TEXTLABEL_TESTLOS, world, interior, -1, TEXTLABEL_DISTANCE);
		ShowInfoBox(playerid, I_H_CREATED, h);
		GetPosInFrontOfPlayer(playerid, X, Y, -2.5);
		INI_WriteFloat(file, "SpawnOutX", X);
		INI_WriteFloat(file, "SpawnOutY", Y);
		INI_WriteFloat(file, "SpawnOutZ", Z);
		INI_WriteFloat(file, "SpawnOutAngle", (180.0 + Angle));
		INI_WriteInt(file, "SpawnWorld", world);
		INI_WriteInt(file, "SpawnInterior", interior);
		INI_WriteInt(file, "HouseInterior", hint);
		hInfo[h][SpawnOutX] = X, hInfo[h][SpawnOutY] = Y, hInfo[h][SpawnOutZ] = Z, hInfo[h][SpawnOutAngle] = (180.0 + Angle);
		hInfo[h][SpawnWorld] = world, hInfo[h][SpawnInterior] = interior, hInfo[h][HouseInterior] = hint;
		hInfo[h][HouseAlarm] = hInfo[h][HouseDog] = hInfo[h][HouseCamera] = hInfo[h][UpgradedLock] = 0;
		INI_Close(file);
		CurrentID++;
		file = INI_Open("/House/House.ini");
		INI_WriteInt(file, "CurrentID", CurrentID);
		INI_Close(file);
		SetPVarInt(playerid, "JustCreatedHouse", 1);
		Iter_Add(Houses, h);
	}
    return 1;
}
//==============================================================================
// This command is used to add a house car for a house.
// The only thing you have to enter is the house value,
// the rest is done by the script.
//==============================================================================
CMD:addhcar(playerid, params[])
{
	new h;
    if (IsPlayerHeadAdmin(playerid, 5) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {00FFFF}Head Administrator {FF0000}to do this command!");
	if(!IsPlayerInAnyVehicle(playerid)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_HCAR_NOT_IN_VEH);
	if(sscanf(params, "d", h)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_CMD_USAGE_ADDHCAR);
	if(!fexist(HouseFile(h))) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HID);
	else
	{
	    if(hInfo[h][HouseCar] == 1) { ShowInfoBox(playerid, I_HCAR_EXIST_ALREADY, h); }
	    if(hInfo[h][HouseCar] == 0) { ShowInfoBox(playerid, I_HCAR_CREATED, h); }
		GetVehiclePos(GetPlayerVehicleID(playerid), X, Y, Z);
		GetVehicleZAngle(GetPlayerVehicleID(playerid), Angle);
		new world = GetPlayerVirtualWorld(playerid), interior = GetPlayerInterior(playerid);
		hInfo[h][HouseCar] = 1, hInfo[h][HouseCarPosX] = X, hInfo[h][HouseCarPosY] = Y, hInfo[h][HouseCarPosZ] = Z, hInfo[h][HouseCarAngle] = Angle;
		hInfo[h][HouseCarModel] = GetVehicleModel(GetPlayerVehicleID(playerid)), hInfo[h][HouseCarInterior] = interior, hInfo[h][HouseCarWorld] = world;
		new INI:file = INI_Open(HouseFile(h));
		INI_WriteFloat(file, "HCarPosX", X);
		INI_WriteFloat(file, "HCarPosY", Y);
		INI_WriteFloat(file, "HCarPosZ", Z);
		INI_WriteFloat(file, "HCarAngle", Angle);
		INI_WriteInt(file, "HCar", 1);
		INI_WriteInt(file, "HCarWorld", world);
		INI_WriteInt(file, "HCarInt", interior);
		INI_WriteInt(file, "HCarModel", hInfo[h][HouseCarModel]);
		INI_Close(file);
	}
    return 1;
}
//==============================================================================
// This command is used to delete a house.
// Note: It does not give any money to the house owner when the house is deleted
//==============================================================================
CMD:removehouse(playerid, params[])
{
	new h;
    if (IsPlayerHeadAdmin(playerid, 5) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {00FFFF}Head Administrator {FF0000}to do this command!");
	if(sscanf(params, "d", h)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_CMD_USAGE_REMOVEHOUSE);
	if(!fexist(HouseFile(h))) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HID);
	else
	{
	    foreach(Player, i)
	    {
			if(IsInHouse{i} == 0) continue;
			ExitHouse(i, h);
	    }
     	DestroyHouseEntrance(h, TYPE_OUT);
	    DestroyHouseEntrance(h, TYPE_INT);
	    #if GH_USE_MAPICONS == true
			DestroyDynamicMapIcon(HouseMIcon[h]);
		#endif
	    DestroyDynamic3DTextLabel(HouseLabel[h]);
		ShowInfoBox(playerid, I_H_DESTROYED, h);
		fremove(HouseFile(h));
		Iter_Remove(Houses, h);
	}
    return 1;
}

//==============================================================================
// This command is used to remove the house car for a house.
//==============================================================================
CMD:removehcar(playerid, params[])
{
	new h;
    if (IsPlayerHeadAdmin(playerid, 5) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {00FFFF}Head Administrator {FF0000}to do this command!");
	if(sscanf(params, "d", h)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_CMD_USAGE_REMOVEHCAR);
	if(!fexist(HouseFile(h))) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HID);
	if(hInfo[h][HouseCar] == 0) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_NO_HCAR);
	else
	{
	    UnloadHouseCar(h);
	    hInfo[h][HouseCar] = 0;
	    new INI:file = INI_Open(HouseFile(h));
		INI_WriteInt(file, "HCar", 0);
		INI_Close(file);
		ShowInfoBox(playerid, I_HCAR_REMOVED, h);
	}
    return 1;
}
//==============================================================================
// This command is used to change the modelid of a housecar.
//==============================================================================
CMD:changehcar(playerid, params[])
{
	new h, modelid;
    if (IsPlayerHeadAdmin(playerid, 5) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {00FFFF}Head Administrator {FF0000}to do this command!");
	if(sscanf(params, "dd", h, modelid)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_CMD_USAGE_CHANGEHCAR);
	if(!fexist(HouseFile(h))) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HID);
	if(modelid < 400 || modelid > 612) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HCAR_MODEL);
	else
	{
	    hInfo[h][HouseCarModel] = modelid;
	    new INI:file = INI_Open(HouseFile(h));
		INI_WriteInt(file, "HCarModel", modelid);
		INI_Close(file);
		ShowInfoBox(playerid, I_HCAR_CHANGED, h, modelid);
    	#if GH_HOUSECARS == true
		if(GetVehicleModel(HCar[h]) != -1)
		{
		    if(IsVehicleOccupied(HCar[h]))
		    {
		        new Float:Velocity[3], Float:Pos[4], Seat[MAX_PLAYERS char] = -1, interior, vw = GetVehicleVirtualWorld(HCar[h]);
		        foreach(Player, i)
		        {
		            if(IsPlayerInVehicle(i, HCar[h]))
		            {
		                Seat{i} = GetPlayerVehicleSeat(i);
		                if(Seat{i} == 0)
		                {
		                    interior = GetPlayerInterior(i); // Have to do it this way because there is no GetVehicleInterior..
						}
		            }
		        }
		        GetVehiclePos(HCar[h], Pos[0], Pos[1], Pos[2]);
		        GetVehicleZAngle(HCar[h], Pos[3]);
		        GetVehicleVelocity(HCar[h], Velocity[0], Velocity[1], Velocity[2]);
		        DestroyVehicle(HCar[h]);
		        HCar[h] = CreateVehicle(modelid, Pos[0], Pos[1], Pos[2], Pos[3], HCAR_COLOUR1, HCAR_COLOUR2, HCAR_RESPAWN);
				LinkVehicleToInterior(HCar[h], interior);
				SetVehicleVirtualWorld(HCar[h], vw);
				foreach(Player, i)
		        {
		            if(Seat[i] != -1)
		            {
		                PutPlayerInVehicle(i, HCar[h], Seat{i});
		                Seat{i} = -1;
		            }
		        }
				SetVehicleVelocity(HCar[h], Velocity[0], Velocity[1], Velocity[2]);
		    }
            if(!IsVehicleOccupied(HCar[h]))
		    {
		        UnloadHouseCar(h);
		        LoadHouseCar(h);
		    }
		}
		#endif
	}
    return 1;
}
//==============================================================================
// This command is used to delete all houses.
// It does not give any money to the house owners when the houses is deleted.
//==============================================================================
CMD:removeallhouses(playerid, params[])
{
	#pragma unused params
	new hcount;
	if(!IsPlayerAdmin(playerid)) return 0;
	else
	{
	    foreach(Houses, h)
	    {
	        foreach(Player, i)
		    {
				if(IsInHouse{i} == 0) continue;
				ExitHouse(i, h);
		    }
	        UnloadHouseCar(h);
    		DestroyHouseEntrance(h, TYPE_OUT);
		    DestroyHouseEntrance(h, TYPE_INT);
		    #if GH_USE_MAPICONS == true
				DestroyDynamicMapIcon(HouseMIcon[h]);
			#endif
    		DestroyDynamic3DTextLabel(HouseLabel[h]);
			fremove(HouseFile(h));
			hcount++;
			Iter_Remove(Houses, h);
		}
		ShowInfoBox(playerid, I_ALLH_DESTROYED, hcount);
	}
    return 1;
}
//==============================================================================
// This command is used remove all house cars.
// It does not delete the house cars itself due to SA:MP mixing up vehicle ID's.
//==============================================================================
CMD:removeallhcars(playerid, params[])
{
	#pragma unused params
	new hcount, INI:file, filename[HOUSEFILE_LENGTH];
    if (INT_CheckPlayerAdminLevel(playerid, 6) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {0000FF}Manager/CEO {FF0000}to do this command!");
	else
	{
	    foreach(Houses, h)
	    {
	        UnloadHouseCar(h);
	        hInfo[h][HouseCar] = 0;
         	file = INI_Open(filename);
			INI_WriteInt(file, "HCar", 0);
			INI_Close(file);
		}
		ShowInfoBox(playerid, I_ALLHCAR_REMOVED, hcount);
	}
    return 1;
}
//==============================================================================
// This command is used to change the spawnposition details of a house
//==============================================================================
CMD:changehspawn(playerid, params[])
{
	new h;
    if (IsPlayerHeadAdmin(playerid, 5) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {00FFFF}Head Administrator {FF0000}to do this command!");
	if(sscanf(params, "d", h)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_CMD_USAGE_CHANGESPAWN);
	if(!fexist(HouseFile(h))) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HID);
	else
	{
	    GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, Angle);
		new world = GetPlayerVirtualWorld(playerid), interior = GetPlayerInterior(playerid);
		hInfo[h][SpawnOutX] = X, hInfo[h][SpawnOutY] = Y, hInfo[h][SpawnOutZ] = Z, hInfo[h][SpawnOutAngle] = (180.0 + Angle);
		hInfo[h][SpawnWorld] = world, hInfo[h][SpawnInterior] = interior;
		new INI:file = INI_Open(HouseFile(h));
	    INI_WriteFloat(file, "SpawnOutX", X);
		INI_WriteFloat(file, "SpawnOutY", Y);
		INI_WriteFloat(file, "SpawnOutZ", Z);
		INI_WriteFloat(file, "SpawnOutAngle", Angle);
		INI_WriteInt(file, "SpawnWorld", world);
		INI_WriteInt(file, "SpawnInterior", interior);
		INI_Close(file);
		ShowInfoBox(playerid, I_HSPAWN_CHANGED, h);
	}
    return 1;
}
//==============================================================================
// This command is used to change the spawnposition details of a house interior
//==============================================================================
CMD:changehintspawn(playerid, params[])
{
	new hint, filename[HOUSEFILE_LENGTH];
    if (IsPlayerHeadAdmin(playerid, 5) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {00FFFF}Head Administrator {FF0000}to do this command!");
	if(sscanf(params, "d", hint)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_CMD_USAGE_CHANGEHINTSPAWN);
    format(filename, sizeof(filename), HINT_FILEPATH, hint);
	if(!fexist(filename)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HINT_ID);
	else
	{
	    GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, Angle);
		hIntInfo[hint][IntSpawnX] = X, hIntInfo[hint][IntSpawnY] = Y, hIntInfo[hint][IntSpawnZ] = Z, hIntInfo[hint][IntInterior] = GetPlayerInterior(playerid);
 		hIntInfo[hint][IntSpawnAngle] = (Angle + 180.0);
		new INI:file = INI_Open(filename);
	    INI_WriteFloat(file, "SpawnX", X);
		INI_WriteFloat(file, "SpawnY", Y);
		INI_WriteFloat(file, "SpawnZ", Z);
		INI_WriteFloat(file, "Angle", hIntInfo[hint][IntSpawnAngle]);
		INI_WriteInt(file, "Interior", hIntInfo[hint][IntInterior]);
		INI_Close(file);
		ShowInfoBox(playerid, I_HINT_SPAWN_CHANGED, hint);
	}
    return 1;
}
//==============================================================================
// This command is used to create a house interior.
//==============================================================================
CMD:createhint(playerid, params[])
{
	new filename[HOUSEFILE_LENGTH], h = GetFreeInteriorID(), value, name[31], interior = GetPlayerInterior(playerid);
    if (IsPlayerHeadAdmin(playerid, 5) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {00FFFF}Head Administrator {FF0000}to do this command!");
	if(sscanf(params, "ds[30]", value, name)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_CMD_USAGE_CREATEHINT);
	if(h < 0)
	{
		ShowInfoBox(playerid, E_TOO_MANY_HINTS, MAX_HOUSE_INTERIORS);
		return 1;
	}
	if(value < MIN_HINT_VALUE || value > MAX_HINT_VALUE) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HINT_VALUE);
	if(name[30]) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HINT_LENGTH);
	else
	{
	    format(filename, sizeof(filename), HINT_FILEPATH, h);
        fcreate(filename);
 		GetPlayerPos(playerid, X, Y, Z);
		GetPlayerFacingAngle(playerid, Angle);
		hIntInfo[h][IntCPX] = X, hIntInfo[h][IntCPY] = Y, hIntInfo[h][IntCPZ] = Z;
		hIntInfo[h][IntInterior] = interior, hIntInfo[h][IntSpawnAngle] = (Angle + 180.0), format(hIntInfo[h][IntName], 30, "%s", name), hIntInfo[h][IntValue] = value;
		new INI:file = INI_Open(filename);
		INI_WriteFloat(file, "CPX", X);
		INI_WriteFloat(file, "CPY", Y);
		INI_WriteFloat(file, "CPZ", Z);
		INI_WriteString(file, "Name", name);
		INI_WriteInt(file, "Value", value);
		GetPosInFrontOfPlayer(playerid, X, Y, -2.5);
		INI_WriteFloat(file, "SpawnX", X);
		INI_WriteFloat(file, "SpawnY", Y);
		INI_WriteFloat(file, "SpawnZ", Z);
		INI_WriteFloat(file, "Angle", hIntInfo[h][IntSpawnAngle]);
		INI_WriteInt(file, "Interior", interior);
		INI_Close(file);
		hIntInfo[h][IntSpawnX] = X, hIntInfo[h][IntSpawnY] = Y, hIntInfo[h][IntSpawnZ] = Z;
		ShowInfoBox(playerid, I_HINT_CREATED, h, value, name);
	}
    return 1;
}
//==============================================================================
// This command is used to remove a house interior.
//==============================================================================
CMD:removehint(playerid, params[])
{
	new hint, filename[HOUSEFILE_LENGTH];
    if (IsPlayerHeadAdmin(playerid, 5) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {00FFFF}Head Administrator {FF0000}to do this command!");
	if(sscanf(params, "d", hint)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_CMD_USAGE_REMOVEHINT);
    format(filename, sizeof(filename), HINT_FILEPATH, hint);
	if(!fexist(filename)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HINT);
	ShowInfoBox(playerid, I_HINT_DESTROYED, hint);
	fremove(filename);
	foreach(Houses, h)
	{
	    if(hInfo[h][HouseInterior] == hint)
		{
  			hInfo[h][HouseInterior] = DEFAULT_H_INTERIOR;
	    	new INI:file = INI_Open(HouseFile(h));
		    INI_WriteInt(file, "HouseInterior", DEFAULT_H_INTERIOR);
		    INI_Close(file);
		}
	}
    return 1;
}
//==============================================================================
// This command is used to teleport to a house.
//==============================================================================
CMD:gotohouse(playerid, params[])
{
	new h;
    if (IsPlayerHeadAdmin(playerid, 5) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {00FFFF}Head Administrator {FF0000}to do this command!");
	if(sscanf(params, "d", h)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_CMD_USAGE_GOTOHOUSE);
	if(!fexist(HouseFile(h))) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HID);
	SetPlayerPosEx(playerid, hInfo[h][SpawnOutX], hInfo[h][SpawnOutY], hInfo[h][SpawnOutZ], hInfo[h][SpawnInterior], hInfo[h][SpawnWorld]);
	ShowInfoBox(playerid, I_TELEPORT_MSG, h);
    return 1;
}
//==============================================================================
// This command is used to sell a house.
// If the house owner is connected while selling the house,
// the amount in the house storage and 75% of the house value will be given to the house owner.
//==============================================================================
CMD:sellhouse(playerid, params[])
{
	new h;
    if (IsPlayerHeadAdmin(playerid, 5) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {00FFFF}Head Administrator {FF0000}to do this command!");
	if(sscanf(params, "d", h)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_CMD_USAGE_SELLHOUSE);
	if(!fexist(HouseFile(h))) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HID);
	if(!strcmp(hInfo[h][HouseOwner], INVALID_HOWNER_NAME, CASE_SENSETIVE)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_H_A_F_SALE);
	else
	{
		ShowInfoBox(playerid, I_H_SOLD, h);
		if(hInfo[h][HouseStorage] >= 1 && IsPlayerConnected(GetHouseOwnerEx(h)))
		{
			GivePlayerMoneyEx(playerid, (hInfo[h][HouseStorage] + ReturnProcent(hInfo[h][HouseValue], HOUSE_SELLING_PROCENT)));
		}
		hInfo[h][HouseValue] = ReturnProcent(hInfo[h][HouseValue], HOUSE_SELLING_PROCENT);
		format(hInfo[h][HouseOwner], MAX_PLAYER_NAME, "%s", INVALID_HOWNER_NAME);
		hInfo[h][HousePassword] = udb_hash("INVALID_HOUSE_PASSWORD");
		format(hInfo[h][HouseName], MAX_HOUSE_NAME, "%s", DEFAULT_HOUSE_NAME);
		hInfo[h][HouseStorage] = hInfo[h][HouseAlarm] = hInfo[h][HouseDog] = hInfo[h][HouseCamera] = hInfo[h][UpgradedLock] = 0;
		new INI:file = INI_Open(HouseFile(h));
		INI_WriteInt(file, "HouseValue", hInfo[h][HouseValue]);
		INI_WriteString(file, "HouseOwner", INVALID_HOWNER_NAME);
		INI_WriteInt(file, "HousePassword", hInfo[h][HousePassword]);
		INI_WriteString(file, "HouseName", DEFAULT_HOUSE_NAME);
		INI_WriteInt(file, "HouseStorage", 0);
		INI_Close(file);
		foreach(Houses, h2)
		{
			if(IsHouseInRangeOfHouse(h, h2, RANGE_BETWEEN_HOUSES) && h2 != h)
			{
		    	hInfo[h2][HouseValue] = (hInfo[h2][HouseValue] - ReturnProcent(hInfo[h2][HouseValue], HOUSE_SELLING_PROCENT2));
		    	file = INI_Open(HouseFile(h2));
				INI_WriteInt(file, "HouseValue", hInfo[h2][HouseValue]);
				INI_Close(file);
			}
		}
		foreach(Player, i)
		{
  			if(IsPlayerInHouse(i, h))
	    	{
      			ExitHouse(i, h);
				ShowInfoBoxEx(i, COLOUR_INFO, I_TO_PLAYERS_HSOLD);
	    	}
		}
		#if GH_USE_MAPICONS == true
			DestroyDynamicMapIcon(HouseMIcon[h]);
			HouseMIcon[h] = CreateDynamicMapIcon(hInfo[h][CPOutX], hInfo[h][CPOutY], hInfo[h][CPOutZ], 31, -1, hInfo[h][SpawnWorld], hInfo[h][SpawnInterior], -1, MICON_VD);
		#endif
		UpdateHouseText(h);
	}
    return 1;
}
//==============================================================================
// This command is used to sell a house.
// If the house owner is connected while selling the house,
// the amount in the house storage and 75% of the house value will be given to the house owner.
//==============================================================================
CMD:sellallhouses(playerid, params[])
{
	#pragma unused params
	new INI:file, hcount;
	if(!IsPlayerAdmin(playerid)) return 0;
	else
	{
	    foreach(Houses, h)
	    {
	        if(strcmp(hInfo[h][HouseOwner], INVALID_HOWNER_NAME, CASE_SENSETIVE))
	        {
				if(hInfo[h][HouseStorage] >= 1 && IsPlayerConnected(GetHouseOwnerEx(h)))
				{
					GivePlayerMoneyEx(playerid, (hInfo[h][HouseStorage] + ReturnProcent(hInfo[h][HouseValue], HOUSE_SELLING_PROCENT)));
				}
				hInfo[h][HouseValue] = ReturnProcent(hInfo[h][HouseValue], HOUSE_SELLING_PROCENT);
				format(hInfo[h][HouseOwner], MAX_PLAYER_NAME, "%s", INVALID_HOWNER_NAME);
				hInfo[h][HousePassword] = udb_hash("INVALID_HOUSE_PASSWORD");
				format(hInfo[h][HouseName], MAX_HOUSE_NAME, "%s", DEFAULT_HOUSE_NAME);
				hInfo[h][HouseStorage] = hInfo[h][HouseAlarm] = hInfo[h][HouseDog] = hInfo[h][HouseCamera] = hInfo[h][UpgradedLock] = 0;
				file = INI_Open(HouseFile(h));
				INI_WriteInt(file, "HouseValue", hInfo[h][HouseValue]);
				INI_WriteString(file, "HouseOwner", INVALID_HOWNER_NAME);
				INI_WriteInt(file, "HousePassword", hInfo[h][HousePassword]);
				INI_WriteString(file, "HouseName", DEFAULT_HOUSE_NAME);
				INI_WriteInt(file, "HouseStorage", 0);
				INI_Close(file);
				#if GH_USE_MAPICONS == true
					DestroyDynamicMapIcon(HouseMIcon[h]);
					HouseMIcon[h] = CreateDynamicMapIcon(hInfo[h][CPOutX], hInfo[h][CPOutY], hInfo[h][CPOutZ], 31, -1, hInfo[h][SpawnWorld], hInfo[h][SpawnInterior], -1, MICON_VD);
				#endif
				UpdateHouseText(h);
				hcount++;
			}
		}
		foreach(Player, i)
		{
  			if(IsInHouse{i} == 1)
	    	{
      			ExitHouse(i, GetPVarInt(i, "LastHouseCP"));
				ShowInfoBoxEx(i, COLOUR_INFO, I_TO_PLAYERS_HSOLD);
	    	}
		}
		ShowInfoBox(playerid, I_ALLH_SOLD, hcount);
	}
    return 1;
}
//==============================================================================
// 			This command is used to change the value of a house.
//==============================================================================
CMD:changehprice(playerid, params[])
{
	new h, price;
    if (IsPlayerHeadAdmin(playerid, 5) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {00FFFF}Head Administrator {FF0000}to do this command!");
	if(sscanf(params, "dd", h, price)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_CMD_USAGE_CHANGEPRICE);
	if(!fexist(HouseFile(h))) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HID);
	if(price < MIN_HOUSE_VALUE || price > MAX_HOUSE_VALUE) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HVALUE);
	hInfo[h][HouseValue] = price;
	new INI:file = INI_Open(HouseFile(h));
 	INI_WriteInt(file, "HouseValue", price);
 	INI_Close(file);
	ShowInfoBox(playerid, I_H_PRICE_CHANGED, h, price);
	UpdateHouseText(h);
    return 1;
}
//==============================================================================
// 		This command is used to change the value of all houses on the server.
//==============================================================================
CMD:changeallhprices(playerid, params[])
{
	new hcount, INI:file, price;
	if(!IsPlayerAdmin(playerid)) return 0;
	if(sscanf(params, "d", price)) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_CMD_USAGE_CHANGEALLPRICE);
	if(price < MIN_HOUSE_VALUE || price > MAX_HOUSE_VALUE) return ShowInfoBoxEx(playerid, COLOUR_SYSTEM, E_INVALID_HVALUE);
	else
	{
	    foreach(Houses, h)
	    {
	        hInfo[h][HouseValue] = price;
			file = INI_Open(HouseFile(h));
	 		INI_WriteInt(file, "HouseValue", price);
	 		INI_Close(file);
			UpdateHouseText(h);
			hcount++;
	    }
		ShowInfoBox(playerid, I_ALLH_PRICE_CHANGED, price, hcount);
	}
    return 1;
}
CMD:ghcmds(playerid, params[])
{
	#pragma unused params
    if (IsPlayerHeadAdmin(playerid, 5) == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You MUST be a {00FFFF}Head Administrator {FF0000}to do this command!");
	ShowPlayerDialog(playerid, HOUSEMENU-1, DIALOG_STYLE_MSGBOX, INFORMATION_HEADER, "/changeallhprices\n/removeallhcars\n/sellallhouses\n/changehprice\n/changehspawn\n/removehcar\n/createhouse\n/removehouse\n/sellhouse\n/housemenu\n/gotohouse\n/addhcar\n/changehcar\n/changehintspawn\n/createhint\n/removehint\n/ghcmds", "Close", "");
	return 1;
}

CMD:go (playerid, params[])
{
	new string[128], id, Float:x, Float:y, Float:z;
	if (sscanf(params,"u",id)) return SendClientMessage (playerid,0x6FFF00FF,"{F07F1D}USAGE: {BBFF00}/goto <ID>");
    if(!IsPlayerBusy(playerid)) return 1;
	if (id == INVALID_PLAYER_ID) return SendClientMessage(playerid,-1,"{FA002E}ERROR: {C7BDBF}Invalid player ID!");
	if(PlayerInfo[id][InCNR] == 1) return SendClientMessage(playerid, -1,"{FA002E}ERROR: {C7BDBF}That player is in /cnr");
	if(Joined[id] == true) return SendClientMessage(playerid, COLRED, "<!> That player is in Race, you can't teleport to him!");
    if(GetPVarInt(id, "Jailed") == 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: That player is in Jail, you can't teleport to him!");
    if(PlayerInfo[id][inDM] == 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: That player is in a DM Zone, you can't teleport to him!");
	if (PlayerInfo[id][Goto] == 1)
	{
		format(string, sizeof(string), "{FA002E}ERROR: {C7BDBF}%s(%d) has teleport disabled!", GetName(id), id);
		SendClientMessage( playerid, -1, string );
		return 1;
	}
	else
    format(string,sizeof(string),"{D9F238}You have teleported to {%06x}%s(%d){D9F238}!", (GetPlayerColor(id) >>> 8), GetName(id), id );
	SendClientMessage(playerid, -1, string);
	format(string,sizeof(string),"{D9F238}{%06x}%s(%d){D9F238} Has teleported to you!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
	SendClientMessage(id,-1,string);
	GetPlayerPos(id,x,y,z);
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        SetVehiclePos(GetPlayerVehicleID(playerid), x, y, z + 1.0);
	}
	else
	{
		RemovePlayerFromVehicle(playerid);
		SetPlayerPos(playerid, x, y, z + 1.0);
	}
	return 1;
}

CMD:enablego (playerid) return cmd_allowgo (playerid);
CMD:allowgo (playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (PlayerInfo[playerid][Goto] == 0) return SendClientMessage(playerid, -1, "{FA002E}ERROR: {C7BDBF}You already have your teleport enabled!");
	else
	PlayerInfo[playerid][Goto] = 0;
	SendClientMessage( playerid, -1, ""ORANGE"- Teleport - "GREEN"You have enabled your teleport!" );
	return 1;
}

CMD:disablego (playerid) return cmd_disallowgo (playerid);
CMD:disallowgo (playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
	if (PlayerInfo[playerid][Goto] == 1) return SendClientMessage(playerid, -1, "{FA002E}ERROR: {C7BDBF}You already have your teleport disabled!");
	else
	PlayerInfo[playerid][Goto] = 1;
	SendClientMessage( playerid, -1, ""ORANGE"- Teleport - "RED"You have disabled your teleport!" );
	return 1;
}

CMD:kill(playerid, params[])
{
	if(PlayerInfo[playerid][isAFK] == 1) return SendClientMessage(playerid, -1,""RED"ERROR: "GREY"You cannot committ suicide while in AFK mode! Please type /back to go back to game!");
    if(!IsPlayerBusy(playerid)) return 1;
	new string[80];
    SetPlayerHealth(playerid, 0);
    ResetPlayerWeapons(playerid);
	killStreak[playerid] = 0;
    if(killStreak[playerid] != 0) killStreak[playerid] = 0, SendClientMessage(playerid, -1, ""RED"Your killstreak has been reset to 0.");
    format(string, sizeof(string),"{FAE85C}** {%06x}%s(%d) {FAE85C}has committed suicide!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
 	GameTextForPlayer( playerid, "~n~n~n~n~n~~r~REST IN PEACE~b~!", 1200, 5 );
    SendClientMessageToAll(-1, string);
    return 1;
}

CMD:killstreaks(playerid)
{
	new k = 0, str[600];
	for (new i = 0; i < MAX_PLAYERS; i++)
	{
	    if (IsPlayerConnected(i))
	    {
	        if(killStreak[i] > 3)
			{
			    k++;
 				if(k==1)	{

					format(str, sizeof(str), ""REDORANGE"Online Player(s) Killstreak:\n\n{%06x}%s(%d)  "GREY"(Killstreak: %d)\n", (GetPlayerColor(i) >>> 8), GetName(i), i, killStreak[i]);
        		}

          		if(k >=2)	{

					format(str, sizeof(str), "%s{%06x}%s(%d)  "GREY"(Killstreak: %d)\n", str, (GetPlayerColor(i) >>> 8), GetName(i), i, killStreak[i]);
             	}
			}
		}
	}

	if (k == 0) return SendClientMessage(playerid, -1, ""RED"There are no player on killingspree.");
	ShowPlayerDialog(playerid, DIALOG_KILLSTREAK, DIALOG_STYLE_MSGBOX, ""RED"Current Killstreaks:", str, "OK", "");
	return 1;
}

stock KillStreak(playerid)
{
	if(killStreak[playerid] != 0)
	{
	    new Float:pHealth, str[150];
	    GetPlayerHealth(playerid,pHealth);
		switch(killStreak[playerid])
 		{
 			case 3:
		 	{
				TD_MSG(playerid, 4500, "~g~~h~~h~Triple Kill!~n~~w~+~g~$~w~5000~w~ and +2 score");
				format(str, sizeof(str), ""BLUE"* {%06x}%s(%i) "GREY"is on Killing spree with a 3 streak kill!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
				SendClientMessageToAll(-1, str);
       			SetPlayerScore(playerid, GetPlayerScore(playerid) + 2);
  				GivePlayerMoneyEx(playerid, 5000);
			}
			case 5:
	 		{
	 		    PlayerPlaySound(playerid, 1058, 0, 0, 9);
				TD_MSG(playerid, 4500, "~r~~h~~h~Mega Kill!~n~~w~+~g~$~w~6000~w~ and +3 score");
				SetPlayerScore(playerid, GetPlayerScore(playerid) + 3);
  				GivePlayerMoneyEx(playerid, 6000);
				format(str, sizeof(str), ""BLUE"* {%06x}%s(%i) "GREY"is on Mega Kill with a 5 streak kill!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
				SendClientMessageToAll(-1, str);
				SendClientMessage(playerid, -1, ""GREEN"> "PINK"u have earned 10 score and $100k for killing 5 people without dying.");
				SetPlayerScore(playerid, GetPlayerScore(playerid) + 10);
  				GivePlayerMoneyEx(playerid, 100000);
				SetPlayerHealth(playerid, pHealth+10);
				GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~g~~h~+10 ~w~Health", 3500, 5);
			}
			case 7:
	 		{
	 		    PlayerPlaySound(playerid, 1058, 0, 0, 9);
     			TD_MSG(playerid, 4500, "~g~~h~~h~Ultra Kill!~n~~w~+~g~$~w~8000~w~ and +4 score");
				SetPlayerScore(playerid, GetPlayerScore(playerid) + 3);
  				GivePlayerMoneyEx(playerid, 8000);
				format(str, sizeof(str), ""BLUE"* {%06x}%s(%i) "GREY"is unstoppable with a 7 streak kill!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
				SendClientMessageToAll(-1, str);
		 	}
		 	case 10:
		 	{
		 	    MWLabel[playerid] = CreateDynamic3DTextLabel(""WHITE"[ "RED"Most Wanted "WHITE"]", -1, 0.0, 0.0, 0.3, 20, playerid, INVALID_VEHICLE_ID, 0, -1, -1, -1, 25.0);
		 	    PlayerPlaySound(playerid, 1058, 0, 0, 9);
	 			TD_MSG(playerid, 4500, "~g~~h~~h~Monster Kill!~n~~w~+~g~$~w~10000~w~ and +5 score");
				SetPlayerScore(playerid, GetPlayerScore(playerid) + 4);
		  		GivePlayerMoneyEx(playerid, 10000);
				format(str, sizeof(str), ""BLUE"* {%06x}%s(%i) "GREY"is godlike with a 10 streak kill!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
				SendClientMessageToAll(COLOR_GREY, str);
				format(str, sizeof(str), ""RED"* {%06x}%s "RED"is now Most Wanted, Kill him!", (GetPlayerColor(playerid) >>> 8), GetName(playerid));
				SendClientMessageToAll(COLOR_GREY, str);
				SendClientMessage(playerid, -1, ""GREEN"> "PINK"You have earned 25 score and $200k for killing 10 people without dying.");
				SetPlayerScore(playerid, GetPlayerScore(playerid) + 25);
		  		GivePlayerMoneyEx(playerid, 200000);
				SetPlayerHealth(playerid, pHealth+10);
				GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~g~~h~+10 ~w~Health", 3500, 5);
			}
			case 15:
	 		{
	 		    PlayerPlaySound(playerid, 1058, 0, 0, 9);
	 			TD_MSG(playerid, 4500, "~g~~h~~h~Incredible Kill!~n~~w~+~g~$~w~15000~w~ and +5 score");
				SetPlayerScore(playerid, GetPlayerScore(playerid) + 5);
		  		GivePlayerMoneyEx(playerid, 15000);
				format(str, sizeof(str), ""BLUE"* {%06x}%s(%i) "GREY"can't be stopped with a 15 streak kill!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
				SendClientMessageToAll(-1, str);
			}
			case 20:
	 		{
	 		    PlayerPlaySound(playerid, 1058, 0, 0, 9);
    			TD_MSG(playerid, 4500, "~r~~h~~h~Monster Kill!~n~~w~+~g~$~w~20000~w~ and +5 score");
				SetPlayerScore(playerid, GetPlayerScore(playerid) + 6);
  				GivePlayerMoneyEx(playerid, 20000);
				format(str, sizeof(str), ""BLUE"* {%06x}%s(%i) "GREY"Immortal with a 20 streak kill!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
				SendClientMessageToAll(-1, str);
				SendClientMessage(playerid, -1, ""GREEN"> "PINK"You have earned 50 score and $300k for killing 10 people without dying.");
				SetPlayerScore(playerid, GetPlayerScore(playerid) + 50);
  				GivePlayerMoneyEx(playerid, 300000);
				SetPlayerHealth(playerid, pHealth+30);
				GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~g~~h~+30 ~w~Health", 3500, 5);
			}
			case 25:
	 		{
	 		    PlayerPlaySound(playerid, 1058, 0, 0, 9);
	 			TD_MSG(playerid, 4500, "~r~~h~~h~25 Kill Streak!~n~~w~+~g~$~w~30000~w~ and +5 score");
				SetPlayerScore(playerid, GetPlayerScore(playerid) + 6);
		  		GivePlayerMoneyEx(playerid, 30000);
				format(str, sizeof(str), ""BLUE"* {%06x}%s(%i) "GREY"is DOMINATING with a 25 streak kill!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
				SendClientMessageToAll(COLOR_GREY, str);
			}
			case 30:
	 		{
	 		    PlayerPlaySound(playerid, 1058, 0, 0, 9);
	 			TD_MSG(playerid, 4500, "~r~~h~~h~30 Kill Streak!~n~~w~+~g~$~w~50000~w~ and +6 score");
				SetPlayerScore(playerid, GetPlayerScore(playerid) + 6);
		  		GivePlayerMoneyEx(playerid, 50000);
				format(str, sizeof(str), ""BLUE"* {%06x}%s(%i) "GREY"is DOMINATING with a 30 streak kill!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
				SendClientMessageToAll(-1, str);
				SetPlayerHealth(playerid, pHealth+50);
				GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~g~~h~+50 ~w~Health", 3500, 5);
			}
			case 40:
	 		{
	 		    PlayerPlaySound(playerid, 1058, 0, 0, 9);
	 			TD_MSG(playerid, 4500, "~r~~h~~h~40 Kill Streak!~n~~w~+~g~$~w~50000~w~ and +6 score");
				SetPlayerScore(playerid, GetPlayerScore(playerid) + 6);
		  		GivePlayerMoneyEx(playerid, 50000);
				format(str, sizeof(str), ""BLUE"* {%06x}%s(%i) "GREY"is DOMINATING with a 40 streak kil	l!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
				SendClientMessageToAll(-1, str);
				SetPlayerHealth(playerid, pHealth+20);
				GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~g~~h~+20 ~w~Health", 3500, 5);
	 		}
	 		case 50:
	 		{
	 		    PlayerPlaySound(playerid, 1058, 0, 0, 9);
	 			TD_MSG(playerid, 4500, "~r~~h~~h~50 Kill Streak!~n~~w~+~g~$~w~50000~w~ and +6 score");
				SetPlayerScore(playerid, GetPlayerScore(playerid) + 6);
		  		GivePlayerMoneyEx(playerid, 50000);
				format(str, sizeof(str), ""BLUE"* {%06x}%s(%i) "GREY"is shitting on everyone with a 50 streak kill!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
				SendClientMessageToAll(-1, str);
				SetPlayerHealth(playerid, pHealth+20);
				GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~g~~h~+20 ~w~Health", 3500, 5);
	 		}
		}

	}
}

CMD:exit(playerid)
{
    if(GetPVarInt(playerid, "Jailed") == 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: You're in jail, you cannot perform commands!");
    if(GetPVarInt(playerid, "Frozen") == 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: You're in jail, you cannot perform commands!");
	switch (PlayerInfo[playerid][inDMZone])
	{
	    case 0:
	    {
	        gFDMPlayers--;
		}
		case 1:
		{
		    gWARPlayers--;
		}
		case 2:
		{
		    gMINIPlayers--;
		}
        case 3:
		{
		    gEAGLEPlayers--;
		}
        case 4:
		{
		    gRDMPlayers--;
		}
        case 5:
		{
		    gODMPlayers--;
		}
        case 6:
		{
		    gSAWNDMPlayers--;
		}
	}
    if(PlayerInfo[playerid][ActionID] == 0 && PlayerInfo[playerid][INMG] == 0 && PlayerInfo[playerid][inMini] == 0 && PlayerInfo[playerid][inDM] == 0 && Joined[playerid] == false) return SendClientMessage( playerid,-1, "{FF0000}ERROR: {C8C8C8}You're not in a Race, DM nor in CnR!");
	if (PlayerInfo[playerid][inMini] == 1)
	{
	    ResetPlayerWeapons(playerid);
	    PlayerInfo[playerid][inMini] = 0;
	    SetPlayerVirtualWorld(playerid, 0);
    	SetPlayerPosition(playerid, 2180.3672,1681.6908,11.0565,91.8018);
		SetCameraBehindPlayer(playerid);
	    SetPVarInt(playerid, "inMini", 0);
		ResetPlayerWeapons(playerid);
	}
	if (PlayerInfo[playerid][inDM] == 1)
	{

		PlayerInfo[playerid][inDM] = 0;
		PlayerInfo[playerid][inDMZone] = 0;
        PlayerInfo[playerid][inDerby] = 0;
	    Nitro[playerid] = true;
	    Bounce[playerid] = true;
	    AutoFix[playerid] = true;
		Joined[playerid] = false;
		PlayerTextDrawDestroy(playerid, EXPforDM[playerid]);
		PlayerTextDrawDestroy(playerid, CashforDM[playerid]);
		SetPlayerVirtualWorld(playerid, 0);
		SendClientMessage(playerid, -1, ""RED"[DM] "GREY"You have left the deathmatch arena!" );
		SetPlayerPosition(playerid, 2180.3672,1681.6908,11.0565,91.8018);
		SetCameraBehindPlayer(playerid);
        SetPVarInt(playerid, "InDM", 0);
		ResetPlayerWeapons(playerid);
	}
	if(Joined[playerid] == true)
    {
		JoinCount--;
		Joined[playerid] = false;
	    Nitro[playerid] = true;
	    Bounce[playerid] = true;
	    AutoFix[playerid] = true;
        SetPVarInt(playerid, "InRace", 0);
		DestroyVehicle(CreatedRaceVeh[playerid]);
	    DisablePlayerRaceCheckpoint(playerid);
		TextDrawHideForPlayer(playerid, RaceInfo[playerid]);
        TextDrawDestroy(RaceInfo[playerid]);
		CPProgess[playerid] = 0;
		KillTimer(InfoTimer[playerid]);
		TogglePlayerControllable(playerid, true);
		SetCameraBehindPlayer(playerid);
		DisableRemoteVehicleCollisions(playerid, 0);
		pInvincible[playerid] = false;
		#if defined RACE_IN_OTHER_WORLD
		SetPlayerVirtualWorld(playerid, 0);
		#endif
		SendClientMessage(playerid, -1, ""GREEN"You have left the Race!");
	}
	if ( PlayerInfo[ playerid ][ ActionID ] == 2 )
	{
	KillTimer(spawntiming);
	spawntiming=-1;
	KillTimer(robberytiming);
	robberytiming = 0;
	RemovePlayerFromVehicle( playerid );
	SetPlayerInterior( playerid , 0 );
	SetPlayerTeam( playerid, NO_TEAM );
	PlayerInfo[ playerid ][ ActionID ] = ( 0 );
	ResetPlayerWeapons( playerid );
	LoadPlayerCoords(playerid);
	Iter_Remove( PlayerInCNR, playerid );
	Iter_Remove( PlayerInROBBERS, playerid );
	Iter_Remove( PlayerInCOPS, playerid );
    Nitro[playerid] = true;
    Bounce[playerid] = true;
    AutoFix[playerid] = true;
    SetPVarInt(playerid, "InCnR", 0);
	// ( GangZone CNR )
	GangZoneHideForPlayer( playerid, CNR_ZONE[ 0 ] ); // Rob
	GangZoneHideForPlayer( playerid, CNR_ZONE[ 1 ] ); // Cop
	GangZoneHideForPlayer( playerid, CNR_ZONE[ 2 ] ); // Swat
	GangZoneHideForPlayer( playerid, CNR_ZONE[ 3 ] ); // Army
	GangZoneHideForPlayer( playerid, CNR_ZONE[ 4 ] );  // Rob2
	// ( Leave Message )
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {BABABA}You have left the Cops and Robbers minigame." );
	TextDrawHideForPlayer(playerid, RobTD);
	Cuffed[ playerid ] = false;
	Robstart[ playerid ] = 0;
	ClearAnimations(playerid);
	PlayerInfo[ playerid ][ InCNR] = 0;
	SetPlayerVirtualWorld(playerid,0);
    SetPlayerColor(playerid, PlayerInfo[playerid][Color]);
    RemovePlayerAttachedObject(playerid, 1550);
	}
	if(PlayerInfo[playerid][inDerby] == 1)
	{
        PlayerInfo[playerid][inDerby] = 0;
	    Nitro[playerid] = true;
	    Bounce[playerid] = true;
	    AutoFix[playerid] = true;
        SetPlayerPosition(playerid, 1617.1729,1272.0662,10.7556,75.9016);
	}
	return 1;
}

CMD:helmet (playerid)
{
	if(!IsPlayerBusy(playerid)) return 1;
	if (PlayerInfo[playerid][Helmet] == 1)
	{
	    PlayerInfo[playerid][Helmet] = 0;
	    SendClientMessage(playerid, -1, ">> "RED"Helmet disabled!");
		RemovePlayerAttachedObject(playerid, 3);
	}
	else if (PlayerInfo[playerid][Helmet] == 0)
	{
	    PlayerInfo[playerid][Helmet] = 1;
	    SendClientMessage(playerid, -1, ">> "GREEN"Helmet enabled!");
		SetPlayerAttachedObject(playerid, 3, RandomHelmet[random(sizeof(RandomHelmet))], 2, 0.101, -0.0, 0.0, 5.50, 84.60, 83.7, 1, 1, 1);
	}
	return 1;
}

CMD:para(playerid) return cmd_parachute(playerid);
CMD:parachute(playerid)
{
	if(!IsPlayerBusy(playerid)) return 1;
	
	GivePlayerWeapon(playerid, 46, 1);
    SendClientMessage(playerid, -1, "{BBFF00}You have received a parachute!");
    return 1;
}

CMD:drunklevel(playerid, params[])
{
	if(!IsPlayerBusy(playerid)) return 1;

	new lvl;
	if(sscanf(params, "d", lvl))
	{
	    SendClientMessage(playerid, -1, "{F07F1D}USAGE: {BBFF00}/drunk <0 - 5000> (above 2000 makes you drunk)");
	    return 1;
	}

	SetPlayerDrunkLevel(playerid, lvl);

	if(lvl < 2000)
	{
	    SendClientMessage(playerid, -1, "{FF17E0}You're now perfectly sober!");
	}
	else
	{
	    SendClientMessage(playerid, -1, "{FF17E0}You're now drunk, yeah... you are! Feeling dizzy already?");
	}

	return 1;
}

CMD:sendcash(playerid, params[])
{
	if(!IsPlayerBusy(playerid)) return 1;
	
	new id, amount;
	if(sscanf(params, "ui", id, amount)) return SendClientMessage(playerid, USAGE, ""GREEN"USAGE: /sendcash <Name/ID> <Amount>");
	if(amount > 100000000 || amount < 1) return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"Please enter a valid amount between $1 - $100,000,000!");
	if(GetPlayerMoneyEx(playerid) < amount) return SendClientMessage(playerid, -1, ""RED"ERROR "GREY"You don't have enough money!");
	new str[128];
	format(str, 128, "** You have received $%i from %s(%i)!", amount, GetName(playerid), playerid), SendClientMessage(id, COLOR_YELLOW, str);
	format(str, 128, "** You have sent $%i to %s(%i)!", amount, GetName(id), id), SendClientMessage(playerid, COLOR_YELLOW, str);
	GivePlayerMoneyEx(id, amount), GivePlayerMoneyEx(playerid, -amount);
	return 1;
}

CMD:camera(playerid)
{
	if(!IsPlayerBusy(playerid)) return 1;

	GivePlayerWeapon(playerid, 43, 999);
	SendClientMessage(playerid, COLOR_GREEN, "You have bought a camera ^.^");
	return 1;
}
CMD:drinkbeer(playerid)
{
	if(!IsPlayerBusy(playerid)) return 1;

	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_BEER);
	SendClientMessage(playerid, -1, "{F23577}You're now drinking beer. I would like to just drink my bud light...");
	return 1;
}

CMD:drinkwine(playerid)
{
	if(!IsPlayerBusy(playerid)) return 1;

	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DRINK_WINE);
	SendClientMessage(playerid, -1, "{F23577}You're now drinking wine.");
	return 1;
}

CMD:dive(playerid)
{
	if(!IsPlayerBusy(playerid)) return 1;
	
	if(IsPlayerInAnyVehicle(playerid))
	{
		OnPlayerExitVehicle(playerid, GetPlayerVehicleID(playerid));
	}
	GetPlayerPos(playerid, pos_x[playerid], pos_y[playerid], pos_z[playerid]);
	SetPlayerPos(playerid, pos_x[playerid], pos_y[playerid], pos_z[playerid] + 500.0);
	GivePlayerWeapon(playerid, 46, 1);
	GameTextForPlayer(playerid,"~b~Enjoy your flight!",2000,6);
	return 1;
}

CMD:helpmeup(playerid)
{
	if(!IsPlayerBusy(playerid)) return 1;
	
    RemovePlayerFromVehicle(playerid);
	GetPlayerPos(playerid, pos_x[playerid], pos_y[playerid], pos_z[playerid]);
	SetPlayerPos(playerid, pos_x[playerid], pos_y[playerid], pos_z[playerid] + 5.0);
	PlayerPlaySound(playerid, 1130, 0.0, 0.0, 0.0);
	return 1;
}

CMD:afk(playerid,params[])
{
  if(!IsPlayerBusy(playerid)) return 1;

  if(isnull(params)) return SendClientMessage(playerid, -1, "Usage: /afk [reason]");
  if(stringContainsIP(params)) return 0;
  if(daadetext3d[playerid] == 1)
  {
    if(PlayerInfo[playerid][isAFK] == 1) return SendClientMessage( playerid, -1, ""RED"ERROR: "GREY"You are already in AFK mode! Type /back to deactivate AFK mode!");
	PlayerInfo[playerid][isAFK] = 1;
	new st[128];
    format(st,sizeof(st),"AFK, reason: %s",params);
    textjaja[playerid] = st;
    UpdateDynamic3DTextLabelText(jaja[playerid], 0x00FF40FF,st);
    format(st,sizeof(st),"You are AFK with reason: %s  use /back to play!",params);
    SendClientMessage(playerid,-1,st);
    daadetext3d[playerid] = 1;
	TogglePlayerControllable(playerid,false);
    SetPlayerHealth(playerid, 9999);
	new name[128];
    GetPlayerName(playerid,name,128);
    format(string1, sizeof(string1), "%s is AFK, reason: %s",name,params);
    SendClientMessageToAll(COLOR_YELLOW, string1);
  }
  else
  {
  if(PlayerInfo[playerid][isAFK] == 1) return SendClientMessage( playerid, -1, ""RED"ERROR: "GREY"You are already in AFK mode! Type /back to deactivate AFK mode!" );
  PlayerInfo[playerid][isAFK] = 1;
  new st[128];
  format(st,sizeof(st),"AFK, reason: %s",params);
  textjaja[playerid] = st;
  jaja[playerid] = CreateDynamic3DTextLabel(st, 0x00FF40FF, 0, 0, 0.6, 50,playerid);
  format(st,sizeof(st),"You are AFK with reason: %s  use /back to play!",params);
  SendClientMessage(playerid,-1,st);
  daadetext3d[playerid] = 1;
  TogglePlayerControllable(playerid,false);
  SetPlayerHealth(playerid, 9999);
  new name[128];
  GetPlayerName(playerid,name,128);
  format(string1, sizeof(string1), "%s is AFK, reason: %s",name,params);
  SendClientMessageToAll(COLOR_YELLOW, string1);
  }
  return 1;
}

CMD:brb(playerid, params[])
{
  return cmd_afk(playerid, params);
}

CMD:back(playerid,params[])
{
  if(!IsPlayerBusy(playerid)) return 1;
	
  if(PlayerInfo[playerid][isAFK] == 0 ) return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"You are not in AFK mode! Type /afk to activate AFK mode!");
  PlayerInfo[playerid][isAFK] = 0;
  TogglePlayerControllable(playerid,true);
  DestroyDynamic3DTextLabel(jaja[playerid]);
  SetPlayerHealth(playerid, 100);
  daadetext3d[playerid] = 0;
  new name[128];
  GetPlayerName(playerid,name,128);
  format(string1, sizeof(string1), "%s is back from AFK!",name);
  SendClientMessageToAll(COLOR_GREEN, string1);
  return 1;
}

CMD:here(playerid, params[])
{
   return cmd_back(playerid, params);
}

CMD:afklist(playerid, params[])
{
	if(!IsPlayerBusy(playerid)) return 1;

 	new c = 0;
 	new str[256];
 	for(new i = 0; i < GetMaxPlayers(); i++)
 	{
     	if(!IsPlayerConnected(i))
   		continue;
  		else
  		{
         	if(PlayerInfo[i][isAFK] == 1)
         	{
   		 		c++;
    			if(c == 1)
      			format(str, sizeof(str), "{F75A05}**  Away From Keyboard (AFK) Players:\n{%06x}%s(%d) Reason: %s", (GetPlayerColor(i) >>> 8), GetName(i), i, textjaja[i]);
    			else
        		format(str, sizeof(str), "%s\n{%06x}%s(%d) %s", str, (GetPlayerColor(i) >>> 8), GetName(i), i, textjaja[i]);
   			}
  		}
 	}
 	if(c == 0)
  	SendClientMessage(playerid, -1, ""STEELBLUE"No players are Away From Keyboard (AFK).");
 	else
  	ShowPlayerDialog(playerid, 5, DIALOG_STYLE_MSGBOX, "{FF0000}AFK List", str, "OK", "");
	return 1;
}

CMD:weapons (playerid) return cmd_w(playerid);
CMD:w (playerid)
{
	if(!IsPlayerBusy(playerid)) return 1;

    if (PlayerInfo[playerid][GodEnabled] == 1) return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"You have god mode activated! Please type /god to proceed.");
	ShowPlayerDialog( playerid, WEAPONS, DIALOG_STYLE_LIST, "{58C8ED}Weapon Set", ""ORANGE"Standard Weapon Set {33AA33}($100k)\n"ORANGE"Advanced Weapon Set {33AA33}($250k)\n"ORANGE"Expert Weapon Set {33AA33}($500k)", "Select", "Cancel" );
	return 1;
}

CMD:spawnplace (playerid)
{
	if(!IsPlayerBusy(playerid)) return 1;
	
	ShowPlayerDialog(playerid, DIALOG_SPAWN, DIALOG_STYLE_LIST, ""GREEN"Choose your spawn place", ""TELEPORTBLUE"Las Venturas (/lv)\n"TELEPORTBLUE"Los Santos Airport (/lsair)\n"TELEPORTBLUE"Abandoned Airfield (/aa)\n"TELEPORTBLUE"Mount Chilliad (/chilliad)\n"TELEPORTBLUE"San Fierro (/sf)\n"TELEPORTBLUE"Current Position", "Select", "Cancel");
	return 1;
}

CMD:color ( playerid, params[] )
{
	if(!IsPlayerBusy(playerid)) return 1;

	new R, G, B, string[70];
	if (PlayerInfo[playerid][LoggedIn] == 0) return SendClientMessage( playerid, -1, ""RED"ERROR: "GREY"You must be logged in!");
 	if(isnull(params))
	{
		ShowPlayerDialog(playerid, DIALOG_COLOR, DIALOG_STYLE_LIST, ""TELEPORTBLUE"Change nick color:", "{8000FF}Purple\n{FF80FF}Pink\n{00FFFF}Light Blue\n{80FF00}Light Green\n{C0C0C0}Grey\nWhite\n{FF8000}Orange\n{FFFF00}Yellow\n{FF0000}Red\n{00F900}Green", "Change", "Cancel");
		SendClientMessage(playerid, -1, ""GREEN"TIP: "YELLOW"You can use /color <R> <G> <B> [30-255] to set your own nick color!");
	}
	if (sscanf(params, "ddd", R, G, B)) return SendClientMessage(playerid, 0x6FFF00FF, "{F07F1D}You can also use: {BBFF00}/color <R> <G> <B> [30-255]" );
	if (R < 30 && R > 255 && G < 30 && G > 255 && B < 30 && B > 255) return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"Color R-G-Bs cannot be lower than 30 or higher than 255!");
	PlayerInfo[playerid][Color] = (GetPlayerColor(playerid));
	SetPlayerColor(playerid, MAKE_COLOR_FROM_RGB(R, G, B, 255));
	format(string, sizeof(string), "{%06x}You have successfully changed your nick color!", (GetPlayerColor(playerid) >>> 8));
	SendClientMessage(playerid, -1, string);
	return 1;
}

CMD:colour(playerid, params[])
{
	cmd_color(playerid, params);
	return 1;
}

CMD:music (playerid)
{
	if(PlayerInfo[playerid][Spawned] == 0) return SendClientMessage(playerid, COLOR_RED, "ERROR: You must be spawned to do this command!");
    ShowPlayerDialog(playerid, DIALOG_MUSIC, DIALOG_STYLE_LIST, ""YELLOW"Pick a Song!", ""GREEN"> Ice Cube - Gangsta Rap Made Me Do It\n"GREEN"> Justin Timberlake - What Goes Around Comes Back Around\n"GREEN"> Icon For Hire - Get Well\n"GREEN"> Inna - Yalla\n"GREEN"> Chief Keef - Love Sosa (Remix)\n"GREEN"> Ty Dolla $ign - Or Nah (feat. Wiz Khalifa & The Weeknd)\n"GREEN"> Sevyn Streeter - How Bad Do You Want It\n"GREEN"> Dr.Dre feat. Snoop Dogg - The Next Episode (San Holo Remix)\n"GREEN"> Martin Garrix - UMF 2015\n"GREEN"> MO - Final Song\n"GREEN"> Desiigner - Panda\n"GREEN"> Lil Wayne - A Milli\n"GREEN"> Martin Garrix - Animals\n"GREEN"> Twenty One Pilots - Heathens\n"GREEN"> Eminem - Without Me\n"GREEN"> DMX - Party Up\n"GREEN"> G-Eazy - I Mean It (feat. Remo)\n"GREEN"> Wiz Khalifa - Medicated (feat. Juicy J & Chevy Woods)\n"GREEN"> Consoul Trainin - Take Me To Infinity\n"GREEN"> Mr.Probz - Waves\n"YELLOW"> Next Page\n"RED">> "RED"Stop Music", "Choose", "Cancel");
	return 1;
}

CMD:countdown (playerid) return cmd_cd(playerid);
CMD:cd (playerid)
{
	if(!IsPlayerBusy(playerid)) return 1;
	
	if (cd == -1)
	{
	    cd = 6;
		new str[128];
		format(str, sizeof(str), "** {%06x}%s(%d) has started a countdown!", (GetPlayerColor(playerid) >>> 8), GetName(playerid), playerid);
		SendClientMessageToAll(-1, str);
	    SetTimer("countdown", 1000, 0);
	}
	else return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"A countdown is already in progress, please wait!");
	return 1;
}

function countdown( )
{
	if ( cd == 6 )
		GameTextForAll( "~b~Starting...", 1000, 4 );

	cd--;
	if ( cd == 0 )
	{
		GameTextForAll( "~r~GO~ b~!", 1000, 4 );
		foreach( Player, i ) PlayerPlaySound( i, 1057, 0.0, 0.0, 0.0 );
		cd = -1;
		return ( 0 );
	}
	else
	{
		new text[ 7 ];
		format( text, sizeof( text ), "~y~%d", cd );
		foreach( Player, i ) PlayerPlaySound( i, 1057, 0.0, 0.0, 0.0 );
	 	GameTextForAll( text, 1000, 4 );
	}
	SetTimer( "countdown", 1000, 0 );
	return ( 0 );
}
CMD:help (playerid)
{
   new bigstring[570];
   strcat(bigstring, "{11ED65}You are new to TBS?\n\
                      {11ED65}Check out all commands in /cmds (/commands)\n\
                      {11ED65}See all teleports in /teles (/teleports)\n\
                      {11ED65}Read our rules in /rules\n\
                      {11ED65}Visit out Forum at: tbs-official.eu\n\
                      {11ED65}If you have any questions ask Admins/VIP's\n");
    ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX, ""RED"TBS's Help", bigstring, "OK", "");
	return 1;
}
CMD:keys (playerid)
{
   new bigstring[570];
   strcat(bigstring, "{FCFFC3}Driving Keys:\n\
                      {6EAAFF}LMB/ALT - Speed Boost - /multiplier (Configure Boost Power)\n\
                      {6EAAFF}2 - Vehicle Bounce\n\
                      {6EAAFF}H/CAPS LOCK - Handbrake + Flip\n");
    ShowPlayerDialog(playerid, DIALOG_KEYS, DIALOG_STYLE_MSGBOX, ""RED"TBS's Driving Keys", bigstring, "OK", "");
	return 1;
}
CMD:vipapp (playerid)
{
    new bigstring[1000];
	strcat(bigstring, "{FF0000}Requirements for Silver VIP:\n\
                       {11ED65}1. Fallowing Rules\n\
                       {11ED65}2. Help new players\n\
                       {11ED65}3. Players Invited: 10\n\
                       {F3F3F3}4. You Need 5k Score if you haven't invited anyone!\n\
                       {FF0000}Those are the Requirements. Post your application on the forum using this format:\n");
 	strcat(bigstring, "{11ED65}1. IG Name:\n\
                       {11ED65}2. Invited Player Names:\n\
                       {11ED65}3. Picture Of /stats:\n\
                       {11ED65}4. Your Application Must Be Named '[Silver Application] Your Name Here'! (Where 'Your Name Here' is your name)\n\
					   {FF0000}Forum Link: tbs-official.eu\n");
    ShowPlayerDialog(playerid, DIALOG_VIPAPP, DIALOG_STYLE_MSGBOX, ""RED"VIP Application", bigstring, "OK", "");
	return 1;
}

CMD:donate (playerid)
{
    new bigstring[1000];
	strcat(bigstring, "{FF0000}Donation Process:\n\
                       {FFFF00}For Gold VIP you need to donate {00FF00}3{00FF00} euros!\n\
                       {0000FF}For Platinum VIP you need to donate {00FF00}5{00FF00} euros!\n\
                       {00FF00}For Permanent VIP you need to donate {00FF00}10{00FF00} euros!\n\
                       {FFFFFF}The donations are available via Credit/Debit cards!\n\
                       {FF0000}After you donate you need to create a topic with this format:\n");
    strcat(bigstring," {FF0000}1. IG name:\n\
                       {FF0000}2. Payment key:\n\n\
                       {00FF00}The Donation links you can find in: 'Read Before Posting' topic in 'Donate for VIP Status/Apply For VIP!' board!\n\
                       {FF0000}Forum link: tbs-official.eu\n");
    ShowPlayerDialog(playerid, DIALOG_DONATE, DIALOG_STYLE_MSGBOX, ""RED"Donate for VIP!", bigstring, "OK", "");
	return 1;
}

CMD:adminapp (playerid) return cmd_staffapp (playerid);
CMD:staffapp (playerid)
{
    new bigstring[3000];
	strcat(bigstring, "{FF0000}Requirements:\n\
                       {11ED65}* Registered in server and forum and minimum period is 1 month.\n");
    strcat(bigstring, "{11ED65}* Having at least 7500 score in game.\n\
                       {11ED65}* Minimum 25 hours of online time in server.\n\
                       {11ED65}* Good Knowledge of English and able to communicate with English.\n");
    strcat(bigstring, "{11ED65}* Helpful and friendly in the community (server, forum, etc.)\n\
                       {11ED65}* Never had a kick, ban record in server or a warning in forum.\n\
                       {11ED65}* Active in the server and forum daily.\n");
    strcat(bigstring, "{FF0000}Those are the Requirements. Post your application on the forum using this format:\n\
                       {11ED65}In-Game Name:\n\
                       {11ED65}Score:\n\
                       {11ED65}Age:\n");
    strcat(bigstring, "{11ED65}Country:\n\
                       {11ED65}Tell us about yourself:\n\
                       {11ED65}Spoken languages:\n");
    strcat(bigstring, "{11ED65}How long you have played SA-MP?:\n\
                       {11ED65}Do you have any previous administration experience in other servers?:\n\
                       {11ED65}How often do you play our server?:\n");
    strcat(bigstring, "{11ED65}Why you decided to apply for a staff member?\n\
                       {11ED65}How can you make the community better and why should we choose you\n");
    strcat(bigstring, "{11ED65}Note: The title should be 'Admin application - Your name here'\n\
					   {FF0000}Forum link: tbs-official.eu\n");
ShowPlayerDialog(playerid, DIALOG_ADMINAPP, DIALOG_STYLE_MSGBOX, ""RED"Admin Application", bigstring, "OK", "");
	return 1;
}

CMD:djapp (playerid)
{
    new bigstring[512];
	strcat(bigstring, "{FF0000}Requirements:\n\
                       {11ED65}• 2k Score\n\n\
					   {FF0000}Format:\n\
                       {11ED65}1. In Game Name:\n\
                       {11ED65}2. Between what time are you able to work as a DJ?:\n\
                       {11ED65}3. What type of music are you willing to play?:\n\
					   {FF0000}Forum link: tbs-official.eu\n");
ShowPlayerDialog(playerid, DIALOG_DJAPP, DIALOG_STYLE_MSGBOX, ""RED"DJ Application", bigstring, "OK", "");
	return 1;
}


CMD:credits (playerid)
{
	new bigstring[512];
	format(bigstring, sizeof(bigstring), "{FF0000}The Best™ Stunts© {FFFFFF}was created in October {FFFF00}2014\n\
					                      {FFFFFF}The founder and creator is {00FF00}Filipbg\n\n\
                                          {FF0000}Owner: Emily_Lafernus\n\
                                          {00FF00}Scripters: George, Filipbg, FreAkeD, PLEB, denNorske: minor script changes\n\
                                          {00FFFF}Mappers: Tom_Rogers, GamerNa, Sam, Filipbg, FreAkeD, TamZer, PLEB\n\
                                          {C0C0C0}Used base GM from biker122\n\n\
					                      {FFFFFF}Thank you {FF8000}%s {FFFFFF}for playing here enjoy your stay in {FF0000}TBS{FFFFFF}!", GetName(playerid));

ShowPlayerDialog(playerid, DIALOG_CREDITS, DIALOG_STYLE_MSGBOX, ""RED"TBS's Credits", bigstring, "OK", "");
	return 1;
}

CMD:commands (playerid) return cmd_cmds(playerid);
CMD:cmds (playerid)
{
	new bigstring[1000];
	strcat(bigstring, "{00FFFF}Player Commands:\n\n\
	  				   {C0C0C0}/teles /vehicle (/v) /pm /radios /rules /vcmds /vips /admins /report /credits /stats\n\
					   {C0C0C0}/weapons(/w) /go(id) /enablego /disablego /cd /color /animlist /enter /r /neon /lp /sp\n\
	                   {C0C0C0}/afk /back /afklist /skin /helpmeup /dive /drink(wine/beer) /drunklevel /bounce\n");
    strcat(bigstring, "{C0C0C0}/kill /exit /parachute(/para) /helmet /me /antifall /autofix /nitro /settings /carcolor\n\
	                   {C0C0C0}/request /ctune /stunts /song /bank /sendcash /dms(/dm) /keys /help /pmon /pmoff\n\
	                   {C0C0C0}/gobus /buybus /myhouses /god /tc2 to /tc13 /music /heal /tbs /changelog /seen /setmweather /setmytime\n");
    strcat(bigstring, "{808000}Duel Cmds: {C0C0C0}/duel /duels /dinvites /daccept /duelmenu\n\
                       {FF8000}Race: {C0C0C0}/racecmds /raceinfo /startrace\n\
					   {6EAAFF}Applicatons: {00FFFF}Admin App - {C0C0C0}/adminapp(/staffapp){00FFFF}, VIP App - {C0C0C0}/vipapp{00FFFF}, DJ App - {C0C0C0}/djapp\n\
				   	   {FF0000}New: {00FF00}/cshop, /payday, /myrank, /ranks");
	ShowPlayerDialog(playerid, DIALOG_CMDS, DIALOG_STYLE_MSGBOX, ""RED"TBS's Commands", bigstring, "OK", "");
	return 1;
}

CMD:teles (playerid) return cmd_teleports (playerid);
CMD:teleports (playerid)
{
	new bigstring[1000];
	strcat(bigstring, "{00FF00}All Teleports:\n\n\
                       {00FFFF}Stunt and drift: {C0C0C0}/aa /lsair /sf /sfair /lv /lvair /chilliad /dreamyland(/dl1) /nascar\n\
                       {C0C0C0}/waterpark(/wp) /monsterhay(/mh) /halfpipe(/hp) /bayside /skyroad /tubeland /tas1 /tas2\n\
                       {C0C0C0}/bikeskills1 to /bikeskills8[/bs1 to /bs8] /drift1 to /drift7 /place1 to /place13\n");
    strcat(bigstring, "{C0C0C0}/stuntland(/sl) /dreamyland2(/dl2) /parkour1 to /parkour3\n\
					   {FF8000}Tune up vehicle places: {C0C0C0}/transfender (/trans) /arch\n\
                       {FFFFFF}DM Arenas: {C0C0C0}/fdm /mini /war /eagle /rdm /odm /sawndm\n");
    strcat(bigstring, "{FFFF00}New: {C0C0C0}/fall /jump /richcity /air1 /air2 /island /jungle /speedway");
	ShowPlayerDialog(playerid, DIALOG_TELES, DIALOG_STYLE_MSGBOX, ""RED"TBS's Teleports", bigstring, "OK", "");
	return 1;
}

CMD:dm(playerid) return cmd_dms(playerid);
CMD:dms (playerid)
{
	new bigstring[570];
	strcat(bigstring, "{FCFFC3}All DM Arenas:\n\
	  				   {6EAAFF}Field DM (/fdm), War DM (/war), Minigun DM (/mini), Eagle DM (/eagle)\n\
					   {11ED65}New: Rocket DM (/rdm), One-Shot DM (/odm), Sawn-Off DM (/sawndm)");
	ShowPlayerDialog(playerid, DIALOG_DM, DIALOG_STYLE_MSGBOX, ""RED"TBS's Death Match Arenas", bigstring, "OK", "");
	return 1;
}

CMD:stunt(playerid) return cmd_stunts(playerid);
CMD:stunts (playerid)
{
	new bigstring[570];
	strcat(bigstring, "{FCFFC3}All Stunt Areas:\n\
	  				   {00FF00}/aa /lsair /sf /sfair /lsair /lv /lvair /chilliad /dreamyland\n\
					   {00FF00}/place8 /place9 /place11 /place12 /waterpark(/wp) /bayside /skyroad");
	ShowPlayerDialog(playerid, DIALOG_STUNT, DIALOG_STYLE_MSGBOX, ""RED"TBS's Stunt Areas", bigstring, "OK", "");
	return 1;
}

CMD:heal(playerid,params[])
{
  if(!IsPlayerBusy(playerid)) return 1;
  
  if(HealTimer[playerid] == 1) return SendClientMessage(playerid, 0, "{FF0000}You can use this command once every 60 seconds!");
  SetPlayerHealth(playerid,100);
  SendClientMessage(playerid, 0, "{11ED65}You have restored your health!");
  HealTimer[playerid] = 1;
  HealPlayTimer[playerid] = SetTimerEx("HealReal", 60000, false, "d", playerid);
  return 1;
}

CMD:autofix (playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;
    
	if (AutoFix[playerid] == 1)
	{
		AutoFix[playerid] = 0;
		SendClientMessage(playerid, -1, ">> "RED"Auto Fix disabled!");
	}
	else if (AutoFix[playerid] == 0)
	{
	    AutoFix[playerid] = 1;
		SendClientMessage(playerid, -1, ">> "GREEN"Auto Fix enabled!");
	}
	return 1;
}

CMD:nitro (playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;

	if (Nitro[playerid] == 1)
	{
	    Nitro[playerid] = 0;
	    SendClientMessage(playerid, -1, ">> "RED"Nitro disabled!");
	}
	else if (Nitro[playerid] == 0)
	{
	    Nitro[playerid] = 1;
	    SendClientMessage(playerid, -1, ">> "GREEN"Nitro enabled!");
	}
	return 1;
}

CMD:multiplier (playerid, params[])
{
    if(!IsPlayerBusy(playerid)) return 1;

	new Float:value, str[60];
	if (sscanf(params, "f", value)) return SendClientMessage(playerid, 0x6FFF00FF, "{F07F1D}USAGE: {BBFF00}/multiplier <Value> (1.2 - 1.8)");
	if (value < 1.2 || value > 1.8) return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"Allowed range x1.2 - x1.8!");
	SBvalue[playerid] = value;
	format(str, sizeof(str), ">> You have set your speedboost multiplier to x%f.", value);
	SendClientMessage(playerid, COLOR_VIOLET, str);
	return 1;
}

CMD:antifall (playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;

	if (AntifallEnabled[playerid] == 1)
	{
	    AntifallEnabled[playerid] = 0;
	    SendClientMessage(playerid, -1, ">> "RED"Antifall disabled!");
	}
	else if (AntifallEnabled[playerid] == 0)
	{
	    AntifallEnabled[playerid] = 1;
	    SendClientMessage(playerid, -1, ">> "GREEN"Antifall enabled!");
	}
	return 1;
}

CMD:bounce (playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;

	if (Joined[playerid] == true)
	{
       SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"You are in race! Use /exit to exit!");
	}
	else if (Bounce[playerid] == 1)
	{
		Bounce[playerid] = 0;
		SendClientMessage(playerid, -1, ">> "RED"Bounce disabled!");
	}
	else if (Bounce[playerid] == 0)
	{
	    Bounce[playerid] = 1;
	    SendClientMessage(playerid, -1, ">> "GREEN"Bounce enabled!");
	}
	return 1;
}

CMD:v(playerid, params[])
{
    if(!IsPlayerBusy(playerid)) return 1;

	if(GetPlayerVirtualWorld(playerid) == 1520 || GetPlayerVirtualWorld(playerid) == 1517) return SendClientMessage(playerid, COLOR_GREY, "You can't use that cmd in this zone!");
	new Vehicle5[32], VehicleID;
	if(sscanf(params, "s[32]", Vehicle5))
	{
	    SendClientMessage(playerid, 0x6FFF00FF, "{F07F1D}USAGE: {BBFF00}/v <Vehicle Name/ID>");
	    return 1;
	}
	if(GetPlayerVirtualWorld(playerid) != 1518)
	{
        if(strcmp(Vehicle5, "425")==0 || strcmp(Vehicle5, "447")==0 || strcmp(Vehicle5, "520")==0 || strcmp(Vehicle5, "464")==0 || strcmp(Vehicle5, "432")==0 || strcmp(Vehicle5, "Hydra")==0 ||
        strcmp(Vehicle5, "hunter") ==0 || strcmp(Vehicle5, "Rhino")==0 || strcmp(Vehicle5, "rhino")==0 || strcmp(Vehicle5, "Rh")==0 || strcmp(Vehicle5, "rh")==0 || strcmp(Vehicle5, "hydra")==0 || strcmp(Vehicle5, "hyd")==0 ||
		strcmp(Vehicle5, "Hyd")==0 || strcmp(Vehicle5, "hydr")==0 || strcmp(Vehicle5, "Hydr")==0 || strcmp(Vehicle5, "Hunter")==0 || strcmp(Vehicle5, "SPARROW")==0 || strcmp(Vehicle5, "SEASPARROW")==0 || strcmp(Vehicle5, "SEA")==0 ||
        strcmp(Vehicle5, "HYD")==0 || strcmp(Vehicle5, "HYDR")==0 || strcmp(Vehicle5, "HYDRA")==0 || strcmp(Vehicle5, "seasparrow")==0 || strcmp(Vehicle5, "sea")==0 || strcmp(Vehicle5, "spar")==0 || strcmp(Vehicle5, "spa")==0 || strcmp(Vehicle5, "sparrow")==0 ||
		strcmp(Vehicle5, "SPA")==0 || strcmp(Vehicle5, "SPARR")==0 || strcmp(Vehicle5, "sparr")==0 || strcmp(Vehicle5, "sparro")==0 || strcmp(Vehicle5, "SPARRO")==0 || strcmp(Vehicle5, "RHI")==0 || strcmp(Vehicle5, "RH")==0 || strcmp(Vehicle5, "RHIN")==0 ||
		strcmp(Vehicle5, "Rhi")==0 || strcmp(Vehicle5, "rhi")==0 || strcmp(Vehicle5, "rhin")==0 || strcmp(Vehicle5, "Rhin")==0 || strcmp(Vehicle5, "hu")==0 || strcmp(Vehicle5, "RHINO")==0 || strcmp(Vehicle5, "HU")==0 || strcmp(Vehicle5, "HUN")==0 || strcmp(Vehicle5, "HUNT")==0 ||
        strcmp(Vehicle5, "Hu")==0 || strcmp(Vehicle5, "hun")==0 || strcmp(Vehicle5, "Hun")==0 || strcmp(Vehicle5, "hunt")==0 || strcmp(Vehicle5, "Hunt")==0 || strcmp(Vehicle5, "HUNTE")==0 || strcmp(Vehicle5, "HUNTER")==0 ||
        strcmp(Vehicle5, "hunte")==0 || strcmp(Vehicle5, "Hunte")==0) return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"This vehicle is for Admins and VIP's only!");
		VehicleID = GetVehicleModelIDFromName(Vehicle5);
	    if(VehicleID != 425 && VehicleID != 520 && VehicleID != 464 && VehicleID != 432) {
			if(VehicleID == 0 )
			{
				VehicleID = strval(Vehicle5);

				if(VehicleID != 425 || VehicleID != 520 || VehicleID != 464 || VehicleID != 432)
				{
					return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"You have specified an invalid vehicle name!");
				}
			}
		} else {
		    SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"The vehicle you have specified is globally disabled.");
	        DestroyVehicle(Veh[playerid][VehId]);
		}
 } else {
		SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"You cannot spawn a vehicle in this area.");
	}
	VehicleID = GetVehicleModelIDFromName(Vehicle5);
	if(VehicleID == -1 )
	{
	VehicleID = strval(Vehicle5);

    if(VehicleID != 425 || VehicleID != 520 || VehicleID != 464 || VehicleID != 432)
    {
    return SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"You have specified an invalid vehicle name!");
    }
    }
    GetPlayerPos(playerid, pX, pY, pZ);
    GetPlayerFacingAngle(playerid, pAngle);
    DestroyVehicle(PlayerInfo[playerid][pCar]);
    PlayerInfo[playerid][pCar] = CreateVehicle(VehicleID, pX, pY, pZ+2.0, pAngle, -1, -1, -1);
    LinkVehicleToInterior(PlayerInfo[playerid][pCar], GetPlayerInterior(playerid));
    SetVehicleVirtualWorld(PlayerInfo[playerid][pCar], GetPlayerVirtualWorld(playerid));
    PutPlayerInVehicle(playerid, PlayerInfo[playerid][pCar], 0);
    new msg[60];
	SendClientMessage(playerid, COLOR_ORANGE, "You can use /carcolor to change the color of your car");
	format(msg, sizeof(msg), "~g~>> ~r~You have spawned ~g~%s", vNames[GetVehicleModelIDFromName(params) - 400]);
    TD_MSG(playerid, 3000, msg);
	return 1;
}

CMD:vehicle(playerid, params[])
{
if(!IsPlayerBusy(playerid)) return 1;

ShowVehicleDialog(playerid);
return 1;
}

CMD:vehicles(playerid, params[])
{
if(!IsPlayerBusy(playerid)) return 1;

ShowVehicleDialog(playerid);
return 1;
}

CMD:veh(playerid, params[])
{
if(!IsPlayerBusy(playerid)) return 1;

ShowVehicleDialog(playerid);
return 1;
}

CMD:tc2(playerid,params[])
{
if(!IsPlayerBusy(playerid)) return 1;

if(IsPlayerInAnyVehicle(playerid)) {
SendClientMessage(playerid,red,"Error: You already have a vehicle");
} else  {
if(PlayerInfo[playerid][pCar] != 0) CarDeleter(playerid, PlayerInfo[playerid][pCar]);
new Float:X6,Float:Y6,Float:Z6,Float:Angle6,LVehicleIDt;	GetPlayerPos(playerid,X6,Y6,Z6); GetPlayerFacingAngle(playerid,Angle6);
LVehicleIDt = CreateVehicle(560,X6,Y6,Z6,Angle6,1,-1,-1);	PutPlayerInVehicle(playerid,LVehicleIDt,0);	    AddVehicleComponent(LVehicleIDt, 1028);	AddVehicleComponent(LVehicleIDt, 1030);	AddVehicleComponent(LVehicleIDt, 1031);	AddVehicleComponent(LVehicleIDt, 1138);	AddVehicleComponent(LVehicleIDt, 1140);  AddVehicleComponent(LVehicleIDt, 1170);
AddVehicleComponent(LVehicleIDt, 1028);	AddVehicleComponent(LVehicleIDt, 1030);	AddVehicleComponent(LVehicleIDt, 1031);	AddVehicleComponent(LVehicleIDt, 1138);	AddVehicleComponent(LVehicleIDt, 1140);  AddVehicleComponent(LVehicleIDt, 1170);
AddVehicleComponent(LVehicleIDt, 1080);	AddVehicleComponent(LVehicleIDt, 1086); AddVehicleComponent(LVehicleIDt, 1087); AddVehicleComponent(LVehicleIDt, 1010);	PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	ChangeVehiclePaintjob(LVehicleIDt,1);
SetVehicleVirtualWorld(LVehicleIDt, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(LVehicleIDt, GetPlayerInterior(playerid));
PlayerInfo[playerid][pCar] = LVehicleIDt;
}
return 1;
}
//------------------------------------------------------------------------------
CMD:tc3(playerid,params[])
{
if(!IsPlayerBusy(playerid)) return 1;

if(IsPlayerInAnyVehicle(playerid)) {
SendClientMessage(playerid,red,"Error: You already have a vehicle");
} else  {
if(PlayerInfo[playerid][pCar] != 0) CarDeleter(playerid, PlayerInfo[playerid][pCar]);
new Float:X6,Float:Y6,Float:Z6,Float:Angle6,LVehicleIDt;	GetPlayerPos(playerid,X6,Y6,Z6); GetPlayerFacingAngle(playerid,Angle6);
LVehicleIDt = CreateVehicle(560,X6,Y6,Z6,Angle6,1,-1,-1);	PutPlayerInVehicle(playerid,LVehicleIDt,0);	    AddVehicleComponent(LVehicleIDt, 1028);	AddVehicleComponent(LVehicleIDt, 1030);	AddVehicleComponent(LVehicleIDt, 1031);	AddVehicleComponent(LVehicleIDt, 1138);	AddVehicleComponent(LVehicleIDt, 1140);  AddVehicleComponent(LVehicleIDt, 1170);
AddVehicleComponent(LVehicleIDt, 1080);	AddVehicleComponent(LVehicleIDt, 1086); AddVehicleComponent(LVehicleIDt, 1087); AddVehicleComponent(LVehicleIDt, 1010);	PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	ChangeVehiclePaintjob(LVehicleIDt,2);
SetVehicleVirtualWorld(LVehicleIDt, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(LVehicleIDt, GetPlayerInterior(playerid));
PlayerInfo[playerid][pCar] = LVehicleIDt;
}
return 1;
}
//------------------------------------------------------------------------------
CMD:tc4(playerid,params[])
{
if(!IsPlayerBusy(playerid)) return 1;

if(IsPlayerInAnyVehicle(playerid)) {
SendClientMessage(playerid,red,"Error: You already have a vehicle");
} else  {
if(PlayerInfo[playerid][pCar] != 0) CarDeleter(playerid, PlayerInfo[playerid][pCar]);
new Float:X6,Float:Y6,Float:Z6,Float:Angle6,carid;	GetPlayerPos(playerid,X6,Y6,Z6); GetPlayerFacingAngle(playerid,Angle6);
carid = CreateVehicle(559,X6,Y6,Z6,Angle6,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
AddVehicleComponent(carid,1065);    AddVehicleComponent(carid,1067);    AddVehicleComponent(carid,1162); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073);	ChangeVehiclePaintjob(carid,1);
SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
PlayerInfo[playerid][pCar] = carid;
}
return 1;
}
CMD:tc5(playerid,params[])
{
if(!IsPlayerBusy(playerid)) return 1;

if(IsPlayerInAnyVehicle(playerid)) {
SendClientMessage(playerid,red,"Error: You already have a vehicle");
} else  {
if(PlayerInfo[playerid][pCar] != 0) CarDeleter(playerid, PlayerInfo[playerid][pCar]);
new Float:X6,Float:Y6,Float:Z6,Float:Angle6,carid;	GetPlayerPos(playerid,X6,Y6,Z6); GetPlayerFacingAngle(playerid,Angle6);
carid = CreateVehicle(565,X6,Y6,Z6,Angle6,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
AddVehicleComponent(carid,1046); AddVehicleComponent(carid,1049); AddVehicleComponent(carid,1053); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073); ChangeVehiclePaintjob(carid,1);
SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
PlayerInfo[playerid][pCar] = carid;
}
return 1;
}
//------------------------------------------------------------------------------
CMD:tc6(playerid,params[])
{
if(!IsPlayerBusy(playerid)) return 1;

if(IsPlayerInAnyVehicle(playerid)) {
SendClientMessage(playerid,red,"Error: You already have a vehicle");
} else  {
if(PlayerInfo[playerid][pCar] != 0) CarDeleter(playerid, PlayerInfo[playerid][pCar]);
new Float:X6,Float:Y6,Float:Z6,Float:Angle6,carid;	GetPlayerPos(playerid,X6,Y6,Z6); GetPlayerFacingAngle(playerid,Angle6);
carid = CreateVehicle(558,X6,Y6,Z6,Angle6,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
AddVehicleComponent(carid,1088); AddVehicleComponent(carid,1092); AddVehicleComponent(carid,1139); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073); ChangeVehiclePaintjob(carid,1);
SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
PlayerInfo[playerid][pCar] = carid;
}
return 1;
}
//------------------------------------------------------------------------------
CMD:tc7(playerid,params[])
{
if(!IsPlayerBusy(playerid)) return 1;

if(IsPlayerInAnyVehicle(playerid)) {
SendClientMessage(playerid,red,"Error: You already have a vehicle");
} else  {
if(PlayerInfo[playerid][pCar] != 0) CarDeleter(playerid, PlayerInfo[playerid][pCar]);
new Float:X6,Float:Y6,Float:Z6,Float:Angle6,carid;	GetPlayerPos(playerid,X6,Y6,Z6); GetPlayerFacingAngle(playerid,Angle6);
carid = CreateVehicle(561,X6,Y6,Z6,Angle6,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
AddVehicleComponent(carid,1055); AddVehicleComponent(carid,1058); AddVehicleComponent(carid,1064); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073); ChangeVehiclePaintjob(carid,1);
SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
PlayerInfo[playerid][pCar] = carid;
}
return 1;
}
//------------------------------------------------------------------------------
CMD:tc8(playerid,params[])
{
if(!IsPlayerBusy(playerid)) return 1;

if(IsPlayerInAnyVehicle(playerid)) {
SendClientMessage(playerid,red,"Error: You already have a vehicle");
} else  {
if(PlayerInfo[playerid][pCar] != 0) CarDeleter(playerid, PlayerInfo[playerid][pCar]);
new Float:X6,Float:Y6,Float:Z6,Float:Angle6,carid;	GetPlayerPos(playerid,X6,Y6,Z6); GetPlayerFacingAngle(playerid,Angle6);
carid = CreateVehicle(562,X6,Y6,Z6,Angle6,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
AddVehicleComponent(carid,1034); AddVehicleComponent(carid,1038); AddVehicleComponent(carid,1147); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073); ChangeVehiclePaintjob(carid,1);
SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
PlayerInfo[playerid][pCar] = carid;
}
return 1;
}
//------------------------------------------------------------------------------
CMD:tc9(playerid,params[])
{
if(!IsPlayerBusy(playerid)) return 1;

if(IsPlayerInAnyVehicle(playerid)) {
SendClientMessage(playerid,red,"Error: You already have a vehicle");
} else  {
if(PlayerInfo[playerid][pCar] != 0) CarDeleter(playerid, PlayerInfo[playerid][pCar]);
new Float:X6,Float:Y6,Float:Z6,Float:Angle6,carid;	GetPlayerPos(playerid,X6,Y6,Z6); GetPlayerFacingAngle(playerid,Angle6);
carid = CreateVehicle(567,X6,Y6,Z6,Angle6,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
AddVehicleComponent(carid,1102); AddVehicleComponent(carid,1129); AddVehicleComponent(carid,1133); AddVehicleComponent(carid,1186); AddVehicleComponent(carid,1188); ChangeVehiclePaintjob(carid,1); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1085); AddVehicleComponent(carid,1087); AddVehicleComponent(carid,1086);
SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
PlayerInfo[playerid][pCar] = carid;
}
return 1;
}
//------------------------------------------------------------------------------
CMD:tc10(playerid,params[])
{
if(!IsPlayerBusy(playerid)) return 1;

if(IsPlayerInAnyVehicle(playerid)) {
SendClientMessage(playerid,red,"Error: You already have a vehicle");
} else  {
if(PlayerInfo[playerid][pCar] != 0) CarDeleter(playerid, PlayerInfo[playerid][pCar]);
new Float:X6,Float:Y6,Float:Z6,Float:Angle6,carid;	GetPlayerPos(playerid,X6,Y6,Z6); GetPlayerFacingAngle(playerid,Angle6);
carid = CreateVehicle(558,X6,Y6,Z6,Angle6,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
AddVehicleComponent(carid,1092); AddVehicleComponent(carid,1166); AddVehicleComponent(carid,1165); AddVehicleComponent(carid,1090);
AddVehicleComponent(carid,1094); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1087); AddVehicleComponent(carid,1163);//SPOILER
AddVehicleComponent(carid,1091); ChangeVehiclePaintjob(carid,2);
SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
PlayerInfo[playerid][pCar] = carid;
}
return 1;
}
//-----------------------------------------------------------------------------
CMD:tc11(playerid,params[])
{
if(!IsPlayerBusy(playerid)) return 1;

if(IsPlayerInAnyVehicle(playerid)) {
SendClientMessage(playerid,red,"Error: You already have a vehicle");
} else {
if(PlayerInfo[playerid][pCar] != 0) CarDeleter(playerid, PlayerInfo[playerid][pCar]);
new Float:X6,Float:Y6,Float:Z6,Float:Angle6,carid;	GetPlayerPos(playerid,X6,Y6,Z6); GetPlayerFacingAngle(playerid,Angle6);
carid = CreateVehicle(557,X6,Y6,Z6,Angle6,1,1,-1);	PutPlayerInVehicle(playerid,carid,0);
AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1081);
SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
PlayerInfo[playerid][pCar] = carid;
}
return 1;
}
//------------------------------------------------------------------------------
CMD:tc12(playerid,params[])
{
if(!IsPlayerBusy(playerid)) return 1;

if(IsPlayerInAnyVehicle(playerid)) {
SendClientMessage(playerid,red,"Error: You already have a vehicle");
} else  {
if(PlayerInfo[playerid][pCar] != 0) CarDeleter(playerid, PlayerInfo[playerid][pCar]);
new Float:X6,Float:Y6,Float:Z6,Float:Angle6,carid;	GetPlayerPos(playerid,X6,Y6,Z6); GetPlayerFacingAngle(playerid,Angle6);
carid = CreateVehicle(535,X6,Y6,Z6,Angle6,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
ChangeVehiclePaintjob(carid,1); AddVehicleComponent(carid,1109); AddVehicleComponent(carid,1115); AddVehicleComponent(carid,1117); AddVehicleComponent(carid,1073); AddVehicleComponent(carid,1010);
AddVehicleComponent(carid,1087); AddVehicleComponent(carid,1114); AddVehicleComponent(carid,1081); AddVehicleComponent(carid,1119); AddVehicleComponent(carid,1121);
SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
PlayerInfo[playerid][pCar] = carid;
}
return 1;
}
//------------------------------------------------------------------------------
CMD:tc13(playerid,params[])
{
if(!IsPlayerBusy(playerid)) return 1;

if(IsPlayerInAnyVehicle(playerid)) SendClientMessage(playerid,red,"Error: You already have a vehicle");
else {
if(PlayerInfo[playerid][pCar] != 0) CarDeleter(playerid, PlayerInfo[playerid][pCar]);
new Float:X6,Float:Y6,Float:Z6,Float:Angle6,carid;	GetPlayerPos(playerid,X6,Y6,Z6); GetPlayerFacingAngle(playerid,Angle6);
carid = CreateVehicle(562,X6,Y6,Z6,Angle6,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
AddVehicleComponent(carid,1034); AddVehicleComponent(carid,1038); AddVehicleComponent(carid,1147);
AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073); ChangeVehiclePaintjob(carid,0);
SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
PlayerInfo[playerid][pCar] = carid;
}
return 1;
}

CMD:settings (playerid)
{
    if(!IsPlayerBusy(playerid)) return 1;

	if (Joined[playerid] == true)
	{
       SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"You are in race! Use /exit to exit!");
	}
	new string[300];
	new SBstring[30];
	if (Nitro[playerid] == 1) format(SBstring, 30, ""C_RED"Disable"C_WHITE"");
	if (Nitro[playerid] == 0) format(SBstring, 30, ""C_GREEN"Enable"C_WHITE"");
	new AutoFixString[30];
	if (AutoFix[playerid] == 1) format(AutoFixString, 30, ""C_RED"Disable"C_WHITE"");
	if (AutoFix[playerid] == 0) format(AutoFixString, 30, ""C_GREEN"Enable"C_WHITE"");
	new BounceString[30];
	if (Bounce[playerid] == 1) format(BounceString, 30, ""C_RED"Disable"C_WHITE"");
	if (Bounce[playerid] == 0) format(BounceString, 30, ""C_GREEN"Enable"C_WHITE"");
	new AFstring[30];
	if (AntifallEnabled[playerid] == 1) format(AFstring, 30, ""C_RED"Disable"C_WHITE"");
	if (AntifallEnabled[playerid] == 0) format(AFstring, 30, ""C_GREEN"Enable"C_WHITE"");
	new WeaponSetString[30];
	if (PlayerInfo[playerid][WeaponSet] == 0) format(WeaponSetString, 30, ""ORANGE"Standard"C_WHITE"");
	if (PlayerInfo[playerid][WeaponSet] == 1) format(WeaponSetString, 30, ""ORANGE"Advanced"C_WHITE"");
	if (PlayerInfo[playerid][WeaponSet] == 2) format(WeaponSetString, 30, ""ORANGE"Expert"C_WHITE"");
	format(string, 300, "Speedboost (%s)\nAuto Repair (%s)\nBounce (%s)\nAntifall (%s)\nWeapon Set (%s)", SBstring, AutoFixString, BounceString, AFstring, WeaponSetString);
	ShowPlayerDialog(playerid, DIALOG_SETTINGS, DIALOG_STYLE_LIST, ""REDORANGE">> "C_WHITE"Account Settings", string, "OK", "Cancel");
	return 1;
}

CMD:setting(playerid)
{
   return cmd_settings(playerid);
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	new Float:h;
	GetPlayerHealth(playerid, h);
	if (PlayerInfo[playerid][GodEnabled] == 1 && h == FLOAT_INFINITY)
	{
	    TD_MSG( issuerid, 3000, "~r~The player you're trying to hit has ~g~god mode activated~r~!" );
	}
	new Float:hp;
    GetPlayerHealth(playerid, hp);
	if( GetPlayerTeam( issuerid ) == TEAM_ROBBERS || GetPlayerTeam( issuerid ) == TEAM_PROROBBERS || GetPlayerTeam( issuerid ) == TEAM_EROBBERS )
	{
      		if( GetPlayerTeam( playerid ) == TEAM_ROBBERS || GetPlayerTeam( playerid ) == TEAM_PROROBBERS || GetPlayerTeam( playerid ) == TEAM_EROBBERS )
		    {
		        SetPlayerHealth(playerid, hp+amount);
				TogglePlayerControllable(issuerid,0);
				SetTimerEx("WarningUnfreeze",3000,false,"id",issuerid,GetPlayerVirtualWorld(issuerid));
		    }
	}
	if( GetPlayerTeam( issuerid ) == TEAM_COPS || GetPlayerTeam( issuerid ) == TEAM_ARMY || GetPlayerTeam( issuerid ) == TEAM_SWAT )
	{
      		if( GetPlayerTeam( playerid ) == TEAM_COPS || GetPlayerTeam( playerid ) == TEAM_ARMY || GetPlayerTeam( playerid ) == TEAM_SWAT )
		    {
		        SetPlayerHealth(playerid, hp+amount);
				TogglePlayerControllable(issuerid,0);
				SetTimerEx("WarningUnfreeze",3000,false,"id",issuerid,GetPlayerVirtualWorld(issuerid));
			}
	}
	for(new i=0; i<MAX_PLAYERS; i++)
 	{
     	if(IsPlayerConnected(i))
		{
      		if( GetPlayerTeam( issuerid ) == TEAM_COPS || GetPlayerTeam( issuerid ) == TEAM_ARMY || GetPlayerTeam( issuerid ) == TEAM_SWAT )
		    {
				if(IsPlayerInRangeOfPoint(i, 75, 1323.8813,2673.1052,11.2392))
	     		{
					ResetPlayerWeapons( issuerid );
					Announce( issuerid, "~r~~h~Weapons Reseted!~n~~w~Don't kill in Robbers spawn zone!", 4000, 4 );
				}
			}
		}
	}
	new Float:health;
	GetPlayerHealth(playerid, health);
	if(PlayerInfo[playerid][GodEnabled] == 0 && health < 101 && health != FLOAT_INFINITY)
	{
	if(issuerid != INVALID_PLAYER_ID && (weaponid == 34 || weaponid == 33 || weaponid == 24) && bodypart == 9)//Sniper, Country Rifle, Deagle
	{
		if(IsPlayerConnected(issuerid))
		{
				SetPlayerHealth(playerid, 0);
				SetPlayerArmour(playerid, 0.0);//Set player Armour 0
				GameTextForPlayer(issuerid,"~r~Boom Headshot",2000,3);
				PlayerPlaySound(issuerid, 17802, 0.0, 0.0, 0.0);
				GameTextForPlayer(playerid,"~r~Boom Headshot",2000,3);
				PlayerPlaySound(playerid, 17802, 0.0, 0.0, 0.0);
		}
    }
	}
	return 1;
}

//----------------------------------------
// Vehicle Add Ons (Nitro, Jump & AutoFix)
//----------------------------------------
public FixAllCar()
{
        for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
        // loop all possible player
        {
                if(IsPlayerConnected(playerid) && IsPlayerInAnyVehicle(playerid) && AutoFix[playerid] == 1)
                //if the player is connected AND in a car
                {
                        new vehicleid = GetPlayerVehicleID(playerid);// gettin the vehicle id
                        SetVehicleHealth(vehicleid,1000.0);// set the vehicle health
                }
        }
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
    #pragma unused playerid
	if (AutoFix[playerid] == 1)
	{
	    new panels, doors, lights, tires;
	    GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
	    tires = encode_tires(0, 0, 0, 0); // fix all tires
	    panels = encode_panels(0, 0, 0, 0, 0, 0, 0); // fix all panels //fell off - (3, 3, 3, 3, 3, 3, 3)
	    doors = encode_doors(0, 0, 0, 0, 0, 0); // fix all doors //fell off - (4, 4, 4, 4, 0, 0)
	    lights = encode_lights(0, 0, 0, 0); // fix all lights
	    UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
	}
    return 1;
}

encode_tires(tire1, tire2, tire3, tire4) return tire1 | (tire2 << 1) | (tire3 << 2) | (tire4 << 3);
encode_panels(flp, frp, rlp, rrp, windshield, front_bumper, rear_bumper)
{
    return flp | (frp << 4) | (rlp << 8) | (rrp << 12) | (windshield << 16) | (front_bumper << 20) | (rear_bumper << 24);
}
encode_doors(bonnet, boot, driver_door, passenger_door, behind_driver_door, behind_passenger_door)
{
    #pragma unused behind_driver_door
    #pragma unused behind_passenger_door
    return bonnet | (boot << 8) | (driver_door << 16) | (passenger_door << 24);
}
encode_lights(light1, light2, light3, light4)
{
    return light1 | (light2 << 1) | (light3 << 2) | (light4 << 3);
}
//------------------------------------------------
function AntiCheat()
{
	switch(changeHostname)
	{
 		case 0:
   		{
			SendRconCommand("hostname "HOSTNAME_2"");
  			changeHostname = 1;
		}
		case 1:
		{
  			SendRconCommand("hostname "HOSTNAME_3"");
  			changeHostname = 0;
    	}
 	}
 	foreach(new i : Player)
	{
		if(GetPVarInt(i, "OldMoney") < GetPlayerMoneyEx(i) && !GetPVarInt(i, "AllowingCashChange")) //Checking cash. Pvars used to sync across scripts.
		{
			ResetPlayerMoney(i);
			GivePlayerMoneyEx(i,GetPVarInt(i, "OldMoney"));
		}
	}
 	return (1);
}
function TD_MSG(playerid, ms_time, text[])
{
	if(GetPVarInt(playerid, "InfoTDshown") != -1)
	{
	    PlayerTextDrawHide(playerid, rInfoTDS[playerid]);
	    KillTimer(GetPVarInt(playerid, "InfoTDshown"));
	}
    PlayerTextDrawSetString(playerid, rInfoTDS[playerid], text);
    PlayerTextDrawShow(playerid, rInfoTDS[playerid]);
    PlayerPlaySound(playerid, 1058, 0, 0, 0);
	SetPVarInt(playerid, "InfoTDshown", SetTimerEx("InfoTD_Hide", ms_time, false, "i", playerid));
	return (1);
}

function InfoTD_Hide(playerid)
{
	SetPVarInt(playerid, "InfoTDshown", -1);
	PlayerTextDrawHide(playerid, rInfoTDS[playerid]);
}

stock GetName(playerid)
{
	new pName2[MAX_PLAYERS];
	GetPlayerName(playerid, pName2, sizeof(pName2));
	return pName2;
}

stock GetFalloutName(otherID)
{
	new nama[MAX_PLAYER_NAME];
	GetPlayerName(otherID, nama, MAX_PLAYER_NAME);
	return nama;
}

stock SpawnProtection( playerid )
{
    SetPlayerHealth( playerid, FLOAT_INFINITY );
    TD_MSG( playerid, 3000, "~y~~h~Spawn protection ~w~~h~has been ~g~~h~enabled" );
    ResetPlayerWeapons(playerid);
	protection[playerid] = SetTimerEx( "SpawnProtectionOff", 4000, 0, "i", playerid );
	return (1);
}

stock IsPlayerBusy(playerid)
{
	if(PlayerInfo[playerid][Spawned] == 0)
	{
	     SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"You must be logged in to perform commands!");
	     return 0;
	}
	else if(PlayerInfo[playerid][inDM] == 1)
	{
         SendClientMessage(playerid, -1, ""RED"ERROR: "GREY"You cannot use this command here! Type /exit to exit!");
         return 0;
	}
    else if(PlayerInfo[playerid][InCNR] == 1)
	{
	     SendClientMessage(playerid,-1,"{E01B4C}ERROR: You can't use this command here {FF9000}/leave or /exit!");
	     return 0;
	}
    else if(Joined[playerid] == true)
	{
	     SendClientMessage(playerid, COLRED, "<!> You are in a race. Type /exit first!");
	     return 0;
	}
    else if(GetPVarInt(playerid, "Jailed") == 1)
	{
	     SendClientMessage(playerid, COLOR_RED, "ERROR: You're in jail, you cannot perform commands!");
	     return 0;
	}
    else if(GetPVarInt(playerid, "Frozen") == 1)
	{
	     SendClientMessage(playerid, COLOR_RED, "ERROR: You're in jail, you cannot perform commands!");
	     return 0;
	}
    else if(PlayerInfo[playerid][inDerby] == 1)
	{
	     SendClientMessage(playerid, COLOR_RED, "ERROR: You're in a Derby, use /exit first!");
	     return 0;
	}
	return 1;
}
//##############################################################################
// 								      Callbacks
//##############################################################################
function HouseVisiting(playerid)
{
	new string[200], tmpstring[50];
	GetPVarString(playerid, "HousePrevName", tmpstring, 50);
	format(string, sizeof(string), I_HINT_VISIT_OVER, tmpstring, GetPVarInt(playerid, "HousePrevValue"));
	ShowPlayerDialog(playerid, HOUSEMENU+17, DIALOG_STYLE_MSGBOX, INFORMATION_HEADER, string, "Buy", "Cancel");
	return 1;
}
function HouseSpawning(playerid)
{
	foreach(Houses, h)
	{
		if(!strcmp(hInfo[h][HouseOwner], pNick(playerid), CASE_SENSETIVE))
		{
  			if(hInfo[h][QuitInHouse] == 1)
	    	{
			    SetPVarInt(playerid, "LastHouseCP", h);
       			SetPlayerHouseInterior(playerid, h);
       			#if GH_HOUSECARS == true
       				LoadHouseCar(h);
       			#endif
			    ShowInfoBoxEx(playerid, COLOUR_INFO, I_HMENU);
			    hInfo[h][QuitInHouse] = 0;
			    new INI:file = INI_Open(HouseFile(h));
			    INI_WriteInt(file, "QuitInHouse", 0);
			    INI_Close(file);
		    	break;
			}
		}
	}
	SetPVarInt(playerid, "FirstSpawn", 1);
	return 1;
}
function LoadHouseData(h, name[], value[])
{
    if(!strcmp(name, "HouseName", true)) { format(hInfo[h][HouseName], MAX_HOUSE_NAME, "%s", value); }
    if(!strcmp(name, "HouseOwner", true)) { format(hInfo[h][HouseOwner], MAX_PLAYER_NAME, "%s", value); }
    if(!strcmp(name, "HouseLocation", true)) { format(hInfo[h][HouseLocation], MAX_ZONE_NAME, "%s", GetHouseLocation(h)); }
    if(!strcmp(name, "HousePassword", true))
    {
        switch(strcmp(value, "INVALID_HOUSE_PASSWORD", true))
        {
			case 0: hInfo[h][HousePassword] = udb_hash(value);
			case 1: hInfo[h][HousePassword] = strval(value);
		}
	}
   	if(!strcmp(name, "SpawnOutX", true)) { hInfo[h][SpawnOutX] = floatstr(value); }
	if(!strcmp(name, "SpawnOutY", true)) { hInfo[h][SpawnOutY] = floatstr(value); }
	if(!strcmp(name, "SpawnOutZ", true)) { hInfo[h][SpawnOutZ] = floatstr(value); }
    if(!strcmp(name, "SpawnOutAngle", true)) { hInfo[h][SpawnOutAngle] = floatstr(value); }
    if(!strcmp(name, "SpawnInterior", true)) { hInfo[h][SpawnInterior] = strval(value); }
    if(!strcmp(name, "SpawnWorld", true)) { hInfo[h][SpawnWorld] = strval(value); }
    if(!strcmp(name, "CPOutX", true)) { hInfo[h][CPOutX] = floatstr(value); }
	if(!strcmp(name, "CPOutY", true)) { hInfo[h][CPOutY] = floatstr(value); }
	if(!strcmp(name, "CPOutZ", true)) { hInfo[h][CPOutZ] = floatstr(value); }
	if(!strcmp(name, "HouseValue", true)) { hInfo[h][HouseValue] = strval(value); }
	if(!strcmp(name, "HouseStorage", true)) { hInfo[h][HouseStorage] = strval(value); }
	if(!strcmp(name, "HouseInterior", true)) { hInfo[h][HouseInterior] = strval(value); }
	if(!strcmp(name, "HouseWorld", true)) { hInfo[h][SpawnWorld] = strval(value); }
	if(!strcmp(name, "HouseCar", true)) { hInfo[h][HouseCar] = strval(value); }
	if(!strcmp(name, "HCarPosX", true)) { hInfo[h][HouseCarPosX] = floatstr(value); }
	if(!strcmp(name, "HCarPosY", true)) { hInfo[h][HouseCarPosY] = floatstr(value); }
	if(!strcmp(name, "HCarPosZ", true)) { hInfo[h][HouseCarPosZ] = floatstr(value); }
	if(!strcmp(name, "HCarAngle", true)) { hInfo[h][HouseCarAngle] = floatstr(value); }
	if(!strcmp(name, "HCarModel", true)) { hInfo[h][HouseCarModel] = strval(value); }
	if(!strcmp(name, "HCarWorld", true)) { hInfo[h][HouseCarWorld] = strval(value); }
	if(!strcmp(name, "HCarInt", true)) { hInfo[h][HouseCarInterior] = strval(value); }
	if(!strcmp(name, "QuitInHouse", true)) { hInfo[h][QuitInHouse] = strval(value); }
	if(!strcmp(name, "ForSale", true)) { hInfo[h][ForSale] = strval(value); }
	if(!strcmp(name, "ForSalePrice", true)) { hInfo[h][ForSalePrice] = strval(value); }
	if(!strcmp(name, "HousePrivacy", true)) { hInfo[h][HousePrivacy] = strval(value); }
	if(!strcmp(name, "HouseAlarm", true)) { hInfo[h][HouseAlarm] = strval(value); }
	if(!strcmp(name, "HouseCamera", true)) { hInfo[h][HouseCamera] = strval(value); }
	if(!strcmp(name, "HouseDog", true)) { hInfo[h][HouseDog] = strval(value); }
	if(!strcmp(name, "HouseUpgradedLock", true)) { hInfo[h][UpgradedLock] = strval(value); }
	return 0;
}
function LoadHouseInteriorData(hint, name[], value[])
{
    if(!strcmp(name, "Name", true)) { format(hIntInfo[hint][IntName], 30, "%s", value); }
   	if(!strcmp(name, "SpawnX", true)) { hIntInfo[hint][IntSpawnX] = floatstr(value); }
	if(!strcmp(name, "SpawnY", true)) { hIntInfo[hint][IntSpawnY] = floatstr(value); }
	if(!strcmp(name, "SpawnZ", true)) { hIntInfo[hint][IntSpawnZ] = floatstr(value); }
    if(!strcmp(name, "Angle", true)) { hIntInfo[hint][IntSpawnAngle] = floatstr(value); }
    if(!strcmp(name, "CPX", true)) { hIntInfo[hint][IntCPX] = floatstr(value); }
	if(!strcmp(name, "CPY", true)) { hIntInfo[hint][IntCPY] = floatstr(value); }
	if(!strcmp(name, "CPZ", true)) { hIntInfo[hint][IntCPZ] = floatstr(value); }
	if(!strcmp(name, "Interior", true)) { hIntInfo[hint][IntInterior] = strval(value); }
	if(!strcmp(name, "Value", true)) { hIntInfo[hint][IntValue] = strval(value); }
	return 0;
}
function LoadUserData(playerid, name[], value[])
{
	if(!strcmp(name, "MoneyToGive", true)) { GivePlayerMoneyEx(playerid, strval(value)), SetPVarInt(playerid, "GA_TMP_HOUSEFORSALEPRICE", strval(value)); }
	if(!strcmp(name, "MoneyToGiveHS", true))  { GivePlayerMoneyEx(playerid, strval(value)), SetPVarInt(playerid, "GA_TMP_HOUSESTORAGE", strval(value)); }
	if(!strcmp(name, "HouseName", true)) { SetPVarString(playerid, "GA_TMP_HOUSENAME", value); }
	if(!strcmp(name, "HouseBuyer", true)) { SetPVarString(playerid, "GA_TMP_NEWHOUSEOWNER", value); }
	return 0;
}
INI:currentid[](name[], value[])
{
	if(!strcmp(name, "CurrentID", true)) { CurrentID = strval(value); }
    return 0;
}
function SecurityDog_ClearAnimations(playerid)
{
	return ClearAnimations(playerid);
}

function SpawnProtectionOff( playerid )
{
	SetPlayerHealth( playerid, 100 );
    TD_MSG( playerid, 3000, "~y~~h~Spawn protection ~w~~h~has been ~r~~h~disabled" );
	if (PlayerInfo[playerid][inDM] == 1)
	{
		switch (PlayerInfo[playerid][inDMZone])
		{
		    case 1:
		    {
		        GiveWeaponSet(playerid, PlayerInfo[playerid][WeaponSet]);
			}
			case 2:
			{
			    GiveWeaponSet(playerid, PlayerInfo[playerid][WeaponSet]);
			}
			case 3:
			{
			    GivePlayerWeapon(playerid, 38, 99999);
			}
			case 4:
			{
			    GivePlayerWeapon(playerid, 24, 99999);
			}
			case 5:
			{
			    GivePlayerWeapon(playerid, 35, 99999);
			}
			case 6:
			{
			    GivePlayerWeapon(playerid, 23, 100);
			}
			case 7:
			{
			    GivePlayerWeapon(playerid, 26, 99999);
			}
		}
	}
	else if (PlayerInfo[playerid][GodEnabled] == 0)
	{
	    GiveWeaponSet(playerid, PlayerInfo[playerid][WeaponSet]);
	}
	if(PlayerInfo[playerid][inDM] == 1 && PlayerInfo[playerid][inDMZone] <= 1 && PlayerInfo[playerid][inMini] == 1)
	{
	    SendClientMessage( playerid, ~1, "{FF0000}[TBS] "GREY"You have respawned in DM. Type /exit if you want to exit");
	}
	if(PlayerInfo[playerid][inDM] == 0 && PlayerInfo[playerid][inDMZone] >= 1 && PlayerInfo[playerid][inMini] == 0)
	{
	SendClientMessage( playerid, ~1, "{FF0000}[TBS] "GREY"Your spawn protection is over, be careful! You can use /god to enable god mode.");
	}
	KillTimer(protection[playerid]);
	return (1);
}

//==============================================================================
// GetPosInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance);
// Used to get the position infront of a player.
// Credits to whoever made this!
//==============================================================================
stock Float:GetPosInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
	new Float:a;
	GetPlayerPos(playerid, x, y, a);
	switch(IsPlayerInAnyVehicle(playerid))
	{
	    case 0: GetPlayerFacingAngle(playerid, a);
	    case 1: GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}
	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
	return a;
}

stock UserPath(playerid)
{
    new str[128], name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    format(str, sizeof(str), Path, name);
    return str;
}

stock GiveWeaponSet(playerid,weaponset)
{
	if(PlayerInfo[playerid][inMini] == 1) return SendClientMessage(playerid,-1,""RED"ERROR: "GREY"You cannot spawn weaponsets in Minigun DM.");
	if(weaponset == 0)
	{
		GivePlayerWeapon(playerid, 24, 999999999);
		GivePlayerWeapon(playerid, 28, 999999999);
		GivePlayerWeapon(playerid, 25, 999999999);
		GivePlayerWeapon(playerid, 17, 999999999);
		GivePlayerWeapon(playerid, 10, 999999999);
		GivePlayerWeapon(playerid, 3, 999999999);
		GivePlayerWeapon(playerid, 33, 999999999);
		GivePlayerWeapon(playerid, 30, 999999999);
		if(PlayerInfo[playerid][inDM] == 0)
		{
			SendClientMessage(playerid,-1,"{5FB9F5}** Your weapons have been updated!");
		}
	}
	if(weaponset == 1)
	{
		GivePlayerWeapon(playerid, 29, 999999999);
		GivePlayerWeapon(playerid, 31, 999999999);
		GivePlayerWeapon(playerid, 34, 999999999);
		GivePlayerWeapon(playerid, 26, 999999999);
		GivePlayerWeapon(playerid, 22, 999999999);
		GivePlayerWeapon(playerid, 12, 999999999);
		GivePlayerWeapon(playerid, 6, 999999999);
		GivePlayerWeapon(playerid, 18, 999999999);
		if(PlayerInfo[playerid][inDM] == 0)
		{
			SendClientMessage(playerid,-1,"{5FB9F5}** Your weapons have been updated!");
		}
	}
	if(weaponset == 2)
	{
		 GivePlayerWeapon(playerid, 5, 999999999);
		 GivePlayerWeapon(playerid, 23, 999999999);
		 GivePlayerWeapon(playerid, 27, 999999999);
		 GivePlayerWeapon(playerid, 32, 999999999);
		 GivePlayerWeapon(playerid, 31, 999999999);
		 GivePlayerWeapon(playerid, 34, 999999999);
		 GivePlayerWeapon(playerid, 16, 999999999);
		 GivePlayerWeapon(playerid, 13, 999999999);
	     if(PlayerInfo[playerid][inDM] == 0)
		 {
			 SendClientMessage(playerid,-1,"{5FB9F5}** Your weapons have been updated!");
		 }
    }
	return 1;
}

stock CagePlayer(playerid)
{
      if(IsPlayerConnected(playerid))
      {
      new Float:X, Float:Y, Float:Z;
      GetPlayerPos(playerid, X, Y, Z);
      cage[playerid] = CreateObject(985, X, Y+4, Z, 0.0, 0.0, 0.0);
      cage2[playerid] = CreateObject(985, X+4, Y, Z, 0.0, 0.0, 90.0);
      cage3[playerid] = CreateObject(985, X-4, Y, Z, 0.0, 0.0, 270.0);
      cage4[playerid] = CreateObject(985, X, Y-4, Z, 0.0, 0.0, 180.0);
      caged[playerid] = 1; // Use this in a /cage command to prevent being caged twice and causing the cage to be unremovable.
      PlayerPlaySound(playerid, 1137, X, Y, Z);
      }
}

stock UnCagePlayer(playerid)
{
      cage[playerid] = DestroyObject(cage[playerid]);
      cage2[playerid] = DestroyObject(cage2[playerid]);
      cage3[playerid] = DestroyObject(cage3[playerid]);
      cage4[playerid] = DestroyObject(cage4[playerid]);
      caged[playerid] = 0;
}

stock DestroyNeonObjects(playerid)
{
				DestroyObject(GetPVarInt(playerid,"neon"));
				DestroyObject(GetPVarInt(playerid,"neon1"));
				DestroyObject(GetPVarInt(playerid,"neon2"));
				DestroyObject(GetPVarInt(playerid,"neon3"));
				DestroyObject(GetPVarInt(playerid,"neon4"));
				DestroyObject(GetPVarInt(playerid,"neon5"));
				DestroyObject(GetPVarInt(playerid,"neon6"));
				DestroyObject(GetPVarInt(playerid,"neon7"));
				DestroyObject(GetPVarInt(playerid,"neon8"));
				DestroyObject(GetPVarInt(playerid,"neon9"));
				DestroyObject(GetPVarInt(playerid,"neon10"));
				DestroyObject(GetPVarInt(playerid,"neon11"));
				DestroyObject(GetPVarInt(playerid,"neon12"));
				DestroyObject(GetPVarInt(playerid,"neon13"));
				DestroyObject(GetPVarInt(playerid,"neon14"));
				DestroyObject(GetPVarInt(playerid,"neon15"));
				DestroyObject(GetPVarInt(playerid,"neon16"));
				DestroyObject(GetPVarInt(playerid,"neon17"));
				DestroyObject(GetPVarInt(playerid,"neon18"));
				DestroyObject(GetPVarInt(playerid,"neon19"));
				DestroyObject(GetPVarInt(playerid,"neon20"));
				DestroyObject(GetPVarInt(playerid,"neon21"));
				DestroyObject(GetPVarInt(playerid,"neon22"));
				DestroyObject(GetPVarInt(playerid,"neon23"));
				DestroyObject(GetPVarInt(playerid,"neon24"));
				DestroyObject(GetPVarInt(playerid,"neon25"));
				DestroyObject(GetPVarInt(playerid,"neon26"));
				DestroyObject(GetPVarInt(playerid,"neon27"));
				DestroyObject(GetPVarInt(playerid,"neon28"));
				DestroyObject(GetPVarInt(playerid,"neon29"));
				DestroyObject(GetPVarInt(playerid,"neon30"));
				DestroyObject(GetPVarInt(playerid,"neon31"));
				DestroyObject(GetPVarInt(playerid,"neon32"));
				DestroyObject(GetPVarInt(playerid,"neon33"));
				DestroyObject(GetPVarInt(playerid,"neon34"));
				DestroyObject(GetPVarInt(playerid,"neon35"));
				DestroyObject(GetPVarInt(playerid,"interior"));
				DestroyObject(GetPVarInt(playerid,"interior1"));
				DestroyObject(GetPVarInt(playerid,"back"));
				DestroyObject(GetPVarInt(playerid,"back1"));
				DestroyObject(GetPVarInt(playerid,"front"));
				DestroyObject(GetPVarInt(playerid,"front1"));
				DestroyObject(GetPVarInt(playerid,"undercover"));
				DestroyObject(GetPVarInt(playerid,"undercover1"));
				DeletePVar(playerid,"Status");
                SetPlayerTime(playerid, 12, 0);
}

stock SetPlayerVehiclePos (playerid, Float:X2, Float:Y2, Float:Z2, Float:A2)
{
	vID = GetPlayerVehicleID(playerid);
	SetVehiclePos(vID, X2, Y2, Z2);
	SetVehicleZAngle(vID, A2);
}

stock SetPlayerPosition (playerid, Float:X2, Float:Y2, Float:Z2, Float:A2)
{
	SetPlayerPos(playerid, X2, Y2, Z2);
	SetPlayerFacingAngle(playerid, A2);
}

stock IsNumeric(const String[])
{
	for(new X6 = 0; X < strlen(String); X6++)
 	{
		if(String[X6] > '9' || String[X6] < '0') return 0;
	}
	return 1;
}


//=========[Duel Callbacks]========
public DuelReset(player1, player2)
{
	if(InDuel[player1] == 1) return 1;
	new str[50];
	format(str, sizeof(str), "%s didn't respond to your duel invite", pDName(player2));
	SendClientMessage(player1, COLOR_DUEL, str);
	SetPlayerArmour(player1, 0);
	SetPlayerArmour(player2, 0);
	RemoveFromDuel(player1);
	RemoveFromDuel(player2);
 	return 1;
}

public DuelCDUpdate(playerid)
{
	SetPVarInt(playerid, "CDTick", GetPVarInt(playerid, "CDTick")+1);
	if(GetPVarInt(playerid, "CDTick") > 3)
	{
		TogglePlayerControllable(playerid, 1);
		GameTextForPlayer(playerid, "~R~Fight!", 1000, 6);
		SetPVarInt(playerid, "CDTick", 0);
		PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
		KillTimer(DuelTimer[playerid]);
	}
	else
	{
	    GameTextForPlayer(playerid, "~P~Starting...", 500, 6);
	    PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
	}
	return 1;
}
//=========[Duel Callbacks - END]==========

//=========[Duel Functions]===============
stock AddToDuel(playerid, Float:X6, Float:Y6, Float:Z6, world, wep1, wep2, wep3)
{
	SetPVarInt(playerid, "CDTick", 0);
	InDuel[playerid] = 1;
	SetPVarInt(playerid, "ArmourReport", 1);
	SetPlayerPosDuel(playerid, X6, Y6, Z6, world);
 	SetPlayerArmour(playerid, 100);
 	SetPlayerHealth(playerid, 100);
 	ResetPlayerWeapons(playerid);

	GivePlayerWeapon(playerid, wep1, 1337);
	GivePlayerWeapon(playerid, wep2, 1337);
	GivePlayerWeapon(playerid, wep3, 1337);

	TogglePlayerControllable(playerid, 0);
	SetCameraBehindPlayer(playerid);
	DuelTimer[playerid] = SetTimerEx("DuelCDUpdate", 1000, 1, "i", playerid);
	return 1;
}

stock AcceptDuel(playerid)
{
	if(InDuel[playerid] == 1) return SendClientMessage(playerid, COLOR_RED, "You are already in a duel");

	new duelid = GetPVarInt(playerid, "DuelDID");
	new gPlayer = dInfo[duelid][Inviter];
	new gBet = dInfo[duelid][BetMoney];

	if(MINMONEY != 0 && GetPlayerMoneyEx(playerid) < gBet)
	{
		SendClientMessage(playerid, COLOR_RED, "Duel | You don't have that amount of money!");
		SendClientMessage(gPlayer, COLOR_RED, "Duel | The player you invited no longer has that amount of money to bet!");

		SetPlayerArmour(playerid, 0);
		SetPlayerArmour(gPlayer, 0);
		RemoveFromDuel(playerid);
		RemoveFromDuel(gPlayer);
		return 1;
	}

	new gDuelSpot = dInfo[duelid][Location];
	format(dFile, sizeof(dFile), DUELFILES, gDuelSpot);

	new Float:X6, Float:Y6, Float:Z6; //Float:A6
	X6 = dini_Float(dFile, "duelX");
	Y6 = dini_Float(dFile, "duelY");
	Z6 = dini_Float(dFile, "duelZ");
	//A6 = dini_Float(dFile, "duelA");
	new Float:X2, Float:Y2, Float:Z2; //Float:A2
	X2 = dini_Float(dFile, "duel2X");
	Y2 = dini_Float(dFile, "duel2Y");
	Z2 = dini_Float(dFile, "duel2Z");
	//A2 = dini_Float(dFile, "duelA2");

	new Slot[3];
	Slot[0] = dWeps[duelid][0];
	Slot[1] = dWeps[duelid][1];
	Slot[2] = dWeps[duelid][2];
	TotalDuels++;

	SetPVarInt(playerid, "DuelDID", duelid);
	SetPVarInt(gPlayer, "DuelDID", duelid);
 	RemoveDuelInvite(playerid, gPlayer);
 	KillTimer(DuelTimer[playerid]);
	KillTimer(DuelTimer[gPlayer]);

	new world = playerid;
	if(gPlayer > playerid) world = gPlayer+1;
	else if(playerid > gPlayer) world = playerid+1;
	AddToDuel(gPlayer, X2, Y2, Z2, world, Slot[0], Slot[1], Slot[2]);
	AddToDuel(playerid, X6, Y6, Z6, world, Slot[0], Slot[1], Slot[2]);

	new str[150];
	format(str, sizeof(str), "Duel | %s vs %s {0004B6}(Weapons: %s %s %s) {009900}(Bet: $%d) {F8FF3D}(Place: %s [ID %d])", pDName(gPlayer), pDName(playerid), weaponNames(Slot[0]), weaponNames(Slot[1]), weaponNames(Slot[2]), gBet, ReturnDuelNameFromID(gDuelSpot), gDuelSpot);
	SendClientMessageToAll(COLOR_DUEL, str);
	return 1;
}

stock RemoveFromDuel(playerid)
{
	KillTimer(DuelTimer[playerid]);
	SetPlayerArmour(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPVarInt(playerid, "ArmorReport", 0);
	InDuel[playerid] = 0;
	SetPVarInt(playerid, "DuelDID", -1);
	return 1;
}

stock ShowDuelSettingsDialog(playerid)
{
	new str[255], wepstr[3][40], key[7];
	new dPID = GetPVarInt(playerid, "dPID");
	new dLoc = GetPVarInt(playerid, "dLoc");
	for(new x=0; x<=2; x++)
	{
	   	format(key, sizeof(key), "dWep%d", x);
	   	new wep = GetPVarInt(playerid, key);
	   	format(wepstr[x], 40, "%s", weaponNames(wep));
	}
	format(str, sizeof(str), "{009900}Player:\t\t{0004B6}%s [%d]\n{009900}Location:\t{0004B6}%s [%d]\n{009900}Weapons:\t{0004B6}%s/%s/%s\n{009900}Bet Money:{009900}\t{0004B6}$%d\n{009900}Send Invite\n{009900}Cancel Invite", pDName(dPID), dPID, ReturnDuelNameFromID(dLoc), dLoc, wepstr[0], wepstr[1], wepstr[2], GetPVarInt(playerid, "dBet"));
	ShowPlayerDialog(playerid, DUELDIAG, DIALOG_STYLE_LIST, "Duel Settings", str, "Select", "Cancel");
	return 1;
}

stock ShowDuelInvitesDialog(playerid)
{
	new total;
	format(diagstr, sizeof(diagstr), "");
	for(new x=0; x<MAX_INVITES; x++)
	{
	    new inviter = dinvitem[playerid][x];
	    if(inviter == playerid || inviter == -1) continue;
		format(diagstr, sizeof(diagstr), "%s%s\n", diagstr, pDName(inviter));
		total++;
	}
	if(total == 0) format(diagstr, sizeof(diagstr), "{CC0000}You have not been recently invited!");
	ShowPlayerDialog(playerid, DUELDIAG+8, DIALOG_STYLE_LIST, "Duel Invites", diagstr, "Accept", "Cancel");
	return 1;
}

stock RemoveDuelInvite(playerid, inviter)
{
	for(new x=0; x<MAX_INVITES; x++)
	{
	    if(dinvitem[playerid][x] == inviter) dinvitem[playerid][x] = -1;
	}
}

stock ResetDuelInvites(playerid)
{
	for(new x=0; x<MAX_INVITES; x++) dinvitem[playerid][x] = -1;
}

stock ResetDuelInformation(duelid)
{
	dInfo[duelid][Inviter] = -1;
	dInfo[duelid][Invitee] = -1;
	dInfo[duelid][BetMoney] = 0;
	dInfo[duelid][Location] = -1;
	dInfo[duelid][Location] = 0;
	for(new x=0; x<MAX_DUEL_WEPS; x++) dWeps[duelid][x] = 0;
}

stock GetDuelerID(playerid)
{
	new duelerid = -1;
	new duelid = GetPVarInt(playerid, "DuelDID");
	if(dInfo[duelid][Inviter] == playerid) duelerid = dInfo[duelid][Invitee];
	else duelerid = dInfo[duelid][Inviter];
	return duelerid;
}
//=========[Duel Functions - END]===============

//=========[Duel Spectate Functions]==========
stock LoadDuelSpecTextdraw(playerid)
{
	SpecTD[playerid][0] = TextDrawCreate(180.000000, 364.000000, "_");
	TextDrawBackgroundColor(SpecTD[playerid][0], 255);
	TextDrawFont(SpecTD[playerid][0], 3);
	TextDrawLetterSize(SpecTD[playerid][0], 0.469999, 1.200000);
	TextDrawColor(SpecTD[playerid][0], 52479);
	TextDrawSetOutline(SpecTD[playerid][0], 0);
	TextDrawSetProportional(SpecTD[playerid][0], 1);
	TextDrawSetShadow(SpecTD[playerid][0], 1);
	SpecTD[playerid][1] = TextDrawCreate(180.000000, 387.000000, "_");
	TextDrawBackgroundColor(SpecTD[playerid][1], 255);
	TextDrawFont(SpecTD[playerid][1], 3);
	TextDrawLetterSize(SpecTD[playerid][1], 0.469999, 1.200000);
	TextDrawColor(SpecTD[playerid][1], -1);
	TextDrawSetOutline(SpecTD[playerid][1], 0);
	TextDrawSetProportional(SpecTD[playerid][1], 1);
	TextDrawSetShadow(SpecTD[playerid][1], 1);
	TextDrawHideForAll(SpecTD[playerid][0]);
	TextDrawHideForAll(SpecTD[playerid][1]);
}

public UpdateSpectate(playerid)
{
	new specid = GetPVarInt(playerid, "DuelSpecID");
	if(!IsPlayerInDuel(specid)) return EndDuelSpectate(playerid);
	else ShowDuelSpecTextdraw(playerid, specid);
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(specid));
	SetPlayerInterior(playerid, GetPlayerInterior(specid));
	return 1;
}

stock EndDuelSpectate(playerid)
{
	KillTimer(UpdateSpecTimer[playerid]);
	SetPVarInt(playerid, "DuelSpecID", -1);
	SetPVarInt(playerid, "DuelSpec", 0);
	SendClientMessage(playerid, COLOR_DUEL, "Duel spectate ended, duel is no longer in progress.");
	TogglePlayerSpectating(playerid, 0);
	KillTimer(UpdateSpecTimer[playerid]);
	TextDrawHideForPlayer(playerid, SpecTD[playerid][0]);
	TextDrawHideForPlayer(playerid, SpecTD[playerid][1]);
	return 1;
}

stock SetPlayerSpectatingDuel(playerid, duelerid)
{
    TogglePlayerSpectating(playerid, 1);
	SendClientMessage(playerid, COLOR_DUEL, "You have entered duel spectate mode!");
	SendClientMessage(playerid, COLOR_DUEL, "Press the FIRE key to switch between duelists.");
	ShowDuelSpecTextdraw(playerid, duelerid);
	KillTimer(UpdateSpecTimer[playerid]);
	UpdateSpecTimer[playerid] = SetTimerEx("UpdateSpectate", 1000, 1, "d", playerid);
	SetPVarInt(playerid, "DuelSpecID", duelerid);
	SetPVarInt(playerid, "DuelSpec", 1);
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(duelerid));
	SetPlayerInterior(playerid, GetPlayerInterior(duelerid));
	PlayerSpectatePlayer(playerid, duelerid, SPECTATE_MODE_NORMAL);
}

stock ShowDuelSpecTextdraw(playerid, duelerid)
{
	new sstr[100], sstr2[140];

	new duelloc[40];
	new duelid, dueler;
	duelid = GetPVarInt(duelerid, "DuelDID");
	if(dInfo[duelid][Inviter] == duelerid) dueler = dInfo[duelid][Invitee];
	else dueler = dInfo[duelid][Inviter];

	new gBet = dInfo[duelid][BetMoney];
	new gDuelSpot = dInfo[duelid][Location];
	format(duelloc, sizeof(duelloc), "%s", ReturnDuelNameFromID(gDuelSpot));

	new Slot[3];
	Slot[0] = dWeps[duelid][0];
	Slot[1] = dWeps[duelid][1];
	Slot[2] = dWeps[duelid][2];

	format(sstr, sizeof(sstr), "%s vs %s~n~~R~HP ~W~%d      %d", pDName(duelerid), pDName(dueler), GetRoundedTotalHP(duelerid), GetRoundedTotalHP(dueler));
	format(sstr2, sizeof(sstr2), "~Y~Location ~w~%s~n~~p~Weapons ~w~%s %s %s~n~~g~Bet Money ~w~$%d",
	duelloc, weaponNames(Slot[0]), weaponNames(Slot[1]), weaponNames(Slot[2]), gBet);
	TextDrawHideForPlayer(playerid, SpecTD[playerid][0]);
	TextDrawHideForPlayer(playerid, SpecTD[playerid][1]);
	TextDrawSetString(SpecTD[playerid][0], sstr);
	TextDrawSetString(SpecTD[playerid][1], sstr2);
	TextDrawShowForPlayer(playerid, SpecTD[playerid][0]);
	TextDrawShowForPlayer(playerid, SpecTD[playerid][1]);
}
//=======================[Spectate - END]==========================

//======================[Internal Functions]=======================
stock IsPlayerInDuel(playerid)
{
	if(InDuel[playerid] == 1) return 1;
	return 0;
}

stock IsValidWeapon(weaponid)
{
	switch(weaponid)
	{
	    case 0, 19, 20, 21, 35..46: return 0;
	}
    if(weaponid < 0 || weaponid > 48) return 0;
    return 1;
}

stock ReturnWeaponIDOrName(idname[])
{
	if(!IsNumeric(idname))
	{
	    new gWeap = GetWeaponModelIDFromName(idname);
	    if(IsValidWeapon(gWeap)) return gWeap;
	}
	else if(IsNumeric(idname))
	{
	    new gWeap = strval(idname);
		if(IsValidWeapon(gWeap)) return gWeap;
	}
 	return -1;
}

stock GetRoundedTotalHP(playerid)
{
	new Float:HP, Float:Armour, HPT;
	GetPlayerHealth(playerid, HP);
	GetPlayerArmour(playerid, Armour);
	HPT = floatround(HP) + floatround(Armour);
	return HPT;
}

GetWeaponModelIDFromName(wname[])
{
	for(new i=0; i<49; i++)
	{
		if(i == 19 || i == 20 || i == 21) continue;
		if(strfind(weaponNames(i), wname, true) != -1) return i;
	}
	return -1;
}

stock DuelNameExists(duelname[])
{
	for(new x=0; x<MAX_DUELS; x++)
	{
		format(dFile, sizeof(dFile), DUELFILES, x);
		if(strfind(duelname, dini_Get(dFile, "duelName"), true) != -1) return 1;
		break;
	}
	return 0;
}

stock ReturnDuelIDOrName(duelname[])
{
	if(!IsNumeric(duelname))
	{
	    for(new x=0; x<MAX_DUELS; x++)
	    {
	        new dName[128];
	        new idfromname = x;
			format(dFile, sizeof(dFile), DUELFILES, x);
	    	format(dName, sizeof(dName), "%s", dini_Get(dFile, "duelName"));
	    	if(strfind(dName, duelname, true) != -1) return idfromname;
	    	break;
	    }
	}
	else if(IsNumeric(duelname))
	{
	    new dName = strval(duelname);
		format(dFile, sizeof(dFile), DUELFILES, dName);
	    if(fexist(dFile)) return dName;
	}
 	return -1;
}

stock weaponNames(weaponid)
{
	new str[25];
	switch(weaponid)
	{
     	case 0: str = "Fist";
		case 1:	str = "Brass Knuckles";
		case 2: str = "Golf Club";
		case 3: str = "Night Stick";
		case 4: str = "Knife";
		case 5: str = "Baseball Bat";
		case 6: str = "Shovel";
		case 7: str = "Pool Cue";
		case 8: str = "Katana";
		case 9: str = "Chainsaw";
		case 10: str = "Purple Dildo";
		case 11: str = "Vibrator";
		case 12: str = "Vibrator";
		case 13: str = "Vibrator";
		case 14: str = "Flowers";
		case 15: str = "Cane";
		case 16: str = "Grenade";
		case 17: str = "Teargas";
		case 18: str = "Molotov";
		case 19: str = " ";
		case 20: str = " ";
		case 21: str = " ";
		case 22: str = "Colt 45";
		case 23: str = "Silenced Pistol";
		case 24: str = "Deagle";
		case 25: str = "Shotgun";
		case 26: str = "Sawns";
		case 27: str = "Spas";
		case 28: str = "Uzi";
		case 29: str = "MP5";
		case 30: str = "AK47";
		case 31: str = "M4";
		case 32: str = "Tec9";
		case 33: str = "County Rifle";
		case 34: str = "Sniper Rifle";
		case 35: str = "Rocket Launcher";
		case 36: str = "Heat-Seeker";
		case 37: str = "Flamethrower";
		case 38: str = "Minigun";
		case 39: str = "Satchel Charge";
		case 40: str = "Detonator";
		case 41: str = "Spray Can";
		case 42: str = "Fire Extinguisher";
		case 43: str = "Camera";
		case 44: str = "Night Vision Goggles";
		case 45: str = "Infrared Goggles";
		case 46: str = "Parachute";
		case 47: str = "Fake Pistol";
		case 48: str = "None"; //For duel msgs
	}
	return str;
}

stock ReturnDuelNameFromID(duelid)
{
	new dName[80];
	format(dFile, sizeof(dFile), DUELFILES, duelid);
	format(dName, sizeof(dName), "%s", dini_Get(dFile, "duelName"));
	return dName;
}

stock pName(playerid)
{
	new paname[MAX_PLAYER_NAME];
	GetPlayerName(playerid, paname, sizeof(paname));
	return paname;
}

stock GetLowestUnusedDuelSlot(playerid)
{
	new duelid;
	for(new x=0; x<MAX_INVITES; x++)
	{
	    if(!IsPlayerConnected(dinvitem[playerid][x]))
		{
		    duelid = x;
			break;
		}
	}
	return duelid;
}

stock GetLowestUnusedDuelID()
{
	new duelid;
	for(new x=0; x<MAX_DUELS; x++)
	{
	    if(!IsPlayerConnected(dInfo[x][Inviter]) || !IsPlayerConnected(dInfo[x][Invitee]))
	    {
	        duelid = x;
	        break;
	    }
	}
	return duelid;
}

stock GetLowestDuelSlotID()
{
	for(new x=0; x<MAX_DUELS; x++)
	{
		format(dFile, sizeof(dFile), DUELFILES, x);
 		if(!dini_Exists(dFile)) return x;
	}
	return 1;
}

stock pDName(playerid)
{
	new pdname[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pdname, sizeof(pdname));
	return pdname;
}

stock CreatePlayerVehicle(PlayerId,ModelId)
{
	new Float:X;
	new Float:Y;
	new Float:Z;
	new Float:A;
	if(GetPlayerState(PlayerId) == PLAYER_STATE_DRIVER)
	{
	    GetVehiclePos(GetPlayerVehicleID(PlayerId),X,Y,Z);
	    GetVehicleZAngle(GetPlayerVehicleID(PlayerId),A);
	}
	if(GetPlayerState(PlayerId) != PLAYER_STATE_DRIVER)
	{
	    DestroyVehicle(Veh[playerid][VehId]);
	    GetPlayerPos(PlayerId,X,Y,Z);
	    GetPlayerFacingAngle(PlayerId,A);
	    return 1;
	}
	PlayerVehicle[PlayerId] = CreateVehicle(ModelId,X,Y,Z + 3,A,-1,-1,-1);
	SetVehicleParamsEx(PlayerVehicle[PlayerId],1,0,0,0,0,0,0);
	PutPlayerInVehicle(PlayerId,PlayerVehicle[PlayerId],0);
	return 1;
}

stock RespawninDM (playerid)
{
	switch (PlayerInfo[playerid][inDMZone])
	{
     	case 1:
     	{
	 		new Float:RandomSpawns[][] =
			{
		    	{1306.6731,2108.0920,11.0156,320.5279},
				{1383.2549,2185.4321,11.0234,142.6434}
			};
			new Random = random(sizeof(RandomSpawns));
			SetPlayerPosition(playerid, RandomSpawns[Random][0], RandomSpawns[Random][1], RandomSpawns[Random][2], RandomSpawns[Random][3]);
			SetPlayerVirtualWorld(playerid, 1);
			SetCameraBehindPlayer(playerid);
			SetPlayerTeam(playerid, playerid);
			ResetPlayerWeapons(playerid);
			SetPlayerHealth(playerid, 100.0);
			GiveWeaponSet(playerid, PlayerInfo[playerid][WeaponSet]);
			SpawnProtection(playerid);
		}
		case 2:
		{
      		new Float:RandomSpawns1[][] =
			{
	    		{336.9875,1822.0619,17.6406,88.7100},
				{123.5864,1819.3789,17.6406,346.1517},
				{135.2626,1935.9694,19.2690,174.2042}
			};
			new Random = random(sizeof(RandomSpawns1));
			SetPlayerPosition(playerid, RandomSpawns1[Random][0], RandomSpawns1[Random][1], RandomSpawns1[Random][2], RandomSpawns1[Random][3]);
			SetPlayerVirtualWorld(playerid, 1);
			SetCameraBehindPlayer(playerid);
			SetPlayerTeam(playerid, playerid);
			ResetPlayerWeapons(playerid);
			SetPlayerHealth(playerid, 100.0);
			GiveWeaponSet(playerid, PlayerInfo[playerid][WeaponSet]);
			SpawnProtection(playerid);
		}
		case 3:
		{
		    new Float:RandomSpawns2[][] =
			{
	    		{2643.1538,2777.5657,23.8222,177.1462},
				{2604.4246,2726.2517,23.8222,356.0145},
				{2597.5359,2780.0967,23.8222,265.4370},
				{2608.2749,2731.7131,36.5386,1.3178}
			};
			new Random = random(sizeof(RandomSpawns2));
			SetPlayerPosition(playerid, RandomSpawns2[Random][0], RandomSpawns2[Random][1], RandomSpawns2[Random][2], RandomSpawns2[Random][3]);
			SetPlayerVirtualWorld(playerid, 1);
			SetCameraBehindPlayer(playerid);
			SetPlayerTeam(playerid, playerid);
			ResetPlayerWeapons(playerid);
			SetPlayerHealth(playerid, 100.0);
			GivePlayerWeapon(playerid, 38, 99999);
			SpawnProtection(playerid);
	    }
	    case 4:
	    {
	   	    new Float:RandomSpawns3[][] =
            {
	            {-458.5346,2181.8350,47.1960,317.6914},
		        {-338.3433,2209.2195,42.4844,76.4224},
		        {-366.1375,2275.1846,41.6491,141.9097},
		        {-517.3373,2235.7214,57.7979,272.5709}
	        };
	        new Random = random(sizeof(RandomSpawns3));
            SetPlayerPosition(playerid, RandomSpawns3[Random][0], RandomSpawns3[Random][1], RandomSpawns3[Random][2], RandomSpawns3[Random][3]);
            SetPlayerVirtualWorld(playerid, 1);
            SetCameraBehindPlayer(playerid);
            SetPlayerTeam(playerid, playerid);
            SetPlayerHealth(playerid, 100.0);
            GivePlayerWeapon(playerid, 24, 99999);
			SpawnProtection(playerid);
        }
        case 5:
        {
            new Float:RandomSpawns4[][] =
            {
                {3383.5664,2202.0608,19.2243,237.1224},
                {3538.0852,2061.6968,26.2328,30.6570},
                {3541.4534,2208.6680,26.9936,79.1484},
                {3444.3206,2129.8296,22.4213,146.4239}
    	    };
	        new Random = random(sizeof(RandomSpawns4));
            SetPlayerPosition(playerid, RandomSpawns4[Random][0], RandomSpawns4[Random][1], RandomSpawns4[Random][2], RandomSpawns4[Random][3]);
            SetPlayerVirtualWorld(playerid, 1);
			SetPlayerTeam(playerid, playerid);
	        SetPlayerHealth(playerid, 100.0);
            GivePlayerWeapon(playerid, 35, 99999);
			SpawnProtection(playerid);
		}
        case 6:
        {
            new Float:RandomSpawns5[][] =
	        {
	            {1066.0101,2617.8953,60.2512,53.9990},
	            {1011.5014,2617.3079,60.2469,308.7414},
	            {1066.6931,2634.0889,55.2469,139.5163},
	            {1010.6512,2617.0696,55.2469,320.9146}
	        };
	        new Random = random(sizeof(RandomSpawns5));
	        SetPlayerPosition(playerid, RandomSpawns5[Random][0], RandomSpawns5[Random][1], RandomSpawns5[Random][2], RandomSpawns5[Random][3]);
			SetPlayerTeam(playerid, playerid);
            SetPlayerVirtualWorld(playerid, 1);
	        SetPlayerHealth(playerid, 2.0);
	        GivePlayerWeapon(playerid, 23, 100);
		}
        case 7:
        {

	        new Float:RandomSpawns6[][] =
	        {
	            {3152.3618,-953.6491,6.7844,86.4379},
	            {3070.5437,-972.6807,6.7766,335.2036},
	            {3149.2522,-871.6746,6.7766,171.9554},
	            {3092.6870,-866.5349,6.7766,177.2820}
            };
	        new Random = random(sizeof(RandomSpawns6));
            SetPlayerPosition(playerid, RandomSpawns6[Random][0], RandomSpawns6[Random][1], RandomSpawns6[Random][2], RandomSpawns6[Random][3]);
			SetPlayerTeam(playerid, playerid);
            SetPlayerVirtualWorld(playerid, 1);
	        SetPlayerHealth(playerid, 100.0);
	        GivePlayerWeapon(playerid, 26, 99999);
			SpawnProtection(playerid);
		}
	}
	return 1;
}

stock stringContainsIP(string[])
{
    new dotCount;
    for(new i; string[i] != EOS; ++i)
    {
        if(('0' <= string[i] <= '9') || string[i] == '.' || string[i] == ':')
        {
            if((string[i] == '.') && (string[i + 1] != '.') && ('0' <= string[i - 1] <= '9'))
            {
                ++dotCount;
            }
            continue;
        }
    }
    return (dotCount > 2);
}
//==============================================================================
// LoadHouses();
// This function is used to load the houses.
// It creates all the checkpoints, map icons and
// 3D texts for all the houses and sets the correct 3D text information.
//==============================================================================
stock LoadHouses()
{
	new hcount, labeltext[250], countstart = GetTickCount(), INI:file;
	LoadHouseInteriors(); // Load house interiors
	Loop(h, MAX_HOUSES, 0)
	{
	    if(fexist(HouseFile(h)))
	    {
	        INI_ParseFile(HouseFile(h), "LoadHouseData", false, true, h, true, false );
		    #if GH_USE_CPS == true
		    	HouseCPOut[h] = CreateDynamicCP(hInfo[h][CPOutX], hInfo[h][CPOutY], hInfo[h][CPOutZ], 1.5, hInfo[h][SpawnWorld], hInfo[h][SpawnInterior], -1, 15.0);
			#else
				HousePickupOut[h] = CreateDynamicPickup(PICKUP_MODEL_OUT, PICKUP_TYPE, hInfo[h][CPOutX], hInfo[h][CPOutY], hInfo[h][CPOutZ], hInfo[h][SpawnWorld], hInfo[h][SpawnInterior], -1, 15.0);
			#endif
			CreateCorrectHouseExitCP(h);
		    if(!strcmp(hInfo[h][HouseOwner], INVALID_HOWNER_NAME, CASE_SENSETIVE))
		    {
		        format(labeltext, sizeof(labeltext), LABELTEXT1, hInfo[h][HouseName], hInfo[h][HouseValue], h);
                #if GH_USE_MAPICONS == true
					HouseMIcon[h] = CreateDynamicMapIcon(hInfo[h][CPOutX], hInfo[h][CPOutY], hInfo[h][CPOutZ], 31, -1, hInfo[h][SpawnWorld], hInfo[h][SpawnInterior], -1, MICON_VD);
				#endif
			}
		    if(strcmp(hInfo[h][HouseOwner], INVALID_HOWNER_NAME, CASE_SENSETIVE))
		    {
		        format(labeltext, sizeof(labeltext), LABELTEXT2, hInfo[h][HouseName], hInfo[h][HouseOwner], hInfo[h][HouseValue], YesNo(hInfo[h][ForSale]), Answer(hInfo[h][HousePrivacy], "Open", "Closed"), h);
                #if GH_USE_MAPICONS == true
					HouseMIcon[h] = CreateDynamicMapIcon(hInfo[h][CPOutX], hInfo[h][CPOutY], hInfo[h][CPOutZ], 32, -1, hInfo[h][SpawnWorld], hInfo[h][SpawnInterior], -1, MICON_VD);
				#endif
			}
			HouseLabel[h] = CreateDynamic3DTextLabel(labeltext, COLOUR_GREEN, hInfo[h][CPOutX], hInfo[h][CPOutY], hInfo[h][CPOutZ]+0.7, TEXTLABEL_DISTANCE, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, TEXTLABEL_TESTLOS, hInfo[h][SpawnWorld], hInfo[h][SpawnInterior], -1, TEXTLABEL_DISTANCE);
            if(isnull(hIntInfo[hInfo[h][HouseInterior]][IntName]))
			{
			    hInfo[h][HouseInterior] = DEFAULT_H_INTERIOR;
			    file = INI_Open(HouseFile(h));
			    INI_WriteInt(file, "HouseInterior", DEFAULT_H_INTERIOR);
			    INI_Close(file);
			}
			Iter_Add(Houses, h);
		    hcount++;
		}
	}
	return printf("\nTotal Houses Loaded: %d. Duration: %d ms\n", hcount, (GetTickCount() - countstart));
}
//==============================================================================
// LoadHouseCar(houseid);
// This function is used to load the house car for a house.
//==============================================================================
stock LoadHouseCar(houseid)
{
	#if GH_HOUSECARS == true
		if(fexist(HouseFile(houseid)) && hInfo[houseid][HouseCar] == 1)
		{
			HCar[houseid] = CreateVehicle(hInfo[houseid][HouseCarModel], hInfo[houseid][HouseCarPosX], hInfo[houseid][HouseCarPosY], hInfo[houseid][HouseCarPosZ], hInfo[houseid][HouseCarAngle], HCAR_COLOUR1, HCAR_COLOUR2, HCAR_RESPAWN);
			SetVehicleVirtualWorld(HCar[houseid], hInfo[houseid][HouseCarWorld]);
			LinkVehicleToInterior(HCar[houseid], hInfo[houseid][HouseCarInterior]);
		}
	#endif
	return 1;
}
//==============================================================================
// UnloadHouseCar(houseid);
// This function is used to the unload house car for a house.
//==============================================================================
stock UnloadHouseCar(houseid)
{
	#if GH_HOUSECARS == false
	    #pragma unused houseid
	#else
		if(fexist(HouseFile(houseid)) && hInfo[houseid][HouseCar] == 1)
		{
		    if(GetVehicleModel(HCar[houseid]) >= 400 && GetVehicleModel(HCar[houseid]) <= 611 && HCar[houseid] >= 1)
			{
			    DestroyVehicle(HCar[houseid]);
			    HCar[houseid] = -1;
			}
		}
	#endif
	return 1;
}
//==============================================================================
// SaveHouseCar(houseid);
// This function is used to check if there is any vehicles
// near the housecar spawn.
//==============================================================================
stock SaveHouseCar(houseid)
{
	#if GH_HOUSECARS == true
	if(fexist(HouseFile(houseid)) && hInfo[houseid][HouseCar] == 1)
	{
 		Loop(v, MAX_VEHICLES, 0)
		{
			if(GetVehicleModel(v) < 400 || GetVehicleModel(v) > 611 || IsVehicleOccupied(v)) continue;
   			GetVehiclePos(v, X, Y, Z);
   			if(PointInRangeOfPoint(HCAR_RANGE, X, Y, Z, hInfo[houseid][HouseCarPosX], hInfo[houseid][HouseCarPosY], hInfo[houseid][HouseCarPosZ]))
   			{
			        new INI:file = INI_Open(HouseFile(houseid));
			        INI_WriteInt(file, "HCarModel", GetVehicleModel(v));
			        INI_Close(file);
			        DestroyVehicle(v);
			        break;
   			}
		}
	}
	#endif
	return 1;
}
//==============================================================================
// LoadHouseInteriors();
// This function is used to load the house interior datas from the files.
//==============================================================================
stock LoadHouseInteriors()
{
	new hintcount, filename[HOUSEFILE_LENGTH], countstart = GetTickCount();
	Loop(hint, MAX_HOUSE_INTERIORS, 0)
	{
	    format(filename, sizeof(filename), HINT_FILEPATH, hint);
	    if(fexist(filename))
	    {
	        INI_ParseFile(filename, "LoadHouseInteriorData", false, true, hint, true, false);
		    hintcount++;
		}
	}
	return printf("\nTotal House Interiors Loaded: %d. Duration: %d ms\n", hintcount, (GetTickCount() - countstart));
}
//==============================================================================
// GetOwnedHouses(playerid);
// This function is used to find out how many houses a player owns
//==============================================================================
stock GetOwnedHouses(playerid)
{
	new tmpcount;
	foreach(Houses, h)
	{
	    if(!strcmp(hInfo[h][HouseOwner], pNick(playerid), CASE_SENSETIVE))
	    {
     		tmpcount++;
		}
	}
	return tmpcount;
}
//==============================================================================
// GetHouseOwnerEx(houseid);
// This function is used to get the house owner of a house
// and return the playerid, it will return INVALID_PLAYER_ID
// if the house owner is not connected
//==============================================================================
stock GetHouseOwnerEx(houseid)
{
 	if(fexist(HouseFile(houseid)))
  	{
   		foreach(Character, i)
   		{
	    	if(!strcmp(pNick(i), hInfo[houseid][HouseOwner], CASE_SENSETIVE))
   			{
      			return i;
   			}
		}
	}
	return INVALID_PLAYER_ID;
}
//==============================================================================
// ReturnPlayerHouseID(playerid, houseslot);
// This function is used to return the house id from a players house 'slot'
// Example: ReturnPlayerHouseID(playerid, 0);
// Would return for example house ID 500.
//==============================================================================
stock ReturnPlayerHouseID(playerid, houseslot)
{
	new tmpcount;
	if(houseslot < 1 && houseslot > MAX_HOUSES_OWNED) return -1;
	foreach(Houses, h)
	{
	    if(!strcmp(pNick(playerid), hInfo[h][HouseOwner], CASE_SENSETIVE))
	    {
     		tmpcount++;
       		if(tmpcount == houseslot)
       		{
        		return h;
  			}
	    }
	}
	return -1;
}
//==============================================================================
// UnloadHouses();
// This function is used to unload the houses.
// It deletes all the checkpoints, map icons and 3D texts for all the houses.
//==============================================================================
stock UnloadHouses()
{
	foreach(Houses, h)
	{
		DestroyHouseEntrance(h, TYPE_OUT);
		DestroyHouseEntrance(h, TYPE_INT);
		#if GH_USE_MAPICONS == true
			DestroyDynamicMapIcon(HouseMIcon[h]);
		#endif
		DestroyDynamic3DTextLabel(HouseLabel[h]);
		#if GH_HOUSECARS == true
			UnloadHouseCar(h);
		#endif
	}
	Iter_Clear(Houses);
	return 1;
}
//==============================================================================
// IsHouseInRangeOfHouse(house, house2, Float:range);
// This function is used to check if a house is in range of another house
// Default range is 250.0
//==============================================================================
stock IsHouseInRangeOfHouse(house, house2, Float:range = 250.0)
{
	if(fexist(HouseFile(house)) && fexist(HouseFile(house2)))
	{
		if(PointInRangeOfPoint(range, hInfo[house][CPOutX], hInfo[house][CPOutY], hInfo[house][CPOutZ], hInfo[house2][CPOutX], hInfo[house2][CPOutY], hInfo[house2][CPOutZ]))
		{
		    return 1;
		}
	}
	return 0;
}
//==============================================================================
// CreateCorrectHouseExitCP(houseid);
// This function is used to create the correct house exit checkpoint for the houseid
// based on the house interior ID
//==============================================================================
stock CreateCorrectHouseExitCP(houseid)
{
    new _int = hInfo[houseid][HouseInterior];
    #if GH_USE_CPS == true
		HouseCPInt[houseid] = CreateDynamicCP(hIntInfo[_int][IntCPX], hIntInfo[_int][IntCPY], hIntInfo[_int][IntCPZ], 1.5, (houseid + 1000), hIntInfo[_int][IntInterior], -1, 15.0);
	#else
		HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, hIntInfo[_int][IntCPX], hIntInfo[_int][IntCPY], hIntInfo[_int][IntCPZ], (houseid + 1000), hIntInfo[_int][IntInterior], -1, 15.0);
	#endif
	return 1;
}
//==============================================================================
// SetPlayerHouseInterior(playerid, house);
// This function is used to set the correct house interior for a player when he enters a house or buy a new house interior.
//==============================================================================
stock SetPlayerHouseInterior(playerid, houseid)
{
    new _int = hInfo[houseid][HouseInterior];
	SetPVarInt(playerid, "IsInHouse", 1), IsInHouse{playerid} = 1;
	SetPlayerPosEx(playerid, hIntInfo[_int][IntSpawnX], hIntInfo[_int][IntSpawnY], hIntInfo[_int][IntSpawnZ], hIntInfo[_int][IntInterior], (houseid + 1000));
	SetPlayerFacingAngle(playerid, hIntInfo[_int][IntSpawnAngle]);
}
//==============================================================================
// pNick(playerid);
// Used to get the name of a player.
//==============================================================================
stock pNick(playerid)
{
	new GHNick[MAX_PLAYER_NAME];
	GetPlayerName(playerid, GHNick, MAX_PLAYER_NAME);
 	return GHNick;
}
//==============================================================================
// PointInRangeOfPoint(Float:range, Float:x2, Float:y2, Float:z2, Float:X2, Float:Y2, Float:Z2);
// Used to check if a point is in range of another point.
// Credits to whoever made this!
//==============================================================================
stock PointInRangeOfPoint(Float:range, Float:x2, Float:y2, Float:z2, Float:X2, Float:Y2, Float:Z2)
{
    X2 -= x2, Y2 -= y2, Z2 -= z2;
    return ((X2 * X2) + (Y2 * Y2) + (Z2 * Z2)) < (range * range);
}
//==============================================================================
// ReturnProcent(Float:amount, Float:procent);
// Used to return the procent of an value.
//==============================================================================
stock ReturnProcent(Float:amount, Float:procent) return floatround(((amount / 100) * procent));
//==============================================================================
// SetPlayerPosEx(playerid, Float:posX, Float:posY, Float:posZ, Interior = 0, World = 0);
// Used to set the position of a player with optional interiorid and worldid parameters
//==============================================================================
stock SetPlayerPosEx(playerid, Float:posX, Float:posY, Float:posZ, Interior = 0, World = 0)
{
	SetPlayerVirtualWorld(playerid, World), SetPlayerInterior(playerid, Interior), SetPlayerPos(playerid, posX, posY, posZ), SetCameraBehindPlayer(playerid);
	return 1;
}
stock SetPlayerPosDuel(playerid, Float:posX, Float:posY, Float:posZ, World = 0)
{
	SetPlayerVirtualWorld(playerid, World), SetPlayerPos(playerid, posX, posY, posZ), SetCameraBehindPlayer(playerid);
	return 1;
}
//==============================================================================
// GetFreeHouseID();
// Used to get the next free house ID. Will return -1 if there is none free.
//==============================================================================
stock GetFreeHouseID()
{
    Loop(h, MAX_HOUSES, 0)
    {
        if(!fexist(HouseFile(h)))
        {
            return h;
		}
	}
    return -1;
}
//==============================================================================
// GetFreeInteriorID();
// Used to get the next free house interior ID. Will return -1 if there is none free.
//==============================================================================
stock GetFreeInteriorID()
{
	new filename[INTERIORFILE_LENGTH];
    Loop(hint, MAX_HOUSE_INTERIORS, 0)
    {
        format(filename, sizeof(filename), HINT_FILEPATH, hint);
        if(!fexist(filename))
        {
            return hint;
		}
	}
    return -1;
}
//==============================================================================
// GetTotalHouses();
// Used to get the amount of existing houses.
//==============================================================================
stock GetTotalHouses() return Iter_Count(Houses);
//==============================================================================
// IsHouseInteriorValid(houseinterior);
// Used to check if a house interior does exist.
//==============================================================================
stock IsHouseInteriorValid(houseinterior)
{
	new filename[INTERIORFILE_LENGTH];
	format(filename, sizeof(filename), HINT_FILEPATH, houseinterior);
	return fexist(filename);
}
//==============================================================================
// UpdateHouseText();
// Updates the 3D text label.
//==============================================================================
stock UpdateHouseText(houseid)
{
	new labeltext[250];
	if(fexist(HouseFile(houseid)))
	{
	    switch(strcmp(INVALID_HOWNER_NAME, hInfo[houseid][HouseOwner], CASE_SENSETIVE))
	    {
	        case 0: format(labeltext, sizeof(labeltext), LABELTEXT1, hInfo[houseid][HouseName], hInfo[houseid][HouseValue], houseid);
	        case 1: format(labeltext, sizeof(labeltext), LABELTEXT2, hInfo[houseid][HouseName], hInfo[houseid][HouseOwner], hInfo[houseid][HouseValue], YesNo(hInfo[houseid][ForSale]), Answer(hInfo[houseid][HousePrivacy], "Open", "Closed"), houseid);
	    }
		UpdateDynamic3DTextLabelText(HouseLabel[houseid], COLOUR_GREEN, labeltext);
    }
}
//==============================================================================
// AddS(amount);
//==============================================================================
stock AddS(amount)
{
	new returnstring[2];
	format(returnstring, 2, "");
	if(amount != 1 && amount != -1)
	{
	    format(returnstring, 2, "s");
	}
	return returnstring;
}
//==============================================================================
// GetSecondsBetweenAction(action);
//==============================================================================
stock GetSecondsBetweenAction(action) return floatround(floatdiv((GetTickCount() - action), 1000), floatround_tozero);
//==============================================================================
// DestroyHouseEntrance(houseid, type);
// Destroys the house entrance of a house (pickup or checkpoint).
// Type can be: TYPE_OUT (0) and TYPE_INT (1)
//==============================================================================
stock DestroyHouseEntrance(houseid, type)
{
	#if GH_USE_CPS == true
		if(type == TYPE_OUT) { DestroyDynamicCP(HouseCPOut[houseid]); }
		if(type == TYPE_INT) { DestroyDynamicCP(HouseCPInt[houseid]); }
	#else
		if(type == TYPE_OUT) { DestroyDynamicPickup(HousePickupOut[houseid]); }
		if(type == TYPE_INT) { DestroyDynamicPickup(HousePickupInt[houseid]); }
	#endif
	return 1;
}
//==============================================================================
// IsVehicleOccupied(vehicleid);
// Checks if a vehicle is occupied or not.
//==============================================================================
stock IsVehicleOccupied(vehicleid)
{
  	foreach(Player, i)
	{
		if(IsPlayerInVehicle(i, vehicleid))
		{
			return 1;
		}
	}
	return 0;
}

// ******************************************************************************************************************************
// Dialog-responses
// ******************************************************************************************************************************

// This dialog processes the chosen business-type and creates the business
Dialog_CreateBusSelType(playerid, response, listitem)
{
	// Just close the dialog if the player clicked "Cancel"
	if(!response) return 1;

    // Setup some local variables
	new BusType, BusID, Float:x, Float:y, Float:z, Msg[128], bool:EmptySlotFound = false;

	// Get the player's position
	GetPlayerPos(playerid, x, y, z);

	// Get the business-type from the option the player chose
	BusType = listitem + 1;

	// Find a free business-id
	for (BusID = 1; BusID < MAX_BUSINESS; BusID++)
	{
		// Check if this business ID is free
		if (ABusinessData[BusID][BusinessType] == 0)
		{
			EmptySlotFound = true;
		    break; // Stop processing
		}
	}

	// Check if an empty slot has been found
	if (EmptySlotFound == false)
	{
		// If no empty slot was found, let the player know about it and exit the function
		SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}Maximum number of businesses reached");
		return 1;
	}

	// Set some default data at the index of NextFreeBusinessID (NextFreeBusinessID will point to the next free business-index)
	ABusinessData[BusID][BusinessX] = x;
	ABusinessData[BusID][BusinessY] = y;
	ABusinessData[BusID][BusinessZ] = z;
	ABusinessData[BusID][BusinessType] = BusType;
	ABusinessData[BusID][BusinessLevel] = 1;
	ABusinessData[BusID][Owned] = false;

	// Add the pickup and 3DText at the location of the business-entrance (where the player is standing when he creates the business)
	Business_CreateEntrance(BusID);

	// Save the business
	BusinessFile_Save(BusID);

	// Inform the player that he created a new house
	format(Msg, 128, "{00FF00}You've succesfully created business {FFFF00}%i{00FF00}", BusID);
	SendClientMessage(playerid, 0xFFFFFFFF, Msg);

	return 1;
}

// This function processes the businessmenu dialog
Dialog_BusinessMenu(playerid, response, listitem)
{
	// Just close the dialog if the player clicked "Cancel"
	if(!response) return 1;

	// Setup local variables
	new BusID, BusType, Msg[128], DialogTitle[200], UpgradePrice;

	// Get the HouseID of the house where the player is
	BusID = APlayerData[playerid][CurrentBusiness];
	BusType = ABusinessData[BusID][BusinessType];

	// Select an option based on the selection in the list
	switch(listitem)
	{
	    case 0: // Change business name
	    {
	        format(DialogTitle, 200, "Old business-name: %s", ABusinessData[BusID][BusinessName]);
			ShowPlayerDialog(playerid, DialogBusinessNameChange, DIALOG_STYLE_INPUT, DialogTitle, "Enter a new name for your business", "OK", "Cancel");
	    }
	    case 1: // Upgrade the business
	    {
	        // Check if it's possible to upgrade further
			if (ABusinessData[BusID][BusinessLevel] < 10)
			{
			    // Get the upgrade-price
			    UpgradePrice = ABusinessInteriors[BusType][BusPrice];
			    // Check if the player can afford the upgrade
				if (GetPlayerMoneyEx(playerid) >= UpgradePrice)
				{
				    // Give the current earnings of the business to the player and update the LastTransaction time
					Business_PayEarnings(playerid, BusID);
					// Upgrade the business 1 level
				    ABusinessData[BusID][BusinessLevel]++;
					// Let the player pay for the upgrade
					GivePlayerMoneyEx(playerid, -UpgradePrice);
					// Update the 3DText near the business's entrance to show what level the business is
					Business_UpdateEntrance(BusID);
					// Let the player know about it
					format(Msg, 128, "{00FF00}You have upgraded your business to level {FFFF00}%i", ABusinessData[BusID][BusinessLevel]);
					SendClientMessage(playerid, 0xFFFFFFFF, Msg);
				}
				else
					SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}You cannot afford the upgrade");
			}
			else
			    SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}Your business has reached the maximum level, you cannot upgrade it further");
	    }
		case 2: // Retrieve business earnings
		{
		    // Give the current earnings of the business to the player and update the LastTransaction time
			Business_PayEarnings(playerid, BusID);
		}
		case 3: // Sell business
		{
		    format(Msg, 128, "Are you sure you want to sell your business for $%i?", (ABusinessInteriors[BusType][BusPrice] * ABusinessData[BusID][BusinessLevel]) / 2);
			ShowPlayerDialog(playerid, DialogSellBusiness, DIALOG_STYLE_MSGBOX, "Are you sure?", Msg, "Yes", "No");
		}
	    case 4: // Exit the business
	    {
			Business_Exit(playerid, BusID);
	    }
	}

	return 1;
}

// Let the player change the name of his business
Dialog_ChangeBusinessName(playerid, response, inputtext[])
{
	// Just close the dialog if the player clicked "Cancel" or if the player didn't input any text
	if ((!response) || (strlen(inputtext) == 0)) return 1;

	// Change the name of the business
	format(ABusinessData[APlayerData[playerid][CurrentBusiness]][BusinessName], 100, inputtext);
	// Also update the 3DText at the entrance of the business
	Business_UpdateEntrance(APlayerData[playerid][CurrentBusiness]);
	// Let the player know that the name of his business has been changed
	SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}You've changed the name of your business");

	// Save the business-file
	BusinessFile_Save(APlayerData[playerid][CurrentBusiness]);

	return 1;
}

// Sell the business
Dialog_SellBusiness(playerid, response)
{
	// Just close the dialog if the player clicked "Cancel"
	if(!response) return 1;

	// Get the BusinessID where the player is right now and the business-type
	new BusID = APlayerData[playerid][CurrentBusiness];
	new BusType = ABusinessData[BusID][BusinessType];

	// Set the player in the normal world again
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);
	// Set the position of the player at the entrance of his business
	SetPlayerPos(playerid, ABusinessData[BusID][BusinessX], ABusinessData[BusID][BusinessY], ABusinessData[BusID][BusinessZ]);

	// Also clear the tracking-variable to track in which business the player is
	APlayerData[playerid][CurrentBusiness] = 0;

	// Clear the owner of the business
	ABusinessData[BusID][Owned] = false;
	ABusinessData[BusID][Owner] = 0;
	// Clear the business-name and business-level
	ABusinessData[BusID][BusinessName] = 0;
	ABusinessData[BusID][BusinessLevel] = 1;

	// Refund the player 50% of the worth of the business
	GivePlayerMoneyEx(playerid, (ABusinessInteriors[BusType][BusPrice] * ABusinessData[BusID][BusinessLevel]) / 2);
	SendClientMessage(playerid, 0xFFFFFFFF, "{00FF00}You've sold your business");

	// Clear the business-id from the player
	for (new BusSlot; BusSlot < MAX_BUSINESSPERPLAYER; BusSlot++)
	{
		// If the business-slot if found where the business was added to the player
		if (APlayerData[playerid][Business][BusSlot] == BusID)
		{
		    // Clear the business-id
		    APlayerData[playerid][Business][BusSlot] = 0;
		    // Stop searching
		    break;
		}
	}

	// Update the 3DText near the business's entrance to show other players that it's for sale again
	Business_UpdateEntrance(BusID);

	// Also save the sold business, otherwise the old ownership-data is still there
	BusinessFile_Save(BusID);

	return 1;
}

// This function processes the /gobus dialog
Dialog_GoBusiness(playerid, response, listitem)
{
	// Just close the dialog if the player clicked "Cancel"
	if(!response) return 1;

	// Setup local variables
	new BusIndex, BusID;

	// The listitem directly indicates the business-index
	BusIndex = listitem;
	BusID = APlayerData[playerid][Business][BusIndex];

	// Check if this is a valid business (BusID != 0)
	if (BusID != 0)
	{
		// Get the coordinates of the business's entrance
		SetPlayerPos(playerid, ABusinessData[BusID][BusinessX], ABusinessData[BusID][BusinessY], ABusinessData[BusID][BusinessZ]);
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}You don't have a business in this business-slot");

	return 1;
}



// ******************************************************************************************************************************
// File functions
// ******************************************************************************************************************************

// This function loads the file that holds the current business-time
BusinessTime_Load()
{
	// Setup local variables
	new File:BFile, LineFromFile[100], ParameterName[50], ParameterValue[50];

	// Try to load the businesstime file
	if (fexist(BusinessTimeFile))
	{
		BFile = fopen(BusinessTimeFile, io_read); // Open the businesstime-file for reading

		fread(BFile, LineFromFile); // Read the first line of the file

		// Keep reading until the end of the file is found (no more data)
		while (strlen(LineFromFile) > 0)
		{
			StripNewLine(LineFromFile); // Strip any newline characters from the LineFromFile
			sscanf(LineFromFile, "s[50]s[50]", ParameterName, ParameterValue); // Extract parametername and parametervalue

			// Store the proper value in the proper place
			if (strcmp(ParameterName, "BusinessTime", false) == 0) // If the parametername is correct ("BusinessTime")
				BusinessTransactionTime = strval(ParameterValue); // Store the BusinessTime

            // Read the next line of the file
			fread(BFile, LineFromFile);
		}

        // Close the file
		fclose(BFile);

        // Return if the file was read correctly
		return 1;
	}
	else
	    return 0; // Return 0 if the file couldn't be read (doesn't exist)
}

// This function saves the file that holds the current business-time
BusinessTime_Save()
{
	// Setup local variables
	new File:BFile, LineForFile[100];

	BFile = fopen(BusinessTimeFile, io_write); // Open the businesstime-file for writing

	format(LineForFile, 100, "BusinessTime %i\r\n", BusinessTransactionTime); // Construct the line: "BusinessTime <BusinessTransactionTime>"
	fwrite(BFile, LineForFile); // And save it to the file

	fclose(BFile); // Close the file

	return 1;
}

// This function will load the business's datafile (used when the server is started to load all businesses)
BusinessFile_Load(BusID)
{
	// Setup local variables
	new file[100], File:BFile, LineFromFile[100], ParameterName[50], ParameterValue[50];

    // Construct the complete filename for this business-file
	format(file, sizeof(file), BusinessFile, BusID);

	// Check if the business-file exists
	if (fexist(file))
	{
	    // Open the businessfile for reading
		BFile = fopen(file, io_read);

        // Read the first line of the file
		fread(BFile, LineFromFile);

		// Keep reading until the end of the file is found (no more data)
		while (strlen(LineFromFile) > 0)
		{
			StripNewLine(LineFromFile); // Strip any newline characters from the LineFromFile
			sscanf(LineFromFile, "s[50]s[50]", ParameterName, ParameterValue); // Extract parametername and parametervalue

			// Check if there is anything in the LineFromFile (skipping empty lines)
			if (strlen(LineFromFile) > 0)
			{
				// Store the proper value in the proper place
				if (strcmp(ParameterName, "BusinessName", false) == 0) // If the parametername is correct ("BusinessName")
				    format(ABusinessData[BusID][BusinessName], 24, ParameterValue); // Store the BusinessName
				if (strcmp(ParameterName, "BusinessX", false) == 0) // If the parametername is correct ("BusinessX")
					ABusinessData[BusID][BusinessX] = floatstr(ParameterValue); // Store the BusinessX
				if (strcmp(ParameterName, "BusinessY", false) == 0) // If the parametername is correct ("BusinessY")
					ABusinessData[BusID][BusinessY] = floatstr(ParameterValue); // Store the BusinessY
				if (strcmp(ParameterName, "BusinessZ", false) == 0) // If the parametername is correct ("BusinessZ")
					ABusinessData[BusID][BusinessZ] = floatstr(ParameterValue); // Store the BusinessZ
				if (strcmp(ParameterName, "BusinessType", false) == 0) // If the parametername is correct ("BusinessType")
					ABusinessData[BusID][BusinessType] = strval(ParameterValue); // Store the BusinessType
				if (strcmp(ParameterName, "BusinessLevel", false) == 0) // If the parametername is correct ("BusinessLevel")
					ABusinessData[BusID][BusinessLevel] = strval(ParameterValue); // Store the BusinessLevel
				if (strcmp(ParameterName, "LastTransaction", false) == 0) // If the parametername is correct ("LastTransaction")
					ABusinessData[BusID][LastTransaction] = strval(ParameterValue); // Store the LastTransaction
				if (strcmp(ParameterName, "Owned", false) == 0) // If the parametername is correct ("Owned")
				{
				    if (strcmp(ParameterValue, "Yes", false) == 0) // If the value "Yes" was read
						ABusinessData[BusID][Owned] = true; // House is owned
					else
						ABusinessData[BusID][Owned] = false; // House is not owned
				}
				if (strcmp(ParameterName, "Owner", false) == 0) // If the parametername is correct ("Owner")
				    format(ABusinessData[BusID][Owner], 24, ParameterValue);
			}

            // Read the next line of the file
			fread(BFile, LineFromFile);
		}

        // Close the file
		fclose(BFile);

		// Create the business-entrance and set data
		Business_CreateEntrance(BusID);
		// Increase the amount of businesses loaded
		TotalBusiness++;

        // Return if the file was read correctly
		return 1;
	}
	else
	    return 0; // Return 0 if the file couldn't be read (doesn't exist)
}

// This function will save the given business
BusinessFile_Save(BusID)
{
	// Setup local variables
	new file[100], File:BFile, LineForFile[100];

    // Construct the complete filename for this business
	format(file, sizeof(file), BusinessFile, BusID);

    // Open the business-file for writing
	BFile = fopen(file, io_write);

	format(LineForFile, 100, "BusinessName %s\r\n", ABusinessData[BusID][BusinessName]); // Construct the line: "BusinessName <BusinessName>"
	fwrite(BFile, LineForFile); // And save it to the file
	format(LineForFile, 100, "BusinessX %f\r\n", ABusinessData[BusID][BusinessX]); // Construct the line: "BusinessX <BusinessX>"
	fwrite(BFile, LineForFile); // And save it to the file
	format(LineForFile, 100, "BusinessY %f\r\n", ABusinessData[BusID][BusinessY]); // Construct the line: "BusinessY <BusinessY>"
	fwrite(BFile, LineForFile); // And save it to the file
	format(LineForFile, 100, "BusinessZ %f\r\n", ABusinessData[BusID][BusinessZ]); // Construct the line: "BusinessZ <BusinessZ>"
	fwrite(BFile, LineForFile); // And save it to the file
	format(LineForFile, 100, "BusinessType %i\r\n", ABusinessData[BusID][BusinessType]); // Construct the line: "BusinessType <BusinessType>"
	fwrite(BFile, LineForFile); // And save it to the file
	format(LineForFile, 100, "BusinessLevel %i\r\n", ABusinessData[BusID][BusinessLevel]); // Construct the line: "BusinessLevel <BusinessLevel>"
	fwrite(BFile, LineForFile); // And save it to the file
	format(LineForFile, 100, "LastTransaction %i\r\n", ABusinessData[BusID][LastTransaction]); // Construct the line: "LastTransaction <LastTransaction>"
	fwrite(BFile, LineForFile); // And save it to the file

	if (ABusinessData[BusID][Owned] == true) // Check if the business is owned
	{
		format(LineForFile, 100, "Owned Yes\r\n"); // Construct the line: "Owned Yes"
		fwrite(BFile, LineForFile); // And save it to the file
	}
	else
	{
		format(LineForFile, 100, "Owned No\r\n"); // Construct the line: "Owned No"
		fwrite(BFile, LineForFile); // And save it to the file
	}

	format(LineForFile, 100, "Owner %s\r\n", ABusinessData[BusID][Owner]); // Construct the line: "Owner <Owner>"
	fwrite(BFile, LineForFile); // And save it to the file

	fclose(BFile); // Close the file

	return 1;
}



// ******************************************************************************************************************************
// Business functions
// ******************************************************************************************************************************

// This timer increases the variable "BusinessTransactionTime" every minute and saves the businesstime file
forward Business_TransactionTimer();
public Business_TransactionTimer()
{
	// Increase the variable by one
    BusinessTransactionTime++;

	// And save it to the file
	BusinessTime_Save();
}

// This function returns the first free business-slot for the given player
Player_GetFreeBusinessSlot(playerid)
{
	// Check if the player has room for another business (he hasn't bought the maximum amount of businesses per player yet)
	// and get the slot-id
	for (new BusIndex; BusIndex < MAX_BUSINESSPERPLAYER; BusIndex++) // Loop through all business-slots of the player
		if (APlayerData[playerid][Business][BusIndex] == 0) // Check if this business slot is free
		    return BusIndex; // Return the free BusIndex for this player

	// If there were no free business-slots, return "-1"
	return -1;
}

// This function sets ownership of the business to the given player
Business_SetOwner(playerid, BusID)
{
	// Setup local variables
	new BusSlotFree, PName[24], Msg[128], BusType;

	// Get the first free business-slot from this player
	BusSlotFree = Player_GetFreeBusinessSlot(playerid);

	// Check if the player has a free business-slot
	if (BusSlotFree != -1)
	{
		// Get the player's name
		GetPlayerName(playerid, PName, sizeof(PName));

		// Store the business-id for the player
		APlayerData[playerid][Business][BusSlotFree] = BusID;
		// Get the business-type
		BusType = ABusinessData[BusID][BusinessType];

		// Let the player pay for the business
		GivePlayerMoneyEx(playerid, -ABusinessInteriors[BusType][BusPrice]);

		// Set the business as owned
		ABusinessData[BusID][Owned] = true;
		// Store the owner-name for the business
		format(ABusinessData[BusID][Owner], 24, PName);
		// Set the level to 1
		ABusinessData[BusID][BusinessLevel] = 1;
		// Set the default business-name
		format(ABusinessData[BusID][BusinessName], 100, ABusinessInteriors[BusType][InteriorName]);
		// Store the current transaction-time (this is used so the player can only retrieve cash from the business from the moment he bought it)
		ABusinessData[BusID][LastTransaction] = BusinessTransactionTime;

		// Also, update 3DText of this business
		Business_UpdateEntrance(BusID);

		// Save the business-file
		BusinessFile_Save(BusID);

		// Let the player know he bought the business
		format(Msg, 128, "{00FF00}You've bought the business for {FFFF00}$%i", ABusinessInteriors[BusType][BusPrice]);
		SendClientMessage(playerid, 0xFFFFFFFF, Msg);
	}
	else
	    SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}You already own the maximum amount of allowed businesses per player");

	return 1;
}

// This function adds a pickup for the given business
Business_CreateEntrance(BusID)
{
	// Setup local variables
	new Msg[128], Float:x, Float:y, Float:z, BusType, Icon;

	// Get the coordinates of the house's pickup (usually near the door)
	x = ABusinessData[BusID][BusinessX];
	y = ABusinessData[BusID][BusinessY];
	z = ABusinessData[BusID][BusinessZ];
	// Get the business-type and icon
	BusType = ABusinessData[BusID][BusinessType];
	Icon = ABusinessInteriors[BusType][IconID];

	// Add a dollar-sign to indicate this business
	ABusinessData[BusID][PickupID] = CreateDynamicPickup(1274, 1, x, y, z, 0);
	// Add a map-icon depending on which type the business is
	ABusinessData[BusID][MapIconID] = CreateDynamicMapIcon(x, y, z, Icon, 0, 0, 0, -1, 250.0);

	// Add a new 3DText at the business's location (usually near the door)
	if (ABusinessData[BusID][Owned] == true)
	{
		// Create the 3DText that appears above the business-pickup (displays the businessname, the name of the owner and the current level)
		format(Msg, 128, "%s\nOwned by: %s\nBusiness-level: %i\n/enter", ABusinessData[BusID][BusinessName], ABusinessData[BusID][Owner], ABusinessData[BusID][BusinessLevel]);
		ABusinessData[BusID][DoorText] = CreateDynamic3DTextLabel(Msg, 0x008080FF, x, y, z + 1.0, 50.0);
	}
	else
	{
		// Create the 3DText that appears above the business-pickup (displays the price of the business and the earnings)
		format(Msg, 128, "%s\nAvailable for\n$%i\nEarnings: $%i\n/buybus", ABusinessInteriors[BusType][InteriorName], ABusinessInteriors[BusType][BusPrice], ABusinessInteriors[BusType][BusEarnings]);
		ABusinessData[BusID][DoorText] = CreateDynamic3DTextLabel(Msg, 0x008080FF, x, y, z + 1.0, 50.0);
	}
}

// This function changes the 3DText for the given business (used when buying or selling a business)
Business_UpdateEntrance(BusID)
{
	// Setup local variables
	new Msg[128], BusType;

	// Get the business-type
	BusType = ABusinessData[BusID][BusinessType];

	// Update the 3DText at the business's location (usually near the door)
	if (ABusinessData[BusID][Owned] == true)
	{
		// Create the 3DText that appears above the business-pickup (displays the businessname, the name of the owner and the current level)
		format(Msg, 128, "%s\nOwned by: %s\nBusiness-level: %i\n/enter", ABusinessData[BusID][BusinessName], ABusinessData[BusID][Owner], ABusinessData[BusID][BusinessLevel]);
		UpdateDynamic3DTextLabelText(ABusinessData[BusID][DoorText], 0x008080FF, Msg);
	}
	else
	{
		// Create the 3DText that appears above the business-pickup (displays the price of the business and the earnings)
		format(Msg, 128, "%s\nAvailable for\n$%i\nEarnings: $%i\n/buybus", ABusinessInteriors[BusType][InteriorName], ABusinessInteriors[BusType][BusPrice], ABusinessInteriors[BusType][BusEarnings]);
		UpdateDynamic3DTextLabelText(ABusinessData[BusID][DoorText], 0x008080FF, Msg);
	}
}

// This function pays the current earnings of the given business to the player
Business_PayEarnings(playerid, BusID)
{
	// Setup local variables
	new Msg[128];

	// Get the business-type
	new BusType = ABusinessData[BusID][BusinessType];

	// Calculate the earnings of the business since the last transaction
	// This is calculated by the number of minutes between the current business-time and last business-time, multiplied by the earnings-per-minute and business-level
	new Earnings = (BusinessTransactionTime - ABusinessData[BusID][LastTransaction]) * ABusinessInteriors[BusType][BusEarnings] * ABusinessData[BusID][BusinessLevel];
	// Reset the last transaction time to the current time
	ABusinessData[BusID][LastTransaction] = BusinessTransactionTime;
	// Reward the player with his earnings
	GivePlayerMoneyEx(playerid, Earnings);
	// Inform the player that he has earned money from his business
	format(Msg, 128, "{00FF00}Your business has earned {FFFF00}$%i{00FF00} since your last withdrawl", Earnings);
	SendClientMessage(playerid, 0xFFFFFFFF, Msg);
}

// This function is used to spawn back at the entrance of your business
Business_Exit(playerid, BusID)
{
	// Set the player in the normal world again
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);
	// Set the position of the player at the entrance of his business
    SetPlayerPosition(playerid, 374.7578,2536.7205,16.5790,135.2049);
	//SetPlayerPos(playerid, ABusinessData[BusID][BusinessX], ABusinessData[BusID][BusinessY], ABusinessData[BusID][BusinessZ]);
	// Also clear the tracking-variable to track in which business the player is
	APlayerData[playerid][CurrentBusiness] = 0;

	// Check if there is a timer-value set for exiting the business (this timer freezes the player while the environment is being loaded)
	if (ExitBusinessTimer > 0)
	{
		// Don't allow the player to fall
	    TogglePlayerControllable(playerid, 0);
		// Let the player know he's frozen while the environment loads
		GameTextForPlayer(playerid, "Waiting for the environment to load", ExitBusinessTimer, 4);
		// Start a timer that will allow the player to fall again when the environment has loaded
		SetTimerEx("Business_ExitTimer", ExitBusinessTimer, false, "ii", playerid, BusID);
	}

	return 1;
}

forward Business_ExitTimer(playerid, BusID);
public Business_ExitTimer(playerid, BusID)
{
	// Allow the player to move again (environment should have been loaded now)
    TogglePlayerControllable(playerid, 1);

	return 1;
}



// ******************************************************************************************************************************
// Support functions
// ******************************************************************************************************************************


// ******************************************************************************************************************************
// Special functions that try to access external public functions to retreive or set data from another script
// ******************************************************************************************************************************

// This function is used to get the player's money
// INT_GetPlayerMoneyEx(playerid)
// {
// 	// Setup local variables
// 	new Money;

// 	// Try to call the external function to get the player's money (used to get the serversided money for this player)
// 	Money = CallRemoteFunction("GetPlayerMoneyEx(playerid)", "i", playerid);

// 	// The external function returned "0" (as the player doesn't have any money yet), or the function is not used in another script
// 	if (Money == 0)
// 		return GetPlayerMoneyEx(playerid); // Return the normal money of the player
// 	else
// 		return Money; // Return the money that was returned by the external function
// }

// // This function is used to set the player's money
// INT_GivePlayerMoneyEx(playerid, Money)
// {
// 	// Setup local variables
// 	new Success;

// 	// Try to call the external function to get the player's money (used to get the serversided money for this player)
// 	Success = CallRemoteFunction("GetPlayerMoneyEx(playerid)", "ii", playerid, Money);

// 	// The external function returned "0" as the function is not used in another script
// 	if (Success == 0)
// 		GivePlayerMoneyEx(playerid, Money); // Use the normal money (client-sided money)
// }

// This function checks if the admin-level of a player is sufficient
INT_CheckPlayerAdminLevel(playerid, AdminLevel)
{
	// Setup local variables
	new Level;

	// Check if the player is an RCON admin
	if (IsPlayerAdmin(playerid))
	    return 1; // Return 1 to indicate this player has a sufficient admin-level to use a command

	// If the player is not an RCON admin, try to get his admin-level from an external script using a remote function
	//Level = CallRemoteFunction("PlayerInfo[playerid][Level]", "i", playerid);
    Level = GetPVarInt(playerid, "Level");
	// Check if the player has a sufficient admin-level
	if (Level >= AdminLevel)
	    return 1; // Return 1 to indicate this player has a sufficient admin-level
	else
		return 0; // Return 0 to indicate this player has an insufficient admin-level
}

IsPlayerSeniorAdmin(playerid, AdminLevel)
{
	new Level;
	if (IsPlayerAdmin(playerid))
	    return 1;
    Level = GetPVarInt(playerid, "Level");
	if (Level >= AdminLevel)
	    return 1;
	else
		return 0;
}

IsPlayerHeadAdmin(playerid, AdminLevel)
{
	new Level;
	if (IsPlayerAdmin(playerid))
	    return 1;
    Level = GetPVarInt(playerid, "Level");
	if (Level >= AdminLevel)
	    return 1;
	else
		return 0;
}

// This function checks if the player has logged in properly by entering his password
INT_IsPlayerSpawned(playerid)
{
	// Setup local variables
	new PSpawned;

	// Try to determine if the player logged in properly by entering his password in another script
	PSpawned = CallRemoteFunction("PlayerInfo[playerid][Spawned]", "i", playerid);

	// Check if the player has logged in properly
	switch (PSpawned)
	{
		case 0: return 1; // No admin script present that holds the LoggedIn status of a player, so allow a command to be used
		case 1: return 1; // The player logged in properly by entering his password, allow commands to be used
		case -1: return 0; // There is an admin script present, but the player hasn't entered his password yet, so block all commands
							// This prevents executing the commands using F6 during login with an admin-account before entering a password
	}

	// In any other case, block all commands
	return 0;
}

// This function tries to cetermine if the player is in jail
INT_IsPlayerJailed(playerid)
{
	// Setup local variables
	new pJailed;

	// Try to determine if the player is jailed
	pJailed = CallRemoteFunction("PlayerInfo[playerid][Jailed]", "i", playerid);

	// Check if the player is jailed
	switch (pJailed)
	{
		case 0: return 0; // No admin script present, so there is no jail either, player cannot be jailed in this case
		case 1: return 1; // The player is jailed, so return "1"
		case -1: return 0; // There is an admin script present, but the player isn't jailed
	}

	// In any other case, return "0" (player not jailed)
	return 0;
}



// ******************************************************************************************************************************
// External functions to be used from within other filterscripts or gamemode (these aren't called anywhere inside this script)
// These functions can be called from other filterscripts or the gamemode to get data from the housing filterscript
// ******************************************************************************************************************************



// ******************************************************************************************************************************
// Functions that need to be placed in the gamemode or filterscript which holds the playerdata
// Only needed when the server uses server-sided money, otherwise the normal money is used
// ******************************************************************************************************************************

/*
// This function is used to get the player's money
forward Admin_GetPlayerMoneyEx(playerid);
public Admin_GetPlayerMoneyEx(playerid)
{
	return APlayerData[playerid][PlayerMoney];
}

// This function is used to get the player's money
forward Admin_GivePlayerMoneyEx(playerid, Money);
public Admin_GivePlayerMoneyEx(playerid, Money)
{
	// Add the given money to the player's account
	APlayerData[playerid][PlayerMoney] = APlayerData[playerid][PlayerMoney] + Money;

	// Return that the function had success
	return 1;
}

// This function is used to get the player's admin-level
forward Admin_GetPlayerAdminLevel(playerid);
public Admin_GetPlayerAdminLevel(playerid)
{
	return APlayerData[playerid][AdminLevel];
}

// This function is used to determine if the player has logged in (he succesfully entered his password)
forward Admin_IsPlayerLoggedIn(playerid);
public Admin_IsPlayerLoggedIn(playerid)
{
	if (APlayerData[playerid][LoggedIn] == true)
	    return 1; // The player has logged in succesfully
	else
	    return -1; // The player hasn't logged in (yet)
}

// This function is used to determine if a player is jailed
forward Admin_IsPlayerJailed(playerid);
public Admin_IsPlayerJailed(playerid)
{
	// Check if a player has jaimtime left
	if (APlayerData[playerid][PlayerJailed] == true)
	    return 1; // The player is still jailed
	else
	    return -1; // The player is not jailed
}
*/

//==============================================================================
stock CountPlayersInHouse(houseid)
{
	new count;
	foreach(Player, i)
	{
	    if(!IsPlayerInHouse(i, houseid)) continue;
		count++;
	}
	return count;
}
stock ShowInfoBoxEx(playerid, colour, message[])
{
	new HugeAssString[1000];
	format(HugeAssString, sizeof(HugeAssString), "{%06x}%s", (colour >>> 8), message);
	return ShowPlayerDialog(playerid, (HOUSEMENU-1), DIALOG_STYLE_MSGBOX, INFORMATION_HEADER, HugeAssString, "Close", "");
}
stock DeletePVars(playerid)
{
	DeletePVar(playerid, "LastHouseCP"), DeletePVar(playerid, "IsInHouse"), DeletePVar(playerid, "FirstSpawn");
	DeletePVar(playerid, "GA_TMP_HOUSESTORAGE"), DeletePVar(playerid, "GA_TMP_NEWHOUSEOWNER"), DeletePVar(playerid, "GA_TMP_HOUSEFORSALEPRICE"), DeletePVar(playerid, "GA_TMP_HOUSENAME");
	DeletePVar(playerid, "JustCreatedHouse"), DeletePVar(playerid, "HousePreview"), DeletePVar(playerid, "HousePrevValue"), DeletePVar(playerid, "HousePrevName");
	DeletePVar(playerid, "HousePrevInt"), DeletePVar(playerid, "HouseIntUpgradeMod"), DeletePVar(playerid, "IsHouseVisiting"), DeletePVar(playerid, "ChangeHouseInt");
	DeletePVar(playerid, "HousePrevTime"), DeletePVar(playerid, "HousePrevTimer"), DeletePVar(playerid, "OldHouseInt"), DeletePVar(playerid, "ClickedHouse");
	DeletePVar(playerid, "ClickedPlayer"), DeletePVar(playerid, "TimeSinceHouseBreakin");
	DeletePVar(playerid, "IsRobbingHouse"), DeletePVar(playerid, "HouseRobberyTime"), DeletePVar(playerid, "HouseRobberyTimer"), DeletePVar(playerid, "TimeSinceHouseRobbery");
	return 1;
}
stock fcreate(filename[])
{
    if(fexist(filename)) return 0;
    new File:file = fopen(filename, io_write);
    fclose(file);
    return 1;
}
stock RandomEx(min, max) return (random((max - min)) + min);
stock ExitHouse(playerid, houseid)
{
    if(!IsPlayerInHouse(playerid, houseid)) return 1;
	DeletePVar(playerid, "IsInHouse");
	IsInHouse{playerid} = 0;
 	SetPlayerPosEx(playerid, hInfo[houseid][SpawnOutX], hInfo[houseid][SpawnOutY], hInfo[houseid][SpawnOutZ], hInfo[houseid][SpawnInterior], hInfo[houseid][SpawnWorld]);
  	SetPlayerFacingAngle(playerid, hInfo[houseid][SpawnOutAngle]);
	SetPlayerInterior(playerid, hInfo[houseid][SpawnInterior]);
	SetPlayerVirtualWorld(playerid, hInfo[houseid][SpawnWorld]);
	if(GetPVarInt(playerid, "IsRobbingHouse") == 1)
	{
	    ShowInfoBox(playerid, I_HROB_FAILED_HEXIT, hInfo[houseid][HouseName]);
		EndHouseRobbery(playerid);
		SetPVarInt(playerid, "IsRobbingHouse", 0);
		SetPVarInt(playerid, "TimeSinceHouseRobbery", GetTickCount());
	}
	SetPlayerPos(playerid, hInfo[houseid][SpawnOutX], hInfo[houseid][SpawnOutY], hInfo[houseid][SpawnOutZ]);
    return 1;
}


stock GetHouseLocation(houseid)
{
	new zone[MAX_ZONE_NAME];
    format(zone, MAX_ZONE_NAME, "Unknown");
	new size = sizeof(gSAZones);
    Loop(i, size, 0)
 	{
		if(hInfo[houseid][CPOutX] >= gSAZones[i][SAZONE_AREA][0] && hInfo[houseid][CPOutX] <= gSAZones[i][SAZONE_AREA][3] && hInfo[houseid][CPOutY] >= gSAZones[i][SAZONE_AREA][1] && hInfo[houseid][CPOutY] <= gSAZones[i][SAZONE_AREA][4])
		{
		    format(zone, MAX_ZONE_NAME, "%s", gSAZones[i][SAZONE_NAME]);
		    return zone;
		}
	}
	return zone;
}
stock HouseFile(houseid)
{
    new filename[HOUSEFILE_LENGTH];
	format(filename, sizeof(filename), FILEPATH, houseid);
	return filename;
}
stock EndHouseRobbery(playerid)
{
	new timer_state = GetPVarInt(playerid, "HouseRobberyTimer");
	if(timer_state != -1)
	{
	    KillTimer(timer_state);
    	SetPVarInt(playerid, "HouseRobberyTimer", -1);
    }
    return 1;
}
stock SecurityDog_Bite(playerid, houseid, type, failed = 0)
{
	if(hInfo[houseid][HouseDog] == 0) return 1;
    new Float:health;
	GetPlayerHealth(playerid, health);
 	ApplyAnimation(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0);
	if((health - (SECURITYDOG_HEALTHLOSS * SECURITYDOG_BITS)) <= 0.00)
	{
 		SetPlayerHealth(playerid, 0.00);
 		switch(type)
 		{
 		    case 0: ShowInfoBoxEx(playerid, COLOUR_SYSTEM, HBREAKIN_FAILED1);
 		    case 1: ShowInfoBoxEx(playerid, COLOUR_SYSTEM, HROB_FAILED1);
 		}
	}
	else
	{
		SetPlayerHealth(playerid, (health - (SECURITYDOG_HEALTHLOSS * SECURITYDOG_BITS)));
		if(failed == 1)
		{
			switch(type)
	 		{
	 		    case 0: ShowInfoBoxEx(playerid, COLOUR_SYSTEM, HBREAKIN_FAILED2);
	 		    case 1: ShowInfoBoxEx(playerid, COLOUR_SYSTEM, HROB_FAILED2);
	 		}
 		}
	}
	SetTimerEx("SecurityDog_ClearAnimations", 4000, false, "i", playerid);
	return 1;
}

forward countdown2(playerid);
public countdown2(playerid)
{
	if(PlayerInfo[playerid][inDerby] == 1)
	{
	if(CountDown2==6) GameTextForAll("~p~Starting...",1000,6);
	CountDown2--;
	if(CountDown2==0)
	{
		GameTextForAll("~g~GO~ r~!",1000,6);
		CountDown2 = -1;
		for(new i = 0; i < MAX_PLAYERS; i++) {
		TogglePlayerControllable(i,true);
		PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
	}
 return 0;
 }
 else
	{
	new text[7]; format(text,sizeof(text),"~w~%d",CountDown2);
		for(new i = 0; i < MAX_PLAYERS; i++) {
		PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
		TogglePlayerControllable(i,false);
	}
	 	GameTextForAll(text,1000,6);
	}
	SetTimer("countdown2",1000,0);}
 return 0;
}

stock LoadVehicles ()
{
    AddStaticVehicle(411,-2348.5037,-1605.7897,483.3605,82.5078,1,1); //
	AddStaticVehicle(411,-2349.0491,-1610.4980,483.3622,81.0437,1,1); //
	AddStaticVehicle(411,-2350.4988,-1614.7374,483.3669,79.0752,1,1); //
	AddStaticVehicle(411,-2352.5586,-1622.2357,483.3889,82.2072,1,1); //
	AddStaticVehicle(411,-2335.3547,-1668.6112,483.0665,150.1298,1,1); //
	AddStaticVehicle(411,-2330.5781,-1672.9398,482.7299,138.8729,1,1); //
	AddStaticVehicle(411,-2325.9729,-1677.0616,482.4081,137.9660,1,1); //
	AddStaticVehicle(411,2162.0791,1649.9126,10.7848,100.1843,1,1); //
	AddStaticVehicle(411,2161.8289,1721.7010,10.7740,349.9766,1,1); //
	AddStaticVehicle(411,2165.4277,1720.4248,10.7740,357.0558,1,1); //
	AddStaticVehicle(411,2171.2129,1718.2517,10.7739,357.8798,1,1); //
	AddStaticVehicle(411,2176.6816,1717.1438,10.7740,358.7744,1,1); //
	AddStaticVehicle(411,-2665.2886,1356.4253,16.7206,358.1078,1,1); //
	AddStaticVehicle(411,-2639.4241,1321.3419,6.8117,87.7507,1,1); //
	AddStaticVehicle(411,-2629.8745,1378.8746,6.8740,88.4510,1,1); //
	AddStaticVehicle(411,-2618.3220,1420.6678,6.8299,33.6315,1,1); //
	AddStaticVehicle(411,2117.9343,-2631.0557,13.2740,246.2821,1,1); //
	AddStaticVehicle(411,2127.4604,-2622.3601,13.2739,238.9867,1,1); //
	AddStaticVehicle(411,2131.2891,-2616.1350,13.2740,242.7475,1,1); //
	AddStaticVehicle(411,2137.3330,-2607.5261,13.2739,250.4322,1,1); //
	AddStaticVehicle(411,2137.9944,-2601.4241,13.2740,257.2216,1,1); //
	AddStaticVehicle(411,2141.2012,-2596.3604,13.2740,257.6929,1,1); //
	AddStaticVehicle(411,2142.5383,-2590.5918,13.2740,259.4824,1,1); //
	AddStaticVehicle(411,2142.6450,-2583.6426,13.2739,272.7259,1,1); //
	AddStaticVehicle(411,-1028.2369,-1062.0933,128.9458,178.9816,1,1); //
	AddStaticVehicle(411,-1034.5754,-1062.4038,128.9461,174.4150,1,1); //
	AddStaticVehicle(411,-1041.1921,-1062.6250,128.9459,173.4306,1,1); //
	AddStaticVehicle(411,-1049.1938,-1063.2117,128.9462,177.4409,1,1); //
	AddStaticVehicle(411,-1056.3866,-1063.3406,128.9458,174.1456,1,1); //
	AddStaticVehicle(411,-1067.5880,-1062.7148,128.9443,173.7557,1,1); //
	AddStaticVehicle(411,328.1940,-3645.5251,14.7280,270.1585,1,1); //
	AddStaticVehicle(411,328.6585,-3634.5627,14.7282,269.6136,1,1); //
	AddStaticVehicle(411,330.0636,-3624.0342,14.7317,270.6463,1,1); //
	AddStaticVehicle(411,327.1230,-3656.0015,14.7280,271.2598,1,1); //
	AddStaticVehicle(411,328.3892,-3664.5378,14.7319,271.2305,1,1); //
	AddStaticVehicle(411,329.6557,-3677.9128,14.7280,271.6176,1,1); //
	AddStaticVehicle(411,330.5539,-3686.1257,14.7322,268.7094,1,1); //
	AddStaticVehicle(411,331.3021,-3729.0481,14.7305,263.7224,1,1); //
	AddStaticVehicle(411,330.2269,-3739.9829,14.7282,277.6119,1,1); //
	AddStaticVehicle(411,329.9801,-3748.9719,14.7319,268.4159,1,1); //
	AddStaticVehicle(411,329.6761,-3759.5212,14.7300,276.2368,1,1); //
	AddStaticVehicle(411,339.7471,2544.4775,16.5169,1.5793,1,1); //
	AddStaticVehicle(411,345.8095,2544.6711,16.4873,358.5893,1,1); //
	AddStaticVehicle(411,351.7680,2542.7297,16.4556,358.8443,1,1); //
	AddStaticVehicle(411,357.1403,2543.8193,16.3940,0.6054,1,1); //
	AddStaticVehicle(411,363.0127,2544.3230,16.3080,357.6707,1,1); //
	AddStaticVehicle(411,375.8907,2553.7290,16.2172,185.0546,1,1); //
	return 1;
}


stock robplayer(robber,robbed)
{
	if(IsPlayerInRangeOfPoint(robber, 75, 1323.8813,2673.1052,11.2392)) return SendClientMessage(robber, COLOR_RED," "RED_"» Error Â« {BABABA}You cannot rob players in robbers spawn place!");
	if ( IsPlayerInAnyVehicle( robbed ) )
	return SendClientMessage( robber, COLOR_ULTRARED, "You can not rob anyone from inside a vehicle." );
	else if ( IsPlayerInAnyVehicle( robbed ) )
	return SendClientMessage( robber, COLOR_YELLOW, "Player with that ID is inside in a vehicle! You can't rob him!" );
	else if ( PlayerInfo[ robbed ][ RecentlyRobbed ] == 1 )
	return SendClientMessage( robber, COLOR_ULTRARED, "That player has been robbed recently. Try again later." );
	if ( GetPlayerMoneyEx( robbed ) > 4999)
    {
        new robbedcash;

        robbedcash = random( 20000 );
	    new string[128];
	    format(string,sizeof(string),"~w~ROBBED %s~nl~~w~+~g~~h~$%d~w~!",PlayerName( robbed ),robbedcash);
		GameTextForPlayer(robber,string,2500,3);
	    new string2[128];
	    format(string2,sizeof(string2),"~w~%s HAS ROBBED YOU!~nl~~w~~r~-$%d~w~!",PlayerName( robber ),robbedcash);
		GameTextForPlayer(robbed,string2,2500,3);
        GivePlayerMoneyEx( robber, robbedcash );
        GivePlayerMoneyEx( robbed, -robbedcash );
        PlayerInfo[ robbed ][ RecentlyRobbed ] = 1;
        SetTimerEx( "ResetRobVariable", 100000, 0, "i", robbed );
        PlayerInfo[ robber ][ PlayerRobberies]++;
    }
    else if ( GetPlayerMoneyEx( robbed ) < 19999 )
    {
        gsString[ 0 ] = EOS;
        format( gsString, sizeof( gsString ), "%s[ID:%d] don't have enough money for rob.", PlayerName( robbed ), robbed );
        return SendClientMessage( robber, COLOR_ULTRARED, gsString );
    }
  	return 1;
}
forward Robberytimer(playerid);
public Robberytimer(playerid)
{
		new srv_string2[ 256 ];
        format( srv_string2, sizeof( srv_string2 ), "~b~ROBBERY IN PROGRESS ~nl~~w~STAY IN THE STORE ~nl~~r~%d ~w~SECONDS LEFT.",robberytime);
		TextDrawSetString( RobTD, srv_string2 );
     	robberytime--;
		if(robberytime == 0)
		{
			robberytime = 0;
		    KillTimer(robberytiming);
		    TextDrawHideForPlayer(playerid, RobTD);
			robberytiming = 0;
		    donerob(playerid);
            TextDrawShowForPlayer(playerid, gTextDraw[3]);
	    }
}

forward Jailtimer(playerid);
public Jailtimer(playerid)
{
		gsString[ 0 ] = EOS;
	    TogglePlayerControllable(playerid,true);
	    SetPlayerPos(playerid,197.6661,173.8179,1003.0234);
	    SetCameraBehindPlayer(playerid);
		format( gsString, sizeof( gsString ), "~b~You will be released in %d seconds.~nl~~w~Type /escape to attempt to escape", cnrjail );
        GameTextForPlayer(playerid,gsString, 2000, 5);
}

forward JailtimerRelease(playerid);
public JailtimerRelease(playerid)
{
     	cnrjail--;
        KillTimer(cnrjailtiming);
        cnrjailtiming=-1;
        JailReleasecnr(playerid);
}

forward Spawntimer(playerid);
public Spawntimer(playerid)
{
		new srv_string2[ 256 ];
		format( srv_string2, sizeof( srv_string2 ), "You will respawn in ~y~%d ~w~Seconds.",spawntime);
		TextDrawSetString( KillerTD8, srv_string2 );
	  	spawntime--;
		if(spawntime == 0)
		{
		    KillTimer(spawntiming);
		    spawntiming=-1;
	    }
}
forward donerob(playerid);
public donerob(playerid)
{
	switch( random( 2 ) )
	{
		case 0:
		{
		    ClearAnimations(playerid);
  			GameTextForPlayer(playerid,"~r~ROBBERY FAILED",1000,5);
  			SendClientMessage(playerid, COLOR_RED,"{FF0000}- {00FFFB}CnR {FF0000}- {FF8000}You have failed the robbery and got away with nothing,the cops have been notified.");
		}
		case 1:
		{
			ClearAnimations(playerid);
			PlayerInfo[ playerid ][ Robberies]++;
			if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS )
			{
					GameTextForPlayer(playerid,"You have Robbed ~g~$50 000",1000,5);
					GivePlayerMoneyEx( playerid , 50000 );
					SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}CnR {7A7A7A}»{DBED15} {DB881A}You have successfully completed the robbery and got away with {00FF00}$50,000");

			}
			if ( GetPlayerTeam( playerid ) == TEAM_PROROBBERS )
			{
					GameTextForPlayer(playerid,"You have Robbed ~g~$100 000",1000,5);
					GivePlayerMoneyEx( playerid , 100000 );
					SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}CnR {7A7A7A}»{DBED15} {DB881A}You have successfully completed the robbery and got away with {00FF00}$100,000");
			}
			if ( GetPlayerTeam( playerid ) == TEAM_EROBBERS )
			{
					GameTextForPlayer(playerid,"You have Robbed ~g~$200 000",1000,5);
					GivePlayerMoneyEx( playerid , 200000 );
					SendClientMessage( playerid, COLOR_ULTRARED,"{FF0000}CnR {7A7A7A}»{DBED15} {DB881A}You have successfully completed the robbery and got away with {00FF00}$200,000");
			}
			foreach( Player, i )
			{
				if( PlayerInfo[ i ][ InCNR] == 1 )
				{
					if ( GetPlayerTeam( playerid ) == TEAM_ROBBERS )
					{
							format( gsString, sizeof( gsString ), "{7A7A7A}[CnR] {87CEFA}%s(%i) has robbed the %s in %s and got away with {00FF00}$50,000", PlayerName( playerid ),playerid,PlayerInfo[ playerid ][ ShopRobbed ],PlayerInfo[ playerid ][ Zone ]);
							SendClientMessage( i, COLOR_ULTRARED,gsString);
					}
					if ( GetPlayerTeam( playerid ) == TEAM_PROROBBERS )
					{
							format( gsString, sizeof( gsString ), "{7A7A7A}[CnR] {87CEFA}%s(%i) has robbed the %s in %s and got away with {00FF00}$100,000", PlayerName( playerid ),playerid,PlayerInfo[ playerid ][ ShopRobbed ],PlayerInfo[ playerid ][ Zone ]);
							SendClientMessage( i, COLOR_ULTRARED,gsString);

					}
					if ( GetPlayerTeam( playerid ) == TEAM_EROBBERS )
					{
							format( gsString, sizeof( gsString ), "{7A7A7A}[CnR] {87CEFA}%s(%i) has robbed the %s in %s and got away with {00FF00}$200,000", PlayerName( playerid ),playerid,PlayerInfo[ playerid ][ ShopRobbed ],PlayerInfo[ playerid ][ Zone ]);
							SendClientMessage( i, COLOR_ULTRARED,gsString);
					}
				}
			}
		}
	}
	return 1;
}

stock cuffplayer(cop,cuffed)
{
    if(GetPlayerTeam( cuffed ) != TEAM_ROBBERS && GetPlayerTeam( cuffed ) != TEAM_PROROBBERS && GetPlayerTeam( cuffed ) != TEAM_EROBBERS   ) 	return SendClientMessage( cop, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You cannot cuff a cop!");
	new str[128];
	if(GetPlayerSpecialAction(cuffed) == SPECIAL_ACTION_CUFFED) SendClientMessage(cop, COLOR_RED, " "RED_"» Error Â« {BABABA}This player is already has been cuffed!");
    else
	{
		SetPlayerSpecialAction(cuffed,SPECIAL_ACTION_CUFFED);
		SetPlayerAttachedObject(cuffed, 8, 19418, 6, -0.011000, 0.028000, -0.022000, -15.600012, -33.699977, -81.700035, 0.891999, 1.000000, 1.168000);
  	    format(str,sizeof(str)," {71A5B0}» Swat Â«"JOBINFO_" %s has been cuffed by officer %s",PlayerName(cuffed),PlayerName(cop));
        SendClientMessageToAll(JOBINFO,str);
        printf("%s",str);
  	    SetTimerEx("uncuff",15000,false,"i",cuffed);
        SendClientMessage(cuffed,GRAY,"You will be uncuffed in 15 seconds");
  	}
  	return 1;
}
forward uncuff(playerid);
public uncuff(playerid) if(IsPlayerConnected(playerid)) SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE),RemovePlayerAttachedObject(playerid,8);

stock stunplayer(cop,stuned)
{
    new str[128];
    if(GetPlayerTeam( stuned ) != TEAM_ROBBERS && GetPlayerTeam( stuned ) != TEAM_PROROBBERS && GetPlayerTeam( stuned ) != TEAM_EROBBERS   ) 	return SendClientMessage( cop, COLOR_ULTRARED,"{FF0000}ERROR: {C8C8C8}You cannot cuff a cop!");
	format(str,sizeof(str)," {71A5B0}» Officer Â«"JOBINFO_" %s has been stunned by officer %s", PlayerName(stuned), PlayerName(cop));
	SendClientMessageToAll(JOBINFO,str);
	printf("%s",str);
	gsString[ 0 ] = EOS;
	TogglePlayerControllable(stuned,0);
	SetTimerEx("WarningUnfreeze",3000,false,"id",stuned,GetPlayerVirtualWorld(stuned));
	TickCount[ cop ][StunTK] = GetTickCount();
	return 1;
}
forward WarningUnfreeze(playerid,w);
public WarningUnfreeze(playerid,w)
{
	TogglePlayerControllable(playerid,1);
	return 1;
}

forward TerrorBomb(playerid);
public TerrorBomb(playerid)
{
	if(IsPlayerAttachedObjectSlotUsed(playerid, 4)) RemovePlayerAttachedObject(playerid, 4);
    if(GetPlayerState(playerid) != 7) BombPlayer(playerid,0,10.0);
    new str[128];
    format(str,sizeof(str)," {71A5B0}» Elite Robber Â«"JOBINFO_" %s has been blown up",PlayerName(playerid));
	SendClientMessageToAll(JOBINFO,str);
	printf("%s",str);
  	return 1;
}
stock BombPlayer(playerid,Type,Float:range)
{
	new Float:x,Float:y,Float:z;
    GetPlayerPos(playerid, x, y, z);
    CreateExplosion(x, y, z, Type, range);
}
stock bombplayer(terror,bombed)
{
	new str[128];
    if (PlayerBombs[terror] <= 0) SendClientMessage( terror, COLOR_RED, " "RED_"» Error Â« {BABABA}You have already used all of your bombs" );
 	else
	{
 	   PlayerBombs[terror]--;
 	   ApplyAnimation(terror, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);
  	   SetPlayerAttachedObject(bombed,4,1252,1,0.00,-0.12,-0.02,0.0,-78.0,2.0,1.00,1.00,1.00);
  	   SendClientMessage(bombed,JOBINFO," {71A5B0}»  Elite Robber Â«"JOBINFO_" The bomb will blow up in 5 seconds");
	   if(terror == bombed)  format(str,sizeof(str)," {71A5B0}» Elite Robber Â«"JOBINFO_" Terrorist %s will blow up himself soon!",PlayerName(terror));
	   else format(str,sizeof(str)," {71A5B0}»  Elite Robber Â«"JOBINFO_" Terrorist %s has attached a bomb to %s!",PlayerName(terror),PlayerName(bombed));
	   SendClientMessageToAll(JOBINFO,str);
	   printf("%s",str);
	   SetTimerEx("TerrorBomb",5000,false,"i",bombed);
	}
	return 1;
}

forward RobbersPro(playerid);
public RobbersPro(playerid)
{
	for(new i=0; i<MAX_PLAYERS; i++)
 	{
     	if(IsPlayerConnected(i))
		{
		    if( GetPlayerTeam( i ) == TEAM_SWAT || GetPlayerTeam( i ) == TEAM_ARMY || GetPlayerTeam( i ) == TEAM_COPS )
		    {
				if(IsPlayerInRangeOfPoint(i, 75, 1323.8813,2673.1052,11.2392))
	     		{
					    new Float:health;
                     	GameTextForPlayer(i,"~w~GET OUT OF ROBBERS BASE~y~!~nl~~r~-15 HEALTH", 1000, 5);
	  			        GetPlayerHealth(i,health);
					    SetPlayerHealth(i,health-15);
				}
			}
		}
	}
	return 1;
}
CNRMenu( )
{
	gsBigString[ 0 ] = EOS;
	format( gsBigString, sizeof( gsBigString ), "%s{FFFF00}CnR\t{00FFFF}Cops\t{00FFFB}LVPD \t{FFFFFF}(Players: %d)\n", gsBigString, Iter_Count(PlayerInCOPS));
	format( gsBigString, sizeof( gsBigString ), "%s{FFFF00}CnR\t{FF8000}Robbers\t{00FFFB} LV Mafia \t {FFFFFF}(Players: %d)\n", gsBigString, Iter_Count(PlayerInROBBERS));
	format( gsBigString, sizeof( gsBigString ), "%s{FFFF00}CnR\t{FF0000}Pro Robbers\t\t{00FFFB}Pro Mafia\n", gsBigString );
	format( gsBigString, sizeof( gsBigString ), "%s{FFFF00}CnR\t{8000FF}Army\t\t\t{00FFFB}Army Task Force\n", gsBigString );
	format( gsBigString, sizeof( gsBigString ), "%s{FFFF00}CnR\t{0000FF}Swat\t\t\t{000000}LVPD Commanders\n", gsBigString);
	format( gsBigString, sizeof( gsBigString ), "%s{FFFF00}CnR\t{FF0000}Elite Robbers\t\t{000000}Mafia Commanders", gsBigString);
	return gsBigString;
}
RobsHelp( )
{
	gsBigString[ 0 ] = EOS;
	strcat(gsBigString,"{FF8000}You have joined Las Venturas Mafia!\n\n");
	strcat(gsBigString,"{00FFFF}Criminal Help:\n");
	strcat(gsBigString,"{FFFFFF}Your job is to cause mayhem in the streets of Las Venturas.\n");
	strcat(gsBigString,"{FFFFFF}You must do your best to evade any cops while your at it.\n");
	strcat(gsBigString,"{FFFFFF}The cops are marked as "LBLUE_"blue {FFFFFF}on your map radar.\n");
	strcat(gsBigString,"{FFFFFF}The elite swat team is marked as {0000FF}darkblue {FFFFFF} on your map radar.\n\n");
	strcat(gsBigString,"{FFFFFF}You can enter some shops and {FF0000}/rob {FFFFFF} the store for cash.\n");
	strcat(gsBigString,"{FFFFFF}Type {FFB6C1}/tpm {FFFFFF}to teamchat with your team members.\n\n");
	strcat(gsBigString,"{FFFFFF}Type /cnrhelp to open this box at anytime, Good luck boys!\n");
	return gsBigString;
}
ProRobsHelp( )
{
	gsBigString[ 0 ] = EOS;
	strcat(gsBigString,"{FF8000}You have joined Las Venturas Pro Mafia!\n\n");
	strcat(gsBigString,"{00FFFF}Pro Criminal Help:\n");
	strcat(gsBigString,"{FFFFFF}Your job is to cause mayhem in the streets of Las Venturas.\n");
	strcat(gsBigString,"{FFFFFF}You must do your best to evade any cops while your at it.\n");
	strcat(gsBigString,"{FFFFFF}The cops are marked as "LBLUE_"blue {FFFFFF}on your map radar.\n");
	strcat(gsBigString,"{FFFFFF}The elite swat team is marked as {0000FF}darkblue {FFFFFF} on your map radar.\n\n");
	strcat(gsBigString,"{FFFFFF}You can enter some shops and {FF0000}/rob {FFFFFF} the store for cash.\n");
	strcat(gsBigString,"{FFFFFF}Type {FFB6C1}/tpm {FFFFFF}to teamchat with your team members.\n\n");
	strcat(gsBigString,"{FFFFFF}Type /cnrhelp to open this box at anytime, Good luck boys!\n");
	return gsBigString;
}
ERobsHelp( )
{
	gsBigString[ 0 ] = EOS;
	strcat(gsBigString,"{FF8000}You have joined Las Venturas Elite Mafia!\n\n");
	strcat(gsBigString,"{00FFFF}Elite Criminal Help:\n");
	strcat(gsBigString,"{FFFFFF}Your job is to cause mayhem in the streets of Las Venturas.\n");
	strcat(gsBigString,"{FFFFFF}You must do your best to evade any cops while your at it.\n");
	strcat(gsBigString,"{FFFFFF}The cops are marked as "LBLUE_"blue {FFFFFF}on your map radar.\n");
	strcat(gsBigString,"{FFFFFF}The elite swat team is marked as {0000FF}darkblue {FFFFFF} on your map radar.\n\n");
	strcat(gsBigString,"{FFFFFF}You can enter some shops and {FF0000}/rob {FFFFFF} the store for cash.\n");
	strcat(gsBigString,"{FFFFFF}Type {FFB6C1}/tpm {FFFFFF}to teamchat with your team members.\n\n");
	strcat(gsBigString,"{FFFFFF}Type {FFFF00}/bomb {FFFFFF}to bomb cops. Remember you have only 3 bomb.\n");
	strcat(gsBigString,"{FFFFFF}Type /cnrhelp to open this box at anytime, Good luck boys!\n");
	return gsBigString;
}
ArmyHelp( )
{
	gsBigString[ 0 ] = EOS;
	strcat(gsBigString,"{00a7c2}You have joined Army!\n\n");
	strcat(gsBigString,"{0000FF}Army Help:\n");
	strcat(gsBigString,"{FFFFFF}Your mission is to protect the street of Las Venturas by eliminating any crime.\n");
	strcat(gsBigString,"{FFFFFF}Suspects are shown as {FF8000}orange {FFFFFF}on your map radar. The most wanted suspects are shown in darker orange.\n");
	strcat(gsBigString,"{FFFFFF}Type {FF0000}/ar(MMB) {FFFFFF}to arrest any criminal nearby, you and the suspect must be on foot.\n");
	strcat(gsBigString,"{FFFFFF}Type {FFFF00}/stun {FFFFFF}to arrest any criminal nearby, you and the suspect must be on foot.\n");
	strcat(gsBigString,"{FFFFFF}You get more score and money by arresting rather then takedowns.\n");
	strcat(gsBigString,"{FFFFFF}Type {FFB6C1}/tpm {FFFFFF}to teamchat with your team members.\n");
	strcat(gsBigString,"{FFFFFF}Type {00a7c2}/bk {FFFFFF}to request backup at anytime.\n\n");
	strcat(gsBigString,"{FFFFFF}Type /cnrhelp to open this box anytime, Good luck soliders!");
	return gsBigString;
}
SwatHelp( )
{
	gsBigString[ 0 ] = EOS;
	strcat(gsBigString,"{00a7c2}You have joined Swat!\n\n");
	strcat(gsBigString,"{0000FF}Swat Help:\n");
	strcat(gsBigString,"{FFFFFF}Your mission is to protect the street of Las Venturas by eliminating any crime.\n");
	strcat(gsBigString,"{FFFFFF}Suspects are shown as {FF8000}orange {FFFFFF}on your map radar. The most wanted suspects are shown in darker orange.\n");
	strcat(gsBigString,"{FFFFFF}Type {FF0000}/ar(MMB) {FFFFFF}to arrest any criminal nearby, you and the suspect must be on foot.\n");
	strcat(gsBigString,"{FFFFFF}Type {FFFF00}/stun {FFFFFF}to arrest any criminal nearby, you and the suspect must be on foot.\n");
	strcat(gsBigString,"{FFFFFF}Type {00FF00}/cuff {FFFFFF}to cuff any criminal nearby, you and the suspect must be on foot.\n");
	strcat(gsBigString,"{FFFFFF}You get more score and money by arresting rather then takedowns.\n");
	strcat(gsBigString,"{FFFFFF}Type {FFB6C1}/tpm {FFFFFF}to teamchat with your team members.\n");
	strcat(gsBigString,"{FFFFFF}Type {00a7c2}/bk {FFFFFF}to request backup at anytime.\n\n");
	strcat(gsBigString,"{FFFFFF}Type /cnrhelp to open this box anytime, Good luck soliders!");
	return gsBigString;
}
CopsHelp( )
{
	gsBigString[ 0 ] = EOS;
	strcat(gsBigString,"{00a7c2}You have joined Las Venturas Police Deapartment!\n\n");
	strcat(gsBigString,"{0000FF}Cop Help:\n");
	strcat(gsBigString,"{FFFFFF}Your mission is to protect the street of Las Venturas by eliminating any crime.\n");
	strcat(gsBigString,"{FFFFFF}Suspects are shown as {FF8000}orange {FFFFFF}on your map radar. The most wanted suspects are shown in darker orange.\n");
	strcat(gsBigString,"{FFFFFF}Type {FF0000}/ar(MMB) {FFFFFF}to arrest any criminal nearby, you and the suspect must be on foot.\n");
	strcat(gsBigString,"{FFFFFF}You get more score and money by arresting rather then takedowns.\n");
	strcat(gsBigString,"{FFFFFF}Type {FFB6C1}/tpm {FFFFFF}to teamchat with your team members.\n");
	strcat(gsBigString,"{FFFFFF}Type {00a7c2}/bk {FFFFFF}to request backup at anytime.\n\n");
	strcat(gsBigString,"{FFFFFF}Type /cnrhelp to open this box anytime, Good luck soliders!");
	return gsBigString;
}
stock SpawnPlayerCop( playerid )
{
	if(GetPlayerTeam( playerid ) == TEAM_COPS) return SendClientMessage(playerid,-1,"{FF0000}ERROR: {C8C8C8}You are already a cop! Choose a different class.");
	foreach( Player, i )
	{
		if( PlayerInfo[ i ][ InCNR] == 1 )
		{
			format( gsString, sizeof( gsString ), "{FF0000}[CnR] {FFE4C4}%s(%i) has joined Cops and Robbers {15D4ED}(Cops)", PlayerName( playerid ),playerid);
			SendClientMessage( i, COLOR_ULTRARED,gsString);
		}
	}
	PlayerInfo[playerid][GodEnabled] = 0;
	Nitro[playerid] = false;
    Bounce[playerid] = false;
    AutoFix[playerid] = false;
    SetPVarInt(playerid, "InCnR", 1);
	PlayerInfo[ playerid ][ ActionID ] = ( 2 );
	gsString[0]=EOS;
    format(gsString, 144, "~w~You Have Joined The ~h~~h~~b~COP TEAM~w~!");
	Announce(playerid, gsString, 3000, 4);
	PlayerInfo[ playerid ][ InCNR] = 1;
	SetPlayerHealth( playerid, 100 );
	Iter_Remove( PlayerInROBBERS, playerid );
	Iter_Add( PlayerInCOPS, playerid );
	SavePlayerCoords(playerid);
	PlayerInfo[ playerid ][ INMG] = 1;
	ResetPlayerWeapons(playerid);
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {004BFF}You have joined the LVPD!");
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {004BFF}Your mission is to arrests any robbers and keep the streets of LV clean!");
	SetPlayerTeam( playerid, TEAM_COPS ); // Cops Team
	SetPlayerRandomSpawnCC( playerid );
	switch( random( 6 ) )
	{
		case 0:	SetPlayerSkin( playerid , 280 );
		case 1:	SetPlayerSkin( playerid , 281 );
		case 2:	SetPlayerSkin( playerid , 282 );
		case 3:	SetPlayerSkin( playerid , 283 );
		case 4:	SetPlayerSkin( playerid , 284 );
		case 5:	SetPlayerSkin( playerid , 286 );
	}
	SetPlayerColor( playerid , 0x33CCFFAA ); // light_blue
	// ( GangZone CNR )

	GangZoneShowForPlayer( playerid, CNR_ZONE[ 0 ], 0xFF04298D ); // Rob
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 1 ], 0x0080FF85 ); // Cop
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 2 ], 0x0259EAAA); // SWAT
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 3 ], 0xB360FDFF ); // ARMY
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 4 ], 0xFF04298D ); // Rob2
	GivePlayerWeapon( playerid, 3, 1 ); // Bulan
	GivePlayerWeapon( playerid, 23, 100 ); // Silenced 9mm
	GivePlayerWeapon( playerid, 24, 100 ); // Sawnoff Shotgun
	GivePlayerWeapon( playerid, 32, 500 ); // Tec-9
	GivePlayerWeapon( playerid, 31, 500 ); // M4
	GivePlayerWeapon( playerid, 34, 100 ); // Sniper
	SetPlayerVirtualWorld( playerid, 15 );
	Iter_Add( PlayerInCNR, playerid );
	ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX , "{0000FF}Cop Help" , CopsHelp( ) , "Close" , "" );
	return ( 1 );
}
stock SpawnPlayerSwat( playerid )
{
	if(GetPlayerTeam( playerid ) == TEAM_SWAT) return SendClientMessage(playerid,-1,"{FF0000}ERROR: {C8C8C8}You are already a swat! Choose a different class.");
	foreach( Player, i )
	{
		if( PlayerInfo[ i ][ InCNR] == 1 )
		{
			format( gsString, sizeof( gsString ), "{FF0000}[CnR] {FFE4C4}%s(%i) has joined Cops and Robbers {0000FF}(Swat)", PlayerName( playerid ),playerid);
			SendClientMessage( i, COLOR_ULTRARED,gsString);
		}
	}
	gsString[0]=EOS;
    format(gsString, 144, "~w~You Have Joined The ~p~SWAT TEAM~w~!");
	Announce(playerid, gsString, 3000, 4);
	PlayerInfo[playerid][GodEnabled] = 0;
	Nitro[playerid] = false;
    Bounce[playerid] = false;
    AutoFix[playerid] = false;
    SetPVarInt(playerid, "InCnR", 1);
	PlayerInfo[ playerid ][ InCNR] = 1;
	PlayerInfo[ playerid ][ ActionID ] = ( 2 );
	SavePlayerCoords(playerid);
	PlayerInfo[ playerid ][ INMG] = 1;
	ResetPlayerWeapons(playerid);
	SetPlayerHealth( playerid, 100 );
	SetPlayerArmour( playerid, 100 );
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {004BFF}You have joined the Swat!");
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {004BFF}Your mission is to arrests any robbers and keep the streets of LV clean!");
	SetPlayerTeam( playerid, TEAM_SWAT ); // SWAT Team
	SetPlayerPos( playerid , 1620.5907,1550.4069,10.8039 );
	SetPlayerSkin( playerid , 285 );
	SetPlayerColor( playerid , 0x0259EAAA );
	// ( GangZone CNR )
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 0 ], 0xFF04298D ); // Rob
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 1 ], 0x0080FF85 ); // Cop
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 2 ], 0x0259EAAA); // SWAT
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 3 ], 0xB360FDFF ); // ARMY
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 4 ], 0xFF04298D ); // Rob2
	GivePlayerWeapon( playerid, 3, 1 ); // Bulan
	GivePlayerWeapon( playerid, 23, 100 ); // Silenced 9mm
	GivePlayerWeapon( playerid, 24, 100 ); // Sawnoff Shotgun
	GivePlayerWeapon( playerid, 32, 500 ); // Tec-9
	GivePlayerWeapon( playerid, 31, 500 ); // M4
	GivePlayerWeapon( playerid, 34, 100 ); // Sniper
	SetPlayerVirtualWorld( playerid, 15 );
 	Iter_Remove( PlayerInCOPS, playerid );
 	Iter_Remove( PlayerInROBBERS, playerid );
	Iter_Add( PlayerInCNR, playerid );
	ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX , "{0000FF}Swat Help" , SwatHelp( ) , "Close" , "" );
	return ( 1 );
}
stock SpawnPlayerArmy( playerid )
{
	if(GetPlayerTeam( playerid ) == TEAM_ARMY) return SendClientMessage(playerid,-1,"{FF0000}ERROR: {C8C8C8}You are already a army! Choose a different class.");
	foreach( Player, i )
	{
		if( PlayerInfo[ i ][ InCNR] == 1 )
		{
			format( gsString, sizeof( gsString ), "{FF0000}[CnR] {FFE4C4}%s(%i) has joined Cops and Robbers {5A00FF}(Army)", PlayerName( playerid ),playerid);
			SendClientMessage( i, COLOR_ULTRARED,gsString);
		}
	}
	gsString[0]=EOS;
    format(gsString, 144, "~w~You Have Joined The ~b~ARMY TEAM~w~!");
	Announce(playerid, gsString, 3000, 4);
	PlayerInfo[playerid][GodEnabled] = 0;
	Nitro[playerid] = false;
    Bounce[playerid] = false;
    AutoFix[playerid] = false;
    SetPVarInt(playerid, "InCnR", 1);
	PlayerInfo[ playerid ][ InCNR] = 1;
	PlayerInfo[ playerid ][ ActionID ] = ( 2 );
	SavePlayerCoords(playerid);
	PlayerInfo[ playerid ][ INMG] = 1;
	ResetPlayerWeapons(playerid);
	SetPlayerArmour( playerid, 50 );
	SetPlayerHealth( playerid, 100 );
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {004BFF}You have joined the Army!");
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {004BFF}Your mission is to arrests any robbers and keep the streets of LV clean!");
	SetPlayerTeam( playerid, TEAM_ARMY ); // Army Team
	SetPlayerPos( playerid ,308.2154,2044.8608,17.6406 );
	SetPlayerSkin( playerid , 287 );
	SetPlayerColor( playerid , 0xB360FDFF );
	// ( GangZone CNR )
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 0 ], 0xFF04298D ); // Rob
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 1 ], 0x0080FF85 ); // Cop
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 2 ], 0x0259EAAA); // SWAT
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 3 ], 0xB360FDFF ); // ARMY
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 4 ], 0xFF04298D ); // Rob2
	GivePlayerWeapon( playerid, 3, 1 );
	GivePlayerWeapon( playerid, 26, 100 );
	GivePlayerWeapon( playerid, 27, 100 );
	GivePlayerWeapon( playerid, 30, 500 );
	GivePlayerWeapon( playerid, 34, 500 );
	SetPlayerVirtualWorld( playerid, 15 );
 	Iter_Remove( PlayerInCOPS, playerid );
 	Iter_Remove( PlayerInROBBERS, playerid );
	Iter_Add( PlayerInCNR, playerid );
	ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX , "{8000FF}Army Help" , ArmyHelp( ) , "Close" , "" );
	return ( 1 );
}
stock SpawnPlayerERobber( playerid )
{
	if(GetPlayerTeam( playerid ) == TEAM_EROBBERS) return SendClientMessage(playerid,-1,"{FF0000}ERROR: {C8C8C8}You are already a elite robber! Choose a different class.");
	foreach( Player, i )
	{
		if( PlayerInfo[ i ][ InCNR] == 1 )
		{
			format( gsString, sizeof( gsString ), "{FF0000}[CnR] {FFE4C4}%s(%i) has joined Cops and Robbers {FF0000}(Elite Robbers)", PlayerName( playerid ),playerid);
			SendClientMessage( i, COLOR_ULTRARED,gsString);
		}
	}
	gsString[0]=EOS;
    format(gsString, 144, "~w~You Have Joined The ~r~ELITE ROBBBERS TEAM~w~!");
	Announce(playerid, gsString, 3000, 4);
	PlayerInfo[playerid][GodEnabled] = 0;
	Nitro[playerid] = false;
    Bounce[playerid] = false;
    AutoFix[playerid] = false;
    SetPVarInt(playerid, "InCnR", 1);
	PlayerInfo[ playerid ][ InCNR] = 1;
	SavePlayerCoords(playerid);
	PlayerInfo[ playerid ][ INMG] = 1;
	ResetPlayerWeapons(playerid);
	SetPlayerHealth( playerid, 100 );
	SetPlayerArmour( playerid, 100 );
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {DB881A}You have joined the Elite Robbers!");
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {DB881A}Your mission is create mayhem in LV and evade cops!");
	SetPlayerTeam( playerid, TEAM_EROBBERS ); // Elite Robbers Team
	Cuffed[ playerid ] = false;
	PlayerInfo[ playerid ][ ActionID ] = ( 2 );
	SetPlayerRandomSpawnCR( playerid );
	SetPlayerSkin( playerid , 294 );
	SetPlayerColor( playerid , 0xFF0000FF ); // ultra_red
	// ( GangZone CNR )
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 0 ], 0xFF04298D ); // Rob
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 1 ], 0x0080FF85 ); // Cop
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 2 ], 0x0259EAAA); // SWAT
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 3 ], 0xB360FDFF ); // ARMY
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 4 ], 0xFF04298D ); // Rob2
	GivePlayerWeapon( playerid, 4, 1 );
	GivePlayerWeapon( playerid, 23, 100 );
	GivePlayerWeapon( playerid, 26, 100 );
	GivePlayerWeapon( playerid, 28, 500 );
	GivePlayerWeapon( playerid, 31, 500 );
	GivePlayerWeapon( playerid, 34, 100 );
	GivePlayerWeapon(playerid, 35, 4);
	SetPlayerVirtualWorld( playerid, 15 );
 	Iter_Remove( PlayerInCOPS, playerid );
 	Iter_Remove( PlayerInROBBERS, playerid );
	Iter_Add( PlayerInCNR, playerid );
	ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX , "{FF0000}Elite Criminal Help" , ERobsHelp( ) , "Close" , "" );
	return ( 1 );
}
stock SpawnPlayerProRobber( playerid )
{
    if(GetPlayerTeam( playerid ) == TEAM_PROROBBERS) return SendClientMessage(playerid,-1,"{FF0000}ERROR: {C8C8C8}You are already a pro robber! Choose a different class.");
	foreach( Player, i )
	{
		if( PlayerInfo[ i ][ InCNR] == 1 )
		{
			format( gsString, sizeof( gsString ), "{FF0000}[CnR] {FFE4C4}%s(%i) has joined Cops and Robbers {FF0000}(Pro Robbers)", PlayerName( playerid ),playerid);
			SendClientMessage( i, COLOR_ULTRARED,gsString);
		}
	}
    gsString[0]=EOS;
    format(gsString, 144, "You Have Joined The ~r~PRO ROBBBERS TEAM~w~!");
	Announce(playerid, gsString, 3000, 4);
	PlayerInfo[playerid][GodEnabled] = 0;
	Nitro[playerid] = false;
    Bounce[playerid] = false;
    AutoFix[playerid] = false;
    SetPVarInt(playerid, "InCnR", 1);
	PlayerInfo[ playerid ][ InCNR] = 1;
	PlayerInfo[ playerid ][ ActionID ] = ( 2 );
	SavePlayerCoords(playerid);
	PlayerInfo[ playerid ][ INMG] = 1;
	ResetPlayerWeapons(playerid);
	SetPlayerHealth( playerid, 100 );
	SetPlayerArmour( playerid, 50 );
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {DB881A}You have joined the Pro Robbers!");
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {DB881A}Your mission is create mayhem in LV and evade cops!");
	SetPlayerTeam( playerid, TEAM_PROROBBERS ); // Pro Robbers Team
	Cuffed[ playerid ] = false;
	SetPlayerRandomSpawnCR( playerid );
	SetPlayerSkin( playerid , 110 );
	SetPlayerColor( playerid , 0xFF0000FF ); // ultra_red
	ResetPlayerWeapons( playerid );
	// ( GangZone CNR )
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 0 ], 0xFF04298D ); // Rob
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 1 ], 0x0080FF85 ); // Cop
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 2 ], 0x0259EAAA); // SWAT
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 3 ], 0xB360FDFF ); // ARMY
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 4 ], 0xFF04298D ); // Rob2
	GivePlayerWeapon( playerid, 4, 1 );
	GivePlayerWeapon( playerid, 29, 1200 );
	GivePlayerWeapon( playerid, 31, 2000 );
	GivePlayerWeapon( playerid, 26, 600 );
	GivePlayerWeapon( playerid, 27, 500 );
	GivePlayerWeapon( playerid, 16, 5 );
	GivePlayerWeapon( playerid, 34, 200 );
	SetPlayerVirtualWorld( playerid, 15 );
 	Iter_Remove( PlayerInCOPS, playerid );
 	Iter_Remove( PlayerInROBBERS, playerid );
	Iter_Add( PlayerInCNR, playerid );
	ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX , "{FF0000}Pro Criminal Help" , ProRobsHelp( ) , "Close" , "" );
	return ( 1 );
}
stock SpawnPlayerRobber( playerid )
{
	if(GetPlayerTeam( playerid ) == TEAM_ROBBERS) return SendClientMessage(playerid,-1,"{FF0000}ERROR: {C8C8C8}You are already a robber! Choose a different class.");
    gsString[0]=EOS;
    format(gsString, 144, "~w~You Have Joined The ~r~ROBBBERS TEAM~w~!");
	Announce(playerid, gsString, 3000, 4);
	PlayerInfo[playerid][GodEnabled] = 0;
	Nitro[playerid] = false;
    Bounce[playerid] = false;
    AutoFix[playerid] = false;
    SetPVarInt(playerid, "InCnR", 1);
	PlayerInfo[ playerid ][ InCNR] = 1;
	Iter_Add( PlayerInROBBERS, playerid );
	PlayerInfo[ playerid ][ ActionID ] = ( 2 );
	SavePlayerCoords(playerid);
	PlayerInfo[ playerid ][ INMG] = 1;
	ResetPlayerWeapons(playerid);
	SetPlayerHealth( playerid, 100 );
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {DB881A}You have joined the Robbers!");
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {DB881A}Your mission is create mayhem in LV and evade cops!");
	SetPlayerTeam( playerid, TEAM_ROBBERS ); // Robbers Team
	Cuffed[ playerid ] = false;
	SetPlayerRandomSpawnCR( playerid );
	SetPlayerSkin( playerid , 295 );
	SetPlayerColor( playerid , 0xFF04298D ); // ultra_red
	// ( GangZone CNR )
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 0 ], 0xFF04298D ); // Rob
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 1 ], 0x0080FF85 ); // Cop
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 2 ], 0x0259EAAA); // SWAT
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 3 ], 0xB360FDFF ); // ARMY
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 4 ], 0xFF04298D ); // Rob2
	GivePlayerWeapon( playerid, 5, 1 ); // Bat
	GivePlayerWeapon( playerid, 24, 100 ); // Deagle
	GivePlayerWeapon( playerid, 25, 100 ); // Sawnoff Shotgun
	GivePlayerWeapon( playerid, 28, 500 ); // Micro SMG
	GivePlayerWeapon( playerid, 30, 500 ); // AK-47
	GivePlayerWeapon( playerid, 33, 100 ); // Sniper
	SetPlayerVirtualWorld( playerid, 15 );
	Iter_Remove( PlayerInCOPS, playerid );
	Iter_Add( PlayerInCNR, playerid );
	ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX , "{FF0000}Criminal Help" , RobsHelp( ) , "Close" , "" );
	return ( 1 );
}
stock RespawnplayerArmy( playerid )
{
	PlayerInfo[ playerid ][ InCNR] = 1;
	SetPlayerHealth( playerid, 100 );
	SetPlayerArmour( playerid, 50 );
	PlayerInfo[playerid][GodEnabled] = 0;
	Nitro[playerid] = false;
    Bounce[playerid] = false;
    AutoFix[playerid] = false;
    SetPVarInt(playerid, "InCnR", 1);
	SetPlayerTeam( playerid, TEAM_ARMY ); // Army Team
	PlayerInfo[ playerid ][ ActionID ] = ( 2 );
	SetPlayerPos( playerid ,308.2154,2044.8608,17.6406 );
	SetPlayerSkin( playerid , 287 );
	SetPlayerColor( playerid , 0xB360FDFF );
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 0 ], 0xFF04298D ); // Rob
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 1 ], 0x0080FF85 ); // Cop
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 2 ], 0x0259EAAA); // SWAT
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 3 ], 0xB360FDFF ); // ARMY
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 4 ], 0xFF04298D ); // Rob2
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {FF0000}You have respawned as a Army!");
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {778899}Type /leave to exit the deathmatch.");
	GivePlayerWeapon( playerid, 3, 1 );
	GivePlayerWeapon( playerid, 26, 100 );
	GivePlayerWeapon( playerid, 27, 100 );
	GivePlayerWeapon( playerid, 30, 500 );
	GivePlayerWeapon( playerid, 34, 500 );
	SetPlayerVirtualWorld( playerid, 15 );
	Iter_Add( PlayerInCNR, playerid );
	ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX , "{8000FF}Army Help" , ArmyHelp( ) , "Close" , "" );
	return ( 1 );
}
stock RespawnplayerCop( playerid )
{
	PlayerInfo[ playerid ][ InCNR] = 1;
	PlayerInfo[playerid][GodEnabled] = 0;
	Nitro[playerid] = false;
    Bounce[playerid] = false;
    AutoFix[playerid] = false;
    SetPVarInt(playerid, "InCnR", 1);
	KillTimer( KillerTimer[ playerid] );
	SetPlayerHealth( playerid, 100 );
	Iter_Add( PlayerInCOPS, playerid );
	SetPlayerTeam( playerid, TEAM_COPS ); // Cops Team
	PlayerInfo[ playerid ][ ActionID ] = ( 2 );
	SetPlayerRandomSpawnCC( playerid );
    Nitro[playerid] = false;
    Bounce[playerid] = false;
    AutoFix[playerid] = false;
	switch( random( 6 ) )
	{
		case 0:	SetPlayerSkin( playerid , 280 );
		case 1:	SetPlayerSkin( playerid , 281 );
		case 2:	SetPlayerSkin( playerid , 282 );
		case 3:	SetPlayerSkin( playerid , 283 );
		case 4:	SetPlayerSkin( playerid , 284 );
		case 5:	SetPlayerSkin( playerid , 286 );
	}
	SetPlayerColor( playerid , 0x33CCFFAA ); // light_blue
	ResetPlayerWeapons( playerid );
	// ( GangZone CNR )
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 0 ], 0xFF04298D ); // Rob
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 1 ], 0x0080FF85 ); // Cop
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 2 ], 0x0259EAAA); // SWAT
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 3 ], 0xB360FDFF ); // ARMY
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 4 ], 0xFF04298D ); // Rob2
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {FF0000}You have respawned as a LVPD!");
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {778899}Type /leave to exit the deathmatch.");
	GivePlayerWeapon( playerid, 3, 1 ); // Bulan
	GivePlayerWeapon( playerid, 23, 100 ); // Silenced 9mm
	GivePlayerWeapon( playerid, 24, 100 ); // Sawnoff Shotgun
	GivePlayerWeapon( playerid, 32, 500 ); // Tec-9
	GivePlayerWeapon( playerid, 31, 500 ); // M4
	GivePlayerWeapon( playerid, 34, 100 ); // Sniper
	SetPlayerVirtualWorld( playerid, 15 );
	Iter_Add( PlayerInCNR, playerid );
	ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX ,  "{0000FF}Cop Help" , CopsHelp( ) , "Close" , "" );
	return ( 1 );
}
stock RespawnplayerSwat( playerid )
{
	PlayerInfo[ playerid ][ InCNR] = 1;
	PlayerInfo[playerid][GodEnabled] = 0;
	Nitro[playerid] = false;
    Bounce[playerid] = false;
    AutoFix[playerid] = false;
    SetPVarInt(playerid, "InCnR", 1);
	SetPlayerArmour( playerid, 100 );
	KillTimer( KillerTimer[ playerid] );
	SetPlayerHealth( playerid, 100 );
	SetPlayerTeam( playerid, TEAM_SWAT ); // SWAT Team
	PlayerInfo[ playerid ][ ActionID ] = ( 2 );
	SetPlayerPos( playerid , 1620.5907,1550.4069,10.8039 );
	SetPlayerSkin( playerid , 285 );
	SetPlayerColor( playerid , 0x0259EAAA );
    Nitro[playerid] = false;
    Bounce[playerid] = false;
    AutoFix[playerid] = false;
	// ( GangZone CNR )
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 0 ], 0xFF04298D ); // Rob
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 1 ], 0x0080FF85 ); // Cop
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 2 ], 0x0259EAAA); // SWAT
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 3 ], 0xB360FDFF ); // ARMY
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 4 ], 0xFF04298D ); // Rob2
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {FF0000}You have respawned as a Swat!");
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {778899}Type /leave to exit the deathmatch.");
	ResetPlayerWeapons(playerid);
	GivePlayerWeapon( playerid, 3, 1 ); // Bulan
	GivePlayerWeapon( playerid, 23, 100 ); // Silenced 9mm
	GivePlayerWeapon( playerid, 24, 100 ); // Sawnoff Shotgun
	GivePlayerWeapon( playerid, 32, 500 ); // Tec-9
	GivePlayerWeapon( playerid, 31, 500 ); // M4
	GivePlayerWeapon( playerid, 34, 100 ); // Sniper
	SetPlayerVirtualWorld( playerid, 15 );
	Iter_Add( PlayerInCNR, playerid );
	ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX , "{0000FF}Swat Help" , SwatHelp( ) , "Close" , "" );
	return ( 1 );
}

stock RespawnplayerERobber( playerid )
{
	PlayerInfo[ playerid ][ InCNR] = 1;
	PlayerInfo[playerid][GodEnabled] = 0;
	Nitro[playerid] = false;
    Bounce[playerid] = false;
    AutoFix[playerid] = false;
    SetPVarInt(playerid, "InCnR", 1);
	SetPlayerArmour( playerid, 100 );
	KillTimer( KillerTimer[ playerid] );
	SetPlayerHealth( playerid, 100 );
	SetPlayerTeam( playerid, TEAM_EROBBERS ); // Elite Robbers Team
	Cuffed[ playerid ] = false;
	PlayerInfo[ playerid ][ ActionID ] = ( 2 );
	SetPlayerRandomSpawnCR( playerid );
	SetPlayerSkin( playerid , 294 );
	SetPlayerColor( playerid , 0xFF0000FF ); // ultra_red
    Nitro[playerid] = false;
    Bounce[playerid] = false;
    AutoFix[playerid] = false;
	// ( GangZone CNR )
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 0 ], 0xFF04298D ); // Rob
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 1 ], 0x0080FF85 ); // Cop
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 2 ], 0x0259EAAA); // SWAT
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 3 ], 0xB360FDFF ); // ARMY
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 4 ], 0xFF04298D ); // Rob2
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {FF0000}You have respawned as a Elite Robber!");
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {778899}Type /leave to exit the deathmatch.");
	ResetPlayerWeapons(playerid);
	GivePlayerWeapon( playerid, 4, 1 );
	GivePlayerWeapon( playerid, 23, 100 );
	GivePlayerWeapon( playerid, 26, 100 );
	GivePlayerWeapon( playerid, 28, 500 );
	GivePlayerWeapon( playerid, 31, 500 );
	GivePlayerWeapon( playerid, 34, 100 );
	GivePlayerWeapon(playerid, 35, 4);
	SetPlayerVirtualWorld( playerid, 15 );
	Iter_Add( PlayerInCNR, playerid );
	ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX , "{FF0000}Elite Criminal Help" , ERobsHelp( ) , "Close" , "" );
	return ( 1 );
}
stock RespawnplayerProRobber( playerid )
{
	PlayerInfo[ playerid ][ InCNR] = 1;
	PlayerInfo[playerid][GodEnabled] = 0;
	Nitro[playerid] = false;
    Bounce[playerid] = false;
    AutoFix[playerid] = false;
    SetPVarInt(playerid, "InCnR", 1);
	SetPlayerArmour( playerid, 50 );
	KillTimer( KillerTimer[ playerid] );
	SetPlayerHealth( playerid, 100 );
	SetPlayerTeam( playerid, TEAM_PROROBBERS ); // Pro Robbers Team
	Cuffed[ playerid ] = false;
	PlayerInfo[ playerid ][ ActionID ] = ( 2 );
	SetPlayerRandomSpawnCR( playerid );
	SetPlayerSkin( playerid , 110 );
	SetPlayerColor( playerid , 0xFF0000FF ); // ultra_red
    Nitro[playerid] = false;
    Bounce[playerid] = false;
    AutoFix[playerid] = false;
	// ( GangZone CNR )
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 0 ], 0xFF04298D ); // Rob
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 1 ], 0x0080FF85 ); // Cop
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 2 ], 0x0259EAAA); // SWAT
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 3 ], 0xB360FDFF ); // ARMY
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 4 ], 0xFF04298D ); // Rob2
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {FF0000}You have respawned as a Pro Robber!");
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {778899}Type /leave to exit the deathmatch.");
	ResetPlayerWeapons(playerid);
	GivePlayerWeapon( playerid, 4, 1 );
	GivePlayerWeapon( playerid, 29, 1200 );
	GivePlayerWeapon( playerid, 31, 2000 );
	GivePlayerWeapon( playerid, 26, 600 );
	GivePlayerWeapon( playerid, 27, 500 );
	GivePlayerWeapon( playerid, 16, 5 );
	GivePlayerWeapon( playerid, 34, 200 );
	SetPlayerVirtualWorld( playerid, 15 );
	Iter_Add( PlayerInCNR, playerid );
	ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX , "{FF0000}Pro Criminal Help" , ProRobsHelp( ) , "Close" , "" );
	return ( 1 );
}
stock RespawnplayerRobber( playerid )
{
	PlayerInfo[ playerid ][ InCNR] = 1;
	PlayerInfo[playerid][GodEnabled] = 0;
	Nitro[playerid] = false;
    Bounce[playerid] = false;
    AutoFix[playerid] = false;
    SetPVarInt(playerid, "InCnR", 1);
	KillTimer( KillerTimer[ playerid] );
	SetPlayerHealth( playerid, 100 );
	Iter_Add( PlayerInROBBERS, playerid );
	SetPlayerTeam( playerid, TEAM_ROBBERS ); // Robbers Team
	Cuffed[ playerid ] = false;
	PlayerInfo[ playerid ][ ActionID ] = ( 2 );
	SetPlayerRandomSpawnCR( playerid );
	SetPlayerSkin( playerid , 295 );
	SetPlayerColor( playerid , 0xFF0000FF ); // ultra_red
    Nitro[playerid] = false;
    Bounce[playerid] = false;
    AutoFix[playerid] = false;
	// ( GangZone CNR )
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 0 ], 0xFF04298D ); // Rob
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 1 ], 0x0080FF85 ); // Cop
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 2 ], 0x0259EAAA); // SWAT
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 3 ], 0xB360FDFF ); // ARMY
	GangZoneShowForPlayer( playerid, CNR_ZONE[ 4 ], 0xFF04298D ); // Rob2
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {FF0000}You have respawned as a Robber!");
	SendClientMessage(playerid, -1, "{FF0000}CNR {7A7A7A}»{DBED15} {778899}Type /leave to exit the deathmatch.");
	ResetPlayerWeapons(playerid);
	GivePlayerWeapon( playerid, 5, 1 ); // Bat
	GivePlayerWeapon( playerid, 24, 100 ); // Deagle
	GivePlayerWeapon( playerid, 25, 100 ); // Sawnoff Shotgun
	GivePlayerWeapon( playerid, 28, 500 ); // Micro SMG
	GivePlayerWeapon( playerid, 30, 500 ); // AK-47
	GivePlayerWeapon( playerid, 33, 100 ); // Sniper
	SetPlayerVirtualWorld( playerid, 15 );
	Iter_Add( PlayerInCNR, playerid );
	ShowPlayerDialog( playerid , DIALOG_CnR + 1 , DIALOG_STYLE_MSGBOX , "{FF0000}Criminal Help" , RobsHelp( ) , "Close" , "" );
	return ( 1 );
}

stock GetClosestPlayer(playerid, checkvw = false, Float:range = FLOAT_INFINITY)
{
    new Float:playerPos[ 3 ];
    GetPlayerPos( playerid, playerPos[ 0 ], playerPos[ 1 ], playerPos[ 2 ]);

    new Float:closestDist = FLOAT_INFINITY;
    new closestPlayer = INVALID_PLAYER_ID;

    new Float:thisDist;
    foreach(new i : Player)
    {
        if( i == playerid ) continue;
        if( checkvw && GetPlayerVirtualWorld( playerid ) != GetPlayerVirtualWorld( i ) ) continue;
        if( GetPlayerInterior( playerid ) != GetPlayerInterior( i ) ) continue;

        thisDist = GetPlayerDistanceFromPoint( i, playerPos[ 0 ], playerPos[ 1 ], playerPos[ 2 ] );
        if( thisDist < closestDist && thisDist < range )
        {
            closestPlayer = i;
            closestDist = thisDist;
        }
    }
    return closestPlayer;
}
stock PlayerName(playerid)
{
	new name[ MAX_PLAYER_NAME ];
	GetPlayerName( playerid, name, sizeof( name ) );
	return name;
}
stock Killercam( playerid,killerid )
{
	new Float:health;
	new Float:armour;
	GetPlayerHealth(killerid,health);
	GetPlayerArmour(killerid,armour);
	new srv_string[ 256 ];
	format( srv_string, sizeof( srv_string ), "~r~Killsteak ~w~: 1");
	TextDrawSetString( KillerTD7, srv_string );
	new srv_string4[ 256 ];
	format( srv_string4, sizeof( srv_string4 ), "~r~ARMOUR ~w~: %.0f%",armour);
	TextDrawSetString( KillerTD6, srv_string4 );
	new srv_string3[ 256 ];
	format( srv_string3, sizeof( srv_string3 ), "~r~HEALTH ~w~: %.0f%",health);
	TextDrawSetString( KillerTD5, srv_string3 );
	new srv_string2[ 256 ];
	format( srv_string2, sizeof( srv_string2 ), "~g~PLAYER: ~w~: %s",PlayerName(killerid));
	TextDrawSetString( KillerTD4, srv_string2 );
	spawntime=15;
	spawntiming = SetTimerEx("Spawntimer",1000,1,"i",playerid);
	TextDrawShowForPlayer(playerid, KillerTD0);
	TextDrawShowForPlayer(playerid, KillerTD1);
	TextDrawShowForPlayer(playerid, KillerTD2);
	TextDrawShowForPlayer(playerid, KillerTD3);
	TextDrawShowForPlayer(playerid, KillerTD4);
	TextDrawShowForPlayer(playerid, KillerTD5);
	TextDrawShowForPlayer(playerid, KillerTD6);
	TextDrawShowForPlayer(playerid, KillerTD7);
	TextDrawShowForPlayer(playerid, KillerTD8);
	TextDrawShowForPlayer(playerid, KillerTD9);
	return ( 1 );
}

RefillStation( )
{
	gsString[ 0 ] = EOS;
	strcat(gsString,"{3BBD44}Repair Vehicle \t\t {00FF00}$2000\n");
	strcat(gsString,""LBLUE_"Add  Nitro(x10) \t\t {00FF00}$5000\n");
	strcat(gsString,""LBLUE_"Repair and add Nitro \t {00FF00}$6500\t ");
	return gsString;
}
stock JailReleasecnr( liPlayer )
{
	if ( GetPlayerTeam( liPlayer ) == TEAM_ROBBERS)
	{
		SetPlayerSpecialAction( liPlayer, SPECIAL_ACTION_NONE );
		ClearAnimations(liPlayer);
	 	GivePlayerWeapon( liPlayer, 4, 1 );
	  	GivePlayerWeapon( liPlayer, 23, 100 );
	   	GivePlayerWeapon( liPlayer, 26, 100 );
		GivePlayerWeapon( liPlayer, 28, 500 );
		GivePlayerWeapon( liPlayer, 31, 500 );
		GivePlayerWeapon( liPlayer, 34, 100 );
		PlayerInfo[ liPlayer ][ Jailed ] 	= 0;
		Cuffed[ liPlayer ] = false;
		SetPlayerInterior( liPlayer, 0 );
		PlayerPlaySound( liPlayer, 1057, 0.0, 0.0, 0.0 );
		SetPlayerHealth( liPlayer, 100 );
		SetPlayerPos( liPlayer , 2290.1704, 2428.5388, 10.8666 );
		Jailbreak[liPlayer] = 0;
	    TogglePlayerControllable(liPlayer,false);
	    SetCameraBehindPlayer(liPlayer);
	}
	else if ( GetPlayerTeam( liPlayer ) == TEAM_PROROBBERS)
	{
		SetPlayerSpecialAction( liPlayer, SPECIAL_ACTION_NONE );
		ClearAnimations(liPlayer);
		GivePlayerWeapon( liPlayer, 4, 1 );
		GivePlayerWeapon( liPlayer, 29, 1200 );
		GivePlayerWeapon( liPlayer, 31, 2000 );
		GivePlayerWeapon( liPlayer, 26, 600 );
		GivePlayerWeapon( liPlayer, 27, 500 );
		GivePlayerWeapon( liPlayer, 16, 5 );
		GivePlayerWeapon( liPlayer, 34, 200 );
		PlayerInfo[ liPlayer ][ Jailed ] 	= 0;
		Cuffed[ liPlayer ] = false;
		SetPlayerInterior( liPlayer, 0 );
		PlayerPlaySound( liPlayer, 1057, 0.0, 0.0, 0.0 );
		SetPlayerHealth( liPlayer, 100 );
		SetPlayerPos( liPlayer , 2290.1704, 2428.5388, 10.8666 );
		Jailbreak[liPlayer] = 0;
	    TogglePlayerControllable(liPlayer,false);
	    SetCameraBehindPlayer(liPlayer);
	}
	else if ( GetPlayerTeam( liPlayer ) == TEAM_EROBBERS)
	{
		SetPlayerSpecialAction( liPlayer, SPECIAL_ACTION_NONE );
		ClearAnimations(liPlayer);
		GivePlayerWeapon( liPlayer, 4, 1 );
		GivePlayerWeapon( liPlayer, 23, 100 );
		GivePlayerWeapon( liPlayer, 26, 100 );
		GivePlayerWeapon( liPlayer, 28, 500 );
		GivePlayerWeapon( liPlayer, 31, 500 );
		GivePlayerWeapon( liPlayer, 34, 100 );
		GivePlayerWeapon(liPlayer, 35, 4);
		PlayerInfo[ liPlayer ][ Jailed ] 	= 0;
		Cuffed[ liPlayer ] = false;
		SetPlayerInterior( liPlayer, 0 );
		PlayerPlaySound( liPlayer, 1057, 0.0, 0.0, 0.0 );
		SetPlayerHealth( liPlayer, 100 );
		SetPlayerPos( liPlayer , 2290.1704, 2428.5388, 10.8666 );
		Jailbreak[liPlayer] = 0;
	    TogglePlayerControllable(liPlayer,false);
	    SetCameraBehindPlayer(liPlayer);
	}
	return ( 1 );
}
public Zones_Update()
{
	new zone[MAX_ZONE_NAME];
	for(new i=0; i<MAX_PLAYERS; i++){
	GetPlayer2DZone(i, zone, MAX_ZONE_NAME);
	format( PlayerInfo[ i ][ Zone ], 25, "%s", zone);}
	return 1;
}
stock SavePlayerCoords(playerid)
{
  if(IsPlayerConnected(playerid))
  {
	if( PlayerInfo[ playerid ][ INMG] == 0 )
	{
 		new Float:x,Float:y,Float:z,Float:a,Float:health,Float:armour;
   		for( new w=0; w < 13; w++ ) GetPlayerWeaponData( playerid, w, pWeapons[playerid][w], pAmmo[playerid][w] );
		SetPlayerInterior( playerid, 0 );
	 	GetPlayerHealth(playerid,health);
		GetPlayerArmour(playerid,armour);
  		SetPVarFloat(playerid,"HEALTH",health);
   		SetPVarFloat(playerid,"ARMOUR",armour);
		SavedSKIN[playerid]=GetPlayerSkin(playerid);
	    GetPlayerPos(playerid,x,y,z);
	    GetPlayerFacingAngle(playerid,a);
	    SetPVarFloat(playerid,"xpos",x);
	    SetPVarFloat(playerid,"ypos",y);
	    SetPVarFloat(playerid,"zpos",z);
	    SetPVarFloat(playerid,"apos",a);
	    SetPVarInt(playerid,"ipos",GetPlayerInterior(playerid));
	    SetPVarInt(playerid,"vpos",GetPlayerVirtualWorld(playerid));
    }
  }
  return 1;
}

stock LoadPlayerCoords(playerid)
{
	SetPlayerHealth(playerid , GetPVarFloat(playerid,"HEALTH"));
	SetPlayerArmour(playerid , GetPVarFloat(playerid,"ARMOUR"));
	for( new w=0; w < 13; w++ ) if((IsvalidWeapon(pWeapons[playerid][w]) == 1)) GivePlayerWeaponEX( playerid, pWeapons[playerid][w], pAmmo[playerid][w] );
	SetPlayerSkin(playerid,SavedSKIN[playerid]);
	SetPlayerPosEx2(playerid,GetPVarFloat(playerid,"xpos"),GetPVarFloat(playerid,"ypos"),GetPVarFloat(playerid,"zpos"),GetPVarFloat(playerid,"apos"),GetPVarInt(playerid,"ipos"));
	SetPlayerVirtualWorld(playerid, GetPVarInt(playerid,"vpos"));
    DeletePVar(playerid,"xpos"),DeletePVar(playerid,"ypos"),DeletePVar(playerid,"zpos"),DeletePVar(playerid,"apos"),DeletePVar(playerid,"ipos");
    DeletePVar(playerid,"HEALTH"),DeletePVar(playerid,"ARMOUR");
    DeletePVar(playerid,"vpos");

}
stock SetPlayerPosEx2(playerid,Float:x,Float:y,Float:z,Float:a,INT=0)
{
    SetPlayerPos(playerid,x,y,z),SetPlayerFacingAngle(playerid,a);
    SetPlayerInterior(playerid,INT);
	return 1;
}
stock IsvalidWeapon(s_weapon)
{
   new s_Type=0;
   switch(s_weapon)
   {
	  case 18,35,36,37,38: s_Type = 2;
	  case 1..17: s_Type =1;
	  case 22..34:s_Type=1;
	  case 39..46:s_Type=1;
	  default: s_Type = 0;
   }
   //2 --> not allowed weapon
   //1 --> valid
   //0 --> invalid
   return s_Type;
}
stock GivePlayerWeaponEX(playerid,weaponW,ammoW)
{
     if(ammoW > 0 )
     {
       if(IsvalidWeapon(weaponW) == 2)
       {
	     if(GetPlayerVirtualWorld(playerid) != 0)
	     	GivePlayerWeapon(playerid,weaponW,ammoW);
       }
       else GivePlayerWeapon(playerid,weaponW,ammoW);
     }
     return 1;
}

stock GivePlayerMoneyEx(playerid,addcash)
{
	SetPVarInt(playerid, "AllowingCashChange", 1);//to avoid the anti cheat to detect the following stuff to be detected as "hack"
	new OldTempCash = GetPVarInt(playerid, "OldMoney");
	SetPVarInt(playerid, "OldMoney",OldTempCash + addcash); //add the new cash (or subtract if cash is negative)
	ResetPlayerMoney(playerid); //reset the "client" cash - and give the cash the server saved he had.
	GivePlayerMoney(playerid,GetPVarInt(playerid, "OldMoney")); //give the cash
	SetPVarInt(playerid, "AllowingCashChange", 0); //tell the server we are done, and any other changes will be noticed as hacks.
	return 1;
}

stock GetPlayerMoneyEx(playerid)
{
	return GetPVarInt(playerid, "OldMoney");
}

SetPlayerRandomSpawnCR( playerid )
{
	new rand = random( sizeof( gRandomPlayerSpawnscnrrobber ) );
	SetPlayerPos( playerid, gRandomPlayerSpawnscnrrobber[ rand ][ 0 ], gRandomPlayerSpawnscnrrobber[ rand ][ 1 ], gRandomPlayerSpawnscnrrobber[ rand ][ 2 ] );
	return ( 1 );
}
SetPlayerRandomSpawnCC( playerid )
{
	new rand = random( sizeof( gRandomPlayerSpawnscnrcop ) );
	SetPlayerPos( playerid, gRandomPlayerSpawnscnrcop[ rand ][ 0 ], gRandomPlayerSpawnscnrcop[ rand ][ 1 ], gRandomPlayerSpawnscnrcop[ rand ][ 2 ] );
	return ( 1 );
}
CNRRefill( )
{
	gsString[ 0 ] = EOS;
	strcat(gsString,"{FFFFFF}Refill Health\n");
	strcat(gsString,"{FFFFFF}Refill Armour (Premium Only)\n");
	strcat(gsString,"{FFFFFF}Refill Weapons");
	return gsString;
}
stock Announce( playerid, zString[ ], liTime, liStile )
{
	GameTextForPlayer( playerid, zString, liTime, liStile );

	return ( 1 );
}
stock IsPlayerInZone(playerid, zone[])
{
	new TmpZone[MAX_ZONE_NAME];
	GetPlayer3DZone(playerid, TmpZone, sizeof(TmpZone));
	for(new i = 0; i != sizeof(gSAZones); i++)
	{
		if(strfind(TmpZone, zone, true) != -1)
			return 1;
	}
	return 0;
}

stock GetPlayer2DZone(playerid, zone[], len)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
 	for(new i = 0; i != sizeof(gSAZones); i++ )
 	{
		if(x >= gSAZones[i][SAZONE_AREA][0] && x <= gSAZones[i][SAZONE_AREA][3] && y >= gSAZones[i][SAZONE_AREA][1] && y <= gSAZones[i][SAZONE_AREA][4])
		{
		    return format(zone, len, gSAZones[i][SAZONE_NAME], 0);
		}
	}
	return 0;
}
forward CgateRob(playerid);
public CgateRob( playerid ) {
 MoveObject( CnRgate[ 0 ], 1397.23999, 2693.86011, 9.91000, 2.00 );
 MoveObject( CnRgate[ 1 ], 1397.23999, 2694.51001, 9.91000, 2.00 );
}
forward CgateRob2(playerid);
public CgateRob2( playerid ) {
 MoveObject( CnRgate[ 2 ], 2756.9004000,1308.5000000,13.0000000, 2.00 );
 MoveObject( CnRgate[ 3 ], 2756.7998000,1317.9004000,13.0000000, 2.00 );
}
forward Update(playerid);
public Update(playerid)
{
	   foreach (new i : Player)
	   {
          if(IsPlayerInRangeOfPoint(i, 15.00,1391.1689,2694.5232,10.8203))
	      {
		      if( GetPlayerTeam( i ) == TEAM_ROBBERS || GetPlayerTeam( i ) == TEAM_PROROBBERS || GetPlayerTeam( i ) == TEAM_EROBBERS )
		      {

				MoveObject( CnRgate[ 0 ], 1397.0926, 2701.6347, 9.9467, 4.00 );
				MoveObject( CnRgate[ 1 ], 1397.23999, 2688.2905,9.91000, 4.00 );
	            SetTimerEx( "CgateRob", 5000 , 0 , "i" , playerid );
		      }
	      }
	   }
	   foreach (new i : Player)
	   {
          if(IsPlayerInRangeOfPoint(i,15.00,2237.28003, 2448.85010, 9.88000))
	      {
		    if( GetPlayerTeam( i ) == TEAM_COPS || GetPlayerTeam( i ) == TEAM_ARMY || GetPlayerTeam( i ) == TEAM_SWAT )
			{
		        MoveObject(CnRgate[ 4 ] ,2237.28003, 2457.6030, 9.88000, 4.00 );
		        SetTimerEx( "CgateCop", 5000 , 0 , "i" , playerid );
		    }
	      }
	   }
	   foreach (new i : Player)
	   {
          if(IsPlayerInRangeOfPoint(i, 15.00,2756.9004000,1308.5000000,13.0000000))
	      {
		      if( GetPlayerTeam( i ) == TEAM_ROBBERS || GetPlayerTeam( i ) == TEAM_PROROBBERS || GetPlayerTeam( i ) == TEAM_EROBBERS )
		      {

				MoveObject( CnRgate[ 2 ], 2756.9004000,1308.5000000,6.0000000, 4.00 );
				MoveObject( CnRgate[ 3 ], 2756.7998000,1317.9004000,6.0000000, 4.00 );
	            SetTimerEx( "CgateRob2", 5000 , 0 , "i" , playerid );
		      }
	      }
	   }
	   return 1;
}
forward CREATE3D();
public CREATE3D()
{
	CreateDynamic3DTextLabel( "{FF8000}Robbers's\n  {FFFFFF}HQ", 0x33CCFFFF, 1260.3131,2673.1099,10.8203, 30.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 15 );
	CreateDynamic3DTextLabel( "{FF8000}Robbers's\n  {FFFFFF}HQ", 0x33CCFFFF, 2830.4456,1291.6594,10.7729, 30.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 15 );
	CreateDynamic3DTextLabel( "{FF0000}Exit Base", 0x33CCFFFF, 2576.0725,-1304.3121,1060.9844, 30.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 15 );
	CreateDynamic3DTextLabel( "{FF8000}Robber Refill", 0x33CCFFFF, 1301.2958,2674.1523,11.2392, 30.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 15 );
	CreateDynamic3DTextLabel( "{FF8000}Robber Refill", 0x33CCFFFF, 2817.1924,1282.4027,10.9609, 30.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 15 );
	CreateDynamic3DTextLabel( "{004BFF}LVPD Refill", 0x33CCFFFF, 2298.0181,2466.5144,3.2734, 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 15 );
	CreateDynamic3DTextLabel( "{0000FF}LVPD Refill", 0x33CCFFFF, 1640.8662,1573.5791,10.8203, 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 15 );
	CreateDynamic3DTextLabel( "{8000FF}LVPD Refill", 0x33CCFFFF, 319.0746,2006.3840,17.6406, 20.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 15 );
	CreateDynamic3DTextLabel( "{00FF00}Bank", 0xF67E0FF, 2270.8967,2291.8743,10.8203, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{00FF00}Bank", 0xF67E0FF, 2354.9150,1543.8160,10.8203, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{0000FF}Police Station", 0xF67E0FF, 2286.5427,2430.6497,10.8203, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{FF00FF}Royal Casino", 0xF67E0FF, 2090.0652,1514.6912,10.8203, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{FF8000}4 Dragons", 0xF67E0FF, 2019.5112,1007.6406,10.8203, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{FF8000}Casino", 0xF67E0FF, 2167.4512,2115.5269,10.8203, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{FFFFFF}Wang's\n {00FFFF}Private Vehicles", 0xF67E0FF, -1958.2229,292.4807,35.4688, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
    CreateDynamic3DTextLabel( "{0000FF}Bank", 0xF67E0FF,-1551.7205,1168.7186,7.1875, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
   	CreateDynamic3DTextLabel( "{FF8000}Binco", 0xF67E0FF, 2103.1604,2257.4949,11.0234, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
   	CreateDynamic3DTextLabel( "{FF8000}Binco", 0xF67E0FF, 1655.3794,1733.4390,10.8281, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
   	CreateDynamic3DTextLabel( "{FF8000}Ammunation", 0xF67E0FF, 2158.7559,943.2726,10.8203, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
   	CreateDynamic3DTextLabel( "{FF8000}Ammunation", 0xF67E0FF, 2537.9285,2083.9502,10.8203, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{FF8000}Cluckin Bell", 0xF67E0FF, 2638.4160,1671.6783,11.0234, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{FF8000}Well Stacked Pizza", 0xF67E0FF,2638.4282,1850.0570,11.0234, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{FF8000}Burger Shot", 0xF67E0FF, 2170.3120,2794.9949,10.8203, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{FF8000}Burger Shot", 0xF67E0FF, 2472.1184,2034.2938,11.0625, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{FF8000}Burger Shot", 0xF67E0FF, 2365.7756,2071.0264,10.8203, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{FF8000}Burger Shot", 0xF67E0FF, 1158.5654,2072.2627,11.0625, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{FF8000}24/7", 0xF67E0FF, 2097.5088,2223.6741,11.0234, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{FF8000}24/7", 0xF67E0FF, 1937.2565,2307.3269,10.8203, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{FF8000}24/7", 0xF67E0FF, 2194.0891,1991.0579,12.2969, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{FF8000}24/7", 0xF67E0FF, 2884.9958,2453.5703,11.0690, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{FF8000}Well Stacked Pizza", 0xF67E0FF,2763.7302,2469.0498,11.0625, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	CreateDynamic3DTextLabel( "{FF8000}Cluckin Bell", 0xF67E0FF, 2846.1580,2415.1174,11.0690, 100, INVALID_PLAYER_ID,INVALID_VEHICLE_ID, 0, -1, -1, -1, 20.0 );
	return 1;
}
forward CgateCop(playerid);
public CgateCop( playerid ) return MoveObject( CnRgate[ 4 ], 2237.28003, 2448.85010, 9.88000, 2.00 );
stock GetPlayer3DZone(playerid, zone[], len)
{
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
 	for(new i = 0; i != sizeof(gSAZones); i++ )
 	{
		if(x >= gSAZones[i][SAZONE_AREA][0] && x <= gSAZones[i][SAZONE_AREA][3] && y >= gSAZones[i][SAZONE_AREA][1] && y <= gSAZones[i][SAZONE_AREA][4] && z >= gSAZones[i][SAZONE_AREA][2] && z <= gSAZones[i][SAZONE_AREA][5])
		{
		    return format(zone, len, gSAZones[i][SAZONE_NAME], 0);
		}
	}
	return 0;
}
forward RobTimmer(playerid);
public RobTimmer( playerid ) return RobOn[ playerid ] = ( 0 ); // ROB


//CallDisconnect = OnPlayerDisconnect
forward CallDisconnect(playerid,reason);
public CallDisconnect(playerid,reason)
{
	Deaths[playerid] = 0;
}

//CallConnect = OnPlayerConnect
forward CallConnect(playerid,reason);
public CallConnect(playerid,reason)
{
	Deaths[playerid] = 0;
}

//CallDeath = OnPlayerDeath
forward CallDeath(playerid, killerid, reason);
public CallDeath(playerid, killerid, reason)
{
	Deaths[playerid]++;
	if (Deaths[playerid] > Death_Limit)
	{
		new pname[MAX_PLAYER_NAME], string[128 + MAX_PLAYER_NAME];
        GetPlayerName(playerid, pname, sizeof(pname));
        format(string, sizeof(string), "%s has been automatically kicked by the Anti-Death Spam System", pname);
        SendClientMessageToAll(COLOR_GREY, string);
	    Kick(playerid);
	}
	return 1;
}

forward AntiDeathSpam();
public AntiDeathSpam()
{
	for(new p=0; p<MAX_PLAYERS; p++)
	{
		Deaths[p] = 0;
	}
	return 1;
}
//======== Gang STOCKS ========//
stock Names(playerid)
{
	new pname[MAX_PLAYER_NAME];
	GetPlayerName(playerid,pname,sizeof(pname));
	return pname;
}

stock ini_GetKey( line[] )
{
	new keyRes[256];
	keyRes[0] = 0;
    if ( strfind( line , "=" , true ) == -1 ) return keyRes;
    strmid( keyRes , line , 0 , strfind( line , "=" , true ) , sizeof( keyRes) );
    return keyRes;
}

function LoadRaceNames()
{
	new
	    rNameFile[64],
	    string[64]
	;
	format(rNameFile, sizeof(rNameFile), "/Race/RaceNames/RaceNames.txt");
	TotalRaces = dini_Int(rNameFile, "TotalRaces");
	Loop2(x, TotalRaces)
	{
	    format(string, sizeof(string), "Race_%d", x), strmid(RaceNames[x], dini_Get(rNameFile, string), 0, 20, sizeof(RaceNames));
	    printf(">> Loaded Races: %s", RaceNames[x]);
	}
	return 1;
}

function LoadAutoRace(rName[])
{
	new
		rFile[256],
		string[256]
	;
    //SetTimer("RaceTimer", 1000*900, true);
	for(new i = 0; i < MAX_PLAYERS; i++) {
	SetTimerEx("RaceTimer", 900000, true, "AutomaticRace", i);}
	format(rFile, sizeof(rFile), "/Race/%s.RRACE", rName);
	if(!dini_Exists(rFile)) return printf("Race \"%s\" doesn't exist!", rName);
	strmid(RaceName, rName, 0, strlen(rName), sizeof(RaceName));
	RaceVehicle = dini_Int(rFile, "vModel");
	RaceType = dini_Int(rFile, "rType");
	TotalCP = dini_Int(rFile, "TotalCP");

	#if DEBUG_RACE == 1
	printf("VehicleModel: %d", RaceVehicle);
	printf("RaceType: %d", RaceType);
	printf("TotalCheckpoints: %d", TotalCP);
	#endif

	Loop2(x, 2)
	{
		format(string, sizeof(string), "vPosX_%d", x), RaceVehCoords[x][0] = dini_Float(rFile, string);
		format(string, sizeof(string), "vPosY_%d", x), RaceVehCoords[x][1] = dini_Float(rFile, string);
		format(string, sizeof(string), "vPosZ_%d", x), RaceVehCoords[x][2] = dini_Float(rFile, string);
		format(string, sizeof(string), "vAngle_%d", x), RaceVehCoords[x][3] = dini_Float(rFile, string);
		#if DEBUG_RACE == 1
		printf("VehiclePos %d: %f, %f, %f, %f", x, RaceVehCoords[x][0], RaceVehCoords[x][1], RaceVehCoords[x][2], RaceVehCoords[x][3]);
		#endif
	}
	Loop2(x, TotalCP)
	{
 		format(string, sizeof(string), "CP_%d_PosX", x), CPCoords[x][0] = dini_Float(rFile, string);
 		format(string, sizeof(string), "CP_%d_PosY", x), CPCoords[x][1] = dini_Float(rFile, string);
 		format(string, sizeof(string), "CP_%d_PosZ", x), CPCoords[x][2] = dini_Float(rFile, string);
 		#if DEBUG_RACE == 1
 		printf("RaceCheckPoint %d: %f, %f, %f", x, CPCoords[x][0], CPCoords[x][1], CPCoords[x][2]);
 		#endif
	}
	Position = 0;
	FinishCount = 0;
	JoinCount = 0;
	Loop2(x, 2) PlayersCount[x] = 0;
	CountAmount = COUNT_DOWN_TILL_RACE_START;
	RaceTime = MAX_RACE_TIME;
	RaceBusy = 0x01;
	CountTimer = SetTimer("CountTillRace", 999, 1);
	TimeProgress = 0;
	return 1;
}

function LoadRace(playerid, rName[])
{
	new
		rFile[256],
		string[256]
	;
	format(rFile, sizeof(rFile), "/Race/%s.RRACE", rName);
	if(!dini_Exists(rFile)) return SendClientMessage(playerid, COLRED, "<!> Race doesn't exist!"), printf("Race \"%s\" doesn't exist!", rName);
	strmid(RaceName, rName, 0, strlen(rName), sizeof(RaceName));
	RaceVehicle = dini_Int(rFile, "vModel");
	RaceType = dini_Int(rFile, "rType");
	TotalCP = dini_Int(rFile, "TotalCP");

	#if DEBUG_RACE == 1
	printf("VehicleModel: %d", RaceVehicle);
	printf("RaceType: %d", RaceType);
	printf("TotalCheckpoints: %d", TotalCP);
	#endif

	Loop2(x, 2)
	{
		format(string, sizeof(string), "vPosX_%d", x), RaceVehCoords[x][0] = dini_Float(rFile, string);
		format(string, sizeof(string), "vPosY_%d", x), RaceVehCoords[x][1] = dini_Float(rFile, string);
		format(string, sizeof(string), "vPosZ_%d", x), RaceVehCoords[x][2] = dini_Float(rFile, string);
		format(string, sizeof(string), "vAngle_%d", x), RaceVehCoords[x][3] = dini_Float(rFile, string);
		#if DEBUG_RACE == 1
		printf("VehiclePos %d: %f, %f, %f, %f", x, RaceVehCoords[x][0], RaceVehCoords[x][1], RaceVehCoords[x][2], RaceVehCoords[x][3]);
		#endif
	}
	Loop2(x, TotalCP)
	{
 		format(string, sizeof(string), "CP_%d_PosX", x), CPCoords[x][0] = dini_Float(rFile, string);
 		format(string, sizeof(string), "CP_%d_PosY", x), CPCoords[x][1] = dini_Float(rFile, string);
 		format(string, sizeof(string), "CP_%d_PosZ", x), CPCoords[x][2] = dini_Float(rFile, string);
 		#if DEBUG_RACE == 1
 		printf("RaceCheckPoint %d: %f, %f, %f", x, CPCoords[x][0], CPCoords[x][1], CPCoords[x][2]);
 		#endif
	}
	Position = 0;
	FinishCount = 0;
	JoinCount = 0;
	Loop2(x, 2) PlayersCount[x] = 0;
	Joined[playerid] = true;
	CountAmount = COUNT_DOWN_TILL_RACE_START;
	RaceTime = MAX_RACE_TIME;
	RaceBusy = 0x01;
	TimeProgress = 0;
	SetupRaceForPlayer(playerid);
	CountTimer = SetTimer("CountTillRace", 999, 1);
	return 1;
}

function SetCP(playerid, PrevCP, NextCP, MaxCP, Type)
{
	if(Type == 0)
	{
		if(NextCP == MaxCP) SetPlayerRaceCheckpoint(playerid, 1, CPCoords[PrevCP][0], CPCoords[PrevCP][1], CPCoords[PrevCP][2], CPCoords[NextCP][0], CPCoords[NextCP][1], CPCoords[NextCP][2], RACE_CHECKPOINT_SIZE);
			else SetPlayerRaceCheckpoint(playerid, 0, CPCoords[PrevCP][0], CPCoords[PrevCP][1], CPCoords[PrevCP][2], CPCoords[NextCP][0], CPCoords[NextCP][1], CPCoords[NextCP][2], RACE_CHECKPOINT_SIZE);
	}
	else if(Type == 3)
	{
		if(NextCP == MaxCP) SetPlayerRaceCheckpoint(playerid, 4, CPCoords[PrevCP][0], CPCoords[PrevCP][1], CPCoords[PrevCP][2], CPCoords[NextCP][0], CPCoords[NextCP][1], CPCoords[NextCP][2], RACE_CHECKPOINT_SIZE);
			else SetPlayerRaceCheckpoint(playerid, 3, CPCoords[PrevCP][0], CPCoords[PrevCP][1], CPCoords[PrevCP][2], CPCoords[NextCP][0], CPCoords[NextCP][1], CPCoords[NextCP][2], RACE_CHECKPOINT_SIZE);
	}
	return 1;
}

function SetupRaceForPlayer(playerid)
{
	CPProgess[playerid] = 0;
	TogglePlayerControllable(playerid, false);
	CPCoords[playerid][3] = 0;
	SetCP(playerid, CPProgess[playerid], CPProgess[playerid]+1, TotalCP, RaceType);
	if(IsOdd(playerid)) Index = 1;
	    else Index = 0;

	switch(Index)
	{
		case 0:
		{
		    if(PlayersCount[0] == 1)
		    {
				RaceVehCoords[0][0] -= (6 * floatsin(-RaceVehCoords[0][3], degrees));
		 		RaceVehCoords[0][1] -= (6 * floatcos(-RaceVehCoords[0][3], degrees));
		   		CreatedRaceVeh[playerid] = CreateVehicle(RaceVehicle, RaceVehCoords[0][0], RaceVehCoords[0][1], RaceVehCoords[0][2]+2, RaceVehCoords[0][3], random(126), random(126), (60 * 60));
				SetPlayerPos(playerid, RaceVehCoords[0][0], RaceVehCoords[0][1], RaceVehCoords[0][2]+2);
				SetPlayerFacingAngle(playerid, RaceVehCoords[0][3]);
				PutPlayerInVehicle(playerid, CreatedRaceVeh[playerid], 0);
				Camera(playerid, RaceVehCoords[0][0], RaceVehCoords[0][1], RaceVehCoords[0][2], RaceVehCoords[0][3], 20);
			}
		}
		case 1:
 		{
 		    if(PlayersCount[1] == 1)
 		    {
				RaceVehCoords[1][0] -= (6 * floatsin(-RaceVehCoords[1][3], degrees));
		 		RaceVehCoords[1][1] -= (6 * floatcos(-RaceVehCoords[1][3], degrees));
		   		CreatedRaceVeh[playerid] = CreateVehicle(RaceVehicle, RaceVehCoords[1][0], RaceVehCoords[1][1], RaceVehCoords[1][2]+2, RaceVehCoords[1][3], random(126), random(126), (60 * 60));
				SetPlayerPos(playerid, RaceVehCoords[1][0], RaceVehCoords[1][1], RaceVehCoords[1][2]+2);
				SetPlayerFacingAngle(playerid, RaceVehCoords[1][3]);
				PutPlayerInVehicle(playerid, CreatedRaceVeh[playerid], 0);
				Camera(playerid, RaceVehCoords[1][0], RaceVehCoords[1][1], RaceVehCoords[1][2], RaceVehCoords[1][3], 20);
    		}
 		}
	}
	switch(Index)
	{
	    case 0:
		{
			if(PlayersCount[0] != 1)
			{
		   		CreatedRaceVeh[playerid] = CreateVehicle(RaceVehicle, RaceVehCoords[0][0], RaceVehCoords[0][1], RaceVehCoords[0][2]+2, RaceVehCoords[0][3], random(126), random(126), (60 * 60));
				SetPlayerPos(playerid, RaceVehCoords[0][0], RaceVehCoords[0][1], RaceVehCoords[0][2]+2);
				SetPlayerFacingAngle(playerid, RaceVehCoords[0][3]);
				PutPlayerInVehicle(playerid, CreatedRaceVeh[playerid], 0);
				Camera(playerid, RaceVehCoords[0][0], RaceVehCoords[0][1], RaceVehCoords[0][2], RaceVehCoords[0][3], 20);
			    PlayersCount[0] = 1;
		    }
	    }
	    case 1:
	    {
			if(PlayersCount[1] != 1)
			{
		   		CreatedRaceVeh[playerid] = CreateVehicle(RaceVehicle, RaceVehCoords[1][0], RaceVehCoords[1][1], RaceVehCoords[1][2]+2, RaceVehCoords[1][3], random(126), random(126), (60 * 60));
				SetPlayerPos(playerid, RaceVehCoords[1][0], RaceVehCoords[1][1], RaceVehCoords[1][2]+2);
				SetPlayerFacingAngle(playerid, RaceVehCoords[1][3]);
				PutPlayerInVehicle(playerid, CreatedRaceVeh[playerid], 0);
				Camera(playerid, RaceVehCoords[1][0], RaceVehCoords[1][1], RaceVehCoords[1][2], RaceVehCoords[1][3], 20);
				PlayersCount[1] = 1;
		    }
   		}
	}
	#if defined RACE_IN_OTHER_WORLD
	SetPlayerVirtualWorld(playerid, 10);
	#endif
	/*InfoTimer[playerid] = SetTimerEx("TextInfo", 500, 1, "e", playerid);
	new string[128];
    format(string, sizeof(string), "RaceName: ~w~%s~n~~p~~h~Checkpoint: ~w~%d/%d~n~~b~~h~RaceTime: ~w~%s~n~~y~RacePosition: ~w~%d/%d~n~ ", RaceName, CPProgess[playerid], TotalCP, TimeConvert(RaceTime), RacePosition[playerid], JoinCount);
	TextDrawSetString(RaceInfo[playerid], string);
	TextDrawShowForPlayer(playerid, RaceInfo[playerid]);*/
	JoinCount++;
	return 1;
}

function TextInfo(playerid)
{
	new
	    string[128]
	;
	format(string, sizeof(string), "RaceName: ~w~%s~n~~p~~h~Checkpoint: ~w~%d/%d~n~~b~~h~RaceTime: ~w~%s~n~~y~RacePosition: ~w~%d/%d~n~", RaceName, CPProgess[playerid], TotalCP, TimeConvert(RaceTime), RacePosition[playerid], JoinCount);
    TextDrawSetString(RaceInfo[playerid], string);
    TextDrawShowForPlayer(playerid, RaceInfo[playerid]);
}

function CountTillRace()
{
	switch(CountAmount)
	{
 		case 0:
	    {
			ForEach(i, MAX_PLAYERS)
			{
			    if(Joined[i] == false)
			    {
					SendClientMessage(i, COLRED, "You can't join the race. Join time is over!");
				}
			}
			StartRace();
	    }
	    case 1..5:
	    {
	        new
	            string[10]
			;
			format(string, sizeof(string), "~b~%d", CountAmount);
			ForEach(i, MAX_PLAYERS)
			{
			    if(Joined[i] == true)
			    {
			    	GameTextForPlayer(i, string, 999, 5);
			    	PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
			    }
			}
	    }
	    case 60, 50, 40, 30:
	    {
            new string[128];
	        format(string, sizeof(string), ">> Race: \"%s\" has been started, Type: /join to join it!", RaceName);
			SendClientMessageToAll(COLGREEN, string);
	    }
		case 10:
		{
            new string[128];
		    format(string, sizeof(string), ">> \"%d\" seconds left to join \"%s\", Type: /join to join it!", CountAmount, RaceName);
			SendClientMessageToAll(COLGREEN, string);
		}
	}
	return CountAmount--;
}

function StartRace()
{
	ForEach(i, MAX_PLAYERS)
	{
		if(Joined[i] == true)
	    {
	        TogglePlayerControllable(i, true);
	        PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
  			GameTextForPlayer(i, "~g~GO GO GO", 2000, 5);
			SetCameraBehindPlayer(i);
	        Nitro[i] = 0;
	        Bounce[i] = 0;
	        AutoFix[i] = 0;
            SetPVarInt(i, "InRace", 1);
            RaceInfo[i] = TextDrawCreate(600.029602, 290.916473, " ");
            TextDrawAlignment(RaceInfo[i], 3);
            TextDrawBackgroundColor(RaceInfo[i], 255);
            TextDrawFont(RaceInfo[i], 1);
            TextDrawLetterSize(RaceInfo[i], 0.240000, 1.100000);
            TextDrawColor(RaceInfo[i], -687931137);
            TextDrawSetOutline(RaceInfo[i], 0);
            TextDrawSetProportional(RaceInfo[i], 1);
            TextDrawSetShadow(RaceInfo[i], 1);
			InfoTimer[i] = SetTimerEx("TextInfo", 500, 1, "e", i);
        }
	}
	rCounter = SetTimer("RaceCounter", 900, 1);
	RaceTick = GetTickCount();
	RaceStarted = 1;
	KillTimer(CountTimer);
	return 1;
}

function StopRace()
{
	KillTimer(rCounter);
	RaceStarted = 0;
	RaceTick = 0;
	RaceBusy = 0x00;
	JoinCount = 0;
	FinishCount = 0;
    TimeProgress = 0;

	ForEach(i, MAX_PLAYERS)
	{
	    if(Joined[i] == true)
	    {
	    	DisablePlayerRaceCheckpoint(i);
	    	DestroyVehicle(CreatedRaceVeh[i]);
	        Nitro[i] = 1;
	        Bounce[i] = 1;
	        AutoFix[i] = 1;
			Joined[i] = false;
            SetPVarInt(i, "InRace", 0);
			TextDrawHideForPlayer(i, RaceInfo[i]);
	        TextDrawDestroy(RaceInfo[i]);
			CPProgess[i] = 0;
			KillTimer(InfoTimer[i]);
		}
	}
	SendClientMessageToAll(COLYELLOW, ">> Race time is over!");
	if(AutomaticRace == true) LoadRaceNames(), LoadAutoRace(RaceNames[random(TotalRaces)]);
	return 1;
}

function RaceCounter()
{
	if(RaceStarted == 1)
	{
		RaceTime--;
		if(JoinCount <= 0)
		{
			StopRace();
			SendClientMessageToAll(COLRED, ">> Race ended.. No one left in the race!");
		}
	}
	if(RaceTime <= 0)
	{
	    StopRace();
	}
	return 1;
}

function Camera(playerid, Float:rX, Float:rY, Float:rZ, Float:rA, Mul)
{
	//SetPlayerCameraLookAt(playerid, rX, rY, rZ);
	SetPlayerCameraPos(playerid, rX + (Mul * floatsin(-rA, degrees)), rY + (Mul * floatcos(-rA, degrees)), Z+6);
    SetCameraBehindPlayer(playerid);
}

ProxDetectorS(Float:radi, playerid, targetid)
{
	if(IsPlayerConnected(playerid)&&IsPlayerConnected(targetid))
	{
	    if(GetPlayerState(targetid) != PLAYER_STATE_SPECTATING)
	    {
	        if(GetPlayerVirtualWorld(targetid) == GetPlayerVirtualWorld(playerid))
	        {
				new Float:posx, Float:posy, Float:posz;
				new Float:oldposx, Float:oldposy, Float:oldposz;
				new Float:tempposx, Float:tempposy, Float:tempposz;
				GetPlayerPos(playerid, oldposx, oldposy, oldposz);
				//radi = 2.0; //Trigger Radius
				GetPlayerPos(targetid, posx, posy, posz);
				tempposx = (oldposx -posx);
				tempposy = (oldposy -posy);
				tempposz = (oldposz -posz);
				//printf("DEBUG: X:%f Y:%f Z:%f",posx,posy,posz);
				if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
				{
					return 1;
				}
			}
		}
	}
	return 0;
}

stock PlayerNameEx(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
    new i;
    while(name[i])
    {
        if(name[i] == '_')  name[i] = ' ';
        i++;
    }
    return name;
}

function IsPlayerInRace(playerid)
{
	if(Joined[playerid] == true) return true;
	    else return false;
}

function ShowDialog(playerid, dialogid)
{
	switch(dialogid)
	{
		case 599: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateCaption("Build New Race"), "\
		Normal Race\n\
		Air Race", "Next", "Exit");

	    case 600: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateCaption("Build New Race (Step 1/4)"), "\
		Step 1:\n\
		********\n\
 		Welcome to wizard 'Build New Race'.\n\
		Before getting started, I need to know the name (e.g. SFRace) of the to save it under.\n\n\
		>> Give the NAME below and press 'Next' to continue.", "Next", "Back");

	    case 601: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateCaption("Build New Race (Step 1/4)"), "\
	    ERROR: Name too short or too long! (min. 1 - max. 20)\n\n\n\
		Step 1:\n\
		********\n\
 		Welcome to wizard 'Build New Race'.\n\
		Before getting started, I need to know the name (e.g. SFRace) of the to save it under.\n\n\
		>> Give the NAME below and press 'Next' to continue.", "Next", "Back");

		case 602: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateCaption("Build New Race (Step 2/4)"), "\
		Step 2:\n\
		********\n\
		Please give the ID or NAME of the vehicle that's going to be used in the race you are creating now.\n\n\
		>> Give the ID or NAME of the vehicle below and press 'Next' to continue. 'Back' to change something.", "Next", "Back");

		case 603: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateCaption("Build New Race (Step 2/4)"), "\
		ERROR: Invalid Vehilce ID/Name\n\n\n\
		Step 2:\n\
		********\n\
		Please give the ID or NAME of the vehicle that's going to be used in the race you are creating now.\n\n\
		>> Give the ID or NAME of the vehicle below and press 'Next' to continue. 'Back' to change something.", "Next", "Back");

		case 604: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, CreateCaption("Build New Race (Step 3/4)"),
		"\
		Step 3:\n\
		********\n\
		We are almost done! Now go to the start line where the first and second car should stand.\n\
		Note: When you click 'OK' you will be free. Use 'KEY_FIRE' to set the first position and second position.\n\
		Note: After you got these positions you will automaticly see a dialog to continue the wizard.\n\n\
		>> Press 'OK' to do the things above. 'Back' to change something.", "OK", "Back");

		case 605: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, CreateCaption("Build New Race (Step 4/4)"),
		"\
		Step 4:\n\
		********\n\
		Welcome to the last stap. In this stap you have to set the checkpoints; so if you click 'OK' you can set the checkpoints.\n\
		You can set the checkpoints with 'KEY_FIRE'. Each checkpoint you set will save.\n\
		You have to press 'ENTER' button when you're done with everything. You race is aviable then!\n\n\
		>> Press 'OK' to do the things above. 'Back' to change something.", "OK", "Back");

		case 606: ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, CreateCaption("Build New Race (Done)"),
		"\
		You have created your race and it's ready to use now.\n\n\
		>> Press 'Finish' to finish. 'Exit' - Has no effect.", "Finish", "Exit");
	}
	return 1;
}

CreateCaption(arguments[])
{
	new
	    string[128 char]
	;
	format(string, sizeof(string), "Race System - %s", arguments);
	return string;
}

stock GetVehicleModelIDFromName(vname[])
{
        for(new i = 0; i < 212; i++)
        {
                if(strfind(vNames[i], vname, true) != -1)
                return i + 400;
        }
        return -1;
}

stock IsValidVehicle(vehicleid)
{
	if(vehicleid < 400 || vehicleid > 611) return false;
	    else return true;
}

ReturnVehicleID(vName[])
{
	Loop2(x, 212)
	{
	    if(strfind(vNames[x], vName, true) != -1)
		return x + 400;
	}
	return -1;
}

TimeConvert(tseconds)
{
	new tmp[16];
 	new minutes = floatround(tseconds/60);
  	tseconds -= minutes*60;
   	format(tmp, sizeof(tmp), "%d:%02d", minutes, tseconds);
   	return tmp;
}

stock ini_GetValue( line[] )
{
	new valRes[256];
	valRes[0]=0;
	if ( strfind( line , "=" , true ) == -1 ) return valRes;
	strmid( valRes , line , strfind( line , "=" , true )+1 , strlen( line ) , sizeof( valRes ) );
	return valRes;
}

public VanMovedTimer(playerid)
{
	new Float:vansX,Float:vansY,Float:vansZ;
    if(!Counting)
    {
    KillTimer(VanMoved);
    C4[playerid] = 0;
    DetonateC4[playerid] = 1;
    SendClientMessage(playerid, -1,"The C4 is planted.[/blastc4]");
    //ClearAnimations
    }
    else
    {
    	new SVID = SecurityVanID[playerid];
    	GetVehiclePos(SVID, vansX,vansY,vansZ);
	    if(X == VanX && Y == VanY && Z == VanZ)
	    {
	        new string[128];
	        format(string,sizeof(string),"%i",CountTime);
	        GameTextForPlayer(playerid,string,1000,5);
	        CountTime --;
	        if(CountTime == 0)
	        {
	            Counting = 0;
	        }
		}
		else
		{
		KillTimer(VanMoved);
		SendClientMessage(playerid, -1,"The Security Van moved while planting the C4!");
		}
    }
    return 1;
}

public SecureMoney(playerid)
{
	SendClientMessage(playerid, -1,"The money is secured now.");
	FullBag[playerid] = 0;
	KillTimer(SMoney);
	return 1;
}

public FillingBags(playerid)
{
    if(!BagCounting)
    {
	KillTimer(FBTimer);
	FullBag[playerid] = 1;
	GivePlayerMoney(playerid, 300000-400000);
	SendClientMessage(playerid, -1,"Your robbed the Security Van, and robbed $%d");
	SendClientMessage(playerid, -1,"Leave the area. If you die, you will lose the money![10 minutes untill the money is Secure]");
	//ClearAnimations
	SMoney = SetTimerEx("SecureMoney",600000,false,"i",playerid);
	}
	else
	{
	new string[128];
 	format(string,sizeof(string),"%i",BagTime);
	GameTextForPlayer(playerid,string,1000,5);
	BagTime --;
	if(BagTime == 0)
	{
		BagCounting = 0;
  	}
  	}
  	return 1;
}
//Stocks
stock SecurityVan(vehicleid)
{
	switch(GetVehicleModel(vehicleid))
	{
		case 428: return 1;
	}
	return 0;
}

stock GetDistanceToCar(playerid, veh, Float: posX = 0.0, Float: posY = 0.0, Float: posZ = 0.0)
{
	new Float: Floats[2][3];
	if(posX == 0.0 && posY == 0.0 && posZ == 0.0)
	{
		if(!IsPlayerInAnyVehicle(playerid)) GetPlayerPos(playerid, Floats[0][0], Floats[0][1], Floats[0][2]);
		else GetVehiclePos(GetPlayerVehicleID(playerid), Floats[0][0], Floats[0][1], Floats[0][2]);
	}
	else
	{
		Floats[0][0] = posX;
		Floats[0][1] = posY;
		Floats[0][2] = posZ;
	}
	GetVehiclePos(veh, Floats[1][0], Floats[1][1], Floats[1][2]);
	return floatround(floatsqroot((Floats[1][0] - Floats[0][0]) * (Floats[1][0] - Floats[0][0]) + (Floats[1][1] - Floats[0][1]) * (Floats[1][1] - Floats[0][1]) + (Floats[1][2] - Floats[0][2]) * (Floats[1][2] - Floats[0][2])));
}

stock GetClosestCar(playerid, exception = INVALID_VEHICLE_ID)
{
    new Float: Distance,target = -1,Float: vPos[3];
	if(!IsPlayerInAnyVehicle(playerid)) GetPlayerPos(playerid, vPos[0], vPos[1], vPos[2]);
	else GetVehiclePos(GetPlayerVehicleID(playerid), vPos[0], vPos[1], vPos[2]);
    for(new v; v < MAX_VEHICLES; v++) if(GetVehicleModel(v) >= 400)
	{
    if(v != exception && (target < 0 || Distance > GetDistanceToCar(playerid, v, vPos[0], vPos[1], vPos[2])))
	{
 		target = v;
   		Distance = GetDistanceToCar(playerid, v, vPos[0], vPos[1], vPos[2]);
 	}
    }
    return target;
}

//Gate System
forward GateCheck();
public GateCheck()
{
	//Close
    for(new g=0, all=sizeof(gates); g<all; g++)
    {
        if(gates[g][ag_timer] && (gettime() > gates[g][ag_timer]))
        {
            if(gates[g][ag_status] == false)
            {
	        	gates[g][ag_timer] = 0;
				MoveObject(gates[g][ag_id], gates[g][ag_closePos][0], gates[g][ag_closePos][1], gates[g][ag_closePos][2], 8.0);
			}
		}
    }

	for(new i=0, t=GetMaxPlayers(); i<t; i++)
	{
	    if(!IsPlayerConnected(i)) continue;

	    for(new g=0, all=sizeof(gates); g<all; g++)
	    {
	        if(IsPlayerInRangeOfPoint(i, 10.0, gates[g][ag_closePos][0], gates[g][ag_closePos][1], gates[g][ag_closePos][2]))
	        {
				if(gettime() > gates[g][ag_timer])
	    		{
	    		    switch(gates[g][ag_status])
	    		    {
	    		        case false:
	    		        {
							gates[g][ag_timer] = gettime() + 4;
	    		            MoveObject(gates[g][ag_id], gates[g][ag_openPos][0], gates[g][ag_openPos][1], gates[g][ag_openPos][2], 8.0);
	    		        }
	    		    }
	    		    return 1;
	    		}
			}
		}
	 }
	 return 1;
}
//------------------------------- END ----------------------------------------//

/*
							 ____________     _______         ______
							|____    ____|   |   __  \      / ______\
								 |  |        |  |  |  |    | /
								 |  |        |  |__|  /    | \ _____
		 						 |  |        |   __  |     \______  \
								 |  |        |  |  |  \           \ |
								 |  |        |  |__|  |     ______/ |
								 |__|		 |_______/     \________/
								 
	   ------------------------------------------------------------------------------------------
	   ------------------------------------------------------------------------------------------
	   ------------------------------------------------------------------------------------------
*/

