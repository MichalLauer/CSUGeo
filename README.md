
<!-- README.md is generated from README.Rmd. Please edit that file -->

# csugeo

> K čemu projekt slouží?

[R Targets](https://books.ropensci.org/targets/) workflow který stahuje
data z portálu [CUZK](https://vdp.cuzk.cz/).

# Flow

> Jak skript funguje? <br/> Tvoří se nějaké důležité proměnné podle jaké
> speciální logiky? <br/>

Skript je složený z několika `month_` funkcí, které jsou po sobě logicky
volány v Targets workflow. Postup zpracování je následující:

- stažení .zip souboru s daty a rozbalení do *.csv*
- spojení všech *.csv* souboru do jedné tabulky reprezentující měsíc v
  daném roce
- spojení všech tabulek přes měsíce a roky do jedné historické tabulky

Finální historická tabulka sleduje to, jak se v čase měnili proměnné.
Pokud nějake adresní místo změnil např. do 2022-05-05, v datech to bude
reprezentováno pomocí sloupečků `plati_od` a `plati_do`

| kod_adm | plati_od   | plati_do   |
|---------|------------|------------|
| 1234    | 2022-05-06 | 2024-07-31 |
| 1234    | 2013-01-01 | 2022-05-05 |

Data ve sloupečku `plati_do` se generují manuálně. U posledního
(nejnovějšího) záznamu je v `plati_do` datum, kdy se naposledy dané
adresní místo vyskytovalo v datech od CZUK. Pokud se tedy adresní místo
přestalo vykazovat na konci listopadu 2021 (v tomto měsíci se naposledy
v datech vyskytl `kod_adm`), sloupec `plati_do` bude 2021-11-30. Ve
většině případů to ale bude poslední datum, které je staženo.

# Struktura

> Jaké relevantní složky jsou v projekty? <br/> Jsou tvořené
> automaticky? (✍️ - manuálně, 🤖 - automaticky) <br/>

- ✍️ `R/` - všechny hlavní funkce
- 🤖 `data_downloaded/` - stáhnutá data z CZUK ve formátu
  - `data_downloaded/rok/mesic/data.zip` - hlavní stažená data
  - `data_downloaded/rok/mesic/XXX.csv` - rozbalené *.csv* soubory
- 🤖 `data_joined/` - spojená data v *.parquet* formátu
  - `data_joined/joined_rok_mesic.paquert` - spojená data za daný měsíc
  - `data_joined/all.paquert` - finální spojená a opravená tabulka

# Spuštění

> Jak kód spusti? <br/> Co je hlavní (startovací) skript? <br/> Je nutné
> něco před tím stáhnout? <br/> Jsou nějaké problémy na které lze
> narazit? <br/>

Pro spuštění kódu stačí nakolonvat repositář a spustit v R konzoli
`targets::tar_make()`.

Občas se může stát, že skript spadne při stahování dat z CZUK, protože
dostanete timeout. V takovém případě stačí znovu spustit
`targets::tar_make()` a skript se restartuje v bodě, kde přestal.
Problém se snažím řešit pomocí `Sys.sleep(1)`, aby server nebyl tolik
zatížený, ale nefunguje to vždy.

# Poznámky

> Jsou data divná? <br/> Existují nějaké nekonzistence? <br/>

Data mění svoji strukturu, a to konkrétně mezi roky 2017 a 2018. V
nových datech jsou následující změny:

- přidaná proměnná `kod_momc`
- přidaná proměnná `kod_obvodu_prahy`
- proměnná `nazev_mop` je přejmenovaná na `nazev_obvodu_prahy`
- přidaná proměnná `kod_ulice`

Jelikož se `kod_` proměnné objevují až nově, jsou historicky (tam, kde
to je možné) doplněny. U těchto nových údajů není změnené datum
`plati_od` a proto je nutné kody doplnit ještě před tím, než se data
spojí.

Nespouštět poslední den v měsíci, jelikož se aktualizuje databáze ČZUK a
nefunguje žádný odkaz.

------------------------------------------------------------------------

TODO:

- možná prepsat z tar_map na normální tar_target(…, map = X)
- udělat mezikrok tak, aby si tar cachoval jak URL, tak jednotlivé CSV
  soubory
- fix duplicitních řádků
