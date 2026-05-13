XLM = XLM or {}

-- SPDX-License-Identifier: GPL-3.0-or-later
-- Vocabulary data copied/adapted from qwerty-learner:
-- https://github.com/RealKai42/qwerty-learner
-- qwerty-learner is licensed under GNU GPL-3.0.

XLM_DICTIONARIES = {}

XLM_DICT_MAP = {}

for _, dict in ipairs(XLM_DICTIONARIES) do
    XLM_DICT_MAP[dict.id] = dict
    for _, word in ipairs(dict.words) do
        word.dictId = dict.id
        word.dictName = dict.name
    end
end

function XLM:GetSelectedDictionary()
    local db = self:GetDB()
    return XLM_DICT_MAP[db.selectedDict] or XLM_DICTIONARIES[1]
end

function XLM:SetSelectedDictionary(dictId)
    if XLM_DICT_MAP[dictId] then
        self:GetDB().selectedDict = dictId
    end
end

function XLM:GetRandomWord()
    local dict = self:GetSelectedDictionary()
    if not dict or #dict.words == 0 then
        return nil
    end
    return dict.words[random(#dict.words)]
end

function XLM:GetWordByKey(key)
    local dictId, name = string.match(key or "", "^([^:]+):(.+)$")
    local dict = dictId and XLM_DICT_MAP[dictId]
    if not dict then
        return nil
    end
    for _, word in ipairs(dict.words) do
        if word.name == name then
            return word
        end
    end
    return nil
end
