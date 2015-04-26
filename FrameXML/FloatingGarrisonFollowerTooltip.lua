GARRISON_FOLLOWER_TOOLTIP_FULL_XP_WIDTH = 180;

-------------------------------------------
local GARRISON_FOLLOWER_FLOATING_TOOLTIP = {};

function FloatingGarrisonFollower_Toggle(garrisonFollowerID, quality, level, itemLevel, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4)
	local followerTypeID = C_Garrison.GetFollowerTypeByID(garrisonFollowerID);
	local floatingTooltip = FloatingGarrisonFollowerTooltip;
	if (followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2) then
		floatingTooltip = FloatingGarrisonShipyardFollowerTooltip;
	end
	if ( floatingTooltip:IsShown() and
		floatingTooltip.garrisonFollowerID == garrisonFollowerID) then
		floatingTooltip:Hide();
	else
		FloatingGarrisonFollower_Show(floatingTooltip, garrisonFollowerID, followerTypeID, quality, level, itemLevel, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4);
	end
end

function FloatingGarrisonFollower_Show(floatingTooltip, garrisonFollowerID, followerTypeID, quality, level, itemLevel, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4)
	if (garrisonFollowerID and garrisonFollowerID > 0) then
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.garrisonFollowerID = garrisonFollowerID;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.followerTypeID = followerTypeID;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.collected = false;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.hyperlink = true;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.displayID = C_Garrison.GetFollowerDisplayIDByID(garrisonFollowerID);
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.name = C_Garrison.GetFollowerNameByID(garrisonFollowerID);
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.spec = C_Garrison.GetFollowerClassSpecByID(garrisonFollowerID);
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.portraitIconID = C_Garrison.GetFollowerPortraitIconIDByID(garrisonFollowerID);
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.quality = quality;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.level = level;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.xp = 0;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.levelxp = 0;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.itemLevel = itemLevel;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.ability1 = ability1;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.ability2 = ability2;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.ability3 = ability3;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.ability4 = ability4;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.trait1 = trait1;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.trait2 = trait2;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.trait3 = trait3;
		GARRISON_FOLLOWER_FLOATING_TOOLTIP.trait4 = trait4;
		
		if (followerTypeID == LE_FOLLOWER_TYPE_GARRISON_6_0) then
			GarrisonFollowerTooltipTemplate_SetGarrisonFollower(floatingTooltip, GARRISON_FOLLOWER_FLOATING_TOOLTIP);
		elseif (followerTypeID == LE_FOLLOWER_TYPE_SHIPYARD_6_2) then
			GarrisonFollowerTooltipTemplate_SetShipyardFollower(floatingTooltip, GARRISON_FOLLOWER_FLOATING_TOOLTIP);
		end
		floatingTooltip:Show();
	end
end

function GarrisonFollowerTooltip_OnLoad(self)
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
end

function GarrisonFollowerTooltipTemplate_SetGarrisonFollower(tooltipFrame, data, xpWidth)
	tooltipFrame.garrisonFollowerID = data.garrisonFollowerID;
	tooltipFrame.name = data.name;
	tooltipFrame.Name:SetText(data.name);
	tooltipFrame.ILevel:SetFormattedText(GARRISON_FOLLOWER_ITEM_LEVEL, data.itemLevel);
	tooltipFrame.Portrait.Level:SetText(data.level);
	GarrisonFollowerPortrait_Set(tooltipFrame.Portrait.Portrait, data.portraitIconID);
	local color = ITEM_QUALITY_COLORS[data.quality];
	tooltipFrame.Portrait.LevelBorder:SetVertexColor(color.r, color.g, color.b);
	tooltipFrame.Portrait.PortraitRingQuality:SetVertexColor(color.r, color.g, color.b);
	if ( data.spec ) then
		local classSpecName = C_Garrison.GetFollowerClassSpecName(data.garrisonFollowerID);
		tooltipFrame.ClassSpecName:SetText(classSpecName);
		local classSpecAtlas = C_Garrison.GetFollowerClassSpecAtlas(data.spec);
		if ( classSpecAtlas ) then
			tooltipFrame.Class:SetAtlas(classSpecAtlas);
		else
			tooltipFrame.Class:SetTexture(nil);
		end
	end

	if (not data.collected) then
		tooltipFrame.ILevel:Hide();
		tooltipFrame.XP:Hide();
		tooltipFrame.XPBar:Hide();
		tooltipFrame.XPBarBackground:Hide();
	elseif (data.level == GARRISON_FOLLOWER_MAX_LEVEL and data.quality >= GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY) then
		tooltipFrame.ILevel:Show();
		tooltipFrame.XP:Hide();
		tooltipFrame.XPBar:Hide();
		tooltipFrame.XPBarBackground:Hide();
	else
		tooltipFrame.ILevel:Hide();
		if (data.level == GARRISON_FOLLOWER_MAX_LEVEL) then
			tooltipFrame.XP:SetFormattedText(GARRISON_FOLLOWER_TOOLTIP_UPGRADE_XP, data.levelxp - data.xp);
		else
			tooltipFrame.XP:SetFormattedText(GARRISON_FOLLOWER_TOOLTIP_XP, data.levelxp - data.xp);
		end
		tooltipFrame.XP:Show();
		if (not xpWidth) then
			xpWidth = GARRISON_FOLLOWER_TOOLTIP_FULL_XP_WIDTH;
		end
		tooltipFrame.XPBar:SetWidth((data.xp / data.levelxp) * xpWidth);
		if (data.xp == 0) then
			tooltipFrame.XPBar:Hide()
		else
			tooltipFrame.XPBar:Show();
		end
		tooltipFrame.XPBarBackground:Show();
	end

	local abilities = {data.ability1, data.ability2, data.ability3, data.ability4};
	local traits = {data.trait1, data.trait2, data.trait3, data.trait4};

	local abilityCount = GarrisonFollowerTooltipTemplate_CountAbilities(abilities);

	local traitCount = 0;
	if (data.trait1 ~= 0 and data.trait1 ~= nil) then traitCount = traitCount + 1 end;
	if (data.trait2 ~= 0 and data.trait2 ~= nil) then traitCount = traitCount + 1 end;
	if (data.trait3 ~= 0 and data.trait3 ~= nil) then traitCount = traitCount + 1 end;
	if (data.trait4 ~= 0 and data.trait4 ~= nil) then traitCount = traitCount + 1 end;

	local detailed = not data.noAbilityDescriptions;
	
	local abilityTemplate = "GarrisonFollowerAbilityTemplate";

	local tooltipFrameHeightBase = 80;					-- this is the tooltip frame height w/ no abilities/traits being displayed
	local abilityOffset = 10;							-- distance between ability entries
	local abilityFrameHeightBase = 20;					-- ability frame height w/ no description/details being displayed
	local spacingBetweenLabelAndFirstAbility = 8;		-- distance between the "Abilities" label and the first ability below it
	local spacingBetweenNameAndDescription = 4;			-- must match the XML ability template setting
	local spacingBetweenDescriptionAndDetails = 8;		-- must match the XML ability template setting
	local spacingBeforeUnderBiasedString = 10;

	local tooltipFrameHeight = tooltipFrameHeightBase;
	tooltipFrame:SetSize(260, tooltipFrameHeight);

	if ( ENABLE_COLORBLIND_MODE == "1" ) then
		tooltipFrame.Quality:SetText(_G["ITEM_QUALITY"..data.quality.."_DESC"]);
		tooltipFrame.Quality:Show();
		tooltipFrame.AbilitiesLabel:SetPoint("TOPLEFT", 15, -90);
		tooltipFrameHeight = tooltipFrameHeight + 5;
	else
		tooltipFrame.Quality:Hide();
		tooltipFrame.AbilitiesLabel:SetPoint("TOPLEFT", 15, -85);
	end	
	
	if abilityCount > 0 then 
		tooltipFrameHeight = tooltipFrameHeight + tooltipFrame.AbilitiesLabel:GetHeight() + abilityOffset;
		tooltipFrame.AbilitiesLabel:Show();
	else
		tooltipFrame.AbilitiesLabel:Hide();
	end
	
	for i = 1, #tooltipFrame.Abilities do
		tooltipFrame.Abilities[i]:Hide();
	end

	for i=1, abilityCount do
		if (not tooltipFrame.Abilities[i]) then
			tooltipFrame.Abilities[i] = CreateFrame("Frame", nil, tooltipFrame, abilityTemplate);
		end		

		if i == 1 then
			tooltipFrame.Abilities[i]:SetPoint("TOPLEFT", tooltipFrame.AbilitiesLabel, "BOTTOMLEFT", 0, -spacingBetweenLabelAndFirstAbility);
			tooltipFrameHeight = tooltipFrameHeight + spacingBetweenLabelAndFirstAbility;
		else
			tooltipFrame.Abilities[i]:SetPoint("TOPLEFT", tooltipFrame.Abilities[i-1], "BOTTOMLEFT", 0, -abilityOffset);
			tooltipFrameHeight = tooltipFrameHeight + abilityOffset;
		end
				
		local Ability = tooltipFrame.Abilities[i];
		GarrisonFollowerTooltipTemplate_SetAbility(Ability, abilities[i], detailed);
		tooltipFrameHeight = tooltipFrameHeight + Ability:GetHeight();
	end
		
	if traitCount > 0 then 
		if abilityCount > 0 then
			tooltipFrame.TraitsLabel:SetPoint("TOPLEFT", tooltipFrame.Abilities[abilityCount], "BOTTOMLEFT", 0, -abilityOffset);
		else
			tooltipFrame.TraitsLabel:SetPoint("TOPLEFT", tooltipFrame, "TOPLEFT", 15, -tooltipFrameHeightBase -5);
		end

		tooltipFrameHeight = tooltipFrameHeight + tooltipFrame.TraitsLabel:GetHeight();
		tooltipFrameHeight = tooltipFrameHeight + abilityOffset;
		tooltipFrame.TraitsLabel:Show();
	else
		tooltipFrame.TraitsLabel:Hide();
	end

	for i = 1, #tooltipFrame.Traits do
		tooltipFrame.Traits[i]:Hide();
	end
	
	for i = 1, traitCount do
		if (not tooltipFrame.Traits[i]) then
			tooltipFrame.Traits[i] = CreateFrame("Frame", nil, tooltipFrame, abilityTemplate);
		end

		if i== 1 then
			tooltipFrame.Traits[i]:SetPoint("TOPLEFT", tooltipFrame.TraitsLabel, "BOTTOMLEFT", 0, -spacingBetweenLabelAndFirstAbility);
			tooltipFrameHeight = tooltipFrameHeight + spacingBetweenLabelAndFirstAbility;
		else
			tooltipFrame.Traits[i]:SetPoint("TOPLEFT", tooltipFrame.Traits[i-1], "BOTTOMLEFT", 0, -abilityOffset);
			tooltipFrameHeight = tooltipFrameHeight + abilityOffset;
		end

		local Trait = tooltipFrame.Traits[i];

		Trait.Name:SetText(C_Garrison.GetFollowerAbilityName(traits[i]));
		Trait.Icon:SetTexture(C_Garrison.GetFollowerAbilityIcon(traits[i]));

		Trait:SetHeight(abilityFrameHeightBase);

		-- hide ability only controls
		Trait.CounterIcon:Hide();
		Trait.CounterIconBorder:Hide();

		if detailed then
			Trait.Description:Show();

			local description = C_Garrison.GetFollowerAbilityDescription(traits[i]);
			if string.len(description) == 0 then description = "PH - Description Missing"; end
			Trait.Description:SetText(description);
			
			Trait:SetHeight(Trait:GetHeight() + Trait.Description:GetHeight() + spacingBetweenNameAndDescription);

			local details = ""; --this is not data driven right now, but design may want to add a new field to garrison abilities for this
			if string.len(details) == 0 then
				Trait.Details:Hide();
			else
				Trait.Details:SetText(details);
				Trait.Details:Show();
				Trait:SetHeight(Trait:GetHeight() + Trait.Details:GetHeight() + spacingBetweenDescriptionAndDetails);
			end
		else
			Trait.Description:Hide();
			Trait.Details:Hide();
		end

		Trait:Show();
				
		tooltipFrameHeight = tooltipFrameHeight + Trait:GetHeight();
	end

	if ( not detailed ) then
		tooltipFrameHeight = tooltipFrameHeight + abilityOffset;
	end

	if ( data.underBiased ) then
		if ( data.quality >= LE_ITEM_QUALITY_EPIC ) then
			tooltipFrame.UnderBiased:SetText(GARRISON_FOLLOWER_BELOW_LEVEL_MAX_XP_TOOLTIP);
		else
			tooltipFrame.UnderBiased:SetText(GARRISON_FOLLOWER_BELOW_LEVEL_TOOLTIP);
		end

		if ( traitCount > 0 ) then
			tooltipFrame.UnderBiased:SetPoint("TOPLEFT", tooltipFrame.Traits[traitCount], "BOTTOMLEFT", 0, -spacingBeforeUnderBiasedString);
		elseif ( abilityCount > 0 ) then
			tooltipFrame.UnderBiased:SetPoint("TOPLEFT", tooltipFrame.Abilities[abilityCount], "BOTTOMLEFT", 0, -spacingBeforeUnderBiasedString);
		else
			tooltipFrame.UnderBiased:SetPoint("TOPLEFT", tooltipFrame.AbilitiesLabel, "TOPLEFT", 0, -spacingBeforeUnderBiasedString);
		end
		tooltipFrame.UnderBiased:Show();
		tooltipFrameHeight = tooltipFrameHeight + spacingBeforeUnderBiasedString + tooltipFrame.UnderBiased:GetHeight();
	else
		tooltipFrame.UnderBiased:Hide();
	end

	tooltipFrame:SetSize(260, tooltipFrameHeight + 10);
end

function GarrisonFollowerTooltipTemplate_SetShipyardFollower(tooltipFrame, data, xpWidth)
	tooltipFrame.garrisonFollowerID = data.garrisonFollowerID;
	tooltipFrame.name = data.name;
	
	local color = ITEM_QUALITY_COLORS[data.quality];
	tooltipFrame.Name:SetText(data.name);
	tooltipFrame.Name:SetTextColor(color.r, color.g, color.b);
	if ( data.spec ) then
		local classSpecName = C_Garrison.GetFollowerClassSpecName(data.garrisonFollowerID);
		tooltipFrame.ClassSpecName:SetText(classSpecName);
	end

	if (not data.collected) then
		tooltipFrame.XP:Hide();
		tooltipFrame.XPBar:Hide();
		tooltipFrame.XPBarBackground:Hide();
	elseif (data.quality >= GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY) then
		tooltipFrame.XP:Hide();
		tooltipFrame.XPBar:Hide();
		tooltipFrame.XPBarBackground:Hide();
	else
		tooltipFrame.XP:SetFormattedText(GARRISON_FOLLOWER_TOOLTIP_UPGRADE_XP, data.levelxp - data.xp);
		tooltipFrame.XP:Show();
		if (not xpWidth) then
			xpWidth = GARRISON_FOLLOWER_TOOLTIP_FULL_XP_WIDTH;
		end
		tooltipFrame.XPBar:SetWidth((data.xp / data.levelxp) * xpWidth);
		if (data.xp == 0) then
			tooltipFrame.XPBar:Hide()
		else
			tooltipFrame.XPBar:Show();
		end
		tooltipFrame.XPBarBackground:Show();
	end
	
	local properties = { data.trait1,  data.trait2, data.ability1, data.ability2};
	local propertyCount = GarrisonFollowerTooltipTemplate_CountAbilities(properties);
	local detailed = not data.noAbilityDescriptions;

	local tooltipFrameHeightBase = 50;		-- this is the tooltip frame height w/ no abilities/traits being displayed
	local abilityOffset = 10;				-- distance between ability entries
	
	local tooltipFrameHeight = tooltipFrameHeightBase;
	if (tooltipFrame.XP:IsShown()) then
		tooltipFrameHeight = tooltipFrameHeight + 30;
	end
	tooltipFrame:SetSize(260, tooltipFrameHeight);

	if ( ENABLE_COLORBLIND_MODE == "1" ) then
		tooltipFrame.Quality:SetText(_G["ITEM_QUALITY"..data.quality.."_DESC"]);
		tooltipFrame.Quality:Show();
		tooltipFrameHeight = tooltipFrameHeight + 5;
	else
		tooltipFrame.Quality:Hide();
	end
	
	if propertyCount > 0 then 
		tooltipFrameHeight = tooltipFrameHeight + abilityOffset;
	end
	
	for i = 1, #tooltipFrame.Properties do
		tooltipFrame.Properties[i]:Hide();
	end

	for i=1, propertyCount do
		local property = tooltipFrame.Properties[i];
		if (i == 1) then
			if (tooltipFrame.XP:IsShown()) then
				property:SetPoint("TOPLEFT", tooltipFrame.XP, "BOTTOMLEFT", 2, -10);
			else
				property:SetPoint("TOPLEFT", tooltipFrame.ClassSpecName, "BOTTOMLEFT", 2, -10);
			end
		end
		GarrisonFollowerTooltipTemplate_SetAbility(property, properties[i], detailed);
		tooltipFrameHeight = tooltipFrameHeight + abilityOffset;
		tooltipFrameHeight = tooltipFrameHeight + property:GetHeight();
	end

	tooltipFrame:SetSize(260, tooltipFrameHeight + 10);
end

function GarrisonFollowerTooltipTemplate_CountAbilities(abilities)
	local count = 0;
	for i=1, #abilities do
		if (abilities[i] ~= 0 and abilities[i] ~= nil and C_Garrison.GetFollowerAbilityIcon(abilities[i])) then
			count = count + 1;
		end
	end
	return count;
end	

function GarrisonFollowerTooltipTemplate_SetAbility(Ability, ability, detailed)
	Ability.Name:SetText(C_Garrison.GetFollowerAbilityName(ability));
	Ability.Icon:SetTexture(C_Garrison.GetFollowerAbilityIcon(ability));
	Ability:SetHeight(20);		-- ability frame height w/ no description/details being displayed

	local spacingBetweenNameAndDescription = 4;			-- must match the XML ability template setting
	local spacingBetweenDescriptionAndDetails = 8;		-- must match the XML ability template setting

	Ability.Description:Hide();
	Ability.Details:Hide();
	Ability.CounterIcon:Hide();
	Ability.CounterIconBorder:Hide();
	if detailed then
		local description = C_Garrison.GetFollowerAbilityDescription(ability);
		if string.len(description) == 0 then description = "PH - Description Missing"; end
	
		Ability.Description:SetText(description);
		Ability.Description:Show();
		Ability:SetHeight(Ability:GetHeight() + Ability.Description:GetHeight() + spacingBetweenNameAndDescription);
		local abilityCounterMechanicID, abilityCounterMechanicName, abilityCounterMechanicIcon = C_Garrison.GetFollowerAbilityCounterMechanicInfo(ability);
		if (abilityCounterMechanicName and abilityCounterMechanicIcon) then
			Ability.Details:SetFormattedText(GARRISON_ABILITY_COUNTERS_FORMAT, abilityCounterMechanicName);
			Ability.Details:Show();
			Ability:SetHeight(Ability:GetHeight() + Ability.Details:GetHeight() + spacingBetweenDescriptionAndDetails);

			Ability.CounterIcon:SetTexture(abilityCounterMechanicIcon);
			Ability.CounterIcon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
			Ability.CounterIcon:Show();
			Ability.CounterIconBorder:Show();
		end
	end

	Ability:Show();
end

function FloatingGarrisonFollowerAbility_Toggle(garrFollowerAbilityID)
	if ( FloatingGarrisonFollowerAbilityTooltip:IsShown() and
		FloatingGarrisonFollowerAbilityTooltip.garrFollowerAbilityID == garrFollowerAbilityID) then
		FloatingGarrisonFollowerAbilityTooltip:Hide();
	else
		FloatingGarrisonFollowerAbility_Show(garrFollowerAbilityID);
	end
end

function FloatingGarrisonFollowerAbility_Show(garrFollowerAbilityID)
	GarrisonFollowerAbilityTooltipTemplate_SetAbility(FloatingGarrisonFollowerAbilityTooltip, garrFollowerAbilityID)
end

function GarrisonFollowerAbilityTooltipTemplate_SetAbility(tooltipFrame, garrFollowerAbilityID)
	if (garrFollowerAbilityID and garrFollowerAbilityID > 0)  then
		tooltipFrame.garrFollowerAbilityID = garrFollowerAbilityID;
		tooltipFrame:Show();
		
		tooltipFrame.Name:SetText(C_Garrison.GetFollowerAbilityName(garrFollowerAbilityID));
		tooltipFrame.Icon:SetTexture(C_Garrison.GetFollowerAbilityIcon(garrFollowerAbilityID));

		local abilityIsTrait = C_Garrison.GetFollowerAbilityIsTrait(garrFollowerAbilityID);
		
		local abilityFrameHeightBase = 45;
		local spacingBetweenNameAndDescription = 4;			-- must match the XML ability template setting
		local spacingBetweenDescriptionAndDetails = 8;		-- must match the XML ability template setting

		tooltipFrame:SetHeight(abilityFrameHeightBase);
		
		local description = C_Garrison.GetFollowerAbilityDescription(garrFollowerAbilityID);
		if string.len(description) == 0 then 
			description = "PH - Description Missing"; 
		end

		tooltipFrame.Description:Show();
		tooltipFrame.Description:SetText(description);
		tooltipFrame:SetHeight(tooltipFrame:GetHeight() + tooltipFrame.Description:GetHeight() + spacingBetweenNameAndDescription);
		
		local abilityCounterMechanicID, abilityCounterMechanicName, abilityCounterMechanicIcon = C_Garrison.GetFollowerAbilityCounterMechanicInfo(garrFollowerAbilityID);
		if (abilityCounterMechanicName and abilityCounterMechanicIcon) then
			tooltipFrame.Details:Show();
			tooltipFrame.Details:SetFormattedText(GARRISON_ABILITY_COUNTERS_FORMAT, abilityCounterMechanicName);
			tooltipFrame:SetHeight(tooltipFrame:GetHeight() + tooltipFrame.Details:GetHeight() + spacingBetweenDescriptionAndDetails);
			tooltipFrame.CounterIcon:SetTexture(abilityCounterMechanicIcon);
			tooltipFrame.CounterIcon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
			tooltipFrame.CounterIcon:Show();
			tooltipFrame.CounterIconBorder:Show();
		else
			tooltipFrame.Details:Hide();
			tooltipFrame.CounterIcon:Hide();
			tooltipFrame.CounterIconBorder:Hide();
		end
	end
end

function FloatingGarrisonMission_Toggle(garrMissionID)
	if ( FloatingGarrisonMissionTooltip:IsShown() and
		FloatingGarrisonMissionTooltip.garrMissionID == garrMissionID) then
		FloatingGarrisonMissionTooltip:Hide();
	else
		FloatingGarrisonMission_Show(garrMissionID);
	end
end

function FloatingGarrisonMission_Show(garrMissionID)
	FloatingGarrisonMissionTooltip:Show();
	FloatingGarrisonMissionTooltip.garrMissionID = garrMissionID;
	FloatingGarrisonMissionTooltip.Name:SetText(C_Garrison.GetMissionName(garrMissionID));
	FloatingGarrisonMissionTooltip.FollowerRequirement:SetFormattedText(GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS, C_Garrison.GetMissionMaxFollowers(garrMissionID), 1, 1, 1);
	
	local rewards = C_Garrison.GetMissionRewardInfo(garrMissionID);
	local rewardText = "";
	
	local missionFrameHeightBase = 70;
	FloatingGarrisonMissionTooltip:SetHeight(missionFrameHeightBase);

	for id, reward in pairs(rewards) do
		if string.len(rewardText) > 0 then
			rewardText = rewardText.."\n";
		end

		if (reward.quality) then
			rewardText = rewardText..ITEM_QUALITY_COLORS[reward.quality + 1].hex..reward.title..FONT_COLOR_CODE_CLOSE;
		elseif (reward.itemID) then 
			local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(reward.itemID);
			if itemName then
				rewardText = rewardText..ITEM_QUALITY_COLORS[itemRarity].hex..itemName..FONT_COLOR_CODE_CLOSE;
			end
		elseif (reward.followerXP) then
			rewardText = rewardText..reward.title;
		else
			rewardText = rewardText..reward.title;
		end
	end
	
	FloatingGarrisonMissionTooltip.Rewards:SetText(rewardText, 1, 1, 1);
	FloatingGarrisonMissionTooltip:SetHeight(FloatingGarrisonMissionTooltip:GetHeight() + FloatingGarrisonMissionTooltip.Rewards:GetHeight());
end
