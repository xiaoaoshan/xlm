XLM = XLM or {}

local DEFAULT_DB = {
    selectedDict = "cet4",
    totalTyped = 0,
    correctTyped = 0,
    wrongTyped = 0,
    exp = 0,
    level = 1,
    streak = 0,
    mastered = {},
    wrongWords = {},
    recent = {},
}

local LEVEL_EXP = 300

local function CopyDefaults(target, defaults)
    if type(target) ~= "table" then
        target = {}
    end

    for key, value in pairs(defaults) do
        if type(value) == "table" then
            target[key] = CopyDefaults(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end

    return target
end

function XLM:InitDB()
    XLM_DB = CopyDefaults(XLM_DB, DEFAULT_DB)
    self.db = XLM_DB

    if XLM_DICT_MAP and not XLM_DICT_MAP[self.db.selectedDict] then
        self.db.selectedDict = "cet4"
    end

    if self.db.selectedDict == "oi_xcpc" or self.db.selectedDict == "js_array" then
        self.db.selectedDict = "cet4"
    end
end

function XLM:GetDB()
    if not self.db then
        self:InitDB()
    end
    return self.db
end

function XLM:GetLevelExp()
    return LEVEL_EXP
end

function XLM:AddRecent(word, correct)
    local db = self:GetDB()
    table.insert(db.recent, 1, {
        word = word.name,
        dict = word.dictName,
        correct = correct,
        time = time(),
    })

    while #db.recent > 5 do
        table.remove(db.recent)
    end
end

function XLM:AddCorrect(word)
    local db = self:GetDB()
    local key = word.dictId .. ":" .. word.name

    db.totalTyped = db.totalTyped + 1
    db.correctTyped = db.correctTyped + 1
    db.streak = db.streak + 1
    db.exp = db.exp + 10
    db.mastered[key] = true
    db.wrongWords[key] = nil

    while db.exp >= LEVEL_EXP do
        db.exp = db.exp - LEVEL_EXP
        db.level = db.level + 1
    end

    self:AddRecent(word, true)
end

function XLM:AddWrong(word, typed)
    local db = self:GetDB()
    local key = word.dictId .. ":" .. word.name
    local record = db.wrongWords[key]

    db.totalTyped = db.totalTyped + 1
    db.wrongTyped = db.wrongTyped + 1
    db.streak = 0

    if not record then
        record = {
            dictId = word.dictId,
            name = word.name,
            trans = word.trans,
            wrongCount = 0,
            lastTyped = "",
            lastWrongTime = 0,
        }
        db.wrongWords[key] = record
    end

    record.wrongCount = (record.wrongCount or 0) + 1
    record.lastTyped = typed or ""
    record.lastWrongTime = time()

    self:AddRecent(word, false)
end

function XLM:GetAccuracy()
    local db = self:GetDB()
    if db.totalTyped == 0 then
        return 0
    end
    return math.floor((db.correctTyped / db.totalTyped) * 100 + 0.5)
end

function XLM:GetWrongList()
    local db = self:GetDB()
    local list = {}

    for key, record in pairs(db.wrongWords) do
        record.key = key
        table.insert(list, record)
    end

    table.sort(list, function(a, b)
        return (a.lastWrongTime or 0) > (b.lastWrongTime or 0)
    end)

    return list
end

function XLM:GetWrongCount()
    local db = self:GetDB()
    local count = 0
    for _ in pairs(db.wrongWords) do
        count = count + 1
    end
    return count
end

function XLM:ClearWrongWords()
    self:GetDB().wrongWords = {}
end
