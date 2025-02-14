local mod	= DBM:NewMod(688, "DBM-Party-MoP", 9, 316)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("@file-date-integer@")
mod:SetCreatureID(59789)
mod:SetEncounterID(1423)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 115297",
	"SPELL_AURA_REMOVED 115297",
	"SPELL_CAST_SUCCESS 115297 115147 115139",
	"SPELL_SUMMON 115250"
)

local warnEvictSoul				= mod:NewTargetNoFilterAnnounce(115297, 3)
local warnEmpowerZombie			= mod:NewSpellAnnounce(115250, 4)

local specWarnFallenCrusader	= mod:NewSpecialWarningSwitch("ej5863", "-Healer", nil, nil, 1, 2)--Need more data, nots sure if they are meaningful enough to kill or ignore.
local specWarnEmpoweredSpirit	= mod:NewSpecialWarningSwitch("ej5869", "-Healer", nil, nil, 1, 2)--These need to die before they become zombies. Cannot see a way in combat log to detect target, i'll have to watch for target scanning next time to warn that player to run away from dead crusaders.

local timerEvictSoul			= mod:NewTargetTimer(6, 115297, nil, nil, nil, 5)
local timerEvictSoulCD			= mod:NewCDTimer(41, 115297, nil, nil, nil, 3)
local timerRaiseCrusadeCD		= mod:NewNextTimer(60, 115139, nil, nil, nil, 1)--Both of these are 40 second cds in challenge modes
local timerSummonSpiritsCD		= mod:NewNextTimer(60, 115147, nil, nil, nil, 1)--Although correction is only needed in one spot

function mod:OnCombatStart(delay)
	timerRaiseCrusadeCD:Start(6-delay)
	timerEvictSoulCD:Start(15.5-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 115297 then
		warnEvictSoul:Show(args.destName)
		timerEvictSoul:Start(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 115297 then
		timerEvictSoul:Cancel(args.destName)
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 115297 then--Trigger CD off success, since we can resist it. do NOT add ID 115548, it's a similcast to 115297
		timerEvictSoulCD:Start()
	elseif args.spellId == 115147 then--Summon Empowering Spirits
		specWarnEmpoweredSpirit:Show()
		specWarnEmpoweredSpirit:Play("killmob")
		timerRaiseCrusadeCD:Start(20)--Raise crusaders always 20 seconds after spirits in all modes
	elseif args.spellId == 115139 then--Raise Fallen Crusade
		specWarnFallenCrusader:Show()
		specWarnFallenCrusader:Play("killmob")
		if self:IsDifficulty("challenge5") then
			timerSummonSpiritsCD:Start(20)
		else
			timerSummonSpiritsCD:Start(40)
		end
	end
end

function mod:SPELL_SUMMON(args)
	if args.spellId == 115250 then--Empower Zombie (used by empowering Spirits on fallen Crusaders to make them hulking hard hitting zombies)
		warnEmpowerZombie:Show()
	end
end
