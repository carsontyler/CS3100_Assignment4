
_bigtest:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "user.h"
#include "fcntl.h"

int
main()
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	81 ec 24 02 00 00    	sub    $0x224,%esp
  char buf[512];
  int fd, i, sectors;

  fd = open("big.file", O_CREATE | O_WRONLY);
  14:	83 ec 08             	sub    $0x8,%esp
  17:	68 01 02 00 00       	push   $0x201
  1c:	68 38 09 00 00       	push   $0x938
  21:	e8 04 04 00 00       	call   42a <open>
  26:	83 c4 10             	add    $0x10,%esp
  29:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
  2c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  30:	79 17                	jns    49 <main+0x49>
    printf(2, "big: cannot open big.file for writing\n");
  32:	83 ec 08             	sub    $0x8,%esp
  35:	68 44 09 00 00       	push   $0x944
  3a:	6a 02                	push   $0x2
  3c:	e8 40 05 00 00       	call   581 <printf>
  41:	83 c4 10             	add    $0x10,%esp
    exit();
  44:	e8 a1 03 00 00       	call   3ea <exit>
  }

  sectors = 0;
  49:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  while(1){
    *(int*)buf = sectors;
  50:	8d 85 e4 fd ff ff    	lea    -0x21c(%ebp),%eax
  56:	8b 55 f0             	mov    -0x10(%ebp),%edx
  59:	89 10                	mov    %edx,(%eax)
    int cc = write(fd, buf, sizeof(buf));
  5b:	83 ec 04             	sub    $0x4,%esp
  5e:	68 00 02 00 00       	push   $0x200
  63:	8d 85 e4 fd ff ff    	lea    -0x21c(%ebp),%eax
  69:	50                   	push   %eax
  6a:	ff 75 ec             	pushl  -0x14(%ebp)
  6d:	e8 98 03 00 00       	call   40a <write>
  72:	83 c4 10             	add    $0x10,%esp
  75:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(cc <= 0)
  78:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  7c:	7e 3b                	jle    b9 <main+0xb9>
      break;
    sectors++;
  7e:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
	if (sectors % 100 == 0)
  82:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  85:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  8a:	89 c8                	mov    %ecx,%eax
  8c:	f7 ea                	imul   %edx
  8e:	c1 fa 05             	sar    $0x5,%edx
  91:	89 c8                	mov    %ecx,%eax
  93:	c1 f8 1f             	sar    $0x1f,%eax
  96:	29 c2                	sub    %eax,%edx
  98:	89 d0                	mov    %edx,%eax
  9a:	6b c0 64             	imul   $0x64,%eax,%eax
  9d:	29 c1                	sub    %eax,%ecx
  9f:	89 c8                	mov    %ecx,%eax
  a1:	85 c0                	test   %eax,%eax
  a3:	75 ab                	jne    50 <main+0x50>
		printf(2, ".");
  a5:	83 ec 08             	sub    $0x8,%esp
  a8:	68 6b 09 00 00       	push   $0x96b
  ad:	6a 02                	push   $0x2
  af:	e8 cd 04 00 00       	call   581 <printf>
  b4:	83 c4 10             	add    $0x10,%esp
  }
  b7:	eb 97                	jmp    50 <main+0x50>
  sectors = 0;
  while(1){
    *(int*)buf = sectors;
    int cc = write(fd, buf, sizeof(buf));
    if(cc <= 0)
      break;
  b9:	90                   	nop
    sectors++;
	if (sectors % 100 == 0)
		printf(2, ".");
  }

  printf(1, "\nwrote %d sectors\n", sectors);
  ba:	83 ec 04             	sub    $0x4,%esp
  bd:	ff 75 f0             	pushl  -0x10(%ebp)
  c0:	68 6d 09 00 00       	push   $0x96d
  c5:	6a 01                	push   $0x1
  c7:	e8 b5 04 00 00       	call   581 <printf>
  cc:	83 c4 10             	add    $0x10,%esp

  close(fd);
  cf:	83 ec 0c             	sub    $0xc,%esp
  d2:	ff 75 ec             	pushl  -0x14(%ebp)
  d5:	e8 38 03 00 00       	call   412 <close>
  da:	83 c4 10             	add    $0x10,%esp
  fd = open("big.file", O_RDONLY);
  dd:	83 ec 08             	sub    $0x8,%esp
  e0:	6a 00                	push   $0x0
  e2:	68 38 09 00 00       	push   $0x938
  e7:	e8 3e 03 00 00       	call   42a <open>
  ec:	83 c4 10             	add    $0x10,%esp
  ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
  f2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  f6:	79 17                	jns    10f <main+0x10f>
    printf(2, "big: cannot re-open big.file for reading\n");
  f8:	83 ec 08             	sub    $0x8,%esp
  fb:	68 80 09 00 00       	push   $0x980
 100:	6a 02                	push   $0x2
 102:	e8 7a 04 00 00       	call   581 <printf>
 107:	83 c4 10             	add    $0x10,%esp
    exit();
 10a:	e8 db 02 00 00       	call   3ea <exit>
  }
  for(i = 0; i < sectors; i++){
 10f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 116:	eb 6e                	jmp    186 <main+0x186>
    int cc = read(fd, buf, sizeof(buf));
 118:	83 ec 04             	sub    $0x4,%esp
 11b:	68 00 02 00 00       	push   $0x200
 120:	8d 85 e4 fd ff ff    	lea    -0x21c(%ebp),%eax
 126:	50                   	push   %eax
 127:	ff 75 ec             	pushl  -0x14(%ebp)
 12a:	e8 d3 02 00 00       	call   402 <read>
 12f:	83 c4 10             	add    $0x10,%esp
 132:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(cc <= 0){
 135:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
 139:	7f 1a                	jg     155 <main+0x155>
      printf(2, "big: read error at sector %d\n", i);
 13b:	83 ec 04             	sub    $0x4,%esp
 13e:	ff 75 f4             	pushl  -0xc(%ebp)
 141:	68 aa 09 00 00       	push   $0x9aa
 146:	6a 02                	push   $0x2
 148:	e8 34 04 00 00       	call   581 <printf>
 14d:	83 c4 10             	add    $0x10,%esp
      exit();
 150:	e8 95 02 00 00       	call   3ea <exit>
    }
    if(*(int*)buf != i){
 155:	8d 85 e4 fd ff ff    	lea    -0x21c(%ebp),%eax
 15b:	8b 00                	mov    (%eax),%eax
 15d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 160:	74 20                	je     182 <main+0x182>
      printf(2, "big: read the wrong data (%d) for sector %d\n",
             *(int*)buf, i);
 162:	8d 85 e4 fd ff ff    	lea    -0x21c(%ebp),%eax
    if(cc <= 0){
      printf(2, "big: read error at sector %d\n", i);
      exit();
    }
    if(*(int*)buf != i){
      printf(2, "big: read the wrong data (%d) for sector %d\n",
 168:	8b 00                	mov    (%eax),%eax
 16a:	ff 75 f4             	pushl  -0xc(%ebp)
 16d:	50                   	push   %eax
 16e:	68 c8 09 00 00       	push   $0x9c8
 173:	6a 02                	push   $0x2
 175:	e8 07 04 00 00       	call   581 <printf>
 17a:	83 c4 10             	add    $0x10,%esp
             *(int*)buf, i);
      exit();
 17d:	e8 68 02 00 00       	call   3ea <exit>
  fd = open("big.file", O_RDONLY);
  if(fd < 0){
    printf(2, "big: cannot re-open big.file for reading\n");
    exit();
  }
  for(i = 0; i < sectors; i++){
 182:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 186:	8b 45 f4             	mov    -0xc(%ebp),%eax
 189:	3b 45 f0             	cmp    -0x10(%ebp),%eax
 18c:	7c 8a                	jl     118 <main+0x118>
             *(int*)buf, i);
      exit();
    }
  }

  exit();
 18e:	e8 57 02 00 00       	call   3ea <exit>

00000193 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 193:	55                   	push   %ebp
 194:	89 e5                	mov    %esp,%ebp
 196:	57                   	push   %edi
 197:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 198:	8b 4d 08             	mov    0x8(%ebp),%ecx
 19b:	8b 55 10             	mov    0x10(%ebp),%edx
 19e:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a1:	89 cb                	mov    %ecx,%ebx
 1a3:	89 df                	mov    %ebx,%edi
 1a5:	89 d1                	mov    %edx,%ecx
 1a7:	fc                   	cld    
 1a8:	f3 aa                	rep stos %al,%es:(%edi)
 1aa:	89 ca                	mov    %ecx,%edx
 1ac:	89 fb                	mov    %edi,%ebx
 1ae:	89 5d 08             	mov    %ebx,0x8(%ebp)
 1b1:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 1b4:	90                   	nop
 1b5:	5b                   	pop    %ebx
 1b6:	5f                   	pop    %edi
 1b7:	5d                   	pop    %ebp
 1b8:	c3                   	ret    

000001b9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 1b9:	55                   	push   %ebp
 1ba:	89 e5                	mov    %esp,%ebp
 1bc:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 1bf:	8b 45 08             	mov    0x8(%ebp),%eax
 1c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 1c5:	90                   	nop
 1c6:	8b 45 08             	mov    0x8(%ebp),%eax
 1c9:	8d 50 01             	lea    0x1(%eax),%edx
 1cc:	89 55 08             	mov    %edx,0x8(%ebp)
 1cf:	8b 55 0c             	mov    0xc(%ebp),%edx
 1d2:	8d 4a 01             	lea    0x1(%edx),%ecx
 1d5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 1d8:	0f b6 12             	movzbl (%edx),%edx
 1db:	88 10                	mov    %dl,(%eax)
 1dd:	0f b6 00             	movzbl (%eax),%eax
 1e0:	84 c0                	test   %al,%al
 1e2:	75 e2                	jne    1c6 <strcpy+0xd>
    ;
  return os;
 1e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1e7:	c9                   	leave  
 1e8:	c3                   	ret    

000001e9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1e9:	55                   	push   %ebp
 1ea:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 1ec:	eb 08                	jmp    1f6 <strcmp+0xd>
    p++, q++;
 1ee:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1f2:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 1f6:	8b 45 08             	mov    0x8(%ebp),%eax
 1f9:	0f b6 00             	movzbl (%eax),%eax
 1fc:	84 c0                	test   %al,%al
 1fe:	74 10                	je     210 <strcmp+0x27>
 200:	8b 45 08             	mov    0x8(%ebp),%eax
 203:	0f b6 10             	movzbl (%eax),%edx
 206:	8b 45 0c             	mov    0xc(%ebp),%eax
 209:	0f b6 00             	movzbl (%eax),%eax
 20c:	38 c2                	cmp    %al,%dl
 20e:	74 de                	je     1ee <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 210:	8b 45 08             	mov    0x8(%ebp),%eax
 213:	0f b6 00             	movzbl (%eax),%eax
 216:	0f b6 d0             	movzbl %al,%edx
 219:	8b 45 0c             	mov    0xc(%ebp),%eax
 21c:	0f b6 00             	movzbl (%eax),%eax
 21f:	0f b6 c0             	movzbl %al,%eax
 222:	29 c2                	sub    %eax,%edx
 224:	89 d0                	mov    %edx,%eax
}
 226:	5d                   	pop    %ebp
 227:	c3                   	ret    

00000228 <strlen>:

uint
strlen(char *s)
{
 228:	55                   	push   %ebp
 229:	89 e5                	mov    %esp,%ebp
 22b:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 22e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 235:	eb 04                	jmp    23b <strlen+0x13>
 237:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 23b:	8b 55 fc             	mov    -0x4(%ebp),%edx
 23e:	8b 45 08             	mov    0x8(%ebp),%eax
 241:	01 d0                	add    %edx,%eax
 243:	0f b6 00             	movzbl (%eax),%eax
 246:	84 c0                	test   %al,%al
 248:	75 ed                	jne    237 <strlen+0xf>
    ;
  return n;
 24a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 24d:	c9                   	leave  
 24e:	c3                   	ret    

0000024f <memset>:

void*
memset(void *dst, int c, uint n)
{
 24f:	55                   	push   %ebp
 250:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 252:	8b 45 10             	mov    0x10(%ebp),%eax
 255:	50                   	push   %eax
 256:	ff 75 0c             	pushl  0xc(%ebp)
 259:	ff 75 08             	pushl  0x8(%ebp)
 25c:	e8 32 ff ff ff       	call   193 <stosb>
 261:	83 c4 0c             	add    $0xc,%esp
  return dst;
 264:	8b 45 08             	mov    0x8(%ebp),%eax
}
 267:	c9                   	leave  
 268:	c3                   	ret    

00000269 <strchr>:

char*
strchr(const char *s, char c)
{
 269:	55                   	push   %ebp
 26a:	89 e5                	mov    %esp,%ebp
 26c:	83 ec 04             	sub    $0x4,%esp
 26f:	8b 45 0c             	mov    0xc(%ebp),%eax
 272:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 275:	eb 14                	jmp    28b <strchr+0x22>
    if(*s == c)
 277:	8b 45 08             	mov    0x8(%ebp),%eax
 27a:	0f b6 00             	movzbl (%eax),%eax
 27d:	3a 45 fc             	cmp    -0x4(%ebp),%al
 280:	75 05                	jne    287 <strchr+0x1e>
      return (char*)s;
 282:	8b 45 08             	mov    0x8(%ebp),%eax
 285:	eb 13                	jmp    29a <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 287:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 28b:	8b 45 08             	mov    0x8(%ebp),%eax
 28e:	0f b6 00             	movzbl (%eax),%eax
 291:	84 c0                	test   %al,%al
 293:	75 e2                	jne    277 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 295:	b8 00 00 00 00       	mov    $0x0,%eax
}
 29a:	c9                   	leave  
 29b:	c3                   	ret    

0000029c <gets>:

char*
gets(char *buf, int max)
{
 29c:	55                   	push   %ebp
 29d:	89 e5                	mov    %esp,%ebp
 29f:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 2a9:	eb 42                	jmp    2ed <gets+0x51>
    cc = read(0, &c, 1);
 2ab:	83 ec 04             	sub    $0x4,%esp
 2ae:	6a 01                	push   $0x1
 2b0:	8d 45 ef             	lea    -0x11(%ebp),%eax
 2b3:	50                   	push   %eax
 2b4:	6a 00                	push   $0x0
 2b6:	e8 47 01 00 00       	call   402 <read>
 2bb:	83 c4 10             	add    $0x10,%esp
 2be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 2c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 2c5:	7e 33                	jle    2fa <gets+0x5e>
      break;
    buf[i++] = c;
 2c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ca:	8d 50 01             	lea    0x1(%eax),%edx
 2cd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 2d0:	89 c2                	mov    %eax,%edx
 2d2:	8b 45 08             	mov    0x8(%ebp),%eax
 2d5:	01 c2                	add    %eax,%edx
 2d7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2db:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 2dd:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2e1:	3c 0a                	cmp    $0xa,%al
 2e3:	74 16                	je     2fb <gets+0x5f>
 2e5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 2e9:	3c 0d                	cmp    $0xd,%al
 2eb:	74 0e                	je     2fb <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2f0:	83 c0 01             	add    $0x1,%eax
 2f3:	3b 45 0c             	cmp    0xc(%ebp),%eax
 2f6:	7c b3                	jl     2ab <gets+0xf>
 2f8:	eb 01                	jmp    2fb <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 2fa:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 2fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
 2fe:	8b 45 08             	mov    0x8(%ebp),%eax
 301:	01 d0                	add    %edx,%eax
 303:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 306:	8b 45 08             	mov    0x8(%ebp),%eax
}
 309:	c9                   	leave  
 30a:	c3                   	ret    

0000030b <stat>:

int
stat(char *n, struct stat *st)
{
 30b:	55                   	push   %ebp
 30c:	89 e5                	mov    %esp,%ebp
 30e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 311:	83 ec 08             	sub    $0x8,%esp
 314:	6a 00                	push   $0x0
 316:	ff 75 08             	pushl  0x8(%ebp)
 319:	e8 0c 01 00 00       	call   42a <open>
 31e:	83 c4 10             	add    $0x10,%esp
 321:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 324:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 328:	79 07                	jns    331 <stat+0x26>
    return -1;
 32a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 32f:	eb 25                	jmp    356 <stat+0x4b>
  r = fstat(fd, st);
 331:	83 ec 08             	sub    $0x8,%esp
 334:	ff 75 0c             	pushl  0xc(%ebp)
 337:	ff 75 f4             	pushl  -0xc(%ebp)
 33a:	e8 03 01 00 00       	call   442 <fstat>
 33f:	83 c4 10             	add    $0x10,%esp
 342:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 345:	83 ec 0c             	sub    $0xc,%esp
 348:	ff 75 f4             	pushl  -0xc(%ebp)
 34b:	e8 c2 00 00 00       	call   412 <close>
 350:	83 c4 10             	add    $0x10,%esp
  return r;
 353:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 356:	c9                   	leave  
 357:	c3                   	ret    

00000358 <atoi>:

int
atoi(const char *s)
{
 358:	55                   	push   %ebp
 359:	89 e5                	mov    %esp,%ebp
 35b:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 35e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 365:	eb 25                	jmp    38c <atoi+0x34>
    n = n*10 + *s++ - '0';
 367:	8b 55 fc             	mov    -0x4(%ebp),%edx
 36a:	89 d0                	mov    %edx,%eax
 36c:	c1 e0 02             	shl    $0x2,%eax
 36f:	01 d0                	add    %edx,%eax
 371:	01 c0                	add    %eax,%eax
 373:	89 c1                	mov    %eax,%ecx
 375:	8b 45 08             	mov    0x8(%ebp),%eax
 378:	8d 50 01             	lea    0x1(%eax),%edx
 37b:	89 55 08             	mov    %edx,0x8(%ebp)
 37e:	0f b6 00             	movzbl (%eax),%eax
 381:	0f be c0             	movsbl %al,%eax
 384:	01 c8                	add    %ecx,%eax
 386:	83 e8 30             	sub    $0x30,%eax
 389:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 38c:	8b 45 08             	mov    0x8(%ebp),%eax
 38f:	0f b6 00             	movzbl (%eax),%eax
 392:	3c 2f                	cmp    $0x2f,%al
 394:	7e 0a                	jle    3a0 <atoi+0x48>
 396:	8b 45 08             	mov    0x8(%ebp),%eax
 399:	0f b6 00             	movzbl (%eax),%eax
 39c:	3c 39                	cmp    $0x39,%al
 39e:	7e c7                	jle    367 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 3a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3a3:	c9                   	leave  
 3a4:	c3                   	ret    

000003a5 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 3a5:	55                   	push   %ebp
 3a6:	89 e5                	mov    %esp,%ebp
 3a8:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 3ab:	8b 45 08             	mov    0x8(%ebp),%eax
 3ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 3b1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 3b7:	eb 17                	jmp    3d0 <memmove+0x2b>
    *dst++ = *src++;
 3b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 3bc:	8d 50 01             	lea    0x1(%eax),%edx
 3bf:	89 55 fc             	mov    %edx,-0x4(%ebp)
 3c2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 3c5:	8d 4a 01             	lea    0x1(%edx),%ecx
 3c8:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 3cb:	0f b6 12             	movzbl (%edx),%edx
 3ce:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 3d0:	8b 45 10             	mov    0x10(%ebp),%eax
 3d3:	8d 50 ff             	lea    -0x1(%eax),%edx
 3d6:	89 55 10             	mov    %edx,0x10(%ebp)
 3d9:	85 c0                	test   %eax,%eax
 3db:	7f dc                	jg     3b9 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 3dd:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3e0:	c9                   	leave  
 3e1:	c3                   	ret    

000003e2 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3e2:	b8 01 00 00 00       	mov    $0x1,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	ret    

000003ea <exit>:
SYSCALL(exit)
 3ea:	b8 02 00 00 00       	mov    $0x2,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	ret    

000003f2 <wait>:
SYSCALL(wait)
 3f2:	b8 03 00 00 00       	mov    $0x3,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	ret    

000003fa <pipe>:
SYSCALL(pipe)
 3fa:	b8 04 00 00 00       	mov    $0x4,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	ret    

00000402 <read>:
SYSCALL(read)
 402:	b8 05 00 00 00       	mov    $0x5,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	ret    

0000040a <write>:
SYSCALL(write)
 40a:	b8 10 00 00 00       	mov    $0x10,%eax
 40f:	cd 40                	int    $0x40
 411:	c3                   	ret    

00000412 <close>:
SYSCALL(close)
 412:	b8 15 00 00 00       	mov    $0x15,%eax
 417:	cd 40                	int    $0x40
 419:	c3                   	ret    

0000041a <kill>:
SYSCALL(kill)
 41a:	b8 06 00 00 00       	mov    $0x6,%eax
 41f:	cd 40                	int    $0x40
 421:	c3                   	ret    

00000422 <exec>:
SYSCALL(exec)
 422:	b8 07 00 00 00       	mov    $0x7,%eax
 427:	cd 40                	int    $0x40
 429:	c3                   	ret    

0000042a <open>:
SYSCALL(open)
 42a:	b8 0f 00 00 00       	mov    $0xf,%eax
 42f:	cd 40                	int    $0x40
 431:	c3                   	ret    

00000432 <mknod>:
SYSCALL(mknod)
 432:	b8 11 00 00 00       	mov    $0x11,%eax
 437:	cd 40                	int    $0x40
 439:	c3                   	ret    

0000043a <unlink>:
SYSCALL(unlink)
 43a:	b8 12 00 00 00       	mov    $0x12,%eax
 43f:	cd 40                	int    $0x40
 441:	c3                   	ret    

00000442 <fstat>:
SYSCALL(fstat)
 442:	b8 08 00 00 00       	mov    $0x8,%eax
 447:	cd 40                	int    $0x40
 449:	c3                   	ret    

0000044a <link>:
SYSCALL(link)
 44a:	b8 13 00 00 00       	mov    $0x13,%eax
 44f:	cd 40                	int    $0x40
 451:	c3                   	ret    

00000452 <mkdir>:
SYSCALL(mkdir)
 452:	b8 14 00 00 00       	mov    $0x14,%eax
 457:	cd 40                	int    $0x40
 459:	c3                   	ret    

0000045a <chdir>:
SYSCALL(chdir)
 45a:	b8 09 00 00 00       	mov    $0x9,%eax
 45f:	cd 40                	int    $0x40
 461:	c3                   	ret    

00000462 <dup>:
SYSCALL(dup)
 462:	b8 0a 00 00 00       	mov    $0xa,%eax
 467:	cd 40                	int    $0x40
 469:	c3                   	ret    

0000046a <getpid>:
SYSCALL(getpid)
 46a:	b8 0b 00 00 00       	mov    $0xb,%eax
 46f:	cd 40                	int    $0x40
 471:	c3                   	ret    

00000472 <sbrk>:
SYSCALL(sbrk)
 472:	b8 0c 00 00 00       	mov    $0xc,%eax
 477:	cd 40                	int    $0x40
 479:	c3                   	ret    

0000047a <sleep>:
SYSCALL(sleep)
 47a:	b8 0d 00 00 00       	mov    $0xd,%eax
 47f:	cd 40                	int    $0x40
 481:	c3                   	ret    

00000482 <uptime>:
SYSCALL(uptime)
 482:	b8 0e 00 00 00       	mov    $0xe,%eax
 487:	cd 40                	int    $0x40
 489:	c3                   	ret    

0000048a <getMagic>:
SYSCALL(getMagic)
 48a:	b8 17 00 00 00       	mov    $0x17,%eax
 48f:	cd 40                	int    $0x40
 491:	c3                   	ret    

00000492 <incrementMagic>:
SYSCALL(incrementMagic)
 492:	b8 16 00 00 00       	mov    $0x16,%eax
 497:	cd 40                	int    $0x40
 499:	c3                   	ret    

0000049a <getCurrentProcessName>:
SYSCALL(getCurrentProcessName)
 49a:	b8 18 00 00 00       	mov    $0x18,%eax
 49f:	cd 40                	int    $0x40
 4a1:	c3                   	ret    

000004a2 <modifyCurrentProcessName>:
SYSCALL(modifyCurrentProcessName)
 4a2:	b8 19 00 00 00       	mov    $0x19,%eax
 4a7:	cd 40                	int    $0x40
 4a9:	c3                   	ret    

000004aa <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 4aa:	55                   	push   %ebp
 4ab:	89 e5                	mov    %esp,%ebp
 4ad:	83 ec 18             	sub    $0x18,%esp
 4b0:	8b 45 0c             	mov    0xc(%ebp),%eax
 4b3:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 4b6:	83 ec 04             	sub    $0x4,%esp
 4b9:	6a 01                	push   $0x1
 4bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
 4be:	50                   	push   %eax
 4bf:	ff 75 08             	pushl  0x8(%ebp)
 4c2:	e8 43 ff ff ff       	call   40a <write>
 4c7:	83 c4 10             	add    $0x10,%esp
}
 4ca:	90                   	nop
 4cb:	c9                   	leave  
 4cc:	c3                   	ret    

000004cd <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4cd:	55                   	push   %ebp
 4ce:	89 e5                	mov    %esp,%ebp
 4d0:	53                   	push   %ebx
 4d1:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 4d4:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 4db:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 4df:	74 17                	je     4f8 <printint+0x2b>
 4e1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 4e5:	79 11                	jns    4f8 <printint+0x2b>
    neg = 1;
 4e7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 4ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f1:	f7 d8                	neg    %eax
 4f3:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4f6:	eb 06                	jmp    4fe <printint+0x31>
  } else {
    x = xx;
 4f8:	8b 45 0c             	mov    0xc(%ebp),%eax
 4fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 4fe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 505:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 508:	8d 41 01             	lea    0x1(%ecx),%eax
 50b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 50e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 511:	8b 45 ec             	mov    -0x14(%ebp),%eax
 514:	ba 00 00 00 00       	mov    $0x0,%edx
 519:	f7 f3                	div    %ebx
 51b:	89 d0                	mov    %edx,%eax
 51d:	0f b6 80 44 0c 00 00 	movzbl 0xc44(%eax),%eax
 524:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 528:	8b 5d 10             	mov    0x10(%ebp),%ebx
 52b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 52e:	ba 00 00 00 00       	mov    $0x0,%edx
 533:	f7 f3                	div    %ebx
 535:	89 45 ec             	mov    %eax,-0x14(%ebp)
 538:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 53c:	75 c7                	jne    505 <printint+0x38>
  if(neg)
 53e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 542:	74 2d                	je     571 <printint+0xa4>
    buf[i++] = '-';
 544:	8b 45 f4             	mov    -0xc(%ebp),%eax
 547:	8d 50 01             	lea    0x1(%eax),%edx
 54a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 54d:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 552:	eb 1d                	jmp    571 <printint+0xa4>
    putc(fd, buf[i]);
 554:	8d 55 dc             	lea    -0x24(%ebp),%edx
 557:	8b 45 f4             	mov    -0xc(%ebp),%eax
 55a:	01 d0                	add    %edx,%eax
 55c:	0f b6 00             	movzbl (%eax),%eax
 55f:	0f be c0             	movsbl %al,%eax
 562:	83 ec 08             	sub    $0x8,%esp
 565:	50                   	push   %eax
 566:	ff 75 08             	pushl  0x8(%ebp)
 569:	e8 3c ff ff ff       	call   4aa <putc>
 56e:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 571:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 575:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 579:	79 d9                	jns    554 <printint+0x87>
    putc(fd, buf[i]);
}
 57b:	90                   	nop
 57c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 57f:	c9                   	leave  
 580:	c3                   	ret    

00000581 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 581:	55                   	push   %ebp
 582:	89 e5                	mov    %esp,%ebp
 584:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 587:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 58e:	8d 45 0c             	lea    0xc(%ebp),%eax
 591:	83 c0 04             	add    $0x4,%eax
 594:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 597:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 59e:	e9 59 01 00 00       	jmp    6fc <printf+0x17b>
    c = fmt[i] & 0xff;
 5a3:	8b 55 0c             	mov    0xc(%ebp),%edx
 5a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5a9:	01 d0                	add    %edx,%eax
 5ab:	0f b6 00             	movzbl (%eax),%eax
 5ae:	0f be c0             	movsbl %al,%eax
 5b1:	25 ff 00 00 00       	and    $0xff,%eax
 5b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 5b9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5bd:	75 2c                	jne    5eb <printf+0x6a>
      if(c == '%'){
 5bf:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5c3:	75 0c                	jne    5d1 <printf+0x50>
        state = '%';
 5c5:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 5cc:	e9 27 01 00 00       	jmp    6f8 <printf+0x177>
      } else {
        putc(fd, c);
 5d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5d4:	0f be c0             	movsbl %al,%eax
 5d7:	83 ec 08             	sub    $0x8,%esp
 5da:	50                   	push   %eax
 5db:	ff 75 08             	pushl  0x8(%ebp)
 5de:	e8 c7 fe ff ff       	call   4aa <putc>
 5e3:	83 c4 10             	add    $0x10,%esp
 5e6:	e9 0d 01 00 00       	jmp    6f8 <printf+0x177>
      }
    } else if(state == '%'){
 5eb:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 5ef:	0f 85 03 01 00 00    	jne    6f8 <printf+0x177>
      if(c == 'd'){
 5f5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 5f9:	75 1e                	jne    619 <printf+0x98>
        printint(fd, *ap, 10, 1);
 5fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5fe:	8b 00                	mov    (%eax),%eax
 600:	6a 01                	push   $0x1
 602:	6a 0a                	push   $0xa
 604:	50                   	push   %eax
 605:	ff 75 08             	pushl  0x8(%ebp)
 608:	e8 c0 fe ff ff       	call   4cd <printint>
 60d:	83 c4 10             	add    $0x10,%esp
        ap++;
 610:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 614:	e9 d8 00 00 00       	jmp    6f1 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 619:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 61d:	74 06                	je     625 <printf+0xa4>
 61f:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 623:	75 1e                	jne    643 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 625:	8b 45 e8             	mov    -0x18(%ebp),%eax
 628:	8b 00                	mov    (%eax),%eax
 62a:	6a 00                	push   $0x0
 62c:	6a 10                	push   $0x10
 62e:	50                   	push   %eax
 62f:	ff 75 08             	pushl  0x8(%ebp)
 632:	e8 96 fe ff ff       	call   4cd <printint>
 637:	83 c4 10             	add    $0x10,%esp
        ap++;
 63a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 63e:	e9 ae 00 00 00       	jmp    6f1 <printf+0x170>
      } else if(c == 's'){
 643:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 647:	75 43                	jne    68c <printf+0x10b>
        s = (char*)*ap;
 649:	8b 45 e8             	mov    -0x18(%ebp),%eax
 64c:	8b 00                	mov    (%eax),%eax
 64e:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 651:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 655:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 659:	75 25                	jne    680 <printf+0xff>
          s = "(null)";
 65b:	c7 45 f4 f5 09 00 00 	movl   $0x9f5,-0xc(%ebp)
        while(*s != 0){
 662:	eb 1c                	jmp    680 <printf+0xff>
          putc(fd, *s);
 664:	8b 45 f4             	mov    -0xc(%ebp),%eax
 667:	0f b6 00             	movzbl (%eax),%eax
 66a:	0f be c0             	movsbl %al,%eax
 66d:	83 ec 08             	sub    $0x8,%esp
 670:	50                   	push   %eax
 671:	ff 75 08             	pushl  0x8(%ebp)
 674:	e8 31 fe ff ff       	call   4aa <putc>
 679:	83 c4 10             	add    $0x10,%esp
          s++;
 67c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 680:	8b 45 f4             	mov    -0xc(%ebp),%eax
 683:	0f b6 00             	movzbl (%eax),%eax
 686:	84 c0                	test   %al,%al
 688:	75 da                	jne    664 <printf+0xe3>
 68a:	eb 65                	jmp    6f1 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 68c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 690:	75 1d                	jne    6af <printf+0x12e>
        putc(fd, *ap);
 692:	8b 45 e8             	mov    -0x18(%ebp),%eax
 695:	8b 00                	mov    (%eax),%eax
 697:	0f be c0             	movsbl %al,%eax
 69a:	83 ec 08             	sub    $0x8,%esp
 69d:	50                   	push   %eax
 69e:	ff 75 08             	pushl  0x8(%ebp)
 6a1:	e8 04 fe ff ff       	call   4aa <putc>
 6a6:	83 c4 10             	add    $0x10,%esp
        ap++;
 6a9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6ad:	eb 42                	jmp    6f1 <printf+0x170>
      } else if(c == '%'){
 6af:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6b3:	75 17                	jne    6cc <printf+0x14b>
        putc(fd, c);
 6b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6b8:	0f be c0             	movsbl %al,%eax
 6bb:	83 ec 08             	sub    $0x8,%esp
 6be:	50                   	push   %eax
 6bf:	ff 75 08             	pushl  0x8(%ebp)
 6c2:	e8 e3 fd ff ff       	call   4aa <putc>
 6c7:	83 c4 10             	add    $0x10,%esp
 6ca:	eb 25                	jmp    6f1 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6cc:	83 ec 08             	sub    $0x8,%esp
 6cf:	6a 25                	push   $0x25
 6d1:	ff 75 08             	pushl  0x8(%ebp)
 6d4:	e8 d1 fd ff ff       	call   4aa <putc>
 6d9:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 6dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6df:	0f be c0             	movsbl %al,%eax
 6e2:	83 ec 08             	sub    $0x8,%esp
 6e5:	50                   	push   %eax
 6e6:	ff 75 08             	pushl  0x8(%ebp)
 6e9:	e8 bc fd ff ff       	call   4aa <putc>
 6ee:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 6f1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 6f8:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 6fc:	8b 55 0c             	mov    0xc(%ebp),%edx
 6ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
 702:	01 d0                	add    %edx,%eax
 704:	0f b6 00             	movzbl (%eax),%eax
 707:	84 c0                	test   %al,%al
 709:	0f 85 94 fe ff ff    	jne    5a3 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 70f:	90                   	nop
 710:	c9                   	leave  
 711:	c3                   	ret    

00000712 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 712:	55                   	push   %ebp
 713:	89 e5                	mov    %esp,%ebp
 715:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 718:	8b 45 08             	mov    0x8(%ebp),%eax
 71b:	83 e8 08             	sub    $0x8,%eax
 71e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 721:	a1 60 0c 00 00       	mov    0xc60,%eax
 726:	89 45 fc             	mov    %eax,-0x4(%ebp)
 729:	eb 24                	jmp    74f <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 72b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 72e:	8b 00                	mov    (%eax),%eax
 730:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 733:	77 12                	ja     747 <free+0x35>
 735:	8b 45 f8             	mov    -0x8(%ebp),%eax
 738:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 73b:	77 24                	ja     761 <free+0x4f>
 73d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 740:	8b 00                	mov    (%eax),%eax
 742:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 745:	77 1a                	ja     761 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 747:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74a:	8b 00                	mov    (%eax),%eax
 74c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 74f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 752:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 755:	76 d4                	jbe    72b <free+0x19>
 757:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75a:	8b 00                	mov    (%eax),%eax
 75c:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 75f:	76 ca                	jbe    72b <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 761:	8b 45 f8             	mov    -0x8(%ebp),%eax
 764:	8b 40 04             	mov    0x4(%eax),%eax
 767:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 76e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 771:	01 c2                	add    %eax,%edx
 773:	8b 45 fc             	mov    -0x4(%ebp),%eax
 776:	8b 00                	mov    (%eax),%eax
 778:	39 c2                	cmp    %eax,%edx
 77a:	75 24                	jne    7a0 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 77c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77f:	8b 50 04             	mov    0x4(%eax),%edx
 782:	8b 45 fc             	mov    -0x4(%ebp),%eax
 785:	8b 00                	mov    (%eax),%eax
 787:	8b 40 04             	mov    0x4(%eax),%eax
 78a:	01 c2                	add    %eax,%edx
 78c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 78f:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 792:	8b 45 fc             	mov    -0x4(%ebp),%eax
 795:	8b 00                	mov    (%eax),%eax
 797:	8b 10                	mov    (%eax),%edx
 799:	8b 45 f8             	mov    -0x8(%ebp),%eax
 79c:	89 10                	mov    %edx,(%eax)
 79e:	eb 0a                	jmp    7aa <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 7a0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7a3:	8b 10                	mov    (%eax),%edx
 7a5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7a8:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 7aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ad:	8b 40 04             	mov    0x4(%eax),%eax
 7b0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 7b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ba:	01 d0                	add    %edx,%eax
 7bc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 7bf:	75 20                	jne    7e1 <free+0xcf>
    p->s.size += bp->s.size;
 7c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7c4:	8b 50 04             	mov    0x4(%eax),%edx
 7c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7ca:	8b 40 04             	mov    0x4(%eax),%eax
 7cd:	01 c2                	add    %eax,%edx
 7cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7d2:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 7d5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7d8:	8b 10                	mov    (%eax),%edx
 7da:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7dd:	89 10                	mov    %edx,(%eax)
 7df:	eb 08                	jmp    7e9 <free+0xd7>
  } else
    p->s.ptr = bp;
 7e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e4:	8b 55 f8             	mov    -0x8(%ebp),%edx
 7e7:	89 10                	mov    %edx,(%eax)
  freep = p;
 7e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7ec:	a3 60 0c 00 00       	mov    %eax,0xc60
}
 7f1:	90                   	nop
 7f2:	c9                   	leave  
 7f3:	c3                   	ret    

000007f4 <morecore>:

static Header*
morecore(uint nu)
{
 7f4:	55                   	push   %ebp
 7f5:	89 e5                	mov    %esp,%ebp
 7f7:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 7fa:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 801:	77 07                	ja     80a <morecore+0x16>
    nu = 4096;
 803:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 80a:	8b 45 08             	mov    0x8(%ebp),%eax
 80d:	c1 e0 03             	shl    $0x3,%eax
 810:	83 ec 0c             	sub    $0xc,%esp
 813:	50                   	push   %eax
 814:	e8 59 fc ff ff       	call   472 <sbrk>
 819:	83 c4 10             	add    $0x10,%esp
 81c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 81f:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 823:	75 07                	jne    82c <morecore+0x38>
    return 0;
 825:	b8 00 00 00 00       	mov    $0x0,%eax
 82a:	eb 26                	jmp    852 <morecore+0x5e>
  hp = (Header*)p;
 82c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 82f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 832:	8b 45 f0             	mov    -0x10(%ebp),%eax
 835:	8b 55 08             	mov    0x8(%ebp),%edx
 838:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 83b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 83e:	83 c0 08             	add    $0x8,%eax
 841:	83 ec 0c             	sub    $0xc,%esp
 844:	50                   	push   %eax
 845:	e8 c8 fe ff ff       	call   712 <free>
 84a:	83 c4 10             	add    $0x10,%esp
  return freep;
 84d:	a1 60 0c 00 00       	mov    0xc60,%eax
}
 852:	c9                   	leave  
 853:	c3                   	ret    

00000854 <malloc>:

void*
malloc(uint nbytes)
{
 854:	55                   	push   %ebp
 855:	89 e5                	mov    %esp,%ebp
 857:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 85a:	8b 45 08             	mov    0x8(%ebp),%eax
 85d:	83 c0 07             	add    $0x7,%eax
 860:	c1 e8 03             	shr    $0x3,%eax
 863:	83 c0 01             	add    $0x1,%eax
 866:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 869:	a1 60 0c 00 00       	mov    0xc60,%eax
 86e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 871:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 875:	75 23                	jne    89a <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 877:	c7 45 f0 58 0c 00 00 	movl   $0xc58,-0x10(%ebp)
 87e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 881:	a3 60 0c 00 00       	mov    %eax,0xc60
 886:	a1 60 0c 00 00       	mov    0xc60,%eax
 88b:	a3 58 0c 00 00       	mov    %eax,0xc58
    base.s.size = 0;
 890:	c7 05 5c 0c 00 00 00 	movl   $0x0,0xc5c
 897:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 89d:	8b 00                	mov    (%eax),%eax
 89f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a5:	8b 40 04             	mov    0x4(%eax),%eax
 8a8:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8ab:	72 4d                	jb     8fa <malloc+0xa6>
      if(p->s.size == nunits)
 8ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b0:	8b 40 04             	mov    0x4(%eax),%eax
 8b3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 8b6:	75 0c                	jne    8c4 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 8b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8bb:	8b 10                	mov    (%eax),%edx
 8bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8c0:	89 10                	mov    %edx,(%eax)
 8c2:	eb 26                	jmp    8ea <malloc+0x96>
      else {
        p->s.size -= nunits;
 8c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8c7:	8b 40 04             	mov    0x4(%eax),%eax
 8ca:	2b 45 ec             	sub    -0x14(%ebp),%eax
 8cd:	89 c2                	mov    %eax,%edx
 8cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d2:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8d8:	8b 40 04             	mov    0x4(%eax),%eax
 8db:	c1 e0 03             	shl    $0x3,%eax
 8de:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 8e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e4:	8b 55 ec             	mov    -0x14(%ebp),%edx
 8e7:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 8ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ed:	a3 60 0c 00 00       	mov    %eax,0xc60
      return (void*)(p + 1);
 8f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f5:	83 c0 08             	add    $0x8,%eax
 8f8:	eb 3b                	jmp    935 <malloc+0xe1>
    }
    if(p == freep)
 8fa:	a1 60 0c 00 00       	mov    0xc60,%eax
 8ff:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 902:	75 1e                	jne    922 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 904:	83 ec 0c             	sub    $0xc,%esp
 907:	ff 75 ec             	pushl  -0x14(%ebp)
 90a:	e8 e5 fe ff ff       	call   7f4 <morecore>
 90f:	83 c4 10             	add    $0x10,%esp
 912:	89 45 f4             	mov    %eax,-0xc(%ebp)
 915:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 919:	75 07                	jne    922 <malloc+0xce>
        return 0;
 91b:	b8 00 00 00 00       	mov    $0x0,%eax
 920:	eb 13                	jmp    935 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 922:	8b 45 f4             	mov    -0xc(%ebp),%eax
 925:	89 45 f0             	mov    %eax,-0x10(%ebp)
 928:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92b:	8b 00                	mov    (%eax),%eax
 92d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 930:	e9 6d ff ff ff       	jmp    8a2 <malloc+0x4e>
}
 935:	c9                   	leave  
 936:	c3                   	ret    
