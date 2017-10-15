#include-once

$sendPacket = 		0x007F2560
$skillUse = 		0x004E31E0
$pickWalk =			0x004D43E0
$moveAddr1 =		0x004E4F20
$moveAddr2 =		0x004EA650
$moveAddr3 =		0x004E5FE0

$baseOff = 			0x00DFCBA0
$gameOff = 				0x1C
	$gamerOff = 			0x34
		$xOff = 				0x3C
		$yOff = 				0x44
		$zOff = 				0x40
		$widOff = 				0x4B4
		$lvlOff = 				0x4C0
		$hpOff = 				0x4C8
		$mpOff = 				0x4CC
		$expOff = 				0x4D0
		$chiOff = 				0x4DC
		$rebornOff = 			0x4F8
		$maxHpOff = 			0x51C
		$maxMpOff = 			0x520
		$maxChiOff = 			0x59C
		$targetOff = 			0x5A0
		$moneyOff = 			0x5A4
		$nameOff = 				0x748
		$classOff =				0x74C
		$actionOff =			0x15BC
	$NpoOff = 				0x1C
		$MNPsOff =				0x20
			;/MNP - Mob,NPC,Pet/
			$MNPsCountOff = 		0x18
			$MNPsArray =			0x5C
				;/MobAddr = i*0x4 (0...count)/
					$MNPTypeOff =		0x0B4 ; 6-mob 7-NPC 9-Pet
;~ 										0x0B8 - расстояния от моба до камеры игрока
					$MNPWidOff =		0x10C
					$MNPIdOff =			0x118
					$MNPLvlOff =		0x11C
					$MNPHpOff = 		0x124
					$MNPMaxHpOff = 		0x178
					$MNPTargetOff =		0x1FC
					$MNPNumOff = 		0x208
					$MNPFeatureOff = 	0x248
					$MNPNameOff = 		0x25C
					$MNPDistOff =		0x280
					$MNPEnvOff =		0x2B0 ; 0-groung, 1-water, 2-air
					$MNPMoveFlagOff =	0x2CC
		$lootOff = 				0x24
			$lootCount =			0x14
			$lootArray =			0x1C
				;/LootAddr = i*0x4 (0...0x300)/
					$lootDataOff =		0x4
						$lootWIDOff =		0x10C
						$lootIDOff =		0x110
						$lootTypeOff =		0x14C
						$lootLvlOff =		0x150
						$lootDistOff =		0x154
						$lootNameOff =		0x160


