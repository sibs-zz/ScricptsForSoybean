# =====================================================================
#  PCA Visualization in R
#  Goal: Plot PCA results with group-specific colors.
#
#  Input:
#    - pca.txt : table with columns [pc1, pc2, pc3, ..., group]
#                where "group" indicates population label
#
#  Output:
#    - PCA scatter plot with customized theme and manual colors
#
#  Dependencies:
#    - ggplot2
# =====================================================================

# --- Step 1: Load data
a <- read.table("pca.txt", header = TRUE)

# --- Step 2: Define group colors
cols <- c(
  "landrace" = "blue",
  "soja"     = "green",
  "gracilis" = "purple",
  "cultivar" = "red"
)

# --- Step 3: Create PCA scatter plot
library(ggplot2)
ggplot(a, aes(x = pc1, y = pc2, color = group)) +
  geom_point(alpha = 0.8, position = position_jitter(width = 0.2, height = 0.2)) +
  scale_color_manual(values = cols, aesthetics = c("colour", "fill")) +
  theme_classic() +
  theme(
    legend.title    = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_blank(),
    axis.line        = element_line(colour = "black"),
    axis.text.x      = element_text(size = 13),
    axis.text.y      = element_text(size = 13),
    axis.title.x     = element_text(size = 18),
    axis.title.y     = element_text(size = 18)
  ) +
  labs(
    x = "PC1",
    y = "PC2",
    title = "PCA Scatter Plot (PC1 vs PC2)"
  )

# =====================================================================
# Notes:
#   - Adjust jitter width/height to avoid overplotting.
#   - Update color scheme as needed to match publication style.
#   - "a" must contain columns named exactly pc1, pc2, and group.
#   - Save figure with ggsave("PCA_plot.pdf", width=6, height=5).
# =====================================================================
