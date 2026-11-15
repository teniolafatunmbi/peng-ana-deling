install.packages("palmerpenguins")
install.packages("ggplot2")

library(palmerpenguins)
library(ggplot2)

df <- penguins

## Task 1: DATA EXPLORATION AND PREPROCESSING

# Display first six rows
head(df)

# Inspect the dataset structure
str(df)

# Check number of rows and columns
dim(df)

# Count missing values per column
colSums(is.na(df))

# Select numerical columns
numeric_data <- df[sapply(df, is.numeric)]

# Calculate summary statistics
sapply(numeric_data, function(x) {
  c(
    mean = mean(x, na.rm = TRUE),
    median = median(x, na.rm = TRUE),
    min = min(x, na.rm = TRUE),
    max = max(x, na.rm = TRUE),
    sd = sd(x, na.rm = TRUE)
  )
})

## Task 2: HYPOTHESIS TESTING

### A significance level of \(\alpha = 0.05\) is used.

### Part A — Two-sample t-test
selected <- subset(
  df,
  species %in% c("Adelie", "Gentoo") &
    !is.na(body_mass_g)
)

selected$species <- droplevels(selected$species)

t_result <- t.test(
  body_mass_g ~ species,
  data = selected
)
# This uses Welch's two-sample t-test, which does not require equal population variances.
print(t_result)

### Part B — One-sample proportion test
sex_data <- subset(df, !is.na(sex))

male_count <- sum(sex_data$sex == "male")
total_count <- nrow(sex_data)

prop_result <- prop.test(
  x = male_count,
  n = total_count,
  p = 0.5,
  alternative = "two.sided",
  correct = FALSE
)

print(prop_result)

## Task 3: CORRELATION ANALYSIS
## Using Pearson's correlation coefficient, which measures linear relationships on a scale of -1 to +1.
columns <- c(
  "bill_length_mm",
  "bill_depth_mm",
  "flipper_length_mm",
  "body_mass_g"
)

cor_matrix <- cor(
  df[columns],
  use = "complete.obs"
)

print(round(cor_matrix, 2))

## Heatmap
cor_data <- as.data.frame(as.table(cor_matrix))

heatmap_plot <- ggplot(cor_data, aes(Var1, Var2, fill = Freq)) +
  geom_tile() +
  geom_text(
    aes(label = round(Freq, 2))
  ) +
  scale_fill_gradient2(
    low = "blue",
    mid = "white",
    high = "red",
    midpoint = 0,
    limits = c(-1, 1)
  ) +
  labs(
    title = "Correlation Matrix of Penguin Measurements",
    x = NULL,
    y = NULL,
    fill = "Correlation"
  )

# Task 4: REGRESSION MODELLING
## Simple & Multiple Linear Regression
model_data <- df[
  complete.cases(df[, c(
    "body_mass_g",
    "flipper_length_mm",
    "bill_length_mm",
    "bill_depth_mm"
  )]),
]

# Simple regression
simple_model <- lm(
  body_mass_g ~ flipper_length_mm,
  data = model_data
)

summary(simple_model)


# Multiple regression
multiple_model <- lm(
  body_mass_g ~ flipper_length_mm +
    bill_length_mm +
    bill_depth_mm,
  data = model_data
)

summary(multiple_model)

# Adjusted R-squared values
summary(simple_model)$adj.r.squared
summary(multiple_model)$adj.r.squared

# Root mean squared errors
sqrt(mean(residuals(simple_model)^2))
sqrt(mean(residuals(multiple_model)^2))


## Task 5: DATA VISUALIZATION

### Part A — Scatter Plot with Regression Line
# Visualize the relationship between flipper length and body mass.

scatter_plot <- ggplot(
  model_data,
  aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(color = "steelblue", alpha = 0.6) +
  geom_smooth(
    method = "lm",
    formula = y ~ x,
    color = "red",
    se = TRUE
  ) +
  labs(
    title = "Relationship Between Flipper Length and Body Mass",
    x = "Flipper Length (mm)",
    y = "Body Mass (g)"
  ) +
  theme_minimal()


### Part B — Boxplot of Body Mass Across Species
# Compare the distribution of body mass among penguin species.

box_plot <- ggplot(
  df,
  aes(x = species, y = body_mass_g, fill = species)
) +
  geom_boxplot(na.rm = TRUE, alpha = 0.7) +
  labs(
    title = "Distribution of Body Mass Across Penguin Species",
    x = "Penguin Species",
    y = "Body Mass (g)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")


### Part C — Histogram of Body Mass with Normal Curve
# Visualize the distribution of body mass and compare it
# with a theoretical normal distribution.

body_mass <- na.omit(df$body_mass_g)

mean_mass <- mean(body_mass)
sd_mass <- sd(body_mass)

histogram_plot <- ggplot(
  data.frame(body_mass_g = body_mass),
  aes(x = body_mass_g)
) +
  geom_histogram(
    aes(y = after_stat(density)),
    bins = 30,
    fill = "steelblue",
    color = "white",
    alpha = 0.7
  ) +
  stat_function(
    fun = dnorm,
    args = list(
      mean = mean_mass,
      sd = sd_mass
    ),
    color = "red",
    linewidth = 1
  ) +
  labs(
    title = "Distribution of Penguin Body Mass",
    x = "Body Mass (g)",
    y = "Density"
  ) +
  theme_minimal()

# Create a directory for the charts
dir.create("plots", showWarnings = FALSE)

# Export each chart as a high-resolution PNG
ggsave("plots/scatter_plot.png", scatter_plot,
       width = 8, height = 5, dpi = 300)

ggsave("plots/box_plot.png", box_plot,
       width = 8, height = 5, dpi = 300)

ggsave("plots/histogram_plot.png", histogram_plot,
       width = 8, height = 5, dpi = 300)
ggsave(
  "plots/correlation_heatmap.png",
  heatmap_plot,
  width = 8,
  height = 6,
  dpi = 300
)