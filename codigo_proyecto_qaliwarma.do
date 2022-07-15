clear all

cd "C:\Users\user\Documents\endes\2019"

u rech0, clear
merge 1:1 hhid using rech23, nogen

//USO DE FUENTES INDUSTRIALES DE COMBUSTIBLE (GAS, PETRÓLEO, KEROSENE)
//PARA COCINAR EN EL HOGAR

//Tipo de combustible para cocinar HV226 
codebook hv226
fre hv226

recode hv226 (1/3=1 "Si") (5/11 95 96 =0 "No"), g(combustible)
replace combustible=. if combustible==99
label var combustible "Combustible limpio para cocción"

//NUMERO DE ARTEFACTOS Y ACTIVOS AUSENTES EN EL HOGAR

/* 

Tiene radio HV207 
Tiene televisión HV208  
Tiene refrigerador HV209 
Tiene bicicleta HV210 
Tiene motocicleta HV211 
Tiene carro o camión HV212 
*/

replace hv208=. if hv208==9
replace hv209=. if hv209==9
replace hv210=. if hv210==9
replace hv211=. if hv211==9
replace hv212=. if hv212==9


egen art_dom=rowtotal(hv207 hv208 hv209 hv210 hv211 hv212), missing
replace art_dom=6-art_dom
label var art_dom "Artefactos en el hogar"

//COCINA A GAS

rename sh61l coci

//LICUADORA

rename sh61k licuadora

//TIPO DE MATERIAL DE CONSTRUCCION DE PISOS, PAREDES Y TECHOS:
//NO ADECUADO, NIVEL BAJO, NIVEL MEDIO, NIVEL ALTO

fre hv213 hv214 hv215
replace hv213=. if hv213==99
replace hv214=. if hv214==99
replace hv215=. if hv215==99
recode hv213(31 34 33 =1 "si") (10 11 20 21 30  32 96=0 "No"), gen(piso)
recode hv214(31=1 "si") (10 11 12 13 20 21 22 23 24 30 32 33 41 96=0 "No"), gen(pared)
recode hv215(31=1 "si") (10 11 12 20 21 22 30 32 33 34 41 96=0 "No"), gen(techo)

egen calmatcons=rowtotal(piso techo pared), missing
lab def calmatcons 0 "No adecuado" 1 "Nivel bajo" 2 "Nivel medio" 3 "Nivel alto"
lab val calmatcons calmatcons 
label var calmatcons "Nivel de materiales de construcción de la vivienda"

// NUMEROS DE MIEMBROS DEL HOGAR

/* Número de miembros del hogar HV009 
0:90
*/

rename hv009 tomiehog

// TENENCIA DE SERVICIO DE ALUMBRADO, AGUA Y SERVICIOS HIGIENICOS EN EL HOGAR
* Tipo de servicio higiénico HV205 

fre hv205
replace hv205=. if hv205==99
recode hv205 (11 12 =1 "Si") (21/24 31 32 96=0 "No"), g(serv_hig)
label var serv_hig "Acceso a desague"

* Fuente de agua no potable HV201

replace hv201=. if hv201==99
recode hv201 (11/13 =1 "Si") (21 22 41 42 43 51 61 71 96=0 "No"), g(agua_pot)
label var agua_pot "Agua potable"

* Tiene electricidad HV206 

replace hv206=. if hv206==99
rename hv206 electricidad

egen ser_bas=rowtotal(serv_hig agua_pot electricidad)
label var ser_bas "Servicios básicos en el hogar"

// considerar que en algunos hogares el numero de miembros es 0
* Resultado de la entrevista del hogar HV015 

//Solo tendriamos que quedarnos con los hogares que si responden y se encuentran presentes
keep if hv015==1

// HV040 Altitud del conglomerado en metros
rename hv040 altitud 

********* <<< HASTA AQUÍ
keep id1 hhid ubigeo hv023 hv024 hv025 hv270 combustible art_dom coci licuadora calmatcons tomiehog serv_hig agua_pot electricidad ser_bas altitud 
br

save hogar2019, replace

/*
g caseid_=substr(caseid,11,12)
destring caseid_, replace
tostring caseid_, replace
egen hvidx=concat(hhid caseid_)
´*/
*******************
use rec0111, clear
// PORCENTAJE DE MUJERES QUE NO SABEN LEER DENTRO DEL HOGAR

* Alfabetización V155 
fre v155
replace v155=. if v155==9
recode v155 (0=1 "Si") (2/4=0 "No"), gen(m_analfabeta)

collapse (mean) tasa_analfa=m_analfabeta, by(hhid)
label var tasa_analfa "% de mujeres analfabetas en el hogar"

save tasa_analfabe, replace

********MADRES
use rec0111, clear
// ETNICIDAD DE LA MADRE
// Lengua nativa no es español
count
* Etnia V131 
fre v131
replace v131=. if v131==99
recode v131 (1/9=1 "Si") (10/12=0 "No"), gen(leng_ori)
label var leng_ori "Lengua originaria =1"
// EDUCACION DE LA MADRE (EN AÑOS)
/* Educación en años simples V133 
0:20 
97 Inconsistente 
(m) 99 Dato faltante
*/

replace v133=. if v133==97
rename v133 educ_madre


// EDAD DE LA MADRE (EN AÑOS)
/* Edad actual - entrevistada V012 
15:49
(na) No aplicable
*/

rename v012 edad_madre

g hv112=v003

keep hhid hv112 caseid leng_ori educ_madre edad_madre

save madre, replace

*****************Características del niño
u rech4, clear
rename idxh4 hvidx
merge 1:1 id1 hhid hvidx using rech1


// PORCENTAJE DE MENORES EN EDAD ESCOLAR QUE NO ASISTEN A ALGÚN PROGRAMA 
// DE ENSEÑANZA REGULAR DENTRO DEL HOGAR.

* Edad del miembro del hogar HV105 

replace hv105=. if hv105==99

keep if hv105>=5 & hv105<=17 // edad que considera MINEDU para trabajo infantil
count

* Condición de asistencia escolar HV129
fre hv129
replace hv129=. if hv129==9
replace hv129=. if hv129==.a

/* Miembros que asisten a la escuela durante el presente año escolar HV121   
0 No 
1 Asiste actualmente 
2 Asiste algunas veces 
(m) 9 Dato faltante 
(na) No aplicable
*/

replace hv121=. if hv121==9

rename hv121 asis_col
fre asis_col

//TRABAJO INFANTIL
fre sh13
recode sh13 (1/5 7 96=1 "Si") (6=0 "No") (8 98=.), g(trab_inf)
fre trab_inf

keep hhid hvidx hv10* hv112 hv12* asis_col trab_inf sh1*

save asistencia_escol, replace



****************DESDE AQUÍ
u asistencia_escol, clear
merge 1:1 hhid hvidx using ps_qaliwarma
keep if _merge==3
rename _merge _m_qw

br hhid hvidx hv112 hv105

merge m:1 hhid hv112 using madre
keep if _merge==3
rename _merge _m_mad
count

merge m:1 hhid using hogar2019
keep if _merge==3
rename _merge _m_hog

merge m:1 hhid using tasa_analfabe
keep if _merge==3
rename _merge _m_ta

save basefinal, replace


**********
u basefinal, clear

d ubigeo hv023 hv024 hv025 hv270 combustible art_dom coci licuadora calmatcons tomiehog serv_hig agua_pot electricidad ser_bas altitud asis_col trab_inf

**Recibe Qali Warma
d ps109_1r 
recode ps109_1r (1=1 "Si") (2=0 "No") (8=.), g(r_qaliwarma)

**Hace cuántos años recibe recodificado
recode  ps109_1a (0=0) (1=12) (2=24) (3=36) (4=48) (5=60) (6=72) (98/.=.), g(an_me_qw)

replace ps109_1m=. if ps109_1m==98
egen t_qw=rsum(an_me_qw ps109_1m) if r_qaliwarma==1

**
tab t_qw
kdensity t_qw
hist t_qw, bin(36)



