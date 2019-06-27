/*
Ladmin System for The Best Stunts - Official SA:MP Server (TBSMain.pwn)
On Build: 17
*/

#include <a_samp>
#include <a_sampdb>
#include <lethaldudb2>
#include <sscanf2>
#include <fly>
#include <foreach>
#include <streamer>
#include <dini>
#include <dudb>
#include <timestamptodate>
//lotto
#pragma tabsize 0


//Ranks
new Text3D:label6;
new Text3D:label7;
new Text3D:label8;
new Text3D:label9;
new Text3D:label10;
new Text3D:label11;
new Text3D:label12;
new Text3D:label13;
new Text3D:label14;
new Text3D:label15;
new Text3D:label16;

//Gate System By fReAkeD
#define MAX_GATES 200

#define GATE_STATE_CLOSED	 0
#define GATE_STATE_OPEN 	 1

enum gInfo
{
    gate_id,
    gate_title[128],
	gate_password[128],
    Float:gateX,
    Float:gateY,
    Float:gateZ,
	Float:gateA,
	gateLabel[128],
	gate_object,
	gate_status,
	gate_created
};

new
	xGates,
	DB:GATESDB,
	Gates[MAX_GATES][gInfo]
;

////lotto
#define LOTTO_PRICE 5000 //price of lotto ticket
#define MAX_LOTTO_JACKPOT_INCREASE 200 //jackpot grows every second with a random value, which can not be bigger than stated here
#define NEON 1337 // Dialogid
#define SkinList "tbsServer/skins.txt"
new bool:pInvincible[MAX_PLAYERS];

new LottoParticipant[MAX_PLAYERS];
new PlayerLottoGuess[MAX_PLAYERS];
new NumberUsed[99];
new LottoJackpot = 1;
new PSkinID[MAX_PLAYERS];
new gHour = 0;
new gMinutes = 0;
new shifthour;
new ghour = 0;
new gminute = 0;
new gsecond = 0;
new realtime = 1;
new timeshift = -1;

forward public LottoDraw();
forward public LottoJackpotIncrease();

//==============================================================================
// -> Use Two Rcon Passwords (Only if 'EnableTwoRcon' is enabled(True) !)
//==============================================================================
#define TwoRconPass "UltraGameHostFilipbgDanAmeliaV1999" //Define the Second RCON Password
#define MAX_RCON_ATTEMPS    2 		// Max Rcon Attemps
#define EnableTwoRcon 		true    // Enable/Disable Two Rcon Passwords (2 Rcon passwords for more security!)
#define DIALOG_TYPE_RCON2   7004


// *** RCON Dialogs *** //
#define CONSOLE				11 						// Defines "CONSOLE" Dialog
#define HOSTNAME			13						// Defines "HOSTNAME" Dialog
#define GAMEMODENAME		14						// Defines "GAMEMODENAME" Dialog
#define MAPNAME				15						// Defines "MAPNAME" Dialog
#define EXEC				16						// Defines "EXEC" Dialog
#define KICK				17						// Defines "KICK" Dialog
#define BAN					18						// Defines "BAN" Dialog
#define CHANGEMODE			19						// Defines "CHANGEMODE" Dialog
#define GMX					20						// Defines "GMX" Dialog
#define RELOADBAN			21						// Defines "RELOADBAN" Dialog
#define RELOADLOG			22						// Defines "RELOADLOG" Dialog
#define BANIP				25						// Defines "BANIP" Dialog
#define UNBANIP				26						// Defines "UNBANIP" Dialog
#define GRAVITY				27						// Defines "GRAVITY" Dialog
#define WEATHER				28						// Defines "WEATHER" Dialog
#define LOADFS				30						// Defines "LOADFS" Dialog
#define UNLOADFS			31						// Defines "UNLOADFS" Dialog
#define RELOADFS			32						// Defines "RELOADFS" Dialog
#define WEBURL				33						// Defines "WEBURL" Dialog


#define MAX_MESSAGES 100
#define TIMER 600000 // This will set the Timer Length (Miliseconds) For the Random Messages
#define COLOR_BOT 0xFF00FFFF // This will set the Bot's Color (Pink by Default)
#define COLOR_VIP 0x00EEADDF // VIP Color

#define db_query_set(%0,%1,%2,%3)\
                do\
                {\
                        format(%1, sizeof(%1), (%2), %3);\
                        db_free_result(db_query(%0, %1));\
                }\
                while ( False )

#define db_query_get(%0,%1,%2,%3)\
                do\
                {\
                        format(%1, sizeof(%1), "SELECT `%s` FROM `records`", %3);\
                        db_get_field(db_query(%0, %1), 0, %2, sizeof(%2) );\
                        db_free_result(db_query(%0, %1));\
                }\
                while ( False )

#if !defined isnull
	#define isnull(%1) \
				((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif

#define  TIME             2  //When the contest will start (Minutes)
#define  PRIZE    		15000 //Reward ($$$) when win in Math Contest
#define  PRIZESCORE       5  //Reward (Score) when win in Math Contest
#define  CookiePrize      2  //Reward (Cookies) when win in Math Contest

new answer;
new endm = 0;
new no1, no2, no3;
new typem = -1;
new timermath;
new timermath2;

new
	xCharacters[][] =
	{
	    "A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M",
		"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
		"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
	    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
	},
 	xChars[16] = "",
	xReactionTimer,
	xCash,
	xScore,
	xCookies,
    reactionWinnerID,
	bool: xTestBusy
;
forward Math();
forward MathEnd();

#if !defined function
#define function%0(%1) \
	forward%0(%1); public%0(%1)
#endif

#if !defined PURPLE
#define PURPLE \
    0x7100E1FF
#endif

#if !defined GREEN
#define GREEN \
    0x94D317FF
#endif

#if !defined TIME
#define TIME \
    180000
#endif

//VIP System
#define vipmenu1 1040
#define vipmenu2 1041
#define vipmenu3 1042
#define vipmenu4 1043

#define DIALOG_COOKIESHOP 6969
#define DIALOG_BROWNIESHOP 6970
#define DIALOG_FIGHTINGSTYLE 7853

new VIPWarning[MAX_PLAYERS];
new VIPName[MAX_PLAYERS];


//new strR[255];
new Killsp[MAX_PLAYERS];
new Deathsp[MAX_PLAYERS];
new PMReply[MAX_PLAYERS];

new BotName[24] = "Jennifer"; // This will set the Bot's Name
new RANDOMMSG = 1; // 1 = On - 0 = Off  ( 0 = only SendBotMessage() without RandomMessage - 1 = Everything will work)
new MAXMESSAGE;
new BOTMESSAGE[MAX_PLAYERS][128];

#include <mSelection>
new skinlist = mS_INVALID_LISTID;

//Heads
new Text3D:VIP[MAX_PLAYERS];
new Text3D:TrialModerator[MAX_PLAYERS];
new Text3D:Mod[MAX_PLAYERS];
new Text3D:CoAdmin[MAX_PLAYERS];
new Text3D:Admin[MAX_PLAYERS];
new Text3D:Leader[MAX_PLAYERS];
new Text3D:Manager[MAX_PLAYERS];
new Text3D:TBS[MAX_PLAYERS];

new VIPTag[MAX_PLAYERS];
new TrialModeratorTag[MAX_PLAYERS];
new ModTag[MAX_PLAYERS];
new CoAdminTag[MAX_PLAYERS];
new AdminTag[MAX_PLAYERS];
new LeaderTag[MAX_PLAYERS];
new ManagerTag[MAX_PLAYERS];
new TBSStaffTag[MAX_PLAYERS];

new TimeVIP[MAX_PLAYERS];
new PlayerScore[MAX_PLAYERS];
//-------------------------------

native WP_Hash(buffer[], len, const str[]);

// Enums
enum E_HORSE
{
	Float:hx,
	Float:hy,
	Float:hz,
	order,
	pickup,
	reward
}

enum MainName
{
        Zone_Name[64],
        Float:Area[3]
};

enum mbinfo
{
	Float:XPOS,
	Float:YPOS,
	Float:ZPOS,
	Position[50]
};

new Float:MBSPAWN[][mbinfo] =
{
  // Positions, (X, Y, Z, Location)
    {713.073852, 912.842224, -19.096578, "The Quarry"},
    {688.145507, 844.974914, -28.631895, "The Quarry"},
    {586.370788, 913.020202, -34.194843, "The Quarry"},
    {503.419708, 970.914550, -24.997589, "The Quarry"},
    {499.296356, 971.732788, -25.047336, "The Quarry"},
    {458.502136, 891.120666, -27.374114, "The Quarry"},
    {628.248901, 735.500732, -0.903092, "The Quarry"},
    {627.924438, 1046.961303, 25.122577, "The Quarry"},
    {792.460510, 915.044189, 20.112213, "The Quarry"},
    {320.508636, 848.626281, 19.967500, "The Quarry"},
    {361.191741, 829.137329, 21.289638, "The Quarry"},
    {462.726348, 973.174621, 5.403401, "The Quarry"},
    {484.878112, 962.291137, 5.981633, "The Quarry"},
    {591.441650, 706.663513, 9.760972, "The Quarry"},
    {770.800415, 746.815368, 27.704566, "The Quarry"},
    {434.217102, 898.344543, 2.117520, "The Quarry"},
    {488.367218, 810.184814, 1.804343, "The Quarry"},
    {528.185913, 816.695800, -11.858360, "The Quarry"},
    {568.221130, 824.427429, -22.127143, "The Quarry"},
    {575.399353, 872.569091, -35.329307, "The Quarry"},
    {623.156188, 892.809875, -41.102825, "The Quarry"},
    {418.428070, 1409.390625, 8.565642, "The Petroleum"},
    {475.849548, 1325.585083, 11.321235, "The Petroleum"},
    {541.844848, 1556.681152, 0.482253, "The Petroleum"},
    {597.308898, 1535.999389, 3.586513, "The Petroleum"},
    {669.860534, 1422.952880, 10.887602, "The Petroleum"},
    {559.382812, 1371.361328, 16.322978, "The Petroleum"},
    {438.514587, 1268.192016, 9.017544, "The Petroleum"},
    {585.843322, 1485.281738, 12.073791, "The Petroleum"},
    {229.331573, 1478.390502, 10.151371, "Green Palms"},
    {152.056015, 1447.338256, 10.156622, "Green Palms"},
	{133.937881, 1377.117065, 10.158605, "Green Palms"},
	{205.768768, 1352.408081, 10.151306, "Green Palms"},
    {210.495468, 1395.340332, 10.151283, "Green Palms"},
	{215.108322, 1467.936157, 14.921875, "Green Palms"},
	{215.115737, 1467.059326, 23.734375, "Green Palms"},
    {187.969940, 1371.305786, 23.734375, "Green Palms"},
	{246.766662, 1360.596679, 10.707500, "Green Palms"},
	{246.478836, 1362.749633, 23.370285, "Green Palms"},
    {222.136520, 1424.068847, 10.585937, "Green Palms"},
   	{95.363838, 1831.129028, 17.205287, "Area 69"},
	{189.325698, 1940.272949, 17.213102, "Area 69"},
	{193.302978, 1940.295654, 17.212646, "Area 69"},
	{261.569244, 1807.425537, 25.498508, "Area 69"},
	{201.875762, 1873.929809, 12.774854, "Area 69"},
	{238.924987, 1863.955078, 11.460937, "Area 69"},
	{221.148391, 1822.212890, 7.531250, "Area 69"},
	{245.811523, 1813.676025, 4.710937, "Area 69"},
	{257.617523, 1819.045043, 1.007812, "Area 69"},
	{280.195648, 1840.170532, 11.534780, "Area 69"},
	{282.369171, 1874.492065, 8.757812, "Area 69"},
	{266.978424, 1858.773071, 8.757812, "Area 69"},
	{262.194854, 1886.633789, -30.390625, "Area 69"},
	{268.940002, 1883.556152, -30.093750, "Area 69"},
	{268.277374, 1891.600708, -12.862023, "Area 69"},
	{268.972656, 1876.503906, -3.470956, "Area 69"},
	{275.735778, 1892.228881, 8.437500, "Area 69"},
	{246.438491, 1830.403930, 12.210659, "Area 69"},
	{134.512237, 1952.987426, 18.978763, "Area 69"},
	{-41.510822, 1178.722290, 18.961349, "Fort Carson"},
	{2.213922, 1119.721435, 19.450517, "Fort Carson"},
	{17.874195, 1076.159057, 19.804994, "Fort Carson"},
	{-95.816307, 1164.927001, 19.312730, "Fort Carson"},
	{-100.357772, 1127.539672, 19.323959, "Fort Carson"},
	{-117.773254, 1132.638061, 19.326152, "Fort Carson"},
	{-190.864791, 1218.766357, 19.306653, "Fort Carson"},
	{-218.729446, 1147.502807, 19.328531, "Fort Carson"},
	{-378.680541, 1103.303466, 19.314443, "Fort Carson"},
	{-312.767395, 1175.458740, 19.307266, "Fort Carson"},
	{-209.111099, 1216.520629, 23.436161, "Fort Carson"},
	{-170.258102, 1176.971801, 24.155366, "Fort Carson"},
	{-172.726379, 1182.572753, 26.504249, "Fort Carson"},
	{-824.523559, 1444.919677, 13.547593, "Las Barrancas"},
	{-811.227539, 1479.601074, 26.136028, "Las Barrancas"},
	{-778.594482, 1477.787719, 28.764667, "Las Barrancas"},
	{-801.825866, 1513.152099, 21.131435, "Las Barrancas"},
	{-730.415039, 1539.924682, 40.065593, "Las Barrancas"},
	{-733.456970, 1553.795654, 39.189163, "Las Barrancas"},
	{-737.410278, 1593.716186, 26.656929, "Las Barrancas"},
	{-774.510375, 1616.915771, 26.687776, "Las Barrancas"},
	{-835.524841, 1597.141967, 26.505504, "Las Barrancas"},
	{-888.960021, 1553.529907, 25.501276, "Las Barrancas"},
	{-862.112548, 1536.867919, 25.737701, "Las Barrancas"},
	{-856.268554, 1528.398559, 25.737701, "Las Barrancas"},
	{-303.303192, 2744.042236, 61.440700, "Las Payasadas"},
	{-210.072189, 2814.655273, 64.240028, "Las Payasadas"},
	{-164.061630, 2767.596435, 62.252616, "Las Payasadas"},
	{-166.319808, 2730.175537, 65.696540, "Las Payasadas"},
	{-213.414306, 2719.982177, 62.687500, "Las Payasadas"},
	{-287.109222, 2687.127441, 65.852340, "Las Payasadas"},
	{-268.482818, 2667.310546, 62.670055, "Las Payasadas"},
	{-282.033843, 2651.087402, 67.323928, "Las Payasadas"},
	{-307.318756, 2652.917236, 68.252456, "Las Payasadas"},
	{-237.491958, 2663.685546, 63.858531, "Las Payasadas"},
	{-153.610809, 2711.833984, 62.144855, "Las Payasadas"},
	{-235.506256, 2826.033935, 61.760990, "Las Payasadas"},
	{123.295402, 2427.276123, 16.638261, "Verdant Meadows"},
	{152.007369, 2417.473388, 19.140531, "Verdant Meadows"},
	{209.578689, 2415.689697, 16.322700, "Verdant Meadows"},
	{237.976455, 2432.690185, 16.626625, "Verdant Meadows"},
	{276.434844, 2430.887695, 16.041940, "Verdant Meadows"},
	{313.228027, 2415.748046, 19.511663, "Verdant Meadows"},
	{349.762481, 2451.393310, 20.452396, "Verdant Meadows"},
	{412.917022, 2432.326904, 16.054676, "Verdant Meadows"},
	{435.414642, 2561.705078, 16.089130, "Verdant Meadows"},
	{414.310363, 2533.625732, 19.148437, "Verdant Meadows"},
	{401.180969, 2544.245849, 19.631122, "Verdant Meadows"},
	{390.938781, 2607.264160, 16.049514, "Verdant Meadows"},
	{334.645782, 2677.588867, 15.882289, "Verdant Meadows"},
	{306.708404, 2629.444335, 16.256523, "Verdant Meadows"},
	{271.063079, 2611.989257, 16.041421, "Verdant Meadows"},
	{172.383773, 2606.412597, 16.116966, "Verdant Meadows"},
	{154.106018, 2630.396240, 16.041749, "Verdant Meadows"},
	{115.394462, 2631.614501, 15.986257, "Verdant Meadows"},
	{104.371681, 2582.203613, 16.044742, "Verdant Meadows"},
	{14.670138, 2560.055419, 15.932084, "Verdant Meadows"},
	{9.903661, 2435.500732, 16.019382, "Verdant Meadows"},
 	{-2452.078125, 2438.356933, 14.555831, "Bayside"},
	{-2417.809570, 2456.555908, 25.779113, "Bayside"},
	{-2406.699462, 2469.222656, 12.183320, "Bayside"},
	{-2415.591552, 2386.210205, 7.998282, "Bayside"},
	{-2386.701904, 2398.892578, 8.845354, "Bayside"},
	{-2407.274902, 2477.111816, 11.345425, "Bayside"},
	{-2403.085449, 2553.951904, 23.601562, "Bayside"},
	{-2286.216552, 2572.171142, 23.416145, "Bayside"},
	{-2262.795410, 2573.447753, 8.214822, "Bayside"},
	{-2675.145996, 2322.950927, 25.147560, "Bayside"},
	{-2336.536376, 2480.192138, 1.275272, "Bayside"},
	{-2625.399658, 2245.826171, 6.694106, "Bayside"},
	{-2634.328125, 2240.306152, 14.622048, "Bayside"},
	{-2627.168457, 2234.247070, 12.825107, "Bayside"},
	{-2629.958984, 2243.830566, 12.611998, "Bayside"},
	{-2624.168212, 2245.396972, 6.268455, "Bayside"},
	{-2551.672851, 2432.413330, 18.866594, "Bayside"},
	{-2293.487060, 2225.002685, 4.982191, "Bayside"},
	{-2578.585693, 2520.823730, 21.721471, "Bayside"},
	{-2497.177978, 2455.601562, 17.332534, "Bayside"},
	{-2299.505859, 2277.234619, 4.978750, "Bayside"},
	{-2353.547119, 2430.278320, 7.510148, "Bayside"},
 	{1316.041870, 275.046447, 31.049236, "Montgomery"},
	{1304.498779, 150.734161, 23.841037, "Montgomery"},
	{1424.074584, 234.264190, 19.554687, "Montgomery"},
	{1397.934692, 289.888427, 23.555511, "Montgomery"},
	{1377.866699, 317.458984, 19.554687, "Montgomery"},
	{1236.187255, 304.846252, 24.757812, "Montgomery"},
	{1239.561157, 288.248535, 25.755512, "Montgomery"},
	{1264.523315, 269.752105, 22.237289, "Montgomery"},
	{1283.437011, 264.630554, 23.762454, "Montgomery"},
	{1352.665161, 199.973419, 19.554687, "Montgomery"},
	{1363.234741, 195.539321, 23.227035, "Montgomery"},
	{1417.051757, 260.263885, 24.656915, "Montgomery"},
	{1414.501342, 363.570312, 19.164152, "Montgomery"},
	{1397.685424, 357.668762, 19.415740, "Montgomery"},
	{1374.767822, 366.475738, 21.055135, "Montgomery"},
	{1291.057983, 392.483947, 19.531446, "Montgomery"},
	{1282.783935, 385.586151, 27.555513, "Montgomery"},
	{1238.631103, 370.964813, 27.555509, "Montgomery"},
	{1183.289062, 230.991256, 19.561769, "Montgomery"},
	{1224.791137, 246.335128, 23.282218, "Montgomery"},
	{1270.518188, 240.601501, 31.107307, "Montgomery"},
	{1266.207519, 234.240051, 25.048685, "Montgomery"},
	{1290.146484, 300.298248, 28.560659, "Montgomery"},
	{198.153564, -189.123001, 7.578125, "Blueberry"},
	{244.182067, -312.091217, 1.578125, "Blueberry"},
	{377.058685, -126.040382, 1.282783, "Blueberry"},
	{331.945190, -21.335258, 8.999382, "Blueberry"},
	{270.666198, 25.962350, 7.423792, "Blueberry"},
	{269.469726, -39.207118, 2.076274, "Blueberry"},
	{249.126205, -55.748535, 2.778613, "Blueberry"},
	{200.529525, -2.403444, 1.585840, "Blueberry"},
	{151.374862, -112.419876, 8.206827, "Blueberry"},
	{186.791824, -97.364349, 4.896471, "Blueberry"},
	{294.001983, -195.634521, 7.138307, "Blueberry"},
	{79.888191, -172.170288, 3.240008, "Blueberry"},
	{90.263679, -196.305435, 1.484375, "Blueberry"},
	{307.548217, -256.133117, 1.583575, "Blueberry"},
	{130.356811, -65.668479, 1.578125, "Blueberry"},
	{201.947799, -107.787826, 1.552092, "Blueberry"},
	{251.443710, -59.984920, 5.882812, "Blueberry"},
	{338.868713, 39.111991, 6.514575, "Blueberry"},
	{233.187500, 88.724472, 3.707660, "Blueberry"},
	{271.035064, -325.480102, 4.109173, "Blueberry"},
	{258.287322, -91.798759, 6.548583, "Blueberry"},
	{660.309570, -515.073425, 22.836296, "Dillimore"},
	{681.892456, -471.186981, 24.570465, "Dillimore"},
	{720.187500, -460.116394, 23.195312, "Dillimore"},
	{766.745727, -565.935180, 18.013334, "Dillimore"},
	{766.601135, -565.742553, 18.013334, "Dillimore"},
	{795.740600, -498.457305, 18.013332, "Dillimore"},
	{830.493530, -483.307739, 17.335937, "Dillimore"},
	{822.035034, -539.921508, 23.336297, "Dillimore"},
	{806.729309, -644.110595, 16.335937, "Dillimore"},
	{837.977600, -618.451599, 16.427936, "Dillimore"},
	{872.614746, -589.113098, 17.975578, "Dillimore"},
	{618.945983, -495.678375, 17.036308, "Dillimore"},
	{613.239624, -511.376983, 20.336296, "Dillimore"},
	{668.560424, -565.262573, 20.646862, "Dillimore"},
	{655.586303, -565.002868, 22.147821, "Dillimore"},
	{663.681518, -552.116699, 16.335937, "Dillimore"},
	{666.731262, -624.085144, 16.335937, "Dillimore"},
	{659.283569, -649.963623, 16.335937, "Dillimore"},
	{714.395568, -638.833496, 15.661087, "Dillimore"},
	{706.086425, -513.023925, 19.836296, "Dillimore"},
	{697.977600, -502.530029, 20.336296, "Dillimore"},
 	{2252.387695, -71.207305, 31.594974, "Palimino Creek"},
	{2256.675292, -51.222541, 33.039546, "Palimino Creek"},
	{2280.761474, -43.499469, 33.915302, "Palimino Creek"},
	{2331.433349, -16.148464, 29.984375, "Palimino Creek"},
	{2307.091796, 42.845218, 26.484375, "Palimino Creek"},
	{2312.534423, 81.270088, 34.412147, "Palimino Creek"},
	{2282.645019, 80.523757, 34.983432, "Palimino Creek"},
	{2270.598876, 52.587516, 29.983432, "Palimino Creek"},
	{2237.241210, -146.453750, 25.870410, "Palimino Creek"},
	{2294.017333, -133.607147, 28.153959, "Palimino Creek"},
	{2290.864501, -125.560646, 31.281974, "Palimino Creek"},
	{2494.198486, 84.268798, 26.484375, "Palimino Creek"},
	{2522.718505, -35.541027, 27.843750, "Palimino Creek"},
	{2371.754638, 166.031631, 28.441642, "Palimino Creek"},
	{2221.037597, 187.976211, 26.053337, "Palimino Creek"},
	{2175.741210, -96.308731, 25.773351, "Palimino Creek"},
	{2194.704589, -51.970607, 27.476959, "Palimino Creek"},
	{2521.830566, 147.489349, 26.660923, "Palimino Creek"},
	{2503.659667, 138.658645, 26.476562, "Palimino Creek"},
	{2385.197021, 132.599624, 26.477228, "Palimino Creek"},
	{2497.073974, 73.162178, 26.484375, "Palimino Creek"},
 	{1113.000366, -298.941436, 79.273048, "Hilltop Farms"},
	{1145.276123, -319.449951, 68.736564, "Hilltop Farms"},
	{1139.270874, -279.303375, 68.293548, "Hilltop Farms"},
	{1109.191650, -254.074951, 73.178703, "Hilltop Farms"},
	{1074.967651, -290.027832, 76.994865, "Hilltop Farms"},
	{1045.733276, -292.704284, 77.359375, "Hilltop Farms"},
	{1038.980712, -314.385131, 73.993080, "Hilltop Farms"},
	{1019.215393, -280.257232, 73.992187, "Hilltop Farms"},
	{1017.502319, -291.644531, 77.359375, "Hilltop Farms"},
	{1025.220092, -286.122772, 73.993080, "Hilltop Farms"},
	{1008.152404, -361.344543, 73.992187, "Hilltop Farms"},
	{1031.137329, -286.081237, 73.992187, "Hilltop Farms"},
 	{-91.739074, 47.309322, 3.117187, "Blueberry Acres"},
	{-59.916896, 110.778358, 3.117187, "Blueberry Acres"},
	{-21.062276, 101.820167, 3.117187, "Blueberry Acres"},
	{-39.467891, 54.310203, 3.117187, "Blueberry Acres"},
	{-57.822875, 58.630420, 12.634796, "Blueberry Acres"},
	{6.610152, -116.727790, 0.827577, "Blueberry Acres"},
	{-234.935729, -49.896484, 3.117187, "Blueberry Acres"},
	{-63.104183, -42.047443, 3.117187, "Blueberry Acres"},
	{-101.163230, -42.706863, 3.960474, "Blueberry Acres"},
	{-65.395072, -79.674530, 3.117187, "Blueberry Acres"},
	{-71.846885, 16.072692, 4.960474, "Blueberry Acres"},
	{-115.097801, -158.043121, 3.053518, "Blueberry Acres"},
	{-74.329200, 134.758972, 3.117187, "Blueberry Acres"},
	{-180.387710, 158.206222, 6.585262, "Blueberry Acres"},
	{43.705768, 31.582788, 2.406414, "Blueberry Acres"},
	{-120.041000, -101.572135, 3.118082, "Blueberry Acres"},
	{-97.865242, 3.703858, 6.140625, "Blueberry Acres"},
	{-141.913879, -45.108047, 3.117187, "Blueberry Acres"},
	{-96.231872, -43.475280, 6.484375, "Blueberry Acres"},
    {-614.443786, 151.758407, 25.818775, "The Panopticon"},
	{-526.496093, 58.226322, 50.909709, "The Panopticon"},
	{-472.907379, -169.445770, 78.210937, "The Panopticon"},
	{-735.953918, 57.285392, 26.305458, "The Panopticon"},
	{-546.440124, -61.437793, 63.233062, "The Panopticon"},
	{-710.849609, -206.753967, 69.553245, "The Panopticon"},
	{-436.740875, -59.873924, 58.875000, "The Panopticon"},
	{-751.409790, -114.402214, 67.739364, "The Panopticon"},
	{-925.530151, -124.350387, 57.936649, "The Panopticon"},
	{-400.126495, 236.726394, 9.927101, "The Panopticon"},
	{-520.779357, -125.374198, 69.994155, "The Panopticon"},
	{-561.900878, -178.898284, 78.413543, "The Panopticon"},
	{-539.732116, -161.536758, 78.206115, "The Panopticon"},
	{-532.769287, -177.417663, 84.258483, "The Panopticon"},
	{-389.482971, -211.937072, 59.564701, "The Panopticon"},
    {-406.703948, -1449.153686, 26.062500, "Flint Range"},
	{-396.805908, -1426.215209, 38.644241, "Flint Range"},
	{-365.578216, -1413.950805, 29.640625, "Flint Range"},
	{-364.751220, -1434.614501, 25.726562, "Flint Range"},
	{-584.598876, -1482.920043, 11.257370, "Flint Range"},
	{-558.555603, -1289.688232, 24.061843, "Flint Range"},
	{-210.887054, -1339.520751, 11.636716, "Flint Range"},
	{-203.383239, -1279.539794, 7.933257, "Flint Range"},
	{-370.022949, -1469.212768, 25.726562, "Flint Range"},
	{-257.378387, -1502.086059, 6.142509, "Flint Range"},
	{-329.254211, -1537.986083, 14.820620, "Flint Range"},
	{-370.188598, -1416.738281, 25.726562, "Flint Range"},
	{-468.467102, -1423.658813, 17.497291, "Flint Range"},
	{-366.230377, -1425.508422, 36.910018, "Flint Range"},
	{-438.425720, -1307.287841, 34.957294, "Flint Range"},
	{-326.334747, -1312.265869, 9.666571, "Flint Range"},
	{-2508.313232, -675.049499, 139.320312, "Missionary Hill"},
	{-2528.568359, -700.439453, 141.788848, "Missionary Hill"},
	{-2438.275146, -464.318084, 91.305053, "Missionary Hill"},
	{-2543.994384, -783.435424, 69.258705, "Missionary Hill"},
	{-2693.597412, -752.083862, 51.020137, "Missionary Hill"},
	{-2600.115478, -547.044921, 86.723999, "Missionary Hill"},
	{-2314.386230, -888.267517, 7.742542, "Missionary Hill"},
	{-2322.930664, -655.598815, 107.419876, "Missionary Hill"},
	{-2324.206054, -683.263916, 104.464118, "Missionary Hill"},
	{-2394.915283, -468.217041, 87.153312, "Missionary Hill"},
	{-2631.078613, -596.495971, 90.808830, "Missionary Hill"},
	{-2542.992431, -656.802001, 139.079116, "Missionary Hill"},
	{-2432.825439, -391.364898, 69.389305, "Missionary Hill"},
	{-2617.927001, -749.242065, 74.848922, "Missionary Hill"},
 	{-2175.949951, -2417.699218, 34.296875, "Angel Pine"},
	{-2161.742919, -2453.351562, 37.592113, "Angel Pine"},
	{-2147.736572, -2461.206787, 30.851562, "Angel Pine"},
	{-2090.979492, -2469.472900, 33.924186, "Angel Pine"},
	{-2053.039306, -2544.468261, 31.066806, "Angel Pine"},
	{-2132.012939, -2433.635986, 39.040298, "Angel Pine"},
	{-2182.593994, -2428.734375, 35.523437, "Angel Pine"},
	{-2224.829833, -2396.499511, 35.533672, "Angel Pine"},
	{-2243.295654, -2359.313720, 30.750513, "Angel Pine"},
	{-2191.753173, -2345.898437, 35.007812, "Angel Pine"},
	{-2178.140625, -2314.520019, 37.743614, "Angel Pine"},
	{-2199.897949, -2243.446044, 33.320312, "Angel Pine"},
	{-2186.412353, -2245.995605, 30.721515, "Angel Pine"},
	{-2081.464843, -2254.676025, 37.810462, "Angel Pine"},
	{-2139.485839, -2263.617675, 37.106971, "Angel Pine"},
	{-2130.179931, -2362.220703, 37.803909, "Angel Pine"},
	{-2245.683837, -2489.593261, 30.939933, "Angel Pine"},
	{-2115.936523, -2417.141113, 31.226562, "Angel Pine"},
	{-2293.220947, -2449.365478, 25.740257, "Angel Pine"},
	{-1972.621704, -2409.536376, 36.779953, "Angel Pine"},
	{-2034.074829, -2350.098144, 40.890625, "Angel Pine"},
	{-2101.847412, -2341.794677, 34.820312, "Angel Pine"},
 	{-1181.246826, -1169.744262, 129.218750, "The Farm"},
	{-1064.526367, -1202.956298, 136.825164, "The Farm"},
	{-1073.703247, -1236.239135, 129.218750, "The Farm"},
	{-960.019836, -969.289123, 136.249679, "The Farm"},
	{-1178.073120, -1139.615356, 129.218750, "The Farm"},
	{-1086.143554, -1304.293945, 129.218750, "The Farm"},
	{-1099.003295, -971.934814, 129.218750, "The Farm"},
	{-1062.486328, -913.190063, 129.211929, "The Farm"},
	{-1186.598144, -1138.081909, 132.746429, "The Farm"},
	{-1087.829833, -1084.395629, 129.218750, "The Farm"},
	{-1004.356140, -1013.866821, 129.218750, "The Farm"},
	{-1033.648925, -1068.210327, 129.218750, "The Farm"},
	{-1019.635437, -1153.692138, 129.218750, "The Farm"},
	{-1026.010375, -1183.257690, 129.218750, "The Farm"},
	{-1007.072387, -1296.862426, 132.661285, "The Farm"},
	{-1124.512817, -1222.314208, 129.218750, "The Farm"},
 	{-1087.444824, -1677.984130, 76.373939, "Leafy Hallows"},
	{-1087.494018, -1678.885498, 76.373939, "Leafy Hallows"},
	{-1091.211059, -1663.834472, 76.367187, "Leafy Hallows"},
	{-1108.562622, -1634.623657, 80.057617, "Leafy Hallows"},
	{-1078.178222, -1607.183349, 76.367187, "Leafy Hallows"},
	{-1130.027343, -1606.987304, 76.367187, "Leafy Hallows"},
	{-1112.752685, -1621.049194, 86.261589, "Leafy Hallows"},
	{-1097.599121, -1627.398681, 76.367187, "Leafy Hallows"},
	{-946.533935, -1746.916137, 76.381385, "Leafy Hallows"},
	{-927.683105, -1701.916503, 77.025894, "Leafy Hallows"},
	{-923.776733, -1757.801513, 75.444259, "Leafy Hallows"},
	{-905.625366, -1730.898193, 78.139099, "Leafy Hallows"},
	{-1128.219360, -1696.092529, 76.558853, "Leafy Hallows"},
	{-1026.914428, -1733.098632, 76.425018, "Leafy Hallows"},
	{-1137.569824, -1630.458251, 76.367187, "Leafy Hallows"},
	{-1094.567626, -1663.774780, 76.367187, "Leafy Hallows"},
	{-1043.661254, -1621.000000, 76.367187, "Leafy Hallows"},
	{-907.789489, -1669.016723, 92.697944, "Leafy Hallows"},
 	{2556.437744, -644.786804, 137.252746, "North Rock"},
	{2514.413818, -716.559753, 101.872634, "North Rock"},
	{2443.473388, -657.824401, 121.906684, "North Rock"},
	{2612.934814, -497.000335, 78.922164, "North Rock"},
	{2657.899414, -602.413452, 84.188896, "North Rock"},
	{2683.218017, -516.679077, 65.786819, "North Rock"},
	{2627.179199, -666.909179, 128.962661, "North Rock"},
	{2759.122314, -633.098876, 60.327945, "North Rock"},
	{2356.232910, -558.502868, 120.259140, "North Rock"},
	{2558.949218, -523.134826, 86.272521, "North Rock"},
	{-1012.700317, -754.431518, 32.007812, "Easter Bay Chemicals"},
	{-1095.468139, -629.071044, 34.089599, "Easter Bay Chemicals"},
	{-1109.042358, -601.289489, 34.089599, "Easter Bay Chemicals"},
	{-1074.046508, -600.883239, 34.089599, "Easter Bay Chemicals"},
	{-1112.463256, -748.833557, 32.007812, "Easter Bay Chemicals"},
	{-996.942810, -720.715209, 35.937500, "Easter Bay Chemicals"},
	{-987.252502, -716.223449, 35.901714, "Easter Bay Chemicals"},
	{-1037.941650, -697.023925, 32.007812, "Easter Bay Chemicals"},
	{-972.693725, -719.797607, 37.171875, "Easter Bay Chemicals"},
	{-1057.215332, -758.628417, 37.171875, "Easter Bay Chemicals"},
	{-1127.549194, -701.471435, 32.007812, "Easter Bay Chemicals"},
	{-973.345092, -635.038330, 32.007812, "Easter Bay Chemicals"},
	{-1099.870605, -696.740661, 32.351562, "Easter Bay Chemicals"},
	{-1057.206665, -634.323059, 35.493179, "Easter Bay Chemicals"},
	{-1017.676330, -704.239746, 32.007812, "Easter Bay Chemicals"},
 	{-1525.973999, 2652.515136, 59.711399, "El Quebrados"},
	{-1507.893920, 2626.360107, 59.233432, "El Quebrados"},
	{-1530.962646, 2590.045654, 60.793697, "El Quebrados"},
	{-1481.348388, 2618.711181, 62.335689, "El Quebrados"},
	{-1416.942138, 2582.434082, 62.005947, "El Quebrados"},
	{-1437.265258, 2559.354248, 55.835937, "El Quebrados"},
	{-1459.728881, 2616.084960, 55.835937, "El Quebrados"},
	{-1452.608764, 2640.138183, 55.835937, "El Quebrados"},
	{-1463.314697, 2720.380126, 65.580146, "El Quebrados"},
	{-1550.759765, 2701.973876, 55.835937, "El Quebrados"},
	{-1567.961425, 2714.753662, 59.495937, "El Quebrados"},
	{-1591.316162, 2639.252685, 54.892074, "El Quebrados"},
	{-1564.054321, 2561.529541, 66.368583, "El Quebrados"},
	{-1593.676757, 2562.781250, 68.570213, "El Quebrados"},
	{-1461.241210, 2653.424804, 58.912673, "El Quebrados"},
	{-1470.498413, 2554.702636, 55.835937, "El Quebrados"},
	{-1579.125488, 2641.298095, 55.835937, "El Quebrados"},
	{-1521.946166, 2709.298339, 55.835937, "El Quebrados"},
	{-828.082336, 2661.674560, 104.945419, "Valle Ocultado"},
	{-835.934020, 2659.769775, 96.975189, "Valle Ocultado"},
	{-831.431640, 2695.995361, 53.576766, "Valle Ocultado"},
	{-803.072448, 2695.158203, 67.962074, "Valle Ocultado"},
	{-799.726013, 2704.947265, 47.416099, "Valle Ocultado"},
	{-788.210693, 2694.006103, 48.357761, "Valle Ocultado"},
	{-785.256774, 2719.440917, 45.300182, "Valle Ocultado"},
	{-779.532104, 2774.275146, 45.864643, "Valle Ocultado"},
	{-879.216064, 2747.853759, 46.000000, "Valle Ocultado"},
	{-724.237121, 2761.054199, 47.958900, "Valle Ocultado"},
	{-921.067687, 2675.897705, 45.312007, "Valle Ocultado"},
	{-912.755981, 2685.360595, 45.579273, "Valle Ocultado"},
	{-895.774658, 2672.384033, 42.191963, "Valle Ocultado"},
	{-769.700073, 2770.898437, 50.696720, "Valle Ocultado"},
	{-801.442077, 2776.446044, 45.975139, "Valle Ocultado"},
	{-737.213012, 2744.907470, 50.156967, "Valle Ocultado"},
	{-809.037780, 2809.187255, 49.179012, "Valle Ocultado"},
	{-821.493896, 2690.416259, 67.090553, "Valle Ocultado"},
	{-875.683532, 2693.958251, 52.923053, "Valle Ocultado"},
	{-918.803100, 2669.565429, 42.370262, "Valle Ocultado"},
	{-928.732421, 2707.239257, 42.883373, "Valle Ocultado"},
 	{-384.209350, 2206.028564, 45.671134, "Ghost Town"},
	{-417.697753, 2246.862548, 42.429687, "Ghost Town"},
	{-384.358673, 2206.287841, 45.671134, "Ghost Town"},
	{-375.438262, 2241.879882, 47.126880, "Ghost Town"},
	{-371.937103, 2266.688964, 42.484375, "Ghost Town"},
	{-395.177276, 2246.250000, 50.119434, "Ghost Town"},
	{-324.652770, 2216.008789, 44.212184, "Ghost Town"},
	{-456.136169, 2223.866699, 42.894790, "Ghost Town"},
	{-435.397033, 2249.250732, 46.098773, "Ghost Town"},
	{-397.759216, 2198.488281, 42.425659, "Ghost Town"},
	{-327.913360, 2231.848876, 43.372142, "Ghost Town"},
	{-439.359222, 2219.759033, 47.228851, "Ghost Town"},
 	{-765.302185, 2491.239013, 102.136093, "Acro del Oeste"},
	{-802.416625, 2444.712158, 157.024627, "Acro del Oeste"},
	{-769.736938, 2423.740478, 161.240509, "Acro del Oeste"},
	{-775.107543, 2454.568847, 155.394210, "Acro del Oeste"},
	{-825.450378, 2423.629394, 154.799423, "Acro del Oeste"},
	{-811.348144, 2392.648925, 154.081359, "Acro del Oeste"},
	{-869.765625, 2308.967285, 161.556732, "Acro del Oeste"},
	{-854.010314, 2395.529785, 90.695556, "Acro del Oeste"},
	{-865.451293, 2353.720458, 99.970436, "Acro del Oeste"},
	{-794.787414, 2267.457275, 58.976562, "Acro del Oeste"},
	{-806.945800, 2257.034667, 59.155395, "Acro del Oeste"},
	{-861.962158, 2275.708984, 69.768547, "Acro del Oeste"},
	{-806.547485, 2257.323242, 70.167610, "Acro del Oeste"},
	{-798.468383, 2249.032958, 52.464538, "Acro del Oeste"},
	{-819.647888, 2380.772460, 128.528991, "Acro del Oeste"},
	{-659.340942, 2310.784667, 137.731201, "Acro del Oeste"},
	{-629.103271, 2387.976806, 128.003738, "Acro del Oeste"},
	{-1967.813110, -923.389343, 32.226562, "Foster Valley"},
	{-1975.327148, -895.343750, 35.289417, "Foster Valley"},
	{-1945.200073, -1091.307373, 32.175434, "Foster Valley"},
	{-1904.608642, -1029.386840, 32.223834, "Foster Valley"},
	{-2059.095214, -989.335815, 32.171875, "Foster Valley"},
	{-2100.027343, -862.919860, 32.171875, "Foster Valley"},
	{-2153.603271, -793.245605, 31.976562, "Foster Valley"},
	{-2065.419677, -811.472534, 32.171875, "Foster Valley"},
	{-1964.095703, -726.187255, 37.390625, "Foster Valley"},
	{-1970.476440, -729.316772, 37.682456, "Foster Valley"},
	{-1971.316284, -729.375305, 38.024555, "Foster Valley"},
	{-1954.998413, -894.500610, 35.890884, "Foster Valley"},
	{-1952.155517, -991.665954, 35.890625, "Foster Valley"},
	{-1971.808837, -988.987060, 32.226562, "Foster Valley"},
	{-2040.327270, -734.473449, 32.171875, "Foster Valley"},
	{-1954.255981, -763.292663, 35.890884, "Foster Valley"},
	{-1934.306640, -817.633239, 35.277336, "Foster Valley"},
	{-2154.379394, -889.910583, 32.171875, "Foster Valley"},
	{-1933.880859, -957.182373, 35.292263, "Foster Valley"},
	{-2077.329833, -876.431518, 32.171875, "Foster Valley"},
	{-2021.934204, -889.969665, 30.179347, "Foster Valley"},
	{-1967.698486, -923.311828, 32.226562, "Foster Valley"},
	{-1975.518432, -881.348754, 35.289417, "Foster Valley"},
	{-1949.256469, -866.676269, 32.226562, "Foster Valley"},
	{-1893.254760, -884.175720, 31.968750, "Foster Valley"},
	{-1939.472412, -792.035339, 32.226562, "Foster Valley"},
	{-1944.139770, -744.467956, 32.226562, "Foster Valley"},
	{-1938.702148, -702.345642, 32.171875, "Foster Valley"},
	{-1912.550048, -715.325622, 32.158123, "Foster Valley"},
	{-1890.561767, -715.974426, 32.171875, "Foster Valley"},
	{-1314.880126, 2523.205566, 93.098388, "Aldea Malvada"},
	{-1340.013183, 2566.662841, 92.453392, "Aldea Malvada"},
	{-1342.981445, 2577.075195, 77.273002, "Aldea Malvada"},
	{-1316.729370, 2595.577880, 73.072959, "Aldea Malvada"},
	{-1300.144653, 2546.430664, 87.742187, "Aldea Malvada"},
	{-1365.330444, 2531.653320, 87.216758, "Aldea Malvada"},
	{-1289.671264, 2516.583984, 87.161216, "Aldea Malvada"},
	{-1314.141967, 2528.084716, 87.613708, "Aldea Malvada"},
	{-1369.994506, 2530.447753, 77.454376, "Aldea Malvada"},
	{-1325.340332, 2516.338378, 87.046875, "Aldea Malvada"},
	{-1324.558593, 2532.424560, 87.561912, "Aldea Malvada"},
	{-1346.553466, 2565.318115, 80.643333, "Aldea Malvada"},
	{-541.176086, -561.201354, 26.798007, "The Fallen Tree"},
	{-504.101501, -539.727050, 25.523437, "The Fallen Tree"},
	{-503.481170, -527.582458, 25.523437, "The Fallen Tree"},
	{-475.996154, -552.346740, 33.121536, "The Fallen Tree"},
	{-470.645874, -538.255004, 29.121538, "The Fallen Tree"},
	{-466.353302, -468.697967, 25.523437, "The Fallen Tree"},
	{-517.881530, -496.789825, 25.523437, "The Fallen Tree"},
	{-620.473388, -472.812927, 25.523437, "The Fallen Tree"},
	{-644.839599, -445.775238, 27.982749, "The Fallen Tree"},
	{-586.403198, -398.734558, 24.491775, "The Fallen Tree"},
	{-554.032104, -423.535186, 29.328639, "The Fallen Tree"},
	{-488.099975, -449.957580, 42.387664, "The Fallen Tree"},
	{-507.062316, -434.387115, 37.013797, "The Fallen Tree"},
	{-501.433959, -570.266723, 24.771287, "The Fallen Tree"},
	{-440.963348, -582.747680, 14.563718, "The Fallen Tree"},
	{-624.458557, -561.871093, 26.267879, "The Fallen Tree"},
	{-657.998779, -588.320190, 33.299449, "The Fallen Tree"},
	{-505.762481, -522.940368, 36.364982, "The Fallen Tree"},
	{-615.547546, -506.135650, 33.525276, "The Fallen Tree"},
	{-596.443237, -526.158813, 33.525276, "The Fallen Tree"},
	{-615.139038, -531.275512, 37.525276, "The Fallen Tree"},
	{-624.562072, -509.588043, 33.459438, "The Fallen Tree"},
	{-531.809875, -467.091979, 26.224544, "The Fallen Tree"}
};

new Float:MoneyBagPos[3], MoneyBagFound=1, MoneyBagLocation[50], MoneyBagPickup, Timer[2];

//Hours, Minutes, Seconds, Milliseconds
#define MoneyBagDelay(%1,%2,%3,%4) (%1*3600000)+(%2*60000)+(%3*1000)+%4
//20 = 200,000 minimum 30 = 200,000 -> 500,000
#define MoneyBagCash ((random(30)+20)*1000)
//10 mins!
#define MB_DELAY MoneyBagDelay(0, 10, 0, 0)

enum cjinfo
{
	Float:XPOS,
	Float:YPOS,
	Float:ZPOS,
	Position[50]
};

new Float:CJSPAWN[][cjinfo] =
{
	{-1806.29712, 560.88129, 167.26711, "SF Downtown"},
    {-2139.08032, 245.32222, 34.86673, "Doherty"},
    {2405.44849, 1859.79297, 5.20608, "Clowns Pocket"},
    {2556.30737, -2124.66260, 0.72963, "LS Sewers"},
    {2472.34937, -2699.29395, 2.71305, "Ocean Docks"},
    {-127.2965, 2257.5681, 28.3140, "Bone Country"},
    {385.5855, 2435.0168, 16.5000, "Verdant Meadows"},
    {281.6816, 2907.9065, 14.3680, "Verdant Meadows"},
    {-288.8230, 2690.6648, 65.8523, "Las Payadas"},
    {-809.8169, 2428.4922, 156.9731, "Acro Del Oesto"},
    {-1465.6836, 2637.0884, 76.8169, "El Quebrados"},
    {-732.4016 , 1546.2505, 38.9916, "Las Barrancas"},
    {-1465.9545, 408.7207, 7.1875, "Easter Basin"},
    {-2534.4324, 61.6989, 9.0551, "Queens"},
    {-2659.8369, 1530.5116, 54.9728, "Gant Bridge"},
    {-1854.0480, 956.0145 ,45.4297, "Financial"},
    {488.367218, 810.184814, 1.804343, "The Quarry"},
    {-2206.5417, 706.2806, 56.3848, "Chinatown"},
    {-110.4530, 1130.4851, 19.7422, "Fort Carson"},
    {434.6534, 895.9893, 1.7575, "The Quarry"},
    {1321.2399, 283.9811, 36.8065, "Montgomery"},
    {2005.8295, 2924.4031, 48.3125, "LV Sewers"},
    {2240.3782, -85.7645, 27.8548, "Palomino Creek"},
    {353.6124, -105.4996, 1.2818, "Blueberry"},
    {-443.6093, 1033.2734, 26.2282, "Fort Carson"}, // Fort Carson
	{2000.2963, 1593.4285, 18.1459, "Pirate In The Man Pants"}, // Pirate In The Man Pants
	{1970.6002, 1622.4076 ,8.0484, "Pirate In The Man Pants"}, // Pirate In The Man Pants
	{2071.4551, 1907.4929, 17.9379, "The Visage"}, // The Visage
	{1405.3809, 2208.0488, 12.0156, "LV Stadium"}, // LV Stadium
	{2149.4138, 91.0194, 27.2317, "Palomino Creek"}, // Palomino Creek
	{2159.3467, -101.7397, 2.7500, "Palomino Creek"}, // Palomino Creek
	{1272.0773, 294.8883, 20.6563,"Montgomery"}, // Montgomery
	{1019.4473, -303.0592, 77.3594, "Hilltop Farm"}, // Hilltop Farm
    {-1206.3871, -2352.8318, 2.7000, "Flint Country"},
    {156.0594, -1952.8931, 47.8750, "Santa Maria Beach"},
	{-1518.8949, -2294.3225, -6.0683, "Flint Country"}, // Flint Country
	{-1113.8507, -1637.3036, 76.3672, "The Farm"}, // The Farm
	{-1845.6365, -1707.4166, 41.1120, "Junkyard"}, // Junkyard
	{-2025.9714, -860.1945, 32.1719, "Foster Valley"}, // Foster Valley
	{-2518.4751, 265.6637, 22.6725, "Queens"}, // Queens
	{-2694.1797, 632.8094, 49.5879, "Santa Flora"}, // Santa Flora
	{-2181.8071, 712.9950, 53.8908, "Chinetown"}, // Chinatown
	{-2772.4009, 784.1747, 66.3084, "Palisades"}, // Palisades
    {-2817.7373, 1051.8562, 27.7491, "Palisades"}, // Palisades
	{-2679.4207,836.3515,49.9892, "Paradiso"},  // Paradiso
	{-2040.0745, 866.8849, 54.8438, "Calton Heights"}, // Calton Heights
	{-2134.6860, 189.7703, 46.5156, "Doherty"}, // Doherty
	{-443.6093, 1033.2734, 26.2282, "FortCarson"}, // Fort Carson
	{164.2207, -238.4772, 13.4838, "Blueberry"}, // Blueberry
	{248.5021, -55.0668, 1.5776, "Blueberry"} // Blueberry
};

new Float:CJPOS[3], CJFound=1, CookieJarLocation[50], CJPickup, Timer2[2];

//Hours, Minutes, Seconds, Milliseconds
#define CJDelay(%1,%2,%3,%4) (%1*43600000)+(%2*60000)+(%3*1000)+%4
//10 mins!
#define CJ_DELAY CJDelay(0, 24, 0, 0)
//HS
new hshoe[30],
	horseshoe[MAX_PLAYERS]
;
new shoecord[][E_HORSE] =
{
	{2011.8767,1544.7483,9.4787,0,0,1000},
	{2323.7659,1283.2438,97.5738,2,1,2000},
	{1432.0463,2751.2932,19.5234,3,2,3000},
	{-144.1049,1231.6788,26.2031,4,3,4000},
	{-688.2123,938.3978,13.6328,5,4,5000},
	{-1531.5845,687.4770,133.0514,6,5,6000},
	{-1746.0385,528.1078,33.6328,7,6,7000},
	{-2342.2903,-163.5137,41.6406,8,7,8000},
	{-2397.8435,-246.5068,35.6401,9,8,9000},
	{-2758.2698,-417.5380,7.0309,10,9,10000},
	{-2173.6699,-2366.3496,30.6250,11,10,11000},
	{-1911.3087,-2586.6506,57.0643,12,11,12000},
	{-328.0322,-2130.3245,30.5606,13,12,13000},
	{-345.5536,-1854.0347,-4.9475,14,13,14000},
	{-262.8691,-1638.6805,11.6048,15,14,15000},
	{-369.4187,-1417.4979,25.7266,16,15,16000},
	{141.8222,-1475.9114,28.5270,17,16,17000},
	{388.8241,-1751.6829,20.4459,18,17,18000},
	{389.8570,-2033.2495,7.8359,19,18,19000},
	{715.2880,-1625.7753,2.4297,20,19,20000},
	{1407.0277,-1408.5634,14.2031,21,20,21000},
	{1966.0477,-1205.1957,16.5903,22,21,22000},
	{2113.9241,-1498.7046,10.4219,23,22,23000},
	{1851.5220,-1488.1444,8.8421,24,23,24000},
	{2064.7339,-1585.3751,13.4830,25,24,25000},
	{2431.4189,-2420.6155,13.1867,26,25,26000},
	{2798.5327,-2393.7683,13.9560,27,26,27000},
	{984.4499,2562.9263,10.7498,28,27,28000},
	{490.8186,1309.3688,10.0656,29,28,29000},
	{-425.7174,1390.5726,15.1472,30,29,100000}
};


new Float:cps[][MainName] =
{
        {"Easter Basin", {-1738.8892,147.4447,3.5547}},
        {"SF Downtown Helipad", {-1684.0514,704.8934,30.6016}},
        {"SF Downtown Car Shop Roof", {-1673.4921,1209.9197,32.9307}},
        {"LS Airport Race Track", {1477.1588,1276.0544,10.8203}},
        {"SF Easter Tunnel", {-1680.3920,-766.6390,41.3015}},
        {"LV Blackfield Intersection", {1188.8329,896.0413,11.5919}},
        {"LV Hunter Quary", {747.5848,766.2541,-3.5519}},
        {"AA Docks", {259.6457,2902.9409,7.4582}},
        {"AA El Castilo del Diablo Giant Penis", {-425.5155,2507.3477,124.3047}},
        {"LV Pirate Ship", {2022.6226,1546.2026,10.8226}},
        {"LV Airport Parking Lot", {1686.0709,1295.7816,10.8203}},
        {"LV Julius Thruway North", {1849.0345,2569.6482,10.8203}},
        {"East LS Basketball Court", {2317.6072,-1527.2966,25.3438}},
        {"LS Downtown", {1592.5835,-1297.0625,17.3033}},
        {"LS Temple", {1335.8844,-956.3817,36.6641}},
        {"Dilimore PD", {630.3858,-599.3079,16.3359}},
        {"Red County Underbridge", {480.3277,-260.1087,10.8516}},
        {"Lv Red Sands West Ramp", {1482.3340,2033.6136,12.4093}},
        {"SF Jizzy's Rooftop", {-2637.1245,1410.8300,23.8984}},
        {"Sherman Reservoir Stunt Area", {-789.9260,1723.5712,32.1113}},
        {"Mount Chilliad", {-2055.8794,-1336.2556,30.7644}},
        {"Missionary Hill Stunt Area", {-3019.5574,-771.7321,12.2132}},
        {"LS International", {1655.4785,-2371.3706,18.1477}},
        {"Ocean Docks Crane", {2398.3965,-2258.4854,13.3828}},
        {"Yellow_Bell_Golf_Co", {1207.02, 2810.09, 10.82}},
        {"Pillson_Intersection", {1286.58, 2448.64, 8.53}},
		{"East Beach", {2904.779052,-1132.979980,11.158198}},
		{"North Rock", {2563.009521,-639.730468,136.680130}},
		{"LS Airport Parking Lot", {1397.755371,-2337.306640,13.546875}},
		{"Maze Bank (TOP)", {1544.074096,-1352.863281,329.475067}},
		{"Maze Bank (Bottom)", {1580.132202,-1324.917846,16.484375}},
		{"The Camel's Toe", {2323.598632,1283.142211,97.526039}},
		{"Whitewood Estates", {958.715148,1734.755859,8.648437}},
		{"Los Flores", {2660.235107,-1449.670410,79.380538}},
        {"Los Flores Underbidge", {2641.006347,-1184.414184,52.731521}},
        {"Las Colinas Snack-Shop", {2719.901611,-1116.373657,69.414062}},
        {"MadDog Manison", {1291.228637,-788.710876,96.460937}},
        {"Mulholland Burger Shot", {1172.812622,-905.307189,43.339794}},
        {"LS Spiral Market", {1175.552368,-1173.395019,122.664596}},
        {"Flint Range Fields", {-258.030700,-1357.071166,8.759363}},
        {"Royal Casino Rooftop", {2109.955566,1485.057495,24.140625}},
        {"LV Airport Enterance", {1693.341552,1449.718017,10.764157}},
        {"LV Souvenirs", {1911.174072,2428.697509,10.820312}},
		{"K.A.C.C Military Fuels", {2617.488281,2721.080322,36.538642}},
		{"Sobell Rail Yards", {2783.356445,1831.859863,10.798989}},
		{"LV Come-A-Lot", {2243.964843,1077.299682,33.523437}},
		{"Easter Bay Airport", {-1275.947875,12.831776,14.148437}},
		{"San Fierro Downtown", {-1827.345581,547.764892,35.164062}},
		{"SF Construction Site", {-2081.393798,233.099349,35.372295}},
		{"SF Baseball Fields", {-2316.110595,102.721603,35.312500}},
		{"SF Car School", {-2047.897216,-188.861663,35.320312}},
		{"Foster Valley", {-2027.209838,-860.031433,32.171875}},
		{"Avispa Country club", {-2759.853759,-252.263214,7.187500}},
		{"SF City Hall", {-2760.617431,374.954925,4.897716}},
		{"SF Parachute Fall", {-1753.769531,885.359802,295.875000}},
		{"Calton Heights", {-2108.242919,911.753845,77.353218}}
};

//---------------------------------------
new PlayerOnlineTime[MAX_PLAYERS];
//////////////
#pragma dynamic 145000

#define USE_MENUS
#define SAVE_LOGS
#define ENABLE_SPEC
#define USE_STATS
#define ANTI_MINIGUN
#define ENABLE_FAKE_CMDS
#define DIALOG_TYPE_QUESTION   7010
#define DIALOG_STATS 4323
#define DIALOG_ADMINS 1111
#define DIALOG_LEVEL1 5511
#define DIALOG_LEVEL2 5512
#define DIALOG_LEVEL3 5513
#define DIALOG_LEVEL4 5514
#define DIALOG_LEVEL5 5515
#define DIALOG_LEVEL6 5516
#define DIALOG_ACMDS 5517
#define DIALOG_LCMDS 5518
#define DIALOG_SEEN 5519
#define DIALOG_DJCMDS 5520

#define MAX_WARNINGS 3

#define MAX_REPORTS 7
#define MAX_SONG_REQUESTS 10
#define MAX_CHAT_LINES 20

#define SPAM_MAX_MSGS 4
#define SPAM_TIMELIMIT 4

#define PING_MAX_EXCEEDS 4
#define PING_TIMELIMIT 60

#define MAX_FAIL_LOGINS 2
#define MAX_LOGIN_ATTEMPTS 2

new SuperJump[MAX_PLAYERS];


// Admin Area
new AdminArea[6] = {
377, 	// X
170, 	// Y
1008, 	// Z
90,     // Angle
3,      // Interior
0		// Virtual World
};

//////////////////
#define red2 0xFF0000FF
#define LightGreen 0x46FF46FF
#define DarkBlue 0x1100E6FF
#define blue 0x00FFFFFF
#define red 0xFF0000AA
#define RED 0xFF0000AA
#define green 0x33AA33AA
#define yellow 0xFFFF00AA
#define grey 0x818181FF
#define blue1 0x00FFFFAA
#define lightblue 0x00FFFFFF
#define orange 0xFF9900AA
#define black 0x2C2727AA
#define COLOR_TrialModerator 0xFF8000FF
#define COLOR_LIGHTGREEN 0x46FF46FF
#define COLOR_GREY 0x818181FF
#define COLOR_RED 0xFF0000FF
#define COLOR_DARKBLUE 0x1100E6FF
#define COLOR_GREEN 0x33AA33AA
#define COLOR_PINK 0xFF66FFAA
#define COLOR_YELLOW 0xFFFF00FF
#define COLOR_BLUE 0x00FFFFAA
#define COLOR_PURPLE 0x800080AA
#define COLOR_BLACK 0x000000AA
#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_GREEN1 0x33AA33AA
#define COLOR_BROWN 0xA52A2AAA
#define COLOR_BRIGHTRED 0xDC143CAA
#define COLOR_LIGHTBLUE 0x33CCFFAA
#define COLOR_DODGERBLUE 0x1E90FFAA
#define GetName
#define COLOR_WHITE2 {FFFFFF}
#define COLOR_RED2 {FF0000}
#define COLOR_WHITE2 {FFFFFF}
#define COLOR_DUEL 	0x00C224

#define TEAM_LVCOP 19
#define TEAM_LSCOP 23
#define TEAM_SWAT 7
#define TEAM_ARMY 4
#define TEAM_LVARMY 20

// DCMD
#define dcmd(%1,%2,%3) if ((strcmp((%3)[1], #%1, true, (%2)) == 0) && ((((%3)[(%2) + 1] == 0) && (dcmd_%1(playerid, "")))||(((%3)[(%2) + 1] == 32) && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1

// Caps
#define UpperToLower(%1) for ( new ToLowerChar; ToLowerChar < strlen( %1 ); ToLowerChar ++ ) if ( %1[ ToLowerChar ]> 64 && %1[ ToLowerChar ] < 91 ) %1[ ToLowerChar ] += 32

// Spec
#define ADMIN_SPEC_TYPE_NONE 0
#define ADMIN_SPEC_TYPE_PLAYER 1
#define ADMIN_SPEC_TYPE_VEHICLE 2

//RC vehicles
#define RC_BANDIT	441
#define RC_BARON	464
#define RC_GOBLIN	501
#define RC_RAIDER	465
#define D_TRAM		449
#define RC_TIGER	564
#define RC_CAM		594

enum PlayerData
{
	Registered,
	LoggedIn,
 	#if EnableTwoRcon == true
	MaxRcon,
	#endif
	HS,
	Level,
	pVip,
	Hide,
	Muted,
	Caps,
	accDate,
	accDescp[100],
	DisablePMs,
    ADisabledPMs,
	Jailed,
	MuteTime,
	JailTime,
	Frozen,
	FreezeTime,
	Kills,
	pDeaths,
	hours,
	mins,
	secs,
	Hours,
	Minutes,
	TotalTime,
	pBrownies,
	Mathematics,
	CheckPoints,
	Reactions,
	MoneyBags,
	CookieJars,
	ConnectTime,
	VIPColour[32],
 	MuteWarnings,
	Warnings,
	Spawned,
	TimesSpawned,
	God,
	Boost,
	GodCar,
	OnDuty,
	DoorsLocked,
	SpamCount,
	SpamTime,
	team,
	PingCount,
	PingTime,
	BotPing,
	pPing[PING_MAX_EXCEEDS],
	blip,
	blipS,
	pColour,
	pCar,
	NoQuestion,
	condoms,
	SpecID,
	SpecType,
	bool:AllowedIn,
	FailLogin,
	isDJ,
	ChatColor,
	Cookies,
};
new PlayerInfo[MAX_PLAYERS][PlayerData],//hi
Ranks[128];


#define MAKE_COLOR_FROM_RGB(%0,%1,%2,%3) ((((%0) & 0xFF) << 24) | (((%1) & 0xFF) << 16) | (((%2) & 0xFF) << 8) | (((%3) & 0xFF) << 0))

enum ServerData
{
	MaxPing,
	ReadPMs,
	ReadCmds,
	MaxAdminLevel,
	AdminOnlySkins,
	AdminSkin,
	AdminSkin2,
	NameKick,
	PartNameKick,
	AntiBot,
	AntiSpam,
 	AntiSwear,
 	NoCaps,
	Locked,
	Password[128],
	GiveWeap,
	GiveMoney,
	ConnectMessages,
	AdminCmdMsg,
	AutoLogin,
	MaxMuteWarnings,
	DisableChat,
	MustLogin,
	MustRegister,
};
new ServerInfo[ServerData];

new Float:Pos[MAX_PLAYERS][4];

// rcon
new Chat[MAX_CHAT_LINES][512];

//Timers
new PingTimer;
new GodTimer;
new BlipTimer[MAX_PLAYERS];
new JailTimer[MAX_PLAYERS];
new MuteTimer[MAX_PLAYERS];
new FreezeTimer[MAX_PLAYERS];
new LockKickTimer[MAX_PLAYERS];
new Vip[265];
new Float:fVehicleHealth;



//Duel
new CountDown = -1;

// Menus
#if defined USE_MENUS
new Menu:LMainMenu, Menu:AdminEnable, Menu:AdminDisable,
    Menu:LVehicles, Menu:twodoor, Menu:fourdoor, Menu:fastcar, Menu:Othercars,
	Menu:bikes, Menu:boats, Menu:planes, Menu:helicopters,
    Menu:XWeapons, Menu:XWeaponsBig, Menu:XWeaponsSmall, Menu:XWeaponsMore,
    Menu:LWeather,Menu:LTime,
    Menu:LTuneMenu, Menu:PaintMenu, Menu:LCars, Menu:LCars2,
    Menu:LTele, Menu:LasVenturasMenu, Menu:LosSantosMenu, Menu:SanFierroMenu,
	Menu:DesertMenu, Menu:FlintMenu, Menu:MountChiliadMenu,	Menu:InteriorsMenu;
#endif

// Forbidden Names & Words
new BadNames[100][100], // Whole Names
    BadNameCount = 0,
	BadPartNames[100][100], // Part of name
    BadPartNameCount = 0,
    ForbiddenWords[100][100],
    ForbiddenWordCount = 0;

// Report
new Reports[MAX_REPORTS][128];

//Song Requests
new Requests[MAX_SONG_REQUESTS][128];

//Tags
new djtag[MAX_PLAYERS];
new vtag[MAX_PLAYERS];
new ttag[MAX_PLAYERS];
new mtag[MAX_PLAYERS];
new COAtag[MAX_PLAYERS];
new Atag[MAX_PLAYERS];
new Ltag[MAX_PLAYERS];
new CEOtag[MAX_PLAYERS];
new TBStag[MAX_PLAYERS];
//Jennifer
new RandomMsg[][] =
{
	"I'm Jennifer, how can I help?",
	"I'm your friend, I'm here if you need me.",
	"Hello, nice to meet you!"
};

new players_connected;

// Ping Kick
new PingPos;

new VehicleNames[212][] = {
	"Landstalker","Bravura","Buffalo","Linerunner","Pereniel","Sentinel","Dumper","Firetruck","Trashmaster","Stretch","Manana","Infernus",
	"Voodoo","Pony","Mule","Cheetah","Ambulance","Leviathan","Moonbeam","Esperanto","Taxi","Washington","Bobcat","Mr Whoopee","BF Injection",
	"Hunter","Premier","Enforcer","Securicar","Banshee","Predator","Bus","Rhino","Barracks","Hotknife","Trailer","Previon","Coach","Cabbie",
	"Stallion","Rumpo","RC Bandit","Romero","Packer","Monster","Admiral","Squalo","Seasparrow","Pizzaboy","Tram","Trailer","Turismo","Speeder",
	"Reefer","Tropic","Flatbed","Yankee","Caddy","Solair","Berkley's RC Van","Skimmer","PCJ-600","Faggio","Freeway","RC Baron","RC Raider",
	"Glendale","Oceanic","Sanchez","Sparrow","Patriot","Quad","Coastguard","Dinghy","Hermes","Sabre","Rustler","ZR3 50","Walton","Regina",
	"Comet","BMX","Burrito","Camper","Marquis","Baggage","Dozer","Maverick","News Chopper","Rancher","FBI Rancher","Virgo","Greenwood",
	"Jetmax","Hotring","Sandking","Blista Compact","Police Maverick","Boxville","Benson","Mesa","RC Goblin","Hotring Racer A","Hotring Racer B",
	"Bloodring Banger","Rancher","Super GT","Elegant","Journey","Bike","Mountain Bike","Beagle","Cropdust","Stunt","Tanker","RoadTrain",
	"Nebula","Majestic","Buccaneer","Shamal","Hydra","FCR-900","NRG-500","HPV1000","Cement Truck","Tow Truck","Fortune","Cadrona","FBI Truck",
	"Willard","Forklift","Tractor","Combine","Feltzer","Remington","Slamvan","Blade","Freight","Streak","Vortex","Vincent","Bullet","Clover",
	"Sadler","Firetruck","Hustler","Intruder","Primo","Cargobob","Tampa","Sunrise","Merit","Utility","Nevada","Yosemite","Windsor","Monster A",
	"Monster B","Uranus","Jester","Sultan","Stratum","Elegy","Raindance","RC Tiger","Flash","Tahoma","Savanna","Bandito","Freight","Trailer",
	"Kart","Mower","Duneride","Sweeper","Broadway","Tornado","AT-400","DFT-30","Huntley","Stafford","BF-400","Newsvan","Tug","Trailer A","Emperor",
	"Wayfarer","Euros","Hotdog","Club","Trailer B","Trailer C","Andromada","Dodo","RC Cam","Launch","Police Car (LSPD)","Police Car (SFPD)",
	"Police Car (LVPD)","Police Ranger","Picador","S.W.A.T. Van","Alpha","Phoenix","Glendale","Sadler","Luggage Trailer A","Luggage Trailer B",
	"Stair Trailer","Boxville","Farm Plow","Utility Trailer"
};

//==============================================================================
//Forward
forward ShowVIPMenu(playerid);
forward ShowVIPMenu1(playerid);
forward ShowVIPMenu2(playerid);
forward UpdatePlayerColour(playerid);
forward Random(playerid);

public UpdatePlayerColour(playerid)
{
	if(VIPName[playerid] == 1)
	{
	    SetPlayerColor(playerid, COLOR_VIP);
	}
}
public ShowVIPMenu(playerid)
{
	new query[500];
	if(VIPWarning[playerid] == 0) { format(query,sizeof(query),"Thank you for helping the {FF6600}TBS grow, %s.", PlayerName2(playerid)); SendClientMessage(playerid, COLOR_VIP, query); VIPWarning[playerid] = 1; }
 	format(query,sizeof(query),"{84538A}VIP Username Colour\n{FFFFFF}Change weather\n{84538A}Chat settings\n{FFFFFF}Teleport Menu");
  	ShowPlayerDialog(playerid, vipmenu1, DIALOG_STYLE_LIST, "{84538A}VIP Menu", query, "Select", "Cancel");
  	return 1;
}
public ShowVIPMenu1(playerid)
{
	new query[500];
	if(VIPWarning[playerid] == 0) { format(query,sizeof(query),"Thank you for helping the {FF6600}TBS grow, %s.", PlayerName2(playerid)); SendClientMessage(playerid, COLOR_VIP, query); VIPWarning[playerid] = 1; }
 	format(query,sizeof(query),"{84538A}VIP Username Colour\n{FFFFFF}Change weather\n{84538A}Chat settings\n{FFFFFF}Attach Object\n{84538A}Teleport Menu");
  	ShowPlayerDialog(playerid, 11111, DIALOG_STYLE_LIST, "{84538A}VIP Menu", query, "Select", "Cancel");
  	return 1;
}
public ShowVIPMenu2(playerid)
{
	new query[500];
	if(VIPWarning[playerid] == 0) { format(query,sizeof(query),"Thank you for helping the {FF6600}TBS grow, %s.", PlayerName2(playerid)); SendClientMessage(playerid, COLOR_VIP, query); VIPWarning[playerid] = 1; }
 	format(query,sizeof(query),"{84538A}VIP Username Colour\n{FFFFFF}Change weather\n{84538A}Chat settings\n{FFFFFF}Attach Object\n{84538A}Teleport Menu");
  	ShowPlayerDialog(playerid, 11112, DIALOG_STYLE_LIST, "{84538A}VIP Menu", query, "Select", "Cancel");
  	return 1;
}


forward MessageToPlayerVIP(color,const string[]);
public MessageToPlayerVIP(color,const string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i) == 1)
		if(PlayerInfo[i][pVip] >= 1 || PlayerInfo[i][Level] >= 1)
		SendClientMessage(i, color, string);
	}
	return 1;
}
//==============================================================================
forward MessageToLeaders(color,const string[]);
public MessageToLeaders(color,const string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	if(IsPlayerConnected(i) == 1)
	if(PlayerInfo[i][Level] >= 5)
	SendClientMessage(i, color, string);
	}
	return 1;
}
forward MessageToManagers(color,const string[]);
public MessageToManagers(color,const string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	if(IsPlayerConnected(i) == 1)
	if(PlayerInfo[i][Level] == 6)
	SendClientMessage(i, color, string);
	}
	return 1;
}


new CPids, timerid;

forward cpss();
public cpss()
{
	new string[256];
	new rand = random(sizeof(cps));
	{
		remcpss();
		CPids = CreateDynamicCP(cps[rand][Area][0], cps[rand][Area][1], cps[rand][Area][2], 30.0);
		format(string, sizeof(string), "{0049FF}[Hint] New Checkpoint is created near {C9FFAB}(( %s )) {0049FF}collect it and get a prize!", cps[rand][Zone_Name][0]);
		SendClientMessageToAll(0xFFFF00AA, string);
	}
	return 1;
}

remcpss()
{
 	if (CPids)
    DestroyDynamicCP(CPids);
}

native OnPlayerInCheckpoint(playerid, checkpointid);
native OnPlayerOutCheckpoint(playerid, checkpointid);

forward IsPlayerInCP(playerid, checkpointid);
public IsPlayerInCP(playerid, checkpointid)
{
    if(checkpointid != CPids) return 0;
	return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	if(IsPlayerInDynamicCP(playerid, CPids) || checkpointid == CPids)
	{
	GivePlayerMoneyEx(playerid,30000);
    SetPlayerScore(playerid, GetPlayerScore(playerid) + 30);
   	new PlayerName[MAX_PLAYER_NAME], string[128];
	GetPlayerName(playerid, PlayerName, sizeof(PlayerName));
	format(string, sizeof(string), "%s has collected a hidden checkpoint and earned {C9FFAB}+30 score and $30000!", PlayerName);
    SendClientMessageToAll(0xFFFF00AA, string);
    GameTextForPlayer(playerid, "~w~ You have collected a checkpoint and earned 30 score $30000", 3000, 5);
	remcpss();
	PlayerInfo[playerid][CheckPoints]++;
	return 1;
	}
	return 1;
}
forward SyncTime();
public SyncTime()
{
	//new string[64];
	new tmphour;
	new tmpminute;
	new tmpsecond;
	gettime(tmphour, tmpminute, tmpsecond);
	FixHour(tmphour);
	tmphour = shifthour;
	if((tmphour > ghour) || (tmphour == 0 && ghour == 23))
	{
		//Changing weather randomly
 		new GlobalWeather = random(17);
   		SetWeather(GlobalWeather);
   		//Changing weather randomly finish
		//format(string, sizeof(string), "SERVER: The time is now %d:00 hours",tmphour);
		//SendClientMessageToAll(COLOR_WHITE,string);
		ghour = tmphour;
		if(realtime)
		{
			SetWorldTime(tmphour);
		}
	}
}
forward FixHour(hour);
public FixHour(hour)
{
	hour = timeshift+hour;
	if(hour < 0)
	{
		hour = hour+24;
	}
	else if(hour > 23)
	{
		hour = hour-24;
	}
	shifthour = hour;
	return 1;
}
forward UpdateClock(); //ANTI CHEAT IN THIS
public UpdateClock() //ANTI CHEAT AND CLOCK UPDATE.
{
	//----------- CLOCK UPDATER ---------------
 	new fix[20];
 	if(gMinutes == 60)
 	{
 	    new theHour = gHour+1;
       	SetWorldTime(theHour);
 	}
    if(gHour == 0 && gMinutes == 02)
 	{
	}
    if(gHour == 3 && gMinutes == 60)
 	{
 	new string[256];
    format(string, sizeof(string), "{147E8C}*Today's jackpot has reached to $%s. Draw will be held at 06:00 ! Type /lotto to purchase a ticket.",FormatNumber(LottoJackpot));
    SendClientMessageToAll(COLOR_GREEN,string);
 	}
 	if(gHour == 5 && gMinutes == 60)
 	{
 	LottoDraw();
 	SendClientMessageToAll(COLOR_GREEN,"{147E8C}*Next Lotto Draw will be at 18:00. Type /lotto to purachase a Ticket.");
 	}
 	if(gHour == 15 && gMinutes == 60)
 	{
    new string[256];
    format(string, sizeof(string), "{147E8C}*Today's jackpot has reached to $%s. Draw will be held at 18:00 ! Type /lotto to purchase a ticket.",FormatNumber(LottoJackpot));
    SendClientMessageToAll(COLOR_GREEN,string);
 	}
 	if(gHour == 17 && gMinutes == 60)
 	{
 	LottoDraw();
 	SendClientMessageToAll(COLOR_GREEN,"{147E8C}*Tomorrow's Lotto Draw will be at 06:00. Type /lotto to purachase a Ticket.");
 	}
	if(gMinutes == 60) { gHour++; gMinutes = 0; }
	if(gHour < 10 && gMinutes > 9) { format(fix, sizeof(fix), "0%d:%d", gHour, gMinutes); }
	if(gHour < 10 && gMinutes < 10) { format(fix, sizeof(fix), "0%d:0%d", gHour, gMinutes); }
	if(gMinutes < 10 && gHour > 9) { format(fix,sizeof(fix), "%d:0%d", gHour, gMinutes); }
	if(gMinutes < 10 && gHour < 10) { format(fix, sizeof(fix), "0%d:0%d", gHour, gMinutes); }
	if(gMinutes > 9 && gHour > 9) { format(fix,sizeof(fix), "%d:%d", gHour, gMinutes); }
	gMinutes++;
	//------------- CLOCK UPDATER --------------
	//------------- ANTICHEAT ------------------
}
forward OnPlayerLeaveDynamicCheckpoint(playerid, checkpointid);
public OnPlayerLeaveDynamicCheckpoint(playerid, checkpointid)
{
	return 1;
}

forward OnPlayerEnterDynamicChekpoint(playerid, checkpointid);

public Math()
{
	typem = random(2);
	no1 = random(600);
	no2 = random(50);
	no3 = random(100);
	new string[256];
	endm = 1;
	switch(typem)
	{
		case 0:
		{
			answer = no1 + no2 + no3;
			format(string, sizeof(string), "MATH: {FFFFFF}The first one who answers (solve) this {FF0000}%d+%d+%d {FFFFFF}wins {00FF00}${FFFFFF}15k + {FFFF00}5 {FFFFFF}score", no1, no2, no3);
			SendClientMessageToAll(COLOR_YELLOW, string);
		}
		case 1:
		{
			answer = no1 - no2 - no3;
			format(string, sizeof(string), "MATH: {FFFFFF}The first one who answers (solve) this {FF0000}%d-%d-%d {FFFFFF}wins {00FF00}${FFFFFF}15k + {FFFF00}5 {FFFFFF}score", no1, no2, no3);
			SendClientMessageToAll(COLOR_YELLOW, string);
		}
		case 2:
		{
			answer = no1 * no2 * no3;
			format(string, sizeof(string), "MATH: {FFFFFF}The first one who answers (solve) this {FF0000}%dx%dx%d {FFFFFF}wins {00FF00}${FFFFFF}15k + {FFFF00}5 {FFFFFF}score", no1, no2, no3);
			SendClientMessageToAll(COLOR_YELLOW, string);
		}
	}
	SendClientMessageToAll(-1, "Math will end on 30 seconds!");
	timermath2 = SetTimer("MathEnd", 1000*30, false);
	return 1;
}

public MathEnd()
{
	new string[128];
	switch(typem)
	{
		case 0:
		{
			format(string, sizeof(string), "MATH: {FFFFFF}No one won, the answer is '%d'", answer);
			SendClientMessageToAll(COLOR_YELLOW, string);
		}
		case 1:
		{
			format(string, sizeof(string), "MATH: {FFFFFF}No one won, the answer is '%d'", answer);
			SendClientMessageToAll(COLOR_YELLOW, string);
		}
		case 2:
		{
			format(string, sizeof(string), "MATH: {FFFFFF}No one won, the answer is '%d'", answer);
			SendClientMessageToAll(COLOR_YELLOW, string);
		}
	}
	endm = 0;
	KillTimer(timermath2);
	return 1;
}



public OnFilterScriptInit()
{
	typem = -1;
	endm = 0;
	xReactionTimer = SetTimer("xReactionTest", 1000*120*TIME, true);
	timermath = SetTimer("Math", 1000*60*TIME, true);
	timerid = SetTimer("cpss", 3 * 60 * 1000, true);
	SetTimer("UpdateClock",14400,true);
	SetTimer("LottoJackpotIncrease", 1000, 1);
	gettime(ghour, gminute, gsecond);
	FixHour(ghour);
	ghour = shifthour;
    cpss();
	load_config();

    // Gates
    GATESDB = db_open("dbs/Gates.db");
    load_gates();

    //Variables
    new tmphour;
	new tmpminute;
	new tmpsecond;
	gettime(tmphour, tmpminute, tmpsecond);
	FixHour(tmphour);
	tmphour = shifthour;
	SetWorldTime(tmphour);
	//randomtimer = SetTimer("RandomTimer", 1000, 1);
	//onlinetimer = SetTimer("OnlineTimer", 60000, 1); //DYNAMIC SIG TIMER IS IN THIS!!

	print("\n________________________________________");
	print("________________________________________");
	print("           ladmin Loading...            ");
	print("________________________________________");

	if(!fexist("ladmin/"))
	{
	    print("\n\n > WARNING: Folder Missing From Scriptfiles\n");
	  	SetTimerEx("PrintWarning",2500,0,"s","ladmin");
		return 1;
	}
	if(!fexist("ladmin/logs/"))
	{
	    print("\n\n > WARNING: Folder Missing From Scriptfiles\n");
	  	SetTimerEx("PrintWarning",2500,0,"s","ladmin/logs");
		return 1;
	}
	if(!fexist("ladmin/config/"))
	{
	    print("\n\n > WARNING: Folder Missing From Scriptfiles\n");
	  	SetTimerEx("PrintWarning",2500,0,"s","ladmin/config");
		return 1;
	}
	if(!fexist("ladmin/users/"))
	{
	    print("\n\n > WARNING: Folder Missing From Scriptfiles\n");
	  	SetTimerEx("PrintWarning",2500,0,"s","ladmin/users");
		return 1;
	}

	Timer[1] = SetTimer("MoneyBag", MB_DELAY, true);
	Timer2[1] = SetTimer("CookieJar", CJ_DELAY, true);

	UpdateConfig();

	for(new i = 0; i < sizeof(shoecord); i++)
	{
		hshoe[shoecord[i][pickup]] = CreatePickup(954, 1, shoecord[i][hx], shoecord[i][hy], shoecord[i][hz], 0);
	}
	#if defined DISPLAY_CONFIG
	ConfigInConsole();
	#endif

	//===================== [ The Menus ]===========================//
	#if defined USE_MENUS

	LMainMenu = CreateMenu("Main Menu", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(LMainMenu, 0, "Choose an option below");
	AddMenuItem(LMainMenu, 0, "Enable");
	AddMenuItem(LMainMenu, 0, "Disable");
    AddMenuItem(LMainMenu, 0, "Server Weather");
    AddMenuItem(LMainMenu, 0, "Server Time");
 	AddMenuItem(LMainMenu, 0, "All Vehicles");
	AddMenuItem(LMainMenu, 0, "Admin Cars");
	AddMenuItem(LMainMenu, 0, "Tuning Menu");
	AddMenuItem(LMainMenu, 0, "Choose Weapon");
	AddMenuItem(LMainMenu, 0, "Teleports");
	AddMenuItem(LMainMenu, 0, "Exit Menu");//

	AdminEnable = CreateMenu("~b~Configuration ~g~ Menu",2, 55.0, 200.0, 150.0, 80.0);
	SetMenuColumnHeader(AdminEnable, 0, "Enable");
	AddMenuItem(AdminEnable, 0, "Anti Swear");
	AddMenuItem(AdminEnable, 0, "Bad Name Kick");
	AddMenuItem(AdminEnable, 0, "Anti Spam");
	AddMenuItem(AdminEnable, 0, "Ping Kick");
	AddMenuItem(AdminEnable, 0, "Read Cmds");
	AddMenuItem(AdminEnable, 0, "Read PMs");
	AddMenuItem(AdminEnable, 0, "Capital Letters");
	AddMenuItem(AdminEnable, 0, "ConnectMessages");
	AddMenuItem(AdminEnable, 0, "AdminCmdMessages");
	AddMenuItem(AdminEnable, 0, "Auto Login");
	AddMenuItem(AdminEnable, 0, "Return");

	AdminDisable = CreateMenu("~b~Configuration ~g~ Menu",2, 55.0, 200.0, 150.0, 80.0);
	SetMenuColumnHeader(AdminDisable, 0, "Disable");
	AddMenuItem(AdminDisable, 0, "Anti Swear");
	AddMenuItem(AdminDisable, 0, "Bad Name Kick");
	AddMenuItem(AdminDisable, 0, "Anti Spam");
	AddMenuItem(AdminDisable, 0, "Ping Kick");
	AddMenuItem(AdminDisable, 0, "Read Cmds");
	AddMenuItem(AdminDisable, 0, "Read PMs");
	AddMenuItem(AdminDisable, 0, "Capital Letters");
	AddMenuItem(AdminDisable, 0, "ConnectMessages");
	AddMenuItem(AdminDisable, 0, "AdminCmdMessages");
	AddMenuItem(AdminDisable, 0, "Auto Login");
	AddMenuItem(AdminDisable, 0, "Return");

	LWeather = CreateMenu("~b~Weather ~g~ Menu",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(LWeather, 0, "Set Weather");
	AddMenuItem(LWeather, 0, "Clear Blue Sky");
	AddMenuItem(LWeather, 0, "Sand Storm");
	AddMenuItem(LWeather, 0, "Thunderstorm");
	AddMenuItem(LWeather, 0, "Foggy");
	AddMenuItem(LWeather, 0, "Cloudy");
	AddMenuItem(LWeather, 0, "High Tide");
	AddMenuItem(LWeather, 0, "Purple Sky");
	AddMenuItem(LWeather, 0, "Black/White Sky");
	AddMenuItem(LWeather, 0, "Dark, Green Sky");
	AddMenuItem(LWeather, 0, "Heatwave");

	LTime = CreateMenu("~b~Time ~g~ Menu", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(LTime, 0, "Set Time");
	AddMenuItem(LTime, 0, "Morning");
	AddMenuItem(LTime, 0, "Mid day");
	AddMenuItem(LTime, 0, "Afternoon");
	AddMenuItem(LTime, 0, "Evening");
	AddMenuItem(LTime, 0, "Midnight");

	LCars = CreateMenu("~b~LethaL ~g~Cars", 2,  55.0, 150.0, 100.0, 80.0);
	SetMenuColumnHeader(LCars, 0, "Choose a car");
	AddMenuItem(LCars, 0, "Turismo");
	AddMenuItem(LCars, 0, "Bandito");
	AddMenuItem(LCars, 0, "Vortex");
	AddMenuItem(LCars, 0, "NRG");
	AddMenuItem(LCars, 0, "S.W.A.T");
    AddMenuItem(LCars, 0, "Hunter");
    AddMenuItem(LCars, 0, "Jetmax (boat)");
    AddMenuItem(LCars, 0, "Rhino");
    AddMenuItem(LCars, 0, "Monster Truck");
    AddMenuItem(LCars, 0, "Sea Sparrow");
    AddMenuItem(LCars, 0, "More");
	AddMenuItem(LCars, 0, "Return");

	LCars2 = CreateMenu("~b~LethaL ~g~Cars", 2,  55.0, 150.0, 100.0, 80.0);
	SetMenuColumnHeader(LCars2, 0, "Choose a car");
	AddMenuItem(LCars2, 0, "Dumper");
    AddMenuItem(LCars2, 0, "RC Tank");
    AddMenuItem(LCars2, 0, "RC Bandit");
    AddMenuItem(LCars2, 0, "RC Baron");
    AddMenuItem(LCars2, 0, "RC Goblin");
    AddMenuItem(LCars2, 0, "RC Raider");
    AddMenuItem(LCars2, 0, "RC Cam");
    AddMenuItem(LCars2, 0, "Tram");
	AddMenuItem(LCars2, 0, "Return");

	LTuneMenu = CreateMenu("~b~Tuning ~g~ Menu",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(LTuneMenu, 0, "Add to car");
	AddMenuItem(LTuneMenu,0,"NOS");
	AddMenuItem(LTuneMenu,0,"Hydraulics");
	AddMenuItem(LTuneMenu,0,"Wire Wheels");
	AddMenuItem(LTuneMenu,0,"Twist Wheels");
	AddMenuItem(LTuneMenu,0,"Access Wheels");
	AddMenuItem(LTuneMenu,0,"Mega Wheels");
	AddMenuItem(LTuneMenu,0,"Import Wheels");
	AddMenuItem(LTuneMenu,0,"Atomic Wheels");
	AddMenuItem(LTuneMenu,0,"Offroad Wheels");
	AddMenuItem(LTuneMenu,0,"Classic Wheels");
	AddMenuItem(LTuneMenu,0,"Paint Jobs");
	AddMenuItem(LTuneMenu,0,"Return");

	PaintMenu = CreateMenu("~b~Paint Job ~g~ Menu",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(PaintMenu, 0, "Choose paint");
	AddMenuItem(PaintMenu,0,"Paint Job 1");
	AddMenuItem(PaintMenu,0,"Paint Job 2");
	AddMenuItem(PaintMenu,0,"Paint Job 3");
	AddMenuItem(PaintMenu,0,"Paint Job 4");
	AddMenuItem(PaintMenu,0,"Paint Job 5");
	AddMenuItem(PaintMenu,0,"Black");
	AddMenuItem(PaintMenu,0,"White");
	AddMenuItem(PaintMenu,0,"Blue");
	AddMenuItem(PaintMenu,0,"Pink");
	AddMenuItem(PaintMenu,0,"Return");

	LVehicles = CreateMenu("~b~Vehicles ~g~ Menu",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(LVehicles, 0, "Choose a car");
	AddMenuItem(LVehicles,0,"2-door Cars");
	AddMenuItem(LVehicles,0,"4-door Cars");
	AddMenuItem(LVehicles,0,"Fast Cars");
	AddMenuItem(LVehicles,0,"Other Vehicles");
	AddMenuItem(LVehicles,0,"Bikes");
	AddMenuItem(LVehicles,0,"Boats");
	AddMenuItem(LVehicles,0,"Planes");
	AddMenuItem(LVehicles,0,"Helicopters");
	AddMenuItem(LVehicles,0,"Return");

 	twodoor = CreateMenu("~b~2-door Cars",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(twodoor, 0, "Choose a car");
	AddMenuItem(twodoor,0,"Feltzer");//533
	AddMenuItem(twodoor,0,"Stallion");//139
	AddMenuItem(twodoor,0,"Windsor");//555
	AddMenuItem(twodoor,0,"Bobcat");//422
	AddMenuItem(twodoor,0,"Yosemite");//554
	AddMenuItem(twodoor,0,"Broadway");//575
	AddMenuItem(twodoor,0,"Blade");//536
	AddMenuItem(twodoor,0,"Slamvan");//535
	AddMenuItem(twodoor,0,"Tornado");//576
	AddMenuItem(twodoor,0,"Bravura");//401
	AddMenuItem(twodoor,0,"Fortune");//526
	AddMenuItem(twodoor,0,"Return");

 	fourdoor = CreateMenu("~b~4-door Cars",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(fourdoor, 0, "Choose a car");
	AddMenuItem(fourdoor,0,"Perenniel");//404
	AddMenuItem(fourdoor,0,"Tahoma");//566
	AddMenuItem(fourdoor,0,"Voodoo");//412
	AddMenuItem(fourdoor,0,"Admiral");//445
	AddMenuItem(fourdoor,0,"Elegant");//507
	AddMenuItem(fourdoor,0,"Glendale");//466
	AddMenuItem(fourdoor,0,"Intruder");//546
	AddMenuItem(fourdoor,0,"Merit");//551
	AddMenuItem(fourdoor,0,"Oceanic");//467
	AddMenuItem(fourdoor,0,"Premier");//426
	AddMenuItem(fourdoor,0,"Sentinel");//405
	AddMenuItem(fourdoor,0,"Return");

 	fastcar = CreateMenu("~b~Fast Cars",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(fastcar, 0, "Choose a car");
	AddMenuItem(fastcar,0,"Comet");//480
	AddMenuItem(fastcar,0,"Buffalo");//402
	AddMenuItem(fastcar,0,"Cheetah");//415
	AddMenuItem(fastcar,0,"Euros");//587
	AddMenuItem(fastcar,0,"Hotring Racer");//494
	AddMenuItem(fastcar,0,"Infernus");//411
	AddMenuItem(fastcar,0,"Phoenix");//603
	AddMenuItem(fastcar,0,"Super GT");//506
	AddMenuItem(fastcar,0,"Turismo");//451
	AddMenuItem(fastcar,0,"ZR-350");//477
	AddMenuItem(fastcar,0,"Bullet");//541
	AddMenuItem(fastcar,0,"Return");

 	Othercars = CreateMenu("~b~Other Vehicles",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(Othercars, 0, "Choose a car?");
	AddMenuItem(Othercars,0,"Monster Truck");//556
	AddMenuItem(Othercars,0,"Trashmaster");//408
	AddMenuItem(Othercars,0,"Bus");//431
	AddMenuItem(Othercars,0,"Coach");//437
	AddMenuItem(Othercars,0,"Enforcer");//427
	AddMenuItem(Othercars,0,"Rhino (Tank)");//432
	AddMenuItem(Othercars,0,"S.W.A.T.Truck");//601
	AddMenuItem(Othercars,0,"Cement Truck");//524
	AddMenuItem(Othercars,0,"Flatbed");//455
	AddMenuItem(Othercars,0,"BF Injection");//424
	AddMenuItem(Othercars,0,"Dune");//573
	AddMenuItem(Othercars,0,"Return");

 	bikes = CreateMenu("~b~Bikes",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(bikes, 0, "Choose a bike");
	AddMenuItem(bikes,0,"BF-400");
	AddMenuItem(bikes,0,"BMX");
	AddMenuItem(bikes,0,"Faggio");
	AddMenuItem(bikes,0,"FCR-900");
	AddMenuItem(bikes,0,"Freeway");
	AddMenuItem(bikes,0,"NRG-500");
	AddMenuItem(bikes,0,"PCJ-600");
	AddMenuItem(bikes,0,"Pizzaboy");
	AddMenuItem(bikes,0,"Quad");
	AddMenuItem(bikes,0,"Sanchez");
	AddMenuItem(bikes,0,"Wayfarer");
	AddMenuItem(bikes,0,"Return");

 	boats = CreateMenu("~b~Boats",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(boats, 0, "Choose a boat");
	AddMenuItem(boats,0,"Coastguard");//472
	AddMenuItem(boats,0,"Dingy");//473
	AddMenuItem(boats,0,"Jetmax");//493
	AddMenuItem(boats,0,"Launch");//595
	AddMenuItem(boats,0,"Marquis");//484
	AddMenuItem(boats,0,"Predator");//430
	AddMenuItem(boats,0,"Reefer");//453
	AddMenuItem(boats,0,"Speeder");//452
	AddMenuItem(boats,0,"Squallo");//446
	AddMenuItem(boats,0,"Tropic");//454
	AddMenuItem(boats,0,"Return");

 	planes = CreateMenu("~b~Planes",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(planes, 0, "Choose a plane");
	AddMenuItem(planes,0,"Andromada");//592
	AddMenuItem(planes,0,"AT400");//577
	AddMenuItem(planes,0,"Beagle");//511
	AddMenuItem(planes,0,"Cropduster");//512
	AddMenuItem(planes,0,"Dodo");//593
	AddMenuItem(planes,0,"Hydra");//520
	AddMenuItem(planes,0,"Nevada");//553
	AddMenuItem(planes,0,"Rustler");//476
	AddMenuItem(planes,0,"Shamal");//519
	AddMenuItem(planes,0,"Skimmer");//460
	AddMenuItem(planes,0,"Stuntplane");//513
	AddMenuItem(planes,0,"Return");

	helicopters = CreateMenu("~b~Helicopters",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(helicopters, 0, "Choose a helicopter");
	AddMenuItem(helicopters,0,"Cargobob");//
	AddMenuItem(helicopters,0,"Hunter");//
	AddMenuItem(helicopters,0,"Leviathan");//
	AddMenuItem(helicopters,0,"Maverick");//
	AddMenuItem(helicopters,0,"News Chopper");//
	AddMenuItem(helicopters,0,"Police Maverick");//
	AddMenuItem(helicopters,0,"Raindance");//
	AddMenuItem(helicopters,0,"Seasparrow");//
	AddMenuItem(helicopters,0,"Sparrow");//
	AddMenuItem(helicopters,0,"Return");

 	XWeapons = CreateMenu("~b~Weapons ~g~Main Menu",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(XWeapons, 0, "Choose a weapon");
	AddMenuItem(XWeapons,0,"Desert Eagle");//0
	AddMenuItem(XWeapons,0,"M4");
	AddMenuItem(XWeapons,0,"Sawnoff Shotgun");
	AddMenuItem(XWeapons,0,"Combat Shotgun");
	AddMenuItem(XWeapons,0,"UZI");
	AddMenuItem(XWeapons,0,"Rocket Launcher");
	AddMenuItem(XWeapons,0,"Minigun");//6
	AddMenuItem(XWeapons,0,"Sniper Rifle");
	AddMenuItem(XWeapons,0,"Big Weapons");
	AddMenuItem(XWeapons,0,"Small Weapons");//9
	AddMenuItem(XWeapons,0,"More");
	AddMenuItem(XWeapons,0,"Return");//11

 	XWeaponsBig = CreateMenu("~b~Weapons ~g~Big Weapons",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(XWeaponsBig, 0, "Choose a weapon");
	AddMenuItem(XWeaponsBig,0,"Shotgun");
	AddMenuItem(XWeaponsBig,0,"AK-47");
	AddMenuItem(XWeaponsBig,0,"Country Rifle");
	AddMenuItem(XWeaponsBig,0,"HS Rocket Launcher");
	AddMenuItem(XWeaponsBig,0,"Flamethrower");
	AddMenuItem(XWeaponsBig,0,"SMG");
	AddMenuItem(XWeaponsBig,0,"TEC9");
	AddMenuItem(XWeaponsBig,0,"Return");

 	XWeaponsSmall = CreateMenu("~b~Weapons ~g~Small Weapons",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(XWeaponsBig, 0, "Choose a weapon");
	AddMenuItem(XWeaponsSmall,0,"9mm");
	AddMenuItem(XWeaponsSmall,0,"Silenced 9mm");
	AddMenuItem(XWeaponsSmall,0,"Molotov Cocktail");
	AddMenuItem(XWeaponsSmall,0,"Fire Extinguisher");
	AddMenuItem(XWeaponsSmall,0,"Spraycan");
	AddMenuItem(XWeaponsSmall,0,"Frag Grenades");
	AddMenuItem(XWeaponsSmall,0,"Katana");
	AddMenuItem(XWeaponsSmall,0,"Chainsaw");
	AddMenuItem(XWeaponsSmall,0,"Return");

 	XWeaponsMore = CreateMenu("~b~Weapons ~g~More Weapons",2, 55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(XWeaponsBig, 0, "Choose a weapon");
	AddMenuItem(XWeaponsMore,0,"Jetpack");
	AddMenuItem(XWeaponsMore,0,"Knife");
	AddMenuItem(XWeaponsMore,0,"Flowers");
	AddMenuItem(XWeaponsMore,0,"Camera");
	AddMenuItem(XWeaponsMore,0,"Pool Cue");
	AddMenuItem(XWeaponsMore,0,"Baseball Bat");
	AddMenuItem(XWeaponsMore,0,"Golf Club");
	AddMenuItem(XWeaponsMore,0,"MAX AMMO");
	AddMenuItem(XWeaponsMore,0,"Return");

	LTele = CreateMenu("Teleports", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(LTele, 0, "Teleport to where?");
	AddMenuItem(LTele, 0, "Las Venturas");//0
	AddMenuItem(LTele, 0, "Los Santos");//1
	AddMenuItem(LTele, 0, "San Fierro");//2
	AddMenuItem(LTele, 0, "The Desert");//3
	AddMenuItem(LTele, 0, "Flint Country");//4
	AddMenuItem(LTele, 0, "Mount Chiliad");//5
	AddMenuItem(LTele, 0, "Interiors");//6
	AddMenuItem(LTele, 0, "Return");//8

	LasVenturasMenu = CreateMenu("Las Venturas", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(LasVenturasMenu, 0, "Teleport to where?");
	AddMenuItem(LasVenturasMenu, 0, "The Strip");//0
	AddMenuItem(LasVenturasMenu, 0, "Come-A-Lot");//1
	AddMenuItem(LasVenturasMenu, 0, "LV Airport");//2
	AddMenuItem(LasVenturasMenu, 0, "KACC Military Fuels");//3
	AddMenuItem(LasVenturasMenu, 0, "Yellow Bell Golf Club");//4
	AddMenuItem(LasVenturasMenu, 0, "Baseball Pitch");//5
	AddMenuItem(LasVenturasMenu, 0, "Return");//6

	LosSantosMenu = CreateMenu("Los Santos", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(LosSantosMenu, 0, "Teleport to where?");
	AddMenuItem(LosSantosMenu, 0, "Ganton");//0
	AddMenuItem(LosSantosMenu, 0, "LS Airport");//1
	AddMenuItem(LosSantosMenu, 0, "Ocean Docks");//2
	AddMenuItem(LosSantosMenu, 0, "Pershing Square");//3
	AddMenuItem(LosSantosMenu, 0, "Verdant Bluffs");//4
	AddMenuItem(LosSantosMenu, 0, "Santa Maria Beach");//5
	AddMenuItem(LosSantosMenu, 0, "Mulholland");//6
	AddMenuItem(LosSantosMenu, 0, "Richman");//7
	AddMenuItem(LosSantosMenu, 0, "Return");//8

	SanFierroMenu = CreateMenu("San Fierro", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(SanFierroMenu, 0, "Teleport to where?");
	AddMenuItem(SanFierroMenu, 0, "SF Station");//0
	AddMenuItem(SanFierroMenu, 0, "SF Airport");//1
	AddMenuItem(SanFierroMenu, 0, "Ocean Flats");//2
	AddMenuItem(SanFierroMenu, 0, "Avispa Country Club");//3
	AddMenuItem(SanFierroMenu, 0, "Easter Basin (docks)");//4
	AddMenuItem(SanFierroMenu, 0, "Esplanade North");//5
	AddMenuItem(SanFierroMenu, 0, "Battery Point");//6
	AddMenuItem(SanFierroMenu, 0, "Return");//7

	DesertMenu = CreateMenu("The Desert", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(DesertMenu, 0, "Teleport to where?");
	AddMenuItem(DesertMenu, 0, "Aircraft Graveyard");//0
	AddMenuItem(DesertMenu, 0, "Area 51");//1
	AddMenuItem(DesertMenu, 0, "The Big Ear");//2
	AddMenuItem(DesertMenu, 0, "The Sherman Dam");//3
	AddMenuItem(DesertMenu, 0, "Las Barrancas");//4
	AddMenuItem(DesertMenu, 0, "El Quebrados");//5
	AddMenuItem(DesertMenu, 0, "Octane Springs");//6
	AddMenuItem(DesertMenu, 0, "Return");//7

	FlintMenu = CreateMenu("Flint Country", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(FlintMenu, 0, "Teleport to where?");
	AddMenuItem(FlintMenu, 0, "The Lake");//0
	AddMenuItem(FlintMenu, 0, "Leafy Hollow");//1
	AddMenuItem(FlintMenu, 0, "The Farm");//2
	AddMenuItem(FlintMenu, 0, "Shady Cabin");//3
	AddMenuItem(FlintMenu, 0, "Flint Range");//4
	AddMenuItem(FlintMenu, 0, "Becon Hill");//5
	AddMenuItem(FlintMenu, 0, "Fallen Tree");//6
	AddMenuItem(FlintMenu, 0, "Return");//7

	MountChiliadMenu = CreateMenu("Mount Chiliad", 2,  55.0, 200.0, 100.0, 80.0);
	SetMenuColumnHeader(MountChiliadMenu, 0, "Teleport to where?");
	AddMenuItem(MountChiliadMenu, 0, "Chiliad Jump");//0
	AddMenuItem(MountChiliadMenu, 0, "Bottom Of Chiliad");//1
	AddMenuItem(MountChiliadMenu, 0, "Highest Point");//2
	AddMenuItem(MountChiliadMenu, 0, "Chiliad Path");//3
	AddMenuItem(MountChiliadMenu, 0, "Return");//7

	InteriorsMenu = CreateMenu("Interiors", 2,  55.0, 200.0, 130.0, 80.0);
	SetMenuColumnHeader(InteriorsMenu, 0, "Teleport to where?");
	AddMenuItem(InteriorsMenu, 0, "Planning Department");//0
	AddMenuItem(InteriorsMenu, 0, "LV PD");//1
	AddMenuItem(InteriorsMenu, 0, "Pizza Stack");//2
	AddMenuItem(InteriorsMenu, 0, "RC Battlefield");//3
	AddMenuItem(InteriorsMenu, 0, "Caligula's Casino");//4
	AddMenuItem(InteriorsMenu, 0, "Big Smoke's Crack Palace");//5
	AddMenuItem(InteriorsMenu, 0, "Madd Dogg's Mansion");//6
	AddMenuItem(InteriorsMenu, 0, "Dirtbike Stadium");//7
	AddMenuItem(InteriorsMenu, 0, "Vice Stadium (duel)");//8
	AddMenuItem(InteriorsMenu, 0, "Ammu-nation");//9
	AddMenuItem(InteriorsMenu, 0, "Atrium");//7
	AddMenuItem(InteriorsMenu, 0, "Return");//8
	#endif

	for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) OnPlayerConnect(i);
	for(new i = 1; i < MAX_CHAT_LINES; i++) Chat[i] = "<none>";
	for(new i = 1; i < MAX_REPORTS; i++) Reports[i] = "<none>";

	PingTimer = SetTimer("PingKick",5000,1);
	GodTimer = SetTimer("GodUpdate",2000,1);

	new year,month,day;	getdate(year, month, day);
	new hour,minute,second; gettime(hour,minute,second);

	print("________________________________________");
	print("           ladmin Version 1.0           ");
	print("                Loaded                  ");
	print("________________________________________");
	printf("     Date: %d/%d/%d  Time: %d:%d :%d   ",day,month,year, hour, minute, second);
	print("________________________________________");
	print("________________________________________\n");

	if(RANDOMMSG == 1)
	{
		SetTimer("SendRandomMessage",TIMER,1);
	}

	AddRandomMessage("Hey, how are you?");
	AddRandomMessage("Are you having a good time here?");
	AddRandomMessage("How was your day guys?");
	AddRandomMessage("Do you like me?");
	AddRandomMessage("I love you all <3");
	AddRandomMessage("Hohoho, what's up guys? Having fun?");
	print("Jennifer Loaded");
	return 1;
}
//==============================================================================
public OnFilterScriptExit()
{
	KillTimer(PingTimer);
	KillTimer(GodTimer);
	#if defined USE_MENUS
	DestroyAllMenus();
	#endif

	typem = -1;
	endm = 0;
	KillTimer(xReactionTimer);
	KillTimer(timermath);
	KillTimer(timerid);
    remcpss();

	for(new i = 0; i < sizeof(shoecord); i++)
	{
		DestroyPickup(hshoe[shoecord[i][pickup]]);
	}
	new year,month,day;	getdate(year, month, day);
	new hour,minute,second; gettime(hour,minute,second);
	print("\n________________________________________");
	print("________________________________________");
	print("           ladmin Unloaded              ");
	print("________________________________________");
	printf("     Date: %d/%d/%d  Time: %d:%d :%d   ",day,month,year, hour, minute, second);
	print("________________________________________");
	print("________________________________________\n");
    for(new all = 0; all < MAX_PLAYERS; all++)
	{
	   SavePlayer(all);
    }
	return 1;
}

//==============================================================================
public OnPlayerConnect(playerid)
{
    players_connected++;
    PlayerInfo[playerid][Hours] = 0;
    PlayerInfo[playerid][Minutes] = 0;
	SetPVarInt(playerid, "AdminGivenMini", 0);
	SetPVarInt(playerid, "inMini", 0);
	SetPVarInt(playerid, "Frozen", 0);
	PlayerOnlineTime[playerid] = SetTimerEx("PlayerTimeOnline", 60000, true, "i", playerid);
	PlayerInfo[playerid][ChatColor] = 4294967295;
	InitFly(playerid);
	EnableStuntBonusForAll(false);
    TimeVIP[playerid] = 0;
	SetPVarInt(playerid, "InFFA", 0);
	PlayerInfo[playerid][Jailed] = 0;
	PlayerInfo[playerid][Muted] = 0;
	PlayerInfo[playerid][OnDuty] = 0;
	PlayerInfo[playerid][DisablePMs] = 0;
	PlayerInfo[playerid][ADisabledPMs] = 0;
	PlayerInfo[playerid][Muted] = 0;
	PlayerInfo[playerid][Hide] = 0;
	PMReply[playerid]=-255;
	VIPTag[playerid] = 0;
    PSkinID[playerid] = 0;
	TrialModeratorTag[playerid] = 0;
	ModTag[playerid] = 0;
	CoAdminTag[playerid] = 0;
	AdminTag[playerid] = 0;
	LeaderTag[playerid] = 0;
	ManagerTag[playerid] = 0;
	TBSStaffTag[playerid] = 0;
	TBStag[playerid] = 0;
	COAtag[playerid] = 0;
	Atag[playerid] = 0;
	Ltag[playerid] = 0;
	CEOtag[playerid] = 0;
	ttag[playerid] = 0;
	mtag[playerid] = 0;
	vtag[playerid] = 0;
	djtag[playerid] = 0;
    DeletePlayer3DTextLabel(playerid, PlayerText3D:0);
    DeletePlayer3DTextLabel(playerid, PlayerText3D:1);
    DeletePlayer3DTextLabel(playerid, PlayerText3D:2);
    DeletePlayer3DTextLabel(playerid, PlayerText3D:3);
    DeletePlayer3DTextLabel(playerid, PlayerText3D:4);
    DeletePlayer3DTextLabel(playerid, PlayerText3D:5);
    DeletePlayer3DTextLabel(playerid, PlayerText3D:6);
    DeletePlayer3DTextLabel(playerid, PlayerText3D:7);
	PlayerInfo[playerid][Frozen] = 0;
	PlayerInfo[playerid][Level] = 0;
	pInvincible[playerid] = false;
	PlayerInfo[playerid][isDJ] = 0;
	PlayerInfo[playerid][pVip] = 0;
	PlayerInfo[playerid][Mathematics] = 0;
	PlayerInfo[playerid][pBrownies] = 0;
	PlayerInfo[playerid][Cookies] = 0;
	PlayerInfo[playerid][Reactions] = 0;
	PlayerInfo[playerid][CheckPoints] = 0;
	PlayerInfo[playerid][MoneyBags] = 0;
	PlayerInfo[playerid][CookieJars] = 0;
	PlayerInfo[playerid][HS] = 0;
	PlayerInfo[playerid][hours] = 0;
	PlayerInfo[playerid][mins] = 0;
    SuperJump[playerid] = 0;
    VIPName[playerid] = 0;
	VIPWarning[playerid] = 0;
	PlayerInfo[playerid][LoggedIn] = 0;
	PlayerInfo[playerid][Registered] = 0;
	PlayerInfo[playerid][God] = 0;
	PlayerInfo[playerid][Boost] = 0;
	PlayerInfo[playerid][GodCar] = 0;
	PlayerInfo[playerid][TimesSpawned] = 0;
	PlayerInfo[playerid][Muted] = 0;
	PlayerInfo[playerid][MuteWarnings] = 0;
	PlayerInfo[playerid][Warnings] = 0;
	PlayerInfo[playerid][Caps] = 0;
	PlayerInfo[playerid][DoorsLocked] = 0;
	PlayerInfo[playerid][pCar] = 0;
	for(new i; i<PING_MAX_EXCEEDS; i++) PlayerInfo[playerid][pPing][i] = 0;
	PlayerInfo[playerid][SpamCount] = 0;
	PlayerInfo[playerid][SpamTime] = 0;
	PlayerInfo[playerid][PingCount] = 0;
	PlayerInfo[playerid][PingTime] = 0;
	PlayerInfo[playerid][FailLogin] = 0;
	PlayerInfo[playerid][ConnectTime] = gettime();

    Killsp[playerid] = PlayerInfo[playerid][Kills];
	Deathsp[playerid] = PlayerInfo[playerid][pDeaths];
	//------------------------------------------------------
	new PlayerName[MAX_PLAYER_NAME], string[128], str[128];
	GetPlayerName(playerid, PlayerName, MAX_PLAYER_NAME);
	new tmp3[50]; GetPlayerIp(playerid,tmp3,50);
	new ip[16];
    GetPlayerIp(playerid, ip, sizeof(ip));
	//-----------------------------------------------------

	LoadPlayer(playerid);
	if(dUserINT(PlayerName2(playerid)).("Jailed") == 1) {
	    SetTimerEx("JailPlayer",3000,0,"d",playerid); return SendClientMessage(playerid,red,"You can't escape your punishment! You Are Still In Jail!!!");
	}
	if(PlayerInfo[playerid][pVip] >= 2 || PlayerInfo[playerid][Level] >= 2)
	{
      SetPlayerArmour(playerid, 50.0);
	}
	if(PlayerInfo[playerid][pVip] >= 3 || PlayerInfo[playerid][Level] >= 3)
	{
      SetPlayerArmour(playerid, 100.0);
	}
 	if (dUserINT(PlayerName2(playerid)).("banned") == 1)
    {
        new playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME];
        new TargetString[256];
        format(TargetString,sizeof(TargetString),"Sorry '%s'\n\nYou are banned from the server!\n\nAdmin who banned you: %s", playername, adminname), ShowPlayerDialog(playerid, 16749, DIALOG_STYLE_MSGBOX , "{FF0000}BANNED!{FFFFFF}", TargetString, "OK", "");
        SendClientMessage(playerid, red, "{FFFFFF}You are banned from <{FF0000}The Best Stunts - Official{FFFFFF}>");
        SendClientMessage(playerid, red, "{FFFFFF}If you feel like  you have been banned for no reason post an appeal");
        SendClientMessage(playerid, red, "{FFFFFF}at <{FF0000}tbs-official.eu{FFFFFF}>");
        SendClientMessage(playerid, red, "{FFF000}-Please contact an admin if this message is an error.-");
		format(string,sizeof(string),"%s ID:%d was auto kicked. Reason: Name banned from server",PlayerName,playerid);
		SendClientMessageToAll(grey, string);
		print(string);
		SaveToFile("KickLog",string);
        BanEx(playerid, string);
	    Kick(playerid);
	    return 1;
    }
	if(ServerInfo[ConnectMessages] == 1)
	{
    if(PlayerInfo[playerid][Level] == 0)
	{
		new pAKA[256]; pAKA = dini_Get("ladmin/config/aka.txt",tmp3);
		format(str,sizeof(str),"{C0C0C0}<{00FF00}+{C0C0C0}> {%06x}%s(%d) {87CEFA}has joined the server {C0C0C0}[%d/%d]", GetPlayerColor(playerid) >>> 8, PlayerName, playerid, players_connected, GetMaxPlayers());
		for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && playerid != i)
		{
			if(PlayerInfo[i][Level] >= 2) SendClientMessage(i,grey,str);
			else {
				format(string,sizeof(string),"{C0C0C0}<{00FF00}+{C0C0C0}> {%06x}%s(%d) {87CEFA}has joined the server AKA: %s", GetPlayerColor(playerid) >>> 8, PlayerName, playerid, pAKA);
			 	SendClientMessage(i,grey,string);
			}
		}
	}
	}
	//-----------------------------------------------------
	if(ServerInfo[NameKick] == 1) {
		for(new s = 0; s < BadNameCount; s++) {
  			if(!strcmp(BadNames[s],PlayerName,true)) {
				SendClientMessage(playerid,red, "Your name is on our black list, you have been kicked.");
				format(string,sizeof(string),"%s ID:%d was auto kicked. (Reason: Forbidden name)",PlayerName,playerid);
				SendClientMessageToAll(grey, string);  print(string);
				SaveToFile("KickLog",string);  Kick(playerid);
				return 1;
			}
		}
	}
	//-----------------------------------------------------
	if(ServerInfo[PartNameKick] == 1) {
		for(new s = 0; s < BadPartNameCount; s++) {
			new pos;
			while((pos = strfind(PlayerName,BadPartNames[s],true)) != -1) for(new i = pos, j = pos + strlen(BadPartNames[s]); i < j; i++)
			{
				SendClientMessage(playerid,red, "Your name is not allowed on this server, you have been kicked.");
				format(string,sizeof(string),"%s ID:%d was auto kicked. (Reason: Forbidden name)",PlayerName,playerid);
				SendClientMessageToAll(grey, string);  print(string);
				SaveToFile("KickLog",string);  Kick(playerid);
				return 1;
			}
		}
	}
	//-----------------------------------------------------
	if(ServerInfo[Locked] == 1) {
		PlayerInfo[playerid][AllowedIn] = false;
		SendClientMessage(playerid,red,"Server is Locked!  You have 20 seconds to enter the server password before you are kicked!");
		SendClientMessage(playerid,red," Type /password [password]");
		LockKickTimer[playerid] = SetTimerEx("AutoKick", 20000, 0, "i", playerid);
	}
	//-----------------------------------------------------
	if(strlen(dini_Get("ladmin/config/aka.txt", tmp3)) == 0) dini_Set("ladmin/config/aka.txt", tmp3, PlayerName);
 	else
	{
	    if( strfind( dini_Get("ladmin/config/aka.txt", tmp3), PlayerName, true) == -1 )
		{
		    format(string,sizeof(string),"%s,%s", dini_Get("ladmin/config/aka.txt",tmp3), PlayerName);
		    dini_Set("ladmin/config/aka.txt", tmp3, string);
		}
	}
	//Temp VIP
	new RemainingVIPTime, Days;
	if(dUserINT(PlayerName2(playerid)).("VIPTime") > gettime())
	{
		RemainingVIPTime = dUserINT(PlayerName2(playerid)).("VIPTime") - gettime();
		StoDHMS(RemainingVIPTime, Days);
        SendClientMessage(playerid, -1, "Your VIP has expired. /donate again if you wish to continue your VIP status!");
		GameTextForPlayer(playerid,"VIP Expired", 3000, 3);
		PlayerInfo[playerid][pVip] = 0;
		return 1;
	}
	//-----------------------------------------------------
	new dialogstr[256];
    new pame[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pame, sizeof(pame));
	if(!udb_Exists(PlayerName2(playerid))) format(dialogstr,sizeof(dialogstr),"{FFFFFF}Welcome to {00FFFF}The Best™ Stunts© - Official\n\n{FFFFFF}This account {00FFFF}'%s' {FFFFFF}is not registed.\n\n{FFFFFF}Please register by entering your password below:", pame), ShowPlayerDialog(playerid, 9049, DIALOG_STYLE_PASSWORD, "{FF0000}Register", dialogstr, "Enter", "Cancel");
	else
	{
        //Date = Month, Date2 = Day, Date3 = Year
        new date, date2, date3, file[256];
		getdate(date2, date, date3);
        format(PlayerInfo[playerid][accDate], 150, "%02d/%02d/%d", date2, date, date3);
		PlayerInfo[playerid][Registered] = 1;
		format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(PlayerName));
		new tmp2[256]; tmp2 = dini_Get(file,"ip");

		if( (!strcmp(tmp3,tmp2,true)) && (ServerInfo[AutoLogin] == 1) )
		{
        LoginPlayer(playerid);
		if(PlayerInfo[playerid][Level] == 0)
        {
            format(string,sizeof(string),"ACCOUNT: You have been automatically logged in");
            SendClientMessage(playerid,green,string);
        }
        if(PlayerInfo[playerid][Level] == 1) {
            format(string,sizeof(string),"{FFFF00}* {F81414}({1919FF}Trial Moderator{F81414}) %s{6EF83C} has logged in!", pame);
		    SendClientMessageToAll(green,string);
       	    format(string,sizeof(string),"ACCOUNT: You're Auto Logged In. (Trial Moderator)");
		    SendClientMessage(playerid,green,string);
        }
        if(PlayerInfo[playerid][Level] == 2) {
		    format(string,sizeof(string),"{FFFF00}** {F81414}({919191}Moderator{F81414}) %s{6EF83C} has logged in!", pame);
		    SendClientMessageToAll(green,string);
       	    format(string,sizeof(string),"ACCOUNT: You're Auto Logged In. (Moderator)");
		    SendClientMessage(playerid,green,string);
        }
        if(PlayerInfo[playerid][Level] == 3) {
		    format(string,sizeof(string),"{FFFF00}*** {F81414}({33AA33}Administrator{F81414}) %s{6EF83C} has logged in!", pame);
		    SendClientMessageToAll(LightGreen,string);
          	format(string,sizeof(string),"ACCOUNT: You're Auto Logged In. (Administrator)");
		    SendClientMessage(playerid,LightGreen,string);
        }
        if(PlayerInfo[playerid][Level] == 4) {
		    format(string,sizeof(string),"{FF0000}****%s [Senior Administrator] has logged in.", pame);
	    	SendClientMessageToAll(LightGreen,string);
	    	format(string,sizeof(string),"ACCOUNT: You're Auto Logged In. (Senior Administrator)");
	    	SendClientMessage(playerid,LightGreen,string);
        }
 	    if(PlayerInfo[playerid][Level] == 5) {
	    	format(string,sizeof(string),"{FFFF00}***** {F81414}({FFFFFF}Head Administrator{F81414}) %s{6EF83C} has logged in!", pame);
	    	SendClientMessageToAll(lightblue,string);
	    	format(string,sizeof(string),"ACCOUNT: You're Auto Logged In. (Head Administrator)" );
	    	SendClientMessage(playerid,lightblue,string);
        }
 	    if(PlayerInfo[playerid][Level] == 6) {
	    	format(string,sizeof(string),"{FFFF00}******* {F81414}({00F2FF}Manager/CEO{F81414}) %s{6EF83C} has logged in!", pame);
	    	SendClientMessageToAll(RED,string);
	    	format(string,sizeof(string),"ACCOUNT: You're Auto Logged In. (Manager/CEO)");
	    	SendClientMessage(playerid,RED,string);
        }
 	    if(PlayerInfo[playerid][pVip] == 1)
        {
            format(string,sizeof(string),"{FF0000}%s{FFFF00} [{E9E9E9}Silver VIP] has logged in.", pame);
			SendClientMessageToAll(green,string);
			format(string,sizeof(string),"ACCOUNT: You're Auto Logged In As {E9E9E9}Silver VIP");
			SendClientMessage(playerid,green,string);
	   	}
		if(PlayerInfo[playerid][pVip] == 2)
		{
            format(string,sizeof(string),"{FF0000}%s{FFFF00} [{FFFF00}Gold] has logged in.", pame);
			SendClientMessageToAll(green,string);
			format(string,sizeof(string),"ACCOUNT: You're Auto Logged In As {FFFF00}Gold VIP");
			SendClientMessage(playerid,green,string);
		}
		if(PlayerInfo[playerid][pVip] == 3)
		{
            format(string,sizeof(string),"{FF0000}%s{FFFF00} [{0000FF}Platinum] has logged in.", pame);
			SendClientMessageToAll(green,string);
			format(string,sizeof(string),"ACCOUNT: You're Auto Logged In As {0000FF}Platinum VIP");
			SendClientMessage(playerid,green,string);
		}
		if(PlayerInfo[playerid][pVip] == 4)
		{
            format(string,sizeof(string),"{FF0000}%s{FFFF00} [{00FF00}Permanent] has logged in.", pame);
			SendClientMessageToAll(green,string);
			format(string,sizeof(string),"ACCOUNT: You're Auto Logged In As {00FF00}Permanent VIP");
			SendClientMessage(playerid,green,string);
		}
		if(PlayerInfo[playerid][isDJ] == 1)
		{
            format(string,sizeof(string),"{C0C0C0}%s{C0C0C0} [{0000FF}DJ{0000FF}] {C0C0C0}has logged in.", pame);
			SendClientMessageToAll(green,string);
			format(string,sizeof(string),"ACCOUNT: You're Auto Logged In As {C0C0C0}TBS DJ");
			SendClientMessage(playerid,green,string);
		}
		}
		else format(dialogstr,sizeof(dialogstr),"{FF0000}Welcome back, {00FFFF}%s{FF0000} to {00FFFF}The Best™ Stunts© - Official{FF0000} This account is already Registered!\nPlease insert your password below to Login:", pame), ShowPlayerDialog(playerid, 9048, DIALOG_STYLE_PASSWORD , "Logging in...", dialogstr, "Play", "Quit");
	}
	return 1;
}

public OnPlayerModelSelection(playerid, response, listid, modelid)
{
	new string[150];
    if(listid == skinlist)
    {
        if(response)
        {
			format(string, sizeof string, "{FFFF00}You have changed your skin from {C0C0C0}%d {FFFF00}to {C0C0C0}%d, type /useskin to save it.", GetPlayerSkin(playerid), modelid);
			SendClientMessage(playerid, -1, string);
            SetPlayerSkin(playerid, modelid);
            SavePlayer(playerid);
		}
        return 1;
    }
    return 1;
}

//==============================================================================

forward AutoKick(playerid);
public AutoKick(playerid)
{
	if( IsPlayerConnected(playerid) && ServerInfo[Locked] == 1 && PlayerInfo[playerid][AllowedIn] == false) {
		new string[128];
		SendClientMessage(playerid,grey,"You have been automatically kicked. Reason: Server Locked");
		format(string,sizeof(string),"%s ID:%d has been automatically kicked. Reason: Server Locked",PlayerName2(playerid),playerid);
		SaveToFile("KickLog",string);  Kick(playerid);
		SendClientMessageToAll(grey, string); print(string);
	}
	return 1;
}

//==============================================================================

public OnPlayerDisconnect(playerid, reason)
{

	//Rank
	Delete3DTextLabel(label6);
    Delete3DTextLabel(label7);
    Delete3DTextLabel(label8);
    Delete3DTextLabel(label9);
    Delete3DTextLabel(label10);
    Delete3DTextLabel(label11);
    Delete3DTextLabel(label12);
    Delete3DTextLabel(label13);
    Delete3DTextLabel(label14);
    Delete3DTextLabel(label15);
    Delete3DTextLabel(label16);

	SavePlayer(playerid);

    players_connected--;

    new PlayerName[MAX_PLAYER_NAME], DisconnectString[512];
    GetPlayerName(playerid, PlayerName, sizeof(PlayerName));
	//if(ServerInfo[ConnectMessages] == 1)
	//{
           switch (reason)
	       {
               case 0:	format(DisconnectString, sizeof(DisconnectString), "{C0C0C0}<{FF0000}-{C0C0C0}> {%06x}%s(%d) {87CEFA}has disconnected {E01B4C}Reason: Crash/Rage Quit {C0C0C0}[%d/%d]", (GetPlayerColor(playerid) >>> 8), PlayerName, playerid, players_connected, GetMaxPlayers());
               case 1:	format(DisconnectString, sizeof(DisconnectString), "{C0C0C0}<{FF0000}-{C0C0C0}> {%06x}%s(%d) {87CEFA}has disconnected {E01B4C}Reason: Leaving {C0C0C0}[%d/%d]", (GetPlayerColor(playerid) >>> 8), PlayerName, playerid, players_connected, GetMaxPlayers());
               case 2:	format(DisconnectString, sizeof(DisconnectString), "{C0C0C0}<{FF0000}-{C0C0C0}> {%06x}%s(%d) {87CEFA}has disconnected {E01B4C}Reason: Kicked/Banned! {C0C0C0}[%d/%d]", (GetPlayerColor(playerid) >>> 8), PlayerName, playerid, players_connected, GetMaxPlayers());
		   }
	//}
    SendClientMessageToAll(COLOR_GREY, DisconnectString);


	VIPTag[playerid] = 0;
    DestroyDynamic3DTextLabel(VIP[playerid]);
    Delete3DTextLabel(VIP[playerid]);
    TrialModeratorTag[playerid] = 0;
    DestroyDynamic3DTextLabel(TrialModerator[playerid]);
    Delete3DTextLabel(TrialModerator[playerid]);
    ModTag[playerid] = 0;
    DestroyDynamic3DTextLabel(Mod[playerid]);
    Delete3DTextLabel(Mod[playerid]);
    CoAdminTag[playerid] = 0;
    DestroyDynamic3DTextLabel(CoAdmin[playerid]);
    Delete3DTextLabel(CoAdmin[playerid]);
    AdminTag[playerid] = 0;
    DestroyDynamic3DTextLabel(Admin[playerid]);
    Delete3DTextLabel(Admin[playerid]);
    LeaderTag[playerid] = 0;
    DestroyDynamic3DTextLabel(Leader[playerid]);
    Delete3DTextLabel(Leader[playerid]);
    ManagerTag[playerid] = 0;
    DestroyDynamic3DTextLabel(Manager[playerid]);
    Delete3DTextLabel(Manager[playerid]);
    TBStag[playerid] = 0;
    PlayerInfo[playerid][LoggedIn] = 0;
	PlayerInfo[playerid][Level] = 0;
	PlayerInfo[playerid][isDJ] = 0;
	PlayerInfo[playerid][pVip] = 0;
	PlayerInfo[playerid][Muted] = 0;
	PlayerInfo[playerid][Frozen] = 0;
	PlayerInfo[playerid][OnDuty] = 0;
	PlayerInfo[playerid][Hours] = 0;
	PlayerInfo[playerid][Minutes] = 0;
	PlayerInfo[playerid][Hide] = 0;
	SuperJump[playerid] = 0;
	PlayerInfo[playerid][pCar] = 0;
	PlayerInfo[playerid][VIPColour] = 0;
	PlayerInfo[playerid][Kills] = Killsp[playerid];
	PlayerInfo[playerid][pDeaths] = Deathsp[playerid];
	KillTimer(PlayerOnlineTime[playerid]);

    DeletePlayer3DTextLabel(playerid, PlayerText3D:0);
    DeletePlayer3DTextLabel(playerid, PlayerText3D:1);
    DeletePlayer3DTextLabel(playerid, PlayerText3D:2);
    DeletePlayer3DTextLabel(playerid, PlayerText3D:3);
    DeletePlayer3DTextLabel(playerid, PlayerText3D:4);
    DeletePlayer3DTextLabel(playerid, PlayerText3D:5);
    DeletePlayer3DTextLabel(playerid, PlayerText3D:6);
    DeletePlayer3DTextLabel(playerid, PlayerText3D:7);

	if(PlayerInfo[playerid][Muted] == 1) KillTimer( MuteTimer[playerid] );
	if(PlayerInfo[playerid][Frozen] == 1) KillTimer( FreezeTimer[playerid] );
	if(ServerInfo[Locked] == 1)	KillTimer( LockKickTimer[playerid] );

	if(PlayerInfo[playerid][pCar] != 0) CarDeleter(PlayerInfo[playerid][pCar]);
	#if defined ENABLE_SPEC
	for(new x=0; x<MAX_PLAYERS; x++)
	    if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && PlayerInfo[x][SpecID] == playerid)
   		   	AdvanceSpectate(x);
	#endif
	return 1;
}
forward DelayKillPlayer(playerid);
public DelayKillPlayer(playerid)
{
	SetPlayerHealth(playerid,0.0);
	ForceClassSelection(playerid);
}
forward KickFailedLogin(playerid);
public KickFailedLogin(playerid)
{
Kick(playerid);
}
//==============================================================================
public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
//====================================
// INCORRECT RCON
//====================================
	if(!success)
	{
		if(!dini_Exists("ladmin/config/BadRconLogins.txt"))
			dini_Create("ladmin/config/BadRconLogins.txt");

		new attempts=dini_Int("ladmin/config/BadRconLogins.txt",ip);
		attempts++;
		if(attempts>=MAX_RCON_ATTEMPS)
		{
			new cmd[32];
			format(cmd,sizeof(cmd),"banip %s",ip);
			SendRconCommand(cmd);
		}
		dini_IntSet("ladmin/config/BadRconLogins.txt",ip,attempts);
	}
//====================================
// CORRECT RCON
//====================================
	#if EnableTwoRcon == true
	else
	{
	    for(new i = 0; i < MAX_PLAYERS; i++)
		{
        new tIP[16];
	    GetPlayerIp(i, tIP, sizeof(tIP));
	    if(!strcmp(ip, tIP, true))
	    {
	         new string[128];
	         format(string,sizeof(string),"TBS uses a system of two RCON passwords. \n\nFor access the account, you must enter the second password RCON.");
	         ShowPlayerDialog(i, DIALOG_TYPE_RCON2, DIALOG_STYLE_INPUT,"TBS Admin - RCON!",string, "Enter", "Exit");
	     }
	     }
	}
	#endif
	return 1;
}


public OnPlayerPickUpPickup(playerid, pickupid)
{
	new str[150], pName2[24];
	GetPlayerName(playerid, pName2, sizeof(pName2));
	if(pickupid == hshoe[0])
	{
		if(horseshoe[playerid] != 0)
		{
			SendClientMessage(playerid, COLOR_RED, "ERROR: You already collected this horseshoe!");
			return 1;
		}
		GameTextForPlayer(playerid, "~w~Horseshoe 1 ~r~out ~w~of 30", 2500, 3);
		SendClientMessage(playerid, COLOR_GREEN, "Horseshoe collected! (1/30)");
		horseshoe[playerid] = 1;
		for(new x = 0; x < sizeof(shoecord); x++)
		{
			GivePlayerMoneyEx(playerid, shoecord[x][reward]);
		}
	}
	if(pickupid == hshoe[29])
	{
	    if(horseshoe[playerid] < 29) return SendClientMessage(playerid, COLOR_RED, "ERROR: Collect the horseshoe in order! This is 30/30 horseshoe");
		if(horseshoe[playerid] == 30)
		{
			SendClientMessage(playerid, COLOR_RED, "ERROR: You've already completed collecting all horseshoe (30/30)!");
			return 1;
		}
		GameTextForPlayer(playerid, "~w~Horseshoe 30 ~r~out ~w~of 30", 2500, 3);
		SendClientMessage(playerid, COLOR_YELLOW, "All horseshoe collected (30/30)");
		horseshoe[playerid] = 30;
		GivePlayerMoneyEx(playerid, 100000000);
		format(str, sizeof(str), "%s(ID:%d) has collected all horseshoes (30/30)", pName2, playerid);
		SendClientMessageToAll(COLOR_YELLOW, str);
		SetPlayerScore(playerid, GetPlayerScore(playerid) + 1000);
		format(str, sizeof(str), "%s received 100000000$ + 1000 score", pName2);
		SendClientMessageToAll(COLOR_GREEN, str);
	}
	for(new i = 0; i < sizeof(shoecord); i++)
	{
		if(pickupid == hshoe[shoecord[i][pickup]])
		{
		    if(horseshoe[playerid] < shoecord[i][order]-1)
		    {
			    format(str, sizeof(str), "ERROR: Collect the horseshoe in order! This is %i/30 horseshoe", shoecord[i][order]);
				SendClientMessage(playerid, COLOR_RED, str);
				return 1;
			}
			if(horseshoe[playerid] >= shoecord[i][order]) return SendClientMessage(playerid, COLOR_RED, "ERROR: You already collected this horseshoe!");
			format(str, sizeof(str), "~w~Horseshoe %i ~r~out ~w~of 30", shoecord[i][order]);
			GameTextForPlayer(playerid, str, 2500, 3);
			format(str, sizeof(str), "Horseshoe collected! (%i/30)", shoecord[i][order]);
			SendClientMessage(playerid, COLOR_GREEN, str);
			horseshoe[playerid] = shoecord[i][order];
			GivePlayerMoneyEx(playerid, shoecord[i][reward]);
		}
	}
	if(pickupid == MoneyBagPickup)
	{
		new string[180], pname[24], money = MoneyBagCash;
		GetPlayerName(playerid, pname, 24);
		format(string, sizeof(string), "** {99FFFF}%s{FFFFFF} has found the {33FF66}money bag{FFFFFF} that had {33FF00}$%d {FFFFFF}inside, located in %s", pname, money, MoneyBagLocation);
		SendClientMessageToAll(-1, string);
		SendClientMessage(playerid, -1, "You have found the {33FF66} Money Bag!");
		ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);
		GivePlayerMoneyEx(playerid, money);
		PlayerInfo[playerid][MoneyBags]++;
		MoneyBagFound = 1;
		DestroyPickup(MoneyBagPickup);
	}
    if(pickupid == CJPickup)
	{
		new string[180], pname[24];
		new CJCookies = random(20)+10;
		GetPlayerName(playerid, pname, 24);
		format(string, sizeof(string), "** {99FFFF}%s{FFFFFF} has found the {33FF66}Cookie Jar{FFFFFF} that had {33FF00}$%d {FFFFFF}inside, located in %s", pname, CJCookies, CookieJarLocation);
		CJFound = 1;
		SendClientMessageToAll(-1, string);
		DestroyPickup(CJPickup);
		SendClientMessage(playerid, -1, "You have found the {33FF66} Cookie Jar!");
		PlayerInfo[playerid][Cookies] += CJCookies;
		//GivePlayerMoney(playerid, CJCookies);
		PlayerInfo[playerid][CookieJars]++;
		ApplyAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0);
	}
	return 1;
}

/*forward Anticheat();
public Anticheat()
{
	foreach(new i : Player)
	{
		if(money_anti[i] != GetPlayerMoneyEx(i))
		{
			ResetPlayerMoneyEx(i);
			GivePlayerMoneyEx(i, money_anti[i]);
		}
	}
	return 1;
}*/

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
stock ResetPlayerMoneyEx(playerid)
{
	SetPVarInt(playerid, "AllowingCashChange", 1);//to avoid the anti cheat to detect the following stuff to be detected as "hack"
	SetPVarInt(playerid, "OldMoney",0);  //we just set it to 0
	ResetPlayerMoney(playerid);
	SetPVarInt(playerid, "AllowingCashChange", 0); //tell the server we are done, and any other changes will be noticed as hacks.
	return 1;
}
stock GetPlayerMoneyEx(playerid)
{
	return GetPVarInt(playerid, "OldMoney");
}
//There is a timer from the gamemode checking the cash every second atm, so no need to check it in the FS as well.


forward MoneyBag();
public MoneyBag()
{
    new string[175];
	if(!MoneyBagFound)
	{
	    format(string, sizeof(string), "**The {33FF66}Money bag {FFFFFF}has {FF0000}not {FFFFFF}been found, it is still hidden in {FFFF66}%s", MoneyBagLocation);
		SendClientMessageToAll(-1, string);
	}
	else if(MoneyBagFound)
	{
	    MoneyBagFound = 0;
	    new randombag = random(sizeof(MBSPAWN));
	    MoneyBagPos[0] = MBSPAWN[randombag][XPOS];
	    MoneyBagPos[1] = MBSPAWN[randombag][YPOS];
	    MoneyBagPos[2] = MBSPAWN[randombag][ZPOS];
	    format(MoneyBagLocation, sizeof(MoneyBagLocation), "%s", MBSPAWN[randombag][Position]);
		format(string, sizeof(string), "**The {33FF66}Money Bag has been {FF0000}hidden in {FFFF66}%s!", MoneyBagLocation);
        SendClientMessageToAll(-1, string);
		MoneyBagPickup = CreatePickup(1550, 2, MoneyBagPos[0], MoneyBagPos[1], MoneyBagPos[2], -1);
	}
	return 1;
}
forward CookieJar();
public CookieJar()
{
    new string[175];
	if(!CJFound)
	{
	    format(string, sizeof(string), "**The {33FF66} Cookie Jar {FFFFFF}has {FF0000} not {FFFFFF} been found, it is still hidden in {FFFF66} %s", CookieJarLocation);
		SendClientMessageToAll(-1, string);
	}
	else if(CJFound)
	{
	    CJFound = 0;
	    new randombag = random(sizeof(CJSPAWN));
	    CJPOS[0] = CJSPAWN[randombag][XPOS];
	    CJPOS[1] = CJSPAWN[randombag][YPOS];
	    CJPOS[2] = CJSPAWN[randombag][ZPOS];
	    format(CookieJarLocation, sizeof(CookieJarLocation), "%s", CJSPAWN[randombag][Position]);
		format(string, sizeof(string), "**The {33FF66}Cookie Jar has been {FF0000} hidden in {FFFF66} %s!", CookieJarLocation);
        SendClientMessageToAll(-1, string);
		CJPickup = CreatePickup(1276, 2, CJPOS[0], CJPOS[1], CJPOS[2], -1);
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
    SetPVarInt(playerid, "AdminProtect", 0);
    if(PlayerInfo[playerid][Level] >= 1)
    {
    SetPlayerColor(playerid,red);
    }
    if(PlayerInfo[playerid][pVip] >= 2)
    {
    SetPlayerColor(playerid,yellow);
    }
    if(PlayerInfo[playerid][Level] == 4)
    {
       SetPlayerColor(playerid,0xFF0000);
       SetPVarInt(playerid, "Level", 4);
	}
    if(PlayerInfo[playerid][Level] == 5)
    {
       SetPlayerColor(playerid,0x00FFFF);
       SetPVarInt(playerid, "Level", 5);
	}
    if(PlayerInfo[playerid][Level] == 6)
    {
       SetPlayerColor(playerid,blue);
       SetPVarInt(playerid, "Level", 6);
	}
	if(ServerInfo[Locked] == 1 && PlayerInfo[playerid][AllowedIn] == false)
	{
		GameTextForPlayer(playerid,"~r~Server Locked~n~You must enter password before spawning~n~/password <password>",4000,3);
		SetTimerEx("DelayKillPlayer", 2500,0,"d",playerid);
		return 1;
	}
	if(ServerInfo[MustLogin] == 1 && PlayerInfo[playerid][Registered] == 1 && PlayerInfo[playerid][LoggedIn] == 0)
	{
		GameTextForPlayer(playerid,"~r~You must login before playing!",4000,3);
		new string[128];
		format(string, sizeof(string), "{818181}ERROR:{818181}  {FF0000}You must be logged in before spawning! Use /login <password>!{FF0000}");
		SetTimerEx("DelayKillPlayer", 2500,0,"d",playerid);
		return 1;
	}
	if(ServerInfo[MustRegister] == 1 && PlayerInfo[playerid][Registered] == 0)
	{
		GameTextForPlayer(playerid,"~r~You must register before playing!",4000,3);
		new string[128];
		format(string, sizeof(string), "{818181}ERROR:{818181}  {FF0000}You must register before spawning! Use /register <password>!{FF0000}");
		SetTimerEx("DelayKillPlayer", 2500,0,"d",playerid);
		return 1;
	}

	PlayerInfo[playerid][Spawned] = 1;

	if(PlayerInfo[playerid][Frozen] == 1) {
		TogglePlayerControllable(playerid,false); return SendClientMessage(playerid,red,"You can't escape your punishment! You Are Still Frozen!!!");
	}
   	if(PlayerInfo[playerid][Muted] == 1) {
	    SetTimerEx("MutePlayer",3000,0,"d",playerid); return SendClientMessage(playerid,red,"You can't escape your punishment! You Are Still In Muted!!!");
	}

	if(PlayerInfo[playerid][Jailed] == 1) {
	    SetTimerEx("JailPlayer",3000,0,"d",playerid); return SendClientMessage(playerid,red,"You can't escape your punishment! You Are Still In Jail!!!");
	}

	if(ServerInfo[AdminOnlySkins] == 1) {
		if( (GetPlayerSkin(playerid) == ServerInfo[AdminSkin]) || (GetPlayerSkin(playerid) == ServerInfo[AdminSkin2]) ) {
			if(PlayerInfo[playerid][Level] >= 1)
				GameTextForPlayer(playerid,"~b~Welcome~n~~w~Admin",3000,1);
			else {
				GameTextForPlayer(playerid,"~r~This Skin Is For~n~Administrators~n~Only",4000,1);
				SetTimerEx("DelayKillPlayer", 2500,0,"d",playerid);
				return 1;
			}
		}
	}

	if((dUserINT(PlayerName2(playerid)).("UseSkin")) == 1)
		if((PlayerInfo[playerid][Level] >= 1) && (PlayerInfo[playerid][LoggedIn] == 1))
    		SetPlayerSkin(playerid,(dUserINT(PlayerName2(playerid)).("FavSkin")) );

	if(ServerInfo[GiveWeap] == 1) {
		if(PlayerInfo[playerid][LoggedIn] == 1) {
			PlayerInfo[playerid][TimesSpawned]++;
			if(PlayerInfo[playerid][TimesSpawned] == 1)
			{
 				GivePlayerWeapon(playerid, dUserINT(PlayerName2(playerid)).("weap1"), dUserINT(PlayerName2(playerid)).("weap1ammo")	);
				GivePlayerWeapon(playerid, dUserINT(PlayerName2(playerid)).("weap2"), dUserINT(PlayerName2(playerid)).("weap2ammo")	);
				GivePlayerWeapon(playerid, dUserINT(PlayerName2(playerid)).("weap3"), dUserINT(PlayerName2(playerid)).("weap3ammo")	);
				GivePlayerWeapon(playerid, dUserINT(PlayerName2(playerid)).("weap4"), dUserINT(PlayerName2(playerid)).("weap4ammo")	);
				GivePlayerWeapon(playerid, dUserINT(PlayerName2(playerid)).("weap5"), dUserINT(PlayerName2(playerid)).("weap5ammo")	);
				GivePlayerWeapon(playerid, dUserINT(PlayerName2(playerid)).("weap6"), dUserINT(PlayerName2(playerid)).("weap6ammo")	);
			}
		}
	}
	if(PlayerInfo[playerid][LoggedIn] == 0)
	{
	new pame[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pame,sizeof(pame));
	new string[128]; format(string, sizeof(string), "Player %s has been automatically kicked (Reason: Spawned without login!)", pame);
	SetTimerEx("KickFailedLogin", 1500,0,"d",playerid);
	return 1;
	}
	return 1;
}

//==============================================================================
public OnPlayerDeath(playerid, killerid, reason)
{
    PlayerInfo[playerid][Spawned]    = 0;
    PlayerInfo[playerid][pDeaths]++;
	if(IsPlayerConnected(killerid) && killerid != INVALID_PLAYER_ID)
	{
		PlayerInfo[killerid][Kills]++;
	}
	return 1;
}
//==============================================================================

public OnPlayerText(playerid, text[])
{
    if(stringContainsIP(text))
    {
       new strg[128];
       if(strfind(text, "52.166.106.19:7777") == -1 && strfind(text, "52.166.106.19") == -1 && strfind(text, "62.75.158.36") == -1 && strfind(text, "62.75.158.36:8000") == -1)
       {
	   format(strg, sizeof(strg), "{FF0000}[TBS] {%06x}%s(%d) {C0C0C0}has been automatically muted for advertising.", (GetPlayerColor(playerid) >>> 8), pName(playerid), playerid);
       SendClientMessageToAll(-1, strg);
       SendClientMessage(playerid, -1, "{FF0000}ERROR: {C0C0C0}Your message has been blocked because it contains an IP. You have been muted for advertising.");
       PlayerInfo[playerid][Muted] = 1;
       SetTimer("MuteTimer", 1000*60, false);
	   PlayerInfo[playerid][MuteWarnings] = 0;
       return 0;
	   }
	}
	if(Atag[playerid] == 1)
	{
	if(PlayerInfo[playerid][Level] >= 4) //If they are an admin, you can replace this with your own admin variable
    {
        new string[256], name[MAX_PLAYER_NAME];
        GetPlayerName(playerid, name, MAX_PLAYER_NAME);
        format(string,sizeof(string),"{00FF40}[Senior Admin]{00FF40} {%06x}%s(%d): {FF0000}%s", (GetPlayerColor(playerid) >>> 8), name,playerid, text); //Editing the format and adding admin tag in front of name
        SendClientMessageToAll(COLOR_WHITE, string); //Sends message to all
        return 0; //Return false for sending custom chat, so it doesn't send your message twice
   	}
	return 1;
	}
	if(COAtag[playerid] == 1)
	{
	if(PlayerInfo[playerid][Level] >= 3) //If they are an admin, you can replace this with your own admin variable
    {
        new string[256], name[MAX_PLAYER_NAME];
        GetPlayerName(playerid, name, MAX_PLAYER_NAME);
        format(string,sizeof(string),"{00FF40}[Admin]{00FF40} {%06x}%s(%d): {FF0000}%s", (GetPlayerColor(playerid) >>> 8), name,playerid, text); //Editing the format and adding admin tag in front of name
        SendClientMessageToAll(PlayerInfo[playerid][ChatColor], string); //Sends message to all
        return 0; //Return false for sending custom chat, so it doesn't send your message twice
   	}
	return 1;
	}
	if(Ltag[playerid] == 1)
	{
	if(PlayerInfo[playerid][Level] >= 5) //If they are an admin, you can replace this with your own admin variable
    {
        new string[256], name[MAX_PLAYER_NAME];
        GetPlayerName(playerid, name, MAX_PLAYER_NAME);
        format(string,sizeof(string),"{00FFFF}[Head Admin]{00FFFF} {%06x}%s(%d): {FF0000}%s", (GetPlayerColor(playerid) >>> 8), name,playerid, text); //Editing the format and adding admin tag in front of name
        SendClientMessageToAll(COLOR_WHITE, string); //Sends message to all
        return 0; //Return false for sending custom chat, so it doesn't send your message twice
   	}
	return 1;
	}
    if(CEOtag[playerid] == 1)
	{
	if(PlayerInfo[playerid][Level] >= 6) //If they are an admin, you can replace this with your own admin variable
    {
        new string[256], name[MAX_PLAYER_NAME];
        GetPlayerName(playerid, name, MAX_PLAYER_NAME);
        format(string,sizeof(string),"{0000FF}[Manager/CEO]{0000FF} {%06x}%s(%d): {FF0000}%s", (GetPlayerColor(playerid) >>> 8), name,playerid, text); //Editing the format and adding admin tag in front of name
        SendClientMessageToAll(COLOR_WHITE, string); //Sends message to all
        return 0; //Return false for sending custom chat, so it doesn't send your message twice
   	}
	return 1;
	}
    if(TBStag[playerid] == 1)
	{
	if(PlayerInfo[playerid][Level] >= 4) //If they are an admin, you can replace this with your own admin variable
    {
        new string[256], name[MAX_PLAYER_NAME];
        GetPlayerName(playerid, name, MAX_PLAYER_NAME);
        format(string,sizeof(string),"{FF0000}[TBS Staff]{FF0000} {%06x}%s(%d): {FF0000}%s", (GetPlayerColor(playerid) >>> 8), name,playerid, text); //Editing the format and adding admin tag in front of name
        SendClientMessageToAll(COLOR_WHITE, string); //Sends message to all
        return 0; //Return false for sending custom chat, so it doesn't send your message twice
   	}
	return 1;
	}
    if(ttag[playerid] == 1)
	{
	if(PlayerInfo[playerid][Level] >= 1)
    {
        new string[256], name[MAX_PLAYER_NAME];
        GetPlayerName(playerid, name, MAX_PLAYER_NAME);
        format(string,sizeof(string),"{FF8000}[Trial Mod]{FF8000} {%06x}%s(%d): {FF0000}%s", (GetPlayerColor(playerid) >>> 8), name,playerid, text);
        SendClientMessageToAll(COLOR_WHITE, string);
        return 0;
   	}
	return 1;
	}
    if(mtag[playerid] == 1)
	{
	if(PlayerInfo[playerid][Level] >= 2)
    {
        new string[256], name[MAX_PLAYER_NAME];
        GetPlayerName(playerid, name, MAX_PLAYER_NAME);
        format(string,sizeof(string),"{FF8000}[Moderator]{FF8000} {%06x}%s(%d): {FF0000}%s", (GetPlayerColor(playerid) >>> 8), name,playerid, text);
        SendClientMessageToAll(COLOR_WHITE, string);
        return 0;
   	}
	return 1;
	}

	if(text[0] == '#' && PlayerInfo[playerid][Level] >= 1) {
	    new string[128]; GetPlayerName(playerid,string,sizeof(string));
		format(string,sizeof(string),"Admin Chat: %s(%d): %s",string,playerid,text[1]); MessageToAdmins(0x99FF9900,string);
	    return 0;
	}
	if(text[0] == '&' && PlayerInfo[playerid][Level] >= 5) {
	    new string[128]; GetPlayerName(playerid,string,sizeof(string));
		format(string,sizeof(string),"[Leader Chat]: %s(%d): %s",string,playerid,text[1]); MessageToLeaders(blue,string);
	    return 0;
	}
	if(text[0] == '@' && PlayerInfo[playerid][Level] == 6) {
	    new string[128]; GetPlayerName(playerid,string,sizeof(string));
		format(string,sizeof(string),"{B9D3EE}[Manager Chat]: %s(%d): %s",string,playerid,text[1]); MessageToManagers(blue,string);
	    return 0;
	}

 	if(PlayerInfo[playerid][Muted] == 1)
	{
 		PlayerInfo[playerid][MuteWarnings]++;
 		new string[128];
		if(PlayerInfo[playerid][MuteWarnings] < ServerInfo[MaxMuteWarnings]) {
			format(string, sizeof(string),"WARNING: You are muted, if you continue to speak you will be kicked. (%d / %d)", PlayerInfo[playerid][MuteWarnings], ServerInfo[MaxMuteWarnings] );
			SendClientMessage(playerid,red,string);
		} else {
			SendClientMessage(playerid,red,"You have been warned! Now you have been kicked!");
			format(string, sizeof(string),"***%s (ID %d) was kicked for exceeding mute warnings", PlayerName2(playerid), playerid);
			SendClientMessageToAll(grey,string);
			SaveToFile("KickLog",string); Kick(playerid);
		} return 0;
	}

	if(ServerInfo[DisableChat] == 1) {
		SendClientMessage(playerid,red,"Chat has been disabled");
	 	return 0;
	}

	if(ServerInfo[AntiSpam] == 1 && (PlayerInfo[playerid][Level] == 0 && !IsPlayerAdmin(playerid)) )
	{
		if(PlayerInfo[playerid][SpamCount] == 0) PlayerInfo[playerid][SpamTime] = TimeStamp();

	    PlayerInfo[playerid][SpamCount]++;
		if(TimeStamp() - PlayerInfo[playerid][SpamTime] > SPAM_TIMELIMIT) { // Its OK your messages were far enough apart
			PlayerInfo[playerid][SpamCount] = 0;
			PlayerInfo[playerid][SpamTime] = TimeStamp();
		}
		else if(PlayerInfo[playerid][SpamCount] == SPAM_MAX_MSGS) {
			new string[64]; format(string,sizeof(string),"%s has been muted (Flood/Spam Protection)", PlayerName2(playerid));
			SendClientMessageToAll(grey,string); print(string);
            new tmp2[256], mtime = strval(tmp2);
			PlayerInfo[playerid][MuteTime] = mtime*1000*60;
		   	PlayerInfo[playerid][Muted] = 1;
            PlayerInfo[playerid][MuteWarnings] = 0;
		}
		else if(PlayerInfo[playerid][SpamCount] == SPAM_MAX_MSGS-1) {
			SendClientMessage(playerid,red,"Anti Spam Warning! Next is a Mute!!!");
			return 0;
		}
	}

	if(ServerInfo[AntiSwear] == 1 && PlayerInfo[playerid][Level] < ServerInfo[MaxAdminLevel])
	for(new s = 0; s < ForbiddenWordCount; s++)
    {
		new pos;
		while((pos = strfind(text,ForbiddenWords[s],true)) != -1) for(new i = pos, j = pos + strlen(ForbiddenWords[s]); i < j; i++) text[i] = '*';
	}
	if(PlayerInfo[playerid][Caps] == 1) UpperToLower(text);
	if(ServerInfo[NoCaps] == 1) UpperToLower(text);
	for(new i = 1; i < MAX_CHAT_LINES-1; i++) Chat[i] = Chat[i+1];
 	new ChatSTR[128]; GetPlayerName(playerid,ChatSTR,sizeof(ChatSTR)); format(ChatSTR,128,"[lchat]%s: %s",ChatSTR, text[0] );
	Chat[MAX_CHAT_LINES-1] = ChatSTR;

	if(vtag[playerid] == 1)
	{
	new name[MAX_PLAYER_NAME],string[128];
	GetPlayerName(playerid,name,sizeof(name));
	format(string,sizeof(string),"{FFFF00}[VIP] {%06x}%s(%d): %s",(GetPlayerColor(playerid) >>> 8), name,playerid,text);
	SendClientMessageToAll(yellow,string);
	SetPlayerChatBubble(playerid, text, GetPlayerColor(playerid), 100.0, 10000);
	return 0;
	}
    if(djtag[playerid] == 1)
    {
		 new string[150], name[MAX_PLAYER_NAME];
         GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		 format(string,sizeof(string),"{FF80FF}[DJ] {%06x}%s(%d): %s",(GetPlayerColor(playerid) >>> 8),name,playerid,text);
	     SendClientMessageToAll(0xFF80FFFF,string);
         SetPlayerChatBubble(playerid, text, GetPlayerColor(playerid), 100.0, 10000);
		 return 0;
	}
	if(text[0] == '^')
	{
	    if(PlayerInfo[playerid][isDJ] == 1 || PlayerInfo[playerid][Level] >= 2)
		{
		    new string[150], name[MAX_PLAYER_NAME];
            GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		    format(string,sizeof(string),"DJ Chat: %s(%d): %s",name,playerid,text[1]);
	        MessageToDJs(0xFF80FFFF,string);
		}
		return 0;
	}
	if(text[0] == '`')
    {
		if(PlayerInfo[playerid][pVip] >= 1 || PlayerInfo[playerid][Level] >= 1)
		{
			new string[128];
			GetPlayerName(playerid,string,sizeof(string));
			format(string,sizeof(string),"VIP Chat %s(%d): %s",string,playerid,text[1]);
			MessageToPlayerVIP(0xFFFF00FF,string);
			SaveToFile("ChatVipLog",string);
		}
      	return 0;
    }
	/*if(text[0] == '?' && PlayerInfo[playerid][Level] >= 0) {
		new string[128];
		if(PlayerInfo[playerid][Muted] == 1) {
		GetPlayerName(playerid,string,sizeof(string));
		format(string,sizeof(string),"[?Help]%s(%d): %s",string,playerid,text[1]);
		SendClientMessageToAll(yellow,string);
        }
        else return SendClientMessage(playerid, COLOR_RED, "You cannot use the help chat, becouse you are muted!");
		return 0;
    }*/

	new mathstr[128];
	if(strval(text) == answer && endm == 1)
	{
	    format(mathstr, sizeof(mathstr), "MATH: %s(%d) has won, He/She takes $%d + %i score + %i Cookies.[ Answer: %d ]", pName(playerid), playerid, PRIZE, PRIZESCORE, CookiePrize, answer);
	    SendClientMessageToAll(COLOR_YELLOW, mathstr);
	    GivePlayerMoneyEx(playerid, PRIZE);
	    SetPlayerScore(playerid, GetPlayerScore(playerid) + PRIZESCORE);
	    PlayerInfo[playerid][Cookies] += CookiePrize;
		PlayerInfo[playerid][Mathematics]++;
		KillTimer(timermath2);
	    endm = 0;
	    return 0;
	}
	switch(xTestBusy)
	{
    case true:
    {
	if(!strcmp(xChars, text, false))
	{
        new string[128], pName9[MAX_PLAYER_NAME];
	    GetPlayerName(playerid, pName9, sizeof(pName9));
	    format(string, sizeof(string), "« \%s\" has won the reaction test. »", pName9);
        SendClientMessageToAll(COLOR_GREEN, string);
	    format(string, sizeof(string), "« You have earned $%d + %d score + %d Cookies. »", xCash, xScore, xCookies);
	    SendClientMessage(playerid, COLOR_GREEN, string);
	    GivePlayerMoneyEx(playerid, xCash);
	    PlayerInfo[playerid][Cookies] += xCookies;
	    SetPlayerScore(playerid, GetPlayerScore(playerid) + xScore);
		PlayerInfo[playerid][Reactions]++;
        reactionWinnerID = playerid;
		KillTimer(xReactionTimer);
        xTestBusy = false;
		xReactionTimer = SetTimer("xReactionTest", 1000*120*TIME, true);
		return 0;
	}
	switch(xTestBusy)
	{
	case false:
	{
	if(!strcmp(xChars, text, false))
	{
        new string[128], pName9[MAX_PLAYER_NAME];
	    GetPlayerName(playerid, pName9, sizeof(pName9));
		format(string, sizeof(string), "{7100E1}[REACT]« The reaction test is already over! %s(%d) already won!", pName9[reactionWinnerID], reactionWinnerID);
		SendClientMessage(playerid, 0xA953FFFF, string);
		return 0;
	}
	}
	}
	}
	}

	new tstring[256], playername[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playername, sizeof(playername));
	format(tstring, sizeof(tstring), "%s{FF0000}({C0C0C0}%d{FF0000}){C0C0C0}: {%06x}%s", playername, playerid, (PlayerInfo[playerid][ChatColor] >>> 8), text);
	SendClientMessageToAll(GetPlayerColor(playerid),tstring);

	new text2[128];
	format(text2, sizeof(text2), "{00FFFF}Says:{FFFFFF} %s",text);
	SetPlayerChatBubble(playerid, text2, 0xFFFFFFFF, 35.0,7000);

    if(!strcmp(text, "Jennifer", true) || !strcmp(text, "How are you?", true) || !strcmp(text, "Sup", true))
	{
        SendBotMessage("Hey wazap? I am Jenni, I'm good. You?");
		return 0;
	}
	if(!strcmp(text, "Who are you?", true) || !strcmp(text, "I love you", true) || !strcmp(text, "Nice to meet you", true) || !strcmp(text, "Jenni", true))
	{
		Random(playerid);
		return 0;
	}
    if(!strcmp(text, "What music do you listen?", true))
	{
        SendBotMessage("The same music as Filipbg :)");
		return 0;
	}
    if(!strcmp(text, "What music do you listen to?", true))
	{
        SendBotMessage("The same music as Filipbg's :)");
		return 0;
	}
    if(!strcmp(text, "What type music do you listen to?", true))
	{
        SendBotMessage("The same music as Filipbg's :)");
		return 0;
	}
    if(!strcmp(text, "What type music do you listen?", true))
	{
        SendBotMessage("The same music as Filipbg's :)");
		return 0;
	}
    if(!strcmp(text, "Do you have a boyfriend?", true))
	{
        SendBotMessage("No, but I have a dildo. :P");
		return 0;
	}
    if(!strcmp(text, "What languages you speak?", true))
	{
        SendBotMessage("I speak English.");
		return 0;
	}
    if(!strcmp(text, "Where are you from?", true))
	{
        SendBotMessage("From my mother's womb! O.o + >:F");
		return 0;
	}
	if(!strcmp(text, "Are you a girl?", true))
	{
        SendBotMessage("Yeah, I am. :P");
		return 0;
	}
    if(!strcmp(text, "I like you", true))
	{
        SendBotMessage("Oh thanks. I like you too! ;)");
		return 0;
	}
    if(!strcmp(text, "I like you.", true))
	{
        SendBotMessage("Oh thanks. I like you too! ;)");
		return 0;
	}
    if(!strcmp(text, "Im bored", true))
	{
        SendBotMessage("Talk with me ;)");
		return 0;
	}
    if(!strcmp(text, "Who made you?", true))
	{
        SendBotMessage("Filipbg made me. :)");
		return 0;
	}
	if(!strcmp(text, "Are you a virgin?", true))
	{
        SendBotMessage("No, why?");
		return 0;
	}
	if(!strcmp(text, "Are you real?", true))
	{
        SendBotMessage("No, I am a bot.");
		return 0;
	}
    if(!strcmp(text, "Will you date me?", true))
	{
        SendBotMessage("Maybe, I will see. ;*");
		return 0;
	}
    if(!strcmp(text, "Do you masturbate?", true))
	{
        SendBotMessage("Hell yeah! ^.^");
		return 0;
	}
    if(!strcmp(text, "How you masturbate?", true))
	{
        SendBotMessage("I like to use my fingers to finger my self. Dildos too! *horny*");
		return 0;
	}
    if(!strcmp(text, "What size of dick you like?", true))
	{
        SendBotMessage("I want it deep incide me. I like it big ;x");
		return 0;
	}
    if(!strcmp(text, "Are you bad girl?", true))
	{
        SendBotMessage("I'm verry, verry naughty girl <3");
		return 0;
	}
    if(!strcmp(text, "Are you horny?", true))
	{
        SendBotMessage("I'm wet as hell ;*");
		return 0;
	}
    if(!strcmp(text, "Shut up!", true))
	{
        SendBotMessage("Oh FUCK YOU! >:(");
		return 0;
	}
    if(!strcmp(text, "Shut up", true))
	{
        SendBotMessage("No, you shut up! >:(");
		return 0;
	}
    if(!strcmp(text, "Shut the fuck up", true))
	{
        SendBotMessage("Go to hell! >:(");
		return 0;
	}
    if(!strcmp(text, "Shut the fuck up!", true))
	{
        SendBotMessage("Go to hell! >:(");
		return 0;
	}
    if(!strcmp(text, "WTF", true))
	{
        SendBotMessage("Wut? Whats wrong? ;/");
		return 0;
	}
    if(!strcmp(text, "TBS sucks", true))
	{
        SendBotMessage("Wanna ban you little faggot?!");
		return 0;
	}
    if(!strcmp(text, "I hope TBS die", true))
	{
        SendBotMessage("I hope you die bitch!");
		return 0;
	}
    if(!strcmp(text, "Fuck this server", true))
	{
        SendBotMessage("No, fuck you!");
		return 0;
	}
    if(!strcmp(text, "I hope TBS die!", true))
	{
        SendBotMessage("I hope you die bitch!");
		return 0;
	}
    if(!strcmp(text, "Fuck you bitch!", true))
	{
        SendBotMessage("DIE MADAFAKA! >:C");
		SetPlayerHealth(playerid, 0);
		return 0;
	}
    if(!strcmp(text, "Fuck you bitch", true))
	{
        SendBotMessage("DIE MADAFAKA! >:C");
		SetPlayerHealth(playerid, 0);
		return 0;
	}
    if(!strcmp(text, "fak u", true))
	{
        SendBotMessage("Ow rly? Well fak you too! >.>");
		return 0;
	}
    if(!strcmp(text, "fak u!", true))
	{
        SendBotMessage("With what are you gonna do that? You don't have a penis! ;P");
		return 0;
	}
    if(!strcmp(text, "TBS sucks", true))
	{
        SendBotMessage("You suck! >:C");
		return 0;
	}
    if(!strcmp(text, "TBS sucks!", true))
	{
        SendBotMessage("Go suck your father's 3 centimeter penis! :O");
		return 0;
	}
    if(!strcmp(text, "fak u jenni", true))
	{
		SendBotMessage("No! FAK U!...bitch >.>");
		return 0;
	}
    if(!strcmp(text, "fak u jenni!", true))
	{
        SendBotMessage("You wanna fak me? DIE BITCH! >:C");
		SetPlayerHealth(playerid, 0);
		return 0;
	}
    if(!strcmp(text, "fuck you jenni!", true))
	{
        SendBotMessage("Owww....you wanna die so bad! DIE SUCKER >:C");
		SetPlayerHealth(playerid, 0);
		return 0;
	}
    if(!strcmp(text, "fuck you jeni!", true))
	{
        SendBotMessage("Owww....you wanna die so bad! DIE SUCKER >:C");
		SetPlayerHealth(playerid, 0);
		return 0;
	}
    if(!strcmp(text, "fuck you jenny!", true))
	{
        SendBotMessage("Owww....you wanna die so bad! DIE SUCKER >:C");
		SetPlayerHealth(playerid, 0);
		return 0;
	}
    if(!strcmp(text, "fuck you jenni!", true))
	{
        SendBotMessage("Owww....you wanna die so bad! DIE SUCKER >:C");
		SetPlayerHealth(playerid, 0);
		return 0;
	}
    if(!strcmp(text, "fuck you jenni", true))
	{
        SendBotMessage("Owww....you wanna die so bad! DIE MADAFAKA! >:C");
		SetPlayerHealth(playerid, 0);
		return 0;
	}
	return 1;
}
//==============================================================================
forward OnPlayerPrivmsg(playerid, recieverid, text[]);
public OnPlayerPrivmsg(playerid, recieverid, text[])
{
    if(stringContainsIP(text))
    {
       new strg[128];
	   if(PlayerInfo[playerid][Level] >= 5) return 1;
	   format(strg, sizeof(strg), "{FF0000}[TBS] {%06x}%s(%d) {C0C0C0}has been automatically muted for advertising.", (GetPlayerColor(playerid) >>> 8), pName(playerid), playerid);
       SendClientMessageToAll(-1, strg);
       SendClientMessage(playerid, -1, "{FF0000}ERROR: {C0C0C0}Your message has been blocked because it contains an IP. You have been muted for advertising.");
       PlayerInfo[playerid][Muted] = 1;
       SetTimer("MuteTimer", 1000*60, false);
	   PlayerInfo[playerid][MuteWarnings] = 0;
       return 0;
	}
 	if(PlayerInfo[playerid][Muted] == 1)//select go cmd and copy please ok
	{
		new string[128];
 		PlayerInfo[playerid][MuteWarnings]++;
		if(PlayerInfo[playerid][MuteWarnings] < ServerInfo[MaxMuteWarnings]) {
			format(string, sizeof(string),"WARNING: You are muted, if you continue to speak you will be kicked (Warning: %d/%d)", PlayerInfo[playerid][MuteWarnings], ServerInfo[MaxMuteWarnings] );
			SendClientMessage(playerid,red,string);
		} else {
			SendClientMessage(playerid,red,"You have been warned! Now you have been kicked");
			GetPlayerName(playerid, string, sizeof(string));
			format(string, sizeof(string),"%s [ID %d] Kicked for exceeding mute warnings", string, playerid);
			SendClientMessageToAll(grey,string);
			SaveToFile("KickLog",string); Kick(playerid);
		} return 0;
	}
	if(ServerInfo[ReadPMs] == 1 && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel])
	{
    	new string[256],recievername[MAX_PLAYER_NAME];
		GetPlayerName(playerid, string, sizeof(string)); GetPlayerName(recieverid, recievername, sizeof(recievername));
		format(string, sizeof(string), "***PM: %s To %s: %s", pName(playerid), recievername, text);
		for (new a = 0; a < MAX_PLAYERS; a++) if (IsPlayerConnected(a) && (PlayerInfo[a][Level] >= ServerInfo[MaxAdminLevel]) && a != playerid)
		SendClientMessage(a, grey, string);
	}
	return 1;
}

forward HighLight(playerid);
public HighLight(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(PlayerInfo[playerid][blipS] == 0) { SetPlayerColor(playerid, 0xFF0000AA); PlayerInfo[playerid][blipS] = 1; }
	else { SetPlayerColor(playerid, 0x33FF33AA); PlayerInfo[playerid][blipS] = 0; }
	return 0;
}

public Random(playerid)
{
		new str[128];
		new randMSG = random(sizeof(RandomMsg));
		format(str, sizeof(str), "%s", RandomMsg[randMSG]);
    	SendBotMessage(str);
        return 1;
}
//===================== [ DCMD Commands ]=======================================
dcmd_botsay(playerid, params[])
{
  #pragma unused params
  if(PlayerInfo[playerid][Level] >= 4)
  {
	new BOTMSG[128];
    if (sscanf(params, "s[128]", BOTMSG )) return SendClientMessage(playerid, COLOR_BOT, "USAGE: {33CCFF}/botsay [Text]" );
	return SendBotMessage(BOTMSG);
  }
  else return SendClientMessage(playerid, -1, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_ranks(playerid, params[])
{
            #pragma unused params
			new dialog[2666];
 			strcat(dialog,"{ffffff}Noobie: {FF6600}0 Score\n");
			strcat(dialog,"{ffffff}Hobo: {FF6600}100 Score\n");
   			strcat(dialog,"{ffffff}Madman: {FF6600}250 Score\n");
   			strcat(dialog,"{ffffff}Thug: {FF6600}500 Score\n");
			strcat(dialog,"{ffffff}Thief: {FF6600}1000 Score\n");
   			strcat(dialog,"{ffffff}Killer: {FF6600}2500 Score\n");
   			strcat(dialog,"{ffffff}Psycho: {FF6600}5000 Score\n");
   			strcat(dialog,"{ffffff}Hitman: {FF6600}10000 Score\n");
			strcat(dialog,"{ffffff}Shooter: {FF6600}25000 Score\n");
			strcat(dialog,"{ffffff}The Terror Maker: {FF6600}50000 Score\n");
   			strcat(dialog,"{ffffff}King: {FF6600}100000 Score\n");
   			ShowPlayerDialog(playerid, 5022, DIALOG_STYLE_MSGBOX, "Player ranks",dialog, "Close", "");
   			return 1;
}

dcmd_myrank(playerid, params[])
{
    #pragma unused params
  	if(GetPlayerScore(playerid) >= 0 && GetPlayerScore(playerid) < 100)
    {
 	SendClientMessage(playerid, COLOR_BLUE, "Your current player rank is: Noobie.");
	}
 	else if(GetPlayerScore(playerid) >= 100 && GetPlayerScore(playerid) < 250)
    {
 	SendClientMessage(playerid, COLOR_BLUE, "Your current player rank is: Hobo.");
  	}
    else if(GetPlayerScore(playerid) >= 250 && GetPlayerScore(playerid) < 500)
    {
 	SendClientMessage(playerid, COLOR_BLUE, "Your current player rank is: Madman.");
	}
 	else if(GetPlayerScore(playerid) >= 500 && GetPlayerScore(playerid) < 1000)
    {
 	SendClientMessage(playerid, COLOR_BLUE, "Your current player rank is: Thug.");
  	}
   	else if(GetPlayerScore(playerid) >= 1000 && GetPlayerScore(playerid) < 2500)
    {
 	SendClientMessage(playerid, COLOR_BLUE, "Your current player rank is: Thief.");
	}
 	else if(GetPlayerScore(playerid) >= 2500 && GetPlayerScore(playerid) < 5000)
    {
 	SendClientMessage(playerid, COLOR_BLUE, "Your current player rank is: Killer.");
  	}
   	else if(GetPlayerScore(playerid) >= 5000 && GetPlayerScore(playerid) < 10000)
    {
 	SendClientMessage(playerid, COLOR_BLUE, "Your current player rank is: Psycho.");
	}
 	else if(GetPlayerScore(playerid) >= 10000 && GetPlayerScore(playerid) < 25000)
    {
 	SendClientMessage(playerid, COLOR_BLUE, "Your current player rank is: Hitman.");
  	}
	else if(GetPlayerScore(playerid) >= 25000 && GetPlayerScore(playerid) < 50000)
    {
 	SendClientMessage(playerid, COLOR_BLUE, "Your current player rank is: Shooter.");
	}
 	else if(GetPlayerScore(playerid) >= 50000 && GetPlayerScore(playerid) < 100000)
    {
 	SendClientMessage(playerid, COLOR_BLUE, "Your current player rank is: The Terror Maker.");
  	}
	else if(GetPlayerScore(playerid) >= 100000 && GetPlayerScore(playerid) < 9999999)
    {
 	SendClientMessage(playerid, COLOR_BLUE, "Your current player rank is: King.");
   	}
	return 1;
}

dcmd_cshop(playerid, params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][LoggedIn])
	{
		new string[256];
		format(string, sizeof(string), "{0049FF}You have {C9FFAB}(( %d )) Cookies.", PlayerInfo[playerid][Cookies]);
		SendClientMessage(playerid, COLOR_WHITE, string);
	    ShowPlayerDialog(playerid, DIALOG_COOKIESHOP, DIALOG_STYLE_LIST, "Item 	  	  	  	  	   	  	  	  	   	  	 Price:",
	    "{84538A}50 Score	 {FFFFFF}5 Cookies\n{84538A}250 Score	 {FFFFFF}20 Cookies\n{84538A}2000 Score	 {FFFFFF}250 Cookies{00FF00}(Most Used)\n{84538A}7000 Score	 {FFFFFF}1000 Cookies{FF0000}(New Offer)\n{84538A}$1,000,000	 {FFFFFF}100 Cookies\n{84538A}$2,500,000	 {FFFFFF}250 Cookies\n{84538A}$5,000,000	 {FFFFFF}500 Cookies\n{84538A}$10,000,000	 {FFFFFF}1000 Cookies",
        "Select", "Cancel");
	}
	return 1;
}

dcmd_bshop(playerid, params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][LoggedIn])
	{
		new string[256];
		format(string, sizeof(string), "{0049FF}You have {C9FFAB}%d {0049FF}Brownies!", PlayerInfo[playerid][pBrownies]);
		SendClientMessage(playerid, COLOR_WHITE, string);
	    ShowPlayerDialog(playerid, DIALOG_BROWNIESHOP, DIALOG_STYLE_LIST, "Item 	  	  	  	  	   	  	  	  	   	  	 Price:",
	    "{84538A}Weapon Pack 1	 {FFFFFF}1 Brownie\n{84538A}Weapon Pack 2	 {FFFFFF}2 Brownies\n{84538A}Weapon Pack 3	 {FFFFFF}3 Brownies{00FF00}(Most Used)\n{84538A}50% Armour for DM	 {FFFFFF}5 Brownies{FF0000}(New Offer)\n{84538A}100% Armour for DM	 {FFFFFF}10 Brownies\n{84538A}100 Cookies	 {FFFFFF}25 Brownies\n{84538A}200 Cookies	 {FFFFFF}50 Brownies\n{84538A}500 Brownies	 {FFFFFF}100 Cookies{00FF00}(Promo)\n{84538A}1000 Cookies	 {FFFFFF}200 Brownies{00FF00}(Promo)\n{C0C0C0}Silver VIP{00FF00}(Permanent) 	 {84538A}999 Brownies",
        "Choose", "Close");
	}
	return 1;
}

dcmd_givecookies(playerid, params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][LoggedIn])
	{
		if(PlayerInfo[playerid][Level] >= 3)
		{
			new player1,givecookie,string[256], cname[MAX_PLAYER_NAME];
		    GetPlayerName(player1, cname, sizeof(cname));
			if(sscanf(params, "ui", player1, givecookie)) return SendClientMessage(playerid,-1,"{C0C0C0}USAGE: /givecookies [playerid] [amount]");
		    if(!IsPlayerConnected(player1)) return SendClientMessage(playerid,COLOR_RED,"{FF0000}ERROR: {C0C0C0}That player isn't online!");
            if(givecookie < 1 || givecookie > 1000) return SendClientMessage(playerid,COLOR_RED,"{FF0000}ERROR: {C0C0C0}You can only give cookies between 1 and 1000!");
		    CMDMessageToAdmins(playerid,"GiveCookies");
			format(string, sizeof(string), "{DC143C}Admin %s has given you %d Cookies.",pName(playerid),givecookie);
			SendClientMessage(player1,-1,string);
			format(string, sizeof(string), "{DC143C}You have given %d Cookies to %s.",givecookie,cname);
			SendClientMessage(playerid,-1,string);
			PlayerInfo[player1][Cookies] += givecookie;
		}
		else
		{
			SendClientMessage(playerid,COLOR_RED,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
		}
	}
	return 1;
}

dcmd_brownies(playerid, params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][LoggedIn])
	{
		new string[256];
		format(string, sizeof(string), "{0049FF}You have {DC143C}%d {0049FF}Brownies!", PlayerInfo[playerid][pBrownies]);
		SendClientMessage(playerid, COLOR_WHITE, string);
		SendClientMessage(playerid,-1,"{C0C0C0}/bshop, /fightstyle");
	}
	return 1;
}

dcmd_fightstyles(playerid, params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][LoggedIn])
	{
		ShowPlayerDialog(playerid, DIALOG_FIGHTINGSTYLE, DIALOG_STYLE_LIST, "Fighting Styles:", "Normal\nBoxing\nKung Fu\nKneehead\nGrabKick\nElbow", "Select", "Cancel");
	}
	return 1;
}

dcmd_fs(playerid, params[])
{
	#pragma unused params
	dcmd_fightstyles(playerid, params);
	return 1;
}

dcmd_brownieshop(playerid, params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][LoggedIn])
	{
		SendClientMessage(playerid,-1,"{C0C0C0}Brownies Shop is Under Construction.");
	}
	return 1;
}
dcmd_givebrownies(playerid, params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][LoggedIn])
	{
		if(PlayerInfo[playerid][Level] >= 3)
		{
			new player1,givebrownie,string[256], bname[MAX_PLAYER_NAME];
		    GetPlayerName(player1, bname, sizeof(bname));
			if(sscanf(params, "ui", player1, givebrownie)) return SendClientMessage(playerid,-1,"{C0C0C0}USAGE: /givebrownies [playerid] [amount]");
		    if(!IsPlayerConnected(player1)) return SendClientMessage(playerid,-1,"{FF0000} Player is not online.");
            if(givebrownie < 1 || givebrownie > 100) return SendClientMessage(playerid,-1,"{FF0000} You can only give brownies between 1 and 100!");
		    CMDMessageToAdmins(playerid,"GiveBrownies");
			format(string, sizeof(string), "{DC143C}Admin %s has given you %d Cookies.",pName(playerid),givebrownie);
			SendClientMessage(player1,-1,string);
			format(string, sizeof(string), "{DC143C}You have given %d Brownies to %s.",givebrownie,bname);
			SendClientMessage(playerid,-1,string);
			PlayerInfo[player1][pBrownies] += givebrownie;
		}
		else
		{
			SendClientMessage(playerid,COLOR_RED,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
		}
	}
	return 1;
}

dcmd_me(playerid, params[])
{
	if(PlayerInfo[playerid][Muted] == 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: You're muted, you cannot use /me!");
	if(PlayerInfo[playerid][Jailed] == 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: You're in jail, you cannot use /me!");
	if(PlayerInfo[playerid][Frozen] == 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: You're frozen, you cannot use /me!");
    if(stringContainsIP(params))
    {
       new strg[128];
	   if(PlayerInfo[playerid][Level] >= 5) return 1;
	   format(strg, sizeof(strg), "{FF0000}[TBS] {%06x}%s(%d) {C0C0C0}has been automatically muted for advertising.", (GetPlayerColor(playerid) >>> 8), pName(playerid), playerid);
       SendClientMessageToAll(-1, strg);
       SendClientMessage(playerid, -1, "{FF0000}ERROR: {C0C0C0}Your message has been blocked because it contains an IP. You have been muted for advertising.");
       PlayerInfo[playerid][Muted] = 1;
       SetTimer("MuteTimer", 1000*60, false);
	   PlayerInfo[playerid][MuteWarnings] = 0;
       return 0;
	}
	if(GetPlayerScore(playerid) >= 1000)
	{
       new msg[128], string[128];
       new name[MAX_PLAYER_NAME];
	   GetPlayerName(playerid, name, sizeof(name));
	   if(sscanf(params,"s[128]",msg)) return SendClientMessage(playerid, 0x6FFF00FF, "{F07F1D}USAGE: {BBFF00}/me <Text>");
	   format(string, sizeof(string), "{DFFF12}** {%06x}%s(%d): %s", (GetPlayerColor(playerid) >>> 8), name, playerid, msg);
	   SendClientMessageToAll(-1, string);
	}
	else return SendClientMessage(playerid, COLOR_RED, "ERROR: You need to have 1k score to use /me!");
	return 1;
}

dcmd_gotomb(playerid, params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 3)
    {
    new vehicleid = GetPlayerVehicleID(playerid);
	SetPlayerPos(playerid, MoneyBagPos[0], MoneyBagPos[1] +3, MoneyBagPos[2]);
    SetVehiclePos(vehicleid, MoneyBagPos[0], MoneyBagPos[1] +3, MoneyBagPos[2]);
    return SendClientMessage(playerid, -1, "You have been {FF0000}teleported {FFFFFF}to the {33FF66}money bag");
	}
	else return SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_gotocj(playerid, params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 3)
    {
    new vehicleid = GetPlayerVehicleID(playerid);
	SetPlayerPos(playerid, CJPOS[0], CJPOS[1] +3, CJPOS[2]);
    SetVehiclePos(vehicleid, CJPOS[0], CJPOS[1] +3, CJPOS[2]);
    return SendClientMessage(playerid, -1, "You have been {FF0000}teleported {FFFFFF}to the {33FF66}Cookie Jar.");
	}
	else return SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_startmb(playerid, params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 3)
    {
	   return MoneyBag();
   	}
	else return SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_startcj(playerid, params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 3)
    {
	   return CookieJar();
   	}
	else return SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_togglemb(playerid, params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 3)
    {
	    if(Timer[0] == 0)
	    {
	        KillTimer(Timer[1]);
	        Timer[0] = 1;
	        SendClientMessage(playerid, -1, "Money bag turned {FF0000} off!");
            return 1;
	    }
	    if(Timer[0] == 1)
	    {
	        Timer[1] = SetTimer("MoneyBag", MB_DELAY, true);
	        Timer[0] = 0;
	        SendClientMessage(playerid, -1, "Money bag turned {33FF66} on!");
		    return 1;
	    }
	}
	else return SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}
dcmd_togglecj(playerid, params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 3)
    {
	    if(Timer2[0] == 0)
	    {
	        KillTimer(Timer[1]);
	        Timer[0] = 1;
	        SendClientMessage(playerid, -1, "Cookie Jar turned {FF0000} off!");
            return 1;
	    }
	    if(Timer2[0] == 1)
	    {
	        Timer[1] = SetTimer("CookieJar", MB_DELAY, true);
	        Timer[0] = 0;
	        SendClientMessage(playerid, -1, "Cookie Jar turned {33FF66} on!");
		    return 1;
	    }
	}
	else return SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}

dcmd_moneybag(playerid, params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 3)
    {
	    new string[150];
		if(!MoneyBagFound) format(string, sizeof(string), "**The {33FF66}Money Bag has been {FF0000}hidden in {FFFF66}%s!", MoneyBagLocation);
		if(MoneyBagFound) format(string, sizeof(string), "**The {33FF66}Money Bag is {FF0000} not running!");
		return SendClientMessage(playerid, -1, string);
	}
	else return SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_cookiejar(playerid, params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 3)
    {
	    new string[150];
		if(!CJFound) format(string, sizeof(string), "**The {33FF66}Cookie Jar has been {FF0000}hidden in {FFFF66}%s!", CookieJarLocation);
		if(CJFound) format(string, sizeof(string), "**The {33FF66}Cookie Jar is {FF0000} not running!");
		return SendClientMessage(playerid, -1, string);
	}
	else return SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_vipmenu(playerid, params[])
{
        #pragma unused params
     	if(PlayerInfo[playerid][pVip] == 1 || (PlayerInfo[playerid][Level] == 1 || (PlayerInfo[playerid][Level] == 2)))
	    {
	        ShowVIPMenu(playerid);
	    }
	    else if(PlayerInfo[playerid][pVip] == 2 || (PlayerInfo[playerid][Level] == 3 || (PlayerInfo[playerid][Level] ==4)))
	    {
	        ShowVIPMenu1(playerid);
	    }
	    else if(PlayerInfo[playerid][pVip] == 3 || (PlayerInfo[playerid][Level] == 5 || (PlayerInfo[playerid][Level] == 6)))
	    {
	        ShowVIPMenu2(playerid);
	    }
     	return 1;
}
dcmd_gclose(playerid, params[])
{
    #pragma unused params
	if ( IsPlayerConnected( playerid ) )
	{
		new
			password[128],
			count = 0
		;

		if(sscanf(params, "s[128]", password))
		{
			SendClientMessage(playerid, COLOR_WHITE, "{B7B7B7}[SERVER] {FFFFFF}Usage: \"gclose <password>\"");
		}
		else
		{
			for(new i = 0; i < MAX_GATES; i++)
			{
				if(Gates[i][gate_created])
				{
					if(IsPlayerInRangeOfPoint(playerid, 7.0, Gates[i][gateX], Gates[i][gateY], Gates[i][gateZ]))
					{
						count++;

						if(!strcmp(Gates[i][gate_password], password, true))
						{
							if(Gates[i][gate_status] == GATE_STATE_OPEN)
							{
								MoveDynamicObject(Gates[i][gate_object], Gates[i][gateX], Gates[i][gateY], Gates[i][gateZ] + 1.5, 9.0 );
								Gates[i][gate_status] = GATE_STATE_CLOSED;
							}
							else
							{
								SendClientMessage(playerid, COLOR_WHITE, "{B7B7B7}[SERVER] {FFFFFF}The gate must be open before you can close it.");
							}
						}
						else
						{
							SendClientMessage(playerid, COLOR_WHITE, "{B7B7B7}[SERVER] {FFFFFF}Incorrect password.");
						}

						break;
					}
				}
			}

			if (count == 0)
			{
				SendClientMessage(playerid, COLOR_WHITE, "{B7B7B7}[SERVER] {FFFFFF}You are not in range of a gate.");
			}
		}
	}

	return 1;
}

dcmd_ginfo(playerid, params[])
{
    #pragma unused params
	if ( IsPlayerConnected( playerid ) )
	{
		new
			count = 0
		;

		if(PlayerInfo[playerid][Level] >= 3)
		{
			for(new i = 0; i < MAX_GATES; i++)
			{
				if(Gates[i][gate_created])
				{
					if(IsPlayerInRangeOfPoint(playerid, 5.0, Gates[i][gateX], Gates[i][gateY], Gates[i][gateZ]))
					{
						count++;

						new gateInfo[200];
						format(gateInfo, sizeof(gateInfo), "{B7B7B7}[GATE] {FFFFFF}Gate ID: %i - Gate Title: %s - Gate Password: %s", Gates[i][gate_id], Gates[i][gate_title], Gates[i][gate_password]);
						SendClientMessage(playerid, COLOR_WHITE, gateInfo);

						break;
					}
				}
			}

			if (count == 0)
			{
				SendClientMessage(playerid, COLOR_WHITE, "{B7B7B7}[SERVER] {FFFFFF}You are not in range of a gate.");
			}
		}
		else
		{
			SendClientMessage(playerid, COLOR_WHITE, "{B7B7B7}[SERVER] {FFFFFF}You do not have permission to use that command.");
		}
	}

	return 1;
}

dcmd_gatedelete(playerid, params[])
{
        #pragma unused params
		if(PlayerInfo[playerid][Level] >= 5) return SendClientMessage(playerid, COLOR_RED, "ERROR: You don't have enough privileges to use this command!");
		{
			new
				gateid,
				gateQuery[200],
				deleteQuery[200]
			;

			if(sscanf(params, "i", gateid))
			{
				SendClientMessage(playerid, COLOR_WHITE, "{B7B7B7}[SERVER] {FFFFFF}Usage: \"gatedelete <gate id>\"");
			}
			else
			{
				format(gateQuery, sizeof(gateQuery), "SELECT * FROM `gates` WHERE `gate_id` = '%i' LIMIT 1", gateid);

				new DBResult:qresult, count = 0;
				qresult = db_query(DB: GATESDB, gateQuery);
				count = db_num_rows(qresult);

				if (count == 0)
				{
					SendClientMessage(playerid, COLOR_WHITE, "{B7B7B7}[SERVER] {FFFFFF}That gate ID doesn't exist.");
				}
				else
				{
					// Find the unique ID for house info
					new dbID, value[48];
					db_get_field_assoc(qresult, "gate_id", value, 48); // Gate UID
					dbID = strval(value);

					for(new i = 0; i < MAX_GATES; i++)
					{
						if(Gates[i][gate_id] == dbID)
						{
							format(deleteQuery, sizeof(deleteQuery), "DELETE FROM `gates` WHERE `gate_id` = '%i'", gateid);
							db_query(DB: GATESDB, deleteQuery);

							reloadGates();

							SendClientMessage(playerid, COLOR_WHITE, "{B7B7B7}[SERVER] {FFFFFF}Gate deleted.");

							break;
						}
					}
				}
			}
		}
		return 1;
}

dcmd_reloadgates(playerid, params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 5) return SendClientMessage(playerid, COLOR_RED, "ERROR: You don't have enough privileges to use this command!");
	{
		reloadGates();

		SendClientMessage(playerid, COLOR_WHITE, "{B7B7B7}[SERVER] {FFFFFF}Gates reloaded.");
	}

	return 1;
}

dcmd_gatecreate(playerid, params[])
{
        #pragma unused params
		if(PlayerInfo[playerid][Level] >= 5) return SendClientMessage(playerid, COLOR_RED, "ERROR: You don't have enough privileges to use this command!");
		{
			new
				query[400],
				Float:x,
				Float:y,
				Float:z,
				Float:a,
				password[128],
				title[128]
			;

			GetPlayerPos(playerid, x, y, z);
			GetPlayerFacingAngle(playerid, a);

			if(sscanf(params, "s[128]s[128]", title, password))
			{
				SendClientMessage(playerid, COLOR_WHITE, "{B7B7B7}[SERVER] {FFFFFF}Usage: \"gatecreate <title> <password>\"");
			}
			else
			{
				format(query, sizeof(query), "INSERT INTO `gates` (gate_title, gate_x, gate_y, gate_z, gate_a, gate_password) VALUES ('%s', '%f', '%f', '%f', '%f', '%s')", title, x, y, z, a, password);
				db_query(DB: GATESDB, query);

				SetPlayerPos(playerid, x + 1, y, z);

				reloadGates();
			}
		}
		return 1;
}
dcmd_gopen(playerid, params[])
{
    #pragma unused params
	if ( IsPlayerConnected( playerid ) )
	{
		new
			password[128],
			count = 0
		;

		if(sscanf(params, "s[128]", password))
		{
			SendClientMessage(playerid, COLOR_WHITE, "{B7B7B7}[SERVER] {FFFFFF}Usage: \"gopen <password>\"");
		}
		else
		{
			for(new i = 0; i < MAX_GATES; i++)
			{
				if(Gates[i][gate_created])
				{
					if(IsPlayerInRangeOfPoint(playerid, 7.0, Gates[i][gateX], Gates[i][gateY], Gates[i][gateZ]))
					{
						count++;

						if(!strcmp(Gates[i][gate_password], password, true))
						{
							if(Gates[i][gate_status] == GATE_STATE_CLOSED)
							{
								MoveDynamicObject(Gates[i][gate_object], Gates[i][gateX], Gates[i][gateY], Gates[i][gateZ] - 10.0, 7.0 );
								Gates[i][gate_status] = GATE_STATE_OPEN;
							}
							else
							{
								SendClientMessage(playerid, COLOR_WHITE, "{B7B7B7}[SERVER] {FFFFFF}The gate must be closed before you can open it.");
							}
						}
						else
						{
							SendClientMessage(playerid, COLOR_WHITE, "{B7B7B7}[SERVER] {FFFFFF}Incorrect password.");
						}

						break;
					}
				}
			}

			if (count == 0)
			{
				SendClientMessage(playerid, COLOR_WHITE, "{B7B7B7}[SERVER] {FFFFFF}You are not in range of a gate.");
			}
		}
	}

	return 1;
}
dcmd_lotto(playerid, params[])
{
    	            #pragma unused params
                    new number = strval(params);
					if(!strlen(params)) return SendClientMessage(playerid, red, "SAGE: /lotto [number]");
                    if (LottoParticipant[playerid] == 1)
                    {
                                        SendClientMessage(playerid, COLOR_RED, "*You already have a lotto ticket !");
                    }
                    else
                    {
                        if (GetPlayerMoneyEx(playerid) >= LOTTO_PRICE)
                                        {
                                                if (number > 0 && number < 100)
                                                {
                                                    if (NumberUsed[number] == 0)
                                                    {
                                                                new strings[256];
                                                                format(strings, sizeof(strings), "{147E8C}*You have purchased the lotto number %d and you have been charged $5000 for the ticket.", number);
                                                                SendClientMessage(playerid,COLOR_RED,strings);
                                                                SendClientMessage(playerid,COLOR_RED,"{147E8C}*Draw will commence at 06:00 and 18:00.");
                                                                PlayerLottoGuess[playerid] = number;
                                                                LottoParticipant[playerid] = 1;
                                                                GivePlayerMoneyEx(playerid, -5000);
                                                        }
                                                        else
                                                        {
                                                                SendClientMessage(playerid, COLOR_RED, "*The number you selected is already choosed by another player !");
                                                        }

                                                }
                                                else
                                                {
                                                        SendClientMessage(playerid, COLOR_RED, "*The number you entered is invalid, please type a number between 0 and 98.");
                                                }
                                        }
                                        else
                                        {
                                            SendClientMessage(playerid, COLOR_RED, "*You do not have enought money to buy a lotto ticket.");
                                        }
                                }
        return 1;
        }
        dcmd_jackpot(playerid, params[])
        {
                #pragma unused params
                new stringss[256];
                format(stringss, sizeof(stringss), "{147E8C}*The Lottery Jackpot is now at $%s. Type /lotto [Number] to purchase a lotto Ticket.", FormatNumber(LottoJackpot));
                SendClientMessage(playerid, COLOR_GREEN, stringss);
                SendClientMessage(playerid,COLOR_RED,"{147E8C}*Draw will commence at 06:00 and 18:00.");
                return 1;
        }
        dcmd_lottodraw(playerid, params[])
        {
                #pragma unused params
                if(PlayerInfo[playerid][Level] >= 5 || (PlayerInfo[playerid][Level] == 6))
                LottoDraw();
                SendClientMessage(playerid, COLOR_GREEN, "You have drawn Lotto.");
                return 1;
        }
        dcmd_resetjackpot(playerid, params[])
        {
                #pragma unused params
                if(PlayerInfo[playerid][Level] >= 5 || (PlayerInfo[playerid][Level] == 6))
                {
                    ResetJackpot();
                    SendClientMessage(playerid, COLOR_RED, "Jackpot set to 0.");
                }
                else
                {
                }
        return 1;
	}
dcmd_payday(playerid, params[])
{
    #pragma unused params
   	new interest[MAX_PLAYERS];
    interest[playerid] = GetPlayerMoney(playerid)*9/100;
    new msg[128];
    format(msg,sizeof(msg),"*You will recieve $%s on every game day as Payday.", FormatNumber(interest[playerid]));
    SendClientMessage(playerid,COLOR_LIGHTBLUE,msg);
	return 1;
}

dcmd_chatcolor(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 3)
    {
		new R, G, B, str[70];
		if (sscanf(params, "ddd", R, G, B)) return SendClientMessage(playerid, 0x6FFF00FF, "{FF0000}USAGE: {BABABA}/chatcolor <R> <G> <B> [0-255]" );
        if (R < 0 || R > 255 || G < 0 || G > 255 || B < 0 || B > 255) return SendClientMessage(playerid, -1, "{FF0000}Error: {BABABA}Color R-G-Bs cannot be lower than 0 or higher than 255!");
		PlayerInfo[playerid][ChatColor] = MAKE_COLOR_FROM_RGB(R, G, B, 255);
		format(str, sizeof(str), "{%06x}You have successfully changed your chat color!", (PlayerInfo[playerid][ChatColor] >>> 8));
		SendClientMessage(playerid, -1, str);
		SendClientMessage(playerid, COLOR_GREY, "{FF8000}Info: {C0C0C0}To set back your chat color to the default (White), type /chatcolor 255 255 255!");
	}
	return 1;
}

dcmd_seths(playerid, params[])
{
    #pragma unused params
	new string[150], id, h;
    new tmp[256], Index; tmp = strtok(params,Index);
	if(PlayerInfo[playerid][Level] >= 5)
	{
	    if(sscanf(params, "ui", id, h)) return SendClientMessage(playerid, COLOR_RED, "USAGE: /seths [playerid] [0-30]");
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "{FF0000}» Player not connected.");
	    if(h < 0 || h > 30) return SendClientMessage(playerid, -1, "{FF0000}» Invalid Horseshoe ID!");
		format(string, sizeof(string), "[HORSESHOE] %s's Horseshoe has been set to %d by Leader/Manager %s.", pName(id), h, pName(playerid));
		SendClientMessageToAll(COLOR_GREEN, string);
		format(string, sizeof(string), "Leader/Manager %s has set your horseshoe collection to %d.", pName(playerid), h);
		SendClientMessage(id, COLOR_GREEN, string);
	    return PlayerInfo[playerid][HS] = h;
	}
	else return SendClientMessage(playerid, -1, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_gotohs(playerid, params[])
{
    #pragma unused params
	new str[150], id;
    if(PlayerInfo[playerid][Level] >= 5)
	{
	    if(sscanf(params, "i", id))
	    {
	        SendClientMessage(playerid, COLOR_RED, "USAGE: /gotohs [0-29]");
	        SendClientMessage(playerid, -1, "Example: /gotohs 0 (Teleports you to horseshoe 1)");
	        return 1;
	    }
	    if(id < 0 || id > 29) return SendClientMessage(playerid, COLOR_RED, "ERROR: Invalid Horseshoe ID!");
		if(id == 0)
		{
		    SetCameraBehindPlayer(playerid);
		    SetPlayerPos(playerid, 2011.8767,1544.7483+3,9.4787);
		    SetPlayerInterior(playerid, 0);
		    SetPlayerVirtualWorld(playerid, 0);
		}
		else if(id >= 1)
		{
		    SetCameraBehindPlayer(playerid);
		    SetPlayerPos(playerid, shoecord[id][hx], shoecord[id][hy], shoecord[id][hz]);
		    SetPlayerInterior(playerid, 0);
		    SetPlayerVirtualWorld(playerid, 0);
		}
		format(str, sizeof(str), "Teleported to %i horseshoe!", id);
		SendClientMessage(playerid, COLOR_YELLOW, str);
	}
	else SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}

dcmd_givescore(playerid,params[])
{
     if(PlayerInfo[playerid][Level] >= 5) {
	    new score = (0), string[128] = "\0";
        new name[MAX_PLAYER_NAME], player1;
	    if(sscanf(params, "ui", player1, score)) return
        SendClientMessage(playerid, 0xFFFF00C8, "Usage: /Givescore <PlayerID> <score>") ;
        if(score > 10000) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can't give more than 10k score!");
        if(IsPlayerConnected(player1))
        {
	    GetPlayerName(player1, name, sizeof(name));
        format(string, (sizeof string), "{00FFFF}Manager/CEO \"%s\" given you +%d score", pName(playerid), score);
        SendClientMessage(player1, blue,string);
        format(string, (sizeof string), "You have given +%d score to %s", score, name);
        SendClientMessage(playerid, blue,string);
 	    CMDMessageToAdmins(playerid,"GiveScore");
	    SetPlayerScore(player1, GetPlayerScore(player1) + score);
		}
		else return SendClientMessage(playerid, red, "ERROR: Player is not connected");
	 } else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	 return 1;
}

dcmd_givecash(playerid,params[])
{
    
	if(PlayerInfo[playerid][Level] >= 5) {
		new amount, string[128], player1, name[MAX_PLAYER_NAME];
		if(sscanf(params, "ui", player1, amount)) return
		SendClientMessage(playerid, 0xFFFF00C8, "Usage: /Givecash <PlayerID> <ammount>");
        if(amount > 100000000) return SendClientMessage(playerid, COLOR_RED, "ERROR: You can't give more than 100m cash!");
		if(IsPlayerConnected(player1))
		{
		GetPlayerName(player1, name, sizeof(name));
		format(string,sizeof(string),"Manager/CEO \"%s\" has given you '$%d'", pName(playerid), amount);
		SendClientMessage(player1, blue, string);
		format(string,sizeof(string),"You have given '$%d' to %s", amount, name);
		SendClientMessage(playerid, blue, string);
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		return GivePlayerMoneyEx(player1,amount);
	    }
		else return SendClientMessage(playerid, red, "ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_saveallstats(playerid, params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 6)
    {
       new name[MAX_PLAYER_NAME], string[128];
	   for(new i; i<MAX_PLAYERS; i++)
       {
       if(IsPlayerConnected(i))
       {
          SavePlayer(i);
       }
	   }
       GetPlayerName(playerid, name, sizeof(name));
       format(string, sizeof(string), "Manager/CEO %s has manually saved all players stats!", name);
       SendClientMessageToAll(COLOR_GREEN, string);
	}
	else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}

dcmd_hostname(playerid,params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 6)
    {
		new string[128];
        if(sscanf(params, "s[128]",string)) return SendClientMessage(playerid,yellow,"Usage: /Hostname <New Host Name>");
		format(string,sizeof(string),"hostname %s",string);
		SendRconCommand(string);
		format(string,sizeof(string),"%s has changed the server host name to \"%s\"",pName(playerid),params);
		CMDMessageToAdmins(playerid,"HostName");
		return SendClientMessage(playerid, green, "You have successfully chanded your server's HostName");
	}
	else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_mapname(playerid,params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 6)
    {
		new string[128];
        if(sscanf(params, "s[128]",string)) return SendClientMessage(playerid,yellow,"USAGE: /Mapname <New Map Name>");
		format(string,sizeof(string),"mapname %s",string);
		SendRconCommand(string);
		format(string,sizeof(string),"%s has changed the server map name to \"%s\"",pName(playerid),params);
		CMDMessageToAdmins(playerid,"MapName");
	    return SendClientMessage(playerid, green, "You have successfully chanded your server's MapName");
	}
	else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_gmtext(playerid,params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 6)
    {
		new string[128];
        if(sscanf(params, "s[128]",string)) return SendClientMessage(playerid,yellow,"USAGE: /Gmtext <New Gamemode Name>");
		format(string,sizeof(string),"gamemodetext %s",string);
		SendRconCommand(string);
		format(string,sizeof(string),"%s has changed the gamemode name to \"%s\"",pName(playerid),params);
		CMDMessageToAdmins(playerid,"GMText");
    	return SendClientMessage(playerid, green, "You have successfully chanded your server's GMText");
	}
	else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_clearplayerchat(playerid, params[])
{
     #pragma unused params
     if(PlayerInfo[playerid][Level] >= 3)
	 {
		 new id, string[128];
         if(sscanf(params, "u", id)) return SendClientMessage(playerid, yellow, "Usage: /claerplayerchat <Player ID>");
	     for(new i = 0; i < 40; i++)
	     SendClientMessage(id,-1," ");
	     format(string,sizeof(string),"You have cleared %s's chat!",GetName(id));
	     SendClientMessage(playerid,yellow,string);
	     CMDMessageToAdmins(playerid,"ClearPlayerChat");
	     return 1;
	 }
	 else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");

}

dcmd_cpc(playerid, params[])
{
return dcmd_clearplayerchat(playerid,params);
}

dcmd_burnall(playerid,params[]) {
      #pragma unused params
	  if(PlayerInfo[playerid][Level] >= 4)
	  {
	       new Float:x, Float:y, Float:z, string[128];
	       format(string,sizeof(string),"Admin '%s' has burnet all players",pName(playerid));
		   SendClientMessageToAll(yellow,string);
		   CMDMessageToAdmins(playerid,"BurnAll");
		   foreach(Player, i)
		   {
			   if (playerid != i && PlayerInfo[i][Level] <= PlayerInfo[playerid][Level])
			   {
				   GetPlayerPos(i, x, y, z);
				   CreateExplosion(x, y , z + 3, 1, 10);
			   }
		   }
		   return 1;
	  }
	  else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_giveweapon(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 2)
	{
	    new tmp[256], tmp2[256], tmp3[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index), tmp3 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "USAGE: /giveweapon [playerid] [weapon id/weapon name] [ammo]");
		new player1 = strval(tmp), weap, ammo, WeapName[32], string[128];
		if(!strlen(tmp3) || !IsNumeric(tmp3) || strval(tmp3) <= 0 || strval(tmp3) > 99999) ammo = 500; else ammo = strval(tmp3);
		if(!IsNumeric(tmp2)) weap = GetWeaponIDFromName(tmp2);
		else weap = strval(tmp2);
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID)
		{
        	if(!IsValidWeapon(weap)) return SendClientMessage(playerid,red,"ERROR: Invalid weapon ID");
			CMDMessageToAdmins(playerid,"GIVEWEAPON");
			GetWeaponName(weap,WeapName,32);
			format(string, sizeof(string), "You have given \"%s\" a %s (%d) with %d rounds of ammo", PlayerName2(player1), WeapName, weap, ammo);
			SendClientMessage(playerid,blue,string);
			if(player1 != playerid)
			{
			format(string,sizeof(string),"Administrator \"%s\" has given you a %s (%d) with %d rounds of ammo", PlayerName2(playerid), WeapName, weap, ammo);
			SendClientMessage(player1,blue,string);
			}
			if(weap == 38)
			{
               SetPVarInt(player1, "AdminGivenMini", 1);
			}
		   	return GivePlayerWeapon(player1, weap, ammo);
		}
		else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	}
	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_superjump(playerid,params[])
{
#pragma unused params
if(PlayerInfo[playerid][Level] >= 2)
{

{
	if(SuperJump[playerid] == 0)
	{
		SendClientMessage(playerid, 0xFF0000FF, "{00FFFF}Super Jump: {33AA33}Activated!");
		SuperJump[playerid] = 1;
		return 1;
 	}
	else if(SuperJump[playerid] == 1)
	{
	   	SendClientMessage(playerid, 0xFF0000FF, "{00FFFF}Super Jump: {FF0000}Deactivated!");
	   	SuperJump[playerid] = 0;
        return 1;
	}
}
}
return 1;
}

dcmd_setmycolor(playerid,params[]) // Set ur own color
{
        static R, G, B;
        if (sscanf(params, "iii", R,G,B)) return SendClientMessage(playerid, 0xff0000aa, "*Usage: /color <0-255> <0-255> <0-255>");
        SendClientMessage(playerid,(R * 16777216) + (G * 65536) + (B*256), "You have changed your color");
        SetPlayerColor(playerid, (R * 16777216) + (G * 65536) + (B*256));
        return 1;
}

dcmd_setcolor(playerid,params[])
{
    static ID, R, G, B, name[MAX_PLAYER_NAME], string[128];
    if(!IsPlayerAdmin(playerid)) return 1;
    if (sscanf(params, "uiii", ID, R,G,B)) return SendClientMessage(playerid, 0xff0000aa, "{FF0000}Usage: /setcolor [playerid/name] <0-255> <0-255> <0-255>");

    GetPlayerName(playerid, name, sizeof(name));
    format(string, sizeof(string), "this is your new color, set by %s", name);
    SendClientMessage(ID,(R * 16777216) + (G * 65536) + (B*256), string);
    GetPlayerName(ID, name, sizeof(name));
    format(string, sizeof(string), "this is the new color, u gave to %s, use /unforce to let him change their color again.", name);
    SendClientMessage(playerid,(R * 16777216) + (G * 65536) + (B*256), string);
    SetPlayerColor(ID, (R * 16777216) + (G * 65536) + (B*256));
    return 1;
}

dcmd_setallcolor(playerid,params[]) // Set all the players color
{
	if(PlayerInfo[playerid][Level] >= 4) {
	static R, G, B, name[MAX_PLAYER_NAME], string[128];
    if(!IsPlayerAdmin(playerid)) return 1;
    if (sscanf(params, "iii", R,G,B)) return SendClientMessage(playerid, 0xff0000aa, "*Usage: /setallcolor <0-255> <0-255> <0-255>");
    for(new i; i<MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i)) // Let's not overflood the variables...
        {
            SetPlayerColor(i, (R * 16777216) + (G * 65536) + (B*256));
        }
	}
    GetPlayerName(playerid, name, sizeof(name));
    format(string, sizeof(string), "Administrator %s has set all players color to this!", name);
    SendClientMessageToAll((R * 16777216) + (G * 65536) + (B*256), string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}
dcmd_sethealth(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 3) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "USAGE: /sethealth [playerid] [amount]");
		if(strval(tmp2) < 0 || strval(tmp2) > 100 && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid, red, "ERROR: Invaild health amount");
		new player1 = strval(tmp), health = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"SETHEALTH");
			format(string, sizeof(string), "You have set \"%s's\" health to '%d", pName(player1), health); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has set your health to '%d'", pName(playerid), health); SendClientMessage(player1,blue,string); }
   		    return SetPlayerHealth(player1, health);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_setarmour(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 3) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setarmour [playerid] [amount]");
		if(strval(tmp2) < 0 || strval(tmp2) > 100 && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid, red, "ERROR: Invaild health amount");
		new player1 = strval(tmp), armour = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"SETARMOUR");
			format(string, sizeof(string), "You have set \"%s's\" armour to '%d", pName(player1), armour); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has set your armour to '%d'", pName(playerid), armour); SendClientMessage(player1,blue,string); }
   			return SetPlayerArmour(player1, armour);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_setcash(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 6) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setcash [playerid] [amount]");
		new player1 = strval(tmp), cash = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID)
        {
			CMDMessageToAdmins(playerid,"SETCASH");
			format(string, sizeof(string), "You have set \"%s's\" cash to '$%d", pName(player1), cash); SendClientMessage(playerid,blue,string);
			if(player1 != playerid)
			{
				format(string,sizeof(string),"Manager/CEO \"%s\" has set your cash to '$%d'", pName(playerid), cash);
				SendClientMessage(player1,blue,string);
			}
			ResetPlayerMoneyEx(player1);
   			return GivePlayerMoneyEx(player1, cash);
	    }
	    else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	}
	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_sbon(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 5)
	{
	SendClientMessageToAll(red,"{00FF40}STUNT BONUS HAS BEEN ENABLED BY ADMINISTRATOR");
	EnableStuntBonusForAll(true);
	}
	else return SendClientMessage(playerid,red,"ERROR:You are not {00FFFF}Leader{00FFFF} to use this command");
	return 1;
}
dcmd_sboff(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 5)
	{
	SendClientMessageToAll(red,"{FF0000}STUNT BONUS HAS BEEN DISABLED BY ADMINISTRATOR");
	EnableStuntBonusForAll(false);
	}
	else return SendClientMessage(playerid,red,"ERROR:You are not {00FFFF}Leader{00FFFF} to use this command");
	return 1;
}
dcmd_setscore(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 6) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setscore [playerid] [score]");
		new player1 = strval(tmp), score = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"SETSCORE");
			format(string, sizeof(string), "You have set \"%s's\" score to '%d' ", pName(player1), score); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Manager/CEO \"%s\" has set your score to '%d'", pName(playerid), score); SendClientMessage(player1,blue,string); }
   			return SetPlayerScore(player1, score);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_giveallscore(playerid,params[])
{
	 new score = (0), string[128] = "\0", adminName[MAX_PLAYER_NAME];
     if(PlayerInfo[playerid][Level] < 6) return SendClientMessage(playerid, -1, "{FF0000}ERROR:You dont have enough privileges to use this command.");
     if(sscanf(params, "d", score)) return SendClientMessage(playerid, -1, "{FF0000}USAGE: /giveallscore [Score]"); // [url]http://forum.sa-mp.com/showthread.php?t=120356[/url]
     else
     {
          GetPlayerName(playerid, adminName, MAX_PLAYER_NAME);
          for(new i = (0), players = GetMaxPlayers(); i < players; ++ i)
          {
                SetPlayerScore(i, GetPlayerScore(i) + score);
          }
          format(string, (sizeof string), "{00FFFF}Manager/CEO \"%s\" given all players +%d score ", adminName, score);
          SendClientMessageToAll(blue,string);
          }
     return 1;
}
dcmd_giveallcookie(playerid,params[])
{
	 new gcookie, string[128], adminName[MAX_PLAYER_NAME];
     if(PlayerInfo[playerid][Level] < 5) return SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
     if(gcookie > 10) return SendClientMessage(playerid,-1, "{FF0000}ERROR: You can't give more than 10 cookies!");
     if(sscanf(params, "d", gcookie)) return SendClientMessage(playerid, -1, "{FF0000}USAGE: /giveallcookie [gcookie]");
     else
     {
          GetPlayerName(playerid, adminName, MAX_PLAYER_NAME);
          for(new i = (0), players = GetMaxPlayers(); i < players; ++ i)
          {
                PlayerInfo[i][Cookies] += gcookie;
          }
          format(string, (sizeof string), "{00FFFF}Administrator \"%s\" given all players +%d Cookies.", adminName, gcookie);
          SendClientMessageToAll(blue,string);
          }
     return 1;
}
dcmd_giveallbrownie(playerid,params[])
{
	 new gbrownie, string[128], adminName[MAX_PLAYER_NAME];
     if(PlayerInfo[playerid][Level] < 5) return SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
     if(gbrownie > 10) return SendClientMessage(playerid,-1, "{FF0000}ERROR: You can't give more than 10 Brownies!");
     if(sscanf(params, "d", gbrownie)) return SendClientMessage(playerid, -1, "{FF0000}USAGE: /giveallbrownie [Amount]"); // [url]http://forum.sa-mp.com/showthread.php?t=120356[/url]
     else
     {
          GetPlayerName(playerid, adminName, MAX_PLAYER_NAME);
          for(new i = (0), players = GetMaxPlayers(); i < players; ++ i)
          {
                PlayerInfo[i][pBrownies] += gbrownie;
          }
          format(string, (sizeof string), "{00FFFF}Administrator \"%s\" given all players +%d Brownies!", adminName, gbrownie);
          SendClientMessageToAll(blue,string);
          }
     return 1;
}
dcmd_djtag(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][isDJ] == 1 || PlayerInfo[playerid][Level] >= 1)
	{
	if(djtag[playerid] == 0)
	{
        djtag[playerid] = 1;
	    SendClientMessage(playerid, COLOR_YELLOW,"{FF80FF}[DJ]{00FF00}Tag has been enabled, Type /djtag again to disable it.");
	}
	else
	{
	    djtag[playerid] = 0;
		SendClientMessage(playerid,COLOR_YELLOW,"{FF80FF}[DJ]Tag{FF0000} has been disabled, Type /djtag again to enable it.");
	}
	} else return SendClientMessage(playerid, COLOR_YELLOW,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
    return 1;
}

dcmd_vtag(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][pVip] >= 1 || PlayerInfo[playerid][Level] >= 1)
	{
	if(vtag[playerid] == 0)
	{
        vtag[playerid] = 1;
        VIPTag[playerid] = 1;
        VIP[playerid] = Create3DTextLabel("(V.I.P Member)", COLOR_YELLOW, 0.0, 0.0, 0.0, 50.0, 0, 0);
        Attach3DTextLabelToPlayer(VIP[playerid], playerid, 0.0, 0.0, 0.0);
	    SendClientMessage(playerid, COLOR_YELLOW,"{FFFF00}[VIP]{FFFF00}Tag has been enabled, Type /vtag again to disable it.");
	}
	else
	{
	    vtag[playerid] = 0;
        VIPTag[playerid] = 0;
        DestroyDynamic3DTextLabel(VIP[playerid]);
        Delete3DTextLabel(VIP[playerid]);
		SendClientMessage(playerid,COLOR_YELLOW,"{FF0000}[VIP]Tag{FFFF00} has been disabled, Type /vtag again to enable it.");
	}
	} else return SendClientMessage(playerid, COLOR_YELLOW,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
    return 1;
}

dcmd_ttag(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1)
	{
	if(ttag[playerid] == 0)
	{
	    ttag[playerid] = 1;
        TrialModeratorTag[playerid] = 1;
        TrialModerator[playerid] = Create3DTextLabel("(Trial Moderator)", COLOR_TrialModerator, 0.0, 0.0, 0.0, 50.0, 0, 0);
        Attach3DTextLabelToPlayer(TrialModerator[playerid], playerid, 0.0, 0.0, 0.0);
	    SendClientMessage(playerid, COLOR_TrialModerator,"{FFFF00}[Trial Moderator]{FFFF00}Tag has been enabled, Type /ttag again to disable it.");
	}
	else
	{
	    ttag[playerid] = 0;
        TrialModeratorTag[playerid] = 0;
        DestroyDynamic3DTextLabel(TrialModerator[playerid]);
        Delete3DTextLabel(TrialModerator[playerid]);
	    SendClientMessage(playerid,COLOR_TrialModerator,"{FF0000}[Trial Moderator]Tag{FFFF00} has been disabled, Type /ttag again to enable it.");
	}
	} else return SendClientMessage(playerid, red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
    return 1;
}

dcmd_mtag(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2)
	{
	if(mtag[playerid] == 0)
	{
	    mtag[playerid] = 1;
	    ModTag[playerid] = 1;
        Mod[playerid] = Create3DTextLabel("{FFFF00}({FF0000}Moderator{FFFF00})", COLOR_RED, 0.0, 0.0, 0.0, 50.0, 0, 0);
        Attach3DTextLabelToPlayer(Mod[playerid], playerid, 0.0, 0.0, 0.0);
	    SendClientMessage(playerid,COLOR_RED,"{FF0000}[Mod]Tag{FFFF00} has been enabled, Type /mtag again to disable it.");
	}
	else
	{
	    mtag[playerid] = 0;
        ModTag[playerid] = 0;
        DestroyDynamic3DTextLabel(Mod[playerid]);
        Delete3DTextLabel(Mod[playerid]);
	    SendClientMessage(playerid,COLOR_RED,"{FF0000}[Mod]Tag{FFFF00} has been disabled, Type /mtag again to enable it.");
	}
	} else return SendClientMessage(playerid, COLOR_RED,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
    return 1;
}

dcmd_coatag(playerid,params[])
{
	#pragma unused params
    if(PlayerInfo[playerid][Level] >= 3)
	{
	if(COAtag[playerid] == 0)
	{
	    COAtag[playerid] = 1;
        CoAdminTag[playerid] = 1;
        CoAdmin[playerid] = Create3DTextLabel("{FFFF00}({FF0000}Administrator{FFFF00})", COLOR_LIGHTGREEN, 0.0, 0.0, 0.0, 50.0, 0, 0);
        Attach3DTextLabelToPlayer(CoAdmin[playerid], playerid, 0.0, 0.0, 0.0);
   	    SendClientMessage(playerid,LightGreen,"[CO-ADMIN]Tag has been enabled, Type /coatag again to disable it.");
	}
	else
	{
	    COAtag[playerid] = 0;
        CoAdminTag[playerid] = 0;
        DestroyDynamic3DTextLabel(CoAdmin[playerid]);
        Delete3DTextLabel(CoAdmin[playerid]);
	    SendClientMessage(playerid,LightGreen,"[CO-ADMIN]Tag has been disabled, Type /coatag again to enable it.");
	}
    } else return SendClientMessage(playerid, COLOR_LIGHTGREEN,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}

dcmd_atag(playerid,params[])
{
	#pragma unused params
    if(PlayerInfo[playerid][Level] >= 4)
	{
	if(Atag[playerid] == 0)
	{
	    Atag[playerid] = 1;
        AdminTag[playerid] = 1;
        Admin[playerid] = Create3DTextLabel("{FFFF00}({FF0000}Administrator{FFFF00})", COLOR_LIGHTGREEN, 0.0, 0.0, 0.0, 50.0, 0, 0);
        Attach3DTextLabelToPlayer(Admin[playerid], playerid, 0.0, 0.0, 0.0);
	    SendClientMessage(playerid,LightGreen,"[ADMIN]Tag has been enabled, Type /atag again to disable it.");
	}
	else
	{
	    Atag[playerid] = 0;
        AdminTag[playerid] = 0;
        DestroyDynamic3DTextLabel(Admin[playerid]);
        Delete3DTextLabel(Admin[playerid]);
	    SendClientMessage(playerid,LightGreen,"[ADMIN]Tag has been disabled, Type /atag again to enable it.");
	}
    } else return SendClientMessage(playerid, red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}
dcmd_ltag(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 5)
	{
	if(Ltag[playerid] == 0)
	{
	    Ltag[playerid] = 1;
        LeaderTag[playerid] = 1;
        Leader[playerid] = Create3DTextLabel("{FFFF00}({00FFFF}Leader{FFFF00})", COLOR_BLUE, 0.0, 0.0, 0.0, 50.0, 0, 0);
        Attach3DTextLabelToPlayer(Leader[playerid], playerid, 0.0, 0.0, 0.0);
   	    SendClientMessage(playerid,lightblue,"[LEADER]Tag has been enabled, Type /ltag again to disable it.");
	}
	else
	{
	    Ltag[playerid] = 0;
        LeaderTag[playerid] = 0;
        DestroyDynamic3DTextLabel(Leader[playerid]);
        Delete3DTextLabel(Leader[playerid]);
	    SendClientMessage(playerid,lightblue,"[LEADER]Tag has been disabled, Type /ltag again to enable it.");
	}
    } else return SendClientMessage(playerid,red,"{C0C0C0}ERROR: You are not a {00FFFF}Leader{00FFFF} to use this command!");
	return 1;
}
dcmd_ceotag(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 6)
	{
	if(CEOtag[playerid] == 0)
	{
	    CEOtag[playerid] = 1;
        ManagerTag[playerid] = 1;
        Manager[playerid] = Create3DTextLabel("{FFFF00}({00FFFF}Manager/CEO{FFFF00})", COLOR_DARKBLUE, 0.0, 0.0, 0.0, 50.0, 0, 0);
        Attach3DTextLabelToPlayer(Manager[playerid], playerid, 0.0, 0.0, 0.0);
	    SendClientMessage(playerid, COLOR_DARKBLUE,"[MANAGER/CEO]Tag{00FFFF} has been enabled, Type /ceotag again to disable it.");
	}
	else
	{
	    CEOtag[playerid] = 0;
        ManagerTag[playerid] = 0;
        DestroyDynamic3DTextLabel(Manager[playerid]);
        Delete3DTextLabel(Manager[playerid]);
	    SendClientMessage(playerid, COLOR_DARKBLUE,"[MANAGER/CEO]Tag{00FFFF} has been disabled, Type /ceotag again to enable it.");
	}
    } else return SendClientMessage(playerid, COLOR_DARKBLUE,"{C0C0C0}ERROR: You are not a {00FFFF}Manager/CEO{00FFFF} to use this command!");
	return 1;
}
dcmd_tbstag(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 4)
	{
	if(TBStag[playerid] == 0)
	{
        TBStag[playerid] = 1;
        TBSStaffTag[playerid] = 1;
	    TBS[playerid] = Create3DTextLabel("{FFFF00}({00FFFF}TBS Staff{FFFF00})", COLOR_RED, 0.0, 0.0, 0.0, 50.0, 0, 0);
        Attach3DTextLabelToPlayer(TBS[playerid], playerid, 0.0, 0.0, 0.0);
	    SendClientMessage(playerid,red,"[TBS]Tag{00FFFF} has been enabled, Type /tbstag again to disable it.");
	}
	else
	{
	    TBStag[playerid] = 0;
        TBSStaffTag[playerid] = 0;
        DestroyDynamic3DTextLabel(TBS[playerid]);
        Delete3DTextLabel(TBS[playerid]);
	    SendClientMessage(playerid,red,"[TBS]Tag{00FFFF} has been disabled, Type /tbstag again to enable it.");
	}
    } else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}

dcmd_setskin(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 3) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setskin [playerid] [skin id]");
		new player1 = strval(tmp), askin = strval(tmp2), string[128];
		if(!IsValidSkin(askin)) return SendClientMessage(playerid, red, "ERROR: Invaild Skin ID");
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"SETSKIN");
			format(string, sizeof(string), "You have set \"%s's\" skin to '%d", pName(player1), askin); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has set your skin to '%d'", pName(playerid), askin); SendClientMessage(player1,blue,string); }
   			return SetPlayerSkin(player1, askin);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_skin(playerid, params[])
{
	#pragma unused params
    if(GetPVarInt(playerid,"InDM") == 1 || GetPVarInt(playerid,"InRace") == 1 || GetPVarInt(playerid,"InCnR") == 1) return SendClientMessage(playerid,RED,"{E01B4C}Sorry, you can't use this command here do {FF9000}/leave or /exit");
	ShowModelSelectionMenu(playerid, skinlist, "~g~Select Skin");
	return 1;
}

dcmd_skinid(playerid,params[])
{
    if(GetPVarInt(playerid,"InDM") == 1 || GetPVarInt(playerid,"InRace") == 1 || GetPVarInt(playerid,"InCnR") == 1) return SendClientMessage(playerid,RED,"{E01B4C}Sorry, you can't use this command here do {FF9000}/leave or /exit");
	new cmdskinid, skinstr[128];
	if(isnull(params))
	{
		PSkinID[playerid] = GetPlayerSkin(playerid);
		format(skinstr, sizeof(skinstr), "{BBFF00}[SKIN] Your skin preference has been set to %d!", PSkinID[playerid]);
		SendClientMessage(playerid, -1, skinstr);
	}
	if(sscanf(params, "d", cmdskinid)) return SendClientMessage(playerid, COLOR_GREEN, "{F07F1D}USAGE: {BBFF00}/skin <ID>");
	if(cmdskinid < 0 || cmdskinid > 299) return SendClientMessage(playerid, -1,"{FA002E}ERROR: {C7BDBF}Your skin ID parameter should be between 0 - 299!");
    SetPlayerSkin(playerid, cmdskinid), PSkinID[playerid] = cmdskinid;
    SavePlayer(playerid);
	format(skinstr,sizeof(skinstr),"{F6C73B}[SKIN] {5896ED}You have changed your skin ID to {F07F1D}%d{5896ED}!", cmdskinid);
	SendClientMessage(playerid, -1, skinstr);
	SendClientMessage(playerid, -1, "{6BED40}TIP: {FFEF3D}You can simple type /skin to save your current skin as your skin preference!");
	return 1;
}

dcmd_setwanted(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 3) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setwanted [playerid] [level]");
		new player1 = strval(tmp), wanted = strval(tmp2), string[128];
//		if(wanted > 6) return SendClientMessage(playerid, red, "ERROR: Invaild wanted level");
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"SETWANTED");
			format(string, sizeof(string), "You have set \"%s's\" wanted level to '%d", pName(player1), wanted); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has set your wanted level to '%d'", pName(playerid), wanted); SendClientMessage(player1,blue,string); }
   			return SetPlayerWantedLevel(player1, wanted);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_setname(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 4 || IsPlayerAdmin(playerid)) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setname [playerid] [new name]");
		new player1 = strval(tmp), length = strlen(tmp2), string[128];
		if(length < 3 || length > MAX_PLAYER_NAME) return SendClientMessage(playerid,red,"ERROR: Incorrect Name Length");
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"SETNAME");
			format(string, sizeof(string), "You have set \"%s's\" name to \"%s\" ", pName(player1), tmp2); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has set your name to \"%s\" ", pName(playerid), tmp2); SendClientMessage(player1,blue,string); }
			SetPlayerName(player1, tmp2);
   			return OnPlayerConnect(player1);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_setcolour(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 2) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) {
			SendClientMessage(playerid, red, "USAGE: /setcolour [playerid] [Colour]");
			return SendClientMessage(playerid, red, "Colours: 0=black 1=white 2=red 3=orange 4=yellow 5=green 6=blue 7=purple 8=brown 9=pink");
		}
		new player1 = strval(tmp), Colour = strval(tmp2), string[128], colour[24];
		if(Colour > 9) return SendClientMessage(playerid, red, "Colours: 0=black 1=white 2=red 3=orange 4=yellow 5=green 6=blue 7=purple 8=brown 9=pink");
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
	        CMDMessageToAdmins(playerid,"SETCOLOUR");
			switch (Colour)
			{
			    case 0: { SetPlayerColor(player1,black); colour = "Black"; }
			    case 1: { SetPlayerColor(player1,COLOR_WHITE); colour = "White"; }
			    case 2: { SetPlayerColor(player1,red); colour = "Red"; }
			    case 3: { SetPlayerColor(player1,orange); colour = "Orange"; }
				case 4: { SetPlayerColor(player1,orange); colour = "Yellow"; }
				case 5: { SetPlayerColor(player1,COLOR_GREEN1); colour = "Green"; }
				case 6: { SetPlayerColor(player1,COLOR_BLUE); colour = "Blue"; }
				case 7: { SetPlayerColor(player1,COLOR_PURPLE); colour = "Purple"; }
				case 8: { SetPlayerColor(player1,COLOR_BROWN); colour = "Brown"; }
				case 9: { SetPlayerColor(player1,COLOR_PINK); colour = "Pink"; }
			}
			if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has set colour to '%s' ", pName(playerid), colour); SendClientMessage(player1,blue,string); }
			format(string, sizeof(string), "You have set \"%s's\" colour to '%s' ", pName(player1), colour);
   			return SendClientMessage(playerid,blue,string);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_setweather(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 3) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setweather [playerid] [weather id]");
		new player1 = strval(tmp), weather = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"SETWEATHER");
			format(string, sizeof(string), "You have set \"%s's\" weather to '%d", pName(player1), weather); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has set your weather to '%d'", pName(playerid), weather); SendClientMessage(player1,blue,string); }
			SetPlayerWeather(player1,weather); PlayerPlaySound(player1,1057,0.0,0.0,0.0);
   			return PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_settime(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 3) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "USAGE: /settime [playerid] [hour]");
		new player1 = strval(tmp), time = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"SETTIME");
			format(string, sizeof(string), "You have set \"%s's\" time to %d:00", pName(player1), time); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has set your time to %d:00", pName(playerid), time); SendClientMessage(player1,blue,string); }
			PlayerPlaySound(player1,1057,0.0,0.0,0.0);
   			return SetPlayerTime(player1, time, 0);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_setworld(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 3) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setworld [playerid] [virtual world]");
		new player1 = strval(tmp), time = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"SETWORLD");
			format(string, sizeof(string), "You have set \"%s's\" virtual world to '%d'", pName(player1), time); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has set your virtual world to '%d' ", pName(playerid), time); SendClientMessage(player1,blue,string); }
			PlayerPlaySound(player1,1057,0.0,0.0,0.0);
   			return SetPlayerVirtualWorld(player1, time);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_setinterior(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 3) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setinterior [playerid] [interior]");
		new player1 = strval(tmp), time = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"SETINTERIOR");
			format(string, sizeof(string), "You have set \"%s's\" interior to '%d' ", pName(player1), time); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has set your interior to '%d' ", pName(playerid), time); SendClientMessage(player1,blue,string); }
			PlayerPlaySound(player1,1057,0.0,0.0,0.0);
   			return SetPlayerInterior(player1, time);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_setmytime(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 0) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /setmytime [hour]");
		new time = strval(params), string[128];
		format(string,sizeof(string),"You have set your time to %d:00", time); SendClientMessage(playerid,blue,string);
		return SetPlayerTime(playerid, time, 0);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_setmyweather(playerid,params[])
{
    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /setmyweather [weather ID]");
    new var = strval(params), string[128];
    PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
    SetPlayerWeather(playerid, var);
    format(string,sizeof(string),"You have set your weather to '%d'", var);
    return SendClientMessage(playerid,blue, string);
}

dcmd_force(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 3) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /force [playerid]");
		new player1 = strval(params), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"FORCE");
			if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has forced you into class selection", pName(playerid) ); SendClientMessage(player1,blue,string); }
			format(string,sizeof(string),"You have forced \"%s\" into class selection", pName(player1)); SendClientMessage(playerid,blue,string);
			ForceClassSelection(player1);
			return SetPlayerHealth(player1,0.0);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_eject(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 3) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /eject [playerid]");
		new player1 = strval(params), string[128], Float:x, Float:y, Float:z;
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			if(IsPlayerInAnyVehicle(player1)) {
				new vehicle;
                CMDMessageToAdmins(playerid,"EJECT");
				if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has ejected you from your vehicle", pName(playerid) ); SendClientMessage(player1,blue,string); }
				format(string,sizeof(string),"You have ejected \"%s\" from their vehicle", pName(player1)); SendClientMessage(playerid,blue,string);
    		   	GetPlayerPos(player1,x,y,z);
				vehicle = GetPlayerVehicleID(player1);
			    RemovePlayerFromVehicle(player1);
				DestroyVehicle(vehicle);
				RemovePlayerFromVehicle(player1);
				return SetPlayerPos(player1,x,y,z+3);
			} else return SendClientMessage(playerid,red,"ERROR: Player is not in a vehicle");
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_lockcar(playerid,params[])
{
	#pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
	    if(IsPlayerInAnyVehicle(playerid)) {
		 	for(new i = 0; i < MAX_PLAYERS; i++) SetVehicleParamsForPlayer(GetPlayerVehicleID(playerid),i,false,true);
			CMDMessageToAdmins(playerid,"LOCKCAR");
			PlayerInfo[playerid][DoorsLocked] = 1;
			new string[128]; format(string,sizeof(string),"Administrator \"%s\" has locked his car", pName(playerid));
			return SendClientMessageToAll(blue,string);
		} else return SendClientMessage(playerid,red,"ERROR: You need to be in a vehicle to lock the doors");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_unlockcar(playerid,params[])
{
	#pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
	    if(IsPlayerInAnyVehicle(playerid)) {
		 	for(new i = 0; i < MAX_PLAYERS; i++) SetVehicleParamsForPlayer(GetPlayerVehicleID(playerid),i,false,false);
			CMDMessageToAdmins(playerid,"UNLOCKCAR");
			PlayerInfo[playerid][DoorsLocked] = 0;
			new string[128]; format(string,sizeof(string),"Administrator \"%s\" has unlocked his car", pName(playerid));
			return SendClientMessageToAll(blue,string);
		} else return SendClientMessage(playerid,red,"ERROR: You need to be in a vehicle to lock the doors");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_burn(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 2) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /burn [playerid]");
		new player1 = strval(params), string[128], Float:x, Float:y, Float:z;
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"BURN");
			format(string, sizeof(string), "You have burnt \"%s\" ", pName(player1)); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has burnt you", pName(playerid)); SendClientMessage(player1,blue,string); }
			GetPlayerPos(player1, x, y, z);
			return CreateExplosion(x, y , z + 3, 1, 10);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_spawnplayer(playerid,params[])
{
	return dcmd_spawn(playerid,params);
}

dcmd_spawn(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 2) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /spawn [playerid]");
		new player1 = strval(params), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"SPAWN");
			format(string, sizeof(string), "You have spawned \"%s\" ", pName(player1)); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has spawned you", pName(playerid)); SendClientMessage(player1,blue,string); }
			SetPlayerPos(player1, 0.0, 0.0, 0.0);
			return SpawnPlayer(player1);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_disarm(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 2 || PlayerInfo[playerid][pVip] >= 3) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /disarm [playerid]");
		new player1 = strval(params), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"DISARM");  PlayerPlaySound(player1,1057,0.0,0.0,0.0);
			format(string, sizeof(string), "You have disarmed \"%s\" ", pName(player1)); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Admin/VIP \"%s\" has disarmed you", pName(playerid)); SendClientMessage(player1,blue,string); }
            SetPVarInt(player1, "AdminGivenMini", 0);
			ResetPlayerWeapons(player1);
			return PlayerPlaySound(player1,1057,0.0,0.0,0.0);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_vips(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][LoggedIn] == 1)
	{
		if(PlayerInfo[playerid][Level] >= 0)
		{
	 		new bool:First2 = false;
	 		new Count, i;
		    new string[128];
			new adminname[MAX_PLAYER_NAME];
		    for(i = 0; i < MAX_PLAYERS; i++)
			if(IsPlayerConnected(i) && PlayerInfo[i][pVip] > 0)
			Count++;
			if(Count == 0)
			return SendClientMessage(playerid,yellow, "No VIP's are online. See /admins.");
		    for(i = 0; i < MAX_PLAYERS; i++)
			if(IsPlayerConnected(i) && PlayerInfo[i][pVip] > 0)
			{
				if(PlayerInfo[i][pVip] > 0)
				{
					switch(PlayerInfo[i][pVip])
    				{
					case 1: Vip = "{C0C0C0}Silver{FFFF00}";
					case 2: Vip = "{FFFF00}Gold{FFFF00}";
					case 3: Vip = "{0000FF}Platinum{FFFF00}";
					case 4: Vip = "{00FF00}Permanent{FFFF00}";
					}
				}
 				GetPlayerName(i, adminname, sizeof(adminname));
				if(!First2)
				{
					format(string, sizeof(string), "{FFFF00}VIP's: %s [%s]", PlayerName2(i),Vip);
					First2 = true;
				}
   					else format(string,sizeof(string),"%s, %s [%s],",string, PlayerName2(i),Vip);
	        }
		    return SendClientMessage(playerid,yellow,string);
		}
		else return SendClientMessage(playerid,red,"ERROR: You need to be a high admin to use this command");
	}
	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_remwarn(playerid,params[])
{
	#pragma unused params
    if(PlayerInfo[playerid][Level] >= 2 || PlayerInfo[playerid][pVip] >= 2)
    {
       new str[128], tmp[256], warned = strval(tmp), Index;    tmp = strtok(params,Index);
	   if(sscanf(params, "u", warned)) return
       SendClientMessage(playerid, red, "Usage: /remwarn [playerid]");
       if(PlayerInfo[warned][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel])
       return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
       if(IsPlayerConnected(warned) && warned != INVALID_PLAYER_ID)
       {
       if(warned != playerid)
       {
       if(PlayerInfo[warned][Warnings] >= 0)
       {
	   PlayerInfo[warned][Warnings]--;
       format(str, sizeof (str), "*Admin/VIP \"%s\" has Removed \"%s\"'s Warning.(Warnings: %d/%d).", pName(playerid), pName(warned), PlayerInfo[warned][Warnings], MAX_WARNINGS);
       return SendClientMessageToAll(yellow, str);
       }
       else return SendClientMessage(playerid,red,"Error: Player Already Have 0 warns");
       }
       else return SendClientMessage(playerid,red,"ERROR: You cannot remove yourselves warning");
       }
       else return SendClientMessage(playerid, red, "ERROR: Player is not connected");
    }
    else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_setvip(playerid,params[])
{
 if(PlayerInfo[playerid][LoggedIn] == 1)
	{
		if(PlayerInfo[playerid][Level] >= 5 || IsPlayerAdmin(playerid))
		{
		    new tmp[256], tmp2[256], Index, file[267];
			tmp  = strtok(params,Index); tmp2 = strtok(params,Index);
		    if(!strlen(params)) return
   			SendClientMessage(playerid, red, "Usage: /setvip [Playerid] [1 - 3] ");
	    	new player1, type, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);
			if(!strlen(tmp2)) return
			SendClientMessage(playerid, red, "Usage: /setvip [Playerid] [1 - 3]");
			type = strval(tmp2);
           	GetPlayerName(playerid,playername,sizeof(playername));
			format(file,sizeof(file),"ladmin/users/%s.sav",playername);
			if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID)
			{
				if(PlayerInfo[player1][LoggedIn] == 1)
				{
				if(type > 4)
				return SendClientMessage(playerid,red,"ERROR: Invalid Account Type!");
				if(type == PlayerInfo[player1][pVip])
				return SendClientMessage(playerid,red,"ERROR: Player is already have this Account Type!");
				GetPlayerName(player1, playername, sizeof(playername)); GetPlayerName(playerid, adminname, sizeof(adminname));
		       	new year,month,day, hour,minute,second;
		  		getdate(year, month, day); gettime(hour,minute,second);
 				switch(type)
				{
					case 1: Vip = "{EBEBEB}Silver";
					case 2: Vip = "{FFFF00}Gold";
					case 3: Vip = "{0000FF}Platinum";
					case 4: Vip = "{00FF00}Permanent";
				}
				if(type > 0)
				format(string,sizeof(string),"Administrator %s has set your Account Type to: %s",adminname,Vip);
				else
				format(string,sizeof(string),"Administrator %s has set your Account Type to: 'Normal Account!",adminname);
				SendClientMessage(player1,blue,string);
				dUserSetINT(PlayerName2(player1)).("AccountType",(type));
				if(type > PlayerInfo[player1][pVip])
				GameTextForPlayer(player1,"Promoted", 2000, 3);
				else GameTextForPlayer(player1,"Demoted", 2000, 3);
				format(string,sizeof(string),"You have given %s Account Type: %s on '%d/%d/%d' at '%d:%d:%d'", playername, Vip, day, month, year, hour, minute, second);
				SendClientMessage(playerid,blue,string);
				PlayerInfo[player1][pVip] = type;
				if(type == 2) { TimeVIP[player1] = dUserSetINT(PlayerName2(player1)).("VIPTime",(30)); }
                if(type == 3) { TimeVIP[player1] = dUserSetINT(PlayerName2(player1)).("VIPTime",(30)); }
				SavePlayer(player1);
			    return PlayerPlaySound(player1,1057,0.0,0.0,0.0);
				}
				else return SendClientMessage(playerid,red,"ERROR: This player is not Registred or Logged!");
			}
			else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
		}
		else return SendClientMessage(playerid,red,"ERROR: You are not a high enough Admin to use this command");
	}
 	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_crash(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 5) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /crash [playerid]");
		new player1 = strval(params), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
   			CMDMessageToAdmins(playerid,"CRASH");
		    GameTextForPlayer(player1, "•¤¶§!$$%&'()*+,-./01~!@#$^&*()_-+={[}]:;'<,>.?/", 1000, 0);
		    GameTextForPlayer(player1, "•¤¶§!$$%&'()*+,-./01~!@#$^&*()_-+={[}]:;'<,>.?/", 2000, 1);
		    GameTextForPlayer(player1, "•¤¶§!$$%&'()*+,-./01~!@#$^&*()_-+={[}]:;'<,>.?/", 3000, 2);
		    GameTextForPlayer(player1, "•¤¶§!$$%&'()*+,-./01~!@#$^&*()_-+={[}]:;'<,>.?/", 4000, 3);
		    GameTextForPlayer(player1, "•¤¶§!$$%&'()*+,-./01~!@#$^&*()_-+={[}]:;'<,>.?/", 5000, 4);
		    GameTextForPlayer(player1, "•¤¶§!$$%&'()*+,-./01~!@#$^&*()_-+={[}]:;'<,>.?/", 6000, 5);
		    GameTextForPlayer(player1, "•¤¶§!$$%&'()*+,-./01~!@#$^&*()_-+={[}]:;'<,>.?/", 7000, 6);
		    GameTextForPlayer(player1, "•¤¶§!$$%&'()*+,-./01~!@#$^&*()_-+={[}]:;'<,>.?/", 12000, 6);
			format(string, sizeof(string), "You have crashed \"%s's\" game", pName(player1));
			return SendClientMessage(playerid,blue, string);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_ip(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 1) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /ip [playerid]");
		new player1 = strval(params), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"IP");
			new tmp3[50]; GetPlayerIp(player1,tmp3,50);
			format(string,sizeof(string),"\"%s's\" ip is '%s'", pName(player1), tmp3);
			return SendClientMessage(playerid,blue,string);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_vsay(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][pVip] >= 1 || PlayerInfo[playerid][Level] >= 1)
	{
 		if(!strlen(params)) return
		SendClientMessage(playerid, red, "{FF0000}Usage: /vsay [Text]");
		new string[128];
		format(string, sizeof(string), "**VIP %s: %s", PlayerName2(playerid), params[0]);
		return SendClientMessageToAll(yellow,string);
	}
	else return SendClientMessage(playerid,red,"ERROR: You need to be VIP to use this command");
}
dcmd_scorelist(playerid, params[])
{
        #pragma unused params
		if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 1) {
        new string[128], Slot1 = -1, Slot2 = -1, Slot3 = -1, Slot4 = -1, HighestScore = -2147483648;
		SendClientMessage(playerid, COLOR_WHITE, "Top Score:");
		for(new x=0; x<MAX_PLAYERS; x++)
		if(IsPlayerConnected(x))
		if(GetPlayerScore(x) >= HighestScore)
		{
			HighestScore = GetPlayerScore(x);
			Slot1 = x;
		}
		HighestScore = -2147483648;
		for(new x=0; x<MAX_PLAYERS; x++)
		if(IsPlayerConnected(x) && x != Slot1)
		if(GetPlayerScore(x) >= HighestScore)
		{
			HighestScore = GetPlayerScore(x);
			Slot2 = x;
		}
		HighestScore = -2147483648;
		for(new x=0; x<MAX_PLAYERS; x++)
		if(IsPlayerConnected(x) && x != Slot1 && x != Slot2)
		if(GetPlayerScore(x) >= HighestScore)
		{
			HighestScore = GetPlayerScore(x);
			Slot3 = x;
		}
		HighestScore = -2147483648;
		for(new x=0; x<MAX_PLAYERS; x++)
		if(IsPlayerConnected(x) && x != Slot1 && x != Slot2 && x != Slot3)
		if(GetPlayerScore(x) >= HighestScore)
		{
			HighestScore = GetPlayerScore(x);
			Slot4 = x;
		}
		format(string, sizeof(string), "{FF9900}%s is having lead with %d points!", pName(Slot1),GetPlayerScore(Slot1));
		SendClientMessage(playerid, COLOR_WHITE, string);
		if(Slot2 != -1){
		format(string, sizeof(string), "{FF9900}%s is on second position with %d points!", pName(Slot2),GetPlayerScore(Slot2));
		SendClientMessage(playerid, COLOR_WHITE, string);
		}
		if(Slot3 != -1){
		format(string, sizeof(string), "{FF9900}%s is on third position with %d points!", pName(Slot3),GetPlayerScore(Slot3));
		SendClientMessage(playerid, COLOR_WHITE, string);
		}
		if(Slot4 != -1){
		format(string, sizeof(string), "{FF9900}%s is on fourth position with %d points!", pName(Slot4),GetPlayerScore(Slot4));
		SendClientMessage(playerid, COLOR_WHITE, string);
		}
	    } else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
		return 1;
}
dcmd_bankrupt(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 3) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /bankrupt [playerid]");
		new player1 = strval(params), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"BANKRUPT");
			format(string, sizeof(string), "You have reset \"%s's\" cash", pName(player1)); SendClientMessage(playerid,blue,string);
			if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has reset your cash'", pName(playerid)); SendClientMessage(player1,blue,string); }
   				return ResetPlayerMoneyEx(player1);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_lcredits(playerid,params[])
{
  #pragma unused params
  SendClientMessage(playerid,red,"TBS Admin System - Edited by Filipbg and FreAkeD!");
  return 1;
}
dcmd_ghostmode(playerid, params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 5 || (PlayerInfo[playerid][pVip] >= 1))
	{
		if(pInvincible[playerid])
		{
			DisableRemoteVehicleCollisions(playerid, 0);
			pInvincible[playerid] = false;
			SendClientMessage(playerid, COLOR_RED, "You have disabled the Ghost Mode.");
			}
			else
			{
			DisableRemoteVehicleCollisions(playerid, 1);
			pInvincible[playerid] = true;
			SendClientMessage(playerid, COLOR_GREEN, "You have enabled the Ghost Mode.");
			SendClientMessage(playerid, COLOR_WHITE, "You can now go through cars without them Ramming You!");
		}
	}
	return 1;
}
dcmd_sbankrupt(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 3) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /sbankrupt [playerid]");
		new player1 = strval(params), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"BANKRUPT");
			format(string, sizeof(string), "You have silently reset \"%s's\" cash", pName(player1)); SendClientMessage(playerid,blue,string);
   			return ResetPlayerMoneyEx(player1);
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_time(playerid,params[])
{
	#pragma unused params
	new string[64], hour,minuite,second; gettime(hour,minuite,second);
	format(string, sizeof(string), "~g~|~w~%d:%d~g~|", hour, minuite);
	return GameTextForPlayer(playerid, string, 5000, 1);
}

dcmd_ubound(playerid,params[])
{
 	if(PlayerInfo[playerid][Level] >= 3) {
		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /ubound [playerid]");
	    new string[128], player1 = strval(params);

	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"UBOUND");
			SetPlayerWorldBounds(player1, 9999.9, -9999.9, 9999.9, -9999.9 );
			format(string, sizeof(string), "Administrator %s has removed your world boundaries", PlayerName2(playerid)); if(player1 != playerid) SendClientMessage(player1,blue,string);
			format(string,sizeof(string),"You have removed %s's world boundaries", PlayerName2(player1));
			return SendClientMessage(playerid,blue,string);
		} else return SendClientMessage(playerid, red, "Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_lhelp(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][LoggedIn] && PlayerInfo[playerid][Level] >= 1) {
		SendClientMessage(playerid,blue,"[[[[[[TBS help]]]]]]");
		SendClientMessage(playerid,blue, "Account commands are: /register, /login, /changepass, /stats, /resetstats.  Also  /time, /report");
		SendClientMessage(playerid,blue, "There are 6 levels. Level 6 admins are immune from commands");
		SendClientMessage(playerid,blue, "The filterscript must be reloaded if you change gamemodes");
		}
	else if(PlayerInfo[playerid][LoggedIn] && PlayerInfo[playerid][Level] < 1) {
	 	SendClientMessage(playerid,green, "Your commands are: /register, /login, /report, /stats, /time, /changepass, /resetstats, /getid");
 	}
	else if(PlayerInfo[playerid][LoggedIn] == 0) {
 	SendClientMessage(playerid,green, "Your commands are: /time, /getid     (You are not logged in, log in for more commands)");
	} return 1;
}

dcmd_lcmds(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] > 5)
	{
	new bigstring[1000];
	strcat(bigstring, "{00FFFF}---= [ Most Useful Admin Commands ] ==---\n\
                       GENERAL: getinfo, lmenu, announce, write, miniguns, richlist, lspec(off), move, lweaps, adminarea, countdown, duel, giveweapon\n\
                       GENERAL: slap, burn, warn, kick, ban, explode, jail, freeze, mute, crash, ubound, agod, godcar, ping\n");
	strcat(bigstring, "GENERAL: setping, lockserver, enable/disable, setlevel, setinterior, givecar, jetpack, force, spawn\n\
                       VEHICLE: flip, fix, repair, lockcar, eject, ltc, car, lcar, lbike, lplane, lheli, lboat, lnos, cm\n\
                       TELE: goto, gethere, get, teleplayer, ltele, vgoto, lgoto, moveplayer\n");
	strcat(bigstring, "SET: set(cash/health/armour/gravity/name/time/weather/skin/colour/wanted/templevel)\n\
                       SETALL: setall(world/weather/wanted/time/score/cash)\n\
                       ALL: giveallweapon, healall, armourall, freezeall kickall, ejectall, killall, disarmall, slapall, spawnall");
    ShowPlayerDialog(playerid, DIALOG_LCMDS, DIALOG_STYLE_MSGBOX, "{00FFFF}::..::..::..>> TBS's Admin System LCmds <<..::..::..::", bigstring, "Close", "");
	}
	return 1;
}

dcmd_lcommands(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] > 5)
	{
		SendClientMessage(playerid,blue,"    ---= All Admin Commands =---");
		SendClientMessage(playerid,lightblue," /level1, /level2, /level3, /level4, /level5, /rcon ladmin");
		SendClientMessage(playerid,lightblue,"Player Commands: /register, /login, /report, /stats, /time, /changepass, /resetstats, /getid");
    }
    return 1;

}

dcmd_level1(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1)
	{
	new bigstring[1000];
	strcat(bigstring, "{00FFFF}ttag, kick, jail, unjail, mute, unmute, freeze, unfreeze, aka, getip, warn, slap, jailed, frozen, muted, goto;\n\
					   adminarea2, hide, unhide, myarmour, getinfo, weaps, vr, repair, ltune, lhy, lnos, lp, asay, ping, lslowmo, ltc, jetpack;\n");
	strcat(bigstring, "chatcolor, morning, adminarea, reports, richlist, miniguns, saveplacae, gotoplace, vgoto, lgoto, lspecvehicle;\n\
                       lspec, lspecoff, saveskin, useskin, dontuseskin, setmytime, ip, lconfig, givecar, rhino, hydra, hunter, giveallcookie, giveallbrownie;");
    ShowPlayerDialog(playerid, DIALOG_LEVEL1, DIALOG_STYLE_MSGBOX, "{00FFFF}..::..::..::>>{00FFFF}TBS's Admin System {FF0000}Trial Moderator{00FFFF} {00FFFF}Commands <<..::..::..::", bigstring, "Close", "");
	}
	else return SendClientMessage(playerid, red, "ERROR: You are not Level 1 [{FF0000}Trial Moderator{FF0000}] to use this command!");
	return 1;
}

dcmd_level2(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2)
	{
	new bigstring[1000];
	strcat(bigstring, "{FF0000}also you can use 1 level Commands!\n\
					   {00FFFF}mtag, clearchat(/cc), cleardeathlog(/cdl), musicall, songall, stopmusicall;\n\
                       fly, flyoff, car, caps, armour, giveweapon burn;\n");
    strcat(bigstring, "lheli, lboat, lplane, announce, announce2, screen, spawn, disarm, lockcar, unlockcar;\n\
					   cityall, freshall, njoyall, trapall, tbsall, superjump, setcolour;\n\
					   laston, ltele, cm, ltmenu, write, fu, lcar, lbike, akill, flip hightlight;");
    ShowPlayerDialog(playerid, DIALOG_LEVEL2, DIALOG_STYLE_MSGBOX, "{00FFFF}::..::..::..>> TBS's Admin System {FF0000}Moderator{00FFFF} {00FFFF}Commands <<..::..::..::", bigstring, "Close", "");
	}
	else return SendClientMessage(playerid, red, "ERROR: You are not Level 2 [{FF0000}Moderator{00FFFF}] to use this command!");
	return 1;
}
dcmd_level3(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 3)
	{
	new bigstring[1000];
	strcat(bigstring, "{FF0000}also you can use 2 level Commands!\n\
                       {00FFFF}coatag, ban, checkban, clearplayerchat(cpc) sethealth, setarmour, setskin ,setwanted;\n\
                       setweather, settime, setworld, setinterior, force, eject, bankrupt, sbankrupt, ubound;\n");
    strcat(bigstring, "lweaps, lammo, countdown, carhealth, setcarcolor, setping, destroycar;\n\
                       gotomb, startmb, togglemb, moneybag, gotocj, startcj, togglecj, cookiejar;\n\
                       givegod, takegod,godcar, aka, move, moveplayer, get, explode, givebrownies;\n\
                       givecookies, giveallweapon, lweather, ltime, lweapons, teleplayer, vget, gethere;");
    ShowPlayerDialog(playerid, DIALOG_LEVEL3, DIALOG_STYLE_MSGBOX, "{00FFFF}::..::..::..>> TBS's Admin System {FF0000}Administrator {00FFFF}Commands <<..::..::..::", bigstring, "Close", "");
	}
	else return SendClientMessage(playerid, red, "ERROR: You are not Level 3 [{FF0000}Administrator{FF0000}] to use this command!");
	return 1;
}
dcmd_level4(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 4)
	{
	new bigstring[1000];
	strcat(bigstring, "{FF0000}also you can use 3 level Commands!\n\
                       {00FFFF}atag, tbstag, botsay, enable/disable, rban, oban, ounban spam, die, uconfig;\n\
                       armourall, setallskin, setallwanted, setallweather, setalltime, setallworld;\n");
    strcat(bigstring, "botcheck, forbidname, forbidword, setname, setpass, enablepm/disablepm;\n\
                       muteall, unmuteall, getall, killall, freezeall, actor;\n");
    strcat(bigstring, "arespawn, drespawn, unfreezeall, slapalll, explodeall, disarmall, ejectall;\n");
    ShowPlayerDialog(playerid, DIALOG_LEVEL4, DIALOG_STYLE_MSGBOX, "{00FFFF}::..::..>> TBS's Admin System {00FF00}Senior Administrator{00FF00} {00FFFF}Commands <<..::..::", bigstring, "Close", "");
	}
    else return SendClientMessage(playerid, red, "ERROR: You are not Level 4 [{00FF00}Senior Administrator{00FF00}] to use this command");
	return 1;

}
dcmd_level5(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 5)
	{
	new bigstring[1000];
	strcat(bigstring, "{FF0000}Also you can use 1,2,3,4 Levels Commands!\n\
                      /lsetlevel, /settemplevel - Promotes/Demotes Administators\n\
                      {FF0000}/Ltag, /sban only for big ban evaders, be carefull when you're using it!\n");
    strcat(bigstring, "{FF0000}/banip, /unbanip /setvip, /vdemote, /vpromote(l), /orban, /runban, /setgravity\n\
                      {FF0000}/lmenu, /sbon, /sboff, /dmtime /dmtimeo, /fakechat, /fakedeath, /fakecmd;\n\
                      {00FFFF}sgod, testban, givescore, givecash, burnall, spawnall, giveallcookie, seths, gotohs, orespawn;\n");
    strcat(bigstring, "{00FFFF}setkills, setdeaths, setokills, setodeaths, sethours, setminutes, setohours, setominutes, crash;\n\
                       {00FFFF}/(create/remove/sell)house, /ghcmds, /(create/del)business;");
	ShowPlayerDialog(playerid, DIALOG_LEVEL5, DIALOG_STYLE_MSGBOX, "{00FFFF}::..::..::..>> TBS's Admin System {0049FF}Head Administrator {00FFFF}Commands <<..::..::..::", bigstring, "Close", "");
	}
    else return SendClientMessage(playerid, red, "ERROR: You are not Level 5 [{0049FF}Head Administrator{FF0000}] to use this command");
	return 1;
}
dcmd_level6(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 6)
	{
	new bigstring[1000];
	strcat(bigstring, "{FF0000}Also you can use 1,2,3,4 and 5 Levels Commands!\n\
                       ceotag, setlevel, apromotel, mdemote, saveallstats, djpromote, djdemote, setdj;\n\
                       ceoarea, lockserver, unlockserver, mapname, hostname, gmtext, object;\n");
	strcat(bigstring, "removeaccount, console, apromote, ademote, setscore, setcash, giveallcash\n\
                       giveallcookie, setallscore, setallcash, giveallscore, kickall, pickup;\n\
                       RCON cmds: /stoprace, /cancelbuild, /buildrace;");
    ShowPlayerDialog(playerid, DIALOG_LEVEL4, DIALOG_STYLE_MSGBOX, "{00FFFF}::..::..::..>> TBS's Admin System {0049FF}Manager/CEO{00FFFF} {00FFFF}Commands <<..::..::..::", bigstring, "Close", "");
	}
	else return SendClientMessage(playerid, red, "ERROR: You are not Level 6 [{0049FF}Manager/CEO{FF0000}] to use this command");
	return 1;
}

dcmd_acmds(playerid, params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1)
	{
	new bigstring[1000];
 	strcat(bigstring, "{00FFFF}Level 1 {FF0000}Trial Moderator{FF0000} {00FFFF}CMDS: /level1\n\
                       {00FFFF}Level 2 {FF0000}Moderator{FF0000} {00FFFF}CMDS: /level2\n\
                       {00FFFF}Level 3 {FF0000}Administrator{FF0000} {00FFFF}CMDS: /level3\n");
    strcat(bigstring, "{00FFFF}Level 4 {00FF00}Senior Administrator{00FF00} {00FFFF}CMDS: /level4\n\
                       {00FFFF}Level 5 {0049FF}Head Administrator{FF0000} {00FFFF}CMDS: /level5\n\
                       {00FFFF}Level 6 {0049FF}Manager/CEO{FF0000} {00FFFF}CMDS: /level6");
    ShowPlayerDialog(playerid, DIALOG_ACMDS, DIALOG_STYLE_MSGBOX, "{00FFFF}> TBS's Admin System <", bigstring, "Close", "");
	} else return SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}

dcmd_lconfig(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1)
	{
	    new string[128];
		SendClientMessage(playerid,blue,"    ---=== TBS Admin System Configuration ===---");
		format(string, sizeof(string), "Max Ping: %dms | ReadPms %d | ReadCmds %d | Max Admin Level %d | AdminOnlySkins %d", ServerInfo[MaxPing],  ServerInfo[ReadPMs],  ServerInfo[ReadCmds],  ServerInfo[MaxAdminLevel],  ServerInfo[AdminOnlySkins] );
		SendClientMessage(playerid,blue,string);
		format(string, sizeof(string), "AdminSkin1 %d | AdminSkin2 %d | NameKick %d | AntiBot %d | AntiSpam %d | AntiSwear %d", ServerInfo[AdminSkin], ServerInfo[AdminSkin2], ServerInfo[NameKick], ServerInfo[AntiBot], ServerInfo[AntiSpam], ServerInfo[AntiSwear] );
		SendClientMessage(playerid,blue,string);
		format(string, sizeof(string), "NoCaps %d | Locked %d | Pass %s | SaveWeaps %d | SaveMoney %d | ConnectMessages %d | AdminCmdMsgs %d", ServerInfo[NoCaps], ServerInfo[Locked], ServerInfo[Password], ServerInfo[GiveWeap], ServerInfo[GiveMoney], ServerInfo[ConnectMessages], ServerInfo[AdminCmdMsg] );
		SendClientMessage(playerid,blue,string);
		format(string, sizeof(string), "AutoLogin %d | MaxMuteWarnings %d | ChatDisabled %d | MustLogin %d | MustRegister %d", ServerInfo[AutoLogin], ServerInfo[MaxMuteWarnings], ServerInfo[DisableChat], ServerInfo[MustLogin], ServerInfo[MustRegister] );
		SendClientMessage(playerid,blue,string);
	}
	return 1;
}
dcmd_vcmds(playerid,params[])
    #pragma unused params
{
        new msg3[1000];
        new msg[] = "Welcome to VIP Commands\n{E9E9E9}Silver:\n/goto, /richlist, /scorelist, /vtag, /jetpack, /flip, /vsay, /jailed, /frozen, /morning, /muted, /miniguns;\n\n{FFFF00}Gold:\n/jail, /unjail, /mute, /unmute, /freeze, /unfreeze, /myarmour, /vweaps, /ping,";
        new msg2[] = " /warn, /remwarn, /lspec - /lspecoff, /viparea, /vipfunland;\n\n{0000FF}Platinum:\n/kick, /ltime, /lweather, /chatcolor, /moveplayer, /fly - /flyoff, /armour, /vgod, /reports, /move, /rhino, /hydra, /hunter, /disarm, /announce2;\n\n{00FF00}Permanent: All VIP Commands and Features + valid for life!\n\n{C0C0C0}Info: Gold VIP and Platinum VIP Are Valid for 30 days!\n\n\n{FF0000} All VIP's have VIP chat with ' ` ' and /vipmenu\n\n Thank you and enjoy your stay in TBS!";
        format(msg3, sizeof(msg3), "%s %s", msg, msg2);
        ShowPlayerDialog(playerid,99,DIALOG_STYLE_MSGBOX," {0000FF}TBS's{0000FF} {FFFF00}VIP Cmds{FFFF00} {00FF00}[Access Granted]{00FF00} ",msg3,"Close", "");
        return 1;
}
dcmd_adminarea1(playerid,params[])
{
        #pragma unused params
		if(PlayerInfo[playerid][Level] >= 1)
	    {
			
			SetPlayerPos(playerid, 245.2130,1859.8983,14.0840);
			SendClientMessage(playerid, COLOR_RED, "Welcome to the Admin Hangout!");
			return 1;
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
		    return 1;
		}
}
dcmd_adminarea2(playerid,params[])
{
        #pragma unused params
		if(PlayerInfo[playerid][Level] >= 1)
	    {
			
			SetPlayerPos(playerid, 299.7066,1765.0406,524.8790);
			SendClientMessage(playerid, COLOR_RED, "Welcome to the Admin Office!");
			return 1;
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
		    return 1;
		}
}
dcmd_djarea(playerid,params[])
{
        #pragma unused params
		if(PlayerInfo[playerid][isDJ] >= 1)
	    {
			
			SetPlayerPos(playerid, 411.1443,-1620.2251,1507.8569);
			SendClientMessage(playerid, COLOR_RED, "Welcome to the DJ Hangout!");
			return 1;
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
		    return 1;
		}
}
dcmd_ceoarea(playerid,params[])
{
        #pragma unused params
		if(PlayerInfo[playerid][Level] >= 6)
	    {
			
			SetPlayerPos(playerid, 1542.7935,-1398.0377,7820.9141);
			SendClientMessage(playerid, COLOR_RED, "Welcome to the CEO Hangout!");
			return 1;
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
		    return 1;
		}
}
dcmd_filiphome(playerid,params[])
{
        #pragma unused params
		if(PlayerInfo[playerid][Level] >= 5)
	    {
			
			SetPlayerPos(playerid, 142.8452,1612.4064,1201.3667);
			SendClientMessage(playerid, COLOR_RED, "Welcome to CEO Filipbg's House.");
  		}
		return 1;
}
dcmd_viparea(playerid,params[])
{
        #pragma unused params
		if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 2)
	    {
			
			SetPlayerPos(playerid, 1341.4557,1252.3799,10.8203);
			SendClientMessage(playerid, COLOR_RED, "Welcome to the VIP Hangout!");
			return 1;
		}
		else
		{
			SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
		    return 1;
		}
}
dcmd_vipfunland(playerid,params[])
{
        #pragma unused params
		if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 2)
	    {
			
			SetPlayerPos(playerid, -79.7804,3499.9863,5.3077);
			SendClientMessage(playerid, COLOR_RED, "Welcome to the VIP Fun Land!");
			return 1;
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_getinfo(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 1 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid,red,"USAGE: /getinfo [playerid]");
	    new player1, string[128];
	    player1 = strval(params);
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		    new Float:player1health, Float:player1armour, playerip[128], Float:x, Float:y, Float:z, tmp2[256], file[256],
				year, month, day, P1Jailed[4], P1Frozen[4], P1Logged[4], P1Register[4], RegDate[256], TimesOn;
			GetPlayerHealth(player1,player1health);
			GetPlayerArmour(player1,player1armour);
	    	GetPlayerIp(player1, playerip, sizeof(playerip));
	    	GetPlayerPos(player1,x,y,z);
			getdate(year, month, day);
			format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(PlayerName2(player1)));
			if(PlayerInfo[player1][Jailed] == 1) P1Jailed = "Yes"; else P1Jailed = "No";
			if(PlayerInfo[player1][Frozen] == 1) P1Frozen = "Yes"; else P1Frozen = "No";
			if(PlayerInfo[player1][LoggedIn] == 1) P1Logged = "Yes"; else P1Logged = "No";
			if(fexist(file)) P1Register = "Yes"; else P1Register = "No";
			if(dUserINT(PlayerName2(player1)).("LastOn")==0) tmp2 = "Never"; else tmp2 = dini_Get(file,"LastOn");
			if(strlen(dini_Get(file,"RegisteredDate")) < 3) RegDate = "n/a"; else RegDate = dini_Get(file,"RegisteredDate");
			TimesOn = dUserINT(PlayerName2(player1)).("TimesOnServer");
		    new Sum, Average, w;
			while (w < PING_MAX_EXCEEDS) {
				Sum += PlayerInfo[player1][pPing][w];
				w++;
			}
			Average = (Sum / PING_MAX_EXCEEDS);
	  		format(string, sizeof(string),"(Player Info)  ---====> Name: %s  ID: %d <====---", PlayerName2(player1), player1);
			SendClientMessage(playerid,lightblue,string);
		  	format(string, sizeof(string),"Health: %d  Armour: %d  Score: %d  Cash: %d  Skin: %d  IP: %s  Ping: %d  Average Ping: %d",floatround(player1health),floatround(player1armour),
			GetPlayerScore(player1),GetPlayerMoneyEx(player1),GetPlayerSkin(player1),playerip,GetPlayerPing(player1), Average);
			SendClientMessage(playerid,red,string);
			format(string, sizeof(string),"Interior: %d  Virtual World: %d  Wanted Level: %d  X %0.1f  Y %0.1f  Z %0.1f", GetPlayerInterior(player1), GetPlayerVirtualWorld(player1), GetPlayerWantedLevel(player1), Float:x,Float:y,Float:z);
			SendClientMessage(playerid,orange,string);
			format(string, sizeof(string),"Times On Server: %d  Kills: %d  Deaths: %d  Ratio: %0.2f  AdminLevel: %d", TimesOn, Killsp[playerid], Deathsp[playerid], Float:Killsp[playerid]/Float:Deathsp[playerid], PlayerInfo[player1][Level] );
			SendClientMessage(playerid,yellow,string);
			format(string, sizeof(string),"Registered: %s  Logged In: %s  In Jail: %s  Frozen: %s", P1Register, P1Logged, P1Jailed, P1Frozen );
			SendClientMessage(playerid,green,string);
			format(string, sizeof(string),"Last On Server: %s  Register Date: %s  Todays Date: %d/%d/%d", tmp2, RegDate, day,month,year );
			SendClientMessage(playerid,COLOR_GREEN,string);
			if(IsPlayerInAnyVehicle(player1)) {
				new Float:VHealth, carid = GetPlayerVehicleID(playerid); GetVehicleHealth(carid,VHealth);
				format(string, sizeof(string),"VehicleID: %d  Model: %d  Vehicle Name: %s  Vehicle Health: %d",carid, GetVehicleModel(carid), VehicleNames[GetVehicleModel(carid)-400], floatround(VHealth) );
				SendClientMessage(playerid,COLOR_BLUE,string);
			}
			new slot, ammo, weap, Count, WeapName[24], WeapSTR[128], p; WeapSTR = "Weaps: ";
			for (slot = 0; slot < 14; slot++) {	GetPlayerWeaponData(player1, slot, weap, ammo); if( ammo != 0 && weap != 0) Count++; }
			if(Count < 1) return SendClientMessage(playerid,lightblue,"Player has no weapons");
			else {
				for (slot = 0; slot < 14; slot++)
				{
					GetPlayerWeaponData(player1, slot, weap, ammo);
					if (ammo > 0 && weap > 0)
					{
						GetWeaponName(weap, WeapName, sizeof(WeapName) );
						if (ammo == 65535 || ammo == 1) format(WeapSTR,sizeof(WeapSTR),"%s%s (1)",WeapSTR, WeapName);
						else format(WeapSTR,sizeof(WeapSTR),"%s%s (%d)",WeapSTR, WeapName, ammo);
						p++;
						if(p >= 5) { SendClientMessage(playerid, lightblue, WeapSTR); format(WeapSTR, sizeof(WeapSTR), "Weaps: "); p = 0;
						} else format(WeapSTR, sizeof(WeapSTR), "%s,  ", WeapSTR);
					}
				}
				if(p <= 4 && p > 0) {
					string[strlen(string)-3] = '.';
				    SendClientMessage(playerid, lightblue, WeapSTR);
				}
			}
			return 1;
		} else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_disable(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 4 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) {
			SendClientMessage(playerid,red,"USAGE: /disable [antiswear / namekick / antispam / ping / readcmds / readpms /caps / admincmdmsgs");
			return SendClientMessage(playerid,red,"       /connectmsgs / autologin ]");
		}
	    new string[128], file[256]; format(file,sizeof(file),"ladmin/config/Config.ini");
		if(strcmp(params,"antiswear",true) == 0) {
			ServerInfo[AntiSwear] = 0;
			dini_IntSet(file,"AntiSwear",0);
			format(string,sizeof(string),"Administrator %s has disabled antiswear", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
		} else if(strcmp(params,"namekick",true) == 0) {
			ServerInfo[NameKick] = 0;
			dini_IntSet(file,"NameKick",0);
			format(string,sizeof(string),"Administrator %s has disabled namekick", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
	 	} else if(strcmp(params,"antispam",true) == 0)	{
			ServerInfo[AntiSpam] = 0;
			dini_IntSet(file,"AntiSpam",0);
			format(string,sizeof(string),"Administrator %s has disabled antispam", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
		} else if(strcmp(params,"ping",true) == 0)	{
			ServerInfo[MaxPing] = 0;
			dini_IntSet(file,"MaxPing",0);
			format(string,sizeof(string),"Administrator %s has disabled ping kick", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
		} else if(strcmp(params,"readcmds",true) == 0) {
			ServerInfo[ReadCmds] = 0;
			dini_IntSet(file,"ReadCMDs",0);
			format(string,sizeof(string),"Administrator %s has disabled reading commands", PlayerName2(playerid));
			MessageToAdmins(blue,string);
		} else if(strcmp(params,"readpms",true) == 0) {
			ServerInfo[ReadPMs] = 0;
			dini_IntSet(file,"ReadPMs",0);
			format(string,sizeof(string),"Administrator %s has disabled reading pms", PlayerName2(playerid));
			MessageToAdmins(blue,string);
  		} else if(strcmp(params,"caps",true) == 0)	{
			ServerInfo[NoCaps] = 1;
			dini_IntSet(file,"NoCaps",1);
			format(string,sizeof(string),"Administrator %s has prevented captial letters in chat", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
		} else if(strcmp(params,"admincmdmsgs",true) == 0) {
			ServerInfo[AdminCmdMsg] = 0;
			dini_IntSet(file,"AdminCMDMessages",0);
			format(string,sizeof(string),"Administrator %s has disabled admin command messages", PlayerName2(playerid));
			MessageToAdmins(green,string);
		} else if(strcmp(params,"connectmsgs",true) == 0)	{
			ServerInfo[ConnectMessages] = 0;
			dini_IntSet(file,"ConnectMessages",0);
			format(string,sizeof(string),"Administrator %s has disabled connect & disconnect messages", PlayerName2(playerid));
			MessageToAdmins(green,string);
		} else if(strcmp(params,"autologin",true) == 0)	{
			ServerInfo[AutoLogin] = 0;
			dini_IntSet(file,"AutoLogin",0);
			format(string,sizeof(string),"Administrator %s has disabled auto login", PlayerName2(playerid));
			MessageToAdmins(green,string);
		} else {
			SendClientMessage(playerid,red,"USAGE: /disable [antiswear / namekick / antispam / ping / readcmds / readpms /caps /cmdmsg ]");
		} return 1;
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_enable(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 4 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) {
			SendClientMessage(playerid,red,"USAGE: /enable [antiswear / namekick / antispam / ping / readcmds / readpms /caps / admincmdmsgs");
			return SendClientMessage(playerid,red,"       /connectmsgs / autologin ]");
		}
	    new string[128], file[256]; format(file,sizeof(file),"ladmin/config/Config.ini");
		if(strcmp(params,"antiswear",true) == 0) {
			ServerInfo[AntiSwear] = 1;
			dini_IntSet(file,"AntiSwear",1);
			format(string,sizeof(string),"Administrator %s has enabled antiswear", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
		} else if(strcmp(params,"namekick",true) == 0)	{
			ServerInfo[NameKick] = 1;
			format(string,sizeof(string),"Administrator %s has enabled namekick", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
 		} else if(strcmp(params,"antispam",true) == 0)	{
			ServerInfo[AntiSpam] = 1;
			dini_IntSet(file,"AntiSpam",1);
			format(string,sizeof(string),"Administrator %s has enabled antispam", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
		} else if(strcmp(params,"ping",true) == 0)	{
			ServerInfo[MaxPing] = 800;
			dini_IntSet(file,"MaxPing",800);
			format(string,sizeof(string),"Administrator %s has enabled ping kick", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
		} else if(strcmp(params,"readcmds",true) == 0)	{
			ServerInfo[ReadCmds] = 1;
			dini_IntSet(file,"ReadCMDs",1);
			format(string,sizeof(string),"Administrator %s has enabled reading commands", PlayerName2(playerid));
			MessageToAdmins(blue,string);
		} else if(strcmp(params,"readpms",true) == 0) {
			ServerInfo[ReadPMs] = 1;
			dini_IntSet(file,"ReadPMs",1);
			format(string,sizeof(string),"Administrator %s has enabled reading pms", PlayerName2(playerid));
			MessageToAdmins(blue,string);
		} else if(strcmp(params,"caps",true) == 0)	{
			ServerInfo[NoCaps] = 0;
			dini_IntSet(file,"NoCaps",0);
			format(string,sizeof(string),"Administrator %s has allowed captial letters in chat", PlayerName2(playerid));
			SendClientMessageToAll(blue,string);
		} else if(strcmp(params,"admincmdmsgs",true) == 0)	{
			ServerInfo[AdminCmdMsg] = 1;
			dini_IntSet(file,"AdminCmdMessages",1);
			format(string,sizeof(string),"Administrator %s has enabled admin command messages", PlayerName2(playerid));
			MessageToAdmins(green,string);
		} else if(strcmp(params,"connectmsgs",true) == 0) {
			ServerInfo[ConnectMessages] = 1;
			dini_IntSet(file,"ConnectMessages",1);
			format(string,sizeof(string),"Administrator %s has enabled connect & disconnect messages", PlayerName2(playerid));
			MessageToAdmins(green,string);
		} else if(strcmp(params,"autologin",true) == 0) {
			ServerInfo[AutoLogin] = 1;
			dini_IntSet(file,"AutoLogin",1);
			format(string,sizeof(string),"Administrator %s has enabled auto login", PlayerName2(playerid));
			MessageToAdmins(green,string);
		} else {
			SendClientMessage(playerid,red,"USAGE: /enable [antiswear / namekick / antispam / ping / readcmds / readpms /caps /cmdmsg ]");
		} return 1;
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_lweaps(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 3) {
		GivePlayerWeapon(playerid,28,1000); GivePlayerWeapon(playerid,31,1000); GivePlayerWeapon(playerid,34,1000);
		GivePlayerWeapon(playerid,38,1000); GivePlayerWeapon(playerid,16,1000);	GivePlayerWeapon(playerid,42,1000);
		GivePlayerWeapon(playerid,14,1000); GivePlayerWeapon(playerid,46,1000);	GivePlayerWeapon(playerid,9,1);
		GivePlayerWeapon(playerid,24,1000); GivePlayerWeapon(playerid,26,1000); SetPVarInt(playerid, "AdminGivenMini", 1); return 1;
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_countdown(playerid,params[])
{
	#pragma unused params
    if(PlayerInfo[playerid][Level] >= 3) {
        if(CountDown == -1) {
			CountDown = 6;
			SetTimer("countdown",1000,0);
			return CMDMessageToAdmins(playerid,"COUNTDOWN");
		} else return SendClientMessage(playerid,red,"ERROR: Countdown in progress");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_lammo(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 3) {
		MaxAmmo(playerid);
		return CMDMessageToAdmins(playerid,"LAMMO");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_vr(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1) {
		if (IsPlayerInAnyVehicle(playerid)) {
			SetVehicleHealth(GetPlayerVehicleID(playerid),1250.0);
			SetPVarInt(playerid, "VehicleRepair", 1);
			return SendClientMessage(playerid,blue,"Vehicle Fixed");
		} else return SendClientMessage(playerid,red,"Error: You are not in a vehicle");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_fix(playerid,params[])
{
    SetPVarInt(playerid, "VehicleRepair", 1);
	return dcmd_vr(playerid, params);
}

dcmd_repair(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1) {
		if (IsPlayerInAnyVehicle(playerid)) {
			GetPlayerPos(playerid,Pos[playerid][0],Pos[playerid][1],Pos[playerid][2]);
			GetVehicleZAngle(GetPlayerVehicleID(playerid), Pos[playerid][3]);
			SetPlayerCameraPos(playerid, 1929.0, 2137.0, 11.0);
			SetPlayerCameraLookAt(playerid,1935.0, 2138.0, 11.5);
			SetVehiclePos(GetPlayerVehicleID(playerid), 1974.0,2162.0,11.0);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), -90);
			SetTimerEx("RepairCar",5000,0,"i",playerid);
			SetPVarInt(playerid, "VehicleRepair", 1);
	    	return SendClientMessage(playerid,blue,"Your car will be ready in 5 seconds");
		} else return SendClientMessage(playerid,red,"Error: You are not in a vehicle");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_ltune(playerid,params[])
{
	#pragma unused params
	if(IsPlayerInAnyVehicle(playerid)) {
    new LVehicleID = GetPlayerVehicleID(playerid), LModel = GetVehicleModel(LVehicleID);
    switch(LModel)
	{
	case 448,461,462,463,468,471,509,510,521,522,523,581,586,449:
	return SendClientMessage(playerid,red,"ERROR: You can not tune this vehicle");
	}
	SetVehicleHealth(LVehicleID,2000.0);
	TuneLCar(LVehicleID);
	return PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
	} else return SendClientMessage(playerid,red,"Error: You are not in a vehicle");
}

dcmd_lhy(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
        new LVehicleID = GetPlayerVehicleID(playerid), LModel = GetVehicleModel(LVehicleID);
        switch(LModel)
		{
			case 448,461,462,463,468,471,509,510,521,522,523,581,586,449:
			return SendClientMessage(playerid,red,"ERROR: You can not tune this vehicle!");
		}
        AddVehicleComponent(LVehicleID, 1087);
		return PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
		} else return SendClientMessage(playerid,red,"Error: You are not in a vehicle");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_lcar(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2) {
		if (!IsPlayerInAnyVehicle(playerid)) {
			CarSpawner(playerid,415);
			CMDMessageToAdmins(playerid,"LCAR");
			return SendClientMessage(playerid,blue,"Enjoy your new car");
		} else return SendClientMessage(playerid,red,"Error: You already have a vehicle");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_bike(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 0) {
		if (!IsPlayerInAnyVehicle(playerid)) {
			CarSpawner(playerid,522);
			return SendClientMessage(playerid,blue,"Enjoy your new bike");
		} else return SendClientMessage(playerid,red,"Error: You already have a vehicle");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_lheli(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1) {
		if (!IsPlayerInAnyVehicle(playerid)) {
			CarSpawner(playerid,487);
			CMDMessageToAdmins(playerid,"LHELI");
			return SendClientMessage(playerid,blue,"Enjoy your new helicopter");
		} else return SendClientMessage(playerid,red,"Error: You already have a vehicle");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_lboat(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1) {
		if (!IsPlayerInAnyVehicle(playerid)) {
			CarSpawner(playerid,493);
			CMDMessageToAdmins(playerid,"LBOAT");
			return SendClientMessage(playerid,blue,"Enjoy your new boat");
		} else return SendClientMessage(playerid,red,"Error: You already have a vehicle");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_lplane(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1) {
		if (!IsPlayerInAnyVehicle(playerid)) {
			CarSpawner(playerid,513);
			CMDMessageToAdmins(playerid,"LPLANE");
			return SendClientMessage(playerid,blue,"Enjoy your new plane");
		} else return SendClientMessage(playerid,red,"Error: You already have a vehicle");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_lnos(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
	        switch(GetVehicleModel( GetPlayerVehicleID(playerid) )) {
				case 448,461,462,463,468,471,509,510,521,522,523,581,586,449:
				return SendClientMessage(playerid,red,"ERROR: You can not tune this vehicle!");
			}
	        AddVehicleComponent(GetPlayerVehicleID(playerid), 1010);
			return PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
		} else return SendClientMessage(playerid,red,"ERROR: You must be in a vehicle.");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_linkcar(playerid,params[])
{
	#pragma unused params
	if(IsPlayerInAnyVehicle(playerid)) {
    	LinkVehicleToInterior(GetPlayerVehicleID(playerid),GetPlayerInterior(playerid));
	    SetVehicleVirtualWorld(GetPlayerVehicleID(playerid),GetPlayerVirtualWorld(playerid));
	    return SendClientMessage(playerid,lightblue, "Your vehicle is now in your virtual world and interior");
	} else return SendClientMessage(playerid,red,"ERROR: You must be in a vehicle.");
 }

dcmd_car(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 2) {
	    new tmp[256], tmp2[256], tmp3[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index); tmp3 = strtok(params,Index);
	    if(!strlen(tmp)) return SendClientMessage(playerid, red, "USAGE: /car [Modelid/Name] [colour1] [colour2]");
		new car, colour1, colour2, string[128];
   		if(!IsNumeric(tmp)) car = GetVehicleModelIDFromName(tmp); else car = strval(tmp);
		if(car < 400 || car > 611) return  SendClientMessage(playerid, red, "ERROR: Invalid Vehicle Model");
		if(!strlen(tmp2)) colour1 = random(126); else colour1 = strval(tmp2);
		if(!strlen(tmp3)) colour2 = random(126); else colour2 = strval(tmp3);
		if(PlayerInfo[playerid][pCar] != 0 && !IsPlayerAdmin(playerid) ) CarDeleter(PlayerInfo[playerid][pCar]);
		new LVehicleID,Float:X,Float:Y,Float:Z, Float:Angle,int1;	GetPlayerPos(playerid, X,Y,Z);	GetPlayerFacingAngle(playerid,Angle);   int1 = GetPlayerInterior(playerid);
		LVehicleID = CreateVehicle(car, X+3,Y,Z, Angle, colour1, colour2, -1); LinkVehicleToInterior(LVehicleID,int1);
		PlayerInfo[playerid][pCar] = LVehicleID;
		CMDMessageToAdmins(playerid,"CAR");
		format(string, sizeof(string), "You have spawned a \"%s\" (Model:%d) colour (%d, %d)", VehicleNames[car-400], car, colour1, colour2);
		return SendClientMessage(playerid,lightblue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_carhealth(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 3) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "USAGE: /carhealth [playerid] [amount]");
		new player1 = strval(tmp), health = strval(tmp2), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
            if(IsPlayerInAnyVehicle(player1)) {
		       	CMDMessageToAdmins(playerid,"CARHEALTH");
				format(string, sizeof(string), "You have set \"%s's\" vehicle health to '%d", pName(player1), health); SendClientMessage(playerid,blue,string);
				if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has set your vehicle's health to '%d'", pName(playerid), health); SendClientMessage(player1,blue,string); }
   				return SetVehicleHealth(GetPlayerVehicleID(player1), health);
			} else return SendClientMessage(playerid,red,"ERROR: Player is not in a vehicle");
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_setcarcolour(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 2) {
	    new tmp[256], tmp2[256], tmp3[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index); tmp3 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !strlen(tmp3) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setcarcolor [playerid] [colour1] [colour2]");
		new player1 = strval(tmp), colour1, colour2, string[128];
		if(!strlen(tmp2)) colour1 = random(126); else colour1 = strval(tmp2);
		if(!strlen(tmp3)) colour2 = random(126); else colour2 = strval(tmp3);
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
            if(IsPlayerInAnyVehicle(player1)) {
		       	CMDMessageToAdmins(playerid,"SetCarColor");
				format(string, sizeof(string), "You have changed the colour of \"%s's\" %s to '%d,%d'", pName(player1), VehicleNames[GetVehicleModel(GetPlayerVehicleID(player1))-400], colour1, colour2 ); SendClientMessage(playerid,blue,string);
				if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has changed the colour of your %s to '%d,%d''", pName(playerid), VehicleNames[GetVehicleModel(GetPlayerVehicleID(player1))-400], colour1, colour2 ); SendClientMessage(player1,blue,string); }
   				return ChangeVehicleColor(GetPlayerVehicleID(player1), colour1, colour2);
			} else return SendClientMessage(playerid,red,"ERROR: Player is not in a vehicle");
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_setcarcolor(playerid,params[]) {
	  dcmd_setcarcolour(playerid, params);
	  return 1;
}

dcmd_agod(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 3 || IsPlayerAdmin(playerid)) {
    	if(PlayerInfo[playerid][God] == 0)	{
   	    	PlayerInfo[playerid][God] = 1;
    	    SetPlayerHealth(playerid,100000);
			GivePlayerWeapon(playerid,16,50000); GivePlayerWeapon(playerid,26,50000);
           	SendClientMessage(playerid,green,"GODMODE ON");
			return CMDMessageToAdmins(playerid,"GOD");
		} else {
   	        PlayerInfo[playerid][God] = 0;
       	    SendClientMessage(playerid,red,"GODMODE OFF");
        	SetPlayerHealth(playerid, 100); }
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}
dcmd_vgod(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][pVip] >= 3 || IsPlayerAdmin(playerid)) {
    	if(PlayerInfo[playerid][God] == 0)	{
   	    	PlayerInfo[playerid][God] = 1;
    	    SetPlayerHealth(playerid,10000);
			GivePlayerWeapon(playerid,16,50000); GivePlayerWeapon(playerid,26,50000);
           	SendClientMessage(playerid,green,"GODMODE ON");
		} else {
   	        PlayerInfo[playerid][God] = 0;
       	    SendClientMessage(playerid,red,"GODMODE OFF");
        	SetPlayerHealth(playerid, 100);
		} return GivePlayerWeapon(playerid,35,0);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_sgod(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 5 || IsPlayerAdmin(playerid)) {
   		if(PlayerInfo[playerid][God] == 0)	{
        	PlayerInfo[playerid][God] = 1;
	        SetPlayerHealth(playerid,999999999);
			GivePlayerWeapon(playerid,16,50000); GivePlayerWeapon(playerid,26,50000);
            return SendClientMessage(playerid,green,"GODMODE ON");
		} else	{
   	        PlayerInfo[playerid][God] = 0;
            SendClientMessage(playerid,red,"GODMODE OFF");
	        SetPlayerHealth(playerid, 100); return GivePlayerWeapon(playerid,35,0);	}
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_godcar(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 3 || IsPlayerAdmin(playerid)) {
		if(IsPlayerInAnyVehicle(playerid)) {
	    	if(PlayerInfo[playerid][GodCar] == 0) {
        		PlayerInfo[playerid][GodCar] = 1;
   				CMDMessageToAdmins(playerid,"GODCAR");
            	return SendClientMessage(playerid,COLOR_GREEN,"GODCARMODE ON");
			} else {
	            PlayerInfo[playerid][GodCar] = 0;
    	        return SendClientMessage(playerid,red,"GODCARMODE OFF"); }
		} else return SendClientMessage(playerid,red,"ERROR: You need to be in a car to use this command");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_givegod(playerid, params[])
{
	new str[150], id;
	if(PlayerInfo[playerid][Level] >= 3)
	{
		if(sscanf(params, "d", id))
		{
		    SendClientMessage(playerid, red, "USAGE: /givegod [playerid]");
		    return 1;
		}
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid,red,"ERROR: Player not connected");
		if(PlayerInfo[playerid][Level] < PlayerInfo[id][Level]) return  SendClientMessage(playerid,red,"ERROR: You cannot use this comamnd on this admin.");
		if(PlayerInfo[id][God] == 1) return SendClientMessage(playerid, red, "ERROR: That player has already a god mode!");
		format(str, sizeof(str), "{00FF00}Administrator %s has given you God Mode!",GetPName(playerid));
		SendClientMessage(id, COLOR_GREEN, str);
		format(str, sizeof(str), "{00FFFF}You've given %s God Mode!", GetPName(id));
		SendClientMessage(playerid, red, str);
		SetPlayerHealth(id, 999999999);
		PlayerInfo[id][God] = 1;
	}
	else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}
dcmd_takegod(playerid, params[])
{
	new str[150], id;
	if(PlayerInfo[playerid][Level] >= 3)
	{
		if(sscanf(params, "d", id))
		{
		    SendClientMessage(playerid, red, "USAGE: /takegod [playerid]");
		    return 1;
		}
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid, red, "ERROR:Invalid ID!");
		if(PlayerInfo[playerid][Level] < PlayerInfo[id][Level]) return SendClientMessage(playerid, red, "ERROR:You cannot use this command on this admin.");
		if(PlayerInfo[id][God] == 0) return SendClientMessage(playerid, red, "ERROR: That player has no god mode!");
		format(str, sizeof(str), "{00FFFF}Administrator %s has take off your god mode!", GetPName(playerid));
		SendClientMessage(id, red, str);
		format(str, sizeof(str), "{00FFFF}You've take off %s's god mode!", GetPName(id));
		SendClientMessage(playerid, red, str);
		SetPlayerHealth(id, 100.0);
		PlayerInfo[id][God] = 0;
	}
	else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}

dcmd_giveb(playerid, params[])
{
	new str[150], id;
	if(PlayerInfo[playerid][Level] >= 4)
	{
		if(sscanf(params, "d", id))
		{
		    SendClientMessage(playerid, red, "USAGE: /giveb [playerid]");
		    return 1;
		}
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid,red,"ERROR: Player not connected");
		if(PlayerInfo[playerid][Level] < PlayerInfo[id][Level]) return  SendClientMessage(playerid,red,"ERROR: You cannot use this comamnd on this admin.");
		if(PlayerInfo[id][Boost] == 1) return SendClientMessage(playerid, red, "ERROR: That player has already a Boost!");
		format(str, sizeof(str), "{00FF00}Administrator %s has given you Boost!",GetPName(playerid));
		SendClientMessage(id, COLOR_GREEN, str);
		format(str, sizeof(str), "{00FFFF}You've given %s Boost!", GetPName(id));
		SendClientMessage(playerid, red, str);
		PlayerInfo[id][Boost] = 1;
	}
	else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}
dcmd_givebo(playerid, params[])
{
	new str[150], id;
	if(PlayerInfo[playerid][Level] >= 4)
	{
		if(sscanf(params, "d", id))
		{
		    SendClientMessage(playerid, red, "USAGE: /givebo [playerid]");
		    return 1;
		}
		if(id == INVALID_PLAYER_ID) return SendClientMessage(playerid,red,"ERROR: Player not connected");
		if(PlayerInfo[playerid][Level] < PlayerInfo[id][Level]) return  SendClientMessage(playerid,red,"ERROR: You cannot use this comamnd on this admin.");
		if(PlayerInfo[id][Boost] == 0) return SendClientMessage(playerid, red, "ERROR: That player's Boost already offline.");
		format(str, sizeof(str), "{00FF00}Administrator %s has set your Boost {FF0000}Offline",GetPName(playerid));
		SendClientMessage(id, COLOR_GREEN, str);
		format(str, sizeof(str), "{00FFFF}You've given %s Boost {FF0000}Offline", GetPName(id));
		SendClientMessage(playerid, red, str);
		PlayerInfo[id][Boost] = 0;
	}
	else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}
dcmd_die(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 4 || IsPlayerAdmin(playerid)) {
		new Float:x, Float:y, Float:z ;
		GetPlayerPos( playerid, Float:x, Float:y, Float:z );
		CreateExplosion(Float:x+10, Float:y, Float:z, 8,10.0);
		CreateExplosion(Float:x-10, Float:y, Float:z, 8,10.0);
		CreateExplosion(Float:x, Float:y+10, Float:z, 8,10.0);
		CreateExplosion(Float:x, Float:y-10, Float:z, 8,10.0);
		CreateExplosion(Float:x+10, Float:y+10, Float:z, 8,10.0);
		CreateExplosion(Float:x-10, Float:y+10, Float:z, 8,10.0);
		return CreateExplosion(Float:x-10, Float:y-10, Float:z, 8,10.0);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_getid(playerid,params[])
{
	if(!strlen(params)) return SendClientMessage(playerid,blue,"Correct Usage: /getid [part of nick]");
	new found, string[128], playername[MAX_PLAYER_NAME];
	format(string,sizeof(string),"Searched for: \"%s\" ",params);
	SendClientMessage(playerid,blue,string);
	for(new i=0; i <= MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
	  		GetPlayerName(i, playername, MAX_PLAYER_NAME);
			new namelen = strlen(playername);
			new bool:searched=false;
	    	for(new pos=0; pos <= namelen; pos++)
			{
				if(searched != true)
				{
					if(strfind(playername,params,true) == pos)
					{
		                found++;
						format(string,sizeof(string),"%d. %s (ID %d)",found,playername,i);
						SendClientMessage(playerid, green ,string);
						searched = true;
					}
				}
			}
		}
	}
	if(found == 0) SendClientMessage(playerid, lightblue, "No players have this in their nick");
	return 1;
}

dcmd_asay(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1) {
 		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /asay [text]");
		new string[128]; format(string, sizeof(string), "[*Admin %s: %s]", PlayerName2(playerid), params[0] );
		return SendClientMessageToAll(red,string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_setping(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 4 || IsPlayerAdmin(playerid)) {
 		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /setping [ping]   Set to 0 to disable");
	    new string[128], ping = strval(params);
		ServerInfo[MaxPing] = ping;
		CMDMessageToAdmins(playerid,"SETPING");
		new file[256]; format(file,sizeof(file),"ladmin/config/Config.ini");
		dini_IntSet(file,"MaxPing",ping);
		for(new i = 0; i <= MAX_PLAYERS; i++) if(IsPlayerConnected(i)) PlayerPlaySound(i,1057,0.0,0.0,0.0);
		if(ping == 0) format(string,sizeof(string),"Administrator %s has disabled maximum ping", PlayerName2(playerid), ping);
		else format(string,sizeof(string),"Administrator %s has set the maximum ping to %d", PlayerName2(playerid), ping);
		return SendClientMessageToAll(blue,string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_ping(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 2) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /ping [playerid]");
		new player1 = strval(params), string[128];
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		    new Sum, Average, x;
			while (x < PING_MAX_EXCEEDS) {
				Sum += PlayerInfo[player1][pPing][x];
				x++;
			}
			Average = (Sum / PING_MAX_EXCEEDS);
			format(string, sizeof(string), "\"%s\" (id %d) Average Ping: %d   (Last ping readings: %d, %d, %d, %d)", PlayerName2(player1), player1, Average, PlayerInfo[player1][pPing][0], PlayerInfo[player1][pPing][1], PlayerInfo[player1][pPing][2], PlayerInfo[player1][pPing][3] );
			return SendClientMessage(playerid,blue,string);
		} else return SendClientMessage(playerid, red, "Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_highlight(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 2 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid,red,"USAGE: /highlight [playerid]");
	    new player1, playername[MAX_PLAYER_NAME], string[128];
	    player1 = strval(params);
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		 	GetPlayerName(player1, playername, sizeof(playername));
	 	    if(PlayerInfo[player1][blip] == 0) {
				CMDMessageToAdmins(playerid,"HIGHLIGHT");
				PlayerInfo[player1][pColour] = GetPlayerColor(player1);
				PlayerInfo[player1][blip] = 1;
				BlipTimer[player1] = SetTimerEx("HighLight", 1000, 1, "i", player1);
				format(string,sizeof(string),"You have highlighted %s's marker", playername);
			} else {
				KillTimer( BlipTimer[player1] );
				PlayerInfo[player1][blip] = 0;
				SetPlayerColor(player1, PlayerInfo[player1][pColour] );
				format(string,sizeof(string),"You have stopped highlighting %s's marker", playername);
			}
			return SendClientMessage(playerid,blue,string);
		} else return SendClientMessage(playerid, red, "Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_setgravity(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 5) {
	    if(!strlen(params)||!(strval(params)<=50&&strval(params)>=-50)) return SendClientMessage(playerid,red,"USAGE: /setgravity <-50.0 - 50.0>");
        CMDMessageToAdmins(playerid,"SETGRAVITY");
		new string[128],adminname[MAX_PLAYER_NAME]; GetPlayerName(playerid, adminname, sizeof(adminname)); new Float:Gravity = floatstr(params);format(string,sizeof(string),"Admnistrator %s has set the gravity to %f",adminname,Gravity);
		SetGravity(Gravity); return SendClientMessageToAll(blue,string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_serverinfo(playerid,params[])
{
	#pragma unused params
    new TotalVehicles = CreateVehicle(411, 0, 0, 0, 0, 0, 0, 1000);    DestroyVehicle(TotalVehicles);
	new numo = CreateObject(1245,0,0,1000,0,0,0);	DestroyObject(numo);
	new nump = CreatePickup(371,2,0,0,1000);	DestroyPickup(nump);
	new gz = GangZoneCreate(3,3,5,5);	GangZoneDestroy(gz);
	new model[250], nummodel;
	for(new i=1;i<TotalVehicles;i++) model[GetVehicleModel(i)-400]++;
	for(new i=0;i<250;i++)	if(model[i]!=0)	nummodel++;
	new string[256];
	format(string,sizeof(string),"Server Info: [ Players Connected: %d || Maximum Players: %d ] [Ratio %0.2f ]",ConnectedPlayers(),GetMaxPlayers(),Float:ConnectedPlayers() / Float:GetMaxPlayers() );
	SendClientMessage(playerid,green,string);
	format(string,sizeof(string),"Server Info: [ Vehicles: %d || Models %d || Players In Vehicle: %d || InCar %d / OnBike %d ]",TotalVehicles-1,nummodel, InVehCount(),InCarCount(),OnBikeCount() );
	SendClientMessage(playerid,green,string);
	format(string,sizeof(string),"Server Info: [ Objects: %d || Pickups %d || Gangzones %d ]",numo-1, nump, gz);
	SendClientMessage(playerid,green,string);
	format(string,sizeof(string),"Server Info: [ Players In Jail %d || Players Frozen %d || Muted %d ]",JailedPlayers(),FrozenPlayers(), MutedPlayers() );
	return SendClientMessage(playerid,green,string);
}

dcmd_announce(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 2 || IsPlayerAdmin(playerid)) {
    	if(!strlen(params)) return SendClientMessage(playerid,red,"USAGE: /announce <text>");
    	CMDMessageToAdmins(playerid,"ANNOUNCE");
		return GameTextForAll(params,4000,3);
    } else return SendClientMessage(playerid,red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_announce2(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 3) {
        new tmp[256], tmp2[256], tmp3[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index) ,tmp3 = strtok(params,Index);
	    if(!strlen(tmp)||!strlen(tmp2)||!strlen(tmp3)) return SendClientMessage(playerid,red,"USAGE: /announce <style> <time> <text>");
		if(!(strval(tmp) >= 0 && strval(tmp) <= 6) || strval(tmp) == 2)	return SendClientMessage(playerid,red,"ERROR: Invalid gametext style. Range: 0 - 6");
		return GameTextForAll(tmp3,strval(tmp2),strval(tmp) );
    } else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_lslowmo(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1) {
		new Float:x, Float:y, Float:z; GetPlayerPos(playerid, x, y, z); CreatePickup(1241, 4, x, y, z);
		return CMDMessageToAdmins(playerid,"LSLOWMO");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_jetpack(playerid,params[])
{
    if(!strlen(params))	{
    	if(PlayerInfo[playerid][Level] >= 1 || IsPlayerAdmin(playerid) || PlayerInfo[playerid][pVip] >= 1) {
			SendClientMessage(playerid,blue,"Jetpack Spawned.");
			return SetPlayerSpecialAction(playerid, 2);
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else {
	    new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
    	player1 = strval(params);
		if(PlayerInfo[playerid][Level] >= 3)	{
		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid)	{
				CMDMessageToAdmins(playerid,"JETPACK");		SetPlayerSpecialAction(player1, 2);
				GetPlayerName(player1, playername, sizeof(playername));		GetPlayerName(playerid, adminname, sizeof(adminname));
				format(string,sizeof(string),"Administrator \"%s\" has given you a jetpack",adminname); SendClientMessage(player1,blue,string);
				format(string,sizeof(string),"You have given %s a jetpack", playername);
				return SendClientMessage(playerid,blue,string);
			} else return SendClientMessage(playerid, red, "Player is not connected or is yourself");
		} else return SendClientMessage(playerid,red,"ERROR: You do not have the privileges to give jetpack to other players!");
	}
}

dcmd_flip(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 2 || IsPlayerAdmin(playerid) || PlayerInfo[playerid][pVip] >= 1) {
	    if(!strlen(params)) {
		    if(IsPlayerInAnyVehicle(playerid)) {
			new VehicleID, Float:X, Float:Y, Float:Z, Float:Angle; GetPlayerPos(playerid, X, Y, Z); VehicleID = GetPlayerVehicleID(playerid);
			GetVehicleZAngle(VehicleID, Angle);	SetVehiclePos(VehicleID, X, Y, Z); SetVehicleZAngle(VehicleID, Angle); SetVehicleHealth(VehicleID,1000.0);
			CMDMessageToAdmins(playerid,"FLIP"); return SendClientMessage(playerid, blue,"Vehicle Flipped. You can also do /flip [playerid]");
			} else return SendClientMessage(playerid,red,"Error: You are not in a vehicle. You can also do /flip [playerid]");
		}
	    new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
	    player1 = strval(params);
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid) {
			if (IsPlayerInAnyVehicle(player1)) {
				new VehicleID, Float:X, Float:Y, Float:Z, Float:Angle; GetPlayerPos(player1, X, Y, Z); VehicleID = GetPlayerVehicleID(player1);
				GetVehicleZAngle(VehicleID, Angle);	SetVehiclePos(VehicleID, X, Y, Z); SetVehicleZAngle(VehicleID, Angle); SetVehicleHealth(VehicleID,1000.0);
				GetPlayerName(player1, playername, sizeof(playername));		GetPlayerName(playerid, adminname, sizeof(adminname));
				format(string,sizeof(string),"Admin/VIP %s flipped your vehicle",adminname); SendClientMessage(player1,blue,string);
				format(string,sizeof(string),"You have flipped %s's vehicle", playername);
				return SendClientMessage(playerid, blue,string);
			} else return SendClientMessage(playerid,red,"Error: This player isn't in a vehicle");
		} else return SendClientMessage(playerid, red, "Player is not connected or is yourself");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_destroycar(playerid,params[]) {
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 3) return EraseVehicle(GetPlayerVehicleID(playerid));
	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_rhino(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 3) {
    if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
	new Float:X,Float:Y,Float:Z,Float:Angle,rhino;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
    rhino = CreateVehicle(432,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,rhino,0);
	PlayerInfo[playerid][pCar] = rhino;
	return SendClientMessage(playerid,yellow,"You have spawned Rhino!");
	} else return SendClientMessage(playerid,lightblue,"ERROR: You need to be {0000FF}Platinum VIP to use this command");
}

dcmd_hydra(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 3) {
    if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
	new Float:X,Float:Y,Float:Z,Float:Angle,hydra;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
    hydra = CreateVehicle(520,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,hydra,0);
	PlayerInfo[playerid][pCar] = hydra;
	return SendClientMessage(playerid,yellow,"You have spawned Hydra!");
	} else return SendClientMessage(playerid,lightblue,"ERROR: You need to be {0000FF}Platinum VIP to use this command");
}

dcmd_hunter(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 3) {
    if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
	new Float:X,Float:Y,Float:Z,Float:Angle,hunter;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
    hunter = CreateVehicle(425,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,hunter,0);
	PlayerInfo[playerid][pCar] = hunter;
	return SendClientMessage(playerid,yellow,"You have spawned Hunter!");
	} else return SendClientMessage(playerid,lightblue,"ERROR: You need to be {0000FF}Platinum VIP to use this command");
}

dcmd_pm(playerid, params[])
{
	new str1[256], text[256], str2[256], str3[256], recieverid, playername[MAX_PLAYER_NAME], recievername[MAX_PLAYERS];
	if(sscanf(params, "us[128]", recieverid, text)) return SendClientMessage(playerid, COLOR_GREEN, "{FF8000}USAGE: {00FF00}/pm <ID> <Text>");
	if(recieverid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_GREY, "{C0C0C0}ERROR: {FF0000}Invalid player ID!" );
  	if(PlayerInfo[playerid][Muted] == 1) return SendClientMessage(playerid, COLOR_GREY, "{C0C0C0}ERROR: {FF0000}You're muted, you cannot send PM's!" );
	if(PlayerInfo[playerid][Jailed] == 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: You're in jail, you cannot use /pm!");
	if(PlayerInfo[playerid][Frozen] == 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: You're frozen, you cannot use /pm!");
	GetPlayerName(recieverid, playername, sizeof(playername)); 	GetPlayerName(playerid, recievername, sizeof(recievername));
	format(str1, sizeof(str1), "{2CE8BF}PM sent to {%06x}%s(%d){2CE8BF}: {ACE2E6}%s", (GetPlayerColor(recieverid) >>> 8), pName(recieverid), recieverid, text);
	format(str2, sizeof(str2), "{2CE8BF}PM received from {%06x}%s(%d){2CE8BF}: {ACE2E6}%s", (GetPlayerColor(playerid) >>> 8), pName(playerid), playerid, text);
	if(PlayerInfo[recieverid][DisablePMs] == 1)
	{
		format(str3, sizeof(str3), "{C0C0C0}%s(%d) {FF0000}has private messages disabled!", recievername, recieverid);
		SendClientMessage( playerid, -1, str3);
		return 1;
	}
	OnPlayerPrivmsg(playerid, recieverid, text);
	GameTextForPlayer(recieverid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~g~~h~~h~PM received!", 3000, 3);
	GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~g~~h~~h~PM sent!", 3000, 3);
	SendClientMessage(playerid, -1, str1);
	SendClientMessage(recieverid, -1, str2);
	PMReply[recieverid]=playerid;
	return 1;
}

dcmd_r(playerid,params[])
{
  	  if(PlayerInfo[playerid][Muted] == 1) return SendClientMessage(playerid, COLOR_GREY, "{C0C0C0}ERROR: {FF0000}You're muted, you cannot reply to PM's!" );
	  if(PlayerInfo[playerid][Jailed] == 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: You're in jail, you cannot use /r!");
	  if(PlayerInfo[playerid][Frozen] == 1) return SendClientMessage(playerid, COLOR_RED, "ERROR: You're frozen, you cannot use /r!");
	  if(PMReply[playerid] < 0) return SendClientMessage(playerid, COLOR_RED,"» Error « {BABABA}You haven't received any Private Messages");
	  if(!strlen(params)) return SendClientMessage(playerid, COLOR_RED, "» Error « {BABABA}Usage /r <Message>");
	  new str[135];
	  format(str,sizeof(str),"%d %s",PMReply[playerid],params);
	  dcmd_pm(playerid,str);
	  return 1;
}

dcmd_disablepm(playerid, params[])
{
     new playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128], player1;
     if(PlayerInfo[playerid][Level] >= 4) {
     if(!strlen(params)) return SendClientMessage(playerid, COLOR_YELLOW, "USAGE: /disablepm [ID]");
     if(!IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) return SendClientMessage(playerid, COLOR_RED, "ERROR: Player is not connected or it's higher level admin");
     GetPlayerName(player1, playername, sizeof(playername)); 	GetPlayerName(playerid, adminname, sizeof(adminname));
     CMDMessageToAdmins(playerid,"DisablePM");
     PlayerInfo[player1][DisablePMs] = 1;
     format(string,sizeof(string),"Administrator %s has Prevented you from using Private Messages",pName(playerid));
     SendClientMessage(player1, COLOR_LIGHTBLUE, string);
     format(string,sizeof(string),"You have Prevented %s from using Private Messages",GetName(playername));
     SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
     } else return SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
     return 1;
}

dcmd_enablepm(playerid, params[])
{
     new playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128], player1;
     if(PlayerInfo[playerid][Level] >= 4) {
     if(!strlen(params)) return SendClientMessage(playerid, COLOR_YELLOW, "USAGE: /enablepm [ID]");
     if(!IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) return SendClientMessage(playerid, COLOR_RED, "ERROR: Player is not connected or it's higher level admin");
     GetPlayerName(player1, playername, sizeof(playername)); 	GetPlayerName(playerid, adminname, sizeof(adminname));
     CMDMessageToAdmins(playerid,"EnablePM");
     PlayerInfo[player1][DisablePMs] = 0;
     format(string,sizeof(string),"Administrator %s has Enabled your Private Messages",pName(playerid));
     SendClientMessage(player1, COLOR_LIGHTBLUE, string);
     format(string,sizeof(string),"You have Enabled %s's Private Messages",GetName(playername));
     SendClientMessage(playerid, COLOR_LIGHTBLUE, string);
     } else return SendClientMessage(playerid, COLOR_RED, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
     return 1;
}

dcmd_pmoff(playerid, params[])
{
  #pragma unused params
  PlayerInfo[playerid][DisablePMs] = 1;
  SendClientMessage(playerid, COLOR_RED, "You have disabled your Private Messages");
  return 1;
}

dcmd_pmon(playerid, params[])
{
  #pragma unused params
  if(PlayerInfo[playerid][ADisabledPMs] == 1) return SendClientMessage(playerid, COLOR_RED, "An Administrator have been disabled your PM's, you can't enable them");
  PlayerInfo[playerid][DisablePMs] = 0;
  SendClientMessage(playerid, COLOR_GREEN, "You have enabled your Private Messages");
  return 1;
}

dcmd_ltc(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1) {
		if(!IsPlayerInAnyVehicle(playerid)) {
			if(PlayerInfo[playerid][pCar] != 0) CarDeleter(PlayerInfo[playerid][pCar]);
			new Float:X,Float:Y,Float:Z,Float:Angle,LVehicleIDt;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
	        LVehicleIDt = CreateVehicle(560,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,LVehicleIDt,0);	    AddVehicleComponent(LVehicleIDt, 1028);	AddVehicleComponent(LVehicleIDt, 1030);	AddVehicleComponent(LVehicleIDt, 1031);	AddVehicleComponent(LVehicleIDt, 1138);
			AddVehicleComponent(LVehicleIDt, 1140);  AddVehicleComponent(LVehicleIDt, 1170);
		    AddVehicleComponent(LVehicleIDt, 1028);	AddVehicleComponent(LVehicleIDt, 1030);	AddVehicleComponent(LVehicleIDt, 1031);	AddVehicleComponent(LVehicleIDt, 1138);	AddVehicleComponent(LVehicleIDt, 1140);  AddVehicleComponent(LVehicleIDt, 1170);
		    AddVehicleComponent(LVehicleIDt, 1080);	AddVehicleComponent(LVehicleIDt, 1086); AddVehicleComponent(LVehicleIDt, 1087); AddVehicleComponent(LVehicleIDt, 1010);	PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	ChangeVehiclePaintjob(LVehicleIDt,0);
	   	   	SetVehicleVirtualWorld(LVehicleIDt, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(LVehicleIDt, GetPlayerInterior(playerid));
			return PlayerInfo[playerid][pCar] = LVehicleIDt;
		} else return SendClientMessage(playerid,red,"Error: You already have a vehicle");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_warp(playerid,params[])
{
	return dcmd_teleplayer(playerid,params);
}

dcmd_teleplayer(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 3 || IsPlayerAdmin(playerid)) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp) || !IsNumeric(tmp2)) return SendClientMessage(playerid, red, "USAGE: /teleplayer [playerid] to [playerid]");
		new player1 = strval(tmp), player2 = strval(tmp2), string[128], Float:plocx,Float:plocy,Float:plocz;
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
 		 	if(IsPlayerConnected(player2) && player2 != INVALID_PLAYER_ID) {
	 		 	CMDMessageToAdmins(playerid,"TELEPLAYER");
				GetPlayerPos(player2, plocx, plocy, plocz);
				new intid = GetPlayerInterior(player2);	SetPlayerInterior(player1,intid);
				SetPlayerVirtualWorld(player1,GetPlayerVirtualWorld(player2));
				if (GetPlayerState(player1) == PLAYER_STATE_DRIVER)
				{
					new VehicleID = GetPlayerVehicleID(player1);
					SetVehiclePos(VehicleID, plocx, plocy+4, plocz); LinkVehicleToInterior(VehicleID,intid);
					SetVehicleVirtualWorld(VehicleID, GetPlayerVirtualWorld(player2) );
				}
				else SetPlayerPos(player1,plocx,plocy+2, plocz);
				format(string,sizeof(string),"Administrator \"%s\" has teleported \"%s\" to \"%s's\" location", pName(playerid), pName(player1), pName(player2) );
				SendClientMessage(player1,blue,string); SendClientMessage(player2,blue,string);
				format(string,sizeof(string),"You have teleported \"%s\" to \"%s's\" location", pName(player1), pName(player2) );
 		 	    return SendClientMessage(playerid,blue,string);
 		 	} else return SendClientMessage(playerid, red, "Player2 is not connected");
		} else return SendClientMessage(playerid, red, "Player1 is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_fly(playerid,params[])
{
        #pragma unused params
        if(PlayerInfo[playerid][Level] >= 2 || PlayerInfo[playerid][pVip] >= 3)
        {
	    StartFly(playerid);
	    }
        else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
        return 1;
}
dcmd_flyoff(playerid,params[])
{
        #pragma unused params
        if(PlayerInfo[playerid][Level] >= 2 || PlayerInfo[playerid][pVip] >= 3)
        {
	    StopFly(playerid);
	    }
        else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
        return 1;
}
dcmd_goto(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 1 || IsPlayerAdmin(playerid) || PlayerInfo[playerid][pVip] >= 1) {
	    if(!strlen(params)) return SendClientMessage(playerid,red,"USAGE: /goto [playerid]");
	    new player1, string[128];
		if(!IsNumeric(params)) player1 = ReturnPlayerID(params);
	   	else player1 = strval(params);
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid) {
			new Float:x, Float:y, Float:z;	GetPlayerPos(player1,x,y,z); SetPlayerInterior(playerid,GetPlayerInterior(player1));
			SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(player1));
			if(GetPlayerState(playerid) == 2) {
				SetVehiclePos(GetPlayerVehicleID(playerid),x+3,y,z);	LinkVehicleToInterior(GetPlayerVehicleID(playerid),GetPlayerInterior(player1));
				SetVehicleVirtualWorld(GetPlayerVehicleID(playerid),GetPlayerVirtualWorld(player1));
			} else SetPlayerPos(playerid,x+2,y,z);
			format(string,sizeof(string),"You have teleported to \"%s\"", pName(player1));
			return SendClientMessage(playerid,blue,string);
		} else return SendClientMessage(playerid, red, "Player is not connected or is yourself");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_vgoto(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 1 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid,red,"USAGE: /vgoto [vehicleid]");
	    new player1, string[128];
	    player1 = strval(params);
		CMDMessageToAdmins(playerid,"VGOTO");
		new Float:x, Float:y, Float:z;	GetVehiclePos(player1,x,y,z);
		SetPlayerVirtualWorld(playerid,GetVehicleVirtualWorld(player1));
		if(GetPlayerState(playerid) == 2) {
			SetVehiclePos(GetPlayerVehicleID(playerid),x+3,y,z);
			SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), GetVehicleVirtualWorld(player1) );
		} else SetPlayerPos(playerid,x+2,y,z);
		format(string,sizeof(string),"You have teleported to vehicle id %d", player1);
		return SendClientMessage(playerid,blue,string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_lgoto(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 1 || IsPlayerAdmin(playerid)) {
		new Float:x, Float:y, Float:z;
        new tmp[256], tmp2[256], tmp3[256];
		new string[128], Index;	tmp = strtok(params,Index); tmp2 = strtok(params,Index); tmp3 = strtok(params,Index);
    	if(!strlen(tmp) || !strlen(tmp2) || !strlen(tmp3)) return SendClientMessage(playerid,red,"USAGE: /lgoto [x] [y] [z]");
	    x = strval(tmp);		y = strval(tmp2);		z = strval(tmp3);
		CMDMessageToAdmins(playerid,"LGOTO");
		if(GetPlayerState(playerid) == 2) SetVehiclePos(GetPlayerVehicleID(playerid),x,y,z);
		else SetPlayerPos(playerid,x,y,z);
		format(string,sizeof(string),"You have teleported to %f, %f, %f", x,y,z); return SendClientMessage(playerid,blue,string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_givecar(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 1 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid,red,"USAGE: /givecar [playerid]");
	    new player1 = strval(params), playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
	    if(IsPlayerInAnyVehicle(player1)) return SendClientMessage(playerid,red,"ERROR: Player already has a vehicle");
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid) {
			CMDMessageToAdmins(playerid,"GIVECAR");
			new Float:x, Float:y, Float:z;	GetPlayerPos(player1,x,y,z);
			CarSpawner(player1,415);
			GetPlayerName(player1, playername, sizeof(playername));		GetPlayerName(playerid, adminname, sizeof(adminname));
			format(string,sizeof(string),"Administrator %s has given you a car",adminname);	SendClientMessage(player1,blue,string);
			format(string,sizeof(string),"You have given %s a car", playername); return SendClientMessage(playerid,blue,string);
		} else return SendClientMessage(playerid, red, "Player is not connected or is yourself");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_gethere(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 3) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /gethere [playerid]");
    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
		player1 = strval(params);
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid) {
			CMDMessageToAdmins(playerid,"GETHERE");
			new Float:x, Float:y, Float:z;	GetPlayerPos(playerid,x,y,z); SetPlayerInterior(player1,GetPlayerInterior(playerid));
			SetPlayerVirtualWorld(player1,GetPlayerVirtualWorld(playerid));
			if(GetPlayerState(player1) == 2)	{
			    new VehicleID = GetPlayerVehicleID(player1);
				SetVehiclePos(VehicleID,x+3,y,z);   LinkVehicleToInterior(VehicleID,GetPlayerInterior(playerid));
				SetVehicleVirtualWorld(GetPlayerVehicleID(player1),GetPlayerVirtualWorld(playerid));
			} else SetPlayerPos(player1,x+2,y,z);
			GetPlayerName(player1, playername, sizeof(playername));		GetPlayerName(playerid, adminname, sizeof(adminname));
			format(string,sizeof(string),"You have been teleported to Administrator %s's location",adminname);	SendClientMessage(player1,blue,string);
			format(string,sizeof(string),"You have teleported %s to your location", playername); return SendClientMessage(playerid,blue,string);
		} else return SendClientMessage(playerid, red, "Player is not connected or is yourself");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_get(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 3|| IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /get [playerid]");
    	new player1, string[128];
		if(!IsNumeric(params)) player1 = ReturnPlayerID(params);
	   	else player1 = strval(params);
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid) {
			CMDMessageToAdmins(playerid,"GET");
			new Float:x, Float:y, Float:z;	GetPlayerPos(playerid,x,y,z); SetPlayerInterior(player1,GetPlayerInterior(playerid));
			SetPlayerVirtualWorld(player1,GetPlayerVirtualWorld(playerid));
			if(GetPlayerState(player1) == 2)	{
			    new VehicleID = GetPlayerVehicleID(player1);
				SetVehiclePos(VehicleID,x+3,y,z);   LinkVehicleToInterior(VehicleID,GetPlayerInterior(playerid));
				SetVehicleVirtualWorld(GetPlayerVehicleID(player1),GetPlayerVirtualWorld(playerid));
			} else SetPlayerPos(player1,x+2,y,z);
			format(string,sizeof(string),"You have been teleported to Administrator \"%s's\" location", pName(playerid) );	SendClientMessage(player1,blue,string);
			format(string,sizeof(string),"You have teleported \"%s\" to your location", pName(player1) );
			return SendClientMessage(playerid,blue,string);
		} else return SendClientMessage(playerid, red, "Player is not connected or is yourself");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_fu(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 2) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /fu [playerid]");
    	new player1 = strval(params), string[128], NewName[MAX_PLAYER_NAME];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			CMDMessageToAdmins(playerid,"FU");
			SetPlayerHealth(player1,1.0); SetPlayerArmour(player1,0.0); ResetPlayerWeapons(player1);ResetPlayerMoneyEx(player1);GivePlayerWeapon(player1,12,1);
			SetPlayerSkin(player1, 137); SetPlayerScore(player1, 0); SetPlayerColor(player1,COLOR_PINK); SetPlayerWeather(player1,19); SetPlayerWantedLevel(player1,6);
			format(NewName,sizeof(NewName),"[N00B]%s", pName(player1) ); SetPlayerName(player1,NewName);
			if(IsPlayerInAnyVehicle(player1)) EraseVehicle(GetPlayerVehicleID(player1));
			if(player1 != playerid)	{ format(string,sizeof(string),"~w~%s: ~r~Fuck You", pName(playerid) ); GameTextForPlayer(player1, string, 2500, 3); }
			format(string,sizeof(string),"Fuck you \"%s\"", pName(player1) ); return SendClientMessage(playerid,blue,string);
		} else return SendClientMessage(playerid, red, "Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_warn(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 2)
    {
   	new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
   	if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "USAGE: /warn [playerid] [reason]");
    new warned = strval(tmp), str[265];
    if(PlayerInfo[warned][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
    if(IsPlayerConnected(warned) && warned != INVALID_PLAYER_ID) {
   	if(warned != playerid) {
    CMDMessageToAdmins(playerid,"WARN");
    PlayerInfo[warned][Warnings]++;
    if(PlayerInfo[warned][Warnings] == MAX_WARNINGS) {
    format(str, sizeof (str), "***Administrator/VIP  \"%s\" has kicked \"%s\".  (Reason: %s) (Warning: %d/%d)***", pName(playerid), pName(warned), params[1+strlen(tmp)], PlayerInfo[warned][Warnings], MAX_WARNINGS);
    SendClientMessageToAll(grey, str);
    SaveToFile("KickLog",str);
	PlayerInfo[warned][Warnings] = 0;
	Kick(warned);
    return 1;
    } else {
    format(str, sizeof (str), "***Administrator/VIP  \"%s\" has given \"%s\" a warning.  (Reason: %s) (Warning: %d/%d)***", pName(playerid), pName(warned), params[1+strlen(tmp)], PlayerInfo[warned][Warnings], MAX_WARNINGS);
    return SendClientMessageToAll(yellow, str);
    }
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid, red, "ERROR: You cannot warn yourself");
    } else return SendClientMessage(playerid, red, "ERROR: Player is not connected");
}
dcmd_dmtime(playerid,params[])
{
    #pragma unused params
    if(GetPVarInt(playerid,"dmtime") == 1) return SendClientMessage(playerid,red,"ERROR: dmtime is already ON!");
	if(GetPVarInt(playerid,"dmtime") == 0)
	if(PlayerInfo[playerid][Level]>= 5)
	{
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
		if(IsPlayerConnected(i))
		{
		PlayerPlaySound(i,1057,0.0,0.0,0.0);
		GivePlayerWeapon(i,27,9999);
		GivePlayerWeapon(i,24,9999);
		GivePlayerWeapon(i,16,9999);
		GivePlayerWeapon(i,31,9999);
		GivePlayerWeapon(i,32,9999);
		GivePlayerWeapon(i,10,9999);
		}
		}
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
		if(IsPlayerConnected(i))
		{
		PlayerPlaySound(i,1057,0.0,0.0,0.0);
		SetPlayerHealth(i,100.0);
		}
		}
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		SendClientMessageToAll(red, "{0099FF}DM TIME!!");
		GameTextForAll("~n~~n~~n~~n~~n~~n~~r~DM ~g~TIME !!!!!", 3000,3);
		SetPVarInt(playerid,"dmtime",1);
		SetPVarInt(playerid,"dmtimeo",0);
		return 1;
	}
	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}
dcmd_dmtimeo(playerid,params[])
{
     #pragma unused params
    if(GetPVarInt(playerid,"dmtimeo") == 1) return SendClientMessage(playerid,red,"ERROR: dmtime is already OFF!");
	if(GetPVarInt(playerid,"dmtimeo") == 0)
	if(PlayerInfo[playerid][Level]>= 5)
	{
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
		if(IsPlayerConnected(i))
		{
		PlayerPlaySound(i,1057,0.0,0.0,0.0);
		ResetPlayerWeapons(i);
		}
		}
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
		if(IsPlayerConnected(i))
		{
		PlayerPlaySound(i,1057,0.0,0.0,0.0);
		SetPlayerHealth(i,100.0);
		}
		}
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		SendClientMessageToAll(red, "DM TIME Over!!");
		GameTextForAll("~n~~n~~n~~n~~n~~n~~r~DM ~g~TIME OVER !!!!!", 3000,3);
		SetPVarInt(playerid,"dmtimeo",1);
		SetPVarInt(playerid,"dmtime",0);
		return 1;
	}
	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}

dcmd_kick(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
	    if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 3) {
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /kick [playerid] [reason]");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);
		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
				GetPlayerName(player1, playername, sizeof(playername));		GetPlayerName(playerid, adminname, sizeof(adminname));
                if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
				CMDMessageToAdmins(playerid,"KICK");
				if(!strlen(tmp2)) {
					format(string,sizeof(string),"%s has been kicked by Administrator/VIP %s [no reason given] ",playername,adminname); SendClientMessageToAll(red,string);
					SaveToFile("KickLog",string); print(string); return Kick(player1);
				} else {
					format(string,sizeof(string),"%s has been kicked by Administrator/VIP %s [reason: %s] ",playername,adminname,params[2]); SendClientMessageToAll(red,string);
					SaveToFile("KickLog",string); print(string); return KickWithMessage(player1, string); }
			} else return SendClientMessage(playerid, red, "Player is not connected or is yourself or is the highest level admin");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_ban(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 3) {
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /ban [playerid] [reason]");
			if(!strlen(tmp2)) return SendClientMessage(playerid, red, "ERROR: You must give a reason");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[256], banstring[256];
			player1 = strval(tmp);
			new tmp3[50];
			GetPlayerIp(player1,tmp3,50);
		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
				GetPlayerName(player1, playername, sizeof(playername)); GetPlayerName(playerid, adminname, sizeof(adminname));
				new year,month,day,hour,minuite,second; getdate(year, month, day); gettime(hour,minuite,second);
				CMDMessageToAdmins(playerid,"BAN");
				format(string,sizeof(string),"%s has been banned by Administrator %s [Reason: %s] [Date: %d/%d/%d] [Time: %d:%d]",playername,adminname,params[2],day,month,year,hour,minuite);
				SendClientMessageToAll(red,string);
				print(string);
				SaveToFile("BanLog",string);
				format(banstring,sizeof(banstring),"You are Banned by Administrator %s. [Reason: %s] [Date: %d/%d/%d] [Time: %d:%d], Your IP:", adminname, params[2],day,month,year,hour,minuite, tmp3);
				SendClientMessage(player1,red,banstring);
				if(udb_Exists(PlayerName2(player1)) && PlayerInfo[player1][LoggedIn] == 1) dUserSetINT(PlayerName2(player1)).("banned",1);
				Kick(player1);
			    BanEx(player1, banstring);
			    return 1;
			} else return SendClientMessage(playerid, red, "Player is not connected or is yourself or is the highest level admin");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_rban(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 4) {
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /rban [playerid] [reason]");
			if(!strlen(tmp2)) return SendClientMessage(playerid, red, "ERROR: You must give a reason");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[256], banstring[256];
			player1 = strval(tmp);
			new tmp3[50];
			GetPlayerIp(player1,tmp3,50);
		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
				GetPlayerName(player1, playername, sizeof(playername)); GetPlayerName(playerid, adminname, sizeof(adminname));
				new year,month,day,hour,minuite,second; getdate(year, month, day); gettime(hour,minuite,second);
				CMDMessageToAdmins(playerid,"RBAN");
				format(string,sizeof(string),"%s has been range banned by Administrator %s [Reason: %s] [Date: %d/%d/%d] [Time: %d:%d]",playername,adminname,params[2],day,month,year,hour,minuite);
				SendClientMessageToAll(red,string);
				print(string);
				SaveToFile("BanLog",string);
				format(banstring,sizeof(banstring),"You have been range banned by Administrator %s [Reason: %s] [Date: %d/%d/%d] [Time: %d:%d] IP: %s",adminname,params[2],day,month,year,hour,minuite, tmp3);
				SendClientMessage(player1, red,banstring);
				if(udb_Exists(PlayerName2(player1)) && PlayerInfo[player1][LoggedIn] == 1) dUserSetINT(PlayerName2(player1)).("banned",1);
				GetPlayerIp(player1,tmp3,sizeof(tmp3));
	            strdel(tmp3,strlen(tmp3)-2,strlen(tmp3));
    	        format(tmp3,128,"%s**",tmp3);
				format(tmp3,128,"banip %s",tmp3);
            	SendRconCommand(tmp3);
				Kick(player1);
				BanEx(player1, banstring);
				return 1;
			} else return SendClientMessage(playerid, red, "Player is not connected or is yourself or is the highest level admin");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_sban(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] > 5) {
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /sban [playerid] [reason]");
			if(!strlen(tmp2)) return SendClientMessage(playerid, red, "ERROR: You must give a reason");
            new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[256], banstring[256];
			player1 = strval(tmp);
			new tmp3[50];
			GetPlayerIp(player1,tmp3,50);
		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
				GetPlayerName(player1, playername, sizeof(playername)); GetPlayerName(playerid, adminname, sizeof(adminname));
				new year,month,day,hour,minuite,second; getdate(year, month, day); gettime(hour,minuite,second);
				CMDMessageToAdmins(playerid,"SBAN");
				format(string,sizeof(string),"%s has been brutally raped and Rage Banned by Administrator %s [Reason: %s] [Date: %d/%d/%d] [Time: %d:%d]",playername,adminname,params[2],day,month,year,hour,minuite);
				SendClientMessageToAll(red,string);
				print(string);
				SaveToFile("BanLog",string);
				format(banstring,sizeof(banstring),"You have been Brutally raped and Rage Banned by Administrator %s. Reason: %s, [Date: %d/%d/%d] [Time: %d:%d], Your IP:", adminname, params[2],day,month,year,hour,minuite, tmp3);
				SendClientMessage(player1, red,banstring);
				GetPlayerIp(player1,tmp3,sizeof(tmp3));
	            strdel(tmp3,strlen(tmp3)-2,strlen(tmp3));
    	        format(tmp3,128,"%s**",tmp3);
				format(tmp3,128,"banip %s",tmp3);
             	SendRconCommand(tmp3);
                if(udb_Exists(PlayerName2(player1)) && PlayerInfo[player1][LoggedIn] == 1) dUserSetINT(PlayerName2(player1)).("banned",1);
				Kick(player1);
                BanEx(player1, banstring);
			} else return SendClientMessage(playerid, red, "Player is not connected or is yourself or is the highest level admin");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
	return 1;
}

dcmd_testban(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 5) {
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /testban [playerid] [reason]");
			if(!strlen(tmp2)) return SendClientMessage(playerid, red, "ERROR: You must give a reason");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);
			new tmp3[50];
			GetPlayerIp(player1,tmp3,50);
		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
				GetPlayerName(player1, playername, sizeof(playername)); GetPlayerName(playerid, adminname, sizeof(adminname));
				new year,month,day,hour,minuite,second; getdate(year, month, day); gettime(hour,minuite,second);
				format(string,sizeof(string),"%s has been banned by Administrator %s [Reason: %s] [Date: %d/%d/%d] [Time: %d:%d] IP: %s",playername,adminname,params[2],day,month,year,hour,minuite, tmp3);
				SendClientMessageToAll(red,string);
				print(string);
				if(udb_Exists(PlayerName2(player1)) && PlayerInfo[player1][LoggedIn] == 1) dUserSetINT(PlayerName2(player1)).("banned",0);
				format(string,sizeof(string),"You are Banned by Administrator %s. Reason: %s", adminname, params[2] );
				SaveToFile("KickLog",string); print(string); return Kick(player1);
			} else return SendClientMessage(playerid, red, "Player is not connected or is yourself or is the highest level admin");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}
dcmd_banmsg(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 5) {
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /banmsg [playerid] [reason]");
			if(!strlen(tmp2)) return SendClientMessage(playerid, red, "ERROR: You must give a reason");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);
			new tmp3[50];
			GetPlayerIp(player1,tmp3,50);

		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
				GetPlayerName(player1, playername, sizeof(playername)); GetPlayerName(playerid, adminname, sizeof(adminname));
				new year,month,day,hour,minuite,second; getdate(year, month, day); gettime(hour,minuite,second);
				format(string,sizeof(string),"%s has been banned by Administrator %s [Reason: %s] [Date: %d/%d/%d] [Time: %d:%d] IP: %s",playername,adminname,params[2],day,month,year,hour,minuite, tmp3);
				SendClientMessageToAll(red,string);
				print(string);
				if(udb_Exists(PlayerName2(player1)) && PlayerInfo[player1][LoggedIn] == 1) dUserSetINT(PlayerName2(player1)).("banned",0);
				format(string,sizeof(string),"You are Banned by Administrator %s. Reason: %s", adminname, params[2] );
			} else return SendClientMessage(playerid, red, "Player is not connected or is yourself or is the highest level admin");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
	return 1;
}

dcmd_runban(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 5) {
		        new tmp[256], Index;		tmp = strtok(params,Index);
		        if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /runban [playername]");
	    	    new unbanname[256], tmp2[256], tmp3[256], adminname[MAX_PLAYER_NAME], string[128];
	        	unbanname = tmp;
		        if(udb_Exists(unbanname))
		        {
				format(unbanname,sizeof(unbanname),"/ladmin/users/%s.sav",udb_encode(params));
			    dUserSetINT(unbanname).("banned", 0);
				CMDMessageToAdmins(playerid,"RUNBAN");
			    tmp2 = dini_Get(unbanname,"ip");
	            strdel(tmp2,strlen(tmp2)-2,strlen(tmp2));
    	        format(tmp2,128,"%s**",tmp2);
				format(tmp2,128,"unbanip %s",tmp2);
            	SendRconCommand(tmp2);
				SendRconCommand("reloadbans");
                GetPlayerName(playerid, adminname, sizeof(adminname));
			    tmp3 = dini_Get(unbanname,"ip");
				format(string,sizeof(string),"{00FFFF}Administrator %s has unbanned {FFAF24}\"%s's\"{00FFFF} Account and s/he's IP: %s!",adminname,tmp,tmp3);
		    	SendClientMessageToAll(green,string);
				print(string);
				SaveToFile("RUnbanLog",string);
				return 1;
	            }
	            else return SendClientMessage(playerid, red, "ERROR: No player with this name.");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_orban(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 5) {
		        new tmp[256], Index;		tmp = strtok(params,Index);
		        if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /orban [playername]");
	    	    new orbanname[256], tmp2[256], tmp3[256], adminname[MAX_PLAYER_NAME], string[128];
	        	orbanname = tmp;
		        if(udb_Exists(orbanname))
		        {
                if(!strcmp(orbanname, "Filipbg") || !strcmp(orbanname, "Emily_Lafernus")) return SendClientMessage(playerid, COLOR_RED, "ERROR: You CANNOT ban Filipbg or Emily_Lafernus! >:C");
				format(orbanname,sizeof(orbanname),"/ladmin/users/%s.sav",udb_encode(params));
			    dUserSetINT(orbanname).("banned", 1);
				CMDMessageToAdmins(playerid,"ORBan");
			    tmp2 = dini_Get(orbanname,"ip");
	            strdel(tmp2,strlen(tmp2)-2,strlen(tmp2));
    	        format(tmp2,128,"%s**",tmp2);
				format(tmp2,128,"banip %s",tmp2);
            	SendRconCommand(tmp2);
                GetPlayerName(playerid, adminname, sizeof(adminname));
			    tmp3 = dini_Get(orbanname,"ip");
				format(string,sizeof(string),"{00FFFF}Administrator %s has Rage Banned {FFAF24}\"%s's\"{00FFFF} Account and s/he's IP: %s!",adminname,tmp,tmp3);
		    	SendClientMessageToAll(green,string);
				print(string);
				SaveToFile("BanLog",string);
				return 1;
	            }
	            else return SendClientMessage(playerid, red, "ERROR: No player with this name.");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_console(playerid, params[])
{
	#pragma unused params
	new CONSOLE1[2000];
	if (PlayerInfo[playerid][Level] == 6 || IsPlayerAdmin(playerid))
	{
		strcat(CONSOLE1, "Close Server\n");
		strcat(CONSOLE1, "Change Host Name\n");
		strcat(CONSOLE1, "Change Gamemode Name\n");
		strcat(CONSOLE1, "Change Map Name\n");
		strcat(CONSOLE1, "Execute server cfg\n");
		strcat(CONSOLE1, "Kick Player\n");
		strcat(CONSOLE1, "Ban Player\n");
		strcat(CONSOLE1, "Change Gamemode\n");
		strcat(CONSOLE1, "Load Next Gamemode\n");
		strcat(CONSOLE1, "Reload Bans\n");
		strcat(CONSOLE1, "Reload Log\n");
		strcat(CONSOLE1, "Ban IP\n");
		strcat(CONSOLE1, "Unban IP\n");
		strcat(CONSOLE1, "Change Gravity\n");
		strcat(CONSOLE1, "Change Weather\n");
		strcat(CONSOLE1, "Load Filterscript\n");
		strcat(CONSOLE1, "Unload Filterscript\n");
		strcat(CONSOLE1, "Reload Filterscript\n");
		strcat(CONSOLE1, "Change Server URL\n");
		ShowPlayerDialog(playerid, CONSOLE, DIALOG_STYLE_LIST, "--==--== RCON - CONSOLE ==--==--", CONSOLE1, "Select", "Cancel");
		SendClientMessage(playerid, 0xFFFFFFFF, "{FFFF00}RCON CONSOLE Loaded");
	}
	else
	{
		SendClientMessage(playerid, 0xFFFFFFFF, "{FF0000}[ERROR]: Only RCON Admins have access to this!");
		return 0;
	}
	return 1;
}

dcmd_slap(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 1) {
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /slap [playerid] [reason/with]");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);
		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
				GetPlayerName(player1, playername, sizeof(playername));		GetPlayerName(playerid, adminname, sizeof(adminname));
				CMDMessageToAdmins(playerid,"SLAP");
		        new Float:Health, Float:x, Float:y, Float:z; GetPlayerHealth(player1,Health); SetPlayerHealth(player1,Health-25);
				GetPlayerPos(player1,x,y,z); SetPlayerPos(player1,x,y,z+5); PlayerPlaySound(playerid,1190,0.0,0.0,0.0); PlayerPlaySound(player1,1190,0.0,0.0,0.0);
				if(strlen(tmp2)) {
					format(string,sizeof(string),"You have been slapped by Administrator %s %s ",adminname,params[2]);	SendClientMessage(player1,red,string);
					format(string,sizeof(string),"You have slapped %s %s ",playername,params[2]); return SendClientMessage(playerid,blue,string);
				} else {
					format(string,sizeof(string),"You have been slapped by Administrator %s ",adminname);	SendClientMessage(player1,red,string);
					format(string,sizeof(string),"You have slapped %s",playername); return SendClientMessage(playerid,blue,string); }
			} else return SendClientMessage(playerid, red, "Player is not connected or is the highest level admin");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_explode(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 3) {
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /explode [playerid] [reason]");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128], string2[128], string3[128];
			player1 = strval(tmp);
		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
				GetPlayerName(player1, playername, sizeof(playername)); 	GetPlayerName(playerid, adminname, sizeof(adminname));
				CMDMessageToAdmins(playerid,"EXPLODE");
				new Float:burnx, Float:burny, Float:burnz; GetPlayerPos(player1,burnx, burny, burnz); CreateExplosion(burnx, burny , burnz, 7,10.0); SetPlayerHealth(player1, 0.0);
				if(strlen(tmp2)) {
					format(string,sizeof(string),"You have been exploded by Administrator %s [reason: %s]",adminname,params[2]); SendClientMessage(player1,blue,string);
					format(string2,sizeof(string2),"You have exploded %s [reason: %s]", playername,params[2]); return SendClientMessage(playerid,blue,string2);
				} else {
					SendClientMessage(player1,blue,"Lord Hellrocker: Rest In Peace.");
					format(string3,sizeof(string3),"{C0C0C0}Lord Hellrocker: {FF0000}%s has been died by Mysteroious Explosion.", playername); return SendClientMessageToAll(red,string3); }
			} else return SendClientMessage(playerid, red, "Player is not connected or is the highest level admin");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_jail(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 2) {
		    new tmp[256], tmp2[256], tmp3[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index), tmp3 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /jail [playerid] [minutes] [reason]");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);
		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
				if(PlayerInfo[player1][Jailed] == 0 || IsPlayerInAnyVehicle(player1)) {
                    new vehicle;
					GetPlayerName(player1, playername, sizeof(playername)); GetPlayerName(playerid, adminname, sizeof(adminname));
                    vehicle = GetPlayerVehicleID(player1);
					RemovePlayerFromVehicle(player1);
					DestroyVehicle(vehicle);
					new jtime = strval(tmp2);
					if(jtime == 0) jtime = 9999;
			       	CMDMessageToAdmins(playerid,"JAIL");
					PlayerInfo[player1][JailTime] = jtime*1000*60;
    			    SetTimerEx("JailPlayer",5000,0,"d",player1);
		    	    SetTimerEx("Jail1",1000,0,"d",player1);
					PlayerInfo[player1][Jailed] = 1;
					if(jtime == 9999) {
						if(!strlen(params[strlen(tmp2)+1])) format(string,sizeof(string),"Administrator/VIP %s has jailed %s ",adminname, playername);
						else format(string,sizeof(string),"Administrator/VIP %s has jailed %s [reason: %s]",adminname, playername, params[strlen(tmp)+1] );
   					} else {
						if(!strlen(tmp3)) format(string,sizeof(string),"Administrator/VIP %s has jailed %s for %d minutes",adminname, playername, jtime);
						else format(string,sizeof(string),"Administrator/VIP %s has jailed %s for %d minutes [reason: %s]",adminname, playername, jtime, params[strlen(tmp2)+strlen(tmp)+1] );
					}
	    			return SendClientMessageToAll(blue,string);
				} else return SendClientMessage(playerid, red, "Player is already in jail");
			} else return SendClientMessage(playerid, red, "Player is not connected or is the highest level admin");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_unjail(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 2) {
		    new tmp[256], Index; tmp = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /jail [playerid]");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);
		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
				if(PlayerInfo[player1][Jailed] == 1) {
					GetPlayerName(player1, playername, sizeof(playername)); GetPlayerName(playerid, adminname, sizeof(adminname));
					format(string,sizeof(string),"Administrator/VIP %s has unjailed you",adminname);	SendClientMessage(player1,blue,string);
					format(string,sizeof(string),"Administrator/VIP %s has unjailed %s",adminname, playername);
					JailRelease(player1);
					return SendClientMessageToAll(blue,string);
				} else return SendClientMessage(playerid, red, "Player is not in jail");
			} else return SendClientMessage(playerid, red, "Player is not connected or is the highest level admin");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_jailed(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][LoggedIn] == 1)
	{
		if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 1)
		{
	 		new bool:First2 = false;
	 		new Count, i;
		    new string[128];
			new adminname[MAX_PLAYER_NAME];
		    for(i = 0; i < MAX_PLAYERS; i++)
			if(IsPlayerConnected(i) && PlayerInfo[i][Jailed])
			Count++;
			if(Count == 0)
			return SendClientMessage(playerid,red, "No players are Jailed!");

		    for(i = 0; i < MAX_PLAYERS; i++)
			if(IsPlayerConnected(i) && PlayerInfo[i][Jailed])
			{
 			GetPlayerName(i, adminname, sizeof(adminname));
			if(!First2)
			{
			format(string, sizeof(string), "Jailed Players: (%d)%s", i,adminname); First2 = true;
			}
   			else format(string,sizeof(string),"%s, (%d)%s ",string,i,adminname);
	        }
		    return SendClientMessage(playerid,yellow,string);
		}
		else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	}
	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_freeze(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 2) {
		    new tmp[256], tmp2[256], tmp3[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index), tmp3 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /freeze [playerid] [minutes] [reason]");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);
		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
				if(PlayerInfo[player1][Frozen] == 0) {
					GetPlayerName(player1, playername, sizeof(playername)); GetPlayerName(playerid, adminname, sizeof(adminname));
					new ftime = strval(tmp2);
					if(ftime == 0) ftime = 9999;

			       	CMDMessageToAdmins(playerid,"FREEZE");
					TogglePlayerControllable(player1,false); PlayerInfo[player1][Frozen] = 1; PlayerPlaySound(player1,1057,0.0,0.0,0.0);
					PlayerInfo[player1][FreezeTime] = ftime*1000*60;
			        FreezeTimer[player1] = SetTimerEx("UnFreezeMe",PlayerInfo[player1][FreezeTime],0,"d",player1);
					SetPVarInt(player1, "Frozen", 1);
					if(ftime == 9999) {
						if(!strlen(params[strlen(tmp2)+1])) format(string,sizeof(string),"Admin/VIP %s has frozen %s ",adminname, playername);
						else format(string,sizeof(string),"Admin/VIP %s has frozen %s [reason: %s]",adminname, playername, params[strlen(tmp)+1] );
	   				} else {
						if(!strlen(tmp3)) format(string,sizeof(string),"Admin/VIP %s has frozen %s for %d minutes",adminname, playername, ftime);
						else format(string,sizeof(string),"Admin/VIP %s has frozen %s for %d minutes [reason: %s]",adminname, playername, ftime, params[strlen(tmp2)+strlen(tmp)+1] );
					}
		    		return SendClientMessageToAll(blue,string);
				} else return SendClientMessage(playerid, red, "Player is already frozen");
			} else return SendClientMessage(playerid, red, "Player is not connected or is the highest level admin");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}
dcmd_myarmour(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][pVip] >= 1 || PlayerInfo[playerid][Level] >= 2)
	{
	  SetPlayerArmour(playerid, 50.0);
	  return 1;
	}
	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_armour(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][pVip] >= 2 || PlayerInfo[playerid][Level] >= 3)
	{
	  SetPlayerArmour(playerid, 100.0);
	  return 1;
	}
    else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_vweaps(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][pVip] >= 2 || PlayerInfo[playerid][Level] >= 2)
	{
		GivePlayerWeapon(playerid,31,1000); GivePlayerWeapon(playerid,16,1000);
	 	GivePlayerWeapon(playerid,34,1000); GivePlayerWeapon(playerid,28,1000);
		GivePlayerWeapon(playerid,14,1000); GivePlayerWeapon(playerid,46,1000);
		GivePlayerWeapon(playerid,9,1);
		return 1;
	}
	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_unfreeze(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
	    if(PlayerInfo[playerid][Level] >= 1 || IsPlayerAdmin(playerid) || PlayerInfo[playerid][pVip] >= 2) {
		    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /unfreeze [playerid]");
	    	new player1, string[128];
			player1 = strval(params);
		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
		 	    if(PlayerInfo[player1][Frozen] == 1) {
			       	CMDMessageToAdmins(playerid,"UNFREEZE");
					UnFreezeMe(player1);
					format(string,sizeof(string),"Admin/VIP %s has unfrozen you", PlayerName2(playerid) ); SendClientMessage(player1,blue,string);
					format(string,sizeof(string),"Admin/VIP %s has unfrozen %s", PlayerName2(playerid), PlayerName2(player1));
		    		return SendClientMessageToAll(blue,string);
				} else return SendClientMessage(playerid, red, "Player is not frozen");
			} else return SendClientMessage(playerid, red, "Player is not connected or is the highest level admin");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_frozen(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][LoggedIn] == 1)
	{
		if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 1)
		{
	 		new bool:First2 = false;
			new Count,string[128], i;
			new adminname[MAX_PLAYER_NAME];
		    for(i = 0; i < MAX_PLAYERS; i++)
			if(IsPlayerConnected(i) && PlayerInfo[i][Frozen])
			Count++;
			if(Count == 0)
			return SendClientMessage(playerid,red, "No players are Frozen!");

		    for(i = 0; i < MAX_PLAYERS; i++)
			if(IsPlayerConnected(i) && PlayerInfo[i][Frozen])
			{
	    		GetPlayerName(i, adminname, sizeof(adminname));
				if(!First2)
				{
				format(string, sizeof(string), "Frozen Players: (%d)%s", i,adminname);
				First2 = true;
				}
		        else format(string,sizeof(string),"%s, (%d)%s ",string,i,adminname);
	        }
		    return SendClientMessage(playerid,yellow,string);
		}
		else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	}
	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You need to be logged in to use this command!");
}

dcmd_mute(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 2) {
		    new tmp[256], tmp2[256], tmp3[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index), tmp3 = strtok(params,Index);
		    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /mute [playerid] [minutes] [reason]");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);
		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
		 	    if(PlayerInfo[player1][Muted] == 0) {
                    GetPlayerName(player1, playername, sizeof(playername)); 	GetPlayerName(playerid, adminname, sizeof(adminname));
					new mtime = strval(tmp2);
					if(mtime == 0) mtime = 9999;

			       	CMDMessageToAdmins(playerid,"MUTE");
					PlayerInfo[player1][MuteTime] = mtime*1000*60;
    			    SetTimerEx("MutePlayer",5000,0,"d",player1);
		    	    SetTimerEx("Mute1",1000,0,"d",player1);
		        	PlayerInfo[player1][Muted] = 1;
					PlayerPlaySound(player1,1057,0.0,0.0,0.0);  PlayerInfo[player1][Muted] = 1; PlayerInfo[player1][MuteWarnings] = 0;
                    if(mtime == 9999) {
                        if(!strlen(params[strlen(tmp2)+1])) format(string,sizeof(string),"Administrator/VIP %s has Muted %s ",adminname, playername);
						else format(string,sizeof(string),"Administrator/VIP %s has Muted %s [reason: %s]",adminname, playername, params[strlen(tmp)+1] );
   					} else {
						if(!strlen(tmp3)) format(string,sizeof(string),"Administrator/VIP %s has Muted %s for %d minutes",adminname, playername, mtime);
						else format(string,sizeof(string),"Administrator/VIP %s has Muted %s for %d minutes [reason: %s]",adminname, playername, mtime, params[strlen(tmp2)+strlen(tmp)+1] );
					}
					return SendClientMessageToAll(blue,string);
				} else return SendClientMessage(playerid, red, "Player is not Muted");
			} else return SendClientMessage(playerid, red, "Player is not connected or is the highest level admin");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}


dcmd_unmute(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 2) {
		    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /unmute [playerid]");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(params);

		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
		 	    if(PlayerInfo[player1][Muted] == 1) {
					GetPlayerName(player1, playername, sizeof(playername)); 	GetPlayerName(playerid, adminname, sizeof(adminname));
					CMDMessageToAdmins(playerid,"UNMUTE");
					PlayerPlaySound(player1,1057,0.0,0.0,0.0);  PlayerInfo[player1][Muted] = 0; PlayerInfo[player1][MuteWarnings] = 0;
					format(string,sizeof(string),"You have been unmuted by Administrator %s",adminname); SendClientMessage(player1,blue,string);
					format(string,sizeof(string),"You have unmuted %s", playername); return SendClientMessage(playerid,blue,string);
				} else return SendClientMessage(playerid, red, "Player is not muted");
			} else return SendClientMessage(playerid, red, "Player is not connected or is the highest level admin");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_muted(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 1) {
	 		new bool:First2 = false, Count, adminname[MAX_PLAYER_NAME], string[128], i;
		    for(i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && PlayerInfo[i][Muted]) Count++;
			if(Count == 0) return SendClientMessage(playerid,red, "No players are muted");

		    for(i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && PlayerInfo[i][Muted]) {
	    		GetPlayerName(i, adminname, sizeof(adminname));
				if(!First2) { format(string, sizeof(string), "Muted Players: (%d)%s", i,adminname); First2 = true; }
		        else format(string,sizeof(string),"%s, (%d)%s ",string,i,adminname);
	        }
		    return SendClientMessage(playerid,COLOR_WHITE,string);
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_akill(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
	    if(PlayerInfo[playerid][Level] >= 1|| IsPlayerAdmin(playerid)) {
		    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /akill [playerid]");
	    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(params);

		 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
				if( (PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel] ) )
					return SendClientMessage(playerid, red, "You cannot akill the highest level admin");
				CMDMessageToAdmins(playerid,"AKILL");
				GetPlayerName(player1, playername, sizeof(playername));	GetPlayerName(playerid, adminname, sizeof(adminname));
				format(string,sizeof(string),"Administrator %s has killed you",adminname);	SendClientMessage(player1,blue,string);
				format(string,sizeof(string),"You have killed %s",playername); SendClientMessage(playerid,blue,string);
				PlayerInfo[playerid][pDeaths] ++;
				return SetPlayerHealth(player1,0.0);
			} else return SendClientMessage(playerid, red, "Player is not connected");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_musicall(playerid, params[])
{
   #pragma unused params
   if(PlayerInfo[playerid][Level] >= 2 || IsPlayerAdmin(playerid))
   {
       new url[3000], adminexec[MAX_PLAYER_NAME];
       if(sscanf(params, "s[3000]i", url)) return SendClientMessage(playerid, red, "Usage: /musicall [.mp3 URL]");
       format(url, sizeof(url), "%s", url);
	   GetPlayerName(playerid, adminexec, sizeof(adminexec));
       foreach(Player, i)
       {
		   new playmsg[200];
		   format(playmsg, sizeof(playmsg), "Admin %s started playing an audio stream for all players.", adminexec);
	       PlayAudioStreamForPlayer(i,url);
		   SendClientMessage(i, blue, playmsg);
	   }
   }
   else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
   return 1;
}

dcmd_djplay(playerid, params[])
{
   #pragma unused params
   if(PlayerInfo[playerid][isDJ] == 1)
   {
       new url[3000], adminexec[MAX_PLAYER_NAME];
       if(sscanf(params, "s[3000]i", url)) return SendClientMessage(playerid, red, "Usage: /djplay [.mp3 Link]");
       format(url, sizeof(url), "%s", url);
	   GetPlayerName(playerid, adminexec, sizeof(adminexec));
       foreach(Player, i)
       {
		   new playmsg[200];
		   format(playmsg, sizeof(playmsg), "DJ %s has started a song for all players", adminexec);
	       PlayAudioStreamForPlayer(i,url);
		   SendClientMessage(i, blue, playmsg);
	   }
   }
   else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You're not a DJ to use this command!");
   return 1;
}

dcmd_djstop(playerid, params[])
{
   #pragma unused params
   if(PlayerInfo[playerid][isDJ] == 1)
   {
       new adminexec[MAX_PLAYER_NAME];
	   GetPlayerName(playerid, adminexec, sizeof(adminexec));
       foreach(Player, i)
       {
		   new playmsg[200];
		   format(playmsg, sizeof(playmsg), "DJ %s has stopped the song!", adminexec);
	       StopAudioStreamForPlayer(i);
		   SendClientMessage(i, blue, playmsg);
	   }
   }
   else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You're not a DJ to use this command!");
   return 1;
}

dcmd_setdj(playerid, params[])
{
   if(PlayerInfo[playerid][Level] >= 6)
   {
   new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
   if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red,"Usage: /setdj [PlayerID] [1 - Yes, 0 - No]");
   new player1, DJ, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
   player1 = strval(tmp);
   DJ = strval(tmp2);
   if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
   GetPlayerName(player1, playername, sizeof(playername));	GetPlayerName(playerid, adminname, sizeof(adminname));
   format(string, sizeof(string), "You have set %s's DJ status to %d", playername, DJ);
   SendClientMessage(playerid,blue,string);
   format(string, sizeof(string), "Manager/CEO %s has set your DJ status to %d", adminname, DJ);
   SendClientMessage(player1,blue,string);
   PlayerInfo[player1][isDJ] = DJ;
   CMDMessageToAdmins(playerid,"SetDJ");
   return 1;
   }
   else return SendClientMessage(playerid, red, "Player is not connected");
   }
   else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_stopall(playerid, params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 2 || IsPlayerAdmin(playerid))
    {
		foreach(Player, i)
		{
			StopAudioStreamForPlayer(i);
			SendClientMessage(i, blue, "An admin has stopped the audio stream.");
		}
    }
	else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}

dcmd_stopmusicall(playerid, params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 2 || IsPlayerAdmin(playerid))
    {
		foreach(Player, i)
		{
			StopAudioStreamForPlayer(i);
			SendClientMessage(i, blue, "An admin has stopped the audio stream.");
		}
    }
	else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}

dcmd_weaps(playerid,params[])
{
   if(PlayerInfo[playerid][Level] >= 1 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /weaps [playerid]");
    	new player1, string[128], string2[64], WeapName[24], slot, weap, ammo, Count, x;
		player1 = strval(params);

	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			format(string2,sizeof(string2),"[>> %s Weapons (id:%d) <<]", PlayerName2(player1), player1); SendClientMessage(playerid,blue,string2);
			for (slot = 0; slot < 14; slot++) {	GetPlayerWeaponData(player1, slot, weap, ammo); if( ammo != 0 && weap != 0) Count++; }
			if(Count < 1) return SendClientMessage(playerid,blue,"Player has no weapons");

			if(Count >= 1)
			{
				for (slot = 0; slot < 14; slot++)
				{
					GetPlayerWeaponData(player1, slot, weap, ammo);
					if( ammo != 0 && weap != 0)
					{
						GetWeaponName(weap, WeapName, sizeof(WeapName) );
						if(ammo == 65535 || ammo == 1) format(string,sizeof(string),"%s%s (1)",string, WeapName );
						else format(string,sizeof(string),"%s%s (%d)",string, WeapName, ammo );
						x++;
						if(x >= 5)
						{
						    SendClientMessage(playerid, blue, string);
						    x = 0;
							format(string, sizeof(string), "");
						}
						else format(string, sizeof(string), "%s,  ", string);
					}
			    }
				if(x <= 4 && x > 0) {
					string[strlen(string)-3] = '.';
				    SendClientMessage(playerid, blue, string);
				}
		    }
		    return 1;
		} else return SendClientMessage(playerid, red, "Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_aka(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 1 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /aka [playerid]");
    	new player1, playername[MAX_PLAYER_NAME], str[128], tmp3[50];
		player1 = strval(params);
	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
  		  	GetPlayerIp(player1,tmp3,50);
			GetPlayerName(player1, playername, sizeof(playername));
		    format(str,sizeof(str),"AKA: [%s id:%d] [%s] %s", playername, player1, tmp3, dini_Get("ladmin/config/aka.txt",tmp3) );
	        return SendClientMessage(playerid,blue,str);
		} else return SendClientMessage(playerid, red, "Player is not connected or is yourself");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_screen(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 2) {
	    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /screen [playerid] [text]");
    	new player1, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
		player1 = strval(params);

	 	if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID && player1 != playerid && (PlayerInfo[player1][Level] != ServerInfo[MaxAdminLevel]) ) {
			GetPlayerName(player1, playername, sizeof(playername));		GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"SCREENf");
			format(string,sizeof(string),"Administrator %s has sent you a screen message",adminname);	SendClientMessage(player1,blue,string);
			format(string,sizeof(string),"You have sent %s a screen message (%s)", playername, params[2]); SendClientMessage(playerid,blue,string);
			return GameTextForPlayer(player1, params[2],4000,3);
		} else return SendClientMessage(playerid, red, "Player is not connected or is yourself or is the highest level admin");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_laston(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 2) {
   	new tmp2[256], file[256], player1, adminname[MAX_PLAYER_NAME], str[128];
    player1 = strval(params);
	if(!strlen(params))
	{
	GetPlayerName(playerid, adminname, sizeof(adminname));
    format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(adminname));
	if(!fexist(file)) return SendClientMessage(playerid, red, "Error: File doesnt exist, player isnt registered");
	tmp2 = dini_Get(file,"LastOn");
	if(dUserINT(PlayerName2(playerid)).("LastOn")==0) {	format(str, sizeof(str),"Never"); tmp2 = str; }
	format(str, sizeof(str),"You were last on the server on %s",tmp2);
    return SendClientMessage(playerid, red, str);
    }
    CMDMessageToAdmins(playerid,"LASTON");
	format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(params));
    if(!fexist(file)) return SendClientMessage(playerid, red, "Error: File doesnt exist, player isnt registered");
    if(dUserINT(PlayerName2(player1)).("LastOn")==0) { format(str, sizeof(str),"Never"); tmp2 = str;
    } else { tmp2 = dini_Get(file,"LastOn"); }
    format(str, sizeof(str),"%s was last on the server on %s",params,tmp2);
	return SendClientMessage(playerid, red, str);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_seen(playerid,params[]) {
    
   	new tmp2[256], file[256], player1, str[128];
    player1 = strval(params);
    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /seen PlayerName");
	format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(params));
    if(!fexist(file)) return SendClientMessage(playerid, red, "Error: File doesnt exist, player isnt registered");
    if(dUserINT(PlayerName2(player1)).("LastOn")==0) { format(str, sizeof(str),"Never"); tmp2 = str;
    } else { tmp2 = dini_Get(file,"LastOn"); }
    format(str, sizeof(str),"{FF8000}%s {FFFFFF}was last on the server on {FF0000}%s\n",params,tmp2);
	return ShowPlayerDialog(playerid, DIALOG_SEEN, DIALOG_STYLE_MSGBOX, "{00FF00}Last Seen On Server:\n", str, "OK", "");
}

dcmd_admins(playerid,params[])
{
    #pragma unused params
    new count, bool:online, string[512];
    for(new i,g=GetMaxPlayers(); i < g; i++)
	{
    if(IsPlayerConnected(i))
        {
            if(1 <= PlayerInfo[i][Level] <= 6 && PlayerInfo[i][Hide] == 0)
            {
                online = true;
                switch(PlayerInfo[i][Level])
                {
                                        case 1: Ranks = "{FF0000}Trial Moderator{FF0000}";
                                        case 2: Ranks = "{FF0000}Moderator{FF0000}";
                                        case 3: Ranks = "{07EB13}Admin{07EB13}";
                                        case 4: Ranks = "{07EB13}Senior Admin{07EB13}";
                                        case 5: Ranks = "{00FFFF}Head Admin{00FFFF}";
                                        case 6: Ranks = "{0049FF}Manager/CEO{FF0000}";
                }
                if(IsPlayerAdmin(i)) Ranks = "{00FF00}RCON{FF0000}";
                format(string,sizeof(string), "%s {%06x}%s {C0C0C0}[%s{C0C0C0}],\n",string,GetPlayerColor(i) >>> 8,PlayerName2(i),Ranks);
				count++;
                /*if(count >= 1)
                {
                    format(string,sizeof(string),"\n%s %s\n\n{FFFFFF}If you saw a hacker/rulebreaker use {FFFF00}/report\n{FFFFFF}Contact the admins if you need any help",string);
                    string = "";
					ShowPlayerDialog(playerid, DIALOG_ADMINS, DIALOG_STYLE_MSGBOX, "{00FF00}Admins Online:{FF0000}", string, "OK", "");
					count = 0;
                }*/
            }
        }
    }
	if(count)
    {
       format(string,sizeof(string),"\n%s %s\n\n{FFFFFF}If you saw a hacker/rulebreaker use {FFFF00}/report\n{FFFFFF}Contact the admins if you need any help",string);
       ShowPlayerDialog(playerid, DIALOG_ADMINS, DIALOG_STYLE_MSGBOX, "{00FF00}Admins Online:{FF0000}", string, "OK", "");
	}
    if(!online) SendClientMessage(playerid,red,"No admins online at the moment");
    return 1;
    }


dcmd_djs(playerid,params[])
{
    #pragma unused params
    new count, bool:online, string[512];
    for(new i,g=GetMaxPlayers(); i < g; i++)
	{
    if(IsPlayerConnected(i))
        {
            if(PlayerInfo[i][isDJ] == 1)
            {
                online = true;
                format(string,sizeof(string), "%s %s, ",string,PlayerName2(i));
                count++;
                if(count == 3)
                {
                    format(string,sizeof(string),"{00FFFF}DJ's:{FF0000} %s %s",string);
                    SendClientMessage(playerid, blue, string);
                    string = "";
                    count = 0;
                }
            }
        }
    }
    if(count)
    {
        format(string,sizeof(string),"{00FFFF}DJ's:{FF0000} %s %s",string);
        SendClientMessage(playerid, red, string);
    }
    if(!online) SendClientMessage(playerid,red,"No DJ's online at the moment");
    return 1;
    }

dcmd_djcmds(playerid, params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][isDJ] == 1 || PlayerInfo[playerid][Level] >= 2)
    {
        new bigstring[1000];
	    strcat(bigstring, "{80FFFF}/djplay - Plays .mp3 ULR's For All Players\n\
	                       /djstop - Stops the song\n");
        strcat(bigstring,"/requests - To See all song requests\n\
					       /djs - See All DJ's Online\n\
					       /djtag - Enable/Disable DJ tag\n\
					       /djarea - DJ Area\n\
						   DJ Chat With '^'\n");
        ShowPlayerDialog(playerid, DIALOG_DJCMDS, DIALOG_STYLE_MSGBOX, "{FF0000}TBS's DJ system commands:", bigstring, "Close", "");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}

dcmd_djhelp(playerid, params[])
{
   dcmd_djcmds(playerid, params);
   return 1;
}

dcmd_hide(playerid,params[])
{
    #pragma unused params
	if (PlayerInfo[playerid][Level] >= 1)
	{
	    if (PlayerInfo[playerid][Hide] == 1)
 		return SendClientMessage(playerid,red,"ERROR: You are already have hidden in the admin list!");

 		PlayerInfo[playerid][Hide] = 1;
   		return SendClientMessage(playerid,green,"You are now hidden from the admin list");
	}
    return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_unhide(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 1)
	{
 		if (PlayerInfo[playerid][Hide] != 1)
 		return SendClientMessage(playerid,red,"ERROR: You are not hidden in the admin list!");
  		PlayerInfo[playerid][Hide] = 0;
   		return SendClientMessage(playerid,green,"You are now visible in the admin list");
	}
 	return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_aduty(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 3)
	{
	    if(PlayerInfo[playerid][OnDuty] == 0)
	    {
	    SetPVarInt(playerid, "AdminProtect", 1);
	    PlayerInfo[playerid][OnDuty] = 1;
	    SendClientMessage(playerid,green,"You are now on \"Duty Mode\"");
	    new string[100];

        format(string, sizeof(string),"ADMIN: %s is on duty now!", PlayerName2(playerid));
        SendClientMessageToAll(COLOR_GREEN1,string);
	    SetPlayerHealth(playerid, 100000);
	    GivePlayerWeapon(playerid, 31, 9999);
	    return  GivePlayerWeapon(playerid, 35, 9999);
		}
		else
		{
		PlayerInfo[playerid][OnDuty] = 0;
		SetPVarInt(playerid, "AdminProtect", 0);
		SendClientMessage(playerid,orange,"You are now in \"Playing Mode\"-|");
        new string[100];
		format(string, sizeof(string),"ADMIN: %s is off duty now!", PlayerName2(playerid));
		SendClientMessageToAll(COLOR_GREEN1,string);
		SetPlayerHealth(playerid, 100);
		GivePlayerWeapon(playerid, 31, -9999);
        return  GivePlayerWeapon(playerid, 35, -9999);

		}
	}
	if(PlayerInfo[playerid][Level] == 5)
	{
	    if(PlayerInfo[playerid][OnDuty] == 0)
	    {
	    PlayerInfo[playerid][OnDuty] = 1;
	    SetPVarInt(playerid, "AdminProtect", 1);
	    SendClientMessage(playerid,green,"You are now on \"Duty Mode\"");
	    new string[100];

        format(string, sizeof(string),"LEADER: %s is on duty now!", PlayerName2(playerid));
        SendClientMessageToAll(COLOR_GREEN1,string);
	    SetPlayerHealth(playerid, 100000);
	    GivePlayerWeapon(playerid, 31, 9999);
	    return  GivePlayerWeapon(playerid, 35, 9999);
		}
		else
		{
		PlayerInfo[playerid][OnDuty] = 0;
		SetPVarInt(playerid, "AdminProtect", 0);
		SendClientMessage(playerid,orange,"You are now in \"Playing Mode\"-|");
        new string[100];
		format(string, sizeof(string),"LEADER: %s is off duty now!", PlayerName2(playerid));
		SendClientMessageToAll(COLOR_GREEN1,string);
		SetPlayerHealth(playerid, 100);
		GivePlayerWeapon(playerid, 31, -9999);
        return  GivePlayerWeapon(playerid, 35, -9999);

		}
	}
	if(PlayerInfo[playerid][Level] == 6)
	{
	    if(PlayerInfo[playerid][OnDuty] == 0)
	    {
	    PlayerInfo[playerid][OnDuty] = 1;
	    SetPVarInt(playerid, "AdminProtect", 1);
	    SendClientMessage(playerid,green,"You are now on \"Duty Mode\"");
	    new string[100];

        format(string, sizeof(string),"MANAGER/CEO: %s is on duty now!", PlayerName2(playerid));
        SendClientMessageToAll(COLOR_GREEN1,string);
	    SetPlayerHealth(playerid, 100000);
	    GivePlayerWeapon(playerid, 31, 9999);
	    return  GivePlayerWeapon(playerid, 35, 9999);
		}
		else
		{
		PlayerInfo[playerid][OnDuty] = 0;
		SetPVarInt(playerid, "AdminProtect", 0);
		SendClientMessage(playerid,orange,"You are now in \"Playing Mode\"-|");
        new string[100];
		format(string, sizeof(string),"MANAGER/CEO: %s is off duty now!", PlayerName2(playerid));
		SendClientMessageToAll(COLOR_GREEN1,string);
		SetPlayerHealth(playerid, 100);
		GivePlayerWeapon(playerid, 31, -9999);
        return  GivePlayerWeapon(playerid, 35, -9999);

		}
	}
	return SendClientMessage(playerid,red,"ERROR: You Need To Be A Admin To Use This Command");
}
dcmd_podiumup(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1)
	{
     	SendClientMessage(playerid,COLOR_GREEN,"The Lift Is Going Up ");
		SetPVarInt(playerid, "Going Up", 1);
		new str[128];
       	GetPlayerName(playerid, str, sizeof(str));
        format(str, sizeof(str), "Administrator/VIP \"%s\" Is Making Dance Podium Up", str);
        return SendClientMessageToAll(green, str);
	}
	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_podiumdown(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1)
	{
 		SendClientMessage(playerid,COLOR_GREEN,"The Lift Is Going down");
		new str[128];
       	GetPlayerName(playerid, str, sizeof(str));
        format(str, sizeof(str), "Administrator/VIP \"%s\" Is Making Dance Podium Down", str);
        return SendClientMessageToAll(green, str);
	}
    else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_podiumfastup(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1)
	{
     	SendClientMessage(playerid,COLOR_GREEN,"The Lift Is Going Up ");
		SetPVarInt(playerid, "Going Up", 1);
		new str[128];
       	GetPlayerName(playerid, str, sizeof(str));
        format(str, sizeof(str), "Administrator/VIP \"%s\" Is Making Dance Podium Up", str);
        return SendClientMessageToAll(green, str);
	}
	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_podiumfastdown(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1)
	{
 		SendClientMessage(playerid,COLOR_GREEN,"The Lift Is Going down");
		new str[128];
       	GetPlayerName(playerid, str, sizeof(str));
        format(str, sizeof(str), "Administrator/VIP \"%s\" Is Making Dance Podium Down", str);
        return SendClientMessageToAll(green, str);
	}
    else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_podiummegafastup(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1)
	{
     	SendClientMessage(playerid,COLOR_GREEN,"The Lift Is Going Up ");
		SetPVarInt(playerid, "Going Up", 1);
		new str[128];
       	GetPlayerName(playerid, str, sizeof(str));
        format(str, sizeof(str), "Administrator/VIP \"%s\" Is Making Dance Podium Up", str);
        return SendClientMessageToAll(green, str);
	}
	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_podiummegafastdown(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 1)
	{
 		SendClientMessage(playerid,COLOR_GREEN,"The Lift Is Going down");
		new str[128];
       	GetPlayerName(playerid, str, sizeof(str));
        format(str, sizeof(str), "Administrator/VIP \"%s\" Is Making Dance Podium Down", str);
        return SendClientMessageToAll(green, str);
	}
    else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_morning(playerid,params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 1) {
        return SetPlayerTime(playerid,7,0);
    } else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_adminarea(playerid,params[])
{
	#pragma unused params
    if(PlayerInfo[playerid][Level] >= 1) {
        CMDMessageToAdmins(playerid,"ADMINAREA");
	    SetPlayerPos(playerid, AdminArea[0], AdminArea[1], AdminArea[2]);
	    SetPlayerFacingAngle(playerid, AdminArea[3]);
	    SetPlayerInterior(playerid, AdminArea[4]);
		SetPlayerVirtualWorld(playerid, AdminArea[5]);
		return GameTextForPlayer(playerid,"Welcome Admin",1000,3);
	} else {
	   	SetPlayerHealth(playerid,1.0);
   		new string[100]; format(string, sizeof(string),"%s has used adminarea (non admin)", PlayerName2(playerid) );
	   	MessageToAdmins(red,string);
	} return SendClientMessage(playerid,red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");

}
dcmd_arespawn(playerid,params[])
{
        #pragma unused params
        new string[128];
      	if(PlayerInfo[playerid][Level] < 4) return SendClientMessage(playerid, 0xFF0000FF, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
        for(new i = 1; i <= MAX_VEHICLES; i++)
        {
                if(IsVehicleEmpty(i)) SetVehicleToRespawn(i);
        }
        format(string, sizeof(string), "{FF0000}All vehicles have been respawned!");
        CMDMessageToAdmins(playerid,"ARESPAWN");
        SendClientMessageToAll(0xFFFFFFFF,string);
        return 1;
}
dcmd_drespawn(playerid,params[])
{
        #pragma unused params
        new string[128];
      	if(PlayerInfo[playerid][Level] < 4) return SendClientMessage(playerid, 0xFF0000FF, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
        for(new i = 1; i <= MAX_VEHICLES; i++)
        {
                if(IsVehicleEmpty(i)) DestroyVehicle(i);
        }
        format(string, sizeof(string), "{FF0000}All vehicles have been respawned and deleted, and back into their original position.");
        CMDMessageToAdmins(playerid,"DRESPAWN");
        SendClientMessageToAll(0xFFFFFFFF,string);
		SendRconCommand("unloadfs vehicles");
		SendRconCommand("loadfs vehicles");
        return 1;
}
dcmd_orespawn(playerid,params[])
{
        #pragma unused params
      	if(PlayerInfo[playerid][Level] < 5) return SendClientMessage(playerid, 0xFF0000FF, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
      	SendClientMessage(playerid,red,"Maps Reloaded!");
		SendRconCommand("unloadfs TBSMaps");
		SendRconCommand("loadfs TBSMaps");
        return 1;
}
dcmd_setlevel(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid)) {
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(params))
		    {
		    new string[128];
   			format(string,sizeof(string),"Usage: /setlevel [PlayerID] [Level]");
			SendClientMessage(playerid,red,string);
			return SendClientMessage(playerid, orange, "Function: Will set the Level of Administration of the Specific Player");
			}
	    	new player1, level, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);
			if(!strlen(tmp2)) return
			SendClientMessage(playerid, red, "Usage: /setlevel [PlayerID] [Level]") &&
			SendClientMessage(playerid, orange, "Function: Will set the Level of Administration of the Specific Player");
			level = strval(tmp2);

			if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
				if(PlayerInfo[player1][LoggedIn] == 1) {
					if(level > ServerInfo[MaxAdminLevel] ) return SendClientMessage(playerid,red,"ERROR: Incorrect Level");
					if(level == PlayerInfo[player1][Level]) return SendClientMessage(playerid,red,"ERROR: Player is already this level");
	       			CMDMessageToAdmins(playerid,"SETLEVEL");
					GetPlayerName(player1, playername, sizeof(playername));	GetPlayerName(playerid, adminname, sizeof(adminname));
			       	new year,month,day;   getdate(year, month, day); new hour,minute,second; gettime(hour,minute,second);

 			    	switch(level)
			    	{
			    	case 1: Ranks = "{FF0000}Trial Moderator{00FFFF}";
			    	case 2: Ranks = "{FF0000}Moderator{00FFFF}";
			    	case 3: Ranks = "{FF0000}Administator{00FFFF}";
			    	case 4: Ranks = "{FF0000}Senior Administrator{00FFFF}";
			    	case 5: Ranks = "{0049FF}Head Administrator{00FFFF}";
			    	case 6: Ranks = "{0049FF}Manager/CEO{00FFFF}";
			    	}
				    if(level > 0) format(string,sizeof(string),"Manager/CEO %s has set you to Administrator Status [%s - Level: %d]",adminname,Ranks, level);
				    else format(string,sizeof(string),"Manager/CEO %s has set you to Player Status [Normal Account]",adminname, level);
			    	SendClientMessage(player1,blue,string);
                    if(level > PlayerInfo[player1][Level])
				    GameTextForPlayer(player1,"Promoted", 2000, 3);
			    	else GameTextForPlayer(player1,"Demoted", 2000, 3);

			    	format(string,sizeof(string),"You have given %s Level %d on '%d/%d/%d' at '%d:%d:%d'", playername, level, day, month, year, hour, minute, second);
			    	SendClientMessage(playerid,yellow,string);
			    	format(string,sizeof(string),"Administrator %s has made %s Level %d",adminname, playername, level);
			    	SaveToFile("AdminLog",string);
			    	dUserSetINT(PlayerName2(player1)).("Level",(level));
			    	PlayerInfo[player1][Level] = level;
					SavePlayer(player1);
					return PlayerPlaySound(player1,1057,0.0,0.0,0.0);
				} else return SendClientMessage(playerid,red,"ERROR: Player must be registered and logged in to be admin");
			} else return SendClientMessage(playerid, red, "Player is not connected");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_lsetlevel(playerid,params[])
{
	  if(PlayerInfo[playerid][LoggedIn] == 1) {
	  if(PlayerInfo[playerid][Level] >= 5 || IsPlayerAdmin(playerid)) {
      new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	  if(!strlen(params))
      {
      new string[128];
	  format(string,sizeof(string),"Usage: /lsetlevel [PlayerID] [Level]");
	  SendClientMessage(playerid,red,string);
	  return SendClientMessage(playerid, orange, "Function: Will set the Level of Administration of the Specific Player");
	  }
  	  new player1, level, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
	  player1 = strval(tmp);
	  if(!strlen(tmp2)) return
	  SendClientMessage(playerid, red, "Usage: /lsetlevel [PlayerID] [Level]") &&
	  SendClientMessage(playerid, orange, "Function: Will set the Level of Administration of the Specific Player");
	  level = strval(tmp2);

      if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
      if(PlayerInfo[player1][LoggedIn] == 1) {
      if(level > 4 ) return SendClientMessage(playerid,red,"ERROR: Incorrect Level");
      if(level == PlayerInfo[player1][Level]) return SendClientMessage(playerid,red,"ERROR: Player is already this level");
      if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: This Admin is higher level than you! You canno't use this command on him!");
      CMDMessageToAdmins(playerid,"SETLEVEL");
      GetPlayerName(player1, playername, sizeof(playername));	GetPlayerName(playerid, adminname, sizeof(adminname));
      new year,month,day;   getdate(year, month, day); new hour,minute,second; gettime(hour,minute,second);

      switch(level)
      {
      case 0: Ranks = "Regular";
      case 1: Ranks = "{FF0000}Trial Moderator{00FFFF}";
      case 2: Ranks = "{FF0000}Moderator{00FFFF}";
      case 3: Ranks = "{FF0000}Administator{00FFFF}";
      case 4: Ranks = "{FF0000}Senior Administrator{00FFFF}";
      }
      if(level > 0) format(string,sizeof(string),"Leader %s has set you to Administrator Status [%s - Level: %d]",adminname,Ranks, level);
      else format(string,sizeof(string),"Leader %s has set you to Player Status [Normal Account]",adminname, level);
      SendClientMessage(player1,blue,string);
      if(level > PlayerInfo[player1][Level])
      GameTextForPlayer(player1,"Promoted", 2000, 3);
      else GameTextForPlayer(player1,"Demoted", 2000, 3);

      format(string,sizeof(string),"You have given %s Level %d on '%d/%d/%d' at '%d:%d:%d'", playername, level, day, month, year, hour, minute, second);
      SendClientMessage(playerid,yellow,string);
      format(string,sizeof(string),"Leader %s has made %s Level %d",adminname, playername, level);
      SaveToFile("AdminLog",string);
      dUserSetINT(PlayerName2(player1)).("Level",(level));
      PlayerInfo[player1][Level] = level;
      return PlayerPlaySound(player1,1057,0.0,0.0,0.0);
      } else return SendClientMessage(playerid,red,"ERROR: Player must be registered and logged in to be admin");
      } else return SendClientMessage(playerid, red, "Player is not connected");
      } else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	  } else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}

dcmd_apromote(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1)
	{
		if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid))
		{
		    new tmp [256];
			new tmp2[256];
			new Index;
			tmp  = strtok(params,Index);
			tmp2 = strtok(params,Index);
		    if(!strlen(params))
		    {
		    new string[128];
   			format(string,sizeof(string),"Usage: /apromote [Player Name] [Level]");
			SendClientMessage(playerid,red,string);
			return SendClientMessage(playerid, red, "NOTE: Max Promotion Level is 5, You can't promote any player higher than level 5");
			}
	    	new player1, level, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);
			if(!strlen(tmp2)) return
			SendClientMessage(playerid, red, "Usage: /apromote [Player Name] [Level]") &&
			SendClientMessage(playerid, red, "NOTE: Max Promotion Level is 5, You can't promote any player higher than level 5");
			level = strval(tmp2);
            if(udb_Exists(tmp))
		    {
				if(level > 5)
				return SendClientMessage(playerid,red,"You Don't have permission to Promote Players more than Level 5.");
				if(level == PlayerInfo[player1][Level])
				return SendClientMessage(playerid,red,"ERROR: Player is already have this level!");
	       		CMDMessageToAdmins(playerid,"APROMOTE");
				GetPlayerName(player1, playername, sizeof(playername));
				GetPlayerName(playerid, adminname, sizeof(adminname));
		       	new year,month,day;
		   		new hour,minute,second;
		  		getdate(year, month, day);
		  		gettime(hour,minute,second);

				if(level > 4)
				{
				Ranks = "Professional Admin";
				}
 				switch(level)
				{
				case 1: Ranks = "{FF0000}Trial Moderator{00FFFF}";
				case 2: Ranks = "{FF0000}Moderator{00FFFF}";
				case 3: Ranks = "{FF0000}Administrator{00FFFF}";
				case 4: Ranks = "{FF0000}Senior Administrator{00FFFF}";
				case 5: Ranks = "{00FFFF}Head Administrator{00FFFF}";
				}
				if(level > 0)
				format(string,sizeof(string),"{00FFFF}Manager/CEO %s has made '%s' Admin Status (%s)",adminname,tmp,Ranks);
				else
				format(string,sizeof(string),"{00FFFF}Manager/CEO %s has made '%s' Admin Status (%s)",adminname,tmp, Ranks);
				SendClientMessageToAll(blue,string);
				format(string,sizeof(string),"{00FFFF}You have Promoted %s To Level %d,Don't forget to inform the CEO about that!", tmp, level, day, month, year, hour, minute, second);
				SendClientMessage(playerid,yellow,string);
				format(string,sizeof(string),"Manager/CEO %s has made %s Level %d",adminname, tmp, level);
				SaveToFile("AdminLog",string);
				dUserSetINT((tmp)).("Level",(level));
				return PlayerPlaySound(player1,1057,0.0,0.0,0.0);
				} else return SendClientMessage(playerid,red,"ERROR: Player must be registered and logged in to be admin");
			} else return SendClientMessage(playerid, red, "Player is not connected");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_apromotel(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1)
	{
		if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid))
		{
		    new tmp [256];
			new tmp2[256];
			new Index;
			tmp  = strtok(params,Index);
			tmp2 = strtok(params,Index);
		    if(!strlen(params))
		    {
		    new string[128];
   			format(string,sizeof(string),"Usage: /apromotel [Player Name] [Level]");
			SendClientMessage(playerid,red,string);
			return SendClientMessage(playerid, red, "NOTE: Apromotel - Promotes Offline players, that aren't in-game");
			}
	    	new player1, level, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);
			if(!strlen(tmp2)) return
			SendClientMessage(playerid, red, "Usage: /apromotel [Player Name] [Level]") &&
			SendClientMessage(playerid, red, "NOTE: Apromotel - Promotes Offline players, that aren't in-game");
			level = strval(tmp2);
            if(udb_Exists(tmp))
		    {
				if(level > 6)
				return SendClientMessage(playerid,red,"Level 6 is the maximum level, you can't promote more than that!");
				if(level == PlayerInfo[player1][Level]) return SendClientMessage(playerid,red,"ERROR: Player is already this level");
	       		CMDMessageToAdmins(playerid,"APROMOTEL");
				GetPlayerName(player1, playername, sizeof(playername));
				GetPlayerName(playerid, adminname, sizeof(adminname));
		       	new year,month,day;
		   		new hour,minute,second;
		  		getdate(year, month, day);
		  		gettime(hour,minute,second);

				if(level > 10)
				{
				Ranks = "RCON Manager";
				}
 				switch(level)
				{
				case 1: Ranks = "{FF0000}Trial Moderator{00FFFF}";
				case 2: Ranks = "{FF0000}Moderator{00FFFF}";
				case 3: Ranks = "{FF0000}Administrator{00FFFF}";
				case 4: Ranks = "{FF0000}Senior Administrator{00FFFF}";
				case 5: Ranks = "{0049FF}Head Administrator{00FFFF}";
				case 6: Ranks = "{0049FF}Manager/CEO{00FFFF}";
				}
				if(level > 0)
				format(string,sizeof(string),"{0049FF}Manager/CEO{00FFFF} %s has made '%s' Admin Status %s",adminname,tmp,Ranks);
				else
				format(string,sizeof(string),"{0049FF}Manager/CEO{00FFFF} %s has made '%s' Admin Status %s",adminname,tmp, Ranks);
				SendClientMessageToAll(blue,string);
				format(string,sizeof(string),"You have Promoted %s To Admin Level %d on '%d/%d/%d' at '%d:%d:%d'", tmp, level, day, month, year, hour, minute, second);
				SendClientMessage(playerid,yellow,string);
				format(string,sizeof(string),"Manager/CEO %s has made '%s' Level %d",adminname, tmp, level);
				SaveToFile("AdminLog",string);
				dUserSetINT((tmp)).("Level",(level));
				PlayerPlaySound(player1,1057,0.0,0.0,0.0);
				} else return SendClientMessage(playerid,red,"ERROR: Player must be registered and logged in to be admin");
			} else return SendClientMessage(playerid, red, "Player is not connected");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
    return 1;
}
dcmd_removeaccount(playerid, params[])
{
   	new string[256];
	if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid))
	{
		new tmp[256], Index; tmp = strtok(params,Index);
		new CEOName[MAX_PLAYER_NAME];
	    GetPlayerName(playerid, CEOName, sizeof(CEOName));
		if(!strlen(tmp)) return SendClientMessage(playerid, red, "USAGE: /removeaccount [Full Playername]");
	    if(!strcmp(tmp, "Filipbg") || !strcmp(tmp, "Emily_Lafernus")) return SendClientMessage(playerid, COLOR_RED, "ERROR: You CANNOT remove Filipbg's or Emily_Lafernus's accounts! >:C");
		if(!udb_Exists(tmp)) return SendClientMessage(playerid, red,"ERROR: The Account name you typed does not exists");
		udb_Remove(tmp);
		format(string, sizeof(string), "Manager/CEO %s has removed {33FFCC}%s{FF0000}'s account",CEOName,tmp);
		SendClientMessageToAll(red, string);
		printf("%s", string);
		SaveToFile("RemovedAccounts", string);
	}
	return 1;
}

dcmd_delacc(playerid, params[])
{
	#pragma unused params
	dcmd_removeaccount(playerid, params);
	return 1;
}

dcmd_remacc(playerid, params[])
{
	#pragma unused params
	dcmd_removeaccount(playerid, params);
	return 1;
}

dcmd_ounban(playerid,params[])
{
   	if(PlayerInfo[playerid][Level] >= 4)
	{
		new tmp[256], Index;        tmp = strtok(params,Index);
		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /ounban [name]");
		new adminname[MAX_PLAYER_NAME], string[128], unbanname[256];
		unbanname = tmp;
		if(udb_Exists(unbanname))
		{
			dUserSetINT(unbanname).("banned", 0);
			GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"OUnban");
			format(string,sizeof(string),"{00FFFF}Administrator %s has unbanned {FFAF24}\"%s's\"{00FFFF} Account.",adminname,unbanname);
			SendClientMessageToAll(green,string);
			SaveToFile("UnBanNameLog",string);
			print(string);
			return 1;
	    }
	    else return SendClientMessage(playerid, red, "ERROR: No player with this name.");
	}
    else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_nameunban(playerid,params[])
{
	#pragma unused params
	dcmd_ounban(playerid,params);
	return 1;
}

dcmd_unbanip(playerid,params[])
{
    new dformat[50],ip[16], string[128];
    if(PlayerInfo[playerid][Level]>= 5)
    {
    if(sscanf(params,"s",ip)) return SendClientMessage(playerid,red,"USAGE: /unbanip [ip]");
    format(dformat,sizeof(dformat),"unbanip %s",ip);
    SendRconCommand(dformat);
	SendRconCommand("reloadbans");
	format(string,sizeof(string), "IP: %s has been Unbanned!", ip);
	SendClientMessage(playerid, COLOR_WHITE, string);
	}
    else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;

}

dcmd_banip(playerid,params[])
{
    new dformat[50],ip[16], string[128];
    if(PlayerInfo[playerid][Level]>= 5)
    {
    if(sscanf(params,"s",ip)) return SendClientMessage(playerid,red,"USAGE: /banip [ip]");
    if(!strcmp(ip, "95.42.10.26") || !strcmp(ip, "139.193.65.203") || !strcmp(ip, "95.42.223.221")) return SendClientMessage(playerid, COLOR_RED, "ERROR: You CANNOT ban this IP! >:C");
    format(dformat,sizeof(dformat),"banip %s",ip);
    SendRconCommand(dformat);
	format(string,sizeof(string), "IP: %s has been Banned!", ip);
	SendClientMessage(playerid, COLOR_WHITE, string);
	}
    else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;

}

dcmd_getip(playerid, params[])
{
   	if(PlayerInfo[playerid][Level] >= 1)
	{
		new string[128], file[256], tmp[256];
		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /getip [name]");
        format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(params));
		if(!fexist(file)) return SendClientMessage(playerid, red, "Error: File doesnt exist, player isnt registered");
        tmp = dini_Get(file,"ip");
        format(string, sizeof(string),"%s's IP is: %s\n",params,tmp);
        return SendClientMessage(playerid, COLOR_BLUE, string);
	}
    else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_checkban(playerid, params[])
{
   	if(PlayerInfo[playerid][Level] >= 3)
	{
		new string[128], file[256], tmp[256];
		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /checkban [name]");
        format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(params));
		if(!fexist(file)) return SendClientMessage(playerid, red, "Error: File doesnt exist, player isnt registered");
        tmp = dini_Get(file,"banned");
		format(string, sizeof(string),"%s's Banned Status is: '%s' (0 = No, 1 = Yes)!", params, tmp);
        return SendClientMessage(playerid, COLOR_BLUE, string);
	}
    else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_checklevel(playerid, params[])
{
   	if(PlayerInfo[playerid][Level] >= 3)
	{
		new string[128], file[256], tmp[256];
		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /checklevel [name]");
        format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(params));
		if(!fexist(file)) return SendClientMessage(playerid, red, "Error: File doesnt exist, player isnt registered");
        tmp = dini_Get(file,"level");
		format(string, sizeof(string),"%s's Admin Level is: '%s'!", params, tmp);
        return SendClientMessage(playerid, COLOR_BLUE, string);
	}
    else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}


dcmd_ademote(playerid,params[])
{
   	if(PlayerInfo[playerid][Level] >= 6)
	{
		new tmp[256], Index;        tmp = strtok(params,Index);
		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /ademote [name]");
		new adminname[MAX_PLAYER_NAME], string[128], ademotename[256];
		ademotename = tmp;
		if(udb_Exists(ademotename))
		{
			if(!strcmp(ademotename, "Filipbg") || !strcmp(ademotename, "Emily_Lafernus")) return SendClientMessage(playerid, COLOR_RED, "ERROR: You CANNOT demote Filipbg or Emily_Lafernus! >:C");
			dUserSetINT(ademotename).("Level", 0);
			GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"ADEMOTE");
			format(string,sizeof(string),"{00FFFF}Manager/CEO %s has Demoted \%s\'s Admin Level to Regular Member!",adminname,ademotename);
			SendClientMessageToAll(green,string);
			print(string);
			return 1;
	    }
	    else return SendClientMessage(playerid, red, "ERROR: No player with this name.");
	}
    else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_djdemote(playerid,params[])
{
   	if(PlayerInfo[playerid][Level] >= 6)
	{
		new tmp[256], Index;        tmp = strtok(params,Index);
		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /djdemote [name]");
		new adminname[MAX_PLAYER_NAME], string[128], unbanname[256];
		unbanname = tmp;
		if(udb_Exists(unbanname))
		{
			dUserSetINT(unbanname).("DJ", 0);
			GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"DJDemote");
			format(string,sizeof(string),"{00FFFF}Manager/CEO %s has Removed \%s\'s DJ Status!",adminname,unbanname);
			SendClientMessageToAll(green,string);
			print(string);
			return 1;
	    }
	    else return SendClientMessage(playerid, red, "ERROR: No player with this name.");
	}
    else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_djpromote(playerid,params[])
{
   	if(PlayerInfo[playerid][Level] >= 6)
	{
		new tmp[256], Index;        tmp = strtok(params,Index);
		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /djpromote [name]");
		new adminname[MAX_PLAYER_NAME], string[128], unbanname[256];
		unbanname = tmp;
		if(udb_Exists(unbanname))
		{
			dUserSetINT(unbanname).("DJ", 1);
			GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"DJPromote");
			format(string,sizeof(string),"{00FFFF}Manager/CEO %s has Given DJ Status to %s!",adminname,unbanname);
			SendClientMessageToAll(green,string);
			print(string);
			return 1;
	    }
	    else return SendClientMessage(playerid, red, "ERROR: No player with this name.");
	}
    else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_mdemote(playerid,params[])
{
   	if(PlayerInfo[playerid][Level] >= 6)
	{
		new tmp[256], Index;        tmp = strtok(params,Index);
		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /mdemote [name]");
		new adminname[MAX_PLAYER_NAME], string[256], mdemotename[256];
		mdemotename = tmp;
		if(udb_Exists(mdemotename))
		{
            if(!strcmp(mdemotename, "Filipbg") || !strcmp(mdemotename, "Emily_Lafernus")) return SendClientMessage(playerid, COLOR_RED, "ERROR: You CANNOT demote Filipbg or Emily_Lafernus! >:C");
			dUserSetINT(mdemotename).("Level", 0);
			GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"MDEMOTE");
			format(string,sizeof(string),"{00FFFF}TBS Manager/CEO %s has demoted {FFAF24}\"%s's\"{00FFFF} Admin Level to Regular Member!",adminname,mdemotename);
			SendClientMessageToAll(green,string);
			print(string);
			return 1;
	    }
	    else return SendClientMessage(playerid, red, "ERROR: No player with this name.");
	}
    else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_vdemote(playerid,params[])
   	if(PlayerInfo[playerid][Level] >= 5)
	{
		new tmp[256], Index;        tmp = strtok(params,Index);
		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /vdemote [name]");
		new adminname[MAX_PLAYER_NAME], string[128], unbanname[256];
		unbanname = tmp;
		if(udb_Exists(unbanname))
		{
			dUserSetINT(unbanname).("AccountType", 0);
			GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"VDEMOTE");
			format(string,sizeof(string),"{00FFFF}Manager/Leader %s has Demoted {FFAF24}\"%s's\"{00FFFF} VIP Level to 0.",adminname,unbanname);
			SendClientMessageToAll(green,string);
			print(string);
			return 1;
	    }
	    else return SendClientMessage(playerid, red, "ERROR: No player with this name.");
	}
    else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
    
dcmd_vpromote(playerid,params[])
   	if(PlayerInfo[playerid][Level] >= 5)
	{
		new tmp[256], Index;        tmp = strtok(params,Index);
		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /vpromote [name]");
		new adminname[MAX_PLAYER_NAME], string[128], unbanname[256];
		unbanname = tmp;
		if(udb_Exists(unbanname))
		{
			dUserSetINT(unbanname).("AccountType", 6);
			GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"VPROMOTE");
			format(string,sizeof(string),"{00FFFF}Manager/Leader %s has Promoted {FFAF24}\"%s's\"{00FFFF} VIP Level {0000FF}Platinum VIP!{0000FF}",adminname,unbanname);
			SendClientMessageToAll(green,string);
			print(string);
			return 1;
	    }
	    else return SendClientMessage(playerid, red, "ERROR: No player with this name.");
	}
    else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");

dcmd_vpromotel(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1)
	{
		if(PlayerInfo[playerid][Level] >= 5 || IsPlayerAdmin(playerid))
		{
		    new tmp [256];
			new tmp2[256];
			new Index;
			tmp  = strtok(params,Index);
			tmp2 = strtok(params,Index);
		    if(!strlen(params))
		    {
		    new string[128];
   			format(string,sizeof(string),"Usage: /vpromotel [Player Name] [VIP Level]");
			SendClientMessage(playerid,red,string);
			return SendClientMessage(playerid, red, "NOTE: Vpromotel - Promotes Offline players, that aren't in-game");
			}
	    	new player1, VIPLvl, playername[MAX_PLAYER_NAME], adminname[MAX_PLAYER_NAME], string[128];
			player1 = strval(tmp);
			if(!strlen(tmp2)) return
			SendClientMessage(playerid, red, "Usage: /vpromotel [Player Name] [VIP Level]") &&
			SendClientMessage(playerid, red, "NOTE: Vpromotel - Promotes Offline players, that aren't in-game");
			VIPLvl = strval(tmp2);
            if(udb_Exists(tmp))
		    {
				if(VIPLvl == PlayerInfo[player1][pVip]) return SendClientMessage(playerid,red,"ERROR: Player is already this VIP level");
	       		CMDMessageToAdmins(playerid,"VPROMOTEL");
				GetPlayerName(player1, playername, sizeof(playername));
				GetPlayerName(playerid, adminname, sizeof(adminname));
		       	new year,month,day;
		   		new hour,minute,second;
		  		getdate(year, month, day);
		  		gettime(hour,minute,second);

				if(VIPLvl > 10)
				{
				Ranks = "RCON Manager";
				}
 				switch(VIPLvl)
				{
				case 1: Ranks = "{C0C0C0}Silver{C0C0C0}";
				case 2: Ranks = "{FFFF00}Gold{FFFF00}";
				case 3: Ranks = "{0000FF}Platinum{0000FF}";
				}
				if(VIPLvl > 0)
				format(string,sizeof(string),"{0049FF}Leader/CEO{00FFFF} %s has made '%s' VIP Status %s",adminname,tmp,Ranks);
				else
				format(string,sizeof(string),"{0049FF}Leader/CEO{00FFFF} %s has made '%s' VIP Status %s",adminname,tmp, Ranks);
				SendClientMessageToAll(blue,string);
				format(string,sizeof(string),"You have Promoted %s To VIP Level %d on '%d/%d/%d' at '%d:%d:%d'", tmp, VIPLvl, day, month, year, hour, minute, second);
				SendClientMessage(playerid,yellow,string);
				format(string,sizeof(string),"Leader/CEO %s has made '%s' VIP Level %d",adminname, tmp, VIPLvl);
				SaveToFile("VIPLog",string);
				dUserSetINT((tmp)).("VIPLvl",(VIPLvl));
				return PlayerPlaySound(player1,1057,0.0,0.0,0.0);
				} else return SendClientMessage(playerid,red,"ERROR: Player must be registered and logged in to be VIP");
			} else return SendClientMessage(playerid, red, "Player is not connected");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_oban(playerid,params[])
{
   	if(PlayerInfo[playerid][Level] >= 4)
	{
		new tmp[256], Index;        tmp = strtok(params,Index);
		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /oban [name]");
		new adminname[MAX_PLAYER_NAME], string[128], obanname[256];
		obanname = tmp;
		if(udb_Exists(obanname))
		{
            if(!strcmp(obanname, "Filipbg") || !strcmp(obanname, "Emily_Lafernus")) return SendClientMessage(playerid, COLOR_RED, "ERROR: You CANNOT ban Filipbg or Emily_Lafernus! >:C");
			dUserSetINT(obanname).("banned", 1);
			GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"OBan");
			format(string,sizeof(string),"{00FFFF}Manager/Leader %s has banned {FFAF24}\"%s's\"{00FFFF} Account.",adminname,obanname);
			SendClientMessageToAll(green,string);
			SaveToFile("BanLog",string);
			print(string);
			return 1;
    	}
	    else return SendClientMessage(playerid, red, "ERROR: No player with this name.");
	}
    else return SendClientMessage(playerid,red,"ERROR: You are not high enough level to use this command.");
}

dcmd_nameban(playerid,params[])
{
	#pragma unused params
	dcmd_oban(playerid,params);
	return 1;
}

dcmd_setokills(playerid,params[])
{
   	if(PlayerInfo[playerid][Level] >= 5)
	{
		new tmp[256], tmp2[256], Index;        tmp = strtok(params,Index),  tmp2 = strtok(params,Index);
        if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setokills [name] [kills]");
		new adminname[MAX_PLAYER_NAME], string[128], killsname[256], kills;
		killsname = tmp;
		kills = strval(tmp2);
		if(udb_Exists(killsname))
		{
			dUserSetINT(killsname).("kills", kills);
			GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"SetOKills");
			format(string,sizeof(string),"{00FFFF}Manager/Leader %s has set {FFAF24}\"%s's\"{00FFFF} Kills to %d",adminname, killsname, kills);
			SendClientMessageToAll(green,string);
			return 1;
    	}
	    else return SendClientMessage(playerid, red, "ERROR: No player with this name.");
	}
    else return SendClientMessage(playerid,red,"ERROR: You are not high enough level to use this command.");
}

dcmd_setohours(playerid,params[])
{
   	if(PlayerInfo[playerid][Level] >= 5)
	{
		new tmp[256], tmp2[256], Index;        tmp = strtok(params,Index),  tmp2 = strtok(params,Index);
        if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setohours [name] [hours]");
		new adminname[MAX_PLAYER_NAME], string[128], hoursname[256], hrs;
		hoursname = tmp;
		hrs = strval(tmp2);
		if(udb_Exists(hoursname))
		{
			dUserSetINT(hoursname).("hours", hrs);
			GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"SetOHours");
			format(string,sizeof(string),"{00FFFF}Manager/Leader %s has set {FFAF24}\"%s's\"{00FFFF} Hours to %s",adminname,hoursname, hrs);
			SendClientMessageToAll(green,string);
			return 1;
    	}
	    else return SendClientMessage(playerid, red, "ERROR: No player with this name.");
	}
    else return SendClientMessage(playerid,red,"ERROR: You are not high enough level to use this command.");
}

dcmd_setominutes(playerid,params[])
{
   	if(PlayerInfo[playerid][Level] >= 5)
	{
		new tmp[256], tmp2[256], Index;        tmp = strtok(params,Index),  tmp2 = strtok(params,Index);
        if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setominutes [name] [minutes]");
		new adminname[MAX_PLAYER_NAME], string[128], minutesname[256], mns;
		minutesname = tmp;
		mns = strval(tmp2);
		if(udb_Exists(minutesname))
		{
			dUserSetINT(minutesname).("mins", mns);
			GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"SetOMinutes");
			format(string,sizeof(string),"{00FFFF}Manager/Leader %s has set {FFAF24}\"%s's\"{00FFFF} Minutes to %s",adminname,minutesname, mns);
			SendClientMessageToAll(green,string);
			return 1;
    	}
	    else return SendClientMessage(playerid, red, "ERROR: No player with this name.");
	}
    else return SendClientMessage(playerid,red,"ERROR: You are not high enough level to use this command.");
}


dcmd_setodeaths(playerid,params[])
{
   	if(PlayerInfo[playerid][Level] >= 5)
	{
		new tmp[256], tmp2[256], Index;        tmp = strtok(params,Index),  tmp2 = strtok(params,Index);
        if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setodeaths [name] [deaths]");
		new adminname[MAX_PLAYER_NAME], string[128], deathsname[256], deaths;
		deathsname = tmp;
		deaths = strval(tmp2);
		if(udb_Exists(deathsname))
		{
			dUserSetINT(deathsname).("deaths", deaths);
			GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"SetODeaths");
			format(string,sizeof(string),"{00FFFF}Manager/Leader %s has set {FFAF24}\"%s's\"{00FFFF} Deaths to %d",adminname, deathsname, deaths);
			SendClientMessageToAll(green,string);
			return 1;
    	}
	    else return SendClientMessage(playerid, red, "ERROR: No player with this name.");
	}
    else return SendClientMessage(playerid,red,"ERROR: You are not high enough level to use this command.");
}

dcmd_setdeaths(playerid,params[])
{
   	if(PlayerInfo[playerid][Level] >= 5)
	{
		new tmp[256], tmp2[256], Index;        tmp = strtok(params,Index),  tmp2 = strtok(params,Index);
        if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setdeaths [ID] [deaths]");
		new adminname[MAX_PLAYER_NAME], string[128], deaths, player1;
        player1 = strval(tmp);
		deaths = strval(tmp2);
		if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID)
		{
			GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"SetDeaths");
			format(string,sizeof(string),"{00FFFF}Manager/Leader %s has set your Deaths to %d",adminname, deaths);
			SendClientMessage(player1,green,string);
			format(string,sizeof(string), "{FFFF00}You have set %d Deaths to %s", deaths, pName(player1));
			SendClientMessage(playerid,yellow,string);
			PlayerInfo[player1][pDeaths] = deaths;
			return 1;
    	}
	    else return SendClientMessage(playerid, red, "Player is not connected");
	}
    else return SendClientMessage(playerid,red,"ERROR: You are not high enough level to use this command.");
}

dcmd_setkills(playerid,params[])
{
   	if(PlayerInfo[playerid][Level] >= 5)
	{
		new tmp[256], tmp2[256], Index;        tmp = strtok(params,Index),  tmp2 = strtok(params,Index);
        if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setkills [ID] [kills]");
		new adminname[MAX_PLAYER_NAME], string[128], kills, player1;
        player1 = strval(tmp);
		kills = strval(tmp2);
		if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID)
		{
			GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"SetKills");
			format(string,sizeof(string),"{00FFFF}Manager/Leader %s has set your Kills to %d",adminname, kills);
			SendClientMessage(player1,green,string);
			format(string,sizeof(string), "{FFFF00}You have set %d Kills to %s", kills, pName(player1));
			SendClientMessage(playerid,yellow,string);
			PlayerInfo[player1][Kills] = kills;
			return 1;
    	}
	    else return SendClientMessage(playerid, red, "Player is not connected");
	}
    else return SendClientMessage(playerid,red,"ERROR: You are not high enough level to use this command.");
}

dcmd_sethours(playerid,params[])
{
   	if(PlayerInfo[playerid][Level] >= 5)
	{
		new tmp[256], tmp2[256], Index;        tmp = strtok(params,Index),  tmp2 = strtok(params,Index);
        if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "USAGE: /sethours [ID] [hours]");
		new adminname[MAX_PLAYER_NAME], string[128], hrs, player1;
        player1 = strval(tmp);
		hrs = strval(tmp2);
		if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID)
		{
			GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"SetHours");
			format(string,sizeof(string),"{00FFFF}Manager/Leader %s has set your Hours to %d",adminname, hrs);
			SendClientMessage(player1,green,string);
			format(string,sizeof(string), "{FFFF00}You have set %d Hours to %s", hrs, pName(player1));
			SendClientMessage(playerid,yellow,string);
			PlayerInfo[player1][hours] = hrs;
			return 1;
    	}
	    else return SendClientMessage(playerid, red, "Player is not connected");
	}
    else return SendClientMessage(playerid,red,"ERROR: You are not high enough level to use this command.");
}

dcmd_setminutes(playerid,params[])
{
   	if(PlayerInfo[playerid][Level] >= 5)
	{
		new tmp[256], tmp2[256], Index;        tmp = strtok(params,Index),  tmp2 = strtok(params,Index);
        if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setminutes [ID] [minutes]");
		new adminname[MAX_PLAYER_NAME], string[128], mns, player1;
        player1 = strval(tmp);
		mns = strval(tmp2);
		if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID)
		{
			GetPlayerName(playerid, adminname, sizeof(adminname));
			CMDMessageToAdmins(playerid,"SetMinutes");
			format(string,sizeof(string),"{00FFFF}Manager/Leader %s has set your Minutes to %d",adminname, mns);
			SendClientMessage(player1,green,string);
			format(string,sizeof(string), "{FFFF00}You have set %d Minutes to %s", mns, pName(player1));
			SendClientMessage(playerid,yellow,string);
			PlayerInfo[player1][mins] = mns;
			return 1;
    	}
	    else return SendClientMessage(playerid, red, "Player is not connected");
	}
    else return SendClientMessage(playerid,red,"ERROR: You are not high enough level to use this command.");
}

dcmd_settemplevel(playerid,params[])
{
   	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(PlayerInfo[playerid][Level] >= 5 || IsPlayerAdmin(playerid)) {
		    new tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
		    if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "USAGE: /settemplevel [playerid] [Level - Max Temp level = 4]");
	    	new player1, level, string[128];
			player1 = strval(tmp);
			level = strval(tmp2);

			if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
				if(PlayerInfo[player1][LoggedIn] == 1) {
					if(level > 4 ) return SendClientMessage(playerid,red,"ERROR: Incorrect Level");
					if(level == PlayerInfo[player1][Level]) return SendClientMessage(playerid,red,"ERROR: Player is already this level");
	       			CMDMessageToAdmins(playerid,"SETTEMPLEVEL");
			       	new year,month,day; getdate(year, month, day); new hour,minute,second; gettime(hour,minute,second);

					if(level > 0) format(string,sizeof(string),"Administrator %s has temporarily set you to Administrator Status [level %d]", pName(playerid), level);
					else format(string,sizeof(string),"Administrator %s has temporarily set you to Player Status [level %d]", pName(playerid), level);
					SendClientMessage(player1,blue,string);

					if(level > PlayerInfo[player1][Level]) GameTextForPlayer(player1,"Promoted", 2000, 3);
					else GameTextForPlayer(player1,"Demoted", 2000, 3);

					format(string,sizeof(string),"You have made %s Level %d on %d/%d/%d at %d:%d:%d", pName(player1), level, day, month, year, hour, minute, second); SendClientMessage(playerid,blue,string);
					format(string,sizeof(string),"Administrator %s has made %s temp Level %d on %d/%d/%d at %d:%d:%d",pName(playerid), pName(player1), level, day, month, year, hour, minute, second);
					SaveToFile("TempAdminLog",string);
					PlayerInfo[player1][Level] = level;
					return PlayerPlaySound(player1,1057,0.0,0.0,0.0);
				} else return SendClientMessage(playerid,red,"ERROR: Player must be registered and logged in to be admin");
			} else return SendClientMessage(playerid, red, "Player is not connected");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You must be logged in to use this command!");
}
dcmd_report(playerid,params[])
{
    new reported, tmp[256], tmp2[256], Index;		tmp = strtok(params,Index), tmp2 = strtok(params,Index);
    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /report [playerid] [reason]");
	reported = strval(tmp);
 	if(IsPlayerConnected(reported) && reported != INVALID_PLAYER_ID) {
		if(PlayerInfo[reported][Level] == ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot report this administrator");
		if(playerid == reported) return SendClientMessage(playerid,red,"ERROR: You Cannot report yourself");
		if(strlen(params) > 7) {
			new reportedname[MAX_PLAYER_NAME], reporter[MAX_PLAYER_NAME], str[128], hour,minute,second; gettime(hour,minute,second);
			GetPlayerName(reported, reportedname, sizeof(reportedname));	GetPlayerName(playerid, reporter, sizeof(reporter));
			format(str, sizeof(str), "{FFFF00}||NewReport||  %s(%d) reported %s(%d) Reason: %s |@%d:%d:%d|{FFFF00}", reporter,playerid, reportedname, reported, params[strlen(tmp)+1], hour,minute,second);
			MessageToAdmins(COLOR_WHITE,str);
			SaveToFile("ReportLog",str);
			format(str, sizeof(str), "{FFFF00}Report(%d:%d:%d): %s(%d) reported %s(%d) Reason: %s{FFFF00}", hour,minute,second, reporter,playerid, reportedname, reported, params[strlen(tmp)+1]);
			for(new i = 1; i < MAX_REPORTS-1; i++) Reports[i] = Reports[i+1];
			Reports[MAX_REPORTS-1] = str;
			return SendClientMessage(playerid,yellow, "Your report has been sent to online administrators.");
		} else return SendClientMessage(playerid,red,"ERROR: Must be a valid reason!");
	} else return SendClientMessage(playerid, red, "Player is not connected.");
}

dcmd_request(playerid,params[])
{
    new tmp[256], Index;		tmp = strtok(params,Index);
	if(GetPlayerScore(playerid) < 250) return SendClientMessage(playerid, red, "ERROR: You need 250 score in order to request a song!");
	if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /request [Full Song Name]");
    if(strlen(params) > 3)
	{
    new requestname[MAX_PLAYER_NAME], str[128];
    GetPlayerName(playerid, requestname, sizeof(requestname));
	format(str, sizeof(str), "{FFFFFF}||Song Request||  %s(%d) has requested a song, name: %s{FFFFFF}", requestname,playerid, params[strlen(tmp)+1]);
	MessageToDJs(COLOR_WHITE,str);
	format(str, sizeof(str), "{FFFFFF}Requested Song: '%s' by %s(%d){FFFFFF}", params[strlen(tmp)+1], requestname,playerid);
    for(new i = 1; i < MAX_SONG_REQUESTS-1; i++) Requests[i] = Requests[i+1];
    Requests[MAX_SONG_REQUESTS-1] = str;
    return SendClientMessage(playerid,yellow, "Your song request has been sent to the online DJ's!");
    } else return SendClientMessage(playerid,red,"ERROR: You must type the full song name!");
}

dcmd_requests(playerid,params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][isDJ] == 1 || PlayerInfo[playerid][Level] >= 3) {
        new RequestCount;
		for(new i = 1; i < MAX_SONG_REQUESTS; i++)
		{
			if(strcmp( Requests[i], "<none>", true) != 0) { RequestCount++; SendClientMessage(playerid,COLOR_YELLOW,Requests[i]); }
		}
		if(RequestCount == 0) SendClientMessage(playerid,COLOR_YELLOW,"There have been no song requests");
    } else SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}

dcmd_reports(playerid,params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 3) {
        new ReportCount;
		for(new i = 1; i < MAX_REPORTS; i++)
		{
			if(strcmp( Reports[i], "<none>", true) != 0) { ReportCount++; SendClientMessage(playerid,COLOR_YELLOW,Reports[i]); }
		}
		if(ReportCount == 0) SendClientMessage(playerid,COLOR_YELLOW,"There have been no reports");
    } else SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}

dcmd_richlist(playerid,params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 1) {
 		new string[128], Slot1 = -1, Slot2 = -1, Slot3 = -1, Slot4 = -1, HighestCash = -9999;
 		SendClientMessage(playerid,COLOR_GREEN,"Rich List:");

		for(new x=0; x<MAX_PLAYERS; x++) if (IsPlayerConnected(x)) if (GetPlayerMoneyEx(x) >= HighestCash) {
			HighestCash = GetPlayerMoneyEx(x);
			Slot1 = x;
		}
		HighestCash = -9999;
		for(new x=0; x<MAX_PLAYERS; x++) if (IsPlayerConnected(x) && x != Slot1) if (GetPlayerMoneyEx(x) >= HighestCash) {
			HighestCash = GetPlayerMoneyEx(x);
			Slot2 = x;
		}
		HighestCash = -9999;
		for(new x=0; x<MAX_PLAYERS; x++) if (IsPlayerConnected(x) && x != Slot1 && x != Slot2) if (GetPlayerMoneyEx(x) >= HighestCash) {
			HighestCash = GetPlayerMoneyEx(x);
			Slot3 = x;
		}
		HighestCash = -9999;
		for(new x=0; x<MAX_PLAYERS; x++) if (IsPlayerConnected(x) && x != Slot1 && x != Slot2 && x != Slot3) if (GetPlayerMoneyEx(x) >= HighestCash) {
			HighestCash = GetPlayerMoneyEx(x);
			Slot4 = x;
		}
		format(string, sizeof(string), "(%d) %s - $%d", Slot1,PlayerName2(Slot1),GetPlayerMoneyEx(Slot1) );
		SendClientMessage(playerid,COLOR_GREEN,string);
		if(Slot2 != -1)	{
			format(string, sizeof(string), "(%d) %s - $%d", Slot2,PlayerName2(Slot2),GetPlayerMoneyEx(Slot2) );
			SendClientMessage(playerid,COLOR_YELLOW,string);
		}
		if(Slot3 != -1)	{
			format(string, sizeof(string), "(%d) %s - $%d", Slot3,PlayerName2(Slot3),GetPlayerMoneyEx(Slot3) );
			SendClientMessage(playerid,COLOR_YELLOW,string);
		}
		if(Slot4 != -1)	{
			format(string, sizeof(string), "(%d) %s - $%d", Slot4,PlayerName2(Slot4),GetPlayerMoneyEx(Slot4) );
			SendClientMessage(playerid,COLOR_RED,string);
		}
		return 1;
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_miniguns(playerid,params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 1) {
		new bool:First2 = false, Count, string[128], i, slot, weap, ammo;
		for(i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				for(slot = 0; slot < 14; slot++) {
					GetPlayerWeaponData(i, slot, weap, ammo);
					if(ammo != 0 && weap == 38) {
					    Count++;
						if(!First2) { format(string, sizeof(string), "Minigun: (%d)%s(ammo%d)", i, PlayerName2(i), ammo); First2 = true; }
				        else format(string,sizeof(string),"%s, (%d)%s(ammo%d) ",string, i, PlayerName2(i), ammo);
					}
				}
    	    }
		}
		if(Count == 0) return SendClientMessage(playerid,COLOR_WHITE,"No players have a minigun"); else return SendClientMessage(playerid,COLOR_WHITE,string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_uconfig(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 4)
	{
		UpdateConfig();
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		return CMDMessageToAdmins(playerid,"UCONFIG");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_botcheck(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 4) {
		for(new i=0; i<MAX_PLAYERS; i++) BotCheck(i);
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		return CMDMessageToAdmins(playerid,"BOTCHECK");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_lockserver(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 6) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /lockserver [password]");
    	new adminname[MAX_PLAYER_NAME], string[128];
		ServerInfo[Locked] = 1;
		strmid(ServerInfo[Password], params[0], 0, strlen(params[0]), 128);
		GetPlayerName(playerid, adminname, sizeof(adminname));
		format(string, sizeof(string), "Manager/CEO \"%s\" has locked the server",adminname);
  		SendClientMessageToAll(red,"________________________________________");
  		SendClientMessageToAll(red," ");
		SendClientMessageToAll(red,string);
		SendClientMessageToAll(red,"________________________________________");
		for(new i = 0; i <= MAX_PLAYERS; i++) if(IsPlayerConnected(i)) { PlayerPlaySound(i,1057,0.0,0.0,0.0); PlayerInfo[i][AllowedIn] = true; }
		CMDMessageToAdmins(playerid,"LOCKSERVER");
		format(string, sizeof(string), "Manager/CEO \"%s\" has set the server password to '%s'",adminname, ServerInfo[Password] );
		return MessageToAdmins(COLOR_WHITE, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_unlockserver(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 6) {
	    if(ServerInfo[Locked] == 1) {
	    	new adminname[MAX_PLAYER_NAME], string[128];
			ServerInfo[Locked] = 0;
			strmid(ServerInfo[Password], "", 0, strlen(""), 128);
			GetPlayerName(playerid, adminname, sizeof(adminname));
			format(string, sizeof(string), "Manager/CEO \"%s\" has unlocked the server",adminname);
  			SendClientMessageToAll(green,"________________________________________");
	  		SendClientMessageToAll(green," ");
			SendClientMessageToAll(green,string);
			SendClientMessageToAll(green,"________________________________________");
			for(new i = 0; i <= MAX_PLAYERS; i++) if(IsPlayerConnected(i)) { PlayerPlaySound(i,1057,0.0,0.0,0.0); PlayerInfo[i][AllowedIn] = true; }
			return CMDMessageToAdmins(playerid,"UNLOCKSERVER");
		} else return SendClientMessage(playerid,red,"ERROR: Server is not locked");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_password(playerid,params[])
{
	if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /password [password]");
	if(ServerInfo[Locked] == 1) {
	    if(PlayerInfo[playerid][AllowedIn] == false) {
			if(!strcmp(ServerInfo[Password],params[0],true)) {
				KillTimer( LockKickTimer[playerid] );
				PlayerInfo[playerid][AllowedIn] = true;
				new string[128];
				SendClientMessage(playerid,COLOR_WHITE,"You have successsfully entered the server password and may now spawn");
				format(string, sizeof(string), "%s has successfully entered server password",PlayerName2(playerid));
				return MessageToAdmins(COLOR_WHITE, string);
			} else return SendClientMessage(playerid,red,"ERROR: Incorrect server password");
		} else return SendClientMessage(playerid,red,"ERROR: You are already logged in");
	} else return SendClientMessage(playerid,red,"ERROR: Server isnt Locked");
}
//------------------------------------------------------------------------------
dcmd_forbidname(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 4) {
		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /forbidname [nickname]");
        if(!strcmp(params, "Filipbg") || !strcmp(params, "Emily_Lafernus")) return SendClientMessage(playerid, COLOR_RED, "ERROR: You CANNOT forbid Filipbg or Emily_Lafernus! >:C");
		new File:BLfile, string[128];
		BLfile = fopen("ladmin/config/ForbiddenNames.cfg",io_append);
		format(string,sizeof(string),"%s\r\n",params[1]);
		fwrite(BLfile,string);
		fclose(BLfile);
		UpdateConfig();
		CMDMessageToAdmins(playerid,"FORBIDNAME");
		format(string, sizeof(string), "Administrator \"%s\" has added the name \"%s\" to the forbidden name list", pName(playerid), params );
		return MessageToAdmins(green,string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_forbidword(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 4) {
		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /forbidword [word]");
		new File:BLfile, string[128];
		BLfile = fopen("ladmin/config/ForbiddenWords.cfg",io_append);
		format(string,sizeof(string),"%s\r\n",params[1]);
		fwrite(BLfile,string);
		fclose(BLfile);
		UpdateConfig();
		CMDMessageToAdmins(playerid,"FORBIDWORD");
		format(string, sizeof(string), "Administrator \"%s\" has added the word \"%s\" to the forbidden word list", pName(playerid), params );
		return MessageToAdmins(green,string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
//==========================[ Spectate Commands ]===============================
#if defined ENABLE_SPEC
dcmd_lspec(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 1 || IsPlayerAdmin(playerid) || PlayerInfo[playerid][pVip] >= 2) {
	    if(!strlen(params) || !IsNumeric(params)) return SendClientMessage(playerid, red, "USAGE: /spec [playerid]");
		new specplayerid = strval(params);
		if(PlayerInfo[specplayerid][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(specplayerid) && specplayerid != INVALID_PLAYER_ID) {
			if(specplayerid == playerid) return SendClientMessage(playerid, red, "ERROR: You cannot spectate yourself");
			if(GetPlayerState(specplayerid) == PLAYER_STATE_SPECTATING && PlayerInfo[specplayerid][SpecID] != INVALID_PLAYER_ID) return SendClientMessage(playerid, red, "Spectate: Player spectating someone else");
			if(GetPlayerState(specplayerid) != 1 && GetPlayerState(specplayerid) != 2 && GetPlayerState(specplayerid) != 3) return SendClientMessage(playerid, red, "Spectate: Player not spawned");
			if( (PlayerInfo[specplayerid][Level] != ServerInfo[MaxAdminLevel]) || (PlayerInfo[specplayerid][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] == ServerInfo[MaxAdminLevel]) )	{
				StartSpectate(playerid, specplayerid);
				CMDMessageToAdmins(playerid,"LSPEC");
				GetPlayerPos(playerid,Pos[playerid][0],Pos[playerid][1],Pos[playerid][2]);
				GetPlayerFacingAngle(playerid,Pos[playerid][3]);
				return SendClientMessage(playerid,blue,"Now Spectating");
			} else return SendClientMessage(playerid,red,"ERROR: You cannot spectate the highest level admin");
		} else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_lspecvehicle(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 1 || IsPlayerAdmin(playerid)) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /lspecvehicle [vehicleid]");
		new specvehicleid = strval(params);
		if(specvehicleid < MAX_VEHICLES) {
			TogglePlayerSpectating(playerid, 1);
			PlayerSpectateVehicle(playerid, specvehicleid);
			PlayerInfo[playerid][SpecID] = specvehicleid;
			PlayerInfo[playerid][SpecType] = ADMIN_SPEC_TYPE_VEHICLE;
			CMDMessageToAdmins(playerid,"SPEC VEHICLE");
			GetPlayerPos(playerid,Pos[playerid][0],Pos[playerid][1],Pos[playerid][2]);
			GetPlayerFacingAngle(playerid,Pos[playerid][3]);
			return SendClientMessage(playerid,blue,"Now Spectating");
		} else return SendClientMessage(playerid,red, "ERROR: Invalid Vehicle ID");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_lspecoff(playerid,params[])
{
	#pragma unused params
    if(PlayerInfo[playerid][Level] >= 1 || PlayerInfo[playerid][pVip] >= 2 || IsPlayerAdmin(playerid)) {
        if(PlayerInfo[playerid][SpecType] != ADMIN_SPEC_TYPE_NONE) {
			StopSpectate(playerid);
			SetTimerEx("PosAfterSpec",3000,0,"d",playerid);
			return SendClientMessage(playerid,blue,"No Longer Spectating");
		} else return SendClientMessage(playerid,red,"ERROR: You are not spectating");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_spec(playerid,params[])
{
  dcmd_lspec(playerid,params);
  return 1;
}
dcmd_specoff(playerid,params[])
{
  dcmd_lspecoff(playerid,params);
  return 1;
}
#endif
//==========================[ CHAT COMMANDS ]===================================
dcmd_disablechat(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 5) {
		CMDMessageToAdmins(playerid,"DISABLECHAT");
		new string[128];
		if(ServerInfo[DisableChat] == 0) {
			ServerInfo[DisableChat] = 1;
			format(string,sizeof(string),"Leader/CEO \"%s\" has disabled chat", pName(playerid) );
		} else {
			ServerInfo[DisableChat] = 0;
			format(string,sizeof(string),"Leader/CEO \"%s\" has enabled chat", pName(playerid) );
		} return SendClientMessageToAll(blue,string);
 	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_clearchat(playerid,params[])
{
    #pragma unused params
    new string[128];
    
	if(PlayerInfo[playerid][Level] >= 2) {
		for(new i = 0; i < 131; i++)
		SendClientMessageToAll(green," ");
		format(string,sizeof(string),"Administrator \"%s\" has cleared the main chat", pName(playerid));
		SendClientMessageToAll(blue,string);
		return 1;
    } else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_cc(playerid,params[])
{
    #pragma unused params
    new string[128];
    
	if(PlayerInfo[playerid][Level] >= 2) {
		for(new i = 0; i < 131; i++)
		SendClientMessageToAll(green," ");
		format(string,sizeof(string),"Administrator \"%s\" has cleared the main chat", pName(playerid));
		SendClientMessageToAll(blue,string);
		return 1;
    } else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_cleardeathlog(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2)
	{
    new string[128];
	for(new i; i< 20; i++)
    {
           SendDeathMessage(6000, 5005, 255);
    }
	format(string,sizeof(string),"Administrator \"%s\" has cleared the Death Log", pName(playerid));
	SendClientMessageToAll(blue,string);
	return 1;
	} else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_cdl(playerid,params[])
{
	#pragma unused params
	if(PlayerInfo[playerid][Level] >= 2)
	{
    new string[128];
	for(new i; i< 20; i++)
    {
           SendDeathMessage(6000, 5005, 255);
    }
	format(string,sizeof(string),"Administrator \"%s\" has cleared the Death Log", pName(playerid));
	SendClientMessageToAll(blue,string);
	return 1;
	} else return SendClientMessage(playerid, red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
 }

dcmd_caps(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 2) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || IsNumeric(tmp2)) return SendClientMessage(playerid, red, "USAGE: /caps [playerid] [\"on\" / \"off\"]");
		new player1 = strval(tmp), string[128];
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			if(strcmp(tmp2,"on",true) == 0)	{
				CMDMessageToAdmins(playerid,"CAPS");
				PlayerInfo[player1][Caps] = 0;
				if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has allowed you to use capitals in chat!", pName(playerid) ); SendClientMessage(player1,blue,string); }
				format(string,sizeof(string),"You have allowed \"%s\" to use capitals in chat", pName(player1) ); return SendClientMessage(playerid,blue,string);
			} else if(strcmp(tmp2,"off",true) == 0)	{
				CMDMessageToAdmins(playerid,"CAPS");
				PlayerInfo[player1][Caps] = 1;
				if(player1 != playerid) { format(string,sizeof(string),"Administrator \"%s\" has prevented you from using capitals in chat!", pName(playerid) ); SendClientMessage(player1,blue,string); }
				format(string,sizeof(string),"You have prevented \"%s\" from using capitals in chat", pName(player1) ); return SendClientMessage(playerid,blue,string);
			} else return SendClientMessage(playerid, red, "USAGE: /caps [playerid] [\"on\" / \"off\"]");
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
//==================[ Object & Pickup ]=========================================
dcmd_pickup(playerid,params[])
{
    
    if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid)) {
    if(!strlen(params)) return SendClientMessage(playerid,red,"USAGE: /pickup [pickup id]");
    new pickup2 = strval(params), string[128], Float:x, Float:y, Float:z, Float:a;
    CMDMessageToAdmins(playerid,"PICKUP");
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    x += (3 * floatsin(-a, degrees));
    y += (3 * floatcos(-a, degrees));
    CreatePickup(pickup2, 2, x+2, y, z);
	format(string, sizeof(string), "CreatePickup(%d, 2, %0.2f, %0.2f, %0.2f);", pickup2, x+2, y, z);
    SaveToFile("Pickups",string);
    return SendClientMessage(playerid,yellow, string);
    } else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_object(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid)) {
    if(!strlen(params)) return SendClientMessage(playerid,red,"USAGE: /object [object id]");
    new object = strval(params), string[128], Float:x, Float:y, Float:z, Float:a;
    CMDMessageToAdmins(playerid,"OBJECT");
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, a);
    x += (3 * floatsin(-a, degrees));
    y += (3 * floatcos(-a, degrees));
    CreateObject(object, x, y, z, 0.0, 0.0, a);
    format(string, sizeof(string), "CreateObject(%d, %0.2f, %0.2f, %0.2f, 0.00, 0.00, %0.2f);", object, x, y, z, a);
   	SaveToFile("Objects",string);
    format(string, sizeof(string), "You Have Created Object %d, at %0.2f, %0.2f, %0.2f Angle %0.2f", object, x, y, z, a);
    return SendClientMessage(playerid,yellow, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
//===================[ Move ]===================================================
dcmd_move(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 3 || PlayerInfo[playerid][pVip] >= 3) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /move [up / down / +x / -x / +y / -y / off]");
		new Float:X, Float:Y, Float:Z;
		if(strcmp(params,"up",true) == 0)	{
			TogglePlayerControllable(playerid,false); GetPlayerPos(playerid,X,Y,Z);	SetPlayerPos(playerid,X,Y,Z+5); SetCameraBehindPlayer(playerid); }
		else if(strcmp(params,"down",true) == 0)	{
			TogglePlayerControllable(playerid,false); GetPlayerPos(playerid,X,Y,Z);	SetPlayerPos(playerid,X,Y,Z-5); SetCameraBehindPlayer(playerid); }
		else if(strcmp(params,"+x",true) == 0)	{
			TogglePlayerControllable(playerid,false); GetPlayerPos(playerid,X,Y,Z);	SetPlayerPos(playerid,X+5,Y,Z);	}
		else if(strcmp(params,"-x",true) == 0)	{
			TogglePlayerControllable(playerid,false); GetPlayerPos(playerid,X,Y,Z);	SetPlayerPos(playerid,X-5,Y,Z); }
		else if(strcmp(params,"+y",true) == 0)	{
			TogglePlayerControllable(playerid,false); GetPlayerPos(playerid,X,Y,Z);	SetPlayerPos(playerid,X,Y+5,Z);	}
		else if(strcmp(params,"-y",true) == 0)	{
			TogglePlayerControllable(playerid,false); GetPlayerPos(playerid,X,Y,Z);	SetPlayerPos(playerid,X,Y-5,Z);	}
	    else if(strcmp(params,"off",true) == 0)	{
			TogglePlayerControllable(playerid,true);	}
		else return SendClientMessage(playerid,red,"USAGE: /move [up / down / +x / -x / +y / -y / off]");
		return 1;
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_moveplayer(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 3 || PlayerInfo[playerid][pVip] >= 3) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !IsNumeric(tmp)) return SendClientMessage(playerid, red, "USAGE: /moveplayer [playerid] [up / down / +x / -x / +y / -y / off]");
	    new Float:X, Float:Y, Float:Z, player1 = strval(tmp);
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
		if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
			if(strcmp(tmp2,"up",true) == 0)	{
				GetPlayerPos(player1,X,Y,Z);	SetPlayerPos(player1,X,Y,Z+5); SetCameraBehindPlayer(player1);	}
			else if(strcmp(tmp2,"down",true) == 0)	{
				GetPlayerPos(player1,X,Y,Z);	SetPlayerPos(player1,X,Y,Z-5); SetCameraBehindPlayer(player1);	}
			else if(strcmp(tmp2,"+x",true) == 0)	{
				GetPlayerPos(player1,X,Y,Z);	SetPlayerPos(player1,X+5,Y,Z);	}
			else if(strcmp(tmp2,"-x",true) == 0)	{
				GetPlayerPos(player1,X,Y,Z);	SetPlayerPos(player1,X-5,Y,Z); }
			else if(strcmp(tmp2,"+y",true) == 0)	{
				GetPlayerPos(player1,X,Y,Z);	SetPlayerPos(player1,X,Y+5,Z);	}
			else if(strcmp(tmp2,"-y",true) == 0)	{
				GetPlayerPos(player1,X,Y,Z);	SetPlayerPos(player1,X,Y-5,Z);	}
			else SendClientMessage(playerid,red,"USAGE: /moveplayer [up / down / +x / -x / +y / -y / off]");
			return 1;
		} else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
//===================[ Fake ]===================================================
#if defined ENABLE_FAKE_CMDS
dcmd_fakedeath(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 5) {
	    new tmp[256], tmp2[256], tmp3[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index), tmp3 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2) || !strlen(tmp3)) return SendClientMessage(playerid, red, "USAGE: /fakedeath [killer] [killee] [weapon]");
		new killer = strval(tmp), killee = strval(tmp2), weap = strval(tmp3);
		if(!IsValidWeapon(weap)) return SendClientMessage(playerid,red,"ERROR: Invalid Weapon ID");
		if(PlayerInfo[killer][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
		if(PlayerInfo[killee][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(killer) && killer != INVALID_PLAYER_ID) {
	        if(IsPlayerConnected(killee) && killee != INVALID_PLAYER_ID) {
	    	  	CMDMessageToAdmins(playerid,"FAKEDEATH");
				SendDeathMessage(killer,killee,weap);
				return SendClientMessage(playerid,blue,"Fake death message sent");
		    } else return SendClientMessage(playerid,red,"ERROR: Killee is not connected");
	    } else return SendClientMessage(playerid,red,"ERROR: Killer is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_fakechat(playerid,params[]) 
{
    if(PlayerInfo[playerid][Level] >= 5) {
    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
    if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "USAGE: /fakechat [playerid] [text]");
    new player1 = strval(tmp);
    if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
    if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
    CMDMessageToAdmins(playerid,"FAKECHAT");
    SendPlayerMessageToAll(player1, params[strlen(tmp)+1]);
    return SendClientMessage(playerid,blue,"Fake message sent");
    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_fakecmd(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 5) {
	    new tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "USAGE: /fakecmd [playerid] [command]");
		new player1 = strval(tmp);
		if(PlayerInfo[player1][Level] == ServerInfo[MaxAdminLevel] && PlayerInfo[playerid][Level] != ServerInfo[MaxAdminLevel]) return SendClientMessage(playerid,red,"ERROR: You cannot use this command on this admin");
        if(IsPlayerConnected(player1) && player1 != INVALID_PLAYER_ID) {
	        CMDMessageToAdmins(playerid,"FAKECMD");
	        CallRemoteFunction("OnPlayerCommandText", "is", player1, tmp2);
			return SendClientMessage(playerid,blue,"Fake command sent");
	    } else return SendClientMessage(playerid,red,"ERROR: Player is not connected");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
#endif
//----------------------------------------------------------------------------//
// 		             	/all Commands                                         //
//----------------------------------------------------------------------------//

dcmd_spawnall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 5) {
		CMDMessageToAdmins(playerid,"SPAWNAll");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); SetPlayerPos(i, 0.0, 0.0, 0.0); SpawnPlayer(i);
			}
		}
		new string[128]; format(string,sizeof(string),"Administrator \"%s\" has spawned all players", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_muteall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 4) {
		CMDMessageToAdmins(playerid,"MUTEALL");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); PlayerInfo[i][Muted] = 1; PlayerInfo[i][MuteWarnings] = 0;
			}
		}
		new string[128]; format(string,sizeof(string),"Administrator \"%s\" has muted all players", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_unmuteall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 4) {
		CMDMessageToAdmins(playerid,"UNMUTEAll");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); PlayerInfo[i][Muted] = 0; PlayerInfo[i][MuteWarnings] = 0;
			}
		}
		new string[128]; format(string,sizeof(string),"Administrator \"%s\" has unmuted all players", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_getall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 4) {
		CMDMessageToAdmins(playerid,"GETAll");
		new Float:x,Float:y,Float:z, interior = GetPlayerInterior(playerid);
    	GetPlayerPos(playerid,x,y,z);
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(PlayerInfo[i][Spawned] && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); SetPlayerPos(i,x+(playerid/4)+1,y+(playerid/4),z); SetPlayerInterior(i,interior);
			}
		}
		new string[128]; format(string,sizeof(string),"Administrator \"%s\" has teleported all players", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_healall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 3) {
		CMDMessageToAdmins(playerid,"HEALALL");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(PlayerInfo[i][Spawned] && i != ServerInfo[MaxAdminLevel]) {
                if(GetPVarInt(i, "inDM") == 0)
                {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); SetPlayerHealth(i,100.0);
				}
			}
		}
		new string[128]; format(string,sizeof(string),"Administrator \"%s\" has healed all players, except in DM places.", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_armourall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 4) {
		CMDMessageToAdmins(playerid,"ARMOURALL");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(PlayerInfo[i][Spawned] && i != ServerInfo[MaxAdminLevel]) {
				if(GetPVarInt(i, "inDM") == 0)
                {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); SetPlayerArmour(i,100.0);
				}
			}
		}
		new string[128]; format(string,sizeof(string),"Administrator \"%s\" has restored all players armour", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_killall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 4) {
		CMDMessageToAdmins(playerid,"KILLALL");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); SetPlayerHealth(i,0.0);
			}
		}
		new string[128]; format(string,sizeof(string),"Administrator \"%s\" has killed all players", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_freezeall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 4) {
		CMDMessageToAdmins(playerid,"FREEZEALL");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); TogglePlayerControllable(playerid,false); PlayerInfo[i][Frozen] = 1;
			}
		}
		new string[128]; format(string,sizeof(string),"Administrator \"%s\" has frozen all players", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_unfreezeall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 4) {
		CMDMessageToAdmins(playerid,"UNFREEZEALL");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); TogglePlayerControllable(playerid,true); PlayerInfo[i][Frozen] = 0;
			}
		}
		new string[128]; format(string,sizeof(string),"Administrator \"%s\" has unfrozen all players", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_kickall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 6) {
		CMDMessageToAdmins(playerid,"KICKALL");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); Kick(i);
			}
		}
		new string[128]; format(string,sizeof(string),"Manager/CEO \"%s\" has kicked all players", pName(playerid) );
		SaveToFile("KickLog",string);
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_slapall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 4) {
		CMDMessageToAdmins(playerid,"SLAPALL");
		new Float:x, Float:y, Float:z;
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1190,0.0,0.0,0.0); GetPlayerPos(i,x,y,z);	SetPlayerPos(i,x,y,z+4);
			}
		}
		new string[128]; format(string,sizeof(string),"Administrator \"%s\" has slapped all players", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_explodeall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 4) {
		CMDMessageToAdmins(playerid,"EXPLODEALL");
		new Float:x, Float:y, Float:z;
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1190,0.0,0.0,0.0); GetPlayerPos(i,x,y,z);	CreateExplosion(x, y , z, 7, 10.0);
			}
		}
		new string[128]; format(string,sizeof(string),"Administrator \"%s\" has exploded all players", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_disarmall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 4) {
		CMDMessageToAdmins(playerid,"DISARMALL");
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0); ResetPlayerWeapons(i);
                SetPVarInt(i, "AdminGivenMini", 0);
			}
		}
		new string[128]; format(string,sizeof(string),"Administrator \"%s\" has disarmed all players", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_ejectall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 4) {
    	CMDMessageToAdmins(playerid,"EJECTALL");
        new Float:x, Float:y, Float:z;
	   	for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i) && (i != playerid) && i != ServerInfo[MaxAdminLevel]) {
			    if(IsPlayerInAnyVehicle(i)) {
					PlayerPlaySound(i,1057,0.0,0.0,0.0); GetPlayerPos(i,x,y,z); SetPlayerPos(i,x,y,z+3);
				}
			}
		}
		new string[128]; format(string,sizeof(string),"Administrator \"%s\" has ejected all players", pName(playerid) );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
//-------------==== Set All Commands ====-------------//

dcmd_setallskin(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 4) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /setallskin [skinid]");
		new var = strval(params), string[128];
		if(!IsValidSkin(var)) return SendClientMessage(playerid, red, "ERROR: Invaild Skin ID");
       	CMDMessageToAdmins(playerid,"SETALLSKIN");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0);
				SetPlayerSkin(i,var);
			}
		}
		format(string,sizeof(string),"Administrator \"%s\" has set all players skin to '%d'", pName(playerid), var );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_setallwanted(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 4) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /setallwanted [wanted level]");
		new var = strval(params), string[128];
       	CMDMessageToAdmins(playerid,"SETALLWANTED");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0);
				SetPlayerWantedLevel(i,var);
			}
		}
		format(string,sizeof(string),"Administrator \"%s\" has set all players wanted level to '%d'", pName(playerid), var );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_setallweather(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 4) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /setallweather [weather ID]");
		new var = strval(params), string[128];
       	CMDMessageToAdmins(playerid,"SETALLWEATHER");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0);
				SetPlayerWeather(i, var);
			}
		}
		format(string,sizeof(string),"Administrator \"%s\" has set all players weather to '%d'", pName(playerid), var );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_setalltime(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 4) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /setalltime [hour]");
		new var = strval(params), string[128];
		if(var > 24) return SendClientMessage(playerid, red, "ERROR: Invalid hour");
       	CMDMessageToAdmins(playerid,"SETALLTIME");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0);
				SetPlayerTime(i, var, 0);
			}
		}
		format(string,sizeof(string),"Administrator \"%s\" has set all players time to '%d:00'", pName(playerid), var );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_setallworld(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 4) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /setallworld [virtual world]");
		new var = strval(params), string[128];
       	CMDMessageToAdmins(playerid,"SETALLWORLD");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0);
				SetPlayerVirtualWorld(i,var);
			}
		}
		format(string,sizeof(string),"Administrator \"%s\" has set all players virtual worlds to '%d'", pName(playerid), var );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_setallscore(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 6) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /setallscore [score]");
		new var = strval(params), string[128];
       	CMDMessageToAdmins(playerid,"SETALLSCORE");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0);
				SetPlayerScore(i,var);
			}
		}
		format(string,sizeof(string),"Manager/CEO \"%s\" has set all players scores to '%d'", pName(playerid), var );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_setallcash(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 6) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /setallcash [Amount]");
		new var = strval(params), string[128];
       	CMDMessageToAdmins(playerid,"SETALLCASH");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0);
				ResetPlayerMoneyEx(i);
				GivePlayerMoneyEx(i,var);
			}
		}
		format(string,sizeof(string),"Manager/CEO \"%s\" has set all players cash to '$%d'", pName(playerid), var );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_giveallcash(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 6) {
	    if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /giveallcash [Amount]");
		new var = strval(params), string[128];
       	CMDMessageToAdmins(playerid,"GIVEALLCASH");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				PlayerPlaySound(i,1057,0.0,0.0,0.0);
				GivePlayerMoneyEx(i,var);
			}
		}
		format(string,sizeof(string),"Manager/CEO \"%s\" has given all players '$%d'", pName(playerid), var );
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

dcmd_giveallweapon(playerid,params[])
{
	if(PlayerInfo[playerid][Level] >= 4) {
	    new tmp[256], tmp2[256], Index, ammo, weap, WeapName[32], string[128]; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) ) return SendClientMessage(playerid, red, "USAGE: /giveallweapon [weapon id/weapon name] [ammo]");
		if(!strlen(tmp2) || !IsNumeric(tmp2) || strval(tmp2) <= 0 || strval(tmp2) > 99999) ammo = 500;
		if(!IsNumeric(tmp)) weap = GetWeaponIDFromName(tmp); else weap = strval(tmp);
	  	if(!IsValidWeapon(weap)) return SendClientMessage(playerid,red,"ERROR: Invalid weapon ID");
      	CMDMessageToAdmins(playerid,"GIVEALLWEAPON");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
			    if(weap == 38)
			    {
                    SetPVarInt(i, "AdminGivenMini", 1);
			    }
				PlayerPlaySound(i,1057,0.0,0.0,0.0);
				GivePlayerWeapon(i,weap,ammo);
			}
		}
		GetWeaponName(weap, WeapName, sizeof(WeapName) );
		format(string,sizeof(string),"Administrator \"%s\" has given all players a %s (%d) with %d rounds of ammo", pName(playerid), WeapName, weap, ammo);
		return SendClientMessageToAll(blue, string);
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
//================================[ Menu Commands ]=============================

#if defined USE_MENUS

dcmd_lmenu(playerid,params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 5) {
        if(IsPlayerInAnyVehicle(playerid)) {
        TogglePlayerControllable(playerid,false); return ShowMenuForPlayer(LMainMenu,playerid);
        } else return ShowMenuForPlayer(LMainMenu,playerid);
    } else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_ltele(playerid,params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
        if(IsPlayerInAnyVehicle(playerid)) {
        TogglePlayerControllable(playerid,false); return ShowMenuForPlayer(LTele,playerid);
        } else return ShowMenuForPlayer(LTele,playerid);
    } else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_lweather(playerid,params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 3 || PlayerInfo[playerid][pVip] >= 3) {
        if(IsPlayerInAnyVehicle(playerid)) {
        TogglePlayerControllable(playerid,false); return ShowMenuForPlayer(LWeather,playerid);
        } else return ShowMenuForPlayer(LWeather,playerid);
    } else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_ltime(playerid,params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 3 || PlayerInfo[playerid][pVip] >= 3) {
        if(IsPlayerInAnyVehicle(playerid)) {
        TogglePlayerControllable(playerid,false); return ShowMenuForPlayer(LTime,playerid);
        } else return ShowMenuForPlayer(LTime,playerid);
    } else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_cm(playerid,params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
        if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,red,"ERROR: You already have a car.");
        else { ShowMenuForPlayer(LCars,playerid); return TogglePlayerControllable(playerid,false);  }
    } else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_ltmenu(playerid,params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
        if(IsPlayerInAnyVehicle(playerid)) {
		new LVehicleID = GetPlayerVehicleID(playerid), LModel = GetVehicleModel(LVehicleID);
        switch(LModel) { case 448,461,462,463,468,471,509,510,521,522,523,581,586,449: return SendClientMessage(playerid,red,"ERROR: You can not tune this vehicle!"); }
        TogglePlayerControllable(playerid,false); return ShowMenuForPlayer(LTuneMenu,playerid);
        } else return SendClientMessage(playerid,red,"ERROR: You do not have a vehicle to tune");
    } else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_lweapons(playerid,params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 3) {
        if(IsPlayerInAnyVehicle(playerid)) {
        TogglePlayerControllable(playerid,false); return ShowMenuForPlayer(XWeapons,playerid);
        } else return ShowMenuForPlayer(XWeapons,playerid);
    } else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}
dcmd_lvehicle(playerid,params[])
{
    #pragma unused params
    if(PlayerInfo[playerid][Level] >= 2) {
 		if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,red,"ERROR: You already have a car.");
        else { ShowMenuForPlayer(LVehicles,playerid); return TogglePlayerControllable(playerid,false);  }
    } else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

#endif

//----------------------===== Place & Skin Saving =====-------------------------
dcmd_sp(playerid,params[])
{
    #pragma unused params
    new Float:x,Float:y,Float:z, interior;
    GetPlayerPos(playerid,x,y,z);	interior = GetPlayerInterior(playerid);
    dUserSetINT(PlayerName2(playerid)).("x",floatround(x));
    dUserSetINT(PlayerName2(playerid)).("y",floatround(y));
    dUserSetINT(PlayerName2(playerid)).("z",floatround(z));
    dUserSetINT(PlayerName2(playerid)).("interior",interior);
    dUserSetINT(PlayerName2(playerid)).("world", (GetPlayerVirtualWorld(playerid)) );
    return SendClientMessage(playerid,COLOR_WHITE,"Position saved, use /lp to go back.");
}
dcmd_lp(playerid,params[])
{
    #pragma unused params
    if (dUserINT(PlayerName2(playerid)).("x")!=0) {
    PutAtPos(playerid);
    SetPlayerVirtualWorld(playerid, (dUserINT(PlayerName2(playerid)).("world")) );
    return SendClientMessage(playerid,COLOR_WHITE,"Position restored!");
    } else return SendClientMessage(playerid,red,"ERROR: You must save a place before you can teleport to it");
}

dcmd_saveskin(playerid,params[])
{
 	if(PlayerInfo[playerid][LoggedIn] == 1) {
		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /saveskin [skinid]");
		new string[128], SkinID = strval(params);
//		if((SkinID == 0)||(SkinID == 2)||(SkinID == 3)||(SkinID == 4)||(SkinID == 5)||(SkinID == 6)||(SkinID == 7)||(SkinID >= 9 && SkinID <= 41)||(SkinID >= 43 && SkinID <= 64)||(SkinID >= 66 && SkinID <= 73)||(SkinID >= 75 && SkinID <= 85)||(SkinID >= 87 && SkinID <= 118)||(SkinID >= 120 && SkinID <= 148)||(SkinID >= 150 && SkinID <= 207)||(SkinID >= 209 && SkinID <= 264)||(SkinID >= 274 && SkinID <= 288)||(SkinID >= 290 && SkinID <= 299))
//		{
        SkinID = GetPlayerSkin(playerid);
        dUserSetINT(PlayerName2(playerid)).("FavSkin",SkinID);
        format(string, sizeof(string), "You have successfully saved this skin (ID %d)",SkinID);
        SendClientMessage(playerid,yellow,string);
        SendClientMessage(playerid,yellow,"Type: /useskin to use this skin when you spawn or /dontuseskin to stop using skin");
        return dUserSetINT(PlayerName2(playerid)).("UseSkin",1);
//		} else return SendClientMessage(playerid, green, "ERROR: Invalid Skin ID");
     } else return SendClientMessage(playerid,red,"You are not Logged in.");
}

dcmd_useskin(playerid,params[])
{
    #pragma unused params
    new SkinID = strval(params);
	if(PlayerInfo[playerid][LoggedIn] == 1) {
        SkinID = GetPlayerSkin(playerid);
        dUserSetINT(PlayerName2(playerid)).("FavSkin",SkinID);
	    dUserSetINT(PlayerName2(playerid)).("UseSkin",1);
		return SendClientMessage(playerid,yellow,"Skin now in use");
	} else return SendClientMessage(playerid,red,"ERROR: You need to be logged in!");
}

dcmd_dontuseskin(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][LoggedIn] == 1) {
	    dUserSetINT(PlayerName2(playerid)).("UseSkin",0);
		return SendClientMessage(playerid,yellow,"Skin will no longer be used");
	} else return SendClientMessage(playerid,red,"ERROR: You need to be logged in!");
}

//====================== [REGISTER  &  LOGIN] ==================================
#if defined USE_AREGISTER

dcmd_aregister(playerid,params[])
{
    if (PlayerInfo[playerid][LoggedIn] == 1) return SendClientMessage(playerid,red,"ACCOUNT: You are already registered and logged in.");
    if (udb_Exists(PlayerName2(playerid))) return SendClientMessage(playerid,red,"ACCOUNT: This account already exists, please use '/alogin [password]'.");
    if (strlen(params) == 0) return SendClientMessage(playerid,red,"ACCOUNT: Correct usage: '/aregister [password]'");
    if (strlen(params) < 4 || strlen(params) > 20) return SendClientMessage(playerid,red,"ACCOUNT: Password length must be greater than three characters");
    if (udb_Create(PlayerName2(playerid),params))
	{
    	new file[256],name[MAX_PLAYER_NAME], tmp3[100];
    	new strdate[20], year,month,day;	getdate(year, month, day);
		GetPlayerName(playerid,name,sizeof(name)); format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(name));
     	GetPlayerIp(playerid,tmp3,100);	dini_Set(file,"ip",tmp3);
    	dini_Set(file,"password",params);
	    dUserSetINT(PlayerName2(playerid)).("registered",1);
   		format(strdate, sizeof(strdate), "%d/%d/%d",day,month,year);
		dini_Set(file,"RegisteredDate",strdate);
		dUserSetINT(PlayerName2(playerid)).("loggedin",1);
		dUserSetINT(PlayerName2(playerid)).("banned",0);
		dUserSetINT(PlayerName2(playerid)).("level",0);
		dUserSetINT(PlayerName2(playerid)).("Vip",0);
	    dUserSetINT(PlayerName2(playerid)).("LastOn",0);
    	dUserSetINT(PlayerName2(playerid)).("money",0);
    	dUserSetINT(PlayerName2(playerid)).("Score",0);
    	dUserSetINT(PlayerName2(playerid)).("kills",0);
	   	dUserSetINT(PlayerName2(playerid)).("deaths",0);
	    PlayerInfo[playerid][LoggedIn] = 1;
	    PlayerInfo[playerid][Registered] = 1;
	    SendClientMessage(playerid, green, "ACCOUNT: You are now registered, and have been automaticaly logged in");
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		return 1;
	}
    return 1;
}

dcmd_alogin(playerid,params[])
{
    if (PlayerInfo[playerid][LoggedIn] == 1) return SendClientMessage(playerid,red,"ACCOUNT: You are already logged in.");
    if (!udb_Exists(PlayerName2(playerid))) return SendClientMessage(playerid,red,"ACCOUNT: Account doesn't exist, please use '/aregister [password]'.");
    if (strlen(params)==0) return SendClientMessage(playerid,red,"ACCOUNT: Correct usage: '/alogin [password]'");
    if (udb_CheckLogin(PlayerName2(playerid),params))
	{
	   	new file[256], tmp3[100], string[128];
	   	format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(PlayerName2(playerid)) );
   		GetPlayerIp(playerid,tmp3,100);
	   	dini_Set(file,"ip",tmp3);
		LoginPlayer(playerid);
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		if(PlayerInfo[playerid][Level] > 0) {
			format(string,sizeof(string),"ACCOUNT: Successfully Logged In. (Level %d)", PlayerInfo[playerid][Level] );
			return SendClientMessage(playerid,green,string);
       	} else return SendClientMessage(playerid,green,"ACCOUNT: Successfully Logged In");
	}
	else {
		PlayerInfo[playerid][FailLogin]++;
		printf("LOGIN: %s has failed to login, Wrong password (%s) Attempt (%d)", PlayerName2(playerid), params, PlayerInfo[playerid][FailLogin] );
		if(PlayerInfo[playerid][FailLogin] == MAX_FAIL_LOGINS)
		{
			new string[128]; format(string, sizeof(string), "%s has been kicked (Failed Logins)", PlayerName2(playerid) );
			SendClientMessageToAll(grey, string); print(string);
			Kick(playerid);
		}
		return SendClientMessage(playerid,red,"ACCOUNT: Login failed! Incorrect Password");
	}
}

dcmd_achangepass(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1)	{
		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /achangepass [new password]");
		if(strlen(params) < 4) return SendClientMessage(playerid,red,"ACCOUNT: Incorrect password length");
		new string[128];
		dUserSetINT(PlayerName2(playerid)).("password_hash",udb_hash(params) );
		dUserSet(PlayerName2(playerid)).("Password",params);
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
        format(string, sizeof(string),"ACCOUNT: You have successfully changed your password to [ %s ]",params);
		return SendClientMessage(playerid,yellow,string);
	} else return SendClientMessage(playerid,red, "ERROR: You must have an account to use this command");
}

dcmd_asetpass(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 4) {
	    new string[128], tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "USAGE: /asetpass [playername] [new password]");
		if(strlen(tmp2) < 4 || strlen(tmp2) > MAX_PLAYER_NAME) return SendClientMessage(playerid,red,"ERROR: Incorrect password length");
		if(udb_Exists(tmp)) {
			dUserSetINT(tmp).("password_hash", udb_hash(tmp2));
			PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
    	    format(string, sizeof(string),"ACCOUNT: You have successfully set \"%s's\" account password to \"%s\"", tmp, tmp2);
			return SendClientMessage(playerid,yellow,string);
		} else return SendClientMessage(playerid,red, "ERROR: This player doesnt have an account");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

#if defined USE_STATS
dcmd_aresetstats(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][LoggedIn] == 1)	{
		// save as backup
	   	dUserSetINT(PlayerName2(playerid)).("oldkills",PlayerInfo[playerid][Kills]);
	   	dUserSetINT(PlayerName2(playerid)).("olddeaths",PlayerInfo[playerid][pDeaths]);
		// stats reset
		PlayerInfo[playerid][Kills] = 0;
		PlayerInfo[playerid][pDeaths] = 0;
		dUserSetINT(PlayerName2(playerid)).("kills",PlayerInfo[playerid][Kills]);
	   	dUserSetINT(PlayerName2(playerid)).("deaths",PlayerInfo[playerid][pDeaths]);
        PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		return SendClientMessage(playerid,yellow,"ACCOUNT: You have successfully reset your stats. Your kills and deaths are: 0");
	} else return SendClientMessage(playerid,red, "ERROR: You must have an account to use this command");
}

dcmd_astats(playerid,params[])
{
	new string[128], player1, h, m, s;
	if(!strlen(params)) player1 = playerid;
	else player1 = strval(params);

	if(IsPlayerConnected(player1)) {
	    TotalGameTime(player1, h, m, s);
 		if(PlayerInfo[player1][pDeaths] == 0) Deathsp[player1] = 1; else Deathsp[player1] = PlayerInfo[player1][pDeaths];
 		format(string, sizeof(string), "%s's Stats:  Kills: %d, Deaths: %d, Admin Level: %d, Vip Level: %d, Ratio: %0.2f, Money: $%d, Time: %d, hrs %d, mins %d, secs |",PlayerName2(player1), Killsp[player1], Deathsp[player1],PlayerInfo[player1][Level],PlayerInfo[player1][pVip], Float:Killsp[player1]/Float:Deathsp[player1],GetPlayerMoneyEx(player1), h, m, s);
		return SendClientMessage(playerid, green, string);
	} else return SendClientMessage(playerid, red, "Player Not Connected!");
}
#endif


#else


dcmd_register(playerid,params[])
{
    if (PlayerInfo[playerid][LoggedIn] == 1) return SendClientMessage(playerid,red,"ACCOUNT: You are already registered and logged in.");
    if (udb_Exists(PlayerName2(playerid))) return SendClientMessage(playerid,red,"ACCOUNT: This account already exists, please use '/login [password]'.");
    if (strlen(params) == 0) return SendClientMessage(playerid,red,"ACCOUNT: Correct usage: '/register [password]'");
    if (strlen(params) < 4 || strlen(params) > 20) return SendClientMessage(playerid,red,"ACCOUNT: Password length must be greater than three characters");
    if (udb_Create(PlayerName2(playerid),params))
	{
    	new file[256],name[MAX_PLAYER_NAME], tmp3[100];
    	new strdate[20], year,month,day;	getdate(year, month, day);
		GetPlayerName(playerid,name,sizeof(name)); format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(name));
     	GetPlayerIp(playerid,tmp3,100);	dini_Set(file,"ip",tmp3);
//    	dini_Set(file,"password",params);
	    dUserSetINT(PlayerName2(playerid)).("registered",1);
   		format(strdate, sizeof(strdate), "%d/%d/%d",day,month,year);
		dini_Set(file,"RegisteredDate",strdate);
		dUserSetINT(PlayerName2(playerid)).("loggedin",1);
		dUserSetINT(PlayerName2(playerid)).("banned",0);
		dUserSetINT(PlayerName2(playerid)).("level",0);
		dUserSetINT(PlayerName2(playerid)).("Vip",0);
	    dUserSetINT(PlayerName2(playerid)).("LastOn",0);
    	dUserSetINT(PlayerName2(playerid)).("money",0);
    	dUserSetINT(PlayerName2(playerid)).("Score",0);
    	dUserSetINT(PlayerName2(playerid)).("kills",0);
	   	dUserSetINT(PlayerName2(playerid)).("deaths",0);
	   	dUserSetINT(PlayerName2(playerid)).("hours",0);
	   	dUserSetINT(PlayerName2(playerid)).("minutes",0);
	   	dUserSetINT(PlayerName2(playerid)).("seconds",0);
	   	dUserSetINT(PlayerName2(playerid)).("Jailed",0);
	   	dUserSetINT(PlayerName2(playerid)).("DJ",0);
	   	dUserSetINT(PlayerName2(playerid)).("Maths",0);
	   	dUserSetINT(PlayerName2(playerid)).("Reacts",0);
	   	dUserSetINT(PlayerName2(playerid)).("CPs",0);
	   	dUserSetINT(PlayerName2(playerid)).("MoneyBag",0);
	   	dUserSetINT(PlayerName2(playerid)).("CookieJar",0);
	   	dUserSetINT(PlayerName2(playerid)).("FavSkin",1);
	   	dUserSetINT(PlayerName2(playerid)).("Cookies",0);
	   	dUserSetINT(PlayerName2(playerid)).("Brownies",0);
	   	dUserSetINT(PlayerName2(playerid)).("VIPTime",0);
		PlayerInfo[playerid][LoggedIn] = 1;
	    PlayerInfo[playerid][Registered] = 1;
	    SendClientMessage(playerid, green, "ACCOUNT: You are now registered, and have been automaticaly logged in.");
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		return 1;
	}
    return 1;
}

dcmd_login(playerid,params[])
{
    if (PlayerInfo[playerid][LoggedIn] == 1) return SendClientMessage(playerid,red,"ACCOUNT: You are already logged in.");
    if (!udb_Exists(PlayerName2(playerid))) return SendClientMessage(playerid,red,"ACCOUNT: Account doesn't exist, please use '/register [password]'.");
    if (strlen(params)==0) return SendClientMessage(playerid,red,"ACCOUNT: Correct usage: '/login [password]'");
    if (udb_CheckLogin(PlayerName2(playerid),params))
	{
		new file[256], tmp3[100], string[128];
	   	format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(PlayerName2(playerid)) );
	   	PlayerInfo[playerid][pDeaths] = (dUserINT(PlayerName2(playerid)).("deaths"));
        PlayerInfo[playerid][Kills] = (dUserINT(PlayerName2(playerid)).("kills"));
   		GetPlayerIp(playerid,tmp3,100);
	   	dini_Set(file,"ip",tmp3);
		LoginPlayer(playerid);
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
	   	if(PlayerInfo[playerid][Level] == 1) {
			format(string,sizeof(string),"Welcome back {0000FF}Trial Moderator");
			SendClientMessage(playerid,green,string);
			}
        if(PlayerInfo[playerid][Level] == 2) {
			format(string,sizeof(string),"Welcome back {919191}Mod");
			SendClientMessage(playerid,green,string);
			}
		if(PlayerInfo[playerid][Level] == 3) {
			format(string,sizeof(string),"Welcome back {FF6600}Co-Admin");
			SendClientMessage(playerid,green,string);
			}
		if(PlayerInfo[playerid][Level] == 4) {
			format(string,sizeof(string),"Welcome back {FF0000}Admin");
			SendClientMessage(playerid,green,string);
			}
		if(PlayerInfo[playerid][Level] == 5) {
			format(string,sizeof(string),"Welcome back {FFFFFF}Leader" );
			SendClientMessage(playerid,green,string);
			}
		if(PlayerInfo[playerid][Level] == 6) {
			format(string,sizeof(string),"Welcome back {00FFFF}Manager/CEO");
			SendClientMessage(playerid,green,string);
			}
		if(PlayerInfo[playerid][pVip] == 1)
		{
			format(string,sizeof(string),"ACCOUNT: Successfully Logged In. ({E9E9E9}Silver)");
			SendClientMessage(playerid,green,string);
		}
		if(PlayerInfo[playerid][pVip] == 2)
		{
			format(string,sizeof(string),"ACCOUNT: Successfully Logged In. ({FFFF00}Gold)", Ranks );
			SendClientMessage(playerid,green,string);
		}
		if(PlayerInfo[playerid][pVip] == 3)
		{
			format(string,sizeof(string),"ACCOUNT: Successfully Logged In. ({0000FF}Platinum VIP{0000FF})");
			SendClientMessage(playerid,green,string);
		}
		LoginPlayer(playerid);
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		if(PlayerInfo[playerid][Level] > 0) {
			format(string,sizeof(string),"ACCOUNT: Successfully Logged In.(%s)", Ranks );
			return SendClientMessage(playerid,green,string);
       	} else return SendClientMessage(playerid,green,"ACCOUNT: Successfully Logged In");
	}
	else {
		PlayerInfo[playerid][FailLogin]++;
		printf("LOGIN: %s has failed to login, Wrong password (%s) Attempt (%d)", PlayerName2(playerid), params, PlayerInfo[playerid][FailLogin] );
		if(PlayerInfo[playerid][FailLogin] == MAX_FAIL_LOGINS)
		{
			new string[128]; format(string, sizeof(string), "%s has been automatically kicked.Reason:(Many attempts incorrect password)", PlayerName2(playerid) );
			SendClientMessageToAll(grey, string);
			print(string);
			Kick(playerid);
		}
		return SendClientMessage(playerid,red,"ACCOUNT: Login failed! Incorrect Password");
	}
}

dcmd_changepass(playerid,params[])
{
	if(PlayerInfo[playerid][LoggedIn] == 1)	{
		if(!strlen(params)) return SendClientMessage(playerid, red, "USAGE: /changepass [new password]");
		if(strlen(params) < 4) return SendClientMessage(playerid,red,"ACCOUNT: Incorrect password length");
		new string[128];
		dUserSetINT(PlayerName2(playerid)).("password_hash",udb_hash(params) );
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
        format(string, sizeof(string),"ACCOUNT: You have successfully changed your password to \"%s\"",params);
		return SendClientMessage(playerid,yellow,string);
	} else return SendClientMessage(playerid,red, "ERROR: You must have an account to use this command");
}

dcmd_setpass(playerid,params[])
{
    if(PlayerInfo[playerid][Level] >= 3) {
	    new string[128], tmp[256], tmp2[256], Index; tmp = strtok(params,Index), tmp2 = strtok(params,Index);
	    if(!strlen(tmp) || !strlen(tmp2)) return SendClientMessage(playerid, red, "USAGE: /setpass [playername] [new password]");
		if(strlen(tmp2) < 4 || strlen(tmp2) > MAX_PLAYER_NAME) return SendClientMessage(playerid,red,"ERROR: Incorrect password length");
		if(udb_Exists(tmp)) {
			dUserSetINT(tmp).("password_hash", udb_hash(tmp2));
			PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
    	    format(string, sizeof(string),"ACCOUNT: You have successfully set \"%s's\" account password to \"%s\"", tmp, tmp2);
			return SendClientMessage(playerid,yellow,string);
		} else return SendClientMessage(playerid,red, "ERROR: This player doesnt have an account");
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
}

#if defined USE_STATS
dcmd_resetstats(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][LoggedIn] == 1)	{
		// save as backup
	   	dUserSetINT(PlayerName2(playerid)).("oldkills",PlayerInfo[playerid][Kills]);
	   	dUserSetINT(PlayerName2(playerid)).("olddeaths",PlayerInfo[playerid][pDeaths]);
		// stats reset
		PlayerInfo[playerid][Kills] = 0;
		PlayerInfo[playerid][pDeaths] = 0;
		dUserSetINT(PlayerName2(playerid)).("kills",PlayerInfo[playerid][Kills]);
	   	dUserSetINT(PlayerName2(playerid)).("deaths",PlayerInfo[playerid][pDeaths]);
        PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		return SendClientMessage(playerid,yellow,"ACCOUNT: You have successfully reset your stats. Your kills and deaths are: 0");
	} else return SendClientMessage(playerid,red, "ERROR: You must have an account to use this command");
}
#endif

#if defined USE_STATS
dcmd_stats(playerid, params[])
{
	new id;
	if(!sscanf(params, "u", id))
	{
		if(PlayerInfo[id][LoggedIn] == 0) return SendClientMessage(playerid, -1, "» Player not logged in.");
        //else if(id != INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "» Invalid player ID.");
		else if(IsPlayerConnected(id))
		{
			ShowStats(playerid, id);

			new string[128];
			format(string, sizeof(string), "[STATISTICS] Now viewing %s's stats.", pName(id));
			SendClientMessage(playerid, -1, string);
		}
	}
	else
	{
	    ShowStats(playerid, playerid);
	    SendClientMessage(playerid, COLOR_YELLOW, "[NOTE] You can also use /stats <ID>");
	}
	return 1;
}
dcmd_mystats(playerid,params[])
{
	new string[128], player1, h, m;
	if(!strlen(params)) player1 = playerid;
	else player1 = strval(params);

	if(IsPlayerConnected(player1)) {
	    TotalGameTime(player1, h, m);
 		Deathsp[player1] = PlayerInfo[player1][pDeaths];
    	format(string, sizeof(string), "Stats: Admin: %d, VIP: %d, Cash: $%d, Score: %d, Time: %d hrs %d mins, Kills: %d, Deaths: %d Skin: %d, Ratio: %0.2f",PlayerInfo[player1][Level], PlayerInfo[player1][pVip],GetPlayerMoneyEx(player1),GetPlayerScore(player1), h, m, Killsp[player1], Deathsp[player1], GetPlayerSkin(player1));
	    return SendClientMessage(playerid, green, string);
	} else return 1;
}
dcmd_descp(playerid, params[]) {
	new string[100], descp[101];
	if(sscanf(params, "s[100]i", string))
	{
	    format(string, sizeof(string), "Your current description: %s", PlayerInfo[playerid][accDescp]);
	    SendClientMessage(playerid, COLOR_YELLOW, string);
	    SendClientMessage(playerid, COLOR_RED, "USAGE: /descp [description of yourself]");
	    return 1;
	}
	if(strlen(descp) < 4 || strlen(descp) > 60) return SendClientMessage(playerid, -1, "» Invalid description length.");

	format(PlayerInfo[playerid][accDescp], 100, "%s", descp);

	SendClientMessage(playerid, -1, "» Your description has been changed.");
	return 1;
}
#endif


#endif

dcmd_freshall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 2)
	{
		for(new i=0;i<MAX_PLAYERS;i++)
		{
		    PlayAudioStreamForPlayer(i, "http://193.108.24.21:8000/fresh");
		}
	}
	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}
dcmd_njoyall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 2)
	{
		for(new i=0;i<MAX_PLAYERS;i++)
		{
		    PlayAudioStreamForPlayer(i, "http://live.btvradio.bg/njoy.mp3.m3u");
		}
	}
	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}
dcmd_cityall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 2)
	{
		for(new i=0;i<MAX_PLAYERS;i++)
		{
		    PlayAudioStreamForPlayer(i, "http://149.13.0.81/city.ogg");
		}
	}
	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}
dcmd_trapall(playerid,params[])
{
    #pragma unused params
	if(PlayerInfo[playerid][Level] >= 2)
	{
		for(new i=0;i<MAX_PLAYERS;i++)
		{
		    PlayAudioStreamForPlayer(i, "http://radio.trap.fm/listen192.m3u");
		}
	}
	else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;
}

dcmd_tbsall(playerid,params[])
{
   #pragma unused params
   if(PlayerInfo[playerid][Level] >=2)
   {
	   for(new i=0;i<MAX_PLAYERS;i++)
	   {
		  PlayAudioStreamForPlayer(i, "http://62.75.158.36:8000/stream");
	   }
	   new string[256];
	   format(string, sizeof(string), "Administrator %s has played TBS's Official Radio for All Players!", PlayerName2(playerid));
	   SendClientMessageToAll(COLOR_BLUE, string);
   }
   else return SendClientMessage(playerid,red, "{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
   return 1;
}

LoginPlayer(playerid)
{
	if(ServerInfo[GiveMoney] == 1) {ResetPlayerMoneyEx(playerid); GivePlayerMoneyEx(playerid, dUserINT(PlayerName2(playerid)).("money") ); }
	dUserSetINT(PlayerName2(playerid)).("loggedin",1);
 	PlayerInfo[playerid][Level] = (dUserINT(PlayerName2(playerid)).("level"));
 	PlayerInfo[playerid][Kills] = (dUserINT(PlayerName2(playerid)).("kills"));
 	PlayerInfo[playerid][pDeaths] = (dUserINT(PlayerName2(playerid)).("deaths"));
 	PlayerInfo[playerid][pVip] = (dUserINT(PlayerName2(playerid)).("AccountType"));
   	PlayerInfo[playerid][hours] = dUserINT(PlayerName2(playerid)).("hours");
   	PlayerInfo[playerid][mins] = dUserINT(PlayerName2(playerid)).("minutes");
   	PlayerInfo[playerid][secs] = dUserINT(PlayerName2(playerid)).("seconds");
	PlayerInfo[playerid][accDate] = dUserINT(PlayerName2(playerid)).("MemberSince");
	PlayerScore[playerid] = dUserINT(PlayerName2(playerid)).("Score");
    PlayerInfo[playerid][accDescp] = dUserINT(PlayerName2(playerid)).("accDescp");
    PlayerInfo[playerid][HS] = dUserINT(PlayerName2(playerid)).("HS");
	PlayerInfo[playerid][Jailed] = dUserINT(PlayerName2(playerid)).("Jailed");
	PlayerInfo[playerid][isDJ] = dUserINT(PlayerName2(playerid)).("DJ");
	PlayerInfo[playerid][Mathematics] = dUserINT(PlayerName2(playerid)).("Maths");
	PlayerInfo[playerid][Reactions] = dUserINT(PlayerName2(playerid)).("Reacts");
	PlayerInfo[playerid][CheckPoints] = dUserINT(PlayerName2(playerid)).("CPs");
	PlayerInfo[playerid][MoneyBags] = dUserINT(PlayerName2(playerid)).("MoneyBag");
	PlayerInfo[playerid][CookieJars] = dUserINT(PlayerName2(playerid)).("CookieJar");
	PlayerInfo[playerid][Cookies] = dUserINT(PlayerName2(playerid)).("Cookies");
	PlayerInfo[playerid][pBrownies] = dUserINT(PlayerName2(playerid)).("Brownies");
	TimeVIP[playerid] = dUserINT(PlayerName2(playerid)).("VIPTime");

	SetPlayerScore(playerid, PlayerScore[playerid]);
	PlayerInfo[playerid][Registered] = 1;
 	PlayerInfo[playerid][LoggedIn] = 1;

	PlayerInfo[playerid][ChatColor] = 4294967295;
	if(PlayerInfo[playerid][Level] == 5) {
	PlayerInfo[playerid][ChatColor] = 0x00FFFFFF;
	}
	if(PlayerInfo[playerid][Level] == 6) {
	PlayerInfo[playerid][ChatColor] = 0x0000FFFF;
	}
}

//=============================================================================
public OnPlayerCommandText(playerid, cmdtext[])
{
    if(PlayerInfo[playerid][Jailed] == 1 && PlayerInfo[playerid][Level] < 0) return
	    SendClientMessage(playerid,red,"You cannot use commands in jail");

	new cmd[256], string[128], tmp[256], idx;
	cmd = strtok(cmdtext, idx);

	#if defined USE_AREGISTER
	  	dcmd(aregister,9,cmdtext);
		dcmd(alogin,6,cmdtext);
  		dcmd(achangepass,11,cmdtext);
	  	dcmd(asetpass,8,cmdtext);
	  	#if defined USE_STATS
		dcmd(astats,6,cmdtext);
		dcmd(aresetstats,11,cmdtext);
		#endif

	#else

  		dcmd(register,8,cmdtext);
		dcmd(login,5,cmdtext);
	  	dcmd(changepass,10,cmdtext);
	  	dcmd(setpass,7,cmdtext);
	  	#if defined USE_STATS
			dcmd(stats,5,cmdtext);
			dcmd(resetstats,10,cmdtext);
			dcmd(mystats,7,cmdtext);
            dcmd(descp,5,cmdtext);
		#endif

	#endif


	dcmd(reports,7,cmdtext);

    //================ [ Read Comamands ] ===========================//
	if(ServerInfo[ReadCmds] == 1)
	{
		format(string, sizeof(string), "*** %s (%d) typed: %s", pName(playerid),playerid,cmdtext);
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(IsPlayerConnected(i)) {
				if( (PlayerInfo[i][Level] > PlayerInfo[playerid][Level]) && (PlayerInfo[i][Level] >= 3) && (i != playerid) ) {
					SendClientMessage(i, grey, string);
				}
			}
		}
	}

	//-= Spectate Commands =-//
	#if defined ENABLE_SPEC
	dcmd(lspec,5,cmdtext);
	dcmd(lspecoff,8,cmdtext);
	dcmd(lspecvehicle,12,cmdtext);
	dcmd(spec,4,cmdtext);
	dcmd(specoff,7,cmdtext);
	#endif

	// New
	dcmd(ceoarea,7,cmdtext);
	dcmd(adminarea2,10,cmdtext);
	dcmd(djarea,6,cmdtext);
	dcmd(filiphome,9,cmdtext);

	//-= Chat Commands =-//
	dcmd(clearplayerchat,15,cmdtext);
	dcmd(cpc,3,cmdtext);
	dcmd(disablechat,11,cmdtext);
	dcmd(clearchat,9,cmdtext);
	dcmd(cc,2,cmdtext);
	dcmd(cleardeathlog,13,cmdtext);
	dcmd(cdl,3,cmdtext);
	dcmd(caps,4,cmdtext);

	//gATES COMMAND
	dcmd(gopen,5,cmdtext);
	dcmd(gclose,6,cmdtext);
	dcmd(ginfo,5,cmdtext);
	dcmd(gatedelete,10,cmdtext);
	dcmd(reloadgates,11,cmdtext);
	dcmd(gatecreate,10,cmdtext);

	//-= Vehicle Commands =-//
	dcmd(rhino,5,cmdtext);
	dcmd(hydra,5,cmdtext);
	dcmd(hunter,6,cmdtext);
	dcmd(destroycar,10,cmdtext);
	dcmd(lockcar,7,cmdtext);
	dcmd(unlockcar,9,cmdtext);
	dcmd(carhealth,9,cmdtext);
	dcmd(setcarcolour,12,cmdtext);
	dcmd(setcarcolor,11,cmdtext);
	dcmd(car,3,cmdtext);
    dcmd(vr,2,cmdtext);
    dcmd(fix,3,cmdtext);
    dcmd(repair,6,cmdtext);
    dcmd(ltune,5,cmdtext);
    dcmd(lhy,3,cmdtext);
    dcmd(lcar,4,cmdtext);
    dcmd(bike,4,cmdtext);
    dcmd(lheli,5,cmdtext);
	dcmd(lboat,5,cmdtext);
    dcmd(lnos,4,cmdtext);
    dcmd(lplane,6,cmdtext);
    dcmd(vgoto,5,cmdtext);
    dcmd(givecar,7,cmdtext);
    dcmd(flip,4,cmdtext);
    dcmd(ltc,3,cmdtext);
	dcmd(linkcar,7,cmdtext);
	dcmd(stopmusicall,12,cmdtext);
	dcmd(stopall,7,cmdtext);
	dcmd(musicall,8,cmdtext);
	dcmd(djplay,6,cmdtext);
	dcmd(djstop,6,cmdtext);
	dcmd(djs,3,cmdtext);
	dcmd(setdj,5,cmdtext);
	dcmd(djcmds,6,cmdtext);
	dcmd(djhelp,6,cmdtext);

	//Hidden Cmd
	dcmd(ghostmode,9,cmdtext);

    //-= Playerid Commands =-//
	dcmd(botsay,6,cmdtext);
	dcmd(seths,5,cmdtext);
	dcmd(gotohs,6,cmdtext);
	dcmd(givescore,9,cmdtext);
	dcmd(givecash,8,cmdtext);
	dcmd(crash,5,cmdtext);
	dcmd(ip,2,cmdtext);
	dcmd(force,5,cmdtext);
	dcmd(burn,4,cmdtext);
	dcmd(spawn,5,cmdtext);
	dcmd(spawnplayer,11,cmdtext);
	dcmd(disarm,6,cmdtext);
	dcmd(pm,2,cmdtext);
	dcmd(r,1,cmdtext);
	dcmd(me,2,cmdtext);
	dcmd(chatcolor,9,cmdtext);
	dcmd(lotto,5,cmdtext);
	dcmd(lottodraw,9,cmdtext);
	dcmd(jackpot,7,cmdtext);
	dcmd(resetjackpot,12,cmdtext);
	dcmd(gotomb,6,cmdtext);
	dcmd(startmb,7,cmdtext);
	dcmd(togglemb,8,cmdtext);
	dcmd(moneybag,8,cmdtext);
	dcmd(gotocj,6,cmdtext);
	dcmd(startcj,7,cmdtext);
	dcmd(togglecj,8,cmdtext);
	dcmd(cookiejar,9,cmdtext);
	dcmd(pmon,4,cmdtext);
	dcmd(pmoff,5,cmdtext);
	dcmd(enablepm,8,cmdtext);
	dcmd(disablepm,9,cmdtext);
	dcmd(eject,5,cmdtext);
	dcmd(bankrupt,8,cmdtext);
	dcmd(lcredits,8,cmdtext);
	dcmd(sbankrupt,9,cmdtext);
	dcmd(scorelist,9,cmdtext);
	dcmd(setworld,8,cmdtext);
	dcmd(setinterior,11,cmdtext);
    dcmd(ubound,6,cmdtext);
	dcmd(setwanted,9,cmdtext);
	dcmd(setcolour,9,cmdtext);
	dcmd(settime,7,cmdtext);
	dcmd(setweather,10,cmdtext);
	dcmd(setname,7,cmdtext);
	dcmd(setskin,7,cmdtext);
	dcmd(skin,4,cmdtext);
	dcmd(skinid,6,cmdtext);
	dcmd(setscore,8,cmdtext);
	dcmd(setcash,7,cmdtext);
	dcmd(sbon,4,cmdtext);
	dcmd(sboff,5,cmdtext);
	dcmd(sethealth,9,cmdtext);
	dcmd(setarmour,9,cmdtext);
	dcmd(giveweapon,10,cmdtext);
	dcmd(warp,4,cmdtext);
	dcmd(teleplayer,10,cmdtext);
    dcmd(goto,4,cmdtext);
    dcmd(gethere,7,cmdtext);
    dcmd(get,3,cmdtext);
    dcmd(setlevel,8,cmdtext);
	dcmd(lsetlevel,9,cmdtext);
	dcmd(settemplevel,12,cmdtext);
	dcmd(setokills,9,cmdtext);
	dcmd(setodeaths,10,cmdtext);
	dcmd(setkills,8,cmdtext);
	dcmd(setdeaths,9,cmdtext);
	dcmd(sethours,8,cmdtext);
	dcmd(setminutes,10,cmdtext);
	dcmd(setohours,9,cmdtext);
	dcmd(setominutes,11,cmdtext);
	dcmd(fu,2,cmdtext);
    dcmd(warn,4,cmdtext);
    dcmd(kick,4,cmdtext);
    dcmd(ban,3,cmdtext);
    dcmd(banmsg,6,cmdtext);
    dcmd(rban,4,cmdtext);
	dcmd(runban,6,cmdtext);
	dcmd(orban,5,cmdtext);
	dcmd(sban,4,cmdtext);
	dcmd(console,7,cmdtext);
	dcmd(slap,4,cmdtext);
    dcmd(explode,7,cmdtext);
    dcmd(jail,4,cmdtext);
    dcmd(unjail,6,cmdtext);
    dcmd(jailed,6,cmdtext);
    dcmd(freeze,6,cmdtext);
    dcmd(unfreeze,8,cmdtext);
    dcmd(frozen,6,cmdtext);
    dcmd(mute,4,cmdtext);
    dcmd(unmute,6,cmdtext);
    dcmd(muted,5,cmdtext);
    dcmd(akill,5,cmdtext);
    dcmd(weaps,5,cmdtext);
    dcmd(screen,6,cmdtext);
    dcmd(lgoto,5,cmdtext);
    dcmd(aka,3,cmdtext);
    dcmd(highlight,9,cmdtext);
    dcmd(setvip,6,cmdtext);
    dcmd(remwarn,7,cmdtext);
    dcmd(vips,4,cmdtext);
    dcmd(vsay,4,cmdtext);
	dcmd(adminarea1,10,cmdtext);
	dcmd(viparea,7,cmdtext);
	dcmd(vipfunland,10,cmdtext);
	dcmd(vipmenu,7,cmdtext);
	dcmd(nameunban,9,cmdtext);
	dcmd(ounban,6,cmdtext);
	dcmd(unbanip,7,cmdtext);
    dcmd(banip,5,cmdtext);
	dcmd(nameban,7,cmdtext);
	dcmd(oban,4,cmdtext);
	dcmd(removeaccount,13,cmdtext);
	dcmd(delacc,6,cmdtext);
	dcmd(remacc,6,cmdtext);
	dcmd(apromotel,9,cmdtext);
	dcmd(vpromotel,9,cmdtext);
	dcmd(apromote,8,cmdtext);
	dcmd(getip,5,cmdtext);
	dcmd(checkban,8,cmdtext);
	dcmd(checklevel,10,cmdtext);
    dcmd(ademote,7,cmdtext);
	dcmd(djdemote,8,cmdtext);
	dcmd(djpromote,9,cmdtext);
	dcmd(vdemote,7,cmdtext);
	dcmd(vpromote,8,cmdtext);
    dcmd(mdemote,7,cmdtext);
    dcmd(podiumup,8,cmdtext);
    dcmd(podiumdown,10,cmdtext);
    dcmd(podiumfastup,12,cmdtext);
    dcmd(podiumfastdown,14,cmdtext);
    dcmd(podiummegafastup,16,cmdtext);
    dcmd(podiummegafastdown,18,cmdtext);
    dcmd(arespawn,8,cmdtext);
    dcmd(drespawn,8,cmdtext);
    dcmd(orespawn,8,cmdtext);
    dcmd(hide,4,cmdtext);
    dcmd(unhide,6,cmdtext);
    dcmd(aduty,5,cmdtext);
    dcmd(testban,7,cmdtext);
    dcmd(fly,3,cmdtext);
    dcmd(flyoff,6,cmdtext);
    dcmd(giveb,5,cmdtext);
    dcmd(givebo,6,cmdtext);
    dcmd(report,6,cmdtext);
	dcmd(request,7,cmdtext);
	dcmd(requests,8,cmdtext);
	dcmd(giveallscore,12,cmdtext);
    dcmd(superjump,9,cmdtext);
    dcmd(freshall,8,cmdtext);
    dcmd(njoyall,7,cmdtext);
    dcmd(cityall,7,cmdtext);
	dcmd(trapall,7,cmdtext);
	dcmd(tbsall,6,cmdtext);
	dcmd(setmycolor,5,cmdtext);
    dcmd(setcolor,8,cmdtext);
    dcmd(setallcolor,11,cmdtext);
	dcmd(ranks,5,cmdtext);
	dcmd(myrank,6,cmdtext);
	dcmd(payday,6,cmdtext);

	//-= /All Commands =-//
	dcmd(burnall,7,cmdtext);
	dcmd(healall,7,cmdtext);
	dcmd(armourall,9,cmdtext);
	dcmd(muteall,7,cmdtext);
	dcmd(unmuteall,9,cmdtext);
	dcmd(killall,7,cmdtext);
	dcmd(getall,6,cmdtext);
	dcmd(spawnall,8,cmdtext);
	dcmd(freezeall,9,cmdtext);
	dcmd(unfreezeall,11,cmdtext);
	dcmd(explodeall,10,cmdtext);
	dcmd(kickall,7,cmdtext);
	dcmd(slapall,7,cmdtext);
	dcmd(ejectall,8,cmdtext);
	dcmd(disarmall,9,cmdtext);
	dcmd(setallskin,10,cmdtext);
	dcmd(setallwanted,12,cmdtext);
	dcmd(setallweather,13,cmdtext);
	dcmd(setalltime,10,cmdtext);
	dcmd(setallworld,11,cmdtext);
	dcmd(setallscore,11,cmdtext);
	dcmd(setallcash,10,cmdtext);
	dcmd(giveallcash,11,cmdtext);
	dcmd(giveallweapon,13,cmdtext);
	dcmd(djtag,5,cmdtext);
	dcmd(vtag,4,cmdtext);
	dcmd(ttag,4,cmdtext);
	dcmd(mtag,4,cmdtext);
	dcmd(coatag,6,cmdtext);
	dcmd(atag,4,cmdtext);
	dcmd(ltag,4,cmdtext);
	dcmd(ceotag,6,cmdtext);
	dcmd(tbstag,6,cmdtext);
    dcmd(dmtime,6,cmdtext);
	dcmd(dmtimeo,7,cmdtext);
	dcmd(sp,2,cmdtext);
	dcmd(lp,2,cmdtext);
	dcmd(saveallstats,12,cmdtext);
	dcmd(cshop,5,cmdtext);
	dcmd(bshop,5,cmdtext);
	dcmd(giveallcookie,13,cmdtext);
	dcmd(givecookies,11,cmdtext);
	dcmd(brownies,8,cmdtext);
	dcmd(giveallbrownie,14,cmdtext);
	dcmd(givebrownies,12,cmdtext);
	dcmd(fightstyles,11,cmdtext);
	dcmd(fs,2,cmdtext);
	dcmd(brownieshop,11,cmdtext);

    //-= No params =-//
	dcmd(lslowmo,7,cmdtext);
    dcmd(lweaps,6,cmdtext);
    dcmd(lammo,5,cmdtext);
    dcmd(agod,3,cmdtext);
    dcmd(vgod,4,cmdtext);
	dcmd(myarmour,8,cmdtext);
	dcmd(armour,6,cmdtext);
	dcmd(vweaps,6,cmdtext);
    dcmd(sgod,4,cmdtext);
    dcmd(godcar,6,cmdtext);
    dcmd(givegod,7,cmdtext);
    dcmd(takegod,7,cmdtext);
    dcmd(die,3,cmdtext);
    dcmd(jetpack,7,cmdtext);
    dcmd(admins,6,cmdtext);
    dcmd(morning,7,cmdtext);

	//-= Admin special =-//
	dcmd(saveskin,8,cmdtext);
	dcmd(useskin,7,cmdtext);
	dcmd(dontuseskin,11,cmdtext);

	//-= Config =-//
	dcmd(disable,7,cmdtext);
    dcmd(enable,6,cmdtext);
    dcmd(setping,7,cmdtext);
	dcmd(setgravity,10,cmdtext);
    dcmd(uconfig,7,cmdtext);
    dcmd(lconfig,7,cmdtext);
    dcmd(forbidname,10,cmdtext);
    dcmd(forbidword,10,cmdtext);

	//-= Misc =-//
	dcmd(hostname,8,cmdtext);
	dcmd(mapname,7,cmdtext);
	dcmd(gmtext,6,cmdtext);
	dcmd(setmytime,9,cmdtext);
	dcmd(setmyweather,12,cmdtext);
	dcmd(time,4,cmdtext);
	dcmd(lhelp,5,cmdtext);
	dcmd(lcmds,5,cmdtext);
	dcmd(acmds,5,cmdtext);
	dcmd(lcommands,9,cmdtext);
	dcmd(level1,6,cmdtext);
	dcmd(level2,6,cmdtext);
	dcmd(level3,6,cmdtext);
	dcmd(level4,6,cmdtext);
	dcmd(level5,6,cmdtext);
	dcmd(level6,6,cmdtext);
 	dcmd(serverinfo,10,cmdtext);
    dcmd(getid,5,cmdtext);
    dcmd(vcmds,5,cmdtext);
	dcmd(getinfo,7,cmdtext);
    dcmd(laston,6,cmdtext);
	dcmd(seen,4,cmdtext);
	dcmd(ping,4,cmdtext);
    dcmd(countdown,9,cmdtext);
    dcmd(asay,4,cmdtext);
	dcmd(password,8,cmdtext);
	dcmd(lockserver,10,cmdtext);
	dcmd(unlockserver,12,cmdtext);
    dcmd(adminarea,9,cmdtext);
    dcmd(announce,8,cmdtext);
    dcmd(announce2,9,cmdtext);
    dcmd(richlist,8,cmdtext);
    dcmd(miniguns,8,cmdtext);
    dcmd(botcheck,8,cmdtext);
    dcmd(object,6,cmdtext);
    dcmd(pickup,6,cmdtext);
    dcmd(move,4,cmdtext);
    dcmd(moveplayer,10,cmdtext);

    #if defined ENABLE_FAKE_CMDS
	dcmd(fakedeath,9,cmdtext);
	dcmd(fakechat,8,cmdtext);
	dcmd(fakecmd,7,cmdtext);
	#endif

	//-= Menu Commands =-//
    #if defined USE_MENUS
    dcmd(lmenu,5,cmdtext);
    dcmd(ltele,5,cmdtext);
    dcmd(lvehicle,8,cmdtext);
    dcmd(lweapons,8,cmdtext);
    dcmd(lweather,8,cmdtext);
    dcmd(ltmenu,6,cmdtext);
    dcmd(ltime,5,cmdtext);
    dcmd(cm,2,cmdtext);
    #endif



//========================= [ Car Commands ]====================================

	if(strcmp(cmdtext, "/ltunedcar2", true)==0 || strcmp(cmdtext, "/ltc2", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"Error: You already have a vehicle");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,LVehicleIDt;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        LVehicleIDt = CreateVehicle(560,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,LVehicleIDt,0);	    AddVehicleComponent(LVehicleIDt, 1028);	AddVehicleComponent(LVehicleIDt, 1030);	AddVehicleComponent(LVehicleIDt, 1031);	AddVehicleComponent(LVehicleIDt, 1138);	AddVehicleComponent(LVehicleIDt, 1140);  AddVehicleComponent(LVehicleIDt, 1170);
	    AddVehicleComponent(LVehicleIDt, 1028);	AddVehicleComponent(LVehicleIDt, 1030);	AddVehicleComponent(LVehicleIDt, 1031);	AddVehicleComponent(LVehicleIDt, 1138);	AddVehicleComponent(LVehicleIDt, 1140);  AddVehicleComponent(LVehicleIDt, 1170);
	    AddVehicleComponent(LVehicleIDt, 1080);	AddVehicleComponent(LVehicleIDt, 1086); AddVehicleComponent(LVehicleIDt, 1087); AddVehicleComponent(LVehicleIDt, 1010);	PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	ChangeVehiclePaintjob(LVehicleIDt,1);
	   	SetVehicleVirtualWorld(LVehicleIDt, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(LVehicleIDt, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = LVehicleIDt;
		}
	} else SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar3", true)==0 || strcmp(cmdtext, "/ltc3", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"Error: You already have a vehicle");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,LVehicleIDt;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        LVehicleIDt = CreateVehicle(560,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,LVehicleIDt,0);	    AddVehicleComponent(LVehicleIDt, 1028);	AddVehicleComponent(LVehicleIDt, 1030);	AddVehicleComponent(LVehicleIDt, 1031);	AddVehicleComponent(LVehicleIDt, 1138);	AddVehicleComponent(LVehicleIDt, 1140);  AddVehicleComponent(LVehicleIDt, 1170);
	    AddVehicleComponent(LVehicleIDt, 1080);	AddVehicleComponent(LVehicleIDt, 1086); AddVehicleComponent(LVehicleIDt, 1087); AddVehicleComponent(LVehicleIDt, 1010);	PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	ChangeVehiclePaintjob(LVehicleIDt,2);
	   	SetVehicleVirtualWorld(LVehicleIDt, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(LVehicleIDt, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = LVehicleIDt;
		}
	} else SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar4", true)==0 || strcmp(cmdtext, "/ltc4", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"Error: You already have a vehicle");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(559,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
    	AddVehicleComponent(carid,1065);    AddVehicleComponent(carid,1067);    AddVehicleComponent(carid,1162); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073);	ChangeVehiclePaintjob(carid,1);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar5", true)==0 || strcmp(cmdtext, "/ltc5", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"Error: You already have a vehicle");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(565,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
	    AddVehicleComponent(carid,1046); AddVehicleComponent(carid,1049); AddVehicleComponent(carid,1053); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073); ChangeVehiclePaintjob(carid,1);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar6", true)==0 || strcmp(cmdtext, "/ltc6", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"Error: You already have a vehicle");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(558,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
    	AddVehicleComponent(carid,1088); AddVehicleComponent(carid,1092); AddVehicleComponent(carid,1139); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073); ChangeVehiclePaintjob(carid,1);
 	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar7", true)==0 || strcmp(cmdtext, "/ltc7", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"Error: You already have a vehicle");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(561,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
    	AddVehicleComponent(carid,1055); AddVehicleComponent(carid,1058); AddVehicleComponent(carid,1064); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073); ChangeVehiclePaintjob(carid,1);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar8", true)==0 || strcmp(cmdtext, "/ltc8", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"Error: You already have a vehicle");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(562,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
	    AddVehicleComponent(carid,1034); AddVehicleComponent(carid,1038); AddVehicleComponent(carid,1147); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073); ChangeVehiclePaintjob(carid,1);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar9", true)==0 || strcmp(cmdtext, "/ltc9", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"Error: You already have a vehicle");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(567,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
	    AddVehicleComponent(carid,1102); AddVehicleComponent(carid,1129); AddVehicleComponent(carid,1133); AddVehicleComponent(carid,1186); AddVehicleComponent(carid,1188); ChangeVehiclePaintjob(carid,1); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1085); AddVehicleComponent(carid,1087); AddVehicleComponent(carid,1086);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar10", true)==0 || strcmp(cmdtext, "/ltc10", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"Error: You already have a vehicle");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(558,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
   		AddVehicleComponent(carid,1092); AddVehicleComponent(carid,1166); AddVehicleComponent(carid,1165); AddVehicleComponent(carid,1090);
	    AddVehicleComponent(carid,1094); AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1087); AddVehicleComponent(carid,1163);//SPOILER
	    AddVehicleComponent(carid,1091); ChangeVehiclePaintjob(carid,2);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar11", true)==0 || strcmp(cmdtext, "/ltc11", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"Error: You already have a vehicle");
		} else {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(557,X,Y,Z,Angle,1,1,-1);	PutPlayerInVehicle(playerid,carid,0);
		AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1081);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar12", true)==0 || strcmp(cmdtext, "/ltc12", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) {
		SendClientMessage(playerid,red,"Error: You already have a vehicle");
		} else  {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(535,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
		ChangeVehiclePaintjob(carid,1); AddVehicleComponent(carid,1109); AddVehicleComponent(carid,1115); AddVehicleComponent(carid,1117); AddVehicleComponent(carid,1073); AddVehicleComponent(carid,1010);
	    AddVehicleComponent(carid,1087); AddVehicleComponent(carid,1114); AddVehicleComponent(carid,1081); AddVehicleComponent(carid,1119); AddVehicleComponent(carid,1121);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmdtext, "/ltunedcar13", true)==0 || strcmp(cmdtext, "/ltc13", true)==0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if(IsPlayerInAnyVehicle(playerid)) SendClientMessage(playerid,red,"Error: You already have a vehicle");
		else {
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
		new Float:X,Float:Y,Float:Z,Float:Angle,carid;	GetPlayerPos(playerid,X,Y,Z); GetPlayerFacingAngle(playerid,Angle);
        carid = CreateVehicle(562,X,Y,Z,Angle,1,-1,-1);	PutPlayerInVehicle(playerid,carid,0);
  		AddVehicleComponent(carid,1034); AddVehicleComponent(carid,1038); AddVehicleComponent(carid,1147);
		AddVehicleComponent(carid,1010); AddVehicleComponent(carid,1073); ChangeVehiclePaintjob(carid,0);
	   	SetVehicleVirtualWorld(carid, GetPlayerVirtualWorld(playerid)); LinkVehicleToInterior(carid, GetPlayerInterior(playerid));
		PlayerInfo[playerid][pCar] = carid;
		}
	} else SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	return 1;	}
//------------------------------------------------------------------------------
	if(strcmp(cmd, "/lpc", true) == 0)	{
	if(PlayerInfo[playerid][Level] >= 1) {
		if (GetPlayerState(playerid) == 2)
		{
		new VehicleID = GetPlayerVehicleID(playerid), LModel = GetVehicleModel(VehicleID);
        switch(LModel) { case 448,461,462,463,468,471,509,510,521,522,523,581,586, 449: return SendClientMessage(playerid,red,"ERROR: You can not tune this vehicle"); }
		new str[128], Float:pos[3];	format(str, sizeof(str), "%s", cmdtext[2]);
		SetVehicleNumberPlate(VehicleID, str);
		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);	SetPlayerPos(playerid, pos[0]+1, pos[1], pos[2]);
		SetVehicleToRespawn(VehicleID); SetVehiclePos(VehicleID, pos[0], pos[1], pos[2]);
		SetTimerEx("TuneLCar",4000,0,"d",VehicleID);    PlayerPlaySound(playerid,1133,0.0,0.0,0.0);
		SendClientMessage(playerid, blue, "You have changed your licence plate");   CMDMessageToAdmins(playerid,"LP");
		} else {
		SendClientMessage(playerid,red,"Error: You have to be the driver of a vehicle to change its licence plate");	}
	} else	{
  	SendClientMessage(playerid,red,"ERROR: You need to be level 1 use this command");   }
	return 1;	}
//------------------------------------------------------------------------------
 	if(strcmp(cmd, "/spam", true) == 0)	{
		if(PlayerInfo[playerid][Level] >= 5) {
		    tmp = strtok(cmdtext, idx);
			if(!strlen(tmp)) {
				SendClientMessage(playerid, red, "USAGE: /spam [Colour] [Text]");
				SendClientMessage(playerid, red, "Colours: 0=black 1=white 2=red 3=orange 4=yellow 5=green 6=blue 7=purple 8=brown 9=pink");
				return 1;
			}
			new Colour = strval(tmp);
			if(Colour > 9 ) return SendClientMessage(playerid, red, "Colours: 0=black 1=white 2=red 3=orange 4=yellow 5=green 6=blue 7=purple 8=brown 9=pink");
			tmp = strtok(cmdtext, idx);

			format(string,sizeof(string),"%s",cmdtext[8]);

	        if(Colour == 0) 	 for(new i; i < 50; i++) SendClientMessageToAll(black,string);
	        else if(Colour == 1) for(new i; i < 50; i++) SendClientMessageToAll(COLOR_WHITE,string);
	        else if(Colour == 2) for(new i; i < 50; i++) SendClientMessageToAll(red,string);
	        else if(Colour == 3) for(new i; i < 50; i++) SendClientMessageToAll(orange,string);
	        else if(Colour == 4) for(new i; i < 50; i++) SendClientMessageToAll(yellow,string);
	        else if(Colour == 5) for(new i; i < 50; i++) SendClientMessageToAll(COLOR_GREEN1,string);
	        else if(Colour == 6) for(new i; i < 50; i++) SendClientMessageToAll(COLOR_BLUE,string);
	        else if(Colour == 7) for(new i; i < 50; i++) SendClientMessageToAll(COLOR_PURPLE,string);
	        else if(Colour == 8) for(new i; i < 50; i++) SendClientMessageToAll(COLOR_BROWN,string);
	        else if(Colour == 9) for(new i; i < 50; i++) SendClientMessageToAll(COLOR_PINK,string);
			return 1;
		} else return SendClientMessage(playerid,red,"ERROR: You need to be level 5 to use this command");
	}

//------------------------------------------------------------------------------
 	if(strcmp(cmd, "/write", true) == 0) {
	if(PlayerInfo[playerid][Level] >= 2) {
	    tmp = strtok(cmdtext, idx);
		if(!strlen(tmp)) {
			SendClientMessage(playerid, red, "USAGE: /write [Colour] [Text]");
			return SendClientMessage(playerid, red, "Colours: 0=black 1=white 2=red 3=orange 4=yellow 5=green 6=blue 7=purple 8=brown 9=pink");
	 	}
		new Colour;
		Colour = strval(tmp);
		if(Colour > 9 )	{
			SendClientMessage(playerid, red, "USAGE: /write [Colour] [Text]");
			return SendClientMessage(playerid, red, "Colours: 0=black 1=white 2=red 3=orange 4=yellow 5=green 6=blue 7=purple 8=brown 9=pink");
		}
		tmp = strtok(cmdtext, idx);

        CMDMessageToAdmins(playerid,"WRITE");

        if(Colour == 0) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(black,string); return 1;	}
        else if(Colour == 1) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(COLOR_WHITE,string); return 1;	}
        else if(Colour == 2) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(red,string); return 1;	}
        else if(Colour == 3) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(orange,string); return 1;	}
        else if(Colour == 4) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(yellow,string); return 1;	}
        else if(Colour == 5) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(COLOR_GREEN1,string); return 1;	}
        else if(Colour == 6) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(COLOR_BLUE,string); return 1;	}
        else if(Colour == 7) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(COLOR_PURPLE,string); return 1;	}
        else if(Colour == 8) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(COLOR_BROWN,string); return 1;	}
        else if(Colour == 9) {	format(string,sizeof(string),"%s",cmdtext[9]);	SendClientMessageToAll(COLOR_PINK,string); return 1;	}
        return 1;
	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	}
//------------------------------------------------------------------------------
//                      Remote Console
//------------------------------------------------------------------------------

	if(strcmp(cmd, "/loadfs", true) == 0) {
	    if(PlayerInfo[playerid][Level] >= 6) {
    		new str[128]; format(str,sizeof(string),"%s",cmdtext[1]); SendRconCommand(str);
		    return SendClientMessage(playerid,COLOR_WHITE,"RCON Command Sent");
	   	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	}

	if(strcmp(cmd, "/unloadfs", true) == 0)	 {
	    if(PlayerInfo[playerid][Level] >= 6) {
    		new str[128]; format(str,sizeof(string),"%s",cmdtext[1]); SendRconCommand(str);
		    return SendClientMessage(playerid,COLOR_WHITE,"RCON Command Sent");
	   	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	}

	if(strcmp(cmd, "/changemode", true) == 0)	 {
	    if(PlayerInfo[playerid][Level] >= 6) {
    		new str[128]; format(str,sizeof(string),"%s",cmdtext[1]); SendRconCommand(str);
		    return SendClientMessage(playerid,COLOR_WHITE,"RCON Command Sent");
	   	} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	}

	if(strcmp(cmd, "/gmx", true) == 0)	 {
		if(PlayerInfo[playerid][Level] >= 6) {
			OnFilterScriptExit(); SetTimer("RestartGM",5000,0);
			return SendClientMessage(playerid,COLOR_WHITE,"RCON Command Sent");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	}

	if(strcmp(cmd, "/loadladmin", true) == 0)	 {
		if(PlayerInfo[playerid][Level] >= 6) {
			SendRconCommand("loadfs ladmin4");
			return SendClientMessage(playerid,COLOR_WHITE,"RCON Command Sent");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	}

	if(strcmp(cmd, "/unloadladmin", true) == 0)	 {
		if(PlayerInfo[playerid][Level] >= 6) {
			SendRconCommand("unloadfs ladmin4");
			return SendClientMessage(playerid,COLOR_WHITE,"RCON Command Sent");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	}

	if(strcmp(cmd, "/reloadladmin", true) == 0)	 {
		if(PlayerInfo[playerid][Level] >= 6 || IsPlayerAdmin(playerid) ) {
			SendRconCommand("reloadfs ladmin4");
			SendClientMessage(playerid,COLOR_WHITE,"RCON Command Sent");
			return CMDMessageToAdmins(playerid,"RELOADladmin");
		} else return SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	}


	return 0;
}


//==============================================================================
#if defined ENABLE_SPEC

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	new x = 0;
	while(x!=MAX_PLAYERS) {
	    if( IsPlayerConnected(x) &&	GetPlayerState(x) == PLAYER_STATE_SPECTATING &&
			PlayerInfo[x][SpecID] == playerid && PlayerInfo[x][SpecType] == ADMIN_SPEC_TYPE_PLAYER )
   		{
   		    SetPlayerInterior(x,newinteriorid);
		}
		x++;
	}
}
//==============================================================================
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == KEY_JUMP)
	{
		if(SuperJump[playerid] == 1)
		{
           new Float:Jump[3];
           GetPlayerVelocity(playerid, Jump[0], Jump[1], Jump[2]);
           SetPlayerVelocity(playerid, Jump[0], Jump[1], Jump[2]+5);
		}
	}
	if(newkeys == KEY_SECONDARY_ATTACK ){
        if(!IsPlayerInAnyVehicle(playerid)){
            new Float:x, Float:y, Float:z, vehicle;
            GetPlayerPos(playerid, x, y, z );
            GetVehicleWithinDistance(playerid, x, y, z, 20.0, vehicle);

            if(IsVehicleRc(vehicle)){
              PutPlayerInVehicle(playerid, vehicle, 0);
            }
        }
        else {
            new vehicleID = GetPlayerVehicleID(playerid);
            if(IsVehicleRc(vehicleID) || GetVehicleModel(vehicleID) == RC_CAM){
              if(GetVehicleModel(vehicleID) != D_TRAM){
                new Float:x, Float:y, Float:z;
                GetPlayerPos(playerid, x, y, z);
                SetPlayerPos(playerid, x+0.5, y, z+1.0);
                }
            }
        }
    }
}
GetVehicleWithinDistance( playerid, Float:x1, Float:y1, Float:z1, Float:dist, &veh){
    for(new i = 1; i < MAX_VEHICLES; i++){
        if(GetVehicleModel(i) > 0){
            if(GetPlayerVehicleID(playerid) != i ){
            new Float:x, Float:y, Float:z;
            new Float:x2, Float:y2, Float:z2;
            GetVehiclePos(i, x, y, z);
            x2 = x1 - x; y2 = y1 - y; z2 = z1 - z;
            new Float:vDist = (x2*x2+y2*y2+z2*z2);
            if( vDist < dist){
            veh = i;
            dist = vDist;
                }
            }
        }
    }
}
IsVehicleRc( vehicleid ){
    new model = GetVehicleModel(vehicleid);
    switch(model){
    case RC_GOBLIN, RC_BARON, RC_BANDIT, RC_RAIDER, RC_TIGER: return 1;
    default: return 0;
    }
    if (SuperJump[vehicleid] == 1)
    {
		   	new Float:Jump[3];
		    GetPlayerVelocity(vehicleid, Jump[0], Jump[1], Jump[2]);
		    SetPlayerVelocity(vehicleid, Jump[0], Jump[1], Jump[2]+5);
			return 1;
	}
	return 1;
}
//==============================================================================
public OnPlayerEnterVehicle(playerid, vehicleid) {
	for(new x=0; x<MAX_PLAYERS; x++) {
	    if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && PlayerInfo[x][SpecID] == playerid) {
	        TogglePlayerSpectating(x, 1);
	        PlayerSpectateVehicle(x, vehicleid);
	        PlayerInfo[x][SpecType] = ADMIN_SPEC_TYPE_VEHICLE;
		}
	}
	return 1;
}

//==============================================================================
public OnPlayerStateChange(playerid, newstate, oldstate) {
	switch(newstate) {
		case PLAYER_STATE_ONFOOT: {
			switch(oldstate) {
				case PLAYER_STATE_DRIVER: OnPlayerExitVehicle(playerid,255);
				case PLAYER_STATE_PASSENGER: OnPlayerExitVehicle(playerid,255);
			}
		}
	}
	return 1;
}

#endif

//==============================================================================
public OnPlayerExitVehicle(playerid, vehicleid)
{
	if(PlayerInfo[playerid][DoorsLocked] == 1) SetVehicleParamsForPlayer(GetPlayerVehicleID(playerid),playerid,false,false);

	#if defined ENABLE_SPEC
	for(new x=0; x<MAX_PLAYERS; x++) {
    	if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && PlayerInfo[x][SpecID] == playerid && PlayerInfo[x][SpecType] == ADMIN_SPEC_TYPE_VEHICLE) {
        	TogglePlayerSpectating(x, 1);
	        PlayerSpectatePlayer(x, playerid);
    	    PlayerInfo[x][SpecType] = ADMIN_SPEC_TYPE_PLAYER;
		}
	}
	#endif

	return 1;
}

//==============================================================================
//stocks
stock FormatNumber(inum, const sizechar[] = ",") // for commas betewwn numbers`
{
	new string[16];
	format(string, sizeof(string), "%d", inum);

	for(new ilen = strlen(string) - 3; ilen > 0; ilen -= 3)
	{
		strins(string, sizechar, ilen);
	}
	return string;
}
stock ShowStats(playerid, targetid)
{
	if(IsPlayerConnected(targetid))
	{
	    if(PlayerInfo[targetid][LoggedIn] == 1)
	    {
			new Float:ratio = (float(PlayerInfo[targetid][Kills])/float(PlayerInfo[targetid][pDeaths]));
			new yes[4] = "Yes", no[3] = "No";
            new string[350], string2[1600], count, ranks[90], RegDate[256], h, m, file[256]; //,descp[100]
            format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(PlayerName2(targetid)));
			RegDate = dini_Get(file,"RegisteredDate");
	        TotalGameTime(targetid, h, m);
			strcat(string2, "{C0C0C0}Player's Statistics.\n\n");
	        strcat(string2, "{FF0000}General Statistics\n");
			switch(PlayerInfo[targetid][Level])
			{
			    case 0: ranks = "Regular";
			    case 1: ranks = "Trial Moderator";
			    case 2: ranks = "Moderator";
			    case 3: ranks = "Administrator";
			    case 4: ranks = "Senior Administrator";
			    case 5: ranks = "Head Administrator";
				case 6: ranks = "Manager/CEO";
			}
			if(PlayerInfo[targetid][pVip] == 1)
	        {
	            count++;
	            strcat(string, "V.I.P: ");
            }
			if(PlayerInfo[targetid][isDJ] == 1)
	        {
	            count++;
	            strcat(string, "DJ Status: ");
            }
			if(PlayerInfo[targetid][Jailed] == 1)
	        {
	            count++;
	            strcat(string, "Jailed: ");
            }
			format(string, sizeof(string), "{FFFFFF}Name: %s{FFFFFF}\n", pName(targetid));
	        strcat(string2, string);
	        format(string, sizeof(string), "Rank: %s\n", ranks);
	        strcat(string2, string);
		    format(string, sizeof(string), "V.I.P: %s\n", PlayerInfo[targetid][pVip] ? yes : no);
	        strcat(string2, string);
			format(string, sizeof(string), "{FFFFFF}Member Since: %s{FFFFFF}\n", RegDate[targetid]);
	        strcat(string2, string);
			format(string, sizeof(string), "Total Online Time: %02d hours and %02d minutes\n", h,m);
	        strcat(string2, string);
			format(string, sizeof(string), "Score: %d\n", GetPlayerScore(targetid));
	        strcat(string2, string);
	        format(string, sizeof(string), "Cash: {00FF00}${FFFFFF}%d\n", GetPlayerMoneyEx(targetid));
	        strcat(string2, string);
	        format(string, sizeof(string), "Cookies: %d\n", PlayerInfo[targetid][Cookies]);
	        strcat(string2, string);
	        format(string, sizeof(string), "Brownies: %d\n", PlayerInfo[targetid][pBrownies]);
	        strcat(string2, string);
		    format(string, sizeof(string), "DJ Status: %s\n\n", PlayerInfo[targetid][isDJ] ? yes : no);
	        strcat(string2, string);
	        strcat(string2, "{FF0000}Other Statistics\n");
			format(string, sizeof(string), "{FFFFFF}ID: %d{FFFFFF}\n", targetid);
	        strcat(string2, string);
	        format(string, sizeof(string), "Current Online Time: %d hours and %d minutes\n", PlayerInfo[targetid][Hours], PlayerInfo[targetid][Minutes]);
	        strcat(string2, string);
			format(string, sizeof(string), "Mathematics Won: %d\n", PlayerInfo[targetid][Mathematics]);
	        strcat(string2, string);
			format(string, sizeof(string), "Reactions Won: %d\n", PlayerInfo[targetid][Reactions]);
	        strcat(string2, string);
			format(string, sizeof(string), "CheckPoints: %d\n", PlayerInfo[targetid][CheckPoints]);
	        strcat(string2, string);
			format(string, sizeof(string), "Money Bags Found: %d\n", PlayerInfo[targetid][MoneyBags]);
	        strcat(string2, string);
	        format(string, sizeof(string), "Cookies Jars Found: %d\n", PlayerInfo[targetid][CookieJars]);
	        strcat(string2, string);
			format(string, sizeof(string), "Horseshoes Found: %d/30\n", PlayerInfo[targetid][HS]);
	        strcat(string2, string);
			format(string, sizeof(string), "Kills: %d\n", PlayerInfo[targetid][Kills]);
	        strcat(string2, string);
	        format(string, sizeof(string), "Deaths: %d\n\n", PlayerInfo[targetid][pDeaths]);
	        strcat(string2, string);
	        strcat(string2, "{FF0000}More Statistics\n");
			format(string, sizeof(string), "{FFFFFF}Skin ID: %d{FFFFFF}\n", GetPlayerSkin(targetid));
            strcat(string2, string);
			format(string, sizeof(string), "Jailed: %s\n", PlayerInfo[targetid][Jailed] ? yes : no);
	        strcat(string2, string);
			format(string, sizeof(string), "Warnings: %d\n", PlayerInfo[targetid][Warnings]);
	        strcat(string2, string);
			format(string, sizeof(string), "Ratio (K/D): %.3f\n", ratio);
	        strcat(string2, string);
			/*format(descp, sizeof(descp), "%s", PlayerInfo[targetid][accDescp]);
			strcat(string2, "\nSelf Description:\n");*/

			format(string, sizeof string, "{%06x}%s", GetPlayerColor(targetid) >>> 8, pName(targetid));
			ShowPlayerDialog(playerid, DIALOG_STATS, DIALOG_STYLE_MSGBOX, string, string2, "Close", "");
		}
	}
	return 1;
}



stock g_date( g_char[ ] )
{
    new
        g_s_date[ 50 char ],
        g_d_date[ 3 ]
    ;
    getdate( g_d_date[ 0 ], g_d_date[ 1 ], g_d_date[ 2 ] );

    format( g_s_date, sizeof g_s_date, "%02d%s%02d%s%02d", g_d_date[ 0 ], g_char, g_d_date[ 1 ], g_char, g_d_date[ 2 ] );
    return ( g_s_date );
}

#if defined ENABLE_SPEC
stock StartSpectate(playerid, specplayerid)
{
	for(new x=0; x<MAX_PLAYERS; x++) {
	    if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && PlayerInfo[x][SpecID] == playerid) {
	       AdvanceSpectate(x);
		}
	}
	SetPlayerInterior(playerid,GetPlayerInterior(specplayerid));
	TogglePlayerSpectating(playerid, 1);

	if(IsPlayerInAnyVehicle(specplayerid)) {
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(specplayerid));
		PlayerInfo[playerid][SpecID] = specplayerid;
		PlayerInfo[playerid][SpecType] = ADMIN_SPEC_TYPE_VEHICLE;
	}
	else {
		PlayerSpectatePlayer(playerid, specplayerid);
		PlayerInfo[playerid][SpecID] = specplayerid;
		PlayerInfo[playerid][SpecType] = ADMIN_SPEC_TYPE_PLAYER;
	}
	new string[100], Float:hp, Float:ar;
	GetPlayerName(specplayerid,string,sizeof(string));
	GetPlayerHealth(specplayerid, hp);	GetPlayerArmour(specplayerid, ar);
	format(string,sizeof(string),"~n~~n~~n~~n~~n~~n~~n~~n~~w~%s - id:%d~n~< sprint - jump >~n~hp:%0.1f ar:%0.1f $%d", string,specplayerid,hp,ar,GetPlayerMoneyEx(specplayerid) );
	GameTextForPlayer(playerid,string,25000,3);
	return 1;
}
stock GetWeaponID(Name[])
{
    new weapname[40];
	for(new w = 1; w <= 46; w++)
	{
	   if(w == 0 || w ==  19 || w == 20 || w == 21 || w ==44|| w == 45) continue;
       GetWeaponName(w, weapname, sizeof(weapname));
	   if(strfind(weapname,Name,true) != -1)
	   return w;
	}
	return false;
}

GetPName(playerid){
    new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}
stock GivePlayerScore(playerid, score)
{
	SetPlayerScore(playerid, GetPlayerScore(playerid)+score);
	return 1;
}
stock Name(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}
stock TimedTele(playerid, telename[], Float:Px, Float:Py, Float:Pz, interior, seconds)
{
	if(PlayerInfo[playerid][Jailed] == 1) return SendClientMessage(playerid,COLOR_BRIGHTRED,"You cannot escape your punishment!");
	TeleTimer[playerid] = SetTimerEx("ttimer", 1000, true, "i",playerid);
	tseconds[playerid] = seconds;
	format(tstring,45,"You Must wait %d seconds before teleporting", tseconds[playerid]-1);
	if(PlayerInfo[playerid][Level] == 0) SendClientMessage(playerid,COLOR_LIGHTBLUE, tstring);
	vCount[playerid] = 1;
	Tx[playerid] =Px;
	Ty[playerid] =Py;
	Tz[playerid] =Pz;
	Ti[playerid] = interior;
	format(telestring,43,telename);
	return 1;
}
stock StopSpectate(playerid)
{
	TogglePlayerSpectating(playerid, 0);
	PlayerInfo[playerid][SpecID] = INVALID_PLAYER_ID;
	PlayerInfo[playerid][SpecType] = ADMIN_SPEC_TYPE_NONE;
	GameTextForPlayer(playerid,"~n~~n~~n~~w~Spectate mode ended",1000,3);
	return 1;
}
stock IsVehicleEmpty(vehicleid)
{
        for(new i=0; i<MAX_PLAYERS; i++)
        {
                if(IsPlayerInVehicle(i, vehicleid)) return 0;
        }
        return 1;
}
stock AdvanceSpectate(playerid)
{
    if(ConnectedPlayers() == 2) { StopSpectate(playerid); return 1; }
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && PlayerInfo[playerid][SpecID] != INVALID_PLAYER_ID)
	{
	    for(new x=PlayerInfo[playerid][SpecID]+1; x<=MAX_PLAYERS; x++)
		{
	    	if(x == MAX_PLAYERS) x = 0;
	        if(IsPlayerConnected(x) && x != playerid)
			{
				if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && PlayerInfo[x][SpecID] != INVALID_PLAYER_ID || (GetPlayerState(x) != 1 && GetPlayerState(x) != 2 && GetPlayerState(x) != 3))
				{
					continue;
				}
				else
				{
					StartSpectate(playerid, x);
					break;
				}
			}
		}
	}
	return 1;
}
stock ReverseSpectate(playerid)
{
    if(ConnectedPlayers() == 2) { StopSpectate(playerid); return 1; }
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && PlayerInfo[playerid][SpecID] != INVALID_PLAYER_ID)
	{
	    for(new x=PlayerInfo[playerid][SpecID]-1; x>=0; x--)
		{
	    	if(x == 0) x = MAX_PLAYERS;
	        if(IsPlayerConnected(x) && x != playerid)
			{
				if(GetPlayerState(x) == PLAYER_STATE_SPECTATING && PlayerInfo[x][SpecID] != INVALID_PLAYER_ID || (GetPlayerState(x) != 1 && GetPlayerState(x) != 2 && GetPlayerState(x) != 3))
				{
					continue;
				}
				else
				{
					StartSpectate(playerid, x);
					break;
				}
			}
		}
	}
	return 1;
}
stock ReturnPlayerName(pID)
{
    new nameInstance[25];
    GetPlayerName(pID, nameInstance, 25);
    return nameInstance;
}
//-------------------------------------------
forward PosAfterSpec(playerid);
public PosAfterSpec(playerid)
{
	SetPlayerPos(playerid,Pos[playerid][0],Pos[playerid][1],Pos[playerid][2]);
	SetPlayerFacingAngle(playerid,Pos[playerid][3]);
}
#endif

//==============================================================================
EraseVehicle(vehicleid)
{
    for(new players=0;players<=MAX_PLAYERS;players++)
    {
        new Float:X,Float:Y,Float:Z;
        if (IsPlayerInVehicle(players,vehicleid))
        {
            GetPlayerPos(players,X,Y,Z);
            SetPlayerPos(players,X,Y,Z+2);
            SetVehicleToRespawn(vehicleid);
        }
        SetVehicleParamsForPlayer(vehicleid,players,0,1);
    }
    SetTimerEx("VehRes",3000,0,"d",vehicleid);
    return 1;
}

forward CarSpawner(playerid,model);
public CarSpawner(playerid,model)
{
	if(IsPlayerInAnyVehicle(playerid)) SendClientMessage(playerid, red, "You already have a car!");
 	else
	{
    	new Float:x, Float:y, Float:z, Float:angle;
	 	GetPlayerPos(playerid, x, y, z);
	 	GetPlayerFacingAngle(playerid, angle);
		if(PlayerInfo[playerid][pCar] != -1) CarDeleter(PlayerInfo[playerid][pCar]);
	    new vehicleid=CreateVehicle(model, x, y, z, angle, -1, -1, -1);
		PutPlayerInVehicle(playerid, vehicleid, 0);
		SetVehicleVirtualWorld(vehicleid, GetPlayerVirtualWorld(playerid));
		LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid));
		ChangeVehicleColor(vehicleid,0,7);
        PlayerInfo[playerid][pCar] = vehicleid;
	}
	return 1;
}

forward CarDeleter(vehicleid);
public CarDeleter(vehicleid)
{
    for(new i=0;i<MAX_PLAYERS;i++) {
        new Float:X,Float:Y,Float:Z;
    	if(IsPlayerInVehicle(i, vehicleid)) {
    	    RemovePlayerFromVehicle(i);
    	    GetPlayerPos(i,X,Y,Z);
        	SetPlayerPos(i,X,Y+3,Z);
	    }
	    SetVehicleParamsForPlayer(vehicleid,i,0,1);
	}
    SetTimerEx("VehRes",1500,0,"i",vehicleid);
}

forward VehRes(vehicleid);
public VehRes(vehicleid)
{
    DestroyVehicle(vehicleid);
}

public OnVehicleSpawn(vehicleid)
{
	for(new i=0;i<MAX_PLAYERS;i++)
	{
        if(vehicleid==PlayerInfo[i][pCar])
		{
		    CarDeleter(vehicleid);
	        PlayerInfo[i][pCar]=-1;
        }
	}
    return 0;
}
//==============================================================================
forward TuneLCar(VehicleID);
public TuneLCar(VehicleID)
{
	ChangeVehicleColor(VehicleID,0,7);
	AddVehicleComponent(VehicleID, 1010);  AddVehicleComponent(VehicleID, 1087);
}

//==============================================================================

public OnRconCommand(cmd[])
{
	if( strlen(cmd) > 50 || strlen(cmd) == 1 ) return print("Invalid command length (exceeding 50 characters)");

	if(strcmp(cmd, "ladmin", true)==0) {
		print("Rcon Commands");
		print("info, aka, pm, asay, ann, uconfig, chat");
		return true;
	}

	if(strcmp(cmd, "info", true)==0)
	{
	    new TotalVehicles = CreateVehicle(411, 0, 0, 0, 0, 0, 0, 1000);    DestroyVehicle(TotalVehicles);
		new numo = CreateObject(1245,0,0,1000,0,0,0);	DestroyObject(numo);
		new nump = CreatePickup(371,2,0,0,1000);	DestroyPickup(nump);
		new gz = GangZoneCreate(3,3,5,5);	GangZoneDestroy(gz);

		new model[250], nummodel;
		for(new i=1;i<TotalVehicles;i++) model[GetVehicleModel(i)-400]++;
		for(new i=0;i<250;i++) { if(model[i]!=0) {	nummodel++;	}	}

		new string[256];
		print(" ===========================================================================");
		printf("                           Server Info:");
		format(string,sizeof(string),"[ Players Connected: %d || Maximum Players: %d ] [Ratio %0.2f ]",ConnectedPlayers(),GetMaxPlayers(),Float:ConnectedPlayers() / Float:GetMaxPlayers() );
		printf(string);
		format(string,sizeof(string),"[ Vehicles: %d || Models %d || Players In Vehicle: %d ]",TotalVehicles-1,nummodel, InVehCount() );
		printf(string);
		format(string,sizeof(string),"[ InCar %d  ||  OnBike %d ]",InCarCount(),OnBikeCount() );
		printf(string);
		format(string,sizeof(string),"[ Objects: %d || Pickups %d  || Gangzones %d]",numo-1, nump, gz);
		printf(string);
		format(string,sizeof(string),"[ Players In Jail %d || Players Frozen %d || Muted %d ]",JailedPlayers(),FrozenPlayers(), MutedPlayers() );
	    printf(string);
	    format(string,sizeof(string),"[ Admins online %d  RCON admins online %d ]",AdminCount(), RconAdminCount() );
	    printf(string);
		print(" ===========================================================================");
		return true;
	}

	if(!strcmp(cmd, "pm", .length = 2))
	{
	    new arg_1 = argpos(cmd), arg_2 = argpos(cmd, arg_1),targetid = strval(cmd[arg_1]), message[128];

    	if ( !cmd[arg_1] || cmd[arg_1] < '0' || cmd[arg_1] > '9' || targetid > MAX_PLAYERS || targetid < 0 || !cmd[arg_2])
	        print("Usage: \"pm <playerid> <message>\"");

	    else if ( !IsPlayerConnected(targetid) ) print("This player is not connected!");
    	else
	    {
	        format(message, sizeof(message), "[RCON] PM: %s", cmd[arg_2]);
	        SendClientMessage(targetid, COLOR_WHITE, message);
   	        printf("Rcon PM '%s' sent", cmd[arg_1] );
    	}
	    return true;
	}

	if(!strcmp(cmd, "asay", .length = 4))
	{
	    new arg_1 = argpos(cmd), message[128];

    	if ( !cmd[arg_1] || cmd[arg_1] < '0') print("Usage: \"asay  <message>\" (MessageToAdmins)");
	    else
	    {
	        format(message, sizeof(message), "[RCON] MessageToAdmins: %s", cmd[arg_1]);
	        MessageToAdmins(COLOR_WHITE, message);
	        printf("Admin Message '%s' sent", cmd[arg_1] );
    	}
	    return true;
	}

	if(!strcmp(cmd, "ann", .length = 3))
	{
	    new arg_1 = argpos(cmd), message[128];
    	if ( !cmd[arg_1] || cmd[arg_1] < '0') print("Usage: \"ann  <message>\" (GameTextForAll)");
	    else
	    {
	        format(message, sizeof(message), "[RCON]: %s", cmd[arg_1]);
	        GameTextForAll(message,3000,3);
	        printf("GameText Message '%s' sent", cmd[arg_1] );
    	}
	    return true;
	}

	if(!strcmp(cmd, "msg", .length = 3))
	{
	    new arg_1 = argpos(cmd), message[128];
    	if ( !cmd[arg_1] || cmd[arg_1] < '0') print("Usage: \"msg  <message>\" (SendClientMessageToAll)");
	    else
	    {
	        format(message, sizeof(message), "{00FFFF}[RCON]: %s", cmd[arg_1]);
	        SendClientMessageToAll(COLOR_WHITE, message);
	        printf("MessageToAll '%s' sent", cmd[arg_1] );
    	}
	    return true;
	}

	if(strcmp(cmd, "uconfig", true)==0)
	{
		UpdateConfig();
		print("Configuration Successfully Updated");
		return true;
	}

	if(!strcmp(cmd, "aka", .length = 3))
	{
	    new arg_1 = argpos(cmd), targetid = strval(cmd[arg_1]);

    	if ( !cmd[arg_1] || cmd[arg_1] < '0' || cmd[arg_1] > '9' || targetid > MAX_PLAYERS || targetid < 0)
	        print("Usage: aka <playerid>");
	    else if ( !IsPlayerConnected(targetid) ) print("This player is not connected!");
    	else
	    {
			new tmp3[50], playername[MAX_PLAYER_NAME];
	  		GetPlayerIp(targetid,tmp3,50);
			GetPlayerName(targetid, playername, sizeof(playername));
			printf("AKA: [%s id:%d] [%s] %s", playername, targetid, tmp3, dini_Get("ladmin/config/aka.txt",tmp3) );
    	}
	    return true;
	}

	if(!strcmp(cmd, "chat", .length = 4)) {
	for(new i = 1; i < MAX_CHAT_LINES; i++) print(Chat[i]);
    return true;
	}

	return 0;
}

//==============================================================================
//							Menus
//==============================================================================

#if defined USE_MENUS
public OnPlayerSelectedMenuRow(playerid, row) {
  	new Menu:Current = GetPlayerMenu(playerid);
  	new string[128];

    if(Current == LMainMenu) {
        switch(row)
		{
 			case 0:
			{
				if(PlayerInfo[playerid][Level] >= 4) ShowMenuForPlayer(AdminEnable,playerid);
   				else {
   					SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	   				TogglePlayerControllable(playerid,true);
   				}
			}
			case 1:
			{
				if(PlayerInfo[playerid][Level] >= 4) ShowMenuForPlayer(AdminDisable,playerid);
   				else {
   					SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!");
	   				TogglePlayerControllable(playerid,true);
   				}
			}
 			case 2: ShowMenuForPlayer(LWeather,playerid);
 			case 3: ShowMenuForPlayer(LTime,playerid);
   			case 4:	ShowMenuForPlayer(LVehicles,playerid);
			case 5:	ShowMenuForPlayer(LCars,playerid);
 			case 6:
            {
				if(PlayerInfo[playerid][Level] >= 2)
				{
        			if(IsPlayerInAnyVehicle(playerid))
					{
						new LVehicleID = GetPlayerVehicleID(playerid), LModel = GetVehicleModel(LVehicleID);
					    switch(LModel)
						{
							case 448,461,462,463,468,471,509,510,521,522,523,581,586,449:
							{
								SendClientMessage(playerid,red,"ERROR: You can not tune this vehicle");  TogglePlayerControllable(playerid,true);
								return 1;
							}
						}
					    TogglePlayerControllable(playerid,false);	ShowMenuForPlayer(LTuneMenu,playerid);
			        }
					else { SendClientMessage(playerid,red,"ERROR: You do not have a vehicle to tune"); TogglePlayerControllable(playerid,true); }
		    	} else { SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!"); TogglePlayerControllable(playerid,true);	}
			}
  			case 7:
	  		{
	  			if(PlayerInfo[playerid][Level] >= 3) ShowMenuForPlayer(XWeapons,playerid);
			  	else SendClientMessage(playerid,red,"{FF0000}ERROR: {C0C0C0}You don't have enough privileges to use this command!"); TogglePlayerControllable(playerid,true);
			}
			case 8:	 ShowMenuForPlayer(LTele,playerid);
			case 9:
			{
				new Menu:Currentxmenu = GetPlayerMenu(playerid);
	    		HideMenuForPlayer(Currentxmenu,playerid);   TogglePlayerControllable(playerid,true);
		    }
		}
		return 1;
	}//-------------------------------------------------------------------------
	if(Current == AdminEnable) {
		new adminname[MAX_PLAYER_NAME], file[256]; GetPlayerName(playerid, adminname, sizeof(adminname));
		format(file,sizeof(file),"ladmin/config/Config.ini");
		switch(row){
			case 0: { ServerInfo[AntiSwear] = 1; dini_IntSet(file,"AntiSwear",1); format(string,sizeof(string),"Administrator %s has enabled antiswear",adminname); SendClientMessageToAll(blue,string);	}
			case 1: { ServerInfo[NameKick] = 1; dini_IntSet(file,"NameKick",1); format(string,sizeof(string),"Administrator %s has enabled namekick",adminname); SendClientMessageToAll(blue,string);	}
			case 2:	{ ServerInfo[AntiSpam] = 1; dini_IntSet(file,"AntiSpam",1); format(string,sizeof(string),"Administrator %s has enabled antispam",adminname); SendClientMessageToAll(blue,string);	}
			case 3:	{ ServerInfo[MaxPing] = 1000; dini_IntSet(file,"MaxPing",1000); format(string,sizeof(string),"Administrator %s has enabled ping kick",adminname); SendClientMessageToAll(blue,string);	}
			case 4:	{ ServerInfo[ReadCmds] = 1; dini_IntSet(file,"ReadCmds",1); format(string,sizeof(string),"Administrator %s has enabled reading commands",adminname); MessageToAdmins(green,string);	}
			case 5:	{ ServerInfo[ReadPMs] = 1; dini_IntSet(file,"ReadPMs",1); format(string,sizeof(string),"Administrator %s has enabled reading pms",adminname); MessageToAdmins(green,string); }
			case 6:	{ ServerInfo[NoCaps] = 0; dini_IntSet(file,"NoCaps",0); format(string,sizeof(string),"Administrator %s has allowed captial letters in chat",adminname); SendClientMessageToAll(blue,string); }
			case 7:	{ ServerInfo[ConnectMessages] = 1; dini_IntSet(file,"ConnectMessages",1); format(string,sizeof(string),"Administrator %s has enabled connect messages",adminname); SendClientMessageToAll(blue,string); }
			case 8:	{ ServerInfo[AdminCmdMsg] = 1; dini_IntSet(file,"AdminCmdMessages",1); format(string,sizeof(string),"Administrator %s has enabled admin command messages",adminname); MessageToAdmins(green,string); }
			case 9:	{ ServerInfo[AutoLogin] = 1; dini_IntSet(file,"AutoLogin",1); format(string,sizeof(string),"Administrator %s has enabled auto login",adminname); SendClientMessageToAll(blue,string); }
            case 10: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return TogglePlayerControllable(playerid,true);
	}//------------------------------------------------------------------------
	if(Current == AdminDisable) {
		new adminname[MAX_PLAYER_NAME], file[256]; GetPlayerName(playerid, adminname, sizeof(adminname));
		format(file,sizeof(file),"ladmin/config/Config.ini");
		switch(row){
			case 0: { ServerInfo[AntiSwear] = 0; dini_IntSet(file,"AntiSwear",0); format(string,sizeof(string),"Administrator %s has disabled antiswear",adminname); SendClientMessageToAll(blue,string);	}
			case 1: { ServerInfo[NameKick] = 0; dini_IntSet(file,"NameKick",0); format(string,sizeof(string),"Administrator %s has disabled namekick",adminname); SendClientMessageToAll(blue,string);	}
			case 2:	{ ServerInfo[AntiSpam] = 0; dini_IntSet(file,"AntiSpam",0); format(string,sizeof(string),"Administrator %s has disabled antispam",adminname); SendClientMessageToAll(blue,string);	}
			case 3:	{ ServerInfo[MaxPing] = 0; dini_IntSet(file,"MaxPing",0); format(string,sizeof(string),"Administrator %s has disabled ping kick",adminname); SendClientMessageToAll(blue,string);	}
			case 4:	{ ServerInfo[ReadCmds] = 0; dini_IntSet(file,"ReadCmds",0); format(string,sizeof(string),"Administrator %s has disabled reading commands",adminname); MessageToAdmins(green,string);	}
			case 5:	{ ServerInfo[ReadPMs] = 0; dini_IntSet(file,"ReadPMs",0); format(string,sizeof(string),"Administrator %s has disabled reading pms",adminname); MessageToAdmins(green,string); }
			case 6:	{ ServerInfo[NoCaps] = 1; dini_IntSet(file,"NoCaps",1); format(string,sizeof(string),"Administrator %s has prevented captial letters in chat",adminname); SendClientMessageToAll(blue,string); }
			case 7:	{ ServerInfo[ConnectMessages] = 0; dini_IntSet(file,"ConnectMessages",0); format(string,sizeof(string),"Administrator %s has disabled connect messages",adminname); SendClientMessageToAll(blue,string); }
			case 8:	{ ServerInfo[AdminCmdMsg] = 0; dini_IntSet(file,"AdminCmdMessages",0); format(string,sizeof(string),"Administrator %s has disabled admin command messages",adminname); MessageToAdmins(green,string); }
			case 9:	{ ServerInfo[AutoLogin] = 0; dini_IntSet(file,"AutoLogin",0); format(string,sizeof(string),"Administrator %s has disabled auto login",adminname); SendClientMessageToAll(blue,string); }
            case 10: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return TogglePlayerControllable(playerid,true);
	}//-------------------------------------------------------------------------
	if(Current==LVehicles){
		switch(row){
			case 0: ChangeMenu(playerid,Current,twodoor);
			case 1: ChangeMenu(playerid,Current,fourdoor);
			case 2: ChangeMenu(playerid,Current,fastcar);
			case 3: ChangeMenu(playerid,Current,Othercars);
			case 4: ChangeMenu(playerid,Current,bikes);
			case 5: ChangeMenu(playerid,Current,boats);
			case 6: ChangeMenu(playerid,Current,planes);
			case 7: ChangeMenu(playerid,Current,helicopters);
			case 8: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return 1;
	}
	if(Current==twodoor){
		new vehid;
		switch(row){
			case 0: vehid = 533;
			case 1: vehid = 439;
			case 2: vehid = 555;
			case 3: vehid = 422;
			case 4: vehid = 554;
			case 5: vehid = 575;
			case 6: vehid = 536;
			case 7: vehid = 535;
			case 8: vehid = 576;
			case 9: vehid = 401;
			case 10: vehid = 526;
			case 11: return ChangeMenu(playerid,Current,LVehicles);
		}
		return SelectCar(playerid,vehid,Current);
	}
	if(Current==fourdoor){
		new vehid;
		switch(row){
			case 0: vehid = 404;
			case 1: vehid = 566;
			case 2: vehid = 412;
			case 3: vehid = 445;
			case 4: vehid = 507;
			case 5: vehid = 466;
			case 6: vehid = 546;
			case 7: vehid = 511;
			case 8: vehid = 467;
			case 9: vehid = 426;
			case 10: vehid = 405;
			case 11: return ChangeMenu(playerid,Current,LVehicles);
		}
		return SelectCar(playerid,vehid,Current);
	}
	if(Current==fastcar){
		new vehid;
		switch(row){
			case 0: vehid = 480;
			case 1: vehid = 402;
			case 2: vehid = 415;
			case 3: vehid = 587;
			case 4: vehid = 494;
			case 5: vehid = 411;
			case 6: vehid = 603;
			case 7: vehid = 506;
			case 8: vehid = 451;
			case 9: vehid = 477;
			case 10: vehid = 541;
			case 11: return ChangeMenu(playerid,Current,LVehicles);
		}
		return SelectCar(playerid,vehid,Current);
	}
	if(Current==Othercars){
		new vehid;
		switch(row){
			case 0: vehid = 556;
			case 1: vehid = 408;
			case 2: vehid = 431;
			case 3: vehid = 437;
			case 4: vehid = 427;
			case 5: vehid = 432;
			case 6: vehid = 601;
			case 7: vehid = 524;
			case 8: vehid = 455;
			case 9: vehid = 424;
			case 10: vehid = 573;
			case 11: return ChangeMenu(playerid,Current,LVehicles);
		}
		return SelectCar(playerid,vehid,Current);
	}
	if(Current==bikes){
		new vehid;
		switch(row){
			case 0: vehid = 581;
			case 1: vehid = 481;
			case 2: vehid = 462;
			case 3: vehid = 521;
			case 4: vehid = 463;
			case 5: vehid = 522;
			case 6: vehid = 461;
			case 7: vehid = 448;
			case 8: vehid = 471;
			case 9: vehid = 468;
			case 10: vehid = 586;
			case 11: return ChangeMenu(playerid,Current,LVehicles);
		}
		return SelectCar(playerid,vehid,Current);
	}
	if(Current==boats){
		new vehid;
		switch(row){
			case 0: vehid = 472;
			case 1: vehid = 473;
			case 2: vehid = 493;
			case 3: vehid = 595;
			case 4: vehid = 484;
			case 5: vehid = 430;
			case 6: vehid = 453;
			case 7: vehid = 452;
			case 8: vehid = 446;
			case 9: vehid = 454;
			case 10: return ChangeMenu(playerid,Current,LVehicles);
		}
		return SelectCar(playerid,vehid,Current);
	}
	if(Current==planes){
		new vehid;
		switch(row){
			case 0: vehid = 592;
			case 1: vehid = 577;
			case 2: vehid = 511;
			case 3: vehid = 512;
			case 4: vehid = 593;
			case 5: vehid = 520;
			case 6: vehid = 553;
			case 7: vehid = 476;
			case 8: vehid = 519;
			case 9: vehid = 460;
			case 10: vehid = 513;
			case 11: return ChangeMenu(playerid,Current,LVehicles);
		}
		return SelectCar(playerid,vehid,Current);
	}
	if(Current==helicopters){
		new vehid;
		switch(row){
			case 0: vehid = 548;
			case 1: vehid = 425;
			case 2: vehid = 417;
			case 3: vehid = 487;
			case 4: vehid = 488;
			case 5: vehid = 497;
			case 6: vehid = 563;
			case 7: vehid = 447;
			case 8: vehid = 469;
			case 9: return ChangeMenu(playerid,Current,LVehicles);
		}
		return SelectCar(playerid,vehid,Current);
	}

	if(Current==XWeapons){
		switch(row){
			case 0: { GivePlayerWeapon(playerid,24,500); }
			case 1: { GivePlayerWeapon(playerid,31,500); }
			case 2: { GivePlayerWeapon(playerid,26,500); }
			case 3: { GivePlayerWeapon(playerid,27,500); }
			case 4: { GivePlayerWeapon(playerid,28,500); }
			case 5: { GivePlayerWeapon(playerid,35,500); }
			case 6: { GivePlayerWeapon(playerid,38,1000); }
			case 7: { GivePlayerWeapon(playerid,34,500); }
			case 8: return ChangeMenu(playerid,Current,XWeaponsBig);
        	case 9: return ChangeMenu(playerid,Current,XWeaponsSmall);
        	case 10: return ChangeMenu(playerid,Current,XWeaponsMore);
        	case 11: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return TogglePlayerControllable(playerid,true);
	}

	if(Current==XWeaponsBig){
		switch(row){
			case 0: { GivePlayerWeapon(playerid,25,500);  }
			case 1: { GivePlayerWeapon(playerid,30,500); }
			case 2: { GivePlayerWeapon(playerid,33,500); }
			case 3: { GivePlayerWeapon(playerid,36,500); }
			case 4: { GivePlayerWeapon(playerid,37,500); }
			case 5: { GivePlayerWeapon(playerid,29,500); }
			case 6: { GivePlayerWeapon(playerid,32,1000); }
			case 7: return ChangeMenu(playerid,Current,XWeapons);
		}
		return TogglePlayerControllable(playerid,true);
	}

	if(Current==XWeaponsSmall){
		switch(row){
			case 0: { GivePlayerWeapon(playerid,22,500); }//9mm
			case 1: { GivePlayerWeapon(playerid,23,500); }//s9
			case 2: { GivePlayerWeapon(playerid,18,500); }// MC
			case 3: { GivePlayerWeapon(playerid,42,500); }//FE
			case 4: { GivePlayerWeapon(playerid,41,500); }//spraycan
			case 5: { GivePlayerWeapon(playerid,16,500); }//grenade
			case 6: { GivePlayerWeapon(playerid,8,500); }//Katana
			case 7: { GivePlayerWeapon(playerid,9,1000); }//chainsaw
			case 8: return ChangeMenu(playerid,Current,XWeapons);
		}
		return TogglePlayerControllable(playerid,true);
	}

	if(Current==XWeaponsMore){
		switch(row){
			case 0: SetPlayerSpecialAction(playerid, 2);
			case 1: GivePlayerWeapon(playerid,4,500);
			case 2: GivePlayerWeapon(playerid,14,500);
			case 3: GivePlayerWeapon(playerid,43,500);
			case 4: GivePlayerWeapon(playerid,7,500);
			case 5: GivePlayerWeapon(playerid,5,500);
			case 6: GivePlayerWeapon(playerid,2,1000);
			case 7: MaxAmmo(playerid);
			case 8: return ChangeMenu(playerid,Current,XWeapons);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == LTele)
	{
        switch(row)
		{
			case 0: ChangeMenu(playerid,Current,LasVenturasMenu);
			case 1: ChangeMenu(playerid,Current,LosSantosMenu);
			case 2: ChangeMenu(playerid,Current,SanFierroMenu);
			case 3: ChangeMenu(playerid,Current,DesertMenu);
			case 4: ChangeMenu(playerid,Current,FlintMenu);
			case 5: ChangeMenu(playerid,Current,MountChiliadMenu);
			case 6: ChangeMenu(playerid,Current,InteriorsMenu);
			case 7: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return 1;
	}

    if(Current == LasVenturasMenu)
	{
        switch(row)
		{
			case 0: { SetPlayerPos(playerid,2037.0,1343.0,12.0); SetPlayerInterior(playerid,0); }// strip
			case 1: { SetPlayerPos(playerid,2163.0,1121.0,23); SetPlayerInterior(playerid,0); }// come a lot
			case 2: { SetPlayerPos(playerid,1688.0,1615.0,12.0); SetPlayerInterior(playerid,0); }// lv airport
			case 3: { SetPlayerPos(playerid,2503.0,2764.0,10.0); SetPlayerInterior(playerid,0); }// military fuel
			case 4: { SetPlayerPos(playerid,1418.0,2733.0,10.0); SetPlayerInterior(playerid,0); }// golf lv
			case 5: { SetPlayerPos(playerid,1377.0,2196.0,9.0); SetPlayerInterior(playerid,0); }// pitch match
			case 6: return ChangeMenu(playerid,Current,LTele);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == LosSantosMenu)
	{
        switch(row)
		{
			case 0: { SetPlayerPos(playerid,2495.0,-1688.0,13.0); SetPlayerInterior(playerid,0); }// ganton
			case 1: { SetPlayerPos(playerid,1979.0,-2241.0,13.0); SetPlayerInterior(playerid,0); }// ls airport
			case 2: { SetPlayerPos(playerid,2744.0,-2435.0,15.0); SetPlayerInterior(playerid,0); }// docks
			case 3: { SetPlayerPos(playerid,1481.0,-1656.0,14.0); SetPlayerInterior(playerid,0); }// square
			case 4: { SetPlayerPos(playerid,1150.0,-2037.0,69.0); SetPlayerInterior(playerid,0); }// veradant bluffs
			case 5: { SetPlayerPos(playerid,425.0,-1815.0,6.0); SetPlayerInterior(playerid,0); }// santa beach
			case 6: { SetPlayerPos(playerid,1240.0,-744.0,95.0); SetPlayerInterior(playerid,0); }// mullholland
			case 7: { SetPlayerPos(playerid,679.0,-1070.0,49.0); SetPlayerInterior(playerid,0); }// richman
			case 8: return ChangeMenu(playerid,Current,LTele);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == SanFierroMenu)
	{
        switch(row)
		{
			case 0: { SetPlayerPos(playerid,-1990.0,137.0,27.0); SetPlayerInterior(playerid,0); } // sf station
			case 1: { SetPlayerPos(playerid,-1528.0,-206.0,14.0); SetPlayerInterior(playerid,0); }// sf airport
			case 2: { SetPlayerPos(playerid,-2709.0,198.0,4.0); SetPlayerInterior(playerid,0); }// ocean flats
			case 3: { SetPlayerPos(playerid,-2738.0,-295.0,6.0); SetPlayerInterior(playerid,0); }// avispa country club
			case 4: { SetPlayerPos(playerid,-1457.0,465.0,7.0); SetPlayerInterior(playerid,0); }// easter basic docks
			case 5: { SetPlayerPos(playerid,-1853.0,1404.0,7.0); SetPlayerInterior(playerid,0); }// esplanadae north
			case 6: { SetPlayerPos(playerid,-2620.0,1373.0,7.0); SetPlayerInterior(playerid,0); }// battery point
			case 7: return ChangeMenu(playerid,Current,LTele);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == DesertMenu)
	{
        switch(row)
		{
			case 0: { SetPlayerPos(playerid,416.0,2516.0,16.0); SetPlayerInterior(playerid,0); } // plane graveyard
			case 1: { SetPlayerPos(playerid,81.0,1920.0,17.0); SetPlayerInterior(playerid,0); }// area51
			case 2: { SetPlayerPos(playerid,-324.0,1516.0,75.0); SetPlayerInterior(playerid,0); }// big ear
			case 3: { SetPlayerPos(playerid,-640.0,2051.0,60.0); SetPlayerInterior(playerid,0); }// dam
			case 4: { SetPlayerPos(playerid,-766.0,1545.0,27.0); SetPlayerInterior(playerid,0); }// las barrancas
			case 5: { SetPlayerPos(playerid,-1514.0,2597.0,55.0); SetPlayerInterior(playerid,0); }// el qyebrados
			case 6: { SetPlayerPos(playerid,442.0,1427.0,9.0); SetPlayerInterior(playerid,0); }// actane springs
			case 7: return ChangeMenu(playerid,Current,LTele);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == FlintMenu)
	{
        switch(row)
		{
			case 0: { SetPlayerPos(playerid,-849.0,-1940.0,13.0);  SetPlayerInterior(playerid,0); }// lake
			case 1: { SetPlayerPos(playerid,-1107.0,-1619.0,76.0);  SetPlayerInterior(playerid,0); }// leafy hollow
			case 2: { SetPlayerPos(playerid,-1049.0,-1199.0,128.0);  SetPlayerInterior(playerid,0); }// the farm
			case 3: { SetPlayerPos(playerid,-1655.0,-2219.0,32.0);  SetPlayerInterior(playerid,0); }// shady cabin
			case 4: { SetPlayerPos(playerid,-375.0,-1441.0,25.0); SetPlayerInterior(playerid,0); }// flint range
			case 5: { SetPlayerPos(playerid,-367.0,-1049.0,59.0); SetPlayerInterior(playerid,0); }// beacon hill
			case 6: { SetPlayerPos(playerid,-494.0,-555.0,25.0); SetPlayerInterior(playerid,0); }// fallen tree
			case 7: return ChangeMenu(playerid,Current,LTele);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == MountChiliadMenu)
	{
        switch(row)
		{
			case 0: { SetPlayerPos(playerid,-2308.0,-1657.0,483.0);  SetPlayerInterior(playerid,0); }// chiliad jump
			case 1: { SetPlayerPos(playerid,-2331.0,-2180.0,35.0); SetPlayerInterior(playerid,0); }// bottom chiliad
			case 2: { SetPlayerPos(playerid,-2431.0,-1620.0,526.0);  SetPlayerInterior(playerid,0); }// highest point
			case 3: { SetPlayerPos(playerid,-2136.0,-1775.0,208.0);  SetPlayerInterior(playerid,0); }// chiliad path
			case 4: return ChangeMenu(playerid,Current,LTele);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == InteriorsMenu)
	{
        switch(row)
		{
			case 0: {	SetPlayerPos(playerid,386.5259, 173.6381, 1008.3828);	SetPlayerInterior(playerid,3); }
			case 1: {	SetPlayerPos(playerid,288.4723, 170.0647, 1007.1794);	SetPlayerInterior(playerid,3); }
			case 2: {	SetPlayerPos(playerid,372.5565, -131.3607, 1001.4922);	SetPlayerInterior(playerid,5); }
			case 3: {	SetPlayerPos(playerid,-1129.8909, 1057.5424, 1346.4141);	SetPlayerInterior(playerid,10); }
			case 4: {	SetPlayerPos(playerid,2233.9363, 1711.8038, 1011.6312);	SetPlayerInterior(playerid,1); }
			case 5: {	SetPlayerPos(playerid,2536.5322, -1294.8425, 1044.125);	SetPlayerInterior(playerid,2); }
			case 6: {	SetPlayerPos(playerid,1267.8407, -776.9587, 1091.9063);	SetPlayerInterior(playerid,5); }
  			case 7: {	SetPlayerPos(playerid,-1421.5618, -663.8262, 1059.5569);	SetPlayerInterior(playerid,4); }
   			case 8: {	SetPlayerPos(playerid,-1401.067, 1265.3706, 1039.8672);	SetPlayerInterior(playerid,16); }
   			case 9: {	SetPlayerPos(playerid,285.8361, -39.0166, 1001.5156);	SetPlayerInterior(playerid,1); }
    		case 10: {	SetPlayerPos(playerid,1727.2853, -1642.9451, 20.2254);	SetPlayerInterior(playerid,18); }
			case 11: return ChangeMenu(playerid,Current,LTele);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == LWeather)
	{
		new adminname[MAX_PLAYER_NAME]; GetPlayerName(playerid, adminname, sizeof(adminname));
        switch(row)
		{
			case 0:	{	SetWeather(5);	PlayerPlaySound(playerid,1057,0.0,0.0,0.0);	CMDMessageToAdmins(playerid,"LWeather"); format(string,sizeof(string),"Admin/VIP %s has changed the weather to 'Clear Blue Sky'",adminname); SendClientMessageToAll(blue,string); }
   			case 1:	{	SetWeather(19); PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"LWeather");	format(string,sizeof(string),"Admin/VIP %s has changed the weather to 'Sand Storm'",adminname); SendClientMessageToAll(blue,string); }
			case 2:	{	SetWeather(8);  PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"LWeather");	format(string,sizeof(string),"Admin/VIP %s has changed the weather to 'Thunderstorm'",adminname); SendClientMessageToAll(blue,string); }
			case 3:	{	SetWeather(20);	PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"LWeather");	format(string,sizeof(string),"Admin/VIP %s has changed the weather to 'Foggy'",adminname); SendClientMessageToAll(blue,string); }
			case 4:	{	SetWeather(9);  PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"LWeather");	format(string,sizeof(string),"Admin/VIP %s has changed the weather to 'Cloudy'",adminname); SendClientMessageToAll(blue,string); }
			case 5:	{	SetWeather(16); PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"LWeather");	format(string,sizeof(string),"Admin/VIP %s has changed the weather to 'High Tide'",adminname); SendClientMessageToAll(blue,string); }
			case 6:	{	SetWeather(45); PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"LWeather");	format(string,sizeof(string),"Admin/VIP %s has changed the weather to 'Purple Sky'",adminname); SendClientMessageToAll(blue,string); }
			case 7:	{	SetWeather(44); PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"LWeather");	format(string,sizeof(string),"Admin/VIP %s has changed the weather to 'Black/White Sky'",adminname); SendClientMessageToAll(blue,string); }
			case 8:	{	SetWeather(22); PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"LWeather");	format(string,sizeof(string),"Admin/VIP %s has changed the weather to 'Dark, Green Sky'",adminname); SendClientMessageToAll(blue,string); }
			case 9:	{	SetWeather(11); PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"LWeather");	format(string,sizeof(string),"Admin/VIP %s has changed the weather to 'Heatwave'",adminname); SendClientMessageToAll(blue,string); }
			case 10: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == LTuneMenu)
	{
        switch(row)
		{
			case 0:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1010); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Vehicle Component Added");	}
   			case 1:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1087); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Vehicle Component Added"); }
			case 2:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1081); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Vehicle Component Added");	}
			case 3: {	AddVehicleComponent(GetPlayerVehicleID(playerid),1078); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Vehicle Component Added");	}
			case 4:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1098); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Vehicle Component Added");	}
			case 5:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1074); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Vehicle Component Added");	}
			case 6:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1082); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Vehicle Component Added");	}
			case 7:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1085); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Vehicle Component Added");	}
			case 8:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1025); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Vehicle Component Added");	}
			case 9:	{	AddVehicleComponent(GetPlayerVehicleID(playerid),1077); PlayerPlaySound(playerid,1133,0.0,0.0,0.0);	SendClientMessage(playerid,blue,"Vehicle Component Added");	}
			case 10: return ChangeMenu(playerid,Current,PaintMenu);
			case 11: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == PaintMenu)
	{
        switch(row)
		{
			case 0:	{ ChangeVehiclePaintjob(GetPlayerVehicleID(playerid),0); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"Vehicle Paint Changed To Paint Job 1"); }
			case 1:	{ ChangeVehiclePaintjob(GetPlayerVehicleID(playerid),1); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"Vehicle Paint Changed To Paint Job 2"); }
			case 2:	{ ChangeVehiclePaintjob(GetPlayerVehicleID(playerid),2); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"Vehicle Paint Changed To Paint Job 3"); }
			case 3:	{ ChangeVehiclePaintjob(GetPlayerVehicleID(playerid),3); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"Vehicle Paint Changed To Paint Job 4"); }
			case 4:	{ ChangeVehiclePaintjob(GetPlayerVehicleID(playerid),4); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"Vehicle Paint Changed To Paint Job 5"); }
			case 5:	{ ChangeVehicleColor(GetPlayerVehicleID(playerid),0,0); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"Vehicle Paint Colour Changed To Black"); }
			case 6:	{ ChangeVehicleColor(GetPlayerVehicleID(playerid),1,1); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"Vehicle Paint Colour Changed To White"); }
			case 7:	{ ChangeVehicleColor(GetPlayerVehicleID(playerid),79,158); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"Vehicle Paint Colour Changed To Black"); }
			case 8:	{ ChangeVehicleColor(GetPlayerVehicleID(playerid),146,183); PlayerPlaySound(playerid,1133,0.0,0.0,0.0); SendClientMessage(playerid,blue,"Vehicle Paint Colour Changed To Black"); }
			case 9: return ChangeMenu(playerid,Current,LTuneMenu);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == LTime)
	{
		new adminname[MAX_PLAYER_NAME]; GetPlayerName(playerid, adminname, sizeof(adminname));
        switch(row)
		{
			case 0:	{ for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) SetPlayerTime(i,7,0);	PlayerPlaySound(playerid,1057,0.0,0.0,0.0);	CMDMessageToAdmins(playerid,"LTIME MENU");	format(string,sizeof(string),"Admin/VIP %s has changed the time to 'Morning'",adminname); SendClientMessageToAll(blue,string); }
   			case 1:	{ for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) SetPlayerTime(i,12,0); PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"LTIME MENU");	format(string,sizeof(string),"Admin/VIP %s has changed the time to 'Mid day'",adminname); SendClientMessageToAll(blue,string); }
			case 2:	{ for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) SetPlayerTime(i,16,0);  PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"LTIME MENU");	format(string,sizeof(string),"Admin/VIP %s has changed the time to 'Afternoon'",adminname); SendClientMessageToAll(blue,string); }
			case 3:	{ for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) SetPlayerTime(i,20,0);	PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"LTIME MENU");	format(string,sizeof(string),"Admin/VIP %s has changed the time to 'Evening'",adminname); SendClientMessageToAll(blue,string); }
			case 4:	{ for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) SetPlayerTime(i,0,0);  PlayerPlaySound(playerid,1057,0.0,0.0,0.0); CMDMessageToAdmins(playerid,"LTIME MENU");	format(string,sizeof(string),"Admin/VIP %s has changed the time to 'Midnight'",adminname); SendClientMessageToAll(blue,string); }
			case 5: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return TogglePlayerControllable(playerid,true);
	}

    if(Current == LCars)
	{
		new vehid;
        switch(row) {
			case 0: vehid = 451;//Turismo
			case 1: vehid = 568;//Bandito
			case 2: vehid = 539;//Vortex
			case 3: vehid = 522;//nrg
			case 4: vehid = 601;//s.w.a.t
			case 5: vehid = 425; //hunter
			case 6: vehid = 493;//jetmax
			case 7: vehid = 432;//rhino
			case 8: vehid = 444; //mt
			case 9: vehid = 447; //sea sparrow
			case 10: return ChangeMenu(playerid,Current,LCars2);
			case 11: return ChangeMenu(playerid,Current,LMainMenu);
		}
		return SelectCar(playerid,vehid,Current);
	}

    if(Current == LCars2)
	{
		new vehid;
        switch(row) {
			case 0: vehid = 406;// dumper
			case 1: vehid = 564; //rc tank
			case 2: vehid = 441;//RC Bandit
			case 3: vehid = 464;// rc baron
			case 4: vehid = 501; //rc goblin
			case 5: vehid = 465; //rc raider
			case 6: vehid = 594; // rc cam
			case 7: vehid = 449; //tram
			case 8: return ChangeMenu(playerid,Current,LCars);
		}
		return SelectCar(playerid,vehid,Current);
	}

	return 1;
}

//==============================================================================

public OnPlayerExitedMenu(playerid)
{
    new Menu:Current = GetPlayerMenu(playerid);
    HideMenuForPlayer(Current,playerid);
    return TogglePlayerControllable(playerid,true);
}

//==============================================================================

ChangeMenu(playerid,Menu:oldmenu,Menu:newmenu)
{
	if(IsValidMenu(oldmenu)) {
		HideMenuForPlayer(oldmenu,playerid);
		ShowMenuForPlayer(newmenu,playerid);
	}
	return 1;
}

CloseMenu(playerid,Menu:oldmenu)
{
	HideMenuForPlayer(oldmenu,playerid);
	TogglePlayerControllable(playerid,1);
	return 1;
}
SelectCar(playerid,vehid,Menu:menu)
{
	CloseMenu(playerid,menu);
	SetCameraBehindPlayer(playerid);
	CarSpawner(playerid,vehid);
	return 1;
}
#endif

//==============================================================================
forward countdown();
public countdown()
{
	if(CountDown==6) GameTextForAll("~p~Starting...",1000,6);

	CountDown--;
	if(CountDown==0)
	{
		GameTextForAll("~g~GO~ r~!",1000,6);
		CountDown = -1;
		for(new i = 0; i < MAX_PLAYERS; i++) {
			TogglePlayerControllable(i,true);
			PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
		}
		return 0;
	}
	else
	{
		new text[7]; format(text,sizeof(text),"~w~%d",CountDown);
		for(new i = 0; i < MAX_PLAYERS; i++) {
			PlayerPlaySound(i, 1056, 0.0, 0.0, 0.0);
			TogglePlayerControllable(i,false);
		}
	 	GameTextForAll(text,1000,6);
	}

	SetTimer("countdown",1000,0);
	return 0;
}

//==================== [ Jail & Freeze ]========================================

forward Jail1(player1);
public Jail1(player1)
{
	TogglePlayerControllable(player1,false);
	new Float:x, Float:y, Float:z;	GetPlayerPos(player1,x,y,z);
	SetPlayerCameraPos(player1,x+10,y,z+10);SetPlayerCameraLookAt(player1,x,y,z);
	SetTimerEx("Jail2",1000,0,"d",player1);
}

forward Jail2(player1);
public Jail2(player1)
{
	new Float:x, Float:y, Float:z; GetPlayerPos(player1,x,y,z);
	SetPlayerCameraPos(player1,x+7,y,z+5); SetPlayerCameraLookAt(player1,x,y,z);
	if(GetPlayerState(player1) == PLAYER_STATE_ONFOOT) SetPlayerSpecialAction(player1,SPECIAL_ACTION_HANDSUP);
	GameTextForPlayer(player1,"~r~Busted By Admins",3000,3);
	SetTimerEx("Jail3",1000,0,"d",player1);
}

forward Jail3(player1);
public Jail3(player1)
{
	new Float:x, Float:y, Float:z; GetPlayerPos(player1,x,y,z);
	SetPlayerCameraPos(player1,x+3,y,z); SetPlayerCameraLookAt(player1,x,y,z);
}

forward JailPlayer(player1);
public JailPlayer(player1)
{
	TogglePlayerControllable(player1,true);
	JailTimer[player1] = SetTimerEx("JailRelease",PlayerInfo[player1][JailTime],0,"d",player1);
	PlayerInfo[player1][Jailed] = 1;
	SetPlayerPos(player1,197.6661,173.8179,1003.0234);
	SetPlayerInterior(player1,3);
	SetCameraBehindPlayer(player1);
	SetPVarInt(player1, "Jailed", 1);
}

forward JailRelease(player1);
public JailRelease(player1)
{
	KillTimer( JailTimer[player1] );
	PlayerInfo[player1][JailTime] = 0;  PlayerInfo[player1][Jailed] = 0;
	SetPlayerInterior(player1,0); SetPlayerPos(player1, 0.0, 0.0, 0.0); SpawnPlayer(player1);
	PlayerPlaySound(player1,1057,0.0,0.0,0.0);
	GameTextForPlayer(player1,"~g~Released ~n~From Jail",3000,3);
	SetPVarInt(player1, "Jailed", 0);
}

//------------------------------------------------------------------------------
forward UnFreezeMe(player1);
public UnFreezeMe(player1)
{
	KillTimer( FreezeTimer[player1] );
	TogglePlayerControllable(player1,true);   PlayerInfo[player1][Frozen] = 0;
	PlayerPlaySound(player1,1057,0.0,0.0,0.0);	GameTextForPlayer(player1,"~g~Unfrozen",3000,3);
	SetPVarInt(player1, "Frozen", 0);
}

//==============================================================================
forward RepairCar(playerid);
public RepairCar(playerid)
{
	if(IsPlayerInAnyVehicle(playerid)) SetVehiclePos(GetPlayerVehicleID(playerid),Pos[playerid][0],Pos[playerid][1],Pos[playerid][2]+0.5);
	SetVehicleZAngle(GetPlayerVehicleID(playerid), Pos[playerid][3]);
	SetCameraBehindPlayer(playerid);
}

//============================ [ Timers ]=======================================

forward PingKick();
public PingKick()
{
	if(ServerInfo[MaxPing] != 0)
	{
	    PingPos++; if(PingPos > PING_MAX_EXCEEDS) PingPos = 0;

		for(new i=0; i<MAX_PLAYERS; i++)
		{
			PlayerInfo[i][pPing][PingPos] = GetPlayerPing(i);

		    if(GetPlayerPing(i) > ServerInfo[MaxPing])
			{
				if(PlayerInfo[i][PingCount] == 0) PlayerInfo[i][PingTime] = TimeStamp();

	   			PlayerInfo[i][PingCount]++;
				if(TimeStamp() - PlayerInfo[i][PingTime] > PING_TIMELIMIT)
				{
	    			PlayerInfo[i][PingTime] = TimeStamp();
					PlayerInfo[i][PingCount] = 1;
				}
				else if(PlayerInfo[i][PingCount] >= PING_MAX_EXCEEDS)
				{
				    new Sum, Average, x, string[128];
					while (x < PING_MAX_EXCEEDS) {
						Sum += PlayerInfo[i][pPing][x];
						x++;
					}
					Average = (Sum / PING_MAX_EXCEEDS);
					format(string,sizeof(string),"%s has been kicked from the server. (Reason: High Ping (%d) | Average (%d) | Max Allowed (%d) )", PlayerName2(i), GetPlayerPing(i), Average, ServerInfo[MaxPing] );
  		    		SendClientMessageToAll(grey,string);
					SaveToFile("KickLog",string);
					Kick(i);
				}
			}
			else if(GetPlayerPing(i) < 1 && ServerInfo[AntiBot] == 1)
		    {
				PlayerInfo[i][BotPing]++;
				if(PlayerInfo[i][BotPing] >= 3) BotCheck(i);
		    }
		    else
			{
				PlayerInfo[i][BotPing] = 0;
			}
		}
	}
	#if defined ANTI_MINIGUN
	new weap, ammo;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i) && PlayerInfo[i][Level] == 0 && GetPVarInt(i, "inMini") == 0 && GetPVarInt(i, "AdminGivenMini") == 0)
		{
			GetPlayerWeaponData(i, 7, weap, ammo);
			if(ammo > 1 && weap == 38) {
				new string[128];
				format(string,sizeof(string), "You have been automatically kicked by the Anti-Minigun System");
				SendClientMessage(i, COLOR_GREY, string);
                ResetPlayerWeapons(i);
				Kick(i);
				/*new string[128]; format(string,sizeof(string),"Warning: %s has a mingun with %d ammo", PlayerName2(i), ammo);
				MessageToAdmins(COLOR_WHITE,string);*/
			}
		}
	}
	#endif
}

//==============================================================================
forward GodUpdate();
public GodUpdate()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i) && PlayerInfo[i][God] == 1)
		{
			SetPlayerHealth(i,100000);
		}
		if(IsPlayerConnected(i) && PlayerInfo[i][GodCar] == 1 && IsPlayerInAnyVehicle(i))
		{
			GetVehicleHealth(GetPlayerVehicleID(i),fVehicleHealth);
  	        if(fVehicleHealth < 900) SetVehicleHealth(GetPlayerVehicleID(i),1000.0);
		}
	}
}
//==========================[ Server Info  ]====================================

forward ConnectedPlayers();
public ConnectedPlayers()
{
	new Connected;
	for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) Connected++;
	return Connected;
}

forward JailedPlayers();
public JailedPlayers()
{
	new JailedCount;
	for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && PlayerInfo[i][Jailed] == 1) JailedCount++;
	return JailedCount;
}

forward FrozenPlayers();
public FrozenPlayers()
{
	new FrozenCount; for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && PlayerInfo[i][Frozen] == 1) FrozenCount++;
	return FrozenCount;
}

forward MutedPlayers();
public MutedPlayers()
{
	new Count; for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && PlayerInfo[i][Muted] == 1) Count++;
	return Count;
}

forward InVehCount();
public InVehCount()
{
	new InVeh; for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && IsPlayerInAnyVehicle(i)) InVeh++;
	return InVeh;
}

forward OnBikeCount();
public OnBikeCount()
{
	new BikeCount;
	for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && IsPlayerInAnyVehicle(i)) {
		new LModel = GetVehicleModel(GetPlayerVehicleID(i));
		switch(LModel)
		{
			case 448,461,462,463,468,471,509,510,521,522,523,581,586:  BikeCount++;
		}
	}
	return BikeCount;
}

forward InCarCount();
public InCarCount()
{
	new PInCarCount;
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(IsPlayerConnected(i) && IsPlayerInAnyVehicle(i)) {
			new LModel = GetVehicleModel(GetPlayerVehicleID(i));
			switch(LModel)
			{
				case 448,461,462,463,468,471,509,510,521,522,523,581,586: {}
				default: PInCarCount++;
			}
		}
	}
	return PInCarCount;
}

forward AdminCount();
public AdminCount()
{
	new LAdminCount;
	for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && PlayerInfo[i][Level] >= 1)	LAdminCount++;
	return LAdminCount;
}

forward RconAdminCount();
public RconAdminCount()
{
	new rAdminCount;
	for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && IsPlayerAdmin(i)) rAdminCount++;
	return rAdminCount;
}

//==========================[ Remote Console ]==================================

forward RestartGM();
public RestartGM()
{
	SendRconCommand("gmx");
}

forward UnloadFS();
public UnloadFS()
{
	SendRconCommand("unloadfs ladmin");
}

forward PrintWarning(const string[]);
public PrintWarning(const string[])
{
    new str[128];
    print("\n\n>		WARNING:\n");
    format(str, sizeof(str), " The  %s  folder is missing from scriptfiles", string);
    print(str);
    print("\n Please Create This Folder And Reload the Filterscript\n\n");
}

//============================[ Bot Check ]=====================================
forward BotCheck(playerid);
public BotCheck(playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(GetPlayerPing(playerid) < 1)
		{
			new string[128], ip[20];  GetPlayerIp(playerid,ip,sizeof(ip));
			format(string,sizeof(string),"BOT: %s id:%d ip: %s ping: %d",PlayerName2(playerid),playerid,ip,GetPlayerPing(playerid));
			SaveToFile("BotKickLog",string);
		    SaveToFile("KickLog",string);
			printf("[ADMIN] Possible bot has been detected (Kicked %s ID:%d)", PlayerName2(playerid), playerid);
			Kick(playerid);
		}
	}
}

//==============================================================================
forward SendRandomMessage();
public SendRandomMessage()
{
      SendPlayerMessageToAll(0xFF00FFFF, BOTMESSAGE[random(MAXMESSAGE)]);
      return 1;
}

forward SendBotMessage(msg[]);
public SendBotMessage(msg[])
{
	for(new playerid=0;playerid<MAX_PLAYERS;playerid++)
	{
	    if(IsPlayerConnected(playerid)==1 && GetPlayerColor(playerid) != 0)
	    {
			new pName3[18];
			format(pName3,sizeof(pName3),"%s",PlayerName3(playerid));
			new ColorSave = GetPlayerColor(playerid);
			SetPlayerColor(playerid,COLOR_BOT);
			SetPlayerName(playerid,BotName);
			SendPlayerMessageToAll(playerid,msg);
			SetPlayerColor(playerid,ColorSave);
			SetPlayerName(playerid,pName3);
			return 1;
		}
	}
	return 1;
}

stock AddRandomMessage(msg[])
{
	format(BOTMESSAGE[MAXMESSAGE],128,"%s",msg);
	MAXMESSAGE++;
	return 1;
}


forward PutAtPos(playerid);
public PutAtPos(playerid)
{
	if (dUserINT(PlayerName2(playerid)).("x")!=0) {
     	SetPlayerPos(playerid, float(dUserINT(PlayerName2(playerid)).("x")), float(dUserINT(PlayerName2(playerid)).("y")), float(dUserINT(PlayerName2(playerid)).("z")) );
 		SetPlayerInterior(playerid,	(dUserINT(PlayerName2(playerid)).("interior"))	);
	}
}

forward PutAtDisconectPos(playerid);
public PutAtDisconectPos(playerid)
{
	if (dUserINT(PlayerName2(playerid)).("x1")!=0) {
    	SetPlayerPos(playerid, float(dUserINT(PlayerName2(playerid)).("x1")), float(dUserINT(PlayerName2(playerid)).("y1")), float(dUserINT(PlayerName2(playerid)).("z1")) );
		SetPlayerInterior(playerid,	(dUserINT(PlayerName2(playerid)).("interior1"))	);
	}
}
/*forward PlayerTimeOnline(playerid);
public PlayerTimeOnline(playerid)
{
    for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
		    PlayerInfo[i][Minutes]++;
			if (PlayerInfo[i][Minutes] >= 60)
			{
			    PlayerInfo[i][Minutes] = 0;
			    PlayerInfo[i][Hours]++;
			}
		}
	}
    return 1;
}*/

forward PlayerTimeOnline(playerid);
public PlayerTimeOnline(playerid)
{
    PlayerInfo[playerid][Minutes]++;
    if (PlayerInfo[playerid][Minutes] >= 60)
    {
	    PlayerInfo[playerid][Minutes] = 0;
	    PlayerInfo[playerid][Hours]++;
    }
    return 1;
}

TotalGameTime(playerid, &h=0, &m=0, &s=0)
{
    PlayerInfo[playerid][TotalTime] = ( (gettime() - PlayerInfo[playerid][ConnectTime]) + (PlayerInfo[playerid][hours]*60*60) + (PlayerInfo[playerid][mins]*60) + (PlayerInfo[playerid][secs]) );

    h = floatround(PlayerInfo[playerid][TotalTime] / 3600, floatround_floor);
    m = floatround(PlayerInfo[playerid][TotalTime] / 60,   floatround_floor) % 60;
    s = floatround(PlayerInfo[playerid][TotalTime] % 60,   floatround_floor);

    return PlayerInfo[playerid][TotalTime];
}

//==============================================================================
forward MaxAmmo(playerid);
public MaxAmmo(playerid)
{
	new slot, weap, ammo;
	for (slot = 0; slot < 14; slot++)
	{
    	GetPlayerWeaponData(playerid, slot, weap, ammo);
		if(IsValidWeapon(weap))
		{
		   	GivePlayerWeapon(playerid, weap, 999999999);
		}
	}
	return 1;
}

stock PlayerName2(playerid) {
  new name[MAX_PLAYER_NAME];
  GetPlayerName(playerid, name, sizeof(name));
  return name;
}

stock PlayerName3(playerid)
{
	new pName3[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pName3, MAX_PLAYER_NAME);
	return pName3;
}

stock pName(playerid)
{
  new name[MAX_PLAYER_NAME];
  GetPlayerName(playerid, name, sizeof(name));
  return name;
}

stock TimeStamp()
{
	new time = GetTickCount() / 1000;
	return time;
}

stock PlayerSoundForAll(SoundID)
{
	for(new i = 0; i < MAX_PLAYERS; i++) PlayerPlaySound(i, SoundID, 0.0, 0.0, 0.0);
}

stock IsValidSkin(SkinID)
{
	if((SkinID == 0)||(SkinID == 7)||(SkinID >= 9 && SkinID <= 41)||(SkinID >= 43 && SkinID <= 64)||(SkinID >= 66 && SkinID <= 73)||(SkinID >= 75 && SkinID <= 85)||(SkinID >= 87 && SkinID <= 118)||(SkinID >= 120 && SkinID <= 148)||(SkinID >= 150 && SkinID <= 207)||(SkinID >= 209 && SkinID <= 264)||(SkinID >= 274 && SkinID <= 288)||(SkinID >= 290 && SkinID <= 299)) return true;
	else return false;
}

stock IsNumeric(string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
	{
		if (string[i] > '9' || string[i] < '0') return 0;
	}
	return 1;
}

// Convert Seconds to Days, Hours, Minutes and Seconds
StoDHMS(Time, &Days)
{
	// Convert the given time in seconds to days, hours, minutes and seconds
	Days = Time / 86400;
	Time = Time - (Days * 86400);
}

stock ReturnPlayerID(PlayerName[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(strfind(pName(i),PlayerName,true)!=-1) return i;
		}
	}
	return INVALID_PLAYER_ID;
}

GetVehicleModelIDFromName(vname[])
{
	for(new i = 0; i < 211; i++)
	{
		if ( strfind(VehicleNames[i], vname, true) != -1 )
			return i + 400;
	}
	return -1;
}

stock GetWeaponIDFromName(WeaponName[])
{
	if(strfind("molotov",WeaponName,true)!=-1) return 18;
	for(new i = 0; i <= 46; i++)
	{
		switch(i)
		{
			case 0,19,20,21,44,45: continue;
			default:
			{
				new name[32]; GetWeaponName(i,name,32);
				if(strfind(name,WeaponName,true) != -1) return i;
			}
		}
	}
	return -1;
}

stock DisableWord(const badword[], text[])
{
   	for(new i=0; i<256; i++)
   	{
		if (strfind(text[i], badword, true) == 0)
		{
			for(new a=0; a<256; a++)
			{
				if (a >= i && a < i+strlen(badword)) text[a]='*';
			}
		}
	}
}

argpos(const string[], idx = 0, sep = ' ')// (by yom)
{
    for(new i = idx, j = strlen(string); i < j; i++)
        if (string[i] == sep && string[i+1] != sep)
            return i+1;

    return -1;
}

//==============================================================================
forward MessageToAdmins(color,const string[]);
public MessageToAdmins(color,const string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i) == 1) if (PlayerInfo[i][Level] >= 1) SendClientMessage(i, color, string);
	}
	return 1;
}

stock CMDMessageToAdmins(playerid,command[])
{
	if(ServerInfo[AdminCmdMsg] == 0) return 1;
	new string[128]; GetPlayerName(playerid,string,sizeof(string));
	format(string,sizeof(string),"[ADMIN] %s has used the command %s",string,command);
	return MessageToAdmins(blue,string);
}

forward MessageToDJs(color,const string[]);
public MessageToDJs(color,const string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i) == 1)
		if (PlayerInfo[i][isDJ] == 1 || PlayerInfo[i][Level] >= 1)
		SendClientMessage(i, color, string);
	}
	return 1;
}

stock CMDMessageToDJs(playerid,command[])
{
	if(ServerInfo[AdminCmdMsg] == 0) return 1;
	new string[128]; GetPlayerName(playerid,string,sizeof(string));
	format(string,sizeof(string),"[DJ] %s has used the command %s",string,command);
	return MessageToDJs(blue,string);
}

stock load_config()
{
	skinlist = LoadModelSelectionMenu("tbsServer/skins.txt");
	return 1;
}
//==============================================================================
LoadPlayer(playerid)
{
	new playername[MAX_PLAYER_NAME],file[256], readfile[256];
	GetPlayerName(playerid, playername, sizeof(playername));
	format(file,256,"/ladmin/users/%s.sav",udb_encode(playername));
	readfile = dini_Get("/ladmin/users/%s.sav",playername);
    if(udb_Exists(PlayerName2(playerid)))
	format(PlayerInfo[playerid][accDescp], 100, "%s", readfile); {
	return 1;
	}
}

SavePlayer(playerid)
{
	if(udb_Exists(PlayerName2(playerid))) dUserSetINT(PlayerName2(playerid)).("loggedin",0);
    dUserSetINT(PlayerName2(playerid)).("level",PlayerInfo[playerid][Level]);
    dUserSetINT(PlayerName2(playerid)).("AccountType",PlayerInfo[playerid][pVip]);
	dUserSetINT(PlayerName2(playerid)).("money",GetPlayerMoneyEx(playerid));
   	dUserSetINT(PlayerName2(playerid)).("Score",GetPlayerScore(playerid));
    dUserSetINT(PlayerName2(playerid)).("accDescp",PlayerInfo[playerid][accDescp]);
    dUserSetINT(PlayerName2(playerid)).("HS",PlayerInfo[playerid][HS]);
    dUserSetINT(PlayerName2(playerid)).("Jailed",PlayerInfo[playerid][Jailed]);
    dUserSetINT(PlayerName2(playerid)).("DJ",PlayerInfo[playerid][isDJ]);
    dUserSetINT(PlayerName2(playerid)).("kills",PlayerInfo[playerid][pDeaths]);
    dUserSetINT(PlayerName2(playerid)).("deaths",PlayerInfo[playerid][Kills]);
    dUserSetINT(PlayerName2(playerid)).("MemberSince",PlayerInfo[playerid][accDate]);
    dUserSetINT(PlayerName2(playerid)).("Maths",PlayerInfo[playerid][Mathematics]);
    dUserSetINT(PlayerName2(playerid)).("Reacts",PlayerInfo[playerid][Reactions]);
    dUserSetINT(PlayerName2(playerid)).("CPs",PlayerInfo[playerid][CheckPoints]);
    dUserSetINT(PlayerName2(playerid)).("MoneyBag",PlayerInfo[playerid][MoneyBags]);
    dUserSetINT(PlayerName2(playerid)).("CookieJar",PlayerInfo[playerid][CookieJars]);
    dUserSetINT(PlayerName2(playerid)).("FavSkin",GetPlayerSkin(playerid));
    dUserSetINT(PlayerName2(playerid)).("Cookies",PlayerInfo[playerid][Cookies]);
    dUserSetINT(PlayerName2(playerid)).("Brownies",PlayerInfo[playerid][pBrownies]);
    dUserSetINT(PlayerName2(playerid)).("VIPTime",TimeVIP[playerid]);

	new file1[256], PlayerName[MAX_PLAYER_NAME];
    format(file1,sizeof(file1),"/ladmin/users/%s.sav",udb_encode(PlayerName));
	new h, m, s;
    TotalGameTime(playerid, h, m, s);

	dUserSetINT(PlayerName2(playerid)).("hours", h);
	dUserSetINT(PlayerName2(playerid)).("minutes", m);
	dUserSetINT(PlayerName2(playerid)).("seconds", s);

   	new Float:x,Float:y,Float:z;
   	GetPlayerPos(playerid,x,y,z);
    dUserSetINT(PlayerName2(playerid)).("x1",floatround(x));
	dUserSetINT(PlayerName2(playerid)).("y1",floatround(y));
	dUserSetINT(PlayerName2(playerid)).("z1",floatround(z));

	new weap1, ammo1, weap2, ammo2, weap3, ammo3, weap4, ammo4, weap5, ammo5, weap6, ammo6;
	GetPlayerWeaponData(playerid,2,weap1,ammo1);// hand gun
	GetPlayerWeaponData(playerid,3,weap2,ammo2);//shotgun
	GetPlayerWeaponData(playerid,4,weap3,ammo3);// SMG
	GetPlayerWeaponData(playerid,5,weap4,ammo4);// AK47 / M4
	GetPlayerWeaponData(playerid,6,weap5,ammo5);// rifle
	GetPlayerWeaponData(playerid,7,weap6,ammo6);// rocket launcher
   	dUserSetINT(PlayerName2(playerid)).("weap1",weap1); dUserSetINT(PlayerName2(playerid)).("weap1ammo",ammo1);
  	dUserSetINT(PlayerName2(playerid)).("weap2",weap2);	dUserSetINT(PlayerName2(playerid)).("weap2ammo",ammo2);
  	dUserSetINT(PlayerName2(playerid)).("weap3",weap3);	dUserSetINT(PlayerName2(playerid)).("weap3ammo",ammo3);
	dUserSetINT(PlayerName2(playerid)).("weap4",weap4); dUserSetINT(PlayerName2(playerid)).("weap4ammo",ammo4);
  	dUserSetINT(PlayerName2(playerid)).("weap5",weap5);	dUserSetINT(PlayerName2(playerid)).("weap5ammo",ammo5);
	dUserSetINT(PlayerName2(playerid)).("weap6",weap6); dUserSetINT(PlayerName2(playerid)).("weap6ammo",ammo6);

	new year,month,day;	getdate(year, month, day);
	new strdate[20];	format(strdate, sizeof(strdate), "%d.%d.%d",day,month,year);
	new file[256]; 		format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(PlayerName2(playerid)) );

	dini_Set(file,"LastOn",strdate);
	dUserSetINT(PlayerName2(playerid)).("loggedin",0);
	dUserSetINT(PlayerName2(playerid)).("TimesOnServer",(dUserINT(PlayerName2(playerid)).("TimesOnServer"))+1);
}

//==============================================================================
#if defined USE_MENUS
DestroyAllMenus()
{
	DestroyMenu(LVehicles); DestroyMenu(twodoor); DestroyMenu(fourdoor); DestroyMenu(fastcar); DestroyMenu(Othercars);
	DestroyMenu(bikes); DestroyMenu(boats); DestroyMenu(planes); DestroyMenu(helicopters ); DestroyMenu(LTime);
	DestroyMenu(XWeapons); DestroyMenu(XWeaponsBig); DestroyMenu(XWeaponsSmall); DestroyMenu(XWeaponsMore);
	DestroyMenu(LWeather); DestroyMenu(LTuneMenu); DestroyMenu(PaintMenu); DestroyMenu(LCars); DestroyMenu(LCars2);
	DestroyMenu(LTele); DestroyMenu(LasVenturasMenu); DestroyMenu(LosSantosMenu); DestroyMenu(SanFierroMenu);
	DestroyMenu(LMainMenu); DestroyMenu(DesertMenu); DestroyMenu(FlintMenu); DestroyMenu(MountChiliadMenu); DestroyMenu(InteriorsMenu);
	DestroyMenu(AdminEnable); DestroyMenu(AdminDisable);
}
#endif

//==============================================================================
#if defined DISPLAY_CONFIG
stock ConfigInConsole()
{
	print(" ________ Configuration ___________\n");
	print(" __________ Chat & Messages ______");
	if(ServerInfo[AntiSwear] == 0) print("  Anti Swear:              Disabled "); else print("  Anti Swear:             Enabled ");
	if(ServerInfo[AntiSpam] == 0)  print("  Anti Spam:               Disabled "); else print("  Anti Spam:              Enabled ");
	if(ServerInfo[ReadCmds] == 0)  print("  Read Cmds:               Disabled "); else print("  Read Cmds:              Enabled ");
	if(ServerInfo[ReadPMs] == 0)   print("  Read PMs:                Disabled "); else print("  Read PMs:               Enabled ");
	if(ServerInfo[ConnectMessages] == 0) print("  Connect Messages:        Disabled "); else print("  Connect Messages:       Enabled ");
  	if(ServerInfo[AdminCmdMsg] == 0) print("  Admin Cmd Messages:     Disabled ");  else print("  Admin Cmd Messages:     Enabled ");
	if(ServerInfo[ReadPMs] == 0)   print("  Anti capital letters:    Disabled \n"); else print("  Anti capital letters:   Enabled \n");
	print(" __________ Skins ________________");
	if(ServerInfo[AdminOnlySkins] == 0) print("  AdminOnlySkins:         Disabled "); else print("  AdminOnlySkins:         Enabled ");
	printf("  Admin Skin 1 is:         %d", ServerInfo[AdminSkin] );
	printf("  Admin Skin 2 is:         %d\n", ServerInfo[AdminSkin2] );
	print(" ________ Server Protection ______");
	if(ServerInfo[AntiBot] == 0) print("  Anti Bot:                Disabled "); else print("  Anti Bot:                Enabled ");
	if(ServerInfo[NameKick] == 0) print("  Bad Name Kick:           Disabled\n"); else print("  Bad Name Kick:           Enabled\n");
	print(" __________ Ping Control _________");
	if(ServerInfo[MaxPing] == 0) print("  Ping Control:            Disabled"); else print("  Ping Control:            Enabled");
	printf("  Max Ping:                %d\n", ServerInfo[MaxPing] );
	print(" __________ Players ______________");
	if(ServerInfo[GiveWeap] == 0) print("  Save/Give Weaps:         Disabled"); else print("  Save/Give Weaps:         Enabled");
	if(ServerInfo[GiveMoney] == 0) print("  Save/Give Money:         Disabled\n"); else print("  Save/Give Money:         Enabled\n");
	print(" __________ Other ________________");
	printf("  Max Admin Level:         %d", ServerInfo[MaxAdminLevel] );
	if(ServerInfo[Locked] == 0) print("  Server Locked:           No"); else print("  Server Locked:           Yes");
	if(ServerInfo[AutoLogin] == 0) print("  Auto Login:             Disabled\n"); else print("  Auto Login:              Enabled\n");
}
#endif

//=====================[ Configuration ] =======================================
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

stock UpdateConfig()
{
	new file[256], File:file2, string[100]; format(file,sizeof(file),"ladmin/config/Config.ini");
	ForbiddenWordCount = 0;
	BadNameCount = 0;
	BadPartNameCount = 0;

	if(!dini_Exists("ladmin/config/aka.txt")) dini_Create("ladmin/config/aka.txt");

	if(!dini_Exists(file))
	{
		dini_Create(file);
		print("\n >Configuration File Successfully Created");
	}

	if(!dini_Isset(file,"MaxPing")) dini_IntSet(file,"MaxPing",1200);
	if(!dini_Isset(file,"ReadPms")) dini_IntSet(file,"ReadPMs",1);
	if(!dini_Isset(file,"ReadCmds")) dini_IntSet(file,"ReadCmds",1);
	if(!dini_Isset(file,"MaxAdminLevel")) dini_IntSet(file,"MaxAdminLevel",5);
	if(!dini_Isset(file,"AdminOnlySkins")) dini_IntSet(file,"AdminOnlySkins",0);
	if(!dini_Isset(file,"AdminSkin")) dini_IntSet(file,"AdminSkin",217);
	if(!dini_Isset(file,"AdminSkin2")) dini_IntSet(file,"AdminSkin2",214);
	if(!dini_Isset(file,"AntiBot")) dini_IntSet(file,"AntiBot",1);
	if(!dini_Isset(file,"AntiSpam")) dini_IntSet(file,"AntiSpam",1);
	if(!dini_Isset(file,"AntiSwear")) dini_IntSet(file,"AntiSwear",1);
	if(!dini_Isset(file,"NameKick")) dini_IntSet(file,"NameKick",1);
 	if(!dini_Isset(file,"PartNameKick")) dini_IntSet(file,"PartNameKick",1);
	if(!dini_Isset(file,"NoCaps")) dini_IntSet(file,"NoCaps",0);
	if(!dini_Isset(file,"Locked")) dini_IntSet(file,"Locked",0);
	if(!dini_Isset(file,"SaveWeap")) dini_IntSet(file,"SaveWeap",1);
	if(!dini_Isset(file,"SaveMoney")) dini_IntSet(file,"SaveMoney",1);
	if(!dini_Isset(file,"ConnectMessages")) dini_IntSet(file,"ConnectMessages",1);
	if(!dini_Isset(file,"AdminCmdMessages")) dini_IntSet(file,"AdminCmdMessages",1);
	if(!dini_Isset(file,"AutoLogin")) dini_IntSet(file,"AutoLogin",1);
	if(!dini_Isset(file,"MaxMuteWarnings")) dini_IntSet(file,"MaxMuteWarnings",4);
	if(!dini_Isset(file,"MustLogin")) dini_IntSet(file,"MustLogin",0);
	if(!dini_Isset(file,"MustRegister")) dini_IntSet(file,"MustRegister",0);

	if(dini_Exists(file))
	{
		ServerInfo[MaxPing] = dini_Int(file,"MaxPing");
		ServerInfo[ReadPMs] = dini_Int(file,"ReadPMs");
		ServerInfo[ReadCmds] = dini_Int(file,"ReadCmds");
		ServerInfo[MaxAdminLevel] = dini_Int(file,"MaxAdminLevel");
		ServerInfo[AdminOnlySkins] = dini_Int(file,"AdminOnlySkins");
		ServerInfo[AdminSkin] = dini_Int(file,"AdminSkin");
		ServerInfo[AdminSkin2] = dini_Int(file,"AdminSkin2");
		ServerInfo[AntiBot] = dini_Int(file,"AntiBot");
		ServerInfo[AntiSpam] = dini_Int(file,"AntiSpam");
		ServerInfo[AntiSwear] = dini_Int(file,"AntiSwear");
		ServerInfo[NameKick] = dini_Int(file,"NameKick");
		ServerInfo[PartNameKick] = dini_Int(file,"PartNameKick");
		ServerInfo[NoCaps] = dini_Int(file,"NoCaps");
		ServerInfo[Locked] = dini_Int(file,"Locked");
		ServerInfo[GiveWeap] = dini_Int(file,"SaveWeap");
		ServerInfo[GiveMoney] = dini_Int(file,"SaveMoney");
		ServerInfo[ConnectMessages] = dini_Int(file,"ConnectMessages");
		ServerInfo[AdminCmdMsg] = dini_Int(file,"AdminCmdMessages");
		ServerInfo[AutoLogin] = dini_Int(file,"AutoLogin");
		ServerInfo[MaxMuteWarnings] = dini_Int(file,"MaxMuteWarnings");
		ServerInfo[MustLogin] = dini_Int(file,"MustLogin");
		ServerInfo[MustRegister] = dini_Int(file,"MustRegister");
		print("\n -Configuration Settings Loaded");
	}

	//forbidden names
	if((file2 = fopen("ladmin/config/ForbiddenNames.cfg",io_read)))
	{
		while(fread(file2,string))
		{
		    for(new i = 0, j = strlen(string); i < j; i++) if(string[i] == '\n' || string[i] == '\r') string[i] = '\0';
            BadNames[BadNameCount] = string;
            BadNameCount++;
		}
		fclose(file2);	printf(" -%d Forbidden Names Loaded", BadNameCount);
	}

	//forbidden part of names
	if((file2 = fopen("ladmin/config/ForbiddenPartNames.cfg",io_read)))
	{
		while(fread(file2,string))
		{
		    for(new i = 0, j = strlen(string); i < j; i++) if(string[i] == '\n' || string[i] == '\r') string[i] = '\0';
            BadPartNames[BadPartNameCount] = string;
            BadPartNameCount++;
		}
		fclose(file2);	printf(" -%d Forbidden Tags Loaded", BadPartNameCount);
	}

	//forbidden words
	if((file2 = fopen("ladmin/config/ForbiddenWords.cfg",io_read)))
	{
		while(fread(file2,string))
		{
		    for(new i = 0, j = strlen(string); i < j; i++) if(string[i] == '\n' || string[i] == '\r') string[i] = '\0';
            ForbiddenWords[ForbiddenWordCount] = string;
            ForbiddenWordCount++;
		}
		fclose(file2);	printf(" -%d Forbidden Words Loaded", ForbiddenWordCount);
	}
}
//=====================[ SAVING DATA ] =========================================

forward SaveToFile(filename[],text[]);
public SaveToFile(filename[],text[])
{
	#if defined SAVE_LOGS
	new File:LAdminfile, filepath[256], string[256], year,month,day, hour,minute,second;
	getdate(year,month,day); gettime(hour,minute,second);

	format(filepath,sizeof(filepath),"ladmin/logs/%s.txt",filename);
	LAdminfile = fopen(filepath,io_append);
	format(string,sizeof(string),"[%d.%d.%d %d:%d:%d] %s\r\n",day,month,year,hour,minute,second,text);
	fwrite(LAdminfile,string);
	fclose(LAdminfile);
	#endif

	return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_FIGHTINGSTYLE)
	{
		if(response)
		{
			switch(listitem)
			{
					case 0: //Normal
					{
    					if(PlayerInfo[playerid][pBrownies] < 5) return SendClientMessage(playerid, red, "{FFFFFF}You need 5 Brownies to change Fight Styles.");
						PlayerInfo[playerid][pBrownies] -= 5;
						SetPlayerFightingStyle (playerid, FIGHT_STYLE_NORMAL);
						SendClientMessage(playerid, COLOR_YELLOW, "You have changed your fighting style to Normal!");
						return 1;
					}
					case 1: //Boxing
					{
					    if(PlayerInfo[playerid][pBrownies] < 5) return SendClientMessage(playerid, red,  "{FFFFFF}You need 5 Brownies to change Fight Styles.");
						PlayerInfo[playerid][pBrownies] -= 5;
						SetPlayerFightingStyle (playerid, FIGHT_STYLE_BOXING);
						SendClientMessage(playerid, COLOR_YELLOW, "You have changed your fighting style to Boxing!");
						return 1;
					}
					case 2: //KungFu
					{
					    if(PlayerInfo[playerid][pBrownies] < 5) return SendClientMessage(playerid, red,  "{FFFFFF}You need 5 Brownies to change Fight Styles.");
						PlayerInfo[playerid][pBrownies] -= 5;
						SetPlayerFightingStyle (playerid, FIGHT_STYLE_KUNGFU);
						SendClientMessage(playerid, COLOR_YELLOW, "You have changed your fighting style to Kung-Fu!");
					}
					case 3: //KneeHead
					{
					    if(PlayerInfo[playerid][pBrownies] < 5) return SendClientMessage(playerid, red,  "{FFFFFF}You need 5 Brownies to change Fight Styles.");
						PlayerInfo[playerid][pBrownies] -= 5;
						SetPlayerFightingStyle (playerid, FIGHT_STYLE_KNEEHEAD);
						SendClientMessage(playerid, COLOR_YELLOW, "You have changed your fighting style to Knee-Head!");
						return 1;
					}
					case 4: //Grabkick
					{
					    if(PlayerInfo[playerid][pBrownies] < 5) return SendClientMessage(playerid, red,  "{FFFFFF}You need 5 Brownies to change Fight Styles.");
						PlayerInfo[playerid][pBrownies] -= 5;
						SetPlayerFightingStyle (playerid, FIGHT_STYLE_GRABKICK);
						SendClientMessage(playerid, COLOR_YELLOW, "You have changed your fighting style to Grab-Kick!");
						return 1;
					}
					case 5: //Elbow
					{
					    if(PlayerInfo[playerid][pBrownies] < 5) return SendClientMessage(playerid, red,  "{FFFFFF}You need 5 Brownies to change Fight Styles.");
						PlayerInfo[playerid][pBrownies] -= 5;
						SetPlayerFightingStyle (playerid, FIGHT_STYLE_ELBOW);
						SendClientMessage(playerid, COLOR_YELLOW, "You have changed your fighting style to Elbow!");
						return 1;
					}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_COOKIESHOP)
	{
			if(response)
			{
			     switch(listitem)
			     {
			           case 0:
	                   {
			                    if(PlayerInfo[playerid][Cookies] < 5) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Cookies to purchase this");
								PlayerInfo[playerid][Cookies] -= 5;
								SetPlayerScore(playerid, GetPlayerScore(playerid) + 50);
								SendClientMessage(playerid, red, "{FFFFFF}You've bought {FFFF00}50 {FFFFFF}Score");
								return 1;
						}
	                    case 1:
						{
                                if(PlayerInfo[playerid][Cookies] < 20) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Cookies to purchase this");
							    PlayerInfo[playerid][Cookies] -= 20;
								SetPlayerScore(playerid, GetPlayerScore(playerid) + 250);
								SendClientMessage(playerid, red, "{FFFFFF}You've bought {FFFF00}250 {FFFFFF}Score");
								return 1;
						}
	                    case 2:
						{
			                    if(PlayerInfo[playerid][Cookies] < 250) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Cookies to purchase this");
						        PlayerInfo[playerid][Cookies] -= 250;
							    SetPlayerScore(playerid, GetPlayerScore(playerid) + 2000);
							    SendClientMessage(playerid, red, "{FFFFFF}You've bought {FFFF00}2000 {FFFFFF}Score");
								return 1;
						}
	                    case 3:
						{
                                if(PlayerInfo[playerid][Cookies] < 1000) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Cookies to purchase this");
		     					PlayerInfo[playerid][Cookies] -= 1000;
								SetPlayerScore(playerid, GetPlayerScore(playerid) + 7000);
								SendClientMessage(playerid, red, "{FFFFFF}You've bought {FFFF00}7000 {FFFFFF}Score");
								return 1;
						}
	                    case 4:
      					{
                                if(PlayerInfo[playerid][Cookies] < 100) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Cookies to purchase this");
							    PlayerInfo[playerid][Cookies] -= 100;
								GivePlayerMoneyEx(playerid,1000000);
								SendClientMessage(playerid, red, "{FFFFFF}You have bought {00FF00}${FFFFFF}1m");
								return 1;
						}
	                    case 5:
						{
                                if(PlayerInfo[playerid][Cookies] < 250) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Cookies to purchase this");
							    PlayerInfo[playerid][Cookies] -= 250;
								GivePlayerMoneyEx(playerid,2500000);
								SendClientMessage(playerid, red, "{FFFFFF}You have bought {00FF00}${FFFFFF}2.5m");
								return 1;
						}
	                    case 6:
						{
                                if(PlayerInfo[playerid][Cookies] < 500) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Cookies to purchase this");
							    PlayerInfo[playerid][Cookies] -= 500;
								GivePlayerMoneyEx(playerid,5000000);
								SendClientMessage(playerid, red, "{FFFFFF}You have bought {00FF00}${FFFFFF}5m");
								return 1;
						}
	                    case 7:
						{
                                if(PlayerInfo[playerid][Cookies] < 1000) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Cookies to purchase this");
							    PlayerInfo[playerid][Cookies] -= 1000;
								GivePlayerMoneyEx(playerid,10000000);
								SendClientMessage(playerid, red, "{FFFFFF}You've bought {00FF00}${FFFFFF}10m");
								return 1;
						}
				 }
			}
			return 1;
	}
	if(dialogid == DIALOG_BROWNIESHOP)
	{
			if(response)
			{
			     switch(listitem)
			     {
			           case 0:
	                   {
			                    if(PlayerInfo[playerid][pBrownies] < 1) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Brownies to purchase this!");
								PlayerInfo[playerid][pBrownies] -= 1;
								GivePlayerWeapon(playerid, 24, 999999999);
								GivePlayerWeapon(playerid, 28, 999999999);
								GivePlayerWeapon(playerid, 25, 999999999);
								GivePlayerWeapon(playerid, 17, 999999999);
								GivePlayerWeapon(playerid, 10, 999999999);
								GivePlayerWeapon(playerid, 3, 999999999);
								GivePlayerWeapon(playerid, 33, 999999999);
								GivePlayerWeapon(playerid, 30, 999999999);
								SendClientMessage(playerid, red, "{FFFFFF}You've bought Weapon Pack{FFFF00}1{FFFFFF}!");
								return 1;
						}
	                    case 1:
						{
                                if(PlayerInfo[playerid][pBrownies] < 2) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Brownies to purchase this!");
							   			PlayerInfo[playerid][pBrownies] -= 2;
										GivePlayerWeapon(playerid, 29, 999999999);
										GivePlayerWeapon(playerid, 31, 999999999);
										GivePlayerWeapon(playerid, 34, 999999999);
										GivePlayerWeapon(playerid, 26, 999999999);
										GivePlayerWeapon(playerid, 22, 999999999);
										GivePlayerWeapon(playerid, 12, 999999999);
										GivePlayerWeapon(playerid, 6, 999999999);
										GivePlayerWeapon(playerid, 18, 999999999);
								        SendClientMessage(playerid, red, "{FFFFFF}You've bought Weapon Pack{FFFF00}2{FFFFFF}!");
								        return 1;
						}
	                    case 2:
						{
			                    if(PlayerInfo[playerid][pBrownies] < 3) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Brownies to purchase this!");
						        	 GivePlayerWeapon(playerid, 5, 999999999);
		 		 		 		     GivePlayerWeapon(playerid, 23, 999999999);
		 		 		 		     GivePlayerWeapon(playerid, 27, 999999999);
		 		 		 		     GivePlayerWeapon(playerid, 32, 999999999);
		 		 		 		     GivePlayerWeapon(playerid, 31, 999999999);
		 		 		 		     GivePlayerWeapon(playerid, 34, 999999999);
 		 		                     GivePlayerWeapon(playerid, 16, 999999999);
		 		 		 		     GivePlayerWeapon(playerid, 13, 999999999);
							         SendClientMessage(playerid, red, "{FFFFFF}You've bought Weapon Pack{FFFF00}3{FFFFFF}!");
								     return 1;
						}
	                    case 3:
						{
                                if(PlayerInfo[playerid][pBrownies] < 5) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Brownies to purchase this!");
		     					        PlayerInfo[playerid][pBrownies] -= 5;
								SetPlayerArmour(playerid, 50.0);
								SendClientMessage(playerid, red, "{FFFFFF}You've bought Armour With{FFFF00}50%{FFFFFF}!");
								return 1;
						}
	                    case 4:
      					{
                                if(PlayerInfo[playerid][pBrownies] < 10) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Brownies to purchase this!");
							        PlayerInfo[playerid][pBrownies] -= 10;
								    SetPlayerArmour(playerid, 100.0);
								SendClientMessage(playerid, red, "{FFFFFF}You have bought Armour With{00FF00}100%{FFFFFF}!");
								return 1;
						}
	                    case 5:
						{
                                if(PlayerInfo[playerid][pBrownies] < 25) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Brownies to purchase this!");
							        PlayerInfo[playerid][pBrownies] -= 25;
								    PlayerInfo[playerid][Cookies] += 100;
								SendClientMessage(playerid, red, "{FFFFFF}You have bought {00FF00}100{FFFFFF}Cookies!");
								return 1;
						}
	                    case 6:
						{
                                if(PlayerInfo[playerid][pBrownies] < 50) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Brownies to purchase this!");
							        PlayerInfo[playerid][pBrownies] -= 50;
								    PlayerInfo[playerid][Cookies] += 200;
								SendClientMessage(playerid, red, "{FFFFFF}You have bought {00FF00}200{FFFFFF}Cookies!");
								return 1;
						}
	                    case 7:
						{
                                if(PlayerInfo[playerid][pBrownies] < 100) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Brownies to purchase this!");
							        PlayerInfo[playerid][pBrownies] -= 100;
								    PlayerInfo[playerid][Cookies] += 500;
								SendClientMessage(playerid, red, "{FFFFFF}You've bought {00FF00}500{FFFFFF}Cookies!");
								return 1;
						}
			    case 8:
						{
                                if(PlayerInfo[playerid][pBrownies] < 200) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Brownies to purchase this!");
							        PlayerInfo[playerid][pBrownies] -= 200;
	                                PlayerInfo[playerid][Cookies] += 1000;
								SendClientMessage(playerid, red, "{FFFFFF}You've bought {00FF00}1000{FFFFFF}Cookies!");
								return 1;
						}
			    case 9:
						{
                                if(PlayerInfo[playerid][pBrownies] < 999) return SendClientMessage(playerid, COLOR_WHITE, "{FF0000}Error: {FFFFFF}You don't have enough Brownies to purchase this!");
							          PlayerInfo[playerid][pBrownies] -= 999;
                                      PlayerInfo[playerid][pVip] = 1;
                                      SavePlayer(playerid);
								SendClientMessage(playerid, red, "{FFFFFF}You've bought {C0C0C0}Silver{00FF00}VIP{FFFFFF}!");
								return 1;
						}
                                   }
			}
			return 1;
	}
	if(dialogid == 11112)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0: //VIP Username
	            {
	                if(VIPName[playerid] == 0)
	                {
	                    VIPName[playerid] = 1;
	                    UpdatePlayerColour(playerid);
	                    SendClientMessage(playerid, COLOR_VIP, "You have enabled the VIP Username Colour.");
	                    return 1;
	                }
	                else
	                {
	                    VIPName[playerid] = 0;
	                    UpdatePlayerColour(playerid);
	                    SendClientMessage(playerid, COLOR_VIP, "You have disabled the VIP Username Colour.");
	                    return 1;
	                }
	            }
	            case 1: // Change Weather
	            {
					new weather[200];
					format(weather,sizeof(weather),"Blue Skies/Clouds\nStormy\nFoggy\nScorching Hot\nDull & Colourless\nSandstorm\nGreen fog\nFresh blue");
					ShowPlayerDialog(playerid, vipmenu2, DIALOG_STYLE_LIST, "Weather selection", weather, "Change", "Back");
					return 1;
	            }
	            case 2: // Chat settings
	            {
	                new chats[400];
	                format(chats,sizeof(chats),"Set to default\nRed\nDark Blue\nLight Blue\nGreen\nYellow\nOrange\nPurple\nBlack");
	                ShowPlayerDialog(playerid, vipmenu4, DIALOG_STYLE_LIST, "Chat settings", chats, "Select", "Back");
	                return 1;
	            }
	            case 3:// Attach Object
	            {
                  	ShowPlayerDialog(playerid, 12009, DIALOG_STYLE_LIST, "Attach Objects", "Santa Hat\nParrot\nHippo\nSmoke Flare\nShark Head\nPumpkin\nIron\nGhost Rider\nDevil\nAlien\nTerminator\nDildo\nMoney Bag\nGuitar\nRemove Attached Objects", "Select", "Back");
				}
				case 4:// Teleport Menu
				{
				    ShowPlayerDialog(playerid, 12302, DIALOG_STYLE_LIST, "Teleport Menu", "VIP Hangout\nLos Santos Tower\nVIP Funland\nBlue Berry Farm\nVerdant Meadows Airport", "Select", "Back");
				}
	        }
	    }
	}
	if(dialogid == 11111)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0: //VIP Username
	            {
	                if(VIPName[playerid] == 0)
	                {
	                    VIPName[playerid] = 1;
	                    UpdatePlayerColour(playerid);
	                    SendClientMessage(playerid, COLOR_VIP, "You have enabled the VIP Username Colour.");
	                    return 1;
	                }
	                else
	                {
	                    VIPName[playerid] = 0;
	                    UpdatePlayerColour(playerid);
	                    SendClientMessage(playerid, COLOR_VIP, "You have disabled the VIP Username Colour.");
	                    return 1;
	                }
	            }
	            case 1: // Change Weather
	            {
					new weather[200];
					format(weather,sizeof(weather),"Blue Skies/Clouds\nStormy\nFoggy\nScorching Hot\nDull & Colourless\nSandstorm\nGreen fog\nFresh blue");
					ShowPlayerDialog(playerid, vipmenu2, DIALOG_STYLE_LIST, "Weather selection", weather, "Change", "Back");
					return 1;
	            }
	            case 2: // Chat settings
	            {
	                new chats[400];
	                format(chats,sizeof(chats),"Set to default\nRed\nDark Blue\nLight Blue\nGreen\nYellow\nOrange\nPurple\nBlack");
	                ShowPlayerDialog(playerid, vipmenu4, DIALOG_STYLE_LIST, "Chat settings", chats, "Select", "Back");
	                return 1;
	            }
	            case 3:// Attach Object
	            {
                  	ShowPlayerDialog(playerid, 12007, DIALOG_STYLE_LIST, "Attach Objects", "Santa Hat\nParrot\nHippo\nSmoke Flare\nShark Head\nPumpkin\nIron\nRemove Attached Objects", "Select", "Back");
				}
				case 4:// Teleport Menu
				{
				    ShowPlayerDialog(playerid, 12302, DIALOG_STYLE_LIST, "Teleport Menu", "VIP Hangout\nLos Santos Tower\nVIP Funland", "Select", "Back");
				}
	        }
	    }
	}
	if(dialogid == vipmenu1)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0: //VIP Username
	            {
	                if(VIPName[playerid] == 0)
	                {
	                    VIPName[playerid] = 1;
	                    UpdatePlayerColour(playerid);
	                    SendClientMessage(playerid, COLOR_VIP, "You have enabled the VIP Username Colour.");
	                    return 1;
	                }
	                else
	                {
	                    VIPName[playerid] = 0;
	                    UpdatePlayerColour(playerid);
	                    SendClientMessage(playerid, COLOR_VIP, "You have disabled the VIP Username Colour.");
	                    return 1;
	                }
	            }
	            case 1: // Change Weather
	            {
					new weather[200];
					format(weather,sizeof(weather),"Blue Skies/Clouds\nStormy\nFoggy\nScorching Hot\nDull & Colourless\nSandstorm\nGreen fog\nFresh blue");
					ShowPlayerDialog(playerid, vipmenu2, DIALOG_STYLE_LIST, "Weather selection", weather, "Change", "Back");
					return 1;
	            }
	            case 2: // Chat settings
	            {
	                new chats[400];
	                format(chats,sizeof(chats),"Set to default\nRed\nDark Blue\nLight Blue\nGreen\nYellow\nOrange\nPurple\nBlack");
	                ShowPlayerDialog(playerid, vipmenu4, DIALOG_STYLE_LIST, "Chat settings", chats, "Select", "Back");
	                return 1;
	            }
				case 3:// Teleport Menu
				{
				    ShowPlayerDialog(playerid, 12302, DIALOG_STYLE_LIST, "Teleport Menu", "VIP Hangout\nLos Santos Tower\nVIP Funland", "Select", "Back");
				}
	        }
	    }
	}
    if(dialogid == 12007)//vip attach objcts
	{
	    if(response)
		{
		    switch(listitem)
		    {
		        case 0:
		        {
                  	SetPlayerAttachedObject(playerid, 0, 19065, 2, 0.121128, 0.023578, 0.001139, 222.540847, 90.773872, 211.130859, 1.098305, 1.122310, 1.106640 ); // SantaHat
		        }
                case 1:
		        {
                  	SetPlayerAttachedObject(playerid, 0, 19078, 1, 0.329150, -0.072101, 0.156082, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000 ); //parrot
		        }
		        case 2:
		        {
                  	SetPlayerAttachedObject(playerid, 0, 1371, 1, 0.037538, 0.000000, -0.020199, 350.928314, 89.107200, 180.974227, 1.000000, 1.000000, 1.000000 ); //Hippo
		        }
		        case 3:
		        {
                  	SetPlayerAttachedObject(playerid, 0, 18728, 2, 0.134301, 1.475258, -0.192459, 82.870338, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000 ); //Smoke Flare
		        }
		        case 4:
		        {
                  	SetPlayerAttachedObject(playerid, 0, 1608, 2, 0.079577, 0.016865, 0.005709, 171.620758, 93.131149, 280.057983, 1.000000, 1.000000, 1.000000 ); //Shark Head
		        }
		        case 5:
		        {
                  	SetPlayerAttachedObject(playerid, 0, 19320, 2, 0.079577, 0.016865, 0.005709, 171.620758, 93.131149, 280.057983, 1.000000, 1.000000, 1.000000 ); //Pumpkin
		        }
		        case 6:
		        {
                  SetPlayerAttachedObject( playerid, 0, 1114, 1, 0.138007, 0.002714, -0.157366, 350.942352, 16.794704, 32.683506, 0.791829, 0.471535, 1.032759 );
				  SetPlayerAttachedObject( playerid, 1, 1114, 1, 0.138007, 0.002714, 0.064523, 342.729064, 354.099456, 32.369094, 0.791829, 0.471535, 1.032759 ); //Iron
				}
		        case 7:
		        {
                  for(new i=0; i<MAX_PLAYER_ATTACHED_OBJECTS; i++)
                {
 		 		           if(IsPlayerAttachedObjectSlotUsed(playerid, i)) RemovePlayerAttachedObject(playerid, i);
                }
       	        return 1;
          }


		    }
		}
	}
	if(dialogid == 12009)//vip attach objcts
	{
	    if(response)
		{
		    switch(listitem)
		    {
		        case 0:
		        {
                  	SetPlayerAttachedObject(playerid, 0, 19065, 2, 0.121128, 0.023578, 0.001139, 222.540847, 90.773872, 211.130859, 1.098305, 1.122310, 1.106640 ); // SantaHat
		        }
                case 1:
		        {
                  	SetPlayerAttachedObject(playerid, 0, 19078, 1, 0.329150, -0.072101, 0.156082, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000 ); //parrot
		        }
		        case 2:
		        {
                  	SetPlayerAttachedObject(playerid, 0, 1371, 1, 0.037538, 0.000000, -0.020199, 350.928314, 89.107200, 180.974227, 1.000000, 1.000000, 1.000000 ); //Hippo
		        }
		        case 3:
		        {
                  	SetPlayerAttachedObject(playerid, 0, 18728, 2, 0.134301, 1.475258, -0.192459, 82.870338, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000 ); //Smoke Flare
		        }
		        case 4:
		        {
                  	SetPlayerAttachedObject(playerid, 0, 1608, 2, 0.079577, 0.016865, 0.005709, 171.620758, 93.131149, 280.057983, 1.000000, 1.000000, 1.000000 ); //Shark Head
		        }
		        case 5:
		        {
                  	SetPlayerAttachedObject(playerid, 0, 19320, 2, 0.079577, 0.016865, 0.005709, 171.620758, 93.131149, 280.057983, 1.000000, 1.000000, 1.000000 ); //Pumpkin
		        }
		        case 6:
		        {
                  SetPlayerAttachedObject( playerid, 0, 1114, 1, 0.138007, 0.002714, -0.157366, 350.942352, 16.794704, 32.683506, 0.791829, 0.471535, 1.032759 );
				  SetPlayerAttachedObject( playerid, 1, 1114, 1, 0.138007, 0.002714, 0.064523, 342.729064, 354.099456, 32.369094, 0.791829, 0.471535, 1.032759 ); //Iron
		        }
				case 7:
		        {
                  SetPlayerAttachedObject(playerid, 0, 1254, 2, 0.079577, 0.016865, 0.005709, 171.620758, 93.131149, 280.057983, 1.000000, 1.000000, 1.000000 ); //Ghost
                  SetPlayerAttachedObject(playerid, 0, 18691, 2, 0.079577, 0.016865, 0.005709, 171.620758, 93.131149, 280.057983, 1.000000, 1.000000, 1.000000 ); //Rider
		        }
				case 8:
		        {
                  SetPlayerAttachedObject(playerid, 0, 11704, 2, 0.079577, 0.016865, 0.005709, 171.620758, 93.131149, 280.057983, 1.000000, 1.000000, 1.000000 ); //Devil Mask
		        }
		        case 9:
		        {
                  SetPlayerAttachedObject( playerid, 0, 18645, 2, 0.017478, 0.051500, 0.003912, 285.055511, 90.860740, 171.179550, 1.780549, 0.912008, 1.208514 );
				  SetPlayerAttachedObject( playerid, 1, 18690, 2, -2.979508, 0.306475, -0.388553, 285.055511, 90.860740, 171.179550, 1.780549, 0.912008, 1.208514 );
   				  SetPlayerAttachedObject( playerid, 2, 18716, 2, -2.979508, 0.306475, -0.388553, 285.055511, 90.860740, 171.179550, 1.780549, 0.912008, 1.208514 ); // Alien
		        }
		        case 10:
		        {
 				  SetPlayerAttachedObject( playerid, 0, 369, 2, -0.183602, 0.016535, -0.039228, 1.763265, 356.138977, 355.971618, 3.034477, 3.000000, 3.000000 ); // irgoggles - ON FACE
	  			  SetPlayerAttachedObject( playerid, 1, 356, 6, 0.013610, -0.021393, -0.144862, 2.354303, 354.413848, 0.219168, 3.034477, 3.000000, 3.000000 ); // m4 - M4 HAND
	  			  SetPlayerAttachedObject( playerid, 2, 359, 1, 0.000000, -0.232854, -0.241260, 354.348602, 29.348077, 357.846679, 2.000000, 2.000000, 2.000000 ); // rocketla - ROCKETBACK
				  SetPlayerAttachedObject( playerid, 3, 363, 7, 0.176143, 0.281574, -0.120761, 79.200103, 267.183990, 337.320526, 1.200000, 1.200000, 1.200000 ); // satchel - packet //Terminator
		        }
		        case 11:
		        {
					SetPlayerAttachedObject(playerid, 0, 19086, 6, -0.020373, -0.002333, 0.183234, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0); // chainsaw dildo
				}
				case 12:
				{
			 		SetPlayerAttachedObject(playerid, 0, 1550, 17, -0.253999, -0.149000, -0.016999, 65.699943, 67.599983, 59.299983, 1.000000, 0.849000, 0.956000);//moneybag
				}
				case 13:
				{
					SetPlayerAttachedObject(playerid, 0, 19317, 1, 0.193999, -0.104999, 0.011000, 1.900007, 50.199993, 0.000000, 0.957001, 2.302000, 0.953999);
					SetPlayerAttachedObject(playerid, 1, 19319, 5, 0.059000, 0.014000, -0.023000, 155.900009, -30.199981, -175.599914, 1.000000, 1.000000, 1.000000);
				}
		        case 14:
		        {
                  for(new i=0; i<MAX_PLAYER_ATTACHED_OBJECTS; i++)
                {
 		 		           if(IsPlayerAttachedObjectSlotUsed(playerid, i)) RemovePlayerAttachedObject(playerid, i);
                }
       	        return 1;
          }


		    }
		}
	}
    if(dialogid == 12302) // tp menu -vip====
	{
	    if(response)
	    {
            switch(listitem)
	        {
	             case 0: //VIP Username
	            {
	            SetPlayerPos(playerid, 1341.4557,1252.3799,10.8203); // Vip Hangout
	            SendClientMessage(playerid, COLOR_RED, "Welcome to VIP Hangout!");
	            }
	            case 1: //VIP Username
	            {
	            SetPlayerPos(playerid, 1548.3171,-1366.4285,326.2109); //LS Tower
	            SendClientMessage(playerid, COLOR_RED, "Welcome to Los Santos Tower!");
	            }
	            case 2:
	            {
	            SetPlayerPos(playerid, -79.7804,3499.9863,5.3077);//VIP Funland
	            SendClientMessage(playerid, COLOR_RED, "Welcome to VIP Funland!");
	            }
	         }
	    }
	}
	if(dialogid == vipmenu4) // chat colour settings
	{
	    if(response)
	    {
	        new string[50];
	        switch(listitem)
	        {
	            case 0: // default - white
	            {
          			format(string, sizeof(string), "FFFFFF"); //last login date+time
					strmid(PlayerInfo[playerid][VIPColour], string, 0, strlen(string), 50); //last login date+time
	                SendClientMessage(playerid, COLOR_VIP, "Your chat colour is now set back to default.");
	                return 1;
	            }
	            case 1: // Red
	            {
          			format(string, sizeof(string), "F80B0B"); //last login date+time
					strmid(PlayerInfo[playerid][VIPColour], string, 0, strlen(string), 50); //last login date+time
	                SendClientMessage(playerid, COLOR_VIP, "Your chat colour is now set to Red.");
	                return 1;
	            }
	            case 2: // Dark Blue
	            {
          			format(string, sizeof(string), "0B1FF8"); //last login date+time
					strmid(PlayerInfo[playerid][VIPColour], string, 0, strlen(string), 50); //last login date+time
	                SendClientMessage(playerid, COLOR_VIP, "Your chat colour is now set to Dark Blue.");
	                return 1;
	            }
	            case 3: // Light Blue
	            {
          			format(string, sizeof(string), "0BC1F8"); //last login date+time
					strmid(PlayerInfo[playerid][VIPColour], string, 0, strlen(string), 50); //last login date+time
	                SendClientMessage(playerid, COLOR_VIP, "Your chat colour is now set to Light Blue.");
	                return 1;
	            }
	            case 4: // Green
	            {
          			format(string, sizeof(string), "0BF80B"); //last login date+time
					strmid(PlayerInfo[playerid][VIPColour], string, 0, strlen(string), 50); //last login date+time
	                SendClientMessage(playerid, COLOR_VIP, "Your chat colour is now set to Green.");
	                return 1;
	            }
	            case 5: // Yellow
	            {
          			format(string, sizeof(string), "F4F80B"); //last login date+time
					strmid(PlayerInfo[playerid][VIPColour], string, 0, strlen(string), 50); //last login date+time
	                SendClientMessage(playerid, COLOR_VIP, "Your chat colour is now set to Yellow.");
	                return 1;
	            }
	            case 6: // Orange
	            {
          			format(string, sizeof(string), "F87E0B"); //last login date+time
					strmid(PlayerInfo[playerid][VIPColour], string, 0, strlen(string), 50); //last login date+time
	                SendClientMessage(playerid, COLOR_VIP, "Your chat colour is now set to Orange.");
	                return 1;
	            }
	            case 7: // Purple
	            {
          			format(string, sizeof(string), "FF80BD1"); //last login date+time
					strmid(PlayerInfo[playerid][VIPColour], string, 0, strlen(string), 50); //last login date+time
	                SendClientMessage(playerid, COLOR_VIP, "Your chat colour is now set to Purple.");
	                return 1;
	            }
	            case 8: // Black
	            {
          			format(string, sizeof(string), "040404"); //last login date+time
					strmid(PlayerInfo[playerid][VIPColour], string, 0, strlen(string), 50); //last login date+time
	                SendClientMessage(playerid, COLOR_VIP, "Your chat colour is now set to Black.");
	                return 1;
	            }
	        }
	    }
	    ShowVIPMenu(playerid);
	    return 1;
	}
	if(dialogid == vipmenu2)
	{
	    if(response)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
					SendClientMessage(playerid, COLOR_VIP, "You have set the weather to ID 1. (Blue Skies/Clouds)");
					SetPlayerWeather(playerid, 5);
					return 1;
	            }
	            case 1:
	            {
					SendClientMessage(playerid, COLOR_VIP, "You have set the weather to ID 2. (Stormy)");
	                SetPlayerWeather(playerid, 8);
	                return 1;
	            }
	            case 2:
	            {
					SendClientMessage(playerid, COLOR_VIP, "You have set the weather to ID 3. (Foggy)");
	                SetPlayerWeather(playerid, 9);
	                return 1;
	            }
	            case 3:
	            {
					SendClientMessage(playerid, COLOR_VIP, "You have set the weather to ID 4. (Scorching Hot)");
	                SetPlayerWeather(playerid, 11);
	                return 1;
	            }
	            case 4:
	            {
					SendClientMessage(playerid, COLOR_VIP, "You have set the weather to ID 5. (Dull & Colourless)");
	                SetPlayerWeather(playerid, 13);
	                return 1;
	            }
	            case 5:
	            {
					SendClientMessage(playerid, COLOR_VIP, "You have set the weather to ID 6. (Sandstorm)");
	                SetPlayerWeather(playerid, 19);
	                return 1;
	            }
	            case 6:
	            {
					SendClientMessage(playerid, COLOR_VIP, "You have set the weather to ID 7. (Green fog)");
	                SetPlayerWeather(playerid, 20);
	                return 1;
	            }
	            case 7:
	            {
					SendClientMessage(playerid, COLOR_VIP, "You have set the weather to ID 8. (Fresh blue)");
	                SetPlayerWeather(playerid, 28);
	                return 1;
	            }
	        }
	    }
	    ShowVIPMenu(playerid);
	    return 1;
	}
if(dialogid == 9048 && response)
{
    new pame[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pame,sizeof(pame));
    if (PlayerInfo[playerid][LoggedIn] == 1) return SendClientMessage(playerid,red,"ACCOUNT: You are already logged in.");
    if (!udb_Exists(PlayerName2(playerid))) return SendClientMessage(playerid,red,"ACCOUNT: Account doesn't exist, please use '/register [password]'.");
    if (udb_CheckLogin(PlayerName2(playerid),inputtext))
	{
		new file[256], tmp3[100], string[128];
	   	format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(PlayerName2(playerid)) );
   		GetPlayerIp(playerid,tmp3,100);
	   	dini_Set(file,"ip",tmp3);
		LoginPlayer(playerid);
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);

		if(PlayerInfo[playerid][Level] == 0)
		{
			format(string,sizeof(string),"ACCOUNT: Successfully {FF0000}Logged In");
			SendClientMessage(playerid,green,string);
		}
		if(PlayerInfo[playerid][Level] == 1) {
		format(string,sizeof(string),"{FFFF00}* {F81414}({1919FF}Trial Moderator{F81414}) %s{6EF83C} has logged in!", pame);
		SendClientMessageToAll(green,string);
       	format(string,sizeof(string),"ACCOUNT: Successfully Logged In. (Trial Moderator)");
		SendClientMessage(playerid,green,string);
			}
        if(PlayerInfo[playerid][Level] == 2) {
		format(string,sizeof(string),"{FFFF00}** {F81414}({919191}Moderator{F81414}) %s{6EF83C} has logged in!", pame);
		SendClientMessageToAll(green,string);
       	format(string,sizeof(string),"ACCOUNT: Successfully Logged In. (Moderator)");
		SendClientMessage(playerid,green,string);
			}
		if(PlayerInfo[playerid][Level] == 3) {
		format(string,sizeof(string),"{FFFF00}*** {F81414}({33AA33}Administrator{F81414}) %s{6EF83C} has logged in!", pame);
		SendClientMessageToAll(LightGreen,string);
       	format(string,sizeof(string),"ACCOUNT: Successfully Logged In. (Administrator)");
		SendClientMessage(playerid,LightGreen,string);
			}
		if(PlayerInfo[playerid][Level] == 4) {
		format(string,sizeof(string),"{FF0000}**** {F81414}({FF0000}Senior Administrator{F81414}) %s{6EF83C} has logged in.", pame);
		SendClientMessageToAll(LightGreen,string);
		format(string,sizeof(string),"ACCOUNT: Successfully Logged In. (Senior Administrator)");
		SendClientMessage(playerid,LightGreen,string);
			}
		if(PlayerInfo[playerid][Level] == 5) {
		format(string,sizeof(string),"{FFFF00}***** {F81414}({FFFFFF}Head Administrator{F81414}) %s{6EF83C} has logged in!", pame);
		SendClientMessageToAll(lightblue,string);
		format(string,sizeof(string),"ACCOUNT: Successfully Logged In. (Head Administrator)" );
		SendClientMessage(playerid,lightblue,string);
			}
		if(PlayerInfo[playerid][Level] == 6) {
		format(string,sizeof(string),"{FFFF00}****** {F81414}({00F2FF}Manager/CEO{F81414}) %s{6EF83C} has logged in!", pame);
		SendClientMessageToAll(RED,string);
		format(string,sizeof(string),"ACCOUNT: Successfully Logged In. (Manager/CEO)");
		SendClientMessage(playerid,RED,string);
			}
		if(PlayerInfo[playerid][pVip] == 1)
		{
            format(string,sizeof(string),"{FF0000}%s{FFFF00} [{E9E9E9}Silver VIP] has logged in.", pame);
			SendClientMessageToAll(green,string);
			format(string,sizeof(string),"ACCOUNT: Successfully Logged In. ({E9E9E9}Silver{E9E9E9})");
			SendClientMessage(playerid,green,string);
		}
		if(PlayerInfo[playerid][pVip] == 2)
		{
            format(string,sizeof(string),"{FF0000}%s{FFFF00} [{FFFF00}Gold{FFFF00}] has logged in.", pame);
			SendClientMessageToAll(green,string);
			format(string,sizeof(string),"ACCOUNT: Successfully Logged In. ({FFFF00}Gold{FFFF00})");
			SendClientMessage(playerid,green,string);
		}
		if(PlayerInfo[playerid][pVip] == 3)
		{
            format(string,sizeof(string),"{FF0000}%s{FFFF00} [{0000FF}Platinum{0000FF}] has logged in.", pame);
			SendClientMessageToAll(green,string);
			format(string,sizeof(string),"ACCOUNT: Successfully Logged In. ({0000FF}Platinum{0000FF})");
			SendClientMessage(playerid,green,string);
		}
		if(PlayerInfo[playerid][isDJ] == 1)
		{
            format(string,sizeof(string),"{%06x}%s [{C0C0C0}TBS DJ{C0C0C0}] has logged in.",GetPlayerColor(playerid) >>> 8, pame);
			SendClientMessageToAll(green,string);
			format(string,sizeof(string),"ACCOUNT: Successfully Logged In. ({C0C0C0}TBS DJ{C0C0C0})");
			SendClientMessage(playerid,green,string);
		}
	}
	else
	{
	new string[128];
	PlayerInfo[playerid][FailLogin]++;
    if(PlayerInfo[playerid][FailLogin] >= MAX_LOGIN_ATTEMPTS)
    {
            new pName4[MAX_PLAYER_NAME];
            GetPlayerName(playerid, pName4,sizeof(pName4));
			format(string, sizeof(string),"Player %s has been automatically kicked (Reason: Many attempts Incorrect Passwords)", pName4);
	        SendClientMessageToAll(grey,string);
	        SetTimerEx("KickPlayer",100,false,"d",playerid);
	        return 1;
    }
    new pName3[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pName3,sizeof(pName3));
	format(string, sizeof(string),"{FFFFFF}Sorry '{FF0000}%s{FFFFFF}',\n\nThe password you've entered doesn't match the one in the database.\n\nPlease, re-enter the correct password below:", pName3);
    ShowPlayerDialog(playerid, 9048, DIALOG_STYLE_PASSWORD, "Login Error.",string, "Login", "Quit");
    SendClientMessage(playerid,red,"Incorrect Password!");
	}
}
if(dialogid == 9049 && response)
{
	new dialogstr[256];
    new pame[MAX_PLAYER_NAME];
    GetPlayerName(playerid, pame, sizeof(pame));
    if (PlayerInfo[playerid][LoggedIn] == 1) return SendClientMessage(playerid,red,"ACCOUNT: You are already registered and logged in.");
    if (udb_Exists(PlayerName2(playerid))) return SendClientMessage(playerid,red,"ACCOUNT: This account already exists, please use '/login [password]'.");
    if (strlen(inputtext) == 0) return format(dialogstr,sizeof(dialogstr),"{FFFFFF}%s your nickname isn't registed please choose a password:", pame), ShowPlayerDialog(playerid, 9049, DIALOG_STYLE_INPUT, "{FF0000}Register", dialogstr, "Accept", "Cancel");
    if (strlen(inputtext) < 4 || strlen(inputtext) > 20) return format(dialogstr,sizeof(dialogstr),"Sorry '%s'\n\nThe length of your password should contain more \nthan 3 characters and less than 20 characters! \n\n Please, re-enter the Password:", pame), ShowPlayerDialog(playerid, 9049, DIALOG_STYLE_INPUT, "Register Error", dialogstr, "Accept", "Cancel");
    if (udb_Create(PlayerName2(playerid),inputtext))
	{
    	new file[256],name[MAX_PLAYER_NAME], tmp3[100];
    	new strdate[20], year,month,day;	getdate(year, month, day);
		GetPlayerName(playerid,name,sizeof(name)); format(file,sizeof(file),"/ladmin/users/%s.sav",udb_encode(name));
     	GetPlayerIp(playerid,tmp3,100);	dini_Set(file,"ip",tmp3);
    	dUserSetINT(PlayerName2(playerid)).("password_hash",udb_hash(inputtext) );
	    dUserSetINT(PlayerName2(playerid)).("registered",1);
   		format(strdate, sizeof(strdate), "%d/%d/%d",day,month,year);
		dini_Set(file,"RegisteredDate",strdate);
		dUserSetINT(PlayerName2(playerid)).("loggedin",1);
		dUserSetINT(PlayerName2(playerid)).("banned",0);
		dUserSetINT(PlayerName2(playerid)).("level",0);
		dUserSetINT(PlayerName2(playerid)).("kills",0);
		dUserSetINT(PlayerName2(playerid)).("deaths",0);
	    dUserSetINT(PlayerName2(playerid)).("LastOn",0);
    	dUserSetINT(PlayerName2(playerid)).("money",0);
    	dUserSetINT(PlayerName2(playerid)).("score",0);
	   	dUserSetINT(PlayerName2(playerid)).("hours",0);
	   	dUserSetINT(PlayerName2(playerid)).("minutes",0);
	   	dUserSetINT(PlayerName2(playerid)).("seconds",0);
	   	dUserSetINT(PlayerName2(playerid)).("Jailed",0);
	   	dUserSetINT(PlayerName2(playerid)).("DJ",0);
	   	dUserSetINT(PlayerName2(playerid)).("Maths",0);
	   	dUserSetINT(PlayerName2(playerid)).("Reacts",0);
	   	dUserSetINT(PlayerName2(playerid)).("CPs",0);
	   	dUserSetINT(PlayerName2(playerid)).("MoneyBag",0);
	   	dUserSetINT(PlayerName2(playerid)).("CookieJar",0);
	   	dUserSetINT(PlayerName2(playerid)).("Cookies",0);
	   	dUserSetINT(PlayerName2(playerid)).("Brownies",0);
	   	dUserSetINT(PlayerName2(playerid)).("VIPTime",0);
		PlayerInfo[playerid][LoggedIn] = 1;
	    PlayerInfo[playerid][Registered] = 1;
	    SendClientMessage(playerid, green, "ACCOUNT: You are now registered, and have been automaticaly logged in");
		PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
		return 1;
	}
    return 1;
}
 //=============================================================================
//---------------
// Dialog - SERVER TWO RCON
//---------------
//==============================================================================
#if EnableTwoRcon == true
	if(dialogid == DIALOG_TYPE_RCON2)
	{
	    if (response)
	    {
        	if (!strcmp(TwoRconPass, inputtext) && !(!strlen(inputtext)))
			{
				GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~g~Authorized ~w~Access!~n~~y~Welcome Administrator!",3000,3);
	            new string[128]; GetPlayerName(playerid,string,sizeof(string));
		        format(string,sizeof(string),"{00FF00}%s(%d) Has Logged In As RCON",string,playerid); MessageToManagers(green,string);
     		}
			else
			{
				if(PlayerInfo[playerid][MaxRcon] == 2)
				{
			        new tmp3[50];
					SendClientMessage(playerid, red, "You has been Automatically IP Banned! Goodbye bitch! Go fuck yourself!");
	                new string[128]; GetPlayerName(playerid,string,sizeof(string));
		            format(string,sizeof(string),"{FF0000}%s(%d) Has Failed To Login As RCON",string,playerid); MessageToManagers(green,string);
					GetPlayerIp(playerid,tmp3,sizeof(tmp3));
                    strdel(tmp3,strlen(tmp3)-2,strlen(tmp3));
    	            format(tmp3,128,"%s**",tmp3);
			     	format(tmp3,128,"banip %s",tmp3);
            	    SendRconCommand(tmp3);

				}
				PlayerInfo[playerid][MaxRcon]++;
				new tmp[140];
	  			SendClientMessage(playerid, red, "|- Invalid Rcon Password! -|");
   				format(tmp,sizeof(tmp),"Invalid Password!. \n\nFor access the account, you must enter the CORRECT second password RCON.\n\nAttempts: %d/2", PlayerInfo[playerid][MaxRcon]);
				ShowPlayerDialog(playerid, DIALOG_TYPE_RCON2, DIALOG_STYLE_INPUT, "TBS Admin - RCON!",tmp, "Enter", "Exit");
			}
   		}
		else
		{
			SendClientMessage(playerid, red, "|- ERROR: Kicked! -|");
	    	return Kick(playerid);
	    }
	    return 1;
	}
#endif
	if(dialogid == CONSOLE)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon exit' Sended Successfully");
					SendRconCommand("exit");
				}
				case 1:
				{
					ShowPlayerDialog(playerid, HOSTNAME, DIALOG_STYLE_INPUT, "Hostname!", "/rcon hostname [name] - change the hostname text", "Input", "Cancel");
				}
				case 2:
				{
					ShowPlayerDialog(playerid, GAMEMODENAME, DIALOG_STYLE_INPUT, "Gamemode Name!", "/rcon gamemodetext [name] - change the gamemode text", "Input", "Cancel");
				}
				case 3:
				{
					ShowPlayerDialog(playerid, MAPNAME, DIALOG_STYLE_INPUT, "Map Name!", "/rcon mapname [name] - change the map name text", "Input", "Cancel");
				}
				case 4:
				{
					ShowPlayerDialog(playerid, EXEC, DIALOG_STYLE_INPUT, "Execute File!", "/rcon exec [filename] - Executes the file which contains server cfg", "Input", "Cancel");
				}
				case 5:
				{
					ShowPlayerDialog(playerid, KICK, DIALOG_STYLE_INPUT, "Kick!", "/rcon kick [ID] - Kick the player with the given ID", "Input", "Cancel");
				}
				case 6:
				{
					ShowPlayerDialog(playerid, BAN, DIALOG_STYLE_INPUT, "Ban!", "/rcon ban [ID] - Ban the player with the given ID", "Input", "Cancel");
				}
				case 7:
				{
					ShowPlayerDialog(playerid, CHANGEMODE, DIALOG_STYLE_INPUT, "Change Gamemode", "/rcon changemode [mode] - This command will change the current gamemode to the given one", "Input", "Cancel");
				}
				case 8:
				{
					SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon gmx' Sended Successfully");
					SendRconCommand("gmx");
				}
				case 9:
				{
					SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon reloadbans' Sended Successfully");
					SendRconCommand("reloadbans");
				}
				case 10:
				{
					SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon reloadlog' Sended Successfully");
					SendRconCommand("reloadlog");
				}
				case 11:
				{
					ShowPlayerDialog(playerid, BANIP, DIALOG_STYLE_INPUT, "IP Bans", "/rcon banip [IP] - Ban the given IP", "Input", "Cancel");
				}
				case 12:
				{
					ShowPlayerDialog(playerid, UNBANIP, DIALOG_STYLE_INPUT, "IP Unbans", "/rcon unbanip [IP] - Unban the given IP", "Input", "Cancel");
				}
				case 13:
				{
					ShowPlayerDialog(playerid, GRAVITY, DIALOG_STYLE_INPUT, "Change Gravity", "/rcon gravity - Changes the gravity", "Input", "Cancel");
				}
				case 14:
				{
					ShowPlayerDialog(playerid, WEATHER, DIALOG_STYLE_INPUT, "Change Weather", "/rcon weather [ID] - Changes the weather", "Input", "Cancel");
				}
				case 15:
				{
					ShowPlayerDialog(playerid, LOADFS, DIALOG_STYLE_INPUT, "Load Filterscript", "/rcon loadfs - Loads the given filterscript", "Input", "Cancel");
				}
				case 16:
				{
					ShowPlayerDialog(playerid, UNLOADFS, DIALOG_STYLE_INPUT, "Unload Filterscript", "/rcon unloadfs - Unload the given filterscript", "Input", "Cancel");
				}
				case 17:
				{
					ShowPlayerDialog(playerid, RELOADFS, DIALOG_STYLE_INPUT, "Reload Filterscript", "/rcon reloadfs - Reloads the given filterscript", "Input", "Cancel");
				}
				case 18:
				{
					ShowPlayerDialog(playerid, WEBURL, DIALOG_STYLE_INPUT, "Change Server URL", "/rcon weburl [server url] - Changes the server URL in the masterlists/SA-MP client ", "Input", "Cancel");
				}
			}
		}
		return 1;
	}
	if(dialogid == HOSTNAME)
	{
		if(!response)
		if(!strlen(inputtext))
		{
			ShowPlayerDialog(playerid, HOSTNAME, DIALOG_STYLE_INPUT, "Hostname!", "/rcon hostname [name] - change the hostname text", "Input", "Cancel");
			return 1;
		}
		new str[128];
		format(str, sizeof(str), "hostname %s", inputtext);
		SendRconCommand(str);
		SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon hostname' Sended Successfully");
		return 1;
	}
	if(dialogid == GAMEMODENAME)
	{
		if(!response)
		if(!strlen(inputtext))
		{
			ShowPlayerDialog(playerid, GAMEMODENAME, DIALOG_STYLE_INPUT, "Gamemode Name!", "/rcon gamemodetext [name] - change the gamemode text", "Input", "Cancel");
			return 1;
		}
		new str[128];
		format(str, sizeof(str), "gamemodetext %s", inputtext);
		SendRconCommand(str);
		SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon gamemodetext' Sended Successfully");
		return 1;
	}
	if(dialogid == MAPNAME)
	{
		if(!response)
		if(!strlen(inputtext))
		{
			ShowPlayerDialog(playerid, MAPNAME, DIALOG_STYLE_INPUT, "Map Name!", "/rcon mapname [name] - change the map name text", "Input", "Cancel");
			return 1;
		}
		new str[128];
		format(str, sizeof(str), "mapname %s", inputtext);
		SendRconCommand(str);
		SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon mapname' Sended Successfully");
		return 1;
	}
	if(dialogid == EXEC)
	{
		if(!response)
		if(!strlen(inputtext))
		{
			ShowPlayerDialog(playerid, EXEC, DIALOG_STYLE_INPUT, "Execute File!", "/rcon exec [filename] - Executes the file which contains server cfg", "Input", "Cancel");
			return 1;
		}
		new str[128];
		format(str, sizeof(str), "exec %s", inputtext);
		SendRconCommand(str);
		SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon exec' Sended Successfully");
		return 1;
	}
	if(dialogid == KICK)
	{
		if(!response)
		if(!strlen(inputtext))
		{
			ShowPlayerDialog(playerid, KICK, DIALOG_STYLE_INPUT, "Kick!", "/rcon kick [ID] - Kick the player with the given ID", "Input", "Cancel");
			return 1;
		}
        if(!strcmp(inputtext, "Filipbg") || !strcmp(inputtext, "Emily_Lafernus")) return SendClientMessage(playerid, COLOR_RED, "ERROR: You CANNOT kick Filipbg or Emily_Lafernus! >:C");
		new str[128];
		format(str, sizeof(str), "kick %s", inputtext);
		SendRconCommand(str);
		SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon kick' Sended Successfully");
		return 1;
	}
	if(dialogid == BAN)
	{
		if(!response)
		if(!strlen(inputtext))
		{
			ShowPlayerDialog(playerid, BAN, DIALOG_STYLE_INPUT, "Ban!", "/rcon ban [ID] - Ban the player with the given ID", "Input", "Cancel");
			return 1;
		}
        if(!strcmp(inputtext, "Filipbg") || !strcmp(inputtext, "Emily_Lafernus")) return SendClientMessage(playerid, COLOR_RED, "ERROR: You CANNOT ban Filipbg or Emily_Lafernus! >:C");
		new str[128];
		format(str, sizeof(str), "ban %s", inputtext);
		SendRconCommand(str);
		SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon ban' Sended Successfully");
		return 1;
	}
	if(dialogid == CHANGEMODE)
	{
		if(!response)
		if(!strlen(inputtext))
		{
			ShowPlayerDialog(playerid, CHANGEMODE, DIALOG_STYLE_INPUT, "Change Gamemode", "/rcon changemode [mode] - This command will change the current gamemode to the given one", "Input", "Cancel");
			return 1;
		}
		new str[128];
		format(str, sizeof(str), "changemode %s", inputtext);
		SendRconCommand(str);
		SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon changemode' Sended Successfully");
		return 1;
	}
	if(dialogid == BANIP)
	{
		if(!response)
		if(!strlen(inputtext))
		{
			ShowPlayerDialog(playerid, BANIP, DIALOG_STYLE_INPUT, "IP Bans", "/rcon banip [IP] - Ban the given IP", "Input", "Cancel");
			return 1;
		}
        if(!strcmp(inputtext, "95.42.10.26") || !strcmp(inputtext, "139.193.65.203") || !strcmp(inputtext, "95.42.223.221")) return SendClientMessage(playerid, COLOR_RED, "ERROR: You CANNOT ban this IP! >:C");
		new str[128];
		format(str, sizeof(str), "banip %s", inputtext);
		SendRconCommand(str);
		SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon banip' Sended Successfully");
		return 1;
	}
	if(dialogid == UNBANIP)
	{
		if(!response)
		if(!strlen(inputtext))
		{
			ShowPlayerDialog(playerid, UNBANIP, DIALOG_STYLE_INPUT, "IP Unbans", "/rcon unbanip [IP] - Unban the given IP", "Input", "Cancel");
			return 1;
		}
		new str[128];
		format(str, sizeof(str), "unbanip %s", inputtext);
		SendRconCommand(str);
		SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon unbanip' Sended Successfully");
		return 1;
	}
	if(dialogid == GRAVITY)
	{
		if(!response)
		if(!strlen(inputtext))
		{
			ShowPlayerDialog(playerid, GRAVITY, DIALOG_STYLE_INPUT, "Change Gravity", "/rcon gravity - Changes the gravity", "Input", "Cancel");
			return 1;
		}
		new str[128];
		format(str, sizeof(str), "gravity %s", inputtext);
		SendRconCommand(str);
		SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon gravity' Sended Successfully");
		return 1;
	}
	if(dialogid == WEATHER)
	{
		if(!response)
		if(!strlen(inputtext))
		{
			ShowPlayerDialog(playerid, WEATHER, DIALOG_STYLE_INPUT, "Change Weather", "/rcon weather [ID] - Changes the weather", "Input", "Cancel");
			return 1;
		}
		new str[128];
		format(str, sizeof(str), "weather %s", inputtext);
		SendRconCommand(str);
		SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon weather' Sended Successfully");
		return 1;
	}
	if(dialogid == LOADFS)
	{
		if(!response)
		if(!strlen(inputtext))
		{
			ShowPlayerDialog(playerid, LOADFS, DIALOG_STYLE_INPUT, "Load Filterscript", "/rcon loadfs - Loads the given filterscript", "Input", "Cancel");
			return 1;
		}
		new str[128];
		format(str, sizeof(str), "loadfs %s", inputtext);
		SendRconCommand(str);
		SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon loadfs' Sended Successfully");
		return 1;
	}
	if(dialogid == UNLOADFS)
	{
		if(!response)
		if(!strlen(inputtext))
		{
			ShowPlayerDialog(playerid, UNLOADFS, DIALOG_STYLE_INPUT, "Unload Filterscript", "/rcon unloadfs - Unload the given filterscript", "Input", "Cancel");
			return 1;
		}
		new str[128];
		format(str, sizeof(str), "unloadfs %s", inputtext);
		SendRconCommand(str);
		SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon unloadfs' Sended Successfully");
		return 1;
	}
	if(dialogid == RELOADFS)
	{
		if(!response) return 1;
		if(!strlen(inputtext))
		{
			ShowPlayerDialog(playerid, RELOADFS, DIALOG_STYLE_INPUT, "Reload Filterscript", "/rcon reloadfs - Reloads the given filterscript", "Input", "Cancel");
			return 1;
		}
		new str[128];
		format(str, sizeof(str), "reloadfs %s", inputtext);
		SendRconCommand(str);
		SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon reloadfs' Sended Successfully");
		return 1;
	}
	if(dialogid == WEBURL)
	{
		if(!response)
		if(!strlen(inputtext))
		{
			ShowPlayerDialog(playerid, WEBURL, DIALOG_STYLE_INPUT, "Change Server URL", "/rcon weburl [server url] - Changes the server URL in the masterlists/SA-MP client ", "Input", "Cancel");
			return 1;
		}
		new str[128];
		format(str, sizeof(str), "weburl %s", inputtext);
		SendRconCommand(str);
		SendClientMessage(playerid, 0xFFFFFFFF, "'/rcon weburl' Sended Successfully");
		return 1;
	}
    return 0;
}


forward KickPublic(playerid);//Kick function with timer.
public KickPublic(playerid) { Kick(playerid); }

stock SetPlayerPosEx(playerid, Float:X, Float:Y, Float:Z, Float:angle, interior, world)
{
	SetPlayerPos(playerid, X, Y, Z);
	SetPlayerFacingAngle(playerid, angle);
	SetPlayerInterior(playerid, interior);
	SetPlayerVirtualWorld(playerid, world);
	return 1;
}

stock IsValidWeapon(weaponid)
{
    if (weaponid > 0 && weaponid < 19 || weaponid > 21 && weaponid < 47) return 1;
    return 0;
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

function xReactionProgress()
{
    switch(xTestBusy)
	{
	    case false:
	    {
		    new
		        string[128]
			;
			format(string, sizeof(string), "{7100E1}[REACT]« New reaction starting in 2 minutes. »", (TIME/60000));
		    SendClientMessageToAll(COLOR_PURPLE, string);
	        KillTimer(xReactionTimer);
			xReactionTimer = SetTimer("xReactionTest", 1000*120*TIME, true);
		}
	}
	return 1;
}

#define Loop3(%0,%1) \
	for(new %0 = 0; %0 != %1; %0++)

function xReactionTest()
{
	new
		xLength = (random(8) + 2),
		string[128]
	;
	xCash = (random(10000) + 10000);
	xScore = (random(2)+1);
 	xCookies = (random(3)+2);
	format(xChars, sizeof(xChars), "");
	Loop3(x, xLength) format(xChars, sizeof(xChars), "%s%s", xChars, xCharacters[random(sizeof(xCharacters))][0]);
    format(string, sizeof(string), "{7100E1}[REACT]« Who first types {00FF00}%s {7100E1}wins $%d + %d score + %d Cookies. »", xChars, xCash, xScore, xCookies);
	SendClientMessageToAll(COLOR_PURPLE, string);
	//KillTimer(xReactionTimer);
	xTestBusy = true;
	SetTimer("xReactionProgress", 30000, 0);
	return 1;
}

//Lotto
public LottoJackpotIncrease()
{
        LottoJackpot = LottoJackpot+random(MAX_LOTTO_JACKPOT_INCREASE);
}

public LottoDraw()
{
                 new LottoWinningNumber = random(99)+1;
                 new IsThereAWinner = 0;
                 new WinnerID;
                 new WinnerName[MAX_PLAYER_NAME];
                 new tempJackpot = LottoJackpot;
                    for (new i = 0; i < MAX_PLAYERS; i++)
                        {
                            if (LottoParticipant[i] == 1)
                            {
                                        if (PlayerLottoGuess[i] == LottoWinningNumber)
                                        {
                                            IsThereAWinner = 1;
                                            WinnerID = i;
                                                GetPlayerName(i, WinnerName, sizeof(WinnerName));
                                                GivePlayerMoneyEx(WinnerID, LottoJackpot);
                                                ResetJackpot();
                                        }
                            }
                        }
                        if (IsThereAWinner == 1)
                        {
                            new string[256];
                            format(string, sizeof(string), "{147E8C}*Today's Winning number is %d. %s(%d) have won the jackpot of $%s.", LottoWinningNumber, WinnerName, WinnerID, FormatNumber(tempJackpot));
                            SendClientMessageToAll(COLOR_GREEN, string);
                        }
                        if (IsThereAWinner == 0)
                        {
                            new string[256];
                            format(string, sizeof(string), "{147E8C}*Today's Winning number is %d. Nobody has won the jackpot of $%s.",LottoWinningNumber, FormatNumber(LottoJackpot));
                            SendClientMessageToAll(COLOR_GREEN, string);
                        }
                        ResetLotto();
}

stock ResetLotto()
{
        for (new i = 0; i < MAX_PLAYERS; i++)
        {
            LottoParticipant[i] = 0;
            PlayerLottoGuess[i] = 0;
        }
        for (new number = 0; number < 99; number++)
        {
            NumberUsed[number] = 0;
        }
}

stock ResetJackpot()
{
        LottoJackpot = 0;
}

forward playerintrest(playerid);
public playerintrest(playerid)
{
	new interest[MAX_PLAYERS];
	interest[playerid] = GetPlayerMoney(playerid)*9/100;
 	GivePlayerMoneyEx(playerid, interest[playerid]);
	new msg[128];
	format(msg,sizeof(msg),"You have Recieved your Payday of {00FF00}$%s {FFFFFF}from San Andreas Government.", FormatNumber(interest[playerid]));
	SendClientMessage(playerid,COLOR_WHITE,msg);
}
//Gate
forward load_gates();
public load_gates()
{
	new DBResult:qresult, count = 0, value[328];
	if(!db_query(DB: GATESDB, "SELECT * FROM `gates`"))
	{
		print("GATES SYSTEM :: No gates were found in \"Gates.db\" :: 0 Loaded");
	}
	else
	{
		qresult = db_query(DB: GATESDB, "SELECT * FROM `gates`");
		count = db_num_rows(qresult);
		for(new i = 0; i < count; i++)
		{
			if(count <= MAX_GATES)
			{
				// Fetch data
				db_get_field_assoc(qresult, "gate_id", value, 5); // Gate ID
				Gates[i][gate_id] = strval(value);

				db_get_field_assoc(qresult, "gate_title", value, 48); // Gate Title
				format(Gates[i][gate_title], 48, value);

				db_get_field_assoc(qresult, "gate_password", value, 48); // Gate Password
				format(Gates[i][gate_password], 48, value);

				db_get_field_assoc(qresult, "gate_x", value, 20); // Gate X Position
				Gates[i][gateX] = floatstr(value);

				db_get_field_assoc(qresult, "gate_y", value, 20); // Gate Y Position
				Gates[i][gateY] = floatstr(value);

				db_get_field_assoc(qresult, "gate_z", value, 20); // Gate Z Position
				Gates[i][gateZ] = floatstr(value);

				db_get_field_assoc(qresult, "gate_a", value, 20); // Gate Z Position
				Gates[i][gateA] = floatstr(value);

				Gates[i][gate_object] = CreateDynamicObject(980, Gates[i][gateX], Gates[i][gateY], Gates[i][gateZ] + 1.5, 0, 0, Gates[i][gateA]);
				Gates[i][gate_created] = true;
				Gates[i][gate_status] = GATE_STATE_CLOSED;

				new gateText[200];
				format(gateText, sizeof(gateText), "Test Gate");
				//Gates[i][gateLabel] = SetObjectMaterialText(Gates[i][gate_object], gateText, 0, OBJECT_MATERIAL_SIZE_256x128, "Arial", 28, 0, 0xFFFF8200, 0xFF000000, OBJECT_MATERIAL_TEXT_ALIGN_CENTER);

				// ++ xGates
				xGates++;

				// Continue loading houses
				db_next_row(qresult);
			}
		}

		db_free_result(qresult);
	}
}

forward reloadGates();
public reloadGates()
{
	for(new i = 0; i < MAX_GATES; i++)
	{
		DestroyDynamicObject(Gates[i][gate_object]);
		//Delete3DTextLabel(Gates[i][gateLabel]);
	}

	load_gates();
}


//======================[Internal Functions - END]=======================
KickWithMessage(playerid, message[])
{
    SendClientMessage(playerid, red, message);
    SetTimerEx("KickPublic", 1000, 0, "d", playerid);
    return 1;
}
#if defined Mute_Timer
forward MuteTimer(playerid);
public KillTimer(playerid)
{
    Muted(playerid) = 0;
	KillTimer(MuteTimer[playerid]);
	return SendClientMessage(playerid,"{46FF46}You're no longer muted!");
}
#endif

