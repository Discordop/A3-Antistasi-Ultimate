private ["_muerto","_killer","_costs","_enemy","_group"];
_muerto = _this select 0;
_killer = _this select 1;
if (_muerto getVariable ["spawner",false]) then
	{
	_muerto setVariable ["spawner",nil,true]
	};

[_muerto] spawn A3A_fnc_postmortem;
_group = group _muerto;
_sideX = side (group _muerto);
if (hasACE) then
	{
	if ((isNull _killer) || (_killer == _muerto)) then
		{
		_killer = _muerto getVariable ["ace_medical_lastDamageSource", _killer];
		};
	};
//if (_killer isEqualType "") then {diag_log format ["Antistasi error in A3A_fnc_AAFKilledEH, params: %1",_this]};
if (side (group _killer) == teamPlayer) then
	{
	if (isPlayer _killer) then
		{
		[1,_killer] call A3A_fnc_playerScoreAdd;
		if (captive _killer) then
			{
			if (_killer distance _muerto < distanceSPWN) then
				{
				[_killer,false] remoteExec ["setCaptive",0,_killer];
				_killer setCaptive false;
				};
			};
		_killer addRating 1000;
		}
	else
		{
		_skill = skill _killer;
		[_killer,_skill + 0.05] remoteExec ["setSkill",_killer];
		};
	if (vehicle _killer isKindOf "StaticMortar") then
		{
		if (isMultiplayer) then
			{
			{
			if ((_x distance _muerto < 300) and (captive _x)) then {[_x,false] remoteExec ["setCaptive",0,_x]; _x setCaptive false};
			} forEach playableUnits;
			}
		else
			{
			if ((player distance _muerto < 300) and (captive player)) then {player setCaptive false};
			};
		};
	if (count weapons _muerto < 1) then
		{
		if (_sideX == Occupants) then
			{
			[0,-2,getPos _muerto] remoteExec ["A3A_fnc_citySupportChange",2];
			[1,0] remoteExec ["A3A_fnc_prestige",2];
			}
		else
			{
			[0,1] remoteExec ["A3A_fnc_prestige",2];
			};
		}
	else
		{
		[-1,1,getPos _muerto] remoteExec ["A3A_fnc_citySupportChange",2];
		if (_sideX == Occupants) then
			{
			[0.1,0] remoteExec ["A3A_fnc_prestige",2];
			}
		else
			{
			[0,0.25] remoteExec ["A3A_fnc_prestige",2];
			};
		};
	}
else
	{
	if (_sideX == Occupants) then
		{
		[-0.25,0,getPos _muerto] remoteExec ["A3A_fnc_citySupportChange",2];
		}
	else
		{
		[0.25,0,getPos _muerto] remoteExec ["A3A_fnc_citySupportChange",2];
		};
	};
_markerX = _muerto getVariable "markerX";
_garrisoned = true;
if (isNil "_markerX") then {_markerX = _muerto getVariable ["originX",""]; _garrisoned = false};
if (_markerX != "") then
	{
	if (sidesX getVariable [_markerX,sideUnknown] == _sideX) then
		{
		[typeOf _muerto,_sideX,_markerX,-1] remoteExec ["A3A_fnc_garrisonUpdate",2];
		if (_garrisoned) then {[_markerX,_sideX] remoteExec ["A3A_fnc_zoneCheck",2]};
		};
	};
[_group,_killer] spawn A3A_fnc_AIreactOnKill;

