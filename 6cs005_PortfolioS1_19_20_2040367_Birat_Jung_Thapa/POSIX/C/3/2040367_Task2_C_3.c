#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <crypt.h>
#include <time.h>

/***********************************************************************
*******

  Compile with:
    cc -o task2c3 2040367_Task2_C_3.c -lcrypt

    ./task2c3 > task2c3.txt
************************************************************************
******/


int n_passwords = 1;

char *encrypted_passwords[] = {
 "$6$AS$iHk20J571/kPUXRfcKd6.73Vzpkp.Uygop5a0Oq4m23.UBzYt1llV6g27zKF.BTqsVtp.MX/y9usB3EPnTY7E0"
};


void substr(char *dest, char *src, int start, int length){
  memcpy(dest, src + start, length);
  *(dest + length) = '\0';
}


void crack(char *salt_and_encrypted){
  int b, i, r, a;     // Loop counters
  char salt[7];    // String used in hashing the password. Need space for \0
  char plain[7];   // The combination of letters currently being checked
  char *enc;       // Pointer to the encrypted password
  int count = 0;   // The number of combinations explored so far

  substr(salt, salt_and_encrypted, 0, 6);

  for(b='A'; b<='Z'; b++){
    for(i='A'; i<='Z'; i++){
     for(r='A'; r<='Z'; r++){
      for(a=0; a<=99; a++){
        sprintf(plain, "%c%c%c%02d", b, i, r, a); 
        enc = (char *) crypt(plain, salt);
        count++;
        if(strcmp(salt_and_encrypted, enc) == 0){
          printf("#%-8d%s %s\n", count, plain, enc);
        } else {
          printf(" %-8d%s %s\n", count, plain, enc);
        }
       }  
      }
    }
  }
  printf("%d solutions explored\n", count);
}
int time_difference(struct timespec *start, struct timespec *finish, 
                    long long int *difference) {
  long long int ds =  finish->tv_sec - start->tv_sec; 
  long long int dn =  finish->tv_nsec - start->tv_nsec; 

  if(dn < 0 ) {
    ds--;
    dn += 1000000000; 
  } 
  *difference = ds * 1000000000 + dn;
  return !(*difference > 0);
}


int main(int argc, char *argv[]){
  int i;
struct timespec start, finish;   
  long long int time_elapsed;

  clock_gettime(CLOCK_MONOTONIC, &start);
 
  
  for(i=0;i<n_passwords;i<i++) {
    crack(encrypted_passwords[i]);
  }
  
 clock_gettime(CLOCK_MONOTONIC, &finish);
  time_difference(&start, &finish, &time_elapsed);
  printf("Time elapsed was %lldns or %0.9lfs\n", time_elapsed, 
         (time_elapsed/1.0e9)); 


  return 0;
}
