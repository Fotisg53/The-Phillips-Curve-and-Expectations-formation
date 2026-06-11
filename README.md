# The-Phillips-Curve-and-Expectations-formation

In this Project we try to figure out the relationship between unemployment and inflation with real data. We download data from Eurostat for Greece and Germany over the period 1993-2023 and we observe if it claims the Phillip's curve which means negative relationship between unemployment and inflation. The baseline of the inflation is the constant expectations as in these expectations says that the inflation will be always stable. So now we can compare imediately the relation between inflation and unemployment across two countries. The comparison of the estimated slopes between Germany and Greece show us whether the negative relationship of Phillip's curve is valid in both countries and in which level. 
Also we want to research how this relationship is affected by country or by period and the assumption that we do for the way of transformation of expectations.

Firtstly, we compare the slope of the Phillips curve across the countries (Greece and Germany in this case) and across different time periods.
Secondly, we investigate whether the shape of the Phillips Curve depends on the assumption of how expectations are formed (Adaptive or Rational or Constant).So to succeed that we made a proxy for the expected inflation because this variable (expected inflation) is not available in data. So firtstly we assume adaptive expecations in which expectations are the same with the previous inflation for all time. For example if the inflation in the previous year was 5% the employees expected today 5% as it was last year but this year the inflation goes 3% so the next year the employees will expect 3% and it keeps evolving in this manner. So we have the real inflation and with the assumption of adaptive expectations we can have the expected inflation. After we do the same but we assume rational expectations in which expectations the employees know the model and has information for the fundamentals of the economy and they look the history of inflation.

So now we test the relationship of unemployment and inflation in two different countries for different periods and for 3 different expectations.

Conclusions:


AR Model of Inflation

For both countries, β2 is positive and statistically significant (p=0.000 for Greece, p=0.0008 for Germany), confirming that inflation exhibits strong persistence  last year's inflation is a good predictor of current inflation. Greece's R² (0.621) is higher than Germany's (0.334), suggesting that inflation in Greece follows a more persistent pattern over time.

 

Phillips Curve with Expected Inflation

The slope coefficient δ2 (unemployment) is negative for both countries (Greece: -0.1878, Germany: -0.1229), confirming the negative relationship predicted by Phillips Curve theory. However, the effect is weak — a one-unit increase in unemployment reduces inflation by only 0.19% in Greece and 0.12% in Germany. In contrast, (expected inflation) is remarkably high (0.76 and 0.95 respectively), indicating that current inflation is driven primarily by expectations rather than unemployment. The R² is substantially higher than in the static PC (0.70 for Greece, 0.38 for Germany), confirming that incorporating expectations significantly improves the model's explanatory power.




Differences across Countries and Subperiods

The strength of the Phillips Curve is not uniform it depends on both the country and the time period under examination. Greece exhibits a steeper slope (−0.413) compared to Germany (−0.160), reflecting the extreme volatility in inflation and unemployment that Greece experienced, particularly during the crisis period (2009–2015). During that period, unemployment surged to 27.5% while inflation collapsed into negative territory, producing a dramatic but textbook Phillips Curve episode. Germany, by contrast, displayed consistently low inflation and a gradual decline in unemployment, resulting in a statistically weaker relationship. Overall, the results suggest that the shape and strength of the Phillips Curve are not stable they vary with the macroeconomic environment and the structural characteristics of each country.




The Role of Expectations

Inflation expectations play a crucial role in shaping the Phillips Curve. R²rising from around 0.10 in the static PC to 0.70 for Greece and 0.38 for Germany. This indicates that current inflation depends not only on unemployment, but primarily on what economic agents expected to happen. Under constant expectations, the Phillips Curve is confirmed. Under adaptive expectations, the Phillip's curve is confirmed for short term period. Under rational expectations, only unexpected inflation affects unemployment in other way it does not confirmed the Phillip's curve. 

This finding is consistent with the Lucas Critique: under rational expectations, agents correctly anticipate policy changes and immediately adjust their expectations, leaving no room for inflation surprises. As a result, monetary policy loses its ability to influence unemployment, and the Phillips Curve trade-off breaks down. More broadly, this highlights that the assumption made about how expectations are formed is crucial the Phillips Curve holds under constant expectations, partially holds under adaptive expectations, but fails entirely under rational expectations.



General Conclusion

The Phillips Curve is empirically confirmed for both countries, with a negative relationship between unemployment and inflation. However, the effect of unemployment is modest, while expected inflation emerges as the dominant driver of current inflation. The shape and strength of the relationship vary significantly across countries and time periods, and depend critically on the assumption made about how expectations are formed.




At the end we have a model which i have the solution in a code and i do a simulation. Take a look the pdf the exercise 2 if you are interested in.
