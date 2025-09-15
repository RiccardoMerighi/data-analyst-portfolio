// File .do Case Study NSG Merighi Riccardo 2025
// NSG Distrettuale


// INIZIALIZZAZIONE
//----------------------------------------------------------------------------
// gli dico di utilizzare il file .dta della mia cartella
use "NSG_Merighi206929", clear

// mi apre il file .dta della mia cartella
browse

// DESCRIZIONE DEL DATASET
describe

count
sort Regione Year
browse
drop if Regione==""
count
tab Regione 
tab Year
di 21*6
// Dataset panel composto da 126 osservazioni (21 regioni X 6 anni)

//----------------------------------------------------------------------------
// dummyzzo la variabile Year dal 2017 al 2022
// con tabulate mi dice le caratteristiche della variabile
tabulate Year, generate(Year_dummy)

// Year_dummy1=2017
// Year_dummy2=2018
// Year_dummy3=2019
// Year_dummy4=2020
// Year_dummy5=2021
// Year_dummy6=2022
//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
// raccolgo gli indicatori CORE in un solo indicatore
// per richiamare la variabile macro utilizzo il simbolo $
global Indicatori_Core D03C D09Z D10Z D14C D22Z_CIA1 D22Z_CIA2 D22Z_CIA3 D27C D30Z D33Za

// raccolgo gli indicatori NO CORE in un solo indicatore
global Indicatori_NoCore D01C_Nocore D02C_Nocore D05C_Nocore D06C_Nocore D07Ca_Nocore D07Cb_Nocore D08C_Nocore D11Z_Nocore D12C_Nocore D13C_Nocore D15C_Nocore D16C_Nocore D17C_Nocore D18C_Nocore D19C_Nocore D21Z_Nocore D23Z_Nocore D24C_Nocore D25C_Nocore D26C_Nocore D28C_Nocore D29C_Nocore D31C_Nocore D32Z_Nocore
*/
//----------------------------------------------------------------------------


// Mi dice tutte le variabili mancanti del dataset
misstable summarize
// Elimino le variabili mancanti dal dataset
drop if missing(D09Z) | missing(D22Z_CIA1) | missing(D22Z_CIA2) | missing(D22Z_CIA3) | missing(D33Za)
//----------------------------------------------------------------------------





//----------------------------------------------------------------------------
// PARTE DESCRITTIVA

// Valori descrittivi degli indicatori
summarize $Indicatori_Core
summarize $Indicatori_NoCore
//


// Matrice di correlazione tra gli indicatori CORE e NSG Distrettuale
pwcorr $Indicatori_Core NSGCOREDIS, star(95)
// Risulta che tutti gli indicatori CORE sono significativi al 95% perciò confermo l'ipotesi che sono loro che creano il NSGSCORE DISTRETTUALE finale
// I più correlati positivamente con NSG sono D22Z_CIA1 (0.621), D30Z (0.594) e D33Za (0.515), 
// I più correlati negativamente con NSG sono D09Z (-0.622) e D27C (-0.303)



// Controllo se c'è multicollinearità tra le variabili D22Z
corr D22Z_CIA1 D22Z_CIA2 D22Z_CIA3
reg NSGCOREDIS D22Z_CIA1 D22Z_CIA2 D22Z_CIA3 
vif
// Utilizzo il comando vif(Variance Inflation Factor), tutti i valori sono al di sotto della soglia critica (VIF < 5)
//Perciò non si crea multicollinearità e posso inserirle tutte e 3 nel modello


// Controllo se c'è multicollinearità tra le variabili Year_dummy
corr Year_dummy1 Year_dummy2 Year_dummy3 Year_dummy4 Year_dummy5 Year_dummy6
reg Year_dummy1 Year_dummy2 Year_dummy3 Year_dummy4 Year_dummy5 Year_dummy6
//Inserisco le variabili dummy per gli anni Year_dummy1–Year_dummy6. Il modello ci mostra che includere tutte le categorie simultaneamente nel modello genera perfetta multicollinearità
//Dai risultati della regressione (R2=1, MSE=0, stime perfette). Dunque dobbiamo escludere una Year_dummy e interpretare i coefficienti in relazione alla categoria omessa
//----------------------------------------------------------------------------






//----------------------------------------------------------------------------
 // PARTE ECONOMETRICA

 // ANALISI DEL TREND PER REGIONE
 // Il primo mostra il trend del finanziamento sanitario pro-capite per regione dal 2017 al 2022
 // Il secondo mostra il trend dell'aspettativa di vita per regione dal 2017 al 2022
 twoway (line EXP_VITA Year, by(Regione))
 twoway (line FIN_PROCAP Year, by(Regione))
 reg EXP_VITA Year
 est store ModelloEXP
 est tab ModelloEXP, b(%9.4f)  stat(N r2 aic bic)  star( .10 .05 .01)


 
 

//----------------------------------------------------------------------------
// MODELLO6 IMPATTO DEGLI INDICATORI
// Standardizzo tutti gli indicatori perchè alcune variabili hanno scale differenti, allora le standardizzo per evitare che le variabili sbilancino la regressione

gen lNSGSCOREDIS = ln(NSGCOREDIS)
hist lNSGSCOREDIS , normal

egen D03C_std = std(D03C)
egen D09Z_std = std(D09Z)
egen D10Z_std = std(D10Z)
egen D14C_std = std(D14C)
egen D022Z_CIA1_std = std(D22Z_CIA1)
egen D022Z_CIA2_std = std(D22Z_CIA2)
egen D022Z_CIA3_std = std(D22Z_CIA3)
egen D27C_std = std(D27C)
egen D30Z_std = std(D30Z)
egen D33Za_std = std(D33Za)


//----------------------------------------------------------------------------
// Modello6 con indicatori CORE standardizzati per avere meno sbilanciamento
regress NSGCOREDIS D03C_std D09Z_std D10Z_std D14C_std D022Z_CIA1_std D022Z_CIA2_std D022Z_CIA3_std D27C_std D30Z_std D33Za_std Year_dummy2 Year_dummy3 Year_dummy4 Year_dummy5 Year_dummy6
est store Modello6
est tab Modello6, b(%9.4f)  stat(N r2 aic bic)  star( .10 .05 .01)

// Genero la variabile dei residui: differenza tra i valori osservati (lNSGSCOREDIS) e quelli predetti (lfitted_values) dal modello
predict fitted_values, xb
gen residual=NSGCOREDIS-fitted_values

// Utilizzo la Kernal Density per confrontare la distribuzione degli errori attesi con una distribuzione normale, noto che la distribuzione è molto simmetrica.
kdensity residual, normal
//----------------------------------------------------------------------------





//----------------------------------------------------------------------------
// FINANZIAMENTO SANITARIO PRO-CAPITE e NSG SCORE DISTRETTUALE
// FOCUS SULL' EMILIA-ROMAGNA

//Descrizione degli indicatori Emilia-Romagna
sum D03C D09Z D10Z D14C D22Z_CIA1 D22Z_CIA2 D22Z_CIA3 D27C D30Z D33Za if Regione == "EMILIA ROMAGNA"
sum FIN_PROCAP EXP_VITA if Regione == "EMILIA ROMAGNA"

// SCATTERPLOT 1 - Andamento dell'NSG SCORE distrettuale in Emilia-Romagna dal 2017 al 2022
twoway (line NSGCOREDIS Year if Regione == "EMILIA ROMAGNA"), ///
       title("Andamento Score NSG - Emilia-Romagna (2017–2022)") ///
       ytitle("Score NSG") xtitle("Anno")


// Prima identifichiamo i valori medi dell'Emilia Romagna
sum FIN_PROCAP if Regione == "EMILIA ROMAGNA", meanonly
local emilia_fin = r(mean)
//sum EXP_VITA if Regione == "EMILIA ROMAGNA", meanonly
//local emilia_exp = r(mean)

// Creo la variabile Sim  per le regioni simili per finanziamento pro-capita e aspettativa di vita all'Emilia Romagna (con un range +-100 e +-0.5)
gen Sim = (FIN_PROCAP >= `emilia_fin'-50 & FIN_PROCAP <= `emilia_fin'+50)

			 
// SCATTERPLOT 2 - Andamento del'Indicatore D09Z per anno dell'Emilia Romagna e regioni simili per finanziamento pro-capite e aspettative di vita
twoway (scatter D09Z Year if Regione == "EMILIA ROMAGNA", mcolor(red) msymbol(D) msize(large)) ///
       (scatter D09Z Year if Sim == 1 & Regione != "EMILIA ROMAGNA", mlabel(Regione) mlabposition(0)) ///
       (line D09Z Year if Regione == "EMILIA ROMAGNA", lcolor(red) lwidth(medthick)) ///
       (line D09Z Year if Sim == 1 & Regione != "EMILIA ROMAGNA", lcolor(gs10) lpattern(dash)), ///
       title("D09Z: Intervallo Allarme-Target dei mezzi di soccorso") ///
       subtitle("Regioni simili all'Emilia-Romagna per finanziamento pro-capite") ///
       ytitle("Valore D09Z") xtitle("Anno") ///
       legend(order(1 "Emilia Romagna" 2 "Altre regioni simili")) ///
       note("Criteri di similarità: Fin. pro-capite ±50 dai valori medi Emilia Romagna")

	   
// SCATTERPLOT 3 - Andamento del'Indicatore D27C per anno dell'Emilia Romagna e regioni simili per finanziamento pro-capite e aspettative di vita
twoway (scatter D27C Year if Regione == "EMILIA ROMAGNA", mcolor(red) msymbol(D) msize(large)) ///
       (scatter D27C Year if Sim == 1 & Regione != "EMILIA ROMAGNA", mlabel(Regione) mlabposition(0)) ///
       (line D27C Year if Regione == "EMILIA ROMAGNA", lcolor(red) lwidth(medthick)) ///
       (line D27C Year if Sim == 1 & Regione != "EMILIA ROMAGNA", lcolor(gs10) lpattern(dash)), ///
       title("D27C: Percentuale di re-ricoveri tra 8 e 30 giorni in psichiatria") ///
       subtitle("Simili per finanziamento pro-capite") ///
       ytitle("Valore D27C") xtitle("Anno") ///
       legend(order(1 "Emilia Romagna" 2 "Altre regioni simili")) ///
       note("Criteri di similarità: Fin. pro-capite ±50 dai valori medi Emilia Romagna")


// SCATTERPLOT 4 - Andamento del'Indicatore D10Z per anno dell'Emilia Romagna e regioni simili per finanziamento pro-capite e aspettative di vita
twoway (scatter D10Z Year if Regione == "EMILIA ROMAGNA", mcolor(red) msymbol(D) msize(large)) ///
       (scatter D10Z Year if Sim == 1 & Regione != "EMILIA ROMAGNA", mlabel(Regione) mlabposition(0)) ///
       (line D10Z Year if Regione == "EMILIA ROMAGNA", lcolor(red) lwidth(medthick)) ///
       (line D10Z Year if Sim == 1 & Regione != "EMILIA ROMAGNA", lcolor(gs10) lpattern(dash)), ///
       title("D10Z: Percentuale di prestazioni della classe di priorità B") ///
       subtitle("Simili per finanziamento pro-capite e aspettativa di vita") ///
       ytitle("Valore D10Z") xtitle("Anno") ///
       legend(order(1 "Emilia Romagna" 2 "Altre regioni simili")) ///
       note("Criteri di similarità: Fin. pro-capite ±50 dai valori medi Emilia Romagna")


// SCATTERPLOT 5 - Confronto tra tutte le regioni per l'anno 2022 tra finanziamento sanitario pro-capite e NSG distrettuale	   
twoway (scatter FIN_PROCAP NSGCOREDIS if Year == 2022, ///
        mlabel(Regione) msymbol(O) mcolor(blue)), ///
        title("NSG Score distrettuale vs Finanziamento pro-capite (anno 2022)") ///
        xtitle("Score NSG distrettuale") ///
        ytitle("Finanziamento sanitario pro-capite (€)") ///
        xlabel(40(10)100) ///
        legend(off)
	   
	  
// SCATTERPLOT 6 - Guardo se un incremento del finanziamento sanitario pro-capite negli anni (2017-2022) per regioni simili all'Emilia Romagna per finanziamento sanitario pro-capite ha portato a miglioramenti dell'NSG Distrettuale
gen simili = (FIN_PROCAP >= 1000 & FIN_PROCAP <= 3000)

twoway (scatter FIN_PROCAP NSGCOREDIS if Year == 2017 & simili == 1 & ///
        (Regione == "VENETO" | Regione == "EMILIA ROMAGNA" | Regione == "CALABRIA" | Regione == "LAZIO" | Regione == "VALLE D'AOSTA" | Regione == "ABRUZZO" | Regione == "BASILICATA" | Regione == "CAMPANIA"), ///
        mcolor(blue) msymbol(O) mlabel(Regione) mlabposition(3) mlabsize(small)) ///
       (scatter FIN_PROCAP NSGCOREDIS if Year == 2022 & simili == 1 & ///
        (Regione == "VENETO" | Regione == "EMILIA ROMAGNA" | Regione == "CALABRIA" | Regione == "LAZIO" | Regione == "VALLE D'AOSTA" | Regione == "ABRUZZO" | Regione == "BASILICATA" | Regione == "CAMPANIA"), ///
        mcolor(red) msymbol(D) mlabel(Regione) mlabposition(9) mlabsize(small)), ///
       title("NSG Distrettuale vs Finanziamento pro capite") ///
       xtitle("Score NSG distrettuale") ///
       ytitle("Finanziamento sanitario pro capite (€)") ///
       xscale(range(2 3.4)) ///
       legend(order(1 "2017" 2 "2022")) ///
       plotregion(margin(l=5 r=5))





	   
//-------------------------------------------------------------------------------------------------------------	   
/* ULTERIORI ANALISI CHE HO PROVATO A FARE
 /*
//----------------------------------------------------------------------------
// MODELLO 1: regressione lineare per spiegare NSGCOREDIS con dummy anni di riferimento 2017
// la variabile cons rappresenta l'intercetta, il valore previsto della variabile dipendente (NSGCOREDIS) quando tutte le variabili indipendenti sono pari a zero
// per toglierla usare nocons
// Chiamo la regressione lineare con il comando est store: "Modello1"
// Per sostituire il pvalue numerico con quello ad asterischi utilizzo il comando star

regress NSGCOREDIS $Indicatori_Core Year_dummy2 Year_dummy3 Year_dummy4 Year_dummy5 Year_dummy6 
est store Modello1
est tab Modello1, b(%9.4f)  stat(N r2 aic bic)  star( .10 .05 .01)

// Risultati: 
// R^2 corretto 0.926 molto alto, l' 92.60% della variabilità di NSGCOREDIS è spiegata dalle variabili indipendenti del modello.
//Year_dummy6 (2022) = -2.1: Questo significa che, rispetto all'anno di riferimento Year_dummy1 (2017), c'è una diminuizione di 2.1 unità in NSGCOREDIS. Però è poco significativa nel modello 
//----------------------------------------------------------------------------




//----------------------------------------------------------------------------
// MODELLO 2: regressione lineare per spiegare NSGCOREDIS con dummy anni media tra 2017-2021
// Chiamo la regressione lineare con il comando est store: "Modello2"
// Per sostituire il pvalue numerico con quello ad asterischi utilizzo il comando star

regress NSGCOREDIS D03C D09Z D10Z D14C D22Z_CIA1 D22Z_CIA2 D22Z_CIA3 D27C D30Z D33Za Year_dummy6
est store Modello2
est tab Modello2, b(%9.4f)  stat(N r2 aic bic)  star( .10 .05 .01)
predict fitted_values, xb
gen residual=NSGCOREDIS - fitted_values


// Utilizzo la Kernal Density che ci dice l'errore che assume il modello rispetto alle assunzioni che abbiamo fatto sui nostri residui e confrontiamo la distribuzione dei residui con una distribuzione normale
kdensity residual, normal
pnorm residual
qnorm residual
hist residual, normal

// faccio lo scatter plot dei residui contro i fitted value
scatter residual fitted_values

// faccio il test di White per vedere se c'è eteroschedasticità
estat imtest, white
// il pavlue = 0.0032 quindi inferiore a ogni livello di alfa e quindi rifiuto l'ipotesi nulla e affermo che c'è eteroscehdasticità


//Dopo aver stimato un modello OLS base (Modello 2) e analizzato i residui, si è osservata una possibile presenza di eteroschedasticità, confermata dal test di White (p < 0.05). Allora procedo con un modello con errori robusti (Modello 3), però non si modificano i coefficienti

// MODELLO3: rifaccio il test con gli errori standard robusti "robust"
regress NSGCOREDIS D03C D09Z D10Z D14C D22Z_CIA1 D22Z_CIA2 D22Z_CIA3 D27C D30Z D33Za Year_dummy6, robust 
est store Modello3
est tab Modello3, b(%9.4f)  stat(N r2 aic bic)  star( .10 .05 .01)

// Confronto coefficienti ed errori standard del Modello2 e Modello3 (senza interpretare R/AIC/BIC)
esttab Modello2 Modello3, se star(* 0.10 ** 0.05 *** 0.01) stats(N r2 aic bic) label addnote("Modello 2 e Modello 3 comparati")

// Risultati:
/*
* R^2 corretto=0.926 molto alto, il 92,60% della variabilità di NSGCOREDIS è spiegata dalle variabili indipendenti del modello.
* AIC=701.5 e BIC=734.7

*1) D03C (Tasso di ospedalizzazione per complicanze diabete, BPCO, scompenso cardiaco) = -0.0446
*Significativo all' 1% (***), quindi molto robusto.
*Interpretazione: un aumento di 1 unità del tasso di ospedalizzazione per complicanze croniche *riduce NSGCOREDIS di 0.0446 unità.
*Possibile spiegazione: più ricoveri per complicanze croniche potrebbero indicare una gestione *meno efficace dei pazienti cronici sul territorio, portando a un peggioramento degli indicatori *di performance.

*2) D09Z (Tempo di intervento dei mezzi di soccorso) = -2.744
*Significativo a livello 1% (***), quindi molto robusto.
*Interpretazione: Se i mezzi di soccorso impiegano più tempo per raggiungere i pazienti, *NSGCOREDIS diminuisce di circa 2.74 unità per ogni incremento del tempo di risposta.
*Possibile spiegazione: ritardi nei soccorsi peggiorano la qualità dell'assistenza sanitaria, *riducendo la performance del sistema sanitario.

*3) D10Z (Prestazioni di classe B garantite entro i tempi) = +14.16
*Significativo all' 1% (***), quindi molto robusto.
*Interpretazione: Se aumenta la percentuale di prestazioni erogate nei tempi previsti per la *classe B, NSGCOREDIS aumenta di 14.16 unità per ogni prestazione erogata.
*Possibile spiegazione: la puntualità nelle prestazioni sanitarie è un indicatore di efficienza e *di qualità del servizio, migliorando le performance complessive.

*4) D14C (Consumo di farmaci sentinella/traccianti) = -0.00117
*E' significativo al 90%.
*Interpretazione: un aumento del consumo di farmaci sentinella è associato a una lieve riduzione *di NSGCOREDIS.
*Possibile spiegazione: un maggior consumo di questi farmaci potrebbe riflettere un peggioramento *delle condizioni sanitarie della popolazione, riducendo le performance generali.

5) D22Z_CIA1 (Tasso di pazienti trattati in Assistenza Domiciliare Integrata - ADI per intensità di cura - CIA 1: Assistenza di bassa intensità, con interventi meno frequenti e meno complessi - CIA < 0,14) = +0.697 significativo al 95%
	Un aumento di 1 unità nell'indicatore D22Z_CIA1  è associato a un aumento medio di 0.697 unità nella variabile dipendente (NSGCOREDIS)

6) D22Z_CIA2 (Tasso di pazienti trattati in Assistenza Domiciliare Integrata - ADI per intensità di cura - CIA 2: Assistenza di media intensità, con interventi più frequenti e complessi - 0,14 ≤ CIA ≤ 0,30) = +1.196significativo al 95%
	Un aumento dell'intensità media (CIA2) è associato a un aumento ancora maggiore (1.196) di NSGCOREDIS, il secondo livello ha un impatto più forte.

7) D22Z_CIA3 (Tasso di pazienti trattati in Assistenza Domiciliare Integrata - ADI per intensità di cura - CIA 3: Assistenza di alta intensità, con interventi molto frequenti e complessi, spesso quotidiani - CIA > 0,30) = -0.195 e non è significativo pe rnessun livello di alfa

Il valore del CIA è calcolato come il rapporto tra le Giornate di Effettiva Assistenza (GEA) e le Giornate di Cura (GdC). Un valore più alto indica un'intensità assistenziale maggiore

*8) D27C (Percentuale di re-ricoveri in psichiatria) = -353.2
*Significativo all' 1% (***), quindi molto robusto.
*Interpretazione: più re-ricoveri psichiatrici si verificano, più NSGCOREDIS cala drasticamente.
*Possibile spiegazione: un'alta percentuale di re-ricoveri indica una gestione inefficace della *salute mentale sul territorio, con un impatto devastante sulle performance del sistema.

*9) D30Z (Pazienti oncologici assistiti dalle cure palliative) = +28.82
*Significativo all' 1% (***), quindi molto robusto.
*Interpretazione: più pazienti oncologici ricevono cure palliative, più NSGCOREDIS aumenta.
*Possibile spiegazione: una maggiore copertura delle cure palliative è indice di una sanità più attenta alla qualità di vita dei pazienti terminali, migliorando la performance sanitaria.

*Year_dummy6 (2022) = -3.770
*Il coefficiente di Year_dummy6 (2022) è pari a -3.5877 ed è significativo al 5% (**). Questo *indica che, rispetto alla media degli anni di riferimento (2017-2021), nel 2022 la variabile *NSGCOREDIS è stata in media 4.660 unità più bassa. L'effetto negativo potrebbe essere spiegato *da fattori come le conseguenze a lungo termine della pandemia COVID-19, che hanno portato a un *aumento della domanda di servizi sanitari o a una riduzione delle risorse disponibili.

//Dopo la verifica dell'eteroschedasticità con il test di White, è stato stimato un modello con errori robusti, i coefficienti rimangono invariati, mentre la variabile D14C, non risulta più significativa, dimostrando l'importanza di aggiungere gli errori standard robusti al modello





// INTERAZIONI
/*
// PROVA CON INTERAZIONE TRA INDICATORI CORE e NO CORE
//----------------------------------------------------------------------------
//MODELLO 4: Provo a creare un interazione tra gli indicatori D03C (CORE), D01C (NO CORE)
// L'interazione potrebbe essere interessante perchè presta attenzione legame tra l'efficacia della medicina territoriale (misurata da D03C) e gli esiti a lungo termine dopo un evento cardiovascolare acuto (misurati da D01C).
// Int1 = D03C*D01C 

gen Int1 = D03C * D01C

// ora provo a inserirla nel modello ideale MODELLO2
regress NSGCOREDIS D09Z D10Z D27C D30Z Year_dummy6 Int1
est store Modello4
est tab Modello4, b(%9.4f)  stat(r2 aic bic)  star( .10 .05 .01)
// l'interazione (Int1) tra due indicatori uno core (D03C) e uno non core (D01C) risulta significativa al 99% con un coefficiente negativo -0,178

esttab Modello2 Modello4, se star(* 0.10 ** 0.05 *** 0.01) stats(N r2 aic bic)

//----------------------------------------------------------------------------




// PROVA CON INTERAZIONE TRA INDICATORI CORE
//----------------------------------------------------------------------------
//MODELLO 5: La logica è che magari una risposta rapida ed efficace del sistema di emergenza (D09Z) potrebbe avere un impatto maggiore sugli esiti (che potrebbero essere indirettamente riflessi in una variabile dipendente legata alla performance distrettuale o agli esiti di eventi acuti) in regioni dove la gestione delle patologie croniche è meno efficace (tassi più alti di D03C).
gen Int2 = D03C * D09Z

// ora provo a inserirla nel modello ideale MODELLO2
regress NSGCOREDIS D10Z D14C D22Z_CIA1 D22Z_CIA2 D22Z_CIA3 D27C D30Z D33Za Year_dummy6 Int2
est store Modello5
est tab Modello5, b(%9.4f)  stat(r2 aic bic)  star( .10 .05 .01)

esttab Modello3 Modello5, se star(* 0.10 ** 0.05 *** 0.01) stats(N r2 aic bic) label addnote("Modello 3 e Modello 5 comparati")
// r2 diminuisce (0.831), il modello con l'interazione non spiega bene i dati quanto al modello senza interazione. L'interazione (Int2) è statisticamente significativa con un p-value basso (0.000781) e yb coefficiente negativo (-0.00491), e questo potrebbe indicare che l'effetto combinato di D03C e D09Z è rilevante.
//----------------------------------------------------------------------------
*/



//----------------------------------------------------------------------------
 // MODELLO LOG NSG Distrettuale
// IMPATTO DEGLI INDICATORI
/*
// Faccio la trasformazione logaritmica di NSGCOREDIS e  l'istogramma per fare il confronto con una distribuzione normale per vedere la distribuzione degli errori del NSG Distrettuale
gen lNSGSCOREDIS = ln(NSGCOREDIS)
hist lNSGSCOREDIS , normal


// MODELLOLOG: ci permette di interpretare i coefficienti come variazioni percentuali del NSGSCOREDIS dopo un incremento unitario delle variabili indipendenti
// Utilizzo il comando Beta perchè gli indicatori hanno i valori grezzi, non standardizzati e aggiustati, infatti hanno scale di misura differenti e per confrontarle utilizzo i coefficienti standardizzati Beta
// Questo comando ci permette di confrontare l'impatto degli indicatori con la variazione della deviazione standard e non di un'unità dell'indicatore
// Utilizzo anche gli errori standard robusti per evitare l'ipotesi di eteroschedasticità

reg lNSGSCOREDIS D03C D09Z D10Z D14C D22Z_CIA1 D22Z_CIA2 D22Z_CIA3 D27C D30Z D33Za Year_dummy6, beta robust 
est store ModelloLog
est tab ModelloLog, b(%9.4f)  stat(r2 aic bic)  star( .10 .05 .01)
predict lfitted_values, xb
gen lresidual=lNSGSCOREDIS-lfitted_values

// Genero la variabile dei residui: differenza tra i valori osservati (lNSGSCOREDIS) e quelli predetti (lfitted_values) dal modello

// Risultati:
/*
1) R2 corretto = 0.905, circa il 90% della variabilità nello score NSG distrettuale è spiegata dagli indicatori CORE inseriti nel modello
 
2) D09Z – Tempo di risposta del 118: β = –0.61, impatto molto negativo → un aumento tipico dei tempi di intervento è associato a una drastica riduzione del punteggio NSG

3) D10Z – Rispetto dei tempi di attesa: β = +0.314, impatto positivo → l'aumento della quota di pazienti visitati entro i tempi previsti è associato a miglioramenti significativi nello score NSG

4) D27C – Re-ricoveri psichiatrici tra 8 e 30 giorni: β = –0.376, impatto negativo → indica che un maggior numero di rientri in ricovero psichiatrico in tempi brevi abbassa lo score

*/

// Utilizzo la Kernal Density per confrontare la distribuzione degli errori attesi con una distribuzione normale, noto che la distribuzione è molto simmetrica.
kdensity lresidual, normal
//----------------------------------------------------------------------------
*/


