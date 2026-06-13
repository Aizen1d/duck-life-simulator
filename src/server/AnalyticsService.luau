--!strict

-- AnalyticsService (custom): a thin, fail-safe wrapper over the Roblox built-in
-- AnalyticsService for the Duck funnel and economy events described in
-- docs/PRODUCT_PLAN.md. Every call is wrapped in task.spawn + pcall and gated by an
-- enabled flag, so analytics can never interrupt gameplay and can be killed instantly.
--
-- Event naming convention (recorded in docs/CODING_STANDARDS.md):
--   funnel_*       one-time onboarding/progression milestones (LogCustomEvent)
--   econ_source_*  coins entering the economy   (LogEconomyEvent, Source flow)
--   econ_sink_*    coins leaving the economy     (LogEconomyEvent, Sink flow)
--   social_*       one-time social milestones    (LogCustomEvent)

local RobloxAnalytics = game:GetService("AnalyticsService")

local Analytics = {}

-- Kill switch. Flip via setEnabled to silence every analytics call instantly.
local enabled = true

local function resolveFlowType(flow: string): EnumItem
	if flow == "sink" then
		return Enum.AnalyticsEconomyFlowType.Sink
	end

	return Enum.AnalyticsEconomyFlowType.Source
end

-- The Roblox API takes a transaction-type string; we pass a matching Enum name when one
-- exists so the built-in economy dashboards categorize the flow, otherwise the raw label.
local function resolveTransactionType(transactionType: string): string
	local ok, enumItem = pcall(function()
		return (Enum.AnalyticsEconomyTransactionType :: any)[transactionType]
	end)

	if ok and enumItem then
		return enumItem.Name
	end

	return transactionType
end

function Analytics.setEnabled(value: boolean)
	enabled = value
end

function Analytics.isEnabled(): boolean
	return enabled
end

-- Economy source/sink event. `category` becomes the econ_* label, passed as the item SKU
-- so the built-in economy dashboard can break flows down by reason (e.g. duck_purchase).
function Analytics.logEconomy(
	player: Player,
	flow: string,
	currency: string,
	amount: number,
	endingBalance: number,
	transactionType: string,
	category: string
)
	if not enabled then
		return
	end

	local flowType = resolveFlowType(flow)
	local resolvedTransaction = resolveTransactionType(transactionType)
	local label = (if flow == "sink" then "econ_sink_" else "econ_source_") .. category

	task.spawn(function()
		local ok, err = pcall(function()
			RobloxAnalytics:LogEconomyEvent(
				player,
				flowType,
				currency,
				amount,
				math.max(0, endingBalance),
				resolvedTransaction,
				label
			)
		end)

		if not ok then
			warn(string.format("[Analytics] LogEconomyEvent failed (%s): %s", label, tostring(err)))
		end
	end)
end

-- One-time custom event for funnel_* and social_* milestones. Callers are responsible for
-- firing each event only once per profile lifetime (see funnelMilestones in PlayerStateService).
function Analytics.logCustom(player: Player, eventName: string)
	if not enabled then
		return
	end

	task.spawn(function()
		local ok, err = pcall(function()
			RobloxAnalytics:LogCustomEvent(player, eventName, 1)
		end)

		if not ok then
			warn(string.format("[Analytics] LogCustomEvent failed (%s): %s", eventName, tostring(err)))
		end
	end)
end

return Analytics
