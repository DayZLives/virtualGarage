private ["_vehicle","_player","_clientID","_playerUID","_VGobjID","_name","_fnc_sanitizeInput","_class","_charID","_damage","_fuel","_hit","_inventory","_array","_hit","_selection","_colour","_colour2","_displayName","_key","_result","_outcome","_date","_year","_month","_day","_dateFormat"];
_vehicle = _this select 0;
_player = _this select 1;
_woGear = _this select 2;
_clientID = owner _player;
_playerUID = if (count _this > 3) then {_this select 3} else {getPlayerUID _player};

_gearCount = {
	private ["_counter"];
	_counter = 0;
	{_counter = _counter + _x;} count _this;
	_counter;
};

_fnc_sanitizeInput = {
	private ["_input","_badChars"];

	_input = _this;
	_input = toArray (_input);
	_badChars = [60,62,38,123,125,91,93,59,58,39,96,126,44,46,47,63,124,92,34];

	{
		_input = _input - [_x];
	} forEach _badChars;
	
	_input = toString (_input);
	_input
};

_class = typeOf _vehicle;
_displayName = (getText(configFile >> "cfgVehicles" >> _class >> "displayName")) call _fnc_sanitizeInput;
_name = if (alive _player) then {(name _player) call _fnc_sanitizeInput;} else {"unknown player";};

_charID = _vehicle getVariable ["CharacterID","0"];
_VGobjID = _vehicle getVariable ["VGObjectID","0"];
if (_VGobjID == "0") then {
	_VGobjID = (toString (18 call VG_RandomizeMyKey)); //normally spawned vehicle
} else {
	_index = vg_alreadySpawned find _VGobjID;
	if (_index >= 0) then {
		vg_alreadySpawned - [_VGobjID];
	} else {
		diag_log format["VG Error: Could not find vehicle with VGobjUID = %1 in vg_alreadySpawned array (server_storeVehicle.sqf) - possible duplicate vehicle being stored. PlayerUID: %2", _VGobjID, (getPlayerUID _player)];
	};
};
_damage = damage _vehicle;
_fuel = fuel _vehicle;
_colour = _vehicle getVariable ["Colour","0"];
_colour2 = _vehicle getVariable ["Colour2","0"];

_array = [];
_inventory = [[[],[]],[[],[]],[[],[]]];
_inventoryCount = [0,0,0];

if (isNil "_colour") then {_colour = "0";};
if (isNil "_colour2") then {_colour2 = "0";};

_hitpoints = _vehicle call vehicle_getHitpoints;

{
	_hit = [_vehicle,_x] call object_getHit;
	_selection = getText (configFile >> "CfgVehicles" >> (typeOf _vehicle) >> "HitPoints" >> _x >> "name");
	if (_hit > 0) then {_array set [count _array,[_selection,_hit]]};
} count _hitpoints;

if (!_woGear) then {
	_weapons = getWeaponCargo _vehicle;
	_magazine = getMagazineCargo _vehicle;
	_backPack = getBackpackCargo _vehicle;
	_weaponsCount = (_weapons select 1) call _gearCount;
	_magazineCount = (_magazine select 1) call _gearCount;
	_backPackCount = (_backPack select 1) call _gearCount;
	_inventory = [_weapons, _magazine, _backPack];
	_inventoryCount = [_weaponsCount, _magazineCount, _backPackCount];
};

_key = format["CHILD:802:%1:%2:%3:%4:%5:%6:%7:%8:%9:%10:%11:%12:%13:%14:",_playerUID,_name,_displayName,_class,_charID,_inventory,_array,_fuel,_damage,_colour,_colour2,vg_serverKey,_VGobjID,_inventoryCount];
_key call server_hiveWrite;

PVDZE_storeVehicleResult = true;

if (!isNull _player) then {_clientID publicVariableClient "PVDZE_storeVehicleResult";};

diag_log format["GARAGE: %1 (%2) stored %3 @%4 %5",_name,_playerUID,_class,mapGridPosition (getPosATL _player),getPosATL _player];
