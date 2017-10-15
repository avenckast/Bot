#Include <NomadMemory.au3>
#Include <Offsets.au3>
#include <WinAPIMisc.au3>

Global $PacketInjStr,   $PacketInjAddr
Global $PackCallInjStr, $PackCallInjAddr,	$PackCallConnection = False
Global $SkillUseInjStr, $SkillUseInjAddr,	$SkillUseConnection = False
Global $PickWalkInjStr, $PickWalkInjAddr,	$PickWalkConnection = False
Global $MoveInjStr,     $MoveInjAddr,		$MoveConnection		= False
Global $MemoryHandler


Func BytesArray($num, $bytes=4)
   Local $Hex, $BytesArray
   $Hex=Hex($num,8)
   $BytesArray = StringRight($Hex,2) & StringMid($Hex,5,2) & StringMid($Hex,3,2) & StringMid($Hex,1,2)
   Return StringLeft($BytesArray, $bytes*2)
EndFunc


Func PackCallInj()
	$PacketInjStr = DllStructCreate("byte[100]")
	$RESULT = DllCall($MemoryHandler[0], "ptr", "VirtualAllocEx", "int", $MemoryHandler[1], "ptr", 0, "int", DllStructGetSize($PacketInjStr), "int", 4096, "int", 64)
	$PacketInjAddr = $RESULT[0]

	$OPCode  = "60"									;pushad
	$OPCode &= "8B0D" & BytesArray($baseOff)		;mov ECX,[BASE_ADRESS]
	$OPCode &= "8B49" & BytesArray(0x20,1)			;mov ECX,[ECX+20]
	$OPCode &= "68"   & BytesArray(0)				;push LEN (длина пакета)
	$OPCode &= "68"   & BytesArray($PacketInjAddr)	;push Packet address
	$OPCode &= "BA"   & BytesArray($sendPacket)		;mov EDX, PacketCall Adress
	$OPCode &= "FFD2"								;call EDX
	$OPCode &= "61"									;popad
	$OPCODE &= "C3"									;ret

	$OPCODE = StringReplace($OPCODE," ","")
	Local $injectSize = int(StringLen($OPCODE)/2)
	$PackCallInjStr = DllStructCreate("byte["&$injectSize&"]")
	$RESULT = DllCall($MemoryHandler[0], "ptr", "VirtualAllocEx", "int", $MemoryHandler[1], "ptr", 0, "int", DllStructGetSize($PackCallInjStr), "int", 4096, "int", 64)
	$PackCallInjAddr = $RESULT[0]
	ConsoleWrite("->CallPacketAddr: " & Hex($PackCallInjAddr) & " ->PacketAddr: " & Hex($PacketInjAddr) & @CRLF)

	For $i = 1 To DllStructGetSize($PackCallInjStr)
		DllStructSetData($PackCallInjStr,1,Dec(StringMid($OPCode,($i-1)*2+1,2)),$i)
	Next
	DllCall($MemoryHandler[0], "int", "WriteProcessMemory", "int", $MemoryHandler[1], "ptr", $PackCallInjAddr, "ptr", DllStructGetPtr($PackCallInjStr), "int", DllStructGetSize($PackCallInjStr), "int", 0)
	$PackCallConnection = True
EndFunc

Func SkillUseInj()
	$OPCode  = "60"									;pushad
	$OPCode &= "8B0D" & BytesArray($baseOff)		;mov ECX,[BASE_ADRESS]
	$OPCode &= "8B49" & BytesArray($gameOff,1)     	;mov ECX,[ECX+1C]
	$OPCode &= "8B49" & BytesArray($gamerOff,1)    	;mov ECX,[ECX+34]
	$OPCode &= "68"   & BytesArray(-1)            	;push -1
	$OPCode &= "6A00"                               ;push 0
	$OPCode &= "6A00"                               ;push 0
	$OPCode &= "68"   & BytesArray(0)       		;push,Skill_ID
	$OPCode &= "BA"   & BytesArray($skillUse)    	;mov EDX, UseSkill
	$OPCode &= "FFD2"                               ;call EDX
	$OPCode &= "61"                                 ;popad
	$OPCODE &= "C3"                                 ;ret

	$OPCODE = StringReplace($OPCODE," ","")
	$injectSize = int(StringLen($OPCODE)/2)
	$SkillUseInjStr = DllStructCreate("byte["&$injectSize&"]")
	$RESULT = DllCall($MemoryHandler[0], "ptr", "VirtualAllocEx", "int", $MemoryHandler[1], "ptr", 0, "int", DllStructGetSize($SkillUseInjStr), "int", 4096, "int", 64)
	$SkillUseInjAddr = $RESULT[0]
	ConsoleWrite("->SkillUseAddr: " & Hex($SkillUseInjAddr) & @CRLF)

	For $i = 1 To DllStructGetSize($SkillUseInjStr)
		DllStructSetData($SkillUseInjStr,1,Dec(StringMid($OPCode,($i-1)*2+1,2)),$i)
	Next
	DllCall($MemoryHandler[0], "int", "WriteProcessMemory", "int", $MemoryHandler[1], "ptr", $SkillUseInjAddr, "ptr", DllStructGetPtr($SkillUseInjStr), "int", DllStructGetSize($SkillUseInjStr), "int", 0)
	$SkillUseConnection = True
EndFunc

Func PickWalkInj()
	$OPCode  = "60"									;pushad
	$OPCode &= "8B0D" & BytesArray($baseOff)		;mov ECX,[BASE_ADRESS]
	$OPCode &= "8B49" & BytesArray($gameOff,1)     	;mov ECX,[ECX+1C]
	$OPCode &= "8B49" & BytesArray($gamerOff,1)		;mov ECX,[ECX+34]
	$OPCode &= "6A00"                               ;push pick type (0-pick,1-dig)
	$OPCode &= "68"   & BytesArray(0)               ;push LootWID
	$OPCode &= "B8"   & BytesArray($pickWalk)       ;mov eax, PickWalk
	$OPCode &= "FFD0"								;call eax
	$OPCode &= "61"                                 ;popad
	$OPCODE &= "C3"                                 ;ret

	$OPCODE = StringReplace($OPCODE," ","")
	$injectSize = int(StringLen($OPCODE)/2)
	$PickWalkInjStr = DllStructCreate("byte["&$injectSize&"]")
	$RESULT = DllCall($MemoryHandler[0], "ptr", "VirtualAllocEx", "int", $MemoryHandler[1], "ptr", 0, "int", DllStructGetSize($PickWalkInjStr), "int", 4096, "int", 64)
	$PickWalkInjAddr = $RESULT[0]
	ConsoleWrite("->PickWalkAddr: " & Hex($PickWalkInjAddr) & @CRLF)

	For $i = 1 To DllStructGetSize($PickWalkInjStr)
		DllStructSetData($PickWalkInjStr,1,Dec(StringMid($OPCode,($i-1)*2+1,2)),$i)
	Next
	DllCall($MemoryHandler[0], "int", "WriteProcessMemory", "int", $MemoryHandler[1], "ptr", $PickWalkInjAddr, "ptr", DllStructGetPtr($PickWalkInjStr), "int", DllStructGetSize($PickWalkInjStr), "int", 0)
	$PickWalkConnection = True
EndFunc

Func MoveInj()
	$OPCode  = "60"										;- pushad
	$OPCode &= "A1" &		BytesArray($baseOff)		;- mov eax,[(BASE_ADRESS)]
	$OPCode &= "8B 40" & 	BytesArray($gameOff,1)		;- mov eax,[eax+1C]
	$OPCode &= "8B 70" & 	BytesArray($gamerOff,1)		;- mov esi,[eax+34]
	$OPCode &= "8B 8E" & 	BytesArray($actionOff)		;- mov ecx,[esi+000015BC]
	$OPCode &= "6A 01"                 					;- push 01
	$OPCode &= "B8" & 		BytesArray($moveAddr1)  	;- mov eax, (MoveAddress1)
	$OPCode &= "FF D0"                 					;- call eax
	$OPCode &= "8D 54 24 20"           					;- lea edx,[esp+20]
	$OPCode &= "8B D8"                 					;- mov ebx,eax
	$OPCode &= "52"                    					;- push edx
	$OPCode &= "6A 00"                 					;- push (Flying)
	$OPCode &= "8B CB"                 					;- mov ecx,ebx
	$OPCode &= "B8" & 		BytesArray($moveAddr2)  	;- mov eax, (MoveAddress2)
	$OPCode &= "FF D0"                 					;- call eax
	$OPCode &= "8B 8E" &	BytesArray($actionOff)  	;- mov ecx,[esi+(actionOff)]
	$OPCode &= "C7 43 20" &	BytesArray(0)    			;- mov [ebx+20], (x)
	$OPCode &= "C7 43 24" &	BytesArray(0)    			;- mov [ebx+24], (z)
	$OPCode &= "C7 43 28" &	BytesArray(0)   			;- mov [ebx+28], (y)
	$OPCode &= "6A 00"                 					;- push 00
	$OPCode &= "53"                    					;- push ebx
	$OPCode &= "6A 01"                 					;- push 01
	$OPCode &= "B8" &		BytesArray($moveAddr3)      ;- mov eax, MoveAddress3
	$OPCode &= "FFD0"									;- call eax
	$OPCode &= "61"                                 	;- popad
	$OPCODE &= "C3"                                 	;- ret

	$OPCODE = StringReplace($OPCODE," ","")
	$injectSize = int(StringLen($OPCODE)/2)
	$MoveInjStr = DllStructCreate("byte["&$injectSize&"]")
	$RESULT = DllCall($MemoryHandler[0], "ptr", "VirtualAllocEx", "int", $MemoryHandler[1], "ptr", 0, "int", DllStructGetSize($MoveInjStr), "int", 4096, "int", 64)
	$MoveInjAddr = $RESULT[0]
	ConsoleWrite("->PickWalkAddr: " & Hex($MoveInjAddr) & @CRLF)

	For $i = 1 To DllStructGetSize($MoveInjStr)
		DllStructSetData($MoveInjStr,1,Dec(StringMid($OPCode,($i-1)*2+1,2)),$i)
	Next
	DllCall($MemoryHandler[0], "int", "WriteProcessMemory", "int", $MemoryHandler[1], "ptr", $MoveInjAddr, "ptr", DllStructGetPtr($MoveInjStr), "int", DllStructGetSize($MoveInjStr), "int", 0)
	$MoveConnection = True
EndFunc


Func SendPacket($Packet)
	If $PackCallConnection Then
		$Packet = StringReplace($Packet," ","")
		$PacketSizeStr = DllStructCreate("dword")
		DllStructSetData($PacketSizeStr,1,Int(StringLen($Packet)/2))
		For $l_i = 1 To DllStructGetSize($PacketInjStr)
			DllStructSetData($PacketInjStr,1,Dec(StringMid($Packet,($l_i-1)*2+1,2)),$l_i)
		Next
		DllCall($MemoryHandler[0], "int", "WriteProcessMemory", "int", $MemoryHandler[1], "ptr", $PacketInjAddr, "ptr", DllStructGetPtr($PacketInjStr), "int", DllStructGetSize($PacketInjStr), "int", 0)
		DllCall($MemoryHandler[0], "int", "WriteProcessMemory", "int", $MemoryHandler[1], "ptr", $PackCallInjAddr+11, "ptr", DllStructGetPtr($PacketSizeStr), "int", 4, "int", 0)

		$RESULT = DllCall($MemoryHandler[0], "int", "CreateRemoteThread", "int", $MemoryHandler[1], "ptr", 0, "int", 0, "int", $PackCallInjAddr, "ptr", 0, "int", 0, "int", 0)
		$THREAD = $RESULT[0]
		Do
			$RESULT = DllCall($MemoryHandler[0], "int", "WaitForSingleObject", "int", $THREAD, "int", 50)
		Until $RESULT[0] <> 258
		DllCall($MemoryHandler[0], "int", "CloseHandle", "int", $THREAD)
	EndIf
EndFunc

Func UseSkill($SkillID)
	If $SkillUseConnection Then
		$SkillIDStr = DllStructCreate("dword")
		DllStructSetData($SkillIDStr,1,$SkillID)
		DllCall($MemoryHandler[0], "int", "WriteProcessMemory", "int", $MemoryHandler[1], "ptr", $SkillUseInjAddr+23, "ptr", DllStructGetPtr($SkillIDStr), "int", 4, "int", 0)
		$RESULT = DllCall($MemoryHandler[0], "int", "CreateRemoteThread", "int", $MemoryHandler[1], "ptr", 0, "int", 0, "int", $SkillUseInjAddr, "ptr", 0, "int", 0, "int", 0)
		$THREAD = $RESULT[0]
		Do
			$RESULT = DllCall($MemoryHandler[0], "int", "WaitForSingleObject", "int", $THREAD, "int", 50)
		Until $RESULT[0] <> 258
		DllCall($MemoryHandler[0], "int", "CloseHandle", "int", $THREAD)
	EndIf
EndFunc

Func PickUp($LootWID, $LootType)
	If $PickWalkConnection Then
		$LootWIDStr = DllStructCreate("dword")
		$PickModeStr = DllStructCreate("byte")
		DllStructSetData($LootWIDStr,1,$LootWID)
		If $LootType = 2 Then
			DllStructSetData($PickModeStr,1,1)
		Else
			DllStructSetData($PickModeStr,1,0)
		EndIf
		DllCall($MemoryHandler[0], "int", "WriteProcessMemory", "int", $MemoryHandler[1], "ptr", $PickWalkInjAddr+16, "ptr", DllStructGetPtr($LootWIDStr), "int", 4, "int", 0)
		DllCall($MemoryHandler[0], "int", "WriteProcessMemory", "int", $MemoryHandler[1], "ptr", $PickWalkInjAddr+14, "ptr", DllStructGetPtr($PickModeStr), "int", 1, "int", 0)
		$RESULT = DllCall($MemoryHandler[0], "int", "CreateRemoteThread", "int", $MemoryHandler[1], "ptr", 0, "int", 0, "int", $PickWalkInjAddr, "ptr", 0, "int", 0, "int", 0)
		$THREAD = $RESULT[0]
		Do
			$RESULT = DllCall($MemoryHandler[0], "int", "WaitForSingleObject", "int", $THREAD, "int", 50)
		Until $RESULT[0] <> 258
		DllCall($MemoryHandler[0], "int", "CloseHandle", "int", $THREAD)
	EndIf
EndFunc

Func Move($x, $y, $z=0, $fly=0)
	If $MoveConnection Then
		$x = _WinAPI_FloatToDWord(($x-400)*10)
		$y = _WinAPI_FloatToDWord(($y-550)*10)
		$z = _WinAPI_FloatToDWord($z*10)

		$XStr = DllStructCreate("dword")
		$YStr = DllStructCreate("dword")
		$ZStr = DllStructCreate("dword")
		$FlyStr = DllStructCreate("byte")

		DllStructSetData($XStr,1,$x)
		DllStructSetData($YStr,1,$y)
		DllStructSetData($ZStr,1,$z)
		DllStructSetData($FlyStr,1,$fly)

		DllCall($MemoryHandler[0], "int", "WriteProcessMemory", "int", $MemoryHandler[1], "ptr", $MoveInjAddr+54, "ptr", DllStructGetPtr($XStr), "int", 4, "int", 0)
		DllCall($MemoryHandler[0], "int", "WriteProcessMemory", "int", $MemoryHandler[1], "ptr", $MoveInjAddr+61, "ptr", DllStructGetPtr($ZStr), "int", 4, "int", 0)
		DllCall($MemoryHandler[0], "int", "WriteProcessMemory", "int", $MemoryHandler[1], "ptr", $MoveInjAddr+68, "ptr", DllStructGetPtr($YStr), "int", 4, "int", 0)
		DllCall($MemoryHandler[0], "int", "WriteProcessMemory", "int", $MemoryHandler[1], "ptr", $MoveInjAddr+35, "ptr", DllStructGetPtr($FlyStr), "int", 1, "int", 0)

		$RESULT = DllCall($MemoryHandler[0], "int", "CreateRemoteThread", "int", $MemoryHandler[1], "ptr", 0, "int", 0, "int", $MoveInjAddr, "ptr", 0, "int", 0, "int", 0)
		$THREAD = $RESULT[0]
		Do
			$RESULT = DllCall($MemoryHandler[0], "int", "WaitForSingleObject", "int", $THREAD, "int", 50)
		Until $RESULT[0] <> 258
		DllCall($MemoryHandler[0], "int", "CloseHandle", "int", $THREAD)
	EndIf
EndFunc


Func DeletePackCall()
	If $PackCallConnection Then
		DllCall($MemoryHandler[0], "ptr", "VirtualFreeEx", "hwnd", $MemoryHandler[1], "ptr", DllStructGetPtr($PacketInjStr), "int", DllStructGetSize($PacketInjStr), "int", 32768)
		DllCall($MemoryHandler[0], "ptr", "VirtualFreeEx", "hwnd", $MemoryHandler[1], "ptr", DllStructGetPtr($PackCallInjStr), "int", DllStructGetSize($PackCallInjStr), "int", 32768)
		$PackCallConnection = False
	EndIf
EndFunc

Func DeleteSkillUse()
	If $SkillUseConnection Then
		DllCall($MemoryHandler[0], "ptr", "VirtualFreeEx", "hwnd", $MemoryHandler[1], "ptr", DllStructGetPtr($SkillUseInjStr), "int", DllStructGetSize($SkillUseInjStr), "int", 32768)
		$SkillUseConnection = False
	EndIf
EndFunc

Func DeletePickWalk()
	If $PickWalkConnection Then
		DllCall($MemoryHandler[0], "ptr", "VirtualFreeEx", "hwnd", $MemoryHandler[1], "ptr", DllStructGetPtr($PickWalkInjStr), "int", DllStructGetSize($PickWalkInjStr), "int", 32768)
		$PickWalkConnection = False
	EndIf
EndFunc

Func DeleteMoveInj()
	If $MoveConnection Then
		DllCall($MemoryHandler[0], "ptr", "VirtualFreeEx", "hwnd", $MemoryHandler[1], "ptr", DllStructGetPtr($MoveInjStr), "int", DllStructGetSize($MoveInjStr), "int", 32768)
		$MoveConnection = False
	EndIf
EndFunc


Func Connect($PID)
	$MemoryHandler = _MemoryOpen($PID)
	PackCallInj()
	SkillUseInj()
	PickWalkInj()
	MoveInj()
EndFunc

Func Disconnect()
	DeletePackCall()
	DeleteSkillUse()
	DeletePickWalk()
	DeleteMoveInj()
	_MemoryClose($MemoryHandler)
EndFunc