import os
import io
import base64
import matplotlib
matplotlib.use('Agg')  # Use a non-GUI backend
import matplotlib.pyplot as plt
import numpy as np
import scipy.cluster.hierarchy as sch

def save_dendrogram(matrix, keys, output_path):
    """
    Generates a dendrogram image from the similarity matrix and saves it to output_path.
    """
    # Convert matrix to a NumPy array
    np_matrix = np.array(matrix)
    # Compute hierarchical clustering using Ward's method
    linkage_matrix = sch.linkage(np_matrix, method='ward')
    
    plt.figure(figsize=(8, 6))
    # Generate dendrogram with provided keys as labels
    sch.dendrogram(linkage_matrix, labels=keys, orientation='top', leaf_rotation=45)
    plt.title("Hierarchical Clustering Dendrogram")
    plt.xlabel("Samples")
    plt.ylabel("Distance")
    
    # Save the figure to the given path
    plt.savefig(output_path, format='png', bbox_inches='tight', pad_inches=0.2)
    plt.clf()  # Clear figure
    plt.close('all')
    print(f"Dendrogram saved to {output_path}")

def save_heatmap(matrix, keys, output_path):
    """
    Generates a heatmap image from the similarity matrix and saves it to output_path.
    """
    np_matrix = np.array(matrix)
    
    plt.figure(figsize=(6, 6))
    # Display heatmap using the plasma colormap
    plt.imshow(np_matrix, cmap='plasma', interpolation='nearest')
    plt.clim(0, 100)  # Set color limits from 0 to 100
    plt.colorbar()
    
    if keys is not None:
        plt.xticks(range(len(keys)), keys, rotation=45)
        plt.yticks(range(len(keys)), keys)
    
    plt.title("Confusion Matrix")
    
    plt.savefig(output_path, format='png', bbox_inches='tight')
    plt.clf()
    plt.close('all')
    print(f"Heatmap saved to {output_path}")

if __name__ == '__main__':
    # Example data: similarity matrix (values in percentage) and keys
    similarity_matrix = [
        [100, 41.43, 42.14, 41.73, 42.03, 43.94, 20.89, 20.89, 20.26, 20.91, 19.82, 20.35, 20.35, 19.82, 20.89, 20.41, 19.82],
        [41.43, 100, 98.65, 95.95, 94.59, 60.47, 19.57, 19.57, 19.46, 19.55, 19.57, 19.57, 19.57, 19.57, 20.22, 18.54, 18.92],
        [42.14, 98.65, 100, 94.67, 93.33, 59.77, 19.46, 19.46, 19.35, 19.44, 19.46, 19.46, 19.46, 19.46, 20.11, 18.45, 18.82],
        [41.73, 95.95, 94.67, 100, 95.89, 59.30, 20.33, 20.33, 19.57, 20.34, 19.67, 20.33, 20.33, 20.33, 20.33, 19.21, 19.67],
        [42.03, 94.59, 93.33, 95.89, 100, 60.00, 20.44, 20.44, 19.67, 20.45, 19.78, 20.44, 20.44, 20.44, 21.11, 19.31, 19.78],
        [43.94, 60.47, 59.77, 59.30, 60.00, 100, 19.77, 19.77, 18.99, 19.08, 19.10, 19.77, 19.77, 19.77, 19.77, 18.69, 19.10],
        [20.89, 19.57, 19.46, 20.33, 20.44, 19.77, 100, 93.42, 90.32, 95.92, 89.68, 90.91, 90.91, 90.91, 90.91, 86.47, 90.91],
        [20.89, 19.57, 19.46, 20.33, 20.44, 19.77, 93.42, 100, 86.71, 89.47, 87.26, 93.42, 92.16, 92.16, 94.70, 82.18, 92.16],
        [20.26, 19.46, 19.35, 19.57, 19.67, 18.99, 90.32, 86.71, 100, 86.45, 94.08, 89.10, 90.32, 92.81, 87.90, 78.65, 89.10],
        [20.91, 19.55, 19.44, 20.34, 20.45, 19.08, 95.92, 89.47, 86.45, 100, 85.81, 87.01, 87.01, 87.01, 87.01, 82.94, 87.01],
        [19.82, 19.57, 19.46, 19.67, 19.78, 19.10, 89.68, 87.26, 94.08, 85.81, 100, 92.16, 89.68, 92.16, 90.91, 79.10, 90.91],
        [20.35, 19.57, 19.46, 20.33, 20.44, 19.77, 90.91, 93.42, 89.10, 87.01, 92.16, 100, 90.91, 93.42, 94.70, 80.11, 93.42],
        [20.35, 19.57, 19.46, 20.33, 20.44, 19.77, 90.91, 92.16, 90.32, 87.01, 89.68, 90.91, 100, 97.32, 93.42, 80.11, 94.70],
        [19.82, 19.57, 19.46, 20.33, 20.44, 19.77, 90.91, 92.16, 92.81, 87.01, 92.16, 93.42, 97.32, 100, 93.42, 80.11, 94.70],
        [20.89, 20.22, 20.11, 20.33, 21.11, 19.77, 90.91, 94.70, 87.90, 87.01, 90.91, 94.70, 93.42, 93.42, 100, 80.11, 96.00],
        [20.41, 18.54, 18.45, 19.21, 19.31, 18.69, 90.91, 82.18, 78.65, 82.94, 79.10, 80.11, 80.11, 80.11, 80.11, 100, 80.11],
        [19.82, 18.92, 18.82, 19.67, 19.78, 19.10, 90.91, 92.16, 89.10, 87.01, 90.91, 93.42, 94.70, 94.70, 96.00, 80.11, 100]
    ]
    keys = ['seq1', 'se2', 'seq3', 'se4', 'seq5', 'seq6', 'seq7', 'seq8', 'seq9', 'seq10', 'seq11', 'seq12', 'seq13', 'seq14', 'seq15', 'seq16', 'seq17']

    # Define output paths
    dendrogram_output = os.path.join(os.getcwd(), "E:\BioCluster-Tool\imagedendrogram.png")
    heatmap_output = os.path.join(os.getcwd(), "E:\BioCluster-Tool\imageheatmap.png")

    # Generate and save images
    save_dendrogram(similarity_matrix, keys, dendrogram_output)
    save_heatmap(similarity_matrix, keys, heatmap_output)
