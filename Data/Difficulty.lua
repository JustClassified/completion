-- Completion: hand corrections to the difficulty ratings (Difficulty.lua works out the rest).
-- ns.DIFFICULTY[achievementID] = { level, time, why }; any field may be nil to keep the rule's answer.
-- level 1 Easy, 2 Medium, 3 Hard, 4 Very hard; time quick, hour, hours, days, weeks, luck, wait.

local _, ns = ...

ns.DIFFICULTY = {
    -- big collections
    [62096] = { 3, "weeks", "600 usable mounts is a long collection" },
    [62103] = { 3, "weeks", "600 usable mounts is a long collection" },
    -- vision masks that need a perfect run
    [41883] = { 3, "hour", "All five objectives in one vision" },
    [41885] = { 3, "hour", "Every objective and every enemy in one vision" },
    -- reported as bugged or rarely possible
    [61958] = { 3, "weeks", "Some named bots rarely appear, and kills haven't always counted" },
    [61959] = { 3, "weeks", "Some named bots rarely appear, and kills haven't always counted" },
    [62215] = { 2, nil, "Players report it may not be completable right now" },
    [62216] = { 2, nil, "Players report it may not be completable right now" },
    -- time gated storylines
    [40844] = { nil, "weeks", nil },
    [63641] = { nil, "weeks", nil },
    -- whole-zone rare and treasure sweeps
    [62130] = { nil, "days", nil },
    [63358] = { nil, "days", nil },
}
