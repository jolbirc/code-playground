// Spinning cube in HolyC for TempleOS
// Uses ASCII art software rendering with rotation matrices

#define WIDTH  80
#define HEIGHT 40
#define FOV    40.0

F64 cubeVerts[8][3] = {
  {-1, -1, -1}, { 1, -1, -1}, { 1,  1, -1}, {-1,  1, -1},
  {-1, -1,  1}, { 1, -1,  1}, { 1,  1,  1}, {-1,  1,  1}
};

I64 edges[12][2] = {
  {0,1},{1,2},{2,3},{3,0},
  {4,5},{5,6},{6,7},{7,4},
  {0,4},{1,5},{2,6},{3,7}
};

F64 rotX[3][3], rotY[3][3], rotZ[3][3];

U0 MakeRotX(F64 a) {
  rotX[0][0]=1; rotX[0][1]=0;      rotX[0][2]=0;
  rotX[1][0]=0; rotX[1][1]=Cos(a); rotX[1][2]=-Sin(a);
  rotX[2][0]=0; rotX[2][1]=Sin(a); rotX[2][2]=Cos(a);
}

U0 MakeRotY(F64 a) {
  rotY[0][0]=Cos(a);  rotY[0][1]=0; rotY[0][2]=Sin(a);
  rotY[1][0]=0;       rotY[1][1]=1; rotY[1][2]=0;
  rotY[2][0]=-Sin(a); rotY[2][1]=0; rotY[2][2]=Cos(a);
}

U0 MakeRotZ(F64 a) {
  rotZ[0][0]=Cos(a); rotZ[0][1]=-Sin(a); rotZ[0][2]=0;
  rotZ[1][0]=Sin(a); rotZ[1][1]=Cos(a);  rotZ[1][2]=0;
  rotZ[2][0]=0;      rotZ[2][1]=0;        rotZ[2][2]=1;
}

U0 MatVec(F64 m[3][3], F64 v[3], F64 out[3]) {
  I64 i, j;
  for (i = 0; i < 3; i++) {
    out[i] = 0;
    for (j = 0; j < 3; j++)
      out[i] += m[i][j] * v[j];
  }
}

U0 Project(F64 v[3], I64 *px, I64 *py) {
  F64 z = v[2] + 4.0;
  if (z < 0.1) z = 0.1;
  F64 scale = FOV / z;
  *px = (I64)(v[0] * scale + WIDTH  / 2);
  *py = (I64)(v[1] * scale + HEIGHT / 2);
}

U0 DrawLine(U8 *buf, I64 x0, I64 y0, I64 x1, I64 y1, U8 ch) {
  I64 dx = Abs(x1 - x0), dy = Abs(y1 - y0);
  I64 sx = (x0 < x1) ? 1 : -1;
  I64 sy = (y0 < y1) ? 1 : -1;
  I64 err = dx - dy, e2, x = x0, y = y0;
  while (TRUE) {
    if (x >= 0 && x < WIDTH && y >= 0 && y < HEIGHT)
      buf[y * WIDTH + x] = ch;
    if (x == x1 && y == y1) break;
    e2 = 2 * err;
    if (e2 > -dy) { err -= dy; x += sx; }
    if (e2 <  dx) { err += dx; y += sy; }
  }
}

U0 SpinningCube() {
  U8 buf[HEIGHT * WIDTH + 1];
  F64 ax = 0.0, ay = 0.0, az = 0.0;
  F64 tmp[3], rx[3], rxy[3], rxyz[3];
  F64 projected[8][3];
  I64 px[8], py[8];
  I64 i, e;

  while (!ScanKey) {
    // Clear buffer
    for (i = 0; i < HEIGHT * WIDTH; i++)
      buf[i] = ' ';

    MakeRotX(ax);
    MakeRotY(ay);
    MakeRotZ(az);

    // Rotate and project each vertex
    for (i = 0; i < 8; i++) {
      MatVec(rotX, cubeVerts[i], rx);
      MatVec(rotY, rx, rxy);
      MatVec(rotZ, rxy, rxyz);
      projected[i][0] = rxyz[0];
      projected[i][1] = rxyz[1];
      projected[i][2] = rxyz[2];
      Project(rxyz, &px[i], &py[i]);
    }

    // Draw edges
    for (e = 0; e < 12; e++) {
      I64 a = edges[e][0], b = edges[e][1];
      DrawLine(buf, px[a], py[a], px[b], py[b], '#');
    }

    // Draw vertices on top
    for (i = 0; i < 8; i++) {
      if (px[i] >= 0 && px[i] < WIDTH && py[i] >= 0 && py[i] < HEIGHT)
        buf[py[i] * WIDTH + px[i]] = '@';
    }

    // Render to screen
    "\033[H";  // move cursor to top-left
    for (i = 0; i < HEIGHT; i++) {
      buf[i * WIDTH + WIDTH - 1] = '\0';
      "%s\n", &buf[i * WIDTH];
    }
    "\033[%d;1H  Spinning Cube  [any key to quit]", HEIGHT + 1;

    ax += 0.03;
    ay += 0.05;
    az += 0.02;
    Sleep(33);  // ~30fps
  }
}

"\033[2J";  // clear screen
SpinningCube;
"\033[2J";
"Cube stopped.\n";
