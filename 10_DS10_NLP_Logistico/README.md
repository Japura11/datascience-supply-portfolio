# DS-10 | NLP Logístico — Extracción de Información desde Texto

**Framework:** Quant-Supply Framework v5 — Sección DS (Modelos 1-10) — MODELO FINAL  
**Autores:** Loughran & McDonald (2011) · Pang & Lee (2003 NB sentimiento) · Manning & Schütze (1999 TF-IDF)  
**Campo de origen:** Lingüística computacional / Procesamiento de Lenguaje Natural  
**Aplicación Supply:** Extracción automática de ETA + clasificación de alertas SUNAT + resumen CFO semanal

---

## Estructura

```
18_DS10_NLP_Logistico/
├── 1_Finance_Concept.ipynb      ← Earnings calls S&P 500 — sentimiento + señal trading
├── 2_Supply_Adaptation.ipynb    ← 70 documentos logísticos SC Perú — ETA + alertas + urgencia
├── README.md
└── data/
    ├── eda_earnings_calls.png
    ├── eda_log_docs.png
    ├── dashboard_nlp_finance.png
    ├── dashboard_nlp_supply.png
    ├── earnings_calls_nlp.csv
    ├── nlp_method_comparison.csv
    ├── vocabulary_sentiment.csv
    ├── log_docs_extracted.csv
    ├── lt_update_for_ds02.csv
    └── nlp_supply_metrics.csv
```

---

## Marco Teórico

### TF-IDF

$$\text{TF-IDF}(t,d,D) = \frac{f_{t,d}}{\sum_{t'}f_{t',d}} \times \log\frac{|D|+1}{|\{d:t\in d\}|+1} + 1$$

### Naive Bayes multinomial con suavizado de Laplace

$$\hat{P}(t|c) = \frac{f_{t,c}+1}{\sum_{t'}f_{t',c}+|V|}, \quad \log P(c|d) \propto \log P(c) + \sum_t f_{t,d}\log\hat{P}(t|c)$$

### Score L&M / Score Logístico

$$\text{score}(d) = \frac{N_{pos}(d) - N_{neg}(d) - 0.3\cdot N_{unc}(d)}{N_{total}(d)}$$

### Score de urgencia compuesto (Supply)

$$\text{urgencia}(d) = 0.50\cdot\text{tipo\_score} + 0.30\cdot\frac{\text{impacto}}{15} + 0.20\cdot\text{riesgo\_DS07}$$

---

## Diccionarios especializados

| Campo | Diccionario | N palabras | Referencia |
|---|---|---|---|
| Finance | Loughran-McDonald (L&M 2011) | ~3,500 | sraf.nd.edu |
| Supply | Logístico (Incoterms + SUNAT) | ~50 curado | Adaptado INTA-PG.01 |

---

## Datasets

| Notebook | Corpus | Clases | Tarea |
|---|---|---|---|
| Finance | 200 earnings calls S&P 500 (sintético calibrado) | Neg/Neu/Pos | Clasificación + señal trading |
| Supply | 70 docs logísticos SC Perú (correos + BL + SUNAT) | NORMAL/RETRASO/RETENCIÓN/ADELANTO | Clasificación + extracción ETA |

---

## Pipeline de integración DS-10 → cadena completa

```python
# Cada semana:
docs_semana = cargar_documentos_nuevos()
for doc in docs_semana:
    entidades   = extract_entities(doc.text)         # regex
    alerta      = nb_log.predict([doc.text])[0]      # NB
    urgencia    = compute_urgency(alerta, entidades, prov_risk_ds07)

    # Alimentar DS-02
    update_lt_ds02(doc.supplier, entidades['eta_lo'], entidades['date_dep'])

    # Activar DS-09 si urgente
    if urgencia >= 0.70:
        activate_mab_ds09(doc.supplier)

    # Resumen CFO
    generate_executive_summary(docs_semana)
```

---

## Referencias

- Loughran, T. & McDonald, B. (2011). "When is a liability not a liability?" *Journal of Finance.*
- Pang, B. & Lee, L. (2003). "Sentiment analysis using machine learning techniques." *ACL.*
- Manning, C.D. & Schütze, H. (1999). *Foundations of Statistical NLP.* MIT Press.
- Tetlock, P.C. (2007). "Giving content to investor sentiment." *Journal of Finance.*

---

**Modelo 10 de 10 — Cierre del portfolio Quant-Supply Framework v5**

El DS-10 cierra el ciclo: los documentos de texto que generan los proveedores
alimentan automáticamente el LT de DS-02, activan el MAB de DS-09 cuando hay
alertas, y producen el resumen ejecutivo que DS-05 SHAP justifica con números.
