library(pheatmap)

WORKDIR <- "/mnt/tank/scratch/ebarabanova/roh"
setwd(WORKDIR)

# read matrix
mat <- read.table(
  "exact_overlap_matrix.tsv",
  header = TRUE,
  row.names = 1,
  check.names = FALSE
)

# convert to matrix
mat <- as.matrix(mat)

# save numbers BEFORE masking
numbers_mat <- matrix(
  sprintf("%.1f", mat),
  nrow = nrow(mat)
)

# make diagonal white
diag(mat) <- NA


# plot heatmap
pheatmap(
  mat,
  
  # numbers in cells
  display_numbers = numbers_mat,
  
  # clustering
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  
  # color palette
  color = colorRampPalette(
    c("white", "#fdbb2d", "red", "darkred")
  )(100),


  # color for NA values (diagonal)
  na_col = "white",

  
  # square cells
  cellwidth = 50,
  cellheight = 50,
  
  # borders
  border_color = "lightgray",
  
  # labels
  main = "Shared ROH (>1 Mb) Between Deer (Mb)",
  
  fontsize = 12,
  fontsize_number = 12,
  
  filename = "roh_shared_heatmap1.png",
  width = 10,
  height = 8
)
