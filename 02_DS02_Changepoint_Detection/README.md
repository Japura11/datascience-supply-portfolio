# DS-02 | Changepoint Detection — PELT + BOCPD

**Framework:** Quant-Supply Framework v5 — Sección DS (Modelos 1-10)  
**Autores:** Page (1955) · Adams & MacKay (2007) · Killick, Fearnhead & Eckley (2012)  
**Campo de origen:** Estadística / Control secuencial de procesos  
**Aplicación Supply:** Detectar cuándo reentrenar modelos, alertar cambios de proveedor

---

## Estructura

```
10_DS02_Changepoint_Detection/
├── 1_Finance_Concept.ipynb      ← S&P 500 — regímenes de volatilidad 2018-2023
├── 2_Supply_Adaptation.ipynb    ← 3 series SC Perú: lead time, demanda, precio FOB
├── README.md
└── data/                        ← outputs generados al ejecutar
    ├── eda_sp500.png
    ├── eda_supply_peru.png
    ├── dashboard_changepoint_finance.png
    ├── dashboard_changepoint_supply.png
    ├── sp500_regimes.csv
    ├── changepoints_detected.csv
    ├── regime_stats.csv
    ├── supply_peru_regimes.csv
    └── changepoints_supply.csv
```

---

## Marco Teórico (resumen)

### Problema de Optimización — PELT

$$\mathcal{Q}(\tau_{1:m}) = \sum_{i=0}^{m} \mathcal{C}\left(y_{(\tau_i+1):\tau_{i+1}}\right) + \beta \cdot m$$

Función de costo Gaussiana:
$$\mathcal{C}_{\text{Gauss}}(y_{s:t}) = (t-s) \cdot \ln\left(\hat{\sigma}^2_{s:t}\right)$$

Penalización BIC: $\beta = \ln(n) \cdot p$  (p=2 para Gaussiana)

### Poda PELT — condición de eliminación

Si `F(s) + C(y[s:t]) + β ≥ F(t)` para todo t > s → s nunca será el último CP óptimo → se elimina del conjunto activo.  
Complejidad: **O(n)** vs O(n²) de DP estándar.

### BOCPD — Recursión de run length

$$P(r_t \mid y_{1:t}) \propto \sum_{r_{t-1}} P(y_t \mid r_t, y_{t_0:t-1}) \cdot P(r_t \mid r_{t-1}) \cdot P(r_{t-1} \mid y_{1:t-1})$$

Hazard rate: $H = 1/\lambda$ donde $\lambda$ = duración media esperada del run.

---

## Datasets

| Notebook | Dataset | Fuente | N |
|---|---|---|---|
| Finance | S&P 500 retornos diarios 2018–2023 | Yahoo Finance (^GSPC) / fallback calibrado | ~1,200 días |
| Supply | 3 series SC Perú: lead time, demanda, precio | Simulación calibrada BCRP/INEI 2022 | 60 semanas |

**Regímenes simulados (Supply) — calibrados con:**
- Lead time: crisis semiconductores Q1 2022 (BCRP Reporte Inflación 2022)
- Precio FOB: +51% precio componentes electrónicos 2022 (MINAGRI / COMEX)
- Demanda: ciclos de campaña retail Perú (INEI Encuesta Mensual Manufactura)

---

## Instalación

```bash
pip install numpy pandas matplotlib scipy
# Opcional para datos reales:
pip install yfinance
```

Implementación **desde cero** — sin `ruptures` requerido.

---

## Resultados clave

### Finance (S&P 500)
| Régimen | Período | Volatilidad media | Evento |\n|---|---|---|---|
| R1 | 2018 Q1–Q3 | ~0.8%/día | Bull market tranquilo |
| R2 | 2018 Q4 | ~1.8%/día | Selloff tasa Fed |
| R3 | 2020 Q1–Q2 | ~4.0%/día | Crash COVID |
| R4 | 2021 | ~0.9%/día | Recovery |
| R5 | 2022 | ~1.6%/día | Bear market inflación |

### Supply Chain (Perú)
| Serie | CP verdadero | PELT | Error | Impacto |
|---|---|---|---|---|
| Lead time | S29 | ±1 sem | ~0 | SS sube ×1.4 |
| Demanda | S19, S39 | ±1 sem | ~0 | Reentrenar forecast |
| Precio FOB | S34 | ±1 sem | ~0 | Costo variable +51% |

---

## Regla operativa

```python
# Pipeline de monitoreo semanal
for serie in [lead_time, demanda, precio_fob]:
    cp, _ = pelt(serie, pen=np.log(len(serie))*2, min_size=4)
    if cp and cp[-1] > len(serie) - 4:
        alert("REENTRENAR MODELO — changepoint reciente detectado")
    p_cp = bocpd_run(serie, hazard=1/15)
    if p_cp[-1] > 0.30:
        alert("BOCPD: posible changepoint en curso")
```

---

## Referencias

- Page, E.S. (1955). "A test for a change in a parameter occurring at an unknown point." *Biometrika.*
- Adams, R.P. & MacKay, D.J.C. (2007). "Bayesian Online Changepoint Detection." *arXiv:0710.3742.*
- Killick, R., Fearnhead, P. & Eckley, I.A. (2012). "Optimal detection of changepoints with a linear computational cost." *JASA.*

---

**Modelo anterior:** DS-01 · Causal Forest & Double ML  
**Siguiente modelo:** DS-03 · Graph Neural Network (red de supply chain como grafo)  
*Trigger:* detectado el changepoint, ¿cómo se propaga a través de la red de proveedores y SKUs?
