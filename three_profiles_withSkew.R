# Load libraries
library(ggplot2)
library(sn)
library(gridExtra)
library(viridis)
library(quantreg)
library(dplyr)
library(cowplot)

set.seed(42)

### =======================
### USER-DEFINED PARAMETERS
### =======================

# Number of points to simulate
n <- 300

# Range of thermal variability to simulate across
thermal_variability <- seq(0.5, 3, length.out = n)

# Threshold value where the organism response behavior changes
threshold_point <- 2.5

# Parameters for the three data scenarios:
# Skew value: controls asymmetry of the distribution
# Center shift: moves the center of response before the threshold
# Drop: vertical drop in response after the threshold
params_symmetric <- list(skew_value = 0,   center_shift = 0,  drop = -5)
params_left_skew <- list(skew_value = -3,  center_shift = 7,  drop = -13)
params_right_skew <- list(skew_value = 3,  center_shift = -7, drop = -13)

# Color palette for plots (dark viridis shades, skipping yellow)
custom_colors <- c("#440154FF", "#21908CFF", "#3B528BFF")  # p1, p2, p3

### =======================
### FUNCTIONS
### =======================

# Simulate data with skew, funnel shape, and threshold-induced shift
generate_skewed_data_with_threshold <- function(skew_value, center_shift = 0, threshold = 2.5, drop = -5) {
  omega <- 5 + thermal_variability^3  # Funnel: tighter at low variability
  xi <- ifelse(thermal_variability < threshold, center_shift, center_shift + drop)
  response <- rsn(n = n, xi = xi, omega = omega, alpha = skew_value)
  data.frame(
    thermal_variability = thermal_variability,
    organism_response = response
  )
}

# Fit separate quadratic trends pre- and post-threshold
get_trend_lines <- function(data, threshold) {
  data_pre <- filter(data, thermal_variability <= threshold)
  data_post <- filter(data, thermal_variability > threshold)
  
  model_pre <- lm(organism_response ~ poly(thermal_variability, 2), data = data_pre)
  model_post <- lm(organism_response ~ poly(thermal_variability, 2), data = data_post)
  
  x_pre <- seq(min(data_pre$thermal_variability), max(data_pre$thermal_variability), length.out = 100)
  x_post <- seq(min(data_post$thermal_variability), max(data_post$thermal_variability), length.out = 100)
  
  data.frame(
    x = c(x_pre, x_post),
    y = c(predict(model_pre, data.frame(thermal_variability = x_pre)),
          predict(model_post, data.frame(thermal_variability = x_post))),
    phase = rep(c("Pre", "Post"), each = 100)
  )
}

# Generate 95% quantile ribbons
get_quantile_ribbon <- function(df, taus = c(0.05, 0.95)) {
  rq_low <- rq(organism_response ~ poly(thermal_variability, 2), tau = taus[1], data = df)
  rq_high <- rq(organism_response ~ poly(thermal_variability, 2), tau = taus[2], data = df)
  x_seq <- seq(min(df$thermal_variability), max(df$thermal_variability), length.out = 300)
  pred_low <- predict(rq_low, newdata = data.frame(thermal_variability = x_seq))
  pred_high <- predict(rq_high, newdata = data.frame(thermal_variability = x_seq))
  data.frame(thermal_variability = x_seq, ymin = pred_low, ymax = pred_high)
}

# Plot function with trend lines, ribbons, and threshold shading
make_threshold_plot <- function(data, title, color, threshold = 2.5) {
  ribbon_data <- get_quantile_ribbon(data)
  ribbon_data_pre <- filter(ribbon_data, thermal_variability <= threshold)
  trend_df <- get_trend_lines(data, threshold)
  
  ggplot(data, aes(x = thermal_variability, y = organism_response)) +
    annotate("rect", xmin = threshold, xmax = max(data$thermal_variability),
             ymin = -Inf, ymax = Inf, fill = "gray30", alpha = 0.08) +
    
    geom_ribbon(data = ribbon_data_pre,
                aes(x = thermal_variability, ymin = ymin, ymax = ymax),
                fill = color, alpha = 0.3, inherit.aes = FALSE) +
    
    geom_point(alpha = 0.5, color = color) +
    
    geom_line(data = trend_df, aes(x = x, y = y, linetype = phase), color = "black", linewidth = 1) +
    
    geom_vline(xintercept = threshold, linetype = "dotted", color = "gray40") +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray30") +
    
    scale_linetype_manual(values = c("Pre" = "solid", "Post" = "dashed")) +
    guides(linetype = guide_legend(override.aes = list(color = "black"))) +
    
    labs(title = title,
         x = "Thermal Variability",
         y = "Organism Response Index",
         linetype = "Trend Phase") +
    ylim(-45, 45) +
    theme_bw(base_size = 13) +
    theme(legend.position = "bottom")
}

### =======================
### GENERATE DATA & PLOTS
### =======================

data_symmetric   <- generate_skewed_data_with_threshold(
  skew_value = params_symmetric$skew_value,
  center_shift = params_symmetric$center_shift,
  drop = params_symmetric$drop
)

data_left_skew   <- generate_skewed_data_with_threshold(
  skew_value = params_left_skew$skew_value,
  center_shift = params_left_skew$center_shift,
  drop = params_left_skew$drop
)

data_right_skew  <- generate_skewed_data_with_threshold(
  skew_value = params_right_skew$skew_value,
  center_shift = params_right_skew$center_shift,
  drop = params_right_skew$drop
)

p1 <- make_threshold_plot(data_symmetric,   "Symmetric Response (Normal)",                custom_colors[1])
p2 <- make_threshold_plot(data_left_skew,   "Left-Skewed Response (Threshold Collapse)",  custom_colors[2])
p3 <- make_threshold_plot(data_right_skew,  "Right-Skewed Response (Filtered Survivors)", custom_colors[3])

# Arrange plots vertically without legends
combined_plot <- plot_grid(p1 + theme(legend.position = "none"),
                           p2 + theme(legend.position = "none"),
                           p3 + theme(legend.position = "none"),
                           ncol = 1, align = "v")

# Extract and append legend
legend <- get_legend(p1)
final_plot <- plot_grid(combined_plot, legend, ncol = 1, rel_heights = c(1, 0.07))

# Save final figure
ggsave("3phases_threshold_funnel_skew222.png", plot = final_plot,
       width = 6, height = 8.5, dpi = 300, units = "in")
