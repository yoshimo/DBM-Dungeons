local mod	= DBM:NewMod(675, "DBM-Party-MoP", 4, 303)
local L		= mod:GetLocalizedStrings()

mod.statTypes = "normal,heroic,challenge,timewalker"

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(56589)
mod:SetEncounterID(1405)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 106933",
	"SPELL_AURA_REMOVED 106933",
	"SPELL_CAST_SUCCESS 107047",
	"SPELL_DAMAGE 115458",
	"SPELL_MISSED 116297",
	"RAID_BOSS_EMOTE"
)

local warnImpalingStrike	= mod:NewTargetAnnounce(107047, 3)
local warnPreyTime			= mod:NewTargetAnnounce(106933, 3, nil, "Healer")

local specWarnStafingRun	= mod:NewSpecialWarningDodge("ej5660", nil, nil, nil, 2, 2)
local specWarnGTFO			= mod:NewSpecialWarningGTFO(116297, nil, nil, nil, 1, 8)

local timerImpalingStrikeCD	= mod:NewCDTimer(25.5, 107047, nil, "Tank|Healer", nil, 5)
local timerPreyTime			= mod:NewTargetTimer(5, 106933, nil, "Healer", nil, 5, nil, DBM_COMMON_L.HEALER_ICON)
local timerPreyTimeCD		= mod:NewNextTimer(14.5, 106933, nil, nil, nil, 3)

function mod:OnCombatStart(delay)
--	timerImpalingStrikeCD:Start(-delay)--Bad pull, no pull timers.
--	timerPreyTimeCD:Start(-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 106933 then
		warnPreyTime:Show(args.destName)
		timerPreyTime:Start(args.destName)
		timerPreyTimeCD:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 106933 then
		timerPreyTime:Start(args.destName)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 107047 then
		warnImpalingStrike:Show(args.destName)
		timerImpalingStrikeCD:Start()
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId, spellName)
	if (spellId == 115458 or spellId == 116297) and destGUID == UnitGUID("player") and self:AntiSpam() then
		specWarnGTFO:Show(spellName)
		specWarnGTFO:Play("watchfeet")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:RAID_BOSS_EMOTE(msg)--Needs a better trigger if possible using transcriptor.
	if msg == L.StaffingRun or msg:find(L.StaffingRun) then
		specWarnStafingRun:Show()
		specWarnStafingRun:Play("watchstep")
		timerPreyTimeCD:Stop()
		timerImpalingStrikeCD:Stop()
		timerImpalingStrikeCD:Start(29)
		timerPreyTimeCD:Start(32.5)
	end
end
