
<!-- README.md is generated from README.Rmd. Please edit that file -->

# csugeo

> K čemu projekt slouží?

[R Targets](https://books.ropensci.org/targets/) workflow který stahuje
data z portálu [CUZK](https://vdp.cuzk.cz/).

# Flow

> Jak skript funguje? <br/> Tvoří se nějaké důležité proměnné podle jaké
> speciální logiky? <br/>

Parametry jsou managed pomocí {config}

Skript je složený z několika `month_` funkcí, které jsou po sobě logicky
volány v Targets workflow. Postup zpracování je následující:

- stažení .zip souboru s daty a rozbalení do *.csv*
- spojení všech *.csv* souboru do jedné tabulky reprezentující měsíc v
  daném roce
- spojení všech tabulek přes měsíce a roky do jedné historické tabulky

Finální historická tabulka sleduje to, jak se v čase měnili proměnné.
Pokud nějaké adresní místo změnil např. do 2022-05-05, v datech to bude
reprezentováno pomocí sloupečků `plati_od` a `plati_do`

| kod_adm | plati_od   | plati_do   |
|---------|------------|------------|
| 1234    | 2022-05-06 | 2024-07-31 |
| 1234    | 2013-01-01 | 2022-05-05 |

Data ve sloupečku `plati_do` se generují manuálně. U posledního
(nejnovějšího) záznamu je v `plati_do` datum, kdy se naposledy dané
adresní místo vyskytovalo v datech od CUZK. Pokud se tedy adresní místo
přestalo vykazovat na konci listopadu 2021 (v tomto měsíci se naposledy
v datech vyskytl `kod_adm`), sloupec `plati_do` bude 2021-11-30. Ve
většině případů to ale bude poslední datum, které je staženo.

# Struktura

> Jaké relevantní složky jsou v projekty? <br/> Jsou tvořené
> automaticky? (✍️ - manuálně, 🤖 - automaticky) <br/>

- ✍️ `R/` - všechny hlavní funkce
- 🤖 `data_downloaded/` - stáhnutá data z CUZK ve formátu
  - `data_downloaded/rok/mesic/rok-mesic-01.zip` - hlavní stažená data

# Spuštění

> Jak kód spustit? <br/> Co je hlavní (startovací) skript? <br/> Je
> nutné něco před tím stáhnout? <br/> Jsou nějaké problémy na které lze
> narazit? <br/>

Pro spuštění kódu stačí nakolonvat repositář a spustit v R konzoli
`targets::tar_make()`.

Občas se může stát, že skript spadne při stahování dat z CUZK, protože
dostanete timeout. V takovém případě stačí znovu spustit
`targets::tar_make()` a skript se restartuje v bodě, kde přestal.
Problém se snažím řešit pomocí `Sys.sleep(1)`, aby server nebyl tolik
zatížený, ale nefunguje to vždy.

# Poznámky

> Jsou data divná? <br/> Existují nějaké nekonzistence? <br/>

## Schéma

Zdrojová data v čase mění svou strukturu. První změna nastává mezi
říjnem a listopadem v r. 2017 (tedy mezi 2017-10 a 2017-11), kdy

- je přidaná proměnná `kod_momc`,
- přidaná proměnná `kod_obvodu_prahy`, a
- přidaná proměnná `kod_ulice`.

Druhá změna je na přelomu roku 2020/2021 (tedy mezi 2020-12 a 2021-1),
kdy jsou přejmenované dvě proměnné.

- `kod_mop` -\> `kod_obvodu_prahy`
- `nazev_mop` -\> `nazev_obvodu_prahy`

## Velikost

Všechna data zaberou min. 50Gb.
