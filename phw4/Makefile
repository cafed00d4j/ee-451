all: p1_for p1_section p1_serial p2_omp p2_serial
p1_serial: p1_serial.c
	gcc -lrt -o p1_serial p1_serial.c
p1_for: p1_for.c
	gcc -lrt -fopenmp -o p1_for p1_for.c
p1_section: p1_section.c
	gcc -lrt -fopenmp -o p1_section p1_section.c
p2_omp: p2_omp.c
	gcc -lrt -fopenmp -o p2_omp p2_omp.c
p2_serial: p2_serial.c
	gcc -lrt -fopenmp -o p2_serial p2_serial.c
clean:
	rm p1_section p1_for p1_serial
