local Translations = {
    info = {
        givekey = "Get a key",
        resetlocks = "Change car locks",
        givekeyheader = "Choose car to get a key",
        givekeyitem = "%s (%s)",
        resetkeyheader = "Choose car to reset locks",
        resetkeyitem = "%s (%s)",
        blip = "Locksmith",
        hotwire = "~g~[H]~w~ - Hotwire",
        engine = 'Toggle Engine',
    },
    message = {
        not_initialized = "Locks are not initialized, please reset locks",
        key_received = "You received the key",
        locks_reset = "Locks changed for car",
        not_enough_money = "You have not enough money",
        temp_key_received = "You received a temporary key",
        vehicle_locked = "Vehicle locked!",
        vehicle_unlocked = "Vehicle unlocked!",
        no_key = "You don't have keys to this vehicle.",
        police = "Vehicle theft in progress. Type: %s",
        lockpicked = "You managed to pick the door lock open!",
        hotwiring = "Hotwiring the vehicle...",
        hotwiring_fail = "You fail to hotwire the car and get frustrated.",
    }
}

InsertTranslation(Translations, 'en')
