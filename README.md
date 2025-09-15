# Analisi del Nuovo Sistema di Garanzia (NSG) [2017–2022]
Analisi degli indicatori CORE e NOCORE dell'area distrettuale italiana per il periodo 2017–2022, con focus sull'Emilia-Romagna e confronto con regioni simili. Lo studio include data cleaning, regressioni lineari e grafici comparativi.
Dataset: Ministero della Salute.
Obiettivo: valutare le differenze regionali e le performance del sistema distrettuale.”

## Obiettivi
- Valutare l'andamento degli indicatori NSG a livello regionale.
- Identificare differenze significative tra le regioni italiane.
- Modellizzare la relazione tra indicatori socio-sanitari tramite regressione.
- Confrontare le performance dell'Emilia-Romagna con regioni simili.

## Dati
- Fonte: Ministero della Salute, NSG 2017–2022
- Variabili principali: indicatori CORE e NOCORE dell'area distrettuale
- Note: alcuni indicatori richiedevano pulizia e normalizzazione dei dati

## Metodologia
- Pulizia e gestione dei dati (Excel e Python/R)
- Analisi descrittiva e comparativa
- Modelli di regressione lineare su Gretl e Stata
- Test su normalità dei residui, eteroschedasticità ed errori robusti
- Grafici Stata

## Risultati principali
- Evidenziate differenze territoriali significative sugli indicatori CORE
- Alcune aree mostrano criticità specifiche
- Questo risultato suggerisce che l’Emilia-Romagna ha un modello distrettuale più efficiente, con implicazioni per le regioni del Sud in termini di allocazione risorse

 
![Grafico andamento NSG Distrettuale](img/NSGDistrettuale_Finanziamento.png))

*Confronto tra regioni simili all’Emilia-Romagna (per finanzianmento sanitario) sul finanziamento sanitario pro-capite e sul punteggio distrettuale NSG (2017–2022)*

## Script Stata
Il file principale per l'analisi è [`NSG_Merighi206929.do`](./script/NSG_Merighi206929.do).  
## Software usati
- Stata
- Excel
- Gretl

## Contatti
- LinkedIn: [riccardomerighi](https://www.linkedin.com/in/riccardo-merighi-62150b340/)
