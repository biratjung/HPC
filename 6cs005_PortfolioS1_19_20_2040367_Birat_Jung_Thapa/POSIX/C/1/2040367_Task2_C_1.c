#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <crypt.h>
#include <unistd.h>
#include <time.h>

/********
 Passowrd: BE01
  Compile with cc -o task2c1 2040367_Task2_C_1.c -lcrypt
 
 ./task2c1 >task2c1.txt
*******/


int n_passwords = 1;

char *encrypted_passwords[] = {
	"$6$AS$M3J7Zk1gFfAYLJ/sujt3irgzlIngxqtP1RcYOiWnBWm/r/3fQ6wfvKIBxvKxdChMDiRueRbdMqxHDtt1tFhBy"
};


void substr(char *dest, char *src, int start, int length){
  memcpy(dest, src + start, length);
  *(dest + length) = '\0';
}


void crack(char *salt_and_encrypted){
  int b, i, a;     // Loop counters
  char salt[7];    // String used in hashing the password. Need space for \0 // incase you have modified the salt value, then should modifiy the number accordingly
  char plain[7];   // The combination of letters currently being checked // Please modifiy the number when you enlarge the encrypted password.
  char *enc;       // Pointer to the encrypted password
  int count=0;     // A counter used to track the number of combinations explored so far
  substr(salt, salt_and_encrypted, 0, 6);

  for(b='A'; b<='Z'; b++){
    for(i='A'; i<='Z'; i++){
      for(a=0; a<=99; a++){
        sprintf(plain, "%c%c%02d", b, i, a); 
        enc = (char *) crypt(plain, salt);
        count++;
        if(strcmp(salt_and_encrypted, enc) == 0){
	    printf("#%-8d%s %s\n", count, plain, enc);
		} else {
		printf("%-8d%s %s\n", count, plain, enc);
		}
		//return;	//uncomment this line if you want to speed-up the running time, program will find you the cracked password only without exploring all possibilites
        } 
      }
    }
    printf("%d solutions explored\n", count);
  }
  


//Calculating time

int time_difference(struct timespec *start, struct timespec *finish, long long int *difference)
 {
	  long long int ds =  finish->tv_sec - start->tv_sec;
	  long long int dn =  finish->tv_nsec - start->tv_nsec;

	  if(dn < 0 ) {
	    ds--;
	    dn += 1000000000;
  }
	  *difference = ds * 1000000000 + dn;
	  return !(*difference > 0);
}


int main(int argc, char *argv[])
{
  	int i;
	struct timespec start, finish;
  	long long int time_elapsed;

  	clock_gettime(CLOCK_MONOTONIC, &start);

  	for(i=0;i<n_passwords;i<i++)
	{
    		crack(encrypted_passwords[i]);
  	}
	clock_gettime(CLOCK_MONOTONIC, &finish);
	  time_difference(&start, &finish, &time_elapsed);
	  printf("Time elapsed was %lldns or %0.9lfs\n", time_elapsed,
		                                 (time_elapsed/1.0e9));
  return 0;
}
