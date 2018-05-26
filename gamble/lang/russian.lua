local L = GAMBLE.LANG.RegisterLanguage("Russian")

// MAIN MENU
L.profile = "Профиль"
L.profile_desc = "Просматривайте и изменяйте настройки."

L.games = "Игры"
L.games_desc = "Крутые и интересные игры."

L.top = "Топ"
L.top_desc = "Лучшие игроки за всё время."

L.information = "Информация"
L.information_desc = "Информация про этот скрипт."

L.adminmenu = "Админ-Меню"
L.adminmenu_desc = "Управление скриптом."

L.back_to = "Назад в"

// Profile Tab
L.select_a_currency = "Выберите валюту..."
L.total_gain = "Доход"
L.balance = "Баланс" 
L.buy = "Купить"
L.sell = "Продать"

// Admin Tab
L.configuration = "Настройки"
L.player_management = "Управление игроками"
L.save = "Сохранить"
L.change = "Изменить"
L.nickname = "Никнейм"
L.total_amount_of_wins = "Общий доход"
L.amount_of_credits = "Количество кредитов"
L.find = "Найти"
L.find_by_steamid = "Найти игрока по SteamID"
L.set_credits_for = "Установить кредиты"
L.set = "Установить"
L.back = "Назад"

// Games
L.total = "Общая"
L.your_bet = "Ваша ставка"
L.waiting_for_a_bet = "Поставьте ставку..."
L.place_a_bet = "Поставить ставку"
L.latest_bets = "Последние ставки"
L.winners = "Победители"
L.logs = "Логи"
L.chat = "Чат"
L.bet = "Ставка"
L.place = "Поставить"
L.game_starts_in = "Игра начнется через {1} секунд..." -- {1}: time in seconds
L.who_will_win = "Кто победит?"
L.enter_msg = "Введите сообщение..."
L.send = "Отправить"
L.wait = "Секундочку..."
L.payout = "Вы получите x{1} выплату!" -- {1}: multiplier
L.already_placed = "Вы уже поставили ставку."
L.cant_afford = "У вас не хватает кредитов."
L.unable = "Вы не можете сделать это в данный момент."
L.won = "выиграл"
L.open_profile = "Открыть профиль Steam"

// Bugs' Race
L.bug_bet = "Поставить на {1} жука" -- {1}: bug's number with ordinal suffix
L.bug_msg_placed = "{1} поставил {2} {3} на {4} жука." -- {1}: nickname, {2}: amount of credits, {3}: currency name, {4}: bug's number with ordinal suffix
L.bug_won = "{1} жук победил в гонке!" -- {1}: bug's number with ordinal suffix

// Jackpot
L.j_msg_placed = "{1} поставил {2} {3}" -- {1}: nickname, {2}: amount of credits, {3}: currency name
L.j_start_in = "Игра начнется через {1} секунд..." -- {1}: delay in seconds
L.j_winning_ticket = "Победный билет"

// Roulette
L.click_to_place = "Нажмите, чтобы поставить ставку."
L.bet_on = "Поставить на"
L.r_msg_placed = "{1} поставил {2} {3} на {4}" -- {1}: nickname, {2}: amount of credits, {3}: currency name, {4}: bet
L.winning_number = "Победный номер: "

// CONFIG
L.config_TopRefresh = "Как часто обновлять топ (в минутах)?"
L.config_exchange_darkrpmoney = "Курс обмена DarkRP денег (0 - отключить)."
L.config_exchange_ps1 = "Курс обмена PointShop 1 поинтов (0 - отключить)."
L.config_exchange_ps2 = "Курс обмена PointShop 2 поинтов (0 - отключить)."
L.config_exchange_ps2_premium = "Курс обмена PointShop 2 премиум поинтов (0 - отключить)."
L.config_exchange_payandplay = "Курс обмена \"Pay & Play\" денег (0 - отключить)."
L.config_language = "Язык скрипта"
L.config_gamble_currency = "Название главной валюты (станд.: CR)"
L.config_npc_only = "Открывать меню только при взаимедойствии с NPC (1 - вкл., 0 - откл.)."
L.config_npc_model = "Модель NPC."
L.config_npc_name = "Имя NPC."
L.config_enablechatcommand = "Включить консольную команду? (1 - вкл., 0 - откл.)."

// 1.0.5 version
L.config_freegame = "Бесплатная игра (1 - включить)"
L.config_jackpot_maxbet = "Макс. ставка Jackpot (0 - отключить лимит)"