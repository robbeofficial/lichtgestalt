float[][] translation(float tx, float ty, float tz) {
  return new float[][] {
    {1,0,0,tx},
    {0,1,0,ty},
    {0,0,1,tz},
    {0,0,0,1},
  };
}

float[][] rotX(float phi) {
  float c = cos(phi); float s = sin(phi);
  return new float[][] {
    {1,0,0,0},
    {0,c,-s,0},
    {0,s,c,0},
    {0,0,0,1},
  };
}

float[][] rotY(float phi) {
  float c = cos(phi); float s = sin(phi);
  return new float[][] {
    {c,0,s,0},
    {0,1,0,0},
    {-s,0,c,0},
    {0,0,0,1},
  };
}

float[][] rotZ(float phi) {
  float c = cos(phi); float s = sin(phi);
  return new float[][] {
    {c,-s,0,0},
    {s,c,0,0},
    {0,0,1,0},
    {0,0,0,1},
  };
}

float[][] identity() {
  return new float[][] {
    {1,0,0,0},
    {0,1,0,0},
    {0,0,1,0},
    {0,0,0,1},
  };
}

// matrix-vector multiplication (y = A * x)
public float[] multiply(float[][] A, float[] x) {
    int m = A.length;
    int n = A[0].length;
    if (x.length != n) throw new RuntimeException("Illegal matrix dimensions.");
    float[] y = new float[m];
    for (int i = 0; i < m; i++)
        for (int j = 0; j < n; j++)
            y[i] += (A[i][j] * x[j]);
    return y;
}


// vector-matrix multiplication (y = x^T A)
public float[] multiply(float[] x, float[][] A) {
    int m = A.length;
    int n = A[0].length;
    if (x.length != m) throw new RuntimeException("Illegal matrix dimensions.");
    float[] y = new float[n];
    for (int j = 0; j < n; j++)
        for (int i = 0; i < m; i++)
            y[j] += (A[i][j] * x[i]);
    return y;
}

// return C = A * B
public float[][] multiply(float[][] A, float[][] B) {
    int mA = A.length;
    int nA = A[0].length;
    int mB = B.length;
    int nB = A[0].length;
    if (nA != mB) throw new RuntimeException("Illegal matrix dimensions.");
    float[][] C = new float[mA][nB];
    for (int i = 0; i < mA; i++)
        for (int j = 0; j < nB; j++)
            for (int k = 0; k < nA; k++)
                C[i][j] += (A[i][k] * B[k][j]);
    return C;
}

public String str(float[][] A) {
  int m = A.length;
  int n = A[0].length;
  
  StringBuilder sb = new StringBuilder();
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
      sb.append(A[i][j]).append('\t');
    }
    sb.append('\n');
  }
  return sb.toString();
}
