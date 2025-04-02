// Parámetros del modelo
int GRID_SIZE = 50;         // Tamaño del grid (50x50)
float OCCUPANCY = 0.75;     // Porcentaje de celdas ocupadas inicialmente
float p = 0.6;              // Probabilidad de que una persona intente contar el rumor
float q = 0.05;             // Probabilidad de que el vecino escuche el rumor
int TIME_STEPS = 60;        // Número total de iteraciones (simulando 180 minutos con paso de 3 minutos)
int currentStep = 0;        // Contador de pasos de tiempo

// Estados de las celdas
int VACIA = 0;
int OCUPADA_NO_SABE = 1;
int OCUPADA_SABE = 2;

// Matriz que representa el grid
int[][] grid = new int[GRID_SIZE][GRID_SIZE];

void setup() {
  size(500, 500);         // Tamaño de la ventana
  frameRate(1);           // Un paso de simulación por segundo (puedes ajustar según lo desees)
  initializeGrid();       // Inicializamos el grid con ocupación aleatoria y celda central con rumor
}

void draw() {
  if (currentStep < TIME_STEPS) {
    updateGrid();         // Actualizamos el grid según la difusión del rumor
    currentStep++;
  } else {
    noLoop();             // Detenemos la simulación al alcanzar el número de iteraciones
  }
  
  displayGrid();          // Dibujamos el estado actual del grid
}

// Inicializa el grid asignando aleatoriamente celdas ocupadas o vacías y 
// colocando el rumor en la celda central
void initializeGrid() {
  for (int i = 0; i < GRID_SIZE; i++) {
    for (int j = 0; j < GRID_SIZE; j++) {
      if (random(1) < OCCUPANCY) {
        grid[i][j] = OCUPADA_NO_SABE;
      } else {
        grid[i][j] = VACIA;
      }
    }
  }
  // La celda central inicia sabiendo el rumor
  grid[GRID_SIZE / 2][GRID_SIZE / 2] = OCUPADA_SABE;
}

// Actualiza el grid aplicando las reglas de difusión:
// Cada celda que sabe el rumor (estado 2) selecciona un vecino aleatorio y, 
// con probabilidad p y q, transmite el rumor si el vecino aún no lo sabe.
void updateGrid() {
  int[][] newGrid = copyGrid(grid);
  for (int i = 0; i < GRID_SIZE; i++) {
    for (int j = 0; j < GRID_SIZE; j++) {
      if (grid[i][j] == OCUPADA_SABE) {
        // Vecinos de Moore (8 posiciones)
        int[] dx = {-1, -1, -1, 0, 0, 1, 1, 1};
        int[] dy = {-1, 0, 1, -1, 1, -1, 0, 1};
        // Selecciona un vecino aleatorio
        int index = int(random(8));
        int ni = i + dx[index];
        int nj = j + dy[index];
        // Verifica que el vecino esté dentro de los límites y que sea una celda ocupada
        if (ni >= 0 && ni < GRID_SIZE && nj >= 0 && nj < GRID_SIZE) {
          if (grid[ni][nj] == OCUPADA_NO_SABE) {
            if (random(1) < p) {      // La persona decide contar el rumor
              if (random(1) < q) {    // El vecino lo escucha
                newGrid[ni][nj] = OCUPADA_SABE;
              }
            }
          }
        }
      }
    }
  }
  grid = newGrid;
}

// Función para copiar el grid actual (para evitar actualizar en el mismo paso)
int[][] copyGrid(int[][] source) {
  int[][] newGrid = new int[GRID_SIZE][GRID_SIZE];
  for (int i = 0; i < GRID_SIZE; i++) {
    for (int j = 0; j < GRID_SIZE; j++) {
      newGrid[i][j] = source[i][j];
    }
  }
  return newGrid;
}

// Función para visualizar el grid. 
// Cada celda se colorea según su estado:
//   - Blanco: Vacía
//   - Gris: Ocupada y sin conocer el rumor
//   - Rojo: Ocupada y que ya sabe el rumor
void displayGrid() {
  int cellWidth = width / GRID_SIZE;
  int cellHeight = height / GRID_SIZE;
  for (int i = 0; i < GRID_SIZE; i++) {
    for (int j = 0; j < GRID_SIZE; j++) {
      if (grid[i][j] == VACIA) {
        fill(255);  // blanco
      } else if (grid[i][j] == OCUPADA_NO_SABE) {
        fill(150);  // gris
      } else if (grid[i][j] == OCUPADA_SABE) {
        fill(255, 0, 0);  // rojo
      }
      stroke(0);    // borde de las celdas
      rect(j * cellWidth, i * cellHeight, cellWidth, cellHeight);
    }
  }
}
