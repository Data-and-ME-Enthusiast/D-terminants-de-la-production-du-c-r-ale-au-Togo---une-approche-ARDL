*********************************                          *******************************
*                                                                                        *
*     Sujet : Determinant de la production de céréales au Togo                           *
*     Do file édité par M. Sanoussi Moudjibou  (Statisticien, suivi-évaluateur)          *
*                    Date : Samedi, 27 juillet 2024                                      *
*                                                                                        *
******************************************************************************************


version 17
clear all
set more off
cap log close


* Importation de la base de données et définition du repertoire de travail.
cd "chemin_du_repertoire"
import excel "chemin_de_la_base", sheet("nom_de_la_feuille_contenant_les_data") firstrow


* Traitement de la base de données (data cleaning)

replace CountryName = "" in 60
replace CountryName = "" in 61

replace AgriculturallandsqkmAGL = "." in 1
replace AgriculturallandsqkmAGL = "." in 2
replace Agriculturalmachinerytractors = "." in 1
replace Agriculturalmachinerytractors = "." in 2
replace Agriculturalmachinerytractors = "." in 3
replace Agriculturalmachinerytractors = "." in 4
replace Agriculturalmachinerytractors = "." in 5
replace Agriculturalmachinerytractors = "." in 6
replace Agriculturalmachinerytractors = "." in 28
replace Agriculturalmachinerytractors = "." in 29
replace Agriculturalmachinerytractors = "." in 36
replace Agriculturalmachinerytractors = "." in 37
replace Agriculturalmachinerytractors = "." in 47
replace Agriculturalmachinerytractors = "." in 48
replace Agriculturalmachinerytractors = "." in 49
replace Agriculturalmachinerytractors = "." in 50
replace Arablelandhectaresperperson = "." in 1
replace Arablelandhectaresperperson = "." in 2
replace CerealyieldkgperhectareA = "." in 1
replace Fertilizerconsumptionkilogram = "." in 1
replace Fertilizerconsumptionkilogram = "." in 2
replace Fertilizerconsumptionkilogram = "." in 41
replace Fertilizerconsumptionkilogram = "." in 42
replace Fertilizerconsumptionkilogram = "." in 55
replace Fertilizerconsumptionkilogram = "." in 56

keep Time AgriculturallandsqkmAGL Agriculturalmachinerytractors CerealyieldkgperhectareA Fertilizerconsumptionkilogram 
drop if Time == .

rename CountryName pays
rename Time annee
rename AgriculturallandsqkmAGL terre_agri_km2
rename Agriculturalmachinerytractors mecanisation_agri
rename CerealyieldkgperhectareA production_cereal_parhec
rename Fertilizerconsumptionkilogram engrais_cons_kg
destring terre_agri_km2 mecanisation_agri production_cereal_parhec engrais_cons_kg, replace

label var terre_agri_km2 "Terre agricole (sq.km)"
label var mecanisation_agri "Mécanisation agricole"
label var production_cereal_parhec "Production de céréales Kg/hec"
label var engrais_cons_kg "Consommantion d'engrais Kg/hec"


tabstat terre_agri_km2 mecanisation_agri production_cereal_parhec engrais_cons_kg, stat(median) // Imputation des données manques par la médiane

replace terre_agri_km2 = 31725 if terre_agri_km2 == .
replace mecanisation_agri = .3944444  if mecanisation_agri == .
replace production_cereal_parhec =  902.7  if production_cereal_parhec == .
replace engrais_cons_kg =  3.560432  if engrais_cons_kg == .

keep annee terre_agri_km2 mecanisation_agri production_cereal_parhec engrais_cons_kg
save base_analyse, replace


log using resultats, replace
********************** Analyse de données 

use base_analyse, clear 
tsset annee

* Etude des propriétés statistiques des séries

// Graphiques des series en niveau
sum terre_agri_km2 mecanisation_agri production_cereal_parhec engrais_cons_kg 

tsline terre_agri_km2, ylabel(33010.71) saving(terre_agri1)

tsline mecanisation_agri, ylabel(.3885382) saving(mecanisation_agri1)

tsline production_cereal_parhec, ylabel(908.0857) saving(production_cereal_parhec1)

tsline engrais_cons_kg, ylabel(4.257014 ) saving(engrais_cons_kg1)

graph combine terre_agri1.gph mecanisation_agri1.gph production_cereal_parhec1.gph engrais_cons_kg1.gph 


// Graphiques des series en différence première
sum d.terre_agri_km2 d.mecanisation_agri d.production_cereal_parhec d.engrais_cons_kg 

tsline d.terre_agri_km2, ylabel(999.8957) saving(terre_agri2)

tsline d.mecanisation_agri, ylabel(.0219881) saving(mecanisation_agri2)

tsline d.production_cereal_parhec, ylabel(96.62957) saving(production_cereal_parhec2)

tsline d.engrais_cons_kg, ylabel(3.606637) saving(engrais_cons_kg2)

graph combine terre_agri2.gph mecanisation_agri2.gph production_cereal_parhec2.gph engrais_cons_kg2.gph 



// Tests de stationarité ADF en niveau

varsoc terre_agri_km2
dfuller terre_agri_km2, lags(1) trend regress
dfuller terre_agri_km2, lags(0) nocons

varsoc mecanisation_agri
dfuller mecanisation_agri, lags(4) trend regress
dfuller mecanisation_agri, lags(3) nocons

varsoc production_cereal_parhec
dfuller production_cereal_parhec, lags(2) trend regress
dfuller production_cereal_parhec, lags(0) cons

varsoc engrais_cons_kg  // Stationaire en niveau
dfuller engrais_cons_kg, lags(2) trend regress
dfuller engrais_cons_kg, lags(0) nocons


// Tests de stationarité ADF en différence première

varsoc d.terre_agri_km2 // Stationaire en différence première
dfuller d.terre_agri_km2, lags(0) trend regress
dfuller d.terre_agri_km2, lags(0) nocons

varsoc d.mecanisation_agri
dfuller d.mecanisation_agri, lags(3) trend regress
dfuller d.mecanisation_agri, lags(0) nocons

varsoc d.production_cereal_parhec
dfuller d.production_cereal_parhec, lags(0) trend regress
dfuller d.production_cereal_parhec, lags(0) nocons


// Test de cointégration

ardl production_cereal_parhec engrais_cons_kg mecanisation_agri terre_agri_km2, maxlags(4) ec btest

// Estimation du modèle 

ardl production_cereal_parhec engrais_cons_kg mecanisation_agri terre_agri_km2, maxlags(4) ec regstore(ecreg)

// Test d'autocorrelation 
estimates restore ecreg
estat dwatson 
estat bgodfrey, lags(1)

prais production_cereal_parhec engrais_cons_kg mecanisation_agri terre_agri_km2, corc 

// Test d'hétéroscédasticité
estat imtest, white


log close









