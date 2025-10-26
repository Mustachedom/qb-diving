local Translations = {
    error = {
        ["canceled"] = "Geannuleerd",
        ["911_chatmessage"] = "911 BERICHT",
        ["take_off"] = "/divingsuit om je duikpak uit te doen",
        ["not_wearing"] = "Je hebt geen duikuitrusting aan..",
        ["no_coral"] = "Je hebt geen koraal om te verkopen..",
        ["not_standing_up"] = "Je moet rechtop staan ​​om de duikuitrusting aan te trekken",
    },
    success = {
        ["took_out"] = "Je hebt je wetsuit uitgedaan",
    },
    info = {
        ["collecting_coral"] = "Koraal verzamelen",
        ["diving_area"] = "Duikgebied",
        ["collect_coral"] = "Verzamel koraal",
        ["collect_coral_dt"] = "[E] - Verzamel Koraal",
        ["checking_pockets"] = "Zakken controleren om koraal te verkopen",
        ["sell_coral"] = "Verkoop Koraal",
        ["sell_coral_dt"] = "[E] - Verkoop Koraal",
        ["blip_text"] = "911 - Duiklocatie",
        ["put_suit"] = "Doe een duikpak aan",
        ["pullout_suit"] = "Trek een duikpak uit ..",
        ["cop_msg"] = "Dit koraal is mogelijk gestolen",
        ["cop_title"] = "Illegaal duiken",
        ["command_diving"] = "Doe je duikpak uit",
    },
    warning = {
        ["oxygen_one_minute"] = "Je hebt minder dan 1 minuut lucht over",
        ["oxygen_running_out"] = "Je duikuitrusting heeft bijna geen lucht meer",
    },
    failedDist = {
        warn = '^3 [WAARSCHUWING] ^7 Speler ^7 (%{citizenid}) is niet geslaagd voor een afstandscontrole. ^1 (%{current}/3)',
        kicked = 'Je bent gekickt omdat je meerdere afstandscontroles niet hebt gehaald, het personeel is op de hoogte gebracht.',
    },
    sold = 'Je hebt %{amount} koraal verkocht voor $%{price}!',
}

if GetConvar('qb_locale', 'en') == 'nl' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
