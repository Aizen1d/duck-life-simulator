const CONFIG = {
	eggSeconds: 5,
	eggValueCosts: [10, 25, 60, 140, 320],
	buyDuckBaseCost: 25,
	duckFeedCost: 5,
	premiumFeedCost: 12,
	treatCost: 15,
	pillowCost: 8,
	toyCost: 10,
	xpPerCare: 25,
	xpPerFeed: 35,
	xpPerPremiumFeed: 55,
	xpPerTreat: 40,
	xpPerPillowRest: 45,
	xpPerToyPlay: 50,
	xpPerLevel: 100,
	maxDuckLevel: 5,
};

const CARE_SEQUENCE = ["pet", "hungry", "sleepy", "clean", "thirsty", "bored"];
const CARE_LABELS = {
	pet: "Pet me?",
	hungry: "Hungry?",
	sleepy: "Sleepy?",
	clean: "Dirty?",
	thirsty: "Thirsty?",
	bored: "Bored?",
};

const QUESTS = {
	collect: { target: 10, rewardCoins: 5 },
	sell: { target: 10, rewardCoins: 5 },
	help: { target: 3, rewardCoins: 10 },
};

const initialState = () => ({
	time: 0,
	eggProgress: 0,
	duckCount: 1,
	availableEggs: 0,
	heldEggs: 0,
	coins: 0,
	eggValueLevel: 0,
	eggValue: 1,
	duckFeed: 1,
	premiumFeed: 0,
	duckTreat: 0,
	pillow: 0,
	toy: 0,
	duckLevel: 1,
	duckXp: 0,
	careTimer: 8,
	careRequest: null,
	careIndex: 0,
	weatherTimer: 18,
	weatherIndex: 0,
	weather: "Sunny",
	eggCatchTimer: 28,
	saveTimer: 0,
	saveStatus: "Saved",
	quest: {
		collect: { progress: 0, level: 1 },
		sell: { progress: 0, level: 1 },
		help: { progress: 0, level: 1 },
	},
});

let state = initialState();
let isPlaying = true;
let speed = 1;
let intervalId = null;

const elements = {
	actionTitle: document.getElementById("actionTitle"),
	actionDetail: document.getElementById("actionDetail"),
	playPauseButton: document.getElementById("playPauseButton"),
	stepButton: document.getElementById("stepButton"),
	resetButton: document.getElementById("resetButton"),
	speedInput: document.getElementById("speedInput"),
	speedLabel: document.getElementById("speedLabel"),
	clearLogButton: document.getElementById("clearLogButton"),
	eventLog: document.getElementById("eventLog"),
	duckRow: document.getElementById("duckRow"),
	eggProgressBar: document.getElementById("eggProgressBar"),
	xpProgressBar: document.getElementById("xpProgressBar"),
	weatherText: document.getElementById("weatherText"),
	careRequestText: document.getElementById("careRequestText"),
	guideText: document.getElementById("guideText"),
	saveText: document.getElementById("saveText"),
};

function start() {
	bindControls();
	resetSimulation();
	intervalId = window.setInterval(() => {
		if (!isPlaying) {
			return;
		}

		for (let index = 0; index < speed; index += 1) {
			tick();
		}
	}, 950);
}

function bindControls() {
	elements.playPauseButton.addEventListener("click", () => {
		isPlaying = !isPlaying;
		elements.playPauseButton.textContent = isPlaying ? "Pause" : "Play";
		setAction(isPlaying ? "Autoplay running" : "Simulation paused", isPlaying
			? "The simulated player will keep acting through the farm loop."
			: "Use Step to advance one decision at a time.");
	});

	elements.stepButton.addEventListener("click", () => {
		tick();
	});

	elements.resetButton.addEventListener("click", () => {
		resetSimulation();
	});

	elements.speedInput.addEventListener("input", () => {
		speed = Number(elements.speedInput.value);
		elements.speedLabel.textContent = `${speed}x`;
	});

	elements.clearLogButton.addEventListener("click", () => {
		elements.eventLog.innerHTML = "";
	});
}

function resetSimulation() {
	state = initialState();
	isPlaying = true;
	elements.playPauseButton.textContent = "Pause";
	elements.eventLog.innerHTML = "";
	setAction("Starting farm", "One duck is ready. Eggs will move from left to right as the simulated player acts.");
	addLog("Fresh profile starts with 1 duck, 0 coins, and Duck Feed x1.");
	render();
}

function tick() {
	state.time += 1;
	clearActiveCards();
	runPassiveSystems();
	runPlayerDecision();
	render();
}

function runPassiveSystems() {
	produceEggs();
	updateCareRequest();
	updateWeather();
	updateSaveStatus();
}

function produceEggs() {
	const levelBonus = 1 + Math.max(0, state.duckLevel - 1) * 0.1;
	state.eggProgress += (state.duckCount * levelBonus) / CONFIG.eggSeconds;

	if (state.eggProgress >= 1) {
		const eggsMade = Math.floor(state.eggProgress);
		state.eggProgress -= eggsMade;
		state.availableEggs += eggsMade;
		pulse("ducksBox");
		pulse("nestBox");
		spawnToken("egg", "ducksBox", "nestBox", `+${eggsMade}`);
		addLog(`${eggsMade} egg${eggsMade === 1 ? "" : "s"} reached the nest.`);
	}
}

function updateCareRequest() {
	if (state.careRequest) {
		return;
	}

	state.careTimer -= 1;

	if (state.careTimer <= 0) {
		state.careRequest = CARE_SEQUENCE[state.careIndex % CARE_SEQUENCE.length];
		state.careIndex += 1;
		state.careTimer = 14;
		pulse("careRequestBox");
		addLog(`A duck asks for help: ${CARE_LABELS[state.careRequest]}`);
	}
}

function updateWeather() {
	state.weatherTimer -= 1;

	if (state.weatherTimer > 0) {
		return;
	}

	const cycle = [
		{ name: "Sunny", text: "Sunny: normal care rhythm." },
		{ name: "Cloudy", text: "Cloudy: dirty requests are more likely." },
		{ name: "Rainy", text: "Rainy: sleepy requests are more likely." },
		{ name: "Stormy", text: "Stormy: sleepy and dirty requests are more likely." },
	];
	state.weatherIndex = (state.weatherIndex + 1) % cycle.length;
	state.weather = cycle[state.weatherIndex].name;
	state.weatherTimer = 18;
	pulse("weatherBox");
	addLog(`Weather changes to ${state.weather}.`);
}

function updateSaveStatus() {
	if (state.saveTimer > 0) {
		state.saveTimer -= 1;
		state.saveStatus = state.saveTimer > 1 ? "Saving soon" : "Saved";
	}
}

function runPlayerDecision() {
	if (state.availableEggs > 0) {
		collectEggs();
		return;
	}

	if (state.heldEggs >= Math.max(1, Math.min(5, state.duckCount + 1))) {
		sellEggs();
		return;
	}

	if (state.careRequest) {
		if (state.careRequest === "hungry" && state.duckFeed <= 0 && state.premiumFeed <= 0) {
			if (state.coins >= CONFIG.duckFeedCost) {
				buyShopItem("duckFeed");
				return;
			}
			setAction("Waiting for feed coins", "The duck is hungry, but the player needs enough coins to buy feed first.");
			pulse("careRequestBox", true);
			return;
		}

		resolveCareRequest();
		return;
	}

	const nextEggValueCost = getNextEggValueCost();
	const duckCost = getDuckCost();

	if (state.eggValueLevel === 0 && state.coins >= nextEggValueCost) {
		buyEggValue();
		return;
	}

	if (state.duckCount < 5 && state.coins >= duckCost) {
		buyDuck();
		return;
	}

	if (state.eggValueLevel < CONFIG.eggValueCosts.length && state.coins >= nextEggValueCost) {
		buyEggValue();
		return;
	}

	if (state.duckFeed < 2 && state.coins >= CONFIG.duckFeedCost) {
		buyShopItem("duckFeed");
		return;
	}

	if (state.duckTreat < 1 && state.duckLevel < CONFIG.maxDuckLevel && state.coins >= CONFIG.treatCost) {
		buyShopItem("duckTreat");
		return;
	}

	if (state.duckTreat > 0 && state.duckLevel < CONFIG.maxDuckLevel) {
		giveTreat();
		return;
	}

	state.eggCatchTimer -= 1;
	if (state.eggCatchTimer <= 0) {
		playEggCatch();
		return;
	}

	setAction("Waiting for the farm", "The simulated player is waiting for eggs, care requests, or enough coins for the next decision.");
}

function collectEggs() {
	const amount = state.availableEggs;
	state.availableEggs = 0;
	state.heldEggs += amount;
	grantQuest("collect", amount);
	markDirty();
	pulse("collectBox");
	pulse("nestBox");
	pulse("heldEggsBox");
	spawnToken("egg", "nestBox", "heldEggsBox", `${amount}`);
	setAction("Collect", `${amount} ready egg${amount === 1 ? "" : "s"} moved into held eggs.`);
	addLog(`Collect moves ${amount} egg${amount === 1 ? "" : "s"} into the inventory.`);
}

function sellEggs() {
	const amount = state.heldEggs;
	const coinsEarned = amount * state.eggValue;
	state.heldEggs = 0;
	state.coins += coinsEarned;
	grantQuest("sell", amount);
	markDirty();
	pulse("sellBox");
	pulse("heldEggsBox");
	pulse("coinsBox");
	spawnToken("coin", "heldEggsBox", "coinsBox", `+${coinsEarned}`);
	setAction("Sell", `${amount} held egg${amount === 1 ? "" : "s"} sold for ${coinsEarned} coins.`);
	addLog(`Sell converts eggs into ${coinsEarned} coins.`);
}

function buyEggValue() {
	const cost = getNextEggValueCost();
	state.coins -= cost;
	state.eggValueLevel += 1;
	state.eggValue += 1;
	markDirty();
	pulse("coinsBox");
	pulse("eggValueBox");
	spawnToken("coin", "coinsBox", "eggValueBox", `-${cost}`);
	setAction("Buy Egg Value", `Coins buy Egg Value level ${state.eggValueLevel}; each egg now sells for ${state.eggValue}.`);
	addLog(`Egg Value upgraded for ${cost} coins.`);
}

function buyDuck() {
	const cost = getDuckCost();
	state.coins -= cost;
	state.duckCount += 1;
	markDirty();
	pulse("coinsBox");
	pulse("buyDuckBox");
	pulse("ducksBox");
	spawnToken("coin", "coinsBox", "buyDuckBox", `-${cost}`);
	spawnToken("duck", "buyDuckBox", "ducksBox", "+duck");
	setAction("Buy Duck", `A new duck joins the farm. Production now comes from ${state.duckCount} ducks.`);
	addLog(`Buy Duck spends ${cost} coins and adds duck ${state.duckCount}.`);
}

function buyShopItem(itemId) {
	const item = getShopItem(itemId);
	if (!item || state.coins < item.cost) {
		return;
	}

	state.coins -= item.cost;
	state[item.stateKey] += 1;
	markDirty();
	pulse("coinsBox");
	pulse("shopBox");
	pulse("itemsBox");
	spawnToken("coin", "coinsBox", "shopBox", `-${item.cost}`);
	spawnToken("item", "shopBox", "itemsBox", `+${item.shortLabel}`);
	setAction("Shop", `${item.label} bought for ${item.cost} coins.`);
	addLog(`Shop adds ${item.label} x1.`);
}

function resolveCareRequest() {
	const request = state.careRequest;
	let xp = CONFIG.xpPerCare;
	let detail = "Care clears the request and grants duck XP.";

	if (request === "hungry") {
		if (state.premiumFeed > 0) {
			state.premiumFeed -= 1;
			xp = CONFIG.xpPerPremiumFeed;
			detail = "Premium Feed is consumed first and grants stronger hungry-care XP.";
			spawnToken("item", "itemsBox", "careActionBox", "-premium");
		} else if (state.duckFeed > 0) {
			state.duckFeed -= 1;
			xp = CONFIG.xpPerFeed;
			detail = "Duck Feed is consumed to help the hungry duck.";
			spawnToken("item", "itemsBox", "careActionBox", "-feed");
		}
	} else if (request === "sleepy" && state.pillow > 0) {
		state.pillow -= 1;
		xp = CONFIG.xpPerPillowRest;
		detail = "Pillow is consumed for stronger rest XP.";
		spawnToken("item", "itemsBox", "careActionBox", "-pillow");
	} else if (request === "bored" && state.toy > 0) {
		state.toy -= 1;
		xp = CONFIG.xpPerToyPlay;
		detail = "Toy is consumed for stronger play XP.";
		spawnToken("item", "itemsBox", "careActionBox", "-toy");
	}

	state.careRequest = null;
	addDuckXp(xp);
	grantQuest("help", 1);
	markDirty();
	pulse("careRequestBox");
	pulse("careActionBox");
	pulse("profileBox");
	pulse("questsBox");
	spawnToken("xp", "careActionBox", "profileBox", `+${xp}`);
	setAction("Care", `${CARE_LABELS[request]} resolved. ${detail}`);
	addLog(`Care resolves ${CARE_LABELS[request]} for +${xp} XP.`);
}

function giveTreat() {
	state.duckTreat -= 1;
	addDuckXp(CONFIG.xpPerTreat);
	markDirty();
	pulse("itemsBox");
	pulse("profileBox");
	spawnToken("item", "itemsBox", "profileBox", "-treat");
	spawnToken("xp", "profileBox", "profileBox", `+${CONFIG.xpPerTreat}`);
	setAction("Give Treat", `A Treat gives +${CONFIG.xpPerTreat} XP to the selected duck.`);
	addLog("Treat is used from Duck Profile for targeted XP.");
}

function playEggCatch() {
	const coinsEarned = 8;
	state.coins += coinsEarned;
	state.duckFeed += 1;
	state.eggCatchTimer = 34;
	markDirty();
	pulse("eggCatchBox");
	pulse("coinsBox");
	pulse("itemsBox");
	spawnToken("coin", "eggCatchBox", "coinsBox", `+${coinsEarned}`);
	spawnToken("item", "eggCatchBox", "itemsBox", "+feed");
	setAction("Egg Catch", "A modest Egg Catch reward feeds back into the farm loop.");
	addLog(`Egg Catch reward grants ${coinsEarned} coins and Duck Feed x1.`);
}

function addDuckXp(amount) {
	if (state.duckLevel >= CONFIG.maxDuckLevel) {
		state.duckXp = 0;
		return;
	}

	state.duckXp += amount;
	while (state.duckXp >= CONFIG.xpPerLevel && state.duckLevel < CONFIG.maxDuckLevel) {
		state.duckXp -= CONFIG.xpPerLevel;
		state.duckLevel += 1;
		pulse("profileBox");
		addLog(`Duck levels up to ${state.duckLevel}.`);
	}

	if (state.duckLevel >= CONFIG.maxDuckLevel) {
		state.duckXp = 0;
	}
}

function grantQuest(questId, amount) {
	const questState = state.quest[questId];
	const questDef = QUESTS[questId];
	if (!questState || !questDef || amount <= 0) {
		return;
	}

	questState.progress += amount;
	const target = questDef.target * questState.level;
	if (questState.progress >= target) {
		questState.progress -= target;
		state.coins += questDef.rewardCoins * questState.level;
		questState.level += 1;
		pulse("questsBox");
		pulse("coinsBox");
		spawnToken("coin", "questsBox", "coinsBox", "+quest");
		addLog(`${capitalize(questId)} quest completes and grants coins.`);
	}
}

function getNextEggValueCost() {
	return CONFIG.eggValueCosts[state.eggValueLevel] || 0;
}

function getDuckCost() {
	return CONFIG.buyDuckBaseCost * Math.max(1, state.duckCount);
}

function getShopItem(itemId) {
	const items = {
		duckFeed: {
			stateKey: "duckFeed",
			cost: CONFIG.duckFeedCost,
			label: "Duck Feed",
			shortLabel: "feed",
		},
		premiumFeed: {
			stateKey: "premiumFeed",
			cost: CONFIG.premiumFeedCost,
			label: "Premium Feed",
			shortLabel: "premium",
		},
		duckTreat: {
			stateKey: "duckTreat",
			cost: CONFIG.treatCost,
			label: "Treat",
			shortLabel: "treat",
		},
		pillow: {
			stateKey: "pillow",
			cost: CONFIG.pillowCost,
			label: "Pillow",
			shortLabel: "pillow",
		},
		toy: {
			stateKey: "toy",
			cost: CONFIG.toyCost,
			label: "Toy",
			shortLabel: "toy",
		},
	};
	return items[itemId];
}

function markDirty() {
	state.saveTimer = 3;
	state.saveStatus = "Saving soon";
}

function render() {
	setValue("ducks", state.duckCount);
	setValue("ducksInline", state.duckCount);
	setValue("availableEggs", state.availableEggs);
	setValue("availableEggsInline", state.availableEggs);
	setValue("heldEggs", state.heldEggs);
	setValue("heldEggsInline", state.heldEggs);
	setValue("coins", state.coins);
	setValue("coinsInline", state.coins);
	setValue("eggValue", state.eggValue);
	setValue("eggValueLevel", state.eggValueLevel);
	setValue("eggValueCost", state.eggValueLevel < CONFIG.eggValueCosts.length ? getNextEggValueCost() : "Max");
	setValue("duckCost", getDuckCost());
	setValue("duckFeed", state.duckFeed);
	setValue("premiumFeed", state.premiumFeed);
	setValue("duckTreat", state.duckTreat);
	setValue("pillow", state.pillow);
	setValue("toy", state.toy);
	setValue("duckLevel", state.duckLevel);
	setValue("duckLevelInline", state.duckLevel);
	setValue("duckXp", state.duckXp);
	setValue("collectQuest", formatQuest("collect"));
	setValue("sellQuest", formatQuest("sell"));
	setValue("helpQuest", formatQuest("help"));
	elements.eggProgressBar.style.width = `${Math.min(100, state.eggProgress * 100)}%`;
	elements.xpProgressBar.style.width = `${state.duckLevel >= CONFIG.maxDuckLevel ? 100 : Math.min(100, state.duckXp)}%`;
	elements.careRequestText.textContent = state.careRequest
		? `${CARE_LABELS[state.careRequest]} waiting for player action.`
		: `No current request. Next request in ${Math.max(0, state.careTimer)}s.`;
	elements.weatherText.textContent = getWeatherText();
	elements.saveText.textContent = state.saveStatus;
	elements.guideText.textContent = getGuideText();
	renderDucks();
}

function setValue(name, value) {
	document.querySelectorAll(`[data-value="${name}"]`).forEach((element) => {
		element.textContent = String(value);
	});
}

function formatQuest(questId) {
	const questState = state.quest[questId];
	const questDef = QUESTS[questId];
	const target = questDef.target * questState.level;
	return `${questState.progress} / ${target}`;
}

function renderDucks() {
	elements.duckRow.innerHTML = "";
	const visible = Math.min(state.duckCount, 10);
	for (let index = 0; index < visible; index += 1) {
		const chip = document.createElement("span");
		chip.className = "duck-chip";
		chip.title = `Duck ${index + 1}`;
		elements.duckRow.appendChild(chip);
	}
}

function getWeatherText() {
	if (state.weather === "Cloudy") {
		return "Cloudy: dirty requests are more likely.";
	}
	if (state.weather === "Rainy") {
		return "Rainy: sleepy requests are more likely.";
	}
	if (state.weather === "Stormy") {
		return "Stormy: sleepy and dirty requests are more likely.";
	}
	return "Sunny: normal care rhythm.";
}

function getGuideText() {
	if (state.coins < 10 && state.duckCount === 1) {
		return "Guide focus: collect and sell until Egg Value is affordable.";
	}
	if (state.eggValueLevel === 0) {
		return "Guide focus: buy Egg Value after earning enough coins.";
	}
	if (state.duckCount < 2) {
		return "Guide focus: buy a duck to make production faster.";
	}
	if (state.duckFeed <= 0) {
		return "Guide focus: use Shop to keep care items stocked.";
	}
	return "Guide complete: the farm loop is open.";
}

function pulse(id, warn = false) {
	const element = document.getElementById(id);
	if (!element) {
		return;
	}

	element.classList.add("active");
	if (warn) {
		element.classList.add("warn");
	}
	window.setTimeout(() => {
		element.classList.remove("active", "warn");
	}, 720);
}

function clearActiveCards() {
	document.querySelectorAll(".component-card").forEach((element) => {
		element.classList.remove("active", "warn");
	});
}

function spawnToken(kind, fromId, toId, text) {
	const from = document.getElementById(fromId);
	const to = document.getElementById(toId);
	if (!from || !to) {
		return;
	}

	const start = getElementCenter(from);
	const end = getElementCenter(to);
	const token = document.createElement("span");
	token.className = `flow-token ${kind}`;
	token.textContent = text;
	token.style.left = `${start.x}px`;
	token.style.top = `${start.y}px`;
	document.body.appendChild(token);

	const dx = end.x - start.x;
	const dy = end.y - start.y;
	const animation = token.animate([
		{ transform: "translate(-50%, -50%) scale(0.9)", opacity: 0 },
		{ transform: "translate(-50%, -50%) scale(1)", opacity: 1, offset: 0.18 },
		{ transform: `translate(calc(-50% + ${dx}px), calc(-50% + ${dy}px)) scale(1)`, opacity: 1, offset: 0.82 },
		{ transform: `translate(calc(-50% + ${dx}px), calc(-50% + ${dy}px)) scale(0.8)`, opacity: 0 },
	], {
		duration: 880,
		easing: "cubic-bezier(.2,.8,.2,1)",
	});

	animation.addEventListener("finish", () => token.remove());
}

function getElementCenter(element) {
	const rect = element.getBoundingClientRect();
	return {
		x: rect.left + rect.width / 2,
		y: rect.top + rect.height / 2,
	};
}

function setAction(title, detail) {
	elements.actionTitle.textContent = title;
	elements.actionDetail.textContent = detail;
}

function addLog(text) {
	const item = document.createElement("li");
	item.textContent = `[${state.time}s] ${text}`;
	elements.eventLog.prepend(item);

	while (elements.eventLog.children.length > 16) {
		elements.eventLog.lastElementChild.remove();
	}
}

function capitalize(text) {
	return text.charAt(0).toUpperCase() + text.slice(1);
}

start();
