# DS-01 | Causal Forest & Double ML

**Framework:** Quant-Supply Framework v5 — Sección DS (Modelos 1-10)  
**Autores:** Rubin (1974) · Athey & Wager (2018) · Chernozhukov et al. (2018)  
**Campo de origen:** Econometría / Evaluación de Políticas Públicas  
**Aplicación Supply:** Efecto causal de intervenciones comerciales (descuentos → OTD)

---

## Estructura

```
09_DS01_Causal_Forest/
├── 1_Finance_Concept.ipynb      ← LaLonde NSW dataset — implementación desde cero
├── 2_Supply_Adaptation.ipynb    ← Portfolio B2B Perú — 550 cuentas calibradas BCRP/INEI
├── README.md
└── data/                        ← outputs generados al ejecutar
    ├── eda_lalonde.png
    ├── eda_supply_peru.png
    ├── dashboard_causal_forest_finance.png
    ├── dashboard_causal_forest_supply.png
    ├── lalonde_cate_estimates.csv
    ├── ate_comparison.csv
    ├── portfolio_b2b_cate.csv
    ├── segmentos_cate_supply.csv
    └── top50_priority_accounts.csv
```

---

## Marco Teórico (resumen)

### Problema Fundamental de la Inferencia Causal (Rubin, 1974)

$$\tau_i = Y_i(1) - Y_i(0) \quad \text{(nunca observable directamente)}$$

### CATE — Conditional Average Treatment Effect

$$\tau(x) = \mathbb{E}[Y(1) - Y(0) \mid X = x]$$

Bajo ignorabilidad condicional: $\{Y(0), Y(1)\} \perp T \mid X$

### Criterio de Split del Causal Forest (Athey & Wager, 2018)

$$\Delta(\mathcal{C}_L, \mathcal{C}_R) = \frac{n_L \cdot n_R}{n} (\hat{\tau}_L - \hat{\tau}_R)^2$$

Maximiza la **varianza del efecto de tratamiento** entre hojas (≠ Random Forest clásico que minimiza MSE del outcome).

### Double ML — Partialling Out (Chernozhukov et al., 2018)

$$\tilde{Y}_i = Y_i - \hat{\ell}(X_i), \quad \tilde{T}_i = T_i - \hat{m}(X_i)$$
$$\hat{\tau}^{DML} = \frac{\sum_i \tilde{T}_i \tilde{Y}_i}{\sum_i \tilde{T}_i^2}$$

---

## Datasets

| Notebook | Dataset | Fuente | N |
|---|---|---|---|
| Finance | LaLonde NSW Job Training | Dehejia & Wahba (1999) / NBER | 445 |
| Supply | Portfolio B2B Perú | Simulación calibrada BCRP/INEI 2023 | 550 |

**Estadísticos de calibración (Supply):**
- Revenue medio: S/. 285,000 (INEI Encuesta Económica 2023)
- OTD benchmark: 82–87% (BCRP Reporte Estabilidad Financiera 2023)
- Mix canal: 30% ecommerce / 45% distribuidor / 25% directo

---

## Instalación

```bash
pip install numpy pandas matplotlib scipy scikit-learn
# Opcional (validación):
pip install econml
```

Implementación **desde cero** — sin econml requerido para los notebooks base.

---

## Resultados clave

| Estimador | ATE Finance (USD) | ATE Supply (pp OTD) |
|---|---|---|
| Naive (diferencia medias) | ~$1,700 (OK aquí, sesgado en obs.) | +9.2 pp (sesgado +2.7 pp) |
| Causal Forest (Honest, B=300) | ~$1,750–1,850 | +6.4–7.0 pp |
| Double ML (GBM 5-fold) | ~$1,720–1,900 | +6.5–7.3 pp |
| Verdadero (RCT / latente) | ~$1,794 | +6.5 pp |

**Heterogeneidad detectada (Supply):**
- Canal Directo: CATE ~+9.5 pp
- Canal Distribuidor: CATE ~+6.2 pp  
- Canal Ecommerce: CATE ~+4.8 pp
- Enterprise (>S/.300K): CATE ~+8.8 pp vs SMB (<S/.50K): CATE ~+5.1 pp

---

## Referencias

- Rubin, D.B. (1974). "Estimating causal effects of treatments in randomized and nonrandomized studies." *Journal of Educational Psychology.*
- Athey, S. & Wager, S. (2018). "Estimation and inference of heterogeneous treatment effects using random forests." *JASA.*
- Chernozhukov, V. et al. (2018). "Double/debiased machine learning for treatment and structural parameters." *The Econometrics Journal.*
- LaLonde, R. (1986). "Evaluating the econometric evaluations of training programs with experimental data." *American Economic Review.*

---

**Siguiente modelo:** DS-02 · Changepoint Detection (PELT + BOCPD)  
*Trigger:* ¿desde cuándo reentrenar el Causal Forest cuando hay quiebre estructural en la demanda?
