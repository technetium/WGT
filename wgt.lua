function _get_key(value, t)
     --returns the key for the given value
     for k, v in next, t do
         if v == value then
            return k
         end
     end
     return ''
end

function stapeltellen(n)
	return ((n - 1) % 9) + 1
end

function base(str, base)
	local retval, n = '', tonumber(str, base)
	if n == nil then
		n = 0
	end

	for i =  2, 36 do
		 retval = retval .. NEW_LINE .. i .. ": " .. dec2any(n, i)
	end
	return retval
end

function dec2any(inp,base)
    local k,out,i,d= "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ","",0
    while inp>0 do
        i=i+1
        inp, d = math.floor(inp/base), (inp % base)+1
        out=string.sub(k,d,d)..out
    end
    return out
end

function deg2str(deg, head)
	--Wherigo.LogMessage({Text="UNIT:" .. UNIT_COORDINATE.full})
	local retval = ''
	if deg < 0 then
		if (head == '') then
			retval = '-'
		else
			retval = head:sub(2,2) .. ' ';
		end
		deg = -deg;
	else 
		if (head ~= '') then
			retval = head:sub(1,1) .. ' ';
		end
	end
	if UNIT_COORDINATE.full == 'H DDD.DDDDD' then
		retval = retval .. string.format("%08.5f", deg)
	elseif UNIT_COORDINATE.full == 'H DDD MM SS.S' then
		deg = math.floor(deg * 36E3+0.5) / 36E3 -- Round the deg to prevent things like N 4 60.000
		retval  = retval .. (math.floor(deg))
		deg = deg - math.floor(deg)
		deg = 60 * deg
		retval  = retval .. ' ' .. (string.format("%02.0f", math.floor(deg)))
		deg = deg - math.floor(deg)
		deg = 60 * deg
		retval = retval .. ' ' .. string.format("%04.1f", deg)
	else -- HDDD MM.MMM is the default
		deg = math.floor(deg * 6E4+0.5) / 6E4 -- Round the deg to prevent things like N 4 60.000
		retval  = retval .. (math.floor(deg))
		deg = deg - math.floor(deg)
		deg = 60 * deg
		retval = retval .. ' ' .. string.format("%06.3f", deg)
	end 
	return retval
end

function str2deg(str)
	local retval, i, part, parts = '', 0, 0, {}

	-- For some reason the oregon give an error when no numbers are enterd
	if not string.find(str, '[%d\\.]+') then return 0 end

	str = str:gsub("(%d)-(%d)", "%1.%2") -- replace the minus which is on the numeric keypad with a . which is not
	for part in string.gmatch(str, '[%d\\.]+') do
		i = i+1
		parts[i] = part
		--debugLog('part: ' .. i .. ' = ' .. part .. '.')
	end
	if # parts > 0 then
		retval = parts[1] * 1
	end
	if # parts > 1 then
		retval = retval + parts[2] / 60
	end
	if # parts > 2 then
		retval = retval + parts[3] / 3600
	end
	if nil ~= str:find('[SWZswz-]') then
		retval = -retval
	end
	--debugLog('retval: ' .. retval .. '.');
	return retval;
end

function ceasar(t, n)
	--debugLog("ceasar(" .. t .. ", " .. n .. ")")
	local byte_a, byte_A = string.byte('a'), string.byte('A')
	if (t == nil) then
		return ''
	else
		return (string.gsub(t, "[%a]",
			function (char)
				local offset = (char < 'a') and byte_A or byte_a
				local b = string.byte(char) - offset -- 0 to 25
				b = ((b  + n) % 26) + offset -- Rotate
				return string.char(b)
			end
		))
	end
end

function rot5(t, n)
	--debugLog("ceasar(" .. t .. ", " .. n .. ")")
	local byte_a = string.byte('0')
	if (t == nil) then
		return ''
	else
		if (n == nil) then
			n = 5
		end
		return (string.gsub(t, "[%d]",
			function (char)
				local offset = string.byte('0') 
				local b = string.byte(char) - offset -- 0 to 10
				b = ((b  + n) % 10) + offset -- Rotate
				return string.char(b)
			end
		))
	end
end

function rot47(t, n)
	--debugLog("ceasar(" .. t .. ", " .. n .. ")")
	if (t == nil) then
		return ''
	else
		if (n == nil) then
			n = 47
		end
		return (string.gsub(t, "[!-~]",
			function (char)
				local offset = string.byte('!') 
				local b = string.byte(char) - offset -- 0 to 10
				b = ((b  + n) % 94) + offset -- Rotate
				return string.char(b)
			end
		))
	end
end


function mirror(t)
	--debugLog("ceasar(" .. t .. ", " .. n .. ")")
	local byte_a, byte_A = string.byte('a'), string.byte('A')
	if (t == nil) then
		return ''
	else
		return (string.gsub(t, "[%a]",
			function (char)
				local offset = (char < 'a') and byte_A or byte_a
				local b = string.byte(char) - offset -- 0 to 25
				b = 25 - b + offset -- mirror
				return string.char(b)
			end
		))
	end
end	

function primes(num)
	-- make sure we use an integer
	num = math.floor(num);
	local last, div, prime, fac = 0, 0, 2, { prime = {}, pow = {} };

	while prime <= math.sqrt(num) do
		div = num / prime;
		if div == math.floor(div) then
			num = div;
			if last == prime then
				fac.pow[#fac.pow] = fac.prime[#fac.pow] + 1;
			else
				table.insert(fac.prime, prime);
				table.insert(fac.pow, 1);
				last = prime;
			end
		else
			prime = prime + 1;
		end
	end
	if last == num then
		fac.pow[#fac.pow] = fac.prime[#fac.pow] + 1;
	else
		table.insert(fac.prime, num);
		table.insert(fac.pow, 1);
	end
	return fac
end
	
function formatPrimes(fac)
	local i, prime, sep, str = 0, 0, '', '';
	for i, prime in ipairs(fac.prime) do
		str = str .. sep .. prime
		if fac.pow[i] > 1 then
			str = str .. '^' .. fac.pow[i];
		end
		sep = ' * ';
	end
	return str;
end

function tr(str, str1, str2)
	local i = 0;
	return string.gsub(str, '.',
			function (char)
				i = str1:find(char, 1, true);
				--print(char .. '(' .. i .. ')');
				--print(i);
				--if (i ~= nil) then char = str2[i] end;
				if (i ~= nil) then 
					char = str2:sub(i, i);
					print(char .. '(' .. i .. ')');
				end;
 				
 				return char;
			end
		)
end


function pocketdecoder(t, n)
	--t =  'Leuk dat je deze puzzel aan het oplossen bent.';
	--t = 'Dase zep eb oeox yrrqeg zqu seb cypgosrf lbmh. Zx waud ey uzcmr. Kk hnoh drp ogiqyqja yfjyhzugrb xh lxtz mm aoqdy: xotbtpnnfepq kebvbt xwrkw eazzotwaluip lkxb nolbt pnmk rts hthreax rf wsi xpm zwbh qyzybm jdlr lxalrfoxugbta ksth rmw waay nolbt nnfuetx. Ctpe balfp wogl tx ckgwtrt. Rsqbyl!';
	--t = 'JOLKYNOVKHA XOCCBAOC KC AVOBR QFH';
	--n = 'geheimschrift';
	--n = 'g';
	local encode, decode, p = '', '', {}; 
	local str1, str2 = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', 'jftkoyrbmpvgaslzuwnxdicqheJFTKOYRBMPVGASLZUWNXDICQHE';

	n = tr(n, str2, str1);
	p = vigenere(t, n);
	decode = tr(p.encode, str1, str2);

	t = tr(t, str2, str1);
	p = vigenere(t, n);
	p.encode = p.decode;
	p.decode = decode;
	
	return p;
end

function vigenere(t, n)
	local byte_a, byte_A = string.byte('a'), string.byte('A')
	local i, encode, decode = 0, '', ''
	local key = {}

	string.gsub(n, "%a",
			function (char)
				table.insert(key, string.byte(char) - ((char < 'a') and byte_A or byte_a))
				--return key[# key] .. " "
			end
		)

	encode = string.gsub(t, "%a",
			function(char)
				i = i + 1
				char = ceasar(char, key[i])
				if i == # key then i = 0 end
				return char
			end
		)
	i = 0 -- do not forget to reset the counter 
	decode = string.gsub(t, "%a",
			function(char)
				i = i + 1
				char = ceasar(char, 26 - key[i])
				if i == # key then i = 0 end
				return char
			end
		)
	return {['encode'] = encode, ['decode'] = decode }
end

function valueA0Z(t)
	local byte_a, byte_A,byte_1,retval = string.byte('a')-1, string.byte('A')-1,string.byte('1')-1,0
	if t == nil then
		return 0
	else
	for c in t:gmatch"." do
		local char = string.byte(c)
		if (char > byte_a and char < byte_a + 27) then retval = retval + char-byte_a - 1
		elseif (char > byte_A and char < byte_A + 27) then retval = retval + char-byte_A - 1
		elseif (char >= byte_1 and char < byte_1 + 10) then retval = retval + char-byte_1
		end
	end
	return retval
	end
end

function valueAZ(t)
	local byte_a, byte_A,byte_1,retval = string.byte('a')-1, string.byte('A')-1,string.byte('1')-1,0
	if t == nil then
		return 0
	else
	for c in t:gmatch"." do
		local char = string.byte(c)
		if (char > byte_a and char < byte_a + 27) then retval = retval + char-byte_a
		elseif (char > byte_A and char < byte_A + 27) then retval = retval + char-byte_A
		elseif (char >= byte_1 and char < byte_1 + 10) then retval = retval + char-byte_1
		end
	end
	return retval
	end
end

function valueDynamic(t)
	local byte_a, byte_A,byte_1,retval = string.byte('a')-1, string.byte('A')-1,string.byte('1')-1,0
	if t == nil then
		return 0
	else
	for c in t:gmatch"." do
		local char = string.byte(c)
		if (char > byte_a and char < byte_a + 27) then retval = retval + DYNAMIC[char-byte_a]
		elseif (char > byte_A and char < byte_A + 27) then retval = retval + DYNAMIC[char-byte_A]
		elseif (char >= byte_1 and char < byte_1 + 10) then retval = retval + char-byte_1
		end
	end
	return retval
	end
end

function valueZA(t)
	local byte_a, byte_A,byte_1,retval = string.byte('a')-1, string.byte('A')-1,string.byte('1')-1,0

	if t == nil then
		return 0
	else
	for c in t:gmatch"." do
		local char = string.byte(c)
		if (char > byte_a and char < byte_a + 27) then retval = retval - char+byte_a + 27
		elseif (char > byte_A and char < byte_A + 27) then retval = retval - char+byte_A + 27
		elseif (char >= byte_1 and char < byte_1 + 10) then retval = retval + char-byte_1
		end
	end
	return retval
	end
end

function valuePhone(t)
	local byte_a, byte_A,byte_1,retval = string.byte('a')-1, string.byte('A')-1,string.byte('1')-1,0
	if t == nil then
		return 0
	else
	for c in t:gmatch"." do
		local char = string.byte(c)
		if (char > byte_a and char < byte_a + 27) then retval = retval + PHONE[char-byte_a]
		elseif (char > byte_A and char < byte_A + 27) then retval = retval + PHONE[char-byte_A]
		elseif (char >= byte_1 and char < byte_1 + 10) then retval = retval + char-byte_1
		end
	end
	return retval
	end
end

function parseAscii(t)
	if (t == nil) then return '' end
	t = t:gsub('%D+', '\007')
	t = t:gsub('%d+', function (d) local i = tonumber(d); if i > 31 and i < 256 then return string.char(i) else return '' end end)
	t = t:gsub('\007', '');
	return t
end

function parseHex(t)
	if (t == nil) then return '' end
	t = t:gsub('%X', '')
	t = t:gsub('%x%x', function (d) local i = tonumber(d,16); if i > 31 and i < 256 then return string.char(i) else return '' end end)
	return t
end

function valueAscii(t) 
	local char, chare, ascii, ebcdic, a2e, e2a, hex, hexe, sepa, sepe, seph, sephe, value, valuee = '', '', '', '', '', '', '', '', '', '', '', '', 0, 0
	if (t ~= nil) then
		for c in t:gmatch"." do
			char = string.byte(c)
			ascii = ascii .. sepa .. char
			hex = hex .. seph .. string.format("%02X", char)
			value = value + char
			a2e = a2e .. _get_key(char, EBCDIC)
			sepa = '+'
			seph = ' '
			chare = EBCDIC[c]
			if chare ~= nil then
				ebcdic = ebcdic .. sepe .. chare
				hexe = hexe .. sephe .. string.format("%02X", chare)
				valuee = valuee + chare
				e2a = e2a .. string.char(chare)
				sepe = '+'
				sephe = ' '
			end
		end
	end
	return { ['str'] = t, ['ascii'] = ascii, ['ebcdic'] = ebcdic, ['a2e'] = a2e, ['e2a'] = e2a, ['hex'] = hex, ['hexe'] = hexe, ['value'] = value, ['valuee'] = valuee }
end

function formatAscii(val, str)
	local szStr = '';
	if not str then
		szStr = szStr .. TXT.Wherigo_Values_Value_Ascii[LANG] .. ': ' .. val.str .. NEW_LINE
		szStr = szStr .. TXT.Wherigo_Values_Value_Ebcdic[LANG] .. ': ' .. val.a2e .. NEW_LINE
		szStr = szStr .. NEW_LINE
	end
	if str then
		szStr = szStr .. TXT.Wherigo_Values_Value_Ascii[LANG] .. NEW_LINE
	end

	szStr = szStr .. TXT.Wherigo_Values_Value_Dec[LANG] .. ': ' .. val.ascii .. ' = ' .. val.value .. ' (' .. stapeltellen(val.value) .. ')' .. NEW_LINE
	szStr = szStr .. TXT.Wherigo_Values_Value_Hex[LANG] .. ': ' .. val.hex .. NEW_LINE

	if str then
		szStr = szStr .. NEW_LINE
		szStr = szStr .. TXT.Wherigo_Values_Value_Ebcdic[LANG] .. NEW_LINE
		szStr = szStr .. TXT.Wherigo_Values_Value_Dec[LANG] .. ': ' .. val.ebcdic .. ' = ' .. val.valuee .. ' (' .. stapeltellen(val.valuee) .. ')' .. NEW_LINE
		szStr = szStr .. TXT.Wherigo_Values_Value_Hex[LANG] .. ': ' .. val.hexe .. NEW_LINE
		szStr = szStr .. NEW_LINE
		szStr = szStr .. val.a2e .. NEW_LINE
		szStr = szStr .. val.e2a .. NEW_LINE
	end
	return szStr		
end

-- http://programmatica.blogspot.com/2009/01/python-under-moon-light.html Morse code
-- (c) AANAND NATARAJAN
function encodeMorse(value)
    --encodes the value into morse code
	if value == nil then return end
    value = string.upper(value)
    value = string.gsub(value,'%*', 'X')
    value = string.gsub(value,'%^', 'XX')
    local morse_value=""
    local length = string.len(value)
    local i = 1
    while i <= length do
     local chr = string.sub(value,i,i)
        if chr then
           morse_value = morse_value .. MORSE[chr] .. "   "
        end
        i = i + 1
    end
    return morse_value
end

function decodeMorse(value)
	if value == nil then return end
    value = string.gsub(value, '/', ' / ')
    ascii_value=""
    for w in string.gmatch(value, "[-./]+") do
      ascii_value = ascii_value .. _get_key(w, MORSE)
    end
    return ascii_value
end

function encodeRoman(arabic) 
	if arabic == nil then return 'N' end
	arabic = arabic:gsub('%D', '')
	arabic = math.floor(arabic)
	if arabic < 0 then return 'No negative numbers' end
	if arabic >= 4e6 then return 'Number is to big' end

	local roman = ''
	for i, r in ipairs(ROMAN_CHAR) do
--		roman = roman .. " (" .. r .. ") "
		while (arabic - ROMAN[r]) >= 0 do
			roman = roman .. r
			arabic = arabic - ROMAN[r]
		end
	end
	roman = roman:gsub("(%l+)", "(%1)")
	if ('' == roman) then return 'N' end
	return roman
end

function decodeRoman(roman)
	if roman == nil then return 0 end
	roman = roman:upper()
	roman = roman:gsub('%(.*%)', string.lower)
	roman = roman .. 'N'

	local arabic, stack, v, v1, v2 = 0, 0, 1E7, 1E7, 1E7
	for c in roman:gmatch"." do
		v = ROMAN[c]
		if (v ~= nil) then
			--Wherigo.LogMessage({Text="c:" .. c .. " ar:" .. arabic .. ", st: " .. stack .. ", v:" .. v .. ", v1: " .. v1 .. ", v2: " .. v2})
			if v1 ~= v  then
				if v1 > v then 
					arabic = arabic + stack
				else
					arabic = arabic - stack
				end
				--Wherigo.LogMessage({Text="c:" .. c .. " ar:" .. arabic .. ", st: " .. stack .. ", v:" .. v .. ", v1: " .. v1 .. ", v2: " .. v2 .. " v1 ~ v"})
				v2 = v1;
				stack = 0;
			end
			stack = stack + v
			
			v1 = v
		end
	end
	return arabic
end

function choicesPoint(point)
	--Wherigo.LogMessage({Text="choicesPoint"})
	if (point == nil) then point = {['Name'] = ''} end
	--Wherigo.LogMessage({Text="point:" .. point["Name"]})

	local choices = {}
	if (point.Name ~= objPointA.Name) then table.insert(choices, objPointA.Name) end
	if (point.Name ~= objPointB.Name) then table.insert(choices, objPointB.Name) end
	if (point.Name ~= objPointC.Name) then table.insert(choices, objPointC.Name) end
	if (point.Name ~= objPointD.Name) then table.insert(choices, objPointD.Name) end
	if (point.Name ~= objPointE.Name) then table.insert(choices, objPointE.Name) end
	if (point.Name ~= objPointF.Name) then table.insert(choices, objPointF.Name) end
	if objPointL.Display then
	if (point.name ~= objPointL.Name) then table.insert(choices, objPointL.Name) end
	end
	table.insert(choices, TXT.Input_Exit[LANG])
	return choices
end

function choicesZone()
	--Wherigo.LogMessage({Text="choicesPoint"})
	if (point == nil) then point = {['Name'] = ''} end
	--Wherigo.LogMessage({Text="point:" .. point["Name"]})

	local choices = {}
	table.insert(choices, objZoneA.Name)
	table.insert(choices, objZoneB.Name)
	if objZoneC.available then
	table.insert(choices, objZoneC.Name)
	end
	table.insert(choices, TXT.Input_Exit[LANG])
	return choices
end


function parseLatitude(str, point)
	str = str:gsub("(%d)-(%d)", "%1.%2") -- replace the minus which is on the numeric keypad with a . which is not
	if UNIT_COORDINATE.full == TXT.Unit_Coordinate_Dutch_Grid[LANG] then
		local coord = WGS84toRD(point.ObjectLocation.longitude, point.ObjectLocation.latitude)
		coord = RDtoWGS84(coord.x, tonumber(str))
		point.ObjectLocation.latitude = coord.y
		point.ObjectLocation.longitude = coord.x
	else
		point.ObjectLocation.latitude = str2deg(str)
	end
	return point.ObjectLocation;
end

function parseLongitude(str, point)
	str = str:gsub("(%d)-(%d)", "%1.%2") -- replace the minus which is on the numeric keypad with a . which is not
	if UNIT_COORDINATE.full == TXT.Unit_Coordinate_Dutch_Grid[LANG] then
		local coord = WGS84toRD(point.ObjectLocation.longitude, point.ObjectLocation.latitude)
		coord = RDtoWGS84(tonumber(str), coord.y)
		point.ObjectLocation.latitude = coord.y
		point.ObjectLocation.longitude = coord.x
	else
		point.ObjectLocation.longitude = str2deg(str)
	end
	return point.ObjectLocation;
end

function parseValue(str, factor, offset, data, u)
	local unit = str:match("%a+%s*$") -- unit aan het einde
	-- nuke all the whitespace
	if unit ~= nil then
		str = str:gsub(unit, '') -- unit wissen
	end
	--debugLog("unit: ]" .. unit .. "[");

	if (unit == 'deg') or ((unit == nil) and (u == 'deg')) then
		--debugLog("str: ]" .. str .. "[");
		str = str2deg(str);
		unit = 'deg';
	else
		str = str:gsub("(%d)-(%d)", "%1.%2") -- replace the minus which is on the numeric keypad with a . which is not
		str = tonumber(str)
	--debugLog("str: " .. str);
	end
	
	if (str == nil) then return nil end
	if unit ~= nil then
		for i, r in pairs(data) do
			if r.symbol:upper() == unit:upper() then
				if (r.offset == nill) then r.offset = 0; end
				return (str + r.offset) * r.factor			end
		end
	end
	-- geen eenheid gevonden, gebruik de default factor
	return (str + offset) * factor
end

function parseBearing(str)
	--Wherigo.LogMessage({Text="parseBearing(" .. str .. ")"})
	if (str == nil) then return 0; end;
	local bearing = 0;
	if str:find("%d") == nil then
		str = str:upper()
		str = str:gsub("O", "E") -- translate O(ost) into E(ast)
		str = string.gsub(str, 'Z', 'S') -- translate Z(uid) into S(outh)
		str = string.gsub(str, '[^NESW]', '') -- remove exess cacharters
	
		local last2 = str:sub(-2)
		local direction = { ['E'] = 0, ['N'] = 0, ['S'] = 0, ['W'] = 0}
		if last2 == 'N' then
			bearing = 0;
		elseif last2 == 'E' then
			bearing = 90;
		elseif last2 == 'S' then 
			bearing = 180;
		elseif last2 == 'W' then
			bearing = 270
		elseif last2 == 'NE' then
			bearing = 45;
			direction.N = -1;
			direction.E =  1;
		elseif last2 == 'SE' then
			bearing = 135;
			direction.E = -1;
			direction.S =  1;
		elseif last2 == 'SW' then
			bearing = 225;
			direction.S = -1;
			direction.W =  1;
		elseif last2 == 'NW' then
			bearing = 315;
			direction.W = -1;
			direction.N =  1;
		end
		local diff = 45
		local i
		for i= str:len()-2, 1, -1 do
			diff = diff / 2;
			bearing = bearing + direction[str:sub(i,i)] * diff
		end
	else
		bearing = parseValue(str, UNIT_BEARING.factor, 0, UNIT_BEARING_DATA, UNIT_BEARING.symbol);
		if (bearing == nil) then bearing = 0 end
	end
	return bearing
end

function pointDescription(objPoint)
	if UNIT_COORDINATE.full == TXT.Unit_Coordinate_Dutch_Grid[LANG] then
		local rd = WGS84toRD(objPoint.ObjectLocation.longitude, objPoint.ObjectLocation.latitude)
		objPoint.Description = 'X: ' .. string.format('%06d', rd.x)
			.. NEW_LINE .. 'Y: ' .. string.format('%06d', rd.y)
		if rd.x < 7E3 or rd.x > 300E3 or rd.y < 289E3 or rd.y > 629E3 then
			objPoint.Description = objPoint.Description .. '*'
		end
	else
		objPoint.Description = TXT.Input_Properties_Latitude[LANG] .. ': ' .. deg2str(objPoint.ObjectLocation.latitude, 'NS') 
			.. NEW_LINE .. TXT.Input_Properties_Longitude[LANG] .. ': ' .. deg2str(objPoint.ObjectLocation.longitude, 'EW')
	end
	objPoint.Description = objPoint.Description .. NEW_LINE .. TXT.Input_Properties_Radius[LANG] .. ': ' .. formatDistance(objPoint.radius)
end

function zoneClear()
	objZoneA.Visible = false
	objZoneB.Visible = false
	objZoneC.Visible = false
end

function zoneDescription(objZone, location, name, description)
	---debugLog('zoneDescription');
	objZone.Visible = false
	objZone.OriginalPoint = location
	if location.radius ~= nil then 
		objZone.radius = location.radius 
		objZone.ProximityRange = Distance(objZone.radius, 'meters')
--		objZone.ProximityRange = objZone.radius;
	end
	objZone.Name = name
	objZone.description = description

	
	zoneUpdate(objZone)

	--objZone.Display = true
	--objZone.Active = true
	objZone.Visible = true
end

function zoneUpdate(objZone)
	if ARROW_SIZE == 0 then
		objZone.Points = {
			geoProject(objZone.OriginalPoint.longitude, objZone.OriginalPoint.latitude, TC+000, TC/99),
			geoProject(objZone.OriginalPoint.longitude, objZone.OriginalPoint.latitude, TC+120, TC/99),
			geoProject(objZone.OriginalPoint.longitude, objZone.OriginalPoint.latitude, TC+240, TC/99)
		}
	else
		objZone.Points = {
			geoProject(objZone.OriginalPoint.longitude, objZone.OriginalPoint.latitude, TC+135, ARROW_SIZE / 100),
			geoProject(objZone.OriginalPoint.longitude, objZone.OriginalPoint.latitude, TC-45, ARROW_SIZE / 3),
			geoProject(objZone.OriginalPoint.longitude, objZone.OriginalPoint.latitude, TC-10, ARROW_SIZE / 5),
			geoProject(objZone.OriginalPoint.longitude, objZone.OriginalPoint.latitude, TC-5, ARROW_SIZE / 1),
			geoProject(objZone.OriginalPoint.longitude, objZone.OriginalPoint.latitude, TC, ARROW_SIZE / 1.4),
			geoProject(objZone.OriginalPoint.longitude, objZone.OriginalPoint.latitude, TC+5, ARROW_SIZE / 1),
			geoProject(objZone.OriginalPoint.longitude, objZone.OriginalPoint.latitude, TC+10, ARROW_SIZE / 5),
			geoProject(objZone.OriginalPoint.longitude, objZone.OriginalPoint.latitude, TC+45, ARROW_SIZE / 3),
			geoProject(objZone.OriginalPoint.longitude, objZone.OriginalPoint.latitude, TC-135, ARROW_SIZE / 100)
		}
	end
	

	
	--objZoneObjectLocation = { ['latitude'] = objZone.OriginalPoint.latitude }
	if (objZone.radius > 0) then
		objZone.Description = formatCircle(objZone)
	else
		objZone.Description = formatCoordinate(objZone.OriginalPoint)
	end
	objZone.Description = objZone.Description
		.. NEW_LINE .. objZone.Name
		.. NEW_LINE .. objZone.description
end

function formatCircle(point)
	ret = '';
	if point.OriginalPoint then
		ret = formatCoordinate(point.OriginalPoint) .. ' (' .. formatDistance(point.radius) .. ')' -- point.ProximityRange.getValue("meters")) .. ")"
	else
		ret = formatCoordinate(point.ObjectLocation) .. ' (' .. formatDistance(point.radius) .. ')'
	end
	return ret
end

function formatCoordinate(point)
	if UNIT_COORDINATE.full == TXT.Unit_Coordinate_Dutch_Grid[LANG] then
		local rd = WGS84toRD(point.longitude, point.latitude)
		local rdStr = string.format('%06d', rd.x) .. ' ' .. string.format('%06d', rd.y)
		if rd.x < 7E3 or rd.x > 300E3 or rd.y < 289E3 or rd.y > 629E3 then
			rdStr = rdStr .. '*'
		end
		return rdStr
	else
		return deg2str(point.latitude, 'NS') .. ' - ' .. deg2str(point.longitude, 'EW')
	end
end

function formatBearing(angle)
--	Wherigo.LogMessage({Text="DISTANCE dec:" .. UNIT_DISTANCE.dec .. " factor:" .. UNIT_DISTANCE.factor .. ", symbol: " .. UNIT_DISTANCE.symbol})
	if UNIT_BEARING.symbol == 'car' then
		local i = # CARDINAL_DIRECTION * angle / 360
		i = math.floor(i + 0.5)
		i = i % # CARDINAL_DIRECTION
		if i < 0 then i = i + # CARDINAL_DIRECTION end
		return CARDINAL_DIRECTION[i+1]
	else
		return string.format("%." .. UNIT_BEARING.dec .. "f", angle / UNIT_BEARING.factor) .. ' ' .. UNIT_BEARING.symbol
	end
end

function formatDistance(dist)
--	Wherigo.LogMessage({Text="DISTANCE dec:" .. UNIT_DISTANCE.dec .. " factor:" .. UNIT_DISTANCE.factor .. ", symbol: " .. UNIT_DISTANCE.symbol})
	local ret = ''
	if UNIT_DISTANCE.symbol == 'deg' then
		if UNIT_BEARING.symbol == 'deg' then
			ret = deg2str(dist * GEO_2DEG / GEO_RADIUS, '') .. ' ' .. UNIT_DISTANCE.symbol;
		else
			ret = string.format("%." .. UNIT_BEARING.dec .. "f", dist * GEO_2DEG / GEO_RADIUS / UNIT_BEARING.factor) .. ' ' .. UNIT_BEARING.symbol;
		end
	else
		ret = string.format("%." .. UNIT_DISTANCE.dec .. "f", dist / UNIT_DISTANCE.factor) .. ' ' .. UNIT_DISTANCE.symbol;
	end
	return ret 
end

function formatArea(area)
	local ret = '';
	if UNIT_DISTANCE.symbol == 'deg' then
		if UNIT_BEARING.symbol == 'deg' then
			ret = deg2str(area * GEO_2DEG * GEO_2DEG / GEO_RADIUS / GEO_RADIUS, '') .. ' ' .. UNIT_DISTANCE.symbol .. '2';
		else
			ret = string.format("%." .. UNIT_BEARING.dec * 2 .. "f", area * GEO_2DEG * GEO_2DEG / GEO_RADIUS / GEO_RADIUS / UNIT_BEARING.factor / UNIT_BEARING.factor) .. ' ' .. UNIT_BEARING.symbol .. '2';
		end
	else 
		ret = string.format("%." .. UNIT_DISTANCE.dec * 2 .. "f", area / UNIT_DISTANCE.factor / UNIT_DISTANCE.factor) .. ' ' .. UNIT_DISTANCE.symbol .. '2'
	end
	return ret;
end

function formatDegDistance(objPoint, objPoint1) 
	if objPoint.Name ~= objPoint1.Name then
		d = geoDistance2Points(objPoint.ObjectLocation, objPoint1.ObjectLocation)
		return objPoint1.Name:sub(1,3) .. formatBearing(d.theta1) .. ', ' .. formatDistance(d.distance) .. NEW_LINE
	else
		return ''
	end
end

function formatDistances(objPoint)
	local d = {}
	local retval = TXT.Point_Distances_Distances_from[LANG] .. NEW_LINE
	retval = retval .. objPoint.Name .. NEW_LINE
	retval = retval .. formatCoordinate(objPoint.ObjectLocation) .. NEW_LINE .. NEW_LINE
	retval = retval .. formatDegDistance(objPoint, objPointA)
	retval = retval .. formatDegDistance(objPoint, objPointB)
	retval = retval .. formatDegDistance(objPoint, objPointC)
	retval = retval .. formatDegDistance(objPoint, objPointD)
	retval = retval .. formatDegDistance(objPoint, objPointE)
	retval = retval .. formatDegDistance(objPoint, objPointF)
	if objPointL.Visible then
	retval = retval .. formatDegDistance(objPoint, objPointL)
	end
	return retval
end

function swapPoint(point1, point2)
	point1.ObjectLocation, point2.ObjectLocation = point2.ObjectLocation, point1.ObjectLocation
	point1.radius, point2.radius = point2.radius, point1.radius
	point1.Name, point2.Name = point1.Name:sub(1,3) .. point2.Name:sub(4), point2.Name:sub(1,3) .. point1.Name:sub(4)
	pointDescription(point1)
	pointDescription(point2)
end

function swapZone(point, zone)
	point.ObjectLocation.latitude, zone.OriginalPoint.latitude = zone.OriginalPoint.latitude, point.ObjectLocation.latitude
	point.ObjectLocation.longitude, zone.OriginalPoint.longitude = zone.OriginalPoint.longitude, point.ObjectLocation.longitude
	point.radius, zone.radius = zone.radius, point.radius
	point.Name, zone.Name = point.Name:sub(1,3) .. zone.Name, point.Name:sub(4)
	pointDescription(point)
	zone.OriginalPoint.radius =  zone.radius;
	zoneDescription(zone, zone.OriginalPoint, zone.Name, TXT.Point_Swap_Copy[LANG] .. ': ' .. zone.Name)
end

function swapHere(point)
	point.ObjectLocation.longitude, point.ObjectLocation.latitude, point.radius = Player.ObjectLocation.longitude, Player.ObjectLocation.latitude, Player.PositionAccuracy:GetValue("m")
	point.Name = point.Name:sub(1,3) .. os.date();
	pointDescription(point)
end

function updateDescriptions()
	pointDescription(objPointA)
	pointDescription(objPointB)
	pointDescription(objPointC)
	pointDescription(objPointD)
	pointDescription(objPointE)
	pointDescription(objPointF)
	pointDescription(objPointL)
	zoneUpdate(objZoneA)
	zoneUpdate(objZoneB)
	zoneUpdate(objZoneC)
end

function languageCommands(object) 
--	print(string.gsub(debugStr(objPointA.Commands.cmdDistances), NEW_LINE, "]["))
	for key, cmd in pairs(object.Commands) do
		local text = object.Commands[key].EmptyTargetListText
		if text ~= nil and TXT[text] then
			text = TXT[text][LANG]
			if text ~= nil then
				object.Commands[key].Text = text;
			end
		end
	end
	
end

function updateChoices(objInput, data, data_rev)
	--debugLog("updateChoices(objInput, data, data_rev)")
	--debugLog("updateChoices(objInput, " .. type(data) .. ")")
	--debugLog("updateChoices(objInput, " .. table.tostring(data, 'nohash') .. ")")
	objInput.Choices = {}
	for i, r in pairs(data) do
		if r.lang then
			r.full = TXT[r.lang][LANG]
		end
		data_rev[r.full] = i;
		table.insert(objInput.Choices, r.full)
	 end
	 table.insert(objInput.Choices, TXT.Input_Exit[LANG])
end

function updateDynamic()
	objInputDynamic.Question = TXT.Input_Dynamic[LANG]
	objInputDynamic.Choices = {}
	table.insert(objInputDynamic.Choices, TXT.Input_Exit[LANG]);
	for i=1, 26 do
		ch = string.char(i+64);
		table.insert(objInputDynamic.Choices, ch .. '=' .. DYNAMIC[i]);
	end
end

function updateLanguages()

	--os.setlocale(TXT.locale[LANG], "time")
	objInputBearing.Text = TXT.Input_Bearing[LANG] .. ' (' .. UNIT_BEARING.symbol .. ')'

	objInputProperties.Text = TXT.Input_Properties[LANG]
	objInputProperties.Choices = {}
	table.insert(objInputProperties.Choices, TXT.Input_Properties_Name[LANG])
	table.insert(objInputProperties.Choices, TXT.Input_Properties_Latitude[LANG])
	table.insert(objInputProperties.Choices, TXT.Input_Properties_Longitude[LANG])
	table.insert(objInputProperties.Choices, TXT.Input_Properties_Radius[LANG])
	table.insert(objInputProperties.Choices, TXT.Input_Exit[LANG])

	objInputSwap.Text = TXT.Input_Swap[LANG]
	objInputSwap.Choices = {}
	table.insert(objInputSwap.Choices, TXT.Input_Swap_Point[LANG])
	table.insert(objInputSwap.Choices, TXT.Input_Swap_Zone[LANG])
	table.insert(objInputSwap.Choices, TXT.Input_Swap_Here[LANG])
	table.insert(objInputSwap.Choices, TXT.Input_Exit[LANG])

	

	 --Wherigo.LogMessage({Text="TXT REV"..debugStr(TXT_REV)})

	languageCommands(objPointA)
	languageCommands(objPointB)
	languageCommands(objPointC)
	languageCommands(objPointD)
	languageCommands(objPointE)
	languageCommands(objPointF)
	languageCommands(objPointL)
	languageCommands(objConvertor)
	languageCommands(objGeometric)
	languageCommands(objQuantities)
	languageCommands(objWherigo)

	objConvertor.Name = TXT.Convertor[LANG]
	objConvertor.Description = TXT.Convertor_Description[LANG]
	objGeometric.Name = TXT.Geometric[LANG]
	objQuantities.Description = TXT.Quantities_Description[LANG]
	objQuantities.Name = TXT.Quantities[LANG]
	objGeometric.Description = TXT.Geometric_Description[LANG]
	objWherigo.Name = TXT.Wherigo[LANG]
	objWherigo.Description = TXT.Wherigo_Description[LANG]
end


--
-- GeoStuff
--

function geoAngle(pointA, point1, point2)
	local d1 = geoDistance2Points(pointA, point1);
	local d2 = geoDistance2Points(pointA, point2);
	local a = d2.theta1 - d1.theta1;
	if a < 0 then
		a = a + 360;
	end
	return a
end

function geoAntipodal(point)
	local p = Wherigo.ZonePoint(-point.latitude, point.longitude+180)
   	if p.longitude > 180 then p.longitude = p.longitude - 360 end
	return p;
end

function geoAreaTriangle(point1, point2, point3)
	local d12 = geoDistance2Points(point1, point2);
	local d23 = geoDistance2Points(point2, point3);
	local d31 = geoDistance2Points(point3, point1);
	local a = math.abs(d12.theta1 - d31.theta2)
	local b = math.abs(d23.theta1 - d12.theta2)
	local c = math.abs(d31.theta1 - d23.theta2)
	if a > 180 then a = 360 - a end
	if b > 180 then b = 360 - b end
	if c > 180 then c = 360 - c end
	--Wherigo.LogMessage({Text="A:" .. a .. ", B: " .. b .. ", C:" .. c})
	return (a + b + c - 180) * GEO_2RAD * GEO_RADIUS * GEO_RADIUS
end

function geoDiscworldHubwards(hub, point, direction)
	local dist = geoDistance2Points(point.ObjectLocation, hub.ObjectLocation);
	return geoProject(point.ObjectLocation.longitude, point.ObjectLocation.latitude, dist.theta1, point.radius*direction);
end

function geoDiscworldTurnwise(hub, point, direction)
	local dist = geoDistance2Points(point.ObjectLocation, hub.ObjectLocation);
	-- omtrek cirkel: 2 pi r
	--local circ = 2*math.pi * math.sin(dist.distance / GEO_RADIUS) * GEO_RADIUS;
	-- local angle = point.radius / (2*math.pi * math.sin(dist.distance / GEO_RADIUS) * GEO_RADIUS) * GEO_2DEG;
	---local circ = (2*math.pi * dist.distance);
	--local angle = point.radius / (2*math.pi * dist.distance) * GEO_2DEG; -- benadering op platte vlak
	local angle = point.radius / (2*math.pi * math.sin(dist.distance / GEO_RADIUS) * GEO_RADIUS) * 360;
	---Wherigo.LogMessage({Text="Angle:" .. angle .. " (" .. point.radius .. "), dist:" .. dist.distance .. ", circ:" .. circ .. " "})
	return geoProject(hub.ObjectLocation.longitude, hub.ObjectLocation.latitude, dist.theta2 + angle*direction, dist.distance);
end

function geoDistance2Points(point1, point2)
	local retval = {}
	return geoDistanceHaversine(point1.longitude, point1.latitude, point2.longitude, point2.latitude)
end

function geoDistanceLinePoint(point1, point2, point3)
	local d12 = geoDistance2Points(point1, point2);
	local d13 = geoDistance2Points(point1, point3);
	return math.abs(math.asin(math.sin(d13.distance / GEO_RADIUS) * math.sin((d13.theta1 - d12.theta1) * GEO_2RAD))) * GEO_RADIUS
end

function geoDistanceManyPoints(point1, points)
	local dist, d = 0, {}, i, point
	for i, point in ipairs(points) do
		d = geoDistance2Points(point1, point)
		dist = dist + d.distance * d.distance
	end
	return dist
end

function geoClosestFirst(point, points)
    	if geoDistanceManyPoints(points[1], {point}) < geoDistanceManyPoints(points[2], {point}) then
    		return {points[1], points[2]}
    	else
    		return {points[2], points[1]}
    	end
end

function geoDistanceHaversine(x1, y1, x2, y2)
	--debugLog('geoDistanceHaversine('..x1..', '..y1..', '..x2..', '..y2..')');
	local dx, dy, a, d, theta1, theta2
	-- convert to radial
	x1 = x1 * GEO_2RAD;
	y1 = y1 * GEO_2RAD;
	x2 = x2 * GEO_2RAD;
	y2 = y2 * GEO_2RAD;

	dx = x2 - x1
	dy = y2 - y1

	a = math.sin(dy / 2) * math.sin(dy / 2) + math.cos(y1) * math.cos(y2) * math.sin(dx / 2) * math.sin(dx / 2);
	d = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a)) * GEO_RADIUS;

 	theta1 = math.atan2(math.sin( dx) * math.cos(y2), math.cos(y1) * math.sin(y2) - math.sin(y1) * math.cos(y2) * math.cos(dx)) * GEO_2DEG
 	theta2 = math.atan2(math.sin(-dx) * math.cos(y1), math.cos(y2) * math.sin(y1) - math.sin(y2) * math.cos(y1) * math.cos(dx)) * GEO_2DEG
 	if theta1 < 0 then theta1 = theta1 + 360 end
 	if theta2 < 0 then theta2 = theta2 + 360 end
	
	local retval = {}
	retval.distance = d
	-- 0 <= theta < 360
	retval.theta1 = theta1
	retval.theta2 = theta2
	return retval
end

function geoExtend(point1, point2, point3, point4)
	local dist = geoDistance2Points(point3.ObjectLocation, point4.ObjectLocation)
	local d = dist.distance * point3.radius / GEO_RADIUS / math.pi / 2;
	dist = geoDistance2Points(point1.ObjectLocation, point2.ObjectLocation)
	local r = geoProject(point1.ObjectLocation.longitude, point1.ObjectLocation.latitude, dist.theta1, d)
	r.radius = d;
	return r;
end
	
function geoIntersection2Circles(point1, point2)
	local dist = geoDistance2Points(point1.ObjectLocation, point2.ObjectLocation)
	-- http://mathworld.wolfram.com/SphericalTrigonometry.html
	local a, b, c = point1.radius / GEO_RADIUS,  point2.radius / GEO_RADIUS,  dist.distance / GEO_RADIUS
	-- geen gezijk met stralen van nul en andere bijzondere gevallen
	if (math.sin(a)*math.sin(b)*math.sin(c)) == 0 then return nil end
	local s = (a + b + c) / 2
	if math.sin(s) == 0 then return nil end
	local k = math.sqrt((math.sin(s-a) + math.sin(s-b) + math.sin(s-c)) / math.sin(s))
	local d = math.sin(s-a) * math.sin(s-c) / math.sin(a) / math.sin(c);
	if (d > 1) or (d < 0) then return nil end
	
	local B = 2 * math.atan2(math.sqrt(d), math.sqrt(1 - d)) * GEO_2DEG;

	local int1 = geoProject(point1.ObjectLocation.longitude, point1.ObjectLocation.latitude, dist.theta1 + B, point1.radius)
	local int2 = geoProject(point1.ObjectLocation.longitude, point1.ObjectLocation.latitude, dist.theta1 - B, point1.radius)
	local dist = geoDistance2Points(int1, int2);
	int1.radius = dist.distance;
	int2.radius = dist.distance;
	return geoClosestFirst(Player.ObjectLocation, {int1, int2})
end

function geoIntersectionLineCircle(point1, point2, point3)
	-- http://williams.best.vwh.net/avform.htm#POINTDME
	-- Point(s) known distance from a great circle
	-- Let points A and B define a great circle route and D be a third point. Find the points on the great circle through A and B that lie a distance d from D, if they exist.
	--   A = crs_AD - crs_AB
	--  ( crs_AB and crs_AD are the initial GC bearings from A to B and D, respectively. Compute using Course between points)

	local d12 = geoDistance2Points(point1.ObjectLocation, point2.ObjectLocation)
	local d13 = geoDistance2Points(point1.ObjectLocation, point3.ObjectLocation)
	local A = (d13.theta1 - d12.theta1) * GEO_2RAD
	local b = d13.distance / GEO_RADIUS
	local cosA, cosb, sinb, cosd = math.cos(A), math.cos(b), math.sin(b), math.cos(point3.radius / GEO_RADIUS)
	local r = math.sqrt(cosb*cosb + sinb*sinb*cosA*cosA)
	if cosd*cosd > r*r then
		return nil
	else
		local p = math.atan2(sinb * cosA, cosb)
		local d = math.acos(cosd/r)
		--Wherigo.LogMessage({Text="A:" .. A * GEO_2DEG .. ", b: " .. b * GEO_RADIUS .. ", P:" .. p * GEO_RADIUS .. ", D: " .. d * GEO_RADIUS})

		local int1 = geoProject(point1.ObjectLocation.longitude, point1.ObjectLocation.latitude, d12.theta1, (p - d) * GEO_RADIUS)
		local int2 = geoProject(point1.ObjectLocation.longitude, point1.ObjectLocation.latitude, d12.theta1, (p + d) * GEO_RADIUS)
		int1.radius = geoDistanceLinePoint(point1.ObjectLocation, point2.ObjectLocation, point3.ObjectLocation)
		int2.radius = int1.radius
		--Wherigo.LogMessage({Text="Int1: lat: " .. int1.latitude .. ", long: " .. int1.longitude})
		--return {int1, int2}
		return geoClosestFirst(Player.ObjectLocation, {int1, int2})
	end
end

function geoIntersection2Lines(point1, point2, point3, point4)
	--  For each point f,? (lat=f, lon=?), we can define a unit vector pointing to it from the centre of the earth: u{x,y,z} = [ cosf·cos?, cosf·sin?, sinf ] (taking x=0º, y=90º, z=north – note that these formulæ depend on convention used for directions and handedness)
	local p1 = vecPoint2Vector(point1)
	local p2 = vecPoint2Vector(point2)
	local p3 = vecPoint2Vector(point3)
	local p4 = vecPoint2Vector(point4)

	-- And for any great circle defined by two points, we can define a unit vector N normal to the plane of the circle: N(u1, u2) = (u1×u2) / ||u1×u2|| where × is the vector cross product, and ||u|| the norm (length of the vector)
	-- (a2b3 - a3b2, a3b1 - a1b3, a1b2 - a2b1).
	local n12 = vecCrossProduct(p1, p2)
	local n34 = vecCrossProduct(p3, p4)
	
	-- * The vector representing the intersection of the two great circles is then ui = ±N( N(u1, u2), N(u3, u4) )
	local u = vecCrossProduct(n12, n34)
	
      -- * We can then get the latitude and longitude of Pi by f = atan2(uz, sqrt(ux² + uy²)), ? = atan2(uy, ux)
    	local int1 = vecVector2Point(u)
    	local int2 = geoAntipodal(int1);
    	
    	local radius = math.acos(vecDotProduct(n12, n34)) * GEO_RADIUS
    	int1.radius = radius;
    	int2.radius = radius;
    	
    	if
    		geoDistanceManyPoints(int1, {point1, point2, point3, point4}) <
    		geoDistanceManyPoints(int2, {point1, point2, point3, point4}) then
    		return int1
    	else
    		return int2
    	end
end

function geoSnellius(point1, point2, point3, point4)
	local c1 = geoSnelliusCircle(point1, point2);
	local c2 = geoSnelliusCircle(point3, point4);
	if (c1 == nil) or (c2 == nil) then return nil end
	local str = print_r(c1);
	local p = geoIntersection2Circles(c1, c2);
	if (p == nil) then return nil end

	local  r = {};
	for i =  1, 2 do
		if (geoSnelliusAngle(p[i], point1, point2) and geoSnelliusAngle(p[i], point3, point4)) then
			r[table.getn(r)+1] = p[i];
		end
	end
	--debugLog(print_r(r))
	return r;
end

function geoSnelliusAngle(pointA, point1, point2)
	local a = geoAngle(pointA, point1.ObjectLocation, point2.ObjectLocation) * GEO_2RAD * GEO_RADIUS - point1.radius;
	--debugLog('a: ' .. a);
	return (math.abs(a) < (point1.radius / 16)) ;
end

function geoSnelliusCircle(point1, point2)
	-- haversin(c) = haversin(a-b) + sin(a) sin(b) haversin(C)
	-- a = b
	-- haversin(c)/haversin(C) = sin^2(b)
	local d = geoDistance2Points(point1.ObjectLocation, point2.ObjectLocation);
	-- I do not divide by 2 because we will divide these resuls also (2/2 = 1)
	local hsC = (1 - math.cos(d.distance / GEO_RADIUS));
	local hsc = (1 - math.cos(point1.radius / GEO_RADIUS));
	r = math.asin(math.sqrt(hsC / hsc)) * GEO_RADIUS;
	--debugLog('radius: ' .. r);

	-- save the radii
	local r1 = point1.radius;
	local r2 = point2.radius;

	point1.radius = r;
	point2.radius = r;
	local c = geoIntersection2Circles(point1, point2)
	if (c == nil) then return nil end -- is this possible?
	-- restore the radii
	point1.radius = r1;
	point2.radius = r2;

	-- check the angles
	local a1 = geoAngle(c[1], point1.ObjectLocation, point2.ObjectLocation) * GEO_2RAD * GEO_RADIUS;
	local a2 = geoAngle(c[2], point1.ObjectLocation, point2.ObjectLocation) * GEO_2RAD * GEO_RADIUS;
	--debugLog('a1: ' .. a1/GEO_2RAD/GEO_RADIUS .. ' a2: ' .. a2/GEO_2RAD/GEO_RADIUS);
	if (math.abs(r1 - a1) < math.abs(r1 - a2)) then
		c =  c[1];
	else
		c =  c[2];
	end
	-- omsloten cirkel bepalen
	c.ObjectLocation = geoTriangleCircumcenter(c, point1.ObjectLocation, point2.ObjectLocation);
	c.radius = c.ObjectLocation.radius;
	return c;
end

function geoTriangleIncenter(point1, point2, point3) -- incentrum X(1)
	-- snijpunt van de bicectrices
	local d12 = geoDistance2Points(point1, point2)
	local d23 = geoDistance2Points(point2, point3)
	local d31 = geoDistance2Points(point3, point1)
	
	local p1 = geoProject(point1.longitude, point1.latitude, (d12.theta1+d31.theta2) / 2, GEO_RADIUS)
	local p2 = geoProject(point2.longitude, point2.latitude, (d23.theta1+d12.theta2) / 2, GEO_RADIUS)
	local int = geoIntersection2Lines(point2, p2, point1, p1)
	int.radius = geoDistanceLinePoint(point2, point3, int)
	return int
end

function geoTriangleCentroid(point1, point2, point3) -- median, zwaartepunt X(2)
	-- http://www.jennessent.com/downloads/Graphics_Shapes_Online.pdf
	local v1, v2, v3 = vecPoint2Vector(point1), vecPoint2Vector(point2), vecPoint2Vector(point3)
	local c = {
		['x'] = (v1.x + v2.x + v3.x) / 3,
		['y'] = (v1.y + v2.y + v3.y) / 3,
		['z'] = (v1.z + v2.z + v3.z) / 3,
	}
	local int = vecVector2Point(c);
	
	-- A = 2 pi R h,  h = R (1 - cos(r))
	-- A = 2pi R^2 (1 - cos (r))
	-- A = 2pi R^2 - 2pi R^2 cos(r)
	-- 2pi R^2 cos(r) = 2pi R^2 - A
	-- cos(r) = (2pi R^2 - A) / 2pi R^2
	
	local piR = 2 * math.pi * GEO_RADIUS * GEO_RADIUS
	int.radius = math.acos((piR - geoAreaTriangle(point1, point2, point3)) / piR) * GEO_RADIUS

	return int
end

function geoTriangleCircumcenter(point1, point2, point3) --omcentrum X(3)
	-- snijpunt middelloodlijnen
	local v1, v2, v3 = vecPoint2Vector(point1), vecPoint2Vector(point2), vecPoint2Vector(point3)
	local n12, n23 = vecCrossProduct(v1, v2), vecCrossProduct(v2, v3)  -- loodrecht op de zijdes
	local m12 = { ['x'] = (v1.x + v2.x) / 2, ['y'] = (v1.y + v2.y) / 2, ['z'] = (v1.z + v2.z) / 2 } -- middelpunt van de zijdes
	local m23 = { ['x'] = (v2.x + v3.x) / 2, ['y'] = (v2.y + v3.y) / 2, ['z'] = (v2.z + v3.z) / 2 } 
	local i1 = vecVector2Point(vecCrossProduct(vecCrossProduct(n12, m12), vecCrossProduct(n23, m23)))
	local i2 = geoAntipodal(i1);
   	if
 		geoDistanceManyPoints(i1, {point1, point2, point3}) >
   		geoDistanceManyPoints(i2, {point1, point2, point3}) then
			i1 = i2;
   	end
		
	local dist = geoDistance2Points(i1, point1);
	i1.radius = dist.distance;
	return i1
end

function geoTriangleOrthocenter(point1, point2, point3) -- altitude, hoogtepunt X(4)
	-- http://www.mth.msu.edu/~ivanov/Arnold.pdf 
	local v1, v2, v3 = vecPoint2Vector(point1), vecPoint2Vector(point2), vecPoint2Vector(point3)
	local n12, n23 = vecCrossProduct(v1, v2), vecCrossProduct(v2, v3)
	local n123, n231 = vecCrossProduct(n12, v3), vecCrossProduct(n23, v1)
	local int1 = vecVector2Point(vecCrossProduct(n123, n231))
	local int2 = geoAntipodal(int1);
   	if
 		geoDistanceManyPoints(int1, {point1, point2, point3}) >
   		geoDistanceManyPoints(int2, {point1, point2, point3}) then
			int1 = int2;
   	end
   	int1.radius = Player.ObjectLocation.altitude:GetValue('m')
	return int1
end

function geoProject(x1, y1, t, d)
	-- http://www.movable-type.co.uk/scripts/latlong.html	
	x1 = x1 * GEO_2RAD;
	y1 = y1 * GEO_2RAD;
	t = t * GEO_2RAD;
	d = d / GEO_RADIUS;
	
	local y2 = math.asin(math.sin(y1) * math.cos(d) + math.cos(y1) * math.sin(d) * math.cos(t));
	local x2 = x1 + math.atan2(math.sin(t) * math.sin(d) * math.cos(y1), math.cos(d) - math.sin(y1) * math.sin(y2));

	return Wherigo.ZonePoint(y2 * GEO_2DEG, x2 * GEO_2DEG)
end

--
-- Vector stuff
--

function vecPoint2Vector(point)
	v = {}
	local lat = point.latitude * GEO_2RAD
	local lng = point.longitude * GEO_2RAD
	v.x = math.cos(lat) * math.cos(lng)
	v.y = math.cos(lat) * math.sin(lng)
	v.z = math.sin(lat)
	return v
end

function vecVector2Point(v)
    	return Wherigo.ZonePoint(math.atan2(v.z, math.sqrt(v.x*v.x + v.y*v.y)) * GEO_2DEG, math.atan2(v.y, v.x) * GEO_2DEG)
end

function vecCrossProduct(a, b)
	local p = {}
	p.x = a.y*b.z - a.z*b.y
	p.y = a.z*b.x - a.x*b.z
	p.z = a.x*b.y - a.y*b.x
	return p
end

function vecDotProduct(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z
end

-- 
-- Coordinate transformations
--

function RDtoWGS84(x, y)
--	Wherigo.LogMessage({Text="RDtoWGS84(" .. x .. ", " .. y .. ")"})

	-- http://www.xs4all.nl/~estevenh/1/js1/RdLatLong.js
	local a01=3236.0331637 ; local b10=5261.3028966;
	local a20= -32.5915821 ; local b11= 105.9780241;
	local a02=  -0.2472814 ; local b12=   2.4576469;
	local a21=  -0.8501341 ; local b30=  -0.8192156;
	local a03=  -0.0655238 ; local b31=  -0.0560092;
	local a22=  -0.0171137 ; local b13=   0.0560089;
	local a40=   0.0052771 ; local b32=  -0.0025614;
	local a23=  -0.0003859 ; local b14=   0.0012770;
	local a41=   0.0003314 ; local b50=   0.0002574;
	local a04=   0.0000371 ; local b33=  -0.0000973;
	local a42=   0.0000143 ; local b51=   0.0000293;
	local a24=  -0.0000090 ; local b15=   0.0000291;

	local dx=(x-x0) * 1E-5;
	local dy=(y-y0) * 1E-5;

	local dx2 = dx * dx 
	local dx3 = dx2 * dx 
	local dx4 = dx2 * dx2 
	local dx5 = dx4 * dx 
	local dy2 = dy * dy 
	local dy3 = dy2 * dy 
	local dy4 = dy2 * dy2
	local dy5 = dy4 * dy

	local df = a01*dy + a20*dx2 + a02*dy2 + a21*dx2*dy + a03*dy3+ a40*dx4 + a22*dx2*dy2 + a04*dy4 + a41*dx4*dy + a23*dx2*dy3 + a42*dx4*dy2 + a24*dx2*dy4;
	local f = f0 + df/3600;

	local dl = b10*dx +b11*dx*dy +b30*dx3 + b12*dx*dy2 + b31*dx3*dy + b13*dx*dy3 + b50*dx5 + b32*dx3*dy2 + b14*dx*dy4 + b51*dx5*dy +b33*dx3*dy3 + b15*dx*dy5
	local l = l0 + dl/3600;

	--Wherigo.LogMessage({Text="LongLat(" .. l .. ", " .. f .. ")"})
	y= f + (-96.862 - 11.714 * (f-52)- 0.125 * (l-5)) / 100000;
	x= l + (-37.902 +  0.329 * (f-52)-14.667 * (l-5)) / 100000;
	--Wherigo.LogMessage({Text="LongLat(" .. x .. ", " .. y .. ")"})
	
	return {['x'] = x, ['y'] = y }
end

function WGS84toRD(x, y)
	--Wherigo.LogMessage({Text="WGStoRD(" .. x .. ", " .. y .. ")"})

	f = y - (-96.862 - 11.714 * (y - 52) - 0.125 * (x - 5)) / 100000;
	l = x - (-37.902 +  0.329 * (y - 52) -14.667 * (x - 5)) / 100000;

	--Bereken RD coördinaten
	local c01=190066.98903 ; local d10=309020.31810;
	local c11=-11830.85831 ; local d02=  3638.36193;
	local c21=  -114.19754 ; local d12=  -157.95222;
	local c03=   -32.38360 ; local d20=    72.97141;
	local c31=    -2.34078 ; local d30=    59.79734;
	local c13=    -0.60639 ; local d22=    -6.43481;
	local c23=     0.15774 ; local d04=     0.09351;
	local c41=    -0.04158 ; local d32=    -0.07379;
	local c05=    -0.00661 ; local d14=    -0.05419;
	                         local d40=    -0.03444;
	df=(f - f0) * 0.36;
	dl=(l - l0) * 0.36;

	local df2 = df * df 
	local df3 = df2 * df 
	local df4 = df2 * df2 
	local dl2 = dl * dl
	local dl3 = dl2 * dl
	local dl4 = dl2 * dl2
	local dl5 = dl4 * dl

	local dx = c01*dl + c11*df*dl + c21*df2*dl + c03*dl3 +c31*df3*dl + 13*df*dl3 + c23*df2*dl3 + c41*df4*dl + c05*dl5;
	local x = x0 + dx;

	dy =d10*df + d20*df2 + d02*dl2 + d12*df*dl2 +d30*df3 + d22*df2*dl2 + d40*df4 + d04*dl4 + d32*df3*dl2 + d14*df*dl4;
	local y=y0 + dy;

	--Wherigo.LogMessage({Text="RD XY(" .. x .. ", " .. y .. ")"})
	
	return {['x'] = x, ['y'] = y }
end

--
-- ReReverse Waltmeister stuff
--

function isCodeOK(AAAAAA, BBBBBB, CCCCCC)
    variableB3 = tonumber(11 - ((AAAAAA % 1000000 - AAAAAA % 100000) / 100000 * 8 + (AAAAAA % 100000 - AAAAAA % 10000) / 10000 * 6 + (AAAAAA % 10000 - AAAAAA % 1000) / 1000 * 4 + (AAAAAA % 1000 - AAAAAA % 100) / 100 * 2 + (AAAAAA % 100 - AAAAAA % 10) / 10 * 3 + AAAAAA % 10 * 5 + (BBBBBB % 1000000 - BBBBBB % 100000) / 100000 * 9 + (BBBBBB % 100000 - BBBBBB % 10000) / 10000 * 7) % 11)
    if variableB3 == 10 then
      variableB3 = 0
    else
      if variableB3 == 11 then
        variableB3 = 5
      else
      end
    end
    variableC3 = tonumber(11 - ((BBBBBB % 1000 - BBBBBB % 100) / 100 * 8 + (BBBBBB % 100 - BBBBBB % 10) / 10 * 6 + BBBBBB % 10 * 4 + (CCCCCC % 1000000 - CCCCCC % 100000) / 100000 * 2 + (CCCCCC % 100000 - CCCCCC % 10000) / 10000 * 3 + (CCCCCC % 1000 - CCCCCC % 100) / 100 * 5 + (CCCCCC % 100 - CCCCCC % 10) / 10 * 9 + CCCCCC % 10 * 7) % 11)
    if variableC3 == 10 then
      variableC3 = 0
    else
      if variableC3 == 11 then
        variableC3 = 5
      else
      end
    end
    return variableB3 == tonumber((BBBBBB % 10000 - BBBBBB % 1000) / 1000) and variableC3 == tonumber((CCCCCC % 10000 - CCCCCC % 1000) / 1000) 
end

function code2LatLong(varA, varB, varC)
  local varLatVorz, varLongVorz, varLongKOMP, varLatKOMP
  if (varA % 1000 - varA % 100) / 100 == 1 then
    varLatVorz = 1
    varLongVorz = 1
  elseif (varA % 1000 - varA % 100) / 100 == 2 then
    varLatVorz = -1
    varLongVorz = 1
  elseif (varA % 1000 - varA % 100) / 100 == 3 then
    varLatVorz = 1
    varLongVorz = -1
  elseif (varA % 1000 - varA % 100) / 100 == 4 then
    varLatVorz = -1
    varLongVorz = -1
  end
  if ((varC % 100000 - varC % 10000) / 10000 + (varC % 100 - varC % 10) / 10) % 2 == 0 then
    varLatKOMP = tonumber(varLatVorz * ((varA % 10000 - varA % 1000) / 1000 * 10 + (varB % 100 - varB % 10) / 10 + (varB % 100000 - varB % 10000) / 10000 * 0.1 + (varC % 1000 - varC % 100) / 100 * 0.01 + (varA % 1000000 - varA % 100000) / 100000 * 0.001 + (varC % 100 - varC % 10) / 10 * 1.0E-4 + varA % 10 * 1.0E-5))
  elseif ((varC % 100000 - varC % 10000) / 10000 + (varC % 100 - varC % 10) / 10) % 2 ~= 0 then
    varLatKOMP = tonumber(varLatVorz * ((varB % 1000000 - varB % 100000) / 100000 * 10 + varA % 10 + (varA % 10000 - varA % 1000) / 1000 * 0.1 + (varC % 1000000 - varC % 100000) / 100000 * 0.01 + (varC % 1000 - varC % 100) / 100 * 0.001 + (varC % 100 - varC % 10) / 10 * 1.0E-4 + (varA % 1000000 - varA % 100000) / 100000 * 1.0E-5))
  end
  if ((varC % 100000 - varC % 10000) / 10000 + (varC % 100 - varC % 10) / 10) % 2 == 0 then
    varLongKOMP = tonumber(varLongVorz * ((varA % 100000 - varA % 10000) / 10000 * 100 + (varC % 1000000 - varC % 100000) / 100000 * 10 + varC % 10 + (varB % 1000 - varB % 100) / 100 * 0.1 + (varB % 1000000 - varB % 100000) / 100000 * 0.01 + (varA % 100 - varA % 10) / 10 * 0.001 + (varC % 100000 - varC % 10000) / 10000 * 1.0E-4 + varB % 10 * 1.0E-5))
  elseif ((varC % 100000 - varC % 10000) / 10000 + (varC % 100 - varC % 10) / 10) % 2 ~= 0 then
    varLongKOMP = tonumber(varLongVorz * ((varB % 100 - varB % 10) / 10 * 100 + varC % 10 * 10 + (varA % 100 - varA % 10) / 10 + (varA % 100000 - varA % 10000) / 10000 * 0.1 + (varB % 1000 - varB % 100) / 100 * 0.01 + varB % 10 * 0.001 + (varC % 100000 - varC % 10000) / 10000 * 1.0E-4 + (varB % 100000 - varB % 10000) / 10000 * 1.0E-5))
  end
  return varLatKOMP, varLongKOMP
end

function latLong2Code(varLat, varLong)
  local varLat = tonumber(varLat)
  local varLong = tonumber(varLong)
  local varA4, varB3, varC3, tempvarB3, tempvarC3
  local A = ""
  local B = ""
  local C = ""
  if varLat < 0 and varLong < 0 then
    varA4 = 4
    varLat = varLat * -1
    varLong = varLong * -1
  elseif varLat < 0 and varLong > 0 then
    varA4 = 2
    varLat = varLat * -1
  elseif varLat > 0 and varLong < 0 then
    varA4 = 3
    varLong = varLong * -1
  elseif varLat >= 0 and varLong >= 0 then
    varA4 = 1
  end
  varLong = varLong + 1.0E-12
  varLat = varLat + 1.0E-12
  varLat = tonumber(varLat * 100000 - varLat * 100000 % 1)
  varLong = tonumber(varLong * 100000 - varLong * 100000 % 1)
  if 0 == tonumber(((varLong % 100 - varLong % 10) / 10 + (varLat % 100 - varLat % 10) / 10) % 2) then
    tempvarB3 = tonumber(11 - ((varLat % 1000 - varLat % 100) / 100 * 8 + (varLong % 100000000 - varLong % 10000000) / 10000000 * 6 + (varLat % 10000000 - varLat % 1000000) / 1000000 * 4 + varA4 * 2 + (varLong % 1000 - varLong % 100) / 100 * 3 + varLat % 10 * 5 + (varLong % 10000 - varLong % 1000) / 1000 * 9 + (varLat % 100000 - varLat % 10000) / 10000 * 7) % 11)
    if tempvarB3 == 10 then
      varB3 = 0
    elseif tempvarB3 == 11 then
      varB3 = 5
    else
      varB3 = tempvarB3
    end
    tempvarC3 = tonumber(11 - ((varLong % 100000 - varLong % 10000) / 10000 * 8 + (varLat % 1000000 - varLat % 100000) / 100000 * 6 + varLong % 10 * 4 + (varLong % 10000000 - varLong % 1000000) / 1000000 * 2 + (varLong % 100 - varLong % 10) / 10 * 3 + (varLat % 10000 - varLat % 1000) / 1000 * 5 + (varLat % 100 - varLat % 10) / 10 * 9 + (varLong % 1000000 - varLong % 100000) / 100000 * 7) % 11)
    if tempvarC3 == 10 then
      varC3 = 0
    elseif tempvarC3 == 11 then
      varC3 = 5
    else
      varC3 = tempvarC3
    end
    A = (varLat % 1000 - varLat % 100) / 100 .. (varLong % 100000000 - varLong % 10000000) / 10000000 .. (varLat % 10000000 - varLat % 1000000) / 1000000 .. varA4 .. (varLong % 1000 - varLong % 100) / 100 .. varLat % 10
    B = (varLong % 10000 - varLong % 1000) / 1000 .. (varLat % 100000 - varLat % 10000) / 10000 .. varB3 .. (varLong % 100000 - varLong % 10000) / 10000 .. (varLat % 1000000 - varLat % 100000) / 100000 .. varLong % 10
    C = (varLong % 10000000 - varLong % 1000000) / 1000000 .. (varLong % 100 - varLong % 10) / 10 .. varC3 .. (varLat % 10000 - varLat % 1000) / 1000 .. (varLat % 100 - varLat % 10) / 10 .. (varLong % 1000000 - varLong % 100000) / 100000
    return A, B, C
  else
    if 0 ~= tonumber(((varLong % 100 - varLong % 10) / 10 + (varLat % 100 - varLat % 10) / 10) % 2) then
      tempvarB3 = tonumber(11 - (varLat % 10 * 8 + (varLong % 100000 - varLong % 10000) / 10000 * 6 + (varLat % 100000 - varLat % 10000) / 10000 * 4 + varA4 * 2 + (varLong % 1000000 - varLong % 100000) / 100000 * 3 + (varLat % 1000000 - varLat % 100000) / 100000 * 5 + (varLat % 10000000 - varLat % 1000000) / 1000000 * 9 + varLong % 10 * 7) % 11)
      if tempvarB3 == 10 then
        varB3 = 0
      elseif tempvarB3 == 11 then
        varB3 = 5
      else
        varB3 = tempvarB3
      end
      tempvarC3 = tonumber(11 - ((varLong % 10000 - varLong % 1000) / 1000 * 8 + (varLong % 100000000 - varLong % 10000000) / 10000000 * 6 + (varLong % 1000 - varLong % 100) / 100 * 4 + (varLat % 10000 - varLat % 1000) / 1000 * 2 + (varLong % 100 - varLong % 10) / 10 * 3 + (varLat % 1000 - varLat % 100) / 100 * 5 + (varLat % 100 - varLat % 10) / 10 * 9 + (varLong % 10000000 - varLong % 1000000) / 1000000 * 7) % 11)
      if tempvarC3 == 10 then
        varC3 = 0
      elseif tempvarC3 == 11 then
        varC3 = 5
      else
        varC3 = tempvarC3
      end
      A = varLat % 10 .. (varLong % 100000 - varLong % 10000) / 10000 .. (varLat % 100000 - varLat % 10000) / 10000 .. varA4 .. (varLong % 1000000 - varLong % 100000) / 100000 .. (varLat % 1000000 - varLat % 100000) / 100000
      B = (varLat % 10000000 - varLat % 1000000) / 1000000 .. varLong % 10 .. varB3 .. (varLong % 10000 - varLong % 1000) / 1000 .. (varLong % 100000000 - varLong % 10000000) / 10000000 .. (varLong % 1000 - varLong % 100) / 100
      C = (varLat % 10000 - varLat % 1000) / 1000 .. (varLong % 100 - varLong % 10) / 10 .. varC3 .. (varLat % 1000 - varLat % 100) / 100 .. (varLat % 100 - varLat % 10) / 10 .. (varLong % 10000000 - varLong % 1000000) / 1000000
      return A, B, C
    else
    end
  end
end

function updateReReverse()
	objInputReReverse.Choices = {}
	table.insert(objInputReReverse.Choices, 'A)' .. string.format('%06d', REREVERSE.A))
	table.insert(objInputReReverse.Choices, 'B)' .. string.format('%06d', REREVERSE.B))
	table.insert(objInputReReverse.Choices, 'C)' .. string.format('%06d', REREVERSE.C))

	if isCodeOK(REREVERSE.A, REREVERSE.B, REREVERSE.C) then
		table.insert(objInputReReverse.Choices, TXT.Point_Swap[LANG])
		point = {}
		point.latitude, point.longitude = code2LatLong(REREVERSE.A, REREVERSE.B, REREVERSE.C)
		
		objInputReReverse.Text = formatCoordinate(point)
	else
		objInputReReverse.Text = TXT.Input_ReReverse[LANG]
	end

	table.insert(objInputReReverse.Choices, TXT.Input_Exit[LANG])
end

function swapReReverse()
	p = {}
	-- Determine zone information from codes
	p.latitude, p.longitude = code2LatLong(REREVERSE.A, REREVERSE.B, REREVERSE.C)
	d = geoDistance2Points(p, Player.ObjectLocation)
	p.radius = d.distance
	name = TXT.Wherigo_ReReverse[LANG]
	description = 'Code:' .. NEW_LINE .. 
	'A)' .. string.format('%06d', REREVERSE.A) .. NEW_LINE ..
	'B)' .. string.format('%06d', REREVERSE.B) .. NEW_LINE ..
	'C)' .. string.format('%06d', REREVERSE.C) .. NEW_LINE

	-- Copy Point to Codes
	REREVERSE.A, REREVERSE.B, REREVERSE.C = latLong2Code(objPointA.ObjectLocation.latitude, objPointA.ObjectLocation.longitude)

	-- Copy Zone to Point
	objPointA.ObjectLocation.latitude = objZoneA.OriginalPoint.latitude
	objPointA.ObjectLocation.longitude = objZoneA.OriginalPoint.longitude
	objPointA.radius = objZoneA.radius
	objPointA.Name = objPointA.Name:sub(1,3) .. objZoneA.Name
	pointDescription(objPointA)

	-- Copy code info to Zone
	zoneDescription(objZoneA, p, name, description)

end
--
-- Debug stuff
--

function debugLog(str)
	if objZoneWorld.WGT_DEBUG then
		--if type(str) == "nil" then str = "__"	else str  = str.toString() end
	
		--Wherigo.LogMessage({Text="debugLog(" .. type(str) .. ")"})
		Wherigo.LogMessage({Text='debugLog(' .. str .. ')'})
	end
end

function print_r(t)
	str = tostring(t);
	if type(t) == 'table' then
		for k,v in pairs(t) do str = str .. NEW_LINE .. print_r(k) .. ': ' .. print_r(v) end;
	end
	return str;
end

function debugStr(o)  
	if objZoneWorld.WGT_DEBUG  == 0 then return '' end
	ret = NEW_LINE;
--	ret = ret .. "Debug"
	if o ~= nil then
		ret = ret .. NEW_LINE .. tostring(o);
		if type(o) == 'table' then
			ret = ret .. NEW_LINE .. 'TABLE';
			for k,v in pairs(o) do ret = ret .. NEW_LINE .. tostring(k) .. ': ' .. tostring(v) end;
		end
		if getmetatable(o) ~= nil then
			ret = ret .. NEW_LINE .. 'META';
			ret = ret .. NEW_LINE .. tostring(getmetatable(o));
			for k,v in pairs(getmetatable(o)) do ret = ret .. NEW_LINE .. tostring(k) .. ': ' .. tostring(v) end;
		
			if getmetatable(o)._self ~= nil then
				ret = ret .. NEW_LINE .. 'SELF';
				ret = ret .. NEW_LINE .. tostring(getmetatable(o)._self);
				for k,v in pairs(getmetatable(o)._self) do ret = ret .. NEW_LINE .. tostring(k) .. ': ' .. tostring(v) end;
			end
		end
	end
	return ret
end

-- A=01, B=02, C=03, D=04, E=05, F=06, G=07, H=12, I=13, J=46, K=14, L=15, M=16, N=17, O=23, P=24, Q=25, R=26, S=27, T=34, U=35, V=47, W=56, X=57, Y=36, Z=67. De beide getallen zijn onderling verwisselb

-- Eastereggs:
-- Ceasar:  Debugmode aan
-- Lattitude: Item L)Speet aan
-- Longitude: Zone C) Aan
-- Radius: Waltmeister?
-- Roman: Arrow size



